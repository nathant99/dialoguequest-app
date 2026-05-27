# SPM Modular Architecture

> **Reorganization playbook**: For migrating an existing flat repo to the Apps/Packages/Server monorepo shape (the 2026 industry convention), see `@labsmith/Docs/PLAYBOOK_MONOREPO_REORGANIZATION.md` — authored by QuillSpell after their 5-PR migration (2026-05-17), promoted to labsmith hub 2026-05-20. Opt-in per app session.

## App Shell + Local Packages Pattern

New app repos use a thin Xcode project (app shell) with all code in a local Swift Package. Two layouts are accepted:

### Current default — flat layout (most portfolio apps)

```
[appname]-app/
├── [AppName].xcworkspace/     # OPEN THIS — standalone workspace (xcodeproj + Libraries)
├── [AppName].xcodeproj/       # Thin shell only
├── [AppName].xctestplan       # Test plan with all test targets (app + SPM)
├── [AppName]/
│   ├── [AppName]App.swift     # @main entry point — imports AppFeature
│   ├── Assets.xcassets        # App icon, accent color, texture atlases
│   └── Info.plist
├── Libraries/                 # Local Swift Package (all app code)
│   ├── Package.swift
│   ├── Sources/
│   │   ├── Models/            # Domain models, SwiftData @Model classes
│   │   ├── Services/          # Persistence, audio, networking
│   │   ├── SharedUI/          # Reusable SwiftUI components
│   │   ├── GameEngine/        # SKScene subclasses, SpriteKit logic
│   │   ├── AIMentor/          # FoundationModels @Generable types
│   │   └── AppFeature/        # Root view, navigation, app coordinator
│   └── Tests/
│       ├── ModelsTests/
│       └── ServicesTests/
├── [AppName]UITests/          # UI tests stay in app target (need app process)
├── ExportOptions.plist
├── CLAUDE.md
└── .swiftlint.yml
```

### Target shape — Apps/Packages/Server monorepo (post-reorganization)

QuillSpell migrated to this layout 2026-05-17 (5 PRs). Other apps can follow via `@Docs/PLAYBOOK_MONOREPO_REORGANIZATION.md`. The cleaner separation is best practice for repos that also ship a server (`<App>Server/`), have multiple companion apps, or have accumulated marketing-asset clutter at root.

```
[appname]-app/                 # repo root — 8 entries max
├── Apps/                      # All Xcode app targets
│   ├── [AppName]/             # App source (synchronized folder)
│   ├── [AppName].xcodeproj
│   ├── [AppName]Tests/
│   ├── [AppName]UITests/
│   └── ExportOptions.plist
├── Packages/                  # All local SPM packages
│   └── Libraries/             # Main client package (Sources/ + Tests/)
├── Server/                    # Optional backend (one SPM package per service)
│   └── [App]Server/
├── Docs/                      # Markdown docs, plans, archived design
├── Scripts/                   # Asset generators, codegen, CI helpers
├── CLAUDE.md
├── [App].xcworkspace          # References all 3 trees
└── [App].xctestplan
```

Migrate via the playbook (5 phased PRs). Not required for v1; opt-in per app session when complexity warrants.

## Key Rules

1. **One package, multiple targets** — Use a single `Libraries/Package.swift` with separate targets per module. The `package` access modifier (SE-0386) only works across targets within the same package
2. **App shell is minimal** — Only `@main` entry point, `Assets.xcassets`, `Info.plist`, and `ModelContainer` configuration. No logic
3. **Always open `.xcworkspace`** — Never open `.xcodeproj` directly. The xcodeproj's embedded workspace (`[AppName].xcodeproj/project.xcworkspace/`) only has a `self:` reference — Libraries isn't a workspace member, so `container:Libraries` in the test plan can't resolve and SPM test targets show "(missing)". The standalone `.xcworkspace` adds Libraries as a member, making the container path valid
4. **Models first** — Extract Models target first when migrating (no UI dependencies, easiest)
5. **`Bundle.module` for resources** — Package targets access resources via `Bundle.module`, not `Bundle.main`
6. **UI tests stay in app target** — `XCUITest` requires the app process; keep `[AppName]UITests/` as an Xcode test target, not in the package

## Access Control

| Level | Scope | Use For |
|---|---|---|
| `private` | Enclosing declaration | Implementation details |
| `internal` (default) | Same target | Most code within a module |
| `package` | All targets in same Package | Cross-module APIs within the app |
| `public` | External consumers (ForgeKit, app shell) | Framework APIs, types used by `@main` |

