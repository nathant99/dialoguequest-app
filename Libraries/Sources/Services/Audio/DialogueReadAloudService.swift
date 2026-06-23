import AVFoundation
import Foundation
import os
import Models

/// Phase 3 read-aloud service. Walks a `DialogueTree` depth-first and
/// queues per-line utterances through `AVSpeechSynthesizer` with per-character
/// voice variants derived from the kid-authored `voiceRegister` keywords.
///
/// Per-character mapping is deterministic + on-device: no entitlements,
/// no microphone usage, no outbound network. Voice selection picks a
/// stable English voice from the system pool by hashing the character's
/// name; pitch + rate nudges come from the `voiceRegister` lexicon
/// (e.g., "soft" → lower pitch + slower rate; "energetic" → higher rate).
///
/// The synthesizer + delegate live on a private nonisolated coordinator
/// so AVSpeechSynthesizer's off-actor callback queue doesn't trip the
/// `_dispatch_assert_queue_fail` heisenbug (per `.claude/rules/concurrency.md`
/// § "Extension to framework-delegate protocols invoked off-actor").
@MainActor
@Observable
public final class DialogueReadAloudService {
    public enum Phase: Equatable, Sendable {
        case idle
        case playing(currentNodeID: UUID)
        case completed
    }

    /// Stable canonical voice identifiers shipped on every iOS device.
    /// Selecting from a curated pool keeps per-character voices recognizable
    /// across re-listens, even when the system voice list changes order.
    nonisolated public static let canonicalVoiceIdentifiers: [String] = [
        "com.apple.voice.compact.en-US.Samantha",
        "com.apple.voice.compact.en-GB.Daniel",
        "com.apple.voice.compact.en-AU.Karen",
        "com.apple.voice.compact.en-US.Aaron",
    ]

    public private(set) var phase: Phase = .idle

    @ObservationIgnored
    private let coordinator: SpeechCoordinator

    public init() {
        self.coordinator = SpeechCoordinator()
        self.coordinator.didFinishHandler = { [weak self] currentNodeID in
            // Coordinator delegate fires on AVSpeechSynthesizer's queue —
            // hop to main via DispatchQueue.main.async (NOT Task { @MainActor })
            // to avoid the `_dispatch_assert_queue_fail` heisenbug class.
            DispatchQueue.main.async { [weak self] in
                self?.advance(currentNodeID: currentNodeID)
            }
        }
    }

    /// Begin walking `tree` depth-first. Cancels any in-flight playback.
    public func play(tree: DialogueTree) {
        stop()
        let jobs = DialogueAudioExporter.renderJobs(for: tree)
        let nodeIDs = Self.depthFirstNodes(in: tree).map(\.id)
        guard !jobs.isEmpty else {
            phase = .completed
            return
        }
        coordinator.queue(jobs: jobs, nodeIDs: nodeIDs)
        if let firstID = nodeIDs.first {
            phase = .playing(currentNodeID: firstID)
        }
        coordinator.start()
    }

    /// Stop any in-flight playback. Idempotent.
    public func stop() {
        coordinator.stop()
        phase = .idle
    }

    private func advance(currentNodeID: UUID?) {
        if let nextID = currentNodeID {
            phase = .playing(currentNodeID: nextID)
        } else {
            phase = .completed
        }
    }

    // MARK: - Pure helpers (testable in isolation)

    nonisolated public static func depthFirstNodes(in tree: DialogueTree) -> [DialogueNode] {
        var ordered: [DialogueNode] = []
        let lookup = Dictionary(uniqueKeysWithValues: tree.nodes.map { ($0.id, $0) })
        var stack: [UUID] = [tree.rootNodeID]
        var visited: Set<UUID> = []
        while let id = stack.popLast() {
            guard !visited.contains(id), let node = lookup[id] else { continue }
            visited.insert(id)
            ordered.append(node)
            // Reverse so children play left-to-right (stack is LIFO).
            for childID in node.children.reversed() {
                stack.append(childID)
            }
        }
        return ordered
    }

    /// Composes the spoken text for a node — speaker name + line, plus a
    /// brief beat for action tags so a `.action("Iris looks away.")` reads
    /// aloud naturally.
    nonisolated public static func composedSpoken(for node: DialogueNode) -> String {
        switch node.tag {
        case .said:
            return node.surfaceText
        case .action(let beat):
            // Action beats render as a narrator-style aside; the kid hears
            // the body language as a tone shift in the playback.
            if node.surfaceText.isEmpty {
                return beat
            }
            return "\(beat) \(node.surfaceText)"
        case .unattributed:
            return node.surfaceText
        }
    }

