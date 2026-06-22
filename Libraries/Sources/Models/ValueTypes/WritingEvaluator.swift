import Foundation

/// Cross-cluster value-type shape for voice-consistency checks.
///
/// Per `@Docs/IMPLEMENTATION_HANDOFF.md` § 5 + `@Docs/TECHNICAL_DESIGN.md`
/// § New Engines: the writing-craft cluster (DialogueQuest /
/// CharacterForge / HaikuQuest / LyricForge / VoiceTale) shares one
/// canonical voice-check API so per-app analyzers + AI mentor outputs
/// project into the same value type, enabling cross-app voice-baseline
/// reuse later (e.g., a CharacterForge-imported character drops into
/// DialogueQuest with a familiar score shape).
///
/// Two producers in DialogueQuest:
///   1. `VoiceConsistencyAnalyzer` — deterministic Jaccard baseline
///      (`Services/Analyzers/VoiceConsistencyAnalyzer.swift`)
///   2. `PatterMentor.analyze(line:mood:)` — AI mentor structured
///      output (`AIMentor/Generables/DialogueLineAnalysis.swift`),
///      bridged to `VoiceCheck` via `.toVoiceCheck()` (see `AIMentor`
///      `Generables/WritingEvaluator+Bridge.swift`).
///
/// Consumers should program against `VoiceCheck` rather than either
/// concrete producer, so swapping in a different scorer (or a
/// CharacterForge-imported voice baseline) is a one-line change.
public enum WritingEvaluator {

    /// Qualitative band for a voice-match score. The bands match the
    /// existing `SubtextPanelView` rubric (red < 0.4 < amber < 0.65 ≤
    /// green) so the dashboard render doesn't have to know the raw
    /// thresholds.
    public nonisolated enum VoiceBand: String, Sendable, Codable, CaseIterable, Hashable {
        case drifting        // < 0.4
        case acceptable      // 0.4...0.65
        case strong          // > 0.65

        /// Compute the band from a 0...1 voice-match score using the
        /// canonical DialogueQuest thresholds.
        public static func band(for score: Double) -> VoiceBand {
            if score < 0.4 { return .drifting }
            if score <= 0.65 { return .acceptable }
            return .strong
        }
    }

    /// Per-line voice-consistency check. Source-agnostic — produced
    /// by either the deterministic analyzer or the AI mentor.
    public nonisolated struct VoiceCheck: Sendable, Hashable, Codable, Identifiable {
        public let id: UUID
        /// Stable speaker reference so cross-app + cross-tree
        /// aggregation can group on the character. May be `nil` when
        /// the check is a per-character summary rather than a per-line
        /// check.
        public let speakerID: UUID?
        /// Original line text (the `surfaceText` from
        /// `DialogueLineAnalysis`).
        public let surfaceText: String
        /// 0...1. 1.0 = perfect voice-register match.
        public let voiceMatchScore: Double
        /// Computed-from-score band so consumers don't have to know
        /// the thresholds.
        public let band: VoiceBand

        public init(
            id: UUID = UUID(),
            speakerID: UUID? = nil,
            surfaceText: String,
            voiceMatchScore: Double
        ) {
            self.id = id
            self.speakerID = speakerID
            self.surfaceText = surfaceText
            let clamped = max(0, min(1, voiceMatchScore))
            self.voiceMatchScore = clamped
            self.band = VoiceBand.band(for: clamped)
        }
    }

    /// Tree-wide voice-consistency summary. Produced by an analyzer
    /// after evaluating every speaking line in a `DialogueTree`.
    public nonisolated struct VoiceSummary: Sendable, Hashable, Codable {
        /// Per-character mean voice-match score (0...1).
        public let perCharacterAverage: [UUID: Double]
        /// Tree-wide mean voice-match score across all characters
        /// that speak at least one line. `nil` when no characters
        /// have spoken yet.
        public let treeAverage: Double?
        /// Lines flagged as drifting (band == .drifting). Visible to
        /// the dashboard as "lines to revisit".
        public let driftingLineIDs: [UUID]

        public init(
            perCharacterAverage: [UUID: Double],
            treeAverage: Double?,
            driftingLineIDs: [UUID]
        ) {
            self.perCharacterAverage = perCharacterAverage
            self.treeAverage = treeAverage
            self.driftingLineIDs = driftingLineIDs
        }
    }
}
