# Handoff from Labsmith — Pillar Deepening: DialogueQuest (C5 Collaborative / Co-authored Dialogue)

Direction: **labsmith → dialoguequest-app**. Round 82 #425 Wave 1 ships **C5 (Collaborative / Co-authored Dialogue)** as the recommended Writing-craft + Together cluster deepening move for DialogueQuest. Dialogue exchanges (two characters in turn) are the canonical use case for C5 per `PLAN_PILLAR_DEEPENING_METHODOLOGY.md` § 2.2. This handoff specifies how to wire the move against DialogueQuest's existing surfaces.

**Filed**: 2026-05-26
**Round**: 82 queue #425 (Wave 1 — Writing-craft + Together cluster)
**Cluster wave**: Part of Round 82 #425 Wave 1 (Writing-craft + Together cluster batch)
**Companion docs (labsmith)**: `labsmith/Docs/PLAN_PILLAR_DEEPENING_METHODOLOGY.md` (§ 2.2 C5) + `labsmith/Docs/AUDIT_PILLAR_DEEPENING_PER_APP.md` (per-app row for dialoguequest)

---

## § 1 — Header: app context

| Field | Value |
|---|---|
| **App slug** | `dialoguequest` |
| **App name** | DialogueQuest |
| **DN cluster** | Writing-craft + Together (§ 2.2) |
| **DN status** | Distributed-narrative handoff shipped — writing-craft Pattern B per `Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` |
| **Mentor pattern** | Pattern B (hero-mascot-led) |
| **AI mentor** | per app's DN handoff |
| **Current pillar profile (audit)** | Create-PRIMARY |
| **Trauma-informed status** | per app's per-cluster TI status |
| **Implementation tier** | Docs-only / pre-scaffolding (verify Phase 1 scaffolding before adoption) |
| **App-side blockers** | Phase 1 scaffolding (Xcode project + Libraries SPM) precedes this work where applicable. **Build-ready when Phase 1 lands.** |

---

## § 2 — Why this deepening move now

DialogueQuest's primary surface (dialogue exchanges (two characters in turn)) is **the canonical use case for C5** per `PLAN_PILLAR_DEEPENING_METHODOLOGY.md` § 2.2.

Writing-craft + Together cluster rationale (per `AUDIT_PILLAR_DEEPENING_PER_APP.md` § 2.2):

- The recommended top-move for DialogueQuest per the audit catalog is C5 (this move).
- All required ForgeKit primitives shipped (see § 4 dependency check).
- The cast (from DN handoff) anchors the primitives this move surfaces; per the `writing-craft Pattern B` DN pattern, the cast either stays as the protagonist (Pattern B) or supports the mentor (Standard variant).

**Strategic frame** (from methodology § 1.1):

> Adopting C5 achieves: modes.together: 0 → 1 (collaborative co-authoring).

---

## § 3 — The move

**Move identifier**: `C5`
**Move name**: Collaborative / Co-authored Dialogue
**Pillar(s) deepened**: **Create** + **Together**
**Score delta**: modes.together: 0 → 1 (collaborative co-authoring)

### 3.1 What the move IS (operational definition)

1. **Two-or-more-kid collaborative composition** on one device (pass-and-play) OR asynchronous (family-shared library).
2. **Pass-and-play turn structure**: Kid A composes the first contribution; device passes to Kid B (or parent); Kid B adds the next; continues until the artifact is complete. Privacy-curtain between turns per `ForgePassAndPlay` 4-stage curtain.
3. **Cast-anchored turn prompts**: Each cast member voices a turn-specific prompt (e.g., 'now Kid B, add a contrasting response'). The cast IS the collaborative scaffold.

### 3.2 What the move IS NOT (anti-pattern guard)

- ❌ **Online multiplayer with strangers** — COPPA-bound; pass-and-play is device-local OR family-shared via async library.
- ❌ **Chat free-text between kids** — enum-based message types only per `.claude/rules/multipeer.md`.
- ❌ **Mandatory peer collaboration** — solo path always available; collaboration is opt-in.
- ❌ **Winner-loser framing** — collaboration is non-competitive by design. Resnick 'Peers' stage.

### 3.3 Evidence baseline (from methodology § 2.2)

- **Resnick — Lifelong Kindergarten** — Peers stage of creative spiral; collaboration deepens engagement.
- **Kafai & Burke — Connected Code** — connected-gaming + collaborative-agency literature.
- **Hirsh-Pasek et al. — 4 Pillars** — social interaction (4th pillar) drives durable learning.
- **Wouters et al. 2013** — collaborative-game effects > solo for retention (d=0.36).

---

## § 4 — ForgeKit dependency check

