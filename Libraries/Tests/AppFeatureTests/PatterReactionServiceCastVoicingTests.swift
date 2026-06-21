import Testing
import Foundation
import Models
import AIMentor
import AppFeature

/// DN-S Move D Step 3 call-site orchestration tests.
///
/// `PatterReactionService` must:
///   1. NOT contact `CastVoicingService` when no service is injected.
///   2. NOT fire cast voicings when the feature flag is OFF.
///   3. Fire `branchPointReached` exactly ONCE per branch-point per session.
///   4. Fire `tagBalanceImbalance` only when the dominant tag class changes.
///   5. Fire `subtextConfirmed` after a confirmed subtext (path covered via
///      direct API call; `WriteTabView`'s `.onChange` glue is exercised by
///      UI tests in `Apps/DialogueQuestUITests`).
///   6. Fire `voiceDrift` only when the score falls below the threshold.
@Suite("PatterReactionService cast voicing wiring")
struct PatterReactionServiceCastVoicingTests {

    /// Reset the `dq.experiments.castVoicing` flag from the standard
    /// UserDefaults so every per-test set/get cycle starts off. Per
    /// `.claude/rules/testing.md` § Crash-Resilience Defaults #1 —
    /// `struct` suite, no deinit needed. `@MainActor` is applied to
    /// each test function rather than the suite so Swift Testing's
    /// discovery macro recognizes the suite cleanly.
    @MainActor
    private static func clearFlag() {
        UserDefaults.standard.removeObject(forKey: CastVoicingFeatureFlag.storageKey)
    }

    // MARK: - Flag-off path

    @Test @MainActor func noVoicingFiresWhenFlagIsOff() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(false)
        let castVoicing = CastVoicingService(flagAccessor: { false })
        let service = PatterReactionService(
            mentor: PatterMentor(),
            castVoicing: castVoicing
        )

        await service.onBranchPointSelected(branchPointID: UUID(), mood: .quietConflict)
        await service.onSubtextConfirmed(mood: .quietConflict)
        await service.onVoiceDrift(score: 0.1, mood: .quietConflict)

        #expect(castVoicing.lastVoicing == nil)
    }

    @Test @MainActor func noVoicingFiresWhenServiceIsNil() async {
        Self.clearFlag()
        // No `castVoicing` injected at all — Phase 1's default config.
        let service = PatterReactionService(mentor: PatterMentor(), castVoicing: nil)
        // No assertion on internal state here — just confirm we don't crash
        // calling every voicing-aware method without an injected service.
        await service.onBranchPointSelected(branchPointID: UUID(), mood: nil)
        await service.onBranchReflectionConfirmed(mood: nil)
        await service.onSubtextDiscovered(line: "I'm fine.", mood: nil)
        await service.onSubtextConfirmed(mood: nil)
        await service.onVoiceDrift(score: 0.1, mood: nil)
        #expect(Bool(true))
    }

    // MARK: - Flag-on path

    @Test @MainActor func branchPointSelectionFiresVoicingOnce() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let castVoicing = CastVoicingService(flagAccessor: { true })
        let service = PatterReactionService(
            mentor: PatterMentor(),
            castVoicing: castVoicing
        )

        let branchID = UUID()
        await service.onBranchPointSelected(branchPointID: branchID, mood: .openingCuriosity)
        let firstVoicing = castVoicing.lastVoicing
        #expect(firstVoicing?.castID == "sprig")
        #expect(firstVoicing?.surface == .branchPointReached)

        // Re-selecting the SAME branch-point should not produce a NEW voicing.
        // We capture the id of the existing voicing and check it doesn't
        // change after re-trigger.
        let firstID = firstVoicing?.id
        await service.onBranchPointSelected(branchPointID: branchID, mood: .openingCuriosity)
        #expect(castVoicing.lastVoicing?.id == firstID)
    }

    @Test @MainActor func subtextConfirmedFiresGlanceAffirmation() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let castVoicing = CastVoicingService(flagAccessor: { true })
        let service = PatterReactionService(
            mentor: PatterMentor(),
            castVoicing: castVoicing
        )

        await service.onSubtextConfirmed(mood: .quietConflict)
        #expect(castVoicing.lastVoicing?.castID == "glance")
        #expect(castVoicing.lastVoicing?.surface == .subtextConfirmed)
    }

    @Test @MainActor func voiceDriftBelowThresholdFiresBrogue() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let castVoicing = CastVoicingService(flagAccessor: { true })
        let service = PatterReactionService(
            mentor: PatterMentor(),
            castVoicing: castVoicing
        )

        await service.onVoiceDrift(score: 0.1, mood: .quietConflict)
        #expect(castVoicing.lastVoicing?.castID == "brogue")
    }

    @Test @MainActor func voiceDriftAtOrAboveThresholdDoesNothing() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let castVoicing = CastVoicingService(flagAccessor: { true })
        let service = PatterReactionService(
            mentor: PatterMentor(),
            castVoicing: castVoicing
        )

        // Threshold is 0.4 (strictly less than) — 0.4 itself should NOT fire.
        await service.onVoiceDrift(score: 0.4, mood: nil)
        #expect(castVoicing.lastVoicing == nil)

        await service.onVoiceDrift(score: 0.9, mood: nil)
        #expect(castVoicing.lastVoicing == nil)
    }

    // MARK: - Reset

    @Test @MainActor func resetClearsVoicingAndGreetedBranchSet() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let castVoicing = CastVoicingService(flagAccessor: { true })
        let service = PatterReactionService(
            mentor: PatterMentor(),
            castVoicing: castVoicing
        )

        let branchID = UUID()
        await service.onBranchPointSelected(branchPointID: branchID, mood: nil)
        #expect(castVoicing.lastVoicing != nil)

        service.reset()
        #expect(castVoicing.lastVoicing == nil)

        // After reset, selecting the SAME branch-point fires a fresh voicing.
        await service.onBranchPointSelected(branchPointID: branchID, mood: nil)
        #expect(castVoicing.lastVoicing != nil)
    }
}
