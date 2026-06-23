# DialogueQuest

Branching-dialogue craft workshop for tweens. Write a conversation, not a paragraph: each line scored for voice consistency, subtext, tag balance, and branch meaningfulness.

> **Deeper context**: `@Docs/TECHNICAL_DESIGN.md` (architecture), `@Docs/FEATURE_PLAN.md` (in-flight work), `@Docs/IMPLEMENTATION_HANDOFF.md` (handoff state), `@Docs/APP_SPECIFIC_NOTES.md` (preserved prior CLAUDE.md content). Portfolio-wide rules auto-load from `@.claude/rules/`.

## Xcode Agent Safety (load-bearing)

> **Single-page reaffirmation** of this section + the canonical SPM subfolder map: `@Docs/HANDOFF_AGENT_SAFETY_RECONFIRMED.md` (last reaffirmed 2026-06-22 mid-session). Read once before touching the repo. **Staging + committing GUI-authored diffs IS allowed** — the "do not write" rule applies to AUTHORING content only.

This agent operates inside Xcode via the Coding Assistant integration. **Do NOT author or edit Xcode-managed files**. Editing them risks External-Changes dialogs or a workspace reload that **terminates the agent session mid-task**.

**Most-bitten subset** (call out explicitly — these are the ones repeatedly forgotten):
- **The Xcode workspace file** (`DialogueQuest.xcworkspace/**` — contents.xcworkspacedata + xcshareddata + xcuserdata)
- **Scheme files** (`*.xcscheme` — including the shared scheme at `DialogueQuest.xcodeproj/xcshareddata/xcschemes/DialogueQuest.xcscheme`)
- **The test-plan file** (`DialogueQuest.xctestplan` at repo root — Xcode 26 auto-generates this; track it in git but never hand-edit its JSON)

For any change to these: **file a `Docs/HANDOFF_TO_USER_<TOPIC>.md` with explicit Xcode GUI steps**. The user does the GUI work. The agent's role is to (a) author the handoff and (b) stage + commit the resulting GUI-authored diff afterward.

**Forbidden file globs** (write-only — git stage/commit is fine):

| Glob | Owned by |
|---|---|
| `*.xcodeproj/project.pbxproj` + `*.xcodeproj/project.xcworkspace/**` | Xcode project editor |
| `DialogueQuest.xcworkspace/contents.xcworkspacedata` + `DialogueQuest.xcworkspace/xcshareddata/**` + `DialogueQuest.xcworkspace/xcuserdata/**` | Xcode workspace editor |
| `*.xcscheme` (anywhere) | Xcode scheme editor |
| `*.xctestplan` (incl. `DialogueQuest.xctestplan` at repo root) | Xcode test plan editor |
| `*.xcassets/Contents.json` + `*.imageset/Contents.json` | Xcode asset catalog editor |
| `Apps/DialogueQuest/DialogueQuest/Info.plist` | Xcode target editor |
| `*.entitlements` | Xcode capabilities editor |
| `*.xcdatamodeld/**` | Xcode data model editor |
| `xcuserdata/**` (anywhere) | Xcode (local per-user) |
| `**/.swiftpm/**` | Xcode SPM cache |
| `Package.resolved` | SPM resolution |

**Safe escape hatches**:

- **SPM source**: `Libraries/Sources/<Target>/**/*.swift` and `Libraries/Tests/<Target>Tests/**/*.swift` — auto-discovered; agent uses `Write`/`Edit` freely.
- **Docs / config**: `*.md`, `.gitignore`, `Resources/**/*.{json,yaml,png,webp,caf,lottie}`, `Scripts/*.{py,sh}` — always safe.
- **App-shell `.swift` files** (`Apps/DialogueQuest/DialogueQuest/**/*.swift`): use MCP `XcodeWrite` / `XcodeUpdate`, NOT filesystem `Write`/`Edit`. Synchronized-folder targets (Xcode 16+) tolerate filesystem writes, but routing through MCP is the canonical-safe path.
- **`Libraries/Package.swift`**: editable but watch out — Xcode triggers package re-resolution on save. Land in isolated commits, never bundle with multi-file changes.
- **GUI-bound work** (workspace membership, target deps, capabilities, entitlements, scheme + test-plan edits, asset-catalog regen, Info.plist usage descriptions): file `Docs/HANDOFF_TO_USER_<TOPIC>.md` with exact GUI steps. The user does it; the agent doesn't.

