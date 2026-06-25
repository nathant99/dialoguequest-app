import Foundation
import Testing
import Models
@testable import Services

@MainActor
@Suite("PatterCallbackService")
struct PatterCallbackServiceTests {

    private func makeSuite() -> UserDefaults {
        let name = UUID().uuidString
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    @Test("Fresh service: no recent moods, no recent titles, no callback")
    func freshServiceHasNoHistory() {
        let suite = makeSuite()
        let service = PatterCallbackService(defaults: suite)
        #expect(service.recentMoods().isEmpty)
        #expect(service.recentTitles().isEmpty)
        #expect(service.nextCallback() == nil)
    }

    @Test("Recording a publish persists mood + title in most-recent-first order")
    func recordingPersistsMostRecentFirst() {
        let suite = makeSuite()
        let service = PatterCallbackService(defaults: suite)
        service.recordPublishedTree(mood: .quietConflict, title: "After the rain")
        service.recordPublishedTree(mood: .warmReunion, title: "Cousin Day")
        let moods = service.recentMoods()
        let titles = service.recentTitles()
        #expect(moods == [.warmReunion, .quietConflict])
        #expect(titles == ["Cousin Day", "After the rain"])
    }

    @Test("Rolling window caps at PatterCallbackService.historyWindow slots")
    func rollingWindowTrims() {
        let suite = makeSuite()
        let service = PatterCallbackService(defaults: suite)
        service.recordPublishedTree(mood: .openingCuriosity, title: "First")
        service.recordPublishedTree(mood: .playfulRivalry, title: "Second")
        service.recordPublishedTree(mood: .warmReunion, title: "Third")
        service.recordPublishedTree(mood: .awkwardSilence, title: "Fourth")
        let moods = service.recentMoods()
        let titles = service.recentTitles()
        #expect(moods.count == PatterCallbackService.historyWindow)
        #expect(moods == [.awkwardSilence, .warmReunion, .playfulRivalry])
        #expect(titles == ["Fourth", "Third", "Second"])
    }

    @Test("Below minimumPublishedTreeCount: nextCallback returns nil")
    func belowMinimumPublishedSuppressesCallback() {
        let suite = makeSuite()
        suite.set(2, forKey: PatterCallbackService.defaultsKeyPublishedTreeCount)
        let service = PatterCallbackService(defaults: suite)
        service.recordPublishedTree(mood: .warmReunion, title: "Sample")
        #expect(service.nextCallback() == nil)
    }

    @Test("At minimumPublishedTreeCount with history: nextCallback returns a kid-friendly line")
    func atMinimumPublishedSurfacesCallback() throws {
        let suite = makeSuite()
        suite.set(PatterCallbackService.minimumPublishedTreeCount,
                  forKey: PatterCallbackService.defaultsKeyPublishedTreeCount)
        let service = PatterCallbackService(defaults: suite)
        service.recordPublishedTree(mood: .quietConflict, title: "After the rain")
        let callback = try #require(service.nextCallback())
        #expect(callback.contains("\u{201C}After the rain\u{201D}"))
        #expect(callback.contains("quiet conflict"))
        #expect(callback.contains("Patter"))
    }

    @Test("Empty title falls back to 'your last conversation'")
    func emptyTitleFallsBack() throws {
        let suite = makeSuite()
        suite.set(PatterCallbackService.minimumPublishedTreeCount,
                  forKey: PatterCallbackService.defaultsKeyPublishedTreeCount)
        let service = PatterCallbackService(defaults: suite)
        service.recordPublishedTree(mood: .warmReunion, title: "   ")
        let callback = try #require(service.nextCallback())
        #expect(callback.contains("your last conversation"))
        #expect(!callback.contains("\u{201C}\u{201D}"))
    }

    @Test("Every DialogueMood maps to a non-empty kid-readable line")
    func everyMoodMapsToALine() {
        for mood in DialogueMood.allCases {
            let line = PatterCallbackService.callbackLine(mood: mood, title: "Sample")
            #expect(!line.isEmpty, "Mood \(mood) produced empty callback line")
            #expect(line.lowercased().contains("patter"),
                    "Mood \(mood) line missing Patter attribution: \(line)")
        }
    }

    @Test("Reset wipes the rolling history")
    func resetClearsHistory() {
        let suite = makeSuite()
        let service = PatterCallbackService(defaults: suite)
        service.recordPublishedTree(mood: .warmReunion, title: "Sample")
        service.reset()
        #expect(service.recentMoods().isEmpty)
        #expect(service.recentTitles().isEmpty)
    }

