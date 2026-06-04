---
status: APPROVED
date: 2026-06-04
freshness-horizon: 90d
direction: labsmith → app
audience: app-repo Claude Code session (any portfolio app)
forgekit-version-target: 0.99.x (current) / 1.0.0 (when stable lands)
---

# Handoff from Labsmith — ForgeKit Integration Bootstrap

**Direction**: labsmith → app. Canonical step-by-step playbook for adding ForgeKit as an SPM dependency in any portfolio app and wiring its 45 client modules (+ 11 server modules where applicable) into the app's local Swift Package targets.

This is the **first ForgeKit doc** every app should read when starting integration. Companion docs:

- `labsmith/Docs/TEMPLATE_PLAN_FORGEKIT_INTEGRATION.md` — reusable per-app migration ladder template
- `labsmith/Docs/GUIDE_FORGEKIT_ADOPTION_BY_CLUSTER.md` — cluster-specific wiring priorities (Math / Writing / Multiplayer / Together / etc.)
- `labsmith/.claude/rules/forgekit.md` — module catalog + versioning + theming + gotchas (REFERENCE — load-bearing)
- `forgekit/Docs/CHANGELOG.md` — authoritative version reference

## When to read this doc

- Your app has `Packages/Libraries/Package.swift` but ForgeKit is NOT listed as a `.package(...)` dependency yet
- OR ForgeKit is listed but no target uses `.product(name: "Forge*", package: "forgekit")` in its dependencies
- OR you're about to fix a build error involving Forge* types that aren't resolving

## When NOT to read this doc

- You already have ForgeKit wired and are migrating local types to ForgeKit equivalents — read `TEMPLATE_PLAN_FORGEKIT_INTEGRATION.md` instead
- You're upgrading from one ForgeKit version to another — see `.claude/rules/forgekit.md` § "Remote GitHub Dependency"
- Your app is a server-only (Hummingbird 2) target — use `labsmith/Docs/GUIDE_FORGESERVER_ADOPTION.md`

## Step 1 — Add ForgeKit as an SPM dependency

In `Packages/Libraries/Package.swift` (NOT in the xcodeproj or workspace — see § Common Gotchas):

```swift
// In Package.swift `dependencies:` array
.package(url: "https://github.com/nathant99/forgekit.git", from: "0.99.0"),
```

**Pin notes**:
- `from: "0.99.0"` resolves to the latest released `0.99.x` version (SPM follows SemVer minor-bump tolerance)
- Pre-release tags (`1.0.0-rc.1`, etc.) are NOT included by default — pin to a SPECIFIC release if you need a pre-1.0-rc
- Upgrade later via Xcode's `File > Packages > Update to Latest Package Versions` (NOT by editing Package.swift)

## Step 2 — Identify your target structure

Open `Packages/Libraries/Package.swift` and inventory your targets. The canonical portfolio shape (App Shell + Local Packages) has these targets in `Libraries/Sources/`:

| Target | Typical role | Imports ForgeKit |
|---|---|---|
| `Models` | Domain types, `@Model` classes, value types | ForgeModels (foundational types) |
| `Services` | Persistence, audio, networking, analytics | ForgePersistence + ForgeGamification + ForgeAnalytics + ForgeAudio (when SFX shipping) |
| `SharedUI` | Reusable SwiftUI components, theming | ForgeUI + ForgeAccessibility |
| `GameEngine` | SpriteKit scenes, SKScene helpers | ForgeGameEngine |
| `AIMentor` | FoundationModels session, `@Generable` types | ForgeAI |
| `AppFeature` | Root view, app coordinator, navigation | ForgeNavigation |

Some apps add additional targets (`Multiplayer` / `Adventure` / `PartyGames` / etc.) — wire to the matching ForgeKit module.

## Step 3 — Wire per-target dependency edges

Add `.product(name: "Forge*", package: "forgekit")` entries to each target's `dependencies:` array. **Canonical 7-module bootstrap** (the minimum useful integration):

```swift
.target(
    name: "Models",
    dependencies: [
        .product(name: "ForgeModels", package: "forgekit"),
    ],
    // ...
),
.target(
    name: "Services",
    dependencies: [
        "Models",
        .product(name: "ForgePersistence", package: "forgekit"),
        .product(name: "ForgeGamification", package: "forgekit"),
        .product(name: "ForgeAnalytics", package: "forgekit"),
    ],
    // ...
),
.target(
    name: "SharedUI",
    dependencies: [
        "Models",
        "Services",
        .product(name: "ForgeUI", package: "forgekit"),
        .product(name: "ForgeAccessibility", package: "forgekit"),
    ],
    // ...
),
.target(
    name: "GameEngine",
    dependencies: [
        "Models", "Services", "SharedUI",
        .product(name: "ForgeGameEngine", package: "forgekit"),
    ],
    // ...
),
.target(
    name: "AIMentor",
    dependencies: [
        "Models",
        .product(name: "ForgeAI", package: "forgekit"),
    ],
    // ...
),
.target(
    name: "AppFeature",
    dependencies: [
        "Models", "Services", "SharedUI", "GameEngine", "AIMentor",
        .product(name: "ForgeNavigation", package: "forgekit"),
    ],
    // ...
),
```