**Staging + committing Xcode-managed files IS allowed**: the "do not write" rule applies to AUTHORING content, not to `git add` / `git commit` of GUI-authored diffs. When the user completes Steps 1–4 of an Xcode-wiring handoff, the agent's responsibility is to stage + commit the resulting `pbxproj` / `xctestplan` / `xcscheme` diff. Refusing to commit would block the handoff loop. See `@.claude/rules/xcode-agent-safety.md` § "Staging + committing Xcode-managed files IS allowed" for the full carve-out.

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

## SPM Scaffold (as of 2026-06-22)

5-target Libraries package per `@Docs/TECHNICAL_DESIGN.md` § "SPM Module Architecture":

```
Libraries/
├── Package.swift                    # swift-tools 6.2, .iOS(.v26), -default-isolation MainActor
├── Sources/
│   ├── Models/                      # Schema/ + ValueTypes/ — domain types + SwiftData @Model classes
│   ├── Services/                    # Analytics/ Analyzers/ Gamification/ Pedagogy/ Persistence/ Privacy/ Reporting/ Sensory/ Spotlight/ — Phase 1+2 services
│   ├── SharedUI/                    # DialogueQuestTheme + Mentor/MentorBubbleView (lean; rich UI lives in AppFeature)
│   ├── AIMentor/                    # PatterMentor + Generables/ + Fallbacks/ + CastVoicing/
│   └── AppFeature/                  # RootView + 17 feature subfolders (Tabs/ Builder/ Inspector/ Panels/ Dashboard/ Mentor/ Onboarding/ Adventure/ Crucible/ Intents/ Quiz/ Anthology/ Progress/ Profile/ Settings/ Welcome/ Parents/ Together/) + Resources/
└── Tests/
    ├── ForgeKitIntegrationTests/    # ForgeKit availability sanity tests
    ├── ModelsTests/                 # value-type Codable + analyzers
    ├── ServicesTests/               # analyzer + service unit tests
    ├── AIMentorTests/               # PatterFallbacks + CastVoice* tests
    └── AppFeatureTests/              # machine + view-model tests
```

ForgeKit pin: `from: "0.99.0"`. Per-target wiring documented in `@Docs/IMPLEMENTATION_HANDOFF.md` § 7.

## SPM File Layout Convention (load-bearing)

Per `@.claude/rules/spm-architecture.md`. Each SPM target's source files live under `Libraries/Sources/<Target>/`. When a target exceeds ~5 files, **organize into subfolders by responsibility**, not by Swift file kind. Tests mirror the source folder shape.

Canonical subfolder taxonomy used in DialogueQuest (apply when adding new files):

