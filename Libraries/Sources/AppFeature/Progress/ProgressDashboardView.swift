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
    /// Per-pillar mastery bars (Priority B → P-follow). Loaded by the host
    /// (`ProgressTabView`) from `DialogueCraftMasteryService` so this view stays
    /// a pure renderer. Empty on a fresh install — the "Your craft" section
    /// gates its own visibility on any non-zero bar.
    var craftBars: [DialogueCraftMasteryService.CraftMasteryReadout] = []
    /// Display name of the pillar Patter suggests focusing on next, or `nil`.
    var craftFocusName: String? = nil

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

                craftSection

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

    /// Per-pillar "Your craft" section. Renders only after the kid has
    /// published at least one tree (so at least one bar is non-zero) — a fresh
    /// install shows just XP + streak + badges. Shows all six pillars so the
    /// kid sees the whole craft map, including not-yet-started ones at 0%.
    @ViewBuilder
    private var craftSection: some View {
        if craftBars.contains(where: { $0.score > 0 }) {
            Text("Your craft")
                .font(.title3.weight(.semibold))
                .foregroundStyle(DialoguePalette.rust)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(craftBars) { bar in
                    craftBar(bar)
                }
                if let craftFocusName {
                    Text("Patter suggests focusing on \(craftFocusName) next.")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(DialoguePalette.inkBlue)
                        .padding(.top, 2)
                        .accessibilityLabel("Patter suggests focusing on \(craftFocusName) next.")
                }
            }
            .padding()
            .background(reduceTransparency ? AnyShapeStyle(DialoguePalette.cream) : AnyShapeStyle(.thinMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func craftBar(_ bar: DialogueCraftMasteryService.CraftMasteryReadout) -> some View {
        let percent = Int((bar.score * 100).rounded())
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(bar.displayName)
                    .font(.subheadline)
                    .foregroundStyle(DialoguePalette.inkBlue)
                Spacer()
                if bar.isMastered {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(DialoguePalette.rust)
                }
                Text("\(percent)%")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: bar.score)
                .tint(DialoguePalette.rust)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(bar.displayName): \(percent) percent\(bar.isMastered ? ", solid" : "").")
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
        earnedBadgeIDs: ["first_tree_authored", "first_subtext_confirmed"],
        craftBars: [
            .init(topic: .voiceConsistency, score: 0.88, isMastered: true),
            .init(topic: .subtextDetection, score: 0.62, isMastered: false),
            .init(topic: .tagBalance, score: 0.45, isMastered: false),
            .init(topic: .branchMeaningfulness, score: 0.30, isMastered: false),
            .init(topic: .multiListenerSubtext, score: 0, isMastered: false),
            .init(topic: .triangleDynamics, score: 0, isMastered: false)
        ],
        craftFocusName: "Subtext"
    )
}
