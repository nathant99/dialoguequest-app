import Foundation
import SwiftData

/// SwiftData storage for a kid-curated **anthology collection** — a named
/// + themed grouping of published `DialogueTree`s. Phase 4 surface per
/// `Docs/FEATURE_PLAN.md` row 158: "Implement anthology curation
/// (kid-curated collection of best trees with themed organization)".
///
/// **Schema decision**: added directly to `DialogueQuestSchemaV1` per
/// `.claude/rules/swiftdata.md` rule "Pre-App Store: don't create new
/// `VersionedSchema` for unreleased models". DialogueQuest hasn't shipped
/// to App Store yet, so existing dev builds will pick up the new model
/// via SwiftData's lightweight migration without crashing on existing data.
///
/// **Why a single `@Model` instead of a separate Collections relationship
/// on `PersistentDialogueTree`**: Phase 1 picked single-`@Model` storage
/// for `PersistentDialogueTree` (JSON blob, no `@Relationship` arrays per
/// SwiftData rule 7). Following the same shape here keeps the storage
/// story consistent. Membership is stored as a JSON-encoded `[UUID]` of
/// tree ids (decoded via `AnthologyCollectionService`).
///
/// **No `@Relationship` to `PersistentDialogueTree`**: deliberate — per
/// `.claude/rules/swiftdata.md` rule 7 ("`@Relationship` arrays are
/// unordered") + the cross-cluster pattern of "treat the JSON blob as
/// the canonical shape". Anthology curation hands off the id list to
/// the fetch surface, which decodes on `onAppear` and caches.
@Model
public final class AnthologyCollectionRecord {
    public var id: UUID = UUID()

    /// Kid-supplied collection title. Empty default so a fresh insert
    /// can be saved + then edited.
    public var title: String = ""

    /// One of the 5 themed organization hints. Stored as the raw value
    /// so the enum can evolve without a schema migration.
    public var themeHintRawValue: String = AnthologyCollectionThemeHint.firstConversations.rawValue

    /// JSON-encoded `[UUID]` of `PersistentDialogueTree` ids the kid
    /// added to this collection. Decode via
    /// `AnthologyCollectionService.decodeEntryIDs(from:)`.
    public var encodedEntryIDs: Data = Data()

    public var createdAt: Date = Date()

    public var lastEditedAt: Date = Date()

    public init() {}
}

/// Themed organization hints surfaced as picker options on the curation
/// surface. Kid-readable register per
/// `.claude/rules/distributed-narrative.md` § R-CHAPTER-REGISTER — no
/// engineering jargon, no clinical labels.
public nonisolated enum AnthologyCollectionThemeHint: String, Sendable, Codable, CaseIterable, Hashable {
    case firstConversations = "first_conversations"
    case quietConflicts = "quiet_conflicts"
    case whatTheyDidntSay = "what_they_didnt_say"
    case branchingMoments = "branching_moments"
    case threeVoiceScenes = "three_voice_scenes"

    /// Reader-facing title for the picker.
    public var displayName: String {
        switch self {
        case .firstConversations: return "First conversations"
        case .quietConflicts: return "Quiet conflicts"
        case .whatTheyDidntSay: return "What they didn't say"
        case .branchingMoments: return "Branching moments"
        case .threeVoiceScenes: return "Three-voice scenes"
        }
    }

    /// One-line reader-facing description for the picker subtitle.
    public var coachingLine: String {
        switch self {
        case .firstConversations:
            return "The first scenes you wrote — keep them as the foundation of your anthology."
        case .quietConflicts:
            return "Scenes where the kids argue without raising their voices. The conflict lives underneath."
        case .whatTheyDidntSay:
            return "Trees where the subtext does more work than the words. Layered reads only."
        case .branchingMoments:
            return "Trees where the kid had to pick which way the scene went. The choice IS the story."
        case .threeVoiceScenes:
            return "Triangle trees — three characters in one scene, three distinct registers."
        }
    }
}
