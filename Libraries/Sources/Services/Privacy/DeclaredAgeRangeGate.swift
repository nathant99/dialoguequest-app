import Foundation

/// Swift-side scaffold for Apple's Declared Age Range API (iOS 26.2+) per
/// `Docs/HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md` + `.claude/rules/age-assurance.md`.
///
/// **Safety**: per `.claude/rules/age-assurance.md` § "Declared Age Range
/// API (iOS 26.2+)", **reading "Under 13" creates COPPA actual knowledge**.
/// Once the system delivers that result, all consent flows + record-keeping
/// requirements immediately apply. This scaffold is deliberately READ-ONLY
/// against the entitlement state — it does NOT invoke the Family Controls
/// API. The actual request flow lands in a follow-up PR once:
///   1. The Family Controls entitlement is wired (Xcode GUI; see handoff)
///   2. The `NSChildUseDescription` Info.plist key is wired (Xcode GUI)
///   3. The parental-consent flow surfaces an opt-in for the band lookup
///
/// **Entitlement probe**: per `.claude/rules/warnings.md` § "Privacy-Gated
/// Frameworks", we gate on `Bundle.main.object(forInfoDictionaryKey:)` so
/// the call is a NO-OP when the GUI work hasn't landed. The Info.plist key
/// is the canonical signal — without it, even loading FamilyControls + the
/// entitlement would crash on first invocation.
///
/// **What this scaffold provides**:
/// - `Status` enum surfacing reader-friendly states
/// - `isWired` static probe — safe to call without entitlement
/// - `status` computed property that stays `.notWired` until GUI work lands
/// - `statusDescription` reader-facing string for Settings row
///
/// **What this scaffold does NOT provide** (intentional):
/// - `requestAgeBand()` — deferred until parental-consent opt-in surface lands
/// - Family Sharing integration — gated on `*.entitlements` (forbidden glob)
/// - SwiftData audit-trail record — added with the request flow
@MainActor
public final class DeclaredAgeRangeGate {
    public static let shared = DeclaredAgeRangeGate()

    /// Reader-facing age-band states. Mirrors Apple's documented bands
    /// (Under 13 / 13–15 / 16–17 / 18+) plus two scaffold-specific cases
    /// (`.notWired` for missing entitlement + `.notRequested` for wired-
    /// but-not-yet-asked).
    public enum Status: Sendable, Equatable {
        /// Entitlement / `NSChildUseDescription` not present. Default
        /// state for the scaffold today.
        case notWired
        /// Wired, but the kid's parent hasn't opted into a band lookup
        /// yet. Stays here until a future PR wires `requestAgeBand()`.
        case notRequested
        /// Asked Apple, no result yet (downloading / declined).
        case unknown
        case under13
        case teen
        case olderTeen
        case adult
    }

    /// Per `.claude/rules/warnings.md` § "Privacy-Gated Frameworks": cache
    /// the entitlement probe at static-let init so subsequent reads are
    /// O(1) and never re-enter the Bundle dictionary. The key checked is
    /// `NSChildUseDescription` (per the handoff doc) which is added in
    /// the same Xcode GUI step as the Family Controls entitlement, so
    /// the presence of either signals both are wired.
    public static let isWired: Bool = {
        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: "NSChildUseDescription") as? String,
            !raw.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            return false
        }
        return true
    }()

    private init() {}

    /// Current age-band status. Stays at `.notWired` until the GUI handoff
    /// completes; stays at `.notRequested` once wired but before a future
    /// PR adds the opt-in request surface.
    public var status: Status {
        if !Self.isWired { return .notWired }
        return .notRequested
    }

    /// Reader-friendly description for Settings + parent dashboards.
    public var statusDescription: String {
        switch status {
        case .notWired:
            return "Family Age Band: not yet enabled. A parent or guardian needs to enable Family Controls + grant DialogueQuest access via iOS Settings before this can show."
        case .notRequested:
            return "Family Age Band: ready. A future update will let you opt in to share the band so DialogueQuest can tailor the parental-consent flow."
        case .unknown:
            return "Family Age Band: unknown — Apple's system hasn't returned a band yet."
        case .under13:
            return "Family Age Band: under 13."
        case .teen:
            return "Family Age Band: teen (13–15)."
        case .olderTeen:
            return "Family Age Band: older teen (16–17)."
        case .adult:
            return "Family Age Band: adult (18+)."
        }
    }

    /// Convenience flag for any future flow that should hide kid-specific
    /// UI from an adult device. Today returns `false` (stays NO-OP) until
    /// the actual request flow surfaces a real result.
    public var hasUnder13Signal: Bool {
        if case .under13 = status { return true }
        return false
    }
}
