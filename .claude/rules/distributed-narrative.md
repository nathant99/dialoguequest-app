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

### Dual-tier chapter editions (post 2026-06-04 audit + decision)

Per `Docs/AUDIT_PDF_BOOK_CONTENT_REGISTER_2026-06-04.md` the original chapters drifted to FK 10.5 (high-school+) — too dense for the 9-14 target. Per user-direct *"go all in 2-tier"* the portfolio chapters now ship in TWO tiers:

| Tier | Audience | FK target | Source location | Theme | Audience cap |
|---|---|---|---|---|---|
| **Tier-1 Standard** | ages 9-12 (lower MG) | 4-6 (Roald Dahl / Wimpy Kid) | `<app>-app/Docs/dn-s/chapters/*.md` (canonical app source) | Blubook | reaches 9-12 directly + 13-14 if reader prefers easier prose |
| **Tier-2 Advanced** | ages 11-14 (upper MG) | 7-8 (Wonder / Hatchet / Holes) | `labsmith/Resources/DN-S-Tier-Upper/chapters/<app>/*.md` | Folio | reaches 11-14 directly + via audio absorbs to 9-10 |

**Tier-1 lives in app repos** (read by ForgeKit / cameos / site /cast prose). Tier-2 lives only in labsmith (PDF rendering + audio drama source).

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

**Rewrite tool** (unified dual-tier, ships in `labsmith/scripts/`):
- `rewrite_chapter_register.py --tier 1` — Tier-1; mutates app-repo MDs in place; Gemini 2.5 Flash
- `rewrite_chapter_register.py --tier 2` — Tier-2; reads snapshot baseline; writes to `labsmith/Resources/DN-S-Tier-Upper/chapters/<app>/`; Gemini 2.5 Flash
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

**Reference impl chapter-length variance** (R385 #804 per user-direct 2026-06-01): GambitTales reference chapters range 1467-2580 words; 9 of 10 exceed the original 800-1500w spec cap. Per user directive **do NOT retroactively edit GambitTales chapters**. The spec is updated to treat 800-1500w as a TARGET range; ensemble-piece chapters (e.g., the-pawn-cohort @ 2580w) are explicitly allowed up to ~2600w when the chapter is itself an ensemble piece. Single-character chapters should still aim for the 800-1500w target; chapters that bundle multiple characters (twin-pairs, cohorts, ensemble framings) may extend up to ~2600w with rationale in the chapter front-matter.

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

The five patterns apply to **forward authoring of new ensemble chapters**. Per R389 #814 (`do NOT retroactively edit GambitTales chapters`), the patterns do **not** retroactively rewrite existing canonical chapters. Existing ensemble chapters that already happen to follow some of these patterns (e.g., `gambittales-app/Docs/dn-s/chapters/the-pawn-cohort.md` already uses the beat structure with `---` breaks + the 4-pair-bond cohort pattern) are surfaced via **sidecar manifest** (`<slug>.beats.json` in a labsmith-side or app-side path), NOT by modifying the chapter MD.

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

- **Generation cost figures** — labsmith internal accounting; never on a reader page
- **Internal file paths** (`gambittales-app/Docs/dn-s/...`, `labsmith/Resources/...`) — engineering surface
- **Ticket / round numbers** (`R389 #814`, "Round 2026-06-08", "Wave 1 (b'/c')") — labsmith workflow surface
- **GitHub doc links** to internal labsmith repos — engineering surface
- **Engineering jargon** in page titles, meta descriptions, footer attribution, header banners

Reader-facing pages — including pilot pages, `/cast/<app>/<char>`, `/stories`, `/books`, audio drama pages — receive the same register discipline as chapter MD body prose. Engineering metadata for source-code readers belongs in:

1. **HTML source comments** (`<!-- ... -->`) in the Astro page
2. **PR descriptions** (visible to engineers via GitHub)
3. **Labsmith findings docs** (`Docs/RESEARCH_*.md` / `Docs/PLAN_*.md`)
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

## Chapter content register stoplist (R-CHAPTER-REGISTER; 2026-06-05)

Per user-direct 2026-06-05 ("there are still mentions of 'load-bearing' in the chapters content. is that intentional?") + the same-round audit + scrub at `Docs/AUDIT_CHAPTER_CONTENT_REGISTER_LEAKS_2026-06-05.md`: **chapter MD body prose MUST NOT contain engineering / project-management / reviewer-framework jargon**. Engineering register reads as adult corporate language inside 9-14-year-old reading register and breaks the Magic Tree House / Wimpy Kid / Wonder / Hatchet register the chapters target.

### What goes WHERE (chapter MD structure)

Chapter MDs have THREE structural zones with different register rules:

| Zone | Lines | Reader-facing? | Register rule |
|---|---|---|---|
| **YAML front-matter** (`--- ... ---`) | top | NO (not rendered) | Internal labsmith metadata; engineering jargon FINE. `register:` / `chapter-round:` / `status:` etc. live here |
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

- **Audit** (read-only): `python3 labsmith/scripts/audit_chapter_content_register.py [--tier {1,2}] [--app <slug>] [--min-severity {1,2,3}] [--json]`
- **Scrub** (one-shot remediation): `python3 labsmith/scripts/scrub_chapter_content_register.py [--tier {1,2}] [--app <slug>] [--apply]` — applies the substitution table above; dry-run by default

### When this rule applies

- **Authoring a new chapter MD** (Tier-1 in `<app>-app/Docs/dn-s/chapters/` OR Tier-2 in `labsmith/Resources/DN-S-Tier-Upper/chapters/<app>/`): use kid-readable equivalents from day one; run `audit_chapter_content_register.py --app <slug> --min-severity 3` before commit; chapter MUST have 0 severity-3 hits
- **Editing an existing chapter MD**: same rule applies — don't reintroduce stoplist tokens
- **Running a register rewrite pass** via `rewrite_chapter_register.py --tier {1,2}`: the rewrite prompt SHOULD include the stoplist as part of the rewriting constraints (future enhancement); for now, run scrubber post-rewrite as a safety net

### What this rule does NOT enforce (yet)

- **CI check**: not yet wired. Future enhancement: `audit_chapter_content_register.py --min-severity 3` could be wired into spark-anvil-site `prebuild` (matching the cast-portrait coverage CI check at the website-build level). For now, rule is human-discipline enforced.
- **Per-chapter manual review of tokens NOT auto-scrubbed**: `primitive` / `canonical` / `register` / `interface` are too context-dependent for safe auto-replace. Future: per-app handoffs for manual review when these surface in audit output.

### Cross-references

- `Docs/AUDIT_CHAPTER_CONTENT_REGISTER_LEAKS_2026-06-05.md` — Phase E audit + scrub artifact (1950 → 0 hits)
- `Docs/AUDIT_PDF_BOOK_CONTENT_REGISTER_2026-06-04.md` — sibling register audit at the FK / syntax level (this rule is at the lexicon level)
- `.claude/rules/spark-anvil-website.md` § "Cast portrait slug convention" — sister codification (parallel Phase A/B/C/D regression-class pattern + CI check)

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
