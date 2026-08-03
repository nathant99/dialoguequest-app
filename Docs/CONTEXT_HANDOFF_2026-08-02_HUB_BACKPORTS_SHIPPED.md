# Context Handoff — 6 hub backport handoffs worked (5 shipped + 1 waiver)

status: CLOSED
date: 2026-08-02
freshness-horizon: 14 days

## Summary

Worked all six open hub→app handoffs on `main` as sequential auto-cycled waves
(branch → build → test → PR → merge → return-to-main). Five shipped as real
iOS Swift features; one (networked room MP) is a documented, reasoned waiver.
All PRs merged + verified; `main` clean; build green; 35 new unit tests pass on
integrated main.

## What shipped (verified on origin/main)

| Wave | PR | Feature | Tests |
|---|---|---|---|
| 1 | #203 | **Audio dramas — relocate + bundle + wire.** 6 `.caf` + catalog relocated into `AppFeature/AudioDramas/`; `.copy("AudioDramas")` + `ForgeAudio` dep; `AudioDramaSupport.swift` catalog adapter (synth opener chapter); `AudioDramaPlayer` wired to a "Listen" row on the Profile dashboard. Dropped web-only `.m4a`/`.vtt`. | `AudioDramaBundlingTests` 4/4 |
| 2 | #204 | **Dialogue Punctuation Fix-It drill.** Reusable `CraftDrill*` shell + 7-rule bundled bank (mirrors web `studio.ts`); ungated "Sharpen your craft" Adventure card. | `CraftDrillTests` 10/10 |
| 3 | #205 | **Write It in Character** (CRA Applications rung). 8-item bank mirroring web `inCharacter.ts`; per-wrong `why` authored in-session; 2nd Adventure card. | `CraftDrillTests` 14/14 (parameterized over both decks) |
| 4 | #206 | **Mastery-progression "Your progress" card.** 7 learning milestones (published trees + 6 craft pillars) + optional learner-set goal; hard exclusions (no leaderboard/currency/streak-guilt; recognizes-not-gates). Pure `MasteryProgression` + `MasteryProgressSection` on the Progress tab. | `MasteryProgressionTests` 7/7 (incl. real `XPEngine` path) |
| 5 | #207 | **Mixed practice (practice-scheduling) mode.** FSRS-lite `[1,3,7,16,35,75]` ladder + interleave-over-acquired (never first teaching) + edge-of-competence ordering; `dq.sched.v1` on-device log; Adventure card. | `PracticeSchedulerTests` 10/10 |
| 6 | #208 | **Networked room MP — documented WAIVER** (no server infra; pass-and-play covers local; DoD; candidate ForgeKit lift). | n/a (docs) |

Each shipped wave filed a `Docs/HANDOFF_FROM_APP_*_SHIPPED.md` reply
(+ `..._WAIVER.md` for wave 6) closing its parity row.

## Remaining work / follow-ups (priorities)

- **P1 — Hub reconciles the parity ledger.** `spark-anvil-hub/Docs/web/dialoguequest/PARITY_WEB_VS_IOS.md`: flip the 5 backport rows 🟡→✅ (per the `HANDOFF_FROM_APP_*_SHIPPED.md` replies) and the room-MP row 🟡→⛔ waived (per `HANDOFF_FROM_APP_NETWORKED_ROOM_MP_WAIVER.md`). Hub-owned; the app-side replies are filed.
- **P2 — XCUITests for the new surfaces.** This session shipped Swift Testing unit + bundling coverage for all new logic; it did NOT add XCUITests. Follow-up: drive the new surfaces (Adventure "Sharpen your craft" drill/mixed-practice cards → `drill.punctuation.entry` / `drill.inCharacter.entry` / `mixedPractice.entry`; Profile `profile.audioDramaEntry`; the `drill.check`/`drill.next`/`mixedPractice.check`/`mixedPractice.next` flow) — accessibility identifiers are already in place.
- **P3 — Networked room MP re-open trigger.** When a shared ForgeKit room CLIENT + a hosted room service exist (iOS analog of the live web V261 Cloudflare transport), wire DialogueQuest's quiz/turn logic in, inheriting the safety-by-design invariants. Until then pass-and-play is the shipped together mode.
- **Optional — full-suite CI regression.** Verified via green `BuildProject` + the 4 new suites (35/35) on integrated main; a full `xcodebuild test` across all targets is the belt-and-suspenders CI check.

## Coordination reality

- Solo on the app repo — no parallel PRs, no CLAIMS, only rule-sync commits before the session.
- Two `Package.swift` edits landed as isolated commits (re-resolution discipline): Wave 1 `ForgeAudio` + `.copy("AudioDramas")`; Wave 2 `.process("Resources/Drills")`; Wave 4 `ForgeGamification` test dep.
- New-test-file discovery: worked without a force in Waves 1/2 (Package.swift changed) and Wave 5 (no change); Wave 4's new file rode the `ForgeGamification` test-dep add.

## Reusable infra added

- `AppFeature/Drill/` — `CraftDrill`/`Deck`/`Loader` + `CraftDrillMachine` + `CraftDrillView` (backs both drill modes; add a deck via a JSON in `Resources/Drills/` + a card).
- `AppFeature/Practice/` — `PracticeScheduler` (pure) + `MixedPracticeService` (`dq.sched.v1` store) + `MixedPracticeMachine` + `MixedPracticeView`.
- `AppFeature/Progress/MasteryProgression.swift` — pure milestone/goal derivation.