**Verified against `forgekit/Docs/CHANGELOG.md` (0.94.0 current).** All primitives SHIPPED.

| Primitive | Status |
|---|---|
| `ForgePassAndPlay` (pass-and-play state machine + 4-stage privacy curtain) | ✅ 0.89 |
| `ForgeMultipeerKit` (LAN sync — if async) | ✅ shipped |
| `ForgeUI.PrivacyCurtainView` | ✅ shipped |
| `ForgePartyGames` (turn-based mini-game state machines as reference) | ✅ shipped |
| `ForgeAccessibility` (parental consent for any external share) | ✅ shipped |

**Pin recommendation**: When `Libraries/Package.swift` is scaffolded, pin **`from: "0.94.0"`** to pick up all current ForgeKit primitives.

---

## § 5 — Implementation Phase A-D

### Phase A — Design finalization (1-2 days)

- [ ] Decide turn structure: fixed N turns? Variable until "done"? Round-robin vs role-asymmetric?
- [ ] Identify cast-anchored turn prompts: which cast members voice which turn (per DN handoff)
- [ ] Confirm privacy curtain stages: 4-stage standard per `ForgePassAndPlay` (handoff → curtain → reveal → next-turn)
- [ ] Confirm UI surfaces: pass-prompt, curtain, role-indicator, completed-artifact view

### Phase B — Core wiring (3-5 days)

- [ ] Wire `PassAndPlaySession` state machine + 4-stage curtain
- [ ] Add per-turn cast-anchored prompts (rendered via mentor session)
- [ ] Persist completed artifacts as `@Model` `CollaborativeArtifactRecord`
- [ ] Update CLAUDE.md § 9: `ForgePassAndPlay` curtain state-transition gotchas; turn-passing race conditions

### Phase C — Surface + Asset Consumer Audit (3-5 days)

- [ ] Add gallery view of completed collaborative artifacts (grouped by date)
- [ ] Wire export sheet (PDF / WebP / MP4 depending on artifact type)
- [ ] **Asset Consumer Audit** per `.claude/rules/portfolio.md`:
  - `grep -rE 'PassAndPlaySession|PrivacyCurtain|CollaborativeArtifactRecord' Libraries/Sources/`
  - At least ONE view renders the curtain + collaborative editor + gallery

### Phase D — Instrumentation + accessibility (2-3 days)

- [ ] Wire `ForgeAnalytics`: `collab.session.started` / `collab.turn.completed` / `collab.artifact.shared`
- [ ] All events local-only per `.claude/rules/age-assurance.md`
- [ ] Document family-engagement claim: "DialogueQuest kids run N collaborative sessions per week on average"
- [ ] Accessibility audit: VoiceOver curtain transitions; reduced-motion mode

**Total estimate**: ~8-14 days per-app session work (assumes Phase 1 scaffolding complete).

---

## § 6 — Code-shape sketch

See per-move code-shape examples in:
- `labsmith/Docs/TEMPLATE_IMPLEMENTATION_HANDOFF_PILLAR_DEEPENING.md` § generic skeleton
- `labsmith/Docs/PLAN_PILLAR_DEEPENING_METHODOLOGY.md` § 2.2 for the C5 concrete primitives

Apply per-app customization in Phase B per `.claude/rules/spm-architecture.md` + `.claude/rules/concurrency.md` (mark Sendable value types `nonisolated`; `@Model` migrations per `.claude/rules/swiftdata.md`).

---

## § 7 — Failure-mode tests

### Universal failure-mode tests (apply to every deepening move)

1. **Cluster-coherence** — does this move work alongside the rest of the Writing-craft + Together cluster recipe? **YES**: cluster § 2.2 top-3 moves include C5; orthogonal to companion moves.
2. **Anti-dilution guard** — does this move push DialogueQuest toward 3+ pillars at 2+? **Verify per § 1**: modes.together: 0 → 1 (collaborative co-authoring).
3. **ForgeKit version verification** — was `forgekit/Docs/CHANGELOG.md` actually pulled + read? **YES**: 0.94.0 verified; primitives shipped + APIs match.
4. **Asset consumer audit** — at least one view actually renders the move surface. **PHASE C CHECKPOINT** (grep above).
5. **Score-delta accuracy** — does the proposed score delta match methodology § 2.2? **YES**: documented above.

### Move-specific failure-mode tests (C5)

