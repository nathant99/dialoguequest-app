# DialogueQuest — Technical Design

**Status**: Pre-implementation scaffold (Tier-D). Implementing session will flesh this out per Phase 1.
**Concept source**: [`Docs/README.md`](README.md) (copy of labsmith `Docs/DialogueQuest/README.md`)
**Primitive**: branching dialogue craft (the kid writes a conversation, not a paragraph)
**Curriculum**: CCSS.ELA-Literacy.W.6-8.3.B (narrative dialogue), CCSS.ELA-Literacy.RL.6-8.6 (point of view + perspective), NCAS TH:Cr3 (theater script development), NCAS LA:Cr2 (literary craft)
**Primary standard mapping**: CCSS.ELA-Literacy.W.6-8.3.B

## SPM Module Architecture

Per `.claude/rules/spm-architecture.md`. Standard targets:

| Target | Purpose | Dependencies |
|---|---|---|
| `Models` | Domain models, SwiftData `@Model` classes, value-type cache structs | `ForgeModels` |
| `Services` | Persistence, audio, networking, AI session management | `Models`, `ForgePersistence`, `ForgeAI` |
| `SharedUI` | Reusable SwiftUI components, dialogue-tree graph editor, ForgeUI theme integration | `Models`, `ForgeUI` |
| `AIMentor` | FoundationModels `@Generable` types, Patter mentor session, subtext-detection prompts | `Models`, `ForgeAI` |
| `AppFeature` | Root view, navigation, app coordinator | All above + `ForgeAdventure` + `ForgeCelebration` |

ForgeKit deps live on `AppFeature` only (matches labsmith-app pattern); intermediate targets are deps-free for faster incremental compilation.

## ForgeKit Module Integration

Pinned at `from: "0.99.0"`. Modules:

- `ForgeUI`
- `ForgeNavigation`
- `ForgePedagogy`
- `ForgeGamification`
- `ForgeAccessibility`
- `ForgeAdventure`
- `ForgeAI`
- `ForgeAvatar`
- `ForgePersistence`
- `ForgeAnalytics`
- `ForgeModels`
- `ForgeCelebration`
- `ForgeStateMachine` (for dialogue-tree navigation)

See @CLAUDE.md § ForgeKit Module Integration for the per-module rationale.

## Domain Model

The DialogueQuest domain model centers on **branching dialogue craft** — a tree of speech nodes between 2-3 characters, with each line scored on voice consistency, subtext, tag balance, and branch meaningfulness. The implementing session will translate this into Swift types per Phase 1. Suggested type sketches (revise during implementation):

### Value types (Sendable, nonisolated)

```swift
// Models target — placeholder shape, refine in Phase 1
nonisolated public struct DialogueNode: Codable, Sendable, Identifiable {
    public let id: UUID
    public let speakerID: UUID            // imported CharacterForge character OR locally defined
    public let surfaceText: String
    public let inferredSubtext: String?   // AI-surfaced; kid confirms/rejects
    public let tag: DialogueTag           // .said(String) / .action(String) / .unattributed
    public let children: [UUID]           // branch points; UUIDs into the same tree
    public let createdAt: Date
}

nonisolated public enum DialogueTag: Codable, Sendable {
    case said(String)
    case action(String)
    case unattributed
}

nonisolated public struct DialogueTree: Codable, Sendable, Identifiable {
    public let id: UUID
    public let title: String
    public let characters: [DialogueCharacterRef]
    public let nodes: [DialogueNode]
    public let rootNodeID: UUID
    public let mood: DialogueMood?
}
```

### SwiftData @Model classes (MainActor)

```swift
// Models target
@Model
public final class PersistentDialogueTree {
    public var id: UUID = UUID()
    public var encodedTreeData: Data = Data()  // JSON-encoded DialogueTree
    public var lastEditedAt: Date = Date()
    public init() { }
}
```

Implementing session decides exact storage strategy (single `@Model` wrapping JSON vs split node-level rows). Per `.claude/rules/swiftdata.md`: never `@Query` in views; cache to value-type structs in `onAppear`.

## New Engines (App-Specific)

- **DialogueEngine** — tree navigation + branch-meaningfulness scoring (3-question check per branch point) + voice consistency cross-line analysis + tag balance dashboard. Reuses CharacterForge's `VoiceCheck` API via shared `WritingEvaluator` extension.
- **SubtextDetector** — FoundationModels `@Generable DialogueLineAnalysis` (surface text + AI-inferred subtext + voice-match score). Kid confirms or rejects; reflective Socratic ladder.
- **TagBalancer** — counts `"X said"` vs unattributed lines vs descriptive beats; warning ribbons when imbalance crosses thresholds.

Each engine lives in its own SPM target or is folded into `Services` per Phase 1 complexity.

## Phase 1 Scope (engineering breakdown)

- Two-character dialogue builder (5-15 node tree with named character roles; import from CharacterForge OR locally defined)
- Branch-meaningfulness check (3-question Socratic prompt at each branch point; 1-line reflection)
- Voice consistency feedback (per-character cumulative voice check across the tree)
- Subtext panel (side panel showing surface + AI-inferred subtext; kid confirms/rejects)
- Tag balance dashboard (bar chart per character; warning ribbons on imbalance)
- Anthology gallery (mood-tagged completed trees)
- Export hook to TaleForge / CharacterForge anthology

