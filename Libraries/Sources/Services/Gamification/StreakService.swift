import Foundation
import ForgeGamification

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

    private let defaults: UserDefaults
    private let config: GamificationConfig

    /// Lazily built so the first `recordPublishedTree()` call seeds
    /// from persisted state. We re-create on each call to pick up
    /// out-of-band writes (e.g., another future surface that nudges
    /// the streak). For Phase 1 the only writer is this service.
    private var manager: StreakManager?

    public init(
        defaults: UserDefaults = .standard,
        config: GamificationConfig = DialogueQuestGamification.makeConfig()
    ) {
        self.defaults = defaults
        self.config = config
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
        switch result {
        case .continued(let streak):
            storedStreak = streak
            storedFreezes = availableFreezes()
        case .frozenAndContinued(let streak, let remaining):
            storedStreak = streak
            storedFreezes = remaining
        case .reset:
            // After a reset, the recordSession call itself counts as
            // day 1 of the new streak — StreakManager's contract.
            storedStreak = 1
            storedFreezes = config.streakFreezeCount
        case .sameDay(let streak):
            storedStreak = streak
            storedFreezes = availableFreezes()
        @unknown default:
            // ForgeKit 0.86 added .heldUnderDistress; treat unknown
            // cases as a no-op until a deliberate handler is wired,
            // so we don't corrupt the persisted state.
            return
        }
        defaults.set(storedStreak, forKey: Self.defaultsKeyStreak)
        defaults.set(storedFreezes, forKey: Self.defaultsKeyFreezes)
        defaults.set(Date.now.timeIntervalSinceReferenceDate, forKey: Self.defaultsKeyLastSession)
    }
}
