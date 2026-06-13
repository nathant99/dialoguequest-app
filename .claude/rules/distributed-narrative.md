# Distributed-Narrative Methodology

Portfolio-wide pedagogy: **named recurring characters embody curricular concepts** — the cast IS the curriculum, not decorative mascot dressing. Grounded in Bruner narrative learning + Habgood intrinsic integration.

**Status**: 100% portfolio coverage (138/138 active apps) as of 2026-05-22. Every app ships a documented cast + site-visible "Meet the cast" section.

## When this rule applies

Any app that has `distributedNarrative: true` in `spark-anvil-site/src/data/apps.generated.ts` AND/OR a `Docs/HANDOFF_FROM_HUB_DISTRIBUTED_NARRATIVE_RETROFIT.md` (canonical 2026-06-11+) or `Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` (legacy pre-2026-06-11) in its repo. **All active portfolio apps meet this criterion** post-2026-05-22 — DN is the portfolio default.

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

### Storytime-Chess parity test (R-DN-PARITY; 2026-06-13) — load-bearing

**A cast member's PRIMARY CHARACTERIZING ACT (the thing they DO that defines them) must literally BE the curricular primitive.** Not "the character has interesting personality AND the rule" — the character's DEFINING DAILY ACTION is the rule. Reference: Storytime Chess (TIME Best Invention 2021; Toy of the Year 2021) — King Chomper's chomping IS one-square-at-a-time; Bea + Bop's color-locked trapeze artistry IS diagonal-swing-on-one-square-color; Clip + Clop's secret-wall dance IS gallop-gallop-step-sideways + jump. Portfolio parallels: Sir Pinwell's library-book-organizing IS the pin pattern; Stride's equal-step walking IS the linear function.

**The swap test**: if you can swap the character's defining act for an unrelated action without changing the chapter's emotional content, the character is failing intrinsic integration (Habgood + Ainsworth 2011) and the chapter is in violation. Apply this test before committing any new or rewritten DN-S chapter. The 2026-06-13 King Pumble + Sable audit (`Docs/AUDIT_GAMBITTALES_KING_PUMBLE_SABLE_PRIMITIVE_EMBODIMENT_2026-06-13.md`) is the canonical empirical illustration of the failure mode — a cousin-friendship chapter where the king-rule (one-square + cannot-enter-check + must-protect) doesn't drive the narrative ACTION and could be swapped for any other cousin-friendship beat with no emotional loss.

**Special discipline for paired or relationship-primary cast** (paired royals, twin pairs, ensembles): the test applies to the PAIR as a unit AND to each individual. Both members' defining acts must be the primitive (or co-extensive parts of it). A pair where the RELATIONSHIP is foregrounded over the RULE-EMBODIMENT fails parity even if each individual member technically embodies the primitive elsewhere.

**Companion exemplar — Storytime Backgammon** (NAPPA Best Games; MESH Accredited): when an app's curricular surface doesn't decompose into distinct character-archetypes (e.g., uniform pieces; single-pattern domains; creative-tool sandboxes), the Storytime Backgammon precedent uses **moment-as-rule** instead of character-as-rule — a small protagonist cast whose narrative beats correspond 1:1 to learning moments. The parity test still applies, just at the beat level rather than the character level: each beat's NARRATIVE EVENT must literally BE the rule it teaches.

### Academic foundation

The portfolio's "DN methodology" synthesizes three of the four effective game-narrative features identified in [Naul + Liu (2020) "Why Story Matters: A Review of Narrative in Serious Games" Journal of Educational Computing Research 58(3), 687-707](https://journals.sagepub.com/doi/abs/10.1177/0735633119859904) — namely (1) **distributed narrative** (narrative dispersed across the 16-kit arc + per-app site cast index + chapter pages, in the Crystal Island / Quest Atlantis tradition), (2) **intrinsic integration** (character behavior literally IS the curricular primitive, per [Habgood + Ainsworth 2011 "Motivating Children to Learn Effectively"](https://shura.shu.ac.uk/3556/1/Habgood_Ainsworth_final.pdf)), and (3) **empathetic characters** (named cast with portraits, chapter backstories per § DN-S, voice register, and recurring relationships table). The fourth Naul + Liu feature — adaptive storytelling — is realized partially via per-kit difficulty curves + AI-mentor scaffolding + `CastDialog` responsiveness (Move D Phase 1).

The portfolio borrows the FIRST feature's name as the umbrella label for the synthesis. The academic term "distributed narrative" in Naul + Liu means narrative dispersed across environmental artifacts to reduce cognitive load; the portfolio's compound usage adds intrinsic integration + empathetic characters under the same banner. Document this synthesis explicitly when citing the methodology in external-facing contexts.

**Contemporary commercial exemplar**: Story Time Learning's Storytime Chess + Storytime Backgammon (storytimelearning.com) — both products explicitly cite the Naul + Liu four-feature framework as their design basis. See `Docs/RESEARCH_STORYTIME_CHESS_BACKGAMMON_DN_EXEMPLARS_2026-06-13.md` for the full pedagogical-foundation synthesis + 11 sources.

**Foundational references** (cited across DN-S authoring + audit work):

- Naul + Liu (2020) — the four-feature framework + recommended design strategy (Figure 1)
- Habgood + Ainsworth (2011) + Cutting + Iacovides (2022) — intrinsic integration directs attention to learning-relevant features; the swap test above is grounded in this attentional mechanism
- Malone (1981) + Rieber (1996) — endogenous vs exogenous fantasy; the § "What the cast is NOT" stoplist below is grounded in Rieber's endogenous criterion
- Bruner (1986; 1991) — narrative cognition + spiral curriculum; DN-S 16-kit arcs spiral character action at increasing depth
- Lepper + Malone (1987) — intrinsic motivation taxonomy (challenge / curiosity / control / fantasy); DN apps target all four via cast-driven engagement

## What the cast is NOT

