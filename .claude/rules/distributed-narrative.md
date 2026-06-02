# Distributed-Narrative Methodology

Portfolio-wide pedagogy: **named recurring characters embody curricular concepts** — the cast IS the curriculum, not decorative mascot dressing. Grounded in Bruner narrative learning + Habgood intrinsic integration.

**Status**: 100% portfolio coverage (138/138 active apps) as of 2026-05-22. Every app ships a documented cast + site-visible "Meet the cast" section.

## When this rule applies

Any app that has `distributedNarrative: true` in `spark-anvil-site/src/data/apps.generated.ts` AND/OR a `Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` in its repo. **All active portfolio apps meet this criterion** post-2026-05-22 — DN is the portfolio default.

## The three variants

| Variant | When | Cast size | Hero mascot role | Trauma depth |
|---|---|---|---|---|
| **Standard** (most apps, ages 9-14) | Default | 4-6 supporting + mentor | Mentor distinct from cast OR mentor stays protagonist (e.g., MotifLab / writing-craft pattern) | Per-app gates as needed |
| **Aggregator-infrastructure** (Wave 27) | AdventureHub / ForgeArena / ForgeClassroom / ForgePortal | Cast #1 IS the AI mentor; 3-4 static others | Cast #1 doubles as mentor | Per-app (ForgePortal trauma-informed flag TRUE) |
| **Younger cluster** (Wave 29) | Ages 5-8 apps | 3-character cast | Hero mascot stays PRIMARY protagonist (cast = friends) | None — scope explicitly gentle |

## What the cast IS

Each cast member embodies ONE specific curricular primitive — not a personification of an abstract concept, but a character whose RECURRING BEHAVIOR demonstrates the primitive. Examples:

- **GambitTales** Sir Pinwell embodies *the chess pin* — recurring scenes show pieces lined up; the pattern IS the character's signature move
- **ProofQuest** Direct-Proof Dora embodies *direct proof* — her catchphrase + presence cue the proof technique whenever it appears
- **FunctionForge** Stride embodies *linear functions* — equal-step walking is both visual and conceptual primitive

## What the cast is NOT

