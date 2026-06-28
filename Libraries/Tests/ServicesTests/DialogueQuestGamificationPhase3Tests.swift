import Foundation
import Testing
import ForgeModels
@testable import Services

@Suite("DialogueQuestGamification Phase 3")
struct DialogueQuestGamificationPhase3Tests {

    @Test func phase3RegistersSevenAchievements() {
        #expect(DialogueQuestGamification.phase3Achievements.count == 7)
    }

    @Test func phase3IDsAreStable() {
        let ids = Set(DialogueQuestGamification.phase3Achievements.map(\.id))
        let expected: Set<String> = [
            "first_read_aloud",
            "first_audio_export",
            "tree_read_three_voices",
            "pacing_with_pauses",
            "silence_as_subtext_aloud",
            "voice_distinguishable_aloud",
            "performance_booth_premiere",
        ]
        #expect(ids == expected)
    }

    @Test func allAchievementsConcatenatesAllPhases() {
        // allAchievements spans Phase 1 + 2 + 3 + 4. Phase 4 achievements
        // shipped after this test was first authored — keep the total in
        // lockstep with every phase array so adding a phase fails here
        // loudly rather than silently drifting.
        let total = DialogueQuestGamification.phase1Achievements.count
            + DialogueQuestGamification.phase2Achievements.count
            + DialogueQuestGamification.phase3Achievements.count
            + DialogueQuestGamification.phase4Achievements.count
        #expect(DialogueQuestGamification.allAchievements.count == total)
    }

    @Test func phase3AchievementsHaveReaderFriendlyCopy() {
        let forbidden = [
            "load-bearing",
            "codified",
            "ADR-",
            "SAMHSA",
            "TestFlight",
            "ForgeKit",
        ]
        for definition in DialogueQuestGamification.phase3Achievements {
            let surface = (definition.title + definition.description).lowercased()
            for token in forbidden {
                #expect(!surface.contains(token.lowercased()),
                        "Phase 3 achievement \(definition.id) contains forbidden token: \(token)")
            }
            #expect(definition.xpValue > 0)
        }
    }

    @Test func phase3XPValuesStayInModerateBand() {
        // Phase 3 badges are smaller pieces of the engagement loop —
        // listening to a tree should feel less than publishing it
        // (75 XP), so cap Phase 3 individual rewards at 50 XP.
        for definition in DialogueQuestGamification.phase3Achievements {
            #expect(definition.xpValue >= 20 && definition.xpValue <= 50,
                    "Phase 3 badge \(definition.id) outside [20, 50] XP band")
        }
    }
}
