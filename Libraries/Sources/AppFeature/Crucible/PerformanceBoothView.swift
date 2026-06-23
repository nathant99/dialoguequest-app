import SwiftUI
import SwiftData
import AIMentor
import Models
import Services
import SharedUI

/// Performance Booth adventure-mode surface. The kid picks a published
/// tree from their anthology, hears it read aloud in per-character voices
/// (`DialogueReadAloudService`), then exports the rendering as an AIFF
/// audio file the kid can share via `ShareLink(item: URL)`.
///
/// Feature-plan provenance: Phase 3 row 148
/// "Add ForgeAdventure mode: Performance Booth (voice + line + tree →
/// audio export)". Composes the existing read-aloud + audio-export Phase 3
/// services into a single kid-facing adventure card. The hub Level-1 JSON
/// tile that wires this into AdventureHub itself is filed at
/// `Docs/HANDOFF_TO_HUB_HUBCONTRIBUTION_LEVEL_1.md`; until that ships,
/// the Booth is reachable from `AdventureTabView`'s unlocked content.
public struct PerformanceBoothView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dismiss) private var dismiss

    @State private var machine = PerformanceBoothMachine()
    @State private var readAloudService = DialogueReadAloudService()
    @State private var entries: [DialoguePersistenceService.AnthologyEntry] = []
    @State private var treeCache: [UUID: DialogueTree] = [:]
    @State private var exporter = DialogueAudioExporter()
    @State private var exportError: String?
    @State private var isExporting = false
    @State private var loadFailure: String?
    @State private var coachingPrompt: CoachingPrompt?

    @AppStorage("dq.audioExportCount") private var audioExportCount: Int = 0
    @AppStorage("dq.performanceBoothExportCount") private var performanceBoothExportCount: Int = 0

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    switch machine.stage {
                    case .choosingTree:
                        treePicker
                    case .performing(let treeID):
                        performingSurface(treeID: treeID)
                    case .exported(let treeID, let url):
                        exportedSurface(treeID: treeID, audioURL: url)
                    }
                }
                .padding()
            }
            .background(DialoguePalette.cream.opacity(0.6))
            .navigationTitle("Performance Booth")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        readAloudService.stop()
                        dismiss()
                    }
                }
            }
            .onAppear(perform: refresh)
            .onChange(of: readAloudService.phase) { _, newPhase in
                if case .playing = newPhase {
                    machine.markListened()
                }
            }
            .sheet(item: $coachingPrompt) { prompt in
                VoiceCoachingSheet(
                    castID: prompt.castID,
                    castDisplayName: prompt.castDisplayName,
                    promptLine: prompt.promptLine
                )
            }
        }
    }

    // MARK: - Coaching prompt

    /// Identifiable coaching prompt for the `.sheet(item:)` presentation.
    /// Picks the first cast member whose voice baseline is available
    /// (LESSONS-layer profiles) and uses the tree's first non-empty line
    /// as the practice prompt.
    fileprivate struct CoachingPrompt: Identifiable, Equatable {
        let id: UUID = UUID()
        let castID: String
        let castDisplayName: String
        let promptLine: String
    }

    private func coachingPromptForTree(_ tree: DialogueTree) -> CoachingPrompt? {
        guard let firstLine = tree.nodes
            .map(\.surfaceText)
            .first(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty })
        else { return nil }
        let profiles = CastVoiceRegistry.lessonsLayerProfiles
        guard let chosen = profiles.first else { return nil }
        return CoachingPrompt(
            castID: chosen.id,
            castDisplayName: chosen.displayName,
            promptLine: firstLine
        )
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hear your scene. Send it anywhere.")
                .font(.headline)
                .foregroundStyle(DialoguePalette.inkBlue)
            Text("Pick a tree from your anthology. Listen as each character speaks in their own voice. Save the recording to share.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Tree picker

    private var treePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let failure = loadFailure {
                ContentUnavailableView(
                    "Couldn't load your anthology",
                    systemImage: "books.vertical",
                    description: Text(failure)
                )
            } else if entries.isEmpty {
                ContentUnavailableView(
                    "Publish a tree first",
                    systemImage: "waveform",
                    description: Text("The Performance Booth needs at least one published tree to read aloud. Head to the Write tab to publish one.")
                )
            } else {
                ForEach(entries) { entry in
                    treeCard(entry: entry)
                }
            }
        }
    }

    private func treeCard(entry: DialoguePersistenceService.AnthologyEntry) -> some View {
        Button {
            machine.selectTree(id: entry.id)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "waveform")
                    .font(.title2)
                    .foregroundStyle(DialoguePalette.rust)
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title.isEmpty ? "Untitled dialogue" : entry.title)
                        .font(.headline)
                        .foregroundStyle(DialoguePalette.inkBlue)
                    if let mood = entry.mood {
                        Text("Mood: \(mood.displayName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Open the Performance Booth for this tree")
    }

    // MARK: - Performing

    @ViewBuilder
    private func performingSurface(treeID: UUID) -> some View {
        if let tree = treeCache[treeID] {
            VStack(alignment: .leading, spacing: 16) {
                Text(tree.title.isEmpty ? "Untitled dialogue" : tree.title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text("Tap to hear each character speak in their own voice. Then export the recording when you're ready.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button {
                        if case .playing = readAloudService.phase {
                            readAloudService.stop()
                        } else {
                            readAloudService.play(tree: tree)
                        }
                    } label: {
                        Label(
                            readAloudService.phase == .idle || readAloudService.phase == .completed
                                ? "Listen"
                                : "Stop",
                            systemImage: readAloudService.phase == .idle || readAloudService.phase == .completed
                                ? "play.circle.fill"
                                : "stop.circle.fill"
                        )
                        .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(DialoguePalette.rust)

                    Button {
                        Task { await runExport(tree: tree) }
                    } label: {
                        if isExporting {
                            Label("Saving…", systemImage: "hourglass")
                        } else {
                            Label("Save recording", systemImage: "square.and.arrow.down")
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isExporting || !machine.hasListenedThisRound)
                }

                if let prompt = coachingPromptForTree(tree) {
                    Button {
                        coachingPrompt = prompt
                    } label: {
                        Label("Coach my voice", systemImage: "mic.badge.plus")
                            .font(.callout)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("performanceBooth.coachMyVoice")
                    .accessibilityHint("Open the voice-acting coach for \(prompt.castDisplayName)")
                }

                if !machine.hasListenedThisRound {
                    Text("Listen at least once before saving.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let exportError {
                    Text(exportError)
                        .font(.caption)
                        .foregroundStyle(DialoguePalette.rust)
                }

                Button("Pick a different tree") {
                    readAloudService.stop()
                    machine.reselectTree()
                }
                .font(.callout)
                .foregroundStyle(DialoguePalette.inkBlue)
            }
            .padding()
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            ContentUnavailableView(
                "Tree no longer available",
                systemImage: "exclamationmark.triangle",
                description: Text("This tree was removed. Pick another one.")
            )
            .onAppear { machine.reselectTree() }
        }
    }

    // MARK: - Exported

    @ViewBuilder
    private func exportedSurface(treeID: UUID, audioURL: URL) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Recording ready", systemImage: "checkmark.seal.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(DialoguePalette.rust)

            Text("Your characters are on tape. Send the file via AirDrop, Files, or Messages.")
                .font(.callout)
                .foregroundStyle(.secondary)

            ShareLink(item: audioURL) {
                Label("Share the recording", systemImage: "square.and.arrow.up")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(DialoguePalette.rust)

            Button("Perform another") {
                machine.reselectTree()
            }
            .font(.callout)
            .foregroundStyle(DialoguePalette.inkBlue)
        }
        .padding()
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Side effects

    private func runExport(tree: DialogueTree) async {
        isExporting = true
        exportError = nil
        do {
            let url = try await exporter.exportAIFF(tree: tree)
            machine.markExported(audioURL: url)
            audioExportCount += 1
            performanceBoothExportCount += 1
            DialogueQuestAnalytics.shared.track(
                .performanceBoothExported,
                properties: ["node_count_bucket": Self.nodeCountBucket(for: tree)]
            )
        } catch let DialogueAudioExporter.ExportError.writeFailed(reason) {
            exportError = "Couldn't save the recording: \(reason)"
        } catch DialogueAudioExporter.ExportError.emptyTree {
            exportError = "This tree has no lines yet to read aloud."
        } catch {
            exportError = "Couldn't save the recording. Try again."
        }
        isExporting = false
    }

    private func refresh() {
        do {
            let descriptor = FetchDescriptor<PersistentDialogueTree>(
                predicate: #Predicate { $0.isPublished == true },
                sortBy: [SortDescriptor(\.lastEditedAt, order: .reverse)]
            )
            let models = try modelContext.fetch(descriptor)
            entries = models.map { DialoguePersistenceService.projection(of: $0) }
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

    /// Reduce-Transparency-aware panel background. Mirrors the
    /// `WriteTabView.panelBackground` helper so the booth surfaces honor
    /// the same accessibility setting.
    @ViewBuilder
    private var panelBackground: some View {
        if reduceTransparency {
            DialoguePalette.cream
        } else {
            Color.clear.background(.thinMaterial)
        }
    }

    private static func nodeCountBucket(for tree: DialogueTree) -> String {
        let count = tree.nodes.count
        switch count {
        case ..<5: return "lt5"
        case 5...10: return "5to10"
        case 11...15: return "11to15"
        case 16...24: return "16to24"
        default: return "25plus"
        }
    }
}
