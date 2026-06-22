import Foundation
import ForgeGamification
import ForgeModels
import Models

/// DialogueQuest's streak coordinator. Wraps ForgeGamification's
/// `StreakManager` actor + persists the kid's last-session date,
/// current streak, and available freezes via `UserDefaults` so the
/// streak advances across app launches.
///
/// Callers invoke `recordPublishedTree()` after a publish event so the
/// streak counter actually moves. `ProgressDashboardView` reads the
/// resulting values via `@AppStorage("dq.currentStreak")` +
/// `@AppStorage("dq.streakFreezes")` — UserDefaults is the canonical
/// store for both surfaces, so the dashboard re-renders on next read
/// without any explicit bridging.
///
/// `StreakManager`'s initializer is MainActor-isolated (ForgeKit 0.99
/// constraint), so this coordinator is `@MainActor` rather than its
/// own actor. UserDefaults access is thread-safe regardless, and the
/// underlying `StreakManager` actor still serializes mutation via
/// its own isolation domain.
@MainActor
public final class StreakService {
    public static let shared = StreakService()

    static let defaultsKeyStreak = "dq.currentStreak"
    static let defaultsKeyFreezes = "dq.streakFreezes"
    static let defaultsKeyLastSession = "dq.lastSessionDate"

    /// Warm broken-streak nudge per `@Docs/FEATURE_PLAN.md` § Engagement
    /// Foundation. Phase 1 surface: when `inspectStreakStatus()` returns
    /// `.broken(previousStreak:)`, the host renders this message in a
    /// MentorBubbleView so the kid sees a "your characters miss you"
    /// frame instead of a numeric "0".
    public static let brokenStreakMessage = "Your characters miss you. Want to write one more line together?"

    /// Status snapshot read by views that want to surface streak-aware
    /// UX without driving a `recordSession()` call.
    public enum Status: Sendable, Equatable {
        /// Streak has never been started — no record yet.
        case neverStarted
        /// Active streak; last session was today (or yesterday, depending
        /// on `StreakManager` contract).
        case active(streak: Int)
        /// Streak was broken since the last session. `previousStreak`
        /// helps the host word the broken-streak nudge ("you were on a
        /// 7-day streak").
        case broken(previousStreak: Int)
    }

    private let defaults: UserDefaults
    private let config: GamificationConfig
    private let calendar: Calendar

    /// Lazily built so the first `recordPublishedTree()` call seeds
    /// from persisted state. We re-create on each call to pick up
    /// out-of-band writes (e.g., another future surface that nudges
    /// the streak). For Phase 1 the only writer is this service.
    private var manager: StreakManager?

    public init(
        defaults: UserDefaults = .standard,
        config: GamificationConfig = DialogueQuestGamification.makeConfig(),
        calendar: Calendar = .current
    ) {
        self.defaults = defaults
        self.config = config
        self.calendar = calendar
    }

    /// Bump the streak via the canonical `StreakManager.recordSession`
    /// flow and persist results back to UserDefaults. Returns the
    /// underlying `StreakResult` so callers can drive UX surfaces
    /// (e.g., a `.frozenAndContinued` result drives the freeze-used
    /// affordance in a future telemetry round).
    @discardableResult
    public func recordPublishedTree() async -> StreakResult {
        let manager = ensureManager()
        let result = await manager.recordSession()
        persistAfter(result: result)
        return result
    }

    /// Mood-aware overload. Maps the published tree's `DialogueMood` to a
    /// `ForgeModels.EmotionSnapshot` (`source: .behavioral` — inferred
    /// from authoring content, not biometrics) and routes through
    /// ForgeKit 0.86's `StreakManager.recordSession(emotionSnapshot:)`
    /// path. When the mood reads as a "hard scene" (`.quietConflict` /
    /// `.awkwardSilence`) the distress score crosses the 0.65 default
    /// threshold and the streak is held instead of advanced — the kid
    /// stays in flow without losing yesterday's progress on a difficult
    /// piece.
    @discardableResult
    public func recordPublishedTree(mood: DialogueMood?) async -> StreakResult {
        let manager = ensureManager()
        let snapshot = Self.emotionSnapshot(for: mood)
        let result = await manager.recordSession(
            date: .now,
            emotionSnapshot: snapshot
        )
        persistAfter(result: result)
        return result
    }

    /// Public mapping so consumers (tests + future hosts) can read the
    /// distress score for a mood without needing to run the manager.
    public static func emotionSnapshot(for mood: DialogueMood?) -> EmotionSnapshot? {
        guard let mood else { return nil }
        let distress: Double
        switch mood {
        case .quietConflict:    distress = 0.75
        case .awkwardSilence:   distress = 0.70
        case .openingCuriosity: distress = 0.15
        case .playfulRivalry:   distress = 0.20
        case .warmReunion:      distress = 0.10
        }
        // Arousal stays mid-band — the writing-craft surface isn't a
        // physiological signal. `.derivedFromTask` tells the ForgeKit
        // pipeline this is inferred from the kid's published mood tag,
        // not biometric (never camera / voice / heart rate).
        return EmotionSnapshot(
            distressScore: distress,
            arousalScore: 0.50,
            valenceScore: nil,
            capturedAt: .now,
            source: .derivedFromTask
        )
    }

