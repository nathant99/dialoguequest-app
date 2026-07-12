# Handoff to DialogueQuest — Dialogue Punctuation Fix-It (web → iOS backport)

Direction: **hub → app**. Date: 2026-07-11. The `/play/dialoguequest` web clone (clone #26, hub V125)
shipped a **web-pioneered** learning feature the iOS app does not have — a dedicated **dialogue
punctuation fix-it drill**. Per `R-CLONE-BIDIRECTIONAL-BACKPORT` (a learning-relevant feature on one
surface must be backported to the other or explicitly waived), this handoff asks the DialogueQuest iOS
session to consider adding an equivalent surface. Hub never writes Swift — this is a spec + reference,
you own the implementation.

## The feature

**Dialogue Punctuation Fix-It** — a short tap-to-select drill: the learner is shown a described
situation + a prompt, and picks the **correctly-punctuated** version of a line of dialogue from 2–3
candidates. Every wrong option carries an anti-shame diagnostic ("why"), and a "teach" line states the
rule on reveal. First-try scoring.

### Why it's a gap on iOS
DialogueQuest's kits teach `tag_balance` (tags vs. beats vs. pacing) but there is **no surface that
drills dialogue *punctuation* directly** — quotation-mark / comma / capitalization placement. The
cross-platform domain research (Quill.org Proofreader; the classroom "pasta-punctuation" tactile
activity) shows this is a distinct, named, teachable micro-craft ("punctuation can be taught in a day,
so don't skip it"). It's learning-relevant, fully on-device, and deterministically gradable — a clean
fit for a ForgePedagogy-style drill.

### The 7 rules the web drill covers (reference content)
1. **Comma inside quotes before a tag** — `"I'm going home," Maya said.` (not `"…home." Maya said.`)
2. **`?`/`!` replace the comma, inside the quotes** — `"Are you sure?" he asked.`
3. **Tag-first → comma after tag + capitalized speech** — `She whispered, "Don't move."`
4. **Interrupted single sentence → commas, lowercase continuation** — `"I think," she said, "we should wait."`
5. **Action beat (not a tag) → period + capital** — `"I'm done." She pushed back her chair.`
6. **Exclamation: inside quotes, no `!,` stacking** — `"Watch out!" Cal shouted.`
7. **New speaker → new paragraph** — each voice on its own line.

## Web reference implementation
- `spark-anvil-site/src/lib/play/dialoguequest/studio.ts` — `kind: 'punctuation'` challenges (7) +
  `renderChallenge` (tap-to-select, first-try scoring, anti-shame `why`, teach card on reveal).
- Route: `/play/dialoguequest/studio?kind=punctuation`.
- Built on the shared custom-round shell (`_shared/customRound.ts`).

## Proposed iOS surface
- A new drill mode alongside the existing kit quiz — a small SwiftUI tap-to-select card
  (`ForgePedagogy` PolyaScaffold-style: articulate-before-hint, anti-shame feedback). Content can be a
  bundled JSON of `{setup, prompt, options:[{text, correct, why}], teach}`, mirroring the web data.
- Fits the `tag_balance` primitive family; could surface as a kit variant or a Write-tab "polish" tool.

## Status / next steps
- This handoff opens a 🟡 iOS-backport row in `spark-anvil-hub/Docs/web/dialoguequest/PARITY_WEB_VS_IOS.md`
  (Axis 1). The row closes when the iOS session ships the drill (reply with a
  `HANDOFF_FROM_APP_DIALOGUE_PUNCTUATION_FIXIT_SHIPPED.md`) **or** returns a documented waiver.
- No deadline; parity is the default, not a rush. If you judge a dedicated punctuation drill redundant
  with an existing surface, a one-line waiver in your reply closes the obligation.

## What this doc does NOT cover
- The web clone's other Studio drills (Subtext, Show-Don't-Tell) are 🔄 web-native renderings of
  existing iOS kit pedagogy — NOT backport gaps.
- Kit *expansion* (72 → richer set) is a separate, iOS-first, gated content effort — not part of this
  handoff.
