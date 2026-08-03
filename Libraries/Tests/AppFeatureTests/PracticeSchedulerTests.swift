import Testing
import Foundation
import Models
@testable import AppFeature

/// Wave 5 (2026-08-02) — Mixed practice / practice-scheduling
/// (`Docs/HANDOFF_FROM_HUB_PRACTICE_SCHEDULING_WEB_BACKPORT.md`, ADR-048
/// axis 7). Covers the pure scheduler (FSRS-lite ladder, interleaving,
/// edge-of-competence, never-first-teaching), the round machine, and the
/// on-device store round-trip.
@Suite("Practice scheduling — ladder + interleave + store")
struct PracticeSchedulerTests {

    // MARK: - Fixtures

    private func question(_ id: String, correct: String = "a") -> QuestionKit.Question {
        QuestionKit.Question(
            id: id,
            prompt: "Prompt \(id)",
            options: [
                .init(id: "a", label: "A"),
                .init(id: "b", label: "B"),
            ],
            correctOptionID: correct,
            freeTextRubric: nil,
            mentorPostScript: "note \(id)"
        )
    }

    /// N questions for a kit, ids like "k1-q0".
    private func questions(_ kit: String, count: Int = 3) -> [QuestionKit.Question] {
        (0..<count).map { question("\(kit)-q\($0)") }
    }

    private let cal = Calendar(identifier: .gregorian)
    private let epoch = Date(timeIntervalSince1970: 1_700_000_000)

    // MARK: - Ladder

