import Foundation

/// Portable schema for a CharacterForge-authored cast. CharacterForge
/// (writing-craft cluster sibling app) exports named characters with
/// voice registers + sample lines; DialogueQuest imports them into a
/// `DialogueTree` via `CharacterForgeImportService`.
///
/// **Phase 2 first cut**: the import surface is clipboard-JSON paste.
/// A future ForgeSync-bridged path (auto-discover CharacterForge's
/// AppGroupStore exports) lands when the bridge is wired.
///
/// **Cross-cluster schema discipline**: the manifest mirrors the canonical
/// `WritingEvaluator.VoiceCheck` shape per the writing-craft cluster
/// agreement (Open Question #5 in TECHNICAL_DESIGN, resolved YES). Every
/// `Character` carries `voiceRegister` + `sampleLines` so the importer
/// can drop directly into `DialogueCharacterRef` without lossy reshape.
public nonisolated struct CharacterForgeManifest: Codable, Sendable, Equatable {

    /// Schema version. Pinned at 1 for the Phase-2 first cut; bump when
    /// the wire format changes incompatibly. The importer rejects unknown
    /// versions.
    public let schemaVersion: Int

    /// Source app that produced the manifest. Conventional value
    /// `"characterforge"`. Used as a soft validity signal at import time.
    public let sourceApp: String

    /// Optional human-readable cast name (e.g., "After the Rain — main 3").
    public let castName: String?

    /// Ordered character list. The importer caps the consumed count at
    /// `DialogueTree.maxCharactersForImport` (3 for Phase 2 triangle
    /// dialogues; trees expecting 2 characters take the first 2).
    public let characters: [Character]

    public init(
        schemaVersion: Int = 1,
        sourceApp: String = "characterforge",
        castName: String? = nil,
        characters: [Character]
    ) {
        self.schemaVersion = schemaVersion
        self.sourceApp = sourceApp
        self.castName = castName
        self.characters = characters
    }

    /// A single imported character — a thin projection of CharacterForge's
    /// character editor onto the shape `DialogueCharacterRef` consumes.
    public nonisolated struct Character: Codable, Sendable, Equatable, Identifiable {
        public let id: UUID
        public let name: String
        public let voiceRegister: String
        public let sampleLines: [String]
        /// Optional archetype hint. `nil` decodes to `.unspecified` on
        /// the consuming `DialogueCharacterRef`, preserving Phase 1
        /// behavior when the manifest omits roles.
        public let role: DialogueCharacterRole?

        public init(
            id: UUID = UUID(),
            name: String,
            voiceRegister: String,
            sampleLines: [String],
            role: DialogueCharacterRole? = nil
        ) {
            self.id = id
            self.name = name
            self.voiceRegister = voiceRegister
            self.sampleLines = sampleLines
            self.role = role
        }
    }
}

/// Import-side hard caps and constants. Lives here (not in
/// `CharacterForgeImportService`) so the limits are visible to any
/// future producer that consults the schema.
public nonisolated enum CharacterForgeImportLimits {
    /// Maximum characters the importer consumes from a manifest. Phase 2
    /// triangle dialogues cap at 3; trees expecting 2 take the first 2.
    public static let maxCharacters = 3

    /// Minimum sample-line count per character. CharacterForge guarantees
    /// 1-5 per character; if a manifest entry ships zero, the importer
    /// flags the row as invalid.
    public static let minSampleLines = 1

    /// Maximum sample-line count consumed per character. Importer truncates
    /// excess lines — matches `DialogueCharacterRef.sampleLines` Phase-1
    /// authoring cap.
    public static let maxSampleLines = 5

    /// Current schema version the importer recognizes. Manifests with
    /// a higher version are rejected as `.unsupportedSchemaVersion`.
    public static let currentSchemaVersion = 1
}
