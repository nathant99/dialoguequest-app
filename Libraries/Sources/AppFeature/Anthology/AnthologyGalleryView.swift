import SwiftUI
import SwiftData
import Models
import Services
import SharedUI

/// Mood-tagged anthology of published trees. Per `.claude/rules/swiftdata.md`:
/// no `@Query` in the body — fetch in `onAppear` into a value-type cache.
struct AnthologyGalleryView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var entries: [DialoguePersistenceService.AnthologyEntry] = []
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
        } catch {
            loadFailure = String(describing: error)
        }
    }
}
