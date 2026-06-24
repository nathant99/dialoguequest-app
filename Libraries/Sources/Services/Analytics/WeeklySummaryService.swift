import Foundation
import ForgeAnalytics
import Models

/// Computes a 7-day "this week's deltas" snapshot for the parent
/// progress dashboard. Aggregates the existing on-device analytics
/// event stream (`DialogueQuestAnalytics`) plus the per-character
/// voice-pattern trend store (`VoicePatternHistoryService`) into a
/// single value-type snapshot consumers can render directly.
///
/// Closes the FEATURE_PLAN row "Weekly summary (opt-in storage) —
/// actual summary rendering lands in a later round once a meaningful
/// 'this week's deltas' report can be computed."
///
/// **Read shape**: `snapshot(now:)` returns a `WeeklySummarySnapshot`
/// covering the last 7 days. Bucketizes the categorical event vocabulary
/// from `DialogueQuestAnalytics.Event` into 4 craft buckets
/// (published trees / subtext confirmations / branch reflections /
/// badges earned). Layers ForgeAnalytics `sessionCount(last:)` +
/// `activeDays(last:)` for engagement signal. Surfaces non-flat
/// `VoicePatternHistoryService.Trend` per character as highlights.
///
/// **No PII / no outbound**: every input is already an on-device,
/// categorical-only signal. The snapshot exposes counts + a sorted
/// list of character-UUID-keyed trend tokens — never display names,
/// never raw event payloads. Per the technical-design Child-Safety
/// table + the portfolio "No third-party analytics SDKs" policy.
///
/// **Gate**: the parent dashboard consumes this surface only when
/// `dq.weeklySummaryOptIn` is on. Service computation is cheap and
/// safe to call regardless — the gate lives at the view layer.
@MainActor
public final class WeeklySummaryService {
    public static let shared = WeeklySummaryService()

    /// 7-day window — load-bearing constant. Surfaced for tests + future
    /// parent-progress UI rendering ("this week" copy hinges on this).
    public nonisolated static let windowDays: Int = 7

    private let analytics: DialogueQuestAnalytics
    private let history: VoicePatternHistoryService
    private let deltaService: WeeklyDeltaService
    private let calendar: Calendar

    public init(
        analytics: DialogueQuestAnalytics = .shared,
        history: VoicePatternHistoryService = .shared,
        deltaService: WeeklyDeltaService = .shared,
        calendar: Calendar = .current
    ) {
        self.analytics = analytics
        self.history = history
        self.deltaService = deltaService
        self.calendar = calendar
    }

    /// Compute the weekly-delta snapshot. `now` injectable for tests.
    /// Async because the underlying `ForgeAnalytics.AnalyticsEngine` is
    /// an actor — the SwiftUI consumer awaits this in `.task`.
    public func snapshot(now: Date = .now) async -> WeeklySummarySnapshot {
        let windowStart = calendar.date(byAdding: .day, value: -Self.windowDays, to: now) ?? now
        let events = await analytics.engine.events(since: windowStart)

        var publishedTrees = 0
        var subtextConfirmed = 0
        var branchesReflected = 0
        var badgesEarned = 0
        for event in events {
            switch event.name {
            case DialogueQuestAnalytics.Event.treePublished.rawValue:
                publishedTrees += 1
            case DialogueQuestAnalytics.Event.subtextConfirmed.rawValue:
                subtextConfirmed += 1
            case DialogueQuestAnalytics.Event.branchReflected.rawValue:
                branchesReflected += 1
            case DialogueQuestAnalytics.Event.badgeEarned.rawValue:
                badgesEarned += 1
            default:
                break
            }
        }

        let activeDays = await analytics.activeDays(last: Self.windowDays)
        let sessions = await analytics.recentSessionCount(last: Self.windowDays)
        let highlights = voicePatternHighlights()

        return WeeklySummarySnapshot(
            windowStart: windowStart,
            windowEnd: now,
            publishedTreesThisWeek: publishedTrees,
            subtextConfirmedThisWeek: subtextConfirmed,
            branchesReflectedThisWeek: branchesReflected,
            badgesEarnedThisWeek: badgesEarned,
            activeDaysThisWeek: activeDays,
            sessionsThisWeek: sessions,
            voicePatternHighlights: highlights
        )
    }

