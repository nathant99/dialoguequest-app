import SwiftUI
import Models
import SharedUI

/// Phase 1 dialogue-tree builder. Pure SwiftUI list-of-nodes editor — no
/// 2-D graph layout in Phase 1 (deferred to Phase 2 once the basics are
/// shippable). Per `Docs/TECHNICAL_DESIGN.md` § "Open Questions" the
/// always-visible side panel UX wins over on-tap-reveal at the kid-9-14
/// register.
struct DialogueTreeBuilderView: View {
    @Binding var machine: DialogueTreeMachine
    /// Called whenever the kid moves the selection to a branch-point —
    /// AppFeature's wiring fires `PatterMentor.branchCheck` and surfaces
    /// the result in the right-hand panel.
    var onSelectBranchPoint: ((UUID) -> Void)?

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerBar
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(orderedNodes()) { node in
                        nodeRow(node)
                    }
                }
                .padding(.horizontal)
            }
            footerBar
        }
        .background(DialoguePalette.cream.opacity(0.6))
    }

    // MARK: - Subviews

    private var headerBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(machine.tree.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)
            HStack(spacing: 12) {
                if let mood = machine.tree.mood {
                    Label(mood.displayName, systemImage: "sparkles")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(machine.tree.nodes.count) / \(DialogueTree.NodeCountConstraint.phase1Max) nodes")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .accessibilityHint("Phase 1 trees can have up to \(DialogueTree.NodeCountConstraint.phase1Max) nodes.")
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }

    @ViewBuilder
    private func nodeRow(_ node: DialogueNode) -> some View {
        let isSelected = machine.selectedNodeID == node.id
        let speaker = machine.tree.character(for: node)?.name ?? "Unknown"
        let depth = depth(for: node.id)

        HStack(alignment: .top, spacing: 8) {
            Spacer().frame(width: CGFloat(depth) * 16)
            Button {
                machine.selectedNodeID = node.id
                if node.isBranchPoint { onSelectBranchPoint?(node.id) }
            } label: {
                nodeBubble(node: node, speaker: speaker, isSelected: isSelected)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text("\(speaker): \(node.surfaceText.isEmpty ? "empty line" : node.surfaceText)"))
            .accessibilityHint(Text(isSelected ? "Selected. Open inspector to edit." : "Tap to inspect and edit."))
        }
        .padding(.vertical, 2)
    }

    private func nodeBubble(node: DialogueNode, speaker: String, isSelected: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text(speaker)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DialoguePalette.rust)
                Spacer()
                tagBadge(node.tag)
                if node.isBranchPoint {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.caption)
                        .foregroundStyle(DialoguePalette.rust)
                        .accessibilityLabel("Branch point")
                }
                if node.id == machine.tree.rootNodeID {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(DialoguePalette.warmGold)
                        .accessibilityLabel("Opening line")
                }
            }
            Text(node.surfaceText.isEmpty ? "Tap to write this line" : node.surfaceText)
                .font(.callout)
                .foregroundStyle(node.surfaceText.isEmpty ? .secondary : DialoguePalette.inkBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isSelected ? DialoguePalette.warmGold.opacity(0.25) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(isSelected ? DialoguePalette.rust : DialoguePalette.rust.opacity(0.25), lineWidth: 1)
        )
    }

    private func tagBadge(_ tag: DialogueTag) -> some View {
        let label: String
        let symbol: String
        switch tag {
        case .said(let verb):
            label = "\u{201C}\(verb)\u{201D}"
            symbol = "quote.bubble"
        case .action(let beat):
            label = beat.isEmpty ? "beat" : String(beat.prefix(18))
            symbol = "figure.walk"
        case .unattributed:
            label = "no tag"
            symbol = "wind"
        }
        return Label(label, systemImage: symbol)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule().fill(DialoguePalette.cream)
            )
            .accessibilityHidden(true)
    }

    private var footerBar: some View {
        HStack(spacing: 12) {
            if let selected = machine.selectedNode {
                Button {
                    if let first = machine.tree.characters.first {
                        let speaker = nextSpeakerID(after: selected.speakerID) ?? first.id
                        machine.appendChild(to: selected.id, speakerID: speaker)
                    }
                } label: {
                    Label("Add line", systemImage: "plus.bubble")
                }
                .buttonStyle(.borderedProminent)
                .tint(DialoguePalette.rust)
                .disabled(machine.tree.nodes.count >= DialogueTree.NodeCountConstraint.phase1Max)

                if selected.id != machine.tree.rootNodeID && selected.isLeaf {
                    Button(role: .destructive) {
                        machine.removeLeaf(selected.id)
                    } label: {
                        Label("Remove", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                }
            }
            Spacer()
            Text("\(machine.tree.nodes.count) of \(DialogueTree.NodeCountConstraint.phase1Min) min")
                .font(.caption.monospacedDigit())
                .foregroundStyle(machine.canPublish ? .green : .secondary)
                .accessibilityHint(
                    Text(
                        machine.canPublish
                        ? "Ready to publish."
                        : "You need at least \(DialogueTree.NodeCountConstraint.phase1Min) lines to publish."
                    )
                )
        }
        .padding()
        .background(reduceTransparency ? AnyShapeStyle(DialoguePalette.cream) : AnyShapeStyle(.thinMaterial))
    }

    // MARK: - Helpers

    /// Layout order: depth-first by `children` starting from the root.
    private func orderedNodes() -> [DialogueNode] {
        var result: [DialogueNode] = []
        var seen: Set<UUID> = []
        func visit(_ id: UUID) {
            guard !seen.contains(id), let node = machine.tree.node(for: id) else { return }
            seen.insert(id)
            result.append(node)
            for childID in node.children { visit(childID) }
        }
        visit(machine.tree.rootNodeID)
        // Append orphans (shouldn't happen, but defensive).
        for node in machine.tree.nodes where !seen.contains(node.id) {
            result.append(node)
        }
        return result
    }

    private func depth(for id: UUID) -> Int {
        var depth = 0
        var current = id
        var seen: Set<UUID> = []
        while current != machine.tree.rootNodeID, !seen.contains(current) {
            seen.insert(current)
            if let parent = machine.tree.nodes.first(where: { $0.children.contains(current) }) {
                current = parent.id
                depth += 1
            } else {
                break
            }
        }
        return depth
    }

    /// Pick the next character (the one NOT speaking the prior line) so
    /// new lines alternate by default — kid can change in the Inspector.
    private func nextSpeakerID(after speakerID: UUID) -> UUID? {
        guard machine.tree.characters.count >= 2 else { return nil }
        return machine.tree.characters.first { $0.id != speakerID }?.id
    }
}

#Preview {
    struct Harness: View {
        @State var machine: DialogueTreeMachine = {
            let iris = DialogueCharacterRef(
                name: "Iris",
                voiceRegister: "clipped",
                sampleLines: ["I guess."]
            )
            let cal = DialogueCharacterRef(
                name: "Cal",
                voiceRegister: "stalling",
                sampleLines: ["So, like, yeah."]
            )
            let root = DialogueNode(speakerID: iris.id, surfaceText: "Did you mean it?", tag: .said("said"))
            let reply = DialogueNode(speakerID: cal.id, surfaceText: "Mean what?", tag: .action("Cal looked away."))
            let rootWithChild = DialogueNode(
                id: root.id,
                speakerID: root.speakerID,
                surfaceText: root.surfaceText,
                tag: root.tag,
                children: [reply.id]
            )
            let tree = DialogueTree(
                title: "After the test",
                characters: [iris, cal],
                nodes: [rootWithChild, reply],
                rootNodeID: rootWithChild.id,
                mood: .quietConflict
            )
            return DialogueTreeMachine(stage: .editingTree, tree: tree, selectedNodeID: rootWithChild.id)
        }()

        var body: some View {
            DialogueTreeBuilderView(machine: $machine)
        }
    }
    return Harness()
}
