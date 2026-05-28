# Build & Test Optimization

## Compilation Caching (Xcode 26+)

Enable in build settings: `COMPILATION_CACHE_ENABLE_CACHING = YES`. Caches Swift/Clang compilation results across clean builds and branch switches.

**Not cacheable**: Run Script phases, linking (`Ld`), storyboard/xib compilation. These always re-run.

## Explicitly Built Modules

Default in Xcode 26 (`SWIFT_EXPLICITLY_BUILT_MODULES = YES`). Each system module (Foundation, SwiftUI, SpriteKit, SwiftData) compiles exactly once per build instead of once per file.

## Debug Build Settings

| Setting | Value | Why |
|---|---|---|
| `ONLY_ACTIVE_ARCH` | `YES` | Skip x86_64, build arm64 only |
| `SWIFT_OPTIMIZATION_LEVEL` | `-Onone` | Fastest compilation |
| `DEBUG_INFORMATION_FORMAT` | `dwarf` | Skip dSYM generation |
| `SWIFT_COMPILATION_MODE` | `incremental` | Recompile only changed files |
| `DEAD_CODE_STRIPPING` | `NO` | Skip dead code analysis |

## Release Build Settings

| Setting | Value | Why |
|---|---|---|
| `ONLY_ACTIVE_ARCH` | `NO` | Build all architectures |
| `SWIFT_OPTIMIZATION_LEVEL` | `-O` | Full optimization |
| `DEBUG_INFORMATION_FORMAT` | `dwarf-with-dsym` | dSYMs for crash reporting |
| `SWIFT_COMPILATION_MODE` | `wholemodule` | Cross-file optimization |
| `DEAD_CODE_STRIPPING` | `YES` | Remove unused code |
| `STRIP_SWIFT_SYMBOLS` | `YES` | Reduce binary size |

## Type-Check Performance

The Swift type checker is the #1 incremental build bottleneck. Keep expressions simple:

- **Long SwiftUI modifier chains** → split into computed properties
- **Large struct literals with closures** → pre-compute arrays as local `let`
- **`#Predicate` macros inline** → extract to separate `let predicate = ...`
- **Chained operators** (`a + b + c + d`) → break into intermediate bindings
- **Rule of thumb**: >3 chained method calls or >5 closure arguments → break it up

Diagnose with: `OTHER_SWIFT_FLAGS = -Xfrontend -warn-long-function-bodies=100 -Xfrontend -warn-long-expression-type-checking=100` (remove for production — adds overhead).

## Test Speed Hierarchy

Use the fastest tool that covers your test scope:

| Method | Time | Use When |
|---|---|---|
| `XcodeRefreshCodeIssuesInFile` | ~2s | After every edit — catches type errors |
| `ExecuteSnippet` | ~5s | Verify logic in file context |
| `swift test` in Libraries/ | ~0.4s | Pure model/service logic (no SwiftData, no GPU) |
| MCP `RunSomeTests` | 15-60s | Tests needing SwiftData, app context, or UI |
| MCP `BuildProject` | 30-120s | Full build validation before commit |
| `xcodebuild test` | 5-30 min | Full suite, CI, pre-push (always `run_in_background`) |

**`swift test` limitations**: Fails with `@Model` (macro plugin needs Xcode build system), some Swift Testing configurations, and GPU-dependent types.

## SPM Parallelism

Keep target dependency edges minimal. If `SharedUI` doesn't use `Services`, don't declare the dependency. Fewer edges = more parallel compilation.

## xcconfig Files

Prefer `.xcconfig` over Xcode GUI build settings — version-controlled, diffable, no `.pbxproj` merge conflicts. Layer as: `Common.xcconfig` → `Debug.xcconfig` / `Release.xcconfig` → per-target overrides. See labsmith `Configs/` for templates.

## Build Timing Summary

Diagnose slow builds:
- **Xcode GUI**: Product > Perform Action > Build With Timing Summary
- **CLI**: `xcodebuild -showBuildTimingSummary`

## CI Pipeline Order

1. Checkout + Resolve Packages (cached)
2. Build (compilation cache enabled)
3. Lint (SwiftLint — currently suspended on Xcode 26; skip this step)
4. Unit tests (`swift test` for pure logic, `xcodebuild test` for SwiftData/UI)
5. UI tests (`-parallel-testing-enabled YES -parallel-testing-worker-count 4`)
6. Archive (release config, wholemodule)

## Common Mistakes

- **Concurrent `xcodebuild` commands** lock the build database — never run two in parallel against the same DerivedData
- **`swift test` CLI** creates `.build/` artifacts that conflict with Xcode — delete `Libraries/.build/` if Xcode can't load the package
- **SwiftLint build plugin** — currently suspended (crashes on Xcode 26). Must be commented out in all `Package.swift` files. See `.claude/rules/swiftlint.md`
- **Missing `-warn-long-*` cleanup** — these flags add overhead; only enable during investigation, remove after fixing bottlenecks
<!-- END LABSMITH-SYNCED CONTENT -->
