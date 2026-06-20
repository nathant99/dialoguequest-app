---
status: ACTIVE
date: 2026-06-19
direction: agent → user
audience: Nghi (Xcode operator)
intent: wire the new Libraries SPM package into the DialogueQuest workspace + app target — work the agent cannot do safely
freshness-horizon: 30 days
---

# Handoff to User — Xcode GUI Wiring

The agent cannot edit `project.pbxproj` / `contents.xcworkspacedata` / `xcscheme` / `Info.plist` / `entitlements` from disk while operating inside Xcode (per `.claude/rules/xcode-agent-safety.md` — direct edits risk terminating the agent session via External-Changes dialog or workspace reload).

The agent landed `Libraries/Package.swift` + 5 target stubs + an integration test suite. You need to do these GUI steps inside Xcode to make the package visible to the workspace + app target.

## Step 1 — Add the `Libraries` package to the workspace

1. Open `DialogueQuest.xcworkspace` (NOT the `.xcodeproj`)
2. In the Project Navigator, right-click in the empty area below the existing project → **Add Files to "DialogueQuest"…**
3. Navigate to `Libraries/` (the folder, NOT `Libraries/Package.swift`)
4. Click **Add**
5. Wait ~30-60s for SPM to resolve the ForgeKit dependency. The Project Navigator should show a `Libraries` package node with 5 targets (Models / Services / SharedUI / AIMentor / AppFeature) plus the `ForgeKitIntegrationTests` test target

## Step 2 — Add `AppFeature` as a dependency of the `DialogueQuest` app target

1. Select the `DialogueQuest` project in the Project Navigator
2. Select the `DialogueQuest` app target (NOT the test targets)
3. **General** tab → scroll to **Frameworks, Libraries, and Embedded Content**
4. Click **+** → select `AppFeature` (from the `Libraries` package) → **Add**
5. Verify `AppFeature` appears in the list with **Embed & Sign** (or **Do Not Embed** for an SPM library — Xcode defaults are correct)

## Step 3 — Verify the build resolves

1. Cmd+B (Build). First build will take a few minutes (resolving ForgeKit's 58 modules from GitHub)
2. **Expected outcome**: clean build with zero warnings. If a Forge* module fails to resolve, check that `from: "0.99.0"` matches the latest ForgeKit release tag — the agent set this per the bootstrap handoff
3. If you see a network error during package resolution, try **File → Packages → Reset Package Caches** then rebuild

## Step 4 — Run the `ForgeKitIntegrationTests` sanity suite

1. Cmd+U on the `ForgeKitIntegrationTests` scheme (or run from the Test Navigator)
2. **Expected outcome**: 5 tests pass:
   - `versionStringPopulated` — confirms ForgeKit version metadata is wired
   - `bloomLevelOrdering` — confirms `BloomLevel.Comparable` round-trips
   - `localModelsTargetLoads` — confirms the local `Models` target is reachable
   - `xpEngineDeterministic` — confirms `XPEngine` computes a level
   - `gamificationConfigDefaults` — confirms `GamificationConfig()` defaults are sane

3. If any test fails: most likely a ForgeKit version mismatch (the API surface may have shifted between when these tests were authored and current `0.99.x`). Report back via a follow-up handoff and the agent will adjust

## Step 5 — Swap `ContentView` for `AppFeature.RootView`

This step happens AFTER PR 4 (AppFeature scaffolding) lands. The agent will route this via MCP `XcodeUpdate` directly — no GUI step needed from you.

## What stays unchanged

- `Apps/DialogueQuest/DialogueQuest.xcodeproj/project.pbxproj` — the agent did NOT edit this. Step 1 (adding the package to the workspace) is the only project-membership change required, and Xcode authors that on your behalf via the **Add Files** dialog
- `DialogueQuest.xctestplan` — already committed; the new `ForgeKitIntegrationTests` runs from the SPM package's own test scheme, not the app's test plan. If you want it in the app test plan, add it via **Product → Scheme → Edit Scheme → Test → +** (Xcode UI, NOT a JSON edit)
- `Info.plist` / `entitlements` — no changes required for Phase 1 scaffold. Future Phase 1 work will need `NSMicrophoneUsageDescription` (if voice features land) + COPPA consent metadata — those will be filed as separate handoffs when needed

## When you've completed all 5 steps

File `Docs/HANDOFF_FROM_USER_XCODE_WIRING_COMPLETE.md` with a one-line confirmation + any issues encountered. The agent will continue with Phase 1 implementation (PR 3 = Models domain types + tests; PR 4 = SharedUI + AIMentor + AppFeature scaffolds).

If anything fails, paste the Xcode error output into the doc — the agent will troubleshoot from there.

## Cross-references

- `@.claude/rules/xcode-agent-safety.md` — full rationale for why this work routes through you
- `@Docs/IMPLEMENTATION_HANDOFF.md` § 7 — ForgeKit module wiring matrix
- `@Docs/HANDOFF_FROM_LABSMITH_FORGEKIT_BOOTSTRAP.md` — the playbook the agent followed when authoring `Libraries/Package.swift`