    /// Compute the snapshot AND the signed delta versus the previously
    /// persisted week. Persists the new snapshot as the baseline when
    /// the window has advanced beyond `WeeklyDeltaService.minWindowSeparationDays`.
    /// Caller-friendly tuple keeps `snapshot(now:)` callers unaffected.
    public func snapshotWithDelta(now: Date = .now) async -> (snapshot: WeeklySummarySnapshot, delta: WeeklyDelta?) {
        let current = await snapshot(now: now)
        let previous = deltaService.previousSnapshot()
        let delta = deltaService.delta(from: previous, current: current)
        deltaService.recordIfWindowAdvanced(current, now: now)
        return (current, delta)
    }

    /// Surface only characters whose rolling-window trend is
    /// `.improving` or `.drifting`. Steady + insufficientData are
    /// suppressed because they're not parent-actionable signals.
    /// Sorted by characterID UUID string for deterministic ordering
    /// (no display-name leak to the parent surface).
    private func voicePatternHighlights() -> [VoicePatternHighlight] {
        var highlights: [VoicePatternHighlight] = []
        for (characterID, _) in history.allHistories() {
            let trend = history.trend(for: characterID)
            switch trend {
            case .improving, .drifting:
                highlights.append(VoicePatternHighlight(characterID: characterID, trend: trend.rawValue))
            case .steady, .insufficientData:
                continue
            }
        }
        return highlights.sorted(by: { $0.characterID.uuidString < $1.characterID.uuidString })
    }
}

/// Value-type snapshot of the last 7 days. Sendable + Equatable so
/// SwiftUI `@State` consumers can diff cheaply. Reader-facing copy
/// for "this week" framing lives at the view layer — this struct
/// holds the counts, not the prose.
public nonisolated struct WeeklySummarySnapshot: Sendable, Equatable {
    /// Calendar-day start of the 7-day window.
    public let windowStart: Date
    /// `.now` at the snapshot moment — the window's close edge.
    public let windowEnd: Date
    /// Count of `treePublished` events in the window.
    public let publishedTreesThisWeek: Int
    /// Count of `subtextConfirmed` events in the window.
    public let subtextConfirmedThisWeek: Int
    /// Count of `branchReflected` events in the window.
    public let branchesReflectedThisWeek: Int
    /// Count of `badgeEarned` events in the window.
    public let badgesEarnedThisWeek: Int
    /// 0...7 — number of distinct calendar days in the window where
    /// the app was opened (from ForgeAnalytics `activeDays`).
    public let activeDaysThisWeek: Int
    /// Count of analytics sessions (start + end pairs) in the window.
    public let sessionsThisWeek: Int
    /// Per-character voice-pattern highlights worth surfacing —
    /// `.improving` is celebratory; `.drifting` is gentle.
    /// `.steady` / `.insufficientData` filtered out.
    public let voicePatternHighlights: [VoicePatternHighlight]

    public init(
        windowStart: Date,
        windowEnd: Date,
        publishedTreesThisWeek: Int,
        subtextConfirmedThisWeek: Int,
        branchesReflectedThisWeek: Int,
        badgesEarnedThisWeek: Int,
        activeDaysThisWeek: Int,
        sessionsThisWeek: Int,
        voicePatternHighlights: [VoicePatternHighlight]
    ) {
        self.windowStart = windowStart
        self.windowEnd = windowEnd
        self.publishedTreesThisWeek = publishedTreesThisWeek
        self.subtextConfirmedThisWeek = subtextConfirmedThisWeek
        self.branchesReflectedThisWeek = branchesReflectedThisWeek
        self.badgesEarnedThisWeek = badgesEarnedThisWeek
        self.activeDaysThisWeek = max(0, activeDaysThisWeek)
        self.sessionsThisWeek = max(0, sessionsThisWeek)
        self.voicePatternHighlights = voicePatternHighlights
    }

    /// Sum of the 4 craft-moment counts — the "things the kid did this
    /// week worth noticing" headline number.
    public var totalCraftMoments: Int {
        publishedTreesThisWeek + subtextConfirmedThisWeek + branchesReflectedThisWeek + badgesEarnedThisWeek
    }

    /// True when the kid touched the app at all this week. Drives the
    /// empty-state vs filled-state branching at the view layer.
    public var hasAnyActivity: Bool {
        totalCraftMoments > 0 || activeDaysThisWeek > 0 || sessionsThisWeek > 0
    }
}

/// A per-character voice-pattern highlight for the weekly summary
/// card. `trend` is the `VoicePatternHistoryService.Trend.rawValue`
/// (`"improving"` / `"drifting"`) — string-typed so this struct
/// stays free of a back-reference into the history service.
public nonisolated struct VoicePatternHighlight: Sendable, Equatable, Hashable {
    public let characterID: UUID
    public let trend: String

    public init(characterID: UUID, trend: String) {
        self.characterID = characterID
        self.trend = trend
    }
}
