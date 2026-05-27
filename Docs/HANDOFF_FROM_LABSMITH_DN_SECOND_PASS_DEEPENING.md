# Handoff from Labsmith — DN Second-Pass Deepening (DialogueQuest)

Direction: **labsmith → app**. Codifies the DN-D second-pass deepening moves for DialogueQuest per `labsmith/Docs/AMENDMENTS_DN_METHODOLOGY_SECOND_PASS_DEEPENING.md` (Round 83 #432) — the methodology amendment that opened the depth axis after Round 73 closed the breadth axis at 100% first-pass DN coverage.

**Round / queue**: Round 85 #437 — Wave A distribution (writing-craft cluster).
**Status**: Plan-only. Labsmith does NOT modify Swift source / Xcode / app `CLAUDE.md`. The app's CC session integrates per Definition of Done § below.
**Companion docs**:
- `labsmith/Docs/AMENDMENTS_DN_METHODOLOGY_SECOND_PASS_DEEPENING.md` — the methodology amendment + 12-move DN-D catalog
- `labsmith/Docs/PLAN_DN_ENHANCEMENT_WRITING_CRAFT_CLUSTER.md` — cluster-level layered-enhancement plan
- `labsmith/Docs/GUIDE_DISTRIBUTED_NARRATIVE_METHODOLOGY.md` — first-pass methodology (PRESERVED)
- `dialoguequest-app/Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` — first-pass DN handoff this deepening BUILDS ON
- `labsmith/.claude/rules/distributed-narrative.md` — portfolio rule (sub-sections § Second-pass deepening conventions + § DN-richness rubric apply)


---

## § 1 — Why deepening, why now

DialogueQuest ships a first-pass DN cast per its existing `HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` (the Existing hero Bramble + dialogue-craft friends (subtext / attribution / beat / a layer) — call this the **LESSONS layer**. The first-pass cast is currently at DN-richness tier **3-4 baseline** (per `AMENDMENTS_DN_METHODOLOGY_SECOND_PASS_DEEPENING.md` § 5.1 rubric).

This handoff applies **5 DN-D second-pass deepening moves** to lift the cast from baseline (3-4) to **rich (5-6)**:

1. **DN-D2** storytime-methodology layered enhancement — adds a WORLD layer above LESSONS
2. **DN-D6** cluster-shared dramatic frames — names the shared universe across the writing-craft cluster
3. **DN-D1** cross-app cameo density extension — names 3 sibling-app cameo targets, density ≥3 cameos per app
4. **DN-D11** cross-cluster meta-bridges — names 2-3 explicit cross-cluster bridges to surface curricular transfer
5. **DN-D5** failure-mode test deepening — expands 6 → 8-12 tests with research-grounded calibration metrics

DN-D3 (cast-voice via FoundationModels) and DN-D12 (cast-encounter persistence) are SKIPPED in this wave — both BLOCKED on outbound ForgeKit handoffs (`ForgeAI.CastDialog` + `ForgePersistence.CastEncounter`) per `AMENDMENTS_DN_METHODOLOGY_SECOND_PASS_DEEPENING.md` § 8. Re-revisit when forgekit ships these primitives.

DN-D4 (cast progression) + DN-D7 (cross-cluster meta-cast threading) + DN-D8 (reader-role-play) + DN-D9 (cast portrait depth) + DN-D10 (cluster-shared cast canon) are deferred to a future deepening wave; this wave keeps the move set tractable per § 4 combination ceiling rule.

### Pattern: Pattern B (hero-mascot leads / cast = friends)

DialogueQuest runs Pattern B per `.claude/rules/distributed-narrative.md` § Hero mascot vs. cast — **Bramble stays the primary protagonist**, and the WORLD-layer + LESSONS-layer cast members are explicitly framed as Bramble's friends / colleagues. The deepening preserves Pattern B; cluster-shared voice-register WORLD-layer characters travel between apps as visiting friends, not as replacement protagonists.

---

## § 2 — Cluster-shared dramatic frame (DN-D6)

**The Story Forge** — a cluster-shared workshop / atelier where each app inhabits a named studio (lyric-loft / haiku-garden / character-studio / dialogue-stage / voice-amphitheatre / motif-loom / ink-press / tale-table / tale-trail / grammar-room / quill-scriptorium / read-library / lingua-bazaar / speak-podium / debate-arena). Heralda / Murmur / Quip Goodfellow / Vesperline travel between studios as cluster-shared voice-register WORLD-layer cast.

DialogueQuest's region within the frame: **DialogueQuest** — dialogue — subtext, attribution, beat structure, audience hearing.

Cluster-shared WORLD-layer cast that travels across all writing-craft-cluster apps:

| Cluster-shared character | Role |
|---|---|
| Heralda the Loud | Epic / High Heroic — third-person omniscient, traveling drum |
| Murmur | Lyric / Confessional — first-person present, leather-bound journal |
| Quip Goodfellow | Comic / Vernacular — wit-quick, neighborhood storyteller |
| Vesperline | Tragic / Pastoral — twilight-walker, handheld lantern |

These cluster-shared WORLD-layer characters use **shared canon** per DN-D10 (cluster-shared cast canon enforcement): same name + same visual treatment + same catchphrase across all cluster-sibling apps. Visual-asset generation for cluster-shared characters happens ONCE at the cluster level and propagates to all apps via the standard `copy_cast_to_repos.sh` pipeline.

---

## § 3 — Proposed WORLD-layer cast (DN-D2 — the load-bearing second-pass move)

Per the storytime-methodology layered-enhancement pattern (T1-T10 from `RESEARCH_GAMBITTALES_DN_ENHANCEMENT.md` § 2.2 — character-trait-IS-rule / no-villains / twin-pair-compression / whimsy-as-pedagogy / etc.), DialogueQuest adds the following WORLD-layer characters above its existing LESSONS layer:

| WORLD-layer character | Role in app |
|---|---|
| Quip Goodfellow | Comic / Vernacular — primary; comic dialogue is QG's territory |
| Murmur | Lyric — interior-thought-as-dialogue |

### Cast-architecture summary

```
THE MENTOR              (PRESERVED from RETROFIT — existing AI-mentor / hero archetype)
THE WORLD layer         2 characters (this handoff) — substrate / universe / region inhabitants
THE LESSONS layer       (PRESERVED from RETROFIT) — Existing hero Bramble + dialogue-craft friends (subtext / attribution / beat / audience-hearing)
THE META characters     (optional; see § 5 below — cluster-shared META cast)
THE CAMEO MATRIX        cross-app cameo density ≥3 per kit (see § 4)
```

Cast size ceiling: **8-12 total** (mentor + WORLD + LESSONS + optional META). This sits at the methodology median per `GUIDE_DISTRIBUTED_NARRATIVE_METHODOLOGY.md` § 2.

### Pacing + fading schedule

- **Kit 1-4**: WORLD-layer cast appears as substrate context — kid sees the region but doesn't yet meet the characters
- **Kit 5-8**: WORLD-layer cast introduced one-at-a-time; LESSONS-layer cast deepens
- **Kit 9-12**: WORLD + LESSONS cast both present; cross-cluster bridges (§ 6) begin
- **Kit 13-16**: capstone — cross-app cameos (§ 4) surface; META-cast (§ 5) appears for meta-cognitive units

---

## § 4 — Cross-app cameo density extension (DN-D1)

DialogueQuest surfaces cluster-internal cameos at density ≥3 per kit 13-16 capstone (vs the 1-2 cameo default in first-pass DN). Cameo targets (cluster-internal):

| Cluster sibling | Repo slug | Cameo kit-targeting |
|---|---|---|
| CharacterForge | `characterforge-app` | kit 13-16 capstone reference |
| VoiceTale | `voicetale-app` | kit 13-16 capstone reference |
| SpeakForge | `speakforge-app` | kit 13-16 capstone reference |

Each cameo is **mentor-voiced** (zero marginal asset cost — no character art imported). Cameo dialog format: brief reference to the sibling app's cast member's signature move, framed so the learner who hasn't yet played the sibling app still recognizes it as a deliberate cross-app pointer.

Sample cameo dialog templates:

> "Reminds me of how their signature WORLD-layer character works in CharacterForge — same idea, different setting."
>
> "If you played VoiceTale, you might recognize their signature LESSONS-layer character's move here."
>
> "their META-layer character (if applicable) from SpeakForge would call this exact pattern X — it's the same primitive."

Cameo density goal: **≥3 cameos surface across kits 13-16** per app, with at least 1 cluster-internal + 1 cross-cluster (per § 6).

---

## § 5 — Cluster-shared META cast (optional)

The writing-craft cluster ships 2 cluster-shared META-stance characters that surface at meta-cognitive kits (typically TaleForge kit 11, DialogueQuest kit 12, DebateForge kit 14-16, ReadQuest throughout):

| Slug | Name | META stance | Static catchphrase |
|---|---|---|---|
| `meta_editor` | **Editor Penn** | The reader-from-within: notices what works and what doesn't, before publishing. Stands behind the writer's shoulder. | _"Let's look again — what's working?"_ |
| `meta_audience` | **Audience Aria** | The reader-from-without: what does the reader bring? what do they feel? Embodies reader-response criticism. | _"I'm the reader. Here's what I felt."_ |

This app's META selection: per § 3 above. If this app's curriculum surfaces meta-cognition, include Editor Penn and/or Audience Aria. If kit-level curriculum is form-mastery only (e.g., HaikuQuest k1-8 syllable-discipline kits), the META layer can be skipped.

---

## § 6 — Cross-cluster meta-bridges (DN-D11)

DialogueQuest surfaces **3 explicit cross-cluster bridges** at capstone kits (kit 13-16) where the AI mentor names that the curricular primitive kid just exercised SHOWS UP in another cluster:

| Bridge | Cross-cluster reference |
|---|---|
| Bridge 1 | Bramble's beat-structure move recurs in MotifLab Trill's pattern-pacing |
| Bridge 2 | Quip Goodfellow cameos in JestForge / PunchlineForge timing-of-wit |
| Bridge 3 | Bramble's audience-hearing move recurs in DebateForge audience-awareness |

Per `AMENDMENTS_DN_METHODOLOGY_SECOND_PASS_DEEPENING.md` § 3 DN-D11, cross-cluster bridges are the deepest second-pass move because they operationalize transmedia-intertextuality (Kinder 1991, Jenkins 2006/2011, Meyerhofer-Parra 2025 SLR) at the curricular level: the kid recognizes that the move they just learned IS the same operation showing up in a different domain.

Sample bridge dialog template:

> "Notice this PRIMITIVE? OTHER_CLUSTER_APP's OTHER_CAST_MEMBER would call this OTHER_TERM — same form, different curriculum."

Bridges go in capstone kits ONLY (NOT throughout the app — that would risk attention-overload per Cutting & Iacovides 2022 attentional-mechanism prediction).

---

## § 7 — Failure-mode test deepening (DN-D5: 6 → 8-12 tests)

The first-pass DN methodology requires 6 failure-mode tests per app handoff doc per `.claude/rules/distributed-narrative.md`. DN-D5 expands to **12 tests** for DialogueQuest:

### Original 6 tests (preserved from RETROFIT)

1. **Anxiety amplification check** — does the cast ever shame errors / wrong-answers / slow learners?
2. **Gender / cultural representation balance** — is the WORLD-layer cast representation-balanced?
3. **Mascotizing risk** — is each character actually a teacher, or just personification?
4. **Forgetability** — will the cast stick across the 16-kit arc?
5. **Cluster coherence** — does the cast work alongside sibling apps' casts in cross-app cameos?
6. **Curriculum-integrity check** — does adding the cast obscure or surface the curricular primitive?

### Additional research-grounded tests (DN-D5 second-pass)

7. **Cast working-memory load** — at kit 8, does a kid's recall test surface ALL named cast members (mentor + WORLD + LESSONS)? Calibrated against Gathercole et al. 2004 working-memory norms for ages 11-14 (capacity = 5.57-6.68 items).
8. **Cast attention-direction** — does instrumentation (or design-time A/B comparison) show the kid attending to cast vs. ignoring them? Per Cutting & Iacovides 2022 — the attentional mechanism is the load-bearing one.
9. **Cast longitudinal recall** — at kit 12, do learners still distinguish Existing from attribution? (Per Green & Appel 2024 narrative-transportation — character identification strengthens across exposure repetition.)
10. **Cast-cluster-sibling confusion** — do learners confuse DialogueQuest's WORLD cast with cluster-sibling app's WORLD cast? (Per Kinder transmedia-intertextuality — shared cast IS the design goal, but apps must remain distinguishable.)
11. **Cluster-shared cast canon consistency** — does the cluster-shared cast (e.g., voice-register archetypes / FC cast / Linea+Eucla / Captain Castle+Translator) maintain identical name + visual + catchphrase across all cluster-sibling apps?
12. **Cross-cluster bridge recognition** — at capstone kits 13-16, do learners recognize the cross-cluster bridge dialog as a deliberate pointer rather than incidental reference?

### Where the tests live

Tests 1-6 inherit from the first-pass RETROFIT § failure-mode-tests section. Tests 7-12 get added to the app's `Docs/TECHNICAL_DESIGN.md` § "Distributed Narrative — Failure-Mode Tests" subsection. Per `.claude/rules/distributed-narrative.md` § 6 failure-mode tests, the test list belongs in `TECHNICAL_DESIGN.md` — not duplicated to CLAUDE.md.

---

## § 8 — Implementation phases (A / B / C / D)

Inherits the Phase A-D structure from the first-pass DN handoff. Phase D ASSET BLOCK preserved.

### Phase A — Cast finalization (~1 hour, app session)
- Read this handoff
- Confirm WORLD-layer cast names + visual specs against current `REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` (re-pull labsmith first)
- Add WORLD-layer cast to `Docs/TECHNICAL_DESIGN.md` § "Distributed Narrative — Cast" subsection (extending the existing first-pass cast)
- Update site `apps.generated.ts dnCast.members[]` to include WORLD-layer characters (and shared META if app uses)

### Phase B — Kit 1-4 intro (~2-3 hours, app session)
- Add WORLD-layer substrate context to kit 1-4 (region naming, atmospheric framing, no characters yet)
- Implement region-name surfacing in QuizMachine intro state per `state-machines.md` patterns

### Phase C — Kit 5-12 deepening (~3-5 hours, app session)
- Introduce WORLD-layer cast one-at-a-time in kits 5-8
- Add cross-cluster bridge dialog lines at kits 9-12 (per § 6)
- Add 4 new failure-mode tests to `TECHNICAL_DESIGN.md` (per § 7)

### Phase D — Kit 13-16 capstone + asset generation (~2-3 hours app + ~$0.20-0.50 labsmith asset gen)
- Add cluster-internal cameo dialogs at kits 13-16 (per § 4, density ≥3)
- Add META-cast surfacing at meta-cognitive kits (per § 5)
- Generate WORLD-layer cast portraits (Flash tier, chunky-cartoon WebP) via labsmith `scripts/gen_cast_portraits.py` extension; bundle to `Resources/Cast/` via `scripts/copy_cast_to_repos.sh`.

---

## § 9 — Trauma-informed overlays

DialogueQuest is NOT trauma-adjacent per `.claude/rules/trauma-informed-content.md`. No reviewer envelope is required for this deepening wave.

Standard portfolio-trauma-informed defaults still apply (off-ramps available, mentor posture if trauma-content ever surfaces incidentally). Visual representation balance (failure-mode test #2) governs cast generation.

The deepening preserves the first-pass DN RETROFIT's existing trauma posture verbatim.

---

## § 10 — Cost projection

| Item | Count | Cost basis | Subtotal |
|---|---|---|---|
| WORLD-layer cast portraits (Flash tier; chunky-cartoon WebP) | 2 | $0.045/portrait | $0.04 |
| Cluster-shared cast portraits | (cluster-amortized; counts ONCE for cluster) | (cluster total) | (amortized) |
| Authoring time per phase | A: 1h / B: 2-3h / C: 3-5h / D: 2-3h | ~8-12h total | (labor) |
| Regeneration buffer (15% per `feedback_read_tool_sees_images.md`) | — | — | (~$0.03-0.08) |

**Total per-app cash**: ~$0.09 (2 Flash-tier portraits net-new for DialogueQuest; shared cluster-WORLD cast is amortized).

---

## § 11 — DN-richness rubric impact

Per `AMENDMENTS_DN_METHODOLOGY_SECOND_PASS_DEEPENING.md` § 5 rubric:

- **Pre-deepening** (current state): **3-4 baseline** (first-pass DN methodology shipped per RETROFIT; 4-6 LESSONS-layer cast; populated `dnCast.members[]`; cast portraits live)
- **Post-deepening target**: **5-6 rich** (WORLD layer added; cluster-shared dramatic frame; cross-app cameo density ≥3; failure-mode tests 8-12)

Combinations applied: DN-D2 + DN-D6 + DN-D1 + DN-D11 + DN-D5 = base delta +3 to +5 (well within combination ceiling of 5 moves per `AMENDMENTS_DN_METHODOLOGY_SECOND_PASS_DEEPENING.md` § 4).

To advance to **7+ load-bearing** in a future wave, add: DN-D4 (cast progression) + DN-D8 (reader-role-play) + DN-D12 (cast-encounter persistence — when forgekit ships). Deferred per § 1.

---

## § 12 — Definition of done

This handoff is DONE when:

1. ☐ `Docs/TECHNICAL_DESIGN.md` § "Distributed Narrative — Cast" updated with WORLD-layer cast members
2. ☐ `Docs/TECHNICAL_DESIGN.md` § "Distributed Narrative — Failure-Mode Tests" expanded to 12 tests
3. ☐ Site `apps.generated.ts dnCast.members[]` updated to include WORLD-layer + META characters (where used); `distributedNarrative: true` flag preserved
4. ☐ Cluster-internal cameo dialog lines wired into QuizMachine capstone (kit 13-16) state
5. ☐ Cross-cluster bridge dialog lines wired into kit 9-16 capstone framing (per § 6)
6. ☐ WORLD-layer cast portraits generated by labsmith (queue to `scripts/gen_cast_portraits.py` extension; per-app delivery via `scripts/copy_cast_to_repos.sh`) — Phase D only
7. ☐ Cast-portrait visual audit per `feedback_read_tool_sees_images.md` (read each Flash-tier WebP; reject artifacts; regen if needed)
8. ☐ App-session Definition-of-Done checks run: build (Cmd+B); unit tests for QuizMachine updated; no zero-warning regressions
9. ☐ App's CLAUDE.md updated ONLY by the app session (NOT by labsmith — per portfolio rule)

---

## § 13 — Cross-references

- `labsmith/Docs/AMENDMENTS_DN_METHODOLOGY_SECOND_PASS_DEEPENING.md` — methodology amendment (Round 83 #432; 12-move DN-D catalog)
- `labsmith/Docs/GUIDE_DISTRIBUTED_NARRATIVE_METHODOLOGY.md` — first-pass methodology spec (PRESERVED)
- `labsmith/Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` — name reservation registry (re-pull before naming any new characters)
- `labsmith/Docs/PLAN_DN_ENHANCEMENT_WRITING_CRAFT_CLUSTER.md` — cluster-level enhancement plan
- `labsmith/Docs/RESEARCH_GAMBITTALES_DN_ENHANCEMENT.md` — Storytime-Chess 10-technique catalog
- `labsmith/Docs/AUDIT_DN_S2_ENHANCEMENT_FIT.md` — Round 65 #355 audit (durable SKIP verdicts; this app is NOT permanently-SKIP)
- `labsmith/.claude/rules/distributed-narrative.md` — portfolio rule
- `labsmith/.claude/rules/trauma-informed-content.md` — trauma-informed-content design rules (apply for trauma-adjacent apps)
- `labsmith/.claude/rules/portfolio.md` — cross-repo handoff protocol
- `dialoguequest-app/Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` — first-pass DN handoff this deepening builds on

---

*Filed by labsmith per Round 85 #437 Wave A DN second-pass distribution. Per app session's Definition of Done § 12.*
