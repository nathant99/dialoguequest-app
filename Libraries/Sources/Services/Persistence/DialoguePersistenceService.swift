import Foundation
import Models
import SwiftData

/// Bridges value-type `DialogueTree`s to / from `PersistentDialogueTree`.
///
/// Encoding helpers are `nonisolated static` per `.claude/rules/warnings.md`
/// § "@Model + Codable isolation" — Codable work inside an `@Model`
/// computed property fights default-MainActor isolation.
public enum DialoguePersistenceService {

    // MARK: - Encode / decode

    /// Encode a value-type tree to JSON for `PersistentDialogueTree.encodedTreeData`.
    public nonisolated static func encode(_ tree: DialogueTree) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(tree)
    }

    /// Decode a JSON blob back to a value-type tree. Throws on schema drift —
    /// callers can fall back to a default tree when decoding fails.
    public nonisolated static func decodeTree(from data: Data) throws -> DialogueTree {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DialogueTree.self, from: data)
    }

    // MARK: - Cache projection

    /// Lightweight projection of a `PersistentDialogueTree` for list views.
    /// Built in `onAppear` per `.claude/rules/swiftdata.md` — never pass
    /// `@Model` instances to views.
    public nonisolated struct AnthologyEntry: Sendable, Hashable, Identifiable {
        public let id: UUID
        public let title: String
        public let mood: DialogueMood?
        public let lastEditedAt: Date
        public let isPublished: Bool
        /// Mirrors `DialogueTree.isDraft` so the anthology can render the
        /// "Draft" pill without re-decoding the full tree blob.
        public let isDraft: Bool

        public init(
            id: UUID,
            title: String,
            mood: DialogueMood?,
            lastEditedAt: Date,
            isPublished: Bool,
            isDraft: Bool = false
        ) {
            self.id = id
            self.title = title
            self.mood = mood
            self.lastEditedAt = lastEditedAt
            self.isPublished = isPublished
            self.isDraft = isDraft
        }
    }

    // MARK: - Save / load

    /// Save a value-type tree into the model context. Creates a new
    /// `PersistentDialogueTree` if `existing` is `nil`; otherwise updates
    /// in place. Caller is responsible for `modelContext.save()` after
    /// per the standing rule "Save after insert".
    @MainActor
    public static func save(
        _ tree: DialogueTree,
        into context: ModelContext,
        updating existing: PersistentDialogueTree? = nil,
        isPublished: Bool = false
    ) throws -> PersistentDialogueTree {
        let data = try encode(tree)
        let model: PersistentDialogueTree
        if let existing {
            model = existing
        } else {
            model = PersistentDialogueTree()
            context.insert(model)
        }
        model.id = tree.id
        model.encodedTreeData = data
        model.lastEditedAt = .now
        model.cachedTitle = tree.title
        model.cachedMoodRawValue = tree.mood?.rawValue
        model.isPublished = isPublished
        model.cachedIsDraft = tree.isDraft
        return model
    }

    /// Build a value-type `AnthologyEntry` projection from a
    /// `PersistentDialogueTree` snapshot — safe to hand to SwiftUI.
    @MainActor
    public static func projection(of model: PersistentDialogueTree) -> AnthologyEntry {
        AnthologyEntry(
            id: model.id,
            title: model.cachedTitle,
            mood: model.cachedMoodRawValue.flatMap(DialogueMood.init(rawValue:)),
            lastEditedAt: model.lastEditedAt,
            isPublished: model.isPublished,
            isDraft: model.cachedIsDraft
        )
    }
}
