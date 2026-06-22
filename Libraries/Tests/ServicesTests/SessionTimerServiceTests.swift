import Foundation
import Testing
@testable import Services

@MainActor
@Suite("SessionTimerService")
struct SessionTimerServiceTests {

    @Test("Fresh service starts idle with no startedAt")
    func freshServiceIsIdle() {
        let service = SessionTimerService()
        #expect(service.phase == .idle)
        #expect(service.startedAt == nil)
        #expect(service.elapsed() == 0)
    }

    @Test("start() flips to .running and records startedAt")
    func startEntersRunning() {
        let service = SessionTimerService()
        let t0 = Date(timeIntervalSinceReferenceDate: 1_000)
        service.start(now: t0)
        #expect(service.phase == .running)
        #expect(service.startedAt == t0)
    }

    @Test("start() is idempotent when already running")
    func startIsIdempotent() {
        let service = SessionTimerService()
        let t0 = Date(timeIntervalSinceReferenceDate: 1_000)
        service.start(now: t0)
        let later = Date(timeIntervalSinceReferenceDate: 2_000)
        service.start(now: later)
        // startedAt did NOT move
        #expect(service.startedAt == t0)
    }

    @Test("tick crosses gentle-nudge threshold at the soft floor")
    func tickReachesGentleNudge() {
        let service = SessionTimerService(
            config: .init(gentleNudgeAfter: 600, endingSummaryAfter: 780)
        )
        let t0 = Date(timeIntervalSinceReferenceDate: 1_000)
        service.start(now: t0)
        service.tick(now: t0.addingTimeInterval(599))
        #expect(service.phase == .running)
        service.tick(now: t0.addingTimeInterval(600))
        #expect(service.phase == .gentleNudgeReady)
    }

    @Test("tick crosses ending-summary threshold at the soft ceiling")
    func tickReachesEndingSummary() {
        let service = SessionTimerService(
            config: .init(gentleNudgeAfter: 600, endingSummaryAfter: 780)
        )
        let t0 = Date(timeIntervalSinceReferenceDate: 1_000)
        service.start(now: t0)
        service.tick(now: t0.addingTimeInterval(780))
        #expect(service.phase == .endingSummaryReady)
    }

    @Test("Phase progression never backslides")
    func phaseNeverBackslides() {
        let service = SessionTimerService(
            config: .init(gentleNudgeAfter: 600, endingSummaryAfter: 780)
        )
        let t0 = Date(timeIntervalSinceReferenceDate: 1_000)
        service.start(now: t0)
        service.tick(now: t0.addingTimeInterval(800))
        #expect(service.phase == .endingSummaryReady)
        // A later tick at a lower elapsed time (clock skew) must not
        // regress the phase back to gentleNudgeReady.
        service.tick(now: t0.addingTimeInterval(620))
        #expect(service.phase == .endingSummaryReady)
    }

    @Test("reset returns to idle and clears startedAt")
    func resetClearsState() {
        let service = SessionTimerService()
        service.start()
        service.reset()
        #expect(service.phase == .idle)
        #expect(service.startedAt == nil)
    }

    @Test("tick is a no-op when idle")
    func tickWhileIdleNoOp() {
        let service = SessionTimerService()
        service.tick(now: Date(timeIntervalSinceReferenceDate: 9_999))
        #expect(service.phase == .idle)
    }

    @Test("derive returns running below gentle threshold")
    func deriveRunning() {
        let phase = SessionTimerService.derive(
            elapsed: 100,
            config: .init(gentleNudgeAfter: 600, endingSummaryAfter: 780)
        )
        #expect(phase == .running)
    }
}
