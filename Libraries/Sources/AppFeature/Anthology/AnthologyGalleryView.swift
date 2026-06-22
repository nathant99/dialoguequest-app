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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.title.isEmpty ? "Untitled" : entry.title)
                    .font(.headline)
                    .foregroundStyle(DialoguePalette.inkBlue)
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
            }
            if let mood = entry.mood {
                Label(mood.displayName, systemImage: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text("Last edited \(entry.lastEditedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
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
        } catch {
            loadFailure = String(describing: error)
        }
    }
}
