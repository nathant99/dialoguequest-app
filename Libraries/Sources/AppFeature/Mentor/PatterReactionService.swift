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
    /// The dominant classification we surfaced a tip for, so we don't
    /// re-fire the tip until the dominant classification CHANGES.
    @ObservationIgnored
    private var lastSurfaceTagClassification: DialogueTag.Classification?
    /// The branch-point IDs we've already greeted, so re-selecting the
    /// same branch-point doesn't re-fire the cast voicing.
    @ObservationIgnored
    private var greetedBranchPointIDs: Set<UUID> = []

    public init(
        mentor: PatterMentor,
        castVoicing: CastVoicingService? = nil
    ) {
        self.mentor = mentor
        self.castVoicing = castVoicing
    }

    /// Call when the kid's selection moved to a branch-point node. The
    /// sheet UI handles the heavy lift; this hook is for surfacing a
    /// one-line bubble outside the sheet.
    public func onBranchPointSelected(branchPointID: UUID, mood: DialogueMood?) async {
        let check = await mentor.branchCheck(for: mood)
        latestBubbleMessage = check.question1
        guard let castVoicing else { return }
        guard greetedBranchPointIDs.insert(branchPointID).inserted else { return }
        await castVoicing.respond(to: .branchPointReached, topic: mood?.displayName)
    }

    /// Call after a branch reflection is confirmed (3-question Socratic
    /// check completed). Sprig affirms via cast voicing if enabled.
    public func onBranchReflectionConfirmed(mood: DialogueMood?) async {
        guard let castVoicing else { return }
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
        if let castVoicing {
            await castVoicing.respond(to: .tagBalanceImbalance, topic: tree.mood?.displayName)
        }
    }

    /// Call when a non-empty inferred subtext lands on the panel.
    /// Glance encourages the kid to name it.
    public func onSubtextDiscovered(line: String, mood: DialogueMood?) async {
        guard let castVoicing else { return }
        await castVoicing.respond(to: .subtextDiscovered, topic: mood?.displayName)
    }

    /// Call when the kid taps "Yes, that's it" on the subtext panel.
    /// Glance affirms the aha moment.
    public func onSubtextConfirmed(mood: DialogueMood?) async {
        guard let castVoicing else { return }
        await castVoicing.respond(to: .subtextConfirmed, topic: mood?.displayName)
    }

    /// Call when the analyzer reports a voice-match score below
    /// `CastVoiceRegistry.voiceDriftThreshold`. Brogue scaffolds the kid
    /// back into voice register.
    public func onVoiceDrift(score: Double, mood: DialogueMood?) async {
        guard score < CastVoiceRegistry.voiceDriftThreshold else { return }
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
    }
}
