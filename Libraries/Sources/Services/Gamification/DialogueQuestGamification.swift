import Foundation
import ForgeGamification
import ForgeModels

/// DialogueQuest-specific gamification config + helpers wrapping
/// ForgeGamification 0.99's `XPEngine` + `StreakManager` + `AchievementEngine`.
///
/// The config tunes the engagement loop for a writing-craft app
/// (longer sessions = more reward; subtext confirmations are
/// XP-multiplied because they're the aha-moment seed).
public enum DialogueQuestGamification {

    /// Phase 1 achievements per `Docs/FEATURE_PLAN.md` § Gamification.
    public nonisolated static let phase1Achievements: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_tree_authored",
            title: "First conversation",
            description: "You wrote and published your very first dialogue tree.",
            iconAssetName: "achievement_first_tree",
            xpValue: 50,
            standard: nil
        ),
        AchievementDefinition(
            id: "first_subtext_confirmed",
            title: "The aha moment",
            description: "You spotted what wasn't being said and confirmed it.",
            iconAssetName: "achievement_first_subtext",
            xpValue: 30,
            standard: nil
        ),
        AchievementDefinition(
            id: "tag_balance_reached",
            title: "Listening for rhythm",
            description: "You balanced your attribution tags — no single style took over.",
            iconAssetName: "achievement_tag_balance",
            xpValue: 20,
            standard: nil
        ),
        AchievementDefinition(
            id: "branch_reflected",
            title: "Branch with intent",
            description: "You reflected on a branch point — every option costs the speaker something.",
            iconAssetName: "achievement_branch_reflected",
            xpValue: 25,
            standard: nil
        ),
    ]

    /// Phase 2 achievements — unlocked when the kid opts in to the triangle
    /// authoring path (3-character trees). Wiring depends on
    /// `dq.experiments.thirdCharacter` being on AND the kid actually
    /// publishing a triangle tree.
    public nonisolated static let phase2Achievements: [AchievementDefinition] = [
        AchievementDefinition(
            id: "triangle_published",
            title: "Three voices in the room",
            description: "You published a dialogue tree with three characters in conversation.",
            iconAssetName: "achievement_triangle_published",
            xpValue: 75,
            standard: nil
        ),
        AchievementDefinition(
            id: "triangle_three_voice_spread",
            title: "Three distinct voices",
            description: "Each character in your triangle had a voice you could recognize without the tag.",
            iconAssetName: "achievement_three_voice_spread",
            xpValue: 50,
            standard: nil
        ),
        AchievementDefinition(
            id: "triangle_alliance_pattern",
            title: "Alliance shape",
            description: "Your triangle leaned into the alliance pattern — two voices closing on the third.",
            iconAssetName: "achievement_triangle_alliance",
            xpValue: 40,
            standard: nil
        ),
        AchievementDefinition(
            id: "triangle_arbitration_pattern",
            title: "The arbiter steps in",
            description: "Your arbiter named what was happening between the other two — the third voice as referee.",
            iconAssetName: "achievement_triangle_arbitration",
            xpValue: 40,
            standard: nil
        ),
    ]

    /// All achievements registered with the engine. Phase 2 entries are
    /// always registered; they simply don't fire until the kid is on the
    /// triangle path. Keeping them in the same definitions array avoids
    /// per-flag config branches in `makeConfig()`.
    public nonisolated static let allAchievements: [AchievementDefinition] =
        phase1Achievements + phase2Achievements

    public nonisolated static func makeConfig() -> GamificationConfig {
        GamificationConfig(
            sessionTargetMinutes: 10...15,
            streakFreezeCount: 2,
            desiredRetention: 0.9,
            xpCurve: .standard,
            achievementDefinitions: allAchievements
        )
    }

    public nonisolated static let xpForBranchReflection: Int = 10
    public nonisolated static let xpForSubtextConfirmation: Int = 15
    public nonisolated static let xpForPublishedTree: Int = 75
}
