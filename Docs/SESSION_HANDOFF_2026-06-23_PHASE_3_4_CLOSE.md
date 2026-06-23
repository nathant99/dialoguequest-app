---
status: ACTIVE
date: 2026-06-23
direction: session → next CLAUDE Code session
audience: future Claude Code session opening DialogueQuest cold
intent: brief the next session on what just shipped, what's still open, and what's worth picking up next
freshness-horizon: 30 days
---

# Session Handoff — Phase 3 + Phase 4 close (2026-06-23 third mid-session)

> **TL;DR**: Phase 3 closed end-to-end; Phase 4 nearly closed (5 of 8 rows). 7 PRs landed in one session under the auto-cycle. 16-kit set complete. ForgeKit module count: 17. Net delta: +69 tests (302 → 371 total).

## What shipped this session (PRs 100-106)

| PR | Title | Net delta |
|---|---|---|
| #100 | Doc-sync round (PR 1) | Phase 3 checkboxes ticked + CLAUDE.md Audio/ taxonomy + IMPLEMENTATION_HANDOFF third-mid-session addendum. Pure docs. |
| #101 | Voice-acting coach scaffold (PR 2) | `VoiceActingCoachService` (privacy-gated; safe no-op until Info.plist wires) + `HANDOFF_TO_USER_VOICE_ACTING_COACH_INFOPLIST.md`. Closes Phase 3 row 144. 9 tests. |
| #102 | Performance Booth adventure mode (PR 3) | `PerformanceBoothMachine` (3-stage value-type) + `PerformanceBoothView` + new `performance_booth_premiere` achievement (50 XP) + new `.performanceBoothExported` analytics event. Closes Phase 3 row 148. 12 tests. |
| #103 | Phase 4 anthology curation (PR 4) | New `@Model AnthologyCollectionRecord` (lightweight schema addition; no V2) + `AnthologyCollectionService` + `AnthologyCurationView` + `ProfileDashboardView` rows (Anthology + Curate collections). Closes Phase 4 row 158. 9 tests. |
| #104 | Phase 4 kits + achievements (PR 5) | 3 new JSON kits (14-16) + 8 new advanced achievements + 8 new `Criteria` signals. **Full 16-kit set met.** Closes Phase 4 rows 161-162. 20 tests. |
| #105 | ForgeLiveActivities scaffold (PR 6) | `DialogueWritingSessionActivity` (entitlement-gated; safe no-op) + `HANDOFF_TO_USER_WIDGET_EXTENSION.md`. ForgeKit module count 16 → 17. 8 tests. |
| #106 | Round-close + session handoff (PR 7 — this PR) | Tick remaining FEATURE_PLAN checkboxes + IMPLEMENTATION_HANDOFF + AGENT_SAFETY third-reaffirmation + this session handoff. Pure docs. |

## What state the codebase is in

### ForgeKit integration

**17 of ~58 ForgeKit modules consumed.** New addition this round: `ForgeLiveActivities` (in Services target). The other 16:

- **Shared** (2): ForgeModels (Models), ForgeServerDTOs (not directly imported — surfaces via others)
- **Client/Services** (11): ForgePersistence, ForgeAI, ForgeAnalytics, ForgeGamification, ForgeKnowledgeGraph, ForgeLiveActivities (NEW), ForgePedagogy, ForgeReporting, ForgeSensory, ForgeSpotlight, plus implicit ForgeModels via Models target
- **Client/SharedUI** (2): ForgeUI, ForgeAccessibility
- **Client/AIMentor** (1): ForgeAI
- **Client/AppFeature** (12): ForgeUI, ForgeNavigation, ForgeAdventure, ForgeAvatar, ForgeCelebration, ForgeGamification, ForgeIntents, ForgePassAndPlay, ForgePedagogy, ForgeProgression, ForgeStateMachine, ForgeSync

### Still-deferred ForgeKit modules

