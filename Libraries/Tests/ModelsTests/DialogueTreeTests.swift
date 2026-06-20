import Foundation
import Testing
@testable import Models

@Suite("DialogueTree — traversal, Phase 1 constraints, Codable")
struct DialogueTreeTests {

    private static func buildSampleTree(nodeCount: Int) -> DialogueTree {
        let iris = DialogueCharacterRef(
            name: "Iris",
            voiceRegister: "clipped sentences; never apologizes directly.",
            sampleLines: ["I'm fine.", "Sure.", "If you say so."]
        )
        let cal = DialogueCharacterRef(
            name: "Cal",
            voiceRegister: "warm; asks follow-up questions.",
            sampleLines: ["What's going on?", "Hey — talk to me.", "I see you."]
        )
        var nodes: [DialogueNode] = []
        for i in 0..<nodeCount {
            let speaker = i.isMultiple(of: 2) ? cal.id : iris.id
            nodes.append(
                DialogueNode(
                    speakerID: speaker,
                    surfaceText: "Line \(i)",
                    tag: .said("said")
                )
            )
        }
        return DialogueTree(
            title: "A quiet afternoon",
            characters: [iris, cal],
            nodes: nodes,
            rootNodeID: nodes.first?.id ?? UUID(),
            mood: .quietConflict
        )
    }

    @Test("Phase 1 node-count gate accepts 5-15 nodes")
    func phase1GateAccepts() {
        let small = Self.buildSampleTree(nodeCount: 5)
        let mid = Self.buildSampleTree(nodeCount: 10)
        let large = Self.buildSampleTree(nodeCount: 15)
        #expect(small.meetsPhase1NodeCount)
        #expect(mid.meetsPhase1NodeCount)
        #expect(large.meetsPhase1NodeCount)
    }

    @Test("Phase 1 node-count gate rejects fewer than 5 or more than 15")
    func phase1GateRejects() {
        let tooSmall = Self.buildSampleTree(nodeCount: 4)
        let tooLarge = Self.buildSampleTree(nodeCount: 16)
        #expect(!tooSmall.meetsPhase1NodeCount)
        #expect(!tooLarge.meetsPhase1NodeCount)
    }

    @Test("Lookups by node UUID + speaker UUID resolve correctly")
    func lookups() {
        let tree = Self.buildSampleTree(nodeCount: 6)
        let first = try? #require(tree.nodes.first)
        let resolved = try? #require(first.flatMap { tree.node(for: $0.id) })
        #expect(resolved?.id == first?.id)
        let character = first.flatMap { tree.character(for: $0) }
        #expect(character != nil)
    }

    @Test("Tree round-trips through Codable preserving structure")
    func roundTrip() throws {
        let original = Self.buildSampleTree(nodeCount: 7)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DialogueTree.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.title == original.title)
        #expect(decoded.nodes.count == original.nodes.count)
        #expect(decoded.mood == original.mood)
    }

    @Test("branchPoints + leaves filter the node array correctly")
    func branchAndLeafFilters() {
        let iris = DialogueCharacterRef(
            name: "Iris",
            voiceRegister: "test",
            sampleLines: ["test"]
        )
        let leaf1 = DialogueNode(speakerID: iris.id, surfaceText: "End A.")
        let leaf2 = DialogueNode(speakerID: iris.id, surfaceText: "End B.")
        let branch = DialogueNode(
            speakerID: iris.id,
            surfaceText: "Pick a path.",
            children: [leaf1.id, leaf2.id]
        )
        let linear = DialogueNode(
            speakerID: iris.id,
            surfaceText: "Just one path.",
            children: [branch.id]
        )
        let tree = DialogueTree(
            title: "Branch sample",
            characters: [iris],
            nodes: [linear, branch, leaf1, leaf2],
            rootNodeID: linear.id
        )
        #expect(tree.branchPoints.count == 1)
        #expect(tree.branchPoints.first?.id == branch.id)
        #expect(tree.leaves.count == 2)
    }
}
