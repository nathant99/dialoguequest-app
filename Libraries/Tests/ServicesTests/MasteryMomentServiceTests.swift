import Foundation
import Testing
@testable import Services

/// First-mastery threshold-crossing service. Fires exactly once per
/// device when the published tree's averageVoiceMatch crosses 0.85.
/// Subsequent crossings + below-threshold publishes return non-firing
/// outcomes so the cinematic doesn't repeat.
@MainActor
@Suite("MasteryMomentService")
struct MasteryMomentServiceTests {

    private func makeSuite(name: String = UUID().uuidString) -> UserDefaults {
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    // MARK: - Threshold gate

    @Test func belowThresholdReturnsBelowThresholdOutcome() {
        let suite = makeSuite()
        let service = MasteryMomentService(defaults: suite)
        let outcome = service.recordPublishedTree(averageVoiceMatch: 0.50)
        #expect(outcome == .belowThreshold)
        #expect(service.firstMasteryAchievedAt() == nil)
    }

    @Test func justBelowThresholdReturnsBelowThresholdOutcome() {
        let suite = makeSuite()
        let service = MasteryMomentService(defaults: suite)
        let outcome = service.recordPublishedTree(averageVoiceMatch: 0.849)
        #expect(outcome == .belowThreshold)
    }

    @Test func atThresholdFiresFirstMastery() {
        let suite = makeSuite()
        let service = MasteryMomentService(defaults: suite)
        let outcome = service.recordPublishedTree(averageVoiceMatch: 0.85)
        #expect(outcome == .firstMasteryAchieved)
        #expect(service.firstMasteryAchievedAt() != nil)
    }

    @Test func aboveThresholdFiresFirstMastery() {
        let suite = makeSuite()
        let service = MasteryMomentService(defaults: suite)
        let outcome = service.recordPublishedTree(averageVoiceMatch: 0.92)
        #expect(outcome == .firstMasteryAchieved)
    }

    // MARK: - One-shot guarantee

    @Test func subsequentCrossingsReturnAlreadyAchieved() {
        let suite = makeSuite()
        let service = MasteryMomentService(defaults: suite)
        _ = service.recordPublishedTree(averageVoiceMatch: 0.88)
        let second = service.recordPublishedTree(averageVoiceMatch: 0.95)
        #expect(second == .alreadyAchievedEarlier)
    }

    @Test func belowThresholdAfterMasteryStillReturnsBelow() {
        let suite = makeSuite()
        let service = MasteryMomentService(defaults: suite)
        _ = service.recordPublishedTree(averageVoiceMatch: 0.90)
        let third = service.recordPublishedTree(averageVoiceMatch: 0.40)
        #expect(third == .belowThreshold)
    }

    // MARK: - Persistence

    @Test func masteryTimestampPersistsAcrossInstances() {
        let suite = makeSuite()
        let first = MasteryMomentService(defaults: suite)
        _ = first.recordPublishedTree(averageVoiceMatch: 0.86)
        let second = MasteryMomentService(defaults: suite)
        #expect(second.firstMasteryAchievedAt() != nil)
        let outcome = second.recordPublishedTree(averageVoiceMatch: 0.99)
        #expect(outcome == .alreadyAchievedEarlier)
    }

    // MARK: - Reset

    @Test func resetClearsThePersistedMilestone() {
        let suite = makeSuite()
        let service = MasteryMomentService(defaults: suite)
        _ = service.recordPublishedTree(averageVoiceMatch: 0.90)
        #expect(service.firstMasteryAchievedAt() != nil)
        service.reset()
        #expect(service.firstMasteryAchievedAt() == nil)
        let outcome = service.recordPublishedTree(averageVoiceMatch: 0.86)
        #expect(outcome == .firstMasteryAchieved)
    }

    // MARK: - Storage-key contract

    @Test func canonicalStorageKey() {
        // The host RootView binds via @AppStorage to this exact key.
        // Renaming the key would silently break the cinematic.
        #expect(MasteryMomentService.defaultsKeyFirstMasteryAt == "dq.firstMasteryAchievedAt")
    }

    @Test func canonicalThreshold() {
        // 0.85 matches the FEATURE_PLAN target for voice-consistency
        // internalization + the DDAEngine.Config voiceMatchCeiling.
        #expect(MasteryMomentService.threshold == 0.85)
    }
}
