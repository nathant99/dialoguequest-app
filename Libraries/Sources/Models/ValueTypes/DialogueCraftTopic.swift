import Foundation

/// The six dialogue-craft primitives a kid learns across Phase 1 + Phase 2,
/// modeled as a value-type topic identifier for the `ForgeMasteryEngine`
/// adaptive-mastery spine.
///
/// **Why this exists** (Priority B — ForgeMasteryEngine adoption): the app
/// already encodes the craft curriculum as a `ForgeKnowledgeGraph` DAG
/// (`DialogueCraftSkillGraph`) for *prerequisite + standards* reasoning. That
/// graph is static curriculum metadata. This enum is the per-pillar *topic
/// identity* the mastery layer tracks the kid's FSRS-6 retention against over
/// time — a `MasteryGraph<DialogueCraftTopic>` keyed by these cases lets the
/// adaptive coaching surface answer "is the kid racing ahead on voice, stuck
/// on branching, or ready to stretch into triangle dynamics?".
///
/// **Raw values match `DialogueCraftSkillGraph.NodeID`** so the prerequisite
/// graph and the mastery graph stay aligned — a future `ForgeReporting`
/// surface can join the two by slug without a translation table.
///
/// **`String`-backed RawRepresentable** so a `[DialogueCraftTopic: …]`
/// dictionary JSON-encodes as a keyed object (the persistence shape
/// `DialogueCraftMasteryService` writes to UserDefaults).
///
/// **`Codable` declared on the type** (not in an extension) per
/// `.claude/rules/concurrency.md` § "Codable on nonisolated struct" — the
/// default-MainActor package isolation otherwise makes the conformance
/// MainActor-isolated and breaks decode from nonisolated test contexts.
public nonisolated enum DialogueCraftTopic: String, CaseIterable, Codable, Sendable, Hashable {
    case voiceConsistency       = "voice_consistency"
    case subtextDetection       = "subtext_detection"
    case tagBalance             = "tag_balance"
    case branchMeaningfulness   = "branch_meaningfulness"
    case multiListenerSubtext   = "multi_listener_subtext"
    case triangleDynamics       = "triangle_dynamics"

    /// Kid-and-parent-readable label for dashboard surfaces. No jargon.
    public var displayName: String {
        switch self {
        case .voiceConsistency:     return "Voice consistency"
        case .subtextDetection:     return "Subtext"
        case .tagBalance:           return "Tag balance"
        case .branchMeaningfulness: return "Branch meaningfulness"
        case .multiListenerSubtext: return "Multi-listener subtext"
        case .triangleDynamics:     return "Triangle dynamics"
        }
    }

    /// Cast member who embodies this primitive (per Pattern B distributed
    /// narrative). Mirrors `DialogueCraftSkillGraph.castEmbodiment(for:)` so
    /// a "Sprig suggests working on branches next" hint can be derived from
    /// either graph. `nil` for `triangleDynamics` — it emerges from the trio,
    /// not any one character.
    public var castEmbodiment: String? {
        switch self {
        case .voiceConsistency:     return "brogue"
        case .subtextDetection:     return "glance"
        case .tagBalance:           return "weigh"
        case .branchMeaningfulness: return "sprig"
        case .multiListenerSubtext: return "glance"   // Glance extends to multi-listener
        case .triangleDynamics:     return nil        // Emergent from 3-character authoring
        }
    }
}
