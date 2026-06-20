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

    public nonisolated static func makeConfig() -> GamificationConfig {
        GamificationConfig(
            sessionTargetMinutes: 10...15,
            streakFreezeCount: 2,
            desiredRetention: 0.9,
            xpCurve: .standard,
            achievementDefinitions: phase1Achievements
        )
    }

    public nonisolated static let xpForBranchReflection: Int = 10
    public nonisolated static let xpForSubtextConfirmation: Int = 15
    public nonisolated static let xpForPublishedTree: Int = 75
}
