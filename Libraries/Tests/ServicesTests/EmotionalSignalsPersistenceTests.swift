import Foundation
import Testing
@testable import Services
import ForgeEmotionAware

/// Tests for `EmotionalSignalsPersistence` — the UserDefaults-backed
/// snapshot store that bridges `PatterReactionService`'s per-session
/// signals to the parent-progress dashboard reader. Per the
/// `DialogueEmotionalStateProbe` precedent the persistence shim is a
/// pure value-type seam.
@MainActor
@Suite("EmotionalSignalsPersistence")
struct EmotionalSignalsPersistenceTests {

    /// Suite-isolated UserDefaults instance so the tests don't poison
    /// the standard defaults consumed by other tests / the app.
    private func makeDefaults() -> UserDefaults {
        let name = "dq.test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @Test("returns nil when no snapshot has been captured")
    func latestNilOnFreshInstall() {
        let defaults = makeDefaults()
        #expect(EmotionalSignalsPersistence.latest(defaults: defaults) == nil)
    }

    @Test("round-trips a snapshot with all four signal fields")
    func recordRoundTrip() {
        let defaults = makeDefaults()
        let signals = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 3,
            tagImbalanceCount: 2,
            branchReflectionRatio: 0.25,
            minutesSinceLastPublish: 12.5
        )
        EmotionalSignalsPersistence.record(signals: signals, defaults: defaults)
        let read = EmotionalSignalsPersistence.latest(defaults: defaults)
        #expect(read != nil)
        #expect(read?.voiceDriftCount == 3)
        #expect(read?.tagImbalanceCount == 2)
        #expect(read?.branchReflectionRatio == 0.25)
        #expect(read?.minutesSinceLastPublish == 12.5)
    }

    @Test("nil minutesSinceLastPublish round-trips as nil (not 0)")
    func nilMinutesRoundTrip() {
        let defaults = makeDefaults()
        let signals = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 0,
            tagImbalanceCount: 0,
            branchReflectionRatio: 1.0,
            minutesSinceLastPublish: nil
        )
        EmotionalSignalsPersistence.record(signals: signals, defaults: defaults)
        let read = EmotionalSignalsPersistence.latest(defaults: defaults)
        #expect(read != nil)
        #expect(read?.minutesSinceLastPublish == nil)
    }

    @Test("overwriting nil-minutes clears a previously-stored value")
    func overwritingClearsMinutes() {
        let defaults = makeDefaults()
        // Seed a real-publish snapshot.
        let initial = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 1,
            tagImbalanceCount: 0,
            branchReflectionRatio: 0.5,
            minutesSinceLastPublish: 4.0
        )
        EmotionalSignalsPersistence.record(signals: initial, defaults: defaults)
        // Then overwrite with a no-publish snapshot (later in the same
        // session, before a publish has happened — e.g., the kid reset
        // the tree and re-opened a draft).
        let next = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 2,
            tagImbalanceCount: 1,
            branchReflectionRatio: 0.3,
            minutesSinceLastPublish: nil
        )
        EmotionalSignalsPersistence.record(signals: next, defaults: defaults)
        let read = EmotionalSignalsPersistence.latest(defaults: defaults)
        #expect(read?.minutesSinceLastPublish == nil)
    }

    @Test("reset clears every stored field including the has-snapshot flag")
    func resetClearsAll() {
        let defaults = makeDefaults()
        let signals = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 4,
            tagImbalanceCount: 4,
            branchReflectionRatio: 0.1,
            minutesSinceLastPublish: 60.0
        )
        EmotionalSignalsPersistence.record(signals: signals, defaults: defaults)
        EmotionalSignalsPersistence.reset(defaults: defaults)
        #expect(EmotionalSignalsPersistence.latest(defaults: defaults) == nil)
        #expect(defaults.bool(forKey: EmotionalSignalsPersistence.Key.hasSnapshot) == false)
    }

    @Test("descriptor mapping is deterministic for each EmotionalState")
    func descriptorPerEmotionalState() {
        // .frustrated — 3+ voice drifts trip Tier 1
        let frustrated = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 3,
            tagImbalanceCount: 0,
            branchReflectionRatio: 1.0,
            minutesSinceLastPublish: nil
        )
        let d1 = DialogueEmotionalStateProbe.descriptor(forSignals: frustrated)
        #expect(d1.parentSummary == "Same notes keep coming up")
        #expect(d1.howWeSupport.contains("eases off"))

        // .disengaged — low reflection + stalled cadence
        let disengaged = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 0,
            tagImbalanceCount: 1,
            branchReflectionRatio: 0.1,
            minutesSinceLastPublish: 30.0
        )
        let d2 = DialogueEmotionalStateProbe.descriptor(forSignals: disengaged)
        #expect(d2.parentSummary == "Branches without follow-through")

        // .flow — quiet steady state
        let flow = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 0,
            tagImbalanceCount: 0,
            branchReflectionRatio: 0.8,
            minutesSinceLastPublish: 6.0
        )
        let d3 = DialogueEmotionalStateProbe.descriptor(forSignals: flow)
        #expect(d3.parentSummary == "Settled writing rhythm")
    }

    @Test("descriptor copy is reader-register clean (no engineering jargon)")
    func descriptorStoplistClean() {
        // Capture every state's descriptor and grep against the
        // `.claude/rules/distributed-narrative.md` § "Chapter content
        // register stoplist" — fields readers see must not leak
        // engineering / project-mgmt / framework jargon.
        let allStates: [EmotionalState] = [
            .flow, .frustrated, .bored, .disengaged,
            .confused, .confident, .recovering,
        ]
        let stoplist = [
            "load-bearing", "codified", "regression class",
            "soft-collision", "single source of truth",
            "phase A", "phase B", "ADR-", "PR #", "round ",
            "SAMHSA", "TIP 57", "trauma-gated", "primitive",
            "embody the primitive", "distributed-narrative",
        ]
        for state in allStates {
            let d = DialogueEmotionalStateDescriptor.descriptor(for: state)
            let merged = "\(d.parentSummary) \(d.whatThisMeans) \(d.howWeSupport) \(d.nextMilestone)".lowercased()
            for token in stoplist {
                #expect(
                    merged.contains(token.lowercased()) == false,
                    "Descriptor for \(state) leaked stoplist token '\(token)': \(merged)"
                )
            }
        }
    }
}