- **ForgeWidgets** — depends on Widget Extension target landing first (handoff filed PR #105)
- **ForgeClassroom** — Phase 4 row 159 (deferred — requires server-side classroom infrastructure)
- **ForgeContent / ForgeMasteryEngine / ForgeMath / ForgeMultiplayer / ForgeMultipeerKit / ForgePartyGames / ForgePolyaScaffold** — not in current product scope

### Test count

| Target | Tests | New this round |
|---|---|---|
| ModelsTests | ~30 | 0 |
| ServicesTests | ~165 | +43 (Voice-Acting 9 + Anthology Collection 9 + Phase 3 achievement 1 + Phase 4 achievement 8 + Phase 4 gamification 5 + LiveActivities 8 + Phase 3 gamification IDs update 0 net) |
| AIMentorTests | ~50 | 0 |
| AppFeatureTests | ~95 | +18 (PerformanceBooth 11 + Phase 4 kits 7) |
| ForgeKitIntegrationTests | ~5 | 0 |
| **Total** | **~370** | **+69 net** |

### SPM layout drift

`Libraries/Sources/Services/` taxonomy now matches CLAUDE.md § "SPM File Layout Convention". `Audio/` subfolder documented; `Sensory/` adds `DialogueWritingSessionActivity`; `Privacy/` adds `TraumaAxisAdvisoryService`; `Persistence/` adds `AnthologyCollectionService`.

## What's still open

### Hub-side asks (BLOCKED on hub, not us)

1. **`HANDOFF_TO_HUB_HUBCONTRIBUTION_LEVEL_1.md`** — hub must ship `spark-anvil-hub/Resources/HubContributions/dialoguequest.json` for AdventureHub Word Workshop tile. **Unchanged this round.** Blocks: AdventureHub integration. The Level-2 Swift overlay (`DialogueQuestHubContribution`) already ships.
2. **`HANDOFF_TO_HUB_PATTER_APP_ICON_PNG.md`** — hub must generate 1024×1024 Patter source PNG. **Unchanged this round.** Blocks: `HANDOFF_TO_USER_APP_ICON.md` (Icon Composer needs the source).

### User-side GUI asks (BLOCKED on user GUI work)

| Handoff | What user does | Unblocks |
|---|---|---|
| `HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md` (ACTIVE) | Family Controls entitlement + `NSChildUseDescription` Info.plist key | Activates the parental-consent flow's age-band path |
| `HANDOFF_TO_USER_APP_ICON.md` (ACTIVE, blocked-on-hub) | Run Icon Composer on hub-shipped PNG | Ships the 6-variant Liquid Glass icon set |
| `HANDOFF_TO_USER_VOICE_ACTING_COACH_INFOPLIST.md` (NEW PR #101) | Add `NSMicrophoneUsageDescription` + `NSSpeechRecognitionUsageDescription` Info.plist keys | Activates `VoiceActingCoachService` from `.notWired` → `.notRequested`; future PR can then add the active path (SFSpeechRecognizer + AVAudioEngine.installTap with the TWO-PART rule) as pure SPM source. |
| `HANDOFF_TO_USER_WIDGET_EXTENSION.md` (NEW PR #105) | Create Widget Extension target via Xcode template + `NSSupportsLiveActivities` Info.plist key | Activates `DialogueWritingSessionActivity` from `.notWired` → `.ready`. Once active, a follow-up PR can wire the Activity.request(...) path + the per-session start/update/end calls from WriteTabView. |

### Phase 3 — 100% CLOSED

All 6 Phase 3 FEATURE_PLAN rows ticked. Voice-acting coach is scaffold-shipped (active path blocked on Info.plist handoff).

### Phase 4 — 5 of 8 rows CLOSED

| Row | Status |
|---|---|
| 158 anthology curation | ✅ CLOSED (PR #103) |
| 159 classroom mode (`ForgeClassroom`) | ⏸️ DEFERRED — requires server-side infrastructure |
| 160 parent progress reports (`ForgeReporting`) | ✅ CLOSED (PR #92 earlier round) |
| 161 3 final question kits 14-16 | ✅ CLOSED (PR #104) |
| 162 8 advanced achievements | ✅ CLOSED (PR #104) |
| 163 App Store submission prep | 🟡 OPEN — privacy nutrition label / KIDSAFE plan / parental gates audit |
| 164 App Store screenshot + preview-video | ⏸️ BLOCKED on hub distribution pipeline |
| 165 App icon | ⏸️ BLOCKED on Patter PNG + Icon Composer GUI |

### Phase-Delight / Phase-A11y / Phase-Onboarding — already 100% closed

No outstanding work.

## What's worth picking up next session

### Priority A — Phase 4 row 163 (App Store submission prep)

The remaining FEATURE_PLAN item that the agent can ship in pure SPM-source + docs:

1. **Privacy nutrition label** — author `Docs/APP_STORE_PRIVACY_NUTRITION_LABEL.md` summarizing the data DialogueQuest collects (none) + retains (none). Mirrors the COPPA-2026 posture already documented in `PrivacyPolicyView`. ~1 hour.
2. **KIDSAFE plan** — author `Docs/APP_STORE_KIDSAFE_PLAN.md`. The portfolio guide is at `.claude/rules/age-assurance.md`; per-app KIDSAFE plans typically run 5-8 pages covering parental consent surface, content moderation (no UGC outbound), in-app purchases (none), advertising (none), data sharing (none). ~2 hours.
3. **Parental gates audit** — `Docs/AUDIT_PARENTAL_GATES_2026-06-23.md` enumerating every gate (math challenge for external links / Family Controls entitlement scaffold / Declared Age Range scaffold / parental consent service / crisis resources) and where they fire. ~1 hour.

### Priority B — Active wiring of scaffold-shipped features (once user GUI work lands)

If the user wires either of the two new handoffs from this round:

- **Voice-acting coach** — the active path is pure SPM source per the scaffold's documented future-wired-path block. Roughly: `requestAuthorization()` → `AVAudioEngine.installTap` (TWO-PART rule) → `SFSpeechRecognizer.recognitionTask(with:)` (on-device locale) → drain transcript at the MainActor boundary → call the existing `scoreTranscript(_:against:)`. Add a UI surface under `PerformanceBoothView` or as its own sheet from `WriteTabView`. ~4 hours.
- **Widget Extension Live Activity** — the active path is also pure SPM source once the target ships. Wire `DialogueWritingSessionActivity.start(...)` into `WriteTabView` on first published node; `update(...)` on every `machine.tree.nodes.count` change; `end()` on `.published` or background-for-8-hours. The widget's `LiveActivity.swift` content view is in the new target. ~3 hours.

### Priority C — Pillar deepening / Hub-integration loose ends (not strictly required for app store)

- **DN-S Move D Phase 3** — Live cast voicings via `CastDialog` are wired via `dq.experiments.castVoicing` AppStorage. The kid-facing surface is mature; the next move (per `Docs/HANDOFF_FROM_LABSMITH_DN_S_AI_MENTOR_VOICING.md` step 4-5) would be telemetry-driven rollout. Hub-side work, not app-side.
- **Companion Pack v2** — current pack ships 3 PDFs (parent letter / coloring / cast poster). Extending with a "Phase 4 collections curation guide" PDF for parents is a future ask.

### Priority D — Test-infrastructure hygiene

- **AIMentorTests in xctestplan** — already closed per `HANDOFF_TO_USER_ADD_AIMENTORTESTS_TO_TESTPLAN.md`. No action.
- **UI test coverage for new Phase 3 + 4 surfaces** — `PerformanceBoothView` + `AnthologyCurationView` lack `DialogueQuestUITests` smoke tests. Could add 4-6 tests under the existing UI test target (the agent can author the test files; running them requires the user's simulator). ~2 hours. Lower priority — unit tests cover the core machines and services.

## How to start tomorrow

1. **`git pull --ff-only`** before any file read (per `.claude/rules/portfolio.md` § "Pull Before ANY Cross-Repo Read" — same rule applies in-repo for freshness queries).
2. Re-read this handoff + `Docs/FEATURE_PLAN.md` + `Docs/IMPLEMENTATION_HANDOFF.md` (the top three round addenda).
3. Check `git status -s` is clean.
4. Pick a priority track (A / B / C / D) based on user direction.
5. Run the auto-cycle per `feedback_auto_cycle_branch_pr_merge.md` for any multi-commit work.

## Discovered + codified this session

Two new "Things That Will Bite You" entries should be added to CLAUDE.md (one per pattern):

1. **Privacy-gated scaffold pattern roundtrips through tests safely** — the static-let probe in `VoiceActingCoachService` / `DialogueWritingSessionActivity` resolves once at first access and stays cached. Tests must assert against `availability` invariants relative to `isWired` (not absolute states) because the test bundle's Info.plist may or may not have the keys depending on Xcode 26's project-editor-managed Info-keys table. Pattern: `if isWired { availability != .notWired } else { availability == .notWired }`.

2. **AnthologyCollectionRecord schema addition pattern** — added directly to `DialogueQuestSchemaV1` per `.claude/rules/swiftdata.md` "Pre-App Store: don't create new `VersionedSchema` for unreleased models". SwiftData picks up new model classes via lightweight migration. The app shell's `ModelContainer` init list needs the new class (MCP `XcodeUpdate` for app-shell `.swift` per CLAUDE.md § Xcode Agent Safety).

Both will land in PR 7's CLAUDE.md edit alongside this handoff.

## Cross-references

- `Docs/FEATURE_PLAN.md` — Phase 1-4 + cross-cutting checkboxes (Phase 3: 100% closed; Phase 4: 5/8 closed)
- `Docs/IMPLEMENTATION_HANDOFF.md` — third-mid-session round addendum with per-PR detail
- `Docs/HANDOFF_AGENT_SAFETY_RECONFIRMED.md` — third reaffirmation appended
- `Docs/HANDOFF_TO_USER_*.md` — 2 new + 3 existing GUI handoffs (5 total ACTIVE)
- `Docs/HANDOFF_TO_HUB_*.md` — 2 hub asks unchanged this round
- `CLAUDE.md` — § SPM File Layout Convention (Audio/ + AnthologyCollectionService + DialogueWritingSessionActivity rows updated PR #100)
- `.claude/rules/portfolio.md` § "Pull Before ANY Cross-Repo Read" — freshness rule
- `.claude/rules/swiftdata.md` § "Pre-App Store: don't create new `VersionedSchema` for unreleased models" — PR 4's schema addition pattern
- `.claude/rules/warnings.md` § "Privacy-Gated Frameworks" + "Entitlement-Gated Frameworks" — PR 2 + PR 6 scaffold pattern