    @Test("Due dates follow the [1,3,7,16,35,75]-day ladder")
    func ladderDueDates() {
        #expect(PracticeScheduler.ladderDays == [1, 3, 7, 16, 35, 75])
        for (idx, days) in PracticeScheduler.ladderDays.enumerated() {
            let due = PracticeScheduler.nextDue(from: epoch, ladderIndex: idx, calendar: cal)
            let expected = cal.date(byAdding: .day, value: days, to: epoch)!
            #expect(due == expected)
        }
        // Out-of-range indices clamp.
        #expect(PracticeScheduler.nextDue(from: epoch, ladderIndex: 99, calendar: cal)
                == cal.date(byAdding: .day, value: 75, to: epoch)!)
    }

    @Test("A good review advances the ladder; a poor one relearns to 0")
    func advanceAndRelearn() {
        #expect(PracticeScheduler.advancedIndex(current: 0, quality: 0.6) == 1)
        #expect(PracticeScheduler.advancedIndex(current: 2, quality: 1.0) == 3)
        #expect(PracticeScheduler.advancedIndex(current: 5, quality: 1.0) == 5, "caps at the last rung")
        #expect(PracticeScheduler.advancedIndex(current: 3, quality: 0.59) == 0, "below 0.6 relearns")
        #expect(PracticeScheduler.advancedIndex(current: 3, quality: 0.0) == 0)
    }

    @Test("First review lands on rung 0; subsequent good advances; poor relearns")
    func stateAfterReview() {
        let first = PracticeScheduler.stateAfterReview(kitID: "k1", prior: nil, quality: 1.0, now: epoch, calendar: cal)
        #expect(first.ladderIndex == 0, "first review (introduction) lands on rung 0 regardless of quality")
        #expect(first.reviews == 1)
        #expect(first.dueAt == cal.date(byAdding: .day, value: 1, to: epoch)!)

        let second = PracticeScheduler.stateAfterReview(kitID: "k1", prior: first, quality: 0.9, now: epoch, calendar: cal)
        #expect(second.ladderIndex == 1)
        #expect(second.reviews == 2)

        let relearn = PracticeScheduler.stateAfterReview(kitID: "k1", prior: second, quality: 0.2, now: epoch, calendar: cal)
        #expect(relearn.ladderIndex == 0)
        #expect(relearn.reviews == 3)
    }

    // MARK: - Round assembly

    private func state(_ kit: String, index: Int, due: Date) -> KitReviewState {
        KitReviewState(kitID: kit, ladderIndex: index, lastReviewedAt: epoch, dueAt: due, reviews: 1)
    }

    @Test("Zero acquired → introduce the first kit (blocked, single kit)")
    func introduceWhenNoneAcquired() {
        let plan = PracticeScheduler.assembleRound(
            allKitIDs: ["k1", "k2", "k3"],
            states: [:],
            now: epoch,
            edgeDistance: { _ in 0 },
            questionsForKit: { self.questions($0) },
            questionsPerRound: 8
        )
        #expect(plan.kind == .introduce(kitID: "k1"))
        #expect(!plan.items.isEmpty)
        #expect(plan.items.allSatisfy { $0.kitID == "k1" }, "an introduction is blocked — one kit only")
    }

    @Test("One acquired + an un-acquired remaining → introduce next (still blocked)")
    func introduceSecondKit() {
        let states = ["k1": state("k1", index: 0, due: epoch)]
        let plan = PracticeScheduler.assembleRound(
            allKitIDs: ["k1", "k2", "k3"],
            states: states,
            now: epoch,
            edgeDistance: { _ in 0 },
            questionsForKit: { self.questions($0) },
            questionsPerRound: 8
        )
        #expect(plan.kind == .introduce(kitID: "k2"))
        #expect(plan.items.allSatisfy { $0.kitID == "k2" })
    }

    @Test("Two+ acquired → interleave round-robin, only over acquired kits")
    func interleaveOverAcquired() {
        let states = [
            "k1": state("k1", index: 0, due: epoch),   // due
            "k2": state("k2", index: 0, due: epoch),   // due
        ]
        let plan = PracticeScheduler.assembleRound(
            allKitIDs: ["k1", "k2", "k3"],   // k3 un-acquired — must NOT appear
            states: states,
            now: epoch,
            edgeDistance: { _ in 0 },
            questionsForKit: { self.questions($0, count: 3) },
            questionsPerRound: 6
        )
        guard case .interleave(let kitIDs) = plan.kind else {
            Issue.record("expected interleave, got \(plan.kind)")
            return
        }
        #expect(Set(kitIDs) == ["k1", "k2"])
        #expect(plan.items.count == 6)
        // Never a first teaching: no un-acquired kit appears.
        #expect(plan.items.allSatisfy { $0.kitID == "k1" || $0.kitID == "k2" })
        #expect(!plan.items.contains { $0.kitID == "k3" })
        // Round-robin: the first two items are from different kits.
        #expect(plan.items[0].kitID != plan.items[1].kitID)
    }

    @Test("Ordering is due-first, then closest to the ~70% band (edge of competence)")
    func edgeOfCompetenceOrdering() {
        let soon = epoch                                   // due
        let later = cal.date(byAdding: .day, value: 30, to: epoch)!   // not due
        let states = [
            "far":  state("far",  index: 2, due: soon),    // due, far from frontier
            "near": state("near", index: 2, due: soon),    // due, near frontier
            "future": state("future", index: 3, due: later), // not due
        ]
        // edgeDistance: "near" closest to 0.7 band, "far" farthest.
        let dist: [String: Double] = ["near": 0.05, "far": 0.5, "future": 0.0]
        let ordered = PracticeScheduler.orderedForRound(
            acquired: ["far", "near", "future"],
            states: states,
            now: epoch,
            edgeDistance: { dist[$0] ?? 1 }
        )
        // Due kits come before the not-due one; among due, "near" before "far".
        #expect(ordered.firstIndex(of: "near")! < ordered.firstIndex(of: "far")!)
        #expect(ordered.firstIndex(of: "far")! < ordered.firstIndex(of: "future")!)
    }

    // MARK: - Round machine

    @Test("Machine tallies first-try quality per kit")
    func machinePerKitQuality() {
        var m = MixedPracticeMachine()
        m.load([
            RoundItem(kitID: "k1", question: question("k1-q0", correct: "a")),
            RoundItem(kitID: "k1", question: question("k1-q1", correct: "a")),
            RoundItem(kitID: "k2", question: question("k2-q0", correct: "a")),
        ])
        // k1 q0 correct, k1 q1 wrong, k2 correct.
        m.select("a"); m.revealCurrent(); m.advance()   // k1 correct
        m.select("b"); m.revealCurrent(); m.advance()   // k1 wrong
        m.select("a"); m.revealCurrent(); m.advance()   // k2 correct
        #expect(m.isComplete)
        #expect(m.correctCount == 2)
        let q = m.perKitQuality
        #expect(q["k1"] == 0.5)
        #expect(q["k2"] == 1.0)
    }

    @Test("Empty round is immediately complete")
    func emptyRoundComplete() {
        var m = MixedPracticeMachine()
        m.load([])
        #expect(m.isComplete)
        #expect(m.perKitQuality.isEmpty)
    }

    // MARK: - Store round-trip

    @Test("Store persists + reloads the review log; recording advances the ladder")
    @MainActor
    func storeRoundTrip() throws {
        let suite = try #require(UserDefaults(suiteName: #file + "practice"))
        suite.removePersistentDomain(forName: #file + "practice")
        defer { suite.removePersistentDomain(forName: #file + "practice") }

        let service = MixedPracticeService(defaults: suite)
        #expect(service.acquiredCount == 0)
        service.recordRoundResults(perKitQuality: ["kit_01_voice_consistency": 1.0], now: epoch)
        #expect(service.acquiredCount == 1)

        // A fresh service over the same suite sees the persisted state.
        let reloaded = MixedPracticeService(defaults: suite)
        #expect(reloaded.acquiredCount == 1)
        let s = try #require(reloaded.states["kit_01_voice_consistency"])
        #expect(s.ladderIndex == 0, "first recorded review lands on rung 0")
        #expect(s.reviews == 1)
    }
}
