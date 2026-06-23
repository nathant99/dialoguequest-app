import Testing
import Foundation
@testable import Models

/// Closes Phase Delight micro-delight § Agency — proves the new
/// `DialogueTree.isDraft` field round-trips via Codable AND that
/// pre-Phase-2 trees (which omit the field) decode cleanly with
/// `isDraft = false`.
@Suite("DialogueTree draft Codable")
struct DialogueTreeDraftCodableTests {

    @Test("Draft flag defaults to false on init")
    func defaultsToFalse() {
        let tree = DialogueTree(
            title: "T",
            characters: [],
            nodes: [],
            rootNodeID: UUID()
        )
        #expect(tree.isDraft == false)
    }

    @Test("withDraftFlag preserves identity + flips flag")
    func withDraftFlagFlips() {
        let original = DialogueTree(
            title: "Original",
            characters: [],
            nodes: [],
            rootNodeID: UUID()
        )
        let drafted = original.withDraftFlag(true)
        #expect(drafted.isDraft == true)
        #expect(drafted.id == original.id)
        #expect(drafted.title == original.title)
        #expect(drafted.characters == original.characters)
    }

    @Test("Roundtrip via Codable preserves isDraft")
    func roundtrip() throws {
        let tree = DialogueTree(
            title: "Roundtrip",
            characters: [],
            nodes: [],
            rootNodeID: UUID(),
            mood: .quietConflict,
            isDraft: true
        )
        let data = try JSONEncoder().encode(tree)
        let decoded = try JSONDecoder().decode(DialogueTree.self, from: data)
        #expect(decoded.isDraft == true)
        #expect(decoded.mood == .quietConflict)
    }

    @Test("Pre-Phase-2 JSON (no isDraft field) decodes with isDraft = false")
    func backwardsCompatPhase1Decoding() throws {
        let rootID = UUID()
        let payload = """
        {
            "id": "\(UUID().uuidString)",
            "title": "Legacy tree",
            "characters": [],
            "nodes": [],
            "rootNodeID": "\(rootID.uuidString)"
        }
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(DialogueTree.self, from: payload)
        #expect(decoded.isDraft == false)
        #expect(decoded.title == "Legacy tree")
    }
}
