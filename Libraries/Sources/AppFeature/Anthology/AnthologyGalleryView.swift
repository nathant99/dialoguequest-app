import SwiftUI
import SwiftData
import Models
import Services
import SharedUI

/// Mood-tagged anthology of published trees. Per `.claude/rules/swiftdata.md`:
/// no `@Query` in the body — fetch in `onAppear` into a value-type cache.
///
/// Phase 2 seed for the TaleForge export hook: each entry surfaces a
/// `ShareLink` that exports the value-type `DialogueTree` as JSON via
/// `DialogueTreeShareable`. The kid initiates the share via the standard
/// iOS share sheet — on-device only, no outbound network.
struct AnthologyGalleryView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var entries: [DialoguePersistenceService.AnthologyEntry] = []
    /// Cached value-type trees keyed by entry id — populated alongside
    /// `entries` so the share sheet has the full tree without a second
    /// SwiftData fetch on tap. Light enough for the Phase 1 anthology
    /// (5-15 node trees × N published); if N grows past ~50 we move to
    /// per-tap fetch via DialoguePersistenceService.
    @State private var treeCache: [UUID: DialogueTree] = [:]
    @State private var loadFailure: String?
    /// The entry whose certificate is currently being presented.
    /// Drives the sheet that hosts `PublishedTreeCertificate` +
    /// the ShareLink that exports the rendered PNG.
    @State private var certificateEntry: DialoguePersistenceService.AnthologyEntry?

    var body: some View {
        Group {
            if let failure = loadFailure {
                ContentUnavailableView(
                    "Couldn't load your anthology",
                    systemImage: "books.vertical",
                    description: Text(failure)
                )
            } else if entries.isEmpty {
                ContentUnavailableView(
                    "No published conversations yet",
                    systemImage: "books.vertical",
                    description: Text("Once you publish your first tree, it lands here.")
                )
            } else {
                listContent
                    .scrollContentBackground(.hidden)
                    .background(DialoguePalette.cream.opacity(0.6))
            }
        }
        .onAppear(perform: refresh)
        .sheet(item: $certificateEntry) { entry in
            certificateSheet(for: entry)
        }
    }

    @ViewBuilder
    private func certificateSheet(for entry: DialoguePersistenceService.AnthologyEntry) -> some View {
        if let tree = treeCache[entry.id] {
            CertificateSheet(
                tree: tree,
                publishedAt: entry.lastEditedAt,
                onClose: { certificateEntry = nil }
            )
        } else {
            ContentUnavailableView(
                "Couldn't load this dialogue",
                systemImage: "rosette",
                description: Text("Try opening the anthology again.")
            )
        }
    }

    private var listContent: some View {
        let list = List(entries) { entry in
            entryRow(entry)
        }
        #if os(iOS) || os(visionOS)
        return list.listStyle(.insetGrouped)
        #else
        return list.listStyle(.inset)
        #endif
    }

    private func entryRow(_ entry: DialoguePersistenceService.AnthologyEntry) -> some View {
        let displayTitle = entry.title.isEmpty ? "Untitled" : entry.title
        let moodLabel = entry.mood?.displayName ?? "no mood set"
        let timestamp = entry.lastEditedAt.formatted(date: .abbreviated, time: .shortened)
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(displayTitle)
                    .font(.headline)
                    .foregroundStyle(DialoguePalette.inkBlue)
                if entry.isDraft {
                    Text("Draft")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(DialoguePalette.inkBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(DialoguePalette.warmGold.opacity(0.45))
                        .clipShape(Capsule())
                        .accessibilityLabel("Marked as a draft sketch")
                        .accessibilityIdentifier("anthology.draftPill.\(entry.id)")
                }
                Spacer()
                if entry.isPublished {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(DialoguePalette.rust)
                        .accessibilityLabel("Published")
                }
                if let tree = treeCache[entry.id] {
                    ShareLink(
                        item: DialogueTreeShareable(tree: tree),
                        preview: SharePreview(
                            entry.title.isEmpty ? "Dialogue" : entry.title,
                            image: Image(systemName: "books.vertical.fill")
                        )
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(DialoguePalette.rust)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        DialogueQuestAnalytics.shared.track(.anthologyEntryShared)
                    })
                    .accessibilityLabel("Share dialogue \(entry.title.isEmpty ? "Untitled" : entry.title)")
                    .accessibilityHint("Export this dialogue tree as JSON via AirDrop, Files, or Mail. Nothing is uploaded — the share sheet is system-provided.")
                }
                if treeCache[entry.id] != nil {
                    Button {
                        certificateEntry = entry
                    } label: {
                        Image(systemName: "rosette")
                            .foregroundStyle(DialoguePalette.rust)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Show certificate for \(entry.title.isEmpty ? "Untitled" : entry.title)")
                    .accessibilityHint("Open the published-tree certificate. You can share the certificate as an image.")
                }
            }
            if let mood = entry.mood {
                Label(mood.displayName, systemImage: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text("Last edited \(timestamp)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(displayTitle), mood: \(moodLabel), last edited \(timestamp).")
    }

    private func refresh() {
        do {
            let descriptor = FetchDescriptor<PersistentDialogueTree>(
                predicate: #Predicate { $0.isPublished == true },
                sortBy: [SortDescriptor(\.lastEditedAt, order: .reverse)]
            )
            let models = try modelContext.fetch(descriptor)
            entries = models.map { DialoguePersistenceService.projection(of: $0) }
            // Decode the JSON payloads alongside the projection so the
            // share sheet has the full value-type tree on tap. We
            // tolerate decode failures (schema drift) silently — the
            // ShareLink is hidden when the tree isn't cached, so the
            // list still renders.
            var cache: [UUID: DialogueTree] = [:]
            for model in models {
                if let tree = try? DialoguePersistenceService.decodeTree(from: model.encodedTreeData) {
                    cache[model.id] = tree
                }
            }
            treeCache = cache
            indexInSpotlight(entries: entries, cache: cache)
        } catch {
            loadFailure = String(describing: error)
        }
    }

    /// Push the current anthology snapshot into Spotlight. Fire-and-forget
    /// — failures are silent because Spotlight is a nice-to-have surface
    /// (the in-app gallery is the canonical UI). The indexer is a value
    /// type, but indexing itself is async because the `CSSearchableIndex`
    /// I/O is async; we hop into a detached task with a sendable snapshot.
    private func indexInSpotlight(
        entries: [DialoguePersistenceService.AnthologyEntry],
        cache: [UUID: DialogueTree]
    ) {
        // Snapshot the spotlight payloads on the MainActor before crossing
        // the Sendable boundary to the detached task.
        let payloads: [AnthologySpotlightIndexer.SpotlightEntry] = entries.compactMap { entry in
            guard let tree = cache[entry.id] else { return nil }
            return AnthologySpotlightIndexer.SpotlightEntry(
                id: entry.id,
                title: entry.title,
                mood: entry.mood,
                lineCount: tree.nodes.count,
                branchCount: tree.nodes.filter { $0.children.count >= 2 }.count,
                lastEditedAt: entry.lastEditedAt
            )
        }
        Task.detached(priority: .background) {
            let indexer = AnthologySpotlightIndexer()
            // Wipe-then-replace so deleted entries fall out of Spotlight too.
            try? await indexer.deindexAllAnthology()
            try? await indexer.indexAll(payloads)
        }
    }
}
