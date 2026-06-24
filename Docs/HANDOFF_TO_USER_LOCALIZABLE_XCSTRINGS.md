---
status: ACTIVE
date: 2026-06-26
direction: agent → user
audience: Nghi (Xcode operator)
intent: create a Localizable.xcstrings string catalog under the AppFeature SPM target so the localization seam is in place before the agent extracts user-facing strings + adopts the ForgeLocalization wrapper
freshness-horizon: 60 days
---

# Handoff to User — Localizable.xcstrings string catalog

The agent cannot author `.xcstrings` files because they are owned by Xcode's String Catalog editor (per `@.claude/rules/xcode-agent-safety.md` + `@.claude/rules/localization.md`). Once the empty `.xcstrings` exists in the right SPM resource directory, the agent extracts every `Text("…")` user-facing string into the catalog programmatically (Xcode auto-indexes the keys on next build).

## Why this matters

Per `@Docs/FEATURE_PLAN.md` Phase 4 and the next-session Priority C from `Docs/SESSION_HANDOFF_2026-06-26_*.md`:

- DialogueQuest is pre-App-Store; the App Store launch will require localized metadata + screenshots.
- The recommended portfolio convention (per QuillSpell + CubeSensei reference impls) is to ship the `.xcstrings` catalog from day one with English-only entries, then add Spanish + Simplified Chinese (the two highest-leverage portfolio locales) closer to App Store submission.
- `@.claude/rules/localization.md` codifies three rules the catalog enables: `Text(verbatim: "DialogueQuest")` for brand names, `String(localized: "key")` for non-SwiftUI strings (accessibility announcements / share text), and the capitalization-collision warning for catalog keys.
- Without an `.xcstrings` catalog in the SPM bundle, the agent cannot adopt the `ForgeLocalization` wrapper (currently unused in DialogueQuest — would be ForgeKit module #19 consumed) per the `@.claude/rules/forgekit.md` § Module Catalog row.

## What you need to do in Xcode (~3 min)

### Step 1 — Create the String Catalog

1. Open `DialogueQuest.xcworkspace` in Xcode
2. In the Project Navigator, navigate to `Libraries → Sources → AppFeature → Resources`
3. Right-click on the `Resources` group → **New File from Template…** (Xcode 26 menu) OR **File → New → File from Template…**
4. Filter: type "string" — select **String Catalog** under the "Resource" category
5. **Next** → name it `Localizable` (Xcode appends `.xcstrings` automatically)
6. **Targets**: ensure only the `AppFeature` library target is checked (NOT `DialogueQuest` app shell, NOT any other Libraries target)
7. **Save location**: confirm the path is `Libraries/Sources/AppFeature/Resources/Localizable.xcstrings`
8. Click **Create**

### Step 2 — Confirm SPM picks up the catalog

After Xcode creates the file, the agent's `Libraries/Package.swift` already declares `.process("Resources")` rules per target. The agent will verify post-GUI that `.process("Resources/Localizable.xcstrings")` is either implicitly covered by the existing `.process("Resources/Questions")` / `.process("Resources/CompanionPack")` / `.process("Resources/Cast")` / `.process("Resources/CustomArt")` set OR add a new `.process("Resources/Localizable.xcstrings")` rule. Likely the existing rules don't cover the catalog because they target specific subdirectories — the agent will add the catalog-specific rule in a follow-up PR.

### Step 3 — Verify the development language

1. With `Localizable.xcstrings` open in Xcode's String Catalog editor
2. Check the upper-right corner — the development language should show **English (en)**
3. If it shows anything else, click and choose **English (en)**

You do NOT need to add any languages yet — start with the empty English catalog. The agent will populate it.

## What the agent will do after the catalog lands

1. **Stage + commit the new `Localizable.xcstrings` file** (per `@.claude/rules/xcode-agent-safety.md` § "Staging + committing Xcode-managed files IS allowed")
2. **Add `ForgeLocalization` to the AppFeature target deps** in `Libraries/Package.swift` (isolated commit per the SPM re-resolution discipline)
3. **Sweep `Libraries/Sources/AppFeature/**/*.swift`** to extract user-facing `Text("…")` strings into keys — for example `Text("Write together")` becomes `Text("write_together")` with the catalog entry mapping `write_together` → `Write together` in English. The sweep respects the three localization rules above:
   - Brand names (`"DialogueQuest"` / `"Patter"` / `"Spark & Anvil"`) become `Text(verbatim: "…")` and are marked `shouldTranslate: false` in the catalog
   - Non-SwiftUI strings (accessibility hints emitted via `AccessibilityNotification.Announcement`, share-link text, etc.) become `String(localized: "…")` — there are a handful in the codebase to hand-audit
   - The capitalization-collision rule applies — duplicate keys differing only in case generate the same symbol; the sweep normalizes
4. **Run `BuildProject`** to confirm zero warnings + no missing-key errors
5. **Surface any non-trivial copy decisions** (e.g., character-name display strings) so you can sign off before the catalog gets locked in

The full sweep is estimated at ~6-8h of agent time per the next-session brief; the actual catalog file lands today via this handoff.

## Verification you can run before unblocking the sweep

1. After Step 1 completes, open `Libraries/Sources/AppFeature/Resources/Localizable.xcstrings` in Xcode
2. The String Catalog editor should show: 0 keys, English (en) as the development language, an empty "Add Localization" picker (you don't need to add languages yet)
3. Build the app (`Cmd+B`) — should compile clean with the empty catalog in place
4. Tell the agent "Localizable.xcstrings created" — the agent stages + commits the file and begins the sweep

## What this handoff does NOT cover

- **Adding additional locales (Spanish, Simplified Chinese, etc.)** — defer until the English entries are stable and we're ready for translator workflow. App Store gate; not blocking TestFlight Beta.
- **The actual `Text("…")` sweep** — that's the agent's follow-up PR (or PRs — likely split per-tab to keep diffs reviewable).
- **`ForgeLocalization` adoption beyond the basic `String(localized:)` pattern** — `ForgeLocalization` ships pluralization + brand-guard + date-formatting helpers; the agent adopts these incrementally as the sweep surfaces use cases.
- **App-shell `.xcstrings` (`Apps/DialogueQuest/DialogueQuest/Localizable.xcstrings`)** — DialogueQuest's app shell is intentionally thin and ships ZERO user-facing strings of its own (per `@CLAUDE.md` § App-Specific Conventions; all UI lives in `AppFeature`). No app-shell catalog needed.

## Cross-references

- `@.claude/rules/localization.md` — three load-bearing rules the catalog enables
- `@.claude/rules/forgekit.md` § Module Catalog § `ForgeLocalization` — what gets adopted after the sweep
- `@.claude/rules/xcode-agent-safety.md` — `.xcstrings` is owned by Xcode's String Catalog editor; agent must NOT author
- `@.claude/rules/warnings.md` § "Non-Obvious Import Requirements" — `String(localized:)` requires `import Foundation`
- `@Docs/FEATURE_PLAN.md` Phase 4 — App Store metadata gate
- `Docs/SESSION_HANDOFF_2026-06-26_ROUND_CLOSE.md` Priority C (the brief that surfaced this handoff)
- QuillSpell + CubeSensei reference impls — both ship `Localizable.xcstrings` from day one under `Packages/Libraries/Sources/AppFeature/Resources/`
