# Handoff from App — Dialogue Punctuation Fix-It SHIPPED (iOS)

Direction: **app → hub**. Date: 2026-08-02. Closes the 🟡 iOS-backport row
opened by `Docs/HANDOFF_FROM_HUB_DIALOGUE_PUNCTUATION_FIXIT_WEB_BACKPORT.md`
(Axis 1, `R-CLONE-BIDIRECTIONAL-BACKPORT`). The iOS app now ships the
web-pioneered dialogue-punctuation fix-it drill.

## What shipped

A tap-to-select **Punctuation Fix-It** drill covering all **7 rules** from the
web reference (comma-inside-quotes-before-tag · `?`/`!` replace-the-comma ·
tag-first comma+capital · interrupted-sentence commas · action-beat
period+capital · exclamation no-`!,`-stacking · new-speaker-new-paragraph).

- **Content:** bundled JSON deck mirroring the web `studio.ts` punctuation bank
  (`Libraries/Sources/AppFeature/Resources/Drills/punctuation_fixit.json`) —
  same 7 challenges, same anti-shame `why` diagnostics + `teach` reframes,
  same option text (curly-quote typography preserved).
- **Surface:** an always-available (ungated) "Sharpen your craft" section on
  the **Adventure** tab → a card opens the drill sheet.
- **Register:** reuses the app's existing anti-shame drill pattern — first-try
  scoring, a `why` shown for a wrong pick, a `teach` MentorBubble on reveal,
  the round always advances (a miss never blocks progress). Choice-graded,
  fully on-device, no free-text / no AI evaluator (COPPA-safe).
- **Reusable infrastructure:** `CraftDrill` / `CraftDrillDeck` / `CraftDrillLoader`
  + `CraftDrillMachine` + `CraftDrillView` (`Libraries/Sources/AppFeature/Drill/`)
  — the same shell backs the Write-It-in-Character transfer drill (its own
  handoff).

## Verification

- Full build green (MCP `BuildProject`).
- `CraftDrillTests` (10 tests, all pass): bank invariants (7 drills, exactly
  one correct each, every wrong option carries a non-empty `why`, unique option
  ids, every drill teaches) + machine transitions (first-try scoring,
  selection-locked-after-reveal, no-op reveal without selection, complete after
  last, `reset()`).

## Notes

- Placed on the Adventure "craft" surface rather than the Write-tab toolbar
  (the handoff offered either) — the Adventure tab is the app's practice hub
  (Voice Crucible / Performance Booth already live there), so a tap-to-select
  practice drill fits its register and stays discoverable + ungated.
- Kit *expansion* (the 72→richer set) remains out of scope per the handoff.
