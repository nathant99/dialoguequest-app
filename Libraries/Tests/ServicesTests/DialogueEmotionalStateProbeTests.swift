import Foundation
import Testing
import ForgeEmotionAware
@testable import Services

/// Tests for the thin `DialogueEmotionalStateProbe` wrapper around
/// ForgeKit's `ForgeEmotionAware.EmotionalState`. Each probe surface
/// receives independent coverage:
///
/// 1. Default Signals (no events, no publish, ratio 1.0) → `.flow`
/// 2. Voice-axis saturation (3+ drifts) → `.frustrated`
/// 3. Tag-axis saturation (3+ imbalances) → `.frustrated`
/// 4. Multi-axis mid-firing (2 drift + 2 imbalance + low ratio) → `.confused`
/// 5. Disengagement (low reflection + stalled cadence) → `.disengaged`
/// 6. Boredom (no events + no engagement loop for 30+ min) → `.bored`
/// 7. Confident hold (recent publish + steady authoring) → `.confident`
/// 8. Trajectory recovery (`.frustrated` prior → `.flow` now) → `.recovering`
/// 9. Trajectory recovery (`.frustrated` prior → `.confident` now) → `.recovering`
/// 10. Suppression delegation matches ForgeEmotionAware canonical
/// 11. Descriptor non-empty for every state (parent-readable register coverage)
/// 12. Descriptor register-stoplist (no engineering / project-mgmt jargon)
/// 13. Signals reflection-ratio clamping (negative / > 1.0)
@Suite("DialogueEmotionalStateProbe")
struct DialogueEmotionalStateProbeTests {

    @Test("Default signals classify as flow")
    func defaultSignalsAreFlow() {
        let signals = DialogueEmotionalStateProbe.Signals()
        #expect(DialogueEmotionalStateProbe.suggestedState(forSignals: signals) == .flow)
    }

