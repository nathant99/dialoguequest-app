import Foundation
import Models

/// Closes the Phase 2 unchecked item *"Implement CharacterForge import
/// hook — load named characters with established voice registers"* in
/// `@Docs/FEATURE_PLAN.md`.
///
/// **Phase 2 first cut**: the importer consumes a JSON `CharacterForgeManifest`
/// payload (typically pasted from CharacterForge's "Export cast" surface).
/// A future ForgeSync-bridged path (auto-discover the sibling app's
/// AppGroupStore export) lands when the bridge is wired.
///
/// **Posture**: pure value-type service. No I/O. No persistence side
/// effects. The caller hands in raw payload bytes (or a decoded manifest);
/// the service returns `[DialogueCharacterRef]` or a typed error.
public nonisolated struct CharacterForgeImportService: Sendable {

    public init() {}

    /// Decode a JSON manifest payload + map to `DialogueCharacterRef` rows.
    /// Returns `.success([ref])` capped at `CharacterForgeImportLimits.maxCharacters`,
    /// or `.failure(ImportError)` when the payload is malformed / version-
    /// incompatible / source-app-rejected / under the minimum row count.
    public func importCharacters(jsonPayload: Data) -> Result<[DialogueCharacterRef], ImportError> {
        let manifest: CharacterForgeManifest
        do {
            manifest = try JSONDecoder().decode(CharacterForgeManifest.self, from: jsonPayload)
        } catch {
            return .failure(.malformedJSON)
        }
        return importCharacters(manifest: manifest)
    }

    /// Map an already-decoded `CharacterForgeManifest` to `DialogueCharacterRef`
    /// rows. Same validation rules as the JSON path; useful for tests +
    /// the future ForgeSync-bridged path.
    public func importCharacters(manifest: CharacterForgeManifest) -> Result<[DialogueCharacterRef], ImportError> {
        // Schema-version guard — refuse unknown future versions so a
        // schema-2 manifest doesn't silently lose new fields.
        guard manifest.schemaVersion <= CharacterForgeImportLimits.currentSchemaVersion else {
            return .failure(.unsupportedSchemaVersion(found: manifest.schemaVersion))
        }
        // Source-app guard — soft signal that the manifest came from the
        // sibling we expect. Case-insensitive to tolerate authoring drift.
        guard manifest.sourceApp.lowercased() == "characterforge" else {
            return .failure(.unrecognizedSourceApp(found: manifest.sourceApp))
        }
        guard manifest.characters.isEmpty == false else {
            return .failure(.emptyManifest)
        }

        var refs: [DialogueCharacterRef] = []
        for character in manifest.characters.prefix(CharacterForgeImportLimits.maxCharacters) {
            let trimmedName = character.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else {
                return .failure(.invalidCharacter(reason: .missingName))
            }
            let trimmedVoice = character.voiceRegister.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedVoice.isEmpty else {
                return .failure(.invalidCharacter(reason: .missingVoiceRegister(name: trimmedName)))
            }
            let cleanedSamples = character.sampleLines
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .prefix(CharacterForgeImportLimits.maxSampleLines)
            guard cleanedSamples.count >= CharacterForgeImportLimits.minSampleLines else {
                return .failure(.invalidCharacter(reason: .missingSampleLines(name: trimmedName)))
            }
            refs.append(
                DialogueCharacterRef(
                    name: trimmedName,
                    voiceRegister: trimmedVoice,
                    sampleLines: Array(cleanedSamples),
                    role: character.role ?? .unspecified
                )
            )
        }
        return .success(refs)
    }

    /// Errors surfaced by the importer. Reader-facing copy lives in
    /// `localizedDescription` so the UI can render the error directly
    /// without per-case switch logic.
    public enum ImportError: Error, Equatable, Sendable, LocalizedError {
        /// JSON payload couldn't be decoded against `CharacterForgeManifest`.
        case malformedJSON
        /// Manifest claims a schemaVersion the importer doesn't recognize.
        case unsupportedSchemaVersion(found: Int)
        /// `sourceApp` is not `"characterforge"`.
        case unrecognizedSourceApp(found: String)
        /// Manifest has zero characters.
        case emptyManifest
        /// A character row failed validation.
        case invalidCharacter(reason: InvalidCharacterReason)

        public enum InvalidCharacterReason: Equatable, Sendable {
            case missingName
            case missingVoiceRegister(name: String)
            case missingSampleLines(name: String)
        }

        public var errorDescription: String? {
            switch self {
            case .malformedJSON:
                return "That doesn't look like a CharacterForge export. Paste the JSON exactly as it was copied."
            case .unsupportedSchemaVersion(let v):
                return "This export uses a newer version (\(v)) than DialogueQuest knows. Update DialogueQuest and try again."
            case .unrecognizedSourceApp(let app):
                return "This export came from \(app), not CharacterForge. The importer only accepts CharacterForge exports."
            case .emptyManifest:
                return "That export has no characters in it. Author at least one in CharacterForge, then export again."
            case .invalidCharacter(let reason):
                switch reason {
                case .missingName:
                    return "One of the characters is missing a name."
                case .missingVoiceRegister(let name):
                    return "\(name) is missing a voice register — the line that describes how they sound."
                case .missingSampleLines(let name):
                    return "\(name) is missing sample lines — DialogueQuest needs at least one."
                }
            }
        }
    }
}
