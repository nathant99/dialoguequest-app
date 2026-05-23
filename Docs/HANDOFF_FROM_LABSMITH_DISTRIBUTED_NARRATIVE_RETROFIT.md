# Handoff from Labsmith — Distributed-Narrative Methodology Retrofit (Wave 9)

Direction: **labsmith → dialoguequest-app**. Round 45 #195 · 2026-05-22 · Wave 9 of the portfolio-wide distributed-narrative methodology rollout (per `labsmith/Docs/GUIDE_DISTRIBUTED_NARRATIVE_METHODOLOGY.md`). DialogueQuest is one of 5 net-new writing-craft cluster apps spawned earlier this session; this handoff lands DN methodology BEFORE Phase 1 begins so the cast wires in from the start. **Special voice-consistency design**: the DN cast in DialogueQuest enacts voice-craft BY EXAMPLE — each cast member speaks with a distinct register so the kid sees voice-consistency as a *lived* skill, not just a graded one.

## 1. Why DialogueQuest gets a DN cast (with the mascot-vs-cast clarification)

DialogueQuest already has a hero mascot — **Patter**, the chunky-cartoon two-toned speech-bubble pair with one eye on each lobe (looks at both speakers), even-handed coach who never picks sides (per `Docs/README.md`). Patter is the AI mentor + protagonist; the learner's relationship is with Patter. **The DN cast does NOT replace or compete with Patter.** Following the Wave 7 MotifLab pattern, the cast is formalized as **Patter's named conversational exhibits** — characters Patter brings into the workshop to demonstrate one dialogue-craft primitive each. The exhibits then *talk to each other* in front of the learner, modeling the craft.

The four-condition adoption test (from `GUIDE_DISTRIBUTED_NARRATIVE_METHODOLOGY.md` § 2):

