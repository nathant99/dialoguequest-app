import Foundation
import Testing
@testable import AIMentor
@testable import Models

@Suite("PatterFallbacks — every @Generable has a deterministic static path")
struct PatterFallbacksTests {

    // MARK: - DialogueLineAnalysis

    @Test("Line-analysis fallback echoes surface text verbatim")
    func lineAnalysisEchoesSurfaceText() {
        let analysis = PatterFallbacks.lineAnalysisFallback(
            for: "Hey, you came back.",
            mood: .warmReunion
        )
        #expect(analysis.surfaceText == "Hey, you came back.")
    }

    @Test(
        "Each mood maps to a distinct subtext line",
        arguments: zip(
            [DialogueMood.warmReunion, .quietConflict, .playfulRivalry, .awkwardSilence, .openingCuriosity],
            [
                "There's relief here. They've been holding this in.",
                "The words are gentle but the feelings are loud.",
                "They're testing how far they can go without breaking the joke.",
                "Something they almost said is staying unsaid.",
                "They're feeling out the shape of the conversation."
            ]
        )
    )
    func lineAnalysisFallbackPerMood(mood: DialogueMood, expected: String) {
        let analysis = PatterFallbacks.lineAnalysisFallback(for: "x", mood: mood)
        #expect(analysis.inferredSubtext == expected)
    }

    @Test("Nil mood produces empty subtext (no jargon-y guess)")
    func lineAnalysisNilMoodIsEmpty() {
        let analysis = PatterFallbacks.lineAnalysisFallback(for: "x", mood: nil)
        #expect(analysis.inferredSubtext.isEmpty)
    }

    @Test("Voice-match score is within the documented 0.0...1.0 range")
    func lineAnalysisScoreInRange() {
        let analysis = PatterFallbacks.lineAnalysisFallback(for: "x", mood: .quietConflict)
        #expect(analysis.voiceMatchScore >= 0.0)
        #expect(analysis.voiceMatchScore <= 1.0)
    }

    // MARK: - BranchMeaningfulnessCheck

    @Test(
        "Branch-check fallback ships three non-empty questions per mood",
        arguments: [DialogueMood.warmReunion, .quietConflict, .playfulRivalry, .awkwardSilence, .openingCuriosity] as [DialogueMood]
    )
    func branchCheckHasThreeQuestions(mood: DialogueMood) {
        let check = PatterFallbacks.branchCheckFallback(for: mood)
        #expect(!check.question1.isEmpty)
        #expect(!check.question2.isEmpty)
        #expect(!check.question3.isEmpty)
    }

    @Test("Nil mood falls back to the openingCuriosity question set")
    func branchCheckNilMatchesOpeningCuriosity() {
        let nilCase = PatterFallbacks.branchCheckFallback(for: nil)
        let opener = PatterFallbacks.branchCheckFallback(for: .openingCuriosity)
        #expect(nilCase == opener)
    }

    @Test("Distinct moods produce distinct question sets")
    func branchCheckMoodsAreDistinct() {
        let warm = PatterFallbacks.branchCheckFallback(for: .warmReunion)
        let conflict = PatterFallbacks.branchCheckFallback(for: .quietConflict)
        #expect(warm != conflict)
    }

    // MARK: - TagBalanceTip

    @Test(
        "Each classification yields a non-empty observation + suggestion",
        arguments: [DialogueTag.Classification.saidVerb, .actionBeat, .unattributed] as [DialogueTag.Classification]
    )
    func tagBalanceHasObservationAndSuggestion(classification: DialogueTag.Classification) {
        let tip = PatterFallbacks.tagBalanceFallback(dominant: classification)
        #expect(!tip.observation.isEmpty)
        #expect(!tip.suggestion.isEmpty)
    }

    @Test("Distinct classifications produce distinct tips")
    func tagBalanceClassificationsAreDistinct() {
        let said = PatterFallbacks.tagBalanceFallback(dominant: .saidVerb)
        let action = PatterFallbacks.tagBalanceFallback(dominant: .actionBeat)
        let untagged = PatterFallbacks.tagBalanceFallback(dominant: .unattributed)
        #expect(said != action)
        #expect(action != untagged)
        #expect(said != untagged)
    }
}