```
Libraries/Sources/Models/
├── Models.swift                          # target marker
├── Schema/                               # @Model classes + VersionedSchema + MigrationPlan
├── ValueTypes/                           # nonisolated Sendable structs/enums
└── (no UI deps anywhere in Models)

Libraries/Sources/Services/
├── Services.swift                        # target marker
├── Analytics/                            # RetentionMetricsService + DialogueQuestAnalytics (ForgeAnalytics wrapper)
├── Analyzers/                            # BranchMeaningfulnessScorer + VoiceConsistencyAnalyzer + TagBalancer + TriangleDynamics
├── Gamification/                         # DialogueQuestGamification + StreakService + AchievementService
├── Pedagogy/                             # DDAEngine + DialogueScaffoldingService + ReturnLoopService + SessionTimerService + VariableReward + PatterCallbackService + MasteryMomentService + DialogueCraftSkillGraph (ForgeKnowledgeGraph DAG)
├── Persistence/                          # DialoguePersistenceService + helpers
├── Privacy/                              # ParentalConsentService + ParentalGateChallenge + DeclaredAgeRangeGate + CrisisResourcesProvider
├── Reporting/                            # DialogueQuestProgressReportBuilder (ForgeReporting StudentReportData projection)
├── Sensory/                              # DialogueSensoryService (ForgeSensory wrapper)
└── Spotlight/                            # AnthologySpotlightIndexer (ForgeSpotlight wrapper)

Libraries/Sources/SharedUI/
├── DialogueQuestTheme.swift              # palette + ForgeTheme conformance
└── Mentor/                               # MentorBubbleView (only cross-target reusable surface; rich UI lives in AppFeature/)

Libraries/Sources/AIMentor/
├── PatterMentor.swift                    # session host
├── Generables/                           # @Generable types (one per file)
├── Fallbacks/                            # static fallback dictionaries
└── CastVoicing/                          # CastVoiceRegistry + ForgeKit 0.97 CastDialog wiring (DN-S Move D)

Libraries/Sources/AppFeature/
├── RootView.swift + AppNavigationMachine.swift
├── Tabs/                                 # WriteTabView + AdventureTabView + ProgressTabView + ProfileTabView
├── Builder/                              # DialogueTreeBuilderView + DialogueTreeMachine + WriteTabUITestSeed
├── Inspector/                            # NodeInspectorView + CharacterAuthoringView
├── Panels/                               # SubtextPanelView + BranchMeaningfulnessCheckView
├── Dashboard/                            # TagBalanceDashboardView
├── Mentor/                               # PatterReactionService + CastVoicingChip + CastVoicingService
├── Onboarding/                           # 6-step flow (parent-handoff step + 5 kid steps)
├── Adventure/                            # DialogueQuestHubContribution
├── Crucible/                             # VoiceCrucibleMachine + VoiceCrucibleView (Phase 2 adventure mode)
├── Intents/                              # DialogueQuestIntents (App Intents + AppShortcutsProvider — Siri / Shortcuts)
├── Quiz/                                 # QuizMachine + QuizView + QuestionKit
├── Anthology/                            # AnthologyGalleryView
├── Progress/                             # ProgressDashboardView
├── Profile/                              # ProfileDashboardView + ParentProgressDashboardView + SessionCloserSheet
├── Settings/                             # SettingsView + CrisisResourcesView (+ PrivacyPolicyView once shipped)
├── Welcome/                              # WelcomeBackBannerView
├── Parents/                              # CompanionPackView
├── Together/                             # CollaborativeDialogueSession + CollaborativeDialogueView (C5)
└── Resources/                            # Questions/*.json + CompanionPack/*.pdf (Bundle.module)
```

Subfolders auto-discover under SPM — no `Package.swift` edit needed when adding files.

## Things That Will Bite You

Specific to DialogueQuest. Portfolio-wide bites live in `@.claude/rules/`; the entries here are *only* the DialogueQuest-specific gotchas.

