---
status: PRESERVED FROM PRIOR CLAUDE.md
preserved-date: 2026-06-08
preserved-from: CLAUDE.md (v1, 18-section template)
preserved-to-v2: CLAUDE.md (v2, 5-section template) per Docs/RESEARCH_CLAUDE_MD_BEST_PRACTICES_2026-06-08
---

# DialogueQuest — preserved app-specific notes (from prior CLAUDE.md)

This file holds content preserved from the pre-2026-06-08 CLAUDE.md (the 18-section v1 template). Per the CLAUDE.md best-practices research, the v2 template delegates portfolio-wide content to `@.claude/rules/` (auto-loaded) and per-app design content to per-app `Docs/*.md` files referenced via `@import`. This file holds the latter pending per-section review + relocation to the right destination.

**Recommended next steps for this file**:

1. Identify which sections of the preserved content are genuinely app-specific (architecture / domain patterns / app-specific gotchas / app-specific limitations) and KEEP them here OR migrate them to topic-specific docs:
   - Architecture → `Docs/TECHNICAL_DESIGN.md`
   - Domain patterns → `Docs/DOMAIN_PATTERNS.md`
   - Parent / educator integration → `Docs/PARENT_EDUCATOR_INTEGRATION.md`
   - Onboarding design → `Docs/ONBOARDING_DESIGN.md`
   - Engagement / retention → `Docs/ENGAGEMENT_RETENTION.md`
2. Identify which sections duplicate portfolio-wide rules (concurrency / SwiftData / SwiftUI / testing / Workflow / COPPA) and DELETE them (the rules in `@.claude/rules/` already auto-load).
3. Once review is complete, update `CLAUDE.md`'s `App-Specific Conventions` section with 3-8 bullets summarizing the actual app-specific differentiators.

---

## Preserved content (verbatim from prior CLAUDE.md)

# DialogueQuest

Branching-dialogue craft workshop for tweens. Write a conversation, not a paragraph: each line scored for voice consistency, subtext, tag balance, and branch meaningfulness.

**Status**: Pre-implementation scaffold. See @Docs/README.md for the labsmith concept doc + Phase 1 entry point. **Full Tier 2 doc set is pending**: TECHNICAL_DESIGN.md, FEATURE_PLAN.md, CONTENT_STYLE_GUIDE.md, TESTING_STRATEGY.md, PERFORMANCE_BUDGET.md, KIDSAFE_PREPARATION.md, DOCUMENT_CATALOG.md (per `labsmith/Docs/PORTFOLIO_PATTERNS.md` Documentation Maturity Tier 2). Labsmith authors these in a future wave; this repo is bootstrap-only.

**Wave**: Wave 6 (writing-craft cluster) per `labsmith/Docs/PLAN_WRITING_CRAFT_CLUSTER.md` or related cluster plan.

**Hero color**: `#A05A4B`
**Mascot**: Patter (chunky-cartoon flat-vector, shipped at `Resources/Illustrations/mascots/patter_encouraging.webp`).

## Tech Stack (portfolio standard)

- **Language**: Swift 6 (strict concurrency)
- **UI**: SwiftUI (menus, HUD, overlays)
- **Rendering**: SwiftUI + SpriteKit + SpriteView (gameplay surfaces). SceneKit prohibited (deprecated WWDC25)
- **AI Mentor**: FoundationModels (on-device, `@Generable` types)
- **Persistence**: SwiftData (`@Model`, `@Relationship`)
- **Minimum Target**: iOS 26
- **IDE**: Xcode 26
- **Testing**: Swift Testing framework (`@Test`, `#expect`)
- **No Combine**: Async/await only
- **Linting**: SwiftLint SUSPENDED (crashes on Xcode 26). Config retained in `.swiftlint.yml`; rules enforced manually
- **Architecture**: App shell + local Swift Package (all code in `Libraries/Package.swift`)
- **Concurrency**: MainActor default, approachable concurrency enabled

## Commands

```bash
# Build (iOS Simulator) — once Xcode project is created in Phase 1
xcodebuild -workspace DialogueQuest.xcworkspace -scheme DialogueQuest -destination 'platform=iOS Simulator,name=iPhone 17' build
```

## Cross-Repo

- **Concept doc** (labsmith): `labsmith/Docs/DialogueQuest/README.md`
- **ForgeKit** (shared SPM): `../forgekit/`
- **AdventureHub HubContribution**: `labsmith/Resources/HubContributions/dialoguequest.json`
- **Portfolio patterns**: `../labsmith/Docs/PORTFOLIO_PATTERNS.md`
- **Portfolio rules**: `.claude/rules/` (synced from labsmith)

## Reference Documents

| Document | Status | Purpose |
|---|---|---|
| @Docs/README.md | ✓ scaffolded | Index + labsmith concept-doc pointer |
| @Docs/IMPLEMENTATION_HANDOFF.md | ✓ scaffolded | Phase 1 entry point + scope (placeholder) |
| Docs/TECHNICAL_DESIGN.md | pending | Architecture + data models |
| Docs/FEATURE_PLAN.md | pending | Phased delivery roadmap |
| Docs/CONTENT_STYLE_GUIDE.md | pending | AI mentor voice + tone |
| Docs/TESTING_STRATEGY.md | pending | Swift Testing patterns |
| Docs/PERFORMANCE_BUDGET.md | pending | Launch / memory / FPS targets |
| Docs/KIDSAFE_PREPARATION.md | pending | COPPA + parental gate |
| Docs/DOCUMENT_CATALOG.md | pending | Self-referential doc index |

## Known Limitations

- **No Xcode project yet** — bootstrap only. Phase 1 implementation session creates the project per `labsmith/Docs/PORTFOLIO_PATTERNS.md` § Implementation Prep Checklist
- **No Question Kits yet** — labsmith authors `Resources/Questions/dialoguequest/kit_NN_*.json` in a future wave
- **No additional mascot poses** — only `encouraging` ships; remaining 4 (demonstrating, praising, thinking, working) generate in a future wave (~$1.08 cost ceiling per app)

## Workflow

This is a docs-only scaffold today. When the implementing CC session opens this repo:

1. Read `Docs/IMPLEMENTATION_HANDOFF.md` first
2. Read the labsmith concept doc at `labsmith/Docs/DialogueQuest/README.md` for full vision
3. Follow the Implementation Prep Checklist in `labsmith/Docs/PORTFOLIO_PATTERNS.md` (Steps 3-7: create Xcode project, SPM package, stub files, build, begin Phase 1)
4. Author the pending Tier 2 docs as you go (or request labsmith to author them via a `Docs/HANDOFF_FROM_APP_TIER2_DOCS.md` request)

