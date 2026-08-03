import Foundation
import Models

/// On-device practice-scheduling for the "Mixed practice" mode
/// (`Docs/HANDOFF_FROM_HUB_PRACTICE_SCHEDULING_WEB_BACKPORT.md`, ADR-048
/// axis 7). Three mechanisms, mirroring the web clone's `review.ts`:
///
/// 1. **Spaced retrieval (FSRS-lite).** An acquired kit resurfaces on an
///    expanding day-ladder `[1, 3, 7, 16, 35, 75]`. A good review
///    (quality ≥ 0.6) advances the ladder; a poor one relearns (rung 0).
/// 2. **Interleaving.** A round samples questions round-robin across ≥2
///    *already-acquired* kits — never a kit's first teaching.
/// 3. **Edge-of-competence.** Due kits are ordered toward the ~70% "just
///    right" band first (Vygotsky ZPD), via the kit theme's craft-pillar
///    mastery.
///
/// Calm-rails: this **orders + resurfaces, it never gates**. There is no
/// due-count dread, no streak-guilt — just a gentle come-back invitation.
/// All on-device (`dq.sched.v1`), no identifier, nothing transmitted.
///
/// The scheduling engine here is a fixed-ladder FSRS-lite matching the web
/// contract for parity + determinism; `ForgeGamification.SpacedRepetitionEngine`
/// (FSRS-6) is the available upgrade path for a future full-FSRS revision.

/// Per-kit spaced-retrieval state.
public nonisolated struct KitReviewState: Codable, Sendable, Equatable {
    public var kitID: String
    /// Index into `PracticeScheduler.ladderDays`.
    public var ladderIndex: Int
    public var lastReviewedAt: Date
    public var dueAt: Date
    public var reviews: Int

    public init(kitID: String, ladderIndex: Int, lastReviewedAt: Date, dueAt: Date, reviews: Int) {
        self.kitID = kitID
        self.ladderIndex = ladderIndex
        self.lastReviewedAt = lastReviewedAt
        self.dueAt = dueAt
        self.reviews = reviews
    }
}

/// One question in an assembled round, tagged with its source kit so the
/// round can record a per-kit review on completion.
public nonisolated struct RoundItem: Sendable, Equatable {
    public let kitID: String
    public let question: QuestionKit.Question
    public init(kitID: String, question: QuestionKit.Question) {
        self.kitID = kitID
        self.question = question
    }
}

/// The plan for the next mixed-practice round.
public nonisolated struct RoundPlan: Sendable, Equatable {
    public enum Kind: Sendable, Equatable {
        /// Fewer than two acquired kits — introduce a new kit (blocked;
        /// this is a first teaching, NOT interleaved).
        case introduce(kitID: String)
        /// Interleaved review across ≥2 already-acquired kits (ordered).
        case interleave(kitIDs: [String])
        /// Nothing to practice yet.
        case empty
    }
    public let kind: Kind
    public let items: [RoundItem]
    public init(kind: Kind, items: [RoundItem]) {
        self.kind = kind
        self.items = items
    }
}

