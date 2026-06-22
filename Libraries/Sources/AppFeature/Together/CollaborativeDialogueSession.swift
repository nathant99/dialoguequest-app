import Foundation
import Models
import ForgePassAndPlay

/// Coordinates a 2-kid co-authored dialogue session per pillar deepening
/// move C5 (Collaborative / Co-authored Dialogue) — see
/// `@Docs/HANDOFF_FROM_LABSMITH_PILLAR_DEEPENING_C5_COLLABORATIVE.md`.
///
/// Wraps ForgeKit's `PassAndPlayEngine` with `Round = CollaborativeTurnPrompt`
/// + `Score = Int` (score not actually used — the session is non-competitive
/// per Resnick "Peers" stage). The engine drives the 4-stage privacy
/// curtain so Kid B can't see Kid A's contribution mid-handoff.
///
/// Cast-anchored turn prompts: each round's prompt is voiced by one of
/// the 5 DialogueQuest cast members (Brogue / Glance / Rest / Sprig /
/// Weigh). The cast IS the collaborative scaffold per `.claude/rules/distributed-narrative.md`.
///
/// Solo path remains available: the kid can dismiss the session entry
/// sheet and write a tree alone. Per § 3.2 "What the move IS NOT" the
/// session is OPT-IN; collaboration is never mandatory.
@MainActor
@Observable
public final class CollaborativeDialogueSession {

    /// Per-turn payload — the cast-anchored prompt the kid sees BEFORE
    /// authoring their line.
    public nonisolated struct TurnPrompt: Sendable, Equatable {
        public let castDisplayName: String
        public let promptText: String
        public init(castDisplayName: String, promptText: String) {
            self.castDisplayName = castDisplayName
            self.promptText = promptText
        }
    }

    /// Phase the host view renders against.
    public enum Phase: Sendable, Equatable {
        case notStarted
        /// Active turn for `currentPlayerName`. Host renders the line
        /// composer + the cast-anchored prompt.
        case authoring(playerName: String, prompt: TurnPrompt)
        /// Privacy curtain — current player has just submitted a line;
        /// device is being handed off to the next player.
        case handoff(toName: String)
        /// Pre-reveal curtain — the next player must tap to reveal.
        case confirmReady(playerName: String)
        /// Session is complete; the artifact (`completedTree`) is
        /// ready for archive.
        case complete(tree: DialogueTree)
    }

    public private(set) var phase: Phase = .notStarted
    /// Lines authored so far in order. Each becomes a `DialogueNode`
    /// in the final `DialogueTree`.
    public private(set) var authoredLines: [AuthoredLine] = []

    @ObservationIgnored
    private var engine: PassAndPlayEngine<TurnPrompt, Int>?

    public init() {}

    /// Start a fresh session with 2 named characters + a target round
    /// count (default 6 lines = 3 per kid, mirroring the Phase 1
    /// 5-15-node tree shape).
    public func start(
        playerA: String,
        playerB: String,
        characterA: DialogueCharacterRef,
        characterB: DialogueCharacterRef,
        treeTitle: String = "Together",
        mood: DialogueMood? = nil,
        roundsPerPlayer: Int = 3,
        castPromptPool: [TurnPrompt] = CollaborativeDialogueSession.defaultCastPrompts
    ) async {
        let players: [PassAndPlayPlayer] = [
            PassAndPlayPlayer(id: "a", displayName: playerA),
            PassAndPlayPlayer(id: "b", displayName: playerB)
        ]
        let promptPool = castPromptPool
        let config = PassAndPlayConfig<TurnPrompt, Int>(
            players: players,
            rotationStyle: .roundRobin,
            roundCount: 1,
            initialScore: 0,
            roundsPerPlayer: max(1, roundsPerPlayer),
            ritualLevel: .full
        )
        // Closure captures: promptPool is Sendable (immutable struct
        // copy); avoids touching self inside the FM closure per
        // .claude/rules/concurrency.md.
        let payloadProvider: @MainActor @Sendable (PassAndPlayPlayer, Int) async -> TurnPrompt? = { _, round in
            let i = (round - 1) % promptPool.count
            return promptPool[i]
        }
        let built = PassAndPlayEngine<TurnPrompt, Int>(
            config: config,
            payloadProvider: payloadProvider
        )
        engine = built
        authoredLines = []
        sessionMetadata = SessionMetadata(
            treeTitle: treeTitle,
            mood: mood,
            characters: [characterA, characterB],
            playerToCharacter: ["a": characterA.id, "b": characterB.id]
        )
        await built.start()
        syncPhase()
    }

    /// Record the current player's authored line and advance the
    /// engine. The line text + speaker character ID are persisted to
    /// `authoredLines`; the engine moves to `.awaitingHandoff`.
    public func recordLine(_ text: String) async {
        guard let engine, let metadata = sessionMetadata else { return }
        guard case .authoring = phase else { return }
        let playerID = engine.currentPlayer.id
        guard let speakerID = metadata.playerToCharacter[playerID] else { return }
        authoredLines.append(
            AuthoredLine(
                playerID: playerID,
                speakerID: speakerID,
                surfaceText: text
            )
        )
        await engine.recordScore(0)
        syncPhase()
    }

