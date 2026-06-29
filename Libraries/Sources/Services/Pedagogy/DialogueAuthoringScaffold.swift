import Foundation
import ForgePedagogy

/// DialogueQuest's adoption of ForgeKit 1.0.0-rc's `PolyaScaffold` /
/// `PolyaMachine` (Priority B), modeling the kid's tree-authoring loop as
/// Polya's four "How To Solve It" phases:
///
/// - **understand** — the kid casts the scene (names it + lists the cast)
/// - **plan** — the kid chooses how the conversation will branch
/// - **execute** — the kid writes the lines
/// - **look back** — the kid reflects on a branch + publishes
///
/// **Articulate-before-hint contract**: the `.dialogueQuest` configuration
/// sets `hintsAllowedBeforePlan: 0`, so the machine refuses to surface a
/// coaching hint until the kid has named the scene (UNDERSTAND) and chosen a
/// branch strategy (PLAN). That invariant was previously hand-rolled inside
/// `PatterReactionService`'s scaffold wording; the `PolyaMachine` makes it a
/// load-bearing, testable state-machine contract.
///
/// **Relationship to `DialogueScaffoldingService`**: that service is the
/// fade-streak telemetry layer (publish-with-reflection → success; fades
/// hints after N successes / restores after M failures) backed by ForgeKit's
/// `ScaffoldingEngine`. This service is the *per-tree* articulate-before-hint
/// loop. They're complementary — the streak service answers "is the kid
/// operating independently across sessions?"; this scaffold answers "did the
/// kid articulate the scene + plan before writing this tree?". Folding the
/// streak service's telemetry into the Polya loop is a forward step for a
/// dedicated round (it would require retiring the `ScaffoldingEngine` wrapper
/// + migrating its WriteTabView call site + tests); kept additive here so the
/// 890-green suite stays green.
///
/// `@Observable` so a future Patter coaching surface can drive UI off
/// `currentPhaseOrdinal` / `hintsAllowedNow` / `isComplete`.
@MainActor
@Observable
public final class DialogueAuthoringScaffold: PolyaScaffold {

    /// The four-phase machine. Public + settable per the `PolyaScaffold`
    /// protocol requirement.
    public var polyaMachine: PolyaMachine

    public init(configuration: PolyaMachine.Configuration = .dialogueQuest) {
        self.polyaMachine = PolyaMachine(configuration: configuration)
    }

    // MARK: - Phase progression (granular)

    /// Phase 1 — the kid casts the scene. Records the scene premise + cast as
    /// the UNDERSTAND content and advances to PLAN. Returns `false` (no
    /// transition) when the premise is blank — the articulate-before-hint
    /// contract: name the scene first.
    @discardableResult
    public func recordSceneCast(premise: String, characterNames: [String]) -> Bool {
        polyaMachine.updateUnderstanding(
            PolyaPhase.Understanding(restatement: premise, given: characterNames)
        )
        return tryAdvance()
    }

    /// Phase 2 — the kid chooses how the conversation branches. Records the
    /// PLAN content + advances to EXECUTE. Returns `false` when no strategy
    /// was chosen (the contract requires a branch strategy before writing).
    @discardableResult
    public func recordBranchPlan(strategy: StrategyTag, rationale: String? = nil) -> Bool {
        polyaMachine.updatePlan(
            PolyaPhase.StrategyPlan(strategyTag: strategy, rationale: rationale)
        )
        return tryAdvance()
    }

    /// Phase 3 — the kid writes the lines. Records the EXECUTE content +
    /// advances to LOOK BACK. Returns `false` when `hintCount` exceeded the
    /// configured execute-phase allowance.
    @discardableResult
    public func recordLineWriting(lines: [String], hintCount: Int = 0) -> Bool {
        polyaMachine.updateExecution(
            PolyaPhase.ExecutionState(steps: lines, hintCount: hintCount)
        )
        return tryAdvance()
    }

    /// Phase 4 — the kid reflects on a branch + publishes. Validates +
    /// finalises the LOOK BACK phase. With `.dialogueQuest`'s
    /// `allowSkipLookBack: true`, a `nil` reflection still completes the loop
    /// (a kid can publish a linear scene without a forced reflection).
    @discardableResult
    public func recordPublishReflection(_ reflection: String?) -> Bool {
        polyaMachine.updateReflection(
            PolyaPhase.Reflection(plausibilityCheck: reflection)
        )
        do {
            try polyaMachine.complete()
            return true
        } catch {
            return false
        }
    }