- ❌ Mascots in costumes (decorative)
- ❌ Concept-as-name without character (don't name a char "Linear")
- ❌ Real historical figures (cultural-appropriation + trauma risks)
- ❌ Stand-ins for the mentor (cast supports mentor, doesn't replace)
- ❌ One-shot cameos (must RECUR across multiple kits to count)

## Handoff doc structure (per app)

Every app's DN handoff doc (filename: `HANDOFF_FROM_HUB_DISTRIBUTED_NARRATIVE_RETROFIT.md` canonical 2026-06-11+, or `HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` legacy) contains:

1. **Header** — hub → app, date, wave number
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

Use `spark-anvil-hub/Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` BEFORE naming any new character. Grep first. The registry holds 700+ reservations as of 2026-05-22.

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

**For existing Wave-0/1/2 retrofit apps**: DN-S retrofit is per-app handoff in `docs/HANDOFF_FROM_HUB_DN_S_STORY_PER_CHARACTER.md` (canonical 2026-06-11+) or `docs/HANDOFF_FROM_LABSMITH_DN_S_STORY_PER_CHARACTER.md` (legacy pre-2026-06-11). Verify-before-action FIRST — many apps already have partial story content that just needs codification.

**For new apps SPAWNing post-R170**: DN-S is required from day one. Author backstory + voice + arc + relationships alongside the initial cast definition.

### When to author in-session (Opus) vs scripted (Gemini Pro) (R-AUTHOR-MODEL-CHOICE; 2026-06-12)

Per user-direct 2026-06-12 + `Docs/RESEARCH_MODEL_CHOICE_CHAPTER_AUTHORING_2026-06-12.md` (10 sources). Two authoring paths exist for chapter prose; choose by the table below — NOT by API-spend default.

| Path | Model | Cost | When to use |
|---|---|---|---|
| **In-session (preferred)** | Opus 4.7 (whatever the current Claude Code session is running) | **$0 marginal** (Claude Code subscription absorbed) | Quality-critical chapters; Phase A.2 placeholder remediation; per-app reference-impl chapters; chapters anchoring register decisions; trauma-axis-sensitive chapters where author judgment matters; any chapter authored during an interactive round |
| **Scripted** | Gemini 2.5 Pro via `scripts/gen_ensemble_chapter_draft.py` | ~$0.20-0.40 per draft (API per-token) | Portfolio-scale batch authoring (>5 chapters in a single round); ensemble Path-C drafts that go through editorial review; metacognitive-companion chapters (AlcumusForge / DepthCheck / DailyChallenge) where structural primitive generation matters more than line-level rhythm |

**Why Opus 4.7 in-session is preferred for quality-critical work** (per the research doc):

- **Inkfluence AI April 2026 7-dim fiction rubric**: Opus 4.7 = 63.2/70 (top score); highest on prose / voice / character consistency — the exact axes DN-S targets
- **Q1 2026 blind human eval**: Claude family preferred 47% vs Gemini 3.1 Pro 24% (Gemini 2.5 Pro presumed lower as predecessor)
- **LMArena May-2026 text top-5**: 4 of 5 slots are Claude; Gemini 2.5 Pro no longer ranked
- **Cost wins in-session** because the Claude Code subscription absorbs the marginal token spend; the historical "Gemini is 5x cheaper per token" argument doesn't apply to interactive rounds

**Do NOT spec an Anthropic-API variant of `gen_ensemble_chapter_draft.py`** (user-direct 2026-06-12 follow-up: *"use Opus in-session, not API"*). Scripted batch authoring stays on Gemini Pro because the API premium for Anthropic doesn't compound when batch jobs would absorb 50-700 chapters at scale. Quality-tier batch work that needs Opus-grade voice routes through interactive rounds, not a new API script.

**In-session authoring discipline** (mitigates Opus 4.7's documented "corporate" / bullet-point default per BoringBot Q2 2026 review):

1. **Pre-frame the register card explicitly** — before authoring, state the audience (ages 9-14), reference books (Magic Tree House / Wimpy Kid / Roald Dahl), tone (warmly absurd with subtext), and structural constraint (flowing prose within beats; no bullets in beat narrative)
2. **Mirror the canonical methodology-section pattern** — use the spec'd H2 headings (`## Voice register` / `## Arc across kits` / `## Relationships` / `## Cultural-context note` / `## Author's note`) so `audit_chapter_quality.py` recognizes them (the script greps for these exact tokens — kid-friendly synonyms like `## About <Char>` / `## <Char>'s Story` get flagged as missing)
3. **Read the per-app YAML front-matter first** — character / role / primitive / register fields are the load-bearing context; don't invent the primitive from imagination when the spec ships it explicitly
4. **Respect the chapter-register stoplist** — per § R-CHAPTER-REGISTER (no engineering jargon in chapter MD body anywhere — `load-bearing` / `codified` / `SAMHSA` / `Phase A/B/C/D` / ticket numbers / etc. all forbidden in narrative AND methodology sections)
5. **R-MULTIBEAT-SNAPSHOT awareness** — if the chapter HAD multi-beat assets shipped previously (sidecar exists at `Resources/AutoSegmentedChapters/<app>/<char>.beats.json` OR `Resources/InterleavedChapters/<app>/<char>.beats.json` AND `chapter_<char>_chapter.m4a` exists in `spark-anvil-site/public/chapters/<app>/`), the new authoring triggers the R-MULTIBEAT-SNAPSHOT recipe (delete stale snapshot + per-beat assets + audio; re-run surgical regen)
6. **R-MULTIBEAT-DEFAULT structure** (2026-06-12 standard) — author the narrative body as **5 beats separated by horizontal-rule (`---`) breaks**, each beat a single scene that can be illustrated as one per-beat image. See § R-MULTIBEAT-DEFAULT below for the canonical beat shape. Single-beat flat-narrative authoring is deprecated.

### R-MULTIBEAT-DEFAULT — Multi-beat structure by default (2026-06-12)

Per user-direct 2026-06-12: *"make sure the pilot is for multi-beat prose which is the new standard going forward"*.

**All forward chapter authoring (single-character + ensemble) MUST produce multi-beat-structured prose by default.** Single-beat flat-narrative chapters are deprecated as a forward authoring pattern. Pre-2026-06-12 single-beat chapters remain valid (no retroactive rewrite mandated; if they're already shipped, the R-MULTIBEAT-SNAPSHOT recipe governs any retrofit).

**Canonical 5-beat shape for single-character chapters**:

| Beat | Role | Words | What |
|---|---|---|---|
| 1 (Opener) | Character + setting + primitive hint | ~250-350 | Vivid SINGLE SCENE where the character is doing something that signals the primitive; establishes tool/object/companion |
| 2 (Origin) | Formative moment | ~250-400 | Childhood / mentor / discovery SCENE that explains how the character came to embody the primitive |
| 3 (Arrival) | Appointment to the academy | ~250-350 | SCENE depicting the character's arrival at the academy + first encounter with the head; they demonstrate why they belong |
| 4 (Teaching) | Classroom demonstration | ~300-400 | SCENE inside the character's workshop where they show a student or students the primitive in action; clean dialogue; show-don't-tell |
| 5 (Closer) | Quiet reframe | ~200-300 | Quiet moment after the demonstration; student question + character's warm reframe; signature line; glance at tool |

Each beat is separated from the next by a single horizontal-rule line (`---` on its own line). Methodology sections (`## Voice register` etc.) are placed AFTER the final beat's `---` rule and AFTER one additional `---` rule, so `auto_segment_chapter.py` cleanly distinguishes them from the closing beat.

**Why 5 beats**:

- Matches the existing ensemble Path-C 5-beat shape (R-ENSEMBLE-AUTHORING) so the auto-segmenter + Path B / Path C illustration + audio pipelines treat single-character and ensemble chapters identically
- 5 beats × Pro opener ($0.134) + 4× Flash spot ($0.045) = ~$0.32 per chapter — matches portfolio cost ceiling
- 1200-1800w total narrative is well within the 800-1500w target (with slight upward drift for the more developed multi-beat structure)
- Each beat = one single illustrate-able moment; matches the storybook rendering surface

**Why NOT 7 beats**:

- 7 × ~$0.045 Flash + 1× $0.134 Pro = ~$0.45 per chapter — over the ceiling without enough quality lift
- 7-beat single-character chapters become repetitive at the 9-14 register; the natural narrative arc (opener / origin / arrival / teaching / closer) is 5

**Beat-boundary craft**:

- Each `---` is a SCENE BREAK — time-jump, location change, or distinct moment, NOT a paragraph break within the same scene
- The reader should feel a clean cut between beats — like turning a page in a picture book
- The illustrator (Pro for beat 1; Flash for beats 2-5) needs the beat to be a single illustrate-able moment, not a montage

**Audio-first calibration within each beat**:

- Dialogue cleanly attributed (`Arch said` / `She murmured`) — no bare quotations
- Natural pause points between speakers
- Each paragraph block ≤120w for clean audio narration line-by-line
- Per-character verbal tics consistent across beats

**Sidecar cleanliness verification**: after authoring, run `python3 scripts/auto_segment_chapter.py --chapter <path> --beats 5` and verify the sidecar's `prose-range` boundaries land between the H-rule breaks (not within a beat) AND methodology sections are excluded.

**Reference impls**:

- `scripts/gen_single_character_chapter_draft.py` (Path B single-character; 2026-06-12 multi-beat prompt update)
- `scripts/gen_ensemble_chapter_draft.py` (Path C ensemble; already multi-beat per R-ENSEMBLE-AUTHORING)
- `gambittales-app/Docs/dn-s/chapters/the-pawn-cohort.md` (reference impl ensemble; naturally adopts beat structure)

**Opportunistic upgrade discipline** (Option D of the retroactive-multi-beat decision; user-direct 2026-06-12):

When any pre-2026-06-12 single-beat chapter is touched for ANY reason — register fix, content correction, Phase A.2 placeholder remediation, trauma-axis re-review, register rewrite, asset regen, factual correction, FK rebalance — **upgrade it to the canonical 5-beat shape in the same change**. Don't proactively touch chapters that don't need it; don't skip the upgrade when you ARE touching one.

**Why**: per the Option E hybrid pick (C + B1 + D), the portfolio converges to multi-beat over 6-12 months through natural workflow without a coordinated retroactive wave on 1385 chapters. Each touched chapter amortizes the multi-beat conversion cost against the work that already justified touching it. Eventually-everywhere multi-beat without paying the all-or-nothing migration tax.

**How to apply**:

1. **Touching a chapter for register / content / correction** — author the new prose directly in the 5-beat canonical shape (Opener / Origin / Arrival / Teaching / Closer), not as flat narrative. The new text replaces the old text; you're already paying the authoring cost, so pay it in the multi-beat shape
2. **Touching a chapter for asset regen ONLY (no prose change)** — DO NOT trigger an opportunistic upgrade. Asset-only regens stay single-beat; bundling a prose rewrite would compound risk + cost without clear benefit
3. **Touching a chapter for a 1-3 word fix (typo, fact correction)** — DO NOT trigger an opportunistic upgrade. The threshold is "a meaningful prose edit"; trivial fixes stay in-shape
4. **R-MULTIBEAT-SNAPSHOT applies** — if the chapter HAD shipped multi-beat assets previously (sidecar at `Resources/AutoSegmentedChapters/<app>/<char>.beats.json` AND `chapter_<char>_chapter.m4a` in `spark-anvil-site/public/chapters/<app>/`), follow the R-MULTIBEAT-SNAPSHOT recipe (delete stale snapshot + per-beat assets + audio; re-run surgical regen). Per-chapter regen cost ~$0.32
5. **GambitTales scope (R389 #814 SUPERSEDED 2026-06-12 per user-direct)** — GambitTales chapters are IN SCOPE for opportunistic upgrade + B1 retroactive multi-beat conversion + asset/audio/portrait regen. R389 #814 (*"do NOT retroactively edit GambitTales chapters"*) is SUPERSEDED. User-direct 2026-06-12: *"upgrade/rewrite GambitTales chapters to multi-beat chapters and all the latest portraits/illustrations/audio dramas advancements. go with the best solutions based on what we know right now."*. Preserve voice register card + arc-across-kits + relationships + cultural-context sections verbatim across the rewrite (they remain canonical reference impl for the 9-14 register); convert narrative body to canonical 5-beat shape

**When the discipline does NOT apply**:

- A chapter authored 2026-06-12+ that is ALREADY multi-beat (forward authoring) — no upgrade needed
- A chapter that is being newly authored from scratch (placeholder remediation) — R-MULTIBEAT-DEFAULT mandates multi-beat from the start; this is forward authoring, not opportunistic upgrade
- A chapter whose only change is YAML front-matter (status flag flip, tag addition) — no prose touched, no upgrade triggered
- A trauma-gated chapter where the SAMHSA register requires a specific structural choice that doesn't fit the canonical 5-beat shape — surface to the user; do NOT force-fit

**Companion B1 selective wave** (Option E's selective component): a separate ~30-50 chapter initial-wave is tracked via `Docs/PLAN_DN_S_OPTION_E_B1_SELECTIVE_WAVE_2026-06-12.md` (when authored). The opportunistic upgrade discipline is the AMBIENT mechanism that closes the long tail; the B1 wave is the PROACTIVE mechanism that lifts highest-value chapters immediately. Both are part of Option E; both apply concurrently.

**Cross-references**:

- § R-ENSEMBLE-AUTHORING — ensemble 5-pattern (parent rule; beat structure rule #1 from there extends to single-character)
- § R-MULTIBEAT-SNAPSHOT — what to do when retrofitting a single-beat chapter to multi-beat
- § R-CHAPTER-HERO-SOURCE — beat 0 IS the chapter hero for multi-beat chapters
- `scripts/auto_segment_chapter.py` — beat boundary detector + sidecar emitter
- `scripts/pilot_interleaved_ensemble_chapter.py` — per-beat illustration + audio gen pipeline
- `Docs/SPEC_INTERLEAVED_ENSEMBLE_CHAPTER.md` — sidecar manifest schema
- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § "Strategic question — should we retroactively re-author..." — Option E decision context

**Reference workflow** (in-session per-chapter):

```
1. Read <app>-app/Docs/dn-s/chapters/<char>.md to inspect current state
2. Identify whether it's WIP (truncated), placeholder (substantive narrative but wrong methodology heading names), or missing-methodology (narrative but no sections)
3. Pre-frame register card + read R-CHAPTER-REGISTER stoplist
4. Author the chapter directly in-session — narrative + 5 canonical methodology sections
5. Commit + push + PR + merge + verify per § workflow
6. Multi-beat post-step if applicable per R-MULTIBEAT-SNAPSHOT
```

**Cross-references**:
- `Docs/RESEARCH_MODEL_CHOICE_CHAPTER_AUTHORING_2026-06-12.md` — 10-source synthesis + per-axis evidence
- `scripts/gen_ensemble_chapter_draft.py:41` — Gemini 2.5 Pro hardcode; stays for scripted batch
- `scripts/audit_chapter_quality.py:54-64` — canonical methodology-H2 regex list
- `Docs/AUDIT_DN_DN_S_CHAPTER_QUALITY_PHASE_A2_CALIBRATION_2026-06-11.md` — Phase A.2 placeholder list (the immediate consumer of this rule)

### Dual-tier chapter editions (post 2026-06-04 audit + decision)

Per `Docs/AUDIT_PDF_BOOK_CONTENT_REGISTER_2026-06-04.md` the original chapters drifted to FK 10.5 (high-school+) — too dense for the 9-14 target. Per user-direct *"go all in 2-tier"* the portfolio chapters now ship in TWO tiers:

| Tier | Audience | FK target | Source location | Theme | Audience cap |
|---|---|---|---|---|---|
| **Tier-1 Standard** | ages 9-12 (lower MG) | 4-6 (Roald Dahl / Wimpy Kid) | `<app>-app/Docs/dn-s/chapters/*.md` (canonical app source) | Blubook | reaches 9-12 directly + 13-14 if reader prefers easier prose |
| **Tier-2 Advanced** | ages 11-14 (upper MG) | 7-8 (Wonder / Hatchet / Holes) | `spark-anvil-hub/Resources/DN-S-Tier-Upper/chapters/<app>/*.md` | Folio | reaches 11-14 directly + via audio absorbs to 9-10 |

**Tier-1 lives in app repos** (read by ForgeKit / cameos / site /cast prose). Tier-2 lives only in hub (PDF rendering + audio drama source).

**Audio drama source rule**: dramas source from Tier-2 (FK 7-8) only — one drama per character serves the entire 9-14 audience because the 2-year listening gap (Audio Publishers Association canonical; Berl 2010; Logan 2019) means listening capacity exceeds independent-reading capacity by ≥2 grade levels. See `Docs/RESEARCH_AUDIO_DRAMA_TIER_2026-06-04.md` (14 sources) + `.claude/rules/audio-pipeline.md` § Register sourcing.

**Scope discipline**: dual-tier applies ONLY to chapter print editions. Other content axes stay single-tier:
- Per-kit cast cameos (Pillar B) → Tier-1 only (kid-conversation cadence; short)
- AI mentor (CastDialog / Pillar D) → Tier-1 only (kids talk like kids)
- Site /cast prose → matches whichever tier the reader is browsing
- Audio drama scripts → Tier-2 only (one drama per character)

**Pre-rewrite snapshot baseline** (`Resources/DN-S-Snapshots/2026-06-04-pre-register-rewrite/`): preserves the original FK 10.5 chapters + 118 Typora-rendered PDFs as a durable comparison set. Per user-direct *"keep the old version for comparison purposes."*

**Authoring guardrails** going forward (codify in any future DN-S authoring prompt):
- Tier-1 target: FK 4-6 / Flesch ease 70-90 / average sentence length 10-14 words / polysyllabic ratio <12% / 800-1500w per chapter (up to 2400 ensemble)
- Tier-2 target: FK 7-8 / Flesch ease 60-75 / average sentence length 14-18 words / polysyllabic ratio <15% / 1000-1800w per chapter (up to 2400 ensemble)
- Both: voice register card + arc-across-kits + relationships sections verbatim (rewriters preserve these)

**Audit tool**: `scripts/audit_pdf_book_content.py` runs per-chapter Flesch-Kincaid + Flesch ease + ASL + polysyllabic + word-count checks. Run after any chapter authoring/rewrite.

**Rewrite tool** (unified dual-tier, ships in `spark-anvil-hub/scripts/`):
- `rewrite_chapter_register.py --tier 1` — Tier-1; mutates app-repo MDs in place; Gemini 2.5 Flash
- `rewrite_chapter_register.py --tier 2` — Tier-2; reads snapshot baseline; writes to `spark-anvil-hub/Resources/DN-S-Tier-Upper/chapters/<app>/`; Gemini 2.5 Flash
- Shared core at `scripts/lib/dn_s_pipeline.py` (`TIER_CONFIG` dict + path resolvers + FK helpers); same `--tier {1,2}` flag pattern carries through `build_pdf_book_per_app.py` / `render_pdf_book_typora.sh` / `render_all_pdf_books_typora.sh` / `render_pdf_book_puppeteer.mjs`. Legacy `_upper.py` / `_tier2.{py,sh,mjs}` siblings removed 2026-06-05.

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

**Reference impl chapter-length variance** (R385 #804 per user-direct 2026-06-01; **R389 #814 freeze SUPERSEDED 2026-06-12 per user-direct**): GambitTales reference chapters range 1467-2580 words; 9 of 10 exceed the original 800-1500w spec cap. The original R389 #814 freeze (*"do NOT retroactively edit GambitTales chapters"*) is SUPERSEDED — GambitTales chapters are now in scope for B1 retroactive multi-beat conversion + asset/audio/portrait regen. The spec is updated to treat 800-1500w as a TARGET range; ensemble-piece chapters (e.g., the-pawn-cohort @ 2580w) are explicitly allowed up to ~2600w when the chapter is itself an ensemble piece. Single-character chapters should still aim for the 800-1500w target; chapters that bundle multiple characters (twin-pairs, cohorts, ensemble framings) may extend up to ~2600w with rationale in the chapter front-matter.

## DN-S Ensemble chapter authoring patterns (R-ENSEMBLE-AUTHORING; 2026-06-08)

Per `Docs/PLAN_INCORPORATE_GOOGLE_STORYBOOK_CONCEPTS_PORTFOLIO_2026-06-08.md` Wave 1 (b') interleaved ensemble chapters: ensemble chapters (≥3 named cast members in the chapter) follow five additional authoring patterns beyond the base DN-S spec. These patterns make ensemble chapters renderable as interleaved storybook-format multi-page output AND as multi-speaker audio drama scripts.

| Pattern | What | Why |
|---|---|---|
| **Beat structure** | Compose the chapter into 5-7 beats (one opener + 3-5 per-pair / per-character + one closer). Each beat ~250-400w. Use a horizontal-rule break (`---`) between beats so the structure is visually self-evident in the rendered MD | Each beat = one rendered page (interleaved text + spot illustration); each beat = one audio drama scene transition |
| **Pair-coding in prose** | When the cohort has natural pair-bonds (sibling pairs / partner pairs / professional pairs), make the pair-bonds explicit in the prose AND in the chapter front-matter via the `pair-bonds:` field. Pair-bond size: 2 (canonical) or 3 (rare; only when narratively load-bearing) | Visual rendering can pair-code automatically; reference-image conditioning preserves pair-bond consistency across beat spots; audio drama can match voice register pairs |
| **Audio-first prose calibration** | For ensemble chapters: (a) attribute dialogue cleanly with speaker tags ("Steg said" or "Sten muttered"), (b) leave natural pause points between speakers, (c) use the per-character verbal tics from each character's voiceRegister card, (d) keep individual paragraph blocks ≤120w so audio narration breaks cleanly | Multi-speaker TTS (Gemini 2.5 Flash native multi-speaker) needs clean attribution + pause points to assign voices reliably |
| **Per-character spotlight beat** | Each named character in the ensemble gets ONE beat where they're a focal character. If the cohort has 4 pair-bonds = 4 beats spotlight pairs; if 8 individuals, then 8 beats spotlight individuals. Closer beat can return to the full cohort | Per-page rendering needs one focal subject per page; pedagogy benefits from per-character primitive dedication |
| **Optional name-slot personalization** | Author optional `{kid_name}` insertion points in beats where the kid's `displayName` could be woven in (typically: ensemble welcomes a guest; cohort acknowledges the kid as an honorary member). Wave 3 (g) runtime layer fills these at render time. Single-character chapters don't need this; ensemble chapters benefit because the cohort can naturally accept a guest | Personalization without breaking chapter canonicity (the slots are optional; chapters render correctly without them filled) |

### Authoring at the source

The five patterns apply to **forward authoring of new ensemble chapters** AND to retroactive multi-beat conversion under Option E B1 (per `Docs/PLAN_DN_S_OPTION_E_B1_SELECTIVE_WAVE_2026-06-12.md`). Existing ensemble chapters that already happen to follow some of these patterns (e.g., `gambittales-app/Docs/dn-s/chapters/the-pawn-cohort.md` already uses the beat structure with `---` breaks + the 4-pair-bond cohort pattern) can be surfaced via **sidecar manifest** (`<slug>.beats.json` in a hub-side or app-side path) WITHOUT chapter MD changes when the existing prose already conforms; chapters that DON'T conform are rewritten in-place via the canonical 5-beat shape during B1 conversion. **Note**: R389 #814 (*"do NOT retroactively edit GambitTales chapters"*) was SUPERSEDED 2026-06-12 per user-direct; GambitTales chapters are now in scope for retroactive rewrites + asset regens.

### Sidecar manifest schema

For existing chapters AND new chapters that want to opt into interleaved rendering, the chapter's beat structure is declared via a JSON sidecar manifest. Spec: `Docs/SPEC_INTERLEAVED_ENSEMBLE_CHAPTER.md`. Brief shape:

```json
{
  "chapter": "the-pawn-cohort",
  "app": "gambittales",
  "ensemble-size": 9,
  "pair-bonds": [
    { "name": "Pawn Patrol", "members": ["Steg", "Sten"] },
    { "name": "Sienna and Bran", "members": ["Sienna", "Bran"] },
    ...
  ],
  "narrator-anchor": "Captain Castle",
  "beats": [
    { "idx": 0, "kind": "opener",  "chars": ["Castle", "Steg", "Sten", ...all 9], "scene": "full cohort assembled" },
    { "idx": 1, "kind": "pair-bond", "chars": ["Steg", "Sten"], "scene": "border crossing" },
    ...
    { "idx": N, "kind": "closer",  "chars": [...all 9], "scene": "promotion scene" }
  ]
}
```

The gen pipeline (`scripts/pilot_interleaved_ensemble_chapter.py` for the pilot; `gen_app_illustrations.py --interleaved` for portfolio rollout after pilot validation) reads the sidecar manifest + the chapter MD + generates ensemble opener (Pro) + per-beat spot illustrations (Flash, reference-conditioned with the opener as `input_image_path`) + per-beat TTS narration (Gemini 2.5 Flash TTS) + per-chapter WebVTT cues for audio+text synchronization.

### Audio + text sync

Each beat ships a per-beat audio segment concatenated into a single chapter `.m4a`; the chapter `.vtt` carries TWO layers of cues:

- **Beat-boundary cues** (`beat-idx=N` payload) drive the active-beat highlight + auto-scroll
- **Per-line cues** (`<v Narrator>...` payload) drive karaoke-style active-line highlight within the current beat

Total per-chapter cost: ~$0.36-$0.56 (illustrations $0.36 + audio $0.20). See `Docs/SPEC_INTERLEAVED_ENSEMBLE_CHAPTER.md` § Audio + text synchronization for the renderer-side WebVTT cue structure + `<InterleavedChapterAudioPlayer />` Astro component.

### Spoken intro + outro attribution (parity with ADR-025)

**Interleaved ensemble chapters MUST ship with the ADR-025 v2 attribution intro + outro frames**, exactly parallel to portfolio audio dramas. Without intro/outro, the chapter has no Spark & Anvil studio attribution + no curriculum credit + no 501(c)(3) charity framing + no Creative Commons license statement — all of which are load-bearing for grant + Common Sense Privacy Seal + Apple Design Award candidacy + brand-identity coherence.

The intro is prepended to the chapter audio (plays before beat 0); the outro is appended (plays after the closer beat). Spec:

- **Standard intro** (~12s): "From Spark and Anvil and `<App Name>` — this is `<Narrator-anchor or chapter-name>`, in chapter `<N>` of `<App Cast Name>`. This drama uses an AI-generated voice. Voiced via Gemini 2.5."
- **Standard outro** (~28s): "You've been listening to a Spark and Anvil chapter, written by the Spark and Anvil writing team for ages 9 to 14. Spark and Anvil is a 501(c)(3) public charity. Apps stay free forever. Curriculum aligned to `<primitive>`. Released under Creative Commons BY-NC-SA 4.0 for educational reuse. Visit Spark and Anvil for the full transcript."
- **Trauma-gated variants** per ADR-016 + ADR-020 + ADR-021 — soft kid-safe phrasing; crisis-resource lists (988 / text HOME 741741 / Childhelp 1-800-422-4453)
- **Cluster-specific variants** per ADR-025 (Indigenous TEK cluster adds cultural-credit line; sensitivity-reviewed cluster adds reviewer credit; grant-funded cluster adds funder line)

The interleaved gen script (`scripts/pilot_interleaved_ensemble_chapter.py` for the pilot; `gen_app_illustrations.py --interleaved` for portfolio rollout) MUST emit these frames by default (`attribution-version: v2`). Implementation lifts the canonical `build_intro_lines()` + `build_outro_lines()` helpers from `scripts/gen_dn_s_audio_drama.py` (lines 418-515) verbatim. The sidecar manifest carries `attribution.app-name`, `attribution.app-cast-name`, `attribution.curriculum-primitive`, `attribution.cluster` (and optionally `attribution.sensitivity-reviewer` / `attribution.cultural-advisor` / `attribution.funder` per ADR-025 cluster variants).

The renderer's VTT cues skip beat-boundary highlighting during intro + outro audio (the visual highlight cycles through beats 0..N only); per-line cues still apply during intro/outro for transcript accessibility.

### Site-chrome register discipline (R-SITE-CHROME; 2026-06-08)

**The same age-9-14 register stoplist (per § Chapter content register stoplist below) applies to SITE CHROME around chapter pages**, not just the chapter MD body. Anything reader-facing on a kid/parent surface MUST NOT contain:

- **Generation cost figures** — hub internal accounting; never on a reader page
- **Internal file paths** (`gambittales-app/Docs/dn-s/...`, `spark-anvil-hub/Resources/...`) — engineering surface
- **Ticket / round numbers** (`R389 #814`, "Round 2026-06-08", "Wave 1 (b'/c')") — hub workflow surface
- **GitHub doc links** to internal hub repos — engineering surface
- **Engineering jargon** in page titles, meta descriptions, footer attribution, header banners

Reader-facing pages — including pilot pages, `/cast/<app>/<char>`, `/stories`, `/books`, audio drama pages — receive the same register discipline as chapter MD body prose. Engineering metadata for source-code readers belongs in:

1. **HTML source comments** (`<!-- ... -->`) in the Astro page
2. **PR descriptions** (visible to engineers via GitHub)
3. **Hub findings docs** (`Docs/RESEARCH_*.md` / `Docs/PLAN_*.md`)
4. **Source-file leading comments** (Astro component docstrings)

NOT in the rendered DOM that readers see.

**Companion check during PR review**: visually inspect the deployed page (or Cloudflare Pages preview) for any of the stoplist items listed above. If a page leaks engineering register, it's a P0 register defect — fix before merging to main.

Reference incident: 2026-06-08 the pilot page footer leaked `Total gen cost: $0.3703 ($0.359 illustrations + $0.011 TTS)` + file paths + `R389 #814` ticket on the live spark-and-anvil.com production surface. Caught via user-direct audit screenshot the same day; cleanup PR (spark-anvil-site #183) shipped same day. This rule prevents recurrence.

### Cross-references

- `Docs/SPEC_INTERLEAVED_ENSEMBLE_CHAPTER.md` — full sidecar manifest schema + gen-script CLI + site-renderer requirements
- `Docs/REGISTRY_DN_S_ENSEMBLE_PAIR_BONDS.md` — portfolio-wide registry of identified pair-bonds across DN-S ensemble chapters
- `Docs/PLAN_INCORPORATE_GOOGLE_STORYBOOK_CONCEPTS_PORTFOLIO_2026-06-08.md` § Wave 1 (b'/c') — parent plan
- `Docs/RESEARCH_NANO_BANANA_PRO_N3_FOLLOWON_PILOT_2026-06-08.md` § Test B — 9-character ensemble proof
- `Docs/RESEARCH_REFERENCE_IMAGE_CONDITIONING_PHASE2_PILOT_2026-06-08.md` — reference-image conditioning that preserves character identity across beats
- `gambittales-app/Docs/dn-s/chapters/the-pawn-cohort.md` — reference impl chapter naturally adopting all 5 patterns

## Auto-segmenter + ensemble-chapter generator (R-DN-S-TOOLING; 2026-06-09)

Per user-direct 2026-06-09 Storybook-rollout plan path B + C. Two hub scripts ship the foundation for portfolio-wide adoption of the interleaved Storybook chrome on cast-character chapters AND new ensemble-chapter creation:

### `scripts/auto_segment_chapter.py` (Path B foundation)

**Purpose**: take a chapter MD body, segment it into N beats by paragraph structure, emit a sidecar manifest JSON matching the pilot ensemble schema (`gambittales/the-pawn-cohort.beats.json`).

**Algorithm**:
1. Parse the chapter MD: front-matter + body
2. Split body into paragraphs (blank-line separated)
3. Group paragraphs into N beats by even-count split (floor + remainder to last beats)
4. Emit `<hub>/Resources/AutoSegmentedChapters/<app>/<chapter>.beats.json` with per-beat `prose-range: { from-line, to-line }` (1-based line numbers into the source MD), `kind` (opener/character/closer), `chars` (from front-matter `character:`), `rendering` (model: pro/flash; ref-image: opener for identity-locking).

**Default**: N=5. Override with `--beats <int>`.

**Used by**: Path B per-beat illustration gen + audio gen pipelines (next round); also Path C sidecar gen on top of `gen_ensemble_chapter_draft.py` output.

**Reference impl**: 8 pilot sidecars in `spark-anvil-hub/Resources/AutoSegmentedChapters/{curiosityquest,quillspell,proofquest,cubesensei,fractionforge}/` (shipped hub PR #763).

### `scripts/gen_ensemble_chapter_draft.py` (Path C foundation)

**Purpose**: generate a DRAFT ensemble chapter MD via Gemini 2.5 Pro for a given `(app, character-pair, primitive, setting)` tuple, following the 5-pattern ensemble-chapter spec above. Output is a draft for editorial review — NOT auto-distributed.

**CLI**:
```
python3 scripts/gen_ensemble_chapter_draft.py \\
    --app curiosityquest \\
    --pair "Revise,Linger" \\
    --primitive "patient inquiry" \\
    --setting "academy library at dusk" \\
    [--cohort-name "The Patient Pair"]
```

**Output**: `spark-anvil-hub/Resources/EnsembleChapterDrafts/<app>/<chapter-slug>.draft.md`. ~800-1500 words. Includes YAML front-matter (character / role / app / primitive / audience / status: DRAFT / pair-bonds[]); H1 title; 5 H-rule-separated beats; ≤120w paragraph blocks for clean audio narration; methodology sections (Voice register / Arc across kits / Relationships) at foot.

**Per-pair editorial workflow**:
1. Run the generator
2. Review the draft + polish prose (~30-60 min vs ~4 hours from-scratch)
3. Copy to `<app>-app/Docs/dn-s/chapters/<chapter-slug>.md`
4. Run `auto_segment_chapter.py` to produce the sidecar manifest
5. Distribute via `sync_content_to_site.sh`

**Reference impl**: 3 pilot drafts in `spark-anvil-hub/Resources/EnsembleChapterDrafts/{curiosityquest/revise-linger,mathcircle/circle-circe-echo-edie,cipherforge/sift-tally}.draft.md` (shipped hub PR <this round>).

**Cost**: ~$0.20-0.40 per draft (Gemini 2.5 Pro generation). Per-app pilot (1 ensemble chapter): ~$0.20. Portfolio-wide rollout (~138 apps × 1-3 ensemble chapters each): ~$30-160 generation + 30-60 min editorial review per draft (45-100 hours portfolio-wide editorial effort).

### When to use what

| Need | Tool |
|---|---|
| Wire existing opener + spot illustrations into single-character chapter pages with Storybook-feel | Already shipped (Path A — spark-anvil-site PR #201). No script needed |
| Segment a single-character chapter into 5-7 beats for the full Storybook upgrade | `auto_segment_chapter.py` (per-beat assets still need separate gen — Path B next-step) |
| Author a brand-new ensemble chapter for an app | `gen_ensemble_chapter_draft.py` + editorial review + `auto_segment_chapter.py` for sidecar |
| Add a new pair-bond to an existing ensemble chapter | Author by hand following the 5 patterns; the generator only does new chapters from scratch |

## Chapter content register stoplist (R-CHAPTER-REGISTER; 2026-06-05)

Per user-direct 2026-06-05 ("there are still mentions of 'load-bearing' in the chapters content. is that intentional?") + the same-round audit + scrub at `Docs/AUDIT_CHAPTER_CONTENT_REGISTER_LEAKS_2026-06-05.md`: **chapter MD body prose MUST NOT contain engineering / project-management / reviewer-framework jargon**. Engineering register reads as adult corporate language inside 9-14-year-old reading register and breaks the Magic Tree House / Wimpy Kid / Wonder / Hatchet register the chapters target.

### What goes WHERE (chapter MD structure)

Chapter MDs have THREE structural zones with different register rules:

| Zone | Lines | Reader-facing? | Register rule |
|---|---|---|---|
| **YAML front-matter** (`--- ... ---`) | top | NO (not rendered) | Internal hub metadata; engineering jargon FINE. `register:` / `chapter-round:` / `status:` etc. live here |
| **Chapter narrative** (the prose) | front-matter end → first `## Voice register` or `## Author's note` | YES | Age-9-14 register only. Per `.claude/rules/distributed-narrative.md` § DN-S Chapter-depth Authoring (Magic Tree House / Wonder / Hatchet band). NO engineering / project-mgmt / reviewer-framework / meta-pedagogy jargon |
| **Author / methodology sections** (`## Voice register`, `## Arc across kits`, `## Relationships`, `## Cultural-context note`, `## Author's note`) | bottom | YES (Astro renders the full MD via `<Content />`) | **Same register rule as the narrative.** Originally these were author-only metadata, BUT they're rendered to readers via Astro's full-MD render. Treat them as reader-facing |

### The stoplist (severity 3 — forbidden in chapter MD body anywhere)

Engineering jargon:
- `load-bearing` → `essential`
- `soft-collision` / `hard-collision` → `shared with` / `duplicates`
- `single source of truth` → `main source`
- `codified` / `codify` → `set`
- `superseded by` → `replaced by`
- `graduation criteria` / `kill criteria` → `when-ready signal` / `stop signal`
- `regression class`, `canonical`, `downstream`/`upstream`, `first-class`, `in-band`/`out-of-band`, `gating`/`ungated` — rewrite per context

Project-management jargon:
- `ADR-NNN` (standalone) → `an internal decision`
- `(per ADR-NNN)` / `per ADR-NNN approved` / `per user-direct YYYY-MM-DD` → drop
- `Phase A/B/C/D` → drop
- `R0 reviewer` → `an external reviewer`
- `PR #NNN`, `SHIPPED`, `MERGED`, `WIP`, `TODO`, `in-flight`, `Round N` — drop or rewrite

Reviewer-framework jargon:
- `SAMHSA` / `TIP 57` → `the trauma-informed framework`
- `validate-then-inform` → `name what is hard, then help`
- `trauma-gated` → `trauma-aware`
- `hold-space`, `refer-up`, `off-ramp` — context-dependent rewrite

Meta-pedagogy:
- `embody the primitive` → `show what the lesson teaches`
- `the cast IS the curriculum` → `the characters teach the lesson`
- `distributed-narrative` → `recurring-character`
- `anchoring phenomena/phenomenon` → `starting questions/question`
- `curricular primitive` → context-dependent rewrite

### Tooling

- **Audit** (read-only): `python3 spark-anvil-hub/scripts/audit_chapter_content_register.py [--tier {1,2}] [--app <slug>] [--min-severity {1,2,3}] [--json]`
- **Scrub** (one-shot remediation): `python3 spark-anvil-hub/scripts/scrub_chapter_content_register.py [--tier {1,2}] [--app <slug>] [--apply]` — applies the substitution table above; dry-run by default

### When this rule applies

- **Authoring a new chapter MD** (Tier-1 in `<app>-app/Docs/dn-s/chapters/` OR Tier-2 in `spark-anvil-hub/Resources/DN-S-Tier-Upper/chapters/<app>/`): use kid-readable equivalents from day one; run `audit_chapter_content_register.py --app <slug> --min-severity 3` before commit; chapter MUST have 0 severity-3 hits
- **Editing an existing chapter MD**: same rule applies — don't reintroduce stoplist tokens
- **Running a register rewrite pass** via `rewrite_chapter_register.py --tier {1,2}`: the rewrite prompt SHOULD include the stoplist as part of the rewriting constraints (future enhancement); for now, run scrubber post-rewrite as a safety net

### What this rule does NOT enforce (yet)

- **CI check**: not yet wired. Future enhancement: `audit_chapter_content_register.py --min-severity 3` could be wired into spark-anvil-site `prebuild` (matching the cast-portrait coverage CI check at the website-build level). For now, rule is human-discipline enforced.
- **Per-chapter manual review of tokens NOT auto-scrubbed**: `primitive` / `canonical` / `register` / `interface` are too context-dependent for safe auto-replace. Future: per-app handoffs for manual review when these surface in audit output.

### Cross-references

- `Docs/AUDIT_CHAPTER_CONTENT_REGISTER_LEAKS_2026-06-05.md` — Phase E audit + scrub artifact (1950 → 0 hits)
- `Docs/AUDIT_PDF_BOOK_CONTENT_REGISTER_2026-06-04.md` — sibling register audit at the FK / syntax level (this rule is at the lexicon level)
- `.claude/rules/spark-anvil-website.md` § "Cast portrait slug convention" — sister codification (parallel Phase A/B/C/D regression-class pattern + CI check)

## Tier-2 multi-beat reuse (R-TIER-2-MULTIBEAT-REUSE; 2026-06-13)

For dual-tier chapters (Tier-1 ages 9-12 + Tier-2 ages 11-14 per § Dual-tier chapter editions), **Tier-2 reuses the byte-identical Tier-1 beat illustrations via cp-with-rename, NOT separate illustration gen**. Tier-2 differentiation is carried by PROSE (denser register) + AUDIO (independently TTS-regenerated against Tier-2 MD).

Codified per `Docs/AUDIT_GAMBITTALES_READER_PERCEPTION_TIER_1_2_2026-06-13.md` which confirmed 25/25 beat illustrations were byte-identical across 5 GambitTales chapter pairs on live spark-and-anvil.com, while 5/5 audio files differed (Tier-2 ~29% larger reflecting denser prose). Reader-facing perception: visual reuse is invisible; differentiation lands via prose + audio.

### Asset shape

| Asset class | Tier-1 path | Tier-2 path | Relationship |
|---|---|---|---|
| Beat illustrations | `public/chapters/<app>/chapter_<char>_beat_NN.png` | `public/chapters/<app>/chapter_<char>-advanced_beat_NN.png` | byte-identical COPY |
| Chapter MD | `public/chapters/<app>/chapter_<char>.md` | `public/chapters/<app>/chapter_<char>-advanced.md` | independently authored (Tier-2 rewritten from snapshot baseline) |
| Audio M4A | `public/chapters/<app>/chapter_<char>_chapter.m4a` | `public/chapters/<app>/chapter_<char>-advanced_chapter.m4a` | independently TTS-regenerated |
| Audio VTT | `public/chapters/<app>/chapter_<char>_chapter.vtt` | `public/chapters/<app>/chapter_<char>-advanced_chapter.vtt` | independently regenerated to match T2 audio |
| Sidecar manifest | `public/chapters/<app>/chapter_<char>.beats.json` | `public/chapters/<app>/chapter_<char>-advanced.beats.json` | independently emitted (line-ranges index against the tier-specific MD) |

### When this rule applies

- Forward Tier-2 authoring for any app with shipped Tier-1 multi-beat
- Tier-2 backfill waves (per `Resources/DN-S-Tier-Upper/chapters/<app>/`)
- The `rewrite_chapter_register.py --tier 2` pipeline output

### When this rule does NOT apply (Tier-2 SHOULD get dedicated illustrations)

- Tier-2 prose adds NEW scenes not present in Tier-1 (e.g., extended denouement, new character intro)
- Tier-2 trauma-axis register meaningfully changes the SCENE depicted (e.g., trauma-aware register adds new safety framing visuals)
- Tier-2 narrative POV shift (e.g., 1st → 3rd person) where beat composition changes
- Founder-direct override for a specific app or cluster

In those carve-outs, Tier-2 visuals are independently gen'd at full ~$0.32/chapter cost.

### Cost

- Standard case (reuse): ~$0 marginal Tier-2 illustration cost (just file copy)
- Carve-out case (dedicated regen): ~$0.32/chapter Tier-2 illustration cost
- Portfolio-wide savings at universal-codification ceiling (~700 chapters): ~$110-220 depending on how many trigger carve-outs

### Sister rules

- § R-MULTIBEAT-DEFAULT — 5-beat canonical shape (governs both tiers symmetrically)
- § R-MULTIBEAT-SNAPSHOT — snapshot regen recipe (when retrofitting chapters; applies per-tier because each tier has its own snapshot)
- § Dual-tier chapter editions — parent dual-tier spec
- `.claude/rules/spark-anvil-website.md` § R-CHAPTER-HERO-SOURCE — beat 0 IS the chapter hero for both tiers (no separate opener)

### Cross-references

- `Docs/AUDIT_GAMBITTALES_READER_PERCEPTION_TIER_1_2_2026-06-13.md` — reader-perception audit that codified this rule
- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § Queue #869 — strategic Q resolved (DD-DEFERRED → AA-CODIFIED)

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
