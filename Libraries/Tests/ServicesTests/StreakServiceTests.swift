import Foundation
import Testing
@testable import Services

@MainActor
@Suite("StreakService")
struct StreakServiceTests {

    /// Build a fresh UserDefaults backed by an isolated suite so each
    /// test runs against a clean store. Cleanup happens via the suite's
    /// `removePersistentDomain(forName:)`.
    private func makeSuite(name: String = UUID().uuidString) -> UserDefaults {
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    @Test("First record establishes a streak of 1 + persists")
    func firstRecordEstablishesStreak() async throws {
        let suite = makeSuite()
        let service = StreakService(defaults: suite)
        let result = await service.recordPublishedTree()
        let streak = service.currentStreak()
        #expect(streak == 1, "First session should establish streak=1, got \(streak)")
        // Same-day re-record returns sameDay(_) or continued() and
        // keeps the streak at a sensible value (1 or 2 in any reasonable
        // StreakManager contract).
        _ = result
        let again = await service.recordPublishedTree()
        switch again {
        case .sameDay(let streak):
            #expect(streak == 1)
        case .continued(let streak):
            #expect(streak == 1 || streak == 2)
        default:
            break
        }
    }

    @Test("Persisted streak survives service re-instantiation")
    func streakPersists() async throws {
        let suiteName = UUID().uuidString
        let suite = UserDefaults(suiteName: suiteName)!
        suite.removePersistentDomain(forName: suiteName)
        let serviceA = StreakService(defaults: suite)
        _ = await serviceA.recordPublishedTree()
        let savedStreak = serviceA.currentStreak()
        // Re-build the service against the same defaults; the new
        // instance must read the persisted value.
        let serviceB = StreakService(defaults: suite)
        let restored = serviceB.currentStreak()
        #expect(restored == savedStreak)
    }

    @Test("Available freezes default to the config value on a fresh store")
    func freezesDefaultFromConfig() throws {
        let suite = makeSuite()
        let service = StreakService(defaults: suite)
        let freezes = service.availableFreezes()
        // DialogueQuestGamification.makeConfig() returns
        // streakFreezeCount: 2 — the test asserts the contract holds.
        #expect(freezes == 2)
    }

    @Test("lastSessionDate is nil before any record, populated after")
    func lastSessionDateBehavior() async throws {
        let suite = makeSuite()
        let service = StreakService(defaults: suite)
        let beforeAny = service.lastSessionDate()
        #expect(beforeAny == nil)
        _ = await service.recordPublishedTree()
        let afterRecord = service.lastSessionDate()
        #expect(afterRecord != nil)
        if let afterRecord {
            // Must be within ~5 seconds of now.
            #expect(abs(afterRecord.timeIntervalSinceNow) < 5)
        }
    }
}
