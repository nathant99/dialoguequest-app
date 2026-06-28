import Foundation

/// Per-experiment cohort change-history ring buffer (Priority Q).
///
/// `DialogueExperimentsService.variant(forExperimentID:)` is deterministic
/// per `installSeed + experimentID`, so a given install sits in ONE fixed
/// cohort per experiment today — the assignment doesn't drift across
/// launches. This service records the resolved variant at each cold
/// launch into a small ring buffer so the parent-progress dashboard can
/// surface a parental-transparency readout ("enrolled in the Treatment
/// cohort for the past N sessions") AND so a future round that changes
/// `defaultDefinitions()` (re-bucketing a kid) has a durable record of the
/// cohort migration to surface.
///
/// **Why record a constant today**: even when the cohort is fixed, the
/// per-session record is the seam that makes a FUTURE re-bucket visible.
/// The dashboard reader gates its "for the past N sessions" line on
/// `consecutiveSessions >= 2` so a single fixed cohort reads as a simple
/// transparency line rather than implying drift that isn't happening.
///
/// **Persistence**: a single `UserDefaults` key under the `dq.*`
/// namespace, JSON-encoding `[experimentID: [Entry]]` (most-recent-first
/// per experiment, capped at `historyWindow`). Mirrors
/// `VoicePatternHistoryService` — `@MainActor` final class, `.shared`
/// singleton, value-type read API, decode/encode failures route through
/// `DialogueQuestDebugLog` and degrade to empty.
///
/// **No PII / no outbound**: every recorded value is a categorical variant
/// ID (`control` / `treatment`) + a timestamp. Nothing leaves the device.
@MainActor
public final class CohortHistoryService {
    public static let shared = CohortHistoryService()

    /// Maximum launches recorded per experiment. 30 keeps several weeks
    /// of daily-launch history without unbounded growth.
    public nonisolated static let historyWindow: Int = 30

    /// `UserDefaults` key. Public so tests + the dashboard reader can
    /// reference the canonical key.
    public nonisolated static let defaultsKey = "dq.experiments.cohortHistory"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Recording

    /// Record this launch's resolved variant for every definition the
    /// service exposes. Called once per cold launch from `RootView.task`
    /// AFTER `recordExperimentAssignments` + `attachExperimentCohorts`.
    /// Definitions that resolve no variant are skipped (defensive).
    public func recordLaunch(
        from service: DialogueExperimentsService,
        now: Date = Date()
    ) {
        var stored = decoded()
        for definition in service.definitions {
            guard let variant = service.variant(forExperimentID: definition.id) else {
                continue
            }
            var window = stored[definition.id, default: []]
            window.insert(Entry(variantID: variant.id, at: now), at: 0)
            if window.count > Self.historyWindow {
                window = Array(window.prefix(Self.historyWindow))
            }
            stored[definition.id] = window
        }
        persist(stored)
    }

    /// Test seam + parental-controls reset hook. Wipes every experiment's
    /// recorded history.
    public func reset() {
        defaults.removeObject(forKey: Self.defaultsKey)
    }

    // MARK: - Reading

    /// One experiment's recorded launches, most-recent-first. Empty when
    /// nothing has been recorded for it.
    public func history(forExperimentID id: String) -> [Entry] {
        decoded()[id] ?? []
    }

    /// The variant ID recorded at the most recent launch for the
    /// experiment, or `nil` when no history exists.
    public func currentVariantID(forExperimentID id: String) -> String? {
        history(forExperimentID: id).first?.variantID
    }

    /// Count of consecutive most-recent launches that share the current
    /// variant. `0` when no history exists. For a fixed cohort this
    /// equals the total launches recorded; once a future re-bucket lands,
    /// it resets to the run-length since the change.
    public func consecutiveSessions(forExperimentID id: String) -> Int {
        let entries = history(forExperimentID: id)
        guard let current = entries.first?.variantID else { return 0 }
        var count = 0
        for entry in entries {
            if entry.variantID == current {
                count += 1
            } else {
                break
            }
        }
        return count
    }

    // MARK: - Persistence helpers

    private func decoded() -> [String: [Entry]] {
        guard let data = defaults.data(forKey: Self.defaultsKey) else {
            return [:]
        }
        do {
            return try JSONDecoder().decode([String: [Entry]].self, from: data)
        } catch {
            DialogueQuestDebugLog.data("CohortHistoryService.decoded — decode failed; treating as empty", error: error)
            return [:]
        }
    }

    private func persist(_ history: [String: [Entry]]) {
        do {
            let encoded = try JSONEncoder().encode(history)
            defaults.set(encoded, forKey: Self.defaultsKey)
        } catch {
            DialogueQuestDebugLog.data("CohortHistoryService.persist — encode failed; cohort history not persisted this launch", error: error)
        }
    }

    // MARK: - Entry

    /// One recorded launch: the resolved variant + when it was recorded.
    /// `nonisolated` so cross-target value-type callers read it without
    /// an isolation hop.
    public nonisolated struct Entry: Codable, Sendable, Hashable {
        public let variantID: String
        public let at: Date

        public init(variantID: String, at: Date) {
            self.variantID = variantID
            self.at = at
        }
    }
}
