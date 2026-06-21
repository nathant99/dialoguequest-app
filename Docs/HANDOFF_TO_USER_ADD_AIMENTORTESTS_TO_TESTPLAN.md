---
status: CLOSED
date: 2026-06-21
closed-at: 2026-06-21
direction: agent → user
audience: Nghi (Xcode operator)
intent: add the new `AIMentorTests` SPM test target to `DialogueQuest.xctestplan` via Xcode GUI so PatterFallbacks tests run in the standard test plan
freshness-horizon: 14 days
---

# Handoff to User — Add `AIMentorTests` to `DialogueQuest.xctestplan`

> **STATUS — CLOSED 2026-06-21**: User completed the test-plan GUI addition; agent staged + committed the resulting `DialogueQuest.xctestplan` diff. `RunSomeTests AIMentorTests/PatterFallbacksTests` returns **19/19 passing** (9 `@Test` functions × parameterized cases). This handoff is preserved as the historical reference.

The agent shipped a new SPM test target `AIMentorTests` (with `PatterFallbacksTests.swift`) in PR #XX. The target compiles cleanly via `BuildProject`, but the agent cannot author `DialogueQuest.xctestplan` per `@.claude/rules/xcode-agent-safety.md` (writing JSON content from disk risks External-Changes dialog or workspace reload). One GUI step closes this:

## Steps

1. Open `DialogueQuest.xcworkspace` in Xcode
2. **Product → Scheme → Edit Scheme…**
3. Select the **Test** action on the left
4. Click **Test Plans** at the top of the Test panel
5. Select `DialogueQuest.xctestplan` → **Edit Test Plan**
6. In the test plan editor, click **+** at the bottom of the Tests list
7. Select **AIMentorTests** (under `Libraries`)
8. Confirm — Xcode regenerates the `.xctestplan` JSON
9. `git status` should show `M DialogueQuest.xctestplan` — stage + commit per the carve-out (the agent will pick up the diff next session and commit, OR you can commit directly)

## Verify

After the test plan update, the next agent session can run:

```
RunSomeTests targetName=AIMentorTests testIdentifier=PatterFallbacksTests
```

and see the 11 tests pass.

## Why this is a handoff and not an agent edit

The `DialogueQuest.xctestplan` file is in the forbidden-glob list per `@.claude/rules/xcode-agent-safety.md`. The agent CAN stage + commit Xcode-regenerated diffs (per the carve-out shipped in PR #30) but CANNOT author the JSON content itself. The Xcode GUI is the canonical surface for editing test plans.

## What's already done

- ✅ `Libraries/Package.swift` — added `.testTarget(name: "AIMentorTests", dependencies: ["Models", "AIMentor"])`
- ✅ `Libraries/Tests/AIMentorTests/PatterFallbacksTests.swift` — 11 tests covering all 3 `@Generable` fallback paths (DialogueLineAnalysis / BranchMeaningfulnessCheck / TagBalanceTip)
- ✅ `BuildProject` succeeded — target compiles cleanly

## When you've completed the step

No follow-up handoff doc needed. Just commit the regenerated `.xctestplan` (one-line addition to the testTargets array). The agent's next session will see the tests in the plan and run them.

## Cross-references

- `@.claude/rules/xcode-agent-safety.md` § "Staging + committing Xcode-managed files IS allowed"
- `@Docs/HANDOFF_TO_USER_XCODE_WIRING.md` — predecessor handoff that added ServicesTests + AppFeatureTests to the plan (CLOSED)
