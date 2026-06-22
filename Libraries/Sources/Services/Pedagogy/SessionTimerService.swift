import Foundation

/// Session-targeting service per `@Docs/FEATURE_PLAN.md` § Engagement
/// Foundation. Hosts a soft 10-15 minute window: emits a `.gentleNudge`
/// at the soft floor (`gentleNudgeAfter`, default 10 min) so the kid
/// gets a "good stopping point" prompt and a `.endingSummaryReady` at
/// the soft ceiling (`endingSummaryAfter`, default 13 min) so the
/// host view can render a one-screen end-of-session summary.
///
/// `SessionTimerService` is pure value-type state + a tiny driver. It
/// does NOT own a `Timer`; the host view (typically `RootView`) drives
/// it via `.task { ... try await Task.sleep(...) }` so we never hit the
/// `_dispatch_assert_queue_fail` Heisenbug class flagged in
/// `.claude/rules/concurrency.md` § "Timer.scheduledTimer +
/// `Task { @MainActor in }`...".
///
/// Storage is in-memory only — the rule per `@Docs/TECHNICAL_DESIGN.md`
/// § Analytics is "no persisted PII." Session duration data resets at
/// app launch.
@MainActor
@Observable
public final class SessionTimerService {

    /// Discrete signals the host view observes via `.onChange(of:)`.
    public enum Phase: Sendable, Equatable {
        /// Pre-start state; `start()` has not been called yet.
        case idle
        /// Inside the soft target window (≤ `gentleNudgeAfter`).
        case running
        /// Crossed the soft floor — host can render a "good stopping
        /// point" affordance without forcing the kid out.
        case gentleNudgeReady
        /// Crossed the soft ceiling — host can render the ending
        /// summary sheet at the next clean break.
        case endingSummaryReady
    }

    /// Configurable thresholds. Reasonable defaults per the
    /// 10-15 minute Phase 1 target.
    public struct Config: Sendable, Equatable {
        public var gentleNudgeAfter: TimeInterval
        public var endingSummaryAfter: TimeInterval

        public init(
            gentleNudgeAfter: TimeInterval = 10 * 60,
            endingSummaryAfter: TimeInterval = 13 * 60
        ) {
            self.gentleNudgeAfter = gentleNudgeAfter
            self.endingSummaryAfter = endingSummaryAfter
        }

        public static let `default` = Config()
    }

    public private(set) var phase: Phase = .idle
    public private(set) var startedAt: Date?
    public let config: Config

    public init(config: Config = .default) {
        self.config = config
    }

    /// Start (or restart) the session window. Idempotent within a single
    /// running window — re-call only resets when phase is `.idle`. To
    /// force a restart, call `reset()` first.
    public func start(now: Date = .now) {
        guard phase == .idle else { return }
        startedAt = now
        phase = .running
    }

    /// Reset to the empty state. Called when the kid finishes the
    /// ending summary OR backgrounds the app for > N minutes (host
    /// decides the policy).
    public func reset() {
        phase = .idle
        startedAt = nil
    }

    /// Re-evaluate phase against the supplied wall-clock. Pure function
    /// over elapsed time so it's trivially testable. The host typically
    /// calls this from a `.task` loop with `Task.sleep(for: .seconds(15))`
    /// granularity.
    public func tick(now: Date = .now) {
        guard let startedAt, phase != .idle else { return }
        let elapsed = now.timeIntervalSince(startedAt)
        let next = Self.derive(elapsed: elapsed, config: config)
        // Only advance forward — once we've shown the ending summary we
        // don't backslide to gentleNudge if the host pauses + resumes.
        if Self.priority(next) > Self.priority(phase) {
            phase = next
        }
    }

    /// Convenience: how long has the current window been running?
    /// Returns 0 when idle.
    public func elapsed(now: Date = .now) -> TimeInterval {
        guard let startedAt else { return 0 }
        return now.timeIntervalSince(startedAt)
    }

    // MARK: - Pure helpers (visible for tests)

    static func derive(elapsed: TimeInterval, config: Config) -> Phase {
        if elapsed >= config.endingSummaryAfter { return .endingSummaryReady }
        if elapsed >= config.gentleNudgeAfter { return .gentleNudgeReady }
        return .running
    }

    private static func priority(_ phase: Phase) -> Int {
        switch phase {
        case .idle: return 0
        case .running: return 1
        case .gentleNudgeReady: return 2
        case .endingSummaryReady: return 3
        }
    }
}
