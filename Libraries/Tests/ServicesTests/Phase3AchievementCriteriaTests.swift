import Foundation
import Testing
@testable import Services

@Suite("Phase 3 achievement criteria")
@MainActor
struct Phase3AchievementCriteriaTests {

    @Test func firstReadAloudFiresOnFirstListen() {
        let criteria = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            readAloudCount: 1
        )
        #expect(AchievementService.satisfiesCriteria("first_read_aloud", criteria: criteria))
    }

    @Test func firstAudioExportFiresOnFirstExport() {
        let criteria = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            audioExportCount: 1
        )
        #expect(AchievementService.satisfiesCriteria("first_audio_export", criteria: criteria))
    }

    @Test func treeReadThreeVoicesRequiresThirdCharacter() {
        let two = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            characterCount: 2,
            readAloudCount: 1
        )
        let three = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            characterCount: 3,
            readAloudCount: 1
        )
        #expect(!AchievementService.satisfiesCriteria("tree_read_three_voices", criteria: two))
        #expect(AchievementService.satisfiesCriteria("tree_read_three_voices", criteria: three))
    }

    @Test func pacingWithPausesRequiresAnActionBeat() {
        let without = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            hasActionBeat: false
        )
        let with = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            hasActionBeat: true
        )
        #expect(!AchievementService.satisfiesCriteria("pacing_with_pauses", criteria: without))
        #expect(AchievementService.satisfiesCriteria("pacing_with_pauses", criteria: with))
    }

    @Test func silenceAsSubtextRequiresAllThreeSignals() {
        let onlyAction = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            audioExportCount: 1,
            hasActionBeat: true
        )
        let full = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 1,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            audioExportCount: 1,
            hasActionBeat: true
        )
        #expect(!AchievementService.satisfiesCriteria("silence_as_subtext_aloud", criteria: onlyAction))
        #expect(AchievementService.satisfiesCriteria("silence_as_subtext_aloud", criteria: full))
    }

    @Test func voiceDistinguishableAloudRequiresTagBalance() {
        let unbalanced = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 6,
            characterCount: 2,
            readAloudCount: 1
        )
        let balanced = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: true,
            totalNodes: 6,
            characterCount: 2,
            readAloudCount: 1
        )
        #expect(!AchievementService.satisfiesCriteria("voice_distinguishable_aloud", criteria: unbalanced))
        #expect(AchievementService.satisfiesCriteria("voice_distinguishable_aloud", criteria: balanced))
    }

    @Test func performanceBoothPremiereFiresOnFirstBoothExport() {
        // Anthology-row exports alone do NOT satisfy the badge — the
        // counter must come from the Performance Booth surface.
        let anthologyOnly = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            audioExportCount: 3,
            performanceBoothExportCount: 0
        )
        let firstBoothRound = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 5,
            audioExportCount: 3,
            performanceBoothExportCount: 1
        )
        #expect(!AchievementService.satisfiesCriteria("performance_booth_premiere", criteria: anthologyOnly))
        #expect(AchievementService.satisfiesCriteria("performance_booth_premiere", criteria: firstBoothRound))
    }
}
