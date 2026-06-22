# Agent Safety — Reaffirmed (2026-06-22)

Direction: **session note → future Claude Code sessions**. Single-page reaffirmation of the Xcode-managed-files boundary, the staging + committing carve-out, and the canonical SPM-side work surfaces. Future sessions should read this once before touching the repo.

> **Last reaffirmed 2026-06-22 (late session)** by the user-direct multi-PR ForgeKit-integration round. Both the boundary AND the staging-carve-out remain canonical. The rule survives every round — author no privileged file from disk; file `HANDOFF_TO_USER_<TOPIC>.md` instead. Staging + committing the resulting GUI diff IS the agent's job. If a future session adds a new privileged surface (a new entitlement, a new Info.plist key, an asset catalog change), file the fresh handoff — DO NOT author the privileged file directly. The full glob table lives in `@CLAUDE.md` § Xcode Agent Safety + `@.claude/rules/xcode-agent-safety.md`; this doc is the single-page reaffirmation.

## What the agent will NEVER do (authoring)

Per `CLAUDE.md` § Xcode Agent Safety + `.claude/rules/xcode-agent-safety.md`:

| Glob | Owned by |
|---|---|
| `*.xcodeproj/project.pbxproj` + `*.xcodeproj/project.xcworkspace/**` | Xcode project editor |
| `DialogueQuest.xcworkspace/contents.xcworkspacedata` + `DialogueQuest.xcworkspace/xcshareddata/**` + `DialogueQuest.xcworkspace/xcuserdata/**` | Xcode workspace editor |
| `*.xcscheme` (anywhere) | Xcode scheme editor |
| `DialogueQuest.xctestplan` at repo root | Xcode test plan editor |
| `*.xcassets/Contents.json` + `*.imageset/Contents.json` | Xcode asset catalog editor |
| `DialogueQuest/DialogueQuest/Info.plist` | Xcode target editor |
| `*.entitlements` | Xcode capabilities editor |
| `*.xcdatamodeld/**` | Xcode data model editor |
| `xcuserdata/**` (anywhere) | Xcode local per-user |
| `**/.swiftpm/**` | Xcode SPM cache |
| `Package.resolved` | SPM resolution |

When the work would require touching any of these, the agent files a `Docs/HANDOFF_TO_USER_<TOPIC>.md` with explicit Xcode GUI steps. The user does the GUI work; the agent commits the resulting diff.

## What the agent WILL do (load-bearing carve-outs)

1. **Author + edit SPM source** under `Libraries/Sources/<Target>/**/*.swift` and `Libraries/Tests/<Target>Tests/**/*.swift` via `Write` / `Edit`.
2. **Edit `Libraries/Package.swift`** to add SPM targets, products, dependencies, and resource directories. Watch out — Xcode triggers package re-resolution on save; land Package.swift edits in isolated commits.
3. **Edit `Apps/DialogueQuest/DialogueQuest/**/*.swift`** (app-shell sources) via MCP `XcodeUpdate` — NOT filesystem `Write` / `Edit`. Synchronized-folder targets tolerate filesystem writes but routing through MCP is canonical-safe.
4. **Edit Docs / scripts / config** — `Docs/*.md`, `.gitignore`, `Resources/**/*.{json,yaml,png,webp,caf,lottie}`, `Scripts/*.{py,sh}` — always safe.
5. **Stage + commit Xcode-managed file diffs** that the USER authored via the GUI. The "do not write" rule applies to AUTHORING content, NOT to `git add` / `git commit` of GUI-authored diffs. When a user completes Steps 1-4 of an Xcode-wiring handoff, the agent's job is to commit the resulting `project.pbxproj` / `xctestplan` / `xcscheme` diff so the handoff loop closes.

## SPM folder taxonomy (load-bearing)

Per `CLAUDE.md` § SPM File Layout Convention. Subfolders auto-discover under SPM — no `Package.swift` edit needed when adding files inside an existing target subfolder.