/// Pure scheduling logic — no persistence, no UI. Injecting the mastery +
/// question closures keeps it fully unit-testable.
public nonisolated enum PracticeScheduler {
    /// FSRS-lite day-ladder (web parity).
    public static let ladderDays: [Int] = [1, 3, 7, 16, 35, 75]

    /// Next due date = `lastReviewed` + the ladder's day count at `ladderIndex`.
    public static func nextDue(from lastReviewed: Date, ladderIndex: Int, calendar: Calendar = .current) -> Date {
        let idx = min(max(ladderIndex, 0), ladderDays.count - 1)
        return calendar.date(byAdding: .day, value: ladderDays[idx], to: lastReviewed) ?? lastReviewed
    }

    /// The ladder index after a review of the given `quality`. A good
    /// review (≥ 0.6) advances one rung (capped); a poor one relearns to 0.
    public static func advancedIndex(current: Int, quality: Double) -> Int {
        if quality >= 0.6 { return min(current + 1, ladderDays.count - 1) }
        return 0
    }

    /// The state after recording a review. First review (no prior state)
    /// lands on rung 0 regardless of quality (introduction → due in 1 day).
    public static func stateAfterReview(
        kitID: String,
        prior: KitReviewState?,
        quality: Double,
        now: Date,
        calendar: Calendar = .current
    ) -> KitReviewState {
        let newIndex: Int
        if let prior {
            newIndex = advancedIndex(current: prior.ladderIndex, quality: quality)
        } else {
            newIndex = 0
        }
        return KitReviewState(
            kitID: kitID,
            ladderIndex: newIndex,
            lastReviewedAt: now,
            dueAt: nextDue(from: now, ladderIndex: newIndex, calendar: calendar),
            reviews: (prior?.reviews ?? 0) + 1
        )
    }

    /// Acquired kits = those with a recorded review state, in `allKitIDs` order.
    public static func acquiredKitIDs(allKitIDs: [String], states: [String: KitReviewState]) -> [String] {
        allKitIDs.filter { states[$0] != nil }
    }

    /// Order acquired kits for a round: due-first, then edge-of-competence
    /// (closest to the ~70% band first), then most-overdue first.
    public static func orderedForRound(
        acquired: [String],
        states: [String: KitReviewState],
        now: Date,
        edgeDistance: (String) -> Double
    ) -> [String] {
        acquired.sorted { a, b in
            let aDue = (states[a]?.dueAt ?? .distantFuture) <= now
            let bDue = (states[b]?.dueAt ?? .distantFuture) <= now
            if aDue != bDue { return aDue && !bDue }          // due first
            let ea = edgeDistance(a), eb = edgeDistance(b)
            if ea != eb { return ea < eb }                    // frontier first
            let da = states[a]?.dueAt ?? .distantFuture
            let db = states[b]?.dueAt ?? .distantFuture
            return da < db                                    // most overdue first
        }
    }

    /// Assemble the next round.
    /// - `edgeDistance`: `|themeMastery − 0.7|` for a kit (ascending = frontier).
    /// - `questionsForKit`: the kit's questions, in order.
    public static func assembleRound(
        allKitIDs: [String],
        states: [String: KitReviewState],
        now: Date,
        edgeDistance: (String) -> Double,
        questionsForKit: (String) -> [QuestionKit.Question],
        questionsPerRound: Int = 8
    ) -> RoundPlan {
        let acquired = acquiredKitIDs(allKitIDs: allKitIDs, states: states)

        // Fewer than 2 acquired → introduce the next un-acquired kit
        // (blocked first teaching), never interleaved.
        if acquired.count < 2 {
            if let next = allKitIDs.first(where: { states[$0] == nil }) {
                let items = Array(questionsForKit(next).prefix(questionsPerRound))
                    .map { RoundItem(kitID: next, question: $0) }
                return RoundPlan(kind: items.isEmpty ? .empty : .introduce(kitID: next), items: items)
            }
            // No un-acquired kit left. If we have exactly one acquired kit,
            // just review it; otherwise nothing to do.
            if acquired.isEmpty { return RoundPlan(kind: .empty, items: []) }
        }

        // Interleave round-robin across the ordered acquired kits.
        let ordered = orderedForRound(acquired: acquired, states: states, now: now, edgeDistance: edgeDistance)
        var pools: [String: [QuestionKit.Question]] = [:]
        for kit in ordered { pools[kit] = questionsForKit(kit) }
        var cursor: [String: Int] = [:]
        var items: [RoundItem] = []
        var exhaustedPasses = 0
        while items.count < questionsPerRound, exhaustedPasses < ordered.count {
            exhaustedPasses = 0
            for kit in ordered {
                guard items.count < questionsPerRound else { break }
                let pool = pools[kit] ?? []
                guard !pool.isEmpty else { exhaustedPasses += 1; continue }
                let idx = (cursor[kit] ?? 0)
                items.append(RoundItem(kitID: kit, question: pool[idx % pool.count]))
                cursor[kit] = idx + 1
            }
        }
        return RoundPlan(kind: ordered.isEmpty ? .empty : .interleave(kitIDs: ordered), items: items)
    }
}
