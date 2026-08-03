import Foundation
import Services

/// Pure, on-device derivation behind the calm "Your progress" card
/// (`Docs/HANDOFF_FROM_HUB_MASTERY_PROGRESSION_WEB_BACKPORT.md`, ADR-048
/// axis 8). Turns the app's real learning signals — published-tree count,
/// per-pillar craft mastery, and XP level — into a set of LEARNING
/// milestones + an optional learner-set goal.
///
/// **Intrapersonal only (hard invariants, enforced by construction).** No
/// leaderboard / normative rank, no currency / cosmetic unlock, no
/// streak-guilt or scarcity. Milestones key to LEARNING (conversations
/// published + craft pillars practiced/mastered), never to clicks or
/// volume; a goal is "reach YOUR target," never a comparison to others.
/// It RECOGNIZES — nothing here gates content.
///
/// iOS keys milestones to the app's real on-device signals (published
/// trees + the 6 craft pillars from `DialogueCraftMasteryService`), which
/// is the iOS analog of the web clone's per-kit counts.
public nonisolated struct MasteryProgression: Sendable, Equatable {
    public let publishedTreeCount: Int
    public let level: Int
    public let totalPillars: Int
    public let pillarsPracticed: Int
    public let pillarsMastered: Int

    public init(
        publishedTreeCount: Int,
        level: Int,
        readouts: [DialogueCraftMasteryService.CraftMasteryReadout]
    ) {
        self.publishedTreeCount = max(0, publishedTreeCount)
        self.level = max(0, level)
        self.totalPillars = readouts.count
        self.pillarsPracticed = readouts.filter { $0.score > 0 }.count
        self.pillarsMastered = readouts.filter(\.isMastered).count
    }

    // MARK: - Milestones

    public struct Milestone: Sendable, Equatable, Identifiable {
        public let id: String
        public let title: String
        public let detail: String
        public let systemImage: String
        public let isEarned: Bool

        public init(id: String, title: String, detail: String, systemImage: String, isEarned: Bool) {
            self.id = id
            self.title = title
            self.detail = detail
            self.systemImage = systemImage
            self.isEarned = isEarned
        }
    }

    /// The 7 learning milestones, in ascending order of reach. Earned state
    /// is derived purely from the on-device signals.
    public var milestones: [Milestone] {
        // "Half the craft" rounds up so, e.g., 3 of 6 counts as half.
        let halfPillars = (totalPillars + 1) / 2
        return [
            Milestone(
                id: "first_conversation",
                title: "First conversation",
                detail: "Publish your first conversation.",
                systemImage: "bubble.left.and.text.bubble.right.fill",
                isEarned: publishedTreeCount >= 1
            ),
            Milestone(
                id: "five_conversations",
                title: "Five conversations",
                detail: "Publish five conversations.",
                systemImage: "text.bubble.fill",
                isEarned: publishedTreeCount >= 5
            ),
            Milestone(
                id: "ten_conversations",
                title: "Ten conversations",
                detail: "Publish ten conversations.",
                systemImage: "books.vertical.fill",
                isEarned: publishedTreeCount >= 10
            ),
            Milestone(
                id: "every_pillar_practiced",
                title: "Touched every craft",
                detail: "Practice all \(totalPillars) craft pillars at least once.",
                systemImage: "square.grid.2x2.fill",
                isEarned: totalPillars > 0 && pillarsPracticed >= totalPillars
            ),
            Milestone(
                id: "first_pillar_mastered",
                title: "First craft solid",
                detail: "Bring one craft pillar to mastery.",
                systemImage: "checkmark.seal.fill",
                isEarned: pillarsMastered >= 1
            ),
            Milestone(
                id: "half_craft_mastered",
                title: "Half the craft solid",
                detail: "Master \(halfPillars) of \(totalPillars) craft pillars.",
                systemImage: "seal.fill",
                isEarned: totalPillars > 0 && pillarsMastered >= halfPillars
            ),
            Milestone(
                id: "all_craft_mastered",
                title: "Every craft solid",
                detail: "Master all \(totalPillars) craft pillars.",
                systemImage: "crown.fill",
                isEarned: totalPillars > 0 && pillarsMastered >= totalPillars
            ),
        ]
    }

    public var earnedMilestoneCount: Int { milestones.filter(\.isEarned).count }

    // MARK: - Goals (learner-set, optional)

    /// A learner-chosen target. Intrapersonal — "reach YOUR goal," never a
    /// comparison to anyone. `.none` = no goal set (the default).
    public enum Goal: String, Sendable, CaseIterable, Identifiable, Hashable {
        case none
        case masterAllPillars
        case reachLevelFive
        case publishTen

        public var id: String { rawValue }

        /// Kid-facing label for the picker.
        public var menuLabel: String {
            switch self {
            case .none: return "No goal — just exploring"
            case .masterAllPillars: return "Master every craft pillar"
            case .reachLevelFive: return "Reach level 5"
            case .publishTen: return "Publish 10 conversations"
            }
        }
    }

    public struct GoalProgress: Sendable, Equatable {
        public let current: Int
        public let target: Int
        public let fraction: Double
        public let isMet: Bool
        /// e.g. "3 of 6 pillars".
        public let label: String
    }

    /// Progress toward a learner-set goal, or `nil` for `.none`.
    public func progress(for goal: Goal) -> GoalProgress? {
        let (current, target, noun): (Int, Int, String)
        switch goal {
        case .none:
            return nil
        case .masterAllPillars:
            (current, target, noun) = (pillarsMastered, max(totalPillars, 1), "pillars mastered")
        case .reachLevelFive:
            (current, target, noun) = (min(level, 5), 5, "to level 5")
        case .publishTen:
            (current, target, noun) = (min(publishedTreeCount, 10), 10, "conversations")
        }
        let fraction = target > 0 ? min(1, Double(current) / Double(target)) : 0
        let label: String
        switch goal {
        case .reachLevelFive:
            label = "Level \(min(level, 5)) of 5"
        default:
            label = "\(current) of \(target) \(noun)"
        }
        return GoalProgress(
            current: current,
            target: target,
            fraction: fraction,
            isMet: current >= target,
            label: label
        )
    }
}
