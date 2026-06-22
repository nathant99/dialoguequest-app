import Foundation

/// Tracks the "mastery moment" — the first time the kid publishes a
/// dialogue tree whose average voice-match score crosses 0.85 across
/// all per-character voice checks. That threshold means the kid has
/// internalized voice consistency well enough that Patter would
/// notice. The moment fires EXACTLY ONCE per device per
/// `MasteryMomentService.threshold` — flipping the bit in
/// `defaultsKeyFirstMasteryAt` so subsequent publishes (which can
/// also clear 0.85) don't re-fire the cinematic.
///
/// Wired via `WriteTabView.onChange(machine.stage)` on the `.published`
/// transition. The view fires `recordPublishedTree(averageVoiceMatch:)`
/// with the snapshot it already computes for `DDAEngine`; if the
/// service returns `.firstMasteryAchieved`, the host (RootView) drives
/// a `.epic`-tier celebration via the existing
/// `ForgeCelebration.CelebrationCoordinator` already on RootView.
///
/// Phase 1 surface — the host fires the cinematic. Phase 2+ may layer
/// a share-worthy certificate on top (per FEATURE_PLAN § Delight &
/// Polish — Share-worthy moments).
@MainActor
public final class MasteryMomentService {
    public static let shared = MasteryMomentService()

    /// The voice-match floor a single tree must clear for the
    /// moment to count. Set to 0.85 — matches the FEATURE_PLAN target
    /// for "kid internalizes voice consistency" + the
    /// `DDAEngine.Config.voiceMatchCeiling` upper bound.
    public static let threshold: Double = 0.85

    public static let defaultsKeyFirstMasteryAt = "dq.firstMasteryAchievedAt"

    public enum Outcome: Sendable, Equatable {
        /// First time this tree cleared the threshold AND no prior
        /// mastery moment has fired — host should celebrate.
        case firstMasteryAchieved
        /// Tree cleared the threshold but the moment already fired
        /// earlier — host can render normal acknowledgement (no
        /// cinematic).
        case alreadyAchievedEarlier
        /// Tree below threshold — host renders normal acknowledgement.
        case belowThreshold
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Returns the outcome AND, when `.firstMasteryAchieved`, persists
    /// the milestone so subsequent publishes don't re-trigger the
    /// cinematic.
    @discardableResult
    public func recordPublishedTree(averageVoiceMatch: Double) -> Outcome {
        guard averageVoiceMatch >= Self.threshold else {
            return .belowThreshold
        }
        if firstMasteryAchievedAt() != nil {
            return .alreadyAchievedEarlier
        }
        defaults.set(Date.now.timeIntervalSinceReferenceDate, forKey: Self.defaultsKeyFirstMasteryAt)
        return .firstMasteryAchieved
    }

    /// Read-only access for views that want to render a "you've earned
    /// this" surface (Phase 2+ certificate UX). `nil` until the kid
    /// has crossed the threshold.
    public func firstMasteryAchievedAt() -> Date? {
        let interval = defaults.double(forKey: Self.defaultsKeyFirstMasteryAt)
        guard interval > 0 else { return nil }
        return Date(timeIntervalSinceReferenceDate: interval)
    }

    /// Test seam — clears the persisted milestone. Production callers
    /// never invoke this; the moment is meant to fire exactly once
    /// per device.
    public func reset() {
        defaults.removeObject(forKey: Self.defaultsKeyFirstMasteryAt)
    }
}
