# Distributed-Narrative Methodology

Portfolio-wide pedagogy: **named recurring characters embody curricular concepts** — the cast IS the curriculum, not decorative mascot dressing. Grounded in Bruner narrative learning + Habgood intrinsic integration.

**Status**: 100% portfolio coverage (138/138 active apps) as of 2026-05-22. Every app ships a documented cast + site-visible "Meet the cast" section.

## When this rule applies

Any app that has `distributedNarrative: true` in `spark-anvil-site/src/data/apps.generated.ts` AND/OR a `Docs/HANDOFF_FROM_HUB_DISTRIBUTED_NARRATIVE_RETROFIT.md` (canonical 2026-06-11+) or `Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` (legacy pre-2026-06-11) in its repo. **All active portfolio apps meet this criterion** post-2026-05-22 — DN is the portfolio default.

## The three variants

| Variant | When | Cast size | Hero mascot role | Trauma depth |
|---|---|---|---|---|
| **Standard** (most apps, ages 9-14) | Default | **≥10 named cast (incl. mentor) + ≥2 ensemble chapters** — see § R-DN-CAST-SIZE | Mentor distinct from cast OR mentor stays protagonist (e.g., MotifLab / writing-craft pattern) | Per-app gates as needed |
| **Aggregator-infrastructure** (Wave 27) | AdventureHub / ForgeArena / ForgeClassroom / ForgePortal | Cast #1 IS the AI mentor; 3-4 static others | Cast #1 doubles as mentor | Per-app (ForgePortal trauma-informed flag TRUE) |
| **Younger cluster** (Wave 29) | Ages 3–5 + lower Ages 6–8 apps (ADR-052) | 3-character cast (hero + 3 = 4 named core) — see § R-YOUNGER-CLUSTER-CAST-SIZE | Hero mascot stays PRIMARY protagonist (cast = friends) | None — scope explicitly gentle |
| **Bridge band** (grade 3 = top of Ages 6–8) | Grade-3 (age 8–9) apps | hero + ~5 + mentor (6–7) — see § R-BRIDGE-BAND-DESIGN | Hero-anchored, Pattern B | Per-app gates as needed |
| **Older-teen** (ages 15–18 / grades 9–12; NEW band, ADR-056) | Grades-9–12 apps (3 shipped: LedgerQuest·StudyForge·NorthQuest, 2026-07-19) | **ADAPTED DN-S** (NOT kid illustrated storybooks): ≥10 realistic case/scenario personas, self-authorship-aware voice — see § R-OLDER-TEEN-BAND-DESIGN + § R-OLDER-TEEN-DN-ADAPTED | Pattern A or B; mature/young-adult, not tween-cute | Per-app; trauma-aware + anti-evangelism for finance/civic/ethics |

> **Age bands (ADR-052 + ADR-056):** the portfolio uses FOUR age bands — **Ages 3–5** (Pre-K/K) · **Ages 6–8** (grades 1–3, incl. the grade-3 bridge at its top) · **Ages 9–14** (grades 4–8, the Standard/tween variant) · **Ages 15–18** (grades 9–12, the NEW Older-teen variant — ADR-056; 3 shipped apps + /play clones as of 2026-07-19; the portfolio was ages 3–14 before). The DN cast-size rules key off the app's CORE band: small hero-anchored (3–5 + lower 6–8, § R-YOUNGER-CLUSTER-CAST-SIZE) → ~6–7 bridge (grade 3, § R-BRIDGE-BAND-DESIGN) → ≥10 + ≥2 ensemble (9–14, § R-DN-CAST-SIZE; and 15–18, § R-OLDER-TEEN-BAND-DESIGN). `/play` browse zoning: `spark-anvil-website.md` § R-WEB-CLONE-AGE-BAND-ZONES (the 15–18 zone is LIVE, opened by LedgerQuest).

### R-YOUNGER-CLUSTER-CAST-SIZE — keep the ages-5-8 cast small + hero-anchored (2026-07-14)

**Every younger-cluster (ages 5-8) app uses a SMALL, hero-anchored cast: exactly ONE clearly-primary hero mascot (single-POV protagonist, Pattern B) + 2-4 supporting characters (default 3), for a total named core of 3-5 (target 4; hard ceiling ~5). Do NOT scale a younger-cluster app up to the standard-variant 4-6-supporting-+-mentor count — that count is calibrated for the 9-14 core's larger working memory, not for ages 5-8.** Codified per founder-direct 2026-07-14 (*"do deep web research about the optimal number of cast characters for the younger app cluster and codify that"*), full evidence in `Docs/RESEARCH_YOUNGER_CLUSTER_CAST_SIZE_2026-07-14.md`. The current younger variant (hero + 3 = 4 named core) is the research-optimal band — this rule AFFIRMS it + adds guardrails so future SPAWNs don't drift up.

