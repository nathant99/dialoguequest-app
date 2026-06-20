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

    public init(
        id: UUID = UUID(),
        name: String,
        voiceRegister: String,
        sampleLines: [String]
    ) {
        self.id = id
        self.name = name
        self.voiceRegister = voiceRegister
        self.sampleLines = sampleLines
    }
}
