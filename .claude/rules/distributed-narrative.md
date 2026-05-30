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

## DN-S — Story-per-character requirement (R170 #604; portfolio-wide)

**Per user-direct override 2026-05-29**, DN cast members now require an explicit STORY in addition to behavioral primitive embodiment. This is the **Storytime-Chess-depth** spec adopted portfolio-wide.

Each character requires:

1. **Backstory** — 1-2 paragraphs (origin: why they embody their primitive, what tradition/world they're from)
2. **Voice register** — 1-paragraph guidance + 3-5 sample lines (how they speak; tics, vocabulary, common phrases)
3. **Arc across kits** — 16-bullet evolution (one per kit; does the character develop / learn / change?)
4. **Relationships** — at minimum 1 alliance + 1 tension with other cast members

Optional but recommended: cultural-context note, voice-acting note, visual evolution.

**Reference impl**: GambitTales (`Docs/PLAN_GAMBITTALES_DN_ENHANCEMENT.md` — 10 chars at this depth).

**Rollout via 7 waves** prioritized by cluster cohesion + existing partial-story content + high-value differentiation surfaces. See `Docs/PLAN_DN_S_STORY_PER_CHARACTER_WAVES.md`. Apply R166 #598 **0.30 multiplier** to budget projections for verify-before-action savings.

**Sequencing constraints**:
- R0 reviewer signoff required for trauma-gated apps (story axis NOT covered by ADR-012 art-axis carve-out)
- Character name registry MUST be checked before DN-S authoring (no name collisions)
- Anti-credentialism gate per CQ `CONTENT_STYLE_GUIDE.md` § 4.5 applies to anxiety-safe register cast (Linger / Notice / etc.)

**For existing Wave-0/1/2 retrofit apps**: DN-S retrofit is per-app handoff in `docs/HANDOFF_FROM_LABSMITH_DN_S_STORY_PER_CHARACTER.md`. Verify-before-action FIRST — many apps already have partial story content that just needs codification.

**For new apps SPAWNing post-R170**: DN-S is required from day one. Author backstory + voice + arc + relationships alongside the initial cast definition.

## Cross-references

- `Docs/GUIDE_DISTRIBUTED_NARRATIVE_METHODOLOGY.md` — full methodology spec (Bruner + Habgood references) + § DN-S
- `Docs/PLAN_DN_S_STORY_PER_CHARACTER_WAVES.md` — DN-S 7-wave rollout plan (R170 #604)
- `Docs/RESEARCH_STORYTIME_CHESS_CHARACTER_STORIES_VS_DN_2026-05-29.md` — DN-S research foundation (R169 #603)
- `Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` — canonical character/mentor registry
- `.claude/rules/trauma-informed-content.md` — trauma-informed-design rules that DN handoffs adhere to
- `.claude/rules/portfolio.md` — cross-repo handoff protocol that DN retrofits use
- `Docs/PLAN_GAMBITTALES_DN_ENHANCEMENT.md` — DN-S reference template
<!-- END LABSMITH-SYNCED CONTENT -->
