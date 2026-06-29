---
status: ACTIVE
date: 2026-07-10
direction: session → next CLAUDE Code session
audience: future Claude Code session opening DialogueQuest cold
intent: brief the next session on what just shipped, what's still open/blocked, and what's worth picking up next
freshness-horizon: 30 days
supersedes: Docs/SESSION_HANDOFF_2026-07-09_ROUND_CLOSE.md
---

# Session Handoff — 2026-07-10 (3 PRs; B-follow — ForgeMasteryEngine surface DEEPENED; full plan 903/903 effective)

> **TL;DR**: Twenty-first mid-session round under the auto-cycle, on the open "all approved, go with your recs, don't stop, describe options first" mandate. Second round on the post-pin-bump baseline (ForgeKit 1.0.0-rc.3). No new module this round — instead a **B-follow DEEPENING** of last round's `ForgeMasteryEngine` adoption into two real reader surfaces: a **kid-facing "Your craft" per-pillar bar section + focus caption on the Progress tab**, and a **3-card extend/consolidate/stretch coaching surface on the parent dashboard** (was: a single focus line). Net **+4 tests**; full plan **903 tests, 903 effective passing** (902 on the full run + 1 known-flaky Performance-Booth UI test that passes on isolated re-run). **ForgeKit module count unchanged at 25.** Remaining user-GUI blocker: still just **Localizable.xcstrings (Priority C)**.

## What shipped this session (PRs #188 → #189 + round-close)

| PR | Title | Net delta |
|---|---|---|
| #188 | Wave A — agent-safety reaffirmation 2026-07-10 | 21st reaffirmation entry; verbatim boundary + carve-out; confirmed no drift in CLAUDE.md / xcode-agent-safety rule. Pure docs. |
| #189 | Wave B — deepen ForgeMasteryEngine surface | `DialogueCraftMasteryService.masteryReadouts()` + `recommendationReadouts()` reader API. Kid Progress tab "Your craft" bars + focus caption (`ProgressDashboardView` + `ProgressTabView`). Parent dashboard 3-card extend/consolidate/stretch set (`ParentProgressDashboardView`). +4 tests. No `Package.swift` edit. |
| (round-close) | Wave Z | `IMPLEMENTATION_HANDOFF.md` twenty-first addendum; this file; 2 new CLAUDE.md "Things That Will Bite You" entries (picker non-determinism + FSRS time-decay). |

## What state the codebase is in

### Test count
Full plan: **903 tests** (was 899). +4 `DialogueCraftMasteryServiceTests` readout tests. A full `RunAllTests` showed 902 passing + 1 failed — the failure was `PhaseThreeFourSurfacesUITests/testTappingPerformanceBoothEntryOpensTheSheet()`, which **passes on isolated re-run** (XCUITest timing flake under the Xcode 26 simulator; not a source regression — this round touched only the Progress tab, parent dashboard, and a service). Run the full plan once per round; if a UI test fails, re-run it in isolation before treating it as real (per `.claude/rules/test-crash-recovery.md`).

### ForgeKit integration
**Pinned to 1.0.0-rc.3. 25 of ~58 modules consumed (unchanged this round).** This round DEEPENED the existing `ForgeMasteryEngine` adoption rather than adding a module. `ForgeLocalization` is the next module gated only on a user-GUI prereq (`Localizable.xcstrings`).

### Silent-fail-site coverage
**100%** maintained — the new readers add no fallible IO; they reuse `DialogueCraftMasteryService`'s existing logged decode path.

### New surfaces this round (read these before touching the craft-coaching path)
- `DialogueCraftMasteryService.masteryReadouts() -> [CraftMasteryReadout]` — all six pillars, 0–1 score + `isMastered`, in `DialogueCraftTopic.allCases` order. Powers the kid Progress-tab bars.
- `DialogueCraftMasteryService.recommendationReadouts() -> [CraftRecommendationReadout]` — up to 3 reader-facing cards (`.extend` / `.consolidate` / `.stretch`), one per kind, register-stoplist-clean. Calls `recommendations()` ONCE (see gotcha below). Powers the parent dashboard cards.
- `ProgressDashboardView` — new `craftBars: [CraftMasteryReadout]` + `craftFocusName: String?` params (pure renderer); `ProgressTabView` loads them in `.task`. The "Your craft" section hides unless ≥1 bar is non-zero.
- `ParentProgressDashboardView.craftFocusSection` — now renders `craftRecommendations` (3 cards) below the existing mastered-count + focus line.

### Two gotchas codified this round (now in CLAUDE.md § Things That Will Bite You)
1. **`NextProblemPicker.recommendations(state:)` is non-deterministic across calls** (iterates a `Set` frontier; ties resolve differently per call) AND **a fresh install still surfaces a `.stretch`** (so `nextFocusTopic()` is non-nil from launch). Call it ONCE per surface; gate kid-facing surfaces on a separate "has published" signal, not on `nextFocusTopic() != nil`.
2. **`TopicMasteryState.masteryScore` is time-decayed** — never assert bit-exact equality across two reads; assert the threshold invariant.

## What's still open

