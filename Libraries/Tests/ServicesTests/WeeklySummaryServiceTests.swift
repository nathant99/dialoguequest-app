import Foundation
import Testing
import ForgeAnalytics
import Models
@testable import Services

@MainActor
@Suite("WeeklySummaryService — 7-day delta snapshot over the analytics event stream")
struct WeeklySummaryServiceTests {

    // MARK: - Helpers

    private func makeSuite() -> UserDefaults {
        let name = UUID().uuidString
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    /// Build a fresh service with isolated UserDefaults + a fresh
    /// AnalyticsEngine. Returns the service plus the engine the test
    /// can seed events into directly.
    private func makeService() -> (service: WeeklySummaryService, engine: AnalyticsEngine, history: VoicePatternHistoryService) {
        let suite = makeSuite()
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)
        let history = VoicePatternHistoryService(defaults: suite)
        let service = WeeklySummaryService(
            analytics: analytics,
            history: history
        )
        return (service, engine, history)
    }

    /// Drain the actor's pending events so the snapshot read sees them.
    /// Mirrors the bounded-spin pattern from DialogueQuestAnalyticsTests.
    private func drain(engine: AnalyticsEngine, atLeast: Int) async {
        for _ in 0..<60 {
            let count = await engine.eventCount
            if count >= atLeast { return }
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    // MARK: - Empty state

    @Test("Fresh service with no events: all counts are 0, hasAnyActivity == false")
    func emptyEventStream() async {
        let bundle = makeService()
        let snapshot = await bundle.service.snapshot()
        #expect(snapshot.publishedTreesThisWeek == 0)
        #expect(snapshot.subtextConfirmedThisWeek == 0)
        #expect(snapshot.branchesReflectedThisWeek == 0)
        #expect(snapshot.badgesEarnedThisWeek == 0)
        #expect(snapshot.activeDaysThisWeek == 0)
        #expect(snapshot.sessionsThisWeek == 0)
        #expect(snapshot.voicePatternHighlights.isEmpty)
        #expect(snapshot.hasAnyActivity == false)
        #expect(snapshot.totalCraftMoments == 0)
    }

    // MARK: - Bucketization

    @Test("Single treePublished event in window: published count == 1")
    func singlePublishBucketsCorrectly() async {
        let bundle = makeService()
        let analytics = DialogueQuestAnalytics(engine: bundle.engine)
        analytics.track(.treePublished)
        await drain(engine: bundle.engine, atLeast: 1)

        let snapshot = await bundle.service.snapshot()
        #expect(snapshot.publishedTreesThisWeek == 1)
        #expect(snapshot.totalCraftMoments == 1)
        #expect(snapshot.hasAnyActivity == true)
    }

    @Test("Mixed event stream: each kind goes to its own bucket")
    func mixedEventStreamBucketsCorrectly() async {
        let bundle = makeService()
        let analytics = DialogueQuestAnalytics(engine: bundle.engine)
        analytics.track(.treePublished)
        analytics.track(.treePublished)
        analytics.track(.subtextConfirmed)
        analytics.track(.subtextConfirmed)
        analytics.track(.subtextConfirmed)
        analytics.track(.branchReflected)
        analytics.track(.badgeEarned)
        analytics.track(.badgeEarned)
        analytics.track(.welcomeBackShown)  // not bucketized
        await drain(engine: bundle.engine, atLeast: 9)

        let snapshot = await bundle.service.snapshot()
        #expect(snapshot.publishedTreesThisWeek == 2)
        #expect(snapshot.subtextConfirmedThisWeek == 3)
        #expect(snapshot.branchesReflectedThisWeek == 1)
        #expect(snapshot.badgesEarnedThisWeek == 2)
        #expect(snapshot.totalCraftMoments == 8)
    }

    @Test("Non-bucketized events (welcomeBackShown / castVoicingShown) do not inflate counts")
    func nonBucketizedEventsIgnored() async {
        let bundle = makeService()
        let analytics = DialogueQuestAnalytics(engine: bundle.engine)
        analytics.track(.welcomeBackShown)
        analytics.track(.castVoicingShown)
        analytics.track(.sessionTimerGentleNudge)
        await drain(engine: bundle.engine, atLeast: 3)

        let snapshot = await bundle.service.snapshot()
        #expect(snapshot.publishedTreesThisWeek == 0)
        #expect(snapshot.subtextConfirmedThisWeek == 0)
        #expect(snapshot.branchesReflectedThisWeek == 0)
        #expect(snapshot.badgesEarnedThisWeek == 0)
        // No tracked craft moments but sessions may have been started by
        // analytics' implicit auto-session — total craft moments stays 0.
        #expect(snapshot.totalCraftMoments == 0)
    }

    // MARK: - Voice-pattern highlights

    @Test("Voice-pattern highlight filters steady + insufficientData characters")
    func voicePatternHighlightsFilterFlat() async {
        let bundle = makeService()
        let improvingID = UUID()
        let driftingID = UUID()
        let steadyID = UUID()
        let insufficientID = UUID()

        // Improving: 5 scores 0.50 → 0.90, delta +0.40
        for score in [0.50, 0.60, 0.70, 0.80, 0.90] {
            let summary = WritingEvaluator.VoiceSummary(
                perCharacterAverage: [improvingID: score],
                treeAverage: score,
                driftingLineIDs: []
            )
            bundle.history.recordPublishedTree(summary: summary)
        }
        // Drifting: 5 scores 0.90 → 0.45, delta -0.45
        for score in [0.90, 0.80, 0.70, 0.60, 0.45] {
            let summary = WritingEvaluator.VoiceSummary(
                perCharacterAverage: [driftingID: score],
                treeAverage: score,
                driftingLineIDs: []
            )
            bundle.history.recordPublishedTree(summary: summary)
        }
        // Steady: all within ±0.04
        for score in [0.70, 0.72, 0.71, 0.73, 0.70] {
            let summary = WritingEvaluator.VoiceSummary(
                perCharacterAverage: [steadyID: score],
                treeAverage: score,
                driftingLineIDs: []
            )
            bundle.history.recordPublishedTree(summary: summary)
        }
        // Insufficient: 1 entry
        let summary = WritingEvaluator.VoiceSummary(
            perCharacterAverage: [insufficientID: 0.7],
            treeAverage: 0.7,
            driftingLineIDs: []
        )
        bundle.history.recordPublishedTree(summary: summary)

        let snapshot = await bundle.service.snapshot()
        let highlightedIDs = Set(snapshot.voicePatternHighlights.map(\.characterID))
        #expect(highlightedIDs == [improvingID, driftingID])
        let improvingHighlight = snapshot.voicePatternHighlights.first(where: { $0.characterID == improvingID })
        let driftingHighlight = snapshot.voicePatternHighlights.first(where: { $0.characterID == driftingID })
        #expect(improvingHighlight?.trend == "improving")
        #expect(driftingHighlight?.trend == "drifting")
    }

    @Test("Voice-pattern highlights are sorted deterministically by UUID string")
    func voicePatternHighlightsSortedByUUIDString() async {
        let bundle = makeService()
        // Construct two IDs we can predict the sort of (UUID string sort
        // is case-sensitive ASCII).
        let charA = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let charB = UUID(uuidString: "FF000000-0000-0000-0000-000000000002")!

        for id in [charB, charA] {  // record B first to verify sort, not insertion order
            for score in [0.50, 0.60, 0.70, 0.80, 0.90] {
                let summary = WritingEvaluator.VoiceSummary(
                    perCharacterAverage: [id: score],
                    treeAverage: score,
                    driftingLineIDs: []
                )
                bundle.history.recordPublishedTree(summary: summary)
            }
        }
        let snapshot = await bundle.service.snapshot()
        let ids = snapshot.voicePatternHighlights.map(\.characterID)
        // 0 < F in ASCII, so charA's UUID string sorts before charB's.
        #expect(ids.first == charA)
        #expect(ids.last == charB)
    }

    // MARK: - Snapshot derived properties

    @Test("totalCraftMoments sums the four bucketized counts")
    func totalCraftMomentsSum() {
        let snapshot = WeeklySummarySnapshot(
            windowStart: .now,
            windowEnd: .now,
            publishedTreesThisWeek: 3,
            subtextConfirmedThisWeek: 5,
            branchesReflectedThisWeek: 2,
            badgesEarnedThisWeek: 4,
            activeDaysThisWeek: 6,
            sessionsThisWeek: 12,
            voicePatternHighlights: []
        )
        #expect(snapshot.totalCraftMoments == 14)
        #expect(snapshot.hasAnyActivity == true)
    }

    @Test("hasAnyActivity true when ANY of craft / activeDays / sessions > 0")
    func hasAnyActivityFiresOnAnySignal() {
        func make(craft: Int, days: Int, sessions: Int) -> WeeklySummarySnapshot {
            WeeklySummarySnapshot(
                windowStart: .now,
                windowEnd: .now,
                publishedTreesThisWeek: craft,
                subtextConfirmedThisWeek: 0,
                branchesReflectedThisWeek: 0,
                badgesEarnedThisWeek: 0,
                activeDaysThisWeek: days,
                sessionsThisWeek: sessions,
                voicePatternHighlights: []
            )
        }
        #expect(make(craft: 1, days: 0, sessions: 0).hasAnyActivity)
        #expect(make(craft: 0, days: 1, sessions: 0).hasAnyActivity)
        #expect(make(craft: 0, days: 0, sessions: 1).hasAnyActivity)
        #expect(make(craft: 0, days: 0, sessions: 0).hasAnyActivity == false)
    }

    @Test("Negative inputs are clamped to 0 — defensive against future ForgeKit surprises")
    func clampedToZero() {
        let snapshot = WeeklySummarySnapshot(
            windowStart: .now,
            windowEnd: .now,
            publishedTreesThisWeek: 0,
            subtextConfirmedThisWeek: 0,
            branchesReflectedThisWeek: 0,
            badgesEarnedThisWeek: 0,
            activeDaysThisWeek: -3,
            sessionsThisWeek: -5,
            voicePatternHighlights: []
        )
        #expect(snapshot.activeDaysThisWeek == 0)
        #expect(snapshot.sessionsThisWeek == 0)
    }

    @Test("Window length matches the documented constant")
    func windowLengthMatchesConstant() async {
        let bundle = makeService()
        let now = Date(timeIntervalSince1970: 1_000_000_000)
        let snapshot = await bundle.service.snapshot(now: now)
        let delta = snapshot.windowEnd.timeIntervalSince(snapshot.windowStart)
        let expected = TimeInterval(WeeklySummaryService.windowDays) * 24 * 60 * 60
        // Calendar-arithmetic precision — allow a wide tolerance.
        #expect(abs(delta - expected) < 60 * 60)  // within 1 hour
    }
}
