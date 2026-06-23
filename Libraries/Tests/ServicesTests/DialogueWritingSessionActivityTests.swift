import Testing
import Foundation
@testable import Services
import ForgeLiveActivities

@Suite("DialogueWritingSessionActivity — entitlement-gated scaffold")
@MainActor
struct DialogueWritingSessionActivityTests {

    @Test("availability surfaces a known state regardless of bundle config")
    func availabilityIsNonCrashing() {
        let activity = DialogueWritingSessionActivity.shared
        let expected: [DialogueWritingSessionActivity.Availability] = [
            .notWired, .ready, .active
        ]
        #expect(expected.contains(activity.availability))
    }

    @Test("isWired probe matches availability invariants")
    func isWiredMatchesAvailability() {
        let activity = DialogueWritingSessionActivity.shared
        if DialogueWritingSessionActivity.isWired {
            // wired bundle — availability is .ready or .active, never .notWired
            #expect(activity.availability != .notWired)
        } else {
            #expect(activity.availability == .notWired)
        }
    }

    @Test("availabilityDescription reads in age-9-14 register for every state")
    func availabilityDescriptionRegister() {
        let activity = DialogueWritingSessionActivity.shared
        let description = activity.availabilityDescription
        #expect(!description.isEmpty)
        let stoplist = [
            "load-bearing", "codified", "SAMHSA", "TIP 57",
            "ADR-", "Phase A", "Phase B", "PR #"
        ]
        for token in stoplist {
            #expect(!description.lowercased().contains(token.lowercased()))
        }
    }

    @Test("WritingSessionAttributes init preserves every field")
    func attributesInitPreservesFields() {
        let attrs = DialogueWritingSessionActivity.WritingSessionAttributes(
            subjectName: "Quiet conflict scene",
            iconName: "text.bubble.fill",
            totalNodesTarget: 12
        )
        #expect(attrs.subjectName == "Quiet conflict scene")
        #expect(attrs.iconName == "text.bubble.fill")
        #expect(attrs.totalNodesTarget == 12)
    }

    @Test("WritingSessionAttributes default icon is text.bubble")
    func attributesDefaultIcon() {
        let attrs = DialogueWritingSessionActivity.WritingSessionAttributes(subjectName: "x")
        #expect(attrs.iconName == "text.bubble")
    }

    @Test("toForgeAttributes maps to the .practice session type")
    func attributesMapToForge() {
        let attrs = DialogueWritingSessionActivity.WritingSessionAttributes(
            subjectName: "Test",
            iconName: "icon",
            totalNodesTarget: 5
        )
        let forge = attrs.toForgeAttributes()
        #expect(forge.subjectName == "Test")
        #expect(forge.iconName == "icon")
        #expect(forge.totalQuestions == 5)
        #expect(forge.sessionType == .practice)
    }

    @Test("WritingSessionContentState toForgeState — paused maps to .paused")
    func stateMapsToPaused() {
        let state = DialogueWritingSessionActivity.WritingSessionContentState(
            currentNodeCount: 3,
            totalNodesTarget: 10,
            moodLabel: "quiet conflict",
            elapsedMinutes: 5,
            isPaused: true
        )
        let forge = state.toForgeState()
        #expect(forge.status == .paused)
        #expect(forge.currentQuestion == 3)
        #expect(forge.totalQuestions == 10)
        #expect(forge.timeRemaining == 300)
    }

    @Test("WritingSessionContentState toForgeState — running maps to .active")
    func stateMapsToActive() {
        let state = DialogueWritingSessionActivity.WritingSessionContentState(
            currentNodeCount: 1,
            totalNodesTarget: 15,
            moodLabel: "playful",
            elapsedMinutes: 0,
            isPaused: false
        )
        let forge = state.toForgeState()
        #expect(forge.status == .active)
    }

    // MARK: - Lifecycle no-op invariants (entitlement-gated)

    @Test("start / update / end are safe to call when not wired (no crash, no state change)")
    func lifecycleSafeWhenUnwired() {
        let activity = DialogueWritingSessionActivity.shared
        let attributes = DialogueWritingSessionActivity.WritingSessionAttributes(
            subjectName: "Test scene"
        )
        let state = DialogueWritingSessionActivity.WritingSessionContentState(
            currentNodeCount: 3,
            totalNodesTarget: 15,
            moodLabel: "Quiet",
            elapsedMinutes: 2,
            isPaused: false
        )
        // No expectation other than: nothing crashes. The activity manager
        // is never touched when isWired is false; if wired, the calls
        // succeed but ActivityKit is real so we don't inspect state.
        activity.start(attributes: attributes, state: state)
        activity.update(state: state)
        activity.end()
        if !DialogueWritingSessionActivity.isWired {
            #expect(activity.availability == .notWired)
        }
    }

    @Test("end is idempotent — calling it twice does not crash")
    func endIsIdempotent() {
        let activity = DialogueWritingSessionActivity.shared
        activity.end()
        activity.end()
        // Both calls are safe regardless of wiring state.
        let known: [DialogueWritingSessionActivity.Availability] = [.notWired, .ready, .active]
        #expect(known.contains(activity.availability))
    }
}
