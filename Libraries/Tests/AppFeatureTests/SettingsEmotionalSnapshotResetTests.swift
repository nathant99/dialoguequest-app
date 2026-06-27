import Testing
import Foundation
import ForgeAnalytics
import ForgeEmotionAware
import Services
@testable import AppFeature

/// Priority R (2026-07-06) — `SettingsView.performEmotionalSnapshotReset`
/// is the post-`ParentalGateChallenge` handler that clears every
/// `EmotionalSignalsPersistence.Key` AND emits the
/// `emotionalSnapshotReset` analytics event. These tests assert the
/// two-side-effect contract on an injected per-test UserDefaults +
/// AnalyticsEngine so the dashboard reader sees a cleanly-cleared
/// surface and the on-device retention pipeline observes the action.
@MainActor
@Suite("Settings emotional snapshot reset")
struct SettingsEmotionalSnapshotResetTests {

    private func makeDefaults() -> UserDefaults {
        let name = "dq.test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private func sampleSignals() -> DialogueEmotionalStateProbe.Signals {
        DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 2,
            tagImbalanceCount: 1,
            branchReflectionRatio: 0.45,
            minutesSinceLastPublish: 12
        )
    }

    @Test func resetClearsPersistedSnapshot() {
        let defaults = makeDefaults()
        EmotionalSignalsPersistence.record(signals: sampleSignals(), defaults: defaults)
        #expect(EmotionalSignalsPersistence.latest(defaults: defaults) != nil)

        let view = SettingsView()
        view.performEmotionalSnapshotReset(
            defaults: defaults,
            analytics: DialogueQuestAnalytics(engine: AnalyticsEngine(config: AnalyticsConfig()))
        )

        #expect(EmotionalSignalsPersistence.latest(defaults: defaults) == nil)
        #expect(EmotionalSignalsPersistence.latestTimestamp(defaults: defaults) == nil)
    }

    @Test func resetEmitsAnalyticsEvent() async {
        let defaults = makeDefaults()
        EmotionalSignalsPersistence.record(signals: sampleSignals(), defaults: defaults)
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)

        let view = SettingsView()
        view.performEmotionalSnapshotReset(defaults: defaults, analytics: analytics)

        for _ in 0..<60 {
            let count = await engine.eventCount
            if count >= 1 { break }
            try? await Task.sleep(for: .milliseconds(20))
        }

        let recorded = await engine.exportEvents()
        let matches = recorded.filter { $0.name == "emotional_snapshot_reset" }
        #expect(matches.count == 1, "Expected one emotional_snapshot_reset event after reset; got \(matches.count)")
    }

    @Test func resetIsIdempotentAcrossRepeatedCalls() {
        let defaults = makeDefaults()
        EmotionalSignalsPersistence.record(signals: sampleSignals(), defaults: defaults)

        let view = SettingsView()
        let analytics = DialogueQuestAnalytics(engine: AnalyticsEngine(config: AnalyticsConfig()))

        // First call clears.
        view.performEmotionalSnapshotReset(defaults: defaults, analytics: analytics)
        #expect(EmotionalSignalsPersistence.latest(defaults: defaults) == nil)

        // Second + third calls stay nil (no crash, no resurrected
        // signal). UserDefaults `removeObject(forKey:)` on a missing
        // key is a no-op.
        view.performEmotionalSnapshotReset(defaults: defaults, analytics: analytics)
        view.performEmotionalSnapshotReset(defaults: defaults, analytics: analytics)
        #expect(EmotionalSignalsPersistence.latest(defaults: defaults) == nil)
        #expect(EmotionalSignalsPersistence.latestTimestamp(defaults: defaults) == nil)
    }

    @Test func resetOnEmptyDefaultsIsSafe() {
        // Fresh-install path — calling reset before any snapshot is
        // recorded must not crash + must leave the surface in a known
        // empty state.
        let defaults = makeDefaults()
        #expect(EmotionalSignalsPersistence.latest(defaults: defaults) == nil)

        let view = SettingsView()
        view.performEmotionalSnapshotReset(
            defaults: defaults,
            analytics: DialogueQuestAnalytics(engine: AnalyticsEngine(config: AnalyticsConfig()))
        )

        #expect(EmotionalSignalsPersistence.latest(defaults: defaults) == nil)
        #expect(EmotionalSignalsPersistence.latestTimestamp(defaults: defaults) == nil)
    }
}
