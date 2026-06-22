import Foundation

/// Dynamic Difficulty Adjustment (DDA) engine — invisible difficulty
/// calibration for DialogueQuest's branch-meaningfulness threshold +
/// voice-match score floor. Per `@Docs/TECHNICAL_DESIGN.md` §
/// Engagement & Retention Engine + `@Docs/FEATURE_PLAN.md` §
/// Engagement Foundation.
///
/// Pure value type so it composes cleanly with `PatterReactionService`
/// + `BranchMeaningfulnessScorer`. The engine holds a rolling window
/// of the most-recent N tree-publish outcomes and adjusts the per-tree
/// thresholds by ±10% within bounded floor / ceiling values. Trying
/// hard sessions raises both thresholds; struggling lowers them.
///
/// **Design notes**:
/// - Single source of truth for thresholds, so other surfaces
///   (the publishStripe disabled-state hint, dashboards, mentor
///   coaching tone) all read the SAME calibrated values.
/// - Update API takes a `RecentOutcome` snapshot, NOT raw events —
///   keeps the engine ignorant of the rest of the domain model.
/// - All thresholds bounded so the engine can't spiral into
///   degenerate states (e.g., score floor 0.0 would let any line
///   through; the FLOOR floor is 0.30).
public nonisolated struct DDAEngine: Sendable, Equatable {

    /// Configurable parameters. Reasonable defaults derived from
    /// `FEATURE_PLAN.md`'s engagement targets (10-15 minute sessions,
    /// 60-second aha moment).
    public struct Config: Sendable, Equatable {
        public var windowSize: Int
        public var rampStep: Double
        public var branchReflectionFloor: Double
        public var branchReflectionCeiling: Double
        public var voiceMatchFloor: Double
        public var voiceMatchCeiling: Double

        public init(
            windowSize: Int = 5,
            rampStep: Double = 0.10,
            branchReflectionFloor: Double = 0.20,
            branchReflectionCeiling: Double = 0.90,
            voiceMatchFloor: Double = 0.30,
            voiceMatchCeiling: Double = 0.80
        ) {
            self.windowSize = windowSize
            self.rampStep = rampStep
            self.branchReflectionFloor = branchReflectionFloor
            self.branchReflectionCeiling = branchReflectionCeiling
            self.voiceMatchFloor = voiceMatchFloor
            self.voiceMatchCeiling = voiceMatchCeiling
        }

        public static let `default` = Config()
    }

    /// Per-tree outcome snapshot fed into `record(outcome:)`.
    public struct RecentOutcome: Sendable, Equatable {
        public let reflectionRatio: Double      // 0...1
        public let averageVoiceMatch: Double    // 0...1
        public init(reflectionRatio: Double, averageVoiceMatch: Double) {
            self.reflectionRatio = max(0, min(1, reflectionRatio))
            self.averageVoiceMatch = max(0, min(1, averageVoiceMatch))
        }
    }

    public let config: Config
    public private(set) var currentReflectionThreshold: Double
    public private(set) var currentVoiceMatchFloor: Double
    public private(set) var recentOutcomes: [RecentOutcome]

    public init(config: Config = .default) {
        self.config = config
        // Start at midpoint between floor + ceiling so first runs
        // converge from neutral, not biased high or low.
        self.currentReflectionThreshold = (config.branchReflectionFloor + config.branchReflectionCeiling) / 2
        self.currentVoiceMatchFloor = (config.voiceMatchFloor + config.voiceMatchCeiling) / 2
        self.recentOutcomes = []
    }

    /// Push a new outcome into the rolling window and ramp thresholds
    /// up / down based on the window's running average. Pure mutation
    /// (no side effects) so easy to test.
    public mutating func record(outcome: RecentOutcome) {
        recentOutcomes.append(outcome)
        if recentOutcomes.count > config.windowSize {
            recentOutcomes.removeFirst(recentOutcomes.count - config.windowSize)
        }
        let avgReflection = recentOutcomes.map(\.reflectionRatio).reduce(0, +) / Double(recentOutcomes.count)
        let avgVoice = recentOutcomes.map(\.averageVoiceMatch).reduce(0, +) / Double(recentOutcomes.count)

        // Ramp the reflection threshold toward the kid's recent reflection ratio
        // but never let one outlier swing more than rampStep in either direction.
        currentReflectionThreshold = clamp(
            adjust(currentReflectionThreshold, toward: avgReflection),
            lower: config.branchReflectionFloor,
            upper: config.branchReflectionCeiling
        )
        currentVoiceMatchFloor = clamp(
            adjust(currentVoiceMatchFloor, toward: avgVoice),
            lower: config.voiceMatchFloor,
            upper: config.voiceMatchCeiling
        )
    }

    public mutating func reset() {
        self = DDAEngine(config: config)
    }

    // MARK: - Private helpers

    private func adjust(_ current: Double, toward target: Double) -> Double {
        let delta = target - current
        let stepped = delta > 0
            ? min(delta, config.rampStep)
            : max(delta, -config.rampStep)
        return current + stepped
    }

    private func clamp(_ value: Double, lower: Double, upper: Double) -> Double {
        max(lower, min(upper, value))
    }
}
