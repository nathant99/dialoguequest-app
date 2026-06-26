import Testing
import Foundation
import Models
import Services
import AIMentor
import AppFeature

/// Priority M.2 (2026-07-03) — `DialogueEmotionalStateProbe` wiring
/// into `PatterReactionService`'s celebration surfaces.
///
/// The service captures four per-session signals:
///   • `voiceDriftCount` — bumped in `onVoiceDrift` (post-threshold)
///   • `tagImbalanceCount` — bumped in `onTreeChanged` (dominant change)
///   • `lastPublishAt` — stamped by `recordTreeOutcome`
///   • `lastBranchReflectionRatio` — captured by `recordTreeOutcome`
///
/// At the two CELEBRATION cast-voicing surfaces
/// (`onBranchReflectionConfirmed` + `onSubtextConfirmed`), the service
/// snapshots `currentSignals` and calls
/// `DialogueEmotionalStateProbe.shouldSuppressCelebrations`. When true
/// (state == `.frustrated` || `.disengaged`), the cast voicing is
/// silenced + `suppressedCelebrationCount` bumps.
///
/// At the four COACHING surfaces (`onBranchPointSelected` /
/// `onSubtextDiscovered` / `onVoiceDrift` / `onTreeChanged`), no
/// suppression — coaching always fires regardless of emotional state.
@Suite("PatterReactionService emotional-state suppression wiring")
struct PatterReactionServiceEmotionalSuppressionTests {

    @MainActor
    private static func clearFlag() {
        UserDefaults.standard.removeObject(forKey: CastVoicingFeatureFlag.storageKey)
    }

    @MainActor
    private static func makeService(
        clock: @escaping @Sendable () -> Date = { Date() }
    ) -> (PatterReactionService, CastVoicingService) {
        let castVoicing = CastVoicingService(flagAccessor: { true })
        let service = PatterReactionService(
            mentor: PatterMentor(),
            castVoicing: castVoicing,
            clock: clock
        )
        return (service, castVoicing)
    }

    // MARK: - currentSignals snapshot shape

    @Test @MainActor func currentSignalsInitiallyEmpty() {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let (service, _) = Self.makeService()
        let signals = service.currentSignals
        #expect(signals.voiceDriftCount == 0)
        #expect(signals.tagImbalanceCount == 0)
        #expect(signals.minutesSinceLastPublish == nil)
        // Default ratio is 1.0 ("no branches yet — not stalled") per the
        // Signals init default; preserved across the seam.
        #expect(signals.branchReflectionRatio == 1.0)
    }

