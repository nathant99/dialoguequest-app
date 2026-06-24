import Foundation
import Testing
import Models
@testable import Services

@MainActor
@Suite("PatterCallbackService — voice-pattern callback path")
struct PatterCallbackServiceVoicePatternTests {

    // MARK: - Suite helpers

    private func makeSuite() -> UserDefaults {
        let name = UUID().uuidString
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    private func makeService(suite: UserDefaults) -> PatterCallbackService {
        PatterCallbackService(defaults: suite)
    }

    private func makeHistoryService(suite: UserDefaults) -> VoicePatternHistoryService {
        VoicePatternHistoryService(defaults: suite)
    }

    private func makeCharacter(name: String) -> DialogueCharacterRef {
        DialogueCharacterRef(
            name: name,
            voiceRegister: "Test register for \(name).",
            sampleLines: ["First sample.", "Second sample."]
        )
    }

    /// Helper to seed the history service with a per-character window
    /// that satisfies `Trend.improving` (5 scores from 0.50 → 0.90,
    /// most-recent-first means latest=0.90, oldest=0.50, delta=+0.40
    /// >> 0.08 trendDelta).
    private func seedImprovingHistory(
        service: VoicePatternHistoryService,
        for characterID: UUID
    ) {
        for score in [0.50, 0.60, 0.70, 0.80, 0.90] {
            // recordPublishedTree only accepts a full VoiceSummary; we go
            // through the public recording surface so the rolling window
            // behaves the same way it would in production.
            let summary = WritingEvaluator.VoiceSummary(
                perCharacterAverage: [characterID: score],
                treeAverage: score,
                driftingLineIDs: []
            )
            service.recordPublishedTree(summary: summary)
        }
        // After 5 inserts most-recent-first, the order at the head of the
        // rolling window is [0.90, 0.80, 0.70, 0.60, 0.50]. Delta latest -
        // oldest = +0.40 → Trend.improving.
    }

    private func seedDriftingHistory(
        service: VoicePatternHistoryService,
        for characterID: UUID
    ) {
        for score in [0.90, 0.80, 0.70, 0.60, 0.45] {
            let summary = WritingEvaluator.VoiceSummary(
                perCharacterAverage: [characterID: score],
                treeAverage: score,
                driftingLineIDs: []
            )
            service.recordPublishedTree(summary: summary)
        }
        // Head after 5 inserts: [0.45, 0.60, 0.70, 0.80, 0.90]. Delta =
        // 0.45 - 0.90 = -0.45 → Trend.drifting.
    }

    private func seedSteadyHistory(
        service: VoicePatternHistoryService,
        for characterID: UUID
    ) {
        for score in [0.70, 0.72, 0.71, 0.73, 0.70] {
            let summary = WritingEvaluator.VoiceSummary(
                perCharacterAverage: [characterID: score],
                treeAverage: score,
                driftingLineIDs: []
            )
            service.recordPublishedTree(summary: summary)
        }
        // All values within ±0.04 → Trend.steady (delta < trendDelta 0.08).
    }

    private func makeTree(with characters: [DialogueCharacterRef]) -> DialogueTree {
        DialogueTree(
            id: UUID(),
            title: "Sample",
            characters: characters,
            nodes: [],
            rootNodeID: UUID()
        )
    }

    // MARK: - Below threshold

    @Test("Below minimumPublishedTreeCount: nextVoicePatternCallback returns nil")
    func belowMinimumPublishedSuppressesCallback() {
        let suite = makeSuite()
        suite.set(PatterCallbackService.minimumPublishedTreeCount - 1,
                  forKey: PatterCallbackService.defaultsKeyPublishedTreeCount)
        let service = makeService(suite: suite)
        let history = makeHistoryService(suite: suite)
        let brogue = makeCharacter(name: "Brogue")
        seedImprovingHistory(service: history, for: brogue.id)
        let tree = makeTree(with: [brogue])

        #expect(service.nextVoicePatternCallback(in: tree, historyService: history) == nil)
    }

    // MARK: - Per-trend gating

    @Test("Improving trend surfaces a celebratory line that names the character")
    func improvingTrendSurfacesCallback() throws {
        let suite = makeSuite()
        suite.set(PatterCallbackService.minimumPublishedTreeCount,
                  forKey: PatterCallbackService.defaultsKeyPublishedTreeCount)
        let service = makeService(suite: suite)
        let history = makeHistoryService(suite: suite)
        let brogue = makeCharacter(name: "Brogue")
        seedImprovingHistory(service: history, for: brogue.id)
        let tree = makeTree(with: [brogue])

        let line = try #require(service.nextVoicePatternCallback(in: tree, historyService: history))
        #expect(line.contains("Brogue"))
        #expect(line.contains("getting steadier"))
        #expect(line.contains("recognize"))
    }

    @Test("Drifting trend surfaces a warm invitation that names the character")
    func driftingTrendSurfacesCallback() throws {
        let suite = makeSuite()
        suite.set(PatterCallbackService.minimumPublishedTreeCount,
                  forKey: PatterCallbackService.defaultsKeyPublishedTreeCount)
        let service = makeService(suite: suite)
        let history = makeHistoryService(suite: suite)
        let glance = makeCharacter(name: "Glance")
        seedDriftingHistory(service: history, for: glance.id)
        let tree = makeTree(with: [glance])

        let line = try #require(service.nextVoicePatternCallback(in: tree, historyService: history))
        #expect(line.contains("Glance"))
        #expect(line.contains("drifted"))
        #expect(line.contains("MOST like"))
    }

    @Test("Steady trend yields no callback — no signal to call out")
    func steadyTrendYieldsNoCallback() {
        let suite = makeSuite()
        suite.set(PatterCallbackService.minimumPublishedTreeCount,
                  forKey: PatterCallbackService.defaultsKeyPublishedTreeCount)
        let service = makeService(suite: suite)
        let history = makeHistoryService(suite: suite)
        let rest = makeCharacter(name: "Rest")
        seedSteadyHistory(service: history, for: rest.id)
        let tree = makeTree(with: [rest])

        #expect(service.nextVoicePatternCallback(in: tree, historyService: history) == nil)
    }

    @Test("Insufficient history (< minimumRecordsForTrend): no callback")
    func insufficientHistoryYieldsNoCallback() {
        let suite = makeSuite()
        suite.set(PatterCallbackService.minimumPublishedTreeCount,
                  forKey: PatterCallbackService.defaultsKeyPublishedTreeCount)
        let service = makeService(suite: suite)
        let history = makeHistoryService(suite: suite)
        let sprig = makeCharacter(name: "Sprig")
        let summary = WritingEvaluator.VoiceSummary(
            perCharacterAverage: [sprig.id: 0.7],
            treeAverage: 0.7,
            driftingLineIDs: []
        )
        history.recordPublishedTree(summary: summary)
        let tree = makeTree(with: [sprig])

        #expect(service.nextVoicePatternCallback(in: tree, historyService: history) == nil)
    }

    // MARK: - Multi-character selection

    @Test("Multi-character tree: first character with a non-flat trend wins")
    func firstCharacterWithTrendWins() throws {
        let suite = makeSuite()
        suite.set(PatterCallbackService.minimumPublishedTreeCount,
                  forKey: PatterCallbackService.defaultsKeyPublishedTreeCount)
        let service = makeService(suite: suite)
        let history = makeHistoryService(suite: suite)
        let weigh = makeCharacter(name: "Weigh")
        let sprig = makeCharacter(name: "Sprig")
        // Weigh: steady → no signal
        seedSteadyHistory(service: history, for: weigh.id)
        // Sprig: improving → wins
        seedImprovingHistory(service: history, for: sprig.id)
        let tree = makeTree(with: [weigh, sprig])

        let line = try #require(service.nextVoicePatternCallback(in: tree, historyService: history))
        // Weigh is first in tree.characters but steady → skipped;
        // Sprig is second with .improving → wins.
        #expect(line.contains("Sprig"))
        #expect(!line.contains("Weigh"))
    }

    @Test("No characters have a non-flat trend: nil")
    func noTrendsYieldsNil() {
        let suite = makeSuite()
        suite.set(PatterCallbackService.minimumPublishedTreeCount,
                  forKey: PatterCallbackService.defaultsKeyPublishedTreeCount)
        let service = makeService(suite: suite)
        let history = makeHistoryService(suite: suite)
        let rest = makeCharacter(name: "Rest")
        let weigh = makeCharacter(name: "Weigh")
        seedSteadyHistory(service: history, for: rest.id)
        seedSteadyHistory(service: history, for: weigh.id)
        let tree = makeTree(with: [rest, weigh])

        #expect(service.nextVoicePatternCallback(in: tree, historyService: history) == nil)
    }

    // MARK: - Pure helper

    @Test(
        "voicePatternFeedback pure helper: per-trend rendering",
        arguments: zip(
            ["improving", "drifting", "steady", "insufficientData", "rocket-launch"],
            [true, true, false, false, false]
        )
    )
    func voicePatternFeedbackPerTrend(trendKey: String, shouldEmit: Bool) {
        let result = PatterCallbackService.voicePatternFeedback(
            trendKey: trendKey,
            characterName: "Brogue"
        )
        #expect((result != nil) == shouldEmit)
    }

    @Test("voicePatternFeedback empty name falls back to 'this character'")
    func voicePatternFeedbackEmptyName() throws {
        let bubble = try #require(PatterCallbackService.voicePatternFeedback(
            trendKey: "improving",
            characterName: ""
        ))
        #expect(bubble.observation.contains("this character"))
    }

    @Test("presentableCharacterName trims and falls back")
    func presentableCharacterName() {
        #expect(PatterCallbackService.presentableCharacterName("  Brogue  ") == "Brogue")
        #expect(PatterCallbackService.presentableCharacterName("") == "this character")
        #expect(PatterCallbackService.presentableCharacterName("   ") == "this character")
    }

    @Test("bubbleLine joins observation + nudge with a single space")
    func bubbleLineFormat() {
        let bubble = PatterCallbackService.VoicePatternBubble(
            observation: "A.",
            nudge: "B."
        )
        #expect(bubble.bubbleLine() == "A. B.")
    }

    // MARK: - Probability gate

    @Test("Voice-pattern probability default is 0.08 (same as mood callback)")
    func defaultProbability() {
        #expect(PatterCallbackService.defaultVoicePatternProbability == 0.08)
    }

    @Test("Voice-pattern probability boundaries collapse correctly")
    func probabilityBoundaries() {
        var rng = SystemRandomNumberGenerator()
        #expect(PatterCallbackService.shouldShowVoicePatternCallback(probability: 0.0, rng: &rng) == false)
        #expect(PatterCallbackService.shouldShowVoicePatternCallback(probability: 1.0, rng: &rng) == true)
    }

    // MARK: - Register stoplist

    @Test("Voice-pattern lines pass the chapter content register stoplist",
          arguments: ["improving", "drifting"])
    func registerStoplistClean(trendKey: String) throws {
        let bubble = try #require(PatterCallbackService.voicePatternFeedback(
            trendKey: trendKey,
            characterName: "Brogue"
        ))
        let combined = bubble.bubbleLine().lowercased()
        let banned = [
            "load-bearing", "codified", "canonical", "samhsa", "trauma-gated",
            "phase a", "phase b", "phase c", "phase d", "adr-",
            "embody the primitive", "distributed narrative",
            "anchoring phenomenon", "regression class"
        ]
        for token in banned {
            #expect(!combined.contains(token), "register leak '\(token)' in \(trendKey) line")
        }
    }
}
