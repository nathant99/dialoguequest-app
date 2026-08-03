import Testing
import Foundation
import Models
import Services
import ForgeGamification
@testable import AppFeature

/// Wave 4 (2026-08-02) — Mastery-progression "Your progress" card
/// (`Docs/HANDOFF_FROM_HUB_MASTERY_PROGRESSION_WEB_BACKPORT.md`, ADR-048
/// axis 8). Covers the pure `MasteryProgression` derivation — the
/// learning-milestone shelf + optional learner-set goal — including the
/// real XP→level→milestone path via `ForgeGamification.XPEngine`.
@Suite("Mastery progression — milestones + goals")
struct MasteryProgressionTests {

    /// Build a readout set with `mastered` mastered pillars and `practiced`
    /// total practiced (mastered ones count as practiced). `practiced`
    /// must be ≥ `mastered`.
    private func readouts(mastered: Int, practiced: Int, total: Int = 6) -> [DialogueCraftMasteryService.CraftMasteryReadout] {
        let topics = DialogueCraftTopic.allCases
        precondition(total <= topics.count && practiced >= mastered)
        return (0..<total).map { i in
            let isMastered = i < mastered
            let score = isMastered ? 0.9 : (i < practiced ? 0.5 : 0.0)
            return .init(topic: topics[i], score: score, isMastered: isMastered)
        }
    }

    @Test("Fresh install: no milestones earned, no goal progress")
    func freshInstall() {
        let p = MasteryProgression(publishedTreeCount: 0, level: 0, readouts: readouts(mastered: 0, practiced: 0))
        #expect(p.milestones.count == 7)
        #expect(p.earnedMilestoneCount == 0)
        #expect(p.pillarsPracticed == 0)
        #expect(p.pillarsMastered == 0)
        #expect(p.progress(for: .none) == nil)
    }

    @Test("Publish milestones unlock at 1, 5, 10")
    func publishMilestones() {
        func earned(_ id: String, at count: Int) -> Bool {
            MasteryProgression(publishedTreeCount: count, level: 0, readouts: readouts(mastered: 0, practiced: 0))
                .milestones.first { $0.id == id }?.isEarned ?? false
        }
        #expect(!earned("first_conversation", at: 0))
        #expect(earned("first_conversation", at: 1))
        #expect(!earned("five_conversations", at: 4))
        #expect(earned("five_conversations", at: 5))
        #expect(!earned("ten_conversations", at: 9))
        #expect(earned("ten_conversations", at: 10))
    }

    @Test("Craft milestones key to practiced/mastered pillar counts")
    func craftMilestones() {
        // 1 mastered, 3 practiced of 6.
        let some = MasteryProgression(publishedTreeCount: 1, level: 1, readouts: readouts(mastered: 1, practiced: 3))
        #expect(some.pillarsMastered == 1)
        #expect(some.pillarsPracticed == 3)
        #expect(some.milestones.first { $0.id == "first_pillar_mastered" }?.isEarned == true)
        #expect(some.milestones.first { $0.id == "every_pillar_practiced" }?.isEarned == false)
        #expect(some.milestones.first { $0.id == "half_craft_mastered" }?.isEarned == false)
        #expect(some.milestones.first { $0.id == "all_craft_mastered" }?.isEarned == false)

        // 3 of 6 mastered = half (rounds up so 3 ≥ ceil(6/2)=3).
        let half = MasteryProgression(publishedTreeCount: 1, level: 1, readouts: readouts(mastered: 3, practiced: 6))
        #expect(half.milestones.first { $0.id == "half_craft_mastered" }?.isEarned == true)
        #expect(half.milestones.first { $0.id == "every_pillar_practiced" }?.isEarned == true)
        #expect(half.milestones.first { $0.id == "all_craft_mastered" }?.isEarned == false)

        // All 6 mastered = every craft solid.
        let all = MasteryProgression(publishedTreeCount: 10, level: 5, readouts: readouts(mastered: 6, practiced: 6))
        #expect(all.milestones.first { $0.id == "all_craft_mastered" }?.isEarned == true)
        #expect(all.earnedMilestoneCount == 7)
    }

    @Test("Goal progress: master all pillars")
    func goalMasterAll() throws {
        let p = MasteryProgression(publishedTreeCount: 2, level: 2, readouts: readouts(mastered: 2, practiced: 4))
        let gp = try #require(p.progress(for: .masterAllPillars))
        #expect(gp.current == 2)
        #expect(gp.target == 6)
        #expect(!gp.isMet)
        #expect(abs(gp.fraction - (2.0 / 6.0)) < 1e-9)
    }

    @Test("Goal progress: publish ten clamps + meets")
    func goalPublishTen() throws {
        let mid = MasteryProgression(publishedTreeCount: 4, level: 1, readouts: readouts(mastered: 0, practiced: 0))
        #expect(mid.progress(for: .publishTen)?.current == 4)
        #expect(mid.progress(for: .publishTen)?.isMet == false)

        let past = MasteryProgression(publishedTreeCount: 25, level: 1, readouts: readouts(mastered: 0, practiced: 0))
        let gp = try #require(past.progress(for: .publishTen))
        #expect(gp.current == 10, "current clamps to the target")
        #expect(gp.fraction == 1.0)
        #expect(gp.isMet)
    }

    @Test("Reach-level-5 goal reflects the real XPEngine level")
    func goalReachLevelViaXPEngine() throws {
        // Genuine ForgeGamification path: derive the level from XP with the
        // app's real config, exactly as the Progress dashboard does.
        let engine = XPEngine(config: DialogueQuestGamification.makeConfig())
        let bigXP = 100_000
        let level = engine.level(for: bigXP)
        let p = MasteryProgression(publishedTreeCount: 1, level: level, readouts: readouts(mastered: 0, practiced: 0))
        let gp = try #require(p.progress(for: .reachLevelFive))
        #expect(gp.target == 5)
        #expect(gp.current == min(level, 5))
        if level >= 5 { #expect(gp.isMet) }

        // A level-0 learner is at 0/5.
        let zero = MasteryProgression(publishedTreeCount: 0, level: 0, readouts: readouts(mastered: 0, practiced: 0))
        #expect(zero.progress(for: .reachLevelFive)?.current == 0)
        #expect(zero.progress(for: .reachLevelFive)?.isMet == false)
    }

    @Test("Every Goal has a kid-facing menu label")
    func goalLabels() {
        for g in MasteryProgression.Goal.allCases {
            #expect(!g.menuLabel.isEmpty)
        }
    }
}
