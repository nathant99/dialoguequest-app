import Foundation
import Models
import Services
import AIMentor

/// Glue between the dialogue-tree machine + analyzers and `PatterMentor`.
///
/// Phase 1 events:
///   • branch-point reached → Patter publishes a `BranchMeaningfulnessCheck`
///   • tag-balance imbalance crossed → Patter publishes a `TagBalanceTip`
///
/// **DN-S Move D Step 3** (additive, default off): when a `CastVoicingService`
/// is injected AND `CastVoicingFeatureFlag.isEnabled == true`, each trigger
/// also asks the matching cast member (sprig / weigh / glance / brogue / rest)
/// to speak. Patter remains the protagonist; the cast voicings populate
/// `CastVoicingService.lastVoicing` for view-side chip rendering.
///
/// **Phase Delight follow-up — Priority M.2 (this round)**: per-session
/// behavioral signals (`voiceDriftCount` / `tagImbalanceCount` /
/// `branchReflectionRatio` / `minutesSinceLastPublish`) are now tracked
/// internally so the service can map them through
/// `DialogueEmotionalStateProbe.shouldSuppressCelebrations(forSignals:)`
/// at the two celebration-shaped cast voicing surfaces:
///
/// | Surface | Suppressed when probe says? |
/// |---|---|
/// | `onBranchReflectionConfirmed` (Sprig affirmation) | YES — affirmation banter on a struggling kid is tone-deaf |
/// | `onSubtextConfirmed` (Glance affirmation)          | YES — same |
/// | `onBranchPointSelected` (Sprig prompt)             | NO — coaching nudge; should still fire |
/// | `onSubtextDiscovered` (Glance prompt)              | NO — coaching nudge; should still fire |
/// | `onVoiceDrift` (Brogue scaffold)                   | NO — coaching nudge; should still fire |
/// | `onTreeChanged` (Weigh tag-balance tip)            | NO — coaching tip; should still fire |
///
/// The probe gate maps to `EmotionalState.shouldSuppressCelebrations`
/// (true for `.frustrated` + `.disengaged`), so a kid who hits 3+ voice
/// drifts in a session no longer gets piled-on cast banter when they
/// eventually land a subtext confirmation. Patter still mentors.
///
/// Pure orchestration — does not own UI state. Views observe the
/// published-bubble property and render accordingly. Every call falls
/// back via `PatterMentor`'s internal fallback dictionary if FM is
/// unavailable.
@MainActor
@Observable
public final class PatterReactionService {
    public private(set) var latestBubbleMessage: String?
    public private(set) var lastTagBalanceTip: TagBalanceTip?

    @ObservationIgnored
    private let mentor: PatterMentor
    @ObservationIgnored
    private let tagBalancer = TagBalancer()
    @ObservationIgnored
    private let voiceAnalyzer = VoiceConsistencyAnalyzer()
    @ObservationIgnored
    private let castVoicing: CastVoicingService?
    /// DDA engine threading the voice-match floor through the reaction
    /// service so the drift threshold ramps with the kid's recent
    /// performance rather than sticking at the static
    /// `CastVoiceRegistry.voiceDriftThreshold` constant.
    @ObservationIgnored
    private var dda: DDAEngine
    /// The dominant classification we surfaced a tip for, so we don't
    /// re-fire the tip until the dominant classification CHANGES.
    @ObservationIgnored
    private var lastSurfaceTagClassification: DialogueTag.Classification?
    /// The branch-point IDs we've already greeted, so re-selecting the
    /// same branch-point doesn't re-fire the cast voicing.
    @ObservationIgnored
    private var greetedBranchPointIDs: Set<UUID> = []

    // MARK: - Emotional-state signal tracking (Priority M.2, 2026-07-03)

    /// Number of times `onVoiceDrift` fired the cast scaffold this
    /// session (post-threshold). Maps to `Signals.voiceDriftCount`.
    @ObservationIgnored
    private var voiceDriftCount: Int = 0
    /// Number of times `onTreeChanged` surfaced a fresh tag-balance tip
    /// this session (dominant-class change events). Maps to
    /// `Signals.tagImbalanceCount`.
    @ObservationIgnored
    private var tagImbalanceCount: Int = 0
    /// Timestamp of the most recent `recordTreeOutcome` call this
    /// session (published-tree marker). `nil` means no publishes yet.
    /// Maps to `Signals.minutesSinceLastPublish`.
    @ObservationIgnored
    private var lastPublishAt: Date?
    /// Most recent per-tree `reflectionRatio` from `recordTreeOutcome`.
    /// Defaults to 1.0 ("no branches yet — not stalled") matching the
    /// `Signals` init default. Maps to `Signals.branchReflectionRatio`.
    @ObservationIgnored
    private var lastBranchReflectionRatio: Double = 1.0
    /// Number of times the celebration suppression gate fired this
    /// session. Exposed read-only so tests + diagnostic surfaces can
    /// confirm wiring without dipping into the cast-voicing chip state.
    public private(set) var suppressedCelebrationCount: Int = 0

