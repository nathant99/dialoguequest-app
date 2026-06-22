import SwiftUI
import ForgeGamification
import ForgeUI
import Services
import SharedUI

/// XP / streak / badge dashboard. Phase 1 surfaces are deliberately
/// modest — counts + ForgeUI components only. Charts join in Phase 2
/// when more sessions of data are recorded.
struct ProgressDashboardView: View {
    /// Total XP earned, persisted by the calling layer; passed in to keep
    /// the view a pure renderer.
    var totalXP: Int = 0
    var currentStreak: Int = 0
    var availableFreezes: Int = 2
    var earnedBadgeIDs: Set<String> = []

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private let config = DialogueQuestGamification.makeConfig()

    var body: some View {
        let engine = XPEngine(config: config)
        let level = engine.level(for: totalXP)
        let progress = engine.xpProgress(currentXP: totalXP)

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForgeXPBar(
                    currentXP: totalXP,
                    xpForNextLevel: engine.xpRequired(forLevel: level + 1),
                    level: level
                )
                .accessibilityLabel("Level \(level), \(Int(progress * 100)) percent to next level.")

                HStack(spacing: 12) {
                    ForgeStreakBadge(streak: currentStreak, isActive: currentStreak > 0)
                        .accessibilityLabel(
                            currentStreak == 0
                            ? "Streak: not started."
                            : "Streak: \(currentStreak) day\(currentStreak == 1 ? "" : "s")."
                        )
                    Text("\(availableFreezes) streak freeze\(availableFreezes == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("\(availableFreezes) streak freeze\(availableFreezes == 1 ? "" : "s") remaining.")
                    Spacer()
                }

                Text("Badges")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(DialoguePalette.rust)

                if config.achievementDefinitions.isEmpty {
                    Text("No badges available yet.")
                        .foregroundStyle(.secondary)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                        ForEach(config.achievementDefinitions) { def in
                            badgeCard(for: def, earned: earnedBadgeIDs.contains(def.id))
                        }
                    }
                }
            }
            .padding()
        }
        .background(DialoguePalette.cream.opacity(0.6))
    }

    private func badgeCard(for def: AchievementDefinition, earned: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: earned ? "checkmark.seal.fill" : "lock.fill")
                    .foregroundStyle(earned ? DialoguePalette.rust : .secondary)
                Spacer()
                Text("\(def.xpValue) XP")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Text(def.title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)
            Text(def.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(reduceTransparency ? AnyShapeStyle(DialoguePalette.cream) : AnyShapeStyle(.thinMaterial))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .opacity(earned ? 1 : 0.55)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(earned ? "Earned" : "Locked") badge: \(def.title). Worth \(def.xpValue) XP.")
        .accessibilityHint(earned ? Text("Earned. \(def.description)") : Text("Locked. \(def.description)"))
    }
}

#Preview {
    ProgressDashboardView(
        totalXP: 120,
        currentStreak: 3,
        availableFreezes: 1,
        earnedBadgeIDs: ["first_tree_authored", "first_subtext_confirmed"]
    )
}
