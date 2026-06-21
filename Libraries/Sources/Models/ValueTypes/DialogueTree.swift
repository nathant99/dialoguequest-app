import Foundation

/// A complete branching dialogue authored by the kid. Phase 1 caps the
/// node count at 5-15; Phase 2 lifts the cap when triangle dialogues land.
public nonisolated struct DialogueTree: Codable, Sendable, Hashable, Identifiable {
    public let id: UUID
    public let title: String
    public let characters: [DialogueCharacterRef]
    public let nodes: [DialogueNode]
    public let rootNodeID: UUID
    public let mood: DialogueMood?

    public init(
        id: UUID = UUID(),
        title: String,
        characters: [DialogueCharacterRef],
        nodes: [DialogueNode],
        rootNodeID: UUID,
        mood: DialogueMood? = nil
    ) {
        self.id = id
        self.title = title
        self.characters = characters
        self.nodes = nodes
        self.rootNodeID = rootNodeID
        self.mood = mood
    }

    /// Lookup by UUID. O(n); for hot-path traversal cache to a dictionary
    /// inside the view-model rather than calling per-node.
    public func node(for id: UUID) -> DialogueNode? {
        nodes.first { $0.id == id }
    }

    /// Lookup the character speaking a given node.
    public func character(for node: DialogueNode) -> DialogueCharacterRef? {
        characters.first { $0.id == node.speakerID }
    }

    /// All branch-point nodes in declaration order. The Socratic
    /// branch-meaningfulness check fires once per branch point.
    public var branchPoints: [DialogueNode] {
        nodes.filter(\.isBranchPoint)
    }

    /// All leaf nodes in declaration order. A well-shaped tree typically
    /// has 2-4 leaves matching the number of distinct endings.
    public var leaves: [DialogueNode] {
        nodes.filter(\.isLeaf)
    }

    public enum NodeCountConstraint {
        public static let phase1Min: Int = 5
        public static let phase1Max: Int = 15

        /// Progressive-disclosure tier. The maximum tree size grows with
        /// the kid's experience: session 1 caps at 3 nodes so the loop is
        /// reachable in 5 minutes; sessions 2-3 cap at 5; sessions 4+ use
        /// the full Phase 1 ceiling. The min for publish stays at 5
        /// regardless — the kid must always meet that bar to publish.
        public enum SessionTier: String, Sendable, Hashable, CaseIterable {
            case firstSession
            case earlySessions
            case experienced

            /// Map a raw "published-trees-so-far" count to a tier.
            public init(publishedCount: Int) {
                switch publishedCount {
                case ..<1: self = .firstSession
                case 1...2: self = .earlySessions
                default: self = .experienced
                }
            }
        }

        public static func maxNodes(for tier: SessionTier) -> Int {
            switch tier {
            case .firstSession: return 3
            case .earlySessions: return 5
            case .experienced: return phase1Max
            }
        }
    }

    /// Phase 1 ship-readiness gate. UI uses this to disable the "Save"
    /// affordance until the kid has authored at least 5 nodes.
    public var meetsPhase1NodeCount: Bool {
        let count = nodes.count
        return count >= NodeCountConstraint.phase1Min &&
               count <= NodeCountConstraint.phase1Max
    }
}
