# ForgeKit Integration

Shared SPM framework at `../forgekit/`. Apps import only the modules they need.

> **⚡ THIS IS A CARD (ADR-111 always-on-context budget fold, 2026-08-17).** Each section below keeps its heading (so `§ <heading>` cross-refs still resolve) + its load-bearing INVARIANT. The FULL detail — the per-release changelog, the pin-cohort census, the module-catalog tables, the ForgeUI/ForgeGamification/ForgeModels quick-reference API tables + snippets, the ForgePedagogy scaffolding-theory tables + citations, the Avatar-system design detail, the Server `/version` implementation recipe, and the long-form Common Gotcha — lives in **`Docs/REFERENCE_FORGEKIT.md`** (fetch on demand; same `## ` headings).

## Versioning

ForgeKit uses **semantic versioning** with annotated git tags (**highest PUBLISHED git tag: `1.0.0-rc.6`, 2026-08-14**; older historical). Breaking changes expected before 1.0. **`CHANGELOG.md` is authoritative for CONTENT; the highest PUBLISHED GIT TAG is authoritative for a `from:` PIN FLOOR** (SPM resolves `from:` against tags, not the version-string). ⚠ **DRIFT (reconciled 2026-08-18):** the old "rc.5 untagged" gap is RESOLVED — `rc.5`+`rc.6` are BOTH now tagged; floor = `rc.6`. (`ForgeKitVersion.swift` lags at `rc.5` — cosmetic; SPM resolves by tag. Detail → `REFERENCE_FORGEKIT.md`.)

- **Runtime check**: `ForgeKitVersion.version` / `.major` / `.minor` / `.patch` in ForgeModels · **CHANGELOG**: `forgekit/Docs/CHANGELOG.md` · **Release**: bump `ForgeKitVersion.swift` → `CHANGELOG.md` → commit → `git tag -a X.Y.Z` → `git push origin main --tags`.

→ **Full detail (per-release changelog 0.85→0.99.1 + release housekeeping):** `Docs/REFERENCE_FORGEKIT.md` § Versioning.

### R-FORGEKIT-PIN-CONSISTENCY — the fleet converges to ONE coordinated pin floor = `from: "1.0.0-rc.6"` (highest PUBLISHED tag; re-verified 2026-08-18); the sub-rc-line cohort MUST bump (2026-07-28; floor rc.3→rc.4→rc.6, latest 2026-08-18)

> **Keep-current (iOS half of ADR-133; founder-direct 2026-08-14 "for ios too"):** the ForgeKit pin + the CLAUDE.md toolchain floor (**Xcode 26.5+ / Swift 6.3.x**) + SPM deps are kept CURRENT (latest stable) for bug fixes · security · major features, on a standing cadence. **Ownership (unchanged): the FOUNDER updates the local Xcode/Swift toolchain; HUB tracks currency (the pin census) + AUTHORS per-app bump handoffs; the app's own CC session edits its `Package.swift` — hub NEVER bumps another repo's `Package.swift` directly.** Full policy + web sibling: `Docs/ADR-133_KEEP_TOOLCHAIN_DEPENDENCIES_CURRENT.md` + `spark-anvil-website.md` § R-SITE-DEPENDENCY-CURRENCY.

**INVARIANT.** Each app pins to a single coordinated floor — the DECIDED floor is `from: "1.0.0-rc.6"` (founder-direct 2026-07-28; bumped rc.3→rc.4 2026-08-13, rc.4→rc.6 2026-08-18), the LATEST *published* pre-release tag. The floor is the **highest PUBLISHED GIT TAG, never the CHANGELOG/version-string** (SPM resolves `from:` against tags; the version-string can lag). `from: "1.0.0-rc.6"` resolves rc.6 + the `1.0.0` final + `1.x` (auto-upgrades) — so **every app pinned below the rc line (the `0.66/0.86/0.87/0.94/0.99.x` cohort) MUST move UP to `from:"1.0.0-rc.6"`** (apps already on a `from:"1.0.0-rc.N"` pin need NO change; they float up to rc.6). Prefer `from:` over `exact:`. **Hub NEVER edits an app `Package.swift`** (`portfolio.md` § R-HUB-OWNS-APP-RESOURCES) — a pin bump is authored per-app via `HANDOFF_FROM_HUB_FORGEKIT_PIN_CONSISTENCY.md`; the app's own CC session updates the manifest + runs `File > Packages > Update`. Re-verify the highest published tag (`git ls-remote --tags origin` on forgekit) at each bump.

