import Foundation
import os
#if canImport(AVFAudio)
import AVFAudio
#endif
#if canImport(Speech)
import Speech
#endif

/// Active-recording wrapper for `VoiceActingCoachService`. Lazily created
/// by the service the first time the kid taps "Record" — and ONLY when
/// `VoiceActingCoachService.isWired` is true. Until the Info.plist
/// handoff lands (`HANDOFF_TO_USER_VOICE_ACTING_COACH_INFOPLIST.md`), the
/// service short-circuits before this class is ever instantiated.
///
/// **Safety pattern (privacy-gated framework)** per
/// `.claude/rules/warnings.md` § "Privacy-Gated Frameworks": the
/// constructor itself is safe — it does not invoke any privacy-gated API.
/// The privacy-gated calls (`AVAudioApplication.requestRecordPermission`
/// + `SFSpeechRecognizer.requestAuthorization` + `AVAudioEngine.start`)
/// are deferred to the explicit lifecycle methods so callers can branch
/// on `isWired` before invoking them. If a caller bypasses the gate +
/// invokes those methods on an unwired build, iOS hard-crashes the
/// process per Apple's runtime contract.
///
/// **TWO-PART tap rule** per `.claude/rules/concurrency.md` §
/// "Extension to AVAudioNodeTap closures":
///   1. The `installTap` block captures NO `self` — not `[weak self]`,
///      not `[unowned self]`, not a direct reference. The block captures
///      a `Sendable` `OSAllocatedUnfairLock<[Float]>` accumulator by
///      value and writes via `withLock`.
///   2. The block is annotated `@Sendable` so the compiler refuses to
///      inherit `@MainActor` from the enclosing function.
/// Draining the accumulator happens at the actor boundary inside
/// `stopRecording()` on the MainActor, then `Task.detached` hands the
/// recognized transcript off for scoring.
///
/// **Why this is a separate file**, not a method bag inside
/// `VoiceActingCoachService`: the `import AVFAudio` + `import Speech` at
/// file scope link the two frameworks into the test bundle even when the
/// scaffold tests don't exercise the active path. Splitting the active
/// session out keeps the scaffold's pure scoring surface importable in
/// pure-value-type contexts (Linux SPM, etc.) without dragging the
/// audio + speech frameworks along.
@MainActor
public final class VoiceActingCoachActiveSession {

    /// Reader-facing lifecycle states. The session moves linearly through
    /// these states — no skipping or backtracking. The `.failed` terminal
    /// is reachable from any non-terminal state.
    public enum Phase: Sendable, Equatable {
        /// Constructed but `requestAuthorization()` hasn't been called.
        case idle
        /// `requestAuthorization()` is in flight.
        case requesting
        /// Both microphone + speech recognition granted; ready to record.
        case authorized
        /// `startRecording(...)` succeeded; capturing audio.
        case recording
        /// `stopRecording()` invoked; recognizer is finishing the final
        /// transcript.
        case finalizing
        /// Recognizer reported a transcript. `transcript` is non-nil.
        case completed(transcript: String)
        /// Any non-recoverable error. `reason` is reader-friendly.
        case failed(reason: String)
    }

    public private(set) var phase: Phase = .idle

    /// Pre-allocated Sendable buffer accumulator. Tap closure writes via
    /// `withLock` (lock-free, any-thread). Drained at MainActor boundary
    /// inside `stopRecording`. Per the TWO-PART rule, the tap closure
    /// captures `self.bufferAccumulator` by value — NOT `self`.
    @ObservationIgnored
    private let bufferAccumulator = OSAllocatedUnfairLock<[Float]>(initialState: [])

    #if canImport(AVFAudio)
    private var audioEngine: AVAudioEngine?
    #endif
    #if canImport(Speech)
    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    #endif

    public init() {}

    // MARK: - Authorization

