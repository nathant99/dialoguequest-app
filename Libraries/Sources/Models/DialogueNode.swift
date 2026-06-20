import Foundation

/// One speech-or-beat node in a `DialogueTree`. Children are referenced by
/// UUID rather than by value so the tree can branch + re-converge without
/// hitting Codable cycle pitfalls.
public nonisolated struct DialogueNode: Codable, Sendable, Hashable, Identifiable {
    public let id: UUID
    /// Identifies which `DialogueCharacterRef.id` speaks this line. For
    /// unattributed beats this still names the implied speaker — the
    /// rendering layer decides whether to show the attribution.
    public let speakerID: UUID
    /// What the character actually says (or does, for action beats).
    public let surfaceText: String
    /// AI-surfaced subtext. Optional because the kid may not have engaged
    /// the subtext detector yet; nil means "not analyzed", empty string
    /// means "analyzed; no clear subtext detected".
    public let inferredSubtext: String?
    public let tag: DialogueTag
    /// IDs of child nodes that branch from this one. A leaf node has an
    /// empty array; a branch point has 2+ entries.
    public let children: [UUID]
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        speakerID: UUID,
        surfaceText: String,
        inferredSubtext: String? = nil,
        tag: DialogueTag = .said("said"),
        children: [UUID] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.speakerID = speakerID
        self.surfaceText = surfaceText
        self.inferredSubtext = inferredSubtext
        self.tag = tag
        self.children = children
        self.createdAt = createdAt
    }

    /// True when this node has more than one child — i.e., the kid was
    /// asked to consider what each branch costs the speaker.
    public var isBranchPoint: Bool { children.count > 1 }

    /// True when this node has no children. Tree traversal stops here.
    public var isLeaf: Bool { children.isEmpty }
}
