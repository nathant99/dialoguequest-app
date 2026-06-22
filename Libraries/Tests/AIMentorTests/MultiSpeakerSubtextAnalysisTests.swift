import Foundation
import Testing
import Models
@testable import AIMentor

/// Phase 2 multi-speaker (triangle-path) subtext schema. Tests cover the
/// fallback dictionary for all 5 `DialogueMood` cases + nil, the
/// `toDialogueLineAnalysis()` collapse for Phase 1 consumers, and the
/// init contract.
@Suite("MultiSpeakerSubtextAnalysis")
struct MultiSpeakerSubtextAnalysisTests {

    // MARK: - Fallback shape

    @Test func quietConflictFallbackProducesNonEmptyDualSubtext() {
        let analysis = PatterFallbacks.multiSpeakerSubtextFallback(
            for: "I'm fine.",
            speakerName: "Iris",
            primaryListenerName: "Cal",
            secondaryListenerName: "Bo",
            mood: .quietConflict
        )
        #expect(analysis.surfaceText == "I'm fine.")
        #expect(analysis.speakerName == "Iris")
        #expect(analysis.primaryListenerName == "Cal")
        #expect(analysis.secondaryListenerName == "Bo")
        #expect(!analysis.primaryListenerSubtext.isEmpty)
        #expect(!analysis.secondaryListenerSubtext.isEmpty)
        // Listeners must read the SAME line differently — that's the
        // whole point of the multi-listener surface.
        #expect(analysis.primaryListenerSubtext != analysis.secondaryListenerSubtext)
    }

    @Test func warmReunionFallbackProducesReliefSubtext() {
        let analysis = PatterFallbacks.multiSpeakerSubtextFallback(
            for: "Hey.",
            speakerName: "Sprig",
            primaryListenerName: "Glance",
            secondaryListenerName: "Rest",
            mood: .warmReunion
        )
        let combined = (analysis.primaryListenerSubtext + " " + analysis.secondaryListenerSubtext).lowercased()
        #expect(combined.contains("true") || combined.contains("relief"))
    }

    @Test func nilMoodFallbackProducesEmptySubtextPair() {
        let analysis = PatterFallbacks.multiSpeakerSubtextFallback(
            for: "Maybe.",
            speakerName: "Lex",
            primaryListenerName: "Mar",
            secondaryListenerName: "Tio",
            mood: nil
        )
        #expect(analysis.primaryListenerSubtext.isEmpty)
        #expect(analysis.secondaryListenerSubtext.isEmpty)
    }

    @Test func everyMoodProducesNonEmptyPair() {
        for mood in DialogueMood.allCases {
            let analysis = PatterFallbacks.multiSpeakerSubtextFallback(
                for: "Anything.",
                speakerName: "A",
                primaryListenerName: "B",
                secondaryListenerName: "C",
                mood: mood
            )
            #expect(!analysis.primaryListenerSubtext.isEmpty, "mood \(mood) produced empty primary")
            #expect(!analysis.secondaryListenerSubtext.isEmpty, "mood \(mood) produced empty secondary")
        }
    }

    // MARK: - Collapse to Phase 1 shape

    @Test func collapseRetainsPrimaryListenerSubtextAsCanonical() {
        let analysis = MultiSpeakerSubtextAnalysis(
            surfaceText: "Stay.",
            speakerName: "Iris",
            primaryListenerName: "Cal",
            primaryListenerSubtext: "Please don't leave me with this.",
            secondaryListenerName: "Bo",
            secondaryListenerSubtext: "She means it this time.",
            voiceMatchScore: 0.82
        )
        let collapsed = analysis.toDialogueLineAnalysis()
        #expect(collapsed.surfaceText == "Stay.")
        #expect(collapsed.inferredSubtext == "Please don't leave me with this.")
        #expect(collapsed.voiceMatchScore == 0.82)
    }

    @Test func collapseFromFallbackRoundTrips() {
        let multi = PatterFallbacks.multiSpeakerSubtextFallback(
            for: "I noticed.",
            speakerName: "Glance",
            primaryListenerName: "Sprig",
            secondaryListenerName: "Brogue",
            mood: .openingCuriosity
        )
        let collapsed = multi.toDialogueLineAnalysis()
        #expect(collapsed.surfaceText == "I noticed.")
        #expect(collapsed.inferredSubtext == multi.primaryListenerSubtext)
        #expect(collapsed.voiceMatchScore == multi.voiceMatchScore)
    }

    // MARK: - Voice match clamp expectations

    @Test func fallbackVoiceMatchScoreIsClampedSensible() {
        let analysis = PatterFallbacks.multiSpeakerSubtextFallback(
            for: "Whatever.",
            speakerName: "Y",
            primaryListenerName: "Z",
            secondaryListenerName: "W",
            mood: .playfulRivalry
        )
        #expect(analysis.voiceMatchScore >= 0.0)
        #expect(analysis.voiceMatchScore <= 1.0)
    }
}