- Prefer `package` over `public` for cross-module APIs within the same app
- Types exposed to the **app shell** must be `public` — the app target is outside the Swift package
- **`public` cascades transitively**: promoting a type to `public` requires all its stored properties, initializers, and any types used in public API signatures to also be `public`
- ForgeKit types must be `public` since they're consumed by external packages

## SpriteKit in Packages

SpriteKit APIs don't accept a `bundle:` parameter. Use this workaround:

```swift
extension SKTexture {
    static func fromModule(_ name: String) -> SKTexture {
        if let image = UIImage(named: name, in: .module, compatibleWith: nil) {
            return SKTexture(image: image)
        }
        return SKTexture(imageNamed: name) // Fallback to main bundle
    }
}
```

- Texture atlases must stay in the app target's Asset Catalog (SpriteKit's `SKTextureAtlas` only searches main bundle)
- Individual sprites can use `Bundle.module` via the extension above
- `.sks` scene files: load via `Bundle.module.url(forResource:withExtension:)` + `NSKeyedUnarchiver`

## SwiftData in Packages

- `@Model` classes work in SPM targets — mark initializers and properties `public`
- Configure `ModelContainer` in the **app shell** (`@main` struct), not inside the package
- Known issues: naming conflicts with `Observation` types, custom build configs break macros
- See `@.claude/rules/swiftdata.md` for full patterns

## FoundationModels in Packages

- `@Generable` structs work in SPM targets — mark all properties and the struct `public`
- `LanguageModelSession` stays in the AIMentor target (lazy init, reuse across calls)
- Availability check (`SystemLanguageModel.default.availability`) in the AIMentor target

## External SPM Dependencies (ForgeKit)

External dependencies (ForgeKit, etc.) are **only declared in `Libraries/Package.swift`** via `.package(path:)` or `.package(url:)`. Never add them to the xcodeproj or workspace:

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Adding external dep to `.xcworkspace` as member | Duplicate target warnings, ambiguous type errors | Remove — SPM resolves it through Libraries |
| Adding external dep as project-level package in xcodeproj | Linker errors, duplicate symbols | Remove — `Libraries/Package.swift` is the single source of truth |

Xcode resolves external dependencies transitively through SPM's dependency graph when building the Libraries package. The app shell gets ForgeKit types through Libraries targets — no direct reference needed.

## Build Settings in SPM

Xcode build settings (`SWIFT_DEFAULT_ACTOR_ISOLATION`, `SWIFT_APPROACHABLE_CONCURRENCY`) do **not** propagate to SPM package targets. Set them via `swiftSettings` in `Package.swift`:

```swift
let defaultSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .unsafeFlags(["-default-isolation", "MainActor"]),
    .enableExperimentalFeature("NonisolatedNonsendingByDefault"),
]

// Apply to EVERY target:
.target(name: "Models", dependencies: [...], swiftSettings: defaultSwiftSettings),
.testTarget(name: "ModelsTests", dependencies: ["Models"], swiftSettings: defaultSwiftSettings),
```

Missing this causes `@Model` macro expansion failures and actor isolation mismatches between app shell and package targets.

**`swift-tools-version` must match platform availability** — `.iOS(.v26)`, `.macOS(.v26)`, `.visionOS(.v26)` require `swift-tools-version: 6.2` (not `6.0`). Using `6.0` with `.v26` platforms causes `'v26' is unavailable` and Xcode shows the package as a plain folder instead of recognizing it as a Swift Package.

## Testing in Packages

### Testables + Workspace Pattern

SPM test targets are integrated via the scheme's `<Testables>` section. An Xcode-managed `.xctestplan` (edited only through the Xcode GUI — Product → Scheme → Edit Scheme → Test → Test Plans) is also supported and works fine. The failure mode the gotchas section warns about is **hand-edited** plan JSON, not the file format itself. Either path is fine; the `<Testables>` pattern below is what this section documents:

1. **`[AppName].xcworkspace`** — standalone workspace containing both `[AppName].xcodeproj` and `Libraries/` as workspace members. Required for `container:Libraries` to resolve
2. **`[AppName].xcscheme`** — `<TestAction>` with `shouldAutocreateTestPlan = "YES"` and `<Testables>` listing all test targets. SPM targets use `ReferencedContainer = "container:Libraries"`

### Adding New Package Test Targets

