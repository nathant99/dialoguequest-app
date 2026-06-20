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
    /// The dominant classification we surfaced a tip for, so we don't
    /// re-fire the tip until the dominant classification CHANGES.
    @ObservationIgnored
    private var lastSurfaceTagClassification: DialogueTag.Classification?

    public init(mentor: PatterMentor) {
        self.mentor = mentor
    }

    /// Call when the kid's selection moved to a branch-point node. The
    /// sheet UI handles the heavy lift; this hook is for surfacing a
    /// one-line bubble outside the sheet.
    public func onBranchPointSelected(mood: DialogueMood?) async {
        let check = await mentor.branchCheck(for: mood)
        latestBubbleMessage = check.question1
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
    }

    /// Reset to the empty state (e.g., when the kid resets the tree).
    public func reset() {
        latestBubbleMessage = nil
        lastTagBalanceTip = nil
        lastSurfaceTagClassification = nil
    }
}
