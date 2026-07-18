# Handoff to DialogueQuest — Mastery-progression view (web-pioneered → iOS backport)

Direction: **hub → app**. Date: 2026-07-18. Filed per **R-CLONE-BIDIRECTIONAL-BACKPORT** (the web clone
pioneered the surfaced VIEW; the iOS session decides implementation — hub never writes Swift). ADR-048 Decision 8.

## The feature

**A calm, intrapersonal mastery-progression VIEW** on the DialogueQuest landing — an XP-from-mastery **progress bar**
toward the next level, a **learning-milestone achievements shelf** (7 milestones keyed to LEARNING — first round,
5 kits practiced, first 80%+ mastery, N kits mastered, all kits mastered, etc.), and an optional learner-set
**goal** ("master N kits" / "reach level N"). All on-device, no identifier, nothing transmitted.

The iOS engine half already exists (`ForgeGamification` — XPEngine / AchievementEngine / StreakManager). What is
**web-pioneered** is the **surfaced calm intrapersonal view** built on it: iOS surfaces XP/level as chrome but
not this consolidated "Your progress" accomplishment card.

**Hard exclusions (design invariants, not optional):** mastery-oriented + INTRAPERSONAL only — NO leaderboard /
normative rank, NO virtual currency / cosmetic-unlock, NO streak-guilt / scarcity / push re-engagement.
Achievements key to LEARNING milestones (never clicks/volume); personal-best is "beat YOUR best," never others;
it **RECOGNIZES, never GATES** (everything stays free + open); boundary-placed (landing/results), never mid-solve.

## Web reference implementation

- `spark-anvil-site/src/lib/play/_shared/masteryProgression.ts` — pure, framework-agnostic, on-device
  (`localStorage`, no identifier): `deriveStats` (XP · level · level-progress fraction · per-kit personal-best ·
  kits-attempted/mastered), `achievementDefs`/`earnedAchievementIds` (7 milestones scaled to kit count),
  `makeGoals`/`goalProgress`.
- `spark-anvil-site/src/components/play/MasteryProgress.astro` — the calm "Your progress" card (bar + milestone
  shelf + goal select), dark-safe, ≥44px, verdict-not-by-colour (icon + label carry earned state).
- Wired on the `/play/dialoguequest` landing right after the hero.

## Proposed iOS surface

Add a "Your progress" section (Home or a results boundary) built on the existing `ForgeGamification` engines:
an XP-toward-next-level bar, a learning-milestone achievements shelf, and an optional learner-set goal — honoring
the hard exclusions above (no leaderboard/currency/streak-guilt). On-device, no new data collection.

## Status
🟡 open — built web-first (site PR #880) + handoff filed. Closes when iOS ships it or documents a waiver. Tracked
in `spark-anvil-hub/Docs/web/dialoguequest/PARITY_WEB_VS_IOS.md` § Expansion passes (pass 2).
