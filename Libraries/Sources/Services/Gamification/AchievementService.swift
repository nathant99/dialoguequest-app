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
        // Phase 3 — read-aloud + audio export surfaces. Counters live on
        // `DialogueReadAloudService` / `DialogueAudioExporter` consumers
        // (typically via `@AppStorage`); the criteria block is what
        // `WriteTabView` / `AnthologyGalleryView` hands to `evaluate`.
        public let readAloudCount: Int
        public let audioExportCount: Int
        public let hasActionBeat: Bool
        public let pacingPausesCount: Int
        /// Phase 3 / Performance Booth — count of completed audio exports
        /// from the Performance Booth surface specifically (a stricter
        /// subset of `audioExportCount`: every Performance-Booth export
        /// IS an audio export, but Anthology row exports do NOT count).
        /// Drives the `performance_booth_premiere` badge gate.
        public let performanceBoothExportCount: Int
        // Phase 4 — synthesis-tier signals. Counters live on
        // `AnthologyCollectionService` snapshots + `QuestionKitLoader`
        // session-history + the per-tree `WritingEvaluator.VoiceSummary`
        // that `WriteTabView` already computes on publish.
        public let averageVoiceMatchScore: Double
        public let strongVoiceAxis: Bool
        public let subtextAxisStrong: Bool
        public let kitsOpenedCount: Int
        public let collectionsCreatedCount: Int
        public let largestCollectionEntryCount: Int
        public let publishedFromDraftCount: Int
        public let crossCraftKitCompleted: Bool

        public init(
            publishedTreeCount: Int,
            confirmedSubtextLineCount: Int,
            reflectedBranchPointCount: Int,
            dominantTagAbsent: Bool,
            totalNodes: Int,
            characterCount: Int = 2,
            trianglePattern: TrianglePattern = .none,
            hasThreeVoiceSpread: Bool = false,
            readAloudCount: Int = 0,
            audioExportCount: Int = 0,
            hasActionBeat: Bool = false,
            pacingPausesCount: Int = 0,
            performanceBoothExportCount: Int = 0,
            averageVoiceMatchScore: Double = 0,
            strongVoiceAxis: Bool = false,
            subtextAxisStrong: Bool = false,
            kitsOpenedCount: Int = 0,
            collectionsCreatedCount: Int = 0,
            largestCollectionEntryCount: Int = 0,
            publishedFromDraftCount: Int = 0,
            crossCraftKitCompleted: Bool = false
        ) {
            self.publishedTreeCount = publishedTreeCount
            self.confirmedSubtextLineCount = confirmedSubtextLineCount
            self.reflectedBranchPointCount = reflectedBranchPointCount
            self.dominantTagAbsent = dominantTagAbsent
            self.totalNodes = totalNodes
            self.characterCount = characterCount
            self.trianglePattern = trianglePattern
            self.hasThreeVoiceSpread = hasThreeVoiceSpread
            self.readAloudCount = readAloudCount
            self.audioExportCount = audioExportCount
            self.hasActionBeat = hasActionBeat
            self.pacingPausesCount = pacingPausesCount
            self.performanceBoothExportCount = performanceBoothExportCount
            self.averageVoiceMatchScore = averageVoiceMatchScore
            self.strongVoiceAxis = strongVoiceAxis
            self.subtextAxisStrong = subtextAxisStrong
            self.kitsOpenedCount = kitsOpenedCount
            self.collectionsCreatedCount = collectionsCreatedCount
            self.largestCollectionEntryCount = largestCollectionEntryCount
            self.publishedFromDraftCount = publishedFromDraftCount
            self.crossCraftKitCompleted = crossCraftKitCompleted
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
        for definition in newly {
            DialogueQuestAnalytics.shared.track(
                .badgeEarned,
                properties: ["badge_id": definition.id]
            )
        }
        // Juice layer — single haptic per evaluation pass even when multiple
        // badges land together. The popup queue renders one badge at a time,
        // and stacked haptics on a 0.1s window feel like a stuttery glitch
        // rather than a celebration.
        DialogueSensoryService.shared.achievementEarned()
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
        case "triangle_jealousy_pattern":
            return criteria.characterCount >= 3 &&
                   criteria.totalNodes >= 5 &&
                   criteria.trianglePattern == .jealousy
        case "triangle_subtext_layered":
            return criteria.characterCount >= 3 &&
                   criteria.totalNodes >= 5 &&
                   criteria.confirmedSubtextLineCount >= 3
        case "triangle_branches_reflected":
            return criteria.characterCount >= 3 &&
                   criteria.totalNodes >= 5 &&
                   criteria.reflectedBranchPointCount >= 2
        case "triangle_tag_balance_held":
            return criteria.characterCount >= 3 &&
                   criteria.totalNodes >= 8 &&
                   criteria.dominantTagAbsent

        // Phase 3 — read-aloud + audio export + voice-acting craft.
        case "first_read_aloud":
            return criteria.readAloudCount >= 1
        case "first_audio_export":
            return criteria.audioExportCount >= 1
        case "tree_read_three_voices":
            return criteria.readAloudCount >= 1 &&
                   criteria.characterCount >= 3
        case "pacing_with_pauses":
            return criteria.publishedTreeCount >= 1 &&
                   criteria.hasActionBeat
        case "silence_as_subtext_aloud":
            return criteria.audioExportCount >= 1 &&
                   criteria.hasActionBeat &&
                   criteria.confirmedSubtextLineCount >= 1
        case "voice_distinguishable_aloud":
            return criteria.readAloudCount >= 1 &&
                   criteria.characterCount >= 2 &&
                   criteria.dominantTagAbsent &&
                   criteria.totalNodes >= 5
        case "performance_booth_premiere":
            // Requires at least one full Performance Booth round (the kid
            // picked a tree, played it through, and exported the AIFF).
            // The export counter is the canonical signal: every Performance
            // Booth export requires the kid to have listened first
            // (`markListened` fires before `markExported` is reachable via
            // the SwiftUI surface).
            return criteria.performanceBoothExportCount >= 1

        // Phase 4 — synthesis tier. All require Phase 1 minimum (5+
        // nodes, published) plus the specific axis combination.
        case "synthesis_published":
            return criteria.publishedTreeCount >= 1 &&
                   criteria.totalNodes >= 5 &&
                   criteria.strongVoiceAxis &&
                   criteria.subtextAxisStrong &&
                   criteria.dominantTagAbsent &&
                   criteria.reflectedBranchPointCount >= 1
        case "cross_craft_recognized":
            return criteria.crossCraftKitCompleted
        case "revision_published":
            return criteria.publishedFromDraftCount >= 1
        case "anthology_curator":
            return criteria.collectionsCreatedCount >= 1
        case "themed_collection_complete":
            return criteria.largestCollectionEntryCount >= 5
        case "sixteen_kits_complete":
            return criteria.kitsOpenedCount >= 16
        case "voice_master_published":
            return criteria.publishedTreeCount >= 1 &&
                   criteria.averageVoiceMatchScore >= 0.92
        case "dialogue_craft_graduate":
            return criteria.publishedTreeCount >= 30

        default:
            return false
        }
    }
}