1. Add `.testTarget()` in `Package.swift` with `swiftSettings: defaultSwiftSettings`
2. Create the test directory with at least one `.swift` file (empty directories are invisible to Xcode)
3. Add a `<TestableReference>` to the scheme's `<Testables>` section (edit with Xcode closed):
```xml
<TestableReference
   skipped = "NO"
   parallelizable = "YES">
   <BuildableReference
      BuildableIdentifier = "primary"
      BlueprintIdentifier = "NewTargetTests"
      BuildableName = "NewTargetTests"
      BlueprintName = "NewTargetTests"
      ReferencedContainer = "container:Libraries">
   </BuildableReference>
</TestableReference>
```
4. Build (Cmd+B) to trigger test discovery

### Gotchas

- **`swift test` CLI fails with SwiftData** — the `@Model` macro plugin is only available through Xcode's build system. Use MCP `RunAllTests`/`RunSomeTests` or `xcodebuild test` instead
- **`swift test` CLI fails with Swift Testing** — the Testing framework requires Xcode's build system. Always use MCP tools or `xcodebuild test`
- **Empty test target directories are invisible** — if a test target declared in `Package.swift` has no source files on disk, Xcode silently omits it from the test navigator
- **Empty SPM resource directories fail codesign** — if `Package.swift` declares a `.process("Resources")` rule pointing at an empty (or only-`.gitkeep`-containing) directory, the SPM build assembles a malformed bundle. Code signing rejects it with `bundle format unrecognized, invalid, or unsuitable`. Mitigation: every resource directory referenced by `Package.swift` MUST contain at least one **real** resource file (a 1-byte `.txt` placeholder OR a meaningful resource). `.gitkeep` files are not enough — SPM's resource scanner ignores dotfiles. Codified per Round 93 #479-A15 (creaturecare Phase 1 kickoff hit this; scaffold template now lands placeholder `.json` per target on first commit)
- **Scheme editing safety** — Xcode must be closed when editing `.xcscheme` files on disk. Xcode caches these in memory and overwrites disk changes on save. If Xcode is open when you edit, the in-memory cache diverges and Xcode may overwrite your changes OR corrupt the file. Recovery: close Xcode completely, write the corrected file (or `git checkout` it), then reopen Xcode
- **`.xctestplan` files — tracking is canonical; hand-editing is forbidden.** **Track the Xcode-generated `<App>.xctestplan` in git** — Xcode 26 auto-promotes `shouldAutocreateTestPlan = "YES"` to a real file the first time the workspace runs a test action, generating a sibling `<App>.xctestplan` at repo root and rewriting the scheme to point at it via `<TestPlans><TestPlanReference reference="container:../<App>.xctestplan" ...></TestPlans>`. The auto-generated file has the correct container paths and is what every portfolio app repo ships. **Commit it; do not gitignore it.** Confirmed working across all 131 app repos (CuriosityQuest PR #59, 2026-05-20). What's *forbidden* is **hand-editing the JSON content** — directly editing the plan JSON is fragile because valid JSON can become unreadable by both Xcode and `xcodebuild` after cache corruption, with no clear recovery path. If you need to change the plan, edit it via the Xcode GUI (Product → Scheme → Edit Scheme → Test → Test Plans) so Xcode regenerates the JSON, OR delete the file and rely on the scheme's `<Testables>` with `shouldAutocreateTestPlan = "YES"` to regenerate it on next test run. **Agent-specific**: the Claude agent operates from inside Xcode and must never *write* `.xctestplan` JSON content from disk; tracking the file Xcode produces is fine. See `@.claude/rules/xcode-agent-safety.md`.
- **`xcode-select` must point to Xcode.app** — if `xcode-select -p` returns `/Library/Developer/CommandLineTools`, SPM manifest compilation uses the old Swift toolchain and silently fails on `swift-tools-version: 6.2` / `.v26` platforms. Fix: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`. Once Xcode caches the "folder" determination, it persists across restarts — you must also nuke `Libraries/.swiftpm/`, DerivedData, remove the workspace entry, reopen, and re-add via File > Add Package Dependencies > Add Local
- **Xcode caches "folder" for failed packages** — if a local package fails initial resolution (wrong toolchain, bad dependency, invalid manifest), Xcode caches it as a plain folder. Fixing the manifest alone won't help. Must: close Xcode, delete `Libraries/.swiftpm/` + DerivedData, remove from workspace, reopen, re-add via File > Add Package Dependencies > Add Local
- **CLI `.build/` conflicts with Xcode** — running `swift build` in the Libraries directory creates `.build/` artifacts that prevent Xcode from loading the package. Fix: delete `Libraries/.build/` and do File > Packages > Reset Package Caches
- **Remote dependencies can block package loading** — if a remote dependency fails to resolve, the entire package fails to load in Xcode and no products are available. Remove or temporarily disable the problematic dependency to unblock. **SwiftLintPlugins is currently suspended** (crashes on Xcode 26) — must be commented out in all `Package.swift` files
- **Cannot edit `.pbxproj` while Xcode is open** — a system hook blocks direct edits. Use Xcode GUI for project file changes (adding frameworks, targets, etc.)
- **Adding AppFeature to app target** — must be done via Xcode GUI: Target > General > Frameworks > + > AppFeature. Two entries may appear (product and target) — select the product
- **ForgeKit path from `Libraries/Package.swift`** — ForgeKit is TWO levels up (`../../forgekit`), not one (`../forgekit`). Package.swift is inside `Libraries/`, one level deeper than the app repo root
- **ForgeKit type name collisions** — when importing both app Models and a ForgeKit module that defines the same type name, always fully qualify (e.g., `Models.Expression`, `ForgeNavigation.AppPhase`). Compiler says "ambiguous" — fix by qualifying in all files importing both
- **`@retroactive` not needed within same SPM package** — conformances across targets in the same `Libraries` package are NOT retroactive. Using `@retroactive` is a compile error
- **`AppIntent` protocol and `package` access** — `AppIntent` requires all conformance members to match the struct's access level. Making intent structs `package` means ALL protocol members must be `package` (verbose). Keep intent structs `internal` and use `@testable import` in tests
- **Pre-App Store: don't create new `VersionedSchema` for unreleased models** — add new `@Model` classes directly to the existing schema version. Creating V2 crashes dev devices with existing data. Only create a new `VersionedSchema` for the first App Store release that changes existing model fields
- **SPM target names must be globally unique** — SPM flattens all target names across the entire dependency graph (including transitive deps). If your target name collides (e.g., `Models` vs `swift-transformers.Models`), rename your target (e.g., `CQModels`) and use `path:` to keep the directory name unchanged. The product name can differ from the target name — use `.library(name: "Models", targets: ["CQModels"])` so the xcodeproj links against `Models` while the module imports as `CQModels`
- **Swift doesn't synthesize public memberwise initializers** — when promoting structs/DTOs to `public`, you must add explicit `public init(...)` for every struct. The compiler error is misleading ("extra argument" or "missing argument for parameter 'from:'")
- **`nonisolated` required on public value types in SPM packages with default MainActor** — Public structs/enums in a package with `-default-isolation MainActor` inherit MainActor isolation. When consumed by the app test target, `#expect` macro expansions generate nonisolated closures that can't access MainActor-isolated properties. Fix: mark all public Sendable structs/enums as `nonisolated`. Exceptions: `@Model` classes (need MainActor), `VersionedSchema`/`SchemaMigrationPlan` conformers, and types with `Color`-creating computed properties

### Access & Imports

- Use `@testable import Models` in test targets for internal access
- Alternative: use `package` access level to avoid needing `@testable`
- Test resources go in `Tests/[Target]Tests/` with `.process("TestData")` in Package.swift
- **Type ambiguity from dual imports** — when a test file imports both `@testable import AppTarget` and `import CQModels`, types from CQModels are visible through both paths with potentially different actor isolation. Compiler says "ambiguous use of init". Fix: qualify with `CQModels.TypeName(...)` or remove the redundant import
- **`nonisolated` on Codable/Sendable value types in Services** — public structs/enums with `Codable`, `Sendable`, `Equatable`, or `Error` conformances in a package with `-default-isolation MainActor` inherit MainActor isolation. This breaks when the types are decoded/encoded from nonisolated contexts. Fix: mark these types `nonisolated public struct/enum`. Exception: types that access MainActor-isolated services must stay MainActor
- **`@Observable` classes need explicit `public init()`** — classes with default property values rely on a synthesized `internal init()`. When the class is `public`, the synthesized init remains `internal`. Add explicit `public init() {}` to every public `@Observable` class that uses the default parameterless init

## Migration Path (Existing Repos)

Incremental "strangler fig" approach — don't rewrite, gradually extract:

1. Create `Libraries/Package.swift` shell with no targets
2. Extract `Models/` target (move model files, add `public` as needed)
3. Extract `Services/` (depends on Models)
4. Extract `SharedUI/` (depends on Models)
5. Extract `GameEngine/` (depends on Models, has SpriteKit resources)
6. Extract `AppFeature/` (depends on everything, root coordinator)
7. Thin the app target to shell-only

Each step is a single PR. App builds and tests must pass at every step.
