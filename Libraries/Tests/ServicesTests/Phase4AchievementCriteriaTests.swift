import Foundation
import Testing
@testable import Services

@Suite("Phase 4 advanced achievement criteria")
@MainActor
struct Phase4AchievementCriteriaTests {

    private func baseCriteria(
        publishedTreeCount: Int = 1,
        totalNodes: Int = 5
    ) -> AchievementService.Criteria {
        AchievementService.Criteria(
            publishedTreeCount: publishedTreeCount,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: totalNodes
        )
    }

    @Test func synthesisPublishedRequiresAllFourAxes() {
        let weak = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 1,
            reflectedBranchPointCount: 1,
            dominantTagAbsent: false,    // ← tag-balance axis weak
            totalNodes: 5,
            strongVoiceAxis: true,
            subtextAxisStrong: true
        )
        let strong = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 1,
            reflectedBranchPointCount: 1,
            dominantTagAbsent: true,
            totalNodes: 5,
            strongVoiceAxis: true,
            subtextAxisStrong: true
        )
        #expect(!AchievementService.satisfiesCriteria("synthesis_published", criteria: weak))
        #expect(AchievementService.satisfiesCriteria("synthesis_published", criteria: strong))
    }

    @Test func crossCraftFiresOnKitCompletion() {
        var crit = baseCriteria()
        #expect(!AchievementService.satisfiesCriteria("cross_craft_recognized", criteria: crit))
        crit = AchievementService.Criteria(
            publishedTreeCount: 0,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 0,
            crossCraftKitCompleted: true
        )
        #expect(AchievementService.satisfiesCriteria("cross_craft_recognized", criteria: crit))
    }

    @Test func revisionPublishedFiresOnFirstDraftPublish() {
        let none = baseCriteria()
        let one = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            publishedFromDraftCount: 1
        )
        #expect(!AchievementService.satisfiesCriteria("revision_published", criteria: none))
        #expect(AchievementService.satisfiesCriteria("revision_published", criteria: one))
    }

    @Test func anthologyCuratorFiresOnFirstCollection() {
        let none = baseCriteria()
        let one = AchievementService.Criteria(
            publishedTreeCount: 0,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 0,
            collectionsCreatedCount: 1
        )
        #expect(!AchievementService.satisfiesCriteria("anthology_curator", criteria: none))
        #expect(AchievementService.satisfiesCriteria("anthology_curator", criteria: one))
    }

    @Test func themedCollectionCompleteRequiresFiveEntries() {
        let four = AchievementService.Criteria(
            publishedTreeCount: 5,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            collectionsCreatedCount: 1,
            largestCollectionEntryCount: 4
        )
        let five = AchievementService.Criteria(
            publishedTreeCount: 5,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            collectionsCreatedCount: 1,
            largestCollectionEntryCount: 5
        )
        #expect(!AchievementService.satisfiesCriteria("themed_collection_complete", criteria: four))
        #expect(AchievementService.satisfiesCriteria("themed_collection_complete", criteria: five))
    }

    @Test func sixteenKitsCompleteRequiresExactlySixteenOrMore() {
        let fifteen = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            kitsOpenedCount: 15
        )
        let sixteen = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            kitsOpenedCount: 16
        )
        #expect(!AchievementService.satisfiesCriteria("sixteen_kits_complete", criteria: fifteen))
        #expect(AchievementService.satisfiesCriteria("sixteen_kits_complete", criteria: sixteen))
    }

    @Test func voiceMasterPublishedRequires092Average() {
        let belowThreshold = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            averageVoiceMatchScore: 0.91
        )
        let atThreshold = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            averageVoiceMatchScore: 0.92
        )
        #expect(!AchievementService.satisfiesCriteria("voice_master_published", criteria: belowThreshold))
        #expect(AchievementService.satisfiesCriteria("voice_master_published", criteria: atThreshold))
    }

    @Test func dialogueCraftGraduateRequiresThirtyPublishedTrees() {
        let twentyNine = AchievementService.Criteria(
            publishedTreeCount: 29,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5
        )
        let thirty = AchievementService.Criteria(
            publishedTreeCount: 30,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5
        )
        #expect(!AchievementService.satisfiesCriteria("dialogue_craft_graduate", criteria: twentyNine))
        #expect(AchievementService.satisfiesCriteria("dialogue_craft_graduate", criteria: thirty))
    }
}

@Suite("DialogueQuestGamification Phase 4")
struct DialogueQuestGamificationPhase4Tests {

    @Test func phase4RegistersEightAchievements() {
        #expect(DialogueQuestGamification.phase4Achievements.count == 8)
    }

    @Test func phase4IDsAreStable() {
        let ids = Set(DialogueQuestGamification.phase4Achievements.map(\.id))
        let expected: Set<String> = [
            "synthesis_published",
            "cross_craft_recognized",
            "revision_published",
            "anthology_curator",
            "themed_collection_complete",
            "sixteen_kits_complete",
            "voice_master_published",
            "dialogue_craft_graduate",
        ]
        #expect(ids == expected)
    }

    @Test func phase4AchievementsHaveReaderFriendlyCopy() {
        let forbidden = [
            "load-bearing",
            "codified",
            "ADR-",
            "SAMHSA",
            "TestFlight",
            "ForgeKit",
        ]
        for definition in DialogueQuestGamification.phase4Achievements {
            let surface = (definition.title + definition.description).lowercased()
            for token in forbidden {
                #expect(!surface.contains(token.lowercased()),
                        "Phase 4 achievement \(definition.id) leaks: \(token)")
            }
            #expect(definition.xpValue > 0)
        }
    }

    @Test func phase4XPValuesStayInExpectedBand() {
        // Phase 4 badges are synthesis-tier so they MAY exceed the 50 XP
        // Phase 3 ceiling — voice mastery + 30-tree graduate are 80 / 100
        // intentionally. Validate the band is [40, 100].
        for definition in DialogueQuestGamification.phase4Achievements {
            #expect(definition.xpValue >= 40 && definition.xpValue <= 100,
                    "Phase 4 badge \(definition.id) outside [40, 100] XP band")
        }
    }

    @Test func allAchievementsConcatenatesAllFourPhases() {
        let total = DialogueQuestGamification.phase1Achievements.count
            + DialogueQuestGamification.phase2Achievements.count
            + DialogueQuestGamification.phase3Achievements.count
            + DialogueQuestGamification.phase4Achievements.count
        #expect(DialogueQuestGamification.allAchievements.count == total)
    }
}