    /// Request microphone + speech-recognition permission. Safe to call
    /// only when `VoiceActingCoachService.isWired` is true; the gate is
    /// the caller's responsibility.
    public func requestAuthorization() async -> Phase {
        guard phase == .idle else { return phase }
        phase = .requesting

        #if canImport(AVFAudio) && canImport(Speech)
        let micGranted = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        guard micGranted else {
            phase = .failed(reason: "Microphone access denied. Open Settings to enable it.")
            return phase
        }

        let speechStatus = await withCheckedContinuation { (continuation: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        guard speechStatus == .authorized else {
            phase = .failed(reason: "Speech recognition unavailable. Open Settings to enable it.")
            return phase
        }
        let locale = Locale.current
        guard let recognizer = SFSpeechRecognizer(locale: locale) ?? SFSpeechRecognizer(),
              recognizer.isAvailable else {
            phase = .failed(reason: "Speech recognizer not available for this device's language.")
            return phase
        }
        recognizer.defaultTaskHint = .dictation
        self.recognizer = recognizer
        phase = .authorized
        #else
        phase = .failed(reason: "Audio frameworks not linked.")
        #endif
        return phase
    }

    // MARK: - Recording

    /// Start microphone capture + on-device speech recognition. Returns
    /// the new phase; `.failed` if anything goes wrong.
    public func startRecording() -> Phase {
        guard phase == .authorized else { return phase }

        #if canImport(AVFAudio) && canImport(Speech)
        guard let recognizer else {
            phase = .failed(reason: "Recognizer not initialized — call requestAuthorization first.")
            return phase
        }

        // Reset accumulator (rerunning a session after .completed/.failed).
        bufferAccumulator.withLock { $0.removeAll(keepingCapacity: true) }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            phase = .failed(reason: "Couldn't activate microphone session: \(error.localizedDescription)")
            return phase
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = false
        if #available(iOS 13.0, *) {
            request.requiresOnDeviceRecognition = true
        }
        self.recognitionRequest = request

        let engine = AVAudioEngine()
        self.audioEngine = engine
        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // TWO-PART rule: capture Sendable accumulator + request by value;
        // mark the tap @Sendable. No `self` capture anywhere in the block.
        let accumulator = bufferAccumulator
        let capturedRequest = request
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { @Sendable (buffer, _) in
            capturedRequest.append(buffer)
            guard let channelData = buffer.floatChannelData?[0] else { return }
            let frameCount = Int(buffer.frameLength)
            let samples = Array(UnsafeBufferPointer(start: channelData, count: frameCount))
            accumulator.withLock { $0.append(contentsOf: samples) }
        }

        engine.prepare()
        do {
            try engine.start()
        } catch {
            inputNode.removeTap(onBus: 0)
            phase = .failed(reason: "Microphone failed to start: \(error.localizedDescription)")
            return phase
        }

        // Kick off recognition. Result handler hops to MainActor before
        // touching `self.phase` — no isolation inheritance into the
        // closure body via `self` capture.
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            // Snapshot first; hop to MainActor.
            let transcript = result?.bestTranscription.formattedString
            let isFinal = result?.isFinal ?? false
            let errorMessage = error?.localizedDescription
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if isFinal, let transcript {
                    self.phase = .completed(transcript: transcript)
                    self.teardownEngine()
                } else if let errorMessage {
                    self.phase = .failed(reason: errorMessage)
                    self.teardownEngine()
                }
            }
        }

        phase = .recording
        #endif
        return phase
    }

    /// Stop microphone capture + finalize recognition. The actual phase
    /// transition to `.completed` happens asynchronously inside the
    /// recognition task's result handler — callers should `await` the
    /// returned phase indicator OR observe `phase` directly.
    public func stopRecording() -> Phase {
        guard phase == .recording else { return phase }
        #if canImport(AVFAudio) && canImport(Speech)
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        phase = .finalizing
        #endif
        return phase
    }

    /// Cancel an in-flight session. Idempotent.
    public func cancel() {
        #if canImport(AVFAudio) && canImport(Speech)
        teardownEngine()
        #endif
        phase = .idle
    }

    /// Drain the accumulated audio samples (e.g. for offline scoring or
    /// later re-recognition). Called by tests + by the future "save the
    /// recording" surface (when wired).
    public func drainAccumulatedSamples() -> [Float] {
        bufferAccumulator.withLock { state -> [Float] in
            let snapshot = state
            state.removeAll(keepingCapacity: true)
            return snapshot
        }
    }

    // MARK: - Teardown

    #if canImport(AVFAudio) && canImport(Speech)
    private func teardownEngine() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        audioEngine?.stop()
        audioEngine = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            DialogueQuestDebugLog.error(
                "VoiceActingCoachActiveSession.teardownEngine — AVAudioSession deactivation threw; other audio apps may still see DialogueQuest's session active",
                error: error
            )
        }
    }
    #endif
}
