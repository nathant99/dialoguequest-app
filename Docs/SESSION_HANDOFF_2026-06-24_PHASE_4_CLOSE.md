---
status: ACTIVE
date: 2026-06-23
direction: session → next CLAUDE Code session
audience: future Claude Code session opening DialogueQuest cold
intent: brief the next session on what just shipped, what's still open, and what's worth picking up next
freshness-horizon: 30 days
---

# Session Handoff — Phase 4 row 163 close + active-path bringup (2026-06-23 fourth mid-session)

> **TL;DR**: Phase 4 row 163 (App Store submission prep) closed. Voice-acting coach + Live Activity scaffolds gained their active paths (still safe-no-op until user GUI work lands). 8 PRs landed in one session under the auto-cycle. Phase 4 progress: 6 of 8 rows now closed. Net delta: +16 tests (370 → 386 total).

## What shipped this session (PRs 107-114)

| PR | Title | Net delta |
|---|---|---|
| #107 | PR α.1 — Privacy nutrition label crib sheet | `Docs/APP_STORE_PRIVACY_NUTRITION_LABEL.md`. 14-type matrix + tracking declaration + COPPA-2026 verification. Pure docs. |
| #108 | PR α.2 — KIDSAFE plan | `Docs/APP_STORE_KIDSAFE_PLAN.md`. 8 Apple Kids Category attestations + No-UGC posture + reviewer-notes paste block. Pure docs. |
| #109 | PR α.3 — Parental gates audit + close FEATURE_PLAN row 163 | `Docs/AUDIT_PARENTAL_GATES_2026-06-23.md`. 9 gate surfaces inventoried. Tick row 163. |
| #110 | PR β.1 — Voice-acting coach active path | `VoiceActingCoachActiveSession` (TWO-PART tap rule) + `VoiceCoachingSheet` + `VoiceActingCoachService` extension + `PerformanceBoothView` integration. 9 tests. Safe no-op until Info.plist handoff lands. |
| #111 | PR β.2 — Live Activity wiring into WriteTabView | `syncLiveActivity()` + `endLiveActivity()` + scenePhase background end + `.task(id: nodes.count)` hook. 2 tests. Safe no-op until Widget Extension target lands. |
| #112 | PR γ.1 — Hub handoff: Curating Together PDF | `Docs/HANDOFF_TO_HUB_CURATING_TOGETHER_PDF.md` + reserved 4th CompanionPackEntry slot. |
| #113 | PR δ.1 — UI test smoke for PerformanceBooth + AnthologyCuration | 5 XCUITest cases + `-uiTestUnlockAdventure` launch arg. |
| #114 | PR 8 — Round-close + session handoff (this PR) | Tick FEATURE_PLAN + IMPLEMENTATION_HANDOFF + AGENT_SAFETY 4th reaffirmation + this session handoff. Pure docs. |

## What state the codebase is in

### ForgeKit integration

**17 of ~58 ForgeKit modules consumed** (unchanged from previous round — this session wired active paths into existing scaffolds rather than adding new module deps).

- **Shared** (2): ForgeModels (Models)
- **Client/Services** (11): ForgePersistence, ForgeAI, ForgeAnalytics, ForgeGamification, ForgeKnowledgeGraph, ForgeLiveActivities, ForgePedagogy, ForgeReporting, ForgeSensory, ForgeSpotlight
- **Client/SharedUI** (2): ForgeUI, ForgeAccessibility
- **Client/AIMentor** (1): ForgeAI
- **Client/AppFeature** (12): ForgeUI, ForgeNavigation, ForgeAdventure, ForgeAvatar, ForgeCelebration, ForgeGamification, ForgeIntents, ForgePassAndPlay, ForgePedagogy, ForgeProgression, ForgeStateMachine, ForgeSync

### Test count

| Target | Tests | New this round |
|---|---|---|
| ModelsTests | ~30 | 0 |
| ServicesTests | ~176 | +11 (PR β.1 9 + PR β.2 2) |
| AIMentorTests | ~50 | 0 |
| AppFeatureTests | ~95 | 0 |
| ForgeKitIntegrationTests | ~5 | 0 |
| DialogueQuestUITests | ~24 | +5 (PR δ.1 PhaseThreeFourSurfaces) |
| **Total** | **~386** | **+16 net** |

### SPM layout drift

No taxonomy drift this round. `Libraries/Sources/Services/Audio/` gains `VoiceActingCoachActiveSession.swift` (alongside the existing `VoiceActingCoachService.swift`). `Libraries/Sources/AppFeature/Crucible/` gains `VoiceCoachingSheet.swift` (alongside `PerformanceBoothMachine.swift` + `PerformanceBoothView.swift` + `VoiceCrucibleMachine.swift` + `VoiceCrucibleView.swift`). Both naming conventions follow the existing files in their directories.

## What's still open

