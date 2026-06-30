---
status: ACTIVE
date: 2026-07-11
direction: session → next CLAUDE Code session
audience: future Claude Code session opening DialogueQuest cold
intent: brief the next session on what just shipped, what's still open/blocked, and what's worth picking up next
freshness-horizon: 30 days
supersedes: Docs/SESSION_HANDOFF_2026-07-10_ROUND_CLOSE.md
---

# Session Handoff — 2026-07-11 (3 PRs; B-follow — mastery-focus nudge into the live Patter bubble; full plan 909/909)

> **TL;DR**: Twenty-second mid-session round under the auto-cycle, on the open "all approved, go with your recs, don't stop, describe options first" mandate. Third round on the post-pin-bump baseline (ForgeKit 1.0.0-rc.3). No new module — a **second B-follow DEEPENING** of `ForgeMasteryEngine`: wired the existing `nextFocusTopic()` recommendation into the **live WriteTabView Patter bubble** as a **sixth** mutually-exclusive kid-facing path (the previous round surfaced it only as a calm Progress-tab caption with zero publish-path risk; this round took the next step into the probabilistic bubble chain, carefully). Net **+6 tests**; full plan **909 tests, 909 passing** on a clean full `RunAllTests` (the Performance-Booth UI test that flaked last round passed under the full run this time). **ForgeKit module count unchanged at 25.** Remaining user-GUI blocker: still just **Localizable.xcstrings (Priority C)**.

## What shipped this session (PRs #191 → #192 + round-close)

| PR | Title | Net delta |
|---|---|---|
| #191 | Wave A — agent-safety reaffirmation 2026-07-11 | 22nd reaffirmation entry; verbatim boundary + carve-out; confirmed no drift in CLAUDE.md / xcode-agent-safety rule. Pure docs. |
| #192 | Wave B — mastery-focus nudge into the live Patter bubble | `DialogueCraftMasteryService.nextFocusNudge()` + `shouldShowFocusNudge(rng:)` + `minimumPublishedForFocusNudge = 3`. WriteTabView publish-path bubble chain extended 5 → 6 paths. +6 tests. No `Package.swift` edit. |
| (round-close) | Wave Z | `IMPLEMENTATION_HANDOFF.md` twenty-second addendum; this file; 1 new CLAUDE.md "Things That Will Bite You" entry (picker can return empty post-publish). |

## What state the codebase is in

### Test count
Full plan: **909 tests, 909 passing** (was 903) on a clean full `RunAllTests`. +6 `DialogueCraftMasteryServiceTests` focus-nudge tests. The `PhaseThreeFourSurfacesUITests/testTappingPerformanceBoothEntryOpensTheSheet()` test that flaked under the full run last round passed this round — still treat any UI-test failure as a candidate flake (re-run in isolation before treating as a regression, per `.claude/rules/test-crash-recovery.md`).

### ForgeKit integration
**Pinned to 1.0.0-rc.3. 25 of ~58 modules consumed (unchanged this round).** This round DEEPENED the existing `ForgeMasteryEngine` adoption rather than adding a module. `ForgeLocalization` is the next module gated only on a user-GUI prereq (`Localizable.xcstrings`).

### Silent-fail-site coverage
**100%** maintained — the nudge adds no fallible IO; it reuses `DialogueCraftMasteryService`'s existing logged decode path.

### The Patter-bubble chain (read this before touching the publish path)
`WriteTabView.onChange(machine.stage == .published)` fills ONE shared `rareVoiceCraftTip` slot via a mutually-exclusive chain — the kid never sees two bubbles. As of this round it has **6 paths**, lower-probability first so rare ones feel special:
1. cameo (12%, flag-gated, `publishedTreeCount >= 2`)
2. callback mood (8%, history-gated)
3. callback voice-pattern (8%, per-character trend, history-gated)
4. seasonal-theme (8%, calendar-window-gated + per-window deduped)
5. **mastery focus nudge (8%, `publishedTreeCount >= 3`)** ← NEW this round
6. voice-craft tip (20%, always-allowed fallback)

All share one `var rewardRNG = SystemRandomNumberGenerator()` + a `slotFilled` flag. If you add a 7th path, follow the same `if !slotFilled, <gate>, <roll>, let line = ... { rareVoiceCraftTip = line; slotFilled = true }` shape and keep the always-on voice-craft tip last.

### New service API this round (`DialogueCraftMasteryService`)
- `nextFocusNudge() -> String?` — warm kid line for `nextFocusTopic()` (calls `recommendations()` ONCE); `nil` when the picker has nothing to recommend.
- `shouldShowFocusNudge(probability: = 0.08, rng:)` — pure RNG gate, mirrors the other bubble-path gates.
- `minimumPublishedForFocusNudge = 3`, `focusNudgeProbability = 0.08` — public locked constants.

