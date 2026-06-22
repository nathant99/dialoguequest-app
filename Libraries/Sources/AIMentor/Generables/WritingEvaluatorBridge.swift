import Foundation
import Models

/// Bridge between AI-mentor `@Generable` types and the cross-cluster
/// `WritingEvaluator.VoiceCheck` shape.
///
/// Consumers (Patter mentor reaction surfaces, parent dashboard, etc.)
/// should prefer the bridged `WritingEvaluator.VoiceCheck` so the
/// downstream code path is identical whether the score came from the
/// deterministic Jaccard baseline (`VoiceConsistencyAnalyzer`) or the
/// FoundationModels-backed `DialogueLineAnalysis`.
public extension DialogueLineAnalysis {

    /// Project the AI mentor's analysis into a `WritingEvaluator.VoiceCheck`.
    /// `lineID` and `speakerID` are passed through from the call site
    /// (they're not part of the @Generable schema since the LLM
    /// shouldn't invent them).
    nonisolated func toVoiceCheck(
        lineID: UUID,
        speakerID: UUID?
    ) -> WritingEvaluator.VoiceCheck {
        WritingEvaluator.VoiceCheck(
            id: lineID,
            speakerID: speakerID,
            surfaceText: surfaceText,
            voiceMatchScore: voiceMatchScore
        )
    }
}
