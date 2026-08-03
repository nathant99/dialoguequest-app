import Foundation
import Models
import Services

/// On-device store + round-assembly for Mixed practice. Persists the
/// per-kit spaced-retrieval log at `dq.sched.v1` (no identifier, nothing
/// transmitted) and assembles the next round from the app's real signals:
/// the 16 question kits + per-pillar craft mastery
/// (`DialogueCraftMasteryService`, which wraps `ForgeMasteryEngine`).
@MainActor
@Observable
public final class MixedPracticeService {
    public static let shared = MixedPracticeService()

    public nonisolated static let defaultsKey = "dq.sched.v1"

    private let defaults: UserDefaults
    /// Per-kit review state, keyed by kit id.
    public private(set) var states: [String: KitReviewState]

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.states = Self.decode(from: defaults)
    }

    // MARK: - Derived

    /// Kits the learner has practised at least once (so they can interleave).
    public var acquiredCount: Int { states.count }

    /// Kits due for a refresher now. Surfaced gently — never as a dread count.
    public func dueCount(now: Date = .now) -> Int {
        states.values.filter { $0.dueAt <= now }.count
    }

    // MARK: - Round assembly

    /// Assemble the next mixed-practice round from the current log + kits +
    /// mastery frontier. Returns an empty plan if no kits are loadable.
    public func assembleRound(now: Date = .now, questionsPerRound: Int = 8) -> RoundPlan {
        let (kits, _) = QuestionKitLoader.loadAllPhases()
        guard !kits.isEmpty else { return RoundPlan(kind: .empty, items: []) }
        let byID = Dictionary(kits.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let allKitIDs = QuestionKitLoader.allKits.filter { byID[$0] != nil }
        let mastery = DialogueCraftMasteryService.shared
        return PracticeScheduler.assembleRound(
            allKitIDs: allKitIDs,
            states: states,
            now: now,
            edgeDistance: { kitID in
                guard let theme = byID[kitID]?.theme, let pillar = Self.pillar(for: theme) else { return 1.0 }
                // |mastery − 0.7|: closest to the "just right" band sorts first.
                return abs(mastery.masteryScore(for: pillar) - 0.7)
            },
            questionsForKit: { byID[$0]?.questions ?? [] },
            questionsPerRound: questionsPerRound
        )
    }

    // MARK: - Recording

    /// Record the per-kit quality of a completed round (0…1 first-try
    /// fraction). Advances / relearns each kit's ladder.
    public func recordRoundResults(perKitQuality: [String: Double], now: Date = .now) {
        for (kitID, quality) in perKitQuality {
            states[kitID] = PracticeScheduler.stateAfterReview(
                kitID: kitID,
                prior: states[kitID],
                quality: quality,
                now: now
            )
        }
        save()
    }

    public func reset() {
        states = [:]
        defaults.removeObject(forKey: Self.defaultsKey)
    }

    // MARK: - Theme → pillar

    /// Map a kit theme to the craft pillar whose mastery orders it toward
    /// the edge-of-competence band.
    nonisolated static func pillar(for theme: QuestionKit.Theme) -> DialogueCraftTopic? {
        switch theme {
        case .voiceConsistency: return .voiceConsistency
        case .subtextDetection: return .subtextDetection
        case .tagBalance: return .tagBalance
        case .branching: return .branchMeaningfulness
        }
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(states) {
            defaults.set(data, forKey: Self.defaultsKey)
        }
    }

    private nonisolated static func decode(from defaults: UserDefaults) -> [String: KitReviewState] {
        guard let data = defaults.data(forKey: defaultsKey),
              let decoded = try? JSONDecoder().decode([String: KitReviewState].self, from: data)
        else { return [:] }
        return decoded
    }
}
