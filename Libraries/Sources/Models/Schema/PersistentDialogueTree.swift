import Foundation
import SwiftData

/// SwiftData storage for a `DialogueTree`. Phase 1 picks **single `@Model`
/// wrapping JSON** per `Docs/IMPLEMENTATION_HANDOFF.md` § 3 — simpler
/// migration story, atomic writes, no relationship-array reorder gotcha.
///
/// Encoding / decoding happens in `DialoguePersistenceService` (Services
/// target) via `nonisolated static` helpers; never decode inside this
/// class's computed properties (per `.claude/rules/warnings.md` § @Model
/// + Codable isolation).
@Model
public final class PersistentDialogueTree {
    public var id: UUID = UUID()

    /// JSON-encoded `DialogueTree`. Decode via
    /// `DialoguePersistenceService.decodeTree(from:)`.
    public var encodedTreeData: Data = Data()

    public var lastEditedAt: Date = Date()

    /// Title cached at the top level so the Anthology gallery can render
    /// thumbnails without decoding every JSON blob.
    public var cachedTitle: String = ""

    /// Mood raw value cached at the top level for the same reason.
    public var cachedMoodRawValue: String? = nil

    /// Mark `true` when the kid taps "Publish" on the editor surface.
    /// Anthology gallery filters to `isPublished == true`.
    public var isPublished: Bool = false

    public init() {}
}
