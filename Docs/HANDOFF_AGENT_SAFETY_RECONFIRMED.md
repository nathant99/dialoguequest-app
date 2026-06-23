# Agent Safety — Reaffirmed (2026-06-23)

Direction: **session note → future Claude Code sessions**. Single-page reaffirmation of the Xcode-managed-files boundary, the staging + committing carve-out, and the canonical SPM-side work surfaces. Future sessions should read this once before touching the repo.

> **Reaffirmed 2026-06-23 (fourth mid-session, PR 8)** by yet another user-direct multi-PR App-Store-prep + ForgeKit-active-path + UI-test-smoke round (PRs α.1–δ.1 + final round-close in `Docs/IMPLEMENTATION_HANDOFF.md` fourth-mid-session entry). Same canonical boundary + carve-out. Round PRs α.1–α.3 shipped 3 App-Store-prep docs closing Phase 4 row 163 (privacy nutrition label + KIDSAFE plan + parental gates audit). PR β.1 shipped the voice-acting coach active path as pure SPM source — `VoiceActingCoachActiveSession` (TWO-PART tap rule per concurrency.md) + new `VoiceCoachingSheet` SwiftUI surface + `PerformanceBoothView` integration; safe no-op until the existing voice-coach Info.plist handoff lands. PR β.2 wired Live Activity start/update/end into WriteTabView's lifecycle hooks (`.task(id: nodes.count)` + `.onChange(stage)` + scenePhase background); safe no-op until the existing Widget Extension handoff lands. PR γ.1 filed a fresh hub handoff for the Curating Together Companion Pack PDF. PR δ.1 shipped 5 XCUITest cases for the Performance Booth + Anthology Curation surfaces via MCP `XcodeWrite` (synchronized-folder target convention — no pbxproj diff) + a new `-uiTestUnlockAdventure` launch arg in AdventureTabView. The auto-cycle ran 7 times cleanly. No Xcode-managed-file authoring; no new privileged surfaces beyond the existing handoffs. The rule survives this round verbatim.
>
> **Reaffirmed 2026-06-23 (third mid-session, PR 7)** by another user-direct multi-PR ForgeKit-integration + feature-plan round (PRs 1–7 in `Docs/IMPLEMENTATION_HANDOFF.md` third-mid-session entry). Same canonical boundary + carve-out. The rule is restated verbatim on every reaffirmation. Round PRs 1–6 shipped pure SPM source + Docs + tests + 2 new user-GUI handoff docs (Voice-Acting Coach Info.plist + Widget Extension target); none required Xcode-managed-file authoring. PR 4's SwiftData model addition went through MCP `XcodeUpdate` for the app-shell `DialogueQuestApp.swift` (synchronized-folder target convention). The auto-cycle ran 6 times cleanly (branch → commit → push → PR → merge → verify) per the standing carve-out for non-Xcode-managed work.
>
> **Reaffirmed 2026-06-23 (second mid-session, PR E)** by another user-direct multi-PR ForgeKit-integration + feature-plan round (PRs A–E in `Docs/IMPLEMENTATION_HANDOFF.md`). Same canonical boundary + carve-out. The rule is restated verbatim on every reaffirmation so a future session opening this doc cold gets the load-bearing version regardless of which round was last. Round PRs A–D shipped pure SPM source + Docs + tests; none required Xcode-managed-file authoring. The auto-cycle ran 4 times cleanly (branch → commit → push → PR → merge → verify) per the standing carve-out for non-Xcode-managed work.
>
> **Reaffirmed 2026-06-23 (mid-session)** by the user-direct multi-PR ForgeKit-integration + feature-plan round. Both the boundary AND the staging-carve-out remain canonical. The rule survives every round — author no privileged file from disk; file `HANDOFF_TO_USER_<TOPIC>.md` instead. Staging + committing the resulting GUI diff IS the agent's job. If a future session adds a new privileged surface (a new entitlement, a new Info.plist key, an asset catalog change), file the fresh handoff — DO NOT author the privileged file directly. The full glob table lives in `@CLAUDE.md` § Xcode Agent Safety + `@.claude/rules/xcode-agent-safety.md`; this doc is the single-page reaffirmation.
>
> **2026-06-23 auto-cycle note** (per saved feedback `feedback_auto_cycle_branch_pr_merge.md`): for multi-commit work the default loop is `branch → commit → push → gh pr create → gh pr merge --merge --delete-branch → verify` with no per-step confirmation prompts. The auto-cycle DOES NOT apply to Xcode-managed-file authoring — those still require a `HANDOFF_TO_USER_*.md` and user-side GUI work. Staging + committing the GUI-authored diff afterward IS in-scope for the auto-cycle.

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
├── Analytics/                            # RetentionMetricsService + DialogueQuestAnalytics
├── Analyzers/                            # BranchMeaningfulnessScorer + VoiceConsistencyAnalyzer + TagBalancer + TriangleDynamics
├── Gamification/                         # XPEngine + StreakService + AchievementService + DialogueQuestGamification
├── Pedagogy/                             # DDAEngine + DialogueScaffoldingService + ReturnLoopService + SessionTimerService + VariableReward
├── Persistence/                          # DialoguePersistenceService
├── Privacy/                              # ParentalConsentService + ParentalGateChallenge + DeclaredAgeRangeGate + CrisisResourcesProvider
└── Sensory/                              # DialogueSensoryService (ForgeSensory wrapper; juice-layer first cut)

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

A third user handoff lands in the 2026-06-23 round: `HANDOFF_TO_HUB_PATTER_APP_ICON_PNG.md` — request to hub for the 1024×1024 Patter source PNG that the App Icon handoff depends on (asset-generation ownership lives with hub per `@.claude/rules/portfolio.md` § "Asset generation ownership"). Once the PNG lands in `Resources/Art/`, the App Icon handoff's blocker is cleared and Icon Composer GUI work can run.

When the user finishes any of these, the agent's role is to stage + commit the resulting diff. Confirm the test plan + scheme are loading correctly via `BuildProject` afterwards.

## Cross-references

- `CLAUDE.md` § Xcode Agent Safety (load-bearing)
- `.claude/rules/xcode-agent-safety.md` — full rule
- `Docs/HANDOFF_TO_USER_XCODE_WIRING.md` — canonical 5-step wiring sequence (closed)
- `Docs/FEATURE_PLAN.md` — phased roadmap; each phase's exit criteria
