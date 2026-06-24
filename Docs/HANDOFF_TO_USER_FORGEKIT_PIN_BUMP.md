---
status: ACTIVE
date: 2026-06-26
direction: agent → user
audience: Nghi (Xcode operator)
intent: bump the ForgeKit pin in Libraries/Package.swift from `from: "0.99.0"` to a 1.0.0-rc.x-aware constraint so the workspace resolves into `ForgeMasteryEngine` + `PolyaScaffold` (shipped in ForgeKit 1.0.0-rc.2/-rc.3)
freshness-horizon: 30 days
---

# Handoff to User — ForgeKit pin bump to 1.0.0-rc.3

The agent CAN edit `Libraries/Package.swift` (Xcode tolerates SPM manifest writes), but the resulting **package re-resolution + `Package.resolved` regeneration is an Xcode-driven operation** and the safer path is to land the manifest edit + let Xcode regenerate `Package.resolved` via the GUI. `Package.resolved` itself is in the forbidden-write glob per `@.claude/rules/xcode-agent-safety.md`.

This handoff describes BOTH paths so you can pick whichever is most convenient. Either way the agent's role is the same — stage + commit the resulting `Package.swift` + `Package.resolved` diff after you finish.

## Why this matters

ForgeKit 1.0.0-rc.2 shipped two load-bearing modules per `@.claude/rules/forgekit.md` § "Module Catalog":

- **`ForgeMasteryEngine`** — `MasteryGraph<Topic>` DAG + `TopicMasteryState` (FSRS-6 + rolling outcomes window) + `NextProblemPicker.recommendations` (extend / consolidate / stretch with `SelectionRationale`) + `MasteryUpdater`. First consumer: AlcumusForge. The DialogueQuest use case is `MasteryGraph<DialogueCraftTopic>` over the 4 craft pillars — voice / subtext / tag balance / branching — so the kid's adaptive coaching surface tracks per-pillar mastery as a value-type DAG rather than the current `@AppStorage`-bucketed counters.
- **`PolyaScaffold`** — `PolyaScaffold` protocol + `PolyaPhase` 4-case enum (understand / plan / execute / lookBack) + `StrategyTag` enum (14 canonical + `.custom`) + `PolyaMachine` state-machine + 3 `Configuration` presets (.default / .strict / .permissive). First consumers: MathCircle + NumberSense. The DialogueQuest use case is to replace the current hand-rolled `DialogueScaffoldingService` wrapper around the lighter `ScaffoldingEngine` + `HintTier` API with the canonical `PolyaMachine`, so Patter's coaching surface follows the articulate-before-hint discipline (`hintsAllowedBeforePlan: 0` default).

