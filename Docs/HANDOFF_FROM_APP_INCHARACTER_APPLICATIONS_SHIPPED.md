# Handoff from App — "Write It in Character" Applications drill SHIPPED (iOS)

Direction: **app → hub**. Date: 2026-08-02. Closes the 🟡 iOS-backport row
opened by `Docs/HANDOFF_FROM_HUB_INCHARACTER_APPLICATIONS_WEB_BACKPORT.md`
(pass 4, `R-CLONE-BIDIRECTIONAL-BACKPORT` / `R-WEB-CLONE-CRA-LADDER`). The iOS
app now ships the CRA-ladder **Applications / transfer** rung.

## What shipped

A **Write It in Character** drill — the learner reads a character + trait + a
moment and picks the line that character would really say (voice + subtext,
feeling shown through action). The transfer/Applications step of the CRA ladder:
the app already teaches/tests the skill; this applies it in a novel context.

- **Content:** an 8-item bundled bank
  (`Libraries/Sources/AppFeature/Resources/Drills/write_in_character.json`)
  mirroring the web `inCharacter.ts` (shy / grumpy-soft-heart / brave-but-scared
  / proud-after-a-loss / curious / loyal / tired-but-loving / stage-nervous).
  Each item's three candidate lines match the web; the correct-line reveal
  reframe (`teach`) is the web's `why`. Per-wrong-option `why` diagnostics were
  authored in-session (anti-shame — each names *why that line breaks the voice*),
  higher-fidelity than the web's single shared `why`.
- **Answer position** is spread across slots (3/3/2) so there's no "always tap A"
  tell.
- **Surface:** a second card in the always-available "Sharpen your craft" section
  on the **Adventure** tab (beside Punctuation Fix-It).
- **Register:** reuses the Wave-2 `CraftDrill*` shell — choice-graded, first-try
  scoring, `why` on a wrong pick, `teach` on reveal, round always advances. No
  free-text / no AI evaluator (COPPA-safe), fully on-device.

## Verification

- Full build green (MCP `BuildProject`).
- `CraftDrillTests` — 14 tests, all pass. Added: in-character deck loads (8
  items); a **parameterized** content-invariant test over BOTH decks (exactly
  one correct, unique option ids, non-empty `why` on every wrong option, every
  drill teaches); answer-position-spread check.

## Notes

- Placed alongside Punctuation Fix-It on the Adventure "craft" surface (the app's
  practice hub) rather than a bespoke mode — it pairs naturally with the existing
  teaching as the Applications rung, and reuses the shared drill infrastructure.
