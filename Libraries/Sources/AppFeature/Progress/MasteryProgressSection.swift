import SwiftUI
import Services
import SharedUI

/// The calm, intrapersonal "Your progress" card — a learning-milestone
/// shelf + an optional learner-set goal, built on the app's existing
/// on-device signals (published-tree count + craft-pillar mastery + XP
/// level). Per `Docs/HANDOFF_FROM_HUB_MASTERY_PROGRESSION_WEB_BACKPORT.md`.
///
/// Hard exclusions honored by construction: no leaderboard / normative
/// rank, no currency, no streak-guilt / scarcity. It RECOGNIZES progress
/// and names growth — it never gates anything. Verdict (earned/unearned)
/// is carried by icon fill + label, never colour alone.
struct MasteryProgressSection: View {
    let publishedTreeCount: Int
    let level: Int
    let craftBars: [DialogueCraftMasteryService.CraftMasteryReadout]

    /// The learner's optional goal — on-device, no identifier. `.none` by
    /// default (just exploring).
    @AppStorage("dq.masteryGoal") private var goalRaw: String = MasteryProgression.Goal.none.rawValue
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var progression: MasteryProgression {
        MasteryProgression(publishedTreeCount: publishedTreeCount, level: level, readouts: craftBars)
    }

    private var goal: MasteryProgression.Goal {
        MasteryProgression.Goal(rawValue: goalRaw) ?? .none
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your progress")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(DialoguePalette.rust)
                Spacer()
                Text("\(progression.earnedMilestoneCount) of \(progression.milestones.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("\(progression.earnedMilestoneCount) of \(progression.milestones.count) milestones reached.")
            }

            milestoneShelf
            goalRow
        }
        .padding()
        .background(reduceTransparency ? AnyShapeStyle(DialoguePalette.cream) : AnyShapeStyle(.thinMaterial))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var milestoneShelf: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
            ForEach(progression.milestones) { milestone in
                milestoneChip(milestone)
            }
        }
    }

    private func milestoneChip(_ milestone: MasteryProgression.Milestone) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: milestone.isEarned ? milestone.systemImage : "circle.dashed")
                .foregroundStyle(milestone.isEarned ? DialoguePalette.rust : Color.secondary)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text(milestone.isEarned ? "Reached" : milestone.detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DialoguePalette.cream.opacity(milestone.isEarned ? 0.9 : 0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .opacity(milestone.isEarned ? 1 : 0.7)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(milestone.isEarned ? "Reached" : "Not yet") milestone: \(milestone.title). \(milestone.detail)")
    }

    @ViewBuilder
    private var goalRow: some View {
        Divider().padding(.vertical, 2)

        HStack {
            Text("Your goal")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)
            Spacer()
            Menu {
                Picker("Goal", selection: $goalRaw) {
                    ForEach(MasteryProgression.Goal.allCases) { g in
                        Text(g.menuLabel).tag(g.rawValue)
                    }
                }
            } label: {
                Label(goal == .none ? "Set a goal" : "Change", systemImage: "target")
                    .font(.footnote)
            }
            .accessibilityHint("Choose an optional personal goal. Goals are just for you and never gate anything.")
        }

        if let gp = progression.progress(for: goal) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(goal.menuLabel)
                        .font(.footnote)
                        .foregroundStyle(DialoguePalette.inkBlue)
                    Spacer()
                    if gp.isMet {
                        Label("Done", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(DialoguePalette.rust)
                            .labelStyle(.titleAndIcon)
                    }
                    Text(gp.label)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                ProgressView(value: gp.fraction)
                    .tint(DialoguePalette.rust)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Goal: \(goal.menuLabel). \(gp.label).\(gp.isMet ? " Reached." : "")")
        } else {
            Text("Pick a personal goal to aim for — totally optional, and it only ever cheers you on.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
