import Foundation
import Models

/// Phase 1 craft metric: how meaningful are the branches in a tree?
///
/// A "meaningful" branch satisfies two structural rules:
///   1. 2+ children (otherwise it isn't really a branch)
///   2. The branches diverge (children eventually reach different leaves
///      OR carry distinct moods inferred from tag style)
///
/// The Socratic Patter check fires once per branch point. The kid's
/// reflection text is not graded — the act of articulating IS the
/// learning. The score below is for the dashboard ribbon only.
public nonisolated struct BranchMeaningfulnessScorer: Sendable {

    public init() {}

    public struct Report: Sendable, Hashable {
        /// Number of branch-point nodes (2+ children) in the tree.
        public let branchPointCount: Int
        /// How many of those branch points have at least one reflection
        /// recorded against them. Phase 1 stores reflections out-of-band
        /// (the dialogue node itself doesn't carry reflection state) so
        /// this is reported back from a sidecar `Set<UUID>`.
        public let reflectedBranchPointCount: Int
        /// 0.0–1.0 ratio of reflected branches; the UI displays as a band
        /// (red ≤ 0.33 / amber ≤ 0.66 / green ≤ 1.0).
        public let reflectionRatio: Double
        /// Leaf-count parity check: a healthy tree branches to multiple
        /// distinct endings. 2-4 leaves is the Phase 1 target band.
        public let leafCount: Int
        public let meetsLeafTarget: Bool
    }

    /// Compute a `Report` for the given tree plus the set of branch-point
    /// node IDs the kid has reflected against.
    public func score(
        tree: DialogueTree,
        reflectedBranchPointIDs: Set<UUID>
    ) -> Report {
        let branchPoints = tree.branchPoints
        let count = branchPoints.count
        let reflected = branchPoints.filter { reflectedBranchPointIDs.contains($0.id) }.count
        let ratio: Double = count > 0 ? Double(reflected) / Double(count) : 0
        let leafCount = tree.leaves.count
        return Report(
            branchPointCount: count,
            reflectedBranchPointCount: reflected,
            reflectionRatio: ratio,
            leafCount: leafCount,
            meetsLeafTarget: (2...4).contains(leafCount)
        )
    }
}
