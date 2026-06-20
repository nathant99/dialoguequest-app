import Foundation
import Models

/// View-local state for the dialogue-tree builder per
/// `.claude/rules/state-machines.md` § "`*Machine` Structs".
///
/// Pure value type — no closures, no service references. Mutating
/// operations advance state; the View binds via `@State`.
public nonisolated struct DialogueTreeMachine: Sendable, Equatable {

    // MARK: - Authoring stages

    public enum Stage: String, Sendable, Hashable {
        /// Kid is naming + voice-registering the 2 characters.
        case authoringCharacters
        /// Kid is building the tree (adding / linking nodes).
        case editingTree
        /// Kid is reviewing for publish (read-only + dashboard surfaces).
        case reviewing
        /// Tree is persisted with `isPublished = true`.
        case published
    }

    // MARK: - Stored state

    public var stage: Stage
    public var tree: DialogueTree
    /// IDs of branch points the kid has answered the 3-question Socratic
    /// prompt against. Drives `BranchMeaningfulnessScorer.reflectionRatio`.
    public var reflectedBranchPointIDs: Set<UUID>
    /// IDs of nodes the kid has accepted Patter's inferred subtext on.
    public var confirmedSubtextLineIDs: Set<UUID>
    /// Currently selected node — drives the Inspector + Panels.
    public var selectedNodeID: UUID?
    /// Last error surfaced to the UI (mutation guard rejections, etc.).
    public var lastError: AuthoringError?

    public enum AuthoringError: String, Sendable, Hashable, Error {
        case treeAtMaxCapacity
        case treeBelowMinForPublish
        case nodeNotFound
        case characterNotFound
        case rootNodeUndeletable
    }

    public init(
        stage: Stage = .authoringCharacters,
        tree: DialogueTree = DialogueTreeMachine.makeEmptyTree(),
        reflectedBranchPointIDs: Set<UUID> = [],
        confirmedSubtextLineIDs: Set<UUID> = [],
        selectedNodeID: UUID? = nil,
        lastError: AuthoringError? = nil
    ) {
        self.stage = stage
        self.tree = tree
        self.reflectedBranchPointIDs = reflectedBranchPointIDs
        self.confirmedSubtextLineIDs = confirmedSubtextLineIDs
        self.selectedNodeID = selectedNodeID
        self.lastError = lastError
    }

    /// Required `reset()` per the portfolio convention.
    public mutating func reset() {
        self = DialogueTreeMachine()
    }

    // MARK: - Stage transitions

    /// Move from character authoring to tree editing. Requires both
    /// characters to have non-empty names + sample lines.
    public mutating func finishCharacterAuthoring() {
        guard tree.characters.count >= 2 else { return }
        guard tree.characters.allSatisfy({ !$0.name.isEmpty && !$0.sampleLines.isEmpty }) else { return }
        if tree.nodes.isEmpty, let first = tree.characters.first {
            // Seed an empty root so the editor has something to render.
            let root = DialogueNode(
                speakerID: first.id,
                surfaceText: "",
                tag: .said("said")
            )
            tree = DialogueTree(
                id: tree.id,
                title: tree.title,
                characters: tree.characters,
                nodes: [root],
                rootNodeID: root.id,
                mood: tree.mood
            )
            selectedNodeID = root.id
        }
        stage = .editingTree
    }

    public mutating func enterReview() {
        guard tree.meetsPhase1NodeCount else {
            lastError = .treeBelowMinForPublish
            return
        }
        stage = .reviewing
    }

    public mutating func markPublished() {
        guard tree.meetsPhase1NodeCount else {
            lastError = .treeBelowMinForPublish
            return
        }
        stage = .published
    }

    // MARK: - Character authoring

    public mutating func addCharacter(_ ref: DialogueCharacterRef) {
        var updated = tree.characters
        updated.append(ref)
        tree = DialogueTree(
            id: tree.id,
            title: tree.title,
            characters: updated,
            nodes: tree.nodes,
            rootNodeID: tree.rootNodeID,
            mood: tree.mood
        )
    }

    public mutating func updateTitle(_ title: String) {
        tree = DialogueTree(
            id: tree.id,
            title: title,
            characters: tree.characters,
            nodes: tree.nodes,
            rootNodeID: tree.rootNodeID,
            mood: tree.mood
        )
    }

    public mutating func updateMood(_ mood: DialogueMood?) {
        tree = DialogueTree(
            id: tree.id,
            title: tree.title,
            characters: tree.characters,
            nodes: tree.nodes,
            rootNodeID: tree.rootNodeID,
            mood: mood
        )
    }

    // MARK: - Tree editing

    /// Append a new child node to `parentID`. Returns the new node's UUID
    /// on success, `nil` if the tree is at Phase 1 max capacity (15 nodes)
    /// or the parent doesn't exist.
    @discardableResult
    public mutating func appendChild(
        to parentID: UUID,
        speakerID: UUID,
        surfaceText: String = "",
        tag: DialogueTag = .said("said")
    ) -> UUID? {
        guard tree.nodes.count < DialogueTree.NodeCountConstraint.phase1Max else {
            lastError = .treeAtMaxCapacity
            return nil
        }
        guard let parentIndex = tree.nodes.firstIndex(where: { $0.id == parentID }) else {
            lastError = .nodeNotFound
            return nil
        }
        guard tree.characters.contains(where: { $0.id == speakerID }) else {
            lastError = .characterNotFound
            return nil
        }
        var nodes = tree.nodes
        let newNode = DialogueNode(
            speakerID: speakerID,
            surfaceText: surfaceText,
            tag: tag
        )
        let parent = nodes[parentIndex]
        let updatedParent = DialogueNode(
            id: parent.id,
            speakerID: parent.speakerID,
            surfaceText: parent.surfaceText,
            inferredSubtext: parent.inferredSubtext,
            tag: parent.tag,
            children: parent.children + [newNode.id],
            createdAt: parent.createdAt
        )
        nodes[parentIndex] = updatedParent
        nodes.append(newNode)
        tree = DialogueTree(
            id: tree.id,
            title: tree.title,
            characters: tree.characters,
            nodes: nodes,
            rootNodeID: tree.rootNodeID,
            mood: tree.mood
        )
        selectedNodeID = newNode.id
        return newNode.id
    }

    /// Replace an existing node in place. Identity is preserved by `id`.
    public mutating func updateNode(_ updated: DialogueNode) {
        guard let index = tree.nodes.firstIndex(where: { $0.id == updated.id }) else {
            lastError = .nodeNotFound
            return
        }
        var nodes = tree.nodes
        nodes[index] = updated
        tree = DialogueTree(
            id: tree.id,
            title: tree.title,
            characters: tree.characters,
            nodes: nodes,
            rootNodeID: tree.rootNodeID,
            mood: tree.mood
        )
    }

    /// Remove a leaf node + its edge from its parent. The root is never
    /// deletable; deleting an inner node first requires unlinking its
    /// children manually (Phase 1 keeps this simple — kid can only delete
    /// leaves).
    public mutating func removeLeaf(_ nodeID: UUID) {
        guard nodeID != tree.rootNodeID else {
            lastError = .rootNodeUndeletable
            return
        }
        guard let node = tree.node(for: nodeID), node.isLeaf else {
            lastError = .nodeNotFound
            return
        }
        var nodes = tree.nodes.filter { $0.id != nodeID }
        if let parentIndex = nodes.firstIndex(where: { $0.children.contains(nodeID) }) {
            let parent = nodes[parentIndex]
            nodes[parentIndex] = DialogueNode(
                id: parent.id,
                speakerID: parent.speakerID,
                surfaceText: parent.surfaceText,
                inferredSubtext: parent.inferredSubtext,
                tag: parent.tag,
                children: parent.children.filter { $0 != nodeID },
                createdAt: parent.createdAt
            )
        }
        tree = DialogueTree(
            id: tree.id,
            title: tree.title,
            characters: tree.characters,
            nodes: nodes,
            rootNodeID: tree.rootNodeID,
            mood: tree.mood
        )
        if selectedNodeID == nodeID { selectedNodeID = tree.rootNodeID }
    }

    // MARK: - Mentor wiring

    public mutating func recordReflection(for branchPointID: UUID) {
        reflectedBranchPointIDs.insert(branchPointID)
    }

    public mutating func confirmSubtext(for lineID: UUID, inferredSubtext: String) {
        guard let node = tree.node(for: lineID) else {
            lastError = .nodeNotFound
            return
        }
        let updated = DialogueNode(
            id: node.id,
            speakerID: node.speakerID,
            surfaceText: node.surfaceText,
            inferredSubtext: inferredSubtext,
            tag: node.tag,
            children: node.children,
            createdAt: node.createdAt
        )
        updateNode(updated)
        confirmedSubtextLineIDs.insert(lineID)
    }

    public mutating func rejectSubtext(for lineID: UUID) {
        guard let node = tree.node(for: lineID) else {
            lastError = .nodeNotFound
            return
        }
        let updated = DialogueNode(
            id: node.id,
            speakerID: node.speakerID,
            surfaceText: node.surfaceText,
            inferredSubtext: nil,
            tag: node.tag,
            children: node.children,
            createdAt: node.createdAt
        )
        updateNode(updated)
        confirmedSubtextLineIDs.remove(lineID)
    }

    // MARK: - Derived

    public var canPublish: Bool { tree.meetsPhase1NodeCount }

    public var selectedNode: DialogueNode? {
        guard let id = selectedNodeID else { return nil }
        return tree.node(for: id)
    }

    // MARK: - Defaults

    public nonisolated static func makeEmptyTree() -> DialogueTree {
        DialogueTree(
            title: "New conversation",
            characters: [],
            nodes: [],
            rootNodeID: UUID()  // overwritten when the first character + root land
        )
    }
}
