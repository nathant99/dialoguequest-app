import Foundation
import Testing
@testable import AIMentor

@Suite("VoicePatternFeedback fallback — trend → register-clean coaching pair")
struct VoicePatternFeedbackFallbackTests {

    // MARK: - Trend coverage

    @Test("Improving trend produces a celebratory observation + nudge")
    func improvingTrendFiresCelebration() throws {
        let feedback = try #require(PatterFallbacks.voicePatternFeedbackFallback(
            trendKey: "improving",
            characterName: "Brogue"
        ))
        #expect(feedback.observation.contains("Brogue"))
        #expect(feedback.observation.contains("getting steadier"))
        #expect(feedback.nudge.contains("Brogue"))
        #expect(feedback.nudge.contains("recognize"))
    }

    @Test("Drifting trend produces a warm invitation to anchor the voice")
    func driftingTrendFiresGentleNudge() throws {
        let feedback = try #require(PatterFallbacks.voicePatternFeedbackFallback(
            trendKey: "drifting",
            characterName: "Glance"
        ))
        #expect(feedback.observation.contains("Glance"))
        #expect(feedback.observation.contains("drifted"))
        #expect(feedback.nudge.contains("Glance"))
        #expect(feedback.nudge.contains("MOST like"))
    }

    @Test("Steady trend returns nil — no callback when there's no signal")
    func steadyTrendIsNil() {
        let feedback = PatterFallbacks.voicePatternFeedbackFallback(
            trendKey: "steady",
            characterName: "Rest"
        )
        #expect(feedback == nil)
    }

    @Test("Insufficient-data trend returns nil — Patter waits for more publishes")
    func insufficientDataIsNil() {
        let feedback = PatterFallbacks.voicePatternFeedbackFallback(
            trendKey: "insufficientData",
            characterName: "Sprig"
        )
        #expect(feedback == nil)
    }

    @Test("Unknown trend key returns nil — defensive")
    func unknownTrendKeyIsNil() {
        let feedback = PatterFallbacks.voicePatternFeedbackFallback(
            trendKey: "rocket-launch",
            characterName: "Weigh"
        )
        #expect(feedback == nil)
    }

    // MARK: - Character name presentation

    @Test("Empty character name falls back to 'this character' so the line reads naturally")
    func emptyNameFallsBack() throws {
        let feedback = try #require(PatterFallbacks.voicePatternFeedbackFallback(
            trendKey: "improving",
            characterName: ""
        ))
        #expect(feedback.observation.contains("this character"))
        #expect(!feedback.observation.contains("'s voice has been getting steadier across") || feedback.observation.contains("this character's"))
    }

    @Test("Whitespace-only character name trimmed and falls back to 'this character'")
    func whitespaceNameFallsBack() throws {
        let feedback = try #require(PatterFallbacks.voicePatternFeedbackFallback(
            trendKey: "drifting",
            characterName: "   "
        ))
        #expect(feedback.observation.contains("this character"))
    }

    @Test("presentableCharacterName trims surrounding whitespace")
    func nameIsTrimmed() {
        #expect(PatterFallbacks.presentableCharacterName("  Brogue  ") == "Brogue")
        #expect(PatterFallbacks.presentableCharacterName("Glance") == "Glance")
        #expect(PatterFallbacks.presentableCharacterName("") == "this character")
    }

    // MARK: - Register stoplist (per .claude/rules/distributed-narrative.md § R-CHAPTER-REGISTER)

    @Test(
        "Register stoplist — neither observation nor nudge leaks engineering / project-mgmt / reviewer-framework jargon",
        arguments: ["improving", "drifting"]
    )
    func registerStoplistClean(trendKey: String) throws {
        let feedback = try #require(PatterFallbacks.voicePatternFeedbackFallback(
            trendKey: trendKey,
            characterName: "Brogue"
        ))
        let combined = (feedback.observation + " " + feedback.nudge).lowercased()
        let banned = [
            "load-bearing", "codified", "canonical", "samhsa", "trauma-gated",
            "phase a", "phase b", "phase c", "phase d", "adr-", "primitive",
            "anchoring phenomenon", "distributed narrative", "regression"
        ]
        for token in banned {
            #expect(!combined.contains(token), "register stoplist leak: '\(token)' in \(trendKey) line")
        }
    }

    // MARK: - bubbleLine collapse

    @Test("bubbleLine joins observation + nudge with a single space")
    func bubbleLineCollapsesPair() {
        let feedback = VoicePatternFeedback(
            observation: "Brogue's voice has been getting steadier across your last few conversations.",
            nudge: "Patter is starting to recognize Brogue before you tag the line."
        )
        let line = feedback.bubbleLine()
        #expect(line == "\(feedback.observation) \(feedback.nudge)")
        #expect(!line.contains("  "))  // no double-space
    }

    @Test("VoicePatternFeedback round-trips through Codable")
    func codableRoundTrip() throws {
        let original = VoicePatternFeedback(
            observation: "Glance's voice has drifted a little.",
            nudge: "Want to try one line where Glance sounds the MOST like Glance?"
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(VoicePatternFeedback.self, from: data)
        #expect(decoded == original)
    }
}
