import Foundation
import Testing
import ForgePedagogy
@testable import Services

/// Articulate-before-hint discipline backed by ForgeKit 0.99's
/// `ScaffoldingEngine`. Tests cover the publish → success / failure
/// transitions, tier escalation under repeated failures, auto-fade
/// after consecutive successes, and persistence round-trip.
@MainActor
@Suite("DialogueScaffoldingService")
struct DialogueScaffoldingServiceTests {

    private func makeSuite(name: String = UUID().uuidString) -> UserDefaults {
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    // MARK: - Fresh state

    @Test func freshServiceHasNoTier() {
        let suite = makeSuite()
        let service = DialogueScaffoldingService(defaults: suite)
        #expect(service.currentTier == nil)
        #expect(service.isScaffolded == false)
        #expect(service.independenceRate == 1.0)
    }

    // MARK: - Failure path

    @Test func twoConsecutiveFailuresActivateScaffolding() {
        let suite = makeSuite()
        let service = DialogueScaffoldingService(
            defaults: suite,
            config: ScaffoldingConfig(fadeThreshold: 3, restoreThreshold: 2)
        )
        service.recordPublishedWithoutReflection()
        service.recordPublishedWithoutReflection()
        #expect(service.isScaffolded == true)
        #expect(service.currentTier == .vague)
    }

    @Test func continuedFailuresAfterScaffoldingEscalateTier() {
        let suite = makeSuite()
        let service = DialogueScaffoldingService(
            defaults: suite,
            config: ScaffoldingConfig(fadeThreshold: 3, restoreThreshold: 2)
        )
        service.recordPublishedWithoutReflection()
        service.recordPublishedWithoutReflection()  // tier .vague
        service.recordPublishedWithoutReflection()  // tier escalates to .medium
        #expect(service.currentTier == .medium)
        service.recordPublishedWithoutReflection()  // tier escalates to .specific
        #expect(service.currentTier == .specific)
        service.recordPublishedWithoutReflection()  // tier capped at .specific
        #expect(service.currentTier == .specific)
    }

    // MARK: - Success path

    @Test func threeConsecutiveSuccessesFadeScaffolding() {
        let suite = makeSuite()
        let service = DialogueScaffoldingService(
            defaults: suite,
            config: ScaffoldingConfig(fadeThreshold: 3, restoreThreshold: 2)
        )
        // First activate scaffolding via 2 failures.
        service.recordPublishedWithoutReflection()
        service.recordPublishedWithoutReflection()
        #expect(service.isScaffolded == true)
        // 3 successes should fade.
        service.recordPublishedWithReflection()
        service.recordPublishedWithReflection()
        service.recordPublishedWithReflection()
        #expect(service.isScaffolded == false)
        #expect(service.currentTier == nil)
    }

    @Test func successFromColdStateDoesNotActivateScaffolding() {
        let suite = makeSuite()
        let service = DialogueScaffoldingService(defaults: suite)
        service.recordPublishedWithReflection()
        #expect(service.isScaffolded == false)
        #expect(service.currentTier == nil)
    }

    // MARK: - Persistence

    @Test func tierPersistsAcrossInstantiation() {
        let suite = makeSuite()
        let first = DialogueScaffoldingService(
            defaults: suite,
            config: ScaffoldingConfig(fadeThreshold: 3, restoreThreshold: 2)
        )
        first.recordPublishedWithoutReflection()
        first.recordPublishedWithoutReflection()
        #expect(first.currentTier == .vague)
        let second = DialogueScaffoldingService(
            defaults: suite,
            config: ScaffoldingConfig(fadeThreshold: 3, restoreThreshold: 2)
        )
        #expect(second.currentTier == .vague)
        #expect(second.isScaffolded == true)
    }

    @Test func independenceRateTracksScaffoldedVsIndependentSolves() {
        let suite = makeSuite()
        let service = DialogueScaffoldingService(
            defaults: suite,
            config: ScaffoldingConfig(fadeThreshold: 3, restoreThreshold: 2)
        )
        // 2 independent solves (scaffolding inactive)
        service.recordPublishedWithReflection()
        service.recordPublishedWithReflection()
        #expect(service.independenceRate == 1.0)
        // Trigger scaffolding via 2 failures
        service.recordPublishedWithoutReflection()
        service.recordPublishedWithoutReflection()
        // 2 successes while scaffolded → scaffolded solves
        service.recordPublishedWithReflection()
        service.recordPublishedWithReflection()
        // 2 independent + 2 scaffolded = 50% independence
        #expect(service.independenceRate == 0.5)
    }

    // MARK: - Reset

    @Test func resetClearsState() {
        let suite = makeSuite()
        let service = DialogueScaffoldingService(defaults: suite)
        service.recordPublishedWithoutReflection()
        service.recordPublishedWithoutReflection()
        #expect(service.isScaffolded == true)
        service.reset()
        #expect(service.isScaffolded == false)
        #expect(service.currentTier == nil)
    }

    // MARK: - HintTier ordering (smoke test for the ForgeKit API surface
    //                            we lean on)

    @Test func hintTiersAreComparableInExpectedOrder() {
        #expect(HintTier.vague < HintTier.medium)
        #expect(HintTier.medium < HintTier.specific)
        #expect(HintTier.vague < HintTier.specific)
    }
}
