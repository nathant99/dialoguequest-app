---
paths:
  - "**/*.swift"
---

# SwiftLint Conventions

## Status: SUSPENDED — but re-pilot pending (0.65.0 looks like the fix; 2026-07-13)

SwiftLintPlugins (SimplyDanny/SwiftLintPlugins) crashed on the **Xcode 26 beta** cycle (illegal-instruction / sourcekitdInProc loading failure, betas 6–7 mid-2025), which prompted the suspension. The `.package(url:)` dependency and all `.plugin()` references stay **commented out** in every `Libraries/Package.swift` until the re-pilot below confirms a clean resolve.

**The suspension now looks obsolete.** SwiftLint has stayed on a steady release cadence through the Xcode 26 era — `0.63.x` → **0.65.0 (2026-07-06)** — tracking Swift 6.3-generation swift-syntax. **Re-pilot required before lifting** (see `Docs/DECISION_SWIFTLINT_UNSUSPEND_REPILOT_2026-07-13.md`): 0.65.0 via SwiftLintPlugins on ONE low-risk app through a full DoD cycle. **One caveat** — SwiftLint currently pins a *prerelease* swift-syntax (`604.0.0-prerelease`), which forfeits Xcode 26's pre-built swift-syntax cache and forces co-resident swift-syntax dependents onto the same prerelease (a clean-build-time + dependency-graph consideration for ForgeKit-adjacent packages, tracked upstream). If that pin conflicts with ForgeKit's graph, prefer the **standalone binary** over the build-tool plugin.

**Do NOT re-enable portfolio-wide** without first verifying the new version resolves cleanly on Xcode 26 (an unresolvable SwiftLint dependency prevents the entire Libraries package from loading — Xcode caches it as a folder instead of a Swift Package). Lift the suspension in this file's status + `CLAUDE.md` + `REFERENCE_TECH_STACK` only after the pilot passes.

The `.swiftlint.yml` config files remain in repos for when SwiftLint is re-enabled. The coding standards below still apply — enforce them manually during code review.

## Setup (When Re-Enabled)

- Use **SimplyDanny/SwiftLintPlugins** (NOT `realm/SwiftLint`) as SPM build tool plugin
- `.swiftlint.yml` in project root — derived from hub `Configs/.swiftlint_base.yml`
- Run SwiftLint as SPM plugin in the local `Libraries/` package, NOT as Xcode build phase

## Rules That Are Errors (Never Bypass)

- **`force_unwrapping`** — Use `guard let`, `if let`, or `??`
- **`force_cast`** — Use `as?` with guard/if let
- **`force_try`** — Use `try?` or `do/catch`
- **`no_combine_import`** — Async/await only
- **`no_scenekit_import`** — Deprecated WWDC 2025
- **`no_any_view`** — Use `@ViewBuilder`, `Group`, or conditional modifiers
- **`no_unchecked_sendable`** — Fix isolation properly
- **`private_swiftui_state`** — `@State` must be `private`

## Rules That Are Warnings (Fix When Practical)

- **`no_parameterless_animation`** — Use `.animation(.default, value:)`
- **`no_accessibility_label_on_buttons`** — Use `.accessibilityHint()` instead
- **`no_uiscreen_main`** — Use `UITraitCollection.current.displayScale`
- **`no_query_in_views`** — Use `modelContext.fetch()` in `onAppear`

## Suppressing Rules

- Use `// swiftlint:disable:next rule_name` for single-line suppression with a comment explaining WHY
- Never use blanket `// swiftlint:disable` without a matching `// swiftlint:enable`
- If suppressing `force_unwrapping`, document the safety proof (e.g., "guaranteed non-nil by Bundle resource")

## Known False Positives

- `@Observable`, `@Model`, `@Generable`, `@Test` macros generate invisible code — SwiftLint may flag issues in macro-expanded code it can't see
- `orphaned_doc_comment` fires on comments above macro-annotated declarations
- `redundant_sendable` auto-correct can produce invalid syntax (hanging commas) — fix manually
- `async_without_await` falsely flags `@MainActor async` methods that don't contain explicit `await`

## Baseline Adoption

For existing repos with many violations, use SwiftLint's baseline feature:
```bash
swiftlint lint --reporter baseline > .swiftlint.baseline.yml
```
This suppresses all existing violations. New code must comply. Fix baseline violations incrementally.
<!-- END LABSMITH-SYNCED CONTENT -->