### Hub-side asks (BLOCKED on hub) — unchanged
1. `HANDOFF_TO_HUB_HUBCONTRIBUTION_LEVEL_1.md` — AdventureHub Word Workshop tile manifest
2. `HANDOFF_TO_HUB_PATTER_APP_ICON_PNG.md` — 1024×1024 Patter source PNG (also the channel for the Patter bubble illustration)
3. `HANDOFF_TO_HUB_CURATING_TOGETHER_PDF.md` — 4th Companion Pack PDF

### User-side GUI asks (BLOCKED on user GUI) — unchanged
**Localizable.xcstrings (still absent — Priority C; the only remaining HOT-once-landed blocker)** · declared age range API · app icon · voice-acting coach Info.plist · widget extension.

### Phases — unchanged
Phase 2/3/Delight/A11y/Onboarding 100% CLOSED. Phase 4: 6/8 rows closed; row 159 (classroom mode) deferred; rows 164/165 hub-blocked.

## What's worth picking up next session

### Priority B-follow — RETIRE `DialogueScaffoldingService` into the Polya scaffold (~2-3h) — STILL the deferred end-state
Two rounds running, this was held additive. Nothing beyond `WriteTabView` consumes `DialogueScaffoldingService` (verified by grep — only doc-comment references elsewhere). The retire-round work: migrate the WriteTabView publish-path call site (`recordPublishedWith[out]Reflection()`) onto the Polya scaffold's look-back phase + decide the fate of the fade-streak independence telemetry (fold into a thin reader or declare superseded), then delete `DialogueScaffoldingService` + `DialogueScaffoldingServiceTests`. Held again this round because it's a destructive refactor of a tested, working advisory service for low integration gain, and it touches a live publish-path call site. Do it in a dedicated round with a full-plan run on either side.

### Priority B-follow — mastery nudge into the live Patter bubble (~1-1.5h, kid-facing, medium risk)
This round surfaced `nextFocusTopic()` as a calm Progress-tab caption (zero publish-path risk). A future round could wire it into the WriteTabView probabilistic bubble slot as a 5th mutually-exclusive path (cameo → callback-mood → callback-voice-pattern → voice-craft-tip → **mastery-focus nudge**), flag-gated. Touches the delicate tested probability chain — do it carefully with a test for the new ordering.

### Priority C (HOT once user lands xcstrings) — Localization seam (~6-8h)
Pre-req: `HANDOFF_TO_USER_LOCALIZABLE_XCSTRINGS.md`. Per `.claude/rules/localization.md`. Still the ONLY user-GUI blocker holding back a ForgeKit module adoption.

### Priority D — Voice-acting Coach UI tests stub (~1.5h once unblocked) — blocked on `HANDOFF_TO_USER_VOICE_ACTING_COACH_INFOPLIST.md`
### Priority L — DevelopmentalCapacityProbe → parent dashboard (~45 min once unblocked) — blocked on `HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md`
### Priority T — Test-side mirror-source reorg — STILL DEFER (session-hazard; needs Xcode restart per the SPM `SwiftFileList` cache gotcha)

## How to start next session
1. **`git pull --ff-only`** before any file read.
2. Re-read this handoff + `Docs/IMPLEMENTATION_HANDOFF.md` (top twenty-first-mid-session entry) + `Docs/FEATURE_PLAN.md`.
3. `git status -s` clean check.
4. Check `Libraries/Sources/AppFeature/Resources/Localizable.xcstrings` — if it now exists, **Priority C is HOT**.
5. Otherwise: the **B-follow retire round** (fold `DialogueScaffoldingService` into the Polya scaffold) and the **mastery-nudge-into-Patter-bubble** are the top unblocked pickups.
6. **Run the FULL plan (`RunAllTests`)** at least once. If a UI test fails, re-run it in isolation before treating it as a regression — the Performance-Booth UI test flaked under the full run this round and passed solo.

## Process notes for next session
- The auto-cycle (branch → commit → push → PR → merge → verify) ran cleanly this round, but **the push step was interactively declined twice and re-approved on ask** — if pushes get declined, pause and confirm rather than retrying blindly.
- `XcodeRefreshCodeIssuesInFile` returned "error 5" on files not open in the editor this round — fall back to `BuildProject` for diagnostics when the fast path fails.
- `RunSomeTests` suite identifier is the **type name** (`DialogueCraftMasteryServiceTests`), not the `@Suite("...")` display name.

## Cross-references
- `Docs/HANDOFF_AGENT_SAFETY_RECONFIRMED.md` — 2026-07-10 reaffirmation (21st in chain)
- `Docs/IMPLEMENTATION_HANDOFF.md` — twenty-first 2026 mid-session addendum (per-PR detail)
- `Libraries/Sources/Services/Pedagogy/DialogueCraftMasteryService.swift` (UPDATED — `masteryReadouts()` + `recommendationReadouts()`)
- `Libraries/Sources/AppFeature/Progress/ProgressDashboardView.swift` (UPDATED — "Your craft" section)
- `Libraries/Sources/AppFeature/Tabs/ProgressTabView.swift` (UPDATED — `.task` mastery load)
- `Libraries/Sources/AppFeature/Profile/ParentProgressDashboardView.swift` (UPDATED — 3-card recommendation surface)
- `Libraries/Tests/ServicesTests/DialogueCraftMasteryServiceTests.swift` (UPDATED — +4 readout tests)
