import Foundation
import ForgeModels
import ForgeReporting

/// Builds `ForgeReporting.StudentReportData` snapshots from the data
/// surfaces DialogueQuest already persists (anthology entries +
/// AchievementService earned IDs + StreakService current/longest +
/// RetentionMetricsService active-days + AnalyticsService aggregates).
///
/// This is the structured value-type shape that
/// `ParentProgressDashboardView` consumes today (inline) and that
/// Phase 4 `ForgeReporting.ForgeReportGenerator` will consume for the
/// exportable parent letter / classroom CSV / conference packet
/// surfaces. Building the canonical shape now means future Phase 4
/// work is a drop-in consumer change, not a re-modeling round.
///
/// Pure function — no MainActor, no service deps. Inputs are value
/// types the caller assembles from app state. Output is a value
/// type the dashboard renders.
public nonisolated struct DialogueQuestProgressReportBuilder: Sendable {

    /// The 4 canonical Phase 1/2 standards DialogueQuest maps to.
    /// Centralized here so the dashboard, the future ForgeReporting
    /// export, and the on-app row table all share one source.
    public nonisolated static let canonicalStandards: [StandardAlignment] = [
        StandardAlignment(
            standard: .ccss,
            code: "CCSS.ELA-Literacy.W.6-8.3.B",
            description: "Use narrative techniques, such as dialogue, pacing, description, and reflection."
        ),
        StandardAlignment(
            standard: .ccss,
            code: "CCSS.ELA-Literacy.RL.6-8.6",
            description: "Explain how an author develops the point of view of the narrator or speaker."
        ),
        StandardAlignment(
            standard: .ncas,
            code: "NCAS.TH:Cr3",
            description: "Refine and complete artistic work in theatre, attending to subtext and revision."
        ),
        StandardAlignment(
            standard: .ncas,
            code: "NCAS.LA:Cr2",
            description: "Organize and develop artistic ideas and work in language arts."
        )
    ]

    /// Compact snapshot of the dashboard inputs. The view-layer builds
    /// this from its `@AppStorage` keys + `RetentionMetricsService`
    /// snapshot + `AchievementService.earnedIDs` count; the builder
    /// turns it into the canonical `StudentReportData` shape.
    public nonisolated struct Inputs: Sendable, Equatable {
        public let studentName: String
        public let publishedTreeCount: Int
        public let currentStreak: Int
        public let longestStreak: Int
        public let badgesEarned: Int
        public let activeDays: Int
        public let totalXP: Int
        /// Average voice-match score across published trees (0...1). Used
        /// as the proficiency proxy for the CCSS W.6-8.3.B + RL.6-8.6
        /// standards. Use the on-app `WritingEvaluator.VoiceSummary`'s
        /// `treeAverage` here.
        public let averageVoiceMatchScore: Double
        /// Number of subtext confirmations across all trees — proxy for
        /// the subtext-detection / theater-craft standards (NCAS.TH:Cr3
        /// + RL.6-8.6).
        public let confirmedSubtextCount: Int
        /// Number of branch points the kid has reflected on — proxy for
        /// the branch-craft surface within W.6-8.3.B.
        public let branchesReflectedCount: Int

        public init(
            studentName: String,
            publishedTreeCount: Int,
            currentStreak: Int,
            longestStreak: Int,
            badgesEarned: Int,
            activeDays: Int,
            totalXP: Int,
            averageVoiceMatchScore: Double,
            confirmedSubtextCount: Int,
            branchesReflectedCount: Int
        ) {
            self.studentName = studentName
            self.publishedTreeCount = publishedTreeCount
            self.currentStreak = currentStreak
            self.longestStreak = longestStreak
            self.badgesEarned = badgesEarned
            self.activeDays = activeDays
            self.totalXP = totalXP
            self.averageVoiceMatchScore = max(0, min(1, averageVoiceMatchScore))
            self.confirmedSubtextCount = confirmedSubtextCount
            self.branchesReflectedCount = branchesReflectedCount
        }
    }

    public init() {}

    /// Build the canonical ForgeReporting shape. Returns `nil` only when
    /// the kid has published zero trees AND has zero activity — a fresh
    /// install has nothing meaningful to report. (View-layer renders a
    /// "Start writing to see your progress" empty state in that case.)
    public func build(
        from inputs: Inputs,
        gradeLevel: GradeLevel = .seventh,
        period: ReportPeriod = .allTime,
        generatedAt: Date = .now
    ) -> StudentReportData? {
        // A freshly-installed kid with zero everything → return nil so
        // the view-layer can surface its empty state instead of a
        // misleading all-zeros report.
        let hasAnyActivity = inputs.publishedTreeCount > 0
            || inputs.activeDays > 0
            || inputs.badgesEarned > 0
        guard hasAnyActivity else { return nil }

        let proficiencies = buildProficiencies(from: inputs)
        let averageScorePercent = inputs.averageVoiceMatchScore * 100

        return StudentReportData(
            studentName: inputs.studentName,
            gradeLevel: gradeLevel,
            totalSessions: inputs.activeDays,
            totalDurationMinutes: estimatedDurationMinutes(from: inputs),
            activitiesCompleted: inputs.publishedTreeCount,
            averageScore: averageScorePercent,
            currentStreak: inputs.currentStreak,
            totalXP: inputs.totalXP,
            standardProficiencies: proficiencies,
            period: period,
            generatedAt: generatedAt,
            longestStreak: inputs.longestStreak,
            averageSessionMinutes: inputs.activeDays > 0
                ? Double(estimatedDurationMinutes(from: inputs)) / Double(inputs.activeDays)
                : 0,
            activeDays: inputs.activeDays
        )
    }

    /// Map app-side counts to ForgeReporting's `StandardProficiency`
    /// rows. Each canonical standard gets a percentage derived from
    /// the most-aligned app surface (voice-match for W/RL; subtext +
    /// branch counts for NCAS).
    private func buildProficiencies(from inputs: Inputs) -> [StandardProficiency] {
        let voicePercent = inputs.averageVoiceMatchScore * 100
        // W.6-8.3.B: narrative-dialogue craft. Voice-match average is
        // the cleanest existing proxy; published-tree count is the
        // attempt count.
        let writingProficiency = StandardProficiency(
            standard: Self.canonicalStandards[0],
            percentage: voicePercent,
            attemptCount: inputs.publishedTreeCount
        )

        // RL.6-8.6: point of view + perspective. Subtext confirmations
        // are the cleanest proxy: each confirmation = the kid
        // identified an inferred POV layer.
        let subtextPercent = inputs.publishedTreeCount > 0
            ? min(100, Double(inputs.confirmedSubtextCount) / Double(inputs.publishedTreeCount) * 50)
            : 0
        let readingProficiency = StandardProficiency(
            standard: Self.canonicalStandards[1],
            percentage: subtextPercent,
            attemptCount: inputs.confirmedSubtextCount
        )

        // NCAS.TH:Cr3: refine + complete theater craft (subtext +
        // revision). Same subtext-confirmation surface, scaled.
        let theaterPercent = subtextPercent
        let theaterProficiency = StandardProficiency(
            standard: Self.canonicalStandards[2],
            percentage: theaterPercent,
            attemptCount: inputs.confirmedSubtextCount
        )

        // NCAS.LA:Cr2: organize + develop language-arts work. Branch
        // reflections are the cleanest proxy.
        let languageArtsPercent = inputs.publishedTreeCount > 0
            ? min(100, Double(inputs.branchesReflectedCount) / Double(inputs.publishedTreeCount) * 50)
            : 0
        let languageArtsProficiency = StandardProficiency(
            standard: Self.canonicalStandards[3],
            percentage: languageArtsPercent,
            attemptCount: inputs.branchesReflectedCount
        )

        return [
            writingProficiency,
            readingProficiency,
            theaterProficiency,
            languageArtsProficiency
        ]
    }

    /// Rough duration estimate — each published tree represents ~10
    /// minutes of authoring + reflection. Used only when the app
    /// doesn't track per-session timing (which it doesn't — by design,
    /// no PII / no per-keystroke tracking).
    private func estimatedDurationMinutes(from inputs: Inputs) -> Int {
        inputs.publishedTreeCount * 10
    }
}
