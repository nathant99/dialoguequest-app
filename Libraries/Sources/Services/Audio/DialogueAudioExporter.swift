import AVFoundation
import Foundation
import os
import Models

/// Phase 3 audio exporter. Renders a `DialogueTree` to a single AIFF file
/// on disk via `AVSpeechSynthesizer.write(_:toBufferCallback:)` — offline
/// rendering, no microphone permission, no audio session reservation,
/// no outbound network.
///
/// Per-character voice variants reuse `DialogueReadAloudService`'s pure
/// `utterance(for:in:)` helper so playback and export sound identical.
///
/// The export pipeline runs on a detached cooperative-pool task so the
/// MainActor isn't pinned by an on-device render that can take several
/// seconds for a 15-node tree. Buffer accumulation uses
/// `OSAllocatedUnfairLock` (Sendable) so the AVSpeechSynthesizer callback
/// can write from any thread.
public struct DialogueAudioExporter: Sendable {

    public enum ExportError: Error, Sendable, Equatable {
        case emptyTree
        case writeFailed(String)
    }

    public init() {}

    /// Pure value-type render job built on the MainActor — Sendable so
    /// the detached render task can rebuild AVSpeechUtterance instances
    /// off-actor without sending non-Sendable AVFoundation class types
    /// across the actor boundary.
    public struct RenderJob: Sendable, Hashable {
        public let text: String
        public let voiceIdentifier: String?
        public let voiceLanguage: String
        public let rate: Float
        public let pitchMultiplier: Float
        public let preUtteranceDelay: TimeInterval
        public let postUtteranceDelay: TimeInterval

        public init(
            text: String,
            voiceIdentifier: String?,
            voiceLanguage: String,
            rate: Float,
            pitchMultiplier: Float,
            preUtteranceDelay: TimeInterval,
            postUtteranceDelay: TimeInterval
        ) {
            self.text = text
            self.voiceIdentifier = voiceIdentifier
            self.voiceLanguage = voiceLanguage
            self.rate = rate
            self.pitchMultiplier = pitchMultiplier
            self.preUtteranceDelay = preUtteranceDelay
            self.postUtteranceDelay = postUtteranceDelay
        }

        public nonisolated func makeUtterance() -> AVSpeechUtterance {
            let u = AVSpeechUtterance(string: text)
            if let id = voiceIdentifier, let voice = AVSpeechSynthesisVoice(identifier: id) {
                u.voice = voice
            } else {
                u.voice = AVSpeechSynthesisVoice(language: voiceLanguage)
            }
            u.rate = rate
            u.pitchMultiplier = pitchMultiplier
            u.preUtteranceDelay = preUtteranceDelay
            u.postUtteranceDelay = postUtteranceDelay
            return u
        }
    }

    /// Render `tree` to an AIFF at a freshly-generated URL inside the
    /// caller's preferred directory (default: temporary directory).
    ///
    /// The file is suitable for `ShareLink(item: URL)`. Callers are
    /// responsible for cleaning up the temp file when share is complete.
    public func exportAIFF(
        tree: DialogueTree,
        outputDirectory: URL = FileManager.default.temporaryDirectory
    ) async throws -> URL {
        let jobs = Self.renderJobs(for: tree)
        guard !jobs.isEmpty else {
            throw ExportError.emptyTree
        }

        let filename = Self.sanitizedFilename(tree.title, fallback: "dialogue") + ".aiff"
        let outputURL = outputDirectory.appendingPathComponent(filename)

        // Clear any prior render at the same URL.
        do {
            try FileManager.default.removeItem(at: outputURL)
        } catch CocoaError.fileNoSuchFile {
            // Expected on first render — no log emission for the steady-state path.
        } catch {
            DialogueQuestDebugLog.data(
                "DialogueAudioExporter.exportAIFF — failed to clear prior render at \(outputURL.lastPathComponent); render may write into a stale file",
                error: error
            )
        }

        return try await Self.performRender(jobs: jobs, outputURL: outputURL)
    }

