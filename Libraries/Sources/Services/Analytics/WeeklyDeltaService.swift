import Foundation

/// Persists the previous-week summary snapshot so the parent dashboard
/// can render "what changed since last week" deltas, not just absolute
/// counts. Closes Priority F from `Docs/SESSION_HANDOFF_2026-06-27_ROUND_CLOSE.md`.
///
/// **Persistence shape**: a single UserDefaults key
/// (`dq.weeklySummary.previousWeek`) carries the most-recent recorded
/// snapshot as a Codable mirror struct (`PersistedWeeklySnapshot`).
/// No PII / no outbound — same posture as `RetentionMetricsService` +
/// `WeeklySummaryService`.
///
/// **Recording rule**: `recordIfWindowAdvanced(_:now:)` writes the
/// current snapshot when ≥ 7 calendar days have passed since the last
/// recorded snapshot's `windowEnd`. This gives a stable Monday-style
/// rollover without needing a calendar-day cron — the next dashboard
/// open after a 7+-day gap captures the new baseline. First record
/// always writes.
///
/// **Read shape**: `delta(from:current:)` is a pure value-type
/// computation. Returns nil when the previous snapshot is absent
/// (fresh install) OR the previous window's `windowEnd` is too close
/// to the current `windowStart` (overlapping windows — would surface
/// a misleading delta). Otherwise returns a `WeeklyDelta` with
/// per-bucket signed integer deltas + voice-pattern transition counts.
@MainActor
public final class WeeklyDeltaService {
    public static let shared = WeeklyDeltaService()

    /// Storage key — load-bearing constant for tests + future
    /// hub-level audit of UserDefaults footprint.
    public nonisolated static let storageKey: String = "dq.weeklySummary.previousWeek"

    /// Minimum days between the previous snapshot's `windowEnd` and
    /// the current snapshot's `windowStart` before a delta is
    /// considered safe to surface. 7 matches the canonical window.
    public nonisolated static let minWindowSeparationDays: Int = 7

    private let defaults: UserDefaults
    private let calendar: Calendar

    public init(
        defaults: UserDefaults = .standard,
        calendar: Calendar = .current
    ) {
        self.defaults = defaults
        self.calendar = calendar
    }

    /// Read the persisted previous-week snapshot if one exists.
    public func previousSnapshot() -> WeeklySummarySnapshot? {
        guard let data = defaults.data(forKey: Self.storageKey) else { return nil }
        do {
            return try JSONDecoder().decode(PersistedWeeklySnapshot.self, from: data).toSnapshot()
        } catch {
            DialogueQuestDebugLog.data("WeeklyDeltaService.previousSnapshot — decode failed; treating as fresh install", error: error)
            return nil
        }
    }

    /// Write the snapshot as the new "previous-week" baseline if the
    /// window has advanced beyond the last recorded snapshot's
    /// `windowEnd` by at least `minWindowSeparationDays`. First record
    /// always writes. Returns true if a write occurred.
    @discardableResult
    public func recordIfWindowAdvanced(_ snapshot: WeeklySummarySnapshot, now: Date = .now) -> Bool {
        if let existing = previousSnapshot() {
            let daysSinceLast = calendar.dateComponents([.day], from: existing.windowEnd, to: snapshot.windowEnd).day ?? 0
            if daysSinceLast < Self.minWindowSeparationDays {
                return false
            }
        }
        let persisted = PersistedWeeklySnapshot(from: snapshot)
        let data: Data
        do {
            data = try JSONEncoder().encode(persisted)
        } catch {
            DialogueQuestDebugLog.data("WeeklyDeltaService.recordIfWindowAdvanced — encode failed; baseline not persisted this week", error: error)
            return false
        }
        defaults.set(data, forKey: Self.storageKey)
        return true
    }

    /// Reset persisted state — exposed for tests + a future "reset
    /// progress" parental action. Production paths don't call this.
    public func reset() {
        defaults.removeObject(forKey: Self.storageKey)
    }

