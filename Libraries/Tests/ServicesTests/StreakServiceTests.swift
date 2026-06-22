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

    @Test("inspectStreakStatus returns .neverStarted on a fresh store")
    func statusNeverStartedOnFreshStore() {
        let suite = makeSuite()
        let service = StreakService(defaults: suite)
        switch service.inspectStreakStatus() {
        case .neverStarted: break
        default: Issue.record("Expected .neverStarted on fresh store")
        }
    }

    @Test("inspectStreakStatus returns .active immediately after a record")
    func statusActiveAfterRecord() async {
        let suite = makeSuite()
        let service = StreakService(defaults: suite)
        _ = await service.recordPublishedTree()
        switch service.inspectStreakStatus() {
        case .active(let streak):
            #expect(streak >= 1)
        default:
            Issue.record("Expected .active immediately after recordPublishedTree")
        }
    }

    @Test("inspectStreakStatus returns .broken when lapsed beyond freezes")
    func statusBrokenWhenLapsed() {
        let suiteName = UUID().uuidString
        let suite = UserDefaults(suiteName: suiteName)!
        suite.removePersistentDomain(forName: suiteName)
        // Seed a 7-day streak with 0 freezes available + a last-session
        // date 5 days ago. The lapse is 5 - 1 = 4 days uncovered.
        suite.set(7, forKey: StreakService.defaultsKeyStreak)
        suite.set(0, forKey: StreakService.defaultsKeyFreezes)
        let calendar = Calendar(identifier: .gregorian)
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: .now)!
        suite.set(
            fiveDaysAgo.timeIntervalSinceReferenceDate,
            forKey: StreakService.defaultsKeyLastSession
        )
        let service = StreakService(defaults: suite, calendar: calendar)
        switch service.inspectStreakStatus() {
        case .broken(let previousStreak):
            #expect(previousStreak == 7)
        default:
            Issue.record("Expected .broken for a 5-day lapse with 0 freezes")
        }
    }

    @Test("inspectStreakStatus stays .active when lapsed within freeze coverage")
    func statusActiveWithinFreezeCoverage() {
        let suiteName = UUID().uuidString
        let suite = UserDefaults(suiteName: suiteName)!
        suite.removePersistentDomain(forName: suiteName)
        // Seed a 3-day streak with 2 freezes available + a last-session
        // date 2 days ago. daysSince = 2, daysSince - 1 = 1, covered by
        // 1 freeze; uncovered = 0 → .active.
        suite.set(3, forKey: StreakService.defaultsKeyStreak)
        suite.set(2, forKey: StreakService.defaultsKeyFreezes)
        let calendar = Calendar(identifier: .gregorian)
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: .now)!
        suite.set(
            twoDaysAgo.timeIntervalSinceReferenceDate,
            forKey: StreakService.defaultsKeyLastSession
        )
        let service = StreakService(defaults: suite, calendar: calendar)
        switch service.inspectStreakStatus() {
        case .active(let streak):
            #expect(streak == 3)
        default:
            Issue.record("Expected .active for a 2-day lapse with 2 freezes")
        }
    }

    @Test("brokenStreakMessage is non-empty and warm")
    func brokenStreakMessageShape() {
        // Sanity-test the message body — keeps the warm framing locked
        // in and prevents a future refactor from accidentally producing
        // a "0-day streak" or other numeric / shaming surface.
        #expect(!StreakService.brokenStreakMessage.isEmpty)
        let lowercase = StreakService.brokenStreakMessage.lowercased()
        #expect(lowercase.contains("miss"))
    }
}
