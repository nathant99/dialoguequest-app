import SwiftUI
import Models
import SharedUI

/// Right-hand inspector: edit the selected node's speaker + line + tag.
struct NodeInspectorView: View {
    @Binding var machine: DialogueTreeMachine

    var body: some View {
        if let selected = machine.selectedNode {
            inspector(for: selected)
        } else {
            ContentUnavailableView(
                "Pick a line to edit",
                systemImage: "hand.tap",
                description: Text("Tap any line in the tree to edit its speaker, words, or attribution.")
            )
        }
    }

    private func inspector(for node: DialogueNode) -> some View {
        Form {
            Section("Speaker") {
                Picker("Speaker", selection: speakerBinding(for: node)) {
                    ForEach(machine.tree.characters) { character in
                        Text(character.name).tag(character.id)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section("Line") {
                TextField("What they say (or do)", text: surfaceTextBinding(for: node), axis: .vertical)
                    .lineLimit(2...6)
            }
            Section("Attribution") {
                Picker("Tag style", selection: classificationBinding(for: node)) {
                    Text("said").tag(DialogueTag.Classification.saidVerb)
                    Text("action beat").tag(DialogueTag.Classification.actionBeat)
                    Text("no tag").tag(DialogueTag.Classification.unattributed)
                }
                .pickerStyle(.segmented)

                switch node.tag {
                case .said:
                    TextField("Verb (said, murmured, asked…)", text: saidVerbBinding(for: node))
                case .action:
                    TextField("Action beat (e.g., 'looked away')", text: actionBeatBinding(for: node), axis: .vertical)
                        .lineLimit(1...3)
                case .unattributed:
                    Text("This line stands alone — no \u{201C}said\u{201D} or action beat.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            if let subtext = node.inferredSubtext, !subtext.isEmpty {
                Section("Subtext") {
                    Text(subtext)
                        .font(.callout)
                        .foregroundStyle(DialoguePalette.inkBlue)
                    Text("Confirmed via the subtext panel.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Bindings

    private func speakerBinding(for node: DialogueNode) -> Binding<UUID> {
        Binding(
            get: { node.speakerID },
            set: { newSpeaker in
                machine.updateNode(
                    DialogueNode(
                        id: node.id,
                        speakerID: newSpeaker,
                        surfaceText: node.surfaceText,
                        inferredSubtext: node.inferredSubtext,
                        tag: node.tag,
                        children: node.children,
                        createdAt: node.createdAt
                    )
                )
            }
        )
    }

    private func surfaceTextBinding(for node: DialogueNode) -> Binding<String> {
        Binding(
            get: { node.surfaceText },
            set: { newText in
                machine.updateNode(
                    DialogueNode(
                        id: node.id,
                        speakerID: node.speakerID,
                        surfaceText: newText,
                        inferredSubtext: node.inferredSubtext,
                        tag: node.tag,
                        children: node.children,
                        createdAt: node.createdAt
                    )
                )
            }
        )
    }

    private func classificationBinding(for node: DialogueNode) -> Binding<DialogueTag.Classification> {
        Binding(
            get: { node.tag.classification },
            set: { newClassification in
                let newTag: DialogueTag
                switch newClassification {
                case .saidVerb:
                    if case .said = node.tag { newTag = node.tag } else { newTag = .said("said") }
                case .actionBeat:
                    if case .action = node.tag { newTag = node.tag } else { newTag = .action("") }
                case .unattributed:
                    newTag = .unattributed
                }
                machine.updateNode(
                    DialogueNode(
                        id: node.id,
                        speakerID: node.speakerID,
                        surfaceText: node.surfaceText,
                        inferredSubtext: node.inferredSubtext,
                        tag: newTag,
                        children: node.children,
                        createdAt: node.createdAt
                    )
                )
            }
        )
    }

    private func saidVerbBinding(for node: DialogueNode) -> Binding<String> {
        Binding(
            get: {
                if case .said(let verb) = node.tag { return verb } else { return "said" }
            },
            set: { newVerb in
                machine.updateNode(
                    DialogueNode(
                        id: node.id,
                        speakerID: node.speakerID,
                        surfaceText: node.surfaceText,
                        inferredSubtext: node.inferredSubtext,
                        tag: .said(newVerb),
                        children: node.children,
                        createdAt: node.createdAt
                    )
                )
            }
        )
    }

    private func actionBeatBinding(for node: DialogueNode) -> Binding<String> {
        Binding(
            get: {
                if case .action(let beat) = node.tag { return beat } else { return "" }
            },
            set: { newBeat in
                machine.updateNode(
                    DialogueNode(
                        id: node.id,
                        speakerID: node.speakerID,
                        surfaceText: node.surfaceText,
                        inferredSubtext: node.inferredSubtext,
                        tag: .action(newBeat),
                        children: node.children,
                        createdAt: node.createdAt
                    )
                )
            }
        )
    }
}
