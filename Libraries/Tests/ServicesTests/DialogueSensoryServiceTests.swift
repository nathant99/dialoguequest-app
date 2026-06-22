import Foundation
import Testing
import ForgeSensory
@testable import Services

/// Verifies the 4 domain methods dispatch through the underlying
/// `SensoryPalette` cleanly + that the last-event probe surfaces the
/// fired event. We don't assert haptic playback (the FK haptic engine
/// is a real subsystem and SPM tests run headless without an iPad
/// haptic motor) — the `lastEvent` surface is the test seam.
@MainActor
@Suite("DialogueSensoryService")
struct DialogueSensoryServiceTests {

    @Test func freshServiceHasNoLastEvent() {
        let service = DialogueSensoryService(palette: SensoryPalette())
        #expect(service.lastEvent == nil)
    }

    @Test func treePublishedFiresChallengeComplete() {
        let service = DialogueSensoryService(palette: SensoryPalette())
        service.treePublished()
        #expect(service.lastEvent?.kind == .challengeComplete)
    }

    @Test func achievementEarnedFiresAchievement() {
        let service = DialogueSensoryService(palette: SensoryPalette())
        service.achievementEarned()
        #expect(service.lastEvent?.kind == .achievement)
    }

    @Test func streakAdvancedCarriesCount() {
        let service = DialogueSensoryService(palette: SensoryPalette())
        service.streakAdvanced(7)
        let event = service.lastEvent
        #expect(event?.kind == .streakMilestone)
        if case .streakMilestone(let count) = event {
            #expect(count == 7)
        } else {
            Issue.record("expected .streakMilestone(7), got \(String(describing: event))")
        }
    }

    @Test func subtextRevealedFiresReveal() {
        let service = DialogueSensoryService(palette: SensoryPalette())
        service.subtextRevealed()
        #expect(service.lastEvent?.kind == .reveal)
    }

    @Test func sequenceOverwritesLastEvent() {
        let service = DialogueSensoryService(palette: SensoryPalette())
        service.treePublished()
        service.achievementEarned()
        service.streakAdvanced(3)
        #expect(service.lastEvent?.kind == .streakMilestone)
    }

    @Test func sharedSingletonReachable() {
        // The singleton itself must be safe to read without crashing — it's
        // accessed by AchievementService / StreakService / WriteTabView /
        // SubtextPanelView from various MainActor contexts. We don't assert
        // on its `lastEvent` (tests share the singleton; mutation order is
        // undefined across the suite). The reachability check is enough.
        let shared = DialogueSensoryService.shared
        _ = shared.lastEvent  // does not crash
    }
}
