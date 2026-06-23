import Testing
@testable import AppFeature

@Suite("VoiceCrucibleMachine") @MainActor
struct VoiceCrucibleMachineTests {

    @Test func initialStageIsSelectingCast() {
        let machine = VoiceCrucibleMachine()
        #expect(machine.stage == .selectingCast)
        #expect(machine.draft.isEmpty)
        #expect(machine.attemptCount == 0)
    }

    @Test func selectCastValidIDTransitionsToWriting() {
        var machine = VoiceCrucibleMachine()
        machine.selectCast(id: "brogue")
        #expect(machine.stage == .writing(targetCastID: "brogue"))
        #expect(machine.draft.isEmpty)
    }

    @Test func selectCastRejectsUnknownID() {
        var machine = VoiceCrucibleMachine()
        machine.selectCast(id: "not-a-real-cast")
        #expect(machine.stage == .selectingCast)
    }

    @Test func selectCastRejectsWorldLayerProfile() {
        // heralda is WORLD layer — Voice Crucible only targets LESSONS.
        var machine = VoiceCrucibleMachine()
        machine.selectCast(id: "heralda")
        #expect(machine.stage == .selectingCast)
    }

    @Test func selectCastRejectsMetaLayerProfile() {
        // aria is META layer — Voice Crucible only targets LESSONS.
        var machine = VoiceCrucibleMachine()
        machine.selectCast(id: "aria")
        #expect(machine.stage == .selectingCast)
    }

    @Test func submitFromSelectingIsNoOp() {
        var machine = VoiceCrucibleMachine()
        machine.draft = "Aye, lad."
        machine.submit()
        // submit() requires .writing — staying in .selectingCast is correct
        #expect(machine.stage == .selectingCast)
        #expect(machine.attemptCount == 0)
    }

    @Test func submitWithEmptyDraftIsNoOp() {
        var machine = VoiceCrucibleMachine()
        machine.selectCast(id: "brogue")
        machine.draft = "   \n\t  "
        machine.submit()
        // Still in .writing — empty whitespace doesn't count
        #expect(machine.stage == .writing(targetCastID: "brogue"))
        #expect(machine.attemptCount == 0)
    }

    @Test func submitBumpsAttemptCount() {
        var machine = VoiceCrucibleMachine()
        machine.selectCast(id: "brogue")
        machine.draft = "Aye, lad, mind ye listen."
        machine.submit()
        #expect(machine.attemptCount == 1)
        if case .scored = machine.stage {} else {
            Issue.record("Expected .scored after submit")
        }
    }

