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
- [ ] Verify build succeeds with zero warnings (after Xcode wiring)
- [x] `.xcworkspace` created by Xcode + committed — 2026-06-19 PR #20

### Data Layer

- [x] Define SwiftData `@Model PersistentDialogueTree` (single-blob JSON-wrapped per IMPLEMENTATION_HANDOFF resolution) — 2026-06-20 PR #25
- [x] Create `VersionedSchema` (V1) with `PersistentDialogueTree` — 2026-06-20 PR #25
- [x] Create `SchemaMigrationPlan` (V1 only — start early) — 2026-06-20 PR #25
- [x] Create value-type cache struct `AnthologyEntry` (consumed by Anthology gallery) — 2026-06-20 PR #25
- [ ] Implement local `CharacterDef` definition flow (kid authors 2-3 characters with voice / register / quirks per `.claude/rules/distributed-narrative.md` voice register pattern)
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
- [ ] Wire detector to `WritingEvaluator` shared extension (reuse CharacterForge `VoiceCheck` API)

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
- [ ] **DN-S Move D follow-up** — wire `CastDialog.respond(as:trigger:context:)` into `PatterReactionService` call sites; feature-flag via `ForgeExperiments.castVoicing` (default off); 100-sample moderation regression audit

### Gamification

- [x] Integrate ForgeGamification `XPEngine` for leveling — 2026-06-20 PR #27 (`DialogueQuestGamification.makeConfig()` + `ProgressDashboardView`)
- [x] Configure `StreakManager` deps + freeze count via `GamificationConfig` (per-session recordCompletion wiring lands in Phase 2 telemetry round) — 2026-06-20 PR #27
- [x] Register 4 Phase-1 achievements (first tree / first subtext / tag balance / branch reflected) — 2026-06-20 PR #27
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
- [ ] Implement Apple Declared Age Range API gate (iOS 26+) — requires Info.plist GUI edit (`NSAdvertisingAttributionReportEndpoint` / Declared-Age-Range entitlement) per `xcode-agent-safety.md`; filed via `HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md`

### Quality

- [x] Unit tests for dialogue tree navigation + branch-meaningfulness scoring — `Libraries/Tests/ModelsTests/DialogueTreeTests.swift` + `Libraries/Tests/ServicesTests/BranchMeaningfulnessScorerTests.swift` (2026-06-19 / 2026-06-20)
- [x] Unit tests for voice consistency analyzer — `Libraries/Tests/ServicesTests/VoiceConsistencyAnalyzerTests.swift` (2026-06-20)
- [x] Unit tests for tag balancer thresholds — `Libraries/Tests/ServicesTests/TagBalancerTests.swift` (2026-06-20)
- [x] Unit tests for subtext fallback paths — `Libraries/Tests/AIMentorTests/PatterFallbacksTests.swift` (11 tests; `Libraries/Package.swift` adds the test target; `Docs/HANDOFF_TO_USER_ADD_AIMENTORTESTS_TO_TESTPLAN.md` queues the test-plan GUI step)
- [x] UI tests for tree-builder flow — `Apps/DialogueQuest/DialogueQuestUITests/RootTabNavigationUITests.swift` (5 tests; smoke-tests 4-tab shell + tab reachability + Write-tab landing; `-uiTestSkipOnboarding` launch arg bypasses onboarding) (2026-06-21)
- [ ] UI tests for subtext confirmation flow — `accessibilityIdentifier` tagging shipped 2026-06-21 (`subtext.panel`, `.heading`, `.empty`, `.message`, `.confirm`, `.reject`); end-to-end XCUITest still deferred because it requires launch-arg-driven machine-state seeding (pre-author 2 characters + a non-empty line). Filed via follow-up handoff.
- [ ] Accessibility audit (VoiceOver / Dynamic Type / color contrast)
- [ ] Performance profiling (tree edit latency < 16ms; AI analysis call queue-bounded)

**Exit criteria**: first session reaches aha moment in ≤ 60 seconds; 5-15 node tree authorable; subtext confirmation flow shippable; 4 question kits ship; anthology gallery functional.

---

## Phase 2: 3-Character Trees + CharacterForge Import

Add third character (triangle dialogues), import characters from CharacterForge, and expand the anthology.

