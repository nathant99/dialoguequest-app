import Foundation
import Testing
@testable import Services

/// Phase-2 triangle-path achievement coverage. The 4 jealousy + subtext-layered
/// + branches-reflected + tag-balance-held badges added 2026-06-22 alongside
/// kit 06 (Voice Crucible). All require characterCount >= 3 AND the analyzer-
/// driven signal (pattern / counts / dominantTagAbsent) so the badge stays
/// gated even if the triangle path is enabled but the kid hasn't actually
/// authored a triangle tree.
@MainActor
@Suite("AchievementService — Phase 2 triangle badges (jealousy + layered)")
struct AchievementServicePhase2Phase2Tests {

    private func makeSuite() -> UserDefaults {
        let name = UUID().uuidString
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    private func triangleBase(
        confirmedSubtextLineCount: Int = 0,
        reflectedBranchPointCount: Int = 0,
        dominantTagAbsent: Bool = false,
        totalNodes: Int = 5,
        trianglePattern: AchievementService.TrianglePattern = .none,
        hasThreeVoiceSpread: Bool = false
    ) -> AchievementService.Criteria {
        AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: confirmedSubtextLineCount,
            reflectedBranchPointCount: reflectedBranchPointCount,
            dominantTagAbsent: dominantTagAbsent,
            totalNodes: totalNodes,
            characterCount: 3,
            trianglePattern: trianglePattern,
            hasThreeVoiceSpread: hasThreeVoiceSpread
        )
    }

    @Test("triangle_jealousy_pattern fires when characterCount=3 + trianglePattern=.jealousy")
    func jealousyPattern() {
        let service = AchievementService(defaults: makeSuite())
        let newly = service.evaluate(criteria: triangleBase(trianglePattern: .jealousy))
        #expect(newly.map(\.id).contains("triangle_jealousy_pattern"))
        #expect(newly.map(\.id).contains("triangle_published"))
        // Alliance + arbitration badges DO NOT fire on a jealousy tree.
        #expect(!newly.map(\.id).contains("triangle_alliance_pattern"))
        #expect(!newly.map(\.id).contains("triangle_arbitration_pattern"))
    }

    @Test("triangle_subtext_layered requires confirmedSubtextLineCount >= 3")
    func subtextLayered() {
        let service = AchievementService(defaults: makeSuite())

        // 2 confirmed subtext lines — below threshold.
        let underThreshold = service.evaluate(criteria: triangleBase(confirmedSubtextLineCount: 2))
        #expect(!underThreshold.map(\.id).contains("triangle_subtext_layered"))

        // 3 confirmed subtext lines — fires.
        let fresh = AchievementService(defaults: makeSuite())
        let atThreshold = fresh.evaluate(criteria: triangleBase(confirmedSubtextLineCount: 3))
        #expect(atThreshold.map(\.id).contains("triangle_subtext_layered"))
    }

    @Test("triangle_branches_reflected requires reflectedBranchPointCount >= 2")
    func branchesReflected() {
        let service = AchievementService(defaults: makeSuite())

        let one = service.evaluate(criteria: triangleBase(reflectedBranchPointCount: 1))
        #expect(!one.map(\.id).contains("triangle_branches_reflected"))

        let fresh = AchievementService(defaults: makeSuite())
        let two = fresh.evaluate(criteria: triangleBase(reflectedBranchPointCount: 2))
        #expect(two.map(\.id).contains("triangle_branches_reflected"))
    }

    @Test("triangle_tag_balance_held requires 8+ nodes AND dominantTagAbsent")
    func tagBalanceHeld() {
        let service = AchievementService(defaults: makeSuite())

        // 5 nodes — not enough.
        let fewNodes = service.evaluate(criteria: triangleBase(dominantTagAbsent: true, totalNodes: 5))
        #expect(!fewNodes.map(\.id).contains("triangle_tag_balance_held"))

        // 8 nodes but a dominant tag — fails.
        let fresh1 = AchievementService(defaults: makeSuite())
        let dominant = fresh1.evaluate(criteria: triangleBase(dominantTagAbsent: false, totalNodes: 8))
        #expect(!dominant.map(\.id).contains("triangle_tag_balance_held"))

        // 8 nodes + balanced tags — fires.
        let fresh2 = AchievementService(defaults: makeSuite())
        let balanced = fresh2.evaluate(criteria: triangleBase(dominantTagAbsent: true, totalNodes: 8))
        #expect(balanced.map(\.id).contains("triangle_tag_balance_held"))
    }

    @Test("Phase 1 trees (characterCount == 2) never earn any Phase 2 jealousy/subtext/branch/tag badge")
    func phaseOneTreeNeverEarnsNewPhase2Badges() {
        let service = AchievementService(defaults: makeSuite())
        let phase1Triangle = AchievementService.Criteria(
            publishedTreeCount: 1,
            confirmedSubtextLineCount: 3,
            reflectedBranchPointCount: 2,
            dominantTagAbsent: true,
            totalNodes: 8,
            characterCount: 2,
            trianglePattern: .jealousy,
            hasThreeVoiceSpread: true
        )
        let newly = service.evaluate(criteria: phase1Triangle).map(\.id)
        #expect(!newly.contains("triangle_jealousy_pattern"))
        #expect(!newly.contains("triangle_subtext_layered"))
        #expect(!newly.contains("triangle_branches_reflected"))
        #expect(!newly.contains("triangle_tag_balance_held"))
    }
}
