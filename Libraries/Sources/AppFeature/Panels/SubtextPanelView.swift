import SwiftUI
import Models
import AIMentor
import SharedUI

/// Side panel where Patter surfaces the AI-inferred subtext for the
/// selected line. Kid confirms or rejects — confirmation drives the
/// 'aha moment' the Phase 1 onboarding targets.
struct SubtextPanelView: View {
    @Binding var machine: DialogueTreeMachine
    let mentor: PatterMentor

    @State private var analysis: DialogueLineAnalysis?
    @State private var isAnalyzing: Bool = false

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subtext")
                .font(.title3.weight(.semibold))
                .foregroundStyle(DialoguePalette.rust)
                .accessibilityIdentifier("subtext.panel.heading")

            if let selected = machine.selectedNode, !selected.surfaceText.isEmpty {
                content(for: selected)
            } else {
                ContentUnavailableView(
                    "Write a line to analyze",
                    systemImage: "ear",
                    description: Text("Patter listens for what's NOT being said. Write a line first.")
                )
                .accessibilityIdentifier("subtext.panel.empty")
            }
        }
        .padding()
        .background(reduceTransparency ? AnyShapeStyle(DialoguePalette.cream) : AnyShapeStyle(.thinMaterial))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityIdentifier("subtext.panel")
        .task(id: machine.selectedNodeID) {
            await refresh()
        }
    }

    @ViewBuilder
    private func content(for node: DialogueNode) -> some View {
        Text("\u{201C}\(node.surfaceText)\u{201D}")
            .font(.callout)
            .italic()
            .foregroundStyle(DialoguePalette.inkBlue)

        if isAnalyzing {
            HStack {
                ProgressView()
                Text("Patter is listening…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } else if let analysis {
            VStack(alignment: .leading, spacing: 8) {
                Label("Patter hears:", systemImage: "ear.and.waveform")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DialoguePalette.rust)
                Text(analysis.inferredSubtext.isEmpty ? "No clear subtext here yet. Maybe try a smaller word or shorter beat?" : analysis.inferredSubtext)
                    .font(.callout)
                    .foregroundStyle(DialoguePalette.inkBlue)
                    .accessibilityIdentifier("subtext.panel.message")

                voiceScoreBar(score: analysis.voiceMatchScore)

                if !analysis.inferredSubtext.isEmpty {
                    HStack(spacing: 8) {
                        Button {
                            machine.confirmSubtext(for: node.id, inferredSubtext: analysis.inferredSubtext)
                        } label: {
                            Label("Yes, that's it", systemImage: "checkmark.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(DialoguePalette.rust)
                        .accessibilityIdentifier("subtext.panel.confirm")
                        .accessibilityHint("Save this subtext to the line and mark it confirmed.")

                        Button {
                            machine.rejectSubtext(for: node.id)
                        } label: {
                            Label("Not quite", systemImage: "arrow.counterclockwise")
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("subtext.panel.reject")
                        .accessibilityHint("Reject this subtext. Patter will not save it.")
                    }
                }
            }
        }
    }

    private func voiceScoreBar(score: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Voice match")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.0f%%", min(max(score, 0), 1) * 100))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: min(max(score, 0), 1))
                .progressViewStyle(.linear)
                .tint(score >= 0.65 ? .green : (score >= 0.4 ? DialoguePalette.warmGold : .red))
        }
    }

    private func refresh() async {
        guard let node = machine.selectedNode, !node.surfaceText.isEmpty else {
            analysis = nil
            return
        }
        isAnalyzing = true
        let result = await mentor.analyze(line: node.surfaceText, mood: machine.tree.mood)
        analysis = result
        isAnalyzing = false
    }
}
