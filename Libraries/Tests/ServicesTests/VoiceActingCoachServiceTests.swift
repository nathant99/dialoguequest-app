import Testing
import Foundation
@testable import Services
import Models

@Suite("VoiceActingCoachService — privacy-gated scaffold")
@MainActor
struct VoiceActingCoachServiceTests {

    @Test("availability surfaces a known state and never crashes the privacy-gated probe")
    func availabilitySurfaceIsNonCrashing() {
        // Per the privacy-gated-framework rule, the probe must NEVER
        // crash regardless of Info.plist state. The actual returned state
        // depends on whether the host bundle declares the two usage
        // descriptions (`NSMicrophoneUsageDescription` +
        // `NSSpeechRecognitionUsageDescription`) — the static-let probe
        // resolves once at first access and stays cached. We only verify
        // the state is one of the four documented enum cases; the wired
        // path activation is tracked via the user GUI handoff.
        let service = VoiceActingCoachService.shared
        let expected: [VoiceActingCoachService.Availability] = [
            .notWired, .notRequested, .unavailable, .ready
        ]
        #expect(expected.contains(service.availability))
    }

    @Test("isWired static probe matches availability invariants")
    func isWiredMatchesAvailability() {
        // When the static-let probe returns false (Info.plist unwired),
        // availability MUST be .notWired. When true, availability is one
        // of the wired states (.notRequested / .unavailable / .ready —
        // never .notWired). This pins down the static-let invariant so
        // future refactors of the probe stay safe.
        let service = VoiceActingCoachService.shared
        if VoiceActingCoachService.isWired {
            #expect(service.availability != .notWired)
        } else {
            #expect(service.availability == .notWired)
        }
    }

    @Test("availabilityDescription is reader-facing in every state")
    func availabilityDescriptionRegister() {
        let service = VoiceActingCoachService.shared
        let description = service.availabilityDescription
        #expect(!description.isEmpty)
        // R-CHAPTER-REGISTER stoplist guard — no engineering jargon
        let stoplist = ["load-bearing", "codified", "SAMHSA", "TIP 57", "primitive", "register", "phase A", "phase B"]
        for token in stoplist {
            #expect(!description.lowercased().contains(token.lowercased()))
        }
    }

    @Test("scoreTranscript exact match yields 1.0")
    func scoreTranscriptExactMatch() {
        let baseline = "rain fell on the roof in the slow quiet hour"
        let score = VoiceActingCoachService.scoreTranscript(baseline, against: baseline)
        #expect(score == 1.0)
    }

    @Test("scoreTranscript zero overlap yields 0.0")
    func scoreTranscriptNoOverlap() {
        let baseline = "rain fell on the roof"
        let transcript = "tomorrow morning ate bicycles loudly"
        let score = VoiceActingCoachService.scoreTranscript(transcript, against: baseline)
        #expect(score == 0.0)
    }

    @Test("scoreTranscript partial overlap clamps to (0.0, 1.0)")
    func scoreTranscriptPartialOverlap() {
        let baseline = "the dog runs fast"
        let transcript = "the cat runs slow"
        let score = VoiceActingCoachService.scoreTranscript(transcript, against: baseline)
        #expect(score > 0.0)
        #expect(score < 1.0)
    }

    @Test("band maps high score → strong, low score → drifting")
    func bandMapping() {
        #expect(VoiceActingCoachService.band(forScore: 0.95) == .strong)
        #expect(VoiceActingCoachService.band(forScore: 0.50) == .acceptable)
        #expect(VoiceActingCoachService.band(forScore: 0.10) == .drifting)
    }

    @Test("coachingLine is non-empty + character-name-bearing for every band")
    func coachingLineCoverage() {
        let name = "Brogue"
        for band in WritingEvaluator.VoiceBand.allCases {
            let line = VoiceActingCoachService.coachingLine(forBand: band, characterName: name)
            #expect(!line.isEmpty)
            #expect(line.contains(name))
        }
    }

