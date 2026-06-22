# DialogueQuest — Feature Plan

> Phased delivery roadmap. Mirrors the engineering breakdown in `@Docs/TECHNICAL_DESIGN.md`. Implementing sessions check off boxes as work lands; do not collapse phases — the per-phase exit criteria gate ship readiness.

## Phase 1: Branching Dialogue MVP

Core 2-character dialogue-tree builder, branch-meaningfulness scoring, voice-consistency feedback, subtext panel, tag-balance dashboard, anthology gallery, and AI mentor — the canonical "write a conversation, not a paragraph" craft loop.

### Scaffolding

- [x] Create Xcode project with thin app shell (`DialogueQuest/DialogueQuestApp.swift`) — 2026-06-19 PR #20
- [x] Create `Libraries/Package.swift` with 5 targets (Models, Services, SharedUI, AIMentor, AppFeature; no GameEngine — pure SwiftUI) — 2026-06-19 PR #21
- [x] Add ForgeKit dependency (remote GitHub URL, `from: "0.99.0"`) — 2026-06-19 PR #21
- [x] Create stub source files for all targets — 2026-06-19 PR #21
- [x] Swap app shell `ContentView` → `AppFeature.RootView()` + wire `ModelContainer(for: PersistentDialogueTree.self, migrationPlan: DialogueQuestMigrationPlan.self)` — 2026-06-20 PR #28 (via MCP `XcodeUpdate`; `ContentView.swift` deleted)
- [x] User completed `@Docs/HANDOFF_TO_USER_XCODE_WIRING.md` Steps 1-4 — 2026-06-21 PR #29 (agent staged + committed the resulting `project.pbxproj` + `DialogueQuest.xctestplan` GUI diffs)
- [x] Verify build succeeds with zero warnings (after Xcode wiring) — 2026-06-22 `BuildProject` clean (1.16s, 0 errors); baseline confirmed on `main` at SHA `2552c7b`
- [x] `.xcworkspace` created by Xcode + committed — 2026-06-19 PR #20

### Data Layer

- [x] Define SwiftData `@Model PersistentDialogueTree` (single-blob JSON-wrapped per IMPLEMENTATION_HANDOFF resolution) — 2026-06-20 PR #25
- [x] Create `VersionedSchema` (V1) with `PersistentDialogueTree` — 2026-06-20 PR #25
- [x] Create `SchemaMigrationPlan` (V1 only — start early) — 2026-06-20 PR #25
- [x] Create value-type cache struct `AnthologyEntry` (consumed by Anthology gallery) — 2026-06-20 PR #25
- [x] Implement local `CharacterDef` definition flow (kid authors 2-3 characters with voice / register / quirks per `.claude/rules/distributed-narrative.md` voice register pattern) — 2026-06-20 PR #26 `CharacterAuthoringView` ships the per-character name + voice register + 1-3 sample lines surface; Phase 2 (PR #65) extends with the optional third character + per-character role picker behind `dq.experiments.thirdCharacter`
- [ ] Implement `CharacterForge` import hook (deferred Phase 2 — Phase 1 ships local-only)

### Dialogue Engine

- [x] Implement `DialogueTree` value type (root + node list + edge list) — 2026-06-19 PR #22
- [x] Implement `DialogueNode` value type (speaker / line / branch options / tag-attribution / inferred-subtext) — 2026-06-19 PR #22
- [x] Implement `BranchMeaningfulnessScorer` — branch-point + leaf-target + reflection-ratio dashboard input — 2026-06-20 PR #25 (Socratic Patter UI lands in PR 3)
- [x] Implement `VoiceConsistencyAnalyzer` — Jaccard token-overlap baseline + AI-availability-safe fallback — 2026-06-20 PR #25
- [x] Implement `TagBalancer` — per-character + per-tree counts; 70% imbalance threshold; dominant classification — 2026-06-20 PR #25
- [x] Implement tree-depth + branch-count constraints (5-15 nodes Phase 1) — `DialogueTree.NodeCountConstraint` shipped 2026-06-19 PR #22
- [x] Implement `DialogueTreeMachine` view-local state machine per `.claude/rules/state-machines.md` — 2026-06-20 PR #26 (4-stage Stage enum, full authoring + editing + reflection + subtext-confirm transitions, deterministic value-type with `reset()`)
- [x] Implement deterministic seedable RNG for reproducible test states — `Libraries/Sources/Models/ValueTypes/SeedableRandom.swift` (NR-LCG; 6 tests in `SeedableRandomTests`)

### Subtext Detector (AI)

- [x] Implement `DialogueLineAnalysis` `@Generable` (surface text + AI-inferred subtext + voice-match score) — 2026-06-19 PR #23
- [x] Implement static fallbacks for every `@Generable` per `.claude/rules/foundationmodels.md` — 2026-06-19 PR #23 (`PatterFallbacks`)
- [x] Implement subtext-confirmation UX (kid confirms or rejects inferred subtext → updates `inferredSubtext` on node) — 2026-06-20 PR #26 (Socratic reflection follow-up unifies with `BranchMeaningfulnessCheckView`)
- [x] Implement curriculum-guarded fallback when FM session unavailable — 2026-06-19 PR #23 `PatterFallbacks` covers all 3 paths; `PatterMentor.isAvailable` gates the live-LLM call
- [x] Wire detector to `WritingEvaluator` shared extension (reuse CharacterForge `VoiceCheck` API) — 2026-06-22: `Libraries/Sources/Models/ValueTypes/WritingEvaluator.swift` ships the canonical cross-cluster shape (`WritingEvaluator.VoiceCheck` + `.VoiceSummary` + `.VoiceBand`). Two producers wired: `VoiceConsistencyAnalyzer.voiceChecks(for:)` + `.summary(for:)` (deterministic Jaccard baseline) and `DialogueLineAnalysis.toVoiceCheck(lineID:speakerID:)` (AI mentor output via `Libraries/Sources/AIMentor/Generables/WritingEvaluatorBridge.swift`). `WriteTabView.computeOutcomeSnapshot` refactored to read `summary.treeAverage` instead of folding per-character means by hand. 8 new tests across `WritingEvaluatorBridgeTests` (Services) + `DialogueLineAnalysisBridgeTests` (AIMentor); 11/11 green when run alongside existing analyzer tests.

