import Foundation
import ForgeEmotionAware

/// Phase Delight follow-up wrapper around ForgeKit's `ForgeEmotionAware`
/// emotional-state ladder. Surfaces a parent-readable descriptor for the
/// kid's likely emotional state during a writing session.
///
/// **Why this seam exists**: DialogueQuest's `PatterReactionService` +
/// `WriteTabView` already observe per-session behavioral signals (voice
/// drift events, tag-balance imbalance, branch reflections completed,
/// trees published). The probe is the value-type entry point that maps
/// `(voiceDriftCount, tagImbalanceCount, branchReflectionRatio,
/// minutesSinceLastPublish) → EmotionalState → DialogueEmotionalStateDescriptor`.
/// The mapping is deterministic + heuristic today; a future enhancement
/// can swap in `ForgeEmotionAware.EmotionDetector` once the writing
/// surface produces `ForgeModels.AnswerRecord`-shaped events (out of
/// scope today — DialogueQuest is a writing tool, not a quiz).
///
/// **What this probe does NOT do** (intentional; mirrors the
/// `DevelopmentalCapacityProbe` precedent):
/// - It does NOT activate any GUI surface today. The probe is a pure
///   value-type seam; `PatterReactionService` + `ParentProgressDashboardView`
///   can adopt it in a future round once the suppression of celebrations
///   based on negative emotional state is wired through.
/// - It does NOT touch persistence. Stateless static helpers.
/// - It does NOT call FoundationModels. The mapping is rule-based so the
///   parent-progress dashboard can render the descriptor offline + the
///   suppression decision lands the same way for every kid given the
///   same signal set.
///
/// **DialogueQuest-relevant states**: per `ForgeEmotionAware.EmotionalState`
/// the 7-case ladder is `flow` / `frustrated` / `bored` / `disengaged` /
/// `confused` / `confident` / `recovering`. DialogueQuest's writing
/// surface most cleanly maps to:
///
/// | Signal pattern | Probe → EmotionalState | Why |
/// |---|---|---|
/// | 0-1 voice drifts, 0-1 imbalances, ≥0.5 reflection ratio, recent publish | `.flow` | Steady authoring rhythm, mentor coaching is sticking |
/// | 3+ voice drifts, OR ≥3 imbalances in one session | `.frustrated` | Mentor is firing repeatedly on the same axis without behavior changing |
/// | < 0.25 reflection ratio + minutesSinceLastPublish > 25 | `.disengaged` | Branches stay un-reflected; cadence stalls |
/// | 2 voice drifts + 2 imbalances + < 0.5 reflection ratio | `.confused` | Mentor firing across multiple axes; kid not converging |
/// | < 1 reflection per session, no publishes in 30+ min | `.bored` | Authoring without engagement loop |
/// | Recent publish + < 1 voice drift + ≥ 0.5 reflection ratio | `.confident` | Held a publish under steady authoring quality |
/// | Was `.frustrated` last snapshot, now `.flow` or `.confident` | `.recovering` | Trajectory recovery (heuristic; caller threads the prior state) |
///
/// **Why `nonisolated public enum`**: pure value-typed namespace so
/// callers across MainActor / nonisolated boundaries reach it without
/// an actor hop. Mirrors `DevelopmentalCapacityProbe` + `DialogueQuestDebugLog`.
public nonisolated enum DialogueEmotionalStateProbe {

    /// Per-session behavioral signals captured by `PatterReactionService`
    /// + `WriteTabView`. The value type is `Sendable` + `Equatable` so it
    /// rides cleanly across MainActor → background boundaries when the
    /// probe is consumed off the writing surface.
    public nonisolated struct Signals: Sendable, Equatable {

        /// Number of voice-drift events the mentor fired this session.
        public var voiceDriftCount: Int

        /// Number of tag-balance imbalance events fired this session.
        public var tagImbalanceCount: Int

        /// Ratio of branch points the kid reflected on (0.0 = none, 1.0
        /// = every branch point reflected). When there are no branch
        /// points yet, the ratio is 1.0 (treat absence as not-stalled).
        public var branchReflectionRatio: Double

        /// Minutes elapsed since the kid's last `.published` transition
        /// in this session. `nil` if no publish yet this session.
        public var minutesSinceLastPublish: Double?

        /// Optional prior-snapshot emotional state. When non-nil, the
        /// probe surfaces `.recovering` for a `.frustrated` → `.flow` /
        /// `.confident` transition without callers re-implementing the
        /// trajectory heuristic. Threading this through is optional.
        public var priorState: EmotionalState?

        public init(
            voiceDriftCount: Int = 0,
            tagImbalanceCount: Int = 0,
            branchReflectionRatio: Double = 1.0,
            minutesSinceLastPublish: Double? = nil,
            priorState: EmotionalState? = nil
        ) {
            self.voiceDriftCount = voiceDriftCount
            self.tagImbalanceCount = tagImbalanceCount
            self.branchReflectionRatio = max(0.0, min(1.0, branchReflectionRatio))
            self.minutesSinceLastPublish = minutesSinceLastPublish
            self.priorState = priorState
        }
    }

    /// Suggest the best-fit emotional state for the captured signals.
    /// Order of precedence (most specific first):
    /// 1. `.frustrated` — 3+ voice drifts OR 3+ imbalances (signal-axis saturation)
    /// 2. `.confused`   — 2 voice drifts + 2 imbalances + < 0.5 reflection ratio
    /// 3. `.bored`      — zero signal events + 30+ min since last publish (nothing firing at all)
    /// 4. `.disengaged` — < 0.25 reflection ratio + 25+ min since last publish (branching without depth)
    /// 5. `.confident`  — recent publish (< 5 min) + ≤ 1 voice drift + ≥ 0.5 reflection ratio
    /// 6. `.recovering` — `priorState == .frustrated` and current is `.flow` / `.confident`
    /// 7. `.flow`       — default; steady authoring without trigger conditions
    public static func suggestedState(forSignals signals: Signals) -> EmotionalState {
        let proposed = classifyWithoutTrajectory(signals)
        if let prior = signals.priorState,
           prior == .frustrated,
           (proposed == .flow || proposed == .confident) {
            return .recovering
        }
        return proposed
    }

    /// Pure-classification step. Trajectory recovery layered on top.
    private static func classifyWithoutTrajectory(_ signals: Signals) -> EmotionalState {
        // Tier 1 — signal-axis saturation: one axis firing repeatedly.
        if signals.voiceDriftCount >= 3 || signals.tagImbalanceCount >= 3 {
            return .frustrated
        }
        // Tier 2 — multi-axis mid-firing: voice + tag both moving, depth lagging.
        if signals.voiceDriftCount >= 2,
           signals.tagImbalanceCount >= 2,
           signals.branchReflectionRatio < 0.5 {
            return .confused
        }
        // Tier 3 — boredom: NO coaching surface activated this session + cadence stalled.
        // Checked BEFORE disengagement because zero-events is the more specific
        // case; a kid skipping the depth surface (disengaged) still has SOMETHING
        // firing (branches without reflection). A bored kid has nothing firing.
        if signals.voiceDriftCount == 0,
           signals.tagImbalanceCount == 0,
           let minutes = signals.minutesSinceLastPublish,
           minutes >= 30 {
            return .bored
        }
        // Tier 4 — disengagement: low reflection + stalled cadence.
        if signals.branchReflectionRatio < 0.25,
           let minutes = signals.minutesSinceLastPublish,
           minutes >= 25 {
            return .disengaged
        }
        // Tier 5 — confident hold: recent publish under steady authoring.
        if let minutes = signals.minutesSinceLastPublish,
           minutes <= 5,
           signals.voiceDriftCount <= 1,
           signals.branchReflectionRatio >= 0.5 {
            return .confident
        }
        // Default.
        return .flow
    }

    /// Whether celebrations / mentor congratulations should be suppressed
    /// for the suggested state. Delegates to ForgeKit's canonical surface
    /// so future changes to `EmotionalState.shouldSuppressCelebrations`
    /// flow through without changes here.
    public static func shouldSuppressCelebrations(forSignals signals: Signals) -> Bool {
        suggestedState(forSignals: signals).shouldSuppressCelebrations
    }

    /// Parent-readable descriptor for the suggested state. The four
    /// strings on `DialogueEmotionalStateDescriptor` (parentSummary /
    /// whatThisMeans / howWeSupport / nextMilestone) render directly into
    /// the parent-progress dashboard without further copy editing. The
    /// register adheres to `.claude/rules/distributed-narrative.md`
    /// § "Chapter content register stoplist" — no engineering jargon, no
    /// SAMHSA / framework terminology, no ticket numbers.
    public static func descriptor(forSignals signals: Signals) -> DialogueEmotionalStateDescriptor {
        let state = suggestedState(forSignals: signals)
        return DialogueEmotionalStateDescriptor.descriptor(for: state)
    }
}

