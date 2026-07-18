# Handoff to DialogueQuest — "Write It in Character" Applications/transfer surface (web-pioneered → iOS backport)

Direction: **hub → app**. Date: 2026-07-18. Filed per **R-CLONE-BIDIRECTIONAL-BACKPORT** + **R-WEB-CLONE-CRA-LADDER**
(the web clone pioneered the transfer surface; the iOS session decides implementation — hub never writes Swift). ADR-048.

## The feature

**"Write It in Character"** — the CRA-ladder **Applications/transfer** rung for picking the line a character would really say (voice + subtext). The iOS app teaches/tests the skill
(the Concrete/Representational/Abstract rungs) but has no surface to APPLY it in a novel, real context — which is
where a skill becomes usable. The learner reads a character + moment and chooses the line that fits, feeling shown through action. Choice/build-graded, COPPA-safe (no free-text / no AI evaluator);
quiet stage, anti-shame.

## Web reference implementation

- `spark-anvil-site/src/lib/play/dialoguequest/inCharacter.ts` — seedable bank + `run…` on `_shared/customRound`.
- `spark-anvil-site/src/pages/play/dialoguequest/in-character.astro` — route, linked as a featured card on the landing.

## Proposed iOS surface

Add an "Write It in Character" mode that presents the stimulus and has the learner choose the in-character line from options, then reveals the answer + a
short "why" — on-device, bank-derived, no new data collection. It pairs with the app's existing teaching as the
transfer/Applications step of the CRA ladder.

## Status
🟡 open — built web-first (site PR #900) + handoff filed. Closes when iOS ships it or documents a waiver. Tracked
in `spark-anvil-hub/Docs/web/dialoguequest/PARITY_WEB_VS_IOS.md` § Expansion passes (pass 4).