- **Add `Libraries` to the workspace via Xcode GUI, not the agent** — the agent can author `Libraries/Package.swift` but cannot add it to `DialogueQuest.xcworkspace` per `@.claude/rules/xcode-agent-safety.md`. Follow `@Docs/HANDOFF_TO_USER_XCODE_WIRING.md` Step 1.
- **`AppFeature` depends on `Models` + `Services` + `SharedUI` + `AIMentor`** — adding the dep on the app target via Xcode GUI is Step 2 of the wiring handoff. Forgetting it produces "No such module 'AppFeature'" when the app shell tries to import.
- **`swift-tools-version: 6.2` is REQUIRED** — `.iOS(.v26)` won't load with 6.0. If Xcode shows `Libraries` as a folder instead of a Swift Package, the wrong tools version is the first thing to check.
- **All public Sendable types must be `nonisolated public struct/enum`** — `InferIsolatedConformances` makes Codable conformance MainActor-isolated by default; tests in nonisolated contexts break. Codable conformance must be declared on the type itself, not via extension.
- **`PatterMentor` lazy session** — `LanguageModelSession` is created on first use + reused. The `@ObservationIgnored private lazy var session` form is required because `@Observable` can't track lazy storage (per `@.claude/rules/warnings.md`).
- **No SpriteKit, no SceneKit, no AnyView** — DialogueQuest is pure SwiftUI; the tree editor uses `Canvas` not SKScene. No `GameEngine` SPM target.
- **App-shell swap to `RootView()` is MCP-routed, not filesystem-routed** — `Apps/DialogueQuest/DialogueQuest/DialogueQuestApp.swift` is a synchronized-folder target but the agent must route the swap through MCP `XcodeUpdate` to avoid External-Changes risk. Step 5 of `@Docs/HANDOFF_TO_USER_XCODE_WIRING.md`.
- **App-shell `ContentView` placeholder** — the Xcode template ships `ContentView()` ("Hello, world!"). Delete it when wiring AppFeature; do not leave dead files.
- **`CastVoiceRegistry` lives in `AIMentor`, not `Services`** — DN-S Move D voicing is FoundationModels-adjacent (ForgeKit `CastDialog` is in `ForgeAI`), so the registry lives alongside `PatterMentor` in `AIMentor/CastVoicing/`. Importing `ForgeAI` in `Services` would force every consumer to import the FoundationModels-gated module unnecessarily.
- **`CastDialog.register(_:signoff:)` throws** — even for non-trauma-gated profiles. Always `try await` at the call site. DialogueQuest's 5 profiles set `reviewerGated: false` so no `ReviewerSignoff` is needed; the call still throws because the function signature requires it.
- **Onboarding now ships 6 pages, not 5** — first page is `isParentHandoff: true` (rendered by `ForgeOnboardingFlow` with the "Ask a parent or guardian to continue" prompt). UI tests asserting the onboarding length must account for this (the existing tests use launch-arg bypass so they don't iterate pages).
- **`-uiTestResetOnboarding` clears `dq.hasCompletedOnboarding`** at `RootView.init` so the onboarding flow surfaces on every test run. Pair with `-uiTestSkipOnboarding` (bypass) — they're mutually exclusive in practice.
- **`-uiTestSeedSubtextLine` pre-populates `DialogueTreeMachine`** with 2 characters + 1 populated root line + mood `.quietConflict` + stage `.editingTree` via `WriteTabUITestSeed.seedIfRequested()` in `Libraries/Sources/AppFeature/Builder/`. Used by `SubtextConfirmationUITests`. Pair with `-uiTestSkipOnboarding` so the subtext panel is reachable without driving onboarding. Production code returns `nil` from `seedIfRequested` when the arg is absent — no behavioral change off the test path.
- **SwiftUI `accessibilityIdentifier` propagates from a container to all descendant accessibility elements** — if you set `.accessibilityIdentifier("subtext.panel")` on a `VStack`, every Text / Button inside (regardless of their own `.accessibilityIdentifier(...)` modifiers) inherits the container's id in the XCUITest tree. This breaks per-element XCUITest queries (e.g., `app.buttons["subtext.panel.confirm"]` returns nothing because the button's id is `"subtext.panel"`). Rule: pick ONE — either tag the container OR the leaves, never both. Discovered + codified 2026-06-21 via `Apps/DialogueQuest/DialogueQuestUITests/SubtextConfirmationUITests.swift` shipping.
- **`ForgeGamification.StreakManager.init(currentStreak:longestStreak:availableFreezes:lastSessionDate:)` is `@MainActor`-isolated** (ForgeKit 0.99). A wrapper service built as a Swift `actor` cannot construct it in its synchronous init — the compiler reports "Call to main actor-isolated initializer ... in a synchronous actor-isolated context." Mitigation: build wrappers as `@MainActor public final class` (UserDefaults persistence is thread-safe anyway, and `StreakManager` still serializes mutation via its own actor isolation). Reference impl: `Libraries/Sources/Services/Gamification/StreakService.swift`.
- **SPM caches the per-test-target `SwiftFileList`** — when ADDING a new test file to an existing SPM test target mid-Xcode-session, `BuildProject` succeeds but Swift Testing's macro doesn't see the new file and `RunSomeTests` reports `"Test '<Suite>' not found in target"`. Touching `Libraries/Package.swift` is insufficient. Force re-discovery by editing the target's dependency list substantively (e.g., add a dependency the new file actually needs — `"AIMentor"` did it for `AppFeatureTests` 2026-06-21). Verify with: `cat $DERIVED_DATA/Build/Intermediates.noindex/Libraries.build/Debug-iphonesimulator/<Target>.build/Objects-normal/arm64/<Target>.SwiftFileList`.
- **`PatterMentor.analyze/branchCheck/tagBalanceTip` calls live FoundationModels** when the build host has Apple Intelligence enabled — each call takes seconds. For unit-test latency budgets, test `PatterFallbacks.*` directly (the value-type fallback path) so the assertion stays host-independent. The `PatterMentor` async wrappers are the right surface for integration tests, NOT performance budgets. Reference impl: `Libraries/Tests/AIMentorTests/PatterMentorFallbackPerformanceTests.swift`.
- **`MentorBubbleView` is `message:`-only** — the bubble takes a single `String` body. When attributing a different speaker (e.g., the C5 collaborative session's cast-anchored prompts voiced by Sprig / Glance / Weigh / Brogue / Rest), inline-format the speaker name into the message body (`"\(castName) — \(promptText)"`). Promoting the bubble to a `speakerName:` overload is a portfolio-side refactor candidate.
- **`PassAndPlayEngine`'s `payloadProvider` must be `@Sendable`** when the closure captures a Sendable value type — closures that don't capture `self` from a `@MainActor` class can still trigger isolation inference if not marked `@Sendable`. `CollaborativeDialogueSession.start` captures a local `let promptPool` (Sendable value-type array) and marks the closure `@MainActor @Sendable` per the rule. Reference impl: `Libraries/Sources/AppFeature/Together/CollaborativeDialogueSession.swift`.
- **`DialogueTreeMachine.replaceTree(_:)` resets per-tree caches** — selection, `reflectedBranchPointIDs`, `confirmedSubtextLineIDs`, and `lastError`. Callers handing over a tree from a collaborative session don't need to reset achievements or `publishedTreeCount` — those are app-level counters and stay intact.
- **`WritingEvaluator.VoiceCheck` is the canonical cross-cluster shape** — both `VoiceConsistencyAnalyzer` + `DialogueLineAnalysis.toVoiceCheck(...)` project into it. Consumers should program against `WritingEvaluator.VoiceCheck` / `VoiceSummary` rather than either concrete producer so a future CharacterForge-imported voice baseline is a drop-in swap. Lives in `Models/ValueTypes/WritingEvaluator.swift`.
- **`CastVoiceRegistry` lookups + static `let` profiles must be `nonisolated`** — the registry's `profile(id:)` / `lessonsLayerProfiles` / `voiceBaseline(for:)` helpers AND every per-cast `static let brogue` / `glance` / `rest` / etc. need `nonisolated` so cross-target value-type callers (e.g., `AppFeature/Crucible/VoiceCrucibleMachine`) can read them without an unnecessary MainActor hop. The default-MainActor SPM isolation otherwise infers the lookups as MainActor-only, and pure value-type machines can't reach them. Codified 2026-06-23 when Voice Crucible shipped.
- **App Intent `static var title / description / openAppWhenRun` must be `static let`** under Swift 6 strict concurrency — declaring them as `static var` even with a default trips "static property is not concurrency-safe because it is nonisolated global shared mutable state". The `AppIntent` protocol declares them as `static var ... { get }`, and `static let` satisfies the requirement. Codified 2026-06-23 from `DialogueQuestIntents.swift`.
- **`AppShortcut.phrases` must contain `\(.applicationName)` interpolation in EVERY string** — Apple's macro guard enforces "Invalid Utterance. Every App Shortcut utterance should have one '${applicationName}' in it." Two-phrase variants need to interpolate the app name in BOTH; hardcoding the app name fails compile. Codified 2026-06-23 from `DialogueQuestIntents.swift`.
- **`@AppShortcutsBuilder` is a result builder — list `AppShortcut` instances directly, NOT inside an array literal** — Apple's `AppShortcutsProvider.appShortcuts` returns `[AppShortcut]` but uses `@AppShortcutsBuilder`. Wrapping in `[ ... ]` trips "Cannot convert value of type '[AppShortcut]' to expected argument type 'AppShortcut'". Codified 2026-06-23 from `DialogueQuestIntents.swift`.

## Reference Documents

- `@Docs/TECHNICAL_DESIGN.md` — architecture, state machines, domain model
- `@Docs/IMPLEMENTATION_HANDOFF.md` — labsmith-shipped implementation context
- `@Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` (or `_ENHANCEMENT.md`) — cast + curricular embedding
- `@Docs/APP_SPECIFIC_NOTES.md` — content preserved from prior CLAUDE.md (pre-v2)
- `@.claude/rules/` — portfolio-wide rules (24+ auto-loaded files)
