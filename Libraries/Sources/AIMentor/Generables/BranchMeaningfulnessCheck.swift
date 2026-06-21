import Foundation
import FoundationModels

/// Socratic 3-question prompt fired at every branch point in a
/// `DialogueTree`. The kid answers in their own words; Patter never
/// evaluates the answer as right/wrong — the act of articulating IS
/// the learning.
@Generable
public struct BranchMeaningfulnessCheck: Sendable, Codable, Hashable {
    @Guide(description: "First Socratic question. Anchors the choice in stakes: what does the speaker risk by branching this way?")
    public let question1: String

    @Guide(description: "Second Socratic question. Anchors the choice in character: what does each branch reveal about who's speaking?")
    public let question2: String

    @Guide(description: "Third Socratic question. Anchors the choice in consequence: how does each branch change what happens next?")
    public let question3: String

    public init(question1: String, question2: String, question3: String) {
        self.question1 = question1
        self.question2 = question2
        self.question3 = question3
    }
}
