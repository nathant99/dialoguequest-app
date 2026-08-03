# Handoff from App — Mastery-progression "Your progress" card SHIPPED (iOS)

Direction: **app → hub**. Date: 2026-08-02. Closes the 🟡 iOS-backport row
opened by `Docs/HANDOFF_FROM_HUB_MASTERY_PROGRESSION_WEB_BACKPORT.md`
(ADR-048 axis 8, pass 2, `R-CLONE-BIDIRECTIONAL-BACKPORT`).

## What shipped

A calm, **intrapersonal** "Your progress" card on the **Progress** tab — a
learning-milestone shelf + an optional learner-set goal, built on the app's
existing on-device signals.

- **Milestones (7, learning-keyed):** first / five / ten conversations
  published · touched every craft pillar · first craft solid · half the craft
  solid · every craft solid. Keyed to the app's real learning signals —
  published-tree count + the 6 `DialogueCraftMasteryService` craft pillars
  (the iOS analog of the web clone's per-kit counts).
- **Goal (optional, learner-set):** "Master every craft pillar" / "Reach level
  5" / "Publish 10 conversations" / none. A calm ProgressView toward *your*
  target — persisted on-device (`dq.masteryGoal`), no identifier.
- **XP-to-next-level bar** already lives at the top of the dashboard
  (`ForgeXPBar` via `ForgeGamification.XPEngine`); the new card sits directly
  under it, consolidating the accomplishment view.

### Hard exclusions honored (by construction)
No leaderboard / normative rank · no currency / cosmetic unlock · no
streak-guilt / scarcity / push re-engagement. Milestones key to LEARNING,
never clicks/volume; the goal is "reach YOUR target," never a comparison. It
**RECOGNIZES — it never gates** (everything stays free + open). Verdict
(earned/unearned) carried by icon fill + label, not colour alone. On-device,
no new data collection.

## Design note

The pure derivation (`MasteryProgression`) turns `(publishedTreeCount, level,
craft readouts)` → milestones + goal-progress, so it's unit-tested independent
of the view. The iOS milestones are keyed to **published trees + craft-pillar
mastery** (the app's first-class on-device learning state) rather than the
web's per-kit counts, because DialogueQuest tracks craft mastery per pillar
(FSRS-6 via `DialogueCraftMasteryService`), not per-kit best scores.

## Verification

- Full build green (MCP `BuildProject`).
- `MasteryProgressionTests` — 7 tests, all pass: fresh-install zero state,
  publish thresholds (1/5/10), craft milestones (practiced/mastered), goal
  progress (master-all fraction, publish-ten clamp+meet, reach-level-5 via the
  **real `XPEngine`** level path), goal labels.
