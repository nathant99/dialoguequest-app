import Foundation
import Testing
import ForgePedagogy
@testable import Services

/// DialogueQuest's `PolyaScaffold` adoption (Priority B). Covers the
/// four-phase authoring loop, the articulate-before-hint contract
/// (`hintsAllowedBeforePlan: 0`), the whole-loop convenience capture, and the
/// `.dialogueQuest` configuration shape.
@MainActor
@Suite("DialogueAuthoringScaffold")
struct DialogueAuthoringScaffoldTests {

    // MARK: - Fresh state

    @Test func freshScaffoldStartsAtUnderstandWithNoHints() {
        let scaffold = DialogueAuthoringScaffold()
        #expect(scaffold.currentPhaseOrdinal == 1)
        #expect(scaffold.isComplete == false)
        // Articulate-before-hint: no hints before the kid finishes PLAN.
        #expect(scaffold.hintsAllowedNow == 0)
    }

    // MARK: - Articulate-before-hint contract

    @Test func blankPremiseBlocksAdvanceOutOfUnderstand() {
        let scaffold = DialogueAuthoringScaffold()
        let advanced = scaffold.recordSceneCast(premise: "   ", characterNames: ["Sprig"])
        #expect(advanced == false)
        #expect(scaffold.currentPhaseOrdinal == 1)
        #expect(scaffold.hintsAllowedNow == 0)
    }

    @Test func hintsStayZeroUntilPlanIsComplete() {
        let scaffold = DialogueAuthoringScaffold()
        #expect(scaffold.recordSceneCast(premise: "Two friends argue", characterNames: ["Sprig", "Glance"]))
        // Now in PLAN — still no hints allowed (the contract gates on PLAN
        // completion, not entry).
        #expect(scaffold.currentPhaseOrdinal == 2)
        #expect(scaffold.hintsAllowedNow == 0)
        #expect(scaffold.recordBranchPlan(strategy: .caseAnalysis, rationale: "two ways to react"))
        // Now in EXECUTE — hints unlock.
        #expect(scaffold.currentPhaseOrdinal == 3)
        #expect(scaffold.hintsAllowedNow == 3)
    }

    // MARK: - Full loop

    @Test func granularLoopCompletes() {
        let scaffold = DialogueAuthoringScaffold()
        #expect(scaffold.recordSceneCast(premise: "A tense goodbye", characterNames: ["Brogue", "Rest"]))
        #expect(scaffold.recordBranchPlan(strategy: .caseAnalysis))
        #expect(scaffold.recordLineWriting(lines: ["line one", "line two"], hintCount: 1))
        #expect(scaffold.currentPhaseOrdinal == 4)
        #expect(scaffold.recordPublishReflection("the branch changes how it ends"))
        #expect(scaffold.isComplete)
    }

    @Test func hintLimitExceededBlocksExecuteAdvance() {
        let scaffold = DialogueAuthoringScaffold()
        #expect(scaffold.recordSceneCast(premise: "Scene", characterNames: ["A"]))
        #expect(scaffold.recordBranchPlan(strategy: .decompose))
        // hintCount 99 exceeds the execute-phase allowance (3) → no advance.
        let advanced = scaffold.recordLineWriting(lines: ["x"], hintCount: 99)
        #expect(advanced == false)
        #expect(scaffold.currentPhaseOrdinal == 3)
        #expect(scaffold.isComplete == false)
    }

    // MARK: - Whole-loop convenience

    @Test func captureCompletedTreeCompletesTheLoop() {
        let scaffold = DialogueAuthoringScaffold()
        let ok = scaffold.captureCompletedTree(
            premise: "The argument",
            characterNames: ["Sprig", "Weigh"],
            hadBranchPoints: true,
            lineCount: 6,
            reflectedAnyBranch: true
        )
        #expect(ok)
        #expect(scaffold.isComplete)
    }

    @Test func captureWithBlankPremiseStillCompletes() {
        let scaffold = DialogueAuthoringScaffold()
        let ok = scaffold.captureCompletedTree(
            premise: "   ",
            characterNames: [],
            hadBranchPoints: false,
            lineCount: 3,
            reflectedAnyBranch: false
        )
        #expect(ok)
        #expect(scaffold.isComplete)
    }

    // MARK: - Reset

    @Test func resetReturnsToUnderstand() {
        let scaffold = DialogueAuthoringScaffold()
        _ = scaffold.captureCompletedTree(
            premise: "Done", characterNames: ["A"],
            hadBranchPoints: false, lineCount: 2, reflectedAnyBranch: false
        )
        #expect(scaffold.isComplete)
        scaffold.reset()
        #expect(scaffold.currentPhaseOrdinal == 1)
        #expect(scaffold.isComplete == false)
    }

    // MARK: - Configuration contract

    @Test func dialogueQuestConfigEncodesArticulateBeforeHint() {
        let config = PolyaMachine.Configuration.dialogueQuest
        #expect(config.hintsAllowedBeforePlan == 0)
        #expect(config.requireRestatementBeforeAdvance == true)
        #expect(config.requireStrategyTagBeforeAdvance == true)
        #expect(config.allowSkipLookBack == true)
    }
}
