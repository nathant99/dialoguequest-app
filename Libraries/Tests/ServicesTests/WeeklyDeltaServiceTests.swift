import Foundation
import Testing
@testable import Services

@Suite("WeeklyDeltaService")
@MainActor
struct WeeklyDeltaServiceTests {
    private func makeIsolatedDefaults() -> UserDefaults {
        let suite = "dq.weeklyDelta.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func makeSnapshot(
        windowStart: Date,
        windowEnd: Date,
        published: Int = 0,
        subtext: Int = 0,
        branches: Int = 0,
        badges: Int = 0,
        activeDays: Int = 0,
        sessions: Int = 0,
        highlights: [VoicePatternHighlight] = []
    ) -> WeeklySummarySnapshot {
        WeeklySummarySnapshot(
            windowStart: windowStart,
            windowEnd: windowEnd,
            publishedTreesThisWeek: published,
            subtextConfirmedThisWeek: subtext,
            branchesReflectedThisWeek: branches,
            badgesEarnedThisWeek: badges,
            activeDaysThisWeek: activeDays,
            sessionsThisWeek: sessions,
            voicePatternHighlights: highlights
        )
    }

    @Test("storage key contract — exposes canonical UserDefaults key")
    func storageKeyContract() {
        #expect(WeeklyDeltaService.storageKey == "dq.weeklySummary.previousWeek")
    }

    @Test("minimum window separation contract — 7 days")
    func minSeparationContract() {
        #expect(WeeklyDeltaService.minWindowSeparationDays == 7)
    }

    @Test("previousSnapshot — nil on first read")
    func previousSnapshotEmpty() {
        let defaults = makeIsolatedDefaults()
        let service = WeeklyDeltaService(defaults: defaults)
        #expect(service.previousSnapshot() == nil)
    }

    @Test("recordIfWindowAdvanced — first record always writes")
    func firstRecordWrites() {
        let defaults = makeIsolatedDefaults()
        let service = WeeklyDeltaService(defaults: defaults)
        let now = Date()
        let snapshot = makeSnapshot(
            windowStart: now.addingTimeInterval(-7 * 86400),
            windowEnd: now,
            published: 3,
            subtext: 5
        )
        let didWrite = service.recordIfWindowAdvanced(snapshot, now: now)
        #expect(didWrite == true)
        #expect(service.previousSnapshot() != nil)
        #expect(service.previousSnapshot()?.publishedTreesThisWeek == 3)
        #expect(service.previousSnapshot()?.subtextConfirmedThisWeek == 5)
    }

    @Test("recordIfWindowAdvanced — within 7 days does not write")
    func withinWindowNoWrite() {
        let defaults = makeIsolatedDefaults()
        let service = WeeklyDeltaService(defaults: defaults)
        let now = Date()
        let first = makeSnapshot(
            windowStart: now.addingTimeInterval(-7 * 86400),
            windowEnd: now,
            published: 1
        )
        _ = service.recordIfWindowAdvanced(first, now: now)
        // Same-day re-record — must not write
        let second = makeSnapshot(
            windowStart: now.addingTimeInterval(-7 * 86400),
            windowEnd: now,
            published: 5
        )
        let didWrite = service.recordIfWindowAdvanced(second, now: now)
        #expect(didWrite == false)
        #expect(service.previousSnapshot()?.publishedTreesThisWeek == 1)
    }

    @Test("recordIfWindowAdvanced — past 7 days writes new baseline")
    func pastWindowWrites() {
        let defaults = makeIsolatedDefaults()
        let service = WeeklyDeltaService(defaults: defaults)
        let now = Date()
        let first = makeSnapshot(
            windowStart: now.addingTimeInterval(-14 * 86400),
            windowEnd: now.addingTimeInterval(-7 * 86400),
            published: 2
        )
        _ = service.recordIfWindowAdvanced(first, now: now.addingTimeInterval(-7 * 86400))
        let second = makeSnapshot(
            windowStart: now.addingTimeInterval(-7 * 86400),
            windowEnd: now,
            published: 5
        )
        let didWrite = service.recordIfWindowAdvanced(second, now: now)
        #expect(didWrite == true)
        #expect(service.previousSnapshot()?.publishedTreesThisWeek == 5)
    }

