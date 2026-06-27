import Foundation
import ForgeAnalytics

/// On-device privacy-safe analytics shim that wraps ForgeKit's `AnalyticsEngine`
/// (PII-filtered, retention-bounded, zero outbound) and exposes a Swift-Testing-
/// friendly synchronous `track` surface for SwiftUI view code.
///
/// All events stay on-device. No third-party SDK. No network transmission.
/// Per the technical-design Child-Safety table + the portfolio "No third-party
/// analytics SDKs" policy.
///
/// Reader-facing event properties stay categorical (mood, badge id, node count
/// bucket) — never raw text, never UUIDs, never display names. PII keys are
/// rejected at the engine layer; this shim adds a domain-level discipline so
/// the engine never sees PII in the first place.
@MainActor
public final class DialogueQuestAnalytics {
    public static let shared = DialogueQuestAnalytics()

    /// Underlying ForgeAnalytics engine. Exposed for tests + the
    /// ParentProgressDashboard reader path.
    public let engine: AnalyticsEngine

    public init(engine: AnalyticsEngine = AnalyticsEngine(config: AnalyticsConfig())) {
        self.engine = engine
    }

    /// Cohort-lens properties resolved once at first attachment and
    /// merged into every subsequent `track(_:properties:)` call so the
    /// on-device retention reader can segment any event by the user's
    /// then-current experiment cohort. Keys use the `cohort.<experiment-id>`
    /// prefix; values are the categorical variant id
    /// (typically `control` / `treatment`). Caller-supplied properties
    /// win on key collision so a future per-event override stays
    /// possible without breaking the lens.
    ///
    /// **Why every event, not a single attachment event** (Priority A,
    /// 2026-07-07): the existing `experiment_variant_assigned` event
    /// emits at cold launch only. Without an event-attached cohort
    /// lens, the on-device retention reader has to time-join every
    /// follow-up event against the most-recent assignment record.
    /// Attaching the lens at emission time removes the join entirely —
    /// any single event row carries the cohort it was emitted under.
    /// Cost: ~2 string keys × ~64 bytes per event = ~128 bytes on
    /// every event; negligible vs the existing event payload.
    private var cohortLens: [String: String] = [:]

    /// Canonical DialogueQuest event vocabulary. Stable across releases so the
    /// parent-progress reader can mine historical events without schema churn.
    public enum Event: String, Sendable, CaseIterable {
        case treePublished = "tree_published"
        case subtextConfirmed = "subtext_confirmed"
        case subtextRejected = "subtext_rejected"
        case branchReflected = "branch_reflected"
        case badgeEarned = "badge_earned"
        case streakAdvanced = "streak_advanced"
        case streakHeldUnderDistress = "streak_held_under_distress"
        case streakBroken = "streak_broken"
        case welcomeBackShown = "welcome_back_shown"
        case sessionTimerGentleNudge = "session_timer_gentle_nudge"
        case sessionEndingSummaryShown = "session_ending_summary_shown"
        case anthologyEntryShared = "anthology_entry_shared"
        case castVoicingShown = "cast_voicing_shown"
        case performanceBoothExported = "performance_booth_exported"
        case experimentVariantAssigned = "experiment_variant_assigned"
        /// Parent tapped "Reset emotional snapshot" in Settings → Privacy
        /// (Priority R, 2026-07-06). Fires after the
        /// `ParentalGateChallenge` clears AND
        /// `EmotionalSignalsPersistence.reset()` has run. No properties —
        /// the action is binary + categorical and the on-device retention
        /// reader only needs to know it happened.
        case emotionalSnapshotReset = "emotional_snapshot_reset"
    }

    /// Fire-and-forget tracking for SwiftUI call sites. Properties whose keys
    /// match the ForgeAnalytics PII blocklist are dropped silently at the engine
    /// layer; the categorical-only discipline here is the upstream guard.
    ///
    /// **Cohort lens merge**: when `attachExperimentCohorts(...)` has been
    /// called this launch, every event picks up `cohort.<experiment-id>`
    /// properties from the cached lens. Caller-supplied properties win on
    /// key collision so per-event overrides remain possible.
    public func track(_ event: Event, properties: [String: String] = [:]) {
        let name = event.rawValue
        let engineRef = engine
        var merged = cohortLens
        for (key, value) in properties {
            merged[key] = value
        }
        Task { await engineRef.track(name, properties: merged) }
    }

    @discardableResult
    public func startSession() async -> UUID {
        await engine.startSession()
    }

    @discardableResult
    public func endSession() async -> SessionSummary? {
        await engine.endSession()
    }

    public func recentSessionCount(last days: Int = 7) async -> Int {
        await engine.sessionCount(last: days)
    }

    public func activeDays(last days: Int = 30) async -> Int {
        await engine.activeDays(last: days)
    }

    /// Emit one `experimentVariantAssigned` event per registered
    /// experiment. Called at cold launch from `RootView.task` so the
    /// on-device retention pipeline can segment by experiment cohort
    /// without re-running the deterministic assignment.
    ///
    /// **Why cold launch, not per-variant-lookup**: the variant is
    /// stable per install — duplicate emissions are noise. The cold-
    /// launch hook emits once per app open, which is the natural cadence
    /// for the on-device retention reader.
    ///
    /// **Properties are categorical** (raw experiment + variant IDs,
    /// never display names). The PII blocklist at the engine layer is
    /// the second line of defense; this discipline is the first.
    public func recordExperimentAssignments(
        experiments: DialogueExperimentsService = .shared
    ) {
        for definition in experiments.definitions {
            guard let variant = experiments.variant(forExperimentID: definition.id) else {
                continue
            }
            track(
                .experimentVariantAssigned,
                properties: [
                    "experiment_id": definition.id,
                    "variant_id": variant.id,
                ]
            )
        }
    }

    /// Attach an experiment-cohort lens that augments every subsequent
    /// `track(_:properties:)` call with `cohort.<experiment-id>` ⇒
    /// variant-id properties. Idempotent — calling twice with the same
    /// definitions produces the same lens.
    ///
    /// Called at cold launch from `RootView.task` immediately AFTER
    /// `recordExperimentAssignments(...)` so the assignment record event
    /// itself ALSO carries the lens (no special-casing needed; the
    /// event's primary `experiment_id` + `variant_id` keys live
    /// alongside the lens's `cohort.<experiment-id>` keys without
    /// collision).
    ///
    /// **Why merge into `track`, not gate on a separate API**: the
    /// existing event vocabulary is stable + load-bearing for the
    /// parent-progress dashboard's per-event reader. A second emission
    /// path would fork the surface; merging at the seam keeps the
    /// vocabulary unchanged.
    public func attachExperimentCohorts(
        experiments: DialogueExperimentsService = .shared
    ) {
        var lens: [String: String] = [:]
        for definition in experiments.definitions {
            guard let variant = experiments.variant(forExperimentID: definition.id) else {
                continue
            }
            lens["cohort.\(definition.id)"] = variant.id
        }
        cohortLens = lens
    }

    /// Test-only escape hatch — clears the attached cohort lens so
    /// subsequent `track(...)` calls emit without cohort properties.
    /// Production callers MUST NOT call this; the lens is meant to
    /// stay attached for the entire app session once
    /// `attachExperimentCohorts(...)` runs at cold launch.
    public func clearExperimentCohortsForTesting() {
        cohortLens = [:]
    }
}
