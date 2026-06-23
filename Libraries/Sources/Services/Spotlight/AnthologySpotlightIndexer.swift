import Foundation
import ForgeSpotlight
import Models

/// Surfaces the kid's published dialogue trees in iOS Spotlight so they
/// can resurface their own work via system search (Springboard pull-down,
/// Safari pull-down, Mac Spotlight, Watch search).
///
/// Pattern: `AnthologyGalleryView` calls `indexAll(_:)` on its `refresh()`
/// onAppear hook, handing in the freshly-loaded entries. The indexer
/// builds `SpotlightIndexable` adapters, batches them through
/// `ForgeSpotlightIndexer`, and is otherwise stateless.
///
/// **Privacy posture** (per `.claude/rules/age-assurance.md` § COPPA): the
/// indexed content is the kid's OWN authored title + mood + line/branch
/// counts. No PII surfaces because `DialogueCharacterRef.name` lives
/// inside the encoded tree blob and is NOT included in the Spotlight
/// description. The kid is the only one who can search their device
/// Spotlight; iOS does not propagate the index off-device.
///
/// **Wipe-on-delete**: when an entry is removed from the anthology, the
/// caller MUST call `deindex(ids:)` to remove the Spotlight surface.
/// `AnthologyGalleryView.refresh()` calls `replaceAllEntries` which
/// `deindexAllAnthology` first, then re-indexes — so deletes propagate
/// implicitly.
public struct AnthologySpotlightIndexer: Sendable {

    /// Stable Spotlight domain identifier — keeps DialogueQuest's
    /// anthology entries grouped + lets `deindexDomain` wipe them all
    /// at once (e.g., on parental-consent revoke).
    public nonisolated static let domainIdentifier: String = "com.sparkandanvil.dialoguequest.anthology"

    /// The unique identifier prefix we use for every anthology entry —
    /// the actual id is `\(prefix).\(treeID.uuidString)`.
    public nonisolated static let identifierPrefix: String = "dq.anthology"

    private let indexer: ForgeSpotlightIndexer

    public nonisolated init(indexer: ForgeSpotlightIndexer? = nil) {
        self.indexer = indexer ?? ForgeSpotlightIndexer(domainIdentifier: Self.domainIdentifier)
    }

    /// Build the Spotlight identifier for a given anthology entry id.
    /// Public so `Tab` deep-link routing or tests can roundtrip the id.
    public nonisolated static func spotlightID(for entryID: UUID) -> String {
        "\(identifierPrefix).\(entryID.uuidString)"
    }

    /// Index the given entries. No-op when the array is empty.
    public func indexAll(_ entries: [SpotlightEntry]) async throws {
        try await indexer.index(entries)
    }

    /// Remove the entries with the given anthology IDs from the index.
    public func deindex(ids: [UUID]) async throws {
        let spotlightIDs = ids.map { Self.spotlightID(for: $0) }
        try await indexer.deindex(ids: spotlightIDs)
    }

    /// Wipe every DialogueQuest anthology entry from the Spotlight index.
    /// Used on parental-consent revoke + on a full anthology clear.
    public func deindexAllAnthology() async throws {
        try await indexer.deindexDomain(Self.domainIdentifier)
    }

    // MARK: - SpotlightIndexable adapter

    /// Value-type adapter that conforms `SpotlightIndexable` to the
    /// fields we want to surface. Built from an `AnthologyEntry` plus
    /// optional line/branch counts (decoded from the tree blob by the
    /// caller — the indexer does NOT decode itself to keep this stateless).
    public struct SpotlightEntry: SpotlightIndexable, Sendable, Equatable {
        public let id: UUID
        public let title: String
        public let mood: DialogueMood?
        public let lineCount: Int
        public let branchCount: Int
        public let lastEditedAt: Date

        public init(
            id: UUID,
            title: String,
            mood: DialogueMood?,
            lineCount: Int,
            branchCount: Int,
            lastEditedAt: Date
        ) {
            self.id = id
            self.title = title
            self.mood = mood
            self.lineCount = lineCount
            self.branchCount = branchCount
            self.lastEditedAt = lastEditedAt
        }

        public var spotlightID: String {
            AnthologySpotlightIndexer.spotlightID(for: id)
        }

        public var spotlightTitle: String {
            title.isEmpty ? "Untitled dialogue" : title
        }

        public var spotlightDescription: String {
            // Reader-facing register per
            // `.claude/rules/distributed-narrative.md` § R-CHAPTER-REGISTER —
            // no engineering jargon. Friendly natural-language summary.
            var parts: [String] = []
            if let mood {
                parts.append(displayMood(mood))
            }
            parts.append(lineCount == 1 ? "1 line" : "\(lineCount) lines")
            parts.append(branchCount == 1 ? "1 branch point" : "\(branchCount) branch points")
            return parts.joined(separator: " • ")
        }

        public var spotlightKeywords: [String] {
            var keywords = ["DialogueQuest", "dialogue", "writing", "conversation"]
            if !title.isEmpty { keywords.append(title) }
            if let mood { keywords.append(displayMood(mood)) }
            return keywords
        }

        /// Anthology entries don't ship their own thumbnail — the gallery
        /// renders mood-tagged surfaces in-app. Spotlight uses the system
        /// fallback when nil.
        public var spotlightThumbnailName: String? { nil }

        private func displayMood(_ mood: DialogueMood) -> String {
            switch mood {
            case .warmReunion: return "warm reunion"
            case .quietConflict: return "quiet conflict"
            case .playfulRivalry: return "playful rivalry"
            case .awkwardSilence: return "awkward silence"
            case .openingCuriosity: return "opening curiosity"
            }
        }
    }
}