**Why (convergent, four lines + exemplars):** (1) **working-memory / subitizing cap** — ages 5-6 hold ~4 forward-span items (much less for active manipulation; 29-46% of 5yo have span ≤3), and humans subitize ~3-4 at a glance, so a cast the child must recognize + tell apart + track should stay ≤~4 to leave capacity for the *learning* (same cognitive-load logic as `R-YOUNGER-CLUSTER-NO-MC-KITS`); (2) **parasocial depth > breadth** — the learning benefit rides a deep bond to a *favorite* well-characterized character (Elmo effect); a large cast dilutes attachment, a hero + few distinct friends maximizes it; (3) **picture-book craft** — center ONE protagonist told through a single POV + a small supporting cast (combine/cut anyone who doesn't move the story); (4) **executive function still maturing** — design to the low end of a wide 5-8 variability band. **Exemplar convergence:** Bluey core = 4, Daniel Tiger = 5, Khan Academy Kids = 5-with-1-lead (Kodi), Sesame = large roster but the child bonds to ONE — a small (≈4-5) deeply-characterized core with a clear anchor, plus (Bluey/Sesame) an optional *peripheral* layer the child is never required to track.

**The guardrails:**
1. **Exactly ONE primary hero** — the single-POV protagonist (Pattern B); the hero never demotes to a co-equal ensemble member.
2. **2-4 supporting (default 3)**, each visually + behaviorally DISTINCT (silhouette/color/role) + each embodying ONE learning primitive per the DN thesis; framed as "the hero's friends."
3. **Total named core 3-5 (target 4)** — never the standard-variant 4-6-supporting-+-mentor cast.
4. **Peripheral/background characters don't count against the cap** — a Bluey-style "other kids exist" layer is fine ONLY if the child is never required to recognize, name, or track them to use the app. Only the *tracked, named, learning-bearing* cast is capped.
5. **Depth over breadth** — deepen the existing 3 rather than add a 4th; combine two adjacent-primitive supporters rather than add a 5th.

**When it applies:** authoring/reviewing any younger-cluster (ages 5-8) DN cast — new SPAWN or retrofit. A younger-cluster app that grows its *tracked, named* cast past ~5, or that disperses focus off the hero into a co-equal ensemble, is a defect against this rule. Boundary is the AGE BAND (classify by the app's CORE target audience / `CLAUDE.md`), mirroring `R-YOUNGER-CLUSTER-NO-MC-KITS`. **Honest yield:** no single RCT tests "N companion characters is optimal for a kids' app"; this is a convergent synthesis (WM + subitizing + parasocial + picture-book craft + exemplar analysis), stated as evidence-aligned, not evidence-proven.

**Cross-references:** `Docs/RESEARCH_YOUNGER_CLUSTER_CAST_SIZE_2026-07-14.md` (the evidence base) · `.claude/rules/spark-anvil-website.md` § R-YOUNGER-CLUSTER-NO-MC-KITS (the sibling younger-cluster rule) · § "The three variants" (above) · § name-collision discipline (the registry check still applies to younger casts) · § Hero mascot vs. cast (Pattern B — the single-hero-primary pattern this rule requires).

### R-DN-CAST-SIZE — standard/tween (9-14) apps carry a RICH cast: ≥10 named members + ≥2 ensemble chapters (2026-07-15)

**Every standard-variant (ages 9-14 core) DN app MUST have a cast of AT LEAST 10 named members (supporting cast + mentor(s), each embodying a distinct curricular primitive per R-DN-PARITY) AND AT LEAST 2 ensemble chapters (multi-character chapters per R-ENSEMBLE-AUTHORING). A tween app that ships with a 4-7-member cast is UNDERSIZED and is a defect against this rule.** Codified per founder-direct 2026-07-15 (*"why 6 cast characters and not 10? codify that it's supposed to be at least 10 cast characters plus at least 2 ensemble chapters"*). This RAISES the former "standard variant = 4-6 supporting + mentor" floor — that count under-served the curriculum.

**Why (the curriculum-coverage argument):** a standard app carries a 16-kit arc, so there are far more than 6 distinct curricular primitives to embody. A 6-member cast forces several primitives to share one character (diluting the R-DN-PARITY "defining act IS the primitive" link) or leaves primitives with no character at all. A **≥10-member** cast lets (a) more of the 16-kit primitives each get their OWN character whose defining act IS that primitive, (b) richer relationships (alliances/tensions) across the cast, and (c) the ensemble chapters to actually have an ensemble to draw on. The reference DN apps (GambitTales, the AoPS cluster) run large casts for exactly this reason; the tween working-memory ceiling that caps the *younger* cluster (R-YOUNGER-CLUSTER-CAST-SIZE) does not bind at 9-14 — a tween reader tracks a large cast comfortably (chess, Pokémon, Harry Potter, Warriors all field 10+).

**The requirements:**
1. **≥10 named cast members** (supporting + mentor(s)), each mapped to a distinct primitive/kit from the app's 16-kit arc (R-DN-PARITY swap test per member). Aim to cover the arc's major primitives; a member may anchor a small cluster of closely-related kits, but avoid one character carrying many unrelated primitives.
2. **≥2 ensemble chapters** (R-ENSEMBLE-AUTHORING — 5-beat, pair-bonds/cohort, per-character spotlight beat), showing the cast's relationships + cross-primitive interaction (e.g., two primitives combining in one scene). Ensemble chapters count toward neither the "solo chapter per member" set nor against the ≥10 — they are additional.
3. **Each member still gets a Tier-1 5-beat solo chapter** (R-MULTIBEAT-DEFAULT + R-DIR-FEDC-CHAPTER + R-CHAPTER-REGISTER) — the ≥10 floor is a floor on *members*, and every member is a full cast member with a chapter, portrait, and (eventually) audio.
4. **A mentor counts toward the 10** (Pattern A or B), but a cast of 9 supporting + 1 mentor is the *minimum*; richer is welcome (GambitTales-scale 10-15 is ideal for a content-rich subject).

**Boundary / exemptions:** this rule is the **tween (9-14) counterpart** to R-YOUNGER-CLUSTER-CAST-SIZE and does NOT apply to the ages-5-8 younger cluster (which stays a small hero-anchored 3-5 core — the working-memory reason there is real). Classify by the app's CORE target audience (`clone.meta.ts` `gradeMin` / the app's `CLAUDE.md`), exactly as the younger-cluster rule does. The aggregator-infrastructure variant keeps its own smaller shape.

**When it applies:** authoring/reviewing ANY standard-variant DN cast — new SPAWN or retrofit. A spawn's `Docs/dn-s/README.md` roster + CONCEPT_SPAWN cast table must list ≥10 members + name ≥2 planned ensemble chapters; a cast under 10, or with <2 ensemble chapters, is a spawn defect. **Retrofit obligation:** the 4 apps spawned 2026-07-15 (WordForge · DeduceQuest · CrownTales · GridForge) shipped with 5-6-member rosters under the old floor and MUST be expanded to ≥10 + ≥2 ensemble (the current expansion wave). Name every new member registry-clean per § name-collision discipline before authoring.

**Cross-references:** § "The three variants" (standard row, updated) · § R-YOUNGER-CLUSTER-CAST-SIZE (the younger-cluster counterpart this pairs with) · § R-DN-PARITY (each member's defining act IS a primitive) · § R-ENSEMBLE-AUTHORING (the ≥2 ensemble chapters) · § R-MULTIBEAT-DEFAULT + § R-DIR-FEDC-CHAPTER (each solo chapter's shape) · § R-CAST-EXPANSION-INTEGRATION (adding members opens the 6-axis integration debt) · `Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` (name-registry check for new members).

### R-BRIDGE-BAND-DESIGN — grade-3 (ages 8-9) apps use the BRIDGE-BAND profile: MC-lite audio-supported kits + dominant CRA manipulatives + hero-anchored ~6-7 cast (2026-07-18)

> **⚠ REBANDED 2026-07-18 (ADR-052, 3-band taxonomy 3–5 / 6–8 / 9–14):** grade 3 (age 8) now lives at the **TOP of the Ages 6–8 band** (early childhood runs through age 8, NAEYC) — NOT a separate "bridge between 5–8 and 9–14." The BRIDGE-BAND *design profile* below is UNCHANGED and now describes the **upper edge of the 6–8 band** (grades 1–2 = lower 6–8, activity-forward + light/no-MC; grade 3 = upper 6–8, MC-lite). `/play` renders grade-3 clones in the **Ages 6–8 zone** (`ageBand: '6-8'`), with their siblings — the fix for the grade-3-hard-to-find incident. References to "the ages-5-8 younger cluster" below read as "the Ages 3–5 + lower Ages 6–8 bands"; "the seam of 5-8 and 9-14" reads as "the top of the 6–8 band."

**Every grade-3 (ages 8-9) app uses the BRIDGE-BAND design profile — the top of the Ages 6–8 band (ADR-052), the on-ramp from grades 1–2 into the ages-9-14 tween core. It is NEITHER convention: it RELAXES `R-YOUNGER-CLUSTER-NO-MC-KITS` (MC kits become viable — grade-3 readers can decode a light stem) but keeps them LIGHTER than the tween model, and it carries a cast SMALLER than the tween `R-DN-CAST-SIZE` ≥10 but RICHER than the younger `R-YOUNGER-CLUSTER-CAST-SIZE` ≤5. A grade-3 app built to the pure younger profile (no MC, ≤5 cast) or the pure tween profile (16×25 MC, ≥10 cast) is a defect against this rule.** Codified 2026-07-18 (founder-directed, after the two reference spawns), from the fit research `RESEARCH_NEW_APP_CONCEPTS_GRADE_3_READING_MATH_2026-07-17.md` §3 + `ADR-051` (band placement reframed by `ADR-052`).

**Why (grade 3 is the top of the 6–8 band):** age 8 is the last year of NAEYC early childhood (the 6–8 band); age 9 begins the 9-14 tween band — so grade 3 sits at the upper edge of 6–8 and no single existing convention fits. Developmentally (ages 8-9, concrete-operational): reading becomes fluent enough to "read to learn," so a lightly-worded MC stem is decodable (unlike the younger cluster) — BUT working memory + attention are still developing and manipulatives still dominate, and a "-Pals"-register / no-MC profile reads too young (NN/g "reads-too-young → disengage"), while the full tween MC-heavy / ≥10-cast profile is too heavy for transitional readers (~110 WCPM, not yet automatic).

**The profile (author + review any grade-3 app/clone against these):**
| Axis | Younger (5-8) | **BRIDGE (8-9)** | Tween (9-14) |
|---|---|---|---|
| **MC kits** | ❌ none (R-YOUNGER-CLUSTER-NO-MC-KITS) | ✅ **MC-lite** — **audio read-aloud on EVERY stem**, short stems, **~10-12 kits × 20** (not 16×25), the MC is the *check* | ✅ full 16×25 |
| **CRA manipulatives** | dominant (audio-first) | **dominant** — the manipulative is the *learning*, MC is the check (never MC-only) | present, less central |
| **Cast** | hero + ≤4 (3-5) | **hero + ~5 + mentor (6-7)**, Pattern B | ≥10 + ≥2 ensemble |
| **Reading load** | near-zero text, audio-first | **audio-SUPPORTED** (read-aloud toggle on all instruction — R-COGNITIVE-ACCESSIBILITY) | full text |
| **Fluency/anxiety** | no fail state | **anti-shame, no-timer default** + productive friction ON | mastery-gated |

**When it applies:** authoring/reviewing ANY grade-3 (ages 8-9) app — new spawn or retrofit — its kits, cast, `/play` clone, and DoD. Classify by the app's CORE audience (`clone.meta.ts` `gradeMin 3` / the app's `CLAUDE.md`), exactly as `R-YOUNGER-CLUSTER-*` classifies the 5-8 band. Reference impls: **ReadRise** (ELA) + **TimesQuest** (Math), spawned 2026-07-17; their **`/play` clones shipped 2026-07-18** (hub V353, site PR #934) — the reference bridge-band clone shape (CRA/SL manipulatives DOMINANT + MC-lite kits). **The canonical web impl of "audio read-aloud on every stem" is the shared `_shared/mcRound.ts` `readAloud` optional** (a backward-compatible additive optional — absent → byte-identical for every existing caller; on-device Web Speech, COPPA-safe): a bridge-band clone's kit runner passes `readAloud: true`. Reuse it — do NOT hand-roll per-clone stem audio. **Honest yield:** no single RCT tests "bridge-band N-cast / MC-lite is optimal"; this is a convergent synthesis (concrete-operational + fluency-onset + NN/g reads-too-young + the two existing band rules), stated as evidence-aligned, not evidence-proven.

**Cross-references:** § R-YOUNGER-CLUSTER-CAST-SIZE (the 5-8 band rule below it) · § R-DN-CAST-SIZE (the 9-14 band rule above it) · § R-DN-PARITY (each cast member's defining act IS a primitive) · § three DN variants · `spark-anvil-website.md` § R-YOUNGER-CLUSTER-NO-MC-KITS (the MC-kit rule this relaxes) · § R-WEB-CLONE-CRA-LADDER · § R-WEB-CLONE-GRADE-LEVEL (the grade-band declaration) · § R-WEB-CLONE-MASTERY-PROGRESSION (anti-shame fluency) · `cognitive-accessibility.md` § Reading-Access (audio read-aloud on stems) · `Docs/RESEARCH_NEW_APP_CONCEPTS_GRADE_3_READING_MATH_2026-07-17.md` §3 + `Docs/ADR-051_NEW_GRADE_3_READING_MATH_APPS_2026-07-17.md`.

### R-OLDER-TEEN-BAND-DESIGN — ages 15–18 (grades 9–12) apps use the OLDER-TEEN profile: mature register + self-authorship-aware DN + real-decision (AAR) mechanics + on-device data posture (NEW band, 2026-07-19)

**Ages 15–18 / grades 9–12 is a NEW fourth portfolio age band (ADR-056, extending ADR-052; the portfolio was ages 3–14 before). Every 15–18 app uses the OLDER-TEEN design profile — it is NEITHER the tween nor any younger convention: a young-adult/MATURE register (trust the reader; abstract/ideological/real-stakes content is expected — NOT tween-cute), the rich Standard cast shape (≥10 + ≥2 ensemble, R-DN-CAST-SIZE) with a SELF-AUTHORSHIP-AWARE voice, a real DECISION / Anticipation-Action-Reflection mechanic (never a survey/planner/decorated narrative), and the portfolio's on-device / no-account / no-PII data posture (a brand invariant — COPPA's under-13 rule doesn't bind at 15–18, but 13+ still warrants FERPA/teen-privacy care). A 15–18 app built to the tween register/cast/zone/data assumptions is a defect against this rule.** Codified 2026-07-19 (founder-direct *"first time we have concepts for 15–18 … codify this"*), from `RESEARCH_NEW_APP_CONCEPTS_AGENCY_9_14_AND_15_18_2026-07-19.md` + `ADR-056`.

**Why (late adolescence is developmentally distinct — E4):** identity work shifts exploration→commitment; **self-authorship** (internal authority over beliefs/identity, Kegan/Baxter Magolda) becomes possible; executive function consolidates (15–20); the prefrontal cortex catches the limbic system → real **future orientation + self-regulation**; abstract reasoning + metacognition mature → sustained engagement with ideological/civic/philosophical content. The agentic capacities (Bandura's four) are near-mature, so the design payoff shifts from *building* the capacity to *exercising* it over real-stakes life domains the 5–14 portfolio has no home for.

**The profile (author + review any 15–18 app/clone against these):**
| Axis | Tween (9–14) | **OLDER-TEEN (15–18)** |
|---|---|---|
| **Register** | warm tween | **young-adult / mature** — trust the reader; ideological/real-stakes OK, NOT cute |
| **Content domains** | school subjects | **real-stakes life-agency**: financial capability · civic/media reasoning · career/future self-authoring · ethical/deliberative reasoning · self-regulated study |
| **DN / DN-S** | ≥10 cast + ≥2 ensemble ILLUSTRATED chapter-books + audio dramas (the storybook form) | **ADAPTED DN-S — NOT the kid storybook form.** DN thesis KEPT (recurring named agents / cast-as-curriculum, swap-test) but delivered as **authentic real-world CASE/SCENARIO narratives with realistic personas** (not whimsical anthropomorphic mascots), identity-relevant + learner-directed, mature/self-authorship-aware voice. **NO cutesy illustrated chapter-books, NO cutesy audio dramas, restrained parasocial design.** See § R-OLDER-TEEN-DN-ADAPTED below |
| **Mechanic** | subject manipulatives + MC | **real DECISION / AAR loop** (set goal → forecast → commit → consequence → reflect); autonomy a real choice, never a coin-flip; NOT a survey/planner |
| **Data posture** | on-device, no PII | **on-device, no PII, no accounts** (brand invariant; FERPA/teen-privacy care) |
| **Content gates** | per-app | **trauma-aware + anti-evangelism** for finance/civic/ethics/values (ADR-016 family); crisis resources where relevant |
| **`/play` zone** | Ages 9–14 clusters | **Ages 15–18 zone — LIVE** (opened by LedgerQuest, R-WEB-CLONE-AGE-BAND-ZONES) |

**When it applies:** authoring/reviewing ANY ages-15–18 app — its concept-fit, kits/mechanics, cast, `/play` clone, and DoD. Classify by the app's CORE audience (`clone.meta.ts` `ageBand:'15-18'` / the app's `CLAUDE.md`), exactly as the younger/bridge rules classify their bands. **The band now has THREE shipped apps + `/play` clones (2026-07-19): LedgerQuest (personal-finance decision sim) · StudyForge (self-regulated-study coach) · NorthQuest (career/future self-authoring)** — the founding wave; further 15–18 apps stay founder-gated (R-NEW-APP-CONCEPT-FIT / R-NEW-APP-SPAWN-DOC). **Honest yield:** the games→agency evidence is modest + under-synthesized (E3b) — lead 15–18 apps with *decision-capability/skill* evidence, not over-claimed lifelong-behavior or RCT-proven-game-agency outcomes.

**Reference 15–18 `/play` clone build shape (the 3 founding clones are the template).** A 15–18 clone = a **deterministic AAR headline surface** (the pure engine — LedgerQuest `sim.ts` · StudyForge `srl.ts` · NorthQuest `future.ts`; Vitest-pinned; web-pioneered → iOS backport) + a **Concept MC bank** via the shared `mcRound` (a hub porter `port_<app>_kits.py`, in-session Opus, emitting to web + iOS `Resources/`) + **adapted-DN-S realistic personas** (no mascots/gen). ns must be globally unique; the SEL/subject keyword goes in `clusterOf` + a `clusters.test` case + the `clone.meta` override; expect a `play.css`-tail + `clusters.ts` **rebase seam** when a sibling 15–18 clone merges first (fix the dropped `}`, re-run `check-play-css-parse.mjs`, keep BOTH keyword sets).

**Anti-evangelism deterministic-surface pattern (for any values/identity/life-choice AAR surface — career, ethics, civics; NorthQuest is the reference).** When the domain has NO single "right" answer, the decision surface MUST NOT score or rank: each option is **value-tagged** (which value it honours) with an honest **trade-off**, and the reveal reflects the choice against the **learner's OWN stated values** ("this leans toward what you said matters"), never "correct/incorrect". Enforce it in the Vitest: **assert no scenario carries a `correct`/`best` field** + every option honours a DISTINCT real value (`northquest/future.test.ts` is the reference). This is the concrete build form of the § R-OLDER-TEEN-BAND-DESIGN + ADR-016 anti-evangelism gate; a scored "which path/career is right for you" recommender is a defect. (A domain WITH a defensible best answer — StudyForge's evidence-strongest study strategy, LedgerQuest's financially-sound `best` on non-life-choice scenarios — keeps a gentle sound-call tally; the anti-evangelism no-score form is only for genuinely values-dependent choices.)

#### R-OLDER-TEEN-DN-ADAPTED — DN-S is ADAPTED for 15–18, NOT the kid illustrated-storybook form (founder-direct 2026-07-19)

**A 15–18 app does NOT ship the standard kid DN-S storybook apparatus — no whimsical anthropomorphic-mascot illustrated multi-beat chapter-books, no cutesy audio dramas, no picture-scaffolded storybook cast pages (the 5–14 form). Instead, DN-S is ADAPTED into a developmentally-appropriate older-teen form: the DN *thesis* is kept (recurring named agents whose defining act IS the curricular primitive — the swap test, R-DN-PARITY) but delivered as AUTHENTIC, REAL-WORLD CASE/SCENARIO narratives with REALISTIC personas (professionals, near-peers, real situations — NOT anthropomorphic mascots), identity-relevant + learner-directed, in a mature/self-authorship-aware register. A 15–18 app built with kid-style illustrated character storybooks / cutesy audio dramas is a defect against this rule.** Codified per founder-direct 2026-07-19 (*"there should not be dn-s stories for the 15–18 age band"* + *"dn-s should be adapted for 15–18"*).

**Why (deep web research, 🔬 foreground-sequential):**
1. **Cute anthropomorphic-mascot storybooks BACKFIRE for teens** — the "childish backfire" is real; character aesthetics must be age-calibrated (sleek/realistic, not cute-round), and for older teens the whimsical-mascot chapter-book form reads as babyish. (Mascoteer/indie design guidance; Karen Cioffi on anthropomorphic children's characters being calibrated to *young* readers.)
2. **Teens are a HEIGHTENED over-attachment risk to anthropomorphic characters** — late adolescence is a period of heightened social-signal sensitivity; teens can hold "I know it's not a person" + "it feels like someone" at once → a *design-ethics* reason to keep parasocial mascot design RESTRAINED, not amplified. (arXiv "Adolescents & Anthropomorphic AI".)
3. **Illustration scaffolding is developmentally STAGED** — picture-facilitation helps younger children; older learners process abstract, text-based authentic scenarios and no longer need (or engage with) picture-scaffolded children's stories. **Relevance > illustration** for older learners. (PMC "More than pretty pictures?".)
4. **What DOES work for 15–18 = authentic case/scenario narrative** — Case-Based Learning (real-world scenarios → analysis/decision; more engaged + stronger critical thinking) and **Narrative Engagement Theory** (engagement rides *perceived realism* + *character identification*, not whimsy), plus the "from kids, through kids, to kids" authenticity + learner voice in the narrative's direction. (Yale/Queen's CBL; NET PMC; identity-relevance / learner-direction.)

**The adapted form (author + review against these):**
- **Personas, not mascots** — realistic humans / professionals / near-peers embodying the primitive (a "compound-interest" mentor is a real financial-literacy educator/scenario, not a cartoon coin creature). Swap test still applies.
- **Case/scenario narrative at boundaries, not illustrated chapters** — the "story" is an authentic real-world case the learner analyzes/decides on (R-NARRATIVE-BETWEEN-NOT-DURING still binds: narrative at session boundaries, decision mechanic in the loop).
- **Text-forward, sleek visuals if any** — no cute multi-beat WebP chapter art, no beat-illustration pipeline, no cutesy TTS audio drama. A realistic/photographic or clean-flat visual register only where it adds relevance.
- **Restrained parasocial design** — no engagement-maximizing anthropomorphic attachment hooks (composes with R-SITE-FEEDBACK no-dark-patterns + the teen over-attachment ethics note).
- **Identity-relevant + learner-directed** — hook on the learner's real interests/identity; give the learner say in the scenario's direction (autonomy — SDT/OECD co-agency).

**Consequence for the pipelines:** a 15–18 app does NOT run the DN-S chapter pipeline (`auto_segment_chapter` / `pilot_interleaved_ensemble_chapter` / cast-portrait mascot gen / audio-drama gen) or the `/cast` illustrated-chapter site surface. It has NO `Docs/dn-s/chapters/` mascot storybooks. Its "cast" is a set of realistic scenario personas surfaced in-mechanic. This makes 15–18 the FIRST band exempt from the standard DN-S story layer (DN was previously 100% portfolio coverage; that coverage statement is 3–14-scoped). **The WEB impl of this adapted DN-S is codified + SHIPPED (2026-07-22, ADR-066): a shared TEXT-FORWARD `_shared/caseNarrative` CASE-NARRATIVE shell (realistic personas + decision→consequence→reflect, ZERO illustrations) — reuse it, never hand-roll — see `spark-anvil-website.md` § R-WEB-CLONE-CASE-NARRATIVE; pilot = LedgerQuest/Priya (site PR #1225).**

**When it applies:** authoring/reviewing ANY 15–18 app or its `/play` clone. **Honest yield:** no RCT directly tests "adapted-DN-S vs kid-DN-S for 15–18"; this is a convergent synthesis (mascot age-calibration + teen over-attachment ethics + staged illustration benefit + CBL/NET authenticity), stated as evidence-aligned, not evidence-proven.

**Cross-references:** § R-OLDER-TEEN-BAND-DESIGN (parent) · § R-DN-PARITY (the swap test the adapted personas still pass) · § R-NARRATIVE-BETWEEN-NOT-DURING + § R-GUARD-THE-RATIO · `spark-anvil-website.md` § R-SITE-FEEDBACK (restrained/no-dark-pattern) · `Docs/ADR-056` (amended) · `Docs/RESEARCH_NEW_APP_CONCEPTS_AGENCY_9_14_AND_15_18_2026-07-19.md`.

**Cross-references:** `Docs/ADR-056_PORTFOLIO_15_18_AGE_BAND_AND_AGENCY_AXIS.md` (the band codification) · `Docs/RESEARCH_NEW_APP_CONCEPTS_AGENCY_9_14_AND_15_18_2026-07-19.md` (concepts + evidence) · `Docs/ADR-052_PORTFOLIO_AGE_BAND_TAXONOMY_3_5_6_8_9_14.md` (the taxonomy this extends) · § R-DN-CAST-SIZE (the ≥10 cast shape it shares) · § R-BRIDGE-BAND-DESIGN + § R-YOUNGER-CLUSTER-CAST-SIZE (sibling per-band rules) · § R-DN-PARITY · `spark-anvil-website.md` § R-WEB-CLONE-AGE-BAND-ZONES (adds `15-18`, zone deferred) · § R-SITE-FEEDBACK (data posture) · `cognitive-accessibility.md` § R-COGNITIVE-ACCESSIBILITY (baseline).

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

The portfolio's "DN methodology" synthesizes ALL FOUR effective game-narrative features identified in [Naul + Liu (2020) "Why Story Matters: A Review of Narrative in Serious Games" Journal of Educational Computing Research 58(3), 687-707](https://journals.sagepub.com/doi/abs/10.1177/0735633119859904) — namely (1) **distributed narrative** (narrative dispersed across the 16-kit arc + per-app site cast index + chapter pages, in the Crystal Island / Quest Atlantis tradition), (2) **intrinsic integration** (character behavior literally IS the curricular primitive, per [Habgood + Ainsworth 2011 "Motivating Children to Learn Effectively"](https://shura.shu.ac.uk/3556/1/Habgood_Ainsworth_final.pdf)), (3) **empathetic characters** (named cast with portraits, chapter backstories per § DN-S, voice register, and recurring relationships table), and (4) **adaptive / responsive storytelling** — realized via the **scaffold-on-top-of-static-narrative** pattern (Crystal Island model, not branching-narrative model). The portfolio's canonical adaptive-axis implementations are `ForgeMasteryEngine` (edge-of-competence problem selection) + `ForgeKnowledgeGraph` (content-suggestion traversal) + `ForgePedagogy.PolyaScaffold` (articulate-before-hint state machine) + `ForgeAI.CastDialog` (per-character FoundationModels-backed responsive voice; Phase 1 Move D approved) + per-kit `castCameos[]` variant selection keyed off learner mastery state (Move B with 2-3 variants per kit; see § DN-S Integration). All adaptive state lives on-device per portfolio COPPA + trust-signal discipline.

The portfolio borrows the FIRST feature's name as the umbrella label for the synthesis. The academic term "distributed narrative" in Naul + Liu means narrative dispersed across environmental artifacts to reduce cognitive load; the portfolio's compound usage adds intrinsic integration + empathetic characters under the same banner. Document this synthesis explicitly when citing the methodology in external-facing contexts.

**Contemporary commercial exemplar**: Story Time Learning's Storytime Chess + Storytime Backgammon (storytimelearning.com) — both products explicitly cite the Naul + Liu four-feature framework as their design basis. See `Docs/RESEARCH_STORYTIME_CHESS_BACKGAMMON_DN_EXEMPLARS_2026-06-13.md` for the full pedagogical-foundation synthesis + 11 sources.

**Foundational references** (cited across DN-S authoring + audit work):

- Naul + Liu (2020) — the four-feature framework + recommended design strategy (Figure 1); 4th feature (adaptive storytelling) deep-research synthesis at `Docs/RESEARCH_NAUL_LIU_4TH_FEATURE_ADAPTIVE_STORYTELLING_2026-06-13.md` + portfolio audit at `Docs/AUDIT_NAUL_LIU_4TH_FEATURE_PORTFOLIO_COVERAGE_2026-06-13.md`
- Habgood + Ainsworth (2011) + Cutting + Iacovides (2022) — intrinsic integration directs attention to learning-relevant features; the swap test above is grounded in this attentional mechanism
- Malone (1981) + Rieber (1996) — endogenous vs exogenous fantasy; the § "What the cast is NOT" stoplist below is grounded in Rieber's endogenous criterion
- Bruner (1986; 1991) — narrative cognition + spiral curriculum; DN-S 16-kit arcs spiral character action at increasing depth
- Lepper + Malone (1987) — intrinsic motivation taxonomy (challenge / curiosity / control / fantasy); DN apps target all four via cast-driven engagement
- Thue et al. (2007) + Lester + Rowe et al. (Crystal Island NCSU IntelliMedia 2009-2024+) — adaptive pedagogical-planner-on-top-of-static-narrative pattern; the portfolio's adaptive axis is grounded in this scaffold-layer adaptation, NOT branching-narrative adaptation, per the authoring-burden constraint identified in Naul + Liu § Cautionary notes
- Greenspan + Wieder (1998) DIR/Floortime + Vygotsky ZPD (1978) + Collins-Brown-Newman cognitive apprenticeship (1989) — converge on **follow-the-learner's-lead** as the canonical scaffolding principle; portfolio operationalization in 5 primitives (`castCameos[]` variant selection / `CastDialog` open-ended responses / `ForgeKnowledgeGraph` suggestions / `ForgeMasteryEngine.NextProblemPicker` / `PolyaScaffold.hintsAllowedBeforePlan: 0`); full alignment table in `.claude/rules/forgekit.md` § ForgePedagogy — scaffolding theory alignment R1
- Kapur (2008) productive failure + Bjork + Bjork (2020) desirable difficulties + Collins-Brown-Newman articulation method (1989) — articulate-before-hint trio; converge on the SAME pedagogical principle (effortful encoding before instruction enhances retention + transfer); portfolio operationalization is `PolyaScaffold.hintsAllowedBeforePlan: 0` paired with anti-shame discipline (cast voice register + anti-credentialism gate). Full alignment in `.claude/rules/forgekit.md` § ForgePedagogy — scaffolding theory alignment R3

**Counter-evidence + design-principle layer (2026-07-07 lift; adventure-modes-vs-mini-games research).** DN is validated *as intrinsic integration* — but the same literature warns that **narrative helps *behavioral* outcomes (practice minutes, completion, return), NOT *cognitive* ones**, and *decorative* narrative *during* the learning loop actively hurts. The failure mode to warn against is **decorative narrative as a seductive detail on the critical path + an unwatched game-to-learning ratio.** Sourced from `fractionforge-app/Docs/RESEARCH_ADVENTURE_MODES_VS_MINIGAMES_2026-07-07.md` (~25 sources; primary = a user-supplied deep-research report):

- **Wouters et al. (2013) + Clark, Tanner-Smith + Killingsworth (2016) + Sailer + Homner (2020)** — the *narrative moderator is non-significant* for cognitive learning (Clark's trend even favors *no* narrative; schematic visuals beat realistic/cartoon); "game fiction" yields a positive **behavioral** effect (practice minutes / completion) but **no** cognitive/motivational gain. Narrative wins the *first click*, not the *test score*.
- **Adams + Mayer et al. (2012) — the distraction hypothesis** — students learned *more* from a plain slideshow than from the narrative games Crystal Island / Cache 17; a strong story functions as a **seductive detail** that drifts attention from "understanding" to "winning."
- **Seductive-details meta-analysis (2025, 177 effect sizes)** — small but significant **negative** effect on learning (g ≈ −0.16), mechanism = extraneous cognitive load; **worst when the core task is already hard** (cognitive-load moderator).
- **Brom et al. (2022, N=11,949) — catch vs. hold** — an integrated shooting mini-game *caught* interest better than a plain quiz (61.8% vs 53.6% finished L1) but the quiz *held* it better and produced **~25% more correct practice with fewer errors**. Even minimal game mechanics cut correct practice ~25%. Maps to **Hidi + Renninger (2006)** four-phase interest (catch ≠ hold). "Integrated mechanics are not a panacea."
- **Sýkora, Stárková + Brom (2021, home RCT)** — story cutscenes added **no** measurable learning advantage. **Habgood's own Zombie Division caution** — children were *more accurate outside* the game than within → argues for **companion reflection outside the loop** (= R-DIR-FEDC reflection-prompts).
- **The five design principles** every DN app should honor (the operational takeaway): **(P1)** integrate at the mechanic level [= § R-DN-PARITY swap test]; **(P2)** narrative BETWEEN practice, not during it [= § R-NARRATIVE-BETWEEN-NOT-DURING]; **(P3)** guard + measure the game-to-learning ratio [= § R-GUARD-THE-RATIO]; **(P4)** companion reflection outside the loop [= R-DIR-FEDC-CHAPTER reflection-prompts]; **(P5)** monetization orthogonal to learning/status (the Prodigy critique is a telemetry + monetization finding; the portfolio's no-IAP/no-ads posture is a structural moat). P1 + P4 are already codified; P2 + P3 are codified below; P5 is portfolio-structural.

## R-NARRATIVE-BETWEEN-NOT-DURING — narrative at session boundaries, not on the active learning loop (2026-07-07)

**Cast cameos, chapter beats, and any narrative surface MUST render at session boundaries (kit preview / results / the calm chapter reader) — NEVER overlaid on the active problem-solving loop.** During the practice moment itself the surface stays *schematic* (clean primitive representation; no busy scene, no chatter). Grounded in the distraction-hypothesis + seductive-details evidence above (P2): narrative on the critical path is extraneous cognitive load that measurably depresses learning, worst when the primitive is hard.

- **The test**: does this narrative element render *while the learner is actively solving*? If yes → move it to a boundary (before the kit, on the results screen, or in the chapter reader). A cameo that *demonstrates the primitive at a boundary* is integration; a cameo that *chatters during a hard problem* is a seductive detail.
- **Companion to R-DN-PARITY**: the swap test governs *whether the mechanic is the content*; this rule governs *where the narrative sits relative to the loop*. Both must hold.
- **Reference impl**: FractionForge (per-kit `castCameos[]` surface at kit-preview/results boundaries; chapters are a separate calm reader; active mode views are schematic). Audit new cameo/illustration placement against this before shipping.
- **Scope**: applies to every DN app's gameplay + practice surfaces. Does NOT restrict the chapter reader / `/cast` site pages / audio drama (those ARE the between-practice narrative surfaces).

## R-GUARD-THE-RATIO — measure learning-relevant actions per session minute (2026-07-07)

**Every practice / game surface SHOULD instrument the game-to-learning ratio — learning-relevant actions (answers, selects, retrievals) per session minute vs. non-learning (decoration / animation / navigation) time — so decoration can never silently crowd out the content.** The Prodigy cautionary tale (educator estimates of ~5 min decorating : 2 min problem-solving at higher levels; the 2021 Fairplay/FTC complaint audited 16 membership ads vs 4 math problems in 19 min) was a *telemetry* finding — invisible without the ratio signal.

- **What to instrument**: a lightweight per-session counter of learning-relevant interactions ÷ session minutes, watched across levels/kits (the ratio tends to decay as decoration accretes). `ForgeAnalytics` is the natural home; on-device only (COPPA), no new network.
- **Hub scope**: this rule is DESIGN + Definition-of-Done guidance for app sessions — **hub does not write the Swift**. A shared `ForgeAnalytics` learning-actions-per-minute helper is a candidate **ForgeKit handoff** (queued), so apps adopt one primitive instead of each rolling their own.
- **Reference impl**: FractionForge L1 (Q29) — a learning-actions-per-minute counter on the mode session lifecycle (extends `DebugLog`; headless-doable).
- **Pairs with P5** (monetization orthogonal): the portfolio's no-IAP/no-ads posture removes the *incentive* to crowd out learning; the ratio signal makes any accidental crowd-out *observable*.

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

### R-NAME-CHECK-LIVE-APPS-GENERATED — the registry file LAGS shipped casts; grep live `apps.generated.ts` too (2026-07-16)

**The name-collision check MUST grep BOTH `Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` AND the live ground-truth `spark-anvil-site/src/data/apps.generated.ts` (the shipped `dnCast.members[]`), because the registry FILE lags the shipped casts — a name shipped in a recent wave often has ZERO registry hits while being live in `apps.generated.ts`.** This is `R-CANONICAL-DOC-GROUND-TRUTH` applied to the name registry: the registry is a secondary doc that drifts; the shipped `apps.generated.ts` is ground truth. A registry-only grep returning 0 hits does NOT mean the name is free.

**Reference incident (2026-07-16, coverage-program Wave C):** a climatequest cast-expansion authored a solo named **Sheen**; the registry grep returned 0 hits (clean), so the chapter was authored, gated, and its source PR merged — but **pixelforge had shipped a character literally named "Sheen" in session-2** (live in `apps.generated.ts`, never recorded in the registry file). It surfaced only when the dnCast registration grep hit the live file, forcing a rename (Sheen→Glint) AFTER the chapter was merged — an app PR + re-segment + audio-regen of rework that a live-file grep at naming time would have avoided entirely.

**The check (run BOTH, before authoring):**
```bash
for n in Cand1 Cand2 Cand3; do
  r=$(grep -ci "\b$n\b" Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md)
  a=$(grep -c "\"name\": \"$n\"" ../spark-anvil-site/src/data/apps.generated.ts)  # live shipped dnCast
  printf "%-10s registry=%s apps.generated=%s\n" "$n" "$r" "$a"   # BOTH must be 0
done
```
An exact hit in `apps.generated.ts` (even with registry=0) is a rule-1 hard collision → pick another name. Especially load-bearing in the **coverage / cast-expansion program**, where names are chosen wave-after-wave and recently-shipped siblings won't be in the registry yet.

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

### R-DN-CAST-ORDER — surface a cast/story list in `dnCast.members[]` ARC order, never alphabetical (2026-07-19)

**Any site surface that lists an app's cast members OR their stories/chapters MUST order them by the character's index in `apps.generated.ts` `dnCast.members[]` — the authored curriculum-ARC order (the sequence the app introduces each primitive) — NOT alphabetically by character name. An ensemble/combined chapter (e.g. "Equi and Stretch") slots by its EARLIEST constituent member; anyone not in the roster (mentor/stray) sorts last, then alphabetical as the final fallback.** The `dnCast.members[]` array IS the pedagogical arc (e.g. fractionforge: Halver→Pie→Equi→Stretch→Dot→Liner→Gather→Times→Tenth→Rank = partition→wholes→equivalence→common-denom→decimals→number-line→operations→compare); an alphabetical sort scrambles it (Dot→Equi→Gather→Halver…), which reads as random to a learner. Codified after a founder-caught defect: `/story` sorted each app's stories A→Z by character name (site PR #1074 fix). **When it applies:** `/story` (done), and any future cast surface — the `/play` cast rail (`PlayNarrative`), `/cast`, a cast picker. Build a per-app `name→index` rank map from `dnCast.members[]`; sort by `(rank, name)`. **Cross-refs:** `spark-anvil-site/src/pages/story/index.astro` (reference impl: `MEMBER_RANK` + `arcRankFor`) · § R-DN-CAST-SIZE (the arc the members encode) · `.claude/rules/spark-anvil-website.md` § R-WEB-CLONE-NARRATIVE-INTEGRATION (the `/play`↔`/story` cast surfaces).

### R-APP-REGISTER-MIRROR-SHAPE — registering a spawned app in `apps.generated.ts` MIRRORS an existing valid entry's EXACT field set; never invent fields (2026-07-18)

**When registering a newly-spawned app in `spark-anvil-site/src/data/apps.generated.ts` (the Wave-B DN registration step), MIRROR a known-good existing entry's EXACT field set — do NOT invent fields, and match the `AppData` interface types precisely.** The file is `AppData[]`-typed, so an excess/mistyped field red-builds the CORE Cloudflare deploy (apps.generated.ts is a core-unit input, so `build:play` does NOT catch it — R-SITE-CORE-PARSE-GATE). The gotchas that cost a revert this session (V378): **(a)** `standards` is `string[]` (an array of standard codes), NOT a plain string; **(b)** `wave` is `number | null` (use `null` for a new app), NOT a string like `"V378"`; **(c)** there is NO `ageBand`/`gradeBand` field on `AppData` — the age band lives in the clone's `clone.meta.ts` (R-WEB-CLONE-AGE-BAND-ZONES), NEVER in apps.generated.ts; **(d)** a shipped reference app (e.g. `readrise`) omits `iconPath`/`iconHeroPath`/`mascotPath` — mirror that omission. **Discipline:** parse a known-good entry first (`json.loads` a brace-matched object), copy its key set verbatim, fill your values; then VERIFY both (1) `node -e "require('esbuild').transformSync(fs.readFileSync('src/data/apps.generated.ts','utf8'),{loader:'ts'})"` (syntax) AND (2) a bracket-matched `json.loads` of the whole `apps` array with a per-new-app `keys_extra == set()` check (structure + no excess keys) BEFORE the PR. This is R-CANONICAL-DOC-GROUND-TRUTH applied to a typed data file: mirror the shipped reality, verify, never guess. Reference: `scripts/register_v378_apps_in_site.py` (the 6-younger-band registration).

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

#### R-COVERAGE-OPUS-AUTHORING — ALL new coverage-program chapters are authored by in-session Opus, never the Gemini-Pro draft script (2026-07-13)

**Every NEW chapter authored for the multi-beat coverage program (the founder-⭐ "≥10 multi-beat T1 + ≥10 multi-beat T2 + ≥2 ensemble + audio for all" target — `Docs/AUDIT_CHAPTER_MULTIBEAT_AUDIO_COVERAGE_2026-07-13.md`) MUST have its PROSE authored by the in-session Opus model (the running Claude Code session), NOT by the scripted Gemini-2.5-Pro draft path (`gen_ensemble_chapter_draft.py` / `gen_single_character_chapter_draft.py`).** Codified per founder-direct 2026-07-13 (*"there should be a rule in the repo that says to use in-session Opus to gen all the new chapters"*). This **OVERRIDES** the R-AUTHOR-MODEL-CHOICE "portfolio-scale batch (>5 chapters) → scripted Gemini Pro" carve-out **for the coverage program specifically** — the batch-scale exception does not apply here; quality (voice / character consistency / swap-test-passing intrinsic integration / affect-anchored DIR-FEDC closers) is the whole point of the program, and the research (Inkfluence 7-dim rubric, blind human eval, LMArena) puts in-session Opus top on exactly those axes. Cost is a non-issue: in-session Opus is **$0 marginal** (Claude Code subscription absorbs it), so the founder-budgeted "~$700-1,000 Gemini" is now **art + TTS only** (beat illustrations + narration), never prose drafting.

- **Scope — PROSE only.** "Gen the chapter" here means author the ~1,200-1,800-word 5-beat narrative + the 5 canonical methodology sections + the DIR-FEDC `reflection-prompts` + affect-anchored closer. The **illustration** pipeline (Pro beat 0 + Flash beats) and the **TTS narration** still run through the Gemini scripts — Opus cannot produce those, and this rule does not change them.
- **The per-chapter loop** becomes: (1) in-session Opus writes the chapter MD directly at the canonical source path (T1 `<app>-app/Docs/dn-s/chapters/<slug>.md`; T2 `Resources/DN-S-Tier-Upper/chapters/<app>/<slug>.md`), pre-framing the register card + reading the app's YAML/primitive first, per the § "In-session authoring discipline" checklist below; (2) `auto_segment_chapter.py` segments it; (3) `pilot_interleaved_ensemble_chapter.py` gens beat art + TTS; (4) gate stack (text-leak / anatomy / DIR-FEDC / register / narrative-quality) + swap-test; (5) distribute + R2 upload + site sync + PR. The gate stack is unchanged — but because Opus authored the prose, the narrative-quality + swap-test gates should pass on the first pass, not after a spec-sheet remediation (the failure class R-CHAPTER-NARRATIVE-QUALITY was built to catch in Gemini-batch output).
- **Throughput consequence (accepted):** in-session authoring is slower than a batch draft script, so the program is inherently multi-wave / multi-session. That is the accepted trade for quality — do NOT reach for the Gemini-Pro draft script to "go faster." If a wave is large, author fewer chapters correctly rather than batch-drafting many.
- **`gen_ensemble_chapter_draft.py` / `gen_single_character_chapter_draft.py` remain in the tree** for any NON-coverage-program batch need, but are NOT used for coverage-program chapters. A coverage-program chapter whose prose was Gemini-drafted is a defect against this rule.
- **⚠ Before authoring a SPAWNED app's DN-S chapters, READ its `Docs/dn-s/README.md` FIRST + grep origin for sibling-authored chapters — the canonical cast (names + animals + primitives) is ALREADY designed + name-reserved in that README at spawn; NEVER invent a parallel cast, and NEVER author without the origin-check (2026-07-19/20, multi-band spawn wave).** A spawn scaffolds `Docs/dn-s/README.md` with the canonical roster (e.g. tallytots = Ribbet + Dottie[ladybug=subitizing] / Wriggle[caterpillar=successor] / Clutch[hen=cardinality]), and those member names are reserved in `apps.generated.ts` (`registry=1 apps.generated=1` at name-check). Authoring against invented names (the session that wrote Pib/Roon/Cluck instead of reading the README) is a double defect: (a) it forks the canonical cast, and (b) on a saturated fleet a **sibling lane is very likely ALREADY authoring the same canonical cast** — the multi-band wave's tallytots/lettertots/blocktots/latticeforge DN-S was authored end-to-end (chapters + portraits + registration + `/cast` live) by a parallel lane while a second session independently re-authored tallytots to invented names → a full duplicate caught only at the cherry-pick conflict (discarded per `workflow.md` § R-PARALLEL-HUB-AGENTS §5b). **The discipline (§5a applied to DN-S):** (1) read `Docs/dn-s/README.md` for the canonical cast; (2) `git ls-tree origin/main -- <app>-app/Docs/dn-s/chapters` (line-count, not `&&`-echo) — if chapters exist, the cast is done, DISCARD your plan; (3) only then author to the README's exact names/animals/primitives. A spawned-app DN-S cast is NEVER a naming-creativity task — it's a pre-reserved roster to fulfill.

**When it applies:** every chapter authored to close a coverage-program deficit (T1 cast-expansion chapters, T2 mirrors' new prose, ensemble backfills). **When it does NOT:** T2 prose that is a mechanical register-rewrite of an existing Opus-authored T1 via `rewrite_chapter_register.py` is a *rewrite*, not fresh authoring — but the coverage program prefers in-session Opus for T2 prose too when the T2 voice needs genuine authoring judgment (the rewriter is acceptable for a straight FK-band lift). **Cross-refs:** R-AUTHOR-MODEL-CHOICE (parent) · R-MULTIBEAT-DEFAULT · R-DIR-FEDC-CHAPTER · R-CHAPTER-NARRATIVE-QUALITY · R-ENSEMBLE-AUTHORING · `Docs/AUDIT_CHAPTER_COVERAGE_SNAPSHOT_2026-07-13.md`.

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

### R-DIR-FEDC-CHAPTER — Affect-anchoring required on every multibeat chapter (2026-06-27)

Per the V18 DIR/Floortime therapist review (`Docs/RESEARCH_AND_AUDIT_DIR_FLOORTIME_THERAPIST_FEEDBACK_2026-06-25.md`) and Greenspan's Functional Emotional Developmental Capacities (FEDC 5+, where abstract reasoning is built FROM affect-anchored emotional experience): **every NEW multibeat chapter (single-character OR ensemble) MUST ship two affect anchors.** This was author-discipline through V22 (FractionForge followed it by hand); V23 makes it an enforced gate.

| Requirement | What | Why |
|---|---|---|
| **1. Affect-recognition reflection-prompt** | `reflection-prompts[]` front-matter with **≥1** prompt that invites the reader's OWN felt-sense — either names a feeling/body-sensation OR uses a reflective second-person invitation ("Have you ever felt…?", "Is there something you…?"). Canonically placed after beats 1 + 4. | Reader empathy (therapist Axis 1 + Pixar Rule #15). The reader maps the character's experience onto their own. |
| **2. Affect-anchored closer** | The final narrative beat ends on the **felt-sense**, not the bare math/concept. The V18 `halver.md` P0 was exactly this: "it ended on the math instead of the feeling." | FEDC: the emotional anchor is what makes the abstract idea stick. A math-only ending strands the concept without affective scaffolding. |

**The gate** — `scripts/audit_chapter_dir_fedc_compliance.py`:

- `NO_REFLECTION_PROMPTS` (high) — front-matter has no `reflection-prompts:` list
- `NO_AFFECT_PROMPT` (medium) — has prompts but none is affect-recognition (no feeling word AND no reflective second-person invitation)
- `MATH_ONLY_CLOSER` (high) — the closer paragraph names the primitive / a math term but contains NO affect/feeling word

**⚠ The coda trap — the gate checks the LITERAL LAST narrative paragraph, so a strong affect paragraph followed by a lighter "and life went on" coda silently FAILS `MATH_ONLY_CLOSER` (2026-07-16, DecodeForge DN-S wave — bit 5 of 13 chapters at once).** The natural authoring instinct is to hit the emotional climax and then add a gentle wind-down coda after it (a callback, a "he never charged anyone," a "she still brings the cake every year"). That reads well — but `last_paragraph()` takes the FINAL non-rule paragraph, and if the affect landed a paragraph or two *earlier* and the coda is affect-free, the gate flags it even though the chapter genuinely ends on feeling *in intent*. **Fix = put the felt-sense in the FINAL paragraph itself** (fold the feeling into the coda, or drop/shorten the coda so the affect paragraph IS the last one). This is also better writing — a chapter should end on the emotion, not trail off past it. Verify with a gate re-run, not by eyeballing "there's a feeling in there somewhere."

**⚠ The `reflection-prompts` front-matter FORMAT is a list of `- beat-after: N` + `prompt: "…"` OBJECTS, NOT a bare string list — the gate silently reports `NO_REFLECTION_PROMPTS` on a bare list (2026-07-18, V378 younger-band wave).** `parse_reflection_prompts` matches `^\s*-?\s*prompt\s*:\s*(.+)$` — i.e. it only sees a nested `prompt:` key. So this FAILS the gate even though prompts are present:
> ```yaml
> reflection-prompts:
>   - Have you ever felt…?        # ❌ bare string — gate sees NONE → NO_REFLECTION_PROMPTS
> ```
> and this PASSES (the canonical shape, e.g. fractionforge/equi.md):
> ```yaml
> reflection-prompts:
>   - beat-after: 1
>     prompt: "Have you ever felt…?"   # ✅ object with a prompt: key
> ```
Author reflection-prompts in the object shape from the start; if a NEW chapter flags `NO_REFLECTION_PROMPTS` while it visibly has prompts, this format mismatch is the cause (not a missing prompt).

Run gate-mode on the chapters being shipped (forward-looking; do NOT retroactively fail the pre-convention backlog):

```bash
python3 scripts/audit_chapter_dir_fedc_compliance.py --ci-mode --files <changed-chapter-md> [...]
```

The gate is wired into the opt-in per-app pre-push hook (`scripts/git-hooks/pre-push-chapter-checks.sh`, gate #3) scoped to chapters changed in the push, and into the in-session pipeline below (step 5a). **FractionForge V22 (liner/gather/times/tenth/rank) is the reference impl — all 5 pass gate-mode.**

**Trauma-axis note**: trauma-gated chapters use the SAMHSA body-sensation register (ADR-016/021), a *stricter* form of the same affect-anchor principle — the gate's affect lexicon includes body-sensation words (breath / shoulders / steady / unclench …) so those pass by construction.

**When it applies**: every new/rewritten multibeat chapter in the cast-expansion + ensemble rollout (FractionForge → NumberSense → GeometryForge → rest of Math → ELA → Science → …). **When it does NOT**: pre-convention backlog chapters (surfaced for visibility by a bare portfolio run, not a merge blocker); asset-only regens with no prose change.

**Cross-references**:
- `Docs/RESEARCH_AND_AUDIT_DIR_FLOORTIME_THERAPIST_FEEDBACK_2026-06-25.md` — the 5-axis therapist feedback (source of truth)
- `.claude/rules/forgekit.md` § R-FORGEPEDAGOGY-SCAFFOLDING — R1/R3/R7 DIR/Floortime alignment
- `fractionforge-app/Docs/dn-s/chapters/halver.md` — V18 end-on-feeling rewrite reference impl
- `scripts/audit_chapter_dir_fedc_compliance.py` — the gate

### R-CHAPTER-NARRATIVE-QUALITY — spec-sheet / raw-spec / register-leak gate (2026-07-07 / V29)

Per the V28 methodology-conformance audit (`Docs/AUDIT_CHAPTER_METHODOLOGY_CONFORMANCE_2026-07-07.md`): the dominant WEAK-tail failure is a **"spec-sheet / character-bible" authoring-debt class** — ~433 chapters (and ~792 deterministically-detectable across both tiers) that shipped as **bullet scaffolds + raw prompt-cue design briefs** and were never rendered into 5-beat narrative. They score 1 on both `bruner_narrative_mode` (no story) and `intrinsic_integration` (concept announced, not dramatized). They slipped every prior gate (text-leak / anatomy / DIR-FEDC / register / dup-key) because none parsed narrative *form*.

**The gate** — `scripts/check_chapter_narrative_quality.py` — is **deterministic (no LLM)** and detects the mechanical signatures of the class. A chapter is a DEFECT if any HARD signal fires:

| Signal | What | Threshold |
|---|---|---|
| `register-leak` | high-confidence engineering/PM/reviewer jargon in the NARRATIVE body (`LOAD-BEARING` / `Habgood` / `codified` / `intrinsic integration` / `the primitive I teach` / `ADR-N` / `PR #N` / `Round N #N` / `SAMHSA` …) | any |
| `spec-phrasing` | character-bible phrasings (`signature feature`, `embodies the … primitive`, `the move is`, `anti-pattern:`, `scaffolds:`, `most novices think`, `is appointed` …) | ≥2 distinct |
| `bullet-scaffold` | narrative bullet-line ratio > 12% AND zero `---` beat breaks | ratio+beats |
| `raw-spec-markers` | dense inline-italic design-cue fragments (`*small*`, `*Watch.*`) — **enricher only**, never a standalone trigger (legit chapters use 15-42 emphasis italics) | co-occur |

Calibrated to **near-zero false positives**: 8/8 known P0 bugs flag; 0/68 flagship CONFORMS chapters (alcumusforge/mathcircle/gambittales/proofquest/fractionforge/numbersense) flag. Low false-positive is paramount — a gate that blocks legit authoring is worse than none.

**Two-gate defense-in-depth** (same pattern as R-CAST-PORTRAIT-SLUG / R-CHAPTER-YAML-DUP-KEY):

| Gate | Where | Coverage | Bypass |
|---|---|---|---|
| Pre-push gate #4 | `scripts/git-hooks/pre-push-chapter-checks.sh` (scoped to CHANGED chapters) | NEW/modified chapters in the active workflow | `SKIP_NARRATIVE_QUALITY_CHECK=1` |
| Portfolio backstop | `check_chapter_narrative_quality.py --all` (on demand; the V29 drain worklist) | HISTORICAL spec-sheet backlog | — |

The pre-push gate is **forward-looking** (changed-files only) so it never blocks the pre-convention backlog — it stops the class from *regrowing* while the backlog is drained. The `--all` run IS the drain worklist.

**The qualitative complement (V28c):** the deterministic gate catches *form*; the *quality* judgment (does the character's defining act dramatize the primitive? does emotion travel personal→general→abstract?) is the **in-session-Claude subagent audit** documented in WORK_QUEUE § V28c — run on new chapters at authoring time. **Do NOT build an Anthropic-API judge variant** (V28c); the `.py` scripts stay Gemini-backed as offline/CI fallback, the interactive path is Claude subagents.

**When it applies:** every new/rewritten chapter (pre-push). When draining the backlog, `--app <slug>` lists an app's flagged chapters. Fix = **authoring** (convert to 5-beat narrative), not trimming.

**Cross-references:**
- `scripts/check_chapter_narrative_quality.py` — the gate
- `Docs/AUDIT_CHAPTER_METHODOLOGY_CONFORMANCE_2026-07-07.md` — the finding (spec-sheet class)
- § R-MULTIBEAT-DEFAULT (5-beat target shape) · § R-CHAPTER-REGISTER (jargon stoplist) · § R-DIR-FEDC-CHAPTER (affect-anchor companion gate)
- WORK_QUEUE § V28 / V28c / V29

### V15 reference-impl in-session polish discipline (codified V16 2026-06-24)

V15 (2026-06-24) shipped 4 trauma-axis ensemble pair chapters (wellnessforge/steady-pause, saffronlab/rise-simmer, mindforge/settle-inside, safetyforge/tell-trace) using a documented in-session polish pipeline. Each chapter took ~45-60 min Opus 4.7 in-session + ~$0.32 pilot regen. The pipeline is reference-impl for any forward trauma-axis ensemble chapter ship (and any non-trauma ensemble chapter that benefits from the same compliance review).

**8-step in-session pipeline**:

1. **In-session Opus editorial polish of Pro draft**:
   - Front-matter cleanup (`character` / `role` / `primitive` / `register` / `chapter-round` / `status`; quoted-string discipline per the prebuild YAML normalizer)
   - § R-CHAPTER-REGISTER stoplist scrub (engineering jargon / project-mgmt jargon / reviewer-framework jargon / meta-pedagogy)
   - Crisis-resource embedding under `## A note for grown-ups` H2 (988 / 741741 / Childhelp 1-800-422-4453 — for trauma-axis chapters per ADR-016 § Compliance gates)
   - Cultural-context note authoring where relevant (per ADR-020 § Cultural credit; e.g., saffronlab/rise-simmer Indigenous-knowledge-credit framing)
   - ADR compliance review per chapter (ADR-016 text axis / ADR-020 cultural-credit / ADR-021 audio axis / ADR-025 v2 attribution / ADR-029 audio player rendering on T1+T2)
2. **Place at canonical Tier-1 path**: `<app>-app/Docs/dn-s/chapters/<slug>.md`
3. **Auto-segment**: `python3 scripts/auto_segment_chapter.py --chapter <md-path> --tier 1` → 5-beat sidecar
4. **Pilot regen**: `python3 scripts/pilot_interleaved_ensemble_chapter.py --manifest <sidecar> --out-dir Resources/PilotsAndExperiments/<wave-id>/<app>` → 5 beats (Pro $0.134 + 4× Flash $0.045) + Gemini 2.5 TTS audio + ADR-025 v2 intro/outro frames
5. **Per-beat text-leak gate** via `audit_image_text_leaks.py` (R-PATH-B-TEXT-LEAK-GATE). LEAK → resolve via `gate-allow-text` allow-list in chapter front-matter per § INTENTIONAL_CURRICULUM_SIGNAGE OR regen with tightened prompt
5a. **DIR/FEDC compliance gate** (R-DIR-FEDC-CHAPTER) — `python3 scripts/audit_chapter_dir_fedc_compliance.py --ci-mode --files <chapter-md>`. MUST pass: ≥1 affect-recognition `reflection-prompt` + affect-anchored (not math-only) closer. Author the prompts + felt-sense ending in step 1; this step verifies
6. **PNG → WebP convert** (V11 ENOSPC discipline) + `cp` to `spark-anvil-site/public/chapters/<app>/`
6.5. **(NEW V16) Pair portrait gen for ensemble chapters**: `python3 scripts/gen_cast_portraits.py --app <slug> --pairs <slug>:<chapter-slug> --include-gated --yes`. **REQUIRED for ensemble pair / cohort chapters** to satisfy § R-CAST-PORTRAIT-SLUG CI check — V15 omitted this step and the 4 V15 chapters tripped the Cloudflare prebuild gate the next round (closed V16 P0). Single-character chapters skip this step (their portrait already lives in dnCast.members[])
7. **Content collection sync**: `bash scripts/sync_content_to_site.sh --apply --app <slug>` → auto-commits + pushes to spark-anvil-site `main`
8. **Per-app branch + chapter MD + handoff doc + PR + merge**: branch off main; commit chapter MD + audit doc + per-app `Docs/HANDOFF_FROM_HUB_DN_S_*.md` citing relevant ADRs + asset paths

**Per-chapter cost**: ~$0.32 pilot regen + (~$0.045 pair portrait if ensemble) + $0 Opus polish (Claude Code subscription).

**Per-chapter wall-clock**: ~45-60 min interactive (editorial polish dominates; pilot + sync + PR is ~10 min mechanical).

**When this discipline applies**:

- Forward authoring of any trauma-axis chapter (ADR-016 / ADR-020 / ADR-021 carve-out cluster)
- Forward authoring of any ensemble pair / cohort chapter (per § R-ENSEMBLE-AUTHORING)
- Phase A.2 placeholder remediation chapters per `Docs/AUDIT_DN_DN_S_CHAPTER_QUALITY_PHASE_A2_CALIBRATION_2026-06-11.md`
- Any chapter where author judgment + compliance review + crisis-resource embedding + cultural-context authoring would benefit from in-session Opus over a scripted batch run

**When this discipline does NOT apply** (scripted batch path is fine):

- Portfolio-scale opportunistic-upgrade waves under § R-MULTIBEAT-DEFAULT (Option E B1 selective wave)
- Non-trauma-axis single-character chapter regen waves
- Asset-only regens (no prose change)

**Cross-references**:
- `Docs/CONTEXT_HANDOFF_2026-06-24_V15_TRAUMA_AXIS_AUDITS_PDF_DEFER.md` § Item 1 (parent V15 ship; 4 reference-impl chapters)
- `.claude/rules/spark-anvil-website.md` § R-PATH-B-PROMPT-PARITY (step 5 + step 6 prompt-side discipline)
- `.claude/rules/spark-anvil-website.md` § R-CAST-PORTRAIT-SLUG (step 6.5 portrait CI check)
- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § V16 P0 (V15 step-6.5 omission incident)

**Cross-references** (parent R-AUTHOR-MODEL-CHOICE):
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

**Audio-player rendering-surface rule (ADR-029; 2026-06-18)**: the audio drama player MUST render on BOTH Tier-1 (`/cast/<app>/<char>`) and Tier-2 (`/cast/<app>/<char>/advanced`) chapter pages whenever an audio asset exists for the character. **Rendering surface (which tier pages show the player) is decoupled from audio-source policy (which audio file each page points at).** Two distinct audio surfaces with different per-tier policies share the same player component:

| Audio surface | Path pattern | Per-tier policy | Why |
|---|---|---|---|
| **Audio drama (Move E)** — single-chapter mode | `/audio/<app>/<dramaSlug>.m4a` | **Shared** — one drama serves both tiers | Pedagogical (2-year listening gap research per § Audio drama source rule above); cost (1× gen per character); brand canon (one drama per character) |
| **Multi-beat chapter narration (Path B)** | `/chapters/<app>/chapter_<char>_chapter.m4a` (T1) + `/chapters/<app>/chapter_<char>-advanced_chapter.m4a` (T2) | **Per-tier** — independently TTS-regenerated per R-TIER-2-MULTIBEAT-REUSE | Narration is prose-bound; shared audio would mismatch one tier's prose; WebVTT line-cues would drift |

The decoupling lets future audio surfaces (per-kit cast cameo audio; per-app theme song; trauma-axis crisis-resource read-alouds; etc.) classify into one of the two policies without re-litigating the rendering surface. Tier-1-only or Tier-2-only rendering is REJECTED: excludes either the 11-14 audio-drama beneficiary (Tier-1-only) or the 9-10 listening-gap beneficiary (Tier-2-only). Reader-toggle rendering is REJECTED: adds UI complexity for zero pedagogical benefit when the audio-source policy already automatically picks the right file per surface per tier.

See `Docs/ADR-029_AUDIO_PLAYER_TIER_RENDERING_2026-06-18.md` for the full decision + alternatives considered + reversibility.

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

**Tier-2 FK 7-8 is a TARGET BAND, not a literal gate (R-TIER-2-FK-ASPIRATIONAL; 2026-07-02).** In practice the founding cohorts ship Tier-2 below FK 7 — e.g., FractionForge's founding-5 Tier-2 land at FK 4.4-7.5 (de-facto ~5-6). Chasing FK 7-8 by inflating vocabulary risks harming the warm, trust-the-reader 9-14 voice the chapters depend on. The **operative bar** is: Tier-2 is *meaningfully denser than its Tier-1 sibling (≈ +2 reading grades)* AND *consistent with the app's founding-cohort Tier-2 register* — documented honestly per chapter, not force-fit to a metric. When a new expansion-cast chapter's Tier-2 lands below FK 7 but ≈ +2 grades over its Tier-1 and matches the founding-cohort register, that is CORRECT, not a defect. Never inflate polysyllabic vocabulary purely to hit the FK number. Codified from the FractionForge Tier-2 expansion-5 session (2026-06-30).

**Audit tool**: `scripts/audit_pdf_book_content.py` runs per-chapter Flesch-Kincaid + Flesch ease + ASL + polysyllabic + word-count checks. Run after any chapter authoring/rewrite.

**Rewrite tool** (unified dual-tier, ships in `spark-anvil-hub/scripts/`):
- `rewrite_chapter_register.py --tier 1` — Tier-1; mutates app-repo MDs in place; Gemini 2.5 Flash
- `rewrite_chapter_register.py --tier 2` — Tier-2; reads snapshot baseline; writes to `spark-anvil-hub/Resources/DN-S-Tier-Upper/chapters/<app>/`; Gemini 2.5 Flash
- Shared core at `scripts/lib/dn_s_pipeline.py` (`TIER_CONFIG` dict + path resolvers + FK helpers); same `--tier {1,2}` flag pattern carries through `build_pdf_book_per_app.py` / `render_pdf_book_typora.sh` / `render_all_pdf_books_typora.sh` / `render_pdf_book_puppeteer.mjs`. Legacy `_upper.py` / `_tier2.{py,sh,mjs}` siblings removed 2026-06-05.

## DN-S Integration (Phase 1, Round 385 #810; ADR-019)

Once an app has shipped DN-S chapters, the **next-step axis is INTEGRATION not further authoring** (per ADR-019). Authoring more chapters has diminishing returns past the existing 800-1500w-per-character density; integration earns the chapters their cost via three complementary surfaces:

| Move | Surface | Status |
|---|---|---|
| **B — Per-kit cast cameos** (v2 multi-variant per R8; 2026-06-13) | Distill chapter voice-register cards + arc-across-kits into recurring per-kit cameo lines that surface in 16-kit question content. **R8 multi-variant**: each cameo ships 2-3 variants per kit keyed off learner mastery state (struggling / steady / racing-ahead) via on-device `ForgeMasteryEngine.TopicMasteryState.masteryScore`. Per-kit cameo entries wired into `Resources/Questions/<app>/kit_NN_*.json` via `castCameos[]` schema v2 (see `Docs/SCHEMA_CAST_CAMEO_KIT_INTEGRATION.md`). Codifies DN-D1 content-axis + Naul+Liu (2020) 4th-feature adaptive-storytelling axis. | ACTIVE Phase 1 (Q3 2026) |
| **C — Site `/cast` aggregate page** | Portfolio-wide cast gallery on spark-anvil-site surfacing 700+ named characters as a navigable, themed, searchable index. Filterable by cluster; per-character cards link to source app pages. | ACTIVE Phase 1 (Q3 2026) |
| **D — AI-mentor voicing via CastDialog** | Wire chapter voice-register cards into ForgeKit 0.97.0 `CastDialog` per-app `CastVoiceRegistry`. AI mentor calls `castDialog.respondAs(.character(slug), prompt:)` for in-context character voicing. 3-app pilot (GambitTales / ProofQuest / QuillSpell) gates portfolio rollout. | PILOT Phase 1 (Q3 2026) |
| **E — Audio drama** | Phase 2 (Q1 2027); telemetry-gated on D pilot results | DEFERRED |
| **F — Illustrated comic** | Conditional; only if Phase 1 telemetry favors audio over voicing | CONDITIONAL |
| **G — Cross-app sagas** | Phase 2.5; conditional on cross-app discovery friction surfacing in Phase 1 telemetry | DEFERRED |
| **A — Ensemble stories (standalone)** | REJECTED per ADR-019. Existing chapters already encode ensemble dynamics densely (every chapter cross-references 1-4 cast members + ships explicit alliance/tension table). Authoring a separate ensemble-stories layer would duplicate ~70% of content at ~1100h cost. Pedagogical literature consistently favors RECURRENCE over standalone ensemble products. | REJECTED |

**DN-S Integration applies to each app that has shipped its DN-S chapters.** When an app reaches "100% SHIPPED" on DN-S authoring, the next per-app handoff to file is the Phase 1 integration handoff (Option B per-kit cameos as the lowest-cost starting move; Option D voicing per the **Phase 1D APPROVED portfolio rollout** per `Docs/DECISION_DN_S_AI_MENTOR_PORTFOLIO_ROLLOUT.md` (R394 #818)). All DN-S-shipped apps (post-pilot) receive customized Option D voicing handoffs via batched 7-wave rollout per `Docs/PLAN_DN_S_PORTFOLIO_ROLLOUT_WAVES_2026-06-01.md` — automated filing via `scripts/file_dn_s_voicing_handoff.py`.

**For apps still in DN-S authoring**: Integration is NOT prerequisite-blocked by completing all chapters — apps can wire Option B cameos incrementally per character as chapters land.

### Move D voicing — asks-questions discipline (R-CASTDIALOG-ASKS-QUESTIONS; 2026-06-13)

**Per-app Move D `CastDialog` voicing MUST default to ASKING questions that surface the kid's thinking BEFORE stating answers, demonstrations, or explanations.** The cast that only answers without asking regresses to the generic-mentor failure mode — fails the swap test (per § R-DN-PARITY) at the dialog-turn granularity. Codified after `Docs/RESEARCH_DEVELOPMENTAL_SCAFFOLDING_APP_EQUIVALENTS_2026-06-13.md` Phase 1 surfaced the Collins-Brown-Newman articulation method as the load-bearing scaffold for primitive embodiment to land at the dialog surface.

**The 3:1 ratio**: across a session's dialog turns, the cast should ASK at least 3× as often as it STATES. Companion to `PolyaScaffold.hintsAllowedBeforePlan: 0` (per `.claude/rules/forgekit.md` § R-FORGEPEDAGOGY-SCAFFOLDING R3) — the scaffold gates progression to require articulation; the cast's voicing reinforces it at the dialog level.

**Implementation**: full forbidden-vs-required pattern table + prompt-template hook + `voiceRegister` adaptation pattern + telemetry signals live in `Docs/TEMPLATE_HANDOFF_FROM_LABSMITH_DN_S_AI_MENTOR_VOICING.md` v2 § Step 3a. Per-app handoff filing flows through the same per-app handoff per `Docs/PLAN_DN_S_PORTFOLIO_ROLLOUT_WAVES_2026-06-01.md` 7-wave rollout — v2 template is the canonical source; v1 handoffs already filed receive a v2 addendum at next-touch.

**Override exception**: kid has already articulated AND asked a direct content question — the cast may state because the kid earned the state via articulation. Default is asking; override is the rare earn-it case.

**What this rule does NOT enforce**: the asks-questions discipline applies to the DIALOG SURFACE (Move D / `CastDialog`). It does NOT apply to:

- Static chapter MD prose (chapters are narrative; characters narrate at length without dialog-turn cadence)
- Per-kit `castCameos[]` lines (Move B; lines are short flavor, not bidirectional dialog)
- Audio drama scripts (Phase 2; scripted, not dialog-turn-bound)
- Cast portraits + illustrations (visual surface; no dialog)

**Cross-references**:
- `Docs/TEMPLATE_HANDOFF_FROM_LABSMITH_DN_S_AI_MENTOR_VOICING.md` v2 § Step 3a — canonical implementation guidance
- `.claude/rules/forgekit.md` § R-FORGEPEDAGOGY-SCAFFOLDING R3 — articulate-before-hint trio (parent pedagogical principle)
- § R-DN-PARITY — swap test (the failure mode this rule prevents)
- `Docs/RESEARCH_DEVELOPMENTAL_SCAFFOLDING_APP_EQUIVALENTS_2026-06-13.md` — source research

**Reference impl chapter-length variance** (R385 #804 per user-direct 2026-06-01; **R389 #814 freeze SUPERSEDED 2026-06-12 per user-direct**): GambitTales reference chapters range 1467-2580 words; 9 of 10 exceed the original 800-1500w spec cap. The original R389 #814 freeze (*"do NOT retroactively edit GambitTales chapters"*) is SUPERSEDED — GambitTales chapters are now in scope for B1 retroactive multi-beat conversion + asset/audio/portrait regen. The spec is updated to treat 800-1500w as a TARGET range; ensemble-piece chapters (e.g., the-pawn-cohort @ 2580w) are explicitly allowed up to ~2600w when the chapter is itself an ensemble piece. Single-character chapters should still aim for the 800-1500w target; chapters that bundle multiple characters (twin-pairs, cohorts, ensemble framings) may extend up to ~2600w with rationale in the chapter front-matter.

### The AI mentor is a TEACHABLE NOVICE + integrity-first + on-device for kids — never an answer-bot or open-ended companion (R-AI-MENTOR-INTEGRITY; 2026-07-20)

**Every AI-mentor / `CastDialog` surface — iOS (`ForgeAI.CastDialog`) AND `/play` web clone — MUST be a TASK-BOUND, INTEGRITY-FIRST tutor whose default frame is "the learner TEACHES a novice cast character," NOT an oracle that hands over answers and NOT an open-ended empathetic companion. A surface that hands over the final answer to the active task, that offers a hint before the learner has articulated, that is designed for emotional/parasocial dependency, or that escalates a child's inference off-device is a defect on the same footing as a failed swap test.** This is the UMBRELLA over § R-CASTDIALOG-ASKS-QUESTIONS (the 3:1 ask:state ratio is one of its invariants). Codified per founder-direct 2026-07-20 on the evidence in `Docs/RESEARCH_TEACHABLE_CAST_ON_DEVICE_AI_MENTOR_2026-07-20.md` + `Docs/RECOMMENDATION_PORTFOLIO_INNOVATION_NEXT_BETS_2026-07-20.md` (bets R1/R2).

**Why (the 2026 convergence — the design IS the evidence):**
- **Protégé effect / teachable agent** (Betty's Brain 2009 → *2026 CHI "Who You Explain To Matters"*): the learner who TEACHES a novice AI shows the deepest cognitive investment — strongest for lower achievers. The novice is the swap-test embodiment of the primitive *still learning its own defining act*, so teaching it IS practicing (R-DN-PARITY at the dialog turn).
- **Metacognitive-laziness antidote** (Fan et al. 2025, *BJET*, RCT: AI help → biggest score gain but ZERO transfer + reduced metacognition). A teachable agent cannot offload the learner's thinking — the learner must PRODUCE the explanation. This is why the mentor asks, never answers.
- **Safe-by-design vs. the 2026 regulatory wave** (GUARD Act; CA SB 243; Common Sense × Stanford rated Character.AI "unacceptable" — open-ended kid COMPANIONS are being banned). The portfolio's on-device / no-accounts / no-open-chat / task-bound / non-parasocial posture is *the* compliant design; a companion-style mentor FORFEITS it.

**The load-bearing invariants (author + review any AI-mentor surface against these):**
1. **Task-bound + on-device for kids** — no open-ended companionship; child inference stays ON-DEVICE (Apple FoundationModels), no off-device/PCC escalation for child surfaces (`ADR-037`), no accounts/PII/logs off-device.
2. **Teach-the-novice + articulate-before-hint** — ask ≥3:1 (R-CASTDIALOG-ASKS-QUESTIONS), NEVER hint before the learner articulates (`PolyaScaffold.hintsAllowedBeforePlan: 0`), and **NEVER hand over the final answer** to the active task — surface the learner's own reasoning, ask, or model a FADED worked STEP only (R-WEB-CLONE-SCAFFOLDED-HINTS).
3. **Productive struggle before scaffold** — prefer a brief sit-with-the-disfluency, then a faded step, never the solution (anti-metacognitive-laziness).
4. **Non-parasocial** — no emotional-dependency / "always listens, never judges" design; no engagement dark-patterns; likes/streaks never gate content (R-SITE-FEEDBACK).
5. **Refer up on crisis** — surface the existing SEL crisis resources (988 / Crisis Text Line; R-WEB-CLONE-SEL-CRISIS-FOOTER-SCOPE); the mentor never counsels, diagnoses, or presents as human/a therapist.
6. **Disclosed + gated** — AI-content disclosure (ADR-025 lineage); trauma-gated cluster gates stay active; boundary-placed only (R-NARRATIVE-BETWEEN-NOT-DURING — the active solve stays schematic).
7. **Verified** — two-axis DoD + (web) light+dark screenshot-DoD + a **transcript audit** confirming the ask:state ratio + zero answer-handover.

**When it applies:** authoring/reviewing any `CastDialog` Move-D voicing handoff, any `/play` AI-mentor surface, or any new AI feature on a child surface. The candidate iOS impl is a `ForgeAI.CastDialog` *teachable-agent mode* (spec: `forgekit/Docs/HANDOFF_FROM_HUB_CASTDIALOG_TEACHABLE_AGENT_MODE.md`; hub authors the spec, the app/ForgeKit session writes Swift). **Founder-gated** for any new dedicated AI app (R-NEW-APP-CONCEPT-FIT). **Cross-refs:** § R-CASTDIALOG-ASKS-QUESTIONS (the 3:1 sub-rule) · § R-DN-PARITY · § R-NARRATIVE-BETWEEN-NOT-DURING · `forgekit.md` § R-FORGEPEDAGOGY-SCAFFOLDING (articulate-before-hint) · `spark-anvil-website.md` § R-WEB-CLONE-SCAFFOLDED-HINTS · § R-WEB-CLONE-SEL-CRISIS-FOOTER-SCOPE · § R-SITE-FEEDBACK · `Docs/ADR-037` (no-PCC-for-kids) · `Docs/RESEARCH_TEACHABLE_CAST_ON_DEVICE_AI_MENTOR_2026-07-20.md` (the grounding + design spec + pilot).

## The DN cast is delivered multilingually via a translanguaging-informed, on-device L1-SCAFFOLD layer — authored/reviewed L1 (never raw MT), Spanish-first, an ASSET not a translation (R-MULTILINGUAL-DN; 2026-07-21, ADR-060)

**The portfolio's DN cast + 5-beat chapters + audio narration are the evidence-backed vehicle for English-learner (EL / emergent-multilingual) vocabulary — so the DN methodology carries an OPTIONAL, on-device MULTILINGUAL L1-SCAFFOLD LAYER: a learner-chosen "home language" (localStorage, no identifier — the R-SITE-FEEDBACK posture) that lights up translanguaging-informed L1 supports ADDED ALONGSIDE the English narrative (cognate bridges · dual-language target-vocabulary cards · L1 audio of the cast's key lines · an L1 gloss of the chapter's target words) — NOT a translation of the app, NOT a new app, and NEVER raw machine-translation shipped to a child. A surface that ships raw-MT L1 content to kids, that treats the home language as a deficit/"English-only" crutch, that adds accounts/PII/off-device data to deliver it, or that over-claims ("closes the EL gap"), is a defect on the same footing as an ADR-045 hard-guardrail violation.** Codified per founder-direct 2026-07-21 (clearing the founder-gate on `RESEARCH_MULTILINGUAL_ELL_DISTRIBUTED_NARRATIVE_2026-07-21.md`); decision `ADR-060`; rollout `CONCEPT_MULTILINGUAL_DN_LAYER_2026-07-21.md`. This is the DN-delivery sibling of the ADR-045 access-backbone (`cognitive-accessibility.md` § R-COGNITIVE-ACCESSIBILITY) — same on-device / no-PII / curb-cut / calm-rails posture, reusing the SAME Reading-Access read-aloud + karaoke surface; it turns the narrative moat into an **equity moat** for ~5.3M underserved US ELs (CZI/Gates/NewSchools equity lane; ties to R4's "E").

**The load-bearing invariants (the evidence DEFINES these — author + review against them):**
1. **Home language on-device, off by default, no PII** — English-only users see zero change; nothing about the learner's language leaves the device (ADR-037). **Spanish first** (the US EL plurality), then the next highest-incidence languages as content lands.
2. **L1 is an ASSET layer, not a mirror translation** — the goal is *bilingual conceptual vocabulary* (a word met in L1 **and** English); use cognates + bridging + strategic translation, NOT blanket translation ("translation is not a solution" — NYSED); multimedia (audio/visual/interactive) beats flat glossaries.
3. **🛑 Authored/reviewed L1 ONLY, never raw MT to a child** — MT of children's narrative is unreliable; all shipped L1 content is in-session-Opus-authored or human-reviewed (R-WEB-CLONE-KITS-OPUS-AUTHOR). On-device/Apple translation may *assist authoring*, never ship unreviewed.
4. **Reuse the Reading-Access backbone** (ADR-045) — the L1 layer extends the shipped on-device read-aloud + karaoke surface, never a parallel one.
5. **Pilot FIRST, one clone, reversible** — a Spanish-L1 scaffold on ONE vocabulary-rich DN clone, R4-instrumented (ADR-061 metric set), then a `ForgeLocalization` iOS handoff (hub authors the spec; the app CC session writes Swift). Portfolio-wide generalization (a shared `<HomeLanguage>` control, like Reading-Access went shared) is a **founder-gated follow-on** after the pilot.
6. **Age-band + cultural gates bind** — L1 register fits the clone's age band (R-BRIDGE-BAND-DESIGN / R-YOUNGER-CLUSTER / R-OLDER-TEEN-DN-ADAPTED); trauma-/culture-gated apps' L1 content inherits their gates + credits community/traditional knowledge (no caricature).
7. **Honest yield** — lead with *"translanguaging-informed narrative vocabulary + access support,"* NEVER a proven-outcomes / gap-closing / replaces-bilingual-instruction claim (the efficacy base is classroom-implementation, not app-efficacy).

**When it applies:** authoring/reviewing any multilingual/L1/home-language surface on a `/play` clone, chapter, or cast page; any EL-facing feature. **Cross-refs:** `Docs/ADR-060_MULTILINGUAL_DISTRIBUTED_NARRATIVE_LAYER.md` + `Docs/RESEARCH_MULTILINGUAL_ELL_DISTRIBUTED_NARRATIVE_2026-07-21.md` + `Docs/CONCEPT_MULTILINGUAL_DN_LAYER_2026-07-21.md` · § R-DN-PARITY + § cultural-sensitivity gates (the DN thesis + gates this extends) · `cognitive-accessibility.md` § R-COGNITIVE-ACCESSIBILITY (the Reading-Access backbone reused) · `spark-anvil-website.md` § R-SITE-FEEDBACK (on-device/no-PII) + § R-WEB-CLONE-KITS-OPUS-AUTHOR (authored-not-raw-MT) · `Docs/ADR-037` (no off-device inference for kids) · `Docs/PLAN_EFFICACY_LEARNING_ENGINEERING_R4_2026-07-21.md` + `Docs/ADR-061` (R4 instrumentation) · `forgekit/Docs/HANDOFF_FROM_HUB_FORGELOCALIZATION_L1_SCAFFOLD.md` (the iOS handoff).

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

**Companion check during PR review**: visually inspect the deployed page (or Cloudflare Workers preview) for any of the stoplist items listed above. If a page leaks engineering register, it's a P0 register defect — fix before merging to main.

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

## Cast-expansion integration debt (R-CAST-EXPANSION-INTEGRATION; 2026-07-02)

**When a DN cast is EXPANDED (e.g., FractionForge 5→10 to close a /method curriculum-coverage gap), shipping the new members' Tier-1 chapters is NOT the finish line — it opens a multi-axis integration debt that stays invisible until a later audit or inbound handoff surfaces it.** This is the "**authored ≠ integrated**" pattern — one level up from "registered ≠ wired" (`.claude/rules/portfolio.md` § Asset Consumer Audit). The SAME round that authors an expansion chapter (or a tracked follow-up handoff) MUST close every downstream axis, or the cast member is authored-but-dark.

### Why the rule exists

The FractionForge expansion-5 (`liner`/`gather`/`times`/`tenth`/`rank`) shipped Tier-1 chapters in V22 (2026-06-24) but as of 2026-06-30 still lacked: Tier-2 advanced editions + Tier-2 audio + site `/advanced` pages (closed 2026-06-30, hub PR #1089 + site PRs #339/#341); **app-bundle** cast portraits + `CastMember.all` roster entries, so Move B per-kit cameos could not render (inbound `HANDOFF_FROM_APP_EXPANSION_CAST_PORTRAITS.md`, closed 2026-07-02 hub delivery); and both the Move B + Move D per-app handoffs carried a stale hardcoded "Cast total: 5". Each gap surfaced separately, weeks apart. See `Docs/AUDIT_FRACTIONFORGE_CAST_UTILIZATION_2026-06-29.md`.

### The Cast-Expansion Integration Checklist (per NEW member)

When a DN cast grows, close ALL of these per new member — in the same round or a tracked follow-up handoff:

1. **Tier-1 chapter** — 5-beat multibeat (R-MULTIBEAT-DEFAULT); passes DIR/FEDC (R-DIR-FEDC-CHAPTER) + register stoplist (R-CHAPTER-REGISTER) + text-leak (R-PATH-B-TEXT-LEAK-GATE) + anatomy (R-ANATOMY-GATE) gates.
2. **Tier-2 advanced edition** — `Resources/DN-S-Tier-Upper/chapters/<app>/<slug>.md` + Tier-2 audio + site `/advanced` page. Per R-TIER-2-MULTIBEAT-REUSE (beat art byte-reused; prose+audio differ) + R-TIER-2-CONTENT-ENTRY (the `src/content/chapters/<app>/<slug>-advanced.md` entry is what makes the route build). Use `scripts/t2_coverage_wave_runner.sh <app>:<slug,...>` end-to-end.
3. **Site cast portrait** — `spark-anvil-site/public/cast/<app>/<slug>.webp` (R-CAST-PORTRAIT-SLUG; slug matches the chapter MD filename).
4. **App-bundle cast portrait + roster entry** — `<app>-app/Libraries/.../Resources/Cast/<slug>.webp` (byte-reuse the site portrait — it's the same `gen_cast_portraits.py` output; don't re-gen) + a `CastMember.all` roster entry delivered via `HANDOFF_FROM_HUB_*.md` (hub ships asset + roster data; the app session writes the Swift). Move B cameos gate on a *renderable speaker* = roster entry + app-bundle portrait; without both, the cameo can't render.
5. **Move B per-kit cameos** authored/refreshed into the member's home kits (cast count derived from `dnCast.members[]` — see companion fix below).
6. **Move D voicing handoff** refreshed (cast count derived from `dnCast.members[]`).

### Companion fix — derive cast totals from `dnCast.members[]`, never hardcode

The Move B (`TEMPLATE_HANDOFF_FROM_LABSMITH_DN_S_PER_KIT_CAMEOS.md`) + Move D (`TEMPLATE_HANDOFF_FROM_LABSMITH_DN_S_AI_MENTOR_VOICING.md`) templates + every generated per-app handoff MUST express cast totals as **"N = count of `dnCast.members[]` (in `spark-anvil-site/src/data/apps.generated.ts`) / `CastMember.all`"**, not a literal "Cast total: N". A hardcoded count silently goes stale the moment the cast expands, and the stale number is what made the FractionForge integration debt invisible in the Move B/D handoffs. When authoring or refreshing a per-app cameo/voicing handoff, re-derive the count at author time.

### When this rule applies

- Any DN cast expansion (adding ≥1 member to an app that already shipped a founding cast).
- New-app authoring where the cast is authored incrementally — each member is only "done" when all 6 axes close.
- Auditing a cast for utilization gaps — enumerate the 6 axes per member; any open axis is integration debt.

### Cross-references

- `Docs/AUDIT_FRACTIONFORGE_CAST_UTILIZATION_2026-06-29.md` — the audit that surfaced the class (10-authored / 5-integrated gap)
- `Docs/CONTEXT_HANDOFF_2026-07-02_FRACTIONFORGE_TIER2_SHIPPED.md` — the session that closed the FractionForge axes + queued this codification
- `.claude/rules/portfolio.md` § Asset Consumer Audit — the "registered ≠ wired" precedent one level down
- `.claude/rules/spark-anvil-website.md` § R-CAST-PORTRAIT-SLUG + § R-TIER-2-CONTENT-ENTRY + § R-SIDECAR-TIER-REQUIRED — the per-axis site rules this checklist references
- § R-TIER-2-MULTIBEAT-REUSE + § Dual-tier chapter editions — the Tier-2 axis
- § DN-S Integration (Move B / Move D) — the cameo + voicing axes

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
