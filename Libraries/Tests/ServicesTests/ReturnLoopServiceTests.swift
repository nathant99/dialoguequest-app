import Foundation
import Testing
@testable import Services

@MainActor
@Suite("ReturnLoopService")
struct ReturnLoopServiceTests {

    private func makeSuite() -> UserDefaults {
        let name = UUID().uuidString
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    @Test("No published trees: never surfaces welcome-back")
    func noPublishedTrees() {
        let suite = makeSuite()
        let service = ReturnLoopService(defaults: suite)
        suite.set(0, forKey: ReturnLoopService.defaultsKeyPublishedTreeCount)
        let now = Date()
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: now)!
        suite.set(tenDaysAgo.timeIntervalSinceReferenceDate, forKey: ReturnLoopService.defaultsKeyLastSession)
        #expect(service.shouldShowWelcomeBack(now: now) == false)
    }

    @Test("Lapsed 5 days with published trees: surfaces welcome-back")
    func lapsedFiveDays() {
        let suite = makeSuite()
        suite.set(3, forKey: ReturnLoopService.defaultsKeyPublishedTreeCount)
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: now)!
        suite.set(fiveDaysAgo.timeIntervalSinceReferenceDate, forKey: ReturnLoopService.defaultsKeyLastSession)
        let service = ReturnLoopService(defaults: suite, calendar: calendar)
        #expect(service.shouldShowWelcomeBack(now: now) == true)
    }

    @Test("Lapsed 1 day with published trees: does NOT surface")
    func lapsedOneDay() {
        let suite = makeSuite()
        suite.set(3, forKey: ReturnLoopService.defaultsKeyPublishedTreeCount)
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: now)!
        suite.set(oneDayAgo.timeIntervalSinceReferenceDate, forKey: ReturnLoopService.defaultsKeyLastSession)
        let service = ReturnLoopService(defaults: suite, calendar: calendar)
        #expect(service.shouldShowWelcomeBack(now: now) == false)
    }

    @Test("Message for 1 published tree uses singular framing")
    func singleTreeMessage() {
        let suite = makeSuite()
        suite.set(1, forKey: ReturnLoopService.defaultsKeyPublishedTreeCount)
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let fourDaysAgo = calendar.date(byAdding: .day, value: -4, to: now)!
        suite.set(fourDaysAgo.timeIntervalSinceReferenceDate, forKey: ReturnLoopService.defaultsKeyLastSession)
        let service = ReturnLoopService(defaults: suite, calendar: calendar)
        let message = service.welcomeBackMessage(now: now)
        #expect(message.contains("first conversation"))
    }

    @Test("Message for 7+ day lapse uses 'week or more' framing")
    func weekLapseMessage() {
        let suite = makeSuite()
        suite.set(5, forKey: ReturnLoopService.defaultsKeyPublishedTreeCount)
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let eightDaysAgo = calendar.date(byAdding: .day, value: -8, to: now)!
        suite.set(eightDaysAgo.timeIntervalSinceReferenceDate, forKey: ReturnLoopService.defaultsKeyLastSession)
        let service = ReturnLoopService(defaults: suite, calendar: calendar)
        let message = service.welcomeBackMessage(now: now)
        #expect(message.lowercased().contains("week"))
    }
}
