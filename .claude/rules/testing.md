---
paths:
  - "**/Tests/**/*.swift"
  - "**/*Tests.swift"
  - "**/*.xctestplan"
---

# Testing Conventions

## Crash-Resilience Defaults (read first; see `test-crash-recovery.md` for agent recovery procedure)

The Xcode 26 simulator bricks on any test crash — subsequent runs fail until `xcrun simctl shutdown all && xcrun simctl erase all`. Treat test crashes as **P0** and apply these defaults preemptively to avoid them:

1. **Prefer `struct` suites** over `final class`. Class only when `deinit` cleanup is required
2. **`final class` suites with any `@MainActor`-isolated field MUST add `nonisolated deinit {}`** to avoid `swift#87316` SIGABRT in `libswift_Concurrency.dylib`
3. **Deduplicate parameterized `@Test arguments:`** — duplicate values trigger `swift-testing#1027` fatal crash. Use `zip()`, `Array(Set(...))`, or assert uniqueness in `init()`
4. **`ModelConfiguration(isStoredInMemoryOnly: true)` MUST also pass `cloudKitDatabase: .none`** — the bare initializer silently fails with `SwiftDataError._Error.loadIssueModelContainer`
5. **UserDefaults in tests MUST use `UserDefaults(suiteName: #file)` + `removePersistentDomain` in `init()`** — never `.standard`
6. **FoundationModels test paths MUST gate on availability**: `try #require(SystemLanguageModel.default.availability == .available)` OR `@Test(.disabled(if: SystemLanguageModel.default.availability != .available, "FoundationModels unavailable in CI"))`
7. **Wrap `LanguageModelSession.respond(to:)` in a timeout** — Swift 6.2 has no built-in test timeout; use `Task` + `cancel()` or a custom `withTimeout { ... }`
8. **NEVER `@unchecked Sendable`** — the #1 source of EXC_BAD_ACCESS in tests. Refactor to actor/struct/`@MainActor` instead
9. **`.serialized` requires a `// FIXME: serialized because <reason>` comment** — it's a workaround, not a fix
10. **Use launch arguments, NOT environment variables, for test configuration** — Xcode 26 regression: `ProcessInfo.processInfo.environment` returns nil for xctestplan-set env vars

## Enforcement

- Every feature requires unit tests AND UI tests — not optional
- All tests must pass before committing
- No force unwraps in tests — fail gracefully with `try #require` or `Issue.record` diagnostics
- **Test crashes are P0** — fix immediately. Recovery procedure for the in-Xcode agent: see `test-crash-recovery.md`

## Unit Tests (Swift Testing)

- Use Swift Testing framework: `import Testing`, `@Suite`, `@Test`, `#expect`, `#require`
- Use `@Suite` for grouping related tests — unique struct names (duplicates cause "invalid redeclaration")
- Prefer `try #require()` for optional unwrapping; reserve `guard case` + `Issue.record()` for enum pattern matching only
- `@MainActor` on `@Suite` serializes all tests (~50% slower) — apply to individual functions when only some tests need it
- Parameterized tests: `zip()` for paired data (1:1); separate argument lists = Cartesian product (every combination)
- When adding items to collections or enum cases, search tests for hardcoded count expectations and update them
- Never mix assertion frameworks in the same test function (`#expect` in Swift Testing, `XCTAssert` in XCTest)
- UserDefaults isolation: clear keys in setup to prevent cross-test pollution

## UI Tests (XCUIAutomation)

- UI tests: `import XCTest` + XCUIAutomation — Swift Testing cannot run UI tests
- `.accessibilityLabel()` on buttons breaks XCUITest `app.buttons["Label"]` matching — use `.accessibilityHint()` instead
- Use launch arguments to configure test state (e.g., `-hasCompletedOnboarding YES`, `-progressionSessionCount 10`)
- Batch 3-8 UI tests per call (each launches the app). Group by feature area
- `performAccessibilityAudit(for:)` for automated WCAG audits (contrast, hit targets, Dynamic Type)
- SpriteKit apps: all interactive `SKNode`s must set `isAccessibilityElement = true` and `accessibilityLabel`

## GPU-Dependent Types in Unit Tests

- **RealityKit** (`MeshResource`, `SimpleMaterial`, `TextureResource`) and **SpriteKit** (`SKView`, `SKScene.didMove(to:)`) require GPU context — they crash in unit test targets
- Test logic (state, math, algorithms) separately from rendering. Validate rendering visually via `RenderPreview` or UI tests
- **SpriteKit lazy visual setup**: Use the `configureVisuals()` pattern with `hasSetupVisuals` guard — never create child `SKShapeNode`/`SKLabelNode` in `init()`. This allows SPM test targets to instantiate and test node logic without GPU access. See `@.claude/rules/spritekit.md` for the full pattern

## MCP-First Testing Workflow

Always prefer MCP tools over `xcodebuild` when Xcode is open:

1. **`XcodeRefreshCodeIssuesInFile`** (~2s) — after every edit; catches type errors, missing imports, hallucinated APIs
2. **`ExecuteSnippet`** (~5s) — verify logic in file context. Uses Xcode project navigator paths, NOT filesystem paths
3. **`RenderPreview`** (~10s) — visually verify SwiftUI views after UI changes
4. **`RunSomeTests`** (15-60s) — suite-level specifiers: `{ testIdentifier: "SuiteName" }`. 1-3 tests for fixes, 1-5 suites for features
5. **`BuildProject`** (30-120s) — full build validation before commit
6. **`xcodebuild test` via Bash** (5-30 min) — full suite for pre-push. Always `run_in_background: true`

### Why MCP over xcodebuild

- **UI tests hang via `xcodebuild` when Xcode is open** — Xcode holds the debugger. MCP works through Xcode directly
- **`xcodebuild test` can cause build.db lock** with Xcode open — prefer MCP `RunAllTests`/`RunSomeTests`
- **Reserve `xcodebuild` for**: CI/CD (no Xcode GUI), archive builds, platform-specific destinations

### MCP Failure Recovery

- **Test failure** → `XcodeRefreshCodeIssuesInFile` on test file → fix → `RunSomeTests` on that suite
- **Build failure** → `GetBuildLog` to see errors → fix per-file → `BuildProject`
- **Cascading failures** → fix the root cause first (usually the earliest error), not downstream symptoms
- **MCP tool failure** → check `XcodeListNavigatorIssues` for workspace-level problems (package resolution, signing)
- **xcodebuild hangs** → don't retry; use MCP `RunSomeTests`/`BuildProject` instead (avoids debugger conflicts)
- **"No result" ambiguity** → Swift Testing shows "No result" on success AND on build failure. Check `counts.notRun` — if >0, the test target failed to build. Verify with `GetBuildLog` severity `error`

### MCP Result Interpretation

- Swift Testing "No result" in MCP output = 0 failures = success
- \>100 tests truncates `results` array but `summary`/`counts` are always accurate; failed tests appear first
- Full details at `fullSummaryPath`

## Swift Testing Features (Xcode 26 / Swift 6.2)

- **Attachments** (`Attachment.record(data, named:)`) — diagnostic data in test reports for post-failure inspection
- **`Issue.record("msg", severity: .warning)`** — non-fatal issues that shouldn't block CI
- **Ranged confirmations** (`confirmation(expectedCount: 5...10)`) — async event-based tests
- **Raw identifier display names** — `` @Test func `Student earns badge`() `` — backtick names become display names
- **Exit tests** (`#expect(processExitsWith: .failure)`) — **macOS/Linux only**, won't compile for iOS
<!-- END LABSMITH-SYNCED CONTENT -->
