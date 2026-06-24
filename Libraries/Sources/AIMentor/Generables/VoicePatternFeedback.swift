import Foundation
import FoundationModels

/// Coaching nudge surfaced when `VoicePatternHistoryService` detects a
/// trend in the kid's per-character voice consistency across the last
/// few published trees. Patter shares what she's noticed (`observation`)
/// and invites the kid into the next move (`nudge`) — a gentle "want to
/// try one more line in their voice?" on drift; a celebratory "their
/// voice is locking in" on improvement.
///
/// Surfaced through `PatterCallbackService.nextVoicePatternCallback(in:)`
/// which collapses the structured `observation` + `nudge` into a single
/// bubble line for `WriteTabView`'s mutually-exclusive Patter-bubble
/// slot. Property order matters per `.claude/rules/foundationmodels.md`
/// § Structured Output — `observation` first (what Patter saw), `nudge`
/// second (what the kid might try) so the LLM has the observed pattern
/// in context when it generates the nudge.
@Generable
public struct VoicePatternFeedback: Sendable, Codable, Hashable {
    @Guide(description: "What Patter noticed about the character's voice across recent trees. Kid-readable, no jargon, 1 sentence.")
    public let observation: String

    @Guide(description: "Gentle invitation for the kid's next move — celebratory on improvement, warm on drift. 1 sentence.")
    public let nudge: String

    public init(observation: String, nudge: String) {
        self.observation = observation
        self.nudge = nudge
    }

    /// Collapses the structured pair into the single-line shape the
    /// `rareVoiceCraftTip` MentorBubbleView slot consumes. Keeps the
    /// "Patter notices, then invites" rhythm without crowding the
    /// bubble. Pure function so call sites can render without an
    /// isolation hop.
    public nonisolated func bubbleLine() -> String {
        "\(observation) \(nudge)"
    }
}
