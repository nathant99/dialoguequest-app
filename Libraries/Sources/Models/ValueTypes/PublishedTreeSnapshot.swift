import Foundation

/// A compact, self-contained record of a single published `DialogueTree`.
///
/// **Why this exists** (Priority P): the per-tree shape computed at
/// publish time (node count, mood, per-character voice-match summary) is
/// fed into `DDAEngine` and then discarded. The parent-progress dashboard
/// renders *outside* any active writing session, so it has no handle on
/// the tree the kid just published — only the rolling
/// `EmotionalSignalsPersistence` snapshot + the weekly counters. This
/// value type captures the per-published-tree artifact so the parent
/// dashboard can surface "your writer's longest conversation" + "their
/// most recent published mood" + "how each character sounded" without
/// re-deriving anything from a live tree.
///
/// **Distinct from `VoicePatternHistoryService`**: that service stores a
/// per-*character* rolling window of voice-match means (keyed by speaker
/// UUID) for trend classification. This type stores a per-*tree* record
/// (title + node count + mood + a self-contained per-character voice
/// list that carries the character *names* so the dashboard doesn't need
/// the live tree to resolve UUIDs). The two surfaces are complementary:
/// one answers "is Brogue's voice steadying across sessions?", the other
/// answers "what did the kid actually make, and how did it read?".
///
/// **No PII / no outbound**: every field is categorical or a clamped
/// 0...1 `Double`. Character names are the kid-authored cast labels
/// (e.g. "Sprig"), not real names; they never leave the device.
///
/// **Codable declared on the type** (not in an extension) per
/// `.claude/rules/concurrency.md` § "Codable on nonisolated struct" — the
/// default-MainActor package isolation otherwise makes the conformance
/// MainActor-isolated and breaks decode from nonisolated test contexts.
public nonisolated struct PublishedTreeSnapshot: Codable, Sendable, Hashable, Identifiable {

    /// The published tree's `id` — stable across re-publishes of the
    /// same tree so the store can de-dup if a tree is published twice.
    public let id: UUID
    /// The tree's kid-authored title.
    public let title: String
    /// Node count at publish time. Drives the "longest conversation"
    /// readout.
    public let nodeCount: Int
    /// The tree's mood, if the kid set one. `nil` when unset.
    public let mood: DialogueMood?
    /// Tree-wide mean voice-match (0...1) at publish time. `nil` when no
    /// character spoke a scored line (mirrors
    /// `WritingEvaluator.VoiceSummary.treeAverage`).
    public let treeAverageVoiceMatch: Double?
    /// Self-contained per-character voice summary. Carries the character
    /// *name* (not just the UUID) so the parent dashboard renders without
    /// a live tree to resolve names against. Sorted by name for a stable
    /// render + stable test assertions.
    public let characterVoices: [CharacterVoice]
    /// When the tree was published.
    public let publishedAt: Date

    public init(
        id: UUID,
        title: String,
        nodeCount: Int,
        mood: DialogueMood?,
        treeAverageVoiceMatch: Double?,
        characterVoices: [CharacterVoice],
        publishedAt: Date
    ) {
        self.id = id
        self.title = title
        self.nodeCount = nodeCount
        self.mood = mood
        self.treeAverageVoiceMatch = treeAverageVoiceMatch.map { max(0, min(1, $0)) }
        self.characterVoices = characterVoices
        self.publishedAt = publishedAt
    }

    /// Per-character voice-match entry. Self-contained: carries the
    /// kid-authored character name so the parent dashboard can render it
    /// without the live tree.
    public nonisolated struct CharacterVoice: Codable, Sendable, Hashable, Identifiable {
        /// Stable speaker reference (the `DialogueCharacterRef.id`).
        public let id: UUID
        /// Kid-authored character name (e.g. "Sprig").
        public let name: String
        /// 0...1 mean voice-match for this character in the published
        /// tree.
        public let voiceMatch: Double
        /// Computed band so the dashboard doesn't have to know the
        /// thresholds.
        public let band: WritingEvaluator.VoiceBand

        public init(id: UUID, name: String, voiceMatch: Double) {
            self.id = id
            self.name = name
            let clamped = max(0, min(1, voiceMatch))
            self.voiceMatch = clamped
            self.band = WritingEvaluator.VoiceBand.band(for: clamped)
        }
    }

    /// Build a snapshot from a freshly published tree + its computed
    /// voice summary. Pure value-type factory — no persistence, no
    /// side-effects. Characters with no scored line in `summary`
    /// (absent from `perCharacterAverage`) are omitted from
    /// `characterVoices` so the snapshot reflects only what was actually
    /// scored this publish.
    public static func from(
        tree: DialogueTree,
        summary: WritingEvaluator.VoiceSummary,
        now: Date
    ) -> PublishedTreeSnapshot {
        let voices: [CharacterVoice] = tree.characters.compactMap { character in
            guard let score = summary.perCharacterAverage[character.id] else {
                return nil
            }
            return CharacterVoice(
                id: character.id,
                name: character.name,
                voiceMatch: score
            )
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        return PublishedTreeSnapshot(
            id: tree.id,
            title: tree.title,
            nodeCount: tree.nodes.count,
            mood: tree.mood,
            treeAverageVoiceMatch: summary.treeAverage,
            characterVoices: voices,
            publishedAt: now
        )
    }
}
