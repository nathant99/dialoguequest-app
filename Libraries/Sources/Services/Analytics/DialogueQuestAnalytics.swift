import Foundation
import ForgeAnalytics

/// On-device privacy-safe analytics shim that wraps ForgeKit's `AnalyticsEngine`
/// (PII-filtered, retention-bounded, zero outbound) and exposes a Swift-Testing-
/// friendly synchronous `track` surface for SwiftUI view code.
///
/// All events stay on-device. No third-party SDK. No network transmission.
/// Per the technical-design Child-Safety table + the portfolio "No third-party
/// analytics SDKs" policy.
///
/// Reader-facing event properties stay categorical (mood, badge id, node count
/// bucket) — never raw text, never UUIDs, never display names. PII keys are
/// rejected at the engine layer; this shim adds a domain-level discipline so
/// the engine never sees PII in the first place.
@MainActor
public final class DialogueQuestAnalytics {
    public static let shared = DialogueQuestAnalytics()

    /// Underlying ForgeAnalytics engine. Exposed for tests + the
    /// ParentProgressDashboard reader path.
    public let engine: AnalyticsEngine

    public init(engine: AnalyticsEngine = AnalyticsEngine(config: AnalyticsConfig())) {
        self.engine = engine
    }

    /// Canonical DialogueQuest event vocabulary. Stable across releases so the
    /// parent-progress reader can mine historical events without schema churn.
    public enum Event: String, Sendable, CaseIterable {
        case treePublished = "tree_published"
        case subtextConfirmed = "subtext_confirmed"
        case subtextRejected = "subtext_rejected"
        case branchReflected = "branch_reflected"
        case badgeEarned = "badge_earned"
        case streakAdvanced = "streak_advanced"
        case streakHeldUnderDistress = "streak_held_under_distress"
        case streakBroken = "streak_broken"
        case welcomeBackShown = "welcome_back_shown"
        case sessionTimerGentleNudge = "session_timer_gentle_nudge"
        case sessionEndingSummaryShown = "session_ending_summary_shown"
        case anthologyEntryShared = "anthology_entry_shared"
        case castVoicingShown = "cast_voicing_shown"
    }

    /// Fire-and-forget tracking for SwiftUI call sites. Properties whose keys
    /// match the ForgeAnalytics PII blocklist are dropped silently at the engine
    /// layer; the categorical-only discipline here is the upstream guard.
    public func track(_ event: Event, properties: [String: String] = [:]) {
        let name = event.rawValue
        let engineRef = engine
        Task { await engineRef.track(name, properties: properties) }
    }

    @discardableResult
    public func startSession() async -> UUID {
        await engine.startSession()
    }

    @discardableResult
    public func endSession() async -> SessionSummary? {
        await engine.endSession()
    }

    public func recentSessionCount(last days: Int = 7) async -> Int {
        await engine.sessionCount(last: days)
    }

    public func activeDays(last days: Int = 30) async -> Int {
        await engine.activeDays(last: days)
    }
}