- ❌ Mascots in costumes (decorative)
- ❌ Concept-as-name without character (don't name a char "Linear")
- ❌ Real historical figures (cultural-appropriation + trauma risks)
- ❌ Stand-ins for the mentor (cast supports mentor, doesn't replace)
- ❌ One-shot cameos (must RECUR across multiple kits to count)

## Handoff doc structure (per app)

Every app's `Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` contains:

1. **Header** — labsmith → app, date, wave number
2. **Why DN now** — primitive→character framing
3. **Proposed cast** + populated `dnCast: { intro, members[] }` JSON ready for site data
4. **Pacing & fading schedule** — cast typically fades by kit 12 (standard 16-kit apps; younger-cluster fades by kit 8)
5. **6 failure-mode tests** (or 4 for younger-cluster variant)
6. **Implementation path** — Phase A (cast finalization) / B (kit 1-4 intro) / C (kit 5-8 deepening) / D (kit 9-12 fading + asset gen)
7. **Cross-references**

## Failure-mode tests (the 6 standard)

Every standard-variant handoff includes:

1. **Anxiety amplification check** — does the cast ever shame errors / wrong-answers / slow learners? (Specific subtype per app: math-anxiety / body-image / intellectual-shame / etc.)
2. **Gender / cultural representation balance**
3. **Mascotizing risk** — is each character actually a teacher, or just personification?
4. **Forgetability** — will the cast stick across the 16-kit arc?
5. **Cluster coherence** — does the cast work alongside sibling apps' casts in cross-app cameos?
6. **Curriculum-integrity check** — does adding the cast obscure or surface the math/science/craft primitive?

## Cultural-sensitivity gates (load-bearing)

Apps engaging trauma-adjacent content (per `.claude/rules/trauma-informed-content.md`) MUST add specific gates:

- **Indigenous land/TEK content** (BiomeForge / TerraVoyage / TrailForge / DigQuest / LoreQuest / OriginForge) — no Indigenous TEK appropriation in cast names; attribute in kit metadata only
- **Religion / origin myths** (OriginForge / MythForge / LoreQuest) — archetype names only; no specific cultural-deity references
- **Body-image-risk apps** (FitQuest / DanceQuest / WellnessForge / SaffronLab) — characters intentionally non-lean-coded; loose layered clothing visual baseline
- **Conspiracy/political-content apps** (NewsForge / TruthQuest / CivicForge / EthosForge / ClaimCraft / DataForge) — abstract examples only; static-response gating for despair signals
- **Medical-trauma apps** (MedicQuest / CreatureCare) — body-autonomy framing; crisis-resource surfacing (988 / Childhelp / Crisis Text Line)
- **Pet-loss / animal-death** (CreatureCare / WildLens / FarmQuest) — observation-framed, not mortality-framed; off-ramps required

These gates BLOCK Phase D asset generation until external sensitivity-reviewer signoff. Cumulative reviewer envelope across gated apps: ~$5K. See per-app handoffs for reviewer-budget specifics.

## Name-collision discipline

Use `labsmith/Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` BEFORE naming any new character. Grep first. The registry holds 700+ reservations as of 2026-05-22.

**Collision rules**:
1. **Exact-string match** → hard collision, must rename
2. **Same first name + different surname** → soft collision; rename if cross-app appearance plausible
3. **Same archetype + different name** → allowed; ensure visual distinction
4. **Homophonic collision** → allowed but flag for audio-context audit
5. **3rd-instance audio-context threshold** (Wave 29) — after 2 existing soft collisions on a name, the 3rd instance renames even if technically allowed
6. **4th-instance cross-wave threshold** (Wave 30) — same rule extended across waves; serial soft-collision accumulation triggers rename

The registry was the dominant design constraint by Wave 30+. Cast naming requires creative range; expect to reject 30+ candidates per 4-app wave.

## Hero mascot vs. cast (the protagonist question)

Two patterns:

**Pattern A — cast leads, mentor coaches**: 
Standard for most apps. The cast carries the recurring curricular embodiment; mentor (e.g., Trailmaster Theo / Dr. Quark / Loresinger Mae) is the meta-voice that introduces / scaffolds. ProofQuest / FunctionForge / RatioRealm.

**Pattern B — hero mascot stays primary, cast supports**:
Standard for the writing-craft cluster + younger cluster. Hero mascot (Pip / Cherry / Ink / Bramble / Patter for writing-craft; Beetle / Calc Jr / Hug / Squeak for younger) IS the protagonist. Cast members are explicitly framed as "X's friends" who each embody one craft primitive. LyricForge / HaikuQuest / CharacterForge / DialogueQuest / VoiceTale / MotifLab (Trill stays protagonist) / younger-cluster all follow this.

Match the pattern to the existing app: if the app already has a strong hero mascot identity, use Pattern B.

## Site surfacing

Each per-app page renders `dnCast.members[]` as a "Meet the cast" section. The aggregate `/cast` page (Wave 33+ deliverable) will showcase all ~600+ characters across the portfolio.

`apps.generated.ts dnCast.intro` is a 1-2 sentence framing of WHY the cast exists for that app — keep it kid-and-parent readable, no jargon.

## DN-S — Chapter-depth story per character (R170 #604 + R172 #606 escalation)

**Per user-direct override 2026-05-29 ("expand to chapter depth for each cast member; audience: 9-14")**, DN cast members now require a **CHAPTER** (800-1500 words at age-9-14 register) in addition to behavioral primitive embodiment. This escalates the R170 paragraph-depth spec to full Storytime-Chess-depth chapters, calibrated to ages 9-14 (NOT preschool 3-7).

Each character requires:

1. **Chapter** — **800-1500 words** at age-9-14 register (Magic Tree House / Wimpy Kid / Roald Dahl). Structure: opening hook (~150w) → origin/formative moment (~400w) → encounter revealing primitive (~400w) → present-day role / why they teach (~250-400w)
2. **Voice register** — 1-paragraph guidance + 3-5 sample lines
3. **Arc across kits** — 16-bullet evolution (one per kit)
4. **Relationships** — at minimum 1 alliance + 1 tension

Optional: cultural-context note, voice-acting note, visual evolution.

### Audience register (LOAD-BEARING)

Audience: **ages 9-14**. Calibrated per `PLAN_GAMBITTALES_DN_ENHANCEMENT.md` § A.4:

- **Tone**: warmly absurd with subtext — NOT "silly silly silly" preschool register (Storytime Chess 3-7 reserved), NOT adult-dense literary
- **Humor**: dry, situational, character-driven
- **Stakes**: clear but kid-scaled — intellectual conflict / friendship strain / growing-up; NOT romance / mortality / existential dread
- **Trust**: chapter trusts the 9-14 reader's intelligence; doesn't condescend; doesn't lecture
- **Length**: 800-1500 words — Magic Tree House / Wimpy Kid / Roald Dahl single-sitting range

Reference books: Roald Dahl, Jeff Kinney, Mary Pope Osborne, Lois Lowry, Beverly Cleary, Kate DiCamillo.

**Reference impl**: GambitTales (`Docs/PLAN_GAMBITTALES_DN_ENHANCEMENT.md` — 10 chars at this depth).

**Rollout via 7 waves** prioritized by cluster cohesion + existing partial-story content + high-value differentiation surfaces. See `Docs/PLAN_DN_S_STORY_PER_CHARACTER_WAVES.md`. **Budget at chapter depth**: ~700 chapters × 1.5h authoring × R166 0.30 multiplier = **~315h portfolio-wide**. Per-round budget: ~5-8h.

**Sequencing constraints**:
- ~~R0 reviewer signoff required for trauma-gated apps~~ **AMENDED R363 #798 (2026-05-31) per ADR-016**: user-direct ADR-016 approval ("approve all trauma-gated work items") is now an accepted alternative pathway to R0 reviewer signoff for the **trauma-gated DN-S story-axis**. Each trauma-gated chapter MUST: use SAMHSA TIP 57 register (validate-then-inform / hold-space / refer-up); include off-ramps + content warnings; surface crisis-resource lists; credit Indigenous/traditional/community knowledge explicitly without mascotization; frame access/inequality as structural (anti-shame); avoid evangelism on contested life-questions (vegetarian/vegan/omnivore for FarmQuest; political position for CivicForge; religion for OriginForge; etc.). Per-app handoff MUST cite ADR-016 + the specific trauma-axis flag(s) (e.g., `food-justice + farmworker-labor + Indigenous-knowledge-credit`). **R0 reviewer signoff remains deferred-but-not-waived for downstream art-axis generation** (separate decision per ADR-012). See `Docs/ADR-016_DN_S_TRAUMA_GATED_STORY_AXIS_APPROVAL.md` for full constraints.
- Character name registry MUST be checked before DN-S authoring (no name collisions)
- Anti-credentialism gate per CQ `CONTENT_STYLE_GUIDE.md` § 4.5 applies to anxiety-safe register cast (Linger / Notice / etc.)

**For existing Wave-0/1/2 retrofit apps**: DN-S retrofit is per-app handoff in `docs/HANDOFF_FROM_LABSMITH_DN_S_STORY_PER_CHARACTER.md`. Verify-before-action FIRST — many apps already have partial story content that just needs codification.

**For new apps SPAWNing post-R170**: DN-S is required from day one. Author backstory + voice + arc + relationships alongside the initial cast definition.

## DN-S Integration (Phase 1, Round 385 #810; ADR-019)

Once an app has shipped DN-S chapters, the **next-step axis is INTEGRATION not further authoring** (per ADR-019). Authoring more chapters has diminishing returns past the existing 800-1500w-per-character density; integration earns the chapters their cost via three complementary surfaces:

| Move | Surface | Status |
|---|---|---|
| **B — Per-kit cast cameos** | Distill chapter voice-register cards + arc-across-kits into recurring per-kit cameo lines that surface in 16-kit question content. Each cast member gets ≤ 16 cameos (one per kit) wired into `Resources/Questions/<app>/kit_NN_*.json` via `castCameos[]` array. Codifies DN-D1 content-axis. | ACTIVE Phase 1 (Q3 2026) |
| **C — Site `/cast` aggregate page** | Portfolio-wide cast gallery on spark-anvil-site surfacing 700+ named characters as a navigable, themed, searchable index. Filterable by cluster; per-character cards link to source app pages. | ACTIVE Phase 1 (Q3 2026) |
| **D — AI-mentor voicing via CastDialog** | Wire chapter voice-register cards into ForgeKit 0.97.0 `CastDialog` per-app `CastVoiceRegistry`. AI mentor calls `castDialog.respondAs(.character(slug), prompt:)` for in-context character voicing. 3-app pilot (GambitTales / ProofQuest / QuillSpell) gates portfolio rollout. | PILOT Phase 1 (Q3 2026) |
| **E — Audio drama** | Phase 2 (Q1 2027); telemetry-gated on D pilot results | DEFERRED |
| **F — Illustrated comic** | Conditional; only if Phase 1 telemetry favors audio over voicing | CONDITIONAL |
| **G — Cross-app sagas** | Phase 2.5; conditional on cross-app discovery friction surfacing in Phase 1 telemetry | DEFERRED |
| **A — Ensemble stories (standalone)** | REJECTED per ADR-019. Existing chapters already encode ensemble dynamics densely (every chapter cross-references 1-4 cast members + ships explicit alliance/tension table). Authoring a separate ensemble-stories layer would duplicate ~70% of content at ~1100h cost. Pedagogical literature consistently favors RECURRENCE over standalone ensemble products. | REJECTED |

**DN-S Integration applies to each app that has shipped its DN-S chapters.** When an app reaches "100% SHIPPED" on DN-S authoring, the next per-app handoff to file is the Phase 1 integration handoff (Option B per-kit cameos as the lowest-cost starting move; Option D voicing per the **Phase 1D APPROVED portfolio rollout** per `Docs/DECISION_DN_S_AI_MENTOR_PORTFOLIO_ROLLOUT.md` (R394 #818)). All DN-S-shipped apps (post-pilot) receive customized Option D voicing handoffs via batched 7-wave rollout per `Docs/PLAN_DN_S_PORTFOLIO_ROLLOUT_WAVES_2026-06-01.md` — automated filing via `scripts/file_dn_s_voicing_handoff.py`.

**For apps still in DN-S authoring**: Integration is NOT prerequisite-blocked by completing all chapters — apps can wire Option B cameos incrementally per character as chapters land.

**Reference impl chapter-length variance** (R385 #804 per user-direct 2026-06-01): GambitTales reference chapters range 1467-2580 words; 9 of 10 exceed the original 800-1500w spec cap. Per user directive **do NOT retroactively edit GambitTales chapters**. The spec is updated to treat 800-1500w as a TARGET range; ensemble-piece chapters (e.g., the-pawn-cohort @ 2580w) are explicitly allowed up to ~2600w when the chapter is itself an ensemble piece. Single-character chapters should still aim for the 800-1500w target; chapters that bundle multiple characters (twin-pairs, cohorts, ensemble framings) may extend up to ~2600w with rationale in the chapter front-matter.

## Cross-references

- `Docs/GUIDE_DISTRIBUTED_NARRATIVE_METHODOLOGY.md` — full methodology spec (Bruner + Habgood references) + § DN-S
- `Docs/PLAN_DN_S_STORY_PER_CHARACTER_WAVES.md` — DN-S 7-wave rollout plan (R170 #604)
- `Docs/RESEARCH_STORYTIME_CHESS_CHARACTER_STORIES_VS_DN_2026-05-29.md` — DN-S research foundation (R169 #603)
- `Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` — canonical character/mentor registry
- `.claude/rules/trauma-informed-content.md` — trauma-informed-design rules that DN handoffs adhere to
- `.claude/rules/portfolio.md` — cross-repo handoff protocol that DN retrofits use
- `Docs/PLAN_GAMBITTALES_DN_ENHANCEMENT.md` — DN-S reference template
- `Docs/ADR-016_DN_S_TRAUMA_GATED_STORY_AXIS_APPROVAL.md` — user-direct R363 approval for trauma-gated DN-S story-axis (R0 reviewer art-axis path preserved per ADR-012)
- `Docs/ADR-019_DN_S_INTEGRATION_OVER_ENSEMBLE_STORIES.md` — DN-S Integration over ensemble-story authoring decision (Round 385 #810)
- `Docs/PLAN_DN_S_INTEGRATION_PHASES_2026-06-01.md` — 5-PR Phase 1 implementation plan (Options B + C + D)
- `Docs/RESEARCH_DN_S_NEXT_STEPS_ENSEMBLE_STORIES_2026-06-01.md` — 58-citation research synthesis underpinning ADR-019
<!-- END LABSMITH-SYNCED CONTENT -->
