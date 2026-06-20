import Foundation

/// How a dialogue line is attributed to its speaker.
///
/// Tag balance is one of DialogueQuest's four core craft metrics — kids
/// learn that good dialogue varies attribution rather than ending every
/// line with `"X said"`.
public nonisolated enum DialogueTag: Sendable, Hashable, Codable {
    /// Canonical attribution (`"Hello," she said.`). The associated value
    /// is the verb phrase (typically `"said"` but may be `"murmured"` /
    /// `"called"` / `"whispered"` etc.).
    case said(String)

    /// A descriptive beat that attributes the line via action
    /// (`Iris closed the book. "We're done."`). The associated value
    /// is the beat description.
    case action(String)

    /// A bare quotation with no attribution. Powerful when used sparingly;
    /// over-used it produces unattributed-line ambiguity.
    case unattributed

    private enum CodingKeys: String, CodingKey { case kind, payload }
    private enum Kind: String, Codable { case said, action, unattributed }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .said:
            let verb = try container.decode(String.self, forKey: .payload)
            self = .said(verb)
        case .action:
            let beat = try container.decode(String.self, forKey: .payload)
            self = .action(beat)
        case .unattributed:
            self = .unattributed
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .said(let verb):
            try container.encode(Kind.said, forKey: .kind)
            try container.encode(verb, forKey: .payload)
        case .action(let beat):
            try container.encode(Kind.action, forKey: .kind)
            try container.encode(beat, forKey: .payload)
        case .unattributed:
            try container.encode(Kind.unattributed, forKey: .kind)
        }
    }

    /// Classification used by `TagBalancer` to detect over-reliance on any
    /// single attribution shape.
    public var classification: Classification {
        switch self {
        case .said: return .saidVerb
        case .action: return .actionBeat
        case .unattributed: return .unattributed
        }
    }

    public enum Classification: String, Codable, Sendable, CaseIterable {
        case saidVerb
        case actionBeat
        case unattributed
    }
}
