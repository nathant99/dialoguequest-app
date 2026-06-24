import SwiftUI
import Models
import AIMentor
import Services
import SharedUI

/// Phase 2 multi-listener picker that surfaces inside the existing
/// `SubtextPanelView` when a triangle scene is active. Shows per-listener
/// inferred subtexts side-by-side so the kid can pick which reading
/// matches the line they wrote.
///
/// Visible ONLY when:
/// - `dq.experiments.thirdCharacter` is on (gates the Phase 2 surface)
/// - The tree has ≥3 characters
/// - The selected node has non-empty surfaceText
/// - `MultiListenerCandidates.pair(speakerID:characters:)` returns a pair
///   (i.e., the speaker is in the cast + ≥2 other listener candidates exist)
///
/// The kid can confirm one of the listener subtexts as the canonical
/// `inferredSubtext` for the node — same confirm path as the Phase 1
/// single-line analysis, just routed through whichever listener
/// interpretation matched their authoring intent.
struct MultiListenerSubtextDisclosure: View {
    @Binding var machine: DialogueTreeMachine
    let node: DialogueNode
    let mentor: PatterMentor

    @State private var analysis: MultiSpeakerSubtextAnalysis?
    @State private var isAnalyzing: Bool = false
    @State private var isExpanded: Bool = false

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        if let pair = listenerPair {
            DisclosureGroup(isExpanded: $isExpanded) {
                contentForExpanded(pair: pair)
                    .padding(.top, 8)
            } label: {
                Label("What does each listener hear?", systemImage: "person.2.wave.2")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DialoguePalette.rust)
                    .accessibilityIdentifier("subtext.multi.disclosure")
                    .accessibilityHint("Show how the two listeners might hear the same line differently.")
            }
            .padding(.top, 4)
            .task(id: disclosureTaskKey(pair: pair)) {
                guard isExpanded else { return }
                await refresh(pair: pair)
            }
        }
    }

    // MARK: - Listener pair

    private var listenerPair: MultiListenerCandidates.Pair? {
        guard TriangleAuthoringFeatureFlag.isEnabled else { return nil }
        return MultiListenerCandidates.pair(
            speakerID: node.speakerID,
            characters: machine.tree.characters
        )
    }

    private func disclosureTaskKey(pair: MultiListenerCandidates.Pair) -> String {
        // Re-runs when the line, speaker, or listener pair changes, AND
        // when the disclosure flips open.
        "\(node.id.uuidString)|\(pair.speaker.id.uuidString)|\(pair.primaryListener.id.uuidString)|\(pair.secondaryListener.id.uuidString)|\(isExpanded)"
    }

    // MARK: - Expanded content

    @ViewBuilder
    private func contentForExpanded(pair: MultiListenerCandidates.Pair) -> some View {
        if isAnalyzing {
            HStack {
                ProgressView()
                Text("Patter is listening for both ears…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } else if let analysis {
            VStack(alignment: .leading, spacing: 12) {
                listenerRow(
                    listenerName: pair.primaryListener.name,
                    inferredSubtext: analysis.primaryListenerSubtext,
                    confirmIdentifier: "subtext.multi.primary.confirm",
                    confirmAccessibilityHint: "Save this as what \(pair.primaryListener.name) hears for this line."
                )
                Divider()
                listenerRow(
                    listenerName: pair.secondaryListener.name,
                    inferredSubtext: analysis.secondaryListenerSubtext,
                    confirmIdentifier: "subtext.multi.secondary.confirm",
                    confirmAccessibilityHint: "Save this as what \(pair.secondaryListener.name) hears for this line."
                )
            }
            .padding()
            .background(reduceTransparency ? AnyShapeStyle(DialoguePalette.cream) : AnyShapeStyle(.thinMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    @ViewBuilder
    private func listenerRow(
        listenerName: String,
        inferredSubtext: String,
        confirmIdentifier: String,
        confirmAccessibilityHint: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("\(listenerName) hears:", systemImage: "ear")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DialoguePalette.rust)
            Text(displaySubtext(inferredSubtext))
                .font(.callout)
                .foregroundStyle(DialoguePalette.inkBlue)
                .accessibilityIdentifier("\(confirmIdentifier).message")

            if !inferredSubtext.isEmpty {
                Button {
                    machine.confirmSubtext(for: node.id, inferredSubtext: inferredSubtext)
                    DialogueSensoryService.shared.subtextRevealed()
                } label: {
                    Label("Yes — that's what I meant for \(listenerName)", systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(.bordered)
                .tint(DialoguePalette.rust)
                .accessibilityIdentifier(confirmIdentifier)
                .accessibilityHint(confirmAccessibilityHint)
            }
        }
    }

    private func displaySubtext(_ value: String) -> String {
        value.isEmpty
            ? "No clear subtext for this listener. Patter doesn't hear a second layer here."
            : value
    }

    // MARK: - Refresh

    @MainActor
    private func refresh(pair: MultiListenerCandidates.Pair) async {
        isAnalyzing = true
        let result = await mentor.analyzeMultiSpeaker(
            line: node.surfaceText,
            speakerName: pair.speaker.name,
            primaryListenerName: pair.primaryListener.name,
            secondaryListenerName: pair.secondaryListener.name,
            mood: machine.tree.mood
        )
        analysis = result
        isAnalyzing = false
    }
}
