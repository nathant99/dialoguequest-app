import Foundation
import Testing
@testable import Models
@testable import AppFeature

@Suite("DialogueTreeMachine — authoring transitions + mutations")
struct DialogueTreeMachineTests {

    @Test("Initial state is authoringCharacters with no nodes")
    func initialState() {
        let machine = DialogueTreeMachine()
        #expect(machine.stage == .authoringCharacters)
        #expect(machine.tree.nodes.isEmpty)
        #expect(machine.tree.characters.isEmpty)
    }

    @Test("finishCharacterAuthoring requires 2 characters with names + sample lines")
    func finishCharacterAuthoringValidates() {
        var machine = DialogueTreeMachine()
        machine.updateTitle("Test")
        machine.updateMood(.openingCuriosity)
        machine.addCharacter(
            DialogueCharacterRef(name: "A", voiceRegister: "v", sampleLines: ["x"])
        )
        machine.finishCharacterAuthoring()
        #expect(machine.stage == .authoringCharacters, "Only one character — should stay in authoring")

        machine.addCharacter(
            DialogueCharacterRef(name: "B", voiceRegister: "v", sampleLines: ["y"])
        )
        machine.finishCharacterAuthoring()
        #expect(machine.stage == .editingTree)
        #expect(machine.tree.nodes.count == 1, "Empty-tree seed root expected")
    }

    @Test("appendChild appends a new node and wires the parent")
    func appendChildLinksParent() {
        var machine = makeReadyForEditing()
        let rootID = machine.tree.rootNodeID
        let secondCharacter = machine.tree.characters[1].id

        let newID = machine.appendChild(to: rootID, speakerID: secondCharacter, surfaceText: "Reply")
        #expect(newID != nil)
        #expect(machine.tree.nodes.count == 2)
        let root = machine.tree.node(for: rootID)
        #expect(root?.children.contains(newID!) == true)
        #expect(machine.selectedNodeID == newID)
    }

    @Test("appendChild rejects when tree is at phase-1 max capacity")
    func appendChildRejectsAtMax() {
        var machine = makeReadyForEditing()
        let speakerID = machine.tree.characters[0].id
        // Already 1 (the seeded root); push to the max of 15.
        for _ in 0..<(DialogueTree.NodeCountConstraint.phase1Max - 1) {
            _ = machine.appendChild(to: machine.tree.rootNodeID, speakerID: speakerID)
        }
        #expect(machine.tree.nodes.count == DialogueTree.NodeCountConstraint.phase1Max)
        let blocked = machine.appendChild(to: machine.tree.rootNodeID, speakerID: speakerID)
        #expect(blocked == nil)
        #expect(machine.lastError == .treeAtMaxCapacity)
    }

    @Test("removeLeaf cannot delete the root")
    func removeLeafProtectsRoot() {
        var machine = makeReadyForEditing()
        machine.removeLeaf(machine.tree.rootNodeID)
        #expect(machine.lastError == .rootNodeUndeletable)
        #expect(machine.tree.nodes.count == 1)
    }

    @Test("recordReflection accumulates reflected branch-point IDs")
    func reflectionAccumulates() {
        var machine = makeReadyForEditing()
        let a = UUID()
        let b = UUID()
        machine.recordReflection(for: a)
        machine.recordReflection(for: b)
        machine.recordReflection(for: a)
        #expect(machine.reflectedBranchPointIDs == [a, b])
    }

    @Test("confirmSubtext updates the node + records the line ID")
    func confirmSubtextUpdatesNode() {
        var machine = makeReadyForEditing()
        let rootID = machine.tree.rootNodeID
        machine.confirmSubtext(for: rootID, inferredSubtext: "they don't believe each other")
        let node = machine.tree.node(for: rootID)
        #expect(node?.inferredSubtext == "they don't believe each other")
        #expect(machine.confirmedSubtextLineIDs.contains(rootID))
    }

    @Test("reset returns the machine to its initial state")
    func resetIsTotal() {
        var machine = makeReadyForEditing()
        machine.recordReflection(for: UUID())
        machine.reset()
        #expect(machine.stage == .authoringCharacters)
        #expect(machine.tree.nodes.isEmpty)
        #expect(machine.tree.characters.isEmpty)
        #expect(machine.reflectedBranchPointIDs.isEmpty)
    }

    // MARK: - Test helpers

    private func makeReadyForEditing() -> DialogueTreeMachine {
        var machine = DialogueTreeMachine()
        machine.updateTitle("Test")
        machine.updateMood(.openingCuriosity)
        machine.addCharacter(
            DialogueCharacterRef(name: "Iris", voiceRegister: "v", sampleLines: ["x"])
        )
        machine.addCharacter(
            DialogueCharacterRef(name: "Cal", voiceRegister: "v", sampleLines: ["y"])
        )
        machine.finishCharacterAuthoring()
        return machine
    }
}