    /// Compute the signed delta from a previous snapshot to a current
    /// one. Pure value-type; trivially testable. Returns nil when the
    /// windows overlap (avoid surfacing a half-week comparison) OR the
    /// previous snapshot's window-edge is missing.
    public nonisolated func delta(
        from previous: WeeklySummarySnapshot?,
        current: WeeklySummarySnapshot
    ) -> WeeklyDelta? {
        guard let previous else { return nil }
        // Windows must be at least minWindowSeparationDays apart at
        // their edges — otherwise the delta is comparing overlapping
        // periods which would understate change.
        let gap = calendar.dateComponents([.day], from: previous.windowEnd, to: current.windowStart).day ?? -999
        guard gap >= 0 else { return nil }

        let prevImprovingIDs = Set(previous.voicePatternHighlights.filter { $0.trend == "improving" }.map { $0.characterID })
        let prevDriftingIDs = Set(previous.voicePatternHighlights.filter { $0.trend == "drifting" }.map { $0.characterID })
        let currImprovingIDs = Set(current.voicePatternHighlights.filter { $0.trend == "improving" }.map { $0.characterID })
        let currDriftingIDs = Set(current.voicePatternHighlights.filter { $0.trend == "drifting" }.map { $0.characterID })

        // "Newly improving" — character is improving this week and
        // wasn't in the improving set last week. "Newly drifting" —
        // same for drifting. These are the parent-actionable counts.
        let newlyImprovingCount = currImprovingIDs.subtracting(prevImprovingIDs).count
        let newlyDriftingCount = currDriftingIDs.subtracting(prevDriftingIDs).count

        return WeeklyDelta(
            previousWindowEnd: previous.windowEnd,
            currentWindowStart: current.windowStart,
            publishedTreesDelta: current.publishedTreesThisWeek - previous.publishedTreesThisWeek,
            subtextConfirmedDelta: current.subtextConfirmedThisWeek - previous.subtextConfirmedThisWeek,
            branchesReflectedDelta: current.branchesReflectedThisWeek - previous.branchesReflectedThisWeek,
            badgesEarnedDelta: current.badgesEarnedThisWeek - previous.badgesEarnedThisWeek,
            activeDaysDelta: current.activeDaysThisWeek - previous.activeDaysThisWeek,
            sessionsDelta: current.sessionsThisWeek - previous.sessionsThisWeek,
            newlyImprovingCount: newlyImprovingCount,
            newlyDriftingCount: newlyDriftingCount
        )
    }
}

/// Signed per-bucket delta between the current weekly snapshot and the
/// previous one. Positive = more activity this week; negative = less.
/// `newlyImprovingCount` + `newlyDriftingCount` track character-level
/// voice-pattern transitions across week boundaries — counts characters
/// that newly entered the improving / drifting band this week.
///
/// Reader-facing copy ("1 more conversation than last week") lives at
/// the view layer — this struct holds the signed counts, not the prose.
public nonisolated struct WeeklyDelta: Sendable, Equatable {
    /// `windowEnd` of the previous week's snapshot.
    public let previousWindowEnd: Date
    /// `windowStart` of the current week's snapshot.
    public let currentWindowStart: Date
    public let publishedTreesDelta: Int
    public let subtextConfirmedDelta: Int
    public let branchesReflectedDelta: Int
    public let badgesEarnedDelta: Int
    public let activeDaysDelta: Int
    public let sessionsDelta: Int
    /// Count of characters that are improving this week but were not
    /// improving last week. Parent-actionable "look at what just
    /// turned a corner" signal.
    public let newlyImprovingCount: Int
    /// Count of characters that are drifting this week but were not
    /// drifting last week. Parent-actionable "look at what's slipping"
    /// signal.
    public let newlyDriftingCount: Int

    public init(
        previousWindowEnd: Date,
        currentWindowStart: Date,
        publishedTreesDelta: Int,
        subtextConfirmedDelta: Int,
        branchesReflectedDelta: Int,
        badgesEarnedDelta: Int,
        activeDaysDelta: Int,
        sessionsDelta: Int,
        newlyImprovingCount: Int,
        newlyDriftingCount: Int
    ) {
        self.previousWindowEnd = previousWindowEnd
        self.currentWindowStart = currentWindowStart
        self.publishedTreesDelta = publishedTreesDelta
        self.subtextConfirmedDelta = subtextConfirmedDelta
        self.branchesReflectedDelta = branchesReflectedDelta
        self.badgesEarnedDelta = badgesEarnedDelta
        self.activeDaysDelta = activeDaysDelta
        self.sessionsDelta = sessionsDelta
        self.newlyImprovingCount = max(0, newlyImprovingCount)
        self.newlyDriftingCount = max(0, newlyDriftingCount)
    }

    /// True when at least one craft-bucket delta is non-zero OR a
    /// character changed bands. Drives the view-layer empty-state
    /// branching ("no change this week").
    public var hasAnySignedChange: Bool {
        publishedTreesDelta != 0
            || subtextConfirmedDelta != 0
            || branchesReflectedDelta != 0
            || badgesEarnedDelta != 0
            || activeDaysDelta != 0
            || sessionsDelta != 0
            || newlyImprovingCount > 0
            || newlyDriftingCount > 0
    }

    /// Sum of the 4 craft-moment signed deltas — useful for an
    /// at-a-glance "more or less craft activity this week" headline.
    public var totalCraftMomentDelta: Int {
        publishedTreesDelta + subtextConfirmedDelta + branchesReflectedDelta + badgesEarnedDelta
    }
}

