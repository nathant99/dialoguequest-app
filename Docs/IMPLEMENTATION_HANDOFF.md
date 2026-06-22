---
status: ACTIVE
date: 2026-06-22
direction: hub → app (filled in by engineering session)
target-audience: any future Claude Code session opening this repo
freshness-horizon: 60 days
---

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

Pin: `from: "0.99.0"`. Per-target wiring (canonical):

| Target | Modules | Notes |
|---|---|---|
| `Models` | `ForgeModels` | Foundational types (StudentProfile, BloomLevel, GradeLevel) |
| `Services` | `ForgePersistence` + `ForgeAI` + `ForgeAnalytics` | SwiftData container + on-device AI helpers + privacy-first analytics |
| `SharedUI` | `ForgeUI` + `ForgeAccessibility` | Theme protocol + 11 reusable components + COPPA consent + session timer |
| `AIMentor` | `ForgeAI` | LanguageModelSession lifecycle |
| `AppFeature` | `ForgeNavigation` + `ForgeAdventure` + `ForgeAvatar` + `ForgeCelebration` + `ForgeGamification` + `ForgePedagogy` + `ForgeStateMachine` | Root nav + Word Workshop adventure mode + Avatar editor + celebration orchestration + XP/streak/achievements + Bloom-level scaffolding + DialogueTreeMachine helper |

Modules **deferred to Phase 2+**: `ForgeContent` (hub kit distribution), `ForgeReporting` (parent dashboard), `ForgeSync` (cross-app progression), `ForgeClassroom` (Phase 4 classroom mode).

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