/// Parent-readable descriptor for an emotional-state surface. Register
/// is calibrated for adult parents reading their kid's progress
/// dashboard. No mentor / framework jargon; concrete observable cues.
public nonisolated struct DialogueEmotionalStateDescriptor: Sendable, Equatable {

    /// Short one-line summary for the dashboard card title.
    public let parentSummary: String

    /// What the state means in plain-language adult register.
    public let whatThisMeans: String

    /// How the app is supporting the kid in this state right now (or
    /// would, if the suppression / coaching surface were wired).
    public let howWeSupport: String

    /// What the kid is moving toward next.
    public let nextMilestone: String

    public init(
        parentSummary: String,
        whatThisMeans: String,
        howWeSupport: String,
        nextMilestone: String
    ) {
        self.parentSummary = parentSummary
        self.whatThisMeans = whatThisMeans
        self.howWeSupport = howWeSupport
        self.nextMilestone = nextMilestone
    }

    /// Map an `EmotionalState` to its DialogueQuest-specific descriptor.
    /// One-to-one mapping; each case has hand-tuned reader-facing copy.
    public static func descriptor(for state: EmotionalState) -> DialogueEmotionalStateDescriptor {
        switch state {
        case .flow:
            return DialogueEmotionalStateDescriptor(
                parentSummary: "Settled writing rhythm",
                whatThisMeans: "Your kid is moving steadily through the dialogue — each line is leaving the page, and the mentor is mostly stepping back.",
                howWeSupport: "Patter stays in the background. We surface short reactions only when a branch point lands.",
                nextMilestone: "Publishing the current tree, or branching into a new scene."
            )
        case .frustrated:
            return DialogueEmotionalStateDescriptor(
                parentSummary: "Same notes keep coming up",
                whatThisMeans: "The same coaching note has fired a few times this session. Your kid may be feeling stuck on one craft axis.",
                howWeSupport: "Patter eases off the repeating note and offers a one-line restart prompt. Celebrations pause until the kid finds a fresh angle.",
                nextMilestone: "A different next line — a new speaker takes the floor, or the tree branches a different way."
            )
        case .bored:
            return DialogueEmotionalStateDescriptor(
                parentSummary: "Quiet stretch",
                whatThisMeans: "Time has passed without a new line landing. Your kid may be reading, sketching, or just thinking — or may want a fresh prompt.",
                howWeSupport: "Patter offers a quick prompt about the scene's mood or a sample line one of the characters might say.",
                nextMilestone: "Adding the next line, or moving to a fresh scene with a different mood."
            )
        case .disengaged:
            return DialogueEmotionalStateDescriptor(
                parentSummary: "Branches without follow-through",
                whatThisMeans: "New branches are being added but the reflection step is being skipped. The tree is growing wide without growing deep.",
                howWeSupport: "Patter pauses the new-branch coaching and offers a one-question reflection on the most recent branch instead.",
                nextMilestone: "Completing one branch-reflection before adding the next branch."
            )
        case .confused:
            return DialogueEmotionalStateDescriptor(
                parentSummary: "Mentor notes pulling in different directions",
                whatThisMeans: "More than one craft axis is firing at once — voice, tag balance, and branching are all asking for attention.",
                howWeSupport: "Patter narrows to the single most-recent note and pauses the other axes for a few lines.",
                nextMilestone: "Settling on one axis at a time."
            )
        case .confident:
            return DialogueEmotionalStateDescriptor(
                parentSummary: "Steady hand on a fresh publish",
                whatThisMeans: "A tree was just published, and the authoring rhythm into it was steady — voice held, reflections happened, branches earned their place.",
                howWeSupport: "Patter celebrates briefly and steps back. The next session can pick a stretch goal — a new mood, a trickier triangle of speakers.",
                nextMilestone: "A new tree with a deliberate craft stretch (a new mood, a third character, a longer arc)."
            )
        case .recovering:
            return DialogueEmotionalStateDescriptor(
                parentSummary: "Coming back into rhythm",
                whatThisMeans: "Your kid hit a tough patch earlier and is now back in a steadier rhythm. This is a real growth moment.",
                howWeSupport: "Patter acknowledges the shift quietly and stays light on coaching while the rhythm holds.",
                nextMilestone: "Holding the rhythm for one more publish."
            )
        }
    }
}