    @Test @MainActor func voiceDriftBumpsCounter() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let (service, _) = Self.makeService()
        // Below threshold → fire → bump
        await service.onVoiceDrift(score: 0.1, mood: .quietConflict)
        #expect(service.currentSignals.voiceDriftCount == 1)
        await service.onVoiceDrift(score: 0.1, mood: .quietConflict)
        #expect(service.currentSignals.voiceDriftCount == 2)
        // At-or-above threshold → no fire → no bump
        await service.onVoiceDrift(score: 0.99, mood: .quietConflict)
        #expect(service.currentSignals.voiceDriftCount == 2)
    }

    @Test @MainActor func tagImbalanceBumpsCounterOnDominantChange() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let (service, _) = Self.makeService()
        // Build a tree dominated by one tag classification first, then
        // mutate mid-test by swapping the dominant classification. The
        // bump should fire exactly once per dominant CHANGE — not per
        // node mutation.
        let tree1 = makeDominantClassificationTree(action: true)
        await service.onTreeChanged(tree1)
        let firstCount = service.currentSignals.tagImbalanceCount
        // Same dominant — no bump
        let tree2 = makeDominantClassificationTree(action: true)
        await service.onTreeChanged(tree2)
        #expect(service.currentSignals.tagImbalanceCount == firstCount)
        // New dominant — bump
        let tree3 = makeDominantClassificationTree(action: false)
        await service.onTreeChanged(tree3)
        #expect(service.currentSignals.tagImbalanceCount == firstCount + 1)
    }

    @Test @MainActor func recordTreeOutcomeStampsLastPublishAndRatio() {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let frozenNow = Date(timeIntervalSince1970: 1_700_000_000)
        let (service, _) = Self.makeService(clock: { frozenNow })
        service.recordTreeOutcome(reflectionRatio: 0.6, averageVoiceMatch: 0.8)
        let signals = service.currentSignals
        #expect(signals.branchReflectionRatio == 0.6)
        // minutesSinceLastPublish == 0 immediately after stamp.
        #expect(signals.minutesSinceLastPublish == 0.0)
    }

    // MARK: - Suppression gate at celebration surfaces

    @Test @MainActor func branchReflectionConfirmedFiresUnderFlow() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let (service, castVoicing) = Self.makeService()
        // No signal accumulation → .flow → no suppression.
        await service.onBranchReflectionConfirmed(mood: .openingCuriosity)
        #expect(castVoicing.lastVoicing?.surface == .branchReflectionConfirmed)
        #expect(service.suppressedCelebrationCount == 0)
    }

    @Test @MainActor func branchReflectionConfirmedSuppressedUnderFrustration() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let (service, castVoicing) = Self.makeService()
        // Drive 3 voice drifts → probe reads .frustrated → suppression on.
        for _ in 0..<3 {
            await service.onVoiceDrift(score: 0.1, mood: .quietConflict)
        }
        #expect(service.shouldSuppressCelebrationsNow)
        // Capture pre-suppression voicing (set by the voice-drift fires).
        let preSuppression = castVoicing.lastVoicing
        await service.onBranchReflectionConfirmed(mood: .openingCuriosity)
        // Cast voicing did NOT advance to .branchReflectionConfirmed.
        #expect(castVoicing.lastVoicing?.surface != .branchReflectionConfirmed)
        #expect(castVoicing.lastVoicing?.surface == preSuppression?.surface)
        #expect(service.suppressedCelebrationCount == 1)
    }

    @Test @MainActor func subtextConfirmedSuppressedUnderFrustration() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let (service, castVoicing) = Self.makeService()
        // Drive 4 voice drifts → .frustrated.
        for _ in 0..<4 {
            await service.onVoiceDrift(score: 0.1, mood: .quietConflict)
        }
        let preSuppression = castVoicing.lastVoicing
        await service.onSubtextConfirmed(mood: .quietConflict)
        #expect(castVoicing.lastVoicing?.surface != .subtextConfirmed)
        #expect(castVoicing.lastVoicing?.surface == preSuppression?.surface)
        #expect(service.suppressedCelebrationCount == 1)
    }

    @Test @MainActor func suppressedCelebrationCountAccumulates() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let (service, _) = Self.makeService()
        for _ in 0..<3 {
            await service.onVoiceDrift(score: 0.1, mood: .quietConflict)
        }
        await service.onBranchReflectionConfirmed(mood: .openingCuriosity)
        await service.onSubtextConfirmed(mood: .openingCuriosity)
        #expect(service.suppressedCelebrationCount == 2)
    }

    // MARK: - Coaching surfaces never suppressed

    @Test @MainActor func voiceDriftCoachingStillFiresUnderFrustration() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let (service, castVoicing) = Self.makeService()
        for _ in 0..<3 {
            await service.onVoiceDrift(score: 0.1, mood: .quietConflict)
        }
        #expect(service.shouldSuppressCelebrationsNow)
        // The 4th voice-drift coaching surface STILL fires.
        await service.onVoiceDrift(score: 0.1, mood: .quietConflict)
        #expect(castVoicing.lastVoicing?.surface == .voiceDrift)
        // Counter advanced; suppression count unchanged (coaching ≠ celebration).
        #expect(service.currentSignals.voiceDriftCount == 4)
        #expect(service.suppressedCelebrationCount == 0)
    }

    @Test @MainActor func branchPointSelectedCoachingStillFiresUnderFrustration() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let (service, castVoicing) = Self.makeService()
        for _ in 0..<3 {
            await service.onVoiceDrift(score: 0.1, mood: .quietConflict)
        }
        let branchID = UUID()
        await service.onBranchPointSelected(branchPointID: branchID, mood: .openingCuriosity)
        #expect(castVoicing.lastVoicing?.surface == .branchPointReached)
        #expect(service.suppressedCelebrationCount == 0)
    }

    // MARK: - shouldSuppressCelebrationsNow surface

    @Test @MainActor func shouldSuppressCelebrationsNowIsFalseInitially() {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let (service, _) = Self.makeService()
        #expect(service.shouldSuppressCelebrationsNow == false)
    }

    @Test @MainActor func shouldSuppressCelebrationsNowFlipsAfterThreeDrifts() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let (service, _) = Self.makeService()
        #expect(service.shouldSuppressCelebrationsNow == false)
        for _ in 0..<3 {
            await service.onVoiceDrift(score: 0.1, mood: .quietConflict)
        }
        #expect(service.shouldSuppressCelebrationsNow == true)
    }

    // MARK: - Reset

    @Test @MainActor func resetClearsAllSignalsAndSuppressionCounter() async {
        Self.clearFlag()
        CastVoicingFeatureFlag.set(true)
        let (service, _) = Self.makeService()
        for _ in 0..<3 {
            await service.onVoiceDrift(score: 0.1, mood: .quietConflict)
        }
        await service.onBranchReflectionConfirmed(mood: .openingCuriosity)
        #expect(service.currentSignals.voiceDriftCount == 3)
        #expect(service.suppressedCelebrationCount == 1)
        service.reset()
        let signals = service.currentSignals
        #expect(signals.voiceDriftCount == 0)
        #expect(signals.tagImbalanceCount == 0)
        #expect(signals.minutesSinceLastPublish == nil)
        #expect(signals.branchReflectionRatio == 1.0)
        #expect(service.suppressedCelebrationCount == 0)
    }

    // MARK: - Helpers

    @MainActor
    private func makeDominantClassificationTree(action: Bool) -> DialogueTree {
        // Build a 5-line tree where every node carries the same tag
        // classification (either all `.action(...)` → actionBeat
        // dominant, or all `.unattributed` → unattributed dominant).
        // The TagBalancer reads dominant classification off the per-
        // tree tag-frequency distribution, so a single-classification
        // tree guarantees a single `dominant` value.
        let iris = DialogueCharacterRef(
            name: "Iris",
            voiceRegister: "warm",
            sampleLines: ["Hi."]
        )
        let cal = DialogueCharacterRef(
            name: "Cal",
            voiceRegister: "wry",
            sampleLines: ["Oh."]
        )
        let tag: DialogueTag = action ? .action("she gestured") : .unattributed
        // Build a flat chain root → c1 → c2 → c3 → c4 so every node is
        // present. The TagBalancer counts per-node tags (not per-leaf).
        let nodeIDs = (0..<5).map { _ in UUID() }
        let nodes: [DialogueNode] = (0..<5).map { index in
            let speakerID = index % 2 == 0 ? iris.id : cal.id
            let children: [UUID] = index < 4 ? [nodeIDs[index + 1]] : []
            return DialogueNode(
                id: nodeIDs[index],
                speakerID: speakerID,
                surfaceText: "Line \(index)",
                tag: tag,
                children: children
            )
        }
        return DialogueTree(
            title: "test",
            characters: [iris, cal],
            nodes: nodes,
            rootNodeID: nodeIDs[0],
            mood: .quietConflict
        )
    }
}
