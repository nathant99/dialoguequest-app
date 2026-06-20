import Foundation
import Testing
@testable import Models
@testable import Services

@Suite("DialoguePersistenceService — encode/decode round-trip")
struct DialoguePersistenceServiceTests {

    @Test("Encode → decode preserves all DialogueTree fields")
    func roundTripPreservesAllFields() throws {
        let iris = DialogueCharacterRef(
            name: "Iris",
            voiceRegister: "clipped, deflects, ends with 'I guess'",
            sampleLines: ["I guess that works.", "Whatever you say.", "Fine, fine."]
        )
        let cal = DialogueCharacterRef(
            name: "Cal",
            voiceRegister: "tries too hard to be casual; uses 'so' as a stall",
            sampleLines: ["So, like, yeah.", "It's whatever.", "I'm cool with it."]
        )
        let line1 = DialogueNode(
            speakerID: iris.id,
            surfaceText: "Did you mean it?",
            inferredSubtext: "she's testing him",
            tag: .said("said"),
            children: []
        )
        let line2 = DialogueNode(
            speakerID: cal.id,
            surfaceText: "Mean what?",
            tag: .action("Cal looked away."),
            children: []
        )
        let tree = DialogueTree(
            title: "After the test",
            characters: [iris, cal],
            nodes: [line1, line2],
            rootNodeID: line1.id,
            mood: .quietConflict
        )

        let data = try DialoguePersistenceService.encode(tree)
        let decoded = try DialoguePersistenceService.decodeTree(from: data)

        #expect(decoded.id == tree.id)
        #expect(decoded.title == tree.title)
        #expect(decoded.mood == .quietConflict)
        #expect(decoded.characters.count == 2)
        #expect(decoded.nodes.count == 2)
        #expect(decoded.rootNodeID == line1.id)
        #expect(decoded.nodes.first?.inferredSubtext == "she's testing him")
    }

    @Test("Decoding malformed data throws")
    func decodeMalformedThrows() {
        let garbage = Data("not json".utf8)
        #expect(throws: (any Error).self) {
            _ = try DialoguePersistenceService.decodeTree(from: garbage)
        }
    }
}