**Optional cluster-specific add-ons** — see `GUIDE_FORGEKIT_ADOPTION_BY_CLUSTER.md` for the cluster-by-cluster wiring matrix. Common add-ons:

- `ForgeAvatar` — if you ship avatar customization (wait for stable 1.0.0+)
- `ForgePassAndPlay` + `ForgeMultipeerKit` — if you ship pass-and-play or local multipeer
- `ForgeMultiplayer` + `ForgeGameCenter` — if you ship online multiplayer
- `ForgeClassroom` — if you ship Live Classroom (LiveKit Cloud-backed)
- `ForgeIllustrations` — when labsmith ships your illustration bundle
- `ForgeAudio` + `ForgeCelebration` — when labsmith ships SFX + celebration assets
- `ForgeContent` — when question kits ship
- `ForgePedagogy` + `ForgeProgression` — DDA difficulty + session-based gating
- `ForgeReporting` — when parent dashboard ships
- `ForgeDevelopmental` + `ForgeEmotionAware` — DIR/FEDC scaffolding (mental-health-adjacent apps)
- `ForgeAdventure` — Adventure Mode (13 mode engines)
- `ForgeEvents` — Seasonal events (41 built-in holidays)
- `ForgeBranding` + `ForgeLocalization` — string catalogs + brand consistency
- `ForgeWidgets` + `ForgeLiveActivities` + `ForgeSpotlight` + `ForgeIntents` — system integrations
- `ForgeKnowledgeGraph` + `ForgeExperiments` + `ForgeSettings` — Phase-2 capabilities
- `ForgeStateMachine` — generic finite-state-machine helpers (optional polish)
- `ForgeSync` + `ForgeSocial` — cross-app progression sync + COPPA-bound leaderboards
- `ForgeMath` — math utilities + expression evaluation (math-cluster apps)
- `ForgeMiniGames` + `ForgePartyGames` + `ForgePuzzles` — pre-built mini-game engines
- `ForgeNetworking` — REST client + API layer
- `ForgeSensory` — multi-modal feedback (visual + audio + haptic)
- `ForgeColoringMode` + `ForgeManagedConfiguration` — accessibility + MDM
- `ForgeGameEngine` — SpriteKit helpers (most apps already wired in Step 3)

## Step 4 — Add a `ForgeKitIntegrationTests` target

Add a test target verifying the integration:

```swift
.testTarget(
    name: "ForgeKitIntegrationTests",
    dependencies: [
        .product(name: "ForgeModels", package: "forgekit"),
        .product(name: "ForgeGamification", package: "forgekit"),
        // any other modules you wired
        "Models",  // your local target — for collision verification
    ],
    swiftSettings: defaultSwiftSettings
),
```

Author 3-5 sanity tests:
1. Version string is non-empty + matches expected major (`ForgeKitVersion.version`)
2. `BloomLevel.remember < BloomLevel.create` (Comparable conformance works)
3. `GradeLevel` ordering is correct
4. Your local type + a ForgeKit type with overlapping name (e.g. local `Models.Expression` vs `Foundation.Expression`) compile clean when fully-qualified
5. A representative ForgeKit value type initializes successfully

Reference: `chemquest-app/Tests/ForgeKitIntegrationTests/` (5 sanity-check tests).

## Step 5 — Build + verify

1. Close Xcode if open (per `.claude/rules/xcode-agent-safety.md`)
2. Delete `Libraries/.swiftpm/` and `Libraries/.build/` to force a clean SPM resolution
3. Open `<AppName>.xcworkspace` (NOT `.xcodeproj` — see § Common Gotchas)
4. Wait for SPM to resolve packages (~30-60s first time)
5. Build (Cmd+B). Should be clean.
6. Run `ForgeKitIntegrationTests` (Cmd+U on the test target). All 5 tests pass.

## Step 6 — File the post-integration handoff

Once Steps 1-5 succeed, file `Docs/HANDOFF_FROM_APP_FORGEKIT_INTEGRATION_COMPLETE.md` in your app repo summarizing:

- ForgeKit version pinned
- Which modules wired (which deferred)
- Type-collision risks observed (per `.claude/rules/forgekit.md` § Common Gotchas)
- Any issues encountered + workarounds applied
- Next migration steps (see `TEMPLATE_PLAN_FORGEKIT_INTEGRATION.md`)

## Common Gotchas (see `.claude/rules/forgekit.md` § Common Gotchas for the full list)

