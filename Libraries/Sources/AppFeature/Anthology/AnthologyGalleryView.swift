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
    /// Phase 3 — per-entry read-aloud playback service. Single instance
    /// shared across rows since only one row plays at a time.
    @State private var readAloudService = DialogueReadAloudService()
    /// Phase 3 — most-recently-rendered audio export URL per entry.
    /// When non-nil, the row renders a `ShareLink(item: URL)` so the kid
    /// can send the AIFF via AirDrop / Files / Messages.
    @State private var exportedAudioURLs: [UUID: URL] = [:]
    /// Phase 3 — entries currently mid-export. UI shows a spinner.
    @State private var exportingEntryID: UUID?
    /// Phase 3 — surface the most recent export error to the kid via an
    /// inline label on the entry (no modal alert disruption).
    @State private var exportErrorMessage: String?

    @AppStorage("dq.readAloudCount") private var readAloudCount: Int = 0
    @AppStorage("dq.audioExportCount") private var audioExportCount: Int = 0

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
                if let tree = treeCache[entry.id] {
                    Button {
                        toggleReadAloud(tree: tree)
                    } label: {
                        Image(systemName: readAloudIcon(for: tree))
                            .foregroundStyle(DialoguePalette.rust)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Listen to \(entry.title.isEmpty ? "Untitled" : entry.title)")
                    .accessibilityHint("Play this dialogue tree aloud. Each character speaks in a voice picked from their register. Audio stays on this device.")
                }
                if let tree = treeCache[entry.id] {
                    if let exportedURL = exportedAudioURLs[entry.id] {
                        ShareLink(
                            item: exportedURL,
                            preview: SharePreview(
                                entry.title.isEmpty ? "Dialogue audio" : entry.title,
                                image: Image(systemName: "waveform")
                            )
                        ) {
                            Image(systemName: "waveform.badge.checkmark")
                                .foregroundStyle(DialoguePalette.rust)
                        }
                        .accessibilityLabel("Share audio for \(entry.title.isEmpty ? "Untitled" : entry.title)")
                        .accessibilityHint("Send the AIFF you just exported via AirDrop, Files, or Messages.")
                    } else if exportingEntryID == entry.id {
                        ProgressView()
                            .accessibilityLabel("Rendering audio for \(entry.title.isEmpty ? "Untitled" : entry.title)")
                    } else {
                        Button {
                            exportAudio(tree: tree, entryID: entry.id)
                        } label: {
                            Image(systemName: "waveform")
                                .foregroundStyle(DialoguePalette.rust)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Export audio for \(entry.title.isEmpty ? "Untitled" : entry.title)")
                        .accessibilityHint("Render this dialogue tree as an AIFF audio file. Rendering happens on this device; nothing is uploaded.")
                    }
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
            if exportingEntryID == entry.id, let err = exportErrorMessage {
                Text(err)
                    .font(.caption2)
                    .foregroundStyle(DialoguePalette.rust)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(displayTitle), mood: \(moodLabel), last edited \(timestamp).")
    }

    private func readAloudIcon(for tree: DialogueTree) -> String {
        if case .playing(let nodeID) = readAloudService.phase,
           tree.nodes.contains(where: { $0.id == nodeID }) {
            return "stop.circle"
        }
        return "play.circle"
    }

    private func toggleReadAloud(tree: DialogueTree) {
        switch readAloudService.phase {
        case .idle, .completed:
            readAloudService.play(tree: tree)
            readAloudCount += 1
            DialogueQuestAnalytics.shared.track(.anthologyEntryShared) // re-use the existing event vocabulary
        case .playing:
            readAloudService.stop()
        }
    }

    private func exportAudio(tree: DialogueTree, entryID: UUID) {
        exportingEntryID = entryID
        exportErrorMessage = nil
        Task {
            let exporter = DialogueAudioExporter()
            do {
                let url = try await exporter.exportAIFF(tree: tree)
                exportedAudioURLs[entryID] = url
                audioExportCount += 1
            } catch let DialogueAudioExporter.ExportError.writeFailed(reason) {
                exportErrorMessage = "Audio export failed: \(reason)"
            } catch DialogueAudioExporter.ExportError.emptyTree {
                exportErrorMessage = "This dialogue has no lines yet to read aloud."
            } catch {
                exportErrorMessage = "Audio export failed unexpectedly."
            }
            exportingEntryID = nil
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