    @Test("delta — nil when no previous snapshot")
    func deltaNilOnFreshInstall() {
        let defaults = makeIsolatedDefaults()
        let service = WeeklyDeltaService(defaults: defaults)
        let current = makeSnapshot(
            windowStart: Date().addingTimeInterval(-7 * 86400),
            windowEnd: Date()
        )
        let delta = service.delta(from: nil, current: current)
        #expect(delta == nil)
    }

    @Test("delta — nil when windows overlap")
    func deltaNilOnOverlap() {
        let defaults = makeIsolatedDefaults()
        let service = WeeklyDeltaService(defaults: defaults)
        let now = Date()
        let previous = makeSnapshot(
            windowStart: now.addingTimeInterval(-7 * 86400),
            windowEnd: now            // ends NOW
        )
        let current = makeSnapshot(
            windowStart: now.addingTimeInterval(-3 * 86400),  // starts BEFORE previous's end
            windowEnd: now.addingTimeInterval(4 * 86400)
        )
        let delta = service.delta(from: previous, current: current)
        #expect(delta == nil)
    }

    @Test("delta — positive published delta")
    func deltaPositivePublished() {
        let defaults = makeIsolatedDefaults()
        let service = WeeklyDeltaService(defaults: defaults)
        let now = Date()
        let previous = makeSnapshot(
            windowStart: now.addingTimeInterval(-14 * 86400),
            windowEnd: now.addingTimeInterval(-7 * 86400),
            published: 2,
            subtext: 4
        )
        let current = makeSnapshot(
            windowStart: now.addingTimeInterval(-7 * 86400),
            windowEnd: now,
            published: 5,
            subtext: 6
        )
        let delta = service.delta(from: previous, current: current)
        #expect(delta?.publishedTreesDelta == 3)
        #expect(delta?.subtextConfirmedDelta == 2)
    }

    @Test("delta — negative deltas surface")
    func deltaNegative() {
        let defaults = makeIsolatedDefaults()
        let service = WeeklyDeltaService(defaults: defaults)
        let now = Date()
        let previous = makeSnapshot(
            windowStart: now.addingTimeInterval(-14 * 86400),
            windowEnd: now.addingTimeInterval(-7 * 86400),
            published: 5,
            badges: 3
        )
        let current = makeSnapshot(
            windowStart: now.addingTimeInterval(-7 * 86400),
            windowEnd: now,
            published: 2,
            badges: 1
        )
        let delta = service.delta(from: previous, current: current)
        #expect(delta?.publishedTreesDelta == -3)
        #expect(delta?.badgesEarnedDelta == -2)
        #expect(delta?.totalCraftMomentDelta == -5)
    }

    @Test("delta — newlyImproving counts only fresh band entries")
    func deltaNewlyImproving() {
        let defaults = makeIsolatedDefaults()
        let service = WeeklyDeltaService(defaults: defaults)
        let now = Date()
        let charA = UUID()
        let charB = UUID()
        let charC = UUID()
        let previous = makeSnapshot(
            windowStart: now.addingTimeInterval(-14 * 86400),
            windowEnd: now.addingTimeInterval(-7 * 86400),
            highlights: [VoicePatternHighlight(characterID: charA, trend: "improving")]
        )
        let current = makeSnapshot(
            windowStart: now.addingTimeInterval(-7 * 86400),
            windowEnd: now,
            highlights: [
                VoicePatternHighlight(characterID: charA, trend: "improving"),   // still improving — not counted
                VoicePatternHighlight(characterID: charB, trend: "improving"),   // NEW — counted
                VoicePatternHighlight(characterID: charC, trend: "improving")    // NEW — counted
            ]
        )
        let delta = service.delta(from: previous, current: current)
        #expect(delta?.newlyImprovingCount == 2)
    }

