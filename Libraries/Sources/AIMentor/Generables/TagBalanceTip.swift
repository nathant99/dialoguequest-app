import Foundation
import FoundationModels

/// Coaching nudge surfaced when `TagBalancer` detects attribution-rhythm
/// imbalance (e.g., 8 of 10 lines end with `"said"`). The observation +
/// suggestion pair lets the kid see the pattern AND have a low-stakes
/// alternative to try.
@Generable
public struct TagBalanceTip: Sendable, Codable, Hashable {
    @Guide(description: "What pattern Patter noticed in the dialogue. Kid-readable, no jargon, 1 sentence.")
    public let observation: String

    @Guide(description: "One concrete alternative the kid could try. Specific, never prescriptive.")
    public let suggestion: String

    public init(observation: String, suggestion: String) {
        self.observation = observation
        self.suggestion = suggestion
    }
}
