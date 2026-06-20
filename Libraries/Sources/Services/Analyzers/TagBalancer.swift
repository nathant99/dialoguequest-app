import Foundation
import Models

/// Counts attribution-tag classification per character + per tree and
/// surfaces imbalance warnings the dashboard renders as ribbons.
///
/// Phase 1 heuristic: "imbalanced" means any single `DialogueTag.Classification`
/// > 70% of a character's lines OR > 70% of the tree as a whole. The
/// thresholds are calibration-tunable; the Patter AI tip path uses the
/// dominant classification to seed `TagBalanceTip`.
public nonisolated struct TagBalancer: Sendable {

    public static let imbalanceThreshold: Double = 0.7

    public init() {}

    public struct CharacterReport: Sendable, Hashable, Identifiable {
        public let id: UUID            // DialogueCharacterRef.id
        public let name: String
        public let totalLineCount: Int
        public let counts: [DialogueTag.Classification: Int]
        /// The classification at or above `imbalanceThreshold`, if any.
        public let dominant: DialogueTag.Classification?
    }

    public struct TreeReport: Sendable, Hashable {
        public let perCharacter: [CharacterReport]
        public let totalLineCount: Int
        public let counts: [DialogueTag.Classification: Int]
        public let dominant: DialogueTag.Classification?

        public var hasImbalance: Bool {
            dominant != nil || perCharacter.contains { $0.dominant != nil }
        }
    }

    public func report(for tree: DialogueTree) -> TreeReport {
        var treeCounts: [DialogueTag.Classification: Int] = [:]
        var perCharacterReports: [CharacterReport] = []

        for character in tree.characters {
            let lines = tree.nodes.filter { $0.speakerID == character.id }
            var counts: [DialogueTag.Classification: Int] = [:]
            for line in lines {
                counts[line.tag.classification, default: 0] += 1
                treeCounts[line.tag.classification, default: 0] += 1
            }
            let dominant = Self.dominant(counts: counts, total: lines.count)
            perCharacterReports.append(
                CharacterReport(
                    id: character.id,
                    name: character.name,
                    totalLineCount: lines.count,
                    counts: counts,
                    dominant: dominant
                )
            )
        }

        let totalLines = tree.nodes.count
        return TreeReport(
            perCharacter: perCharacterReports,
            totalLineCount: totalLines,
            counts: treeCounts,
            dominant: Self.dominant(counts: treeCounts, total: totalLines)
        )
    }

    nonisolated static func dominant(
        counts: [DialogueTag.Classification: Int],
        total: Int
    ) -> DialogueTag.Classification? {
        guard total > 0 else { return nil }
        for (classification, count) in counts {
            let ratio = Double(count) / Double(total)
            if ratio >= imbalanceThreshold { return classification }
        }
        return nil
    }
}
