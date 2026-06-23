import Foundation
import SwiftData
import Models

/// Phase 4 anthology curation service — wraps the
/// `AnthologyCollectionRecord` SwiftData model with value-type Codable
/// helpers + a `CollectionSnapshot` projection consumed by SwiftUI.
///
/// **Why a service over `@Query`**: per `.claude/rules/swiftdata.md` rule
/// "Zero `@Query` in Views". Anthology curation reads
/// `AnthologyCollectionRecord` rows on `onAppear`, decodes the entry-id
/// JSON, and renders against a value-type snapshot. The service owns the
/// encoding/decoding seam so views stay free of `JSONDecoder` calls.
///
/// **Storage shape**: each collection stores its membership as
/// `encodedEntryIDs: Data` (JSON-encoded `[UUID]`). Fetches that need the
/// underlying tree shape pair this service with
/// `DialoguePersistenceService.decodeTree(from:)` per-id.
public enum AnthologyCollectionService {

    /// JSON encoder/decoder pair shared across encode/decode calls.
    /// `nonisolated static let` because the closure captures
    /// `@Sendable`-clean values and is read from any actor.
    nonisolated static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    nonisolated static let decoder = JSONDecoder()

    // MARK: - Codable helpers

    /// Encode an `entryIDs` list for `AnthologyCollectionRecord.encodedEntryIDs`.
    /// Idempotent + Sendable — safe to call from any actor.
    public nonisolated static func encodeEntryIDs(_ ids: [UUID]) throws -> Data {
        try encoder.encode(ids)
    }

    /// Decode a stored `encodedEntryIDs` blob back to a `[UUID]`.
    /// Tolerates empty `Data()` (returns `[]`) — fresh inserts persist
    /// with the default empty blob until first `addEntry`.
    public nonisolated static func decodeEntryIDs(from data: Data) throws -> [UUID] {
        guard !data.isEmpty else { return [] }
        return try decoder.decode([UUID].self, from: data)
    }

    // MARK: - Value-type snapshot

    /// View-facing snapshot of an `AnthologyCollectionRecord`. Value-type
    /// + `Identifiable` so SwiftUI can render the curation list without
    /// reaching into the `@Model` object inside `body`.
    public nonisolated struct CollectionSnapshot: Sendable, Hashable, Identifiable {
        public let id: UUID
        public let title: String
        public let themeHint: AnthologyCollectionThemeHint
        public let entryIDs: [UUID]
        public let createdAt: Date
        public let lastEditedAt: Date

        public init(
            id: UUID,
            title: String,
            themeHint: AnthologyCollectionThemeHint,
            entryIDs: [UUID],
            createdAt: Date,
            lastEditedAt: Date
        ) {
            self.id = id
            self.title = title
            self.themeHint = themeHint
            self.entryIDs = entryIDs
            self.createdAt = createdAt
            self.lastEditedAt = lastEditedAt
        }
    }

    /// Project a `@Model` row into a Sendable value-type snapshot. Returns
    /// `nil` when the stored theme hint can't be parsed (forward-compat
    /// guard so a future-schema collection doesn't crash the gallery).
    @MainActor
    public static func projection(of model: AnthologyCollectionRecord) -> CollectionSnapshot? {
        guard let theme = AnthologyCollectionThemeHint(rawValue: model.themeHintRawValue) else {
            return nil
        }
        let ids = (try? decodeEntryIDs(from: model.encodedEntryIDs)) ?? []
        return CollectionSnapshot(
            id: model.id,
            title: model.title,
            themeHint: theme,
            entryIDs: ids,
            createdAt: model.createdAt,
            lastEditedAt: model.lastEditedAt
        )
    }

    // MARK: - CRUD

    /// Create + persist a new collection. Caller is responsible for
    /// `modelContext.save()` afterwards (matches the existing
    /// `DialoguePersistenceService.save` convention).
    @MainActor
    public static func create(
        title: String,
        themeHint: AnthologyCollectionThemeHint,
        initialEntryIDs: [UUID] = [],
        into context: ModelContext
    ) throws -> AnthologyCollectionRecord {
        let record = AnthologyCollectionRecord()
        record.title = title
        record.themeHintRawValue = themeHint.rawValue
        record.encodedEntryIDs = try encodeEntryIDs(initialEntryIDs)
        record.createdAt = .now
        record.lastEditedAt = .now
        context.insert(record)
        return record
    }

    /// Add an entry id to a collection. Idempotent — duplicates are
    /// silently de-duped. Bumps `lastEditedAt`.
    @MainActor
    public static func addEntry(
        _ entryID: UUID,
        to record: AnthologyCollectionRecord
    ) throws {
        var ids = try decodeEntryIDs(from: record.encodedEntryIDs)
        guard !ids.contains(entryID) else { return }
        ids.append(entryID)
        record.encodedEntryIDs = try encodeEntryIDs(ids)
        record.lastEditedAt = .now
    }

    /// Remove an entry id from a collection. No-op when not a member.
    @MainActor
    public static func removeEntry(
        _ entryID: UUID,
        from record: AnthologyCollectionRecord
    ) throws {
        var ids = try decodeEntryIDs(from: record.encodedEntryIDs)
        let beforeCount = ids.count
        ids.removeAll { $0 == entryID }
        guard ids.count != beforeCount else { return }
        record.encodedEntryIDs = try encodeEntryIDs(ids)
        record.lastEditedAt = .now
    }

    /// Rename a collection. No-op when the title hasn't changed.
    @MainActor
    public static func rename(_ record: AnthologyCollectionRecord, to title: String) {
        guard record.title != title else { return }
        record.title = title
        record.lastEditedAt = .now
    }

    /// Change the theme hint on an existing collection. No-op when the
    /// hint hasn't changed.
    @MainActor
    public static func setThemeHint(
        _ themeHint: AnthologyCollectionThemeHint,
        on record: AnthologyCollectionRecord
    ) {
        guard record.themeHintRawValue != themeHint.rawValue else { return }
        record.themeHintRawValue = themeHint.rawValue
        record.lastEditedAt = .now
    }

    // MARK: - Share payload

    /// JSON archive shape for `ShareLink`. Includes the collection metadata
    /// + the full value-type trees so the receiving device can import the
    /// collection without needing access to the source kid's anthology.
    public nonisolated struct CollectionArchive: Sendable, Codable {
        public let schemaVersion: Int
        public let title: String
        public let themeHint: String
        public let exportedAt: Date
        public let trees: [DialogueTree]

        public init(
            schemaVersion: Int = 1,
            title: String,
            themeHint: AnthologyCollectionThemeHint,
            exportedAt: Date = .now,
            trees: [DialogueTree]
        ) {
            self.schemaVersion = schemaVersion
            self.title = title
            self.themeHint = themeHint.rawValue
            self.exportedAt = exportedAt
            self.trees = trees
        }
    }

    /// Build the `Data` payload for `ShareLink(item: URL)` — caller writes
    /// the result to a temporary URL with a `.dqcollection.json` extension.
    public nonisolated static func encodeArchive(
        title: String,
        themeHint: AnthologyCollectionThemeHint,
        trees: [DialogueTree]
    ) throws -> Data {
        let archive = CollectionArchive(
            title: title,
            themeHint: themeHint,
            trees: trees
        )
        return try encoder.encode(archive)
    }
}