    @Test("coachingLine register stoplist — every band's line clean of engineering jargon")
    func coachingLineRegister() {
        let stoplist = [
            "load-bearing", "codified", "SAMHSA", "TIP 57",
            "primitive", "register", "Phase A", "Phase B",
            "ADR-", "PR #", "round close"
        ]
        for band in WritingEvaluator.VoiceBand.allCases {
            let line = VoiceActingCoachService.coachingLine(forBand: band, characterName: "Glance")
            for token in stoplist {
                #expect(!line.lowercased().contains(token.lowercased()), "Band \(band) coaching line leaks '\(token)': \(line)")
            }
        }
    }

    // MARK: - Active session integration

    @Test("makeActiveSession returns nil when not wired and a session when wired")
    func makeActiveSessionRespectsGate() {
        let service = VoiceActingCoachService.shared
        defer { service.resetActiveSession() }
        let session = service.makeActiveSession()
        if VoiceActingCoachService.isWired {
            #expect(session != nil)
        } else {
            #expect(session == nil)
        }
    }

    @Test("makeActiveSession caches the same instance across calls")
    func makeActiveSessionCachesInstance() {
        let service = VoiceActingCoachService.shared
        defer { service.resetActiveSession() }
        let first = service.makeActiveSession()
        let second = service.makeActiveSession()
        if VoiceActingCoachService.isWired {
            #expect(first === second)
        } else {
            #expect(first == nil)
            #expect(second == nil)
        }
    }

    @Test("resetActiveSession clears the cache so a future call returns a fresh instance")
    func resetActiveSessionClearsCache() {
        let service = VoiceActingCoachService.shared
        guard VoiceActingCoachService.isWired else {
            // On unwired builds, both calls return nil — no cache to clear.
            #expect(service.makeActiveSession() == nil)
            return
        }
        let first = service.makeActiveSession()
        service.resetActiveSession()
        let second = service.makeActiveSession()
        #expect(first !== second)
        service.resetActiveSession()
    }
}

@Suite("VoiceActingCoachActiveSession — lifecycle invariants")
@MainActor
struct VoiceActingCoachActiveSessionTests {

    @Test("freshly constructed session is in .idle phase")
    func idlePhaseAtInit() {
        let session = VoiceActingCoachActiveSession()
        #expect(session.phase == .idle)
    }

    @Test("cancel is idempotent + resets to .idle")
    func cancelIsIdempotent() {
        let session = VoiceActingCoachActiveSession()
        session.cancel()
        #expect(session.phase == .idle)
        session.cancel()
        #expect(session.phase == .idle)
    }

    @Test("stopRecording is no-op when not in .recording state")
    func stopWhenNotRecordingIsNoOp() {
        let session = VoiceActingCoachActiveSession()
        let phase = session.stopRecording()
        // No transition from .idle when stopRecording is called without
        // first starting; phase should stay at .idle.
        #expect(phase == .idle)
        #expect(session.phase == .idle)
    }

    @Test("startRecording is no-op when not yet authorized")
    func startWhenNotAuthorizedIsNoOp() {
        let session = VoiceActingCoachActiveSession()
        let phase = session.startRecording()
        // Without explicit authorization, startRecording short-circuits
        // and the phase stays at .idle.
        #expect(phase == .idle)
        #expect(session.phase == .idle)
    }

    @Test("drainAccumulatedSamples returns empty for a fresh session")
    func drainEmptyAtInit() {
        let session = VoiceActingCoachActiveSession()
        let samples = session.drainAccumulatedSamples()
        #expect(samples.isEmpty)
    }

    @Test("Phase.completed equality is transcript-driven")
    func completedEqualityIsTranscriptDriven() {
        let a = VoiceActingCoachActiveSession.Phase.completed(transcript: "hello world")
        let b = VoiceActingCoachActiveSession.Phase.completed(transcript: "hello world")
        let c = VoiceActingCoachActiveSession.Phase.completed(transcript: "goodbye")
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Phase.failed equality is reason-driven")
    func failedEqualityIsReasonDriven() {
        let a = VoiceActingCoachActiveSession.Phase.failed(reason: "mic denied")
        let b = VoiceActingCoachActiveSession.Phase.failed(reason: "mic denied")
        let c = VoiceActingCoachActiveSession.Phase.failed(reason: "speech denied")
        #expect(a == b)
        #expect(a != c)
    }
}