1. **ForgeKit path from `Libraries/Package.swift`** — it's TWO levels up (`../../forgekit`), not one (`../forgekit`) — only relevant if using `.package(path:)` for local dev. Default remote URL avoids this entirely.
2. **`AppPhase` / `AppTab` / `AvatarConfig` collisions** — if your app defines these locally AND imports ForgeNavigation / ForgeAvatar, qualify the local one as `<YourTarget>.AppPhase` in all files importing both.
3. **`@retroactive` not needed within same SPM package** — conformances across targets in the same `Libraries` package are NOT retroactive. Using `@retroactive` is a compile error.
4. **Don't add ForgeKit to the xcodeproj or workspace** — only declare it in `Libraries/Package.swift`. Otherwise: duplicate target warnings + ambiguous type errors.
5. **`AvatarStudioView` requires `getOrCreateForgeID` seeding** — if you adopt the avatar editor, seed the ForgeID via `appGroupStore.getOrCreateForgeID(...)` in `.task` BEFORE the editor opens. Otherwise: cryptic `AppGroupStoreError error 0`.
6. **Pre-1.0 breaking changes are expected** — current version is `0.99.x` heading to `1.0.0`. Pin via `from: "0.99.0"` for SemVer tolerance; do NOT pin to `branch: "main"`.
7. **`swift test` CLI fails with SwiftData / Swift Testing** — use Xcode's `RunSomeTests` / `xcodebuild test` instead.
8. **SwiftLint plugin SUSPENDED** — comment out `SwiftLintPlugins` in Package.swift; crashes on Xcode 26.
9. **Default MainActor isolation in ForgeKit value types** — all ForgeKit Sendable structs/enums are marked `nonisolated`; your local Sendable types consumed by ForgeKit generic constraints (`<T: Sendable & Identifiable>`) must also be `nonisolated` (production AND test fixtures).

## ForgeKit module catalog (reference)

45 client modules + 11 server modules + 2 shared modules = 58 total. Full catalog with one-line purpose statements in `.claude/rules/forgekit.md` § "Module Catalog".

**Client modules** (45): ForgeAI / ForgeAccessibility / ForgeAdventure / ForgeAnalytics / ForgeAudio / ForgeAvatar / ForgeBranding / ForgeCelebration / ForgeClassroom / ForgeColoringMode / ForgeContent / ForgeDevelopmental / ForgeEmotionAware / ForgeEvents / ForgeExperiments / ForgeGameCenter / ForgeGameEngine / ForgeGamification / ForgeIllustrations / ForgeIntents / ForgeKnowledgeGraph / ForgeLiveActivities / ForgeLocalization / ForgeManagedConfiguration / ForgeMath / ForgeMiniGames / ForgeMultipeerKit / ForgeMultiplayer / ForgeNavigation / ForgeNetworking / ForgePartyGames / ForgePassAndPlay / ForgePedagogy / ForgePersistence / ForgeProgression / ForgePuzzles / ForgeReporting / ForgeSensory / ForgeSettings / ForgeSocial / ForgeSpotlight / ForgeStateMachine / ForgeSync / ForgeUI / ForgeWidgets

**Server modules** (11): ForgeClassroomServer / ForgeServerActors / ForgeServerEmail / ForgeServerLeaderboard / ForgeServerMatchmaking / ForgeServerMiddleware / ForgeServerMultiplayer / ForgeServerRealTime / ForgeServerSafety / ForgeServerTracking / ForgeServerWebSocket

**Shared modules** (2): ForgeModels / ForgeServerDTOs

## Sequencing — what comes next

1. ✅ Bootstrap (this doc) — wire ForgeKit as an SPM dep + canonical 7-module bootstrap
2. 🚧 Migration ladder — replace local types with ForgeKit equivalents per `TEMPLATE_PLAN_FORGEKIT_INTEGRATION.md`
3. 🚧 Cluster-specific add-ons — wire optional modules per `GUIDE_FORGEKIT_ADOPTION_BY_CLUSTER.md`
4. 🚧 Subsequent ForgeKit upgrades — track via `forgekit/Docs/CHANGELOG.md`

## Cross-references

- `labsmith/.claude/rules/forgekit.md` — full module catalog + versioning + theming + 30+ gotchas
- `labsmith/.claude/rules/spm-architecture.md` — App Shell + Local Packages pattern + SPM gotchas
- `labsmith/.claude/rules/xcode-agent-safety.md` — Xcode-managed files the agent must not write
- `forgekit/Docs/CHANGELOG.md` — authoritative version + per-release notes
- `labsmith/Docs/PLAN_FORGEKIT_ROADMAP.md` — per-release rationale archive
- `labsmith/Docs/TEMPLATE_PLAN_FORGEKIT_INTEGRATION.md` — companion migration template
- `labsmith/Docs/GUIDE_FORGEKIT_ADOPTION_BY_CLUSTER.md` — companion cluster guide
- `chemquest-app/Docs/HANDOFF_FROM_APP_FORGEKIT_INCREMENTAL_MIGRATION.md` — reference implementation (app-direction follow-on)
