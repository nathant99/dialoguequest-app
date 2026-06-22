import Foundation
import Testing
@testable import Services

@MainActor
@Suite("AchievementService")
struct AchievementServiceTests {

    private func makeSuite(name: String = UUID().uuidString) -> UserDefaults {
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    private func zeroCriteria() -> AchievementService.Criteria {
        AchievementService.Criteria(
            publishedTreeCount: 0,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 0
        )
    }

    @Test("Fresh service has no earned IDs and no pending badges")
    func freshState() throws {
        let service = AchievementService(defaults: makeSuite())
        #expect(service.earnedIDs.isEmpty)
        #expect(service.pendingNewBadges.isEmpty)
    }

    @Test("first_tree_authored fires once on publishedTreeCount==1")
    func firstTreeAuthored() throws {
        let service = AchievementService(defaults: makeSuite())
        let criteria = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 0
        )
        let newly = service.evaluate(criteria: criteria)
        #expect(newly.map(\.id) == ["first_tree_authored"])
        #expect(service.earnedIDs == ["first_tree_authored"])
        #expect(service.pendingNewBadges.map(\.id) == ["first_tree_authored"])
        // A second evaluate with the same criteria yields no new badges.
        let again = service.evaluate(criteria: criteria)
        #expect(again.isEmpty)
    }

    @Test("first_subtext_confirmed fires when confirmedSubtextLineCount >= 1")
    func subtextBadge() throws {
        let service = AchievementService(defaults: makeSuite())
        let criteria = AchievementService.Criteria(
            publishedTreeCount: 0,
            confirmedSubtextLineCount: 1,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 0
        )
        let newly = service.evaluate(criteria: criteria)
        #expect(newly.contains { $0.id == "first_subtext_confirmed" })
    }

    @Test("branch_reflected fires when reflectedBranchPointCount >= 1")
    func branchReflectedBadge() throws {
        let service = AchievementService(defaults: makeSuite())
        let criteria = AchievementService.Criteria(
            publishedTreeCount: 0,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 1,
            dominantTagAbsent: false,
            totalNodes: 0
        )
        let newly = service.evaluate(criteria: criteria)
        #expect(newly.contains { $0.id == "branch_reflected" })
    }

    @Test("tag_balance_reached requires both 5+ nodes AND no dominant tag")
    func tagBalanceBadge() throws {
        let service = AchievementService(defaults: makeSuite())
        // 5+ nodes but dominant tag present → no badge
        let dominant = AchievementService.Criteria(
            publishedTreeCount: 0,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 6
        )
        #expect(!service.evaluate(criteria: dominant).contains { $0.id == "tag_balance_reached" })
        // <5 nodes + absent → no badge (skip the dead-empty seed case)
        let tooSmall = AchievementService.Criteria(
            publishedTreeCount: 0,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: true,
            totalNodes: 3
        )
        #expect(!service.evaluate(criteria: tooSmall).contains { $0.id == "tag_balance_reached" })
        // 5+ AND absent → badge
        let balanced = AchievementService.Criteria(
            publishedTreeCount: 0,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: true,
            totalNodes: 5
        )
        let newly = service.evaluate(criteria: balanced)
        #expect(newly.contains { $0.id == "tag_balance_reached" })
    }

    @Test("consumeBadge drains a single pending badge")
    func consumeBadgeDrains() throws {
        let service = AchievementService(defaults: makeSuite())
        let criteria = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 1,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 0
        )
        _ = service.evaluate(criteria: criteria)
        #expect(service.pendingNewBadges.count == 2)
        let first = try #require(service.pendingNewBadges.first)
        service.consumeBadge(id: first.id)
        #expect(service.pendingNewBadges.count == 1)
    }

    @Test("Earned IDs persist across service re-instantiation")
    func earnedPersists() throws {
        let suiteName = UUID().uuidString
        let suite = UserDefaults(suiteName: suiteName)!
        suite.removePersistentDomain(forName: suiteName)
        let serviceA = AchievementService(defaults: suite)
        let criteria = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 0,
            reflectedBranchPointCount: 0,
            dominantTagAbsent: false,
            totalNodes: 0
        )
        _ = serviceA.evaluate(criteria: criteria)
        let serviceB = AchievementService(defaults: suite)
        #expect(serviceB.earnedIDs == ["first_tree_authored"])
        // Re-evaluating against the same criteria yields no new badges.
        let again = serviceB.evaluate(criteria: criteria)
        #expect(again.isEmpty)
    }
}
