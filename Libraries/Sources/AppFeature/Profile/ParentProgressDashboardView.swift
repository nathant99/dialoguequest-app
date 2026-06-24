import SwiftUI
import Services
import SharedUI
import ForgeGamification
import ForgeReporting

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
    @AppStorage("dq.weeklySummaryOptIn") private var weeklySummaryOptIn: Bool = false

    /// Snapshot fetched in `.task` per the read-only dashboard rule.
    @State private var retention: RetentionMetricsService.Snapshot?
    /// 7-day weekly delta snapshot. Loaded in `.task` when the parent
    /// has opted in (`dq.weeklySummaryOptIn`).
    @State private var weeklySummary: WeeklySummarySnapshot?
    /// Signed deltas vs the previously persisted weekly snapshot.
    /// nil on first open (no baseline yet) or when overlapping windows
    /// would surface a misleading comparison.
    @State private var weeklyDelta: WeeklyDelta?

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                heroSection
                primaryMetrics
                weeklySummarySection
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
            if weeklySummaryOptIn {
                let (snapshot, delta) = await WeeklySummaryService.shared.snapshotWithDelta()
                weeklySummary = snapshot
                weeklyDelta = delta
            }
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

    @ViewBuilder
    private var weeklySummarySection: some View {
        if weeklySummaryOptIn, let summary = weeklySummary {
            VStack(alignment: .leading, spacing: 10) {
                Text("This week")
                    .font(.headline)
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text(weeklySummaryFraming(summary))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if summary.hasAnyActivity {
                    VStack(spacing: 6) {
                        weeklyMetricRow(
                            label: "Conversations published",
                            value: summary.publishedTreesThisWeek
                        )
                        weeklyMetricRow(
                            label: "Subtext lines confirmed",
                            value: summary.subtextConfirmedThisWeek
                        )
                        weeklyMetricRow(
                            label: "Branches reflected on",
                            value: summary.branchesReflectedThisWeek
                        )
                        weeklyMetricRow(
                            label: "Badges earned",
                            value: summary.badgesEarnedThisWeek
                        )
                        weeklyMetricRow(
                            label: "Days opened",
                            value: summary.activeDaysThisWeek,
                            unitLimit: 7
                        )
                    }
                    if let delta = weeklyDelta, delta.hasAnySignedChange {
                        Divider()
                        Text("Change vs last week")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(DialoguePalette.inkBlue)
                        Text(weeklyDeltaFraming(delta))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    if !summary.voicePatternHighlights.isEmpty {
                        Divider()
                        Text("Voice patterns")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(DialoguePalette.inkBlue)
                        Text(voicePatternHighlightFraming(summary.voicePatternHighlights))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("No conversations this week yet. Patter is waiting.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .accessibilityElement(children: .contain)
            .accessibilityLabel(weeklySummaryAccessibilitySummary(summary))
        }
    }

    @ViewBuilder
    private func weeklyMetricRow(label: String, value: Int, unitLimit: Int? = nil) -> some View {
        HStack {
            Text(label)
                .font(.body)
            Spacer()
            if let unitLimit {
                Text("\(value) of \(unitLimit)")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(DialoguePalette.inkBlue)
            } else {
                Text("\(value)")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(DialoguePalette.inkBlue)
            }
        }
    }

    private func weeklySummaryFraming(_ summary: WeeklySummarySnapshot) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let start = formatter.string(from: summary.windowStart)
        let end = formatter.string(from: summary.windowEnd)
        return "What changed between \(start) and \(end). On-device only."
    }

    private func voicePatternHighlightFraming(_ highlights: [VoicePatternHighlight]) -> String {
        let improvingCount = highlights.filter { $0.trend == "improving" }.count
        let driftingCount = highlights.filter { $0.trend == "drifting" }.count
        var parts: [String] = []
        if improvingCount > 0 {
            parts.append("\(improvingCount) \(improvingCount == 1 ? "character is" : "characters are") sounding more like themselves")
        }
        if driftingCount > 0 {
            parts.append("\(driftingCount) \(driftingCount == 1 ? "character" : "characters") could use a gentle anchor line next session")
        }
        if parts.isEmpty {
            return "All characters held steady this week."
        }
        return parts.joined(separator: "; ") + "."
    }

    private func weeklyDeltaFraming(_ delta: WeeklyDelta) -> String {
        var parts: [String] = []
        if delta.publishedTreesDelta != 0 {
            parts.append(deltaPhrase(value: delta.publishedTreesDelta, noun: "conversation"))
        }
        if delta.subtextConfirmedDelta != 0 {
            parts.append(deltaPhrase(value: delta.subtextConfirmedDelta, noun: "subtext line"))
        }
        if delta.branchesReflectedDelta != 0 {
            parts.append(deltaPhrase(value: delta.branchesReflectedDelta, noun: "branch reflection"))
        }
        if delta.badgesEarnedDelta != 0 {
            parts.append(deltaPhrase(value: delta.badgesEarnedDelta, noun: "badge"))
        }
        if delta.newlyImprovingCount > 0 {
            let plural = delta.newlyImprovingCount == 1 ? "character" : "characters"
            parts.append("\(delta.newlyImprovingCount) \(plural) newly improving")
        }
        if delta.newlyDriftingCount > 0 {
            let plural = delta.newlyDriftingCount == 1 ? "character" : "characters"
            parts.append("\(delta.newlyDriftingCount) \(plural) newly drifting")
        }
        if parts.isEmpty {
            return "Same shape as last week."
        }
        return parts.joined(separator: "; ") + " vs last week."
    }

    private func deltaPhrase(value: Int, noun: String) -> String {
        let magnitude = abs(value)
        let plural = magnitude == 1 ? noun : "\(noun)s"
        if value > 0 {
            return "\(magnitude) more \(plural)"
        } else {
            return "\(magnitude) fewer \(plural)"
        }
    }

    private func weeklySummaryAccessibilitySummary(_ summary: WeeklySummarySnapshot) -> String {
        if !summary.hasAnyActivity {
            return "This week: no conversations published yet."
        }
        return "This week: \(summary.publishedTreesThisWeek) conversations published, \(summary.subtextConfirmedThisWeek) subtext lines confirmed, \(summary.branchesReflectedThisWeek) branches reflected, \(summary.badgesEarnedThisWeek) badges earned, opened on \(summary.activeDaysThisWeek) of 7 days."
    }

    private var standardSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Standards covered")
                .font(.headline)
                .foregroundStyle(DialoguePalette.inkBlue)
            if let report = buildReport() {
                ForEach(report.standardProficiencies) { proficiency in
                    proficiencyRow(proficiency)
                }
            } else {
                // Fresh install — surface the standards the app maps to
                // without a percentage so the parent sees the curriculum
                // surface before any practice has happened.
                ForEach(DialogueQuestProgressReportBuilder.canonicalStandards, id: \.code) { standard in
                    standardRow(label: standard.code, description: standard.description)
                }
            }
        }
        .padding()
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private func proficiencyRow(_ proficiency: StandardProficiency) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(proficiency.standard.code)
                    .font(.subheadline.monospaced())
                    .foregroundStyle(DialoguePalette.rust)
                Spacer()
                Text(proficiency.proficiency.displayName)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DialoguePalette.inkBlue)
            }
            Text(proficiency.standard.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
            ProgressView(value: proficiency.percentage, total: 100)
                .tint(DialoguePalette.rust)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(proficiency.standard.code), \(proficiency.proficiency.displayName), \(Int(proficiency.percentage.rounded())) percent."
        )
    }

    /// Build the canonical ForgeReporting shape from on-app counters.
    /// Returns nil for a fresh install (no published trees + no badges
    /// + no active days) so the view-layer surfaces the empty state.
    private func buildReport() -> StudentReportData? {
        let inputs = DialogueQuestProgressReportBuilder.Inputs(
            studentName: "your writer",
            publishedTreeCount: publishedTreeCount,
            currentStreak: max(0, currentStreak),
            longestStreak: max(0, currentStreak),
            badgesEarned: earnedBadgeIDs.count,
            activeDays: derivedActiveDays(from: retention),
            totalXP: 0,                                   // future: pipe from ForgeGamification XPEngine
            averageVoiceMatchScore: 0.65,                 // placeholder until WritingEvaluator.VoiceSummary persists
            confirmedSubtextCount: 0,                     // future: pipe from AchievementService earned set
            branchesReflectedCount: 0                     // future: same — counter persists in PatterReactionService
        )
        return DialogueQuestProgressReportBuilder().build(from: inputs)
    }

    /// Derive a coarse active-day count from the retention snapshot —
    /// counts the milestones the kid has hit (D1 / D7 / D30). The
    /// canonical per-day counter doesn't persist today; this is the
    /// best proxy until a richer surface lands.
    private func derivedActiveDays(from snapshot: RetentionMetricsService.Snapshot?) -> Int {
        guard let snapshot else { return publishedTreeCount > 0 ? 1 : 0 }
        var days = publishedTreeCount > 0 ? 1 : 0
        if snapshot.hitD1 { days += 1 }
        if snapshot.hitD7 { days += 1 }
        if snapshot.hitD30 { days += 1 }
        return days
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
