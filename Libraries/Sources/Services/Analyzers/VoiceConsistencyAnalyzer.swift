import Foundation
import Models

/// Per-character cumulative voice-match score across the tree. The
/// canonical AI path lives in `AIMentor.PatterMentor.analyze(line:mood:)`
/// — this struct exists for two reasons:
///   1. Offline / availability-unavailable fallback so the UI dashboard
///      still has SOMETHING to render
///   2. Deterministic baseline the AI score can be calibrated against
///
/// The baseline is intentionally simple: a per-character Jaccard-style
/// token-overlap between the character's `sampleLines` and each line they
/// speak. It approximates voice register without burning AI calls.
public nonisolated struct VoiceConsistencyAnalyzer: Sendable {

    public init() {}

    public struct CharacterReport: Sendable, Hashable, Identifiable {
        public let id: UUID            // DialogueCharacterRef.id
        public let name: String
        /// 0.0-1.0; closer to 1 = closer to the sample-line baseline.
        public let averageVoiceMatchScore: Double
        /// Number of lines this character speaks in the tree.
        public let lineCount: Int
        /// Lines that score < 0.35 — the dashboard surfaces these as
        /// "out-of-voice" candidates the kid can rework.
        public let outOfVoiceLineIDs: [UUID]
    }

    public func report(for tree: DialogueTree) -> [CharacterReport] {
        tree.characters.map { ref in
            let lines = tree.nodes.filter { $0.speakerID == ref.id }
            guard !lines.isEmpty else {
                return CharacterReport(
                    id: ref.id,
                    name: ref.name,
                    averageVoiceMatchScore: 0,
                    lineCount: 0,
                    outOfVoiceLineIDs: []
                )
            }
            let baselineTokens = Self.tokenSet(for: ref.sampleLines.joined(separator: " "))
            var scoreSum: Double = 0
            var outOfVoice: [UUID] = []
            for node in lines {
                let lineTokens = Self.tokenSet(for: node.surfaceText)
                let score = Self.jaccard(baselineTokens, lineTokens)
                scoreSum += score
                if score < 0.35 { outOfVoice.append(node.id) }
            }
            return CharacterReport(
                id: ref.id,
                name: ref.name,
                averageVoiceMatchScore: scoreSum / Double(lines.count),
                lineCount: lines.count,
                outOfVoiceLineIDs: outOfVoice
            )
        }
    }

    // MARK: - WritingEvaluator bridge

    /// Per-line `WritingEvaluator.VoiceCheck` projections — one per
    /// speaking node in the tree. Source-agnostic shape per
    /// `Models/ValueTypes/WritingEvaluator.swift`; consumers should
    /// prefer this over the raw `CharacterReport` shape when they
    /// don't need character-level aggregation.
    public func voiceChecks(for tree: DialogueTree) -> [WritingEvaluator.VoiceCheck] {
        tree.characters.flatMap { ref -> [WritingEvaluator.VoiceCheck] in
            let lines = tree.nodes.filter { $0.speakerID == ref.id }
            let baselineTokens = Self.tokenSet(for: ref.sampleLines.joined(separator: " "))
            return lines.map { node in
                let lineTokens = Self.tokenSet(for: node.surfaceText)
                let score = Self.jaccard(baselineTokens, lineTokens)
                return WritingEvaluator.VoiceCheck(
                    id: node.id,
                    speakerID: ref.id,
                    surfaceText: node.surfaceText,
                    voiceMatchScore: score
                )
            }
        }
    }

    /// Tree-wide summary suitable for the dashboard. Aggregates the
    /// per-character means and surfaces drifting line IDs.
    public func summary(for tree: DialogueTree) -> WritingEvaluator.VoiceSummary {
        let perChar = report(for: tree)
        let speaking = perChar.filter { $0.lineCount > 0 }
        let perCharacterAverage = Dictionary(
            uniqueKeysWithValues: speaking.map { ($0.id, $0.averageVoiceMatchScore) }
        )
        let treeAverage: Double?
        if speaking.isEmpty {
            treeAverage = nil
        } else {
            treeAverage = speaking.map(\.averageVoiceMatchScore).reduce(0, +) / Double(speaking.count)
        }
        let drifting = voiceChecks(for: tree)
            .filter { $0.band == .drifting }
            .map(\.id)
        return WritingEvaluator.VoiceSummary(
            perCharacterAverage: perCharacterAverage,
            treeAverage: treeAverage,
            driftingLineIDs: drifting
        )
    }

    // MARK: - Token helpers

    /// Lowercase, strip non-alphanumerics, split on whitespace, drop
    /// 1-character tokens. Stable across simulator + device.
    nonisolated static func tokenSet(for text: String) -> Set<String> {
        let scalars = text.unicodeScalars.map { scalar -> Character in
            if CharacterSet.alphanumerics.contains(scalar) { return Character(scalar) }
            if CharacterSet.whitespacesAndNewlines.contains(scalar) { return " " }
            return " "
        }
        let cleaned = String(scalars).lowercased()
        let tokens = cleaned
            .split(separator: " ", omittingEmptySubsequences: true)
            .map(String.init)
            .filter { $0.count > 1 }
        return Set(tokens)
    }

    nonisolated static func jaccard(_ a: Set<String>, _ b: Set<String>) -> Double {
        guard !a.isEmpty || !b.isEmpty else { return 0 }
        let intersection = a.intersection(b).count
        let union = a.union(b).count
        return union > 0 ? Double(intersection) / Double(union) : 0
    }
}