### Hub-side asks (BLOCKED on hub, not us)

1. **`HANDOFF_TO_HUB_HUBCONTRIBUTION_LEVEL_1.md`** — hub must ship `spark-anvil-hub/Resources/HubContributions/dialoguequest.json` for AdventureHub Word Workshop tile. **Unchanged this round.**
2. **`HANDOFF_TO_HUB_PATTER_APP_ICON_PNG.md`** — hub must generate 1024×1024 Patter source PNG. **Unchanged this round.**
3. **`HANDOFF_TO_HUB_CURATING_TOGETHER_PDF.md`** (NEW PR #112) — hub must generate a 4th Companion Pack PDF introducing parents to the Phase 4 anthology curation surface.

### User-side GUI asks (BLOCKED on user GUI work)

5 ACTIVE handoffs as of this round (same set as previous round):

| Handoff | What user does | Unblocks |
|---|---|---|
| `HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md` | Family Controls entitlement + `NSChildUseDescription` Info.plist key | Activates `DeclaredAgeRangeGate` from `.notWired` → `.notRequested` |
| `HANDOFF_TO_USER_APP_ICON.md` (blocked-on-hub) | Run Icon Composer on hub-shipped PNG | Ships the 6-variant Liquid Glass icon set |
| `HANDOFF_TO_USER_VOICE_ACTING_COACH_INFOPLIST.md` | Add `NSMicrophoneUsageDescription` + `NSSpeechRecognitionUsageDescription` Info.plist keys | Activates `VoiceActingCoachService` from `.notWired` → `.notRequested`. **Active path is now WIRED in code (PR #110); the user GUI work is the last gate.** Tapping "Coach my voice" in Performance Booth then shows the wired record/score UX. |
| `HANDOFF_TO_USER_WIDGET_EXTENSION.md` | Create Widget Extension target via Xcode template + `NSSupportsLiveActivities` Info.plist key | Activates `DialogueWritingSessionActivity` from `.notWired` → `.ready`. **WriteTabView wiring is now WIRED (PR #111).** Once the target ships, the Lock Screen card surfaces automatically. |
| `HANDOFF_TO_USER_ADD_AIMENTORTESTS_TO_TESTPLAN.md` (pre-existing) | Add AIMentorTests target to test plan via GUI | AIMentor tests run in the standard test plan flow |

### Phase 4 status — 6 of 8 rows CLOSED

| Row | Status |
|---|---|
| 158 anthology curation | ✅ CLOSED (PR #103) |
| 159 classroom mode (`ForgeClassroom`) | ⏸️ DEFERRED — requires server-side infrastructure |
| 160 parent progress reports | ✅ CLOSED (PR #92) |
| 161 3 final question kits 14-16 | ✅ CLOSED (PR #104) |
| 162 8 advanced achievements | ✅ CLOSED (PR #104) |
| 163 App Store submission prep | ✅ CLOSED (PRs #107 + #108 + #109 this round) |
| 164 App Store screenshot + preview-video | ⏸️ BLOCKED on hub distribution pipeline |
| 165 App icon | ⏸️ BLOCKED on Patter PNG + Icon Composer GUI |

### Phase 3 — 100% CLOSED (unchanged from previous round)
### Phase-Delight / Phase-A11y / Phase-Onboarding — 100% CLOSED (unchanged)

## What's worth picking up next session

### Priority A — Telemetry-driven rollout of DN-S Move D Phase 3 (cross-repo)

The `Docs/HANDOFF_FROM_LABSMITH_DN_S_AI_MENTOR_VOICING.md` step 4-5 describes a telemetry-driven rollout of the AppStorage-gated `dq.experiments.castVoicing` feature flag. This is partly hub-side (telemetry analysis), partly app-side (potentially adding feature-flag gates to the rollout decisions). ~2-4 hours app-side; depends on hub's telemetry surface.

### Priority B — Voice Crucible mode UI test smoke

The Voice Crucible surface (Phase 2 row 131) lacks XCUITest coverage. Mirror the pattern from `PhaseThreeFourSurfacesUITests.swift` (PR #113) — 3-4 tests covering Adventure tab → Voice Crucible entry → mood pick + read line + score reveal. ~1.5 hours. Unblocked by the new `-uiTestUnlockAdventure` launch arg shipped this round.

### Priority C — Additional ForgeKit module integrations

Modules still unconsumed that could naturally fit DialogueQuest's surface:

- **`ForgeContent`** — hub kit distribution. Currently kit JSON ships bundled in `Resources/Questions/`; future kit updates could route through ForgeContent for over-the-air refresh. ~3-4 hours design + ~3-4 hours implementation.
- **`ForgeMasteryEngine`** — `MasteryGraph<Topic>` + `NextProblemPicker.recommendations`. Could replace the current `DDAEngine` per-tree DDA logic with a portfolio-canonical adaptive surface. Substantial refactor — ~6-8 hours; preserves the current pure-function APIs at the call site.
- **`ForgePedagogy.PolyaScaffold`** — articulate-before-hint scaffolding. Already partially mirrored by the existing `DialogueScaffoldingService` (uses ForgeKit's `ScaffoldingEngine` + `HintTier`). Adopting PolyaScaffold instead would be a refactor, not net-new functionality. Defer unless the kid-coaching surface needs the 4-phase enum explicitly.

### Priority D — Pre-App-Store smoke testing

With Phase 4 row 163 closed, the next gate is actual TestFlight Beta upload. The agent can author a `Docs/CHECKLIST_TESTFLIGHT_BETA.md` walking through:

1. Archive build verification (release config; wholemodule optimization)
2. Privacy nutrition label data entry (cribbed from `APP_STORE_PRIVACY_NUTRITION_LABEL.md`)
3. App Store Connect Kids Category opt-in (cribbed from `APP_STORE_KIDSAFE_PLAN.md`)
4. Reviewer notes paste (the verbatim block in `APP_STORE_KIDSAFE_PLAN.md`)
5. Build upload steps + provisioning profile verification

~2 hours pure docs.

### Priority E — Round-1 implementation of Voice-acting coach UI tests (when Info.plist lands)

Once the user lands the Voice-acting Coach Info.plist handoff, write 3-5 XCUITest cases verifying:

- The Performance Booth → "Coach my voice" affordance opens `VoiceCoachingSheet`
- The `scaffoldExplainerCard` is NOT shown (since wiring is now active)
- The Record button is enabled
- (Microphone interaction itself cannot be fully tested in XCUITest — the system prompt is OS-mediated; we'd verify the button transitions through the visible phases)

~1.5 hours. Predicated on the Info.plist handoff completing first.

## How to start tomorrow

1. **`git pull --ff-only`** before any file read (per `.claude/rules/portfolio.md` § "Pull Before ANY Cross-Repo Read" — same rule applies in-repo for freshness queries).
2. Re-read this handoff + `Docs/FEATURE_PLAN.md` + `Docs/IMPLEMENTATION_HANDOFF.md` (the top four round addenda).
3. Check `git status -s` is clean.
4. Pick a priority track (A / B / C / D / E) based on user direction.
5. Run the auto-cycle per `feedback_auto_cycle_branch_pr_merge.md` for any multi-commit work.

## Discovered + codified this session

One new "Things That Will Bite You" entry could land in CLAUDE.md, but doesn't strictly need to (the rule is already stated in `.claude/rules/concurrency.md`):

1. **TWO-PART AVAudioNodeTap rule + on-device speech recognition co-locate** — `VoiceActingCoachActiveSession` (PR β.1) implements the canonical pattern: no `self` capture in the tap closure; capture a Sendable `OSAllocatedUnfairLock<[Float]>` accumulator by value; mark the tap `@Sendable`. The recognition task result handler uses `[weak self]` + `DispatchQueue.main.async` for the phase transition (`@MainActor`-isolated property write). Reference impl for any future audio surface — voice-export, voice-import, voice-coaching variant.

## Cross-references

- `Docs/FEATURE_PLAN.md` — Phase 1-4 + cross-cutting checkboxes (Phase 4: 6/8 closed; only row 159 deferred + rows 164-165 blocked-on-hub remain open)
- `Docs/IMPLEMENTATION_HANDOFF.md` — fourth-mid-session round addendum with per-PR detail
- `Docs/HANDOFF_AGENT_SAFETY_RECONFIRMED.md` — fourth reaffirmation appended
- `Docs/APP_STORE_PRIVACY_NUTRITION_LABEL.md` (NEW PR α.1)
- `Docs/APP_STORE_KIDSAFE_PLAN.md` (NEW PR α.2)
- `Docs/AUDIT_PARENTAL_GATES_2026-06-23.md` (NEW PR α.3)
- `Docs/HANDOFF_TO_HUB_CURATING_TOGETHER_PDF.md` (NEW PR γ.1)
- `Apps/DialogueQuest/DialogueQuestUITests/PhaseThreeFourSurfacesUITests.swift` (NEW PR δ.1)
- `Libraries/Sources/Services/Audio/VoiceActingCoachActiveSession.swift` (NEW PR β.1)
- `Libraries/Sources/AppFeature/Crucible/VoiceCoachingSheet.swift` (NEW PR β.1)
- `.claude/rules/portfolio.md` § "Pull Before ANY Cross-Repo Read" — freshness rule
- `.claude/rules/concurrency.md` § "Extension to AVAudioNodeTap closures" — TWO-PART rule (PR β.1 reference impl)
- `.claude/rules/warnings.md` § "Privacy-Gated Frameworks" + "Entitlement-Gated Frameworks" — PR β.1 + PR β.2 scaffold pattern
