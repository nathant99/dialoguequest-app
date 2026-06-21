---
status: CLOSED
date: 2026-06-19
closed-at: 2026-06-21
direction: hub → app
intent: engineering kickoff — dialoguequest sits in the Tier 3 ELA cluster cohort (composite 60.0) on the 2026-06-19 docs-only ranking; full docs-only stack shipped but IMPLEMENTATION_HANDOFF.md is a stub awaiting Tier-2 doc-wave fill-in
freshness-horizon: 14 days
---

# Handoff from Hub — DialogueQuest Engineering Kickoff

> **STATUS — CLOSED 2026-06-21**: Phase 0 (full `IMPLEMENTATION_HANDOFF.md` fill-in per the 9-section pattern) shipped in `Docs/IMPLEMENTATION_HANDOFF.md` 2026-06-19 (engineering session authored in-session — hub fill-in not needed). Step 0 ForgeKit bootstrap shipped PR #21 (`Libraries/Package.swift` pinned `from: "0.99.0"`, 9 client modules + 4 server-shared on `AppFeature`; remote-URL pattern). Steps 1-N Phase 1 feature work substantially shipped via PRs #22–#41 (Models / Services / SharedUI / AIMentor / AppFeature / RootView / DialogueTreeMachine / 4 question kits / PatterMentor + 3 @Generable + fallbacks / 5 cast chapters / onboarding / progressive-disclosure / progress + profile + settings tabs / quiz machine / Liquid Glass auto-adoption / clean SPM test target wiring). Pattern B + R-DN-PARITY swap test confirmed via cast-as-friends framing of brogue / glance / rest / sprig / weigh embodying distinct dialogue-craft primitives (already documented in `IMPLEMENTATION_HANDOFF.md` § 5). This handoff is preserved as historical kickoff context.

