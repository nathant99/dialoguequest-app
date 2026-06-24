import Foundation
import Models

/// Per-character voice-signature longitudinal store. Records the
/// `WritingEvaluator.VoiceSummary.perCharacterAverage` of every
/// published tree so future Patter coaching surfaces (and the parent
/// progress dashboard) can read pattern trends across sessions —
/// "Brogue's voice has gotten steadier over your last 5 publishes"
/// rather than a single snapshot.
///
/// Closes the deferred Phase Delight follow-up row described in the
/// 2026-06-26 round-close session handoff (`Priority F — Voice-pattern
/// axis longitudinal store (post-Phase Delight follow-up)`). Until this
/// service shipped, `PatterCallbackService` only callback-axis was
/// mood + title; the voice-pattern axis was deferred because no
/// longitudinal store existed for `VoiceSummary` to land in.
///
/// **Persistence**: per-character rolling window of the last
/// `historyWindow` recorded voice-match means. Encoded as JSON
/// `[UUID-string : [Double]]` (most-recent-first per character) in
/// a single `UserDefaults` key. Tied to the same `dq.*` namespace
/// the rest of the app uses.
///
/// **No PII / no outbound**: every recorded value is a clamped 0...1
/// `Double` derived from `VoiceConsistencyAnalyzer.summary(for:)` or
/// `WritingEvaluator.VoiceSummary.perCharacterAverage`. Character IDs
/// are UUIDs the kid never sees; mapping back to a name happens via
/// the in-tree `DialogueCharacterRef`, not via this store. Nothing
/// leaves the device.
///
/// **Read shape**: `recentScores(for:)` returns the most-recent-first
/// rolling window; `trend(for:)` collapses the window into a
/// 4-case `Trend` enum so coaching surfaces don't have to reason
/// about deltas. The thresholds (`trendDelta`) align with the
/// existing `WritingEvaluator.VoiceBand` step (~0.08, roughly a
/// quarter of the drifting / acceptable / strong band width).
@MainActor
public final class VoicePatternHistoryService {
    public static let shared = VoicePatternHistoryService()

    /// Maximum number of records the service keeps per character.
    /// Five publishes is enough to show a meaningful trend without
    /// either (a) drowning out a recent shift or (b) being so narrow
    /// that a single noisy tree dominates the signal.
    public nonisolated static let historyWindow: Int = 5

    /// `|last - first|` threshold for classifying a window as
    /// `.improving` or `.drifting` (otherwise `.steady`). Sized to
    /// the `VoiceBand` step so a kid moving from acceptable into
    /// strong (≈ 0.65 → 0.73) registers as improvement.
    public nonisolated static let trendDelta: Double = 0.08

    /// Minimum number of records before `trend(for:)` returns
    /// anything other than `.insufficientData`. Two is the floor —
    /// you need at least one delta to call a trend.
    public nonisolated static let minimumRecordsForTrend: Int = 2

    /// `UserDefaults` key. Public so tests + future parent-progress
    /// dashboard reads can reference the canonical key.
    public nonisolated static let defaultsKey = "dq.voicePattern.perCharacterHistory"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Recording

    /// Record the per-character means from a freshly published tree's
    /// `WritingEvaluator.VoiceSummary`. Characters with no speaking
    /// lines in this tree (absent from `perCharacterAverage`) are
    /// left untouched — their history doesn't decay on publishes that
    /// don't involve them.
    public func recordPublishedTree(summary: WritingEvaluator.VoiceSummary) {
        let perCharacter = summary.perCharacterAverage
        guard !perCharacter.isEmpty else { return }
        var stored = decodedHistory()
        for (speakerID, score) in perCharacter {
            let key = speakerID.uuidString
            let clamped = max(0, min(1, score))
            var window = stored[key, default: []]
            window.insert(clamped, at: 0)
            if window.count > Self.historyWindow {
                window = Array(window.prefix(Self.historyWindow))
            }
            stored[key] = window
        }
        persist(stored)
    }

    /// Test seam + parental-controls reset hook. Wipes every
    /// character's recorded history.
    public func reset() {
        defaults.removeObject(forKey: Self.defaultsKey)
    }

    // MARK: - Reading

    /// Snapshot of one character's rolling history, most-recent-first.
    /// Returns an empty array when no records exist for the character.
    public func recentScores(for speakerID: UUID) -> [Double] {
        decodedHistory()[speakerID.uuidString] ?? []
    }

    /// Snapshot of every character's rolling history, keyed by
    /// `speakerID`. Order within each character's array is
    /// most-recent-first. Empty when no publishes have been
    /// recorded.
    public func allHistories() -> [UUID: [Double]] {
        var converted: [UUID: [Double]] = [:]
        for (key, values) in decodedHistory() {
            if let uuid = UUID(uuidString: key) {
                converted[uuid] = values
            }
        }
        return converted
    }

    /// Collapsed 4-case classification of the per-character window.
    /// Pure value-type read. Future Patter coaching surfaces consume
    /// this directly — `.improving` triggers a celebratory callback,
    /// `.drifting` triggers a gentle "want to try one more line in
    /// their voice?" nudge.
    public func trend(for speakerID: UUID) -> Trend {
        let scores = recentScores(for: speakerID)
        guard scores.count >= Self.minimumRecordsForTrend else {
            return .insufficientData
        }
        // `scores` is most-recent-first; `first` is the latest,
        // `last` is the oldest of the window. Trend is latest minus
        // oldest so a positive delta = improving.
        guard let latest = scores.first, let oldest = scores.last else {
            return .insufficientData
        }
        let delta = latest - oldest
        if delta > Self.trendDelta { return .improving }
        if delta < -Self.trendDelta { return .drifting }
        return .steady
    }

    // MARK: - Persistence helpers

    private func decodedHistory() -> [String: [Double]] {
        guard
            let data = defaults.data(forKey: Self.defaultsKey),
            let decoded = try? JSONDecoder().decode([String: [Double]].self, from: data)
        else {
            return [:]
        }
        return decoded
    }

    private func persist(_ history: [String: [Double]]) {
        guard let encoded = try? JSONEncoder().encode(history) else { return }
        defaults.set(encoded, forKey: Self.defaultsKey)
    }

    // MARK: - Trend enum

    /// Per-character trend classification across the rolling window.
    /// `Sendable` + `nonisolated` so cross-target callers (e.g.
    /// `AppFeature.PatterReactionService`) can read it without an
    /// isolation hop.
    public nonisolated enum Trend: String, Sendable, Equatable, Codable, CaseIterable {
        /// Fewer than `minimumRecordsForTrend` records — can't call
        /// a direction yet.
        case insufficientData
        /// Latest score exceeds oldest by more than `trendDelta`.
        case improving
        /// Latest is within `±trendDelta` of oldest — flat.
        case steady
        /// Oldest exceeds latest by more than `trendDelta`.
        case drifting
    }
}