### Gotcha codified this round (now in CLAUDE.md § Things That Will Bite You)
**`NextProblemPicker.recommendations(state:)` can return EMPTY after attempts even though a fresh install never does.** Fresh install reliably surfaces a `.stretch`; a post-publish state can legitimately return nothing. Tests asserting "names a pillar" must use a FRESH service; surfaces must tolerate `nil`.

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

### Priority B-follow — RETIRE `DialogueScaffoldingService` into the Polya scaffold (~2-3h) — STILL the deferred end-state, now with a sharper reason to leave it
Three rounds running this stays deferred. **New consideration this round**: the retire would REMOVE the ForgeKit `ScaffoldingEngine` surface (`DialogueScaffoldingService` wraps it) rather than ADD one, which works *against* the standing "maximize ForgeKit integration" mandate. So it is no longer obviously the top pickup. If a future session does do it: nothing beyond `WriteTabView` consumes `DialogueScaffoldingService` (grep-verified — only doc-comment references elsewhere); migrate the publish-path call site onto the Polya scaffold's look-back phase, decide the fade-streak telemetry's fate, then delete the service + its tests. Dedicated round, full-plan run on either side.

### Priority B-follow — mastery nudge is now LIVE in the bubble; the obvious next deepening is small + additive
Options for a future round, all low-risk: (a) add a Progress-tab "Your craft" empty-state nudge when `nextFocusNudge()` is non-nil but no bars are filled yet (currently the section hides entirely on fresh install); (b) thread the focus topic's cast embodiment (`DialogueCraftTopic.castEmbodiment`) into the nudge so the suggested pillar's cast member "invites" the kid (e.g. Brogue for voice consistency) — would compose the mastery nudge with the existing cameo system; (c) a parent-dashboard "what Patter is nudging toward" line mirroring the kid surface.

### Priority C (HOT once user lands xcstrings) — Localization seam (~6-8h)
Pre-req: `HANDOFF_TO_USER_LOCALIZABLE_XCSTRINGS.md`. Per `.claude/rules/localization.md`. Still the ONLY user-GUI blocker holding back a ForgeKit module adoption (`ForgeLocalization`).

### Priority D — Voice-acting Coach UI tests stub (~1.5h once unblocked) — blocked on `HANDOFF_TO_USER_VOICE_ACTING_COACH_INFOPLIST.md`
### Priority L — DevelopmentalCapacityProbe → parent dashboard (~45 min once unblocked) — blocked on `HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md`
### Priority T — Test-side mirror-source reorg — STILL DEFER (session-hazard; needs Xcode restart per the SPM `SwiftFileList` cache gotcha)

## How to start next session
1. **`git pull --ff-only`** before any file read.
2. Re-read this handoff + `Docs/IMPLEMENTATION_HANDOFF.md` (top twenty-second-mid-session entry) + `Docs/FEATURE_PLAN.md`.
3. `git status -s` clean check.
4. Check `Libraries/Sources/AppFeature/Resources/Localizable.xcstrings` — if it now exists, **Priority C is HOT**.
5. Otherwise: the small additive mastery-nudge deepenings above (a/b/c) are the cleanest unblocked pickups; the `DialogueScaffoldingService` retire is documented-as-deferred (and now arguably best left as-is to preserve the ForgeKit `ScaffoldingEngine` surface).
6. **Run the FULL plan (`RunAllTests`)** at least once. If a UI test fails, re-run it in isolation before treating it as a regression.

## Process notes for next session
- The auto-cycle (branch → commit → push → PR → merge → verify) ran cleanly this round — no declined pushes.
- One Wave-B test (`focusNudgeLineNamesARecommendedPillar`) initially failed because it published first (post-publish picker returned empty); fixed by asserting against a fresh service. This is now a codified CLAUDE.md gotcha — don't re-discover it.
- The simulated daily date chain reached 2026-07-11 this round (the wall-clock differs, but the repo's reaffirmation + handoff history is monotonic on this forward chain — keep dating new work forward, not backward).
- `RunSomeTests` suite identifier is the **type name** (`DialogueCraftMasteryServiceTests`), not the `@Suite("...")` display name.

## Cross-references
- `Docs/HANDOFF_AGENT_SAFETY_RECONFIRMED.md` — 2026-07-11 reaffirmation (22nd in chain)
- `Docs/IMPLEMENTATION_HANDOFF.md` — twenty-second 2026 mid-session addendum (per-PR detail)
- `Libraries/Sources/Services/Pedagogy/DialogueCraftMasteryService.swift` (UPDATED — `nextFocusNudge()` + `shouldShowFocusNudge(rng:)` + constants)
- `Libraries/Sources/AppFeature/Tabs/WriteTabView.swift` (UPDATED — 6th bubble slot)
- `Libraries/Tests/ServicesTests/DialogueCraftMasteryServiceTests.swift` (UPDATED — +6 focus-nudge tests)