/// Codable mirror of `WeeklySummarySnapshot` used for UserDefaults
/// persistence. Keeping the persistence shape separate from the
/// public snapshot type avoids the InferIsolatedConformances trap —
/// `WeeklySummarySnapshot` stays `Sendable` + `Equatable`, persistence
/// lives here as a `nonisolated` Codable struct.
nonisolated struct PersistedWeeklySnapshot: Codable, Sendable {
    let windowStart: Date
    let windowEnd: Date
    let publishedTreesThisWeek: Int
    let subtextConfirmedThisWeek: Int
    let branchesReflectedThisWeek: Int
    let badgesEarnedThisWeek: Int
    let activeDaysThisWeek: Int
    let sessionsThisWeek: Int
    let voicePatternHighlights: [PersistedVoicePatternHighlight]

    init(from snapshot: WeeklySummarySnapshot) {
        self.windowStart = snapshot.windowStart
        self.windowEnd = snapshot.windowEnd
        self.publishedTreesThisWeek = snapshot.publishedTreesThisWeek
        self.subtextConfirmedThisWeek = snapshot.subtextConfirmedThisWeek
        self.branchesReflectedThisWeek = snapshot.branchesReflectedThisWeek
        self.badgesEarnedThisWeek = snapshot.badgesEarnedThisWeek
        self.activeDaysThisWeek = snapshot.activeDaysThisWeek
        self.sessionsThisWeek = snapshot.sessionsThisWeek
        self.voicePatternHighlights = snapshot.voicePatternHighlights.map { PersistedVoicePatternHighlight(from: $0) }
    }

    func toSnapshot() -> WeeklySummarySnapshot {
        WeeklySummarySnapshot(
            windowStart: windowStart,
            windowEnd: windowEnd,
            publishedTreesThisWeek: publishedTreesThisWeek,
            subtextConfirmedThisWeek: subtextConfirmedThisWeek,
            branchesReflectedThisWeek: branchesReflectedThisWeek,
            badgesEarnedThisWeek: badgesEarnedThisWeek,
            activeDaysThisWeek: activeDaysThisWeek,
            sessionsThisWeek: sessionsThisWeek,
            voicePatternHighlights: voicePatternHighlights.map { $0.toHighlight() }
        )
    }
}

nonisolated struct PersistedVoicePatternHighlight: Codable, Sendable {
    let characterID: UUID
    let trend: String

    init(from highlight: VoicePatternHighlight) {
        self.characterID = highlight.characterID
        self.trend = highlight.trend
    }

    func toHighlight() -> VoicePatternHighlight {
        VoicePatternHighlight(characterID: characterID, trend: trend)
    }
}
