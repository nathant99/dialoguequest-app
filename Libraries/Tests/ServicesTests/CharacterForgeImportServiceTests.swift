import Testing
import Foundation
@testable import Services
import Models

/// Closes Phase 2 unchecked checkbox *"Implement CharacterForge import
/// hook"* — proves the Phase 2 clipboard-JSON import surface accepts a
/// canonical manifest + rejects malformed / version-mismatched / empty /
/// row-invalid payloads with reader-facing copy that stays in the
/// age-9-14 register stoplist.
@Suite("CharacterForgeImportService")
struct CharacterForgeImportServiceTests {

    let service = CharacterForgeImportService()

    // MARK: - Fixtures

    static let validCharacter = CharacterForgeManifest.Character(
        name: "Iris",
        voiceRegister: "Speaks in short, clipped sentences; never apologizes directly.",
        sampleLines: [
            "I'm fine.",
            "Don't.",
            "Whatever you want."
        ],
        role: .protagonist
    )

    static let validManifest = CharacterForgeManifest(
        schemaVersion: 1,
        sourceApp: "characterforge",
        castName: "After the Rain — main 3",
        characters: [
            validCharacter,
            CharacterForgeManifest.Character(
                name: "Cal",
                voiceRegister: "Asks open questions; pauses before answering his own.",
                sampleLines: [
                    "What did you mean by that?",
                    "I — hold on, let me think.",
                    "Okay. Tell me again."
                ],
                role: .confidant
            )
        ]
    )

    // MARK: - Happy path

    @Test("Valid 2-character manifest maps to DialogueCharacterRef rows")
    func validManifestMaps() {
        let result = service.importCharacters(manifest: Self.validManifest)
        guard case .success(let refs) = result else {
            Issue.record("expected success; got \(result)")
            return
        }
        #expect(refs.count == 2)
        #expect(refs[0].name == "Iris")
        #expect(refs[0].voiceRegister.contains("clipped sentences"))
        #expect(refs[0].sampleLines.count == 3)
        #expect(refs[0].role == .protagonist)
        #expect(refs[1].name == "Cal")
        #expect(refs[1].role == .confidant)
    }

    @Test("Roundtrip via JSON payload")
    func jsonRoundtrip() throws {
        let data = try JSONEncoder().encode(Self.validManifest)
        let result = service.importCharacters(jsonPayload: data)
        guard case .success(let refs) = result else {
            Issue.record("expected success; got \(result)")
            return
        }
        #expect(refs.count == 2)
    }

    @Test("3-character cap caps at 3 even when manifest has more")
    func capsAt3() {
        let oversized = CharacterForgeManifest(
            characters: Array(repeating: Self.validCharacter, count: 6)
        )
        let result = service.importCharacters(manifest: oversized)
        guard case .success(let refs) = result else {
            Issue.record("expected success; got \(result)")
            return
        }
        #expect(refs.count == CharacterForgeImportLimits.maxCharacters)
        #expect(CharacterForgeImportLimits.maxCharacters == 3)
    }

    @Test("Role defaults to .unspecified when manifest omits it")
    func roleDefaults() {
        let manifest = CharacterForgeManifest(
            characters: [
                CharacterForgeManifest.Character(
                    name: "Roleless",
                    voiceRegister: "Whatever voice you imagine.",
                    sampleLines: ["Hi."],
                    role: nil
                )
            ]
        )
        let result = service.importCharacters(manifest: manifest)
        guard case .success(let refs) = result else {
            Issue.record("expected success; got \(result)")
            return
        }
        #expect(refs.first?.role == .unspecified)
    }

    // MARK: - Validation guards

    @Test("Malformed JSON returns .malformedJSON")
    func malformedJSON() {
        let bytes = Data("this is not json".utf8)
        let result = service.importCharacters(jsonPayload: bytes)
        guard case .failure(let error) = result else {
            Issue.record("expected failure; got \(result)")
            return
        }
        #expect(error == .malformedJSON)
    }

    @Test("Future schema version rejected")
    func futureSchemaRejected() {
        let manifest = CharacterForgeManifest(
            schemaVersion: 99,
            characters: [Self.validCharacter]
        )
        let result = service.importCharacters(manifest: manifest)
        guard case .failure(let error) = result else {
            Issue.record("expected failure; got \(result)")
            return
        }
        if case .unsupportedSchemaVersion(let found) = error {
            #expect(found == 99)
        } else {
            Issue.record("expected .unsupportedSchemaVersion; got \(error)")
        }
    }

    @Test("Unrecognized source app rejected")
    func unrecognizedSourceAppRejected() {
        let manifest = CharacterForgeManifest(
            sourceApp: "somerandomapp",
            characters: [Self.validCharacter]
        )
        let result = service.importCharacters(manifest: manifest)
        guard case .failure(let error) = result else {
            Issue.record("expected failure; got \(result)")
            return
        }
        if case .unrecognizedSourceApp(let found) = error {
            #expect(found == "somerandomapp")
        } else {
            Issue.record("expected .unrecognizedSourceApp; got \(error)")
        }
    }

    @Test("Empty manifest rejected")
    func emptyManifestRejected() {
        let manifest = CharacterForgeManifest(characters: [])
        let result = service.importCharacters(manifest: manifest)
        guard case .failure(let error) = result else {
            Issue.record("expected failure; got \(result)")
            return
        }
        #expect(error == .emptyManifest)
    }

    @Test("Missing voice register on a character row rejected")
    func missingVoiceRegisterRejected() {
        let manifest = CharacterForgeManifest(
            characters: [
                CharacterForgeManifest.Character(
                    name: "Bare",
                    voiceRegister: "   ",
                    sampleLines: ["hi"],
                    role: nil
                )
            ]
        )
        let result = service.importCharacters(manifest: manifest)
        guard case .failure(let error) = result else {
            Issue.record("expected failure; got \(result)")
            return
        }
        if case .invalidCharacter(let reason) = error,
           case .missingVoiceRegister(let name) = reason {
            #expect(name == "Bare")
        } else {
            Issue.record("expected .invalidCharacter(.missingVoiceRegister); got \(error)")
        }
    }

    @Test("Reader-facing error copy stays in age-9-14 register (no engineering jargon)")
    func errorCopyRegisterStoplist() {
        let banned = [
            "load-bearing", "codified", "ADR-", "schema-",
            "deserialization", "parse error",
            "PII", "COPPA"
        ]
        let errors: [CharacterForgeImportService.ImportError] = [
            .malformedJSON,
            .unsupportedSchemaVersion(found: 99),
            .unrecognizedSourceApp(found: "x"),
            .emptyManifest,
            .invalidCharacter(reason: .missingName),
            .invalidCharacter(reason: .missingVoiceRegister(name: "Bare")),
            .invalidCharacter(reason: .missingSampleLines(name: "Bare"))
        ]
        for error in errors {
            let copy = (error.errorDescription ?? "").lowercased()
            #expect(!copy.isEmpty, "every error must have copy")
            for token in banned {
                #expect(!copy.contains(token.lowercased()),
                        "error copy '\(copy)' must not contain '\(token)'")
            }
        }
    }
}
