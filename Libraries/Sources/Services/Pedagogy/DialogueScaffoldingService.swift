import Foundation
import ForgePedagogy

/// DialogueQuest's adoption of ForgeKit 0.99's `ScaffoldingEngine` +
/// `HintTier`. Drives an articulate-before-hint discipline aligned with
/// Patter's "validate-then-inform" voice register:
///
/// - **Success** = kid published a tree with at least one branch
///   reflected upon (the reflection IS the kid's plan in Polya terms).
/// - **Failure** = kid published a tree without reflecting on any
///   branch point. Repeated failures escalate Patter's scaffolding
///   tier so the kid sees more directive hints over time; consistent
///   successes auto-fade scaffolding back to no-hints.
///
/// `ScaffoldingEngine` does the pure-logic mutation; this service
/// persists `ScaffoldingState` to UserDefaults so the tier survives
/// across launches.
///
/// Phase 1 wiring is advisory only — the current tier is exposed via
/// `currentTier` for future Patter surfaces to consult. Existing
/// coaching surfaces (Socratic prompts, cast voicings, tag-balance
/// tips) continue to fire without consulting the scaffolding tier;
/// the tier informs the WORDING of future hint surfaces (Phase 2+).
@MainActor
public final class DialogueScaffoldingService {
    public static let shared = DialogueScaffoldingService()

    static let defaultsKeyTier = "dq.scaffolding.currentTier"
    static let defaultsKeyIsScaffolded = "dq.scaffolding.isScaffolded"
    static let defaultsKeyConsecutiveSuccesses = "dq.scaffolding.consecutiveSuccesses"
    static let defaultsKeyConsecutiveFailures = "dq.scaffolding.consecutiveFailures"
    static let defaultsKeyScaffoldedSolves = "dq.scaffolding.scaffoldedSolves"
    static let defaultsKeyIndependentSolves = "dq.scaffolding.independentSolves"

    private let defaults: UserDefaults
    private let engine: ScaffoldingEngine
    private var state: ScaffoldingState

    public init(
        defaults: UserDefaults = .standard,
        config: ScaffoldingConfig = ScaffoldingConfig(fadeThreshold: 3, restoreThreshold: 2)
    ) {
        self.defaults = defaults
        self.engine = ScaffoldingEngine(config: config)
        self.state = Self.loadState(from: defaults)
    }

    /// Record a publish where the kid reflected on at least one branch
    /// point. Counts as a success — engine fades scaffolding after the
    /// `fadeThreshold` (default 3) consecutive successes.
    public func recordPublishedWithReflection() {
        engine.recordSuccess(state: &state)
        persistState()
    }

    /// Record a publish where the kid did NOT reflect on any branch
    /// point. Counts as a failure — engine escalates the hint tier
    /// (or restores scaffolding from a faded state) after the
    /// `restoreThreshold` (default 2) consecutive failures.
    public func recordPublishedWithoutReflection() {
        engine.recordFailure(state: &state)
        persistState()
    }

    /// Current hint tier — `nil` when scaffolding has auto-faded (the
    /// kid is hitting publish + reflect consistently and Patter steps
    /// back). Future Patter surfaces consult this to decide whether to
    /// surface a `.vague` directional nudge, a `.medium` worked
    /// suggestion, or `.specific` example text.
    public var currentTier: HintTier? {
        state.currentTier
    }

    /// True when scaffolding is currently active. Convenience reader
    /// for views that want to render a "Patter is here to help"
    /// affordance vs the bare authoring surface.
    public var isScaffolded: Bool {
        state.isScaffolded
    }

    /// Proportion of publishes the kid completed without scaffolding
    /// active (0.0-1.0). 1.0 means no publishes yet, or every publish
    /// happened with scaffolding faded — the kid is operating
    /// independently.
    public var independenceRate: Double {
        state.independenceRate
    }

    /// Test seam — replaces the persisted state with a fresh `ScaffoldingState()`.
    /// Production code never calls this; tests use it to reset between cases.
    public func reset() {
        engine.reset(state: &state)
        persistState()
    }

    // MARK: - Persistence

    private func persistState() {
        defaults.set(state.currentTier?.rawValue, forKey: Self.defaultsKeyTier)
        defaults.set(state.isScaffolded, forKey: Self.defaultsKeyIsScaffolded)
        defaults.set(state.consecutiveSuccesses, forKey: Self.defaultsKeyConsecutiveSuccesses)
        defaults.set(state.consecutiveFailures, forKey: Self.defaultsKeyConsecutiveFailures)
        defaults.set(state.scaffoldedSolves, forKey: Self.defaultsKeyScaffoldedSolves)
        defaults.set(state.independentSolves, forKey: Self.defaultsKeyIndependentSolves)
    }

    private static func loadState(from defaults: UserDefaults) -> ScaffoldingState {
        var state = ScaffoldingState()
        if let raw = defaults.object(forKey: defaultsKeyTier) as? Int,
           let tier = HintTier(rawValue: raw) {
            state.currentTier = tier
        }
        state.isScaffolded = defaults.bool(forKey: defaultsKeyIsScaffolded)
        state.consecutiveSuccesses = defaults.integer(forKey: defaultsKeyConsecutiveSuccesses)
        state.consecutiveFailures = defaults.integer(forKey: defaultsKeyConsecutiveFailures)
        state.scaffoldedSolves = defaults.integer(forKey: defaultsKeyScaffoldedSolves)
        state.independentSolves = defaults.integer(forKey: defaultsKeyIndependentSolves)
        return state
    }
}