### SwiftUI Views

- [x] Create 4-tab `TabView` (Write / Adventure / Progress / Profile) per portfolio convention — 2026-06-19 PR #23 (`AppFeature.RootView`)
- [x] Build `DialogueTreeBuilderView` — depth-first list-of-nodes Phase 1 surface (2-D Canvas graph deferred to Phase 2) — 2026-06-20 PR #26
- [x] Build `NodeInspectorView` — per-node line + speaker + tag-attribution editing — 2026-06-20 PR #26
- [x] Build `CharacterAuthoringView` — kid authors 2 characters with name / voice register / 1-3 sample lines + mood + title — 2026-06-20 PR #26
- [x] Build `SubtextPanelView` — surface + AI-inferred subtext; confirm/reject controls drive Patter-acknowledged subtext into the node — 2026-06-20 PR #26
- [x] Build `TagBalanceDashboardView` — Charts bar chart per character; imbalance warning ribbons + dominant-tag coaching line — 2026-06-20 PR #26
- [x] Build `BranchMeaningfulnessCheckView` — 3-question Socratic prompt + 1-line reflection; records `reflectedBranchPointIDs` — 2026-06-20 PR #26
- [x] Build `AnthologyGalleryView` — mood-tagged published trees; SwiftData fetch in `onAppear` (no `@Query`); platform-guarded list style — 2026-06-20 PR #27
- [x] Build `ProgressDashboardView` with XP bar + streak badge + adaptive badge grid; `@AppStorage`-backed totals — 2026-06-20 PR #27
- [x] Build `ProfileDashboardView` with `ForgeAvatar.AvatarStudioView(.lite)` + `AppGroupStore`-seeded ForgeID — 2026-06-20 PR #28
- [x] Build `SettingsView` with parental-gate stub + daily-session limit stepper (full COPPA parental-gate UI lands in follow-up handoff) — 2026-06-20 PR #28
- [x] Wire `CompanionPackView` under Settings → "For parents & educators" — 2026-06-22: Resources/CompanionPack/{cast_poster,coloring,parent_letter}.pdf now resolve via `Bundle.module` (copied from repo-root `Resources/CompanionPack/` into the SPM AppFeature target; `.process("Resources/CompanionPack")` added to `Libraries/Package.swift`); SettingsView surfaces a new NavigationLink that opens `CompanionPackView` (3 share cards per PDF; `ShareLink` routes to Files/AirPrint/AirDrop). 4 tests in `CompanionPackEntryTests` cover catalog shape, bundle-URL resolution, UI-uniqueness, and reader-facing register stoplist.
- [x] Build `QuizView` for question kits — kit loader + `QuizMachine` + reveal-on-tap UX + completion screen — 2026-06-20 PR #27

### AI Mentor (DN cast lead per handoff)

- [x] Create mentor class with lazy `LanguageModelSession` — 2026-06-19 PR #23 (`PatterMentor`)
- [x] Implement `BranchMeaningfulnessCheck` `@Generable` for per-branch Socratic prompting — 2026-06-19 PR #23
- [x] Implement `DialogueLineAnalysis` `@Generable` for surface-vs-subtext reflection — 2026-06-19 PR #23
- [x] Implement `TagBalanceTip` `@Generable` for attribution-rhythm coaching — 2026-06-19 PR #23
- [x] Implement static fallbacks for every `@Generable` — 2026-06-19 PR #23 (`PatterFallbacks`)
- [x] Create mentor speech-bubble UI component — 2026-06-19 PR #23 (`SharedUI.MentorBubbleView`)
- [x] Wire mentor to events: branch-point reached + tag-balance threshold crossed — 2026-06-20 PR #27 (`PatterReactionService` orchestrates `PatterMentor.branchCheck` + `tagBalanceTip`; voice-consistency dip wires in the Phase 2 SubtextPanel iteration)
- [x] **DN-S Move D — `CastVoiceRegistry`** (5 `CastVoiceProfile`s for brogue / glance / rest / sprig / weigh derived from `Docs/dn-s/chapters/*.md`; `makeCastDialog()` builds a ForgeKit `CastDialog` actor with all 5 pre-registered; 14 tests in `Libraries/Tests/AIMentorTests/CastVoiceRegistryTests.swift`) — 2026-06-21 PR (handoff `HANDOFF_FROM_LABSMITH_DN_S_AI_MENTOR_VOICING.md` → IN-PROGRESS; Step 1 + Step 2 of the 5-step rollout closed)
- [x] **DN-S Move D follow-up** — wired `CastDialog.respond(as:trigger:context:)` into `PatterReactionService` at the 5 coaching surfaces (branch-point reached / branch reflection confirmed / tag-balance imbalance / subtext discovered & confirmed / voice drift). Feature-flagged via `dq.experiments.castVoicing` `@AppStorage` (default off; `ForgeExperiments` is A/B-only — not a flag API). Cast voicings render via `CastVoicingChip` next to Patter's bubble in `WriteTabView`. Moderation regression audit: 10 `CastVoicingSurfaceTests` covering surface-map totality + (cast × trigger) × 5 = 25-pair fallback matrix + anti-pattern + length guards; 7 `PatterReactionServiceCastVoicingTests` covering flag-off / nil-service / once-per-branch-point / drift-threshold / reset. 17 new tests green; 42 prior tests still green. — 2026-06-21 PR (handoff `HANDOFF_FROM_LABSMITH_DN_S_AI_MENTOR_VOICING.md` → CLOSED)

