import Foundation
import ForgeGamification
import ForgeModels
import Models

/// Phase 1 achievement coordinator. Wraps ForgeGamification's pure
/// `AchievementEngine` with persistence + a per-tree criteria evaluation
/// surface tailored to DialogueQuest's 4 starter achievements
/// (first tree / first subtext / tag balance / branch reflected).
///
/// The engine itself stays pure (no internal state); this service owns
/// the persisted `dq.earnedBadgeIDs` UserDefaults key + the new-badge
/// emission queue that `WriteTabView` drains into `ForgeAchievementPopup`.
///
/// Why a class (not an actor):
/// - `AchievementEngine` is a pure `nonisolated struct` so we don't
///   inherit any actor concerns from it; consumers are MainActor
///   SwiftUI surfaces, so the service is `@MainActor` for ergonomic
///   `@Observable` integration.
@Observable
@MainActor
public final class AchievementService {
    public static let shared = AchievementService()

    static let defaultsKeyEarnedIDs = "dq.earnedBadgeIDs"

    /// Newly-earned badges since the last drain — `WriteTabView` reads,
    /// drains, and renders one at a time via `ForgeAchievementPopup`.
    public private(set) var pendingNewBadges: [BadgeDisplayData] = []

    @ObservationIgnored
    private let defaults: UserDefaults
    @ObservationIgnored
    private let engine = AchievementEngine()
    @ObservationIgnored
    private let definitions: [AchievementDefinition]

    public init(
        defaults: UserDefaults = .standard,
        definitions: [AchievementDefinition] = DialogueQuestGamification.allAchievements
    ) {
        self.defaults = defaults
        self.definitions = definitions
    }

    /// Phase 2 triangle classification surfaced via `Criteria`. Mirrors the
    /// 4-case shape of `TriangleDynamics.Classification` so the service
    /// stays decoupled from the `Services` analyzer module; callers pass
    /// the raw classification value when known.
    public enum TrianglePattern: String, Sendable, Equatable {
        case alliance
        case jealousy
        case arbitration
        case none
    }

    /// Criteria snapshot fed into `evaluate(criteria:)`. Pure value type
    /// so callers can construct one from any view-local state without
    /// reaching into the service's storage.
    public struct Criteria: Sendable {
        public let publishedTreeCount: Int
        public let confirmedSubtextLineCount: Int
        public let reflectedBranchPointCount: Int
        public let dominantTagAbsent: Bool
        public let totalNodes: Int
        // Phase 2 — present only for triangle-path trees. `characterCount`
        // is the cheap gate; the analyzer-driven signals (`trianglePattern`
        // and `hasThreeVoiceSpread`) provide the per-shape badges.
        public let characterCount: Int
        public let trianglePattern: TrianglePattern
        public let hasThreeVoiceSpread: Bool

        public init(
            publishedTreeCount: Int,
            confirmedSubtextLineCount: Int,
            reflectedBranchPointCount: Int,
            dominantTagAbsent: Bool,
            totalNodes: Int,
            characterCount: Int = 2,
            trianglePattern: TrianglePattern = .none,
            hasThreeVoiceSpread: Bool = false
        ) {
            self.publishedTreeCount = publishedTreeCount
            self.confirmedSubtextLineCount = confirmedSubtextLineCount
            self.reflectedBranchPointCount = reflectedBranchPointCount
            self.dominantTagAbsent = dominantTagAbsent
            self.totalNodes = totalNodes
            self.characterCount = characterCount
            self.trianglePattern = trianglePattern
            self.hasThreeVoiceSpread = hasThreeVoiceSpread
        }
    }

    /// Compute newly-earned badges against the supplied criteria, persist
    /// them, and queue them onto `pendingNewBadges` for the UI layer.
    /// Returns the badges added in this call so tests can assert directly.
    @discardableResult
    public func evaluate(criteria: Criteria) -> [AchievementDefinition] {
        let earned = earnedIDs
        let newly = engine.evaluate(
            definitions: definitions,
            earnedIDs: earned
        ) { definition in
            Self.satisfiesCriteria(definition.id, criteria: criteria)
        }
        guard !newly.isEmpty else { return [] }

        // Persist before queueing so a crash mid-show doesn't replay
        // the badge on next launch.
        let nowEarned = earned.union(newly.map(\.id))
        persistEarnedIDs(nowEarned)

        let now = Date.now
        let display = newly.map {
            BadgeDisplayData(
                id: $0.id,
                title: $0.title,
                iconAssetName: $0.iconAssetName,
                earnedAt: now
            )
        }
        pendingNewBadges.append(contentsOf: display)
        return newly
    }

    /// UI calls this after `ForgeAchievementPopup`'s onDismiss fires so
    /// the next queued badge can appear.
    public func consumeBadge(id: String) {
        pendingNewBadges.removeAll { $0.id == id }
    }

    public var earnedIDs: Set<String> {
        let raw = defaults.string(forKey: Self.defaultsKeyEarnedIDs) ?? ""
        let parts = raw.split(separator: ",")
            .map(String.init)
            .filter { !$0.isEmpty }
        return Set(parts)
    }

    private func persistEarnedIDs(_ ids: Set<String>) {
        let serialized = ids.sorted().joined(separator: ",")
        defaults.set(serialized, forKey: Self.defaultsKeyEarnedIDs)
    }

    /// The 4 Phase 1 + 4 Phase 2 criteria. Keep in lockstep with
    /// `DialogueQuestGamification.{phase1Achievements, phase2Achievements}` IDs.
    static func satisfiesCriteria(
        _ id: String,
        criteria: Criteria
    ) -> Bool {
        switch id {
        // Phase 1
        case "first_tree_authored":
            return criteria.publishedTreeCount >= 1
        case "first_subtext_confirmed":
            return criteria.confirmedSubtextLineCount >= 1
        case "tag_balance_reached":
            // Trees authored to Phase-1 minimum (5+ nodes) with no
            // dominant tag class qualify. Skip dead-empty trees so the
            // badge isn't auto-awarded on a freshly-seeded session.
            return criteria.totalNodes >= 5 && criteria.dominantTagAbsent
        case "branch_reflected":
            return criteria.reflectedBranchPointCount >= 1

        // Phase 2 — triangle path. All four require characterCount ≥ 3
        // AND the tree meeting Phase-1 minimum node count so the analyzer
        // signal is reliable.
        case "triangle_published":
            return criteria.characterCount >= 3 &&
                   criteria.publishedTreeCount >= 1 &&
                   criteria.totalNodes >= 5
        case "triangle_three_voice_spread":
            return criteria.characterCount >= 3 &&
                   criteria.totalNodes >= 5 &&
                   criteria.hasThreeVoiceSpread
        case "triangle_alliance_pattern":
            return criteria.characterCount >= 3 &&
                   criteria.totalNodes >= 5 &&
                   criteria.trianglePattern == .alliance
        case "triangle_arbitration_pattern":
            return criteria.characterCount >= 3 &&
                   criteria.totalNodes >= 5 &&
                   criteria.trianglePattern == .arbitration

        default:
            return false
        }
    }
}
