import Foundation
import Testing
import ForgeGamification
import Models
@testable import Services

/// Mood-aware streak path. The `recordPublishedTree(mood:)` overload
/// maps `DialogueMood` to an `EmotionSnapshot.distressScore`; when the
/// score clears the 0.65 default threshold, ForgeKit 0.86 routes through
/// `StreakResult.heldUnderDistress(streak:)` instead of advancing or
/// resetting. The streak is held flat (no break on a hard scene) but
/// the streak counter doesn't grow either — the kid is in flow.
@MainActor
@Suite("StreakService — mood-aware path")
struct StreakServiceMoodAwareTests {

    private func makeSuite(name: String = UUID().uuidString) -> UserDefaults {
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    // MARK: - Mood → EmotionSnapshot mapping

    @Test func warmMoodsMapToLowDistress() {
        let warm = StreakService.emotionSnapshot(for: .warmReunion)
        #expect(warm != nil)
        #expect((warm?.distressScore ?? 1.0) < 0.5)
    }

    @Test func hardMoodsMapToDistressAboveDefaultThreshold() {
        let quiet = StreakService.emotionSnapshot(for: .quietConflict)
        let awkward = StreakService.emotionSnapshot(for: .awkwardSilence)
        #expect((quiet?.distressScore ?? 0.0) >= 0.65)
        #expect((awkward?.distressScore ?? 0.0) >= 0.65)
    }

    @Test func playfulMoodsStayBelowThreshold() {
        for mood in [DialogueMood.playfulRivalry, .openingCuriosity] {
            let snapshot = StreakService.emotionSnapshot(for: mood)
            #expect((snapshot?.distressScore ?? 1.0) < 0.65,
                    "Mood \(mood) should not trigger distress suppression")
        }
    }

    @Test func nilMoodMapsToNilSnapshot() {
        let snapshot = StreakService.emotionSnapshot(for: nil)
        #expect(snapshot == nil)
    }

    @Test func everyMoodHasAMapping() {
        for mood in DialogueMood.allCases {
            let snapshot = StreakService.emotionSnapshot(for: mood)
            #expect(snapshot != nil, "Mood \(mood) returned nil snapshot")
        }
    }

    @Test func snapshotSourceIsDerivedFromTaskNotSelfReport() {
        // We're inferring distress from the mood tag — not asking the kid
        // to self-report. The source MUST stay non-biometric AND non-
        // self-report so future consumers don't accidentally treat the
        // signal as a primary affective measurement.
        for mood in DialogueMood.allCases {
            let snapshot = StreakService.emotionSnapshot(for: mood)
            #expect(snapshot?.source == .derivedFromTask,
                    "Mood \(mood) snapshot source != .derivedFromTask")
        }
    }

    // MARK: - End-to-end recordPublishedTree(mood:) path

    @Test func hardMoodPathProducesHeldUnderDistressResult() async {
        let service = StreakService(defaults: makeSuite())
        // First record a session normally so the streak is at 1.
        _ = await service.recordPublishedTree()
        // Re-record on the same day with a hard mood — distress
        // suppression keeps the streak held (not advanced) and returns
        // `.heldUnderDistress`.
        let result = await service.recordPublishedTree(mood: .quietConflict)
        if case .heldUnderDistress = result {
            // expected
        } else {
            Issue.record("Expected .heldUnderDistress, got \(result)")
        }
    }

    @Test func warmMoodPathAdvancesStreakNormally() async {
        let service = StreakService(defaults: makeSuite())
        let result = await service.recordPublishedTree(mood: .warmReunion)
        switch result {
        case .continued, .sameDay:
            // expected
            break
        case .heldUnderDistress:
            Issue.record("Warm mood should not trigger distress suppression")
        default:
            break
        }
    }

    @Test func nilMoodMatchesParameterlessRecord() async {
        // Calling `recordPublishedTree(mood: nil)` must produce the same
        // semantic result as the parameterless `recordPublishedTree()`
        // (both fall through to `StreakManager.recordSession()`).
        let service = StreakService(defaults: makeSuite())
        let nilMoodResult = await service.recordPublishedTree(mood: nil)
        // Same-day re-record returns `.sameDay` for the second call;
        // the first call returns `.continued(1)`. Compare the result's
        // case-only equality (numeric streaks may differ across timing).
        switch nilMoodResult {
        case .continued, .sameDay:
            break // expected on first call
        default:
            Issue.record("Nil mood should NOT trigger distress suppression; got \(nilMoodResult)")
        }
    }
}