ForgeKit 1.0.0-rc.3 is the current patch-level release of the 1.0.0-rc line per the changelog (verify with the ForgeKit repo's latest tag before pinning if you want the absolute newest). The SPM `from: "0.99.0"` constraint **does NOT auto-resolve into pre-release `1.0.0-rc.x` versions** — SPM treats `1.0.0-rc.3` as a pre-release and won't pull it under a stable-`from:` constraint. The pin must explicitly opt in via either `.exact("1.0.0-rc.3")` or `.upToNextMajor(from: "1.0.0-rc.3")` (the upper bound of `2.0.0` lets future patch / stable releases auto-resolve once 1.0.0 lands).

## Path A — agent-authored manifest edit + you run "Update to Latest Package Versions" (recommended, ~3 min)

1. The agent has NOT yet edited `Libraries/Package.swift` — this handoff only files the request. Once you confirm via a quick message ("go ahead with Path A"), the agent will:
   - Edit `Libraries/Package.swift` to change line 26 from `.package(url: "https://github.com/nathant99/forgekit.git", from: "0.99.0"),` to `.package(url: "https://github.com/nathant99/forgekit.git", .upToNextMajor(from: "1.0.0-rc.3")),`
   - Commit the manifest edit in an isolated commit (per `@CLAUDE.md` § Things That Will Bite You — "Land in isolated commits, never bundle with multi-file changes" for `Package.swift`)
   - Push the branch
2. After the agent's branch lands, open `DialogueQuest.xcworkspace` in Xcode (if not already)
3. Xcode will detect the manifest change and offer to re-resolve. If it doesn't auto-prompt: **File → Packages → Update to Latest Package Versions**
4. Xcode regenerates `Package.resolved` with the new ForgeKit revision
5. Verify the resolution worked by checking `Package.resolved` references `forgekit` at `1.0.0-rc.3` (or whichever the latest 1.0.0-rc.x is)
6. Build the project (`Cmd+B` or MCP `BuildProject`) — expect first-build errors if 1.0.0-rc.3 ships any breaking API changes from 0.99.x; surface them to the agent and the agent will sweep the fixes in a follow-up PR
7. Tell the agent "Path A complete" — the agent stages + commits the resulting `Package.resolved` diff

## Path B — you author both the manifest edit + run the GUI re-resolution yourself (~5 min)

1. Open `Libraries/Package.swift` in Xcode (or any editor)
2. Change line 26 from `.package(url: "https://github.com/nathant99/forgekit.git", from: "0.99.0"),` to one of:
   - `.package(url: "https://github.com/nathant99/forgekit.git", .upToNextMajor(from: "1.0.0-rc.3")),` (recommended — patch + stable auto-update once 1.0 lands)
   - `.package(url: "https://github.com/nathant99/forgekit.git", .exact("1.0.0-rc.3")),` (pin to a specific pre-release; useful if you want to manually approve each future bump)
3. Save the file (Xcode auto-detects the manifest change)
4. **File → Packages → Update to Latest Package Versions**
5. Verify `Package.resolved` references the new ForgeKit revision
6. Build the project to confirm clean compile
7. Tell the agent "Path B complete" — the agent stages + commits BOTH the `Package.swift` + `Package.resolved` diffs together

## Verification you can run before unblocking the integration

After either path completes, the agent will run `BuildProject` to confirm the workspace resolves clean. If breakages surface, the agent sweeps them in a follow-up PR (typically thin — a few `import` order tweaks or API rename catches).

To independently verify the modules are now reachable:

1. Open any file in `Libraries/Sources/Services/`
2. Add `import ForgeMasteryEngine` at the top
3. The build should succeed (or surface a usage error if the module name has changed in 1.0.0-rc.3 — that's exactly the kind of API churn the bump is designed to surface early)
4. Remove the test import; the real integration lands in the agent's follow-up PR

## What this unblocks

Per `Docs/SESSION_HANDOFF_2026-06-26_*.md` Priority B and the deferred Priorities D + E from earlier handoffs:

1. **`ForgeMasteryEngine` adoption** (~3-4h agent-side): `MasteryGraph<DialogueCraftTopic>` over voice / subtext / tag balance / branching pillars. Wire to `WriteTabView.recordTreeOutcome` so per-publish outcomes feed the FSRS-6 + rolling-window state. `NextProblemPicker.recommendations` informs Patter's coaching surface — should the kid extend (try a new sub-pillar), consolidate (return to a wobbly pillar), or stretch (push into the edge-of-competence band)?
2. **`PolyaScaffold` adoption** (~3-4h agent-side): replace the current `DialogueScaffoldingService` wrapper around `ScaffoldingEngine` + `HintTier` with a `PolyaMachine` whose phase enum mirrors the kid's actual authoring loop (understand the scene → plan the branches → execute the lines → look back at the published tree). Patter's articulate-before-hint discipline becomes a load-bearing contract rather than a hand-rolled invariant.
3. **ForgeKit module count goes 18 → 20** consumed across DialogueQuest.

## Risks

- **API churn** between 0.99.x and 1.0.0-rc.3 — ForgeKit 0.99→1.0.0-rc.x landed `CastDialog` v1 → v2 + the FSRS-6 mastery-graph spine + the Polya scaffold. None should change types DialogueQuest already imports (DialogueQuest doesn't consume FSRS-6 / `CastEncounter` / etc.), but a clean `BuildProject` after the bump is the only way to know for sure. Risk: medium.
- **Pre-release semver** — if you pick `.upToNextMajor(from: "1.0.0-rc.3")`, future 1.0.0-rc.4 / 1.0.0-rc.5 / 1.0.0 stable releases auto-resolve. If a release introduces a breaking change in a module DialogueQuest consumes, the next workspace open could surface a build error. Mitigation: the agent flags this in `Docs/IMPLEMENTATION_HANDOFF.md` after each pin bump.
- **Reversibility**: very high. Revert the `Package.swift` line + run "Update to Latest Package Versions" again to roll back to 0.99.x.

## What this handoff does NOT cover

- **`ForgeMasteryEngine` integration code** — the agent ships this in a separate PR after the pin lands.
- **`PolyaScaffold` integration code** — same.
- **Any other ForgeKit 1.0.0-rc.x API adoption** — `CastDialog` v2, `CastEncounter`, `ForgeServerLeaderboard`, etc. — only ForgeMasteryEngine + PolyaScaffold are in scope for the next round. The pin bump unblocks anything else as future work.
- **A new test target or app-target dep** — neither new module needs a new test target; both fold into existing `ServicesTests` + `AppFeatureTests`.

## Cross-references

- `@.claude/rules/forgekit.md` § Versioning + § Module Catalog (the `ForgeMasteryEngine` + `PolyaScaffold` rows)
- `@CLAUDE.md` § "Things That Will Bite You" — `Libraries/Package.swift` re-resolution discipline
- `@.claude/rules/xcode-agent-safety.md` — `Package.resolved` is in the forbidden-write glob
- `forgekit/Docs/CHANGELOG.md` — authoritative for the current ForgeKit version + breaking-change notes
- `Docs/SESSION_HANDOFF_2026-06-26_ROUND_CLOSE.md` Priority B (the brief that surfaced this handoff)