    @Test("delta — newlyDrifting counts only fresh band entries")
    func deltaNewlyDrifting() {
        let defaults = makeIsolatedDefaults()
        let service = WeeklyDeltaService(defaults: defaults)
        let now = Date()
        let charA = UUID()
        let charB = UUID()
        let previous = makeSnapshot(
            windowStart: now.addingTimeInterval(-14 * 86400),
            windowEnd: now.addingTimeInterval(-7 * 86400),
            highlights: [VoicePatternHighlight(characterID: charA, trend: "drifting")]
        )
        let current = makeSnapshot(
            windowStart: now.addingTimeInterval(-7 * 86400),
            windowEnd: now,
            highlights: [
                VoicePatternHighlight(characterID: charB, trend: "drifting")
            ]
        )
        let delta = service.delta(from: previous, current: current)
        #expect(delta?.newlyDriftingCount == 1)
    }

    @Test("delta — hasAnySignedChange false on all-zero diff")
    func hasAnyChangeFalseOnZero() {
        let defaults = makeIsolatedDefaults()
        let service = WeeklyDeltaService(defaults: defaults)
        let now = Date()
        let previous = makeSnapshot(
            windowStart: now.addingTimeInterval(-14 * 86400),
            windowEnd: now.addingTimeInterval(-7 * 86400),
            published: 3
        )
        let current = makeSnapshot(
            windowStart: now.addingTimeInterval(-7 * 86400),
            windowEnd: now,
            published: 3
        )
        let delta = service.delta(from: previous, current: current)
        #expect(delta?.hasAnySignedChange == false)
    }

    @Test("delta — hasAnySignedChange true on any non-zero")
    func hasAnyChangeTrue() {
        let defaults = makeIsolatedDefaults()
        let service = WeeklyDeltaService(defaults: defaults)
        let now = Date()
        let previous = makeSnapshot(
            windowStart: now.addingTimeInterval(-14 * 86400),
            windowEnd: now.addingTimeInterval(-7 * 86400),
            sessions: 2
        )
        let current = makeSnapshot(
            windowStart: now.addingTimeInterval(-7 * 86400),
            windowEnd: now,
            sessions: 4
        )
        let delta = service.delta(from: previous, current: current)
        #expect(delta?.hasAnySignedChange == true)
        #expect(delta?.sessionsDelta == 2)
    }

    @Test("WeeklyDelta — clamps negative band counts to 0 (defensive)")
    func clampsNegativeBandCounts() {
        let delta = WeeklyDelta(
            previousWindowEnd: Date(),
            currentWindowStart: Date(),
            publishedTreesDelta: 0,
            subtextConfirmedDelta: 0,
            branchesReflectedDelta: 0,
            badgesEarnedDelta: 0,
            activeDaysDelta: 0,
            sessionsDelta: 0,
            newlyImprovingCount: -5,
            newlyDriftingCount: -3
        )
        #expect(delta.newlyImprovingCount == 0)
        #expect(delta.newlyDriftingCount == 0)
    }

    @Test("reset — clears persisted state")
    func resetClears() {
        let defaults = makeIsolatedDefaults()
        let service = WeeklyDeltaService(defaults: defaults)
        let now = Date()
        let snapshot = makeSnapshot(
            windowStart: now.addingTimeInterval(-7 * 86400),
            windowEnd: now,
            published: 7
        )
        _ = service.recordIfWindowAdvanced(snapshot, now: now)
        #expect(service.previousSnapshot() != nil)
        service.reset()
        #expect(service.previousSnapshot() == nil)
    }

    @Test("persistence round-trip preserves voice-pattern highlights")
    func persistenceRoundTripHighlights() {
        let defaults = makeIsolatedDefaults()
        let service = WeeklyDeltaService(defaults: defaults)
        let now = Date()
        let charA = UUID()
        let charB = UUID()
        let snapshot = makeSnapshot(
            windowStart: now.addingTimeInterval(-7 * 86400),
            windowEnd: now,
            highlights: [
                VoicePatternHighlight(characterID: charA, trend: "improving"),
                VoicePatternHighlight(characterID: charB, trend: "drifting")
            ]
        )
        _ = service.recordIfWindowAdvanced(snapshot, now: now)
        let restored = service.previousSnapshot()
        #expect(restored?.voicePatternHighlights.count == 2)
        let restoredTrends = Set(restored?.voicePatternHighlights.map { $0.trend } ?? [])
        #expect(restoredTrends == ["improving", "drifting"])
    }
}