    /// Injectable clock so tests can advance `minutesSinceLastPublish`
    /// without sleeping. Mirrors the `RetentionMetricsService` /
    /// `StreakService` / `ReturnLoopService` precedent.
    @ObservationIgnored
    private let clock: @Sendable () -> Date

    public init(
        mentor: PatterMentor,
        castVoicing: CastVoicingService? = nil,
        dda: DDAEngine = DDAEngine(),
        clock: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.mentor = mentor
        self.castVoicing = castVoicing
        self.dda = dda
        self.clock = clock
    }

    /// Currently-effective voice-match floor. The view consumers (e.g.,
    /// `SubtextPanelView`'s voice-match bar) can ask this service for
    /// the live threshold instead of hardcoding
    /// `CastVoiceRegistry.voiceDriftThreshold`. Falls through to the
    /// stricter of `dda.currentVoiceMatchFloor` and the registry
    /// constant so the DDA engine can only lower the floor (be more
    /// permissive) within bounds, never raise it above the canonical
    /// drift threshold.
    public var effectiveVoiceDriftThreshold: Double {
        min(CastVoiceRegistry.voiceDriftThreshold, dda.currentVoiceMatchFloor)
    }

    /// Snapshot of the per-session signals the
    /// `DialogueEmotionalStateProbe` consumes. Exposed read-only so the
    /// parent-progress dashboard + future descriptors can read the
    /// same signal set the suppression gate sees without re-implementing
    /// the capture logic.
    public var currentSignals: DialogueEmotionalStateProbe.Signals {
        DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: voiceDriftCount,
            tagImbalanceCount: tagImbalanceCount,
            branchReflectionRatio: lastBranchReflectionRatio,
            minutesSinceLastPublish: minutesSinceLastPublish(now: clock())
        )
    }

    /// Whether celebration cast voicings should be suppressed right now.
    /// Public so callers in `WriteTabView` (variable-reward bonus tips /
    /// celebration cinematics / mastery-moment flourishes) can also
    /// consult the gate without re-implementing the signal snapshot.
    public var shouldSuppressCelebrationsNow: Bool {
        DialogueEmotionalStateProbe.shouldSuppressCelebrations(forSignals: currentSignals)
    }

    private func minutesSinceLastPublish(now: Date) -> Double? {
        guard let lastPublishAt else { return nil }
        return now.timeIntervalSince(lastPublishAt) / 60.0
    }

    /// Push a per-tree outcome into the DDA engine. Called by the
    /// host view after a publish event when both reflection ratio and
    /// average voice-match score are known. Pure mutation; no UI side
    /// effects (the next coaching call reads the updated threshold).
    /// Also stamps `lastPublishAt = clock()` + records the reflection
    /// ratio so the emotional-state probe can read fresh
    /// `minutesSinceLastPublish` + `branchReflectionRatio` signals.
    public func recordTreeOutcome(reflectionRatio: Double, averageVoiceMatch: Double) {
        dda.record(
            outcome: .init(
                reflectionRatio: reflectionRatio,
                averageVoiceMatch: averageVoiceMatch
            )
        )
        lastBranchReflectionRatio = max(0.0, min(1.0, reflectionRatio))
        lastPublishAt = clock()
        EmotionalSignalsPersistence.record(signals: currentSignals)
    }

    /// Call when the kid's selection moved to a branch-point node. The
    /// sheet UI handles the heavy lift; this hook is for surfacing a
    /// one-line bubble outside the sheet.
    public func onBranchPointSelected(branchPointID: UUID, mood: DialogueMood?) async {
        let check = await mentor.branchCheck(for: mood)
        latestBubbleMessage = check.question1
        guard let castVoicing else { return }
        guard greetedBranchPointIDs.insert(branchPointID).inserted else { return }
        // Coaching nudge — does NOT pass through the suppression gate.
        // Even a frustrated kid benefits from being asked the question
        // again; the gate only silences celebrations.
        await castVoicing.respond(to: .branchPointReached, topic: mood?.displayName)
    }

    /// Call after a branch reflection is confirmed (3-question Socratic
    /// check completed). Sprig affirms via cast voicing if enabled.
    ///
    /// **Suppression gate**: affirmation is celebratory; when the per-
    /// session signals trip `.frustrated` / `.disengaged`, the gate
    /// fires and Sprig stays quiet. Patter still mentors.
    public func onBranchReflectionConfirmed(mood: DialogueMood?) async {
        guard let castVoicing else { return }
        if shouldSuppressCelebrationsNow {
            suppressedCelebrationCount += 1
            return
        }
        await castVoicing.respond(to: .branchReflectionConfirmed, topic: mood?.displayName)
    }

    /// Call after every node mutation. If the tree's dominant tag-class
    /// changed since the last call, publish a fresh `TagBalanceTip`.
    public func onTreeChanged(_ tree: DialogueTree) async {
        let report = tagBalancer.report(for: tree)
        guard let dominant = report.dominant else {
            if lastSurfaceTagClassification != nil {
                lastSurfaceTagClassification = nil
                lastTagBalanceTip = nil
            }
            return
        }
        if dominant == lastSurfaceTagClassification { return }
        lastSurfaceTagClassification = dominant
        let tip = await mentor.tagBalanceTip(dominant: dominant)
        lastTagBalanceTip = tip
        latestBubbleMessage = tip.observation
        // Bump the per-session imbalance counter BEFORE the cast voicing
        // dispatch so the next snapshot reads the post-fire count. The
        // imbalance tip is a coaching surface — does NOT pass through
        // the suppression gate.
        tagImbalanceCount += 1
        EmotionalSignalsPersistence.record(signals: currentSignals)
        if let castVoicing {
            await castVoicing.respond(to: .tagBalanceImbalance, topic: tree.mood?.displayName)
        }
    }

    /// Call when a non-empty inferred subtext lands on the panel.
    /// Glance encourages the kid to name it.
    public func onSubtextDiscovered(line: String, mood: DialogueMood?) async {
        guard let castVoicing else { return }
        // Coaching nudge — does NOT pass through the suppression gate.
        await castVoicing.respond(to: .subtextDiscovered, topic: mood?.displayName)
    }

    /// Call when the kid taps "Yes, that's it" on the subtext panel.
    /// Glance affirms the aha moment.
    ///
    /// **Suppression gate**: affirmation is celebratory; when the per-
    /// session signals trip `.frustrated` / `.disengaged`, the gate
    /// fires and Glance stays quiet. Patter still mentors.
    public func onSubtextConfirmed(mood: DialogueMood?) async {
        guard let castVoicing else { return }
        if shouldSuppressCelebrationsNow {
            suppressedCelebrationCount += 1
            return
        }
        await castVoicing.respond(to: .subtextConfirmed, topic: mood?.displayName)
    }

    /// Call when the analyzer reports a voice-match score below
    /// `effectiveVoiceDriftThreshold`. Brogue scaffolds the kid back
    /// into voice register. The threshold ramps with `DDAEngine` so a
    /// struggling kid sees fewer drift nudges and a confident one sees
    /// stricter coaching.
    public func onVoiceDrift(score: Double, mood: DialogueMood?) async {
        guard score < effectiveVoiceDriftThreshold else { return }
        // Bump the per-session counter BEFORE the cast voicing dispatch
        // so the next snapshot reads the post-fire count. The scaffold
        // is a coaching surface — does NOT pass through the suppression
        // gate. The counter feeds the probe's frustration tier.
        voiceDriftCount += 1
        EmotionalSignalsPersistence.record(signals: currentSignals)
        guard let castVoicing else { return }
        await castVoicing.respond(to: .voiceDrift, topic: mood?.displayName)
    }

    /// Reset to the empty state (e.g., when the kid resets the tree).
    public func reset() {
        latestBubbleMessage = nil
        lastTagBalanceTip = nil
        lastSurfaceTagClassification = nil
        greetedBranchPointIDs.removeAll()
        castVoicing?.reset()
        dda.reset()
        voiceDriftCount = 0
        tagImbalanceCount = 0
        lastPublishAt = nil
        lastBranchReflectionRatio = 1.0
        suppressedCelebrationCount = 0
    }
}