    /// Advance from the privacy curtain's "passToNext" stage.
    /// Mirrors `PrivacyCurtain.acceptHandoff`.
    public func acceptHandoff() async {
        guard let engine else { return }
        engine.privacyCurtain.acceptHandoff()
        syncPhase()
    }

    /// Advance from the "confirmReady" stage to begin the next player's
    /// turn. Internally drives the curtain reveal + engine's
    /// `confirmHandoff()`.
    public func revealAndBegin() async {
        guard let engine else { return }
        engine.privacyCurtain.reveal()
        engine.privacyCurtain.dismiss()
        await engine.confirmHandoff()
        syncPhase()
    }

    /// End the session early ("Done for now"). Surfaces the complete
    /// phase with whatever lines were authored so far so the kid can
    /// still archive the partial artifact. Maps to the trauma-informed
    /// off-ramp per ForgeKit `SessionEndReason.offRamp`.
    public func endEarly() {
        engine?.endSession(reason: .offRamp)
        syncPhase()
    }

    // MARK: - Private

    private struct SessionMetadata {
        let treeTitle: String
        let mood: DialogueMood?
        let characters: [DialogueCharacterRef]
        let playerToCharacter: [String: UUID]
    }

    @ObservationIgnored
    private var sessionMetadata: SessionMetadata?

    private func syncPhase() {
        guard let engine, let metadata = sessionMetadata else { return }
        switch engine.phase {
        case .notStarted, .paused, .roundComplete:
            phase = .notStarted
        case .playing:
            let payload = engine.currentPayload ?? TurnPrompt(
                castDisplayName: "Patter",
                promptText: "Write the next line."
            )
            phase = .authoring(playerName: engine.currentPlayer.displayName, prompt: payload)
        case .awaitingHandoff:
            switch engine.privacyCurtain.phase {
            case .passToNext, .hidden:
                let nextName = engine.privacyCurtain.nextPlayerDisplayName
                    ?? engine.currentPlayer.displayName
                phase = .handoff(toName: nextName)
            case .confirmReady:
                phase = .confirmReady(playerName: engine.currentPlayer.displayName)
            case .revealed:
                phase = .handoff(toName: engine.currentPlayer.displayName)
            }
        case .sessionComplete:
            phase = .complete(tree: buildTree(metadata: metadata))
        }
    }

    private func buildTree(metadata: SessionMetadata) -> DialogueTree {
        // Convert authored lines to a linear branch-free tree. Phase 1
        // C5 ships the linear case; multi-branch collaborative trees
        // land in Phase 2.
        var nodes: [DialogueNode] = []
        var prior: UUID?
        for line in authoredLines {
            let node = DialogueNode(
                speakerID: line.speakerID,
                surfaceText: line.surfaceText,
                children: []
            )
            // Stitch each line as the unique child of its predecessor.
            if let priorID = prior, let idx = nodes.firstIndex(where: { $0.id == priorID }) {
                let oldNode = nodes[idx]
                nodes[idx] = DialogueNode(
                    id: oldNode.id,
                    speakerID: oldNode.speakerID,
                    surfaceText: oldNode.surfaceText,
                    inferredSubtext: oldNode.inferredSubtext,
                    tag: oldNode.tag,
                    children: [node.id],
                    createdAt: oldNode.createdAt
                )
            }
            nodes.append(node)
            prior = node.id
        }
        let rootID = nodes.first?.id ?? UUID()
        return DialogueTree(
            title: metadata.treeTitle,
            characters: metadata.characters,
            nodes: nodes,
            rootNodeID: rootID,
            mood: metadata.mood
        )
    }
}

/// One authored line in a collaborative session — the bridge between
/// the engine's per-turn record and the final `DialogueNode` shape.
public nonisolated struct AuthoredLine: Sendable, Equatable, Hashable, Identifiable {
    public let id: UUID
    public let playerID: String
    public let speakerID: UUID
    public let surfaceText: String

    public init(
        id: UUID = UUID(),
        playerID: String,
        speakerID: UUID,
        surfaceText: String
    ) {
        self.id = id
        self.playerID = playerID
        self.speakerID = speakerID
        self.surfaceText = surfaceText
    }
}

public extension CollaborativeDialogueSession {
    /// Curated cast-anchored prompt pool. Cycled per turn by the
    /// engine's payload provider. Each prompt frames the turn around
    /// one DialogueQuest cast member's primitive so the kids feel the
    /// scaffold per § 3.1 of the C5 handoff.
    static let defaultCastPrompts: [TurnPrompt] = [
        TurnPrompt(
            castDisplayName: "Sprig",
            promptText: "Open the scene. Where are these two characters, and what's the first thing one of them says?"
        ),
        TurnPrompt(
            castDisplayName: "Glance",
            promptText: "Reply to the last line. Don't say what your character means — let the line hint at it."
        ),
        TurnPrompt(
            castDisplayName: "Weigh",
            promptText: "Try a beat without an attribution. Let an action or a glance carry the speaker."
        ),
        TurnPrompt(
            castDisplayName: "Brogue",
            promptText: "Stay in your character's voice. What signature word would they slip in here?"
        ),
        TurnPrompt(
            castDisplayName: "Rest",
            promptText: "Let the silence speak. Write a line that arrives AFTER a long pause."
        ),
        TurnPrompt(
            castDisplayName: "Sprig",
            promptText: "Land the scene. What does the last line cost the speaker?"
        )
    ]
}