Direction: **hub → app**. The docs-only phase is complete on the content axes; the engineering CC session can open dialoguequest in Xcode and begin Phase 1 implementation — BUT must first author the full `IMPLEMENTATION_HANDOFF.md` content per the standard 9-section pattern (it's a stub today).

## Why this kickoff is happening now

Per the 2026-06-19 docs-only ranking refresh (`spark-anvil-hub/Docs/AUDIT_DOCS_ONLY_APP_RANKING_2026-06-19.md`), dialoguequest sits in the **Tier 3 ELA cluster cohort at composite 60.0** — alongside characterforge / haikuquest / lyricforge / voicetale.

## Cluster context — ELA writing-craft cluster (Pattern B)

DialogueQuest sits in the **ELA writing-craft cluster** with 4 sibling apps. Per `.claude/rules/distributed-narrative.md` § "Hero mascot vs. cast", Pattern B applies — hero mascot stays PRIMARY protagonist; cast members (brogue / glance / rest / sprig / weigh) are explicitly framed as the hero's friends who each embody one dialogue-craft primitive. **Pattern B verification is FLAGGED for engineering session per predecessor's Wave 3 ELA audit** — confirm cast members embody distinct dialogue craft primitives.

## What hub has shipped (content + handoff inventory)

### Content (`Resources/`)

| Class | Count |
|---|---|
| Audio dramas | 14 |
| Cast portraits | 5 |
| Custom art (book covers) | 2 |
| Illustrations | 15 |
| Companion pack | 4 |
| Chapter MDs | 5 (`Docs/dn-s/chapters/{brogue,glance,rest,sprig,weigh}.md`) |

### Per-axis handoff docs (13 total)

| Handoff | What it covers |
|---|---|
| `HANDOFF_FROM_LABSMITH_FORGEKIT_BOOTSTRAP.md` | **Step 0** — read FIRST |
| `HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` | DN cast definition + Pattern B framing |
| `HANDOFF_FROM_LABSMITH_DN_ENHANCEMENT.md` | Cluster-coherence enhancements |
| `HANDOFF_FROM_LABSMITH_DN_S_STORY_PER_CHARACTER.md` | Chapter-depth (800-1500w) per character + Tier-2 advanced |
| `HANDOFF_FROM_LABSMITH_DN_SECOND_PASS_DEEPENING.md` | Cast pacing schedule |
| `HANDOFF_FROM_LABSMITH_DN_S_AI_MENTOR_VOICING.md` | Move D voicing for hero mascot + cast (R-CASTDIALOG-ASKS-QUESTIONS 3:1 asks-vs-states) |
| `HANDOFF_FROM_LABSMITH_DN_S_AUDIO_DRAMA_WEIGH.md` | Per-character audio drama (weigh focal) |
| `HANDOFF_FROM_LABSMITH_CHAPTER_ILLUSTRATIONS_WAVE.md` | Path A → Path B multi-beat illustration consumption |
| `HANDOFF_FROM_HUB_CAST_PORTRAITS.md` | Cast portrait consumption + R-CAST-PORTRAIT-SLUG |
| `HANDOFF_FROM_HUB_BOOK_COVERS.md` | Per-app PDF book cover treatment |
| `HANDOFF_FROM_LABSMITH_AVATAR_SIMPLIFIED_MIGRATION.md` | Avatar editor (writing-craft cluster: `.full`-direct or R3 segmented recommended) |
| `HANDOFF_FROM_LABSMITH_COMPANION_PACK.md` | Parent letter + cast poster bundling |
| `HANDOFF_FROM_LABSMITH_PILLAR_DEEPENING_C5_COLLABORATIVE.md` | Pillar-deepening C5 — collaborative scene-writing surface (cross-cluster multi-author scaffold) |

## Implementation sequence

### Phase 0 — Author full `IMPLEMENTATION_HANDOFF.md` (PREREQUISITE)

The current `IMPLEMENTATION_HANDOFF.md` is a STUB ("Phase 1 Scope (Summary — Pending Detail)") awaiting Tier-2 doc-wave fill-in. Engineering session OR hub session must author the 9-section structure per `labsmith/Docs/PORTFOLIO_PATTERNS.md`:

1. Overview (dialogue-craft primitive)
2. Phase 1 Scope (specific surfaces to build)
3. Domain Types (`DialogueQuestSession` etc.)
4. Rendering Decision (SwiftUI only — no SpriteKit; pure interaction-driven)
5. AI Mentor Persona (mascot — pending detail; consult DN handoffs)
6. Question Kits / Content (Phase 1 inline scaffolds; hub kits lazy-not-eager)
7. ForgeKit Modules to Wire
8. Constraints (iOS 26 / Swift 6 / no Combine / etc.)
9. Definition of Done

If engineering session prefers to defer this to hub, file `Docs/HANDOFF_FROM_APP_IMPLEMENTATION_HANDOFF_FILL_IN.md` back to hub.

### Step 0 — ForgeKit Bootstrap (~30-60 min)

Per `HANDOFF_FROM_LABSMITH_FORGEKIT_BOOTSTRAP.md`. Pin: `from: "0.99.0"`. ELA cluster typically wires ForgeUI / ForgeNavigation / ForgePedagogy / ForgeGamification / ForgeAccessibility / ForgeAdventure / ForgeAI / ForgePersistence.

### Steps 1-N — Phase 1 feature work

To be defined in Phase 0 IMPLEMENTATION_HANDOFF.md fill-in. Initial estimate based on dialogue-craft primitive:

1. **Dialogue editor** — line-by-line authoring with speaker tags + voice-consistency feedback
2. **Scene structure builder** — beat-by-beat dialogue scene assembly
3. **AI voice-check** — @Generable `VoiceCheck` schema for per-speaker consistency
4. **Collaborative scene-writing** (C5 pillar deepening) — pass-and-play OR async multi-author scaffold
5. **Anthology of authored dialogue scenes** + cross-export to TaleForge / CharacterForge

## Reference impls from sister apps

| Sister app | Why relevant |
|---|---|
| CharacterForge | Closest cluster sibling — character craft pairs with dialogue craft; voice-check schema lifts |
| QuillSpell | Play-PRIMARY writing-craft register; 8-accessory portfolio-canonical pack; R3 segmented avatar |
| CuriosityQuest | ForgeKit bootstrap reference impl + Move D voicing pilot |

## Open questions for the engineering session

1. **Phase 0 fill-in ownership** — engineering session authors IMPLEMENTATION_HANDOFF.md OR hub authors? Recommendation: hub authors in next session if engineering session prefers (faster turnaround; hub has DN-S + Pattern B context).
2. **Pattern B verification** — predecessor's Wave 3 ELA audit flagged Pattern B verification for dialoguequest. Confirm hero mascot identity + cast-as-friends framing in DN handoffs vs current state.
3. **R-DN-PARITY swap test** — Predecessor Wave 3 ELA audit flagged R-DN-PARITY swap test as "needs manual review for dialoguequest". Verify each cast member (brogue / glance / rest / sprig / weigh) embodies one distinct dialogue-craft primitive.
4. **C5 collaborative pillar deepening** — `HANDOFF_FROM_LABSMITH_PILLAR_DEEPENING_C5_COLLABORATIVE.md` ships collaborative scene-writing scaffold. Phase 1 includes OR defers to Phase 2?
5. **Voice-check @Generable schema design** — share with CharacterForge for cross-cluster consistency? Recommend YES (one canonical `VoiceCheck` schema in shared module; both apps consume).

## What this doc does NOT cover

- **IMPLEMENTATION_HANDOFF.md content** — that's the Phase 0 stub-fill-in
- **Server-side work** — solo Phase 1 (no Tier 1/2 server cell)
- **App Store submission** — covered in Phase 1 DoD when authored

## Acceptance criteria (Phase 1 done state — pending IMPLEMENTATION_HANDOFF.md fill-in)

Standard Phase 1 DoD pattern (full list lives in IMPLEMENTATION_HANDOFF.md when authored):

- [ ] Build clean (all targets, zero warnings)
- [ ] Unit tests + UI tests covering dialogue editor + scene builder + voice-check
- [ ] First 60 seconds reaches aha moment (first authored dialogue line + mascot voice-check feedback)
- [ ] App icon (6-variant Liquid Glass set)
- [ ] COPPA-2025 parental consent functional
- [ ] Composable avatar editor adopts per cluster pattern
- [ ] Performance budget targets met
- [ ] CLAUDE.md § "Things That Will Bite You" updated

## Cross-references

- `spark-anvil-hub/Docs/AUDIT_DOCS_ONLY_APP_RANKING_2026-06-19.md` — Tier 3 ELA cluster placement
- `spark-anvil-hub/Docs/CONTEXT_HANDOFF_2026-06-19_THREE_WAVE_EXECUTION_CLOSE.md` — predecessor session close-out
- `spark-anvil-hub/.claude/rules/forgekit.md` — module catalog + 0.99.x API surface
- `spark-anvil-hub/.claude/rules/distributed-narrative.md` — DN methodology + DN-S + Pattern B writing-craft + R-CASTDIALOG-ASKS-QUESTIONS + R-DN-PARITY swap test
- `spark-anvil-hub/.claude/rules/workflow.md` — Definition of Done + auto-cycle + verify-PR-merged
- `labsmith/Docs/PORTFOLIO_PATTERNS.md` — 9-section IMPLEMENTATION_HANDOFF.md structure

---

**Welcome to engineering.** Phase 0 (full IMPLEMENTATION_HANDOFF.md fill-in) precedes Step 0 (ForgeKit bootstrap). Hub remains available to author Phase 0 fill-in on request via per-app handoff protocol.
