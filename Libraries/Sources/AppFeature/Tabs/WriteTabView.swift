import SwiftUI
import Models
import Services
import AIMentor
import SharedUI

/// Phase 1 Write tab — orchestrates character authoring → tree editing →
/// review. Holds the `PatterMentor` instance + analyzer state and feeds
/// derived data into the Builder / Inspector / Panels / Dashboard.
struct WriteTabView: View {
    /// Progressive-disclosure: count of trees the kid has published. Maps
    /// to a `SessionTier` that caps the max tree size for early sessions
    /// (session 1 → 3 nodes; sessions 2-3 → 5; experienced → 15).
    @AppStorage("dq.publishedTreeCount") private var publishedTreeCount: Int = 0

    @State private var machine = DialogueTreeMachine()
    @State private var mentor = PatterMentor()
    @State private var castVoicing = CastVoicingService()
    @State private var reactionService: PatterReactionService?
    @State private var activeBranchPointID: UUID?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private let scorer = BranchMeaningfulnessScorer()
    private let voiceAnalyzer = VoiceConsistencyAnalyzer()
    private let tagBalancer = TagBalancer()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(navigationTitle)
        }
        .task {
            // UI-test seed (no-op in production). Must run BEFORE the tier
            // sync so the seeded machine's tier doesn't get clobbered.
            if let seeded = WriteTabUITestSeed.seedIfRequested(), machine.tree.nodes.isEmpty {
                machine = seeded
            }
            // Sync the tier on initial appear so the machine's cap matches
            // the kid's experience even before they publish anything new.
            let tier = DialogueTree.NodeCountConstraint.SessionTier(
                publishedCount: publishedTreeCount
            )
            if machine.sessionTier != tier {
                machine.sessionTier = tier
            }
            // Lazy-build the reaction service so it captures the
            // `@State`-owned mentor + cast-voicing references. Built once
            // per Write-tab appear; idempotent on re-task fire.
            if reactionService == nil {
                reactionService = PatterReactionService(
                    mentor: mentor,
                    castVoicing: castVoicing
                )
            }
        }
        .task(id: machine.selectedNodeID) {
            // Fire `onBranchPointSelected` whenever the kid lands on a
            // node that branches. Cast voicing (Sprig) wakes up via
            // `CastVoicingService` when the feature flag is on.
            guard let service = reactionService else { return }
            guard let selected = machine.selectedNode, selected.isBranchPoint else { return }
            await service.onBranchPointSelected(branchPointID: selected.id, mood: machine.tree.mood)
        }
        .task(id: machine.tree.nodes.count) {
            // Fire `onTreeChanged` after every mutation so Weigh's
            // tag-balance scaffold wakes up when the dominant tag-class
            // crosses a threshold. Tied to node-count so the task ID
            // changes on each append / remove (and not on cosmetic edits
            // that don't change topology — those don't move tag balance).
            guard let service = reactionService else { return }
            await service.onTreeChanged(machine.tree)
        }
        .onChange(of: machine.confirmedSubtextLineIDs) { oldSet, newSet in
            // The kid confirmed a subtext. Glance affirms via cast voicing.
            guard newSet.count > oldSet.count else { return }
            guard let service = reactionService else { return }
            Task { await service.onSubtextConfirmed(mood: machine.tree.mood) }
        }
        .onChange(of: machine.reflectedBranchPointIDs) { oldSet, newSet in
            // The kid completed a branch reflection. Sprig affirms.
            guard newSet.count > oldSet.count else { return }
            guard let service = reactionService else { return }
            Task { await service.onBranchReflectionConfirmed(mood: machine.tree.mood) }
        }
        .onChange(of: machine.stage) { _, newStage in
            // Bump the published-tree counter when the kid ships a tree.
            // Pure side-effect; the AppStorage value is the source of truth
            // for the next session's tier — current session keeps its cap.
            if newStage == .published {
                publishedTreeCount += 1
            }
        }
        .sheet(item: branchSheetBinding) { branchID in
            BranchMeaningfulnessCheckView(
                machine: $machine,
                mentor: mentor,
                branchPointID: branchID.id,
                onClose: { activeBranchPointID = nil }
            )
            .presentationDetents([.medium, .large])
        }
    }

    @ViewBuilder
    private var content: some View {
        switch machine.stage {
        case .authoringCharacters:
            CharacterAuthoringView(machine: $machine)
        case .editingTree, .reviewing, .published:
            editingSurface
        }
    }

    private var editingSurface: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DialogueTreeBuilderView(machine: $machine) { branchPointID in
                    activeBranchPointID = branchPointID
                }
                .frame(minHeight: 360)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                SubtextPanelView(machine: $machine, mentor: mentor)

                TagBalanceDashboardView(report: tagBalancer.report(for: machine.tree))

                NodeInspectorView(machine: $machine)
                    .frame(minHeight: 280)
                    .padding()
                    .background(panelBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                if let voicing = castVoicing.lastVoicing {
                    CastVoicingChip(voicing: voicing)
                        .transition(
                            reduceMotion
                            ? .opacity
                            : .opacity.combined(with: .scale(scale: 0.95, anchor: .leading))
                        )
                }

                publishStripe
            }
            .padding()
            .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: castVoicing.lastVoicing?.id)
        }
        .background(DialoguePalette.cream.opacity(0.6))
    }

    /// Reduce-Transparency-aware background — per `.claude/rules/liquid-glass.md`
    /// glass + thin-material surfaces must collapse to a solid palette tint
    /// when `accessibilityReduceTransparency` is on, so the background isn't
    /// fully translucent (and so a low-vision reader keeps the surface
    /// boundary visible).
    @ViewBuilder
    private var panelBackground: some View {
        if reduceTransparency {
            DialoguePalette.cream
        } else {
            Color.clear.background(.thinMaterial)
        }
    }

    private var publishStripe: some View {
        let report = scorer.score(
            tree: machine.tree,
            reflectedBranchPointIDs: machine.reflectedBranchPointIDs
        )
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Branches reflected upon")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("\(report.reflectedBranchPointCount) of \(report.branchPointCount)")
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(DialoguePalette.inkBlue)
                if machine.sessionTier != .experienced {
                    Text("\(machine.tree.nodes.count) of \(machine.maxNodes) lines (Session ladder)")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button {
                if machine.canPublish {
                    machine.markPublished()
                }
            } label: {
                Label(
                    machine.stage == .published ? "Published" : "Publish",
                    systemImage: machine.stage == .published ? "checkmark.seal.fill" : "paperplane.fill"
                )
            }
            .buttonStyle(.borderedProminent)
            .tint(DialoguePalette.rust)
            .disabled(!machine.canPublish || machine.stage == .published)
            .accessibilityHint(
                machine.canPublish
                ? Text("Mark the dialogue tree as ready for the anthology.")
                : Text("You need at least \(DialogueTree.NodeCountConstraint.phase1Min) lines to publish.")
            )
        }
        .padding()
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var navigationTitle: String {
        switch machine.stage {
        case .authoringCharacters: return "Cast the scene"
        case .editingTree: return machine.tree.title
        case .reviewing: return "Review"
        case .published: return "Published"
        }
    }

    /// Identifiable wrapper so we can drive `.sheet(item:)` off an
    /// optional UUID. SwiftUI requires Identifiable, not raw UUID.
    private struct PendingBranchSheet: Identifiable, Hashable {
        let id: UUID
    }

    private var branchSheetBinding: Binding<PendingBranchSheet?> {
        Binding(
            get: { activeBranchPointID.map(PendingBranchSheet.init) },
            set: { activeBranchPointID = $0?.id }
        )
    }
}

#Preview {
    WriteTabView()
}
