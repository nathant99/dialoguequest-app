import SwiftUI
import SwiftData
import Models
import Services
import SharedUI

/// Phase 4 anthology curation surface — closes FEATURE_PLAN row 158
/// "Implement anthology curation (kid-curated collection of best trees
/// with themed organization)". Sits alongside `AnthologyGalleryView` (the
/// flat chronological list) as the kid's "what would I show my parent?"
/// surface.
///
/// **Flow**: kid sees their existing collections (or an empty state) on
/// open; can create a new collection (title + themed picker), drag-add
/// published anthology entries to it, rename / re-theme the collection,
/// remove entries, and share the entire collection as a JSON archive
/// via the system share sheet (`ShareLink(item: URL)`).
///
/// **Privacy posture**: every action stays on-device. No outbound network,
/// no third-party SDK, no PII written to disk beyond the kid-supplied
/// collection title.
public struct AnthologyCurationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @State private var collections: [AnthologyCollectionService.CollectionSnapshot] = []
    @State private var publishedEntries: [DialoguePersistenceService.AnthologyEntry] = []
    @State private var treeCache: [UUID: DialogueTree] = [:]
    @State private var isCreatingCollection: Bool = false
    @State private var newCollectionTitle: String = ""
    @State private var newCollectionTheme: AnthologyCollectionThemeHint = .firstConversations
    @State private var loadFailure: String?

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if let failure = loadFailure {
                    ContentUnavailableView(
                        "Couldn't load your collections",
                        systemImage: "books.vertical",
                        description: Text(failure)
                    )
                } else {
                    createSection
                    if collections.isEmpty {
                        ContentUnavailableView(
                            "No collections yet",
                            systemImage: "books.vertical",
                            description: Text("Group your favorite trees into themed collections you can share with a parent or teacher.")
                        )
                        .padding(.vertical, 24)
                    } else {
                        ForEach(collections) { snapshot in
                            collectionCard(snapshot: snapshot)
                        }
                    }
                }
            }
            .padding()
        }
        .background(DialoguePalette.cream.opacity(0.6))
        .navigationTitle("Curate anthology")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear(perform: refresh)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pick the trees you want to share.")
                .font(.headline)
                .foregroundStyle(DialoguePalette.inkBlue)
            Text("Group your favorites into a themed collection. The collection saves as a JSON file you can send anywhere.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Create surface

    @ViewBuilder
    private var createSection: some View {
        if isCreatingCollection {
            VStack(alignment: .leading, spacing: 12) {
                Text("New collection")
                    .font(.headline)
                    .foregroundStyle(DialoguePalette.inkBlue)
                TextField("Collection title", text: $newCollectionTitle)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityHint("Pick a short title for this collection.")
                Picker("Theme", selection: $newCollectionTheme) {
                    ForEach(AnthologyCollectionThemeHint.allCases, id: \.self) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                Text(newCollectionTheme.coachingLine)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    Button("Cancel") {
                        cancelCreate()
                    }
                    Button("Create") {
                        commitCreate()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(DialoguePalette.rust)
                    .disabled(newCollectionTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding()
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Button {
                isCreatingCollection = true
            } label: {
                Label("New collection", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(DialoguePalette.rust)
            .accessibilityIdentifier("curation.newCollection")
        }
    }

    // MARK: - Collection card

    private func collectionCard(snapshot: AnthologyCollectionService.CollectionSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(snapshot.title.isEmpty ? "Untitled collection" : snapshot.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(DialoguePalette.inkBlue)
                    Text(snapshot.themeHint.displayName)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(DialoguePalette.rust)
                }
                Spacer()
                shareButton(for: snapshot)
            }

            Text(snapshot.themeHint.coachingLine)
                .font(.footnote)
                .foregroundStyle(.secondary)

            entryList(snapshot: snapshot)

            addEntryMenu(snapshot: snapshot)

            HStack(spacing: 16) {
                Button(role: .destructive) {
                    deleteCollection(id: snapshot.id)
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func shareButton(for snapshot: AnthologyCollectionService.CollectionSnapshot) -> some View {
        if let url = exportURL(for: snapshot) {
            ShareLink(item: url) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(.caption.weight(.semibold))
            }
            .accessibilityHint("Share this collection as a JSON file.")
        }
    }

    @ViewBuilder
    private func entryList(snapshot: AnthologyCollectionService.CollectionSnapshot) -> some View {
        if snapshot.entryIDs.isEmpty {
            Text("No trees in this collection yet.")
                .font(.footnote.italic())
                .foregroundStyle(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(snapshot.entryIDs, id: \.self) { entryID in
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                            .foregroundStyle(DialoguePalette.rust)
                        Text(titleForEntry(id: entryID))
                            .font(.callout)
                            .foregroundStyle(DialoguePalette.inkBlue)
                        Spacer()
                        Button {
                            removeEntry(entryID, fromCollectionID: snapshot.id)
                        } label: {
                            Image(systemName: "xmark.circle")
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityLabel("Remove from collection")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func addEntryMenu(snapshot: AnthologyCollectionService.CollectionSnapshot) -> some View {
        let availableEntries = publishedEntries.filter { entry in
            !snapshot.entryIDs.contains(entry.id)
        }
        if availableEntries.isEmpty {
            Text(snapshot.entryIDs.isEmpty
                 ? "Publish a tree first, then add it here."
                 : "Every published tree is in this collection.")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            Menu {
                ForEach(availableEntries) { entry in
                    Button(entry.title.isEmpty ? "Untitled dialogue" : entry.title) {
                        addEntry(entry.id, toCollectionID: snapshot.id)
                    }
                }
            } label: {
                Label("Add a tree", systemImage: "plus.circle")
                    .font(.callout.weight(.semibold))
            }
            .accessibilityHint("Pick a published tree to add to this collection.")
        }
    }

    // MARK: - Side effects

    private func refresh() {
        do {
            let collectionDescriptor = FetchDescriptor<AnthologyCollectionRecord>(
                sortBy: [SortDescriptor(\.lastEditedAt, order: .reverse)]
            )
            let collectionModels = try modelContext.fetch(collectionDescriptor)
            collections = collectionModels.compactMap { AnthologyCollectionService.projection(of: $0) }

            let entryDescriptor = FetchDescriptor<PersistentDialogueTree>(
                predicate: #Predicate { $0.isPublished == true },
                sortBy: [SortDescriptor(\.lastEditedAt, order: .reverse)]
            )
            let entryModels = try modelContext.fetch(entryDescriptor)
            publishedEntries = entryModels.map { DialoguePersistenceService.projection(of: $0) }

            var cache: [UUID: DialogueTree] = [:]
            for model in entryModels {
                do {
                    let tree = try DialoguePersistenceService.decodeTree(from: model.encodedTreeData)
                    cache[model.id] = tree
                } catch {
                    DialogueQuestDebugLog.data(
                        "AnthologyCurationView.refresh — decodeTree failed for id=\(model.id); entry hidden from curation picker",
                        error: error
                    )
                }
            }
            treeCache = cache
        } catch {
            loadFailure = String(describing: error)
        }
    }

    private func cancelCreate() {
        isCreatingCollection = false
        newCollectionTitle = ""
        newCollectionTheme = .firstConversations
    }

    private func commitCreate() {
        let title = newCollectionTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        do {
            _ = try AnthologyCollectionService.create(
                title: title,
                themeHint: newCollectionTheme,
                into: modelContext
            )
            try modelContext.save()
            cancelCreate()
            refresh()
        } catch {
            loadFailure = String(describing: error)
        }
    }

    private func addEntry(_ entryID: UUID, toCollectionID collectionID: UUID) {
        guard let record = fetchCollection(id: collectionID) else { return }
        do {
            try AnthologyCollectionService.addEntry(entryID, to: record)
            try modelContext.save()
            refresh()
        } catch {
            loadFailure = String(describing: error)
        }
    }

    private func removeEntry(_ entryID: UUID, fromCollectionID collectionID: UUID) {
        guard let record = fetchCollection(id: collectionID) else { return }
        do {
            try AnthologyCollectionService.removeEntry(entryID, from: record)
            try modelContext.save()
            refresh()
        } catch {
            loadFailure = String(describing: error)
        }
    }

    private func deleteCollection(id: UUID) {
        guard let record = fetchCollection(id: id) else { return }
        modelContext.delete(record)
        do {
            try modelContext.save()
        } catch {
            DialogueQuestDebugLog.data("AnthologyCurationView.deleteCollection — modelContext.save failed", error: error)
        }
        refresh()
    }

    private func fetchCollection(id: UUID) -> AnthologyCollectionRecord? {
        let descriptor = FetchDescriptor<AnthologyCollectionRecord>(
            predicate: #Predicate { $0.id == id }
        )
        return try? modelContext.fetch(descriptor).first
    }

    private func titleForEntry(id: UUID) -> String {
        publishedEntries.first(where: { $0.id == id })?.title ?? "Removed tree"
    }

    /// Build a temporary `.dqcollection.json` file for `ShareLink(item: URL)`.
    /// Returns `nil` when no included entries decoded (the share sheet hides
    /// the button in that case).
    private func exportURL(for snapshot: AnthologyCollectionService.CollectionSnapshot) -> URL? {
        let trees: [DialogueTree] = snapshot.entryIDs.compactMap { treeCache[$0] }
        guard !trees.isEmpty else { return nil }
        do {
            let data = try AnthologyCollectionService.encodeArchive(
                title: snapshot.title,
                themeHint: snapshot.themeHint,
                trees: trees
            )
            let safeTitle = snapshot.title
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty }
                .joined(separator: "_")
            let filename = (safeTitle.isEmpty ? "collection" : safeTitle) + ".dqcollection.json"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try data.write(to: url, options: [.atomic])
            return url
        } catch {
            return nil
        }
    }

    /// Reduce-Transparency-aware panel background — mirrors the
    /// WriteTabView / PerformanceBoothView local helper.
    @ViewBuilder
    private var panelBackground: some View {
        if reduceTransparency {
            DialoguePalette.cream
        } else {
            Color.clear.background(.thinMaterial)
        }
    }
}
