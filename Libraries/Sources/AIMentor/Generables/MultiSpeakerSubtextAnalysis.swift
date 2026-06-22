import Foundation
import FoundationModels
import Models

/// Phase 2 multi-speaker subtext schema. When the dialogue tree has 3+
/// characters (triangle dynamics behind `dq.experiments.thirdCharacter`),
/// a single line carries DIFFERENT inferred subtexts depending on which
/// listener is meant to receive it.
///
/// Example: in a quiet-conflict triangle scene, Iris says "I'm fine."
/// - Cal (the friend Iris is comforting): reads it as "please don't ask"
/// - Bo (the bystander listening in): reads it as "she's not okay, but she's holding"
///
/// The 2-listener payload is the canonical Phase 2 shape — a 3-character
/// tree always has the SPEAKER + 2 other characters as candidate
/// listeners. The kid picks which listener interpretation matches their
/// authoring intent.
///
/// Property order matters per `.claude/rules/foundationmodels.md` — the
/// LLM generates in declaration order, so the surface text + speaker
/// metadata come first, then the per-listener subtexts.
@Generable
public struct MultiSpeakerSubtextAnalysis: Sendable, Codable, Hashable {
    @Guide(description: "Echo of the line as the kid wrote it. Keep punctuation verbatim.")
    public let surfaceText: String

    @Guide(description: "Display name of the speaker as a short string.")
    public let speakerName: String

    @Guide(description: "Display name of the first listener (the most likely intended recipient).")
    public let primaryListenerName: String

    @Guide(description: "What the speaker is implying for the PRIMARY listener — kid-readable, 1 sentence, no clinical jargon. Empty string when no clear subtext for this listener.")
    public let primaryListenerSubtext: String

    @Guide(description: "Display name of the second listener (the secondary witness or bystander).")
    public let secondaryListenerName: String

    @Guide(description: "What the speaker is implying for the SECONDARY listener — kid-readable, 1 sentence, no clinical jargon. Empty string when no clear subtext for this listener.")
    public let secondaryListenerSubtext: String

    @Guide(description: "How well the line matches the speaker's voice register, on a 0.0–1.0 scale. 1.0 = perfect match.")
    public let voiceMatchScore: Double

    public init(
        surfaceText: String,
        speakerName: String,
        primaryListenerName: String,
        primaryListenerSubtext: String,
        secondaryListenerName: String,
        secondaryListenerSubtext: String,
        voiceMatchScore: Double
    ) {
        self.surfaceText = surfaceText
        self.speakerName = speakerName
        self.primaryListenerName = primaryListenerName
        self.primaryListenerSubtext = primaryListenerSubtext
        self.secondaryListenerName = secondaryListenerName
        self.secondaryListenerSubtext = secondaryListenerSubtext
        self.voiceMatchScore = voiceMatchScore
    }

    /// Convenience: collapse the multi-speaker analysis into the canonical
    /// `DialogueLineAnalysis` shape so consumers that haven't been
    /// updated for the multi-listener surface (e.g., the Phase 1
    /// `SubtextPanelView` render path) can still consume the result.
    /// The collapsed `inferredSubtext` is the primary listener's read.
    public func toDialogueLineAnalysis() -> DialogueLineAnalysis {
        DialogueLineAnalysis(
            surfaceText: surfaceText,
            inferredSubtext: primaryListenerSubtext,
            voiceMatchScore: voiceMatchScore
        )
    }
}
