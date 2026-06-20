import Foundation
import Testing
@testable import Models

@Suite("DialogueNode — branch/leaf detection + Codable")
struct DialogueNodeTests {

    private static let speakerID = UUID()

    @Test("A node with two children is a branch point and not a leaf")
    func branchPointDetection() {
        let node = DialogueNode(
            speakerID: Self.speakerID,
            surfaceText: "Are you sure?",
            children: [UUID(), UUID()]
        )
        #expect(node.isBranchPoint)
        #expect(!node.isLeaf)
    }

    @Test("A node with one child is neither a branch point nor a leaf")
    func linearNode() {
        let node = DialogueNode(
            speakerID: Self.speakerID,
            surfaceText: "I'm sure.",
            children: [UUID()]
        )
        #expect(!node.isBranchPoint)
        #expect(!node.isLeaf)
    }

    @Test("A node with no children is a leaf")
    func leafDetection() {
        let node = DialogueNode(
            speakerID: Self.speakerID,
            surfaceText: "Good.",
            children: []
        )
        #expect(!node.isBranchPoint)
        #expect(node.isLeaf)
    }

    @Test("Node round-trips through Codable including inferred subtext")
    func roundTrip() throws {
        let original = DialogueNode(
            speakerID: Self.speakerID,
            surfaceText: "I'm fine.",
            inferredSubtext: "She is not fine.",
            tag: .action("She didn't look up."),
            children: [UUID(), UUID()]
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DialogueNode.self, from: data)
        #expect(decoded == original)
    }
}
