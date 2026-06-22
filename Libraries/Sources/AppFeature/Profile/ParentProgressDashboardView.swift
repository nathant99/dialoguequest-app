import SwiftUI
import Services
import SharedUI
import ForgeGamification

/// Parent-facing progress dashboard. Surfaces what the kid has done in
/// DialogueQuest mapped to the primary CCSS standard
/// (CCSS.ELA-Literacy.W.6-8.3.B — narrative dialogue) plus secondary
/// pedagogical surfaces (subtext detection, branch meaningfulness,
/// tag-balance dashboard).
///
/// Phase 1 surface is read-only and value-type based. All data lives
/// in `@AppStorage` (`dq.publishedTreeCount` + earned-badge IDs from
/// `AchievementService` + retention snapshot). No PII / no outbound.
///
/// Accessibility: every metric block is its own accessibility element
/// with a label that reads "X conversations published" rather than
/// the raw number — supports VoiceOver reads of the dashboard.
public struct ParentProgressDashboardView: View {
    @AppStorage("dq.publishedTreeCount") private var publishedTreeCount: Int = 0
    @AppStorage("dq.currentStreak") private var currentStreak: Int = 0
    @AppStorage("dq.streakFreezes") private var streakFreezes: Int = 2
    @AppStorage("dq.earnedBadgeIDs") private var earnedBadgeIDsRaw: String = ""

    /// Snapshot fetched in `.task` per the read-only dashboard rule.
    @State private var retention: RetentionMetricsService.Snapshot?

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                heroSection
                primaryMetrics
                retentionSection
                standardSection
                whatThisMeansSection
            }
            .padding()
        }
        .background(DialoguePalette.cream.opacity(0.6))
        .navigationTitle("Progress")
        .task {
            retention = RetentionMetricsService.shared.snapshot()
        }
    }

    // MARK: - Sections

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("How your writer is doing")
                .font(.title2.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)
            Text("A snapshot for parents and educators. No personal data leaves the device.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var primaryMetrics: some View {
        VStack(spacing: 10) {
            ParentProgressMetricRow(
                title: "Conversations published",
                value: "\(publishedTreeCount)",
                detail: publishedTreeCount == 0
                    ? "Once your child publishes their first tree, it will appear in the anthology."
                    : "Each tree is a 2-character conversation with branch points your child reflected on.",
                systemImage: "tray.full.fill"
            )
            ParentProgressMetricRow(
                title: "Current streak",
                value: streakLabel,
                detail: "Streak freezes available: \(max(0, streakFreezes)). A freeze covers one missed day.",
                systemImage: "flame.fill"
            )
            ParentProgressMetricRow(
                title: "Badges earned",
                value: "\(earnedBadgeIDs.count)",
                detail: "Badges recognize milestones in voice consistency, subtext, tag balance, and branch craft.",
                systemImage: "rosette"
            )
        }
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private var retentionSection: some View {
        if let retention {
            VStack(alignment: .leading, spacing: 8) {
                Text("Return habit")
                    .font(.headline)
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text("Has your child come back to DialogueQuest at these checkpoints?")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                VStack(spacing: 6) {
                    retentionRow(label: "Day 1", hit: retention.hitD1)
                    retentionRow(label: "Day 7", hit: retention.hitD7)
                    retentionRow(label: "Day 30", hit: retention.hitD30)
                }
                if let firstLaunch = retention.firstLaunch {
                    Text("First opened \(firstLaunch.formatted(date: .abbreviated, time: .omitted)).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Return habit. Day 1 \(retention.hitD1 ? "met" : "pending"), day 7 \(retention.hitD7 ? "met" : "pending"), day 30 \(retention.hitD30 ? "met" : "pending").")
        }
    }

    private var standardSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Standards covered")
                .font(.headline)
                .foregroundStyle(DialoguePalette.inkBlue)
            standardRow(
                label: "CCSS.ELA-Literacy.W.6-8.3.B",
                description: "Use narrative techniques, such as dialogue, pacing, description, reflection, and multiple plot lines, to develop experiences, events, and/or characters."
            )
            standardRow(
                label: "CCSS.ELA-Literacy.RL.6-8.6",
                description: "Explain how an author develops the point of view of the narrator or speaker."
            )
            standardRow(
                label: "NCAS TH:Cr3",
                description: "Refine and complete artistic work — theater script development."
            )
        }
        .padding()
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var whatThisMeansSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What this means")
                .font(.headline)
                .foregroundStyle(DialoguePalette.inkBlue)
            Text("DialogueQuest is about craft, not grades. Every line your child writes gets gentle feedback on whether each character sounds like themselves, whether what they're saying matches what they mean, and whether each choice in the conversation actually changes the story.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("No data ever leaves the device. The dashboard reads the same on-device counters your child sees in their Progress tab.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Helpers

    private var streakLabel: String {
        if currentStreak <= 0 { return "—" }
        return "\(currentStreak) day\(currentStreak == 1 ? "" : "s")"
    }

    private var earnedBadgeIDs: [String] {
        earnedBadgeIDsRaw
            .split(separator: ",", omittingEmptySubsequences: true)
            .map { String($0) }
    }

    @ViewBuilder
    private func retentionRow(label: String, hit: Bool) -> some View {
        HStack {
            Image(systemName: hit ? "checkmark.circle.fill" : "circle.dashed")
                .foregroundStyle(hit ? DialoguePalette.rust : .secondary)
            Text(label)
                .font(.body)
            Spacer()
            Text(hit ? "Met" : "Pending")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func standardRow(label: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline.monospaced())
                .foregroundStyle(DialoguePalette.rust)
            Text(description)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var panelBackground: some View {
        if reduceTransparency {
            DialoguePalette.cream
        } else {
            Color.clear.background(.thinMaterial)
        }
    }
}

/// Single dashboard metric row. Public-internal so the parent screen
/// can reuse it; keeps the dashboard layout legible.
struct ParentProgressMetricRow: View {
    let title: String
    let value: String
    let detail: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(DialoguePalette.rust)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(value)
                .font(.title3.weight(.semibold).monospacedDigit())
                .foregroundStyle(DialoguePalette.inkBlue)
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value). \(detail)")
    }
}

#Preview {
    NavigationStack { ParentProgressDashboardView() }
}