    @Test("3+ voice drifts saturate to frustrated")
    func voiceDriftSaturationFrustrated() {
        let signals = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 3,
            tagImbalanceCount: 0,
            branchReflectionRatio: 1.0
        )
        #expect(DialogueEmotionalStateProbe.suggestedState(forSignals: signals) == .frustrated)
    }

    @Test("3+ tag imbalances saturate to frustrated")
    func tagImbalanceSaturationFrustrated() {
        let signals = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 0,
            tagImbalanceCount: 3,
            branchReflectionRatio: 1.0
        )
        #expect(DialogueEmotionalStateProbe.suggestedState(forSignals: signals) == .frustrated)
    }

    @Test("Multi-axis mid-firing classifies as confused")
    func multiAxisMidFiringConfused() {
        let signals = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 2,
            tagImbalanceCount: 2,
            branchReflectionRatio: 0.3
        )
        #expect(DialogueEmotionalStateProbe.suggestedState(forSignals: signals) == .confused)
    }

    @Test("Low reflection + stalled cadence classifies as disengaged")
    func disengagementClassifiesAsDisengaged() {
        let signals = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 0,
            tagImbalanceCount: 0,
            branchReflectionRatio: 0.2,
            minutesSinceLastPublish: 26
        )
        #expect(DialogueEmotionalStateProbe.suggestedState(forSignals: signals) == .disengaged)
    }

    @Test("No engagement loop + 30+ min stalls to bored")
    func boredomClassifiesAsBored() {
        let signals = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 0,
            tagImbalanceCount: 0,
            branchReflectionRatio: 0.0,
            minutesSinceLastPublish: 31
        )
        #expect(DialogueEmotionalStateProbe.suggestedState(forSignals: signals) == .bored)
    }

    @Test("Recent publish + steady authoring classifies as confident")
    func confidentHoldClassifiesAsConfident() {
        let signals = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 1,
            tagImbalanceCount: 0,
            branchReflectionRatio: 0.75,
            minutesSinceLastPublish: 2
        )
        #expect(DialogueEmotionalStateProbe.suggestedState(forSignals: signals) == .confident)
    }

    @Test("Frustrated → flow trajectory classifies as recovering")
    func frustratedToFlowIsRecovering() {
        let signals = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 0,
            tagImbalanceCount: 0,
            branchReflectionRatio: 1.0,
            minutesSinceLastPublish: nil,
            priorState: .frustrated
        )
        #expect(DialogueEmotionalStateProbe.suggestedState(forSignals: signals) == .recovering)
    }

    @Test("Frustrated → confident trajectory classifies as recovering")
    func frustratedToConfidentIsRecovering() {
        let signals = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 1,
            tagImbalanceCount: 0,
            branchReflectionRatio: 0.75,
            minutesSinceLastPublish: 2,
            priorState: .frustrated
        )
        #expect(DialogueEmotionalStateProbe.suggestedState(forSignals: signals) == .recovering)
    }

    @Test("Suppression delegation matches ForgeEmotionAware canonical")
    func suppressionDelegationMatchesCanonical() {
        // Frustrated saturates → ForgeEmotionAware says suppress.
        let frustrated = DialogueEmotionalStateProbe.Signals(voiceDriftCount: 3)
        #expect(DialogueEmotionalStateProbe.shouldSuppressCelebrations(forSignals: frustrated) == true)
        // Flow → ForgeEmotionAware says don't suppress.
        let flow = DialogueEmotionalStateProbe.Signals()
        #expect(DialogueEmotionalStateProbe.shouldSuppressCelebrations(forSignals: flow) == false)
        // Confident → don't suppress (celebration is appropriate).
        let confident = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 1,
            branchReflectionRatio: 0.75,
            minutesSinceLastPublish: 2
        )
        #expect(DialogueEmotionalStateProbe.shouldSuppressCelebrations(forSignals: confident) == false)
    }

    @Test("Descriptor is non-empty for every EmotionalState")
    func descriptorNonEmptyForEveryState() {
        let states: [EmotionalState] = [
            .flow, .frustrated, .bored, .disengaged, .confused, .confident, .recovering,
        ]
        for state in states {
            let descriptor = DialogueEmotionalStateDescriptor.descriptor(for: state)
            #expect(!descriptor.parentSummary.isEmpty, "parentSummary empty for \(state)")
            #expect(!descriptor.whatThisMeans.isEmpty, "whatThisMeans empty for \(state)")
            #expect(!descriptor.howWeSupport.isEmpty, "howWeSupport empty for \(state)")
            #expect(!descriptor.nextMilestone.isEmpty, "nextMilestone empty for \(state)")
        }
    }

    @Test("Descriptor register stoplist (no engineering / project jargon)")
    func descriptorRegisterStoplistClean() {
        // Per `.claude/rules/distributed-narrative.md` § Chapter content
        // register stoplist — these tokens MUST NOT appear in reader-facing
        // dashboard surfaces.
        let stoplist = [
            "load-bearing",
            "codified",
            "soft-collision",
            "hard-collision",
            "SAMHSA",
            "TIP 57",
            "ADR-",
            "trauma-gated",
            "downstream",
            "upstream",
            "first-class",
            "in-band",
            "out-of-band",
            "Phase A",
            "Phase B",
            "Phase C",
            "Phase D",
            "R0 reviewer",
        ]
        let states: [EmotionalState] = [
            .flow, .frustrated, .bored, .disengaged, .confused, .confident, .recovering,
        ]
        for state in states {
            let descriptor = DialogueEmotionalStateDescriptor.descriptor(for: state)
            let combined = [
                descriptor.parentSummary,
                descriptor.whatThisMeans,
                descriptor.howWeSupport,
                descriptor.nextMilestone,
            ].joined(separator: " ")
            for token in stoplist {
                #expect(
                    !combined.localizedCaseInsensitiveContains(token),
                    "Found stoplist token '\(token)' in descriptor for \(state)"
                )
            }
        }
    }

    @Test("Reflection ratio clamps to [0.0, 1.0]")
    func reflectionRatioClamps() {
        let negative = DialogueEmotionalStateProbe.Signals(branchReflectionRatio: -0.5)
        #expect(negative.branchReflectionRatio == 0.0)
        let overUnit = DialogueEmotionalStateProbe.Signals(branchReflectionRatio: 1.7)
        #expect(overUnit.branchReflectionRatio == 1.0)
        let inRange = DialogueEmotionalStateProbe.Signals(branchReflectionRatio: 0.5)
        #expect(inRange.branchReflectionRatio == 0.5)
    }

    @Test("descriptor(forSignals:) routes through suggestedState")
    func descriptorRoutesThroughSuggestedState() {
        let signals = DialogueEmotionalStateProbe.Signals(voiceDriftCount: 3)
        let descriptor = DialogueEmotionalStateProbe.descriptor(forSignals: signals)
        let expected = DialogueEmotionalStateDescriptor.descriptor(for: .frustrated)
        #expect(descriptor == expected)
    }

    @Test("priorState frustrated but current still frustrated stays frustrated")
    func priorFrustratedStillFrustrated() {
        let signals = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 3,
            priorState: .frustrated
        )
        // Should remain `.frustrated`, NOT collapse to `.recovering`,
        // because current classification is still `.frustrated`.
        #expect(DialogueEmotionalStateProbe.suggestedState(forSignals: signals) == .frustrated)
    }

    @Test("priorState non-frustrated → no recovering promotion")
    func priorNonFrustratedNoPromotion() {
        let signals = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 1,
            branchReflectionRatio: 0.75,
            minutesSinceLastPublish: 2,
            priorState: .bored
        )
        // Should classify as `.confident`, not promote to `.recovering`.
        #expect(DialogueEmotionalStateProbe.suggestedState(forSignals: signals) == .confident)
    }
}