### Gamification

- [x] Integrate ForgeGamification `XPEngine` for leveling — 2026-06-20 PR #27 (`DialogueQuestGamification.makeConfig()` + `ProgressDashboardView`)
- [x] Configure `StreakManager` deps + freeze count via `GamificationConfig` — 2026-06-20 PR #27
- [x] Wire per-session `StreakManager.recordSession()` advance — 2026-06-22: shipped `Libraries/Sources/Services/Gamification/StreakService.swift` (`@MainActor public final class` wrapping the ForgeKit actor; UserDefaults-persists `dq.currentStreak` / `dq.streakFreezes` / `dq.lastSessionDate`); `WriteTabView.onChange(machine.stage)` fires `StreakService.shared.recordPublishedTree()` on transition to `.published`. `ProgressDashboardView` picks up the new values via its existing `@AppStorage` keys with no view changes. 4 tests in `StreakServiceTests` cover first-record / persistence / freeze-default / lastSessionDate. Phase 2 telemetry round adds the warm broken-streak nudge + ForgeKit 0.86 `.heldUnderDistress` handling.
- [x] Register 4 Phase-1 achievements (first tree / first subtext / tag balance / branch reflected) — 2026-06-20 PR #27
- [x] Evaluate + award the 4 Phase-1 achievements at trigger sites — 2026-06-22: shipped `Libraries/Sources/Services/Gamification/AchievementService.swift` (`@Observable @MainActor` wrapper around ForgeGamification's pure `AchievementEngine`; persists earned IDs to `dq.earnedBadgeIDs` AppStorage key). `WriteTabView` calls `evaluateAchievements()` on every relevant `onChange` (stage / confirmedSubtextLineIDs / reflectedBranchPointIDs); newly-earned badges render via `ForgeAchievementPopup` overlay at top of the Write tab. 7 tests cover state / per-badge criteria / consumption / persistence (all passing).
- [x] Wire question kits 01-04 via `Bundle.module` (voice / subtext / tag balance / branching) — 2026-06-20 PR #27 (`QuestionKitLoader` + `.process("Resources/Questions")` + 4 JSON kits)
- [x] Codify XP awards constants for: published tree (75), subtext confirmation (15), branch reflection (10) — 2026-06-20 PR #27 (`DialogueQuestGamification.xpFor*`); ProgressTabView consumes via `@AppStorage`

### Adventure Mode

- [ ] Wire Level 1 config from `spark-anvil-hub/Resources/HubContributions/dialoguequest.json` — handoff filed to hub at `@Docs/HANDOFF_TO_HUB_HUBCONTRIBUTION_LEVEL_1.md` (2026-06-20 PR #28)
- [x] Implement `DialogueQuestHubContribution` Level-2 Swift overlay in `Libraries/Sources/AppFeature/Adventure/` (wires to QuizView via HubChallengeBridge; renders Word Woods themed kits) — 2026-06-20 PR #28
- [ ] Register mode-cards in `AdventureView` — gated on hub-side Level-1 JSON shipping (filed handoff in #28)
- [x] Wire `ForgeProgressionManager` gating — Word Workshop (`word-woods` ContentGate) unlocks after 3 distinct session-days; `AdventureTabView` renders locked-vs-unlocked surfaces with a progress ring, calendar-aware session counter, and accessibility hint (2026-06-21)

### Onboarding

- [x] Create 5-step onboarding flow (welcome, meet 2 characters, first 3-node tree, first subtext check, first published tree) — 2026-06-20 PR #28 (`AppFeature.OnboardingFlow` wraps `ForgeUI.ForgeOnboardingFlow`; presented as fullScreenCover on RootView gated by `@AppStorage("dq.hasCompletedOnboarding")`)
- [x] Implement aha moment: first subtext confirmation revealing 2 layers of meaning — driven by `SubtextPanelView` confirm-button (PR #26) + onboarding step 4 framing (PR #28)
- [x] Implement progressive disclosure (Session 1: 3-node tree only) — `DialogueTree.NodeCountConstraint.SessionTier` (firstSession=3 / earlySessions=5 / experienced=15); `DialogueTreeMachine.sessionTier` field threads through `appendChild` cap; `WriteTabView.@AppStorage("dq.publishedTreeCount")` maps to tier on `.task` + bumps on publish (2026-06-21)
- [x] Implement parent handoff flow (30s setup) — 2026-06-21 PR: `OnboardingFlow` now ships 6 pages with the first step `isParentHandoff: true` ("A quick note for grown-ups" — no PII / daily-session-limit-in-Settings / pass-back-when-ready). `ForgeOnboardingFlow` renders the standard "Ask a parent or guardian to continue" prompt on that step. New UI test `testOnboardingFirstStepIsParentHandoff()` asserts both surfaces.
- [ ] Implement Apple Declared Age Range API gate (iOS 26+) — Swift-side **scaffold SHIPPED 2026-06-22** at `Libraries/Sources/Services/Privacy/DeclaredAgeRangeGate.swift` (`@MainActor public final class`; entitlement-gated `NSChildUseDescription` Info.plist probe via `Bundle.main.object(forInfoDictionaryKey:)` per `.claude/rules/warnings.md` § Privacy-Gated Frameworks; status enum surfaces `.notWired` / `.notRequested` / `.unknown` / `.under13` / `.teen` / `.olderTeen` / `.adult`; reader-facing `statusDescription` register-stoplist-clean). `SettingsView` Privacy section now shows the Family Age Band row read-only — surfaces "not yet enabled" copy until GUI work lands. 5 tests cover the probe + status fallback + reader-register stoplist. **Scaffold deliberately omits the actual FamilyControls API request** per `.claude/rules/age-assurance.md` § "Reading 'under 13' creates COPPA actual knowledge" — request flow lands in a follow-up PR once Xcode GUI work in `@Docs/HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md` Steps 1–3 completes AND the parental-consent opt-in surface is wired.

### Quality

- [x] Unit tests for dialogue tree navigation + branch-meaningfulness scoring — `Libraries/Tests/ModelsTests/DialogueTreeTests.swift` + `Libraries/Tests/ServicesTests/BranchMeaningfulnessScorerTests.swift` (2026-06-19 / 2026-06-20)
- [x] Unit tests for voice consistency analyzer — `Libraries/Tests/ServicesTests/VoiceConsistencyAnalyzerTests.swift` (2026-06-20)
- [x] Unit tests for tag balancer thresholds — `Libraries/Tests/ServicesTests/TagBalancerTests.swift` (2026-06-20)
- [x] Unit tests for subtext fallback paths — `Libraries/Tests/AIMentorTests/PatterFallbacksTests.swift` (11 tests; `Libraries/Package.swift` adds the test target; `Docs/HANDOFF_TO_USER_ADD_AIMENTORTESTS_TO_TESTPLAN.md` queues the test-plan GUI step)
- [x] UI tests for tree-builder flow — `Apps/DialogueQuest/DialogueQuestUITests/RootTabNavigationUITests.swift` (5 tests; smoke-tests 4-tab shell + tab reachability + Write-tab landing; `-uiTestSkipOnboarding` launch arg bypasses onboarding) (2026-06-21)
- [x] UI tests for subtext confirmation flow — 2026-06-21: shipped `SubtextConfirmationUITests` (3 tests) at `Apps/DialogueQuest/DialogueQuestUITests/SubtextConfirmationUITests.swift` covering panel-reachable / confirm-shows-badge / reject-removes-badge. Driven by a new `-uiTestSeedSubtextLine` launch arg that activates `WriteTabUITestSeed.seedIfRequested()` to pre-populate the machine with Iris + Cal + the line "I'm fine." + mood `.quietConflict`, surfacing a non-empty fallback inferred subtext immediately. A new `subtext.panel.confirmedBadge` element renders in the panel viewport once the line lands in `confirmedSubtextLineIDs` — the test signal is panel-local instead of relying on the off-screen NodeInspector form section. Also discovered + codified a SwiftUI gotcha: an outer `.accessibilityIdentifier("subtext.panel")` on a VStack overrides per-child identifiers (clobbers `.heading` / `.confirm` / `.reject`), so the outer identifier was removed.
- [x] Accessibility audit (VoiceOver / Dynamic Type / color contrast / Reduce-Motion / Reduce-Transparency) — 2026-06-21: every `.thinMaterial` background in `AppFeature/` now wraps in a `panelBackground` helper that collapses to a solid `DialoguePalette.cream` tint when `accessibilityReduceTransparency` is on (`WriteTabView` / `SubtextPanelView` / `TagBalanceDashboardView` / `DialogueTreeBuilderView` footer / `ProgressDashboardView` badge / `ProfileDashboardView` header + settings row). `CastVoicingChip`'s scale-in transition + WriteTabView's `.animation(.snappy)` now collapse to pure-opacity / no-op respectively when `accessibilityReduceMotion` is on. Tag-balance dashboard + tree-builder footer + `CastVoicingChip` got per-element `accessibilityElement` / `accessibilityLabel` / `accessibilityHint` so VoiceOver users get the right context. Dashboard ribbons and publish-eligibility hint provide the WHY behind disabled / warning states.
- [x] Performance profiling (tree edit latency < 16ms; AI analysis call queue-bounded) — 2026-06-21: shipped `Libraries/Tests/AppFeatureTests/DialogueTreeMachinePerformanceTests.swift` (5 tests covering appendChild / updateNode / confirm+reject subtext / removeLeaf / reset latency — all P95 < 16 ms / one display frame) + `Libraries/Tests/AIMentorTests/PatterMentorFallbackPerformanceTests.swift` (3 tests covering `PatterFallbacks.lineAnalysisFallback` / `.branchCheckFallback` / `.tagBalanceFallback` per-call latency — all P95 < 5 ms / one-third of a display frame). The mentor's fallback path is tested directly (NOT through `PatterMentor.analyze`) so the budget assertion stays meaningful regardless of whether `SystemLanguageModel.default.availability == .available` on the build host. 8 new tests green; existing 42 still green.

**Exit criteria**: first session reaches aha moment in ≤ 60 seconds; 5-15 node tree authorable; subtext confirmation flow shippable; 4 question kits ship; anthology gallery functional.

---

## Phase 2: 3-Character Trees + CharacterForge Import

Add third character (triangle dialogues), import characters from CharacterForge, and expand the anthology.

### Pillar Deepening (cross-cuts Phase 1 + 2)

- [x] **DN Layered Cast — WORLD + META text-only voice profiles** — 2026-06-22: Closes `Docs/HANDOFF_FROM_LABSMITH_DN_ENHANCEMENT.md` + `Docs/HANDOFF_FROM_LABSMITH_DN_SECOND_PASS_DEEPENING.md` (text-axis). New `Libraries/Sources/AIMentor/CastVoicing/CastVoiceLayer.swift` ships a 3-case `CastVoiceLayer` enum (`.lessons` / `.world` / `.meta`) with per-layer `minimumKitNumber` (1 / 5 / 11). `CastVoiceRegistry` now ships **10 profiles across 3 layers**: 5 LESSONS (Brogue / Glance / Rest / Sprig / Weigh — preserved), 4 WORLD voice-register archetypes (Heralda the Loud — Epic; Murmur — Lyric; Quip Goodfellow — Comic; Vesperline — Tragic), and 1 META (Audience Aria, with load-bearing **Aria-is-data rule** encoded in antiPatterns). New `CoachingSurface` cases — `.voiceRegisterEpic` / `.voiceRegisterLyric` / `.voiceRegisterComic` / `.voiceRegisterTragic` / `.audiencePerception` — and a `.layer` discriminator on every surface. `CastVoicingService.respond(to:topic:kitNumber:)` gates WORLD/META utterances behind the layer's `minimumKitNumber` so Patter (Pattern B protagonist) stays the on-screen coach through the early arc. Asset gen for the WORLD characters stays inherited from LyricForge handoff #304 ($0 marginal); META Aria portrait is a future hub wave. 19 new tests in `CastVoiceLayerTests` + 6 new in `CastVoicingServiceLayerGatingTests`; 14 existing `CastVoiceRegistryTests` + 10 existing `CastVoicingSurfaceTests` updated to the 10-profile / 12-surface inventory. 50/50 tests green.

- [x] **C5 Collaborative / Co-authored Dialogue** — 2026-06-22: per `Docs/HANDOFF_FROM_LABSMITH_PILLAR_DEEPENING_C5_COLLABORATIVE.md`. `Libraries/Sources/AppFeature/Together/CollaborativeDialogueSession.swift` wraps ForgeKit's `PassAndPlayEngine` (Round = cast-anchored `TurnPrompt`, Score = Int) + drives the 4-stage `PrivacyCurtain`. `CollaborativeDialogueView` renders one of 4 sub-surfaces (start sheet → authoring + cast prompt → handoff curtain → confirmReady → complete). `WriteTabView` toolbar exposes "Write together" entry; completed sessions hand the linear tree back into `DialogueTreeMachine.replaceTree(_:)`. Cast-anchored prompts cycle through 6 turn prompts voiced by Sprig / Glance / Weigh / Brogue / Rest. Solo path preserved (collaboration is opt-in). 6 tests cover idle / start / record+curtain / 4-line full session / endEarly / alternating speakers. Closes pillar deepening `modes.together: 0 → 1`.

- [x] Expand tree to support 3 characters (triangle dynamics; jealousy / alliance / arbitration patterns) — 2026-06-22: behind `dq.experiments.thirdCharacter` feature flag (default off). `Libraries/Sources/Services/Analyzers/TriangleDynamics.swift` ships a pure value-type analyzer returning `.alliance` / `.jealousy` / `.arbitration` / `.none` with per-character speaker shares + consecutive-streak counts. `DialogueTree.NodeCountConstraint.maxNodes(for:characterCount:)` widens the experienced-tier ceiling from 15 → 24 nodes when 3+ characters share the tree; `DialogueTreeMachine.maxNodes` consults the new overload. `CharacterAuthoringView` adds an optional third character section + per-character role picker, both hidden when the flag is off (Phase 1 flow untouched). 11 tests in `TriangleDynamicsTests` + 8 tests in `DialogueCharacterRoleTests` covering analyzer classifications, Codable backwards-compat for Phase 1 trees that omit the `role` field, and the phase 2 ceiling rule.
- [ ] Implement CharacterForge import hook — load named characters with established voice registers
- [x] Implement `CharacterRoleConstraint` — characters carry archetype (protagonist / antagonist / mentor / etc.) with voice-baseline guidance — 2026-06-22: `DialogueCharacterRole` enum ships with 5 cases (`.protagonist` / `.antagonist` / `.confidant` / `.arbiter` / `.unspecified`); per-role `coachingHint` lines are reader-facing (no engineering jargon) and surface on the role picker as the `accessibilityHint`. Phase 1 trees roundtrip via Codable with the optional `role` field defaulting to `.unspecified`.
- [ ] Add 5 more triangle-specific question kits (kits 05-09) — kits 05 + 06 SHIPPED 2026-06-22 (`kit_05_triangle_voices.json` — 5 questions on alliance / jealousy / arbitration + voice differentiation; `kit_06_voice_crucible.json` — 5 questions on voice fingerprinting + register matching + stakes vs surface text; both registered via `QuestionKitLoader.phase2Kits` + `.allKits` + `.loadAllPhases()`). Kits 07-09 stay queued until 05 + 06 surface real voice-craft gaps.
- [x] Add 8 Phase-2 achievements — 8 SHIPPED 2026-06-22 (`triangle_published` / `triangle_three_voice_spread` / `triangle_alliance_pattern` / `triangle_arbitration_pattern` / `triangle_jealousy_pattern` / `triangle_subtext_layered` / `triangle_branches_reflected` / `triangle_tag_balance_held` — all in `DialogueQuestGamification.phase2Achievements`). `AchievementService.Criteria` extends with `characterCount` + `trianglePattern: TrianglePattern` + `hasThreeVoiceSpread`; `satisfiesCriteria` gates each Phase 2 badge on the triangle path (characterCount ≥ 3 AND totalNodes ≥ 5 — except `triangle_tag_balance_held` which requires totalNodes ≥ 8). 5 new tests in `AchievementServicePhase2ExtensionsTests` cover the jealousy / subtext-layered / branches-reflected / tag-balance-held badges + a Phase-1-regression-guard confirming a 2-character publish never earns any of the 4 new badges.
- [ ] Add ForgeAdventure mode: Voice Crucible (target voice + write a line in their register)
- [ ] Expand subtext detector with multi-speaker layered-subtext analysis
- [x] Wire anthology export hook to TaleForge — 2026-06-22 (Phase 2 seed): `Libraries/Sources/AppFeature/Anthology/DialogueTreeShareable.swift` wraps `DialogueTree` in `Transferable` with a `DataRepresentation(exportedContentType: .json)` representation + filename-safe `sanitizeFilename(...)` helper (alphanumerics + dash + underscore preserved; everything else collapsed to `_`; falls back to "dialogue" for empty / all-punctuation titles; clamps to 60 chars). `AnthologyGalleryView` decodes the full value-type tree alongside the projection in `refresh()` and renders a per-entry `ShareLink` that fires `DialogueQuestAnalytics.shared.track(.anthologyEntryShared)` on tap (system share sheet — AirDrop / Files / Mail / Messages; on-device only, no outbound network). The JSON shape IS the portable canonical form — TaleForge's future hub-side import will consume the same payload. 4 tests cover sanitization + roundtrip.

**Exit criteria**: 3-character trees authorable; CharacterForge import functional; 9 question kits live.

---

## Phase 3: Dialogue Performance & Voice Coaching

Add read-aloud performance, voice-acting coaching, and audio export of completed trees.

- [ ] Implement read-aloud playback (text-to-speech with per-character voice variants — accessibility + perf)
- [ ] Implement voice-acting coach (kid records their own voice for a character; AI compares to register guidance)
- [ ] Implement audio export of completed dialogue tree (CAF; on-device only)
- [ ] Add 4 performance-focused question kits (kits 10-13)
- [ ] Add 6 Phase-3 achievements
- [ ] Add ForgeAdventure mode: Performance Booth (voice + line + tree → audio export)

**Exit criteria**: read-aloud playback shippable; voice-acting coach gives actionable feedback; audio export works offline.

---

## Phase 4: Anthology + Classroom + App Store

Anthology curation, classroom integration, and App Store submission readiness.

- [ ] Implement anthology curation (kid-curated collection of best trees with themed organization)
- [ ] Implement classroom mode (ForgeKit `ForgeClassroom` integration when wired)
- [ ] Implement parent/educator progress reports (`ForgeReporting`) standards-mapped to CCSS-ELA writing standards
- [ ] Add 3 final question kits (kits 14-16; synthesis / cross-craft / writing process)
- [ ] Add 8 advanced achievements
- [ ] App Store submission preparation (privacy nutrition label / KIDSAFE plan / parental gates)
- [ ] App Store screenshot + preview-video assets (await hub distribution per portfolio pipeline)
- [ ] App icon (6-variant Liquid Glass set) — filed `@Docs/HANDOFF_TO_USER_APP_ICON.md` (Icon Composer GUI work after Patter source PNG lands)

**Exit criteria**: full 16-kit set; classroom mode wired; App Store metadata complete.

---

## Phase: Onboarding & Child Safety

COPPA compliance, parental consent, age gates, and first-time experience polish. Runs in parallel with Phase 1 — must land BEFORE TestFlight.

### Onboarding & Child Safety (Excellence Framework)

- [x] **First 60 Seconds experience** — mentor intro → meet 2 characters → first dialogue line → subtext reveal → curiosity hook (shipped via `OnboardingFlow` PR #28 + Phase 1 publish-loop polish; 6 pages including parent handoff first; `RootView` gates onboarding via `dq.hasCompletedOnboarding` `@AppStorage`)
- [x] **Aha moment design** — first subtext confirmation revealing layered meaning (shipped via `SubtextPanelView` confirm button PR #26 + onboarding step 4 framing PR #28)
- [x] **Parent handoff flow** — 30-second parent setup → "Ready!" transition (shipped via `OnboardingFlow` first-step `isParentHandoff: true` PR #43; `ForgeOnboardingFlow` renders the "Ask a parent or guardian to continue" prompt; `testOnboardingFirstStepIsParentHandoff()` UI test verifies)
- [ ] **Age gate** — Apple Declared Age Range API on iOS 26+ (Swift-side scaffold shipped 2026-06-22; entitlement + Info.plist GUI work blocks the actual API request flow per `@Docs/HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md`)
- [x] **Parental consent service** (Phase 1 scaffold) — 2026-06-22: shipped `Libraries/Sources/Services/Privacy/ParentalConsentService.swift` (`@MainActor public final class`; `dq.parentalConsentGrantedAt` UserDefaults key; 12-month expiry per FTC 2026; injectable clock for tests). `SettingsView` surfaces the consent status row + a light parental-gate sheet (multiplication challenge) to record consent. Full Family Controls / Declared Age Range API integration stays handoff-blocked (`HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md`). 5 tests cover grant / revoke / expiry / re-consent countdown.
- [x] **Privacy policy** — 2026-06-22: `Libraries/Sources/AppFeature/Settings/PrivacyPolicyView.swift` ships a plain-language COPPA-2026 summary (9 sections: what we do / what stays on device / what never leaves / parental consent / AI mentor / pass-and-play / crisis resources / App Store age rating / contact). Linked from Settings → Privacy. No outbound URL; in-app only.
- [x] **Parental gates** — 2026-06-22: extracted the existing inline math challenge into `Libraries/Sources/Services/Privacy/ParentalGateChallenge.swift` (Sendable / nonisolated / public). 6×6...9×9 multiplication, `accepts(_:)` accepts canonical answer + tolerates whitespace, rejects empty / non-numeric. Reusable across future external-link surfaces (donate / studio site / privacy off-app page). SettingsView's ParentalConsentGateView now uses the shared challenge. 5 new tests in `ParentalGateChallengeTests` cover math / prompt shape / accepts rule / range / generator-injectable API.
- [x] **Progressive disclosure** — Session 1: 3-node tree only → Sessions 2-3: 5-node + tag balance → Sessions 4+: full features (shipped via `DialogueTree.NodeCountConstraint.SessionTier` + `DialogueTreeMachine.sessionTier` + `WriteTabView.@AppStorage("dq.publishedTreeCount")` PR #44, 2026-06-21)

### Engagement Foundation (Excellence Framework)

- [x] **Streak system** — `StreakService.recordPublishedTree()` (shipped 2026-06-22 earlier) + this round's `StreakService.inspectStreakStatus(now:)` snapshot exposing `.neverStarted` / `.active(streak:)` / `.broken(previousStreak:)` based on calendar-day delta vs available freezes. `RootView` renders `StreakService.brokenStreakMessage` ("Your characters miss you. Want to write one more line together?") as a one-line dismissible banner when status is `.broken`. `.heldUnderDistress` (ForgeKit 0.86) case now persists explicitly rather than falling into the `@unknown default` no-op arm. 5 new tests cover the status surface. **Mood-aware path SHIPPED 2026-06-22 (later)**: new `recordPublishedTree(mood:)` overload maps `DialogueMood` → `ForgeModels.EmotionSnapshot` (`.derivedFromTask` source — never biometric); `.quietConflict` (0.75) and `.awkwardSilence` (0.70) cross the 0.65 distress threshold so ForgeKit routes through the `.heldUnderDistress` path and the streak HOLDS instead of advancing on a hard scene. `WriteTabView` passes `machine.tree.mood` at publish. 9 new `StreakServiceMoodAwareTests` cover the mood mapping, every-mood-mapped guard, source-discipline (never `.selfReport`), and the end-to-end `.heldUnderDistress` result for hard moods.
- [x] **DDA engine** + consumer wiring — 2026-06-22: foundational engine shipped earlier; this round wires `engine.currentVoiceMatchFloor` into `PatterReactionService.effectiveVoiceDriftThreshold` (taken as the stricter of the canonical `CastVoiceRegistry.voiceDriftThreshold` and the DDA-ramped floor, so DDA can only widen — never tighten — the drift threshold). `WriteTabView` calls `reactionService.recordTreeOutcome(reflectionRatio:averageVoiceMatch:)` on every `.published` transition, snapshotting branch-reflection ratio + per-character averaged voice-match from the analyzers.
- [x] **Session targeting** (foundation) — 2026-06-22: `Libraries/Sources/Services/Pedagogy/SessionTimerService.swift` ships an `@Observable @MainActor` value-type-state service with a `Phase` enum (`.idle` / `.running` / `.gentleNudgeReady` / `.endingSummaryReady`). Defaults: gentle-nudge at 10 min, ending-summary at 13 min — within the FEATURE_PLAN 10-15 min target. `RootView` starts the service on appear (post-onboarding) and drives the ticker via a `.task(id: sessionTimer.phase)` loop using `Task.sleep(for: .seconds(15))` (NOT `Timer.scheduledTimer + Task { @MainActor in }` per the concurrency rule). Pure-function `derive(elapsed:config:)` makes phase transitions trivially testable; 9 tests in `SessionTimerServiceTests`. Ending-summary sheet rendering lands in PR-3 (parent integration).
- [x] **Variable rewards** (Phase 1 first cut) — 2026-06-22: `Libraries/Sources/Services/Pedagogy/VariableReward.swift` ships pure functions `shouldShowBonus(probability:rng:)` + a curated `voiceCraftTips` pool of 5 age-9-14-register tips. `WriteTabView` rolls on every publish; when the bonus fires, a `MentorBubbleView` overlay surfaces a randomly-picked tip dismissable on tap. Hidden anthology themes + character cameos land in later phases.
- [x] **Return loop** — 2026-06-22: `Libraries/Sources/Services/Pedagogy/ReturnLoopService.swift` ships `shouldShowWelcomeBack(now:)` (3+ calendar-day lapse threshold, requires ≥ 1 published tree) + `welcomeBackMessage(now:)` (warm, register-appropriate). `RootView` overlays `WelcomeBackBannerView` at the top with a "Write" CTA that jumps to the Write tab and a dismiss button. 5 tests cover never-published / 5-day lapse / 1-day no-fire / singular vs plural framing / 7+ day "week or more" copy.
- [x] **Retention metrics baseline** — 2026-06-22: `Libraries/Sources/Services/Analytics/RetentionMetricsService.swift` records D1 / D7 / D30 booleans + first-launch date on every `RootView.task`. Storage: 4 UserDefaults keys (no PII / no outbound / no third-party SDK). `Snapshot` API ready for the parent-progress dashboard. 5 tests cover first-open seeding / D1 / D7 / D30 / reset.
- [x] **On-device ForgeAnalytics event stream** — 2026-06-22: `Libraries/Sources/Services/Analytics/DialogueQuestAnalytics.swift` (`@MainActor public final class`) wraps ForgeKit's `AnalyticsEngine` actor (PII-blocklist + retention-pruned + COPPA-safe — zero outbound). 13-case stable `Event` vocabulary (tree_published / subtext_confirmed / subtext_rejected / branch_reflected / badge_earned / streak_advanced / streak_held_under_distress / streak_broken / welcome_back_shown / session_timer_gentle_nudge / session_ending_summary_shown / anthology_entry_shared / cast_voicing_shown). Wired in `WriteTabView.onChange(machine.stage == .published)` with categorical mood + node-count bucket + character count properties, `AchievementService.evaluate()` (badge_id only), `StreakService.persistAfter(result:)` (5-arm switch routes to 3 distinct analytics events; `.sameDay` no-ops), and `RootView.onChange(sessionTimer.phase)` + `welcomeBackShown`. 4 tests cover full round-trip / event vocabulary stability / session lifecycle / categorical-only discipline.

**Exit criteria**: aha moment within 60s; DDA holds flow; engagement loop creates intrinsic return motivation.

---

## Phase: Delight & Parent Integration

Audio/visual/haptic polish, parent-facing dashboards, and emotional design. Runs after Phase 2 minimum.

### Delight & Polish

- [ ] **Juice layer** — Visual + audio + haptic trifecta on every interaction (with iPad haptic fallback)
- [x] **Celebration system** (Phase 1 first cut) — 2026-06-22: `ForgeCelebration.CelebrationCoordinator` instance lives on `RootView`; first publish (publishedTreeCount 0→1) fires `.epic`-tier "Your first conversation is in the anthology" with ✨ emoji; subsequent publishes fire `.medium`-tier "Published" with 📜. `.celebrationOverlay(...)` rendered at the root so the celebration crosses tabs. Per-tier cooldowns + Reduce-Motion respect handled by the Forge coordinator. Subtle tag-balance sparkle + anthology-curation cinematic land in Phase 2+.
- [ ] **Micro-delight coverage** — All 8 types: celebration, surprise, personality, mastery, social, sensory, agency, discovery
- [ ] **Character personality** — Mentor with callbacks to player's recurring voice patterns + favorite themes
- [ ] **Mastery moments** — Distinct screen ripple + chord when child internalizes voice-consistency intuition
- [ ] **Easter eggs** — Hidden character-cameo invitations (DN-cast members visit as guest writers)
- [ ] **Share-worthy moments** — Published-tree certificates; anthology covers; voice-acting badges

### Parent Integration

- [x] **Progress dashboard** — 2026-06-22: `Libraries/Sources/AppFeature/Profile/ParentProgressDashboardView.swift` ships a read-only dashboard linked from `SettingsView`. Surfaces published-tree count, current streak + freezes, badges earned, D1/D7/D30 retention snapshot from `RetentionMetricsService`, and standards-mapped section (CCSS.ELA-Literacy.W.6-8.3.B primary + RL.6-8.6 secondary + NCAS TH:Cr3). All data via @AppStorage; no PII / no outbound. Per-row accessibilityLabel keeps the dashboard VoiceOver-friendly.
- [x] **Parental controls** — Daily session stepper ships earlier in `SettingsView`; this round links the parent progress dashboard + weekly-summary toggle into the same section.
- [x] **Weekly summary** (opt-in storage) — 2026-06-22: `dq.weeklySummaryOptIn` `@AppStorage` toggle in Settings. When ON, the in-app dashboard will surface a weekly summary; delivery is in-app only (no email / no notification). Actual summary rendering lands in a later round once a meaningful "this week's deltas" report can be computed.
- [x] **Session closer** — 2026-06-22: `Libraries/Sources/AppFeature/Profile/SessionCloserSheet.swift` rendered as a sheet from `RootView` when `SessionTimerService.phase` reaches `.endingSummaryReady`. Lists published-tree count, streak, badge count, plus a "Up next" preview line keyed off the kid's progress. Dismissing the sheet resets the timer for the next window.

---

## Phase: Accessibility & Trauma-Informed Polish

- [x] VoiceOver labels for every dialogue node + character portrait — 2026-06-22 sweep: `NodeInspectorView` added accessibilityHint on speaker / line / tag style / verb / action beat fields + Subtext display labeled as "Confirmed subtext: …"; `CharacterAuthoringView` added per-field accessibilityHint on name / voice register / sample lines + conversation title / mood picker; `AnthologyGalleryView` entry rows collapse to a single accessibility element with "<title>, mood: <mood>, last edited <date>"; `ProfileDashboardView` profile header reads "<displayName>, Storyteller in the making."; `ProgressDashboardView` streak badge labels with day count + freeze remaining + badge cards with "Earned/Locked badge: <title>. Worth N XP"; `TagBalanceDashboardView` per-bar `accessibilityLabel` "<character>: N <style> lines". DialogueTreeBuilderView a11y already in place from prior round (line 75–77).
- [ ] Dynamic Type support across tree builder + inspector
- [ ] Color-contrast audit (WCAG AA in default + dark + high-contrast themes)
- [ ] Reduce-Motion variants for tree-edit animations + subtext-reveal flourishes
- [ ] Reduce-Transparency variants for any glass UI (per portfolio Liquid Glass policy)
- [ ] Trauma-informed gate review for advanced dialogue topics — flag conflict / loss / identity-shame themes before exposing to kid (SAMHSA TIP 57 register; off-ramps)
- [x] Crisis-resource list (988 / Childhelp / Crisis Text Line) surfaced from Settings — 2026-06-22: `Libraries/Sources/Services/Privacy/CrisisResourcesProvider.swift` ships the three canonical US resources with tap-to-call + tap-to-text + URL fields; `Libraries/Sources/AppFeature/Settings/CrisisResourcesView.swift` renders them under a "Need help?" disclosure in Settings. 3 tests cover the canonical trio + per-resource invariants.

**Exit criteria**: A11y audit PASS; trauma-gate sensitivity review per ADR-016 protocol if mature-topic dialogues unlock.

---

## Cross-references

- `@Docs/TECHNICAL_DESIGN.md` — architecture + state machines + domain model
- `@Docs/IMPLEMENTATION_HANDOFF.md` — hub-shipped implementation context
- `@Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` — DN cast (voice mentors)
- `@Docs/HANDOFF_FROM_LABSMITH_DN_S_STORY_PER_CHARACTER.md` — DN-S chapter-depth backstories
- `@.claude/rules/forgekit.md` § Module Catalog — ForgeKit 0.99 surface
- `@.claude/rules/state-machines.md` — DialogueTreeMachine pattern
- `@.claude/rules/foundationmodels.md` — `@Generable` + fallback discipline
- `@.claude/rules/distributed-narrative.md` — voice register pattern for character definitions