See @Docs/FEATURE_PLAN.md for the full phased roadmap.

## Adventure Mode Integration

Contributes to **Word Workshop** zone in AdventureHub. Level 1 config (canonical JSON) lives at `labsmith/Resources/HubContributions/dialoguequest.json`; Level 2 Swift overlay (this repo) lives at `Libraries/Sources/AppFeature/HubContribution/DialogueQuestHubContribution.swift` per `Docs/AMENDMENTS_ADVENTUREHUB_SOURCE_OWNED_UI.md`.

## Home Screen & Navigation

4-tab `TabView` per portfolio convention:

- **Write**: core dialogue-tree builder loop
- **Adventure**: Word Workshop mode-cards (gated via `ForgeProgressionManager`)
- **Progress**: streak, XP, badge gallery, dialogue-craft attunement chart
- **Profile**: avatar via `ForgeAvatar.AvatarStudioView(.lite)`, settings, parental controls

## Full-App UI/UX Patterns

- **DialogueTreeMachine** struct (per `.claude/rules/state-machines.md`) for view-local state in tree navigation
- **Graph editor**: SwiftUI 2-D node-edge editor (reuses CharacterForge's relationship-graph patterns)
- **Feedback sequences**: `.correctFeedback(isActive:)` / `.incorrectFeedback(isActive:)` from ForgeUI for branch-meaningfulness reflections
- **Results animation**: spring + scale via `ForgeCelebration.CelebrationCoordinator`
- **Onboarding**: `ForgeOnboardingFlow.Page` builder; first 60 seconds reach the aha moment (write one 2-character exchange)

## Child Safety & Privacy Architecture

| Channel | Data classification | Storage | Outbound? |
|---|---|---|---|
| Dialogue tree content | App-internal | SwiftData (local) | No (export to TaleForge is opt-in user action) |
| Mentor dialogue context | App-internal | In-memory only | No |
| Achievement badges | App-internal | SwiftData (local) | No |
| Parental consent records | Required for COPPA audit | SwiftData (local, 12-month expiry per FTC 2026) | No |

See @Docs/KIDSAFE_PREPARATION.md for the full plan.

## Parent & Educator Integration

- `ProgressReportService` standards-mapped to **CCSS.ELA-Literacy.W.6-8.3.B**
- `ParentalControlsManager`: session limits, content filters, dashboard
- Teacher dashboard data model: weekly summary, anonymized class-wide trends (no per-student PII)

## Onboarding & First-Time Experience

See @CLAUDE.md § Onboarding for the First 60 Seconds timeline. Aha moment: kid writes one 2-character exchange with at least one branch and sees Patter (mascot) acknowledge the branch as meaningful.

## Engagement & Retention Engine

- `ForgeGamification.StreakManager` with streak freezes + `heldUnderDistress` (0.86 case)
- `ForgeGamification.XPEngine` for level progression
- `DDAEngine` (TBD or per Phase 2) for invisible difficulty calibration on the branch-meaningfulness threshold
- Variable-ratio reward schedule via `CelebrationCoordinator` (per labsmith `DESIGN_FORGEADVENTURE_API_SPECS.md`)

## Delight & Emotional Design

- 8 micro-delight types per `labsmith/Docs/TEMPLATE_EXCELLENCE_ADDITIONS.md`
- Mascot (Patter — two-toned speech bubble with wobbly tail) reaction animations on key transitions
- Hero color `#A05A4B` (Conversation rust) used judiciously — primary CTA, mascot background, ForgeAdventure zone tag

## Analytics & Instrumentation

- Privacy-first on-device analytics via `ForgeAnalytics`
- MetricKit for crash + performance reporting (no PII)
- Feature flags via `ForgeExperiments` (COPPA-safe on-device A/B)
- **No third-party analytics SDKs** — no Firebase, no Mixpanel, no Amplitude

## Trauma-Informed Design Posture (if applicable)

Not in scope for DialogueQuest Phase 1 (no trauma-adjacent content). Branch-meaningfulness reflections follow validate-then-inform tone — never grade-down for emotional dialogue content.

## Open Questions / Decisions Pending

Implementing session resolves these in Phase 1 design:

1. Exact SwiftData storage strategy for dialogue trees (single `@Model` wrapping JSON vs split node-level rows)
2. AI prompt-engineering pass for Patter persona (use `labsmith/Docs/TEMPLATE_MASCOT_PROMPT.md` voice guidance)
3. Specific `ForgeProgressionManager` unlock schedule (which Phase 1 features gate behind which session count)
4. Asset bundle plan (mascot poses arrive via labsmith handoff; topic illustrations deferred per portfolio convention)
5. CharacterForge import API surface — does DialogueQuest pull `CharacterForgeSession` directly, or does CharacterForge expose a `package`-level `CharacterRef` export?
6. Subtext panel UX — always-visible side panel vs on-tap-reveal vs separate "review pass" mode