    /// Read the persisted streak count without advancing it.
    public func currentStreak() -> Int {
        defaults.integer(forKey: Self.defaultsKeyStreak)
    }

    public func availableFreezes() -> Int {
        (defaults.object(forKey: Self.defaultsKeyFreezes) as? Int) ?? config.streakFreezeCount
    }

    public func lastSessionDate() -> Date? {
        let interval = defaults.double(forKey: Self.defaultsKeyLastSession)
        guard interval > 0 else { return nil }
        return Date(timeIntervalSinceReferenceDate: interval)
    }

    /// Read-only snapshot of streak status (does not advance the
    /// underlying StreakManager). Use this from `RootView` to decide
    /// whether to render `brokenStreakMessage`.
    ///
    /// The "broken" branch fires when there's a persisted streak ≥ 1
    /// AND the last session was ≥ 2 calendar days ago AND the kid has
    /// already exhausted freezes (or has more lapsed days than freezes
    /// can cover). The implementation is intentionally simpler than
    /// `StreakManager`'s internal freeze logic — it's a UX hint, not a
    /// canonical streak calculation. The actual `recordSession()` call
    /// is still authoritative.
    public func inspectStreakStatus(now: Date = .now) -> Status {
        let streak = currentStreak()
        guard let last = lastSessionDate(), streak > 0 else {
            return .neverStarted
        }
        // Calendar-day delta (start-of-day-aware so a 1-hour wall-clock
        // jitter across midnight still reads as "next day", matching
        // `StreakManager`'s semantics).
        let lastDay = calendar.startOfDay(for: last)
        let today = calendar.startOfDay(for: now)
        let components = calendar.dateComponents([.day], from: lastDay, to: today)
        let daysSince = components.day ?? 0
        if daysSince <= 1 {
            return .active(streak: streak)
        }
        // Lapse window: each available freeze covers one missed day.
        let freezes = availableFreezes()
        let coveredDays = freezes
        let uncoveredLapse = max(0, daysSince - 1 - coveredDays)
        if uncoveredLapse > 0 {
            return .broken(previousStreak: streak)
        }
        return .active(streak: streak)
    }

    // MARK: - Private

    private func ensureManager() -> StreakManager {
        if let manager { return manager }
        let savedStreak = defaults.integer(forKey: Self.defaultsKeyStreak)
        let savedFreezes = (defaults.object(forKey: Self.defaultsKeyFreezes) as? Int)
            ?? config.streakFreezeCount
        let lastSession = lastSessionDate()
        let built = StreakManager(
            currentStreak: savedStreak,
            longestStreak: savedStreak,
            availableFreezes: savedFreezes,
            lastSessionDate: lastSession
        )
        self.manager = built
        return built
    }

    private func persistAfter(result: StreakResult) {
        let storedStreak: Int
        let storedFreezes: Int
        let analyticsEvent: DialogueQuestAnalytics.Event?
        switch result {
        case .continued(let streak):
            storedStreak = streak
            storedFreezes = availableFreezes()
            analyticsEvent = .streakAdvanced
        case .frozenAndContinued(let streak, let remaining):
            storedStreak = streak
            storedFreezes = remaining
            analyticsEvent = .streakAdvanced
        case .reset:
            // After a reset, the recordSession call itself counts as
            // day 1 of the new streak — StreakManager's contract.
            storedStreak = 1
            storedFreezes = config.streakFreezeCount
            analyticsEvent = .streakBroken
        case .sameDay(let streak):
            storedStreak = streak
            storedFreezes = availableFreezes()
            analyticsEvent = nil
        case .heldUnderDistress(let streak):
            // ForgeKit 0.86 case. Treat as a streak-continued event from
            // a persistence perspective — the streak is held; the host
            // view decides whether to render an extra-warm bubble.
            storedStreak = streak
            storedFreezes = availableFreezes()
            analyticsEvent = .streakHeldUnderDistress
        @unknown default:
            // Forward-compatibility: any future StreakResult case is a
            // no-op until a deliberate handler is wired so we don't
            // corrupt the persisted state.
            return
        }
        defaults.set(storedStreak, forKey: Self.defaultsKeyStreak)
        defaults.set(storedFreezes, forKey: Self.defaultsKeyFreezes)
        defaults.set(Date.now.timeIntervalSinceReferenceDate, forKey: Self.defaultsKeyLastSession)
        if let analyticsEvent {
            DialogueQuestAnalytics.shared.track(analyticsEvent)
        }
        // Juice layer — fire a streak-milestone haptic on advance/held but
        // stay silent on `.sameDay` (already-recorded today; would feel
        // pesty) and on `.reset` (kid just lost the streak; the broken-
        // streak nudge banner carries the UX, not a celebratory buzz).
        switch result {
        case .continued(let streak), .frozenAndContinued(let streak, _), .heldUnderDistress(let streak):
            DialogueSensoryService.shared.streakAdvanced(streak)
        case .sameDay, .reset:
            break
        @unknown default:
            break
        }
    }
}
