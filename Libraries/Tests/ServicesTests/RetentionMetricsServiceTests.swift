import Foundation
import Testing
@testable import Services

@MainActor
@Suite("RetentionMetricsService")
struct RetentionMetricsServiceTests {

    private func makeSuite() -> UserDefaults {
        let name = UUID().uuidString
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    @Test("First recordAppOpen seeds firstLaunch but leaves all flags false")
    func firstOpenSeedsLaunch() {
        let suite = makeSuite()
        let service = RetentionMetricsService(defaults: suite)
        service.recordAppOpen(now: Date(timeIntervalSinceReferenceDate: 1_000))
        let snap = service.snapshot()
        #expect(snap.firstLaunch != nil)
        #expect(snap.hitD1 == false)
        #expect(snap.hitD7 == false)
        #expect(snap.hitD30 == false)
    }

    @Test("Re-open after 1 day flips hitD1")
    func d1Flips() {
        let suite = makeSuite()
        let calendar = Calendar(identifier: .gregorian)
        let service = RetentionMetricsService(defaults: suite, calendar: calendar)
        let day0 = Date(timeIntervalSinceReferenceDate: 1_000)
        service.recordAppOpen(now: day0)
        let day1 = calendar.date(byAdding: .day, value: 1, to: day0)!
        service.recordAppOpen(now: day1)
        let snap = service.snapshot()
        #expect(snap.hitD1 == true)
        #expect(snap.hitD7 == false)
    }

    @Test("Re-open after 7 days flips D1 + D7")
    func d7Flips() {
        let suite = makeSuite()
        let calendar = Calendar(identifier: .gregorian)
        let service = RetentionMetricsService(defaults: suite, calendar: calendar)
        let day0 = Date(timeIntervalSinceReferenceDate: 1_000)
        service.recordAppOpen(now: day0)
        let day7 = calendar.date(byAdding: .day, value: 7, to: day0)!
        service.recordAppOpen(now: day7)
        let snap = service.snapshot()
        #expect(snap.hitD1 == true)
        #expect(snap.hitD7 == true)
        #expect(snap.hitD30 == false)
    }

    @Test("Re-open after 30 days flips all three")
    func d30Flips() {
        let suite = makeSuite()
        let calendar = Calendar(identifier: .gregorian)
        let service = RetentionMetricsService(defaults: suite, calendar: calendar)
        let day0 = Date(timeIntervalSinceReferenceDate: 1_000)
        service.recordAppOpen(now: day0)
        let day30 = calendar.date(byAdding: .day, value: 30, to: day0)!
        service.recordAppOpen(now: day30)
        let snap = service.snapshot()
        #expect(snap.hitD1 == true)
        #expect(snap.hitD7 == true)
        #expect(snap.hitD30 == true)
    }

    @Test("reset clears all keys")
    func resetClears() {
        let suite = makeSuite()
        let calendar = Calendar(identifier: .gregorian)
        let service = RetentionMetricsService(defaults: suite, calendar: calendar)
        let day0 = Date(timeIntervalSinceReferenceDate: 1_000)
        service.recordAppOpen(now: day0)
        let day7 = calendar.date(byAdding: .day, value: 7, to: day0)!
        service.recordAppOpen(now: day7)
        service.reset()
        let snap = service.snapshot()
        #expect(snap.firstLaunch == nil)
        #expect(snap.hitD1 == false)
        #expect(snap.hitD7 == false)
        #expect(snap.hitD30 == false)
    }
}
