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
        AchievementDefinition(
            id: "triangle_jealousy_pattern",
            title: "Jealousy on the page",
            description: "Your triangle leaned into the jealousy pattern — one voice watching the other two close together.",
            iconAssetName: "achievement_triangle_jealousy",
            xpValue: 40,
            standard: nil
        ),
        AchievementDefinition(
            id: "triangle_subtext_layered",
            title: "Three voices, three layers of subtext",
            description: "You confirmed three or more subtext lines across a triangle tree — every voice carrying something underneath.",
            iconAssetName: "achievement_triangle_subtext",
            xpValue: 60,
            standard: nil
        ),
        AchievementDefinition(
            id: "triangle_branches_reflected",
            title: "Two paths, three voices",
            description: "You reflected on two or more branch points in a triangle tree — every choice felt the weight of all three.",
            iconAssetName: "achievement_triangle_branches_reflected",
            xpValue: 50,
            standard: nil
        ),
        AchievementDefinition(
            id: "triangle_tag_balance_held",
            title: "Three voices, balanced rhythm",
            description: "You authored a triangle tree of 8+ nodes with no dominant tag style — every voice kept the rhythm.",
            iconAssetName: "achievement_triangle_tag_balance",
            xpValue: 50,
            standard: nil
        ),
    ]

    /// Phase 3 achievements — unlocked when the kid uses the read-aloud
    /// playback + audio export surfaces. Per `Docs/FEATURE_PLAN.md`
    /// § Phase 3: read-aloud playback / voice-acting craft / audio export.
    public nonisolated static let phase3Achievements: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_read_aloud",
            title: "Heard your scene",
            description: "You listened to one of your trees read aloud. The ear catches what the eye missed.",
            iconAssetName: "achievement_first_read_aloud",
            xpValue: 25,
            standard: nil
        ),
        AchievementDefinition(
            id: "first_audio_export",
            title: "Your scene on tape",
            description: "You exported your tree as an audio file. Your characters now travel anywhere you send them.",
            iconAssetName: "achievement_first_audio_export",
            xpValue: 40,
            standard: nil
        ),
        AchievementDefinition(
            id: "tree_read_three_voices",
            title: "Three voices read aloud",
            description: "You listened to a triangle tree and three characters sounded like three people.",
            iconAssetName: "achievement_three_voices_aloud",
            xpValue: 50,
            standard: nil
        ),
        AchievementDefinition(
            id: "pacing_with_pauses",
            title: "Held the silence",
            description: "You published a tree with at least one action beat — the pause does the work the words can't.",
            iconAssetName: "achievement_pacing_pauses",
            xpValue: 30,
            standard: nil
        ),
        AchievementDefinition(
            id: "silence_as_subtext_aloud",
            title: "Silence carried it",
            description: "You exported a tree whose loudest line was the pause. Subtext you can hear.",
            iconAssetName: "achievement_silence_subtext_aloud",
            xpValue: 45,
            standard: nil
        ),
        AchievementDefinition(
            id: "voice_distinguishable_aloud",
            title: "Voices you can tell apart",
            description: "You read aloud a tree where every character's register sounded like a different person.",
            iconAssetName: "achievement_voice_distinguishable_aloud",
            xpValue: 50,
            standard: nil
        ),
        AchievementDefinition(
            id: "performance_booth_premiere",
            title: "Performance Booth premiere",
            description: "You picked a tree, listened to your characters speak, and shipped the recording as an audio file. Your scene has a soundtrack now.",
            iconAssetName: "achievement_performance_booth_premiere",
            xpValue: 50,
            standard: nil
        ),
    ]

    /// All achievements registered with the engine. Phase 2 + Phase 3
    /// entries are always registered; they simply don't fire until the
    /// kid is on the right path (triangle / read-aloud / export).
    /// Keeping them in the same definitions array avoids per-flag config
    /// branches in `makeConfig()`.
    public nonisolated static let allAchievements: [AchievementDefinition] =
        phase1Achievements + phase2Achievements + phase3Achievements

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
