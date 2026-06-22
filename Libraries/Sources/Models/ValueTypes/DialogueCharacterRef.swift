import Foundation

/// A named speaker in a `DialogueTree`. In Phase 1 these are authored
/// locally inside DialogueQuest; Phase 2 will accept refs imported from
/// CharacterForge via the shared `CharacterRef` schema.
public nonisolated struct DialogueCharacterRef: Codable, Sendable, Hashable, Identifiable {
    public let id: UUID
    public let name: String
    /// 1-paragraph voice description guiding the AI mentor's voice-match
    /// scoring (e.g., "speaks in short clipped sentences; never apologizes
    /// directly; uses 'I guess' when she's actually sure").
    public let voiceRegister: String
    /// 3-5 sample lines that anchor the per-character voice baseline used
    /// by `VoiceConsistencyAnalyzer`. Shorter is better.
    public let sampleLines: [String]
    /// Phase 2 archetype guidance (`.unspecified` keeps Phase 1 trees
    /// behavior-equivalent). `TriangleDynamics` uses the role assignment
    /// to classify triangle patterns (alliance / jealousy / arbitration)
    /// when 3 characters share a tree.
    public let role: DialogueCharacterRole

    public init(
        id: UUID = UUID(),
        name: String,
        voiceRegister: String,
        sampleLines: [String],
        role: DialogueCharacterRole = .unspecified
    ) {
        self.id = id
        self.name = name
        self.voiceRegister = voiceRegister
        self.sampleLines = sampleLines
        self.role = role
    }

    // Backwards-compatible Codable decoding: trees authored on Phase 1
    // omit the role field; decode them as `.unspecified` without churn.
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case voiceRegister
        case sampleLines
        case role
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.voiceRegister = try container.decode(String.self, forKey: .voiceRegister)
        self.sampleLines = try container.decode([String].self, forKey: .sampleLines)
        self.role = try container.decodeIfPresent(DialogueCharacterRole.self, forKey: .role) ?? .unspecified
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(voiceRegister, forKey: .voiceRegister)
        try container.encode(sampleLines, forKey: .sampleLines)
        try container.encode(role, forKey: .role)
    }
}

/// Phase 2 archetype assigned to a `DialogueCharacterRef`. Drives
/// `TriangleDynamics` classification when three characters share a tree.
/// `.unspecified` is the default — Phase 1 two-character trees do not
/// need archetypes; the role surfaces only when the kid opts in to the
/// triangle authoring path (gated by `dq.experiments.thirdCharacter`).
public nonisolated enum DialogueCharacterRole: String, Codable, Sendable, Hashable, CaseIterable {
    /// Drives the central question of the scene. Their wants set the
    /// stakes; the other characters react to them.
    case protagonist
    /// Pushes against the protagonist's want. Doesn't have to be a villain
    /// — could be a parent, a coach, a best friend with a different read.
    case antagonist
    /// Holds the protagonist's secret. Lower stakes than the antagonist;
    /// the confidant tells the truth nobody else will.
    case confidant
    /// Steps between the other two when their conflict crosses a line.
    /// Often the late-arriving third voice in arbitration triangles.
    case arbiter
    /// No archetype claim. Phase 1 default + Phase 2 escape hatch when the
    /// kid doesn't want to commit to a role yet.
    case unspecified

    public var displayName: String {
        switch self {
        case .protagonist: "Protagonist"
        case .antagonist: "Antagonist"
        case .confidant: "Confidant"
        case .arbiter: "Arbiter"
        case .unspecified: "Unspecified"
        }
    }

    /// Short coaching line shown when the kid taps the role picker.
    public var coachingHint: String {
        switch self {
        case .protagonist: "Whose want drives this conversation?"
        case .antagonist: "Who pushes against the protagonist — not a villain, just a different read."
        case .confidant: "Who holds the protagonist's secret? Who tells the truth nobody else will?"
        case .arbiter: "Who steps in when the conflict crosses a line?"
        case .unspecified: "Skip role-tagging for now — you can add it later."
        }
    }
}
