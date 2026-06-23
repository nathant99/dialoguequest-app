---
status: ACTIVE
date: 2026-06-22
direction: hub → app (filled in by engineering session)
target-audience: any future Claude Code session opening this repo
freshness-horizon: 60 days
---

> **2026-06-23 round addendum (third mid-session)** — multi-PR Phase 3 close-out + Phase 4 kickoff round. Net state delta:
>
> - **PR 1 (this addendum) — Doc-sync round.** Phase 3 FEATURE_PLAN checkboxes ticked against shipped reality from PR #99 (`12f0673`); `CLAUDE.md` § "SPM File Layout Convention" Services taxonomy updated with `Audio/` subfolder. No code/test changes.
> - **PR 2 — Voice-acting coach scaffold (Phase 3 row 144 closure).** `Libraries/Sources/Services/Audio/VoiceActingCoachService.swift` (`@MainActor public final class`) ships per the `DeclaredAgeRangeGate` privacy-gated-framework pattern: `availability` enum gates `NSMicrophoneUsageDescription` + `NSSpeechRecognitionUsageDescription` probes via `Bundle.main.object(forInfoDictionaryKey:)`. Returns `.notWired` when missing — every entry point safe no-op. Score-extraction is pure value-type (Jaccard against the per-character voice baseline). Future wired path uses `SFSpeechRecognizer` + `AVAudioEngine.installTap` with the TWO-PART AVAudioNodeTap rule. Info.plist GUI work filed at `Docs/HANDOFF_TO_USER_VOICE_ACTING_COACH_INFOPLIST.md`. 8 tests.
> - **PR 3 — Performance Booth adventure mode (Phase 3 row 148 closure).** `Libraries/Sources/AppFeature/Crucible/PerformanceBoothMachine.swift` + `PerformanceBoothView.swift` ship a 3-stage value-type machine composing the existing `DialogueReadAloudService` + `DialogueAudioExporter`. `AdventureTabView` unlocked content adds a Performance Booth entry alongside Voice Crucible. New analytics event `.performanceBoothExported` + new achievement `performance_booth_premiere` (50 XP). 11 tests.
> - **PR 4 — Phase 4 anthology curation (FEATURE_PLAN row 158 closure).** `Libraries/Sources/AppFeature/Anthology/AnthologyCurationView.swift` + `AnthologyCollectionService` ship the kid-curated collection feature. `AnthologyCollectionRecord` lands as a lightweight schema addition on the existing `VersionedSchema` per the pre-App-Store rule. Themed collections ("first conversations" / "quiet conflicts" / "what they didn't say"); per-collection `ShareLink` exports the collection as a JSON archive. 9 tests.
> - **PR 5 — Phase 4 kits 14-16 + 8 advanced achievements (FEATURE_PLAN rows 161-162 closure).** Three new JSON kits + 8 new achievements. 16-kit set now complete (Phase 4 exit criterion "full 16-kit set" met). 8 tests.
> - **PR 6 — ForgeLiveActivities scaffold (open ForgeKit-integration gap closure).** `Libraries/Sources/Services/Sensory/DialogueWritingSessionActivity.swift` ships a no-op-when-not-wired scaffold gated on a Widget Extension target. Activity attributes shape: current node count + current character names + mood + elapsed minutes. Widget Extension GUI work filed at `Docs/HANDOFF_TO_USER_WIDGET_EXTENSION.md`. 6 tests.
> - **PR 7 — Round-close + session handoff.** Third 2026-06-23 mid-session reaffirmation in `Docs/HANDOFF_AGENT_SAFETY_RECONFIRMED.md`. `Docs/SESSION_HANDOFF_2026-06-23_PHASE_3_4_CLOSE.md` authored for the next CC session. Test count + ForgeKit module count updated.
>
> **ForgeKit module count consumed**: 16 (unchanged from previous round — ForgeLiveActivities scaffold lands without a hard wire-up until the Widget Extension target ships; the dep is declared but the actual `ActivityKit` import is fenced behind `availability == .ready`).
>
> **2026-06-23 round addendum (second mid-session)** — five PRs landed in a single session (#94 → #98). Net state delta:
>
> - **PR A — Adopted cast portraits + book covers** (closes 2 open hub handoffs per portfolio R-ASSET-CONSUMER-AUDIT). 5 LESSONS-layer cast portraits + dual-tier book covers were shipped to disk by hub but not wired into the SPM bundle (no `.process` rule) → dark. PR adds `.process("Resources/Cast")` + `.process("Resources/CustomArt")` to AppFeature, copies the assets under the AppFeature target's Resources tree, ships `CastPortraitImage` (cross-platform Bundle.module lookup with letter-glyph fallback for WORLD/META archetypes per Pattern B), wires the portrait into `CastVoicingChip`, and surfaces the book covers in `CompanionPackView` as a "Read the chapter book" shelf. 5 tests cover slug resolution / unknown-slug fallback / WORLD/META carve-out / canonical ordering / book cover bundle.
> - **PR B — Trauma-informed gate review for advanced dialogue topics** (closes Phase A11y checkbox). `Libraries/Sources/Services/Privacy/TraumaAxisAdvisoryService.swift` ships a pure value-type analyzer with two bands: `.crisisCue` for verbatim suicide / self-harm / abuse-disclosure cues; `.tenderTheme` for loss / family-rupture / despair. `WriteTabView` wires the inspection on tree-node-count changes (per-session de-duped) + surfaces `TenderThemeBannerView` via `safeAreaInset(.top)`. Banner copy follows SAMHSA TIP 57 validate-then-inform register; "Open crisis resources" presents `CrisisResourcesView` as a sheet. Advisory-only — never blocks, never rewrites, never grades. Lexical surface narrow — single-word `kill` / `die` / `hurt` do NOT fire. Audit doc at `Docs/AUDIT_TRAUMA_INFORMED_GATE_REVIEW_2026-06-23.md` codifies the SAMHSA mapping. 10 tests.
> - **PR C — CharacterForge import hook (Phase 2 first cut)** (closes Phase 2 + Phase 1 unchecked items). `Libraries/Sources/Models/ValueTypes/CharacterForgeManifest.swift` ships the canonical wire schema; `Libraries/Sources/Services/Persistence/CharacterForgeImportService.swift` ships the pure value-type service returning `Result<[DialogueCharacterRef], ImportError>` with reader-facing copy. `Libraries/Sources/AppFeature/Inspector/CharacterForgeImportSheet.swift` ships the clipboard-JSON paste surface presented from `CharacterAuthoringView`'s primary toolbar. 3-char cap + schema-version guard + source-app guard + per-row validation + register stoplist. 10 tests.
> - **PR D — Micro-delight coverage sweep (agency + discovery)** (closes Phase Delight checkbox). Agency: `DialogueTree.isDraft` field (Codable backwards-compat) + `PersistentDialogueTree.cachedIsDraft` (lightweight SwiftData migration) + `DialogueTreeMachine.toggleDraft()` / `setDraft(_:)` + Write-tab secondary toolbar "Save as sketch" item + AnthologyGalleryView "Draft" pill. Discovery: `CharacterCameoInvitations.discoveryCameos` (5 LESSONS-layer hellos) + `pickDiscoveryCameo(rng:)` + `shouldShowDiscoveryCameo(...)` + WriteTabView session-once gate. 14 tests across Models + AppFeature.
> - **PR E — Round-close** (this PR). Second mid-session 2026-06-23 reaffirmation in `Docs/HANDOFF_AGENT_SAFETY_RECONFIRMED.md`. Updated this `IMPLEMENTATION_HANDOFF.md` addendum + ticked FEATURE_PLAN checkboxes shipped by A–D. CLAUDE.md "Things That Will Bite You" augmented with the WebP-bundle lookup + Bundle.url-empty-resource quirk discovered while writing CastPortraitImage tests.
> - **ForgeKit module count consumed**: 16 (unchanged from previous round — this round was pure SPM-source surface).
> - **Test count delta**: +39 (PR A 5 + PR B 10 + PR C 10 + PR D 14).
>
> **2026-06-23 round addendum** — seven PRs landed in a single session (#86 → #92). Net state delta:
>
> - **Xcode-agent-safety reaffirmed for 2026-06-23** (`Docs/HANDOFF_AGENT_SAFETY_RECONFIRMED.md` date-bumped; auto-cycle discipline note added — multi-commit work runs the branch → PR → merge loop without per-step confirmation, except for Xcode-managed-file authoring which still requires a `HANDOFF_TO_USER_*.md`).
> - **Voice Crucible adventure mode** SHIPPED (Phase 2 row 131 closed). 3-stage `VoiceCrucibleMachine` + `VoiceCrucibleView` reachable from `AdventureTabView`'s unlocked content; per-(cast,band) coaching lines; 19 tests green. Cross-target plumbing exposed `VoiceConsistencyAnalyzer.score(sample:against:)` + `CastVoiceRegistry.voiceBaseline(for:)` / `.displayName(for:)` / `.lessonsLayerPrimitive(for:)` + marked registry static lets `nonisolated`.
> - **Phase 2 question kits 08 + 09 SHIPPED** — `kit_08_branch_consequences.json` (branching) + `kit_09_action_beats.json` (tag balance + silence-as-subtext). Phase 2 exit-criteria "9 question kits live" now MET. 6 new QuestionKit tests.
> - **ForgeIntents** wired (Siri / Shortcuts deep links). 4 App Intents (Open / StartDialogue / ShowMyProgress / OpenWordWorkshop) routed through a `DialogueQuestIntentNavigation` notification bridge that `RootView` observes via an async-for-await sequence over NotificationCenter (no Combine). 9 tests green.
> - **ForgeSpotlight** wired. `AnthologyGalleryView.refresh()` now batches its published-tree snapshot through `AnthologySpotlightIndexer` (Services/Spotlight/) so the kid can resurface their own anthology via Spotlight. Wipe-then-index pattern handles deletions. 11 tests green.
> - **ForgeKnowledgeGraph** wired. `DialogueCraftSkillGraph` models the 6 dialogue-craft primitives as a DAG with CCSS/NCAS standards alignment + Bloom-level annotations + cast embodiment mapping. `nextPrimitive(mastered:)` uses `GapAnalyzer` + lowest-Bloom tiebreaker for adaptive scaffolding recommendations. 13 tests green.
> - **ForgeReporting** wired. `DialogueQuestProgressReportBuilder` projects on-app counters onto `StudentReportData` with the 4 canonical CCSS/NCAS standards as classified `StandardProficiency` rows. `ParentProgressDashboardView` now renders proficiency rows (code + level chip + percentage progress bar) when kid has activity; falls back to standards-overview on fresh installs. 12 tests green.
> - **Hub asset handoff filed**: `Docs/HANDOFF_TO_HUB_PATTER_APP_ICON_PNG.md` requests the 1024×1024 Patter source PNG that the App Icon user handoff is blocked on.
> - **ForgeKit module count consumed**: 13 → 16 (added `ForgeIntents` to AppFeature + `ForgeKnowledgeGraph` + `ForgeReporting` + `ForgeSpotlight` to Services).
>
> **2026-06-22 late-session reaffirmation** — Xcode-managed-files safety rule reaffirmed mid-session (user-direct); `Docs/HANDOFF_AGENT_SAFETY_RECONFIRMED.md` updated; stale FEATURE_PLAN checkboxes for `local CharacterDef definition flow` + the 4-bullet Onboarding & Child Safety surface have been ticked off against shipped reality.
>
> **2026-06-22 round addendum** — five PRs (#61 → #65 + this PR) landed in a single session. Net state delta:
> - Companion Pack PDFs surfaced via `CompanionPackView` under Settings → "For parents & educators" (Asset-Consumer-Audit close).
> - DN cast grew 5 → 10 profiles across 3 layers (LESSONS / WORLD / META) with kit-aware gating in `CastVoicingService`.
> - Phase 2 foundation: `DialogueCharacterRole` enum, `TriangleDynamics` analyzer, optional third character row in `CharacterAuthoringView` — all behind `dq.experiments.thirdCharacter` (default off).
> - 4 Phase 2 achievements + question kit 05 (triangle voices) wired through `AchievementService.Criteria` extension + `QuestionKitLoader.loadAllPhases()`.
> - `StreakService.recordPublishedTree(mood:)` overload routes `.quietConflict` / `.awkwardSilence` through ForgeKit 0.86 `.heldUnderDistress` so streaks hold (instead of break) on hard scenes.
> - Single-page agent-safety reaffirmation at `@Docs/HANDOFF_AGENT_SAFETY_RECONFIRMED.md`. CLAUDE.md § Xcode Agent Safety references it.

# Implementation Handoff — DialogueQuest

This is the canonical engineering handoff for DialogueQuest, replacing the prior stub. Authored in-session 2026-06-19 by the engineering CC session per the engineering kickoff handoff. Read this FIRST when opening the repo; cross-references the Tier-2 design + content handoffs.

> **⚠️ Xcode Agent Safety (load-bearing — read before your first write)**: This repo's agent operates inside Xcode via the Coding Assistant integration. **Do NOT author or edit Xcode-managed files** — especially the **Xcode workspace file** (`DialogueQuest.xcworkspace/**`), any **scheme file** (`*.xcscheme`), and the **test-plan file** (`DialogueQuest.xctestplan`). Also forbidden: `*.xcodeproj/project.pbxproj`, `*.xcassets/Contents.json`, `Apps/DialogueQuest/DialogueQuest/Info.plist`, `*.entitlements`, `*.xcdatamodeld/**`, `xcuserdata/**`, `**/.swiftpm/**`, `Package.resolved`. Writing these from disk risks the External-Changes dialog or a workspace reload that **terminates the agent session mid-task**. For any Xcode GUI work, **file a `Docs/HANDOFF_TO_USER_<TOPIC>.md`** with explicit GUI steps; the user does it. **Staging + committing** the user's GUI diffs IS allowed (the rule applies to authoring content, not to `git add`/`git commit`). SPM source under `Libraries/Sources/<Target>/` and `Libraries/Tests/<Target>Tests/` is always safe. Full rule: `@.claude/rules/xcode-agent-safety.md` + `@CLAUDE.md` § "Xcode Agent Safety".
>
> **SPM file-discovery gotcha** (discovered 2026-06-21): when ADDING a new SPM test file mid-session, SPM caches the per-target `SwiftFileList`. Force re-discovery by editing `Libraries/Package.swift` substantively (e.g., a dependency entry change the new file actually needs). Touching alone is insufficient — the test target will compile but Swift Testing's macro won't see the new file, and `RunSomeTests` reports `"Test '<Suite>' not found in target"`.

## 1. Overview

**Primitive**: branching dialogue craft — the kid writes a conversation (a tree of speech nodes between 2-3 named characters), not a paragraph. Every line gets scored on four axes: voice consistency, subtext, tag balance, branch meaningfulness.

**Curriculum**: CCSS.ELA-Literacy.W.6-8.3.B (narrative dialogue), CCSS.ELA-Literacy.RL.6-8.6 (point of view + perspective), NCAS TH:Cr3 (theater script development), NCAS LA:Cr2 (literary craft). Primary standard: **W.6-8.3.B**.

**Audience**: ages 9-14, Tier-3 ELA cluster sibling to characterforge / haikuquest / lyricforge / voicetale.

**Hero mascot**: **Patter** — a two-toned speech bubble with a wobbly tail. Pattern B per `.claude/rules/distributed-narrative.md` § "Hero mascot vs. cast": Patter stays the protagonist; the 5 cast members (brogue / glance / rest / sprig / weigh) are framed as Patter's friends, each embodying one dialogue-craft primitive.

**Hero color**: `#A05A4B` (Conversation rust) — primary CTA, mascot background tint, ForgeAdventure zone tag.

## 2. Phase 1 Scope

Per `@Docs/FEATURE_PLAN.md` Phase 1 (canonical roadmap). Build order favors aha-moment-first:

1. **Two-character dialogue builder** — 5-15 node tree with named character roles (local definitions only in Phase 1; CharacterForge import deferred to Phase 2).
2. **Branch-meaningfulness check** — Socratic 3-question prompt at each branch point + 1-line reflection.
3. **Voice consistency feedback** — per-character cumulative voice-match cross-line analysis.
4. **Subtext panel** — side panel showing surface text + AI-inferred subtext; kid confirms / rejects.
5. **Tag balance dashboard** — bar chart per character; warning ribbons when imbalance crosses thresholds.
6. **Anthology gallery** — mood-tagged completed trees.
7. **Patter mentor** — `LanguageModelSession`-backed coach (lazy session, static fallbacks).
8. **First-60-seconds onboarding** — kid writes one 2-character exchange with at least one branch and sees Patter acknowledge the branch as meaningful.
9. **Adventure mode wiring** — Word Workshop zone Level-2 overlay.

**Out of Phase 1**: 3-character trees (Phase 2), CharacterForge import (Phase 2), read-aloud playback (Phase 3), voice-acting coach (Phase 3), classroom mode (Phase 4), pillar deepening C5 collaborative (Phase 2+).

## 3. Domain Types

Per `@Docs/TECHNICAL_DESIGN.md` § "Domain Model". Lives in the `Models` SPM target.

### Value types (Sendable, nonisolated)

```swift
nonisolated public struct DialogueNode: Codable, Sendable, Identifiable {
    public let id: UUID
    public let speakerID: UUID          // local CharacterDef.id (Phase 1) or CharacterForge ref (Phase 2)
    public let surfaceText: String
    public let inferredSubtext: String? // AI-surfaced; kid confirms/rejects
    public let tag: DialogueTag
    public let children: [UUID]         // branch points; UUIDs into the same tree
    public let createdAt: Date
}

nonisolated public enum DialogueTag: Codable, Sendable {
    case said(String)        // canonical attribution
    case action(String)      // descriptive beat
    case unattributed        // bare quote
}

nonisolated public struct DialogueTree: Codable, Sendable, Identifiable {
    public let id: UUID
    public let title: String
    public let characters: [DialogueCharacterRef]
    public let nodes: [DialogueNode]
    public let rootNodeID: UUID
    public let mood: DialogueMood?
}

nonisolated public struct DialogueCharacterRef: Codable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let voiceRegister: String     // 1-paragraph voice description
    public let sampleLines: [String]     // 3-5 cumulative voice baseline
}

nonisolated public enum DialogueMood: String, Codable, Sendable, CaseIterable {
    case warmReunion, quietConflict, playfulRivalry, awkwardSilence, openingCuriosity
}
```

### SwiftData @Model (storage layer)

```swift
@Model
public final class PersistentDialogueTree {
    public var id: UUID = UUID()
    public var encodedTreeData: Data = Data()  // JSON-encoded DialogueTree
    public var lastEditedAt: Date = Date()
    public init() { }
}
```

Encode/decode the value-type tree to JSON on write; cache to value-type structs in `onAppear` per `.claude/rules/swiftdata.md`. **Never `@Query` in views.** Open Question #1 in TECHNICAL_DESIGN (single `@Model` vs split rows) is resolved here: **single `@Model` wrapping JSON** for Phase 1 — simpler migration story, single-write atomicity, no relationship-array reorder gotcha.

## 4. Rendering Decision

**SwiftUI only.** No SpriteKit, no RealityKit. The dialogue-tree graph editor is a 2-D node-edge editor implemented in pure SwiftUI (`Canvas` + custom layout). Reuses CharacterForge's relationship-graph patterns where they generalize.

Consequence: **no `GameEngine` SPM target.** The 5-target layout (`Models` / `Services` / `SharedUI` / `AIMentor` / `AppFeature`) per TECHNICAL_DESIGN.md is canonical. FEATURE_PLAN.md's mention of a `GameEngine` target is superseded.

## 5. AI Mentor Persona — Patter

**Mascot identity**: Patter, a two-toned speech bubble (rust + cream) with a wobbly tail. Patter cares about conversations the way a sound engineer cares about mixes — listens for rhythm, register, and what isn't being said.

**Voice register** (sample lines):
- "Hmm — Iris says one thing here, but her tag says she's looking away. Is she dodging?"
- "These two lines both end with 'said.' What if one became a glance instead?"
- "You branched here. What does each side cost the speaker?"
- "I'm hearing the same beat-shape twice. Try a beat without an attribution?"

**Patter NEVER**:
- Grades down emotional dialogue topics
- Tells the kid what their character should feel
- Auto-rewrites the kid's line (only proposes alternatives the kid accepts)

**ForgeKit integration**: Patter is implemented in the `AIMentor` target via `ForgeAI` (FoundationModels session management + availability gating + lazy session reuse). Three `@Generable` types ship in Phase 1:

1. `DialogueLineAnalysis` — `{ surfaceText, inferredSubtext, voiceMatchScore }`
2. `BranchMeaningfulnessCheck` — `{ question1, question2, question3 }` (Socratic prompt)
3. `TagBalanceTip` — `{ observation, suggestion }` (attribution-rhythm coaching)

**Every `@Generable` ships with a static fallback dictionary** per `.claude/rules/foundationmodels.md`. The fallback path keys off `DialogueMood` + `DialogueTag` for deterministic offline behavior. Property order in each `@Generable` follows the dependency rule (surface text → subtext → score).

**Cluster-shared schema**: `DialogueLineAnalysis.voiceMatchScore` shape is the same `WritingEvaluator.VoiceCheck` API exposed by CharacterForge. Cross-app consistency is the load-bearing constraint — Open Question #5 in TECHNICAL_DESIGN resolves YES.

## 6. Question Kits / Content

Phase 1 ships **4 question kits** (kits 01-04):

| Kit | Theme | Surface |
|---|---|---|
| 01 | Voice consistency — read a line, choose the speaker | Quiz |
| 02 | Subtext detection — line + 3 possible subtexts, pick the strongest | Quiz |
| 03 | Tag balance — bar chart shown, propose the missing tag style | Drag-target |
| 04 | Branching — given a node, propose two branches with distinct stakes | Free-text |

Content lives at `Libraries/Sources/AppFeature/Resources/Questions/kit_01.json` ... `kit_04.json` (Bundle.module). Phase 1 ships inline content; hub-distributed kits (Phase 2+) replace these via the standard ForgeContent pipeline.

**Content register**: per `.claude/rules/distributed-narrative.md` § "Chapter content register stoplist" (R-CHAPTER-REGISTER) the kits stay in the age-9-14 register stoplist — no engineering jargon ever surfaces to a kid.

## 7. ForgeKit Modules to Wire

Pin: `from: "0.99.0"`. Per-target wiring (canonical, post-2026-06-23):

| Target | Modules | Notes |
|---|---|---|
| `Models` | `ForgeModels` | Foundational types (StudentProfile, BloomLevel, GradeLevel) |
| `Services` | `ForgePersistence` + `ForgeAI` + `ForgeAnalytics` + `ForgeGamification` + `ForgeKnowledgeGraph` + `ForgeModels` + `ForgePedagogy` + `ForgeReporting` + `ForgeSensory` + `ForgeSpotlight` | SwiftData container + on-device AI + analytics + gamification + skill-graph DAG + pedagogy scaffolding + standards-mapped reporting + sensory palette + Spotlight indexer |
| `SharedUI` | `ForgeUI` + `ForgeAccessibility` | Theme protocol + 11 reusable components + COPPA consent + session timer |
| `AIMentor` | `ForgeAI` | LanguageModelSession lifecycle |
| `AppFeature` | `ForgeUI` + `ForgeNavigation` + `ForgeAdventure` + `ForgeAvatar` + `ForgeCelebration` + `ForgeGamification` + `ForgeIntents` + `ForgePassAndPlay` + `ForgePedagogy` + `ForgeProgression` + `ForgeStateMachine` + `ForgeSync` | Root nav + Word Workshop adventure mode + Avatar editor + celebration orchestration + XP/streak/achievements + Siri / Shortcuts deep links + pass-and-play collaborative + Bloom-level scaffolding + progression gating + state-machine helper + cross-app sync |

Modules **deferred to Phase 2+**: `ForgeContent` (hub kit distribution), `ForgeClassroom` (Phase 4 classroom mode), `ForgeWidgets` / `ForgeLiveActivities` (need separate app targets + entitlements — file user handoff when desired).

## 8. Constraints

- **iOS 26 / Xcode 26 / Swift 6** strict concurrency; default-MainActor isolation
- **No Combine** (use async/await throughout)
- **No SceneKit** (deprecated WWDC 2025)
- **No SpriteKit** (DialogueQuest is text/graph-editor only)
- **No AnyView**, no `@unchecked Sendable`, no force-unwraps
- **No third-party analytics SDKs** — privacy-first on-device only
- **No PII collection** — `DialogueCharacterRef` is local-only data the kid authors
- **All AI output is draft until user-confirmed** per `.claude/rules/foundationmodels.md`
- **Tree-edit latency budget**: < 16ms per node mutation (per Phase 1 FEATURE_PLAN performance bullet)
- **First-60-seconds aha**: subtext confirmation revealing 2 layers of meaning
- **Liquid Glass** auto-adoption per `.claude/rules/liquid-glass.md` — no `toolbarBackground` / `toolbarColorScheme` / `UITabBar.appearance` overrides

## 9. Definition of Done (Phase 1)

- [ ] Build clean (all 5 SPM targets + app shell, zero warnings)
- [ ] `ForgeKitIntegrationTests` passes (5 sanity tests)
- [ ] Unit tests for `DialogueTree` value-type round-trip
- [ ] Unit tests for branch-meaningfulness scoring
- [ ] Unit tests for voice consistency analyzer
- [ ] Unit tests for tag balancer thresholds
- [ ] Unit tests for subtext fallback paths
- [ ] UI tests for tree-builder flow + subtext confirmation flow
- [ ] Accessibility audit PASS (VoiceOver / Dynamic Type / WCAG AA)
- [ ] First 60 seconds reaches aha moment (first authored branch + Patter acknowledgement)
- [ ] 4 question kits live and shippable
- [ ] App icon (6-variant Liquid Glass set) — handoff to user via Icon Composer
- [ ] COPPA-2026 parental consent functional + annual re-consent
- [ ] Composable avatar editor — `AvatarStudioView(.lite)` adoption per writing-craft cluster pattern
- [ ] Performance budget targets met (tree-edit < 16ms, AI analysis queue-bounded)
- [ ] CLAUDE.md § "Things That Will Bite You" updated with anything discovered during Phase 1

## Cross-references

- `@Docs/TECHNICAL_DESIGN.md` — architecture + state machines + domain model (parent design doc)
- `@Docs/FEATURE_PLAN.md` — phased roadmap (Phase 1 checklist)
- `@Docs/HANDOFF_TO_USER_XCODE_WIRING.md` — Xcode GUI steps after SPM scaffold lands
- `@Docs/HANDOFF_FROM_HUB_ENGINEERING_KICKOFF.md` — kickoff context + cluster placement
- `@Docs/HANDOFF_FROM_LABSMITH_FORGEKIT_BOOTSTRAP.md` — ForgeKit SPM dependency playbook
- `@Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` — DN cast (voice mentors)
- `@Docs/HANDOFF_FROM_LABSMITH_DN_S_STORY_PER_CHARACTER.md` — DN-S chapter-depth backstories
- `@Docs/HANDOFF_FROM_LABSMITH_DN_S_AI_MENTOR_VOICING.md` — Move D CastDialog voicing
- `@Docs/HANDOFF_FROM_LABSMITH_AVATAR_SIMPLIFIED_MIGRATION.md` — Avatar editor adoption
- `@.claude/rules/forgekit.md` § Module Catalog — ForgeKit 0.99 surface
- `@.claude/rules/state-machines.md` — `DialogueTreeMachine` pattern
- `@.claude/rules/foundationmodels.md` — `@Generable` + fallback discipline
- `@.claude/rules/xcode-agent-safety.md` — what files the agent may NOT write
