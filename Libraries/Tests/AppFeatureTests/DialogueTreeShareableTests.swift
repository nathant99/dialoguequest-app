import Foundation
import Testing
import Models
import Services
@testable import AppFeature

@Suite("DialogueTreeShareable")
struct DialogueTreeShareableTests {

    private func makeTree(title: String = "Two Friends, One Conflict") -> DialogueTree {
        let cal = DialogueCharacterRef(
            id: UUID(),
            name: "Cal",
            voiceRegister: "Brash, blunt, short sentences.",
            sampleLines: ["Whatever.", "Just say it."]
        )
        let iris = DialogueCharacterRef(
            id: UUID(),
            name: "Iris",
            voiceRegister: "Careful, hedged, long sentences with commas.",
            sampleLines: ["I think — maybe — we both said too much."]
        )
        let root = DialogueNode(
            id: UUID(),
            speakerID: iris.id,
            surfaceText: "I'm fine.",
            inferredSubtext: nil,
            tag: .said("Iris"),
            children: [],
            createdAt: .now
        )
        return DialogueTree(
            id: UUID(),
            title: title,
            characters: [cal, iris],
            nodes: [root],
            rootNodeID: root.id,
            mood: .quietConflict
        )
    }

    @Test("sanitizeFilename keeps alphanumerics, replaces spaces + punctuation with underscores")
    func sanitizeKeepsAlphanumerics() {
        let result = DialogueTreeShareable.sanitizeFilename("Two Friends, One Conflict")
        #expect(result == "Two_Friends_One_Conflict")
    }

    @Test("sanitizeFilename clamps to 60 chars")
    func sanitizeClampsLength() {
        let longTitle = String(repeating: "ABCDEFGHIJ", count: 10)  // 100 chars
        let result = DialogueTreeShareable.sanitizeFilename(longTitle)
        #expect(result.count == 60)
    }

    @Test("sanitizeFilename falls back to \"dialogue\" for empty / whitespace titles")
    func sanitizeFallback() {
        #expect(DialogueTreeShareable.sanitizeFilename("") == "dialogue")
        #expect(DialogueTreeShareable.sanitizeFilename("   ") == "dialogue")
        #expect(DialogueTreeShareable.sanitizeFilename("\t\n") == "dialogue")
        // Even all-punctuation collapses to "dialogue" via the trim step.
        #expect(DialogueTreeShareable.sanitizeFilename("!!!") == "dialogue")
    }

    @Test("Shareable wraps the tree losslessly through JSON encode + decode")
    func roundTripJSON() throws {
        let tree = makeTree()
        let shareable = DialogueTreeShareable(tree: tree)
        let data = try DialoguePersistenceService.encode(shareable.tree)
        let decoded = try DialoguePersistenceService.decodeTree(from: data)

        #expect(decoded.id == tree.id)
        #expect(decoded.title == tree.title)
        #expect(decoded.mood == tree.mood)
        #expect(decoded.characters.count == tree.characters.count)
        #expect(decoded.nodes.count == tree.nodes.count)
        #expect(decoded.rootNodeID == tree.rootNodeID)
    }
}