    @Test("Boundary probabilities collapse correctly")
    func shouldShowCallbackBoundaries() {
        var rng = SystemRandomNumberGenerator()
        #expect(PatterCallbackService.shouldShowCallback(probability: 0.0, rng: &rng) == false)
        #expect(PatterCallbackService.shouldShowCallback(probability: 1.0, rng: &rng) == true)
    }

    @Test("Default probability is rarer than VariableReward and cameo")
    func defaultProbabilityIsRarest() {
        // Callback (0.08) < cameo (0.12) < variable-reward (0.20). The
        // mutually-exclusive wiring in WriteTabView assumes this order.
        #expect(PatterCallbackService.defaultProbability == 0.08)
        #expect(PatterCallbackService.defaultProbability < 0.12)
        #expect(PatterCallbackService.defaultProbability < 0.20)
    }

    /// Register-stoplist guard mirroring the cameo + chapter-content
    /// stoplist. Every emitted callback line MUST pass age-9-14 reader
    /// register per `.claude/rules/distributed-narrative.md`
    /// § R-CHAPTER-REGISTER.
    @Test("Every callback line passes the chapter register stoplist")
    func everyLinePassesStoplist() {
        let stoplistTokens: [String] = [
            "load-bearing", "soft-collision", "hard-collision",
            "single source of truth", "codified", "codify",
            "superseded by", "graduation criteria", "kill criteria",
            "regression class", "canonical", "downstream", "upstream",
            "first-class", "in-band", "out-of-band", "gating", "ungated",
            "ADR-", "(per ADR-", "per ADR-", "per user-direct",
            "Phase A", "Phase B", "Phase C", "Phase D",
            "R0 reviewer", "PR #", "SHIPPED", "MERGED",
            "WIP", "TODO", "in-flight", "Round ",
            "SAMHSA", "TIP 57", "validate-then-inform",
            "trauma-gated", "hold-space", "refer-up", "off-ramp",
            "embody the primitive", "the cast IS the curriculum",
            "distributed-narrative", "anchoring phenomena",
            "anchoring phenomenon", "curricular primitive"
        ]
        for mood in DialogueMood.allCases {
            let line = PatterCallbackService.callbackLine(mood: mood, title: "After the rain")
            let lowercase = line.lowercased()
            for token in stoplistTokens {
                #expect(
                    !lowercase.contains(token.lowercased()),
                    "Callback line '\(line)' contains forbidden register token '\(token)'"
                )
            }
        }
    }

    // MARK: - Corrupt-data fallback (DebugLog wiring; Priority K)

    @Test("Corrupt mood data falls back to empty history without crash")
    func corruptMoodDataFallsBackEmpty() {
        let suite = makeSuite()
        // Write garbage bytes under the canonical key. The decode path must
        // log the failure (via DialogueQuestDebugLog.data, debug-only) and
        // return [] so callers stay on the safe-empty path.
        let garbage = Data([0xFF, 0xFE, 0xFD, 0x00, 0x01])
        suite.set(garbage, forKey: PatterCallbackService.defaultsKeyRecentMoods)
        let service = PatterCallbackService(defaults: suite)
        #expect(service.recentMoods().isEmpty)
    }

    @Test("Corrupt title data falls back to empty history without crash")
    func corruptTitleDataFallsBackEmpty() {
        let suite = makeSuite()
        let garbage = Data([0xFF, 0xFE, 0xFD, 0x00, 0x01])
        suite.set(garbage, forKey: PatterCallbackService.defaultsKeyRecentTitles)
        let service = PatterCallbackService(defaults: suite)
        #expect(service.recentTitles().isEmpty)
    }

    @Test("After corrupt fallback, recording a new publish overwrites the garbage cleanly")
    func corruptFallbackThenRecordHeals() {
        let suite = makeSuite()
        let garbage = Data([0xFF, 0xFE, 0xFD, 0x00, 0x01])
        suite.set(garbage, forKey: PatterCallbackService.defaultsKeyRecentMoods)
        suite.set(garbage, forKey: PatterCallbackService.defaultsKeyRecentTitles)
        let service = PatterCallbackService(defaults: suite)
        service.recordPublishedTree(mood: .warmReunion, title: "Healed")
        #expect(service.recentMoods() == [.warmReunion])
        #expect(service.recentTitles() == ["Healed"])
    }
}
