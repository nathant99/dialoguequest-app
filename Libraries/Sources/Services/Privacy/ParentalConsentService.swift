import Foundation

/// COPPA-2026 parental consent record holder. Scaffold per
/// `@Docs/FEATURE_PLAN.md` § Phase: Onboarding & Child Safety —
/// **Parental consent service**: COPPA-compliant consent; annual
/// re-consent per FTC April-2026 amendments.
///
/// Phase 1 ships a `UserDefaults`-backed record (simpler migration
/// story; matches StreakService + AchievementService pattern). The
/// full SwiftData-backed audit trail joins in the Phase 2 handoff
/// when paired with the Apple Declared Age Range API + Family
/// Controls entitlement (the latter is GUI-bound; see
/// `Docs/HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md`).
///
/// **What this scaffolds**:
/// - Records the consent timestamp on grant
/// - Returns `isExpired` after 12 months per FTC 2026
/// - Supports explicit revocation (parent-driven)
/// - Persists `dq.parentalConsentGrantedAt` so `SettingsView` can
///   surface the status
///
/// **What this does NOT scaffold** (requires GUI handoffs):
/// - Family Controls entitlement / `AuthorizationCenter`
///   integration — needs `*.entitlements` (forbidden glob)
/// - `NSChildUseDescription` Info.plist key — forbidden glob
/// - Apple Declared Age Range API actual binding — entitlement-gated
@MainActor
public final class ParentalConsentService {
    public static let shared = ParentalConsentService()

    static let defaultsKeyGrantedAt = "dq.parentalConsentGrantedAt"

    /// FTC 2026 annual re-consent window. Codified here so any future
    /// jurisdiction-specific tweak (e.g., shorter window for Utah)
    /// lands in one place.
    public static let consentValidity: TimeInterval = 60 * 60 * 24 * 365

    private let defaults: UserDefaults
    private let clock: () -> Date

    public init(
        defaults: UserDefaults = .standard,
        clock: @escaping () -> Date = { Date.now }
    ) {
        self.defaults = defaults
        self.clock = clock
    }

    public var grantedAt: Date? {
        // Use object(forKey:) presence rather than a > 0 check — the
        // canonical reference-date timestamp can be negative for
        // pre-2001 instants, and tests inject `Date(timeIntervalSince1970: 0)`
        // (= reference interval ~ -978307200) to anchor the expiry math.
        guard let raw = defaults.object(forKey: Self.defaultsKeyGrantedAt) as? Double else {
            return nil
        }
        return Date(timeIntervalSinceReferenceDate: raw)
    }

    /// Returns true when a non-expired consent record exists.
    public var hasValidConsent: Bool {
        guard let grantedAt else { return false }
        return clock().timeIntervalSince(grantedAt) < Self.consentValidity
    }

    public var isExpired: Bool {
        guard let grantedAt else { return false }
        return clock().timeIntervalSince(grantedAt) >= Self.consentValidity
    }

    /// Days remaining before annual re-consent is required. Returns nil
    /// when no consent is on file. Returns 0 once expired (negative
    /// values are clamped so the UI never shows "-3 days").
    public var daysUntilReconsent: Int? {
        guard let grantedAt else { return nil }
        let elapsed = clock().timeIntervalSince(grantedAt)
        let remaining = Self.consentValidity - elapsed
        if remaining <= 0 { return 0 }
        return Int(remaining / 86_400)
    }

    public func grant() {
        defaults.set(clock().timeIntervalSinceReferenceDate, forKey: Self.defaultsKeyGrantedAt)
    }

    public func revoke() {
        defaults.removeObject(forKey: Self.defaultsKeyGrantedAt)
    }
}