```
Libraries/Sources/Models/
├── Schema/                               # @Model classes + VersionedSchema + MigrationPlan
├── ValueTypes/                           # nonisolated Sendable structs/enums
└── Models.swift                          # target marker

Libraries/Sources/Services/
├── Analytics/                            # RetentionMetricsService
├── Analyzers/                            # BranchMeaningfulnessScorer + VoiceConsistencyAnalyzer + TagBalancer + TriangleDynamics
├── Gamification/                         # XPEngine + StreakService + AchievementService + DialogueQuestGamification
├── Pedagogy/                             # DDAEngine + ReturnLoopService + SessionTimerService + VariableReward
├── Persistence/                          # DialoguePersistenceService
└── Privacy/                              # ParentalConsentService + CrisisResourcesProvider

Libraries/Sources/AIMentor/
├── CastVoicing/                          # CastVoiceRegistry + CastVoiceLayer
├── Fallbacks/                            # PatterFallbacks
├── Generables/                           # @Generable types — one per file
└── PatterMentor.swift                    # session host

Libraries/Sources/AppFeature/
├── Adventure/                            # DialogueQuestHubContribution
├── Anthology/                            # AnthologyGalleryView
├── Builder/                              # DialogueTreeBuilderView + DialogueTreeMachine + WriteTabUITestSeed
├── Dashboard/                            # TagBalanceDashboardView
├── Inspector/                            # NodeInspectorView + CharacterAuthoringView
├── Mentor/                               # CastVoicingChip + CastVoicingService + PatterReactionService
├── Onboarding/                           # OnboardingFlow
├── Panels/                               # SubtextPanelView + BranchMeaningfulnessCheckView
├── Parents/                              # CompanionPackView ← NEW 2026-06-22 PR #61
├── Profile/                              # ProfileDashboardView + ParentProgressDashboardView + SessionCloserSheet
├── Progress/                             # ProgressDashboardView
├── Quiz/                                 # QuizMachine + QuizView + QuestionKit
├── Resources/                            # Questions/*.json + CompanionPack/*.pdf
├── Settings/                             # SettingsView + CrisisResourcesView
├── Tabs/                                 # WriteTabView + AdventureTabView + ProgressTabView + ProfileTabView
├── Together/                             # CollaborativeDialogueSession + CollaborativeDialogueView
├── Welcome/                              # WelcomeBackBannerView
├── RootView.swift
└── AppNavigationMachine.swift
```

When adding a new file, drop it into the correct subfolder by responsibility — not by Swift kind (don't make a `Views/` / `Services/` folder inside an existing target; the subfolders ARE the responsibility partition).

## Currently-open user handoffs (still pending)

These are the GUI items the user (not the agent) needs to act on:

| Doc | What |
|---|---|
| `Docs/HANDOFF_TO_USER_APP_ICON.md` | Generate Patter source PNG → Icon Composer → 6-variant `.icon` bundle in asset catalog. Not blocking TestFlight; required before App Store. |
| `Docs/HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md` | Add Family Controls entitlement + `NSChildUseDescription` Info.plist key via Xcode GUI. Unblocks parental-consent Phase 2. (Once GUI work lands, the agent scaffolds the `DeclaredAgeRangeGate` Swift surface so the API call is entitlement-gated + safe by default.) |

Two prior items closed earlier in 2026-06-21: `HANDOFF_TO_USER_CLEAR_STALE_WORKSPACE_GROUP.md` (stale group removed) + `HANDOFF_TO_USER_ADD_AIMENTORTESTS_TO_TESTPLAN.md` (test plan now includes `AIMentorTests`). Verify-before-action: if the user reports either issue resurfacing, re-pull the test plan + workspace data via `git pull` before re-filing.

When the user finishes any of these, the agent's role is to stage + commit the resulting diff. Confirm the test plan + scheme are loading correctly via `BuildProject` afterwards.

## Cross-references

- `CLAUDE.md` § Xcode Agent Safety (load-bearing)
- `.claude/rules/xcode-agent-safety.md` — full rule
- `Docs/HANDOFF_TO_USER_XCODE_WIRING.md` — canonical 5-step wiring sequence (closed)
- `Docs/FEATURE_PLAN.md` — phased roadmap; each phase's exit criteria
