import SwiftUI
import Models
import Services
import AIMentor
import SharedUI

/// Phase 1 Write tab — orchestrates character authoring → tree editing →
/// review. Holds the `PatterMentor` instance + analyzer state and feeds
/// derived data into the Builder / Inspector / Panels / Dashboard.
struct WriteTabView: View {
    @State private var machine = DialogueTreeMachine()
    @State private var mentor = PatterMentor()
    @State private var activeBranchPointID: UUID?

    private let scorer = BranchMeaningfulnessScorer()
    private let voiceAnalyzer = VoiceConsistencyAnalyzer()
    private let tagBalancer = TagBalancer()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(navigationTitle)
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
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                publishStripe
            }
            .padding()
        }
        .background(DialoguePalette.cream.opacity(0.6))
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
        .background(.thinMaterial)
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
