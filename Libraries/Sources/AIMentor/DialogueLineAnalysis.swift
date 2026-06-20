import Foundation
import FoundationModels
import Models

/// FoundationModels structured-output schema for the subtext detector.
///
/// Property order matters per `.claude/rules/foundationmodels.md` — the
/// LLM generates fields in declaration order, so dependencies come
/// first: `surfaceText` → `inferredSubtext` → `voiceMatchScore`.
@Generable
public struct DialogueLineAnalysis: Sendable, Codable, Hashable {
    @Guide(description: "Echo of the line as the kid wrote it. Keep punctuation verbatim.")
    public let surfaceText: String

    @Guide(description: "What the character is implying without saying — kid-readable, 1 sentence, no clinical jargon. Empty string when no clear subtext.")
    public let inferredSubtext: String

    @Guide(description: "How well the line matches the speaker's voice register, on a 0.0–1.0 scale. 1.0 = perfect match.")
    public let voiceMatchScore: Double

    public init(surfaceText: String, inferredSubtext: String, voiceMatchScore: Double) {
        self.surfaceText = surfaceText
        self.inferredSubtext = inferredSubtext
        self.voiceMatchScore = voiceMatchScore
    }
}
