import Testing
import Foundation
import ForgeAnalytics
@testable import Services

/// Priority R (2026-07-06) — the new
/// `DialogueQuestAnalytics.Event.emotionalSnapshotReset` case fires
/// when the parent taps "Reset emotional snapshot" in Settings (after
/// the `ParentalGateChallenge` clears). The event is no-properties +
/// categorical; the on-device retention reader only needs to know it
/// happened.
@MainActor
@Suite("DialogueQuestAnalytics emotional snapshot reset event")
struct DialogueQuestAnalyticsEmotionalSnapshotResetTests {

    @Test func eventRawValueIsCanonical() {
        // The raw value is the wire-key for the on-device retention
        // reader; a rename would silently disconnect future readers.
        #expect(DialogueQuestAnalytics.Event.emotionalSnapshotReset.rawValue == "emotional_snapshot_reset")
    }

    @Test func eventCaseIsInVocabulary() {
        // Sanity check that the new case is reachable via `allCases`
        // so any future Event-driven dispatch loop covers it.
        #expect(DialogueQuestAnalytics.Event.allCases.contains(.emotionalSnapshotReset))
    }

    @Test func trackEmitsExactlyOneEvent() async {
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)

        analytics.track(.emotionalSnapshotReset)

        for _ in 0..<60 {
            let count = await engine.eventCount
            if count >= 1 { break }
            try? await Task.sleep(for: .milliseconds(20))
        }

        let recorded = await engine.exportEvents()
        let matches = recorded.filter { $0.name == "emotional_snapshot_reset" }
        #expect(matches.count == 1, "Expected exactly one emotional_snapshot_reset event; got \(matches.count)")
        #expect(matches.first?.properties.isEmpty == true, "emotional_snapshot_reset should carry no properties — it's a categorical signal only")
    }
}
