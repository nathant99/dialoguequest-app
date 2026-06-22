import Foundation

/// D1 / D7 / D30 retention metrics, on-device only.
///
/// Per `@Docs/TECHNICAL_DESIGN.md` § Analytics + `.claude/rules/age-assurance.md`:
/// no PII collection, no third-party analytics SDKs, no outbound
/// network. The service simply records whether the kid has re-opened
/// the app within 1 / 7 / 30 calendar days of first install. Stats are
/// boolean flags + the install date — nothing identifying.
///
/// Phase 1 consumers: future parent-progress dashboard rendering a
/// "you've come back N of M target days" affordance, and the in-app
/// telemetry surface. No outbound use.
@MainActor
public final class RetentionMetricsService {
    public static let shared = RetentionMetricsService()

    static let defaultsKeyFirstLaunch = "dq.retention.firstLaunchDate"
    static let defaultsKeyD1 = "dq.retention.d1"
    static let defaultsKeyD7 = "dq.retention.d7"
    static let defaultsKeyD30 = "dq.retention.d30"

    /// Snapshot read by view consumers.
    public struct Snapshot: Sendable, Equatable {
        public var firstLaunch: Date?
        public var hitD1: Bool
        public var hitD7: Bool
        public var hitD30: Bool

        public init(firstLaunch: Date?, hitD1: Bool, hitD7: Bool, hitD30: Bool) {
            self.firstLaunch = firstLaunch
            self.hitD1 = hitD1
            self.hitD7 = hitD7
            self.hitD30 = hitD30
        }
    }

    private let defaults: UserDefaults
    private let calendar: Calendar

    public init(
        defaults: UserDefaults = .standard,
        calendar: Calendar = .current
    ) {
        self.defaults = defaults
        self.calendar = calendar
    }

    /// Record an app-open event. Idempotent within a single calendar
    /// day. Seeds `firstLaunchDate` on the very first call.
    public func recordAppOpen(now: Date = .now) {
        if firstLaunchDate() == nil {
            defaults.set(now.timeIntervalSinceReferenceDate, forKey: Self.defaultsKeyFirstLaunch)
            // The first open IS the first launch — D1 etc. all evaluate
            // against future opens, not this one.
            return
        }
        guard let first = firstLaunchDate() else { return }
        let firstDay = calendar.startOfDay(for: first)
        let today = calendar.startOfDay(for: now)
        let components = calendar.dateComponents([.day], from: firstDay, to: today)
        let daysSince = components.day ?? 0
        if daysSince >= 1, !defaults.bool(forKey: Self.defaultsKeyD1) {
            defaults.set(true, forKey: Self.defaultsKeyD1)
        }
        if daysSince >= 7, !defaults.bool(forKey: Self.defaultsKeyD7) {
            defaults.set(true, forKey: Self.defaultsKeyD7)
        }
        if daysSince >= 30, !defaults.bool(forKey: Self.defaultsKeyD30) {
            defaults.set(true, forKey: Self.defaultsKeyD30)
        }
    }

    public func snapshot() -> Snapshot {
        Snapshot(
            firstLaunch: firstLaunchDate(),
            hitD1: defaults.bool(forKey: Self.defaultsKeyD1),
            hitD7: defaults.bool(forKey: Self.defaultsKeyD7),
            hitD30: defaults.bool(forKey: Self.defaultsKeyD30)
        )
    }

    /// Reset for tests + parental "clear progress" flows.
    public func reset() {
        defaults.removeObject(forKey: Self.defaultsKeyFirstLaunch)
        defaults.removeObject(forKey: Self.defaultsKeyD1)
        defaults.removeObject(forKey: Self.defaultsKeyD7)
        defaults.removeObject(forKey: Self.defaultsKeyD30)
    }

    // MARK: - Reads

    public func firstLaunchDate() -> Date? {
        let interval = defaults.double(forKey: Self.defaultsKeyFirstLaunch)
        guard interval > 0 else { return nil }
        return Date(timeIntervalSinceReferenceDate: interval)
    }
}
