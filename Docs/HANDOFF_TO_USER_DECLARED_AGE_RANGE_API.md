---
status: ACTIVE
date: 2026-06-21
direction: agent → user
audience: Nghi (Xcode operator)
intent: wire the Apple Declared Age Range API gate (iOS 26.2+) so DialogueQuest can self-report the kid's age band via Family Sharing — work the agent cannot do because `Info.plist` + entitlements are in the forbidden-globs list
freshness-horizon: 30 days
---

# Handoff to User — Apple Declared Age Range API gate

The agent cannot author or edit `Apps/DialogueQuest/DialogueQuest/Info.plist` or any `*.entitlements` file per `@.claude/rules/xcode-agent-safety.md` (those files trigger External-Changes dialogs / workspace reloads that terminate the agent session). The Declared Age Range API requires changes to BOTH so this is GUI-only work.

## Why this matters

Per `@.claude/rules/age-assurance.md` § "Declared Age Range API (iOS 26.2+)" the API returns four age categories via Family Sharing: Under 13 (child), 13–15 (teen), 16–17 (older teen), Over 18 (adult). DialogueQuest's curriculum target is ages 9–14, so the Under-13 + 13–15 paths both apply. Wiring the gate gives DialogueQuest a structured signal for parental-consent flow + COPPA actual-knowledge handling per the 2026 FTC amendments (April 22, 2026 compliance deadline).

**Reading "Under 13" creates COPPA actual knowledge** — once that signal lands, all consent flows + record-keeping requirements immediately apply. Do NOT integrate the API on the kid's behalf until the consent flow (separately handed off) is in place. The work below SCAFFOLDS the integration; the actual gate activation is gated on parental-consent UX shipping first.

## What you need to do in Xcode (~10 min)

### Step 1 — Add the Family Sharing entitlement

1. Open `DialogueQuest.xcworkspace` in Xcode
2. Select the `DialogueQuest` project in the Project Navigator
3. Select the `DialogueQuest` app target
4. **Signing & Capabilities** tab → **+ Capability** → **Family Controls**
5. Confirm the `com.apple.developer.family-controls` entitlement appears in `DialogueQuest.entitlements` (Xcode creates the file if it doesn't exist)
6. `git status` should show `M Apps/DialogueQuest/DialogueQuest/DialogueQuest.entitlements` (or `A` if new); the agent will stage + commit this per the carve-out

### Step 2 — Add Info.plist keys

1. Same target → **Info** tab
2. Add the following keys (Xcode UI; do NOT edit `Info.plist` JSON content from disk per `xcode-agent-safety.md`):

| Key | Type | Value |
|---|---|---|
| `NSChildUseDescription` | String | "DialogueQuest uses your Family Sharing age band to tailor the writing experience and consent flow. Nothing the kid writes leaves this device." |

The Declared Age Range API does NOT require a dedicated usage-description key — the `NSChildUseDescription` shown above is the broader child-use disclosure recommended for COPPA-2026 apps. Apple's HIG additionally surfaces the Family Controls authorization sheet with system-supplied copy.

3. Verify `git status` shows `M Apps/DialogueQuest/DialogueQuest/Info.plist`; the agent will stage + commit per the carve-out

### Step 3 — Build verify

1. Cmd+B (Build)
2. **Expected**: clean build. The `Family Controls` framework links automatically once the capability is enabled.
3. If you see "Provisioning profile doesn't include the com.apple.developer.family-controls entitlement", you may need to refresh the provisioning profile via **Signing & Capabilities → Automatically manage signing** off/on or via the Apple Developer portal (per Apple's standard entitlement workflow).

## What happens next (agent-side)

Once Steps 1–3 are complete and the entitlement + Info.plist diffs are committed, a future agent session will:

1. Add a `Libraries/Sources/Services/AgeAssurance/` subfolder with a `DeclaredAgeRangeGate` actor that reads `FamilyControls.AuthorizationCenter.shared` + Apple's `DeclaredAgeRange` API
2. Wire the gate into the `SettingsView` parental-controls section as a "Family Age Band" read-only row (Phase 1 only reads; Phase 2 conditions parental-consent UX on the result)
3. Add unit tests in `ServicesTests/DeclaredAgeRangeGateTests.swift` that mock the API and verify the band-classification helpers
4. Update CLAUDE.md § "Things That Will Bite You" with the entitlement / availability gotchas

## What this handoff does NOT cover

- **Parental consent UX flow** — separate handoff; gated on the Declared Age Range result + 2026 FTC opt-in-for-ads requirement
- **Privacy policy authoring** — separate handoff; needs hub legal review
- **Age rating questionnaire** — App Store Connect work, not Xcode; lands at App Store submission time

## Cross-references

- `@.claude/rules/age-assurance.md` — full portfolio rule (Declared Age Range API + 2026 FTC COPPA amendments + state laws)
- `@.claude/rules/xcode-agent-safety.md` — why Info.plist + entitlements are forbidden globs
- `@Docs/TECHNICAL_DESIGN.md` § "Child Safety & Privacy Architecture" — DialogueQuest's data-classification table
- `@Docs/FEATURE_PLAN.md` § "Onboarding & Child Safety" — the Phase-1 / Phase 2 sequencing

## When you've completed Steps 1–3

`git status` will show the modified `Info.plist` + new `DialogueQuest.entitlements` file. Commit the diff per the standard Xcode-managed-files carve-out (per `xcode-agent-safety.md` § "Staging + committing Xcode-managed files IS allowed"), or leave them staged and the next agent session will pick them up.

If anything fails in Step 3, paste the Xcode error output into a follow-up handoff and the agent will troubleshoot.
