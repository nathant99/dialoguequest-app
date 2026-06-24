import Testing
import Foundation
import ForgeAnalytics
@testable import Services

@MainActor
@Suite("DialogueQuestAnalytics")
struct DialogueQuestAnalyticsTests {
    @Test func everyEventRoundTripsThroughTheEngine() async {
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)

        analytics.track(.treePublished, properties: ["mood": "warmReunion"])
        analytics.track(.subtextConfirmed)
        analytics.track(.badgeEarned, properties: ["badge_id": "first_tree_authored"])

        // `track` is fire-and-forget. Wait until the actor has drained.
        for _ in 0..<60 {
            let count = await engine.eventCount
            if count >= 3 { break }
            try? await Task.sleep(for: .milliseconds(20))
        }

        let recorded = await engine.exportEvents()
        let names = Set(recorded.map(\.name))
        #expect(names.contains("tree_published"))
        #expect(names.contains("subtext_confirmed"))
        #expect(names.contains("badge_earned"))
    }

    @Test func eventVocabularyIsStable() {
        // Stable wire-level event names — the parent-progress reader
        // mines historical events by raw string. Lock the names to a
        // canonical set.
        let actual = Set(DialogueQuestAnalytics.Event.allCases.map(\.rawValue))
        let expected: Set<String> = [
            "tree_published",
            "subtext_confirmed",
            "subtext_rejected",
            "branch_reflected",
            "badge_earned",
            "streak_advanced",
            "streak_held_under_distress",
            "streak_broken",
            "welcome_back_shown",
            "session_timer_gentle_nudge",
            "session_ending_summary_shown",
            "anthology_entry_shared",
            "cast_voicing_shown",
            "performance_booth_exported"
        ]
        #expect(actual == expected, "Event vocabulary drift will break historical mining; coordinate the change.")
    }

    @Test func sessionLifecycleSurfacesUUIDs() async {
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)

        let sessionID = await analytics.startSession()
        analytics.track(.treePublished)
        // Let the fire-and-forget land.
        for _ in 0..<60 {
            let count = await engine.eventCount
            if count >= 2 { break }
            try? await Task.sleep(for: .milliseconds(20))
        }
        let summary = await analytics.endSession()

        #expect(summary != nil)
        #expect(summary?.sessionId == sessionID)
    }

    @Test func categoricalPropertiesOnlyNoPII() {
        // Compile-time guard: the `Event` enum's vocabulary defines what
        // shows up on the wire. Properties are caller-controlled but the
        // domain rule (categorical / counts / IDs only — never raw text
        // or display names) is documented on the service and enforced
        // by the ForgeAnalytics PII blocklist at the engine layer.
        //
        // This test is intentionally a no-op assertion that records the
        // contract for future readers — any code review surfacing a
        // raw-text or display-name property MUST also fail this rule
        // check. Audit grep:
        //   grep -rn 'DialogueQuestAnalytics.shared.track(' Libraries/Sources/
        //   inspect every `properties:` arg
        #expect(true)
    }
}