- [ ] Expand tree to support 3 characters (triangle dynamics; jealousy / alliance / arbitration patterns)
- [ ] Implement CharacterForge import hook — load named characters with established voice registers
- [ ] Implement `CharacterRoleConstraint` — characters carry archetype (protagonist / antagonist / mentor / etc.) with voice-baseline guidance
- [ ] Add 5 more triangle-specific question kits (kits 05-09)
- [ ] Add 8 Phase-2 achievements
- [ ] Add ForgeAdventure mode: Voice Crucible (target voice + write a line in their register)
- [ ] Expand subtext detector with multi-speaker layered-subtext analysis
- [ ] Wire anthology export hook to TaleForge

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

**Exit criteria**: full 16-kit set; classroom mode wired; App Store metadata complete.

---

## Phase: Onboarding & Child Safety

COPPA compliance, parental consent, age gates, and first-time experience polish. Runs in parallel with Phase 1 — must land BEFORE TestFlight.

### Onboarding & Child Safety (Excellence Framework)

- [ ] **First 60 Seconds experience** — mentor intro → meet 2 characters → first dialogue line → subtext reveal → curiosity hook
- [ ] **Aha moment design** — first subtext confirmation revealing layered meaning
- [ ] **Parent handoff flow** — 30-second parent setup → "Ready!" transition
- [ ] **Age gate** — Apple Declared Age Range API on iOS 26+
- [ ] **Parental consent service** — COPPA-compliant consent; annual re-consent per 2026 FTC
- [ ] **Privacy policy** — Plain-language policy accessible from Settings and App Store listing
- [ ] **Parental gates** — Required for external links and data-sharing permissions
- [ ] **Progressive disclosure** — Session 1: 3-node tree only → Sessions 2-3: 5-node + tag balance → Sessions 4+: full features

### Engagement Foundation (Excellence Framework)

- [ ] **Streak system** — Daily activity with streak freeze (one mercy day per week), warm broken-streak messaging ("Your characters miss you!")
- [ ] **DDA engine** — Invisible difficulty adjustment across branch-meaningfulness scoring + subtext-detector confidence thresholds
- [ ] **Session targeting** — 10-15 minute sessions with gentle ending summary
- [ ] **Variable rewards** — ~1 in 5 sessions: rare voice-craft tip / hidden anthology theme / character-cameo
- [ ] **Return loop** — Welcome-back flow for 3+ day lapsed users: warm greeting + best-tree recap
- [ ] **Retention metrics baseline** — D1 / D7 / D30 (on-device, privacy-first)

**Exit criteria**: aha moment within 60s; DDA holds flow; engagement loop creates intrinsic return motivation.

---

## Phase: Delight & Parent Integration

Audio/visual/haptic polish, parent-facing dashboards, and emotional design. Runs after Phase 2 minimum.

### Delight & Polish

- [ ] **Juice layer** — Visual + audio + haptic trifecta on every interaction (with iPad haptic fallback)
- [ ] **Celebration system** — Proportional: subtle sparkle for tag-balance reach → full-screen for "first published tree" → cinematic for "anthology curation milestone"
- [ ] **Micro-delight coverage** — All 8 types: celebration, surprise, personality, mastery, social, sensory, agency, discovery
- [ ] **Character personality** — Mentor with callbacks to player's recurring voice patterns + favorite themes
- [ ] **Mastery moments** — Distinct screen ripple + chord when child internalizes voice-consistency intuition
- [ ] **Easter eggs** — Hidden character-cameo invitations (DN-cast members visit as guest writers)
- [ ] **Share-worthy moments** — Published-tree certificates; anthology covers; voice-acting badges

### Parent Integration

- [ ] **Progress dashboard** — Parent-facing standards-mapped view (CCSS-ELA writing standards)
- [ ] **Parental controls** — Daily session time limits (default 30 min) + content-comfort filters (e.g., dialogue-topic preferences)
- [ ] **Weekly summary** — Opt-in progress notification (strengths, growth areas, recommendations)
- [ ] **Session closer** — End-of-session summary with achievements + preview of next session content

---

## Phase: Accessibility & Trauma-Informed Polish

- [ ] VoiceOver labels for every dialogue node + character portrait
- [ ] Dynamic Type support across tree builder + inspector
- [ ] Color-contrast audit (WCAG AA in default + dark + high-contrast themes)
- [ ] Reduce-Motion variants for tree-edit animations + subtext-reveal flourishes
- [ ] Reduce-Transparency variants for any glass UI (per portfolio Liquid Glass policy)
- [ ] Trauma-informed gate review for advanced dialogue topics — flag conflict / loss / identity-shame themes before exposing to kid (SAMHSA TIP 57 register; off-ramps)
- [ ] Crisis-resource list (988 / Childhelp / Crisis Text Line) surfaced from Settings

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
