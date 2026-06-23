import Foundation
import Models

/// Phase 3 voice-acting coach scaffold per FEATURE_PLAN row 144. The kid
/// picks a cast member (or a kid-authored character), records a short voice
/// sample reading one of the character's sample lines, and the service
/// scores how close the recorded transcript reads to the character's voice
/// baseline (catchphrase pool / register guidance).
///
/// **Safety pattern (privacy-gated framework)** per
/// `@.claude/rules/warnings.md` § "Privacy-Gated Frameworks": every public
/// entry point is a NO-OP when the Xcode GUI work in
/// `@Docs/HANDOFF_TO_USER_VOICE_ACTING_COACH_INFOPLIST.md` has not landed.
/// We check both `NSMicrophoneUsageDescription` AND
/// `NSSpeechRecognitionUsageDescription` because iOS hard-crashes the
/// process the moment either gated API is invoked without the matching
/// Info.plist key (`This app has crashed because it attempted to access
/// privacy-sensitive data without a usage description`).
///
/// **Score model**: pure value-type Jaccard token-overlap of the recorded
/// transcript vs the character's voice baseline string. Reuses
/// `VoiceConsistencyAnalyzer.score(sample:against:)` so the scoring rubric
/// stays consistent with how Patter scores written lines today. The kid
/// gets the same `WritingEvaluator.VoiceBand` rollup the analyzer already
/// surfaces (`.spotOn` / `.close` / `.drift` / `.offRegister`).
///
/// **Future wired path** (post Info.plist + entitlement GUI work):
///   1. `requestAuthorization()` chains
///      `AVAudioApplication.requestRecordPermission` +
///      `SFSpeechRecognizer.requestAuthorization` per the on-device locale.
///   2. `startRecording(castID:promptLine:)` installs an `AVAudioNodeTap`
///      following the TWO-PART rule per `@.claude/rules/concurrency.md`:
///      no `self` capture; `OSAllocatedUnfairLock` Sendable accumulator;
///      `@Sendable` annotation on the tap block; AVAudio buffer drained
///      at the MainActor boundary inside `stopRecording()`.
///   3. `stopRecording()` runs the recognizer on the drained buffer and
///      hands the transcript to `scoreTranscript(_:against:)` which is
///      the only function callable from tests today (pure value-type).
///
/// **What's NOT in this scaffold** (intentional):
///   - Actual microphone access — gated on user GUI handoff (Info.plist +
///     `NSMicrophoneUsageDescription` string).
///   - Actual `SFSpeechRecognizer` instance — gated on
///     `NSSpeechRecognitionUsageDescription` string.
///   - Persistent recording bundle — Phase 3 design is on-device only +
///     ephemeral; transcripts vanish after scoring.
///   - Server round-trips — no outbound network ever (COPPA-safe + the
///     standing rule "All data on-device").
@MainActor
public final class VoiceActingCoachService {
    public static let shared = VoiceActingCoachService()

    /// Reader-facing availability states. Mirrors the
    /// `DeclaredAgeRangeGate.Status` pattern + adds `.unavailable` for the
    /// case where the user explicitly denied permission after wiring.
    public enum Availability: Sendable, Equatable {
        /// One or both Info.plist usage descriptions missing. Default
        /// state for the scaffold today.
        case notWired
        /// Wired, but the kid (or kid's parent) hasn't tapped to grant
        /// permission yet. Stays here until a future PR wires
        /// `requestAuthorization()`.
        case notRequested
        /// User denied at the system prompt OR `SFSpeechRecognizer.isAvailable`
        /// returned false for the device's current locale.
        case unavailable
        /// Both Info.plist strings present, both system authorizations
        /// granted, recognizer reports ready. Today the scaffold never
        /// reaches this state (the wired path is gated on user GUI work).
        case ready
    }

    /// Per `@.claude/rules/warnings.md` § "Privacy-Gated Frameworks":
    /// cache the entitlement probe at static-let init so subsequent reads
    /// are O(1) and never re-enter the Bundle dictionary. We check BOTH
    /// keys because either missing causes a hard crash on first API use.
    public static let isWired: Bool = {
        let micKey = "NSMicrophoneUsageDescription"
        let speechKey = "NSSpeechRecognitionUsageDescription"
        let micWired = (Bundle.main.object(forInfoDictionaryKey: micKey) as? String)
            .map { !$0.trimmingCharacters(in: .whitespaces).isEmpty } ?? false
        let speechWired = (Bundle.main.object(forInfoDictionaryKey: speechKey) as? String)
            .map { !$0.trimmingCharacters(in: .whitespaces).isEmpty } ?? false
        return micWired && speechWired
    }()

