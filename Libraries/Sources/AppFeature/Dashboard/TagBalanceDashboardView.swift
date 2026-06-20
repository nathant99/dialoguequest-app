import SwiftUI
import Charts
import Models
import Services
import SharedUI

/// Per-character + per-tree attribution-tag bar chart. Warning ribbon
/// surfaces when a single classification crosses
/// `TagBalancer.imbalanceThreshold` (70%).
struct TagBalanceDashboardView: View {
    let report: TagBalancer.TreeReport

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tag balance")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(DialoguePalette.rust)
                Spacer()
                if report.hasImbalance {
                    Label("Imbalanced", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                        .accessibilityHint("One attribution style is more than 70% of the tree's lines.")
                }
            }

            if report.totalLineCount == 0 {
                Text("Write a few lines to see attribution patterns.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                Chart {
                    ForEach(report.perCharacter) { character in
                        ForEach(Self.barEntries(for: character)) { entry in
                            BarMark(
                                x: .value("Lines", entry.count),
                                y: .value("Character", character.name)
                            )
                            .foregroundStyle(by: .value("Style", entry.label))
                            .annotation(position: .trailing, alignment: .leading, spacing: 4) {
                                if entry.count > 0 {
                                    Text("\(entry.count)")
                                        .font(.caption2.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .chartLegend(position: .bottom, alignment: .center)
                .frame(height: max(80, CGFloat(report.perCharacter.count) * 64))
                .chartForegroundStyleScale([
                    Self.label(for: .saidVerb): DialoguePalette.rust,
                    Self.label(for: .actionBeat): DialoguePalette.warmGold,
                    Self.label(for: .unattributed): DialoguePalette.inkBlue.opacity(0.5)
                ])

                if let dominant = report.dominant {
                    Text(Self.imbalanceMessage(for: dominant))
                        .font(.footnote)
                        .foregroundStyle(.orange)
                        .accessibilityLabel(Text(Self.imbalanceMessage(for: dominant)))
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private struct BarEntry: Identifiable {
        let id: String
        let label: String
        let count: Int
    }

    private static func barEntries(for character: TagBalancer.CharacterReport) -> [BarEntry] {
        DialogueTag.Classification.allCases.map { classification in
            BarEntry(
                id: "\(character.id)-\(classification.rawValue)",
                label: label(for: classification),
                count: character.counts[classification] ?? 0
            )
        }
    }

    private static func label(for classification: DialogueTag.Classification) -> String {
        switch classification {
        case .saidVerb: return "\u{201C}said\u{201D}"
        case .actionBeat: return "action"
        case .unattributed: return "no tag"
        }
    }

    private static func imbalanceMessage(for dominant: DialogueTag.Classification) -> String {
        switch dominant {
        case .saidVerb:
            return "Most lines end with \u{201C}said\u{201D}. Try one action beat — a shrug, a glance — to vary the rhythm."
        case .actionBeat:
            return "Lots of action beats. Drop one and let a plain \u{201C}said\u{201D} carry the line."
        case .unattributed:
            return "Many lines have no attribution. Add one \u{201C}X said\u{201D} so the reader can keep track."
        }
    }
}

#Preview {
    let a = DialogueCharacterRef(name: "Iris", voiceRegister: "", sampleLines: [])
    let b = DialogueCharacterRef(name: "Cal", voiceRegister: "", sampleLines: [])
    let lines: [DialogueNode] = [
        DialogueNode(speakerID: a.id, surfaceText: "x", tag: .said("said")),
        DialogueNode(speakerID: a.id, surfaceText: "y", tag: .said("murmured")),
        DialogueNode(speakerID: b.id, surfaceText: "z", tag: .action("Cal looked away."))
    ]
    let tree = DialogueTree(title: "t", characters: [a, b], nodes: lines, rootNodeID: lines[0].id)
    let report = TagBalancer().report(for: tree)
    return TagBalanceDashboardView(report: report).padding()
}
