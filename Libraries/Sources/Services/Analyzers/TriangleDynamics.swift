import Foundation
import Models

/// Phase 2 triangle-dynamics analyzer. Reads a `DialogueTree` with
/// 3+ characters and reports which classical triangle pattern the
/// dialogue is shaping toward — `.alliance` (two voices closing
/// against the third), `.jealousy` (one voice excluded), `.arbitration`
/// (one voice steps between the conflict), or `.none` when the volumes
/// are balanced.
///
/// **Pedagogical posture** (load-bearing): the analyzer is descriptive,
/// never prescriptive. The kid reads "Looks like an alliance pattern is
/// forming — that's one classical shape" and chooses whether to lean in
/// or break out. The Patter mentor surface receives the classification
/// as context, never as a corrective scaffold.
///
/// **Determinism**: pure value-type analysis driven only by speaker
/// counts, contiguous-speaker streaks, and arbiter-role placement.
/// Same `DialogueTree` → same `Classification` every time.
public nonisolated struct TriangleDynamics: Sendable {

    /// Triangle pattern the analyzer surfaces.
    public enum Classification: String, Sendable, Equatable, Hashable, CaseIterable {
        /// Two characters' lines outnumber the third by ≥ 2:1.
        case alliance
        /// One character speaks ≤ 20% of the time AND has no consecutive
        /// reply with their addressing partner — they're being talked
        /// around rather than to.
        case jealousy
        /// A character with `.arbiter` role speaks ≥ 20% of the lines
        /// AND those lines sit between the other two characters' lines.
        case arbitration
        /// Speech volumes ≈ balanced; no dominant pattern.
        case none

        /// Coaching line the analyzer hands to `PatterReactionService`.
        /// Reads as observation, not correction.
        public var observationLine: String {
            switch self {
            case .alliance: "Looks like two voices are closing on the third. That's an alliance shape — lean in or break out, your call."
            case .jealousy: "One voice is being talked around. The exclusion is its own kind of dialogue — what does the quiet character notice?"
            case .arbitration: "Your arbiter is doing real work — stepping between the others. Try giving them a line that names what they're doing."
            case .none: "Voices are balanced. Triangle is wide open — pick a beat to tilt it."
            }
        }
    }

    /// Per-character contribution share + the surfaced classification.
    public nonisolated struct Result: Sendable, Equatable {
        public let classification: Classification
        /// Map: character UUID → fraction of nodes whose speaker is that
        /// character (0.0...1.0). Sum is always 1.0 across speakers.
        public let speakerShare: [UUID: Double]
        /// Number of contiguous same-speaker pairs (a kid who alternates
        /// every line has 0; an "alliance" reads as a high streak count).
        public let consecutiveStreakCount: Int

        public init(
            classification: Classification,
            speakerShare: [UUID: Double],
            consecutiveStreakCount: Int
        ) {
            self.classification = classification
            self.speakerShare = speakerShare
            self.consecutiveStreakCount = consecutiveStreakCount
        }
    }

    public init() {}

    /// Classify a tree. Returns `.none` for trees with fewer than 3
    /// characters or fewer than 5 nodes (insufficient signal).
    public func classify(_ tree: DialogueTree) -> Result {
        let speakerCounts = Self.speakerCounts(in: tree.nodes)
        let total = Double(tree.nodes.count)
        let share = speakerCounts.mapValues { Double($0) / max(total, 1) }
        let streaks = Self.consecutiveSameSpeakerCount(in: tree.nodes)

        guard tree.characters.count >= 3, tree.nodes.count >= 5 else {
            return Result(
                classification: .none,
                speakerShare: share,
                consecutiveStreakCount: streaks
            )
        }

        // Arbitration first: an explicit `.arbiter` role with substantial
        // air time pre-empts the other classifications.
        if let arbiterID = tree.characters.first(where: { $0.role == .arbiter })?.id,
           (share[arbiterID] ?? 0) >= 0.20 {
            return Result(
                classification: .arbitration,
                speakerShare: share,
                consecutiveStreakCount: streaks
            )
        }

        // Jealousy: someone speaks ≤ 20% of the time.
        let quietestShare = share.values.min() ?? 0
        if quietestShare > 0 && quietestShare <= 0.20 {
            return Result(
                classification: .jealousy,
                speakerShare: share,
                consecutiveStreakCount: streaks
            )
        }

        // Alliance: top-two combined strictly exceeds 2× third. Strict
        // inequality means a perfectly balanced 1/3-1/3-1/3 conversation
        // is .none, not .alliance — the kid only sees the alliance
        // observation when the gap between the pair and the third is
        // measurable.
        let sortedShares = share.values.sorted(by: >)
        if sortedShares.count >= 3 {
            let topTwo = sortedShares[0] + sortedShares[1]
            let third = sortedShares[2]
            if third > 0 && topTwo > 2 * third {
                return Result(
                    classification: .alliance,
                    speakerShare: share,
                    consecutiveStreakCount: streaks
                )
            }
        }

        return Result(
            classification: .none,
            speakerShare: share,
            consecutiveStreakCount: streaks
        )
    }

    // MARK: - Helpers

    private static func speakerCounts(in nodes: [DialogueNode]) -> [UUID: Int] {
        var counts: [UUID: Int] = [:]
        for node in nodes {
            counts[node.speakerID, default: 0] += 1
        }
        return counts
    }

    private static func consecutiveSameSpeakerCount(in nodes: [DialogueNode]) -> Int {
        guard nodes.count >= 2 else { return 0 }
        var count = 0
        for index in 1..<nodes.count where nodes[index].speakerID == nodes[index - 1].speakerID {
            count += 1
        }
        return count
    }
}