→ **Full detail (the 51-app / 4-cohort pull-verified census + the missing-primitive list + the per-policy-line rationale):** `Docs/REFERENCE_FORGEKIT.md` § R-FORGEKIT-PIN-CONSISTENCY + `Docs/AUDIT_FORGEKIT_PIN_CONSISTENCY_2026-08-18.md` + `Docs/REGISTRY_FORGEKIT_PIN_COVERAGE.txt`.

## Source Layout (0.57.0 soft-split)

```
forgekit/Sources/
├── Client/   46 modules — UI, gameplay, persistence, on-device AI, accessibility, avatars, classroom, reflection
├── Server/   11 modules — Hummingbird 2 actors, middleware, matchmaking, email, classroom, leaderboard
└── Shared/    2 modules — ForgeModels, ForgeServerDTOs (consumed by both)
```

Public API and product names are unchanged — apps still write `.product(name: "ForgeIllustrations", package: "forgekit")` and `import ForgeIllustrations`. The split is internal-only. When reading ForgeKit source, find files with `find /Volumes/Data/Projects/GitHub/forgekit/Sources -ipath "*<ModuleName>*" -name "*.swift"`.

## Remote GitHub Dependency (Default)

`Libraries/Package.swift` uses `.package(url: "https://github.com/nathant99/forgekit.git", from: "0.99.0")` — pin to minimum version (see R-FORGEKIT-PIN-CONSISTENCY for the coordinated floor), allows multiple app workspaces open simultaneously. After a ForgeKit release, `File > Packages > Update to Latest Package Versions` in each consuming workspace. **Migration from `branch: "main"`**: replace with `from: "…"`.

### Local Development Fallback

Temporarily switch to `.package(path: "../../forgekit")` for active ForgeKit development. **Only one workspace can claim a local path dependency** — close other workspaces using ForgeKit locally. Switch back to the remote `from:` URL when done.

## Module Catalog (live total 59 modules — 46 client + 11 server + 2 shared)

**INVARIANT.** ForgeKit is 59 modules (46 client + 11 server + 2 shared — soft-split `Sources/{Client,Server,Shared}/`, live 2026-08-02; the older "58/50/49" tallies were stale). **The authoritative list is the live tree — `ls ../forgekit/Sources/{Client,Server,Shared}`** + `forgekit/Docs/CHANGELOG.md` (R-CANONICAL-DOC-GROUND-TRUTH); never quote a count from a doc. Every ForgeKit type is `public`; `ForgeModels` types are value types (apps bridge to their own `@Model`).

→ **Full detail (the full per-module purpose tables — Shared·Client·Server, incl. `ForgeMasteryEngine` / `PolyaScaffold` / `ForgeAdventure` Hub subdirectory / the Server actors + APIs):** `Docs/REFERENCE_FORGEKIT.md` § Module Catalog.

## ForgeUI Quick Reference

`ForgeTheme` protocol injected via `.environment(\.forgeTheme, MyTheme())` (theme injection is REQUIRED — `DefaultForgeTheme` applies if none). Components: `ForgePrimaryButton` · `ForgeXPBar` · `ForgeProgressBar` · `ForgeScoreHUD` · `ForgeCurrencyHUD` · `ForgeStreakBadge` · `ForgeTimerRing` · `ForgeEmptyState` · `ForgeCard` · `ForgeOnboardingFlow` · `ForgeAchievementPopup`. Feedback modifiers use `isActive:` **NOT `trigger:`** (`.correctFeedback(isActive:)` / `.incorrectFeedback(isActive:)` / `.hudOverlay(alignment:content:)`).

→ **Full detail (the `ForgeTheme` protocol body + the full init-parameter + view-modifier tables):** `Docs/REFERENCE_FORGEKIT.md` § ForgeUI Quick Reference.

## ForgeGamification Quick Reference