    /// Pure value-type planner — builds the Sendable render-job list
    /// from a tree. Reused by tests to assert the planning surface
    /// without touching AVFoundation.
    public static func renderJobs(for tree: DialogueTree) -> [RenderJob] {
        let nodes = DialogueReadAloudService.depthFirstNodes(in: tree)
        return nodes.map { node in
            let character = tree.characters.first(where: { $0.id == node.speakerID })
            let nudge = DialogueReadAloudService.paceNudge(for: character?.voiceRegister ?? "")
            let identifier: String?
            if let character {
                let identifiers = DialogueReadAloudService.canonicalVoiceIdentifiers
                if !identifiers.isEmpty {
                    let stable = abs(character.name.unicodeScalars.reduce(0) { $0 &+ Int($1.value) })
                    identifier = identifiers[stable % identifiers.count]
                } else {
                    identifier = nil
                }
            } else {
                identifier = nil
            }
            return RenderJob(
                text: DialogueReadAloudService.composedSpoken(for: node),
                voiceIdentifier: identifier,
                voiceLanguage: "en-US",
                rate: nudge.rate,
                pitchMultiplier: nudge.pitch,
                preUtteranceDelay: 0.18,
                postUtteranceDelay: nudge.postDelay
            )
        }
    }

    /// Filename-safe slug shared with `DialogueTreeShareable`. Keeps
    /// alphanumerics + dash + underscore + space; collapses others to `_`;
    /// clamps to 60 chars; falls back when the title is empty / all punctuation.
    public static func sanitizedFilename(_ raw: String, fallback: String) -> String {
        let allowed = CharacterSet.alphanumerics
            .union(CharacterSet(charactersIn: "-_ "))
        let collapsed = raw.unicodeScalars.map { scalar -> Character in
            if allowed.contains(scalar) { return Character(scalar) }
            return "_"
        }
        let trimmed = String(collapsed).trimmingCharacters(in: .whitespacesAndNewlines)
        let alnum = trimmed.unicodeScalars.contains { CharacterSet.alphanumerics.contains($0) }
        guard alnum else { return fallback }
        return String(trimmed.prefix(60))
    }

    /// Detached render — synthesizer + lock-protected file accumulator
    /// live entirely off the MainActor.
    private static func performRender(
        jobs: [RenderJob],
        outputURL: URL
    ) async throws -> URL {
        try await Task.detached(priority: .userInitiated) {
            try await renderSync(jobs: jobs, outputURL: outputURL)
            return outputURL
        }.value
    }

    private static func renderSync(
        jobs: [RenderJob],
        outputURL: URL
    ) async throws {
        let fileLock = OSAllocatedUnfairLock<AVAudioFile?>(initialState: nil)
        let errorLock = OSAllocatedUnfairLock<ExportError?>(initialState: nil)
        let synth = AVSpeechSynthesizer()

        for job in jobs {
            try await renderOne(
                utterance: job.makeUtterance(),
                synth: synth,
                outputURL: outputURL,
                fileLock: fileLock,
                errorLock: errorLock
            )
            if let err = errorLock.withLock({ $0 }) {
                fileLock.withLock { $0 = nil }
                throw err
            }
        }
        // Force-close the file by releasing the AVAudioFile reference.
        fileLock.withLock { $0 = nil }
    }

    private static func renderOne(
        utterance: AVSpeechUtterance,
        synth: AVSpeechSynthesizer,
        outputURL: URL,
        fileLock: OSAllocatedUnfairLock<AVAudioFile?>,
        errorLock: OSAllocatedUnfairLock<ExportError?>
    ) async throws {
        let resumedLock = OSAllocatedUnfairLock<Bool>(initialState: false)
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            synth.write(utterance) { buffer in
                guard let pcm = buffer as? AVAudioPCMBuffer else { return }
                if pcm.frameLength == 0 {
                    // AVSpeechSynthesizer signals end-of-utterance with a
                    // zero-length buffer. Resume the continuation once.
                    let firstFinish = resumedLock.withLock { resumed -> Bool in
                        if resumed { return false }
                        resumed = true
                        return true
                    }
                    if firstFinish {
                        cont.resume()
                    }
                    return
                }
                fileLock.withLock { file in
                    if file == nil {
                        do {
                            file = try AVAudioFile(
                                forWriting: outputURL,
                                settings: pcm.format.settings,
                                commonFormat: pcm.format.commonFormat,
                                interleaved: pcm.format.isInterleaved
                            )
                        } catch {
                            errorLock.withLock { $0 = .writeFailed(error.localizedDescription) }
                        }
                    }
                    if let f = file {
                        do {
                            try f.write(from: pcm)
                        } catch {
                            errorLock.withLock { $0 = .writeFailed(error.localizedDescription) }
                        }
                    }
                }
            }
        }
    }
}
