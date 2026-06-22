import Foundation

/// Welcome-back surface for kids who lapsed 3+ days. Per
/// `@Docs/FEATURE_PLAN.md` § Engagement Foundation, the return loop
/// surfaces a warm greeting + a recap of the kid's published tree
/// count when re-opening the app.
///
/// Phase 1 surface is intentionally simple: read `lastSessionDate` +
/// `publishedTreeCount` from `UserDefaults`. The "best tree recap"
/// (pulling the actual tree from SwiftData) lands in a follow-up
/// round once the persistence layer has the right query surface
/// — for now we frame the count in a warm message so the kid feels
/// remembered without inventing tree titles.
///
/// `ReturnLoopService` is a pure value type so it composes cleanly
/// with the RootView's banner overlay. The `dismiss` state lives on
/// the host view (per `.claude/rules/swiftui.md`).
@MainActor
public final class ReturnLoopService {
    public static let shared = ReturnLoopService()

    /// Calendar-day threshold for surfacing the welcome-back banner.
    /// 3 days matches the FEATURE_PLAN "lapsed user" definition.
    public static let lapseThresholdDays: Int = 3

    /// Persistence keys shared with `StreakService` (intentional) so
    /// the two services agree on the kid's session timeline.
    static let defaultsKeyLastSession = "dq.lastSessionDate"
    static let defaultsKeyPublishedTreeCount = "dq.publishedTreeCount"

    private let defaults: UserDefaults
    private let calendar: Calendar

    public init(
        defaults: UserDefaults = .standard,
        calendar: Calendar = .current
    ) {
        self.defaults = defaults
        self.calendar = calendar
    }

    /// Returns true when the kid has previously published at least
    /// one tree AND their last session was ≥ `lapseThresholdDays`
    /// calendar days ago.
    public func shouldShowWelcomeBack(now: Date = .now) -> Bool {
        guard publishedTreeCount() > 0 else { return false }
        guard let last = lastSessionDate() else { return false }
        let lastDay = calendar.startOfDay(for: last)
        let today = calendar.startOfDay(for: now)
        let components = calendar.dateComponents([.day], from: lastDay, to: today)
        let daysSince = components.day ?? 0
        return daysSince >= Self.lapseThresholdDays
    }

    /// Warm greeting text framing the kid's anthology size + the lapse.
    /// Stays in the age-9-14 register per
    /// `.claude/rules/distributed-narrative.md` § R-CHAPTER-REGISTER.
    public func welcomeBackMessage(now: Date = .now) -> String {
        let count = publishedTreeCount()
        let last = lastSessionDate()
        let daysSince: Int
        if let last {
            let lastDay = calendar.startOfDay(for: last)
            let today = calendar.startOfDay(for: now)
            daysSince = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        } else {
            daysSince = 0
        }
        let dayPhrase: String
        if daysSince >= 7 {
            dayPhrase = "It's been a week or more"
        } else {
            dayPhrase = "Welcome back"
        }
        if count == 1 {
            return "\(dayPhrase). Your first conversation is still in the anthology — want to write the next one?"
        }
        return "\(dayPhrase). Your \(count) conversations are in the anthology — want to add one more?"
    }

    // MARK: - Reads (visible for tests + RootView)

    public func publishedTreeCount() -> Int {
        defaults.integer(forKey: Self.defaultsKeyPublishedTreeCount)
    }

    public func lastSessionDate() -> Date? {
        let interval = defaults.double(forKey: Self.defaultsKeyLastSession)
        guard interval > 0 else { return nil }
        return Date(timeIntervalSinceReferenceDate: interval)
    }
}