    @Test func submitDifferentiatesOnRegisterFromOffRegister() {
        // The scoring is Jaccard token-overlap on a small per-line sample
        // vs the full catchphrase pool (~50 baseline tokens). Single-line
        // matches don't usually land in the locked band; the meaningful
        // assertion is that an on-register line scores STRICTLY HIGHER
        // than an off-register line.
        let onRegister = VoiceCrucibleMachine.score(
            line: "Aye, lad, mind ye listen for the same voice in every line.",
            targetCastID: "brogue"
        )
        let offRegister = VoiceCrucibleMachine.score(
            line: "Quantum entanglement defies classical intuition.",
            targetCastID: "brogue"
        )
        #expect(onRegister > offRegister,
                "On-register score (\(onRegister)) should beat off-register (\(offRegister))")
        #expect(offRegister < 0.1,
                "Off-register score should be near zero (got \(offRegister))")
    }

    @Test func submitProducesNonZeroScoreForOnRegisterLine() {
        var machine = VoiceCrucibleMachine()
        machine.selectCast(id: "brogue")
        // A Brogue-signature line should produce a score meaningfully
        // above the off-register baseline (~0). Single-line Jaccard
        // against the full catchphrase pool is naturally bounded around
        // 0.25-0.35; clearing 0.15 is sufficient to assert the algorithm
        // is doing voice-aware work.
        machine.draft = "Aye, lad, mind ye listen for the same voice in every line."
        machine.submit()
        guard case let .scored(_, score) = machine.stage else {
            Issue.record("Expected .scored")
            return
        }
        #expect(score > 0.15,
                "Brogue-signature line should score meaningfully above zero (got \(score))")
    }

    @Test func retryWithSameCastResetsDraftButKeepsTarget() {
        var machine = VoiceCrucibleMachine()
        machine.selectCast(id: "glance")
        machine.draft = "What's hiding underneath?"
        machine.submit()
        machine.retryWithSameCast()
        #expect(machine.stage == .writing(targetCastID: "glance"))
        #expect(machine.draft.isEmpty)
    }

    @Test func retryFromSelectingIsNoOp() {
        var machine = VoiceCrucibleMachine()
        machine.retryWithSameCast()
        #expect(machine.stage == .selectingCast)
    }

    @Test func reselectCastClearsTarget() {
        var machine = VoiceCrucibleMachine()
        machine.selectCast(id: "sprig")
        machine.draft = "A branch that costs the speaker something."
        machine.submit()
        machine.reselectCast()
        #expect(machine.stage == .selectingCast)
        #expect(machine.draft.isEmpty)
    }

    @Test func resetClearsAllState() {
        var machine = VoiceCrucibleMachine()
        machine.selectCast(id: "weigh")
        machine.draft = "The scale is heavy."
        machine.submit()
        machine.reset()
        #expect(machine.stage == .selectingCast)
        #expect(machine.draft.isEmpty)
        #expect(machine.attemptCount == 0)
    }

    @Test func staticScoreReturnsZeroForUnknownCast() {
        let s = VoiceCrucibleMachine.score(line: "anything", targetCastID: "bogus")
        #expect(s == 0)
    }

    @Test func staticScoreIsDeterministic() {
        let line = "Aye, lad, mind ye."
        let a = VoiceCrucibleMachine.score(line: line, targetCastID: "brogue")
        let b = VoiceCrucibleMachine.score(line: line, targetCastID: "brogue")
        #expect(a == b)
    }

    @Test func voiceBandThresholds() {
        #expect(VoiceCrucibleMachine.VoiceBand(score: 0.0) == .drifting)
        #expect(VoiceCrucibleMachine.VoiceBand(score: 0.39) == .drifting)
        #expect(VoiceCrucibleMachine.VoiceBand(score: 0.4) == .onRegister)
        #expect(VoiceCrucibleMachine.VoiceBand(score: 0.64) == .onRegister)
        #expect(VoiceCrucibleMachine.VoiceBand(score: 0.65) == .locked)
        #expect(VoiceCrucibleMachine.VoiceBand(score: 1.0) == .locked)
    }

    @Test("Coaching lines stay in age-9-14 register (no engineering jargon)")
    func coachingLinesRegisterStoplist() {
        let stoplist = [
            "load-bearing", "codified", "canonical", "SAMHSA",
            "Phase 1", "Phase 2", "Phase 3", "ADR-",
            "primitive", "register stoplist"
        ]
        let casts = ["brogue", "glance", "rest", "sprig", "weigh"]
        let bands: [VoiceCrucibleMachine.VoiceBand] = [.drifting, .onRegister, .locked]
        for cast in casts {
            for band in bands {
                let line = VoiceCrucibleMachine.coachingLine(targetCastID: cast, band: band)
                #expect(!line.isEmpty, "(\(cast), \(band)) is empty")
                #expect(line.count <= 160, "(\(cast), \(band)) is over 160 chars (\(line.count))")
                for token in stoplist {
                    #expect(
                        !line.lowercased().contains(token.lowercased()),
                        "(\(cast), \(band)) leaks register stoplist token \"\(token)\": \(line)"
                    )
                }
            }
        }
    }

    @Test func coachingLineFallbackForUnknownCast() {
        let line = VoiceCrucibleMachine.coachingLine(
            targetCastID: "not-a-real-cast",
            band: .onRegister
        )
        #expect(!line.isEmpty)
    }
}