Pure value-type engines — callers manage persistence (except `StreakManager`, an actor — all access `async`): `XPEngine` (curves `.standard`/`.accelerated`/`.custom`) · `StreakManager` (→ `StreakResult` enum) · `AchievementEngine` · `EconomyEngine` · `SpacedRepetitionEngine` (FSRS-6) · central `GamificationConfig`.

→ **Full detail (the API snippets + `StreakResult` cases + `GamificationConfig` fields):** `Docs/REFERENCE_FORGEKIT.md` § ForgeGamification Quick Reference.

## ForgeModels Quick Reference

Foundational value types (NOT `@Model` — apps bridge): `StudentProfile` · `AchievementDefinition` · `BloomLevel` (Comparable) · `GradeLevel` · `BadgeDisplayData` · `FSRSState`.

→ **Full detail (the property + notes table):** `Docs/REFERENCE_FORGEKIT.md` § ForgeModels Quick Reference.

## ForgePedagogy — scaffolding theory alignment (R-FORGEPEDAGOGY-SCAFFOLDING; 2026-06-13)

**INVARIANT.** ForgePedagogy's `PolyaScaffold` primitives operationalize a converging developmental-psych + learning-science cluster; three alignments are load-bearing when authoring/reviewing a per-app handoff:
- **Follow-the-learner's-lead (R1)** — modules CURATE offerings the learner chooses from; they never force linear curriculum or hint-on-demand-without-articulation (the failure mode). Realized across Move-B `castCameos[]` · `CastDialog` · `ForgeKnowledgeGraph` · `ForgeMasteryEngine.NextProblemPicker` · `PolyaScaffold.hintsAllowedBeforePlan: 0`.
- **Articulate-before-hint (R3)** — `hintsAllowedBeforePlan: 0` = the learner surfaces a plan before any hint (articulation method + productive failure + desirable difficulties). Only works PAIRED with the anti-shame register (`distributed-narrative.md` § Voice register).
- **Per-cluster preset (R2)** — `.default` (Play/Practice) · `.permissive` (Create) · `.strict` (Reflect) · `.default` (Together); **ages 9-10 route to `.permissive` regardless of cluster** (cognitive-load overlay).

**When it applies:** authoring a per-app PolyaScaffold handoff (name R1/R3 + pick the R2 preset) · reviewing a CastDialog Move-D handoff (R1 test) · defending competitive position on a public surface.

→ **Full detail (the R1/R3/R2 theory tables + citations [Collins-Brown-Newman · Kapur · Bjork · Vygotsky · DIR/Floortime] + the "does NOT cover" list + cross-refs):** `Docs/REFERENCE_FORGEKIT.md` § ForgePedagogy — scaffolding theory alignment.

## Avatar system — simplified Contacts-style tint + glyph (ADR-022; supersedes the composable/accessory design)

