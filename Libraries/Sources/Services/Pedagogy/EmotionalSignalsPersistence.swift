import Foundation
import ForgeEmotionAware

/// UserDefaults-backed persistence shim for the most recent
/// `DialogueEmotionalStateProbe.Signals` snapshot captured during a
/// writing session. Bridges the per-session `PatterReactionService`
/// state (which is rebuilt each time `WriteTabView` mounts) to the
/// `ParentProgressDashboardView` reader, which renders outside any
/// active session.
///
/// **Why a separate persistence enum (not a property on the service)**:
/// `PatterReactionService` is a per-`WriteTabView` `@Observable`
/// instance — its lifetime is the writing surface, not the app. The
/// parent-progress dashboard lives under the Profile tab and is
/// rendered without a live reaction service in scope. Routing the
/// snapshot through UserDefaults is the smallest seam that lets both
/// surfaces share the same signal set without forcing a portfolio-level
/// `EmotionalStateStore` singleton.
///
/// **What it does NOT do**:
/// - It does NOT persist trajectory state. The `Signals.priorState`
///   field is intentionally re-seeded to `nil` on every read — the
///   parent dashboard surfaces the kid's current emotional read, not
///   the trajectory shape.
/// - It does NOT decorate the snapshot with a timestamp readable by
///   callers today. A future round can layer `lastSnapshotAt` if the
///   dashboard needs "stale snapshot" framing; for now the snapshot is
///   timeless from the reader's perspective.
/// - It does NOT throw. UserDefaults writes are infallible; reads
///   return `nil` cleanly when the keys are missing.
///
/// **Reader pattern**: `ParentProgressDashboardView` calls
/// `EmotionalSignalsPersistence.latest()` in `.task`. The view
/// `@ViewBuilder`-guards on the optional and omits the section when
/// nothing has been captured yet (fresh-install path).
public nonisolated enum EmotionalSignalsPersistence {

    /// UserDefaults keys. Stable across releases.
    public enum Key {
        public static let voiceDriftCount = "dq.lastSession.voiceDriftCount"
        public static let tagImbalanceCount = "dq.lastSession.tagImbalanceCount"
        public static let branchReflectionRatio = "dq.lastSession.branchReflectionRatio"
        public static let minutesSinceLastPublish = "dq.lastSession.minutesSinceLastPublish"
        public static let hasSnapshot = "dq.lastSession.hasSnapshot"
    }

    /// Capture a signal snapshot. Called by `PatterReactionService`
    /// after every signal-mutation hook (`recordTreeOutcome` /
    /// `onTreeChanged` / `onVoiceDrift`). Discards the optional
    /// `minutesSinceLastPublish` when nil (so the reader can
    /// distinguish "no publish this session" from "publish was 0 min
    /// ago"). UserDefaults writes never throw; the call is fire-and-
    /// forget.
    public static func record(
        signals: DialogueEmotionalStateProbe.Signals,
        defaults: UserDefaults = .standard
    ) {
        defaults.set(signals.voiceDriftCount, forKey: Key.voiceDriftCount)
        defaults.set(signals.tagImbalanceCount, forKey: Key.tagImbalanceCount)
        defaults.set(signals.branchReflectionRatio, forKey: Key.branchReflectionRatio)
        if let minutes = signals.minutesSinceLastPublish {
            defaults.set(minutes, forKey: Key.minutesSinceLastPublish)
        } else {
            defaults.removeObject(forKey: Key.minutesSinceLastPublish)
        }
        defaults.set(true, forKey: Key.hasSnapshot)
    }

    /// Read back the most recent snapshot. Returns `nil` when no
    /// snapshot has ever been captured (fresh install path).
    public static func latest(
        defaults: UserDefaults = .standard
    ) -> DialogueEmotionalStateProbe.Signals? {
        guard defaults.bool(forKey: Key.hasSnapshot) else { return nil }
        let voiceDrift = defaults.integer(forKey: Key.voiceDriftCount)
        let tagImbalance = defaults.integer(forKey: Key.tagImbalanceCount)
        let branchRatio = defaults.object(forKey: Key.branchReflectionRatio) as? Double ?? 1.0
        let minutes = defaults.object(forKey: Key.minutesSinceLastPublish) as? Double
        return DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: voiceDrift,
            tagImbalanceCount: tagImbalance,
            branchReflectionRatio: branchRatio,
            minutesSinceLastPublish: minutes
        )
    }

    /// Clear the persisted snapshot. Test seam + future "reset
    /// privacy" hook on the Settings surface.
    public static func reset(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: Key.voiceDriftCount)
        defaults.removeObject(forKey: Key.tagImbalanceCount)
        defaults.removeObject(forKey: Key.branchReflectionRatio)
        defaults.removeObject(forKey: Key.minutesSinceLastPublish)
        defaults.removeObject(forKey: Key.hasSnapshot)
    }
}
