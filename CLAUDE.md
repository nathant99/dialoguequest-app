# DialogueQuest

Branching-dialogue craft workshop for tweens. Write a conversation, not a paragraph: each line scored for voice consistency, subtext, tag balance, and branch meaningfulness.

> **Deeper context**: `@Docs/TECHNICAL_DESIGN.md` (architecture), `@Docs/FEATURE_PLAN.md` (in-flight work), `@Docs/IMPLEMENTATION_HANDOFF.md` (handoff state), `@Docs/APP_SPECIFIC_NOTES.md` (preserved prior CLAUDE.md content). Portfolio-wide rules auto-load from `@.claude/rules/`.

## Xcode Agent Safety (load-bearing)

This agent operates inside Xcode via the Coding Assistant integration. **Do NOT author or edit Xcode-managed files** (`*.xcodeproj/project.pbxproj`, `*.xcworkspace/contents.xcworkspacedata`, `*.xcscheme`, `*.xctestplan`, `*.xcassets/Contents.json`, `Info.plist`, `*.entitlements`, `xcuserdata/`). Editing them risks External-Changes dialogs or a workspace reload that **terminates the agent session mid-task**.

- Staging + committing these files via git is **allowed** (the rule is about file-content edits, not git ops).
- For Xcode-GUI-bound work (adding SPM package to the workspace, target dependency changes, capability/entitlement edits, scheme creation, asset-catalog Contents.json regen), file `Docs/HANDOFF_TO_USER_XCODE_WIRING.md` (or a topical variant) describing the exact GUI steps.
- For source code, prefer `Libraries/Sources/<Target>/*.swift` (SPM auto-discovers — no project edit). When an app-shell file must change, route through MCP `XcodeUpdate` / `XcodeWrite`, not filesystem `Write`/`Edit`.

Full rule: `@.claude/rules/xcode-agent-safety.md`.

## Tech Stack

- **Language**: Swift 6 (strict concurrency)
- **UI**: SwiftUI
- **AI**: FoundationModels (on-device)
- **Persistence**: SwiftData
- **Testing**: Swift Testing (`@Test`, `#expect`)
- **Min Target**: iOS 26 / Xcode 26
- **Architecture**: App shell + local Swift Package (`Libraries/Package.swift`)
- **Framework**: ForgeKit (pinned via `.package(url:, from: "0.99.0")`)

Portfolio-wide tech stack rules live in `@.claude/rules/forgekit.md` + `@.claude/rules/concurrency.md` + `@.claude/rules/swiftui.md` + `@.claude/rules/swiftdata.md` + `@.claude/rules/spritekit.md` + `@.claude/rules/foundationmodels.md`. All auto-load with this file.

## Commands

```bash
# Build (iOS Simulator)
xcodebuild -workspace DialogueQuest.xcworkspace -scheme DialogueQuest \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# Tests
xcodebuild test -workspace DialogueQuest.xcworkspace -scheme DialogueQuest \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Prefer MCP `BuildProject` / `RunSomeTests` over `xcodebuild` when Xcode is open (per `@.claude/rules/workflow.md` § "MCP-First Testing Workflow").

## App-Specific Conventions

See `@Docs/APP_SPECIFIC_NOTES.md` for the preserved prior CLAUDE.md content (architecture / domain patterns / gotchas accumulated through development). Portfolio-wide rules — Swift 6 concurrency, SwiftData patterns, testing conventions, ForgeKit module APIs, Liquid Glass register, distributed-narrative methodology, trauma-informed gates, COPPA / age-assurance — auto-load from `@.claude/rules/` (24+ files synced from labsmith). Do NOT re-state portfolio-wide rules here.

## SPM Scaffold (as of 2026-06-19)

5-target Libraries package per `@Docs/TECHNICAL_DESIGN.md` § "SPM Module Architecture":

```
Libraries/
├── Package.swift                    # swift-tools 6.2, .iOS(.v26), -default-isolation MainActor
├── Sources/
│   ├── Models/                      # DialogueNode / DialogueTree / DialogueTag / DialogueMood / DialogueCharacterRef
│   ├── Services/                    # (stub — Phase 1 services land in follow-on PR)
│   ├── SharedUI/                    # DialogueQuestTheme + MentorBubbleView + DialogueTreeBuilderPlaceholder
│   ├── AIMentor/                    # PatterMentor + 3 @Generable types + PatterFallbacks
│   └── AppFeature/                  # RootView (4-tab TabView) + AppNavigationMachine + tab placeholders
└── Tests/
    ├── ForgeKitIntegrationTests/    # 5 sanity tests
    └── ModelsTests/                 # 14 tests across the 5 value types
```

ForgeKit pin: `from: "0.99.0"`. Per-target wiring documented in `@Docs/IMPLEMENTATION_HANDOFF.md` § 7.

## Things That Will Bite You

Specific to DialogueQuest. Portfolio-wide bites live in `@.claude/rules/`; the entries here are *only* the DialogueQuest-specific gotchas.

- **Add `Libraries` to the workspace via Xcode GUI, not the agent** — the agent can author `Libraries/Package.swift` but cannot add it to `DialogueQuest.xcworkspace` per `@.claude/rules/xcode-agent-safety.md`. Follow `@Docs/HANDOFF_TO_USER_XCODE_WIRING.md` Step 1.
- **`AppFeature` depends on `Models` + `Services` + `SharedUI` + `AIMentor`** — adding the dep on the app target via Xcode GUI is Step 2 of the wiring handoff. Forgetting it produces "No such module 'AppFeature'" when the app shell tries to import.
- **`swift-tools-version: 6.2` is REQUIRED** — `.iOS(.v26)` won't load with 6.0. If Xcode shows `Libraries` as a folder instead of a Swift Package, the wrong tools version is the first thing to check.
- **All public Sendable types must be `nonisolated public struct/enum`** — `InferIsolatedConformances` makes Codable conformance MainActor-isolated by default; tests in nonisolated contexts break. Codable conformance must be declared on the type itself, not via extension.
- **`PatterMentor` lazy session** — `LanguageModelSession` is created on first use + reused. The `@ObservationIgnored private lazy var session` form is required because `@Observable` can't track lazy storage (per `@.claude/rules/warnings.md`).
- **No SpriteKit, no SceneKit, no AnyView** — DialogueQuest is pure SwiftUI; the tree editor uses `Canvas` not SKScene. No `GameEngine` SPM target.

## Reference Documents

- `@Docs/TECHNICAL_DESIGN.md` — architecture, state machines, domain model
- `@Docs/IMPLEMENTATION_HANDOFF.md` — labsmith-shipped implementation context
- `@Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` (or `_ENHANCEMENT.md`) — cast + curricular embedding
- `@Docs/APP_SPECIFIC_NOTES.md` — content preserved from prior CLAUDE.md (pre-v2)
- `@.claude/rules/` — portfolio-wide rules (24+ auto-loaded files)
