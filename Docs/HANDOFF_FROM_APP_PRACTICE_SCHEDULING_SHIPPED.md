# Handoff from App — Mixed practice (practice-scheduling) SHIPPED (iOS)

Direction: **app → hub**. Date: 2026-08-02. Closes the 🟡 iOS-backport row
opened by `Docs/HANDOFF_FROM_HUB_PRACTICE_SCHEDULING_WEB_BACKPORT.md`
(ADR-048 axis 7, row A7, `R-CLONE-BIDIRECTIONAL-BACKPORT`).

## What shipped

A boundary-placed **"Mixed practice"** mode that assembles a due-first,
interleaved, edge-of-competence-ordered refresher over already-practised kits.
All three web mechanisms, on-device:

1. **Spaced retrieval (FSRS-lite).** Each acquired kit resurfaces on the
   expanding day-ladder `[1, 3, 7, 16, 35, 75]` (web parity). A good review
   (first-try quality ≥ 0.6) advances the ladder; a poor one relearns (rung 0).
   Stored in a tiny on-device log at `dq.sched.v1` — no identifier, nothing
   transmitted.
2. **Interleaving.** A round samples questions round-robin across ≥2
   **already-acquired** kits — never a kit's first teaching. Fewer than two
   acquired kits → the round *introduces* the next kit blocked (a first
   teaching), never interleaved.
3. **Edge-of-competence.** Due kits are ordered toward the ~70% "just right"
   band first (Vygotsky ZPD), via each kit theme's craft-pillar mastery
   (`DialogueCraftMasteryService`, which wraps `ForgeMasteryEngine`).

**Calm-rails (honored by construction):** it **orders + resurfaces, it never
gates**. No due-count dread, no streak-guilt, no "you're behind" copy — the
entry is a gentle "Ready when you are" invitation, and the round always
advances (anti-shame, first-try scoring). Surfaced as a card in the
always-available "Sharpen your craft" section on the Adventure tab.

## Design note

The scheduling engine is a fixed-ladder FSRS-lite matching the web `review.ts`
contract exactly (parity + determinism + testability). `ForgeGamification.`
`SpacedRepetitionEngine` (FSRS-6) remains the available upgrade path for a
future full-FSRS revision; the edge-of-competence ordering already reads the
`ForgeMasteryEngine`-backed mastery frontier via the Services wrapper. Pure
logic (`PracticeScheduler`) is fully unit-tested independent of persistence
and UI.

## Verification

- Full build green (MCP `BuildProject`).
- `PracticeSchedulerTests` — 10 tests, all pass: ladder due-dates + advance/
  relearn, `stateAfterReview` (first-review rung 0 / advance / relearn),
  round assembly (introduce-when-<2-acquired, introduce-next, interleave-only-
  over-acquired + never-first-teaching, round-robin), edge-of-competence
  ordering (due-first then frontier), the round machine's per-kit first-try
  quality tally, and the on-device store round-trip.
