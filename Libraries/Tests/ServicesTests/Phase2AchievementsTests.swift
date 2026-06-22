import Foundation
import Testing
@testable import Services

/// Phase 2 achievement coverage — verifies that the four triangle-path
/// badges fire ONLY for triangle trees (characterCount ≥ 3) and respect
/// the analyzer-driven pattern signals. Phase 1 paths must continue to
/// not award any Phase 2 badges accidentally (regression guard).
@MainActor
@Suite("Phase 2 achievement criteria")
struct Phase2AchievementsTests {

    private func makeSuite(name: String = UUID().uuidString) -> UserDefaults {
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    private func makeService() -> AchievementService {
        AchievementService(defaults: makeSuite())
    }

    private func triangleCriteria(
        characterCount: Int = 3,
        publishedTreeCount: Int = 1,
        totalNodes: Int = 12,
        pattern: AchievementService.TrianglePattern = .none,
        threeVoiceSpread: Bool = false
    ) -> AchievementService.Criteria {
        AchievementService.Criteria(
            publishedTreeCount: publishedTreeCount,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: totalNodes,
            characterCount: characterCount,
            trianglePattern: pattern,
            hasThreeVoiceSpread: threeVoiceSpread
        )
    }

    // MARK: - triangle_published

    @Test func trianglePublishedRequiresThreeCharacters() {
        let service = makeService()
        // 2 characters: no Phase 2 badges.
        let twoChar = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 12,
            characterCount: 2
        )
        let newly = service.evaluate(criteria: twoChar)
        #expect(!newly.contains { $0.id == "triangle_published" })
    }

    @Test func trianglePublishedFiresOnThreeCharactersAndPublish() {
        let service = makeService()
        let newly = service.evaluate(criteria: triangleCriteria())
        #expect(newly.contains { $0.id == "triangle_published" })
    }

    @Test func trianglePublishedRequiresPhaseOneNodeMinimum() {
        let service = makeService()
        let short = triangleCriteria(totalNodes: 4)
        let newly = service.evaluate(criteria: short)
        #expect(!newly.contains { $0.id == "triangle_published" })
    }

    // MARK: - triangle_three_voice_spread

    @Test func threeVoiceSpreadRequiresExplicitSignal() {
        let service = makeService()
        let unspread = triangleCriteria(threeVoiceSpread: false)
        #expect(!service.evaluate(criteria: unspread).contains { $0.id == "triangle_three_voice_spread" })
    }

    @Test func threeVoiceSpreadFiresWhenSignalIsTrue() {
        let service = makeService()
        let spread = triangleCriteria(threeVoiceSpread: true)
        #expect(service.evaluate(criteria: spread).contains { $0.id == "triangle_three_voice_spread" })
    }

    // MARK: - Pattern-specific badges

    @Test func alliancePatternFiresOnlyOnAllianceClassification() {
        let service = makeService()
        let alliance = triangleCriteria(pattern: .alliance)
        #expect(service.evaluate(criteria: alliance).contains { $0.id == "triangle_alliance_pattern" })
    }

    @Test func alliancePatternDoesNotFireOnOtherClassifications() {
        for pattern in [AchievementService.TrianglePattern.jealousy, .arbitration, .none] {
            let service = makeService()
            let criteria = triangleCriteria(pattern: pattern)
            #expect(!service.evaluate(criteria: criteria).contains { $0.id == "triangle_alliance_pattern" })
        }
    }

    @Test func arbitrationPatternFiresOnlyOnArbitrationClassification() {
        let service = makeService()
        let arbitration = triangleCriteria(pattern: .arbitration)
        #expect(service.evaluate(criteria: arbitration).contains { $0.id == "triangle_arbitration_pattern" })
    }

    @Test func arbitrationPatternDoesNotFireOnOtherClassifications() {
        for pattern in [AchievementService.TrianglePattern.alliance, .jealousy, .none] {
            let service = makeService()
            let criteria = triangleCriteria(pattern: pattern)
            #expect(!service.evaluate(criteria: criteria).contains { $0.id == "triangle_arbitration_pattern" })
        }
    }

    // MARK: - Phase 1 regression guard

    @Test func phase1PathDoesNotAwardPhase2BadgesAccidentally() {
        let service = makeService()
        // Realistic Phase 1 criteria: 2 characters, full publish state.
        let phase1 = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 2,
            reflectedBranchPointCount: 3,
            dominantTagAbsent: true,
            totalNodes: 12,
            characterCount: 2
        )
        let newly = service.evaluate(criteria: phase1)
        let earnedIDs = Set(newly.map(\.id))
        let phase2IDs: Set<String> = [
            "triangle_published",
            "triangle_three_voice_spread",
            "triangle_alliance_pattern",
            "triangle_arbitration_pattern",
        ]
        #expect(earnedIDs.intersection(phase2IDs).isEmpty,
                "Phase 1 criteria leaked Phase 2 badge: \(earnedIDs.intersection(phase2IDs))")
    }

    @Test func phase1PathStillAwardsPhase1Badges() {
        let service = makeService()
        let phase1 = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 1,
            reflectedBranchPointCount: 1,
            dominantTagAbsent: true,
            totalNodes: 10,
            characterCount: 2
        )
        let newly = service.evaluate(criteria: phase1)
        let ids = Set(newly.map(\.id))
        #expect(ids.contains("first_tree_authored"))
        #expect(ids.contains("first_subtext_confirmed"))
        #expect(ids.contains("branch_reflected"))
        #expect(ids.contains("tag_balance_reached"))
    }
}