    private init() {}

    /// Current availability. Stays at `.notWired` until the Info.plist
    /// handoff completes; stays at `.notRequested` once wired but before
    /// a future PR adds the authorization request surface.
    public var availability: Availability {
        if !Self.isWired { return .notWired }
        return .notRequested
    }

    /// Reader-friendly description for parent-dashboard surfaces.
    public var availabilityDescription: String {
        switch availability {
        case .notWired:
            return "Voice-acting coach: not yet enabled. A parent or guardian needs to enable microphone + speech recognition for DialogueQuest before the coach can listen."
        case .notRequested:
            return "Voice-acting coach: ready. A future update will let you tap to record a line and hear how close it sounds to the character."
        case .unavailable:
            return "Voice-acting coach: unavailable. The kid (or kid's parent) chose not to share microphone or speech recognition with DialogueQuest."
        case .ready:
            return "Voice-acting coach: ready. Pick a character, read a line, get a voice-match score."
        }
    }

    // MARK: - Pure scoring surface (always callable; no privacy gate needed)

    /// Score a recorded transcript against a character's voice baseline.
    /// Delegates to `VoiceConsistencyAnalyzer.score(sample:against:)` so the
    /// rubric matches how Patter scores written lines.
    ///
    /// Always callable — no microphone or speech-recognition state is
    /// touched. This is the function the future wired path will hand its
    /// drained recognizer transcript to.
    ///
    /// - Parameters:
    ///   - transcript: The recognizer's transcription of the kid's voice.
    ///   - baseline: The character's voice baseline (catchphrase pool / sample lines
    ///     joined; for cast members, prefer `CastVoiceRegistry.voiceBaseline(for:)`).
    /// - Returns: 0.0–1.0 voice-match score (1.0 = perfect overlap).
    public nonisolated static func scoreTranscript(_ transcript: String, against baseline: String) -> Double {
        return VoiceConsistencyAnalyzer.score(sample: transcript, against: baseline)
    }

    /// Map a numeric score onto the canonical `WritingEvaluator.VoiceBand`
    /// rollup so coach surfaces use the same kid-facing language Patter
    /// uses elsewhere.
    public nonisolated static func band(forScore score: Double) -> WritingEvaluator.VoiceBand {
        return WritingEvaluator.VoiceBand.band(for: score)
    }

    /// Reader-friendly per-band coaching line. Register stoplist-clean per
    /// `@.claude/rules/distributed-narrative.md` § R-CHAPTER-REGISTER.
    public nonisolated static func coachingLine(forBand band: WritingEvaluator.VoiceBand, characterName: String) -> String {
        switch band {
        case .strong:
            return "\(characterName)'s voice — that's exactly them. The match is uncanny."
        case .acceptable:
            return "Close. \(characterName) lives in that voice for the most part — a few words could be theirs even more."
        case .drifting:
            return "The voice drifted. \(characterName) has their own rhythm — try the line again and listen for the word they would never say."
        }
    }

    // MARK: - Active session (privacy-gated)

    /// Lazily-built active session. Only ever instantiated when
    /// `Self.isWired == true`. Until the Info.plist handoff lands,
    /// `makeActiveSession()` returns nil and every caller falls back to
    /// the pure scoring surface.
    private var cachedActiveSession: VoiceActingCoachActiveSession?

    /// Returns an active-recording session when the Info.plist usage
    /// descriptions are wired; nil otherwise. Callers MUST branch on the
    /// returned optional — invoking the session on an unwired build is a
    /// caller bug + would hard-crash the process if it were possible.
    public func makeActiveSession() -> VoiceActingCoachActiveSession? {
        guard Self.isWired else { return nil }
        if let cached = cachedActiveSession {
            return cached
        }
        let session = VoiceActingCoachActiveSession()
        cachedActiveSession = session
        return session
    }

    /// For tests + for parents who want to reset coach state without
    /// closing the app. Cancels any in-flight session.
    public func resetActiveSession() {
        cachedActiveSession?.cancel()
        cachedActiveSession = nil
    }
}