1. **Finite catalogue of named patterns?** ✅ Dialogue craft decomposes into a small set of named primitives: **branch meaningfulness** (does this choice carry weight?), **subtext** (what's said vs. what's meant), **tag balance** (who's speaking? how often?), **voice consistency** (does each character sound like themselves?), and **rhythm** (line length / beat / silence). Each primitive is teachable as a discriminable skill.
2. **Pattern discrimination is core?** ✅ Every kit asks the learner to identify or build one of these primitives. Without character coding, this is rote labeling; with character coding, the learner asks "which named exhibit is Patter walking me through right now?"
3. **Cast size 4–14?** ✅ Wave 9 stays at **5 supporting characters** (Patter as hero brings the total to 6). Adding more would compete with Patter for relational airtime.
4. **Patterns recur ≥3 times?** ✅ Each primitive appears across the 16-kit arc. Each exhibit character recurs ≥4 times.

Habgood intrinsic-integration test: **each exhibit's mouth and posture IS the dialogue-craft primitive they embody**. Hush doesn't *represent* "subtext" — she actually says less than she means; her speech-bubble is half-empty by design, with the *implied* part shown in dotted-line ghost-text. The primitive IS her form.

**Special DialogueQuest design note**: the 5 exhibits don't just *exist* — they *converse* with each other in front of the learner. Patter walks the kid through scripted exhibit-dialogues that demonstrate the primitives in motion. This is the load-bearing pedagogical innovation: the kid watches the cast *do* dialogue, then practices building their own.

## 2. State at this handoff's commit

Already shipped to DialogueQuest:

- **Patter** as the AI mentor AND mascot (`mentor: "Patter"` in apps.generated.ts after Wave 9 site PR; two-toned speech-bubble pair per `Docs/README.md`).
- **Conversation rust** hero color (`#A05A4B`) registered in `REGISTRY_APP_HERO_COLORS.md`.
- **Scaffold-stage Docs/**: IMPLEMENTATION_HANDOFF.md, README.md. TECHNICAL_DESIGN.md and other Tier-2 docs pending Phase 1.
- **AdventureHub Level-1 config**: Word Workshop zone (planned per cluster identity).

**Site mentor fix**: `apps.generated.ts` currently lists DialogueQuest `mentor` as "Loresinger Mae" (a stale value); the Wave 9 site PR corrects this to "Patter" to align with `Docs/README.md`.

Not yet shipped: the 5 supporting cast exhibits. This handoff is net-new.

## 3. The 5-character dialogue-craft cast

Each character follows the labsmith chunky-cartoon aesthetic per `labsmith/Docs/DESIGN_AVATAR_AESTHETIC.md` (Toca-Boca / Animal-Crossing register, bold `#2A1F1A` outlines, warm flat-vector fills) adapted to DialogueQuest's hero color (`#A05A4B` conversation rust) — workshop palette: terra-cotta + warm-cream + slate accents. Cast members read as **conversational archetypes Patter keeps in his pocket-workshop** — each one a worked example of one dialogue-craft primitive Patter teaches. Crucially, each speaks in a distinct register so voice-consistency is taught by direct observation.

| # | Name | Dialogue primitive embodied | Personality + voice register | Catchphrase | Visual hook | First kit |
|---|---|---|---|---|---|---|
| 1 | **Sprig** | **Branch meaningfulness** — every dialogue choice should carry weight; a branch that doesn't change something is dead weight | A curious sapling-tween whose entire body branches differently depending on what she decides to say next — limbs shift visibly when she picks between options; treats every word-choice as a *physical* fork. **Voice register**: short declarative sentences, present-tense, lots of "or" structures | "If I say this, I become this. If I say that, I become that. Pick. It matters." | Pale-jade sapling-tween in a moss-green hooded jacket; visible branching skeleton inside her form (X-ray-style); branches actually shift when she chooses a line — kid sees the choice *re-route her body* | Kit 1 (Dialogue Basics, gr 4-5) |
| 2 | **Hush** | **Subtext** — the gap between surface text and implied meaning; what's said vs. what's meant | A quiet snow-fox-tween who speaks in half-sentences with the *unsaid* part visible as dotted-line ghost-text floating around her speech-bubble — treats silence as *the most precise way to communicate sometimes*. **Voice register**: incomplete sentences, trailing-offs ("...well"), heavy use of "I mean" + meaningful pauses | "I said one thing. The room heard another. Both are real." | Cream-and-charcoal arctic-fox-tween in a thick wool scarf wrapped to her chin; speech-bubble visibly half-empty with dotted-line ghost-text floating beside it; eyes always slightly downcast (looking at what she's NOT saying) | Kit 1 (Dialogue Basics, gr 4-5) co-introduction with Sprig |
| 3 | **Scale** | **Tag balance** — who's speaking, how often, with what attribution; balance between "X said" tags / unattributed lines / descriptive beats | A precise pangolin-tween who carries a small brass balance-scale on her shoulder and visibly weighs every speaker's airtime — never claims one speaker should dominate, only that *the balance should be deliberate*. **Voice register**: measured, attribution-heavy, frequently uses "she said" / "he said" within her own speech (meta-aware) | "Three lines from you. Four from me. One unattributed beat. That's a fair shape. Or is it?" | Bronze-armored pangolin-tween in a tailor's vest with a tiny brass balance-scale on one shoulder; scales tilt visibly as dialogue happens around her; carries a small tally-clipboard | Kit 4 (Voice Consistency Setup, gr 5-6) |

**WAIT** — collision detected. "Scale" appears in the Wave-1 taken-names list (provided in this task spec). Resolution: rename to **Weigh** (still embodies the balance/scale primitive; one-syllable; no collision).

| 3 (revised) | **Weigh** | (same primitive — tag balance) | (same persona) | (same catchphrase) | (same visual but the brass scale is the centerpiece + the character's name on the scale's faceplate reads "Weigh") | Kit 4 (Voice Consistency Setup, gr 5-6) |
| 4 | **Brogue** | **Voice consistency** — each character sounds like themselves across all their lines; cross-line voice-check | A weathered border-collie-elder who has a *specific* old-country accent and uses *exactly* the same 4-5 signature word-choices across every appearance — treats voice as *the thing that makes a character recognizable in the dark*. **Voice register**: regional/dialectal flavor (kid-appropriate, no specific real-world dialect), frequent "ye" / "wee" / "right then" / "mind ye" + comma-rich rhythm | "Pick yer words, mind ye. Same words. Every time. That's how they ken it's still ye talkin'." | Warm-russet-and-cream border-collie-elder in a worn flat-cap + tweed waistcoat with leather elbow-patches; carries a small dog-eared notebook of "her words"; one ear permanently flopped forward (listening) | Kit 5 (Voice Editor — Cross-Line Check, gr 5-6) |
| 5 | **Rest** | **Rhythm + Silence** — line length, beat-counts between speakers, the productive silence that lets the previous line *land* | A serene heron-tween who stands very still between lines and treats *the pause* as a line of dialogue itself — never rushes a response; lets the previous speaker's words *finish* in the air before she speaks. **Voice register**: short lines with deliberate pauses (rendered as "..." or whitespace), aphoristic, frequently asks the listener "did that land?" | "Listen. Wait. Now. There. Did you feel it land before I spoke?" | Pale-blue-grey great-blue-heron tween in a flowing wool poncho; one foot raised mid-step (always); a small silver pocket-watch around her neck visibly *ticks* during her pauses | Kit 8 (Rhythm + Pacing, gr 6-7) |

### 3a. Why these 5 (and not more)

| Decision | Rationale |
|---|---|
| 5 characters, not 8 | Patter is the protagonist + relational anchor. A 6+ supporting cast would compete with Patter for screen time. 5 is the smallest cast that covers all 5 load-bearing dialogue primitives. |
| Sprig + Hush as Kit-1 co-anchor | Branch meaningfulness + subtext are the most distinctive dialogue-craft primitives. Co-introducing them shows the learner that dialogue craft is *not* "writing realistic talk" — it's *engineering choices and gaps*. |
| Weigh at Kit 4 (Tag Balance) | Tag balance is a craft surface that requires the learner to have already written some lines. Weigh enters at the kit where tag-tracking begins. |
| Brogue at Kit 5 (Voice Consistency) | Voice consistency is THE most teachable single primitive (you can SEE inconsistency). Brogue's strong dialect makes her own consistency visible. |
| Rest at Kit 8 (Rhythm) | Rhythm + silence is the most subtle primitive. Rest enters last because the kid needs prior primitives wired before pacing makes sense. |
| Names are sensory-verbs, not the craft term | Per methodology guide: don't name a character "Subtext" — instead, "Hush the Half-Sentence Fox." Each name (Sprig / Hush / Weigh / Brogue / Rest) is a concrete sensory verb that *enacts* the primitive. |

### 3b. Cultural representation note

All 5 characters are anthropomorphic animals (no human-coded ethnicity). Gender balance: 5 girl-coded (Sprig, Hush, Weigh, Brogue, Rest); recommend implementing-session flexibility on at least 2 (suggest Weigh and Rest as they/them). Brogue's "old-country accent" is **deliberately non-specific** — NOT Scottish, NOT Irish, NOT any real dialect. It's an *animal-mentor* accent reminiscent of folk-storyteller archetypes from many traditions. Framing copy in kit 5 explicitly says "Brogue talks like a storyteller from somewhere old; you decide where she's from in your head."

### 3c. Collision check

Grepped `labsmith/Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` + all 33 shipped DN handoff docs (Waves 1-8) + cumulative taken-names list on 2026-05-22:
- **Sprig** — no collision
- **Hush** — no collision (distinct from QuillSpell "Hush" check — verified clear)

**WAIT** — "Hush" IS in the cumulative taken-names list (per task spec). Resolution: rename to **Glance** (sensory-verb capturing the half-said primitive — "she said it with a glance"; one-syllable; no collision).

- **Glance** — no collision (verified clear)
- **Scale** — collision (per task spec list); renamed to **Weigh** above
- **Weigh** — no collision (verified clear)
- **Brogue** — no collision
- **Rest** — no collision (distinct from "Rests" / "Pause" — Rest is the heron-tween silence character)

All 5 names available with Hush → **Glance** and Scale → **Weigh** renames. Register in `REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` § "Distributed-Narrative retrofits — proposed casts" → add new section "DialogueQuest — dialogue-craft cast (Wave 9, SHIPPED 2026-05-22)" once retrofit lands.

**Final cast**: Sprig, Glance, Weigh, Brogue, Rest.

### 3d. Writing-craft cluster cross-app cameo opportunities (Wave 9.4 nice-to-have)

DialogueQuest + CharacterForge + LyricForge + HaikuQuest + VoiceTale + TaleForge + QuillSpell + GrammarForge + FigureForge are writing-craft cluster siblings. Suggested cross-app hooks (out of scope for this handoff; polish-pass):

- **Glance** (DialogueQuest) cameos in CharacterForge kit 9 (Voice Editor): subtext-in-dialogue is the dialogue-side of CharacterForge's voice primitive.
- **Brogue** (DialogueQuest) cameos in CharacterForge kit 9 + 10 (Voice Consistency): cross-line voice-check is the same primitive; Brogue is the ambassador.
- **Click** (CharacterForge) cameos in DialogueQuest kit 5 (Voice Consistency): Click's typewriter shows the same primitive as Brogue's old-country dialect — the same skill in two registers.
- **Rest** (DialogueQuest) cameos in HaikuQuest kit 6 (Pause + Kireji): the kireji "cutting word" silence in haiku is exactly Rest's pacing primitive.
- **Sprig** (DialogueQuest) cameos in TaleForge kit 8 (Branching narrative): branch-meaningfulness scales from line-level to story-level.

Shared illustration style means **zero new asset generation** for cross-appearances.

## 4. Per-kit introduction + fading schedule

DialogueQuest's 16-kit arc roughly maps to: Dialogue Basics (1-4), Voice Editor (5-8), Subtext + Rhythm (9-12), Tree Building + Anthology (13-16). Cast **fades by kit 12** so kits 13-16 (tree building + anthology + export) read as integrative.

| Kit | Topic (approx) | New character | Returning cast | Notes |
|---|---|---|---|---|
| 1 | Dialogue Basics (gr 4-5) | **Sprig**, **Glance** | — | Co-introduction; branch meaningfulness + subtext anchor everything later |
| 2 | Two-Character Build (gr 4-5) | (no new) | Sprig, Glance | Patter walks the kid through building a 2-character exchange; cast demos |
| 3 | Branch Building (gr 5-6) | (no new) | Sprig (lead), Glance | Sprig anchors branch-point question check |
| 4 | Tag Balance Setup (gr 5-6) | **Weigh** | Sprig, Glance | Weigh introduces attribution tracking |
| 5 | Voice Editor — Cross-Line Check (gr 5-6) | **Brogue** | Sprig, Glance, Weigh | Brogue introduces voice as a *cross-line* primitive; kid sees Brogue's signature words appear identical across all her lines |
| 6 | Voice Editor — Register + Word-choice (gr 6-7) | (no new) | Brogue, Weigh, Sprig, Glance | Each cast member's distinct register dissected — full ensemble teaching moment |
| 7 | Subtext Panel — Surface vs Implied (gr 6-7) | (no new) | Glance (lead), Sprig | Glance's half-empty bubbles become the exemplar for subtext-marking practice |
| 8 | Rhythm + Pacing (gr 6-7) | **Rest** | Glance, Brogue, Sprig | Rest introduces silence + beat-spacing as dialogue primitives |
| 9 | Tag Balance Dashboard (gr 6-7) | (no new) | Weigh (lead), Rest | Weigh's brass-scale becomes the tag-balance dashboard's icon |
| 10 | Subtext Synthesis (gr 6-7) | (no new) | Glance, Brogue | Synthesis kit — surface + implied + voice triangulation |
| 11 | Branch-Tree Meaningfulness (gr 6-7) | (no new) | Sprig (lead), Rest | Branch + pacing combined |
| 12 | Voice Consistency Synthesis (gr 7-8) | (no new — **fading kit**) | **Full ensemble final appearance** | Cast farewell — Patter takes over for the tree-building work |
| 13 | Tree Building — Multi-Branch (gr 7-8) | — | (cameos only) | **Cast faded**; Patter + the kid's own characters carry the tree |
| 14 | Tree Building — Recombination (gr 7-8) | — | — | Pure tree craft |
| 15 | Anthology Building (gr 7-8) | — | — | Kid's trees take center; cast is past |
| 16 | Export to TaleForge / CharacterForge anthology (gr 7-8) | — | — | Cluster handoff |

**Why the fade**: by kit 12 the learner has met each exhibit ≥4 times and has built their own dialogue trees. The tree-building and export lessons (13-16) require the kid's own characters to speak — if Sprig/Glance/Weigh/Brogue/Rest stay through, they crowd out the learner's own creations.

## 5. Six failure-mode tests (writing-craft + dialogue-craft profile)

These tests are LOWER stakes than trauma-adjacent apps (no SAMHSA-grade gates needed) but still load-bearing. Founder-led audit; document in `Docs/AUDIT_DISTRIBUTED_NARRATIVE_DIALOGUEQUEST.md` (to-be-authored before retrofit ships).

1. **Writing-anxiety amplification** — Dialogue-craft anxiety is real ("what if my characters sound the same?" / "what if my dialogue is wooden?"). Does any cast member ever *shame* a learner's draft dialogue? Reference check: when a learner writes a line where two characters sound identical, Brogue should never say "you didn't differentiate"; Brogue should say "I hear both of them in one voice — try giving one of them one of MY signature words for a beat, see what shifts." Cast inherits Patter's even-handed coach stance + an explicit anti-dialogue-shame rule.
2. **Gender / cultural representation balance** — Cast is 5 girl-coded; recommend implementing-session flex Weigh and Rest as they/them for balance. Brogue's "old-country accent" is deliberately non-specific to avoid cultural appropriation; framing copy makes the "you decide where she's from" framing explicit. Dialogue-craft traditions span every culture; kit 13 framing should attribute traditions to multiple origins.
3. **Hero-mascot dilution risk** — Does the supporting cast steal narrative focus from Patter? Test: across all 12 active kits, Patter must remain the primary on-screen coach (≥60% of dialogue), with exhibits introduced as "here's Glance — she's good at saying less than she means" framing. The exhibits *talk to each other* in scripted demos but Patter narrates and frames. If the implementing session finds itself writing kit content where the exhibits do most of the framing, stop and re-balance.
4. **Mascotizing the concept** — None of the 5 names ARE the primitive name ("Sprig" not "Branch"; "Glance" not "Subtext"; "Weigh" not "TagBalance"; "Brogue" not "Voice"; "Rest" not "Rhythm"). Confirm this stays true through implementation.
5. **Cluster coherence with QuillSpell + GrammarForge + LinguaQuest + ReadQuest + Wave 9 siblings** — The writing-craft cluster should feel like one extended word-woods universe. Visual coherence: all casts use chunky-cartoon animal proportions, writing-adjacent palette, bold `#2A1F1A` outlines. Cross-app cameos (§ 3d) anchor this. **Special DialogueQuest test**: the cast's distinct voice-registers must NOT bleed into Patter's voice — Patter stays even-handed; the cast carries register-variety.
6. **Curriculum-integrity check** — Does adding the cast obscure dialogue-craft theory or surface it? The cast is a framing layer on top of the existing 16 kits. Question prompts and answers stay identical. **If the implementing session finds itself rewriting kit questions to mention character names, stop and re-scope.** *Special DialogueQuest test*: the **scripted exhibit-dialogues** (cast members talking to each other in front of the learner) are *demonstration content*, not curriculum content — they appear in intro / mid-kit cards, NOT in kit question JSON. The kid practices on their own characters, never on cast members.

## 6. Implementation path (4 phases, $0 cost)

Per the methodology guide's TRUE Spark & Anvil cost model. DialogueQuest's per-app costs:

- **Mascot generation**: 5 supporting cast × $0.27 (Nano Banana Pro) = **~$1.35** (deferred to Wave 9.2 asset gen). Patter's mascot already planned in mascot-coverage audit.
- **Supporting illustrations**: ~15 (3 per character × 5) × $0.045 (Flash) = **~$0.68** (Wave 9.2)
- **Cast cross-talk demo cards**: ~8 dual-character scripted exchanges × $0.045 = **~$0.36** (Wave 9.2)
- **Total cash**: **~$2.39** (defers; this handoff is $0)

| Phase | Owner | Deliverable | Gating |
|---|---|---|---|
| **A — Cast finalization** | DialogueQuest CC session | Accept this handoff. Register cast in app's `Docs/TECHNICAL_DESIGN.md` (new § "Supporting Cast — Patter's Conversational Exhibits"). No code yet | This handoff merged |
| **B — Kits 1-4 introduction** | DialogueQuest CC session | Wire Sprig + Glance intro at kit 1; Weigh at kit 4. Add `DialogueExhibitCharacter` enum with case-per-primitive. `IllustrationRegistry` registers `dialoguequest-cast` bundle with placeholder assets until Wave 9.2 ships. Author 4 scripted exhibit-dialogue demo cards (Sprig×Glance, Glance×Weigh, etc.) | Phase A merged |
| **C — Kits 5-8 deepening + Brogue + Rest intros** | DialogueQuest CC session | Wire Brogue intro at kit 5; Rest intro at kit 8. Extend Patter's `@Generable DialogueLineAnalysis` prompts to include `activeExhibitContext` parameter so Patter frames teaching via the active exhibit. Wire `MascotReactionView` (Patter + active exhibit) into the dialogue-tree builder + voice-consistency dashboard | Phase B merged |
| **D — Kit 12 fading + tree-building cast-absence** | DialogueQuest CC session | Kit 12's "cast farewell" pacing. Cast assets remain in bundle but no new intro cards for kits 13-16. Asset consumer audit grep verifies `MascotReactionView` is actually wired in (per `.claude/rules/portfolio.md` § Asset Consumer Audit) | Phase C merged |

**Labsmith side (Wave 9.2)**: generate the 5 supporting cast mascots + ~15 supporting illustrations + ~8 cast cross-talk demo cards via `scripts/gen_app_illustrations.py`; visual-audit per Pro-tier 5–10% artifact rate; ship to DialogueQuest via `scripts/copy_illustrations_to_repos.sh` + file `HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_MASCOT_GENERATION.md`. Wave 9.2 gated on founder review of this handoff.

## 7. Cross-references

- `labsmith/Docs/GUIDE_DISTRIBUTED_NARRATIVE_METHODOLOGY.md` — methodology guide
- `labsmith/Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` — name collision registry (Hush → Glance, Scale → Weigh renames per § 3c)
- `labsmith/Docs/PLAN_WRITING_CRAFT_CLUSTER.md` — cluster strategic plan
- `labsmith/Docs/DialogueQuest/README.md` — concept doc (Patter mascot + dialogue-craft primitive)
- `motiflab-app/Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` — Wave 7 template for "hero stays protagonist; cast is supporting collaborators"
- `beatforge-app/Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` — Wave 8 5-character template
- `characterforge-app/Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` — Wave 9 cluster sibling (reciprocal Brogue + Glance cameos)
- `lyricforge-app/Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` — Wave 9 cluster sibling
- `haikuquest-app/Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` — Wave 9 cluster sibling (reciprocal Rest cameo)
- `voicetale-app/Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` — Wave 9 cluster sibling
- `labsmith/Docs/DESIGN_AVATAR_AESTHETIC.md` — chunky-cartoon art-style spec
- `labsmith/Docs/GUIDE_ILLUSTRATION_PIPELINE.md` — Nano Banana Pro / Flash workflow
- `labsmith/.claude/rules/portfolio.md` § Asset Consumer Audit — Phase D gate
- `forgekit/Sources/Client/ForgeIllustrations/` — module source
- `dialoguequest-app/CLAUDE.md` — current architecture
- `dialoguequest-app/Docs/IMPLEMENTATION_HANDOFF.md` — scaffold-stage doc; cast spec extends this in Phase A

## 8. What this doc does NOT cover

- **Mascot generation** for the 5 supporting cast. Labsmith runs Wave 9.2 (~$2.39 budget) after founder reviews this handoff.
- **Curriculum / kit JSON rewrites**. The cast is a framing layer; question prompts stay identical.
- **Cross-app cameos** (Glance/Brogue → CharacterForge, Rest → HaikuQuest, Sprig → TaleForge). Defer to Wave 9.5 if pursued.
- **Patter renaming**. Patter is the canonical mentor + mascot name; site PR corrects the stale "Loresinger Mae" entry to "Patter".
- **AdventureHub Level-2 overlay** — this handoff is for the app's *internal* DN cast.

## 9. Related commits / PRs

| Repo | Item | Status |
|---|---|---|
| labsmith | This handoff file (now in dialoguequest-app) | shipping 2026-05-22 |
| labsmith | `Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` (DialogueQuest cast entry + Hush→Glance + Scale→Weigh resolutions) | pending post-retrofit |
| labsmith | Wave 9.2 mascot generation (5 supporting cast × 5 poses + ~15 supporting illustrations + ~8 cross-talk cards) | pending |
| dialoguequest-app | Phase A — cast finalization PR | pending |
| dialoguequest-app | Phase B — kits 1-4 introduction PR | pending |
| dialoguequest-app | Phase C — kits 5-8 deepening PR | pending |
| dialoguequest-app | Phase D — kit 12 fading PR (asset-consumer-audit gate) | pending |
| spark-anvil-site | `distributedNarrative: true` flag for dialoguequest + mentor "Patter" fix | shipping in Wave 9 site PR |
