import Foundation
import Testing
@testable import Models
@testable import Services

/// Per-character voice-signature longitudinal store. Records every
/// published tree's `WritingEvaluator.VoiceSummary.perCharacterAverage`
/// into a rolling 5-slot window keyed by character UUID. Future
/// Patter coaching surfaces consume `recentScores(for:)` +
/// `trend(for:)` to surface "Brogue's voice has gotten steadier" style
/// callbacks across sessions.
@MainActor
@Suite("VoicePatternHistoryService")
struct VoicePatternHistoryServiceTests {

    private func makeSuite(name: String = UUID().uuidString) -> UserDefaults {
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    private func summary(scores: [UUID: Double]) -> WritingEvaluator.VoiceSummary {
        let tree = scores.values.reduce(0.0, +) / Double(max(scores.count, 1))
        return WritingEvaluator.VoiceSummary(
            perCharacterAverage: scores,
            treeAverage: scores.isEmpty ? nil : tree,
            driftingLineIDs: []
        )
    }

    // MARK: - Recording

    @Test func recordEmptySummaryDoesNotPersist() {
        let suite = makeSuite()
        let service = VoicePatternHistoryService(defaults: suite)
        service.recordPublishedTree(summary: summary(scores: [:]))
        #expect(service.allHistories().isEmpty)
    }

    @Test func recordPersistsPerCharacterScore() {
        let suite = makeSuite()
        let service = VoicePatternHistoryService(defaults: suite)
        let brogue = UUID()
        service.recordPublishedTree(summary: summary(scores: [brogue: 0.72]))
        #expect(service.recentScores(for: brogue) == [0.72])
    }

    @Test func recordIsMostRecentFirst() {
        let suite = makeSuite()
        let service = VoicePatternHistoryService(defaults: suite)
        let brogue = UUID()
        service.recordPublishedTree(summary: summary(scores: [brogue: 0.40]))
        service.recordPublishedTree(summary: summary(scores: [brogue: 0.55]))
        service.recordPublishedTree(summary: summary(scores: [brogue: 0.72]))
        #expect(service.recentScores(for: brogue) == [0.72, 0.55, 0.40])
    }

    @Test func recordTrimsToHistoryWindow() {
        let suite = makeSuite()
        let service = VoicePatternHistoryService(defaults: suite)
        let brogue = UUID()
        for value in stride(from: 0.10, through: 0.80, by: 0.10) {
            service.recordPublishedTree(summary: summary(scores: [brogue: value]))
        }
        let window = service.recentScores(for: brogue)
        #expect(window.count == VoicePatternHistoryService.historyWindow)
        // Most-recent-first; the last recorded (0.80) sits at the head;
        // anything older than the window cap (0.10, 0.20, 0.30) fell off.
        #expect(window.first == 0.80)
        #expect(window.contains(0.10) == false)
        #expect(window.contains(0.20) == false)
        #expect(window.contains(0.30) == false)
    }

    @Test func recordClampsScoresOutsideUnitInterval() {
        let suite = makeSuite()
        let service = VoicePatternHistoryService(defaults: suite)
        let glance = UUID()
        // Supplying out-of-range values directly bypasses the analyzer's
        // own clamp — the service is its own line of defense.
        service.recordPublishedTree(summary: summary(scores: [glance: 1.7]))
        service.recordPublishedTree(summary: summary(scores: [glance: -0.3]))
        let window = service.recentScores(for: glance)
        #expect(window.allSatisfy { $0 >= 0.0 && $0 <= 1.0 })
        #expect(window.first == 0.0)
        #expect(window.last == 1.0)
    }

    @Test func recordOnlyTouchesPresentCharacters() {
        let suite = makeSuite()
        let service = VoicePatternHistoryService(defaults: suite)
        let brogue = UUID()
        let glance = UUID()
        service.recordPublishedTree(summary: summary(scores: [brogue: 0.50, glance: 0.65]))
        // A tree that doesn't include glance shouldn't decay glance's history.
        service.recordPublishedTree(summary: summary(scores: [brogue: 0.62]))
        #expect(service.recentScores(for: brogue) == [0.62, 0.50])
        #expect(service.recentScores(for: glance) == [0.65])
    }

    // MARK: - Persistence

    @Test func snapshotRoundTripsAcrossInstances() {
        let suite = makeSuite()
        let serviceA = VoicePatternHistoryService(defaults: suite)
        let weigh = UUID()
        serviceA.recordPublishedTree(summary: summary(scores: [weigh: 0.55]))
        serviceA.recordPublishedTree(summary: summary(scores: [weigh: 0.70]))
        let serviceB = VoicePatternHistoryService(defaults: suite)
        #expect(serviceB.recentScores(for: weigh) == [0.70, 0.55])
    }

    @Test func resetWipesAllHistory() {
        let suite = makeSuite()
        let service = VoicePatternHistoryService(defaults: suite)
        let sprig = UUID()
        service.recordPublishedTree(summary: summary(scores: [sprig: 0.40, UUID(): 0.50]))
        service.reset()
        #expect(service.recentScores(for: sprig).isEmpty)
        #expect(service.allHistories().isEmpty)
    }

    @Test func recentScoresForUnknownCharacterReturnsEmpty() {
        let suite = makeSuite()
        let service = VoicePatternHistoryService(defaults: suite)
        #expect(service.recentScores(for: UUID()).isEmpty)
    }

    // MARK: - Trend classification

    @Test func trendInsufficientDataBelowMinimumRecords() {
        let suite = makeSuite()
        let service = VoicePatternHistoryService(defaults: suite)
        let id = UUID()
        #expect(service.trend(for: id) == .insufficientData)
        service.recordPublishedTree(summary: summary(scores: [id: 0.5]))
        #expect(service.trend(for: id) == .insufficientData)
    }

    @Test func trendImprovingWhenLatestExceedsOldestByDelta() {
        let suite = makeSuite()
        let service = VoicePatternHistoryService(defaults: suite)
        let id = UUID()
        service.recordPublishedTree(summary: summary(scores: [id: 0.40]))
        service.recordPublishedTree(summary: summary(scores: [id: 0.55]))
        // window: [0.55 (latest), 0.40 (oldest)]; delta = 0.15 > 0.08
        #expect(service.trend(for: id) == .improving)
    }

    @Test func trendDriftingWhenOldestExceedsLatestByDelta() {
        let suite = makeSuite()
        let service = VoicePatternHistoryService(defaults: suite)
        let id = UUID()
        service.recordPublishedTree(summary: summary(scores: [id: 0.80]))
        service.recordPublishedTree(summary: summary(scores: [id: 0.55]))
        // window: [0.55 (latest), 0.80 (oldest)]; delta = -0.25 < -0.08
        #expect(service.trend(for: id) == .drifting)
    }

    @Test func trendSteadyWhenDeltaWithinThreshold() {
        let suite = makeSuite()
        let service = VoicePatternHistoryService(defaults: suite)
        let id = UUID()
        service.recordPublishedTree(summary: summary(scores: [id: 0.50]))
        service.recordPublishedTree(summary: summary(scores: [id: 0.52]))
        // delta = 0.02, well below 0.08
        #expect(service.trend(for: id) == .steady)
    }

    @Test func trendUsesRollingWindowNotAllTimeHistory() {
        let suite = makeSuite()
        let service = VoicePatternHistoryService(defaults: suite)
        let id = UUID()
        // Older history that should be evicted by the rolling window
        for v in [0.10, 0.15, 0.20] {
            service.recordPublishedTree(summary: summary(scores: [id: v]))
        }
        // Recent steady run of 5 — these dominate the window
        for v in [0.50, 0.51, 0.49, 0.52, 0.48] {
            service.recordPublishedTree(summary: summary(scores: [id: v]))
        }
        // Window is the last 5; oldest visible is ~0.50, latest ~0.48 — steady
        #expect(service.trend(for: id) == .steady)
    }

    @Test func trendThresholdsMatchTrendDeltaContract() {
        // Sanity-check the documented contract: trendDelta = 0.08.
        #expect(VoicePatternHistoryService.trendDelta == 0.08)
        #expect(VoicePatternHistoryService.historyWindow == 5)
        #expect(VoicePatternHistoryService.minimumRecordsForTrend == 2)
    }

    // MARK: - Cross-character independence

    @Test func multipleCharactersTrackIndependently() {
        let suite = makeSuite()
        let service = VoicePatternHistoryService(defaults: suite)
        let brogue = UUID()
        let glance = UUID()
        service.recordPublishedTree(summary: summary(scores: [brogue: 0.30, glance: 0.80]))
        service.recordPublishedTree(summary: summary(scores: [brogue: 0.45, glance: 0.85]))
        service.recordPublishedTree(summary: summary(scores: [brogue: 0.60, glance: 0.90]))
        #expect(service.trend(for: brogue) == .improving) // 0.60 - 0.30 = +0.30
        #expect(service.trend(for: glance) == .improving) // 0.90 - 0.80 = +0.10
        let all = service.allHistories()
        #expect(all[brogue]?.count == 3)
        #expect(all[glance]?.count == 3)
    }
}
