import SwiftUI
import Models
import Services
import SharedUI
import ForgeGamification
import ForgeReporting
import ForgeEmotionAware

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
    /// Lifetime cumulative craft counters (Priority P-follow) — written at
    /// each publish by WriteTabView. Feed the standards report's
    /// `confirmedSubtextCount` / `branchesReflectedCount` (previously 0
    /// placeholders).
    @AppStorage("dq.confirmedSubtextTotal") private var confirmedSubtextTotal: Int = 0
    @AppStorage("dq.branchesReflectedTotal") private var branchesReflectedTotal: Int = 0

    /// Snapshot fetched in `.task` per the read-only dashboard rule.
    @State private var retention: RetentionMetricsService.Snapshot?
    /// 7-day weekly delta snapshot. Loaded in `.task` when the parent
    /// has opted in (`dq.weeklySummaryOptIn`).
    @State private var weeklySummary: WeeklySummarySnapshot?
    /// Signed deltas vs the previously persisted weekly snapshot.
    /// nil on first open (no baseline yet) or when overlapping windows
    /// would surface a misleading comparison.
    @State private var weeklyDelta: WeeklyDelta?
    /// Reader-side descriptor of the most recent session's emotional
    /// state. Sourced from `EmotionalSignalsPersistence.latest()`
    /// captured by `PatterReactionService` during writing sessions.
    /// `nil` on a fresh install or before the kid's first signal-
    /// mutating action — the section omits in that case.
    @State private var emotionalDescriptor: DialogueEmotionalStateDescriptor?
    /// Timestamp of the most recent emotional-signal snapshot. Drives
    /// the "Last read N minutes/hours/days ago" line in the "How
    /// writing felt" section so a parent reading a 3-day-old snapshot
    /// isn't misled into treating it as today's signal. `nil` when no
    /// snapshot exists OR when an older install upgraded past the
    /// additive `Key.lastSnapshotAt` key add — the staleness suffix
    /// is omitted cleanly in that case.
    @State private var emotionalSnapshotTimestamp: Date?
    /// Cohort assignments loaded from `DialogueExperimentsService` on
    /// the cold-launch task. Each row carries the experiment ID +
    /// reader-friendly name + assigned variant ID + variant name. Empty
    /// when no definitions resolve a variant (fresh install before
    /// the install-seed is first written, OR a future round that
    /// catalogs no experiments).
    @State private var experimentCohorts: [ExperimentCohortReadout] = []
    /// Per-published-tree snapshots loaded from `PublishedTreeSnapshotStore`
    /// (Priority P). Most-recent-first. Drives the "Published works"
    /// section (longest conversation + most recent published mood +
    /// per-character voice for the latest tree). Empty on a fresh install
    /// before the kid's first publish — the section omits in that case.
    @State private var publishedSnapshots: [PublishedTreeSnapshot] = []
    /// Adaptive-mastery readout (Priority B → P-follow surface). Loaded from
    /// `DialogueCraftMasteryService` in `.task`. `masteredCraftCount` is how
    /// many of the six craft pillars have reached the mastery threshold;
    /// `masteryFocus` is the pillar Patter suggests focusing on next (`nil`
    /// before the first publish or when nothing is recommended).
    @State private var masteredCraftCount: Int = 0
    @State private var masteryFocus: DialogueCraftTopic?
    /// Up to three reader-facing coaching cards (extend / consolidate /
    /// stretch) from `DialogueCraftMasteryService.recommendationReadouts()`.
    /// Surfaces the FULL `NextProblemPicker` output, not just the first row.
    /// Empty before the first publish or when the picker has nothing to say.
    @State private var craftRecommendations: [DialogueCraftMasteryService.CraftRecommendationReadout] = []
    /// The exact warm, kid-facing focus-nudge line the child's Write tab might
    /// surface in Patter's bubble (cast-voiced per Wave B). Mirrored here so a
    /// parent has transparency into the delight surface — they see what their
    /// writer sees. `nil` when the picker has nothing to suggest.
    @State private var masteryNudgeLine: String?

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                heroSection
                primaryMetrics
                weeklySummarySection
                publishedWorksSection
                craftFocusSection
                emotionalStateSection
                experimentCohortsSection
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
            if let signals = EmotionalSignalsPersistence.latest() {
                emotionalDescriptor = DialogueEmotionalStateProbe.descriptor(forSignals: signals)
            }
            // Priority M.4 (2026-07-05) — load the timestamp so
            // `emotionalStateSection` can render the staleness suffix.
            // Read independently of `latest()` so an upgraded install
            // missing the timestamp key still renders the section
            // (with no suffix). `latestTimestamp()` already gates on
            // `hasSnapshot` so we never surface a stale Date when the
            // signals were reset.
            emotionalSnapshotTimestamp = EmotionalSignalsPersistence.latestTimestamp()
            // Priority N.3 (2026-07-05) — surface variant assignments
            // on the parent dashboard alongside the `experiment_variant_assigned`
            // analytics events emitted at cold launch. Read-only
            // transparency; no control affordance + no mutation of
            // the existing `@AppStorage("dq.experiments.*")` flags
            // (those remain the runtime control surface).
            experimentCohorts = ParentProgressDashboardView.cohortReadouts(
                from: DialogueExperimentsService.shared,
                history: CohortHistoryService.shared
            )
            // Priority P (2026-07-08) — load the per-published-tree
            // snapshots so the "Published works" section can surface the
            // longest conversation + most recent published mood + per-
            // character voice. Read-only; the store is the source of
            // truth, captured at each publish in WriteTabView.
            publishedSnapshots = PublishedTreeSnapshotStore.shared.recent()
            // Priority B → P-follow (2026-07-09) — surface the adaptive
            // mastery readout: how many craft pillars are solid + which
            // pillar Patter suggests focusing on next. Read-only; the
            // FSRS-6 mastery state is captured at each publish in WriteTabView.
            masteredCraftCount = DialogueCraftMasteryService.shared.masteredTopics().count
            masteryFocus = DialogueCraftMasteryService.shared.nextFocusTopic()
            craftRecommendations = DialogueCraftMasteryService.shared.recommendationReadouts()
            // Mirror the kid-facing bubble line (cast-voiced) so a parent
            // can see exactly what their writer might be nudged toward.
            masteryNudgeLine = DialogueCraftMasteryService.shared.nextFocusNudge()
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

    /// Adaptive-mastery readout (Priority B → P-follow). Renders once the
    /// kid has published at least one tree (so the mastery state is
    /// non-empty); omits cleanly on a fresh install. Surfaces how many of
    /// the six craft pillars are solid + which one Patter suggests next.
    @ViewBuilder
    private var craftFocusSection: some View {
        if masteredCraftCount > 0 || masteryFocus != nil {
            VStack(alignment: .leading, spacing: 8) {
                Text("Craft focus")
                    .font(.headline)
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text("\(masteredCraftCount) of \(DialogueCraftTopic.allCases.count) dialogue-craft skills are looking solid.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if let focus = masteryFocus {
                    Text("Patter suggests focusing on \(focus.displayName) next.")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(DialoguePalette.inkBlue)
                }
                if let masteryNudgeLine {
                    Text("What your writer might see: “\(masteryNudgeLine)”")
                        .font(.caption)
                        .italic()
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("What your writer might see: \(masteryNudgeLine)")
                }
                if !craftRecommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(craftRecommendations) { recommendation in
                            craftRecommendationCard(recommendation)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .accessibilityElement(children: .contain)
        }
    }

    /// One extend / consolidate / stretch coaching card. The leading symbol
    /// keys the rationale (build / revisit / stretch) for quick parent scanning.
    private func craftRecommendationCard(
        _ recommendation: DialogueCraftMasteryService.CraftRecommendationReadout
    ) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: Self.symbol(for: recommendation.kind))
                .font(.footnote)
                .foregroundStyle(DialoguePalette.rust)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(recommendation.headline)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text(recommendation.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(recommendation.headline). \(recommendation.detail)")
    }

    private static func symbol(for kind: DialogueCraftMasteryService.CraftRecommendationReadout.Kind) -> String {
        switch kind {
        case .extend:      return "arrow.up.right.circle"
        case .consolidate: return "arrow.counterclockwise.circle"
        case .stretch:     return "sparkles"
        }
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

    // MARK: - Priority P (2026-07-08) — published works surface

    /// Tree-average voice-match from the most recent published tree that
    /// scored at least one line. Falls back through the buffer so a
    /// recent voiceless tree (treeAverage == nil) doesn't blank the
    /// report. `nil` only when no published tree has a scored line yet.
    private var latestTreeAverageVoiceMatch: Double? {
        publishedSnapshots.first { $0.treeAverageVoiceMatch != nil }?.treeAverageVoiceMatch
    }

    @ViewBuilder
    private var publishedWorksSection: some View {
        if let mostRecent = publishedSnapshots.first {
            let longest = publishedSnapshots.max { $0.nodeCount < $1.nodeCount } ?? mostRecent
            VStack(alignment: .leading, spacing: 10) {
                Text("Published works")
                    .font(.headline)
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text("The conversations your writer has shipped. On-device only.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                publishedWorkRow(
                    label: "Most recent",
                    snapshot: mostRecent
                )
                if longest.id != mostRecent.id {
                    Divider()
                    publishedWorkRow(
                        label: "Longest conversation",
                        snapshot: longest
                    )
                }
                if !mostRecent.characterVoices.isEmpty {
                    Divider()
                    Text("How each character sounded")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(DialoguePalette.inkBlue)
                    VStack(spacing: 6) {
                        ForEach(mostRecent.characterVoices) { voice in
                            characterVoiceRow(voice)
                        }
                    }
                }
            }
            .padding()
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .accessibilityElement(children: .contain)
            .accessibilityLabel(publishedWorksAccessibilityLabel(mostRecent: mostRecent, longest: longest))
            .accessibilityIdentifier("published.works")
        }
    }

    @ViewBuilder
    private func publishedWorkRow(label: String, snapshot: PublishedTreeSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)
            HStack(alignment: .firstTextBaseline) {
                Text(snapshot.title.isEmpty ? "Untitled conversation" : snapshot.title)
                    .font(.subheadline)
                    .foregroundStyle(DialoguePalette.rust)
                Spacer()
                Text("\(snapshot.nodeCount) line\(snapshot.nodeCount == 1 ? "" : "s")")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            if let mood = snapshot.mood {
                Text("Mood: \(mood.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func characterVoiceRow(_ voice: PublishedTreeSnapshot.CharacterVoice) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(voice.name)
                .font(.subheadline)
                .foregroundStyle(DialoguePalette.inkBlue)
            Spacer()
            Text(voiceBandLabel(voice.band))
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DialoguePalette.rust)
        }
    }

    /// Maps the voice band to a kid-and-parent-readable phrase. Avoids
    /// surfacing the raw "drifting / acceptable / strong" enum tokens.
    private func voiceBandLabel(_ band: WritingEvaluator.VoiceBand) -> String {
        switch band {
        case .strong: return "Sounds like themselves"
        case .acceptable: return "Mostly in voice"
        case .drifting: return "Could use an anchor line"
        }
    }

    private func publishedWorksAccessibilityLabel(
        mostRecent: PublishedTreeSnapshot,
        longest: PublishedTreeSnapshot
    ) -> String {
        var parts: [String] = ["Published works."]
        let recentTitle = mostRecent.title.isEmpty ? "Untitled conversation" : mostRecent.title
        parts.append("Most recent: \(recentTitle), \(mostRecent.nodeCount) lines.")
        if longest.id != mostRecent.id {
            let longestTitle = longest.title.isEmpty ? "Untitled conversation" : longest.title
            parts.append("Longest: \(longestTitle), \(longest.nodeCount) lines.")
        }
        for voice in mostRecent.characterVoices {
            parts.append("\(voice.name): \(voiceBandLabel(voice.band)).")
        }
        return parts.joined(separator: " ")
    }

    @ViewBuilder
    private var emotionalStateSection: some View {
        if let descriptor = emotionalDescriptor {
            VStack(alignment: .leading, spacing: 8) {
                Text("How writing felt")
                    .font(.headline)
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text(descriptor.parentSummary)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DialoguePalette.rust)
                if let staleness = stalenessFraming(for: emotionalSnapshotTimestamp) {
                    Text(staleness)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(DialoguePalette.inkBlue.opacity(0.7))
                        .accessibilityIdentifier("emotional.staleness")
                }
                emotionalDescriptorRow(title: "What this means", body: descriptor.whatThisMeans)
                emotionalDescriptorRow(title: "How we support", body: descriptor.howWeSupport)
                emotionalDescriptorRow(title: "Next milestone", body: descriptor.nextMilestone)
                Text("On-device only. No data ever leaves the device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .accessibilityElement(children: .contain)
            .accessibilityLabel(emotionalSectionAccessibilityLabel(descriptor: descriptor))
        }
    }

    /// Builds the staleness-framing line ("Last read just now" /
    /// "Last read 4 minutes ago" / "Last read about 2 hours ago" /
    /// "Last read 3 days ago"). Returns `nil` when the timestamp is
    /// `nil` (upgraded install OR fresh install) — the caller omits
    /// the line in that case. Pure value-type computation; safe to
    /// call from a SwiftUI body.
    private func stalenessFraming(for date: Date?) -> String? {
        ParentProgressDashboardView.stalenessFraming(for: date, now: Date())
    }

    /// Static seam so tests can pin `now` without driving the view.
    static func stalenessFraming(for date: Date?, now: Date) -> String? {
        guard let date else { return nil }
        let interval = max(0, now.timeIntervalSince(date))
        if interval < 60 {
            return "Last read just now"
        }
        if interval < 60 * 60 {
            let minutes = Int(interval / 60)
            return "Last read \(minutes) minute\(minutes == 1 ? "" : "s") ago"
        }
        if interval < 60 * 60 * 24 {
            let hours = Int(interval / 3600)
            return "Last read about \(hours) hour\(hours == 1 ? "" : "s") ago"
        }
        let days = Int(interval / (3600 * 24))
        return "Last read \(days) day\(days == 1 ? "" : "s") ago"
    }

    /// Builds the consolidated accessibility label for the emotional
    /// state section so the staleness suffix is read aloud alongside
    /// the descriptor body.
    private func emotionalSectionAccessibilityLabel(
        descriptor: DialogueEmotionalStateDescriptor
    ) -> String {
        var parts: [String] = ["How writing felt.", descriptor.parentSummary + "."]
        if let staleness = stalenessFraming(for: emotionalSnapshotTimestamp) {
            parts.append(staleness + ".")
        }
        parts.append(descriptor.whatThisMeans)
        parts.append(descriptor.howWeSupport)
        parts.append("Next milestone: \(descriptor.nextMilestone)")
        return parts.joined(separator: " ")
    }

    @ViewBuilder
    private func emotionalDescriptorRow(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)
            Text(body)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Priority N.3 (2026-07-05) — experiment cohorts surface

    @ViewBuilder
    private var experimentCohortsSection: some View {
        if !experimentCohorts.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Experiment cohorts")
                    .font(.headline)
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text("What this means")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text("Your writer is in one cohort per experiment so we can compare new features against the existing ones. Cohort assignment stays on-device. No data leaves the device.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(experimentCohorts, id: \.experimentID) { cohort in
                        experimentCohortRow(cohort)
                    }
                }
                .padding(.top, 2)
                Text("On-device only. No data ever leaves the device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .accessibilityElement(children: .contain)
            .accessibilityLabel(experimentCohortsAccessibilityLabel())
            .accessibilityIdentifier("experiment.cohorts")
        }
    }

    @ViewBuilder
    private func experimentCohortRow(_ cohort: ExperimentCohortReadout) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline) {
                Text(cohort.experimentName)
                    .font(.subheadline)
                    .foregroundStyle(DialoguePalette.inkBlue)
                Spacer()
                Text(cohort.variantName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DialoguePalette.rust)
            }
            // Priority Q — only surface the duration line once there's a
            // run of 2+ launches; a single launch reads as noise.
            if cohort.sessionsInCohort >= 2 {
                Text("In this cohort for the past \(cohort.sessionsInCohort) sessions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func experimentCohortsAccessibilityLabel() -> String {
        let body = experimentCohorts
            .map { cohort -> String in
                if cohort.sessionsInCohort >= 2 {
                    return "\(cohort.experimentName) — \(cohort.variantName) cohort, for the past \(cohort.sessionsInCohort) sessions."
                }
                return "\(cohort.experimentName) — \(cohort.variantName) cohort."
            }
            .joined(separator: " ")
        return "Experiment cohorts. \(body)"
    }

    /// Pure value-type test seam. Iterates the service's definitions
    /// and resolves the assigned variant per experiment. Skips
    /// definitions where no variant resolves (defensive — Phase 1
    /// always resolves; future definitions could carry an empty
    /// variant list while the catalog is shaped).
    @MainActor
    static func cohortReadouts(
        from service: DialogueExperimentsService,
        history: CohortHistoryService? = nil
    ) -> [ExperimentCohortReadout] {
        service.definitions.compactMap { definition in
            guard let variant = service.variant(forExperimentID: definition.id) else {
                return nil
            }
            return ExperimentCohortReadout(
                experimentID: definition.id,
                experimentName: definition.name,
                variantID: variant.id,
                variantName: variant.name,
                sessionsInCohort: history?.consecutiveSessions(forExperimentID: definition.id) ?? 0
            )
        }
    }
}

/// Read-only reader-side projection of a single experiment / variant
/// assignment. Surfaces on the parent dashboard's
/// "Experiment cohorts" section. Value-type; safe to compare in tests.
nonisolated struct ExperimentCohortReadout: Equatable, Hashable, Sendable {
    let experimentID: String
    let experimentName: String
    let variantID: String
    let variantName: String
    /// Consecutive launches the kid has been in this cohort (Priority Q).
    /// `0` when no cohort history has been recorded yet (e.g. tests that
    /// pass no history service). The dashboard surfaces the
    /// "for the past N sessions" line only when this is `>= 2`.
    var sessionsInCohort: Int = 0
}

extension ParentProgressDashboardView {

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
            averageVoiceMatchScore: latestTreeAverageVoiceMatch ?? 0.65,  // Priority P: most-recent persisted tree-average; 0.65 fallback before first publish
            confirmedSubtextCount: confirmedSubtextTotal,    // Priority P-follow: lifetime cumulative, bumped at each publish in WriteTabView
            branchesReflectedCount: branchesReflectedTotal   // Priority P-follow: same
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