    // MARK: - Phase progression (whole-loop convenience)

    /// Capture a just-published tree as one complete authoring loop. Resets
    /// first so every publish is a clean understand → plan → execute → look
    /// back trace. Returns `true` when all four phases validated. A blank
    /// premise is substituted so a kid who never titled the scene still
    /// produces a valid loop.
    @discardableResult
    public func captureCompletedTree(
        premise: String,
        characterNames: [String],
        hadBranchPoints: Bool,
        lineCount: Int,
        reflectedAnyBranch: Bool
    ) -> Bool {
        reset()
        let scenePremise = premise.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "A scene" : premise
        guard recordSceneCast(premise: scenePremise, characterNames: characterNames) else { return false }
        let strategy: StrategyTag = hadBranchPoints ? .caseAnalysis : .custom("linear-scene")
        let rationale = hadBranchPoints ? "branch on the choice so the scene can go two ways" : nil
        guard recordBranchPlan(strategy: strategy, rationale: rationale) else { return false }
        let lines = Array(repeating: "line", count: max(0, lineCount))
        guard recordLineWriting(lines: lines, hintCount: 0) else { return false }
        let reflection = reflectedAnyBranch
            ? "checked that the branch makes the scene end differently"
            : nil
        return recordPublishReflection(reflection)
    }

    // MARK: - Readers

    /// 1-based ordinal of the current phase (understand = 1 … look back = 4).
    public var currentPhaseOrdinal: Int {
        polyaMachine.phase.ordinal
    }

    /// Whether the authoring loop has finished (a LOOK BACK entry landed in
    /// the machine's history).
    public var isComplete: Bool {
        polyaMachine.history.contains { phase in
            if case .lookBack = phase { return true }
            return false
        }
    }

    /// Hints permitted right now under the articulate-before-hint contract:
    /// `hintsAllowedBeforePlan` (0 in `.dialogueQuest`) until the kid finishes
    /// PLAN, then the execute-phase allowance.
    public var hintsAllowedNow: Int {
        switch polyaMachine.phase {
        case .understand, .plan:
            return polyaMachine.configuration.hintsAllowedBeforePlan
        case .execute, .lookBack:
            return polyaMachine.configuration.hintsAllowedBeforeExecute
        }
    }

    /// Reset to a fresh understand phase. Test seam + per-tree loop reset.
    public func reset() {
        polyaMachine.reset()
    }

    // MARK: - Private

    /// Attempt a phase transition. `false` means the current phase content
    /// didn't satisfy the contract (blank restatement / missing strategy /
    /// hint-limit exceeded) so no transition happened. Only called for the
    /// understand → plan → execute transitions; the terminal LOOK BACK uses
    /// `complete()`, so `.alreadyAtFinalPhase` never surfaces here.
    private func tryAdvance() -> Bool {
        do {
            try polyaMachine.advance()
            return true
        } catch {
            return false
        }
    }
}

extension PolyaMachine.Configuration {

    /// DialogueQuest's authoring-loop scaffold contract.
    ///
    /// - Restatement (scene premise) required before advancing out of
    ///   UNDERSTAND, and a branch strategy required before advancing out of
    ///   PLAN — together with `hintsAllowedBeforePlan: 0` this is the
    ///   articulate-before-hint discipline (name the scene + plan the
    ///   branches before any coaching hint surfaces).
    /// - No sketch requirement (DialogueQuest authors in text, not diagrams).
    /// - Rationale encouraged but not required (a kid can plan a branch
    ///   without writing why).
    /// - Look-back skippable so a kid can publish a linear scene without a
    ///   forced reflection (the `DialogueScaffoldingService` fade-streak layer
    ///   already nudges reflection over time).
    nonisolated public static let dialogueQuest = PolyaMachine.Configuration(
        requireRestatementBeforeAdvance: true,
        requireSketchBeforeAdvance: false,
        requireStrategyTagBeforeAdvance: true,
        requireRationaleBeforeAdvance: false,
        allowSkipLookBack: true,
        hintsAllowedBeforePlan: 0,
        hintsAllowedBeforeExecute: 3
    )
}