6. **Curtain integrity test**: between turns, Kid B cannot see Kid A's contribution mid-curtain (4-stage `ForgePassAndPlay` curtain).
7. **Solo path test**: kid CAN complete the artifact without inviting a partner — collaboration is opt-in.
8. **Turn-prompt freshness test**: cast-anchored prompts vary per turn; not the same prompt repeated.
9. **Parent-share COPPA gate**: external-share routes through `ParentalConsentService`.
10. **Non-competitive framing test**: mentor never says "Kid A wins"; collaboration is non-competitive.
11. **Async sync test**: if using `ForgeMultipeerKit`, COPPA-compliant peer-name sanitization per `.claude/rules/multipeer.md`.
12. **Privacy-curtain ritual-level test**: `PrivacyCurtain.RitualLevel` (pending 0.88 DyadicPair per `AUDIT_FORGEPARTYGAMES_MATURITY.md`) for dyadic ritual variations — verify before adoption.

---

## § 8 — Cross-references

### Labsmith
- `Docs/PLAN_PILLAR_DEEPENING_METHODOLOGY.md` § 2.2 (C5 move definition)
- `Docs/AUDIT_PILLAR_DEEPENING_PER_APP.md` § 2.2 + per-app row for dialoguequest
- `Docs/AUDIT_PORTFOLIO_PILLAR_TAGGING.md` — current pillar profile
- `Docs/RESEARCH_DISTRIBUTED_NARRATIVE_PORTFOLIO_EXPANSION.md` — DN methodology + cluster cast roster
- `Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` — canonical cast registry (if cross-app cameos involved)
- `.claude/rules/forgekit.md` — ForgeKit module reference
- `.claude/rules/swiftdata.md` — schema versioning rules
- `.claude/rules/ai-content.md` — validate-first AI tone rule
- `.claude/rules/distributed-narrative.md` — DN methodology rules (writing-craft Pattern B)
- `.claude/rules/portfolio.md` — Asset Consumer Audit rule + asset-delivery handoff rule

### App repo
- `Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` — cast roster + per-primitive embodiment
- `Docs/HANDOFF_FROM_LABSMITH_DN_ENHANCEMENT.md` — second-pass DN
- `Docs/IMPLEMENTATION_HANDOFF.md` — Phase 1 scaffolding baseline
- `Docs/TECHNICAL_DESIGN.md` — domain models reference
- `CLAUDE.md` — app overview + 18-section template

### ForgeKit
- `forgekit/Docs/CHANGELOG.md` — version log (currently 0.94.0)
- relevant modules per § 4 above

### External research
- Resnick *Lifelong Kindergarten* — Peers stage of creative spiral
- Kafai & Burke *Connected Code* — connected-gaming collaborative-agency literature
- Hirsh-Pasek et al. — 4 Pillars (social interaction, 4th pillar)
- Wouters et al. 2013 meta-analysis — collaborative > solo game effects d=0.36

---

## § 9 — Sequencing for app session

1. **Read this handoff in full** (15 min)
2. **Read methodology** in `labsmith/Docs/PLAN_PILLAR_DEEPENING_METHODOLOGY.md` § 2.2 for C5 (15 min)
3. **Read Writing-craft + Together cluster recipe** in `labsmith/Docs/AUDIT_PILLAR_DEEPENING_PER_APP.md` § 2.2 (5 min)
4. **Verify Phase 1 scaffolding** is complete (Xcode project + `Libraries/Package.swift` present)
5. **Pin ForgeKit** `from: "0.94.0"` in `Libraries/Package.swift`
6. **Plan-mode session** (30-45 min) — work through Phase A design questions
7. **Phase A** → **Phase B** → **Phase C** → **Phase D** per § 5
8. **Asset Consumer Audit** at Phase C checkpoint (grep + render verification per `.claude/rules/portfolio.md`)
9. **Mark handoff CLOSED**

### Post-completion checklist

- [ ] Build zero errors zero warnings
- [ ] Unit tests pass per § 7 failure-mode tests
- [ ] UI tests pass: per-move surfaces
- [ ] CLAUDE.md § 9 Things-That-Will-Bite-You updated with move-specific gotchas
- [ ] FEATURE_PLAN.md sub-phase marked complete
- [ ] `apps.generated.ts` modes score updated by labsmith per § 3 score-delta

---

## § 10 — Labsmith follow-up after app session ships

1. Labsmith updates `apps.generated.ts` DialogueQuest modes score per § 3
2. Labsmith updates `AUDIT_PILLAR_DEEPENING_PER_APP.md` row — mark `next_step` as "Adopted YYYY-MM-DD"
3. Labsmith files cluster-wave-2 inbound for next-app in the Writing-craft + Together cluster (if any remain)
4. If pilot reveals a gap in methodology, labsmith updates `PLAN_PILLAR_DEEPENING_METHODOLOGY.md` § 2.2

---

**End of pillar-deepening handoff.**

**Wave status**: Round 82 #425 Wave 1 — Writing-craft + Together cluster batch. Per-app sessions begin implementing post-handoff once Phase 1 scaffolding lands.