**INVARIANT.** The avatar is `AvatarConfig` = **2 fields** (`tintIndex: Int` 0..<12 + `glyph: AvatarGlyph` = `.initial`/`.symbol`/`.emoji`), rendered by `AvatarRenderer` (`ZStack { Circle().fill(tint); glyph }`) and edited via `ForgeAvatar.AvatarStudioView` (single presentation — **never hand-roll a per-app tint/glyph picker**). Per-app identity flavor goes through `AvatarThemedGlyphProvider` + `ForgeAvatarRegistry` (a themed glyph), **NOT** bundled accessory WebPs. 🛑 **The layered-composable avatar (8 layers + accessory packs + `AvatarAssetCatalog` + `.lite`/`.full`) is RETIRED** (ADR-022 — gen models can't produce transparent/tintable layers); **do NOT generate new accessory packs**. Inert `AvatarShared/accessories/*.webp` + `avatar_accessories.json` may be `git rm`'d directly by HUB (resource-owned, R-HUB-OWNS-APP-RESOURCES; the Swift/Xcode SOURCE prohibition is unchanged).

→ **Full detail (the current-design field/renderer detail + edit-authority essentials + the retired-accessory convention + migration ref):** `Docs/REFERENCE_FORGEKIT.md` § Avatar system.

## Server `/version` endpoint (R151 #582; lifted from CuriosityQuest 2026-05-29)

**INVARIANT.** Every portfolio server MUST expose `GET /api/v1/version` (→ `{version, versionFull, branch, builtAt}`) **behind the existing `X-API-Key` middleware**, for deploy verification. 🛑 **Public `/health` MUST NOT contain build/system info** (commit SHA, OS/runtime/hardware) — CVE-2026-29787 was exactly this leak; authenticated `/version` is the right home for build metadata.

→ **Full detail (the endpoint table + the `BuildInfo.swift` placeholder + Dockerfile + route-registration recipe + per-platform env-var names + CQ reference impl):** `Docs/REFERENCE_FORGEKIT.md` § Server `/version` endpoint.

## Cast asset filename convention (DN methodology)

For apps with a DN cast bundled via `ForgeIllustrations`, cast assets MUST use a **flat-bundle filename convention** with a `cast_` prefix:

```
Packages/Libraries/Sources/AppFeature/Resources/Illustrations/
├── cast_<character_slug>_<pose>.webp
├── cast_etyma_demonstrating.webp
├── cast_lexa_thinking.webp
```

**Why**: `ForgeIllustrations.IllustrationRegistry` resolves via `Bundle.module` flat lookup (subdirectory paths fail silently); the `cast_` prefix disambiguates cast members from mascot files (`<mascot_name>_<pose>.webp`); per-character poses share the prefix so registry filtering can group by character (`registry.assets(prefix: "cast_etyma_")`). Codified per QuillSpell `HANDOFF_FROM_APP_CAST_FILENAME_CONVENTION.md` (Round 93 #479-A42, 2026-05-27). Applies to all DN-cast retrofit apps.

## Common Gotchas

- **`AvatarStudioView` requires `getOrCreateForgeID` seeding** (R489 2026-06-02) — `AppGroupStore.setAvatar(_:editedAt:)` throws `AppGroupStoreError.forgeIDMissing` (surfaces as cryptic `ForgeSync.AppGroupStoreError error 0`) unless an identity is seeded FIRST; `AvatarStudioView` calls `setAvatar` on Save, so seed via `.task { await appGroupStore.getOrCreateForgeID(...) }` before the editor opens. Hits non-ForgeSync apps hardest. → **code block + rationale:** `Docs/REFERENCE_FORGEKIT.md` § Common Gotchas — long-form.
- **`ForgeUI.CorrectFeedbackModifier`**: parameter is `isActive:`, **NOT** `trigger:`
- **All ForgeKit types are `public`** — app code imports them directly
- **`ForgeModels` types are value types** — not `@Model`. Apps create their own SwiftData models and convert to/from ForgeModels types
- **`StreakManager` is an actor** — all access is `async`
- **`XPEngine`/`EconomyEngine`/`AchievementEngine` are pure structs** — no internal state, callers manage persistence
- **Theme injection is required** — components use `@Environment(\.forgeTheme)`. Inject a custom theme at the app root or `DefaultForgeTheme` applies
- **`nonisolated` required on Sendable value types** — `InferIsolatedConformances` causes protocol conformances on value types to inherit MainActor isolation. All ForgeKit Sendable structs/enums are marked `nonisolated`. Exception: `@MainActor` SpriteKit types (`ForgeFeedback`, `ForgeCelebration`, `ForgeNodeFactory`) must NOT be `nonisolated`
- **`ForgeProgressionManager` debug bypass** — use `debugUnlockAllGates()` / `debugRestoreGateEvaluation()` for testing; constructor parameter for permanent bypass
- **ForgeKit path from `Libraries/Package.swift`** — use `../../forgekit` (two levels up), not `../forgekit`. Package.swift is inside `Libraries/`, one level deeper than the app repo root
- **Type name collisions** — qualify fully when both app modules and ForgeKit define the same type name (e.g., `Models.Expression` vs `Foundation.Expression`, `AppFeature.AppPhase` vs `ForgeNavigation.AppPhase`)
- **`@retroactive` not needed within same package** — conformances to ForgeKit protocols from targets in the same `Libraries` package are NOT retroactive. `@retroactive` in this case is a compile error
- **Fix isolation in ForgeKit, not in app code** — if a ForgeKit value type causes "call to main actor-isolated initializer in nonisolated context", mark it `nonisolated struct` IN the ForgeKit repo. Don't work around it in app code
<!-- END LABSMITH-SYNCED CONTENT -->