    /// Per-voice-register pace nudge. Pure value-type lookup so tests can
    /// pin the exact rate / pitch / post-delay for every register keyword.
    public nonisolated struct PaceNudge: Equatable, Sendable {
        public let rate: Float
        public let pitch: Float
        public let postDelay: TimeInterval

        public init(rate: Float, pitch: Float, postDelay: TimeInterval) {
            self.rate = rate
            self.pitch = pitch
            self.postDelay = postDelay
        }

        /// Default nudge — close to AVSpeechUtterance defaults but slightly
        /// slowed so kids tracking the script can read along.
        public nonisolated static let `default` = PaceNudge(
            rate: AVSpeechUtteranceDefaultSpeechRate * 0.94,
            pitch: 1.0,
            postDelay: 0.32
        )
    }

    nonisolated public static func paceNudge(for register: String) -> PaceNudge {
        let lowercased = register.lowercased()
        var rate: Float = PaceNudge.default.rate
        var pitch: Float = 1.0
        var postDelay: TimeInterval = PaceNudge.default.postDelay

        // Speed signals
        if lowercased.contains("fast") || lowercased.contains("rapid") || lowercased.contains("energetic") || lowercased.contains("excited") {
            rate = min(rate + 0.06, AVSpeechUtteranceMaximumSpeechRate)
        }
        if lowercased.contains("slow") || lowercased.contains("careful") || lowercased.contains("measured") || lowercased.contains("deliberate") {
            rate = max(rate - 0.06, AVSpeechUtteranceMinimumSpeechRate)
            postDelay += 0.10
        }

        // Pitch signals
        if lowercased.contains("low") || lowercased.contains("deep") || lowercased.contains("grave") || lowercased.contains("brogue") {
            pitch = max(pitch - 0.15, 0.5)
        }
        if lowercased.contains("high") || lowercased.contains("bright") || lowercased.contains("airy") || lowercased.contains("lilting") {
            pitch = min(pitch + 0.15, 2.0)
        }

        // Texture signals
        if lowercased.contains("soft") || lowercased.contains("quiet") || lowercased.contains("hushed") || lowercased.contains("whisper") {
            rate = max(rate - 0.03, AVSpeechUtteranceMinimumSpeechRate)
            postDelay += 0.06
        }
        if lowercased.contains("pause") || lowercased.contains("hesitant") || lowercased.contains("thoughtful") {
            postDelay += 0.18
        }

        return PaceNudge(rate: rate, pitch: pitch, postDelay: postDelay)
    }
}

/// Off-actor speech coordinator. Lives in a `nonisolated final class` so
/// `AVSpeechSynthesizerDelegate` callbacks don't inherit MainActor
/// isolation (per `.claude/rules/concurrency.md` § "Extension to
/// framework-delegate protocols invoked off-actor"). Mutable state is
/// guarded by `OSAllocatedUnfairLock` — value-type Sendable storage
/// (no AVSpeechUtterance instances in the lock), so the closure capture
/// passes Swift 6 strict-concurrency.
private final class SpeechCoordinator: NSObject, AVSpeechSynthesizerDelegate {
    typealias DidFinishHandler = @Sendable (UUID?) -> Void

    private let synthesizer = AVSpeechSynthesizer()
    private let state = OSAllocatedUnfairLock<CoordinatorState>(initialState: CoordinatorState())
    private let handlerLock = OSAllocatedUnfairLock<DidFinishHandler?>(initialState: nil)

    var didFinishHandler: DidFinishHandler? {
        get { handlerLock.withLock { $0 } }
        set { handlerLock.withLock { $0 = newValue } }
    }

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func queue(jobs: [DialogueAudioExporter.RenderJob], nodeIDs: [UUID]) {
        state.withLock { s in
            s.jobs = jobs
            s.nodeIDs = nodeIDs
            s.index = 0
        }
    }

    func start() {
        let nextJob = state.withLock { s -> DialogueAudioExporter.RenderJob? in
            guard s.index < s.jobs.count else { return nil }
            let j = s.jobs[s.index]
            s.index += 1
            return j
        }
        if let job = nextJob {
            synthesizer.speak(job.makeUtterance())
        }
    }

    func stop() {
        state.withLock { s in
            s.jobs.removeAll()
            s.nodeIDs.removeAll()
            s.index = 0
        }
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    // MARK: - AVSpeechSynthesizerDelegate (off-actor)

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        let nextJob = state.withLock { s -> DialogueAudioExporter.RenderJob? in
            guard s.index < s.jobs.count else { return nil }
            let j = s.jobs[s.index]
            s.index += 1
            return j
        }
        if let job = nextJob {
            synthesizer.speak(job.makeUtterance())
        }
        // After didFinish, `index` points at the NEXT utterance — that's
        // the node the kid is now hearing (until didFinish fires again).
        let currentNodeID = state.withLock { s -> UUID? in
            guard s.index < s.nodeIDs.count else { return nil }
            return s.nodeIDs[s.index]
        }
        if let handler = didFinishHandler {
            handler(currentNodeID)
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        // No-op — `stop()` already cleared state.
    }
}

private struct CoordinatorState: Sendable {
    var jobs: [DialogueAudioExporter.RenderJob] = []
    var nodeIDs: [UUID] = []
    var index: Int = 0
}
