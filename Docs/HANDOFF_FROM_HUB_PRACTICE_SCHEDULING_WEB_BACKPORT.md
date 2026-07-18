# Handoff from Hub — Practice-scheduling (Review / Mixed practice) web backport

Direction: **hub → app**. The `/play/dialoguequest` web clone shipped a **Review / Mixed-practice** mode
(ADR-048 axis 7; `R-WEB-CLONE-PRACTICE-SCHEDULING`) that the iOS app does not yet surface. This is a
web-pioneered learning surface → an iOS backport under `R-CLONE-BIDIRECTIONAL-BACKPORT`.

## What the web shipped
A boundary-placed **"Mixed practice"** entry off the clone landing that:
1. **Spaced retrieval (FSRS-lite)** — an acquired kit resurfaces on an expanding interval ladder
   (`[1, 3, 7, 16, 35, 75]` days), not only in the round that introduced it. A good review (quality
   ≥ 0.6) advances the ladder; a poor one relearns.
2. **Interleaving** — a round samples questions ROUND-ROBIN across ≥2 **already-acquired** kits
   (never a primitive's first teaching); the learner practises a mix, which improves discrimination
   + retention.
3. **Edge-of-competence** — the review set is ordered toward the mastery frontier (ZPD; kits nearest
   the ~70% "just right" band first).

On-device only (a tiny `<ns>.sched.v1` review-log alongside the existing progress store), **no
identifier, nothing transmitted**. Calm-rails: it **orders + resurfaces, never gates** — no
due-count dread, no streak-guilt, no "you're behind" copy; a gentle come-back invitation.

Web reference impl: `spark-anvil-site/src/lib/play/dialoguequest/review.ts` (+ the shared
`src/lib/play/_shared/practiceScheduling.ts`). Site PR #920.

## Proposed iOS surface (the engine already exists on iOS)
iOS already ships the scheduling **engines** — `ForgeGamification.SpacedRepetitionEngine` (FSRS-6) +
`ForgeMasteryEngine` (edge-of-competence `NextProblemPicker`). The gap is the **surfaced learner-facing
"Review / Mixed practice" MODE**. Proposed:
- A **"Mixed practice"** entry on the app's home/menu that assembles a due-first, interleaved,
  edge-of-competence-ordered round over already-practised kits, using the existing engines (no new
  data model — read the on-device mastery/progress state you already keep).
- Calm-rails identical to the web: orders/resurfaces, never gates; no due-count dread copy;
  boundary-placed (never mid-solve). Anti-shame, first-try scoring, hints-after-a-miss preserved.

## Ownership + status
Hub owns the web + this handoff; **the app's own Claude Code session implements the Swift** (hub never
writes Swift). The parity-ledger row for this feature is **🟡 open** until the iOS Review mode ships
(or the app session records a documented waiver — e.g. "already covered by <surface>").

## References
- `spark-anvil-hub/Docs/web/dialoguequest/PARITY_WEB_VS_IOS.md` § Expansion passes (row **A7**)
- `spark-anvil-hub/Docs/web/dialoguequest/AUDIT_WEB_CLONE_EXPANSION_dialoguequest_2026-07-18_practice_scheduling.md`
- `.claude/rules/spark-anvil-website.md` § R-WEB-CLONE-PRACTICE-SCHEDULING
- `.claude/rules/forgekit.md` § ForgeMasteryEngine / § SpacedRepetitionEngine
