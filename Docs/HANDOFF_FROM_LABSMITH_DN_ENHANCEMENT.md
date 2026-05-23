# Handoff from Labsmith — Distributed-Narrative ENHANCEMENT (Layered Methodology)

Direction: **labsmith → dialoguequest-app**. Companion to (not replacement of) the 2026-05-22 `HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` (Wave 9). Expands the named cast from 5 LESSONS-layer + Patter mentor → 10 (5 LESSONS preserved + 4 net-new cluster-shared WORLD-layer voice-register characters + 1 cluster-shared META-layer character). Patter remains the protagonist (Pattern B preserved).

**Status**: Specification handoff. Phase D asset generation INHERITED from LyricForge handoff #304 (cluster-shared WORLD-layer chars — all 4 inherited at $0 marginal cost) plus 1 net-new META-layer Audience Aria generation (~$0.27 Pro tier — first cluster-shared generation site for Audience Aria; subsequent apps consuming Audience Aria inherit at $0). Existing 5-character LESSONS-layer cast assets (Sprig / Glance / Weigh / Brogue / Rest) PRESERVED — no regeneration required.

**Round**: 59 · **Queue item**: #317 · **Date**: 2026-05-23 · **Wave**: Writing-craft cluster layered-DN Wave 1, Session 2
**Source plan**: `labsmith/Docs/PLAN_DN_ENHANCEMENT_WRITING_CRAFT_CLUSTER.md` (queue #279)
**Cluster-canonical asset-gen handoff**: `lyricforge-app/Docs/HANDOFF_FROM_LABSMITH_DN_ENHANCEMENT.md` (queue #304 — generates the 4 cluster-shared WORLD-layer characters; DialogueQuest inherits ALL 4)
**Methodology spec**: `labsmith/Docs/GUIDE_DISTRIBUTED_NARRATIVE_METHODOLOGY.md` + `labsmith/Docs/PLAN_GAMBITTALES_DN_ENHANCEMENT.md` (Storytime-Chess-inspired layered methodology)
**Previous handoff**: `Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` (Wave 9, 2026-05-22 — Patter + 5-char LESSONS-layer cast: Sprig / Glance / Weigh / Brogue / Rest)

---

## 1. Why layered-DN now (Pattern B note)

DialogueQuest's Wave-9 retrofit shipped Patter + 5 dialogue-craft LESSONS-layer exhibits (Sprig / Glance / Weigh / Brogue / Rest — embodying branch meaningfulness / subtext / tag balance / voice consistency / rhythm-and-silence). Labsmith's 2026-05-22 study of the user-provided **Storytime Chess** curriculum surfaced a more complete narrative architecture: alongside LESSONS-layer characters embodying *what is being taught*, a **WORLD-layer** can personify *the medium in which the teaching happens* — for dialogue craft, that medium is the **voice register** the characters speak IN. DialogueQuest is also one of the cluster apps where META-cognition is load-bearing — kit 11-12 surface "how does the audience hear this?" — so a **META layer** anchor is added.

**Dialogue is inherently about voice DIFFERENTIATION** — the core craft is making two characters sound discriminably different from each other. The 4 cluster-shared voice-register WORLD characters are therefore PRIMARY in DialogueQuest — they appear in scripted exhibit-dialogues where the kid hears each register juxtaposed against another ("How would Heralda say this? How would Murmur say this?"). The juxtaposition makes voice-register tangible in a way no other writing-craft app surfaces it. DialogueQuest joins CharacterForge as one of two cluster apps consuming ALL 4 cluster-shared WORLD chars.

**Critical: DialogueQuest is a Pattern B app** per `.claude/rules/distributed-narrative.md` § Hero mascot vs. cast. Patter stays the PRIMARY PROTAGONIST. The WORLD-layer characters are explicitly framed as "Patter's conversational guests — Patter walks the kid around the workshop to meet each register-archetype." Patter is the even-handed coach who never picks sides; the WORLD-layer cast members are guests whose DISTINCT registers Patter showcases without endorsing one over another. The layered ENHANCEMENT does NOT convert DialogueQuest into a Pattern A cast-leads app.

| Layer | Purpose | DialogueQuest mapping |
|---|---|---|
| **MENTOR (= hero in Pattern B)** | Patter — AI listening coach + on-screen protagonist; hero doubles as mentor | Patter (PRESERVED — two-toned chunky-cartoon speech-bubble pair with one eye on each lobe + ear-leaf; even-handed coach register) |
| **LESSONS layer** | One character per dialogue-craft primitive (branch / subtext / tag balance / voice / rhythm) | Sprig / Glance / Weigh / Brogue / Rest (PRESERVED — Wave 9 retrofit) |
| **WORLD layer** | One character per voice register the characters speak IN | NEW — ALL 4 cluster-shared voice-register archetypes (Heralda / Murmur / Quip Goodfellow / Vesperline). Dialogue requires each character to inhabit SOME register; the 4 archetypes form the demonstration set for voice-differentiation craft |
| **META layer** | The reader-from-without stance — what does the LISTENER bring, what do they feel? | NEW — Audience Aria (cluster-shared META archetype; appears kits 11-12 when audience-perception surfaces meta-cognition) |

The methodology test for adding both layers (`PLAN_DN_ENHANCEMENT_WRITING_CRAFT_CLUSTER.md` § 1.4 + § 1.7):

1. **Voice register is pedagogically load-bearing in dialogue craft?** ✅ Dialogue's whole point is to make two characters sound different. Register-archetype variety (heroic-bardic / lyric-confessional / comic-vernacular / tragic-pastoral) gives the kid 4 distinct register-targets to write toward. DialogueQuest needs full rotation.
2. **Audience / META is pedagogically load-bearing?** ✅ Kit 11-12 ("how does the audience hear this?" — subtext-synthesis + listener-perspective) demand the learner step OUT of the writer stance into the listener stance. Audience Aria IS that stance.
3. **Working-memory ceiling allows expansion?** ⚠️ DialogueQuest at 10 cast sits at the upper bound of the methodology median (`GUIDE_DISTRIBUTED_NARRATIVE_METHODOLOGY.md` § 2 condition 3, 6-14 range). Justified by cast-fading discipline (Section 4) and intentional pacing — characters introduce 1-2 per kit; no kit features all 10 simultaneously; cast fades by kit 12.
4. **Cluster-shared cross-app coherence?** ✅ All 4 voice-register archetypes appear in sibling writing-craft apps. Audience Aria appears in TaleForge / ReadQuest / DebateForge / DialogueQuest — cluster glue across reader-response-coded apps.
5. **Pattern B preserved?** ✅ Voice-register + Audience Aria are "Patter's conversational guests" Patter WALKS THE LEARNER AROUND; Patter remains the primary on-screen coach in every kit (16/16). Density rule per § 4.

Net cast: **6 → 10 visible characters** (Patter + 5 LESSONS + 4 WORLD + 1 META). Cast-fading + density caps preserve Patter's protagonist status.

---

## 2. State at this handoff's commit

Already shipped to DialogueQuest:

- **Patter** as the AI listening coach AND on-screen protagonist (per `Docs/CONTENT_STYLE_GUIDE.md` — even-handed coach + warm + "tell me more" register; two-toned speech-bubble pair coding)
- **5 LESSONS-layer cast** (Sprig / Glance / Weigh / Brogue / Rest) per `Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md`
- **16 question kits** authored — Dialogue Basics → Voice Editor → Subtext + Rhythm → Tree Building → Anthology
- **AdventureHub Level-1 config**: Word Workshop zone (planned per cluster identity)

Not yet shipped: any of the 4 net-new WORLD-layer cluster-shared characters or the META-layer Audience Aria. This handoff is a layered ADDITION on top of the existing Wave-9 cast.

---

## 3. The 5 net-new characters (WORLD + META layers)

Each follows the labsmith chunky-cartoon aesthetic per `labsmith/Docs/DESIGN_AVATAR_AESTHETIC.md` (Toca-Boca / Animal-Crossing register; bold `#2A1F1A` outlines; warm flat-vector fills). DialogueQuest's hero color (`#A05A4B` conversation rust) provides the workshop-palette overlay; the WORLD + META characters themselves are PALETTE-NEUTRAL chunky-cartoon human-coded figures (NOT animal-coded — distinct from LESSONS-layer's sapling/snow-fox/pangolin/border-collie/heron cast). This is intentional — WORLD/META chars read as "older mentor-friends Patter walks the learner around to meet"; LESSONS-layer reads as "conversational archetypes Patter keeps in his pocket-workshop."

### 3.1 WORLD layer (4 net-new — cluster-shared inherited assets)

| Slug | Name | Voice register | Personality + voice | Static catchphrase (≤8 words) | First kit |
|---|---|---|---|---|---|
| `voice_epic` | **Heralda the Loud** | Epic / High Heroic | Bard-warrior who tells of mighty deeds across long ages. Speaks in third-person omniscient. Carries a traveling drum. In dialogue work, anchors characters whose lines carry mythic register ("AND SO they faced the dragon") — heroes, leaders, oracles. | _"And SO the great tale begins."_ | Kit 5 |
| `voice_lyric` | **Murmur** | Lyric / Confessional | Quiet observer who writes the inner feeling. Speaks in first-person present. Carries a small journal. In dialogue work, anchors characters whose lines carry confessional register ("today I noticed...") — diary-keepers, reflective protagonists, soft-spoken witnesses. | _"This is what it feels like, inside."_ | Kit 5 |
| `voice_comic` | **Quip Goodfellow** | Comic / Vernacular | Wit-quick neighborhood storyteller who makes everyone laugh by noticing the absurd. Dialogue-driven. Carries a pocket of one-liners. **NATIVE TO DIALOGUE** — comic-vernacular IS the dialogue register par excellence; Quip anchors the dialogue-as-banter register. | _"Wait — did you SEE that?"_ | Kit 7 |
| `voice_tragic` | **Vesperline** | Tragic / Pastoral | Twilight-walker who tends grief and longing without sentimentality. Speaks in the imperfect past. Carries a small lit lantern. In dialogue work, anchors characters whose lines carry elegiac register ("we walked there once...") — grief-tenders, characters carrying loss. | _"It was. And then it wasn't."_ | Kit 10 |

**All 4 voice-register WORLD characters appear in DialogueQuest** — full register rotation. Justified: dialogue's core craft is voice-differentiation; the 4 register-archetypes are the demonstration set Patter walks the learner around. Without all 4 available, the voice-consistency curriculum loses its full register-contrast set.

### 3.2 META layer (1 net-new — cluster-shared, FIRST GENERATION SITE)

| Slug | Name | META stance | Personality + voice | Static catchphrase (≤8 words) | First kit |
|---|---|---|---|---|---|
| `meta_audience` | **Audience Aria** | The reader-from-without: what does the listener bring? what do they feel? Embodies reader-response criticism — the audience hears the dialogue, not the writer. | Calmly-attentive listener-figure (ages 12-14, kid-reader anchor) with an open book on her lap (reading mid-page). One hand at chin in "I'm thinking about this" pose. Treats listening as the OTHER HALF of dialogue craft. Anchors the kit-11-onward audience-perspective curriculum. | _"I'm the reader. Here's what I felt."_ | Kit 11 |

**Editor Penn (the other cluster-shared META archetype) is NOT included in DialogueQuest's cast.** Cluster plan § 3 puts Editor Penn in CharacterForge / TaleForge / GrammarForge / ReadQuest / DebateForge — the apps where editorial-revision is the load-bearing META. DialogueQuest's META is audience-perception (Audience Aria) — dialogue lives in the gap between teller and listener; the META stance is "what does the listener hear?", not "what does the editor see?". Audience Aria anchors that alone.

**DialogueQuest is the canonical first-generation site for Audience Aria** (analogous to LyricForge being the canonical site for the 4 WORLD chars in S1). Aria is generated here at $0.27, bundled at `Branding/Cluster/WritingCraft/meta_audience.{png,webp}`; subsequent cluster apps consuming Audience Aria (TaleForge / ReadQuest / DebateForge) inherit at $0 marginal cost.

### 3.3 Visual prompts (WORLD inherited + Audience Aria new)

WORLD-layer visual prompts are documented in `lyricforge-app/Docs/HANDOFF_FROM_LABSMITH_DN_ENHANCEMENT.md` § 3.2 + `PLAN_DN_ENHANCEMENT_WRITING_CRAFT_CLUSTER.md` § 1.6. DialogueQuest inherits the cluster-shared WebPs at `labsmith/Branding/Cluster/WritingCraft/voice_{epic,lyric,comic,tragic}.webp`.

**Audience Aria visual prompt** (new generation under this handoff, per cluster plan § 1.7):
- chunky-cartoon listener-figure, ages 12-14 (kid-reader anchor). Bright-sage hoodie. Open book on lap (reading mid-page). One hand at chin in "I'm thinking about this" pose. Background: subtle reading-chair silhouette. Chunky-cartoon style; bold `#2A1F1A` outlines. NO authority-coding (Aria is a peer-listener, NOT a critic); NO judgment-coding (Aria's stance is receptive, never harsh); reading-glasses are NOT a visual feature (those belong to Editor Penn — Aria is younger + reads without glasses).

### 3.4 Cluster-shared asset strategy

**DialogueQuest INHERITS all 4 cluster-shared WORLD-layer assets from LyricForge handoff #304** (the canonical first-generation site). The 4 voice-register WebPs are generated ONCE in LyricForge's Phase D wave (~$1.08 cluster-total). DialogueQuest consumes ALL 4 at **$0 marginal asset cost** for the WORLD layer.

**Audience Aria is GENERATED UNDER THIS HANDOFF** (~$0.27 Pro tier) as the cluster-shared META anchor. The asset is bundled at `labsmith/Branding/Cluster/WritingCraft/meta_audience.{png,webp}`; subsequent apps consuming Audience Aria inherit at $0 marginal cost.

- Asset paths: `labsmith/Branding/Cluster/WritingCraft/voice_{epic,lyric,comic,tragic}.webp` + `meta_audience.webp`
- Per-app distribution: `scripts/copy_cluster_assets_to_repos.sh --cluster writing-craft --app dialoguequest` copies all 5 WebP files into `dialoguequest-app/Docs/HandoffAssets/distributed_narrative_v2/cluster_shared/`
- DialogueQuest's `IllustrationRegistry.register(...)` resolves all 5 slugs via `ForgeIllustrations` multi-bundle resolution
- **DialogueQuest's marginal asset cost: $0 for WORLD (inherited) + $0.27 for Audience Aria META = $0.27 total**

### 3.5 Cast access pattern — suggested Swift API (advisory only)

The implementing session has final say on naming + access patterns. Labsmith does not write Swift. The shape below is a suggestion based on the methodology spec.

```swift
public enum DialogueQuestCharacter: String, CaseIterable, Sendable {
    // Hero / mentor (PRESERVED)
    case patter                 // hero mascot + AI listening coach

    // LESSONS layer (PRESERVED — Wave 9)
    case sprig                  // branch meaningfulness
    case glance                 // subtext
    case weigh                  // tag balance
    case brogue                 // voice consistency
    case rest                   // rhythm + silence

    // WORLD layer (NEW — cluster-shared assets)
    case voiceEpic              // Heralda the Loud — epic/heroic register
    case voiceLyric             // Murmur — lyric/confessional register
    case voiceComic             // Quip Goodfellow — comic/vernacular register
    case voiceTragic            // Vesperline — tragic/pastoral register

    // META layer (NEW — cluster-shared asset, first-gen site)
    case metaAudience           // Audience Aria — audience-perspective meta-stance

    public var layer: Layer { /* .hero | .lessons | .world | .meta */ }
    public var catchphrase: String? { /* static for cast; nil for Patter (FoundationModels) */ }
    public var assetSlug: String { /* resolves to cluster-shared bundle for .world + .meta cases */ }
}

public enum Layer: String, Sendable {
    case hero, lessons, world, meta
}
```

10 cast entries total (1 hero + 5 LESSONS + 4 WORLD + 1 META).

### 3.6 Collision check

Grepped `labsmith/Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` + Wave 1-58 shipped DN handoffs on 2026-05-23:

- **Heralda** — no collision (cluster-shared reservation, registered via LyricForge handoff #304)
- **Murmur** — no collision (cluster-shared reservation, registered via LyricForge handoff #304)
- **Quip Goodfellow** — SOFT COLLISION with JestForge mentor "Quip" (per registry rule 4 — different visual register: JestForge Quip is a comedy-mentor solo voice; this Quip Goodfellow is a writing-craft WORLD-layer cast member, cluster-shared). Full name "Quip Goodfellow" disambiguates. Flagged for cross-app audio-context audit at art-gen time. (Same soft-collision treatment as LyricForge handoff #304 § 3.5.)
- **Vesperline** — no collision (cluster-shared reservation, registered via LyricForge handoff #304)
- **Audience Aria** — no collision (verified clear; NEW cluster-shared registration under this handoff — DialogueQuest is the canonical first-gen site)

All names available. Cluster-shared registration of WORLD layer handled in LyricForge handoff #304; DialogueQuest's REGISTRY entry references the cluster-shared reservations as a CONSUMER. Audience Aria is NEW cluster-shared registration under this handoff — register in `REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` § "Distributed-Narrative ENHANCEMENT — cluster-shared META layer".

---

## 4. Kit-recurrence schedule (16-kit pacing, Pattern B density caps)

Per `GUIDE_DISTRIBUTED_NARRATIVE_METHODOLOGY.md` + Pattern B pacing rule (`PLAN_DN_ENHANCEMENT_WRITING_CRAFT_CLUSTER.md` § 4.1):

- **Every kit features Patter** (16/16) — Patter is the through-line
- **WORLD-layer characters appear at most 1 per kit** in kits 1-9; full rotation possible in kit 6 voice-editor synthesis kit
- **LESSONS-layer characters appear at most 2 per kit** — preserved from Wave 9 retrofit
- **META-layer character appears kits 11-12 only** — audience-cognition is by definition late-curriculum
- **Density rule**: max 3 cast members visible per kit in kits 1-9; max 4 in voice-editor synthesis kit 6; cast fades by kit 12

### 4.1 Introduction schedule

| Kit | Topic (approx) | New character(s) introduced | Returning cast | Notes |
|---|---|---|---|---|
| 01 | Dialogue Basics (gr 4-5) | Patter re-intro · Sprig · Glance (PRESERVED Wave 9) | — | Branch + subtext co-anchor preserved |
| 02 | Two-Character Build (gr 4-5) | — | Patter, Sprig, Glance | LESSONS-focal |
| 03 | Branch Building (gr 5-6) | — | Patter, Sprig (lead), Glance | LESSONS-focal |
| 04 | Tag Balance Setup (gr 5-6) | Weigh (Wave 9 intro) | Patter, Sprig, Glance | LESSONS-focal — preserved |
| 05 | Voice Editor — Cross-Line Check (gr 5-6) | Brogue (Wave 9 intro) · **Heralda the Loud** (Epic register) · **Murmur** (Lyric register) | Patter, Sprig, Glance, Weigh | **Major register-juxtaposition kit** — Brogue's signature-word consistency contrasted against Heralda's heroic-register lines + Murmur's lyric-register lines. The kid hears voice-consistency PLUS register-discrimination in the same kit. Density at 4 cast (max for cluster) — load-bearing demonstration |
| 06 | Voice Editor — Register + Word-choice (gr 6-7) | — | Patter, Brogue, Heralda, Murmur | Full WORLD-layer-so-far demonstration; Brogue + 2 WORLD chars |
| 07 | Subtext Panel — Surface vs Implied (gr 6-7) | **Quip Goodfellow** (Comic register) | Patter, Glance (lead), Brogue | Quip enters where subtext gets MOST comic-leverage — comic-vernacular dialogue thrives on subtext-irony; Quip demonstrates "say one thing, mean another" as comedy |
| 08 | Rhythm + Pacing (gr 6-7) | Rest (Wave 9 intro) | Patter, Glance, Brogue, Quip | LESSONS-focal — Rest as the pacing primitive; Quip's comic-rhythm carries over briefly |
| 09 | Tag Balance Dashboard (gr 6-7) | — | Patter, Weigh (lead), Rest, Quip | LESSONS-focal |
| 10 | Subtext Synthesis (gr 6-7) | **Vesperline** (Tragic / Pastoral register) | Patter, Glance, Brogue, Murmur | Vesperline's register completes the taxonomy — tragic-pastoral subtext (the unsaid mourning, the imperfect-past reference). The kid hears subtext across 4 distinct registers — this is the synthesis kit |
| 11 | Branch-Tree Meaningfulness (gr 6-7) | **Audience Aria** (META) | Patter, Sprig (lead), Rest, Heralda, Vesperline | Audience Aria enters as the META stance — kit 11 is where the learner steps OUT of writing dialogue into asking "how does the listener hear it?". Aria anchors that shift. Density at 5 cast — the cluster's only kit with 4 WORLD-chars-so-far + 1 META; founder-review density-tightness flag |
| 12 | Voice Consistency Synthesis (gr 7-8) | — (**Wave 9 fading kit**) | **Full ensemble final appearance** | Cast farewell — Patter takes over for kits 13-16 |
| 13 | Tree Building — Multi-Branch (gr 7-8) | — | Patter + (cameos only) | Cast faded; capstone work |
| 14 | Tree Building — Recombination (gr 7-8) | — | Patter | Pure dialogue-tree craft |
| 15 | Anthology Building (gr 7-8) | — | Patter + cross-app cameos | See § 5 |
| 16 | Export to CharacterForge / TaleForge anthology (gr 7-8) | — | Patter + capstone cameos | Cluster handoff |

### 4.2 Appearance count across all 16 kits

| Character | Kits featured | Frequency tier |
|---|---|---|
| Patter | 16 / 16 | Always-present (Pattern B requirement) |
| Sprig | 9 / 16 | High (PRESERVED Wave 9) |
| Glance | 9 / 16 | High (PRESERVED Wave 9) |
| Weigh | 6 / 16 | Moderate (PRESERVED Wave 9) |
| Brogue | 6 / 16 | Moderate (PRESERVED Wave 9) |
| Rest | 4 / 16 | Moderate (PRESERVED Wave 9) |
| Heralda the Loud | 4 / 16 | Moderate (NEW WORLD; epic-register-coded characters) |
| Murmur | 4 / 16 | Moderate (NEW WORLD; lyric-register-coded characters) |
| Quip Goodfellow | 5 / 16 | Moderate (NEW WORLD; comic-register-coded characters — DialogueQuest is comic-native) |
| Vesperline | 3 / 16 | Moderate-low (NEW WORLD; tragic-register-coded characters) |
| Audience Aria | 2 / 16 | Low (NEW META; kits 11-12 only) |

All cast members meet the methodology minimum of 3 kits (`GUIDE_DISTRIBUTED_NARRATIVE_METHODOLOGY.md` § 2 condition 4), EXCEPT Audience Aria at 2 kits — which is allowed per cluster plan § 4.3 ("META-layer characters can drop to ≥ 4 of 16 kits"). Aria's 2-kit appearance is below the cluster minimum of 4 — **flag for implementing-session review**: either extend Aria into kits 13-14 (audience-as-anthology-reader) OR accept the lower count given Aria's late-curriculum focus. Default recommendation: extend to kits 11 / 12 / 13 / 14 for 4 total appearances (Aria as anthology-reader is a natural extension).

---

## 5. Cross-app cameo opportunities (kit 13-16 only)

Per Pattern B cameo policy: **all cameos are HERO-voiced** (Patter narrates the cameo; cluster-shared WORLD characters don't count as cameos when they appear in another writing-craft app — they're cast natively in each app's manifest).

### 5.1 In-cluster cameos (kit 15-16 capstone)

| Sibling app | Sibling character / mascot | Patter's cameo voicing |
|---|---|---|
| **CharacterForge** | Ink (+ Click) | _"Ink in CharacterForge works on voice BEFORE the dialogue scene — Click's surface-signature is what becomes Brogue-style consistency once your characters start talking. Same work, two stages."_ |
| **LyricForge** | Pip (+ Hook Tilly / Chorus Cassie) | _"Pip in LyricForge writes lyrics where the chorus IS dialogue — Rest's silence between lines is the same primitive as a lyric pause."_ |
| **VoiceTale** | Bramble (+ Lean / Slow / Pivot / Refrain) | _"Bramble in VoiceTale speaks dialogue aloud — Pivot is the spoken-form of Sprig's branch-turn. Same pivot, different medium."_ |
| **TaleForge** | Bram (+ Audience Aria shared) | _"Bram in TaleForge plots whole stories; we plot the conversations INSIDE those stories. Audience Aria visits both of us — she reads everything you write."_ |
| **HaikuQuest** | Cherry | _"Cherry in HaikuQuest writes single-line dialogue — a haiku IS a one-utterance scene. Murmur lives there too."_ |
| **DebateForge** | Reasona (+ Audience Aria shared) | _"Reasona's dialogue is ARGUMENT; ours is CONVERSATION. Same listening discipline, different goals. Aria reads both."_ |

### 5.2 Stretch cross-cluster cameos (kit 13-14, lighter touch — optional)

| Sibling app | Sibling character | Patter's cameo voicing |
|---|---|---|
| **MythForge** | (mentor) | _"Heralda shows up in MythForge too — epic dialogue scaled up to mythic register. Same Heralda voice, mythic stakes."_ |
| **DanceQuest** | (mentor) | _"Dance dialogue is non-verbal but it's still dialogue. Rest's pause-craft applies — silence is a line in both."_ |
| **JestForge** | (mentor Quip) | _"JestForge's Quip is a different character than our Quip Goodfellow — same name family, different work. JestForge's Quip is a stand-up comedy coach; ours is a writing-craft register-archetype."_ |

### 5.3 Cameo policy (all clusters)

1. ALL cameos are PATTER-VOICED (Pattern B convention).
2. Cameos CONSTRAINED to kits 13-16. NEVER kits 1-9.
3. Cluster-shared WORLD characters (Heralda / Murmur / Quip Goodfellow / Vesperline) DON'T count as cameos in sibling writing-craft apps — they're cast natively in each app's manifest.
4. Audience Aria cameos to sibling apps in the same cluster (TaleForge / ReadQuest / DebateForge) — when Aria appears in DialogueQuest's kit 11, Patter can reference her appearance in TaleForge's kit 11 ("Aria reads Bram's stories too — she's our shared listener across the workshop").

---

## 6. Assets — delivery plan

### 6.1 Current state

| Asset class | Status | Location |
|---|---|---|
| Patter mascot (5 poses) | PENDING Wave 9.2 asset gen | `Docs/HandoffAssets/distributed_narrative/` |
| Sprig / Glance / Weigh / Brogue / Rest PNGs | PENDING Wave 9.2 asset gen | same |

### 6.2 Phase D — Cluster-shared WORLD inheritance + new META generation

| Asset class | Count | Per-asset cost | Total | Source | Status |
|---|---|---|---|---|---|
| Cluster-shared WORLD (Heralda + Murmur + Quip Goodfellow + Vesperline — all 4 inherited from LyricForge handoff #304) | 4 | $0.00 (inherited) | **$0.00** | LyricForge handoff #304 generates the 4 at $1.08 cluster-total; DialogueQuest consumes ALL 4 at $0 marginal | INHERITED |
| Cluster-shared META — Audience Aria (NEW generation under this handoff — first-gen site) | 1 | $0.27 (Nano Banana Pro) | **$0.27** | Generated here; bundled at `Branding/Cluster/WritingCraft/meta_audience.webp` for sibling-app inheritance | QUEUED |
| Regeneration buffer (15% Pro-tier failure rate, ~0 char) | 0 | — | — | budgeted at handoff level | — |
| **DialogueQuest marginal Phase D cost** | **1** | — | **$0.27** | — | — |

**Output paths**:

```
labsmith/Branding/Cluster/WritingCraft/
├── voice_epic.png + voice_epic.webp        (Heralda — generated in LyricForge wave)
├── voice_lyric.png + voice_lyric.webp      (Murmur — generated in LyricForge wave)
├── voice_comic.png + voice_comic.webp      (Quip Goodfellow — generated in LyricForge wave)
├── voice_tragic.png + voice_tragic.webp    (Vesperline — generated in LyricForge wave)
├── meta_editor.png + meta_editor.webp      (Editor Penn — generated in CharacterForge wave; NOT used by DialogueQuest)
└── meta_audience.png + meta_audience.webp  (Audience Aria — GENERATED HERE)

dialoguequest-app/Docs/HandoffAssets/distributed_narrative_v2/cluster_shared/
├── voice_epic.webp              (inherited)
├── voice_lyric.webp             (inherited)
├── voice_comic.webp             (inherited)
├── voice_tragic.webp            (inherited)
└── meta_audience.webp           (inherited from this handoff's gen)
```

Per-app distribution: `scripts/copy_cluster_assets_to_repos.sh --cluster writing-craft --app dialoguequest` copies all 5 WebP files. The implementing session registers them via `IllustrationRegistry.register(bundle: clusterSharedBundle, slugs: ["voice_epic", "voice_lyric", "voice_comic", "voice_tragic", "meta_audience"])`.

### 6.3 Cultural-sensitivity guardrails (per asset, Phase D audit)

WORLD-layer guardrails inherited from LyricForge handoff #304 § 6.3 + cluster plan § 6.3.

**Audience Aria specific guardrails** (this handoff's new generation):

1. NO authority-coding (Aria is a peer-listener, NOT a critic or gatekeeper).
2. NO judgment-coding (Aria's stance is receptive — she SAYS what she felt, never JUDGES what she heard).
3. Age coding tween-anchor — Aria is the kid-reader peer, ages 12-14; younger than Editor Penn (mid-40s) and younger than the 4 WORLD chars.
4. NO reading-glasses (those belong to Editor Penn — visual distinction matters since both are cluster-shared META).
5. NO race / ethnicity-specific coding (per cluster plan § 1.6 — cluster-shared chars read universally).
6. Gender-presentation inclusive (Aria's name reads any-gender; visual ambiguous-tween-listener).
7. Chunky-cartoon style consistent with `Docs/DESIGN_AVATAR_AESTHETIC.md`; bold `#2A1F1A` outlines.

Reject + regenerate if any fails. Up to 2 regeneration attempts (~$0.54 max for Aria).

---

## 7. Patter voicing — codified rules for layered cast (Pattern B)

Per `PLAN_DN_ENHANCEMENT_WRITING_CRAFT_CLUSTER.md` § 9.2. Patter's existing voice (even-handed coach + "tell me more" + warm + speech-bubble-coded) is PRESERVED. The layered ENHANCEMENT adds these voicing patterns:

1. **Patter introduces WORLD-layer characters as workshop guests, not register-authorities**: "This is Heralda — she helps me hear the BIG voice in a character's lines. When your character needs to sound mythic, Heralda shows us how that register sounds." Never "Heralda is the Epic register expert."
2. **Patter remains the primary on-screen coach (≥60% of dialogue across kits)**. WORLD-layer characters arrive with their catchphrase + 1 demo line in scripted exhibit-dialogues; Patter frames + responds.
3. **Audience Aria is introduced as Patter's listening-friend, not Patter's supervisor**: "Aria reads what we write. She tells us what she FELT — not what was right or wrong. Let's invite her in." Aria's voicing is receptive ("I'm the reader. Here's what I felt."), never gatekeeping.
4. **WORLD + META characters do NOT speak via FoundationModels** — they have ONLY their static catchphrases (≤8 words). Patter's `@Generable DialogueLineAnalysis` prompts can include `activeVoiceRegisterContext: VoiceRegister?` + `activeMetaStanceContext: MetaStance?` so Patter frames examples by register and stance.
5. **Patter's Pattern B convention preserved**: hero stays primary protagonist; cast members are explicitly "my workshop guests" not "experts I defer to."
6. **CRITICAL — Voice-register characters are NOT comparison targets for the learner's own characters.** Patter never says "your character is just like Heralda!" — the WORLD-layer cast teaches register-archetypes through example; the learner's characters are their own.
7. **CRITICAL — Audience Aria's reactions are not corrective.** When Aria says "I felt confused at that turn," Patter never translates this into "you wrote it wrong." Patter's framing is always "Aria heard it that way — is that what you wanted her to hear? If yes, you're done. If no, what could shift?" The reader-response stance is data, not judgment.

---

## 8. Asset-consumer audit — REQUIRED before closing this handoff

Per `.claude/rules/portfolio.md` § Asset Consumer Audit (standing rule 2026-05-20). When Phase D cluster-shared assets ship and you integrate them:

1. **Grep for consumer call sites** — every new slug must be rendered by at least one view:
   ```
   grep -rE 'IllustrationRenderer|MascotReactionView|VoiceRegisterCard|MetaStanceCard|ExhibitDialogueCard' \
     Libraries/Sources/
   ```
2. **Zero hits = shipped-but-dark** — `IllustrationRegistry.register(bundle: clusterSharedBundle, ...)` alone does NOT mean the asset is visible to users. File a follow-up wiring task before closing the handoff.
3. **Confirm Patter's per-kit voicing scripts reference each WORLD + META character** at least once across the 16-kit arc per § 4.1 schedule.
4. **NO orphaned registrations** — every registered slug has at least one consumer.
5. **Audience Aria kit-count gate** — if Aria ships at 2 kits only (kits 11-12), consider extending to 4 per § 4.2 flag. Document the decision in `Docs/AUDIT_DISTRIBUTED_NARRATIVE_DIALOGUEQUEST.md`.

---

## 9. Integration tasks (suggested order)

The implementing session owns the implementation. Suggested sequencing (builds on Wave 9 retrofit phases):

1. **Extend `DialogueExhibitCharacter` → `DialogueQuestCharacter`** (or parallel enum with `.layer` discriminator per § 3.5) — add 4 new `.world` cases + 1 new `.meta` case.
2. **Wire static catchphrases** into a `Character+Catchphrase` extension. ≤8 words each.
3. **Update kit-recurrence map** — extend the Wave 9 map with WORLD + META character introductions per § 4.1.
4. **Patter voicing scripts** — for each (kit, scene) tuple where a WORLD or META character appears, write Patter's framing per § 7 rules. Particular care for kit 5 (density at 4) + kit 11 (density at 5; founder review density-tightness).
5. **Author scripted register-juxtaposition exhibit-dialogues** — kit 5 specifically asks for Heralda + Murmur exhibit-dialogues (the kid hears one line in heroic register, the same line in lyric register, and feels the difference). Kit 10 adds Vesperline as a third register-contrast. This is the LOAD-BEARING pedagogy DialogueQuest extends from Wave 9.
6. **Wait for LyricForge Phase D cluster-shared asset wave** (queue #304) + this handoff's Audience Aria generation. On arrival, register via `IllustrationRegistry.register(bundle: clusterSharedBundle, slugs: ["voice_epic", "voice_lyric", "voice_comic", "voice_tragic", "meta_audience"])` and wire through `MascotReactionView` per the consumer-audit standing rule.
7. **Test gates** — every WORLD character has ≥3 kit appearances; Audience Aria either extends to ≥4 kits or document the deviation; every cast member has at least one consumer call site; no cast member appears in kits 13-16 without first being introduced in kits 1-9.

---

## 10. Cross-references

- `labsmith/Docs/PLAN_DN_ENHANCEMENT_WRITING_CRAFT_CLUSTER.md` — cluster plan (queue #279)
- `labsmith/Docs/RESEARCH_DN_LAYERED_ENHANCEMENT_PORTFOLIO_EXPANSION.md` — cluster research input (queue #277)
- `lyricforge-app/Docs/HANDOFF_FROM_LABSMITH_DN_ENHANCEMENT.md` — sibling cluster handoff (queue #304; canonical asset-gen site for the 4 cluster-shared WORLD chars)
- `haikuquest-app/Docs/HANDOFF_FROM_LABSMITH_DN_ENHANCEMENT.md` — sibling cluster handoff (queue #305)
- `characterforge-app/Docs/HANDOFF_FROM_LABSMITH_DN_ENHANCEMENT.md` — sibling cluster handoff (queue #306; canonical first-gen site for Editor Penn)
- `voicetale-app/Docs/HANDOFF_FROM_LABSMITH_DN_ENHANCEMENT.md` — sibling Session-2 handoff (queue #318)
- `inkquest-app/Docs/HANDOFF_FROM_LABSMITH_DN_ENHANCEMENT.md` — sibling Session-2 handoff (queue #319)
- `labsmith/Docs/GUIDE_DISTRIBUTED_NARRATIVE_METHODOLOGY.md` — DN methodology canonical spec
- `labsmith/Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` — collision-prevention registry
- `labsmith/Docs/DESIGN_AVATAR_AESTHETIC.md` — chunky-cartoon style spec
- `labsmith/.claude/rules/distributed-narrative.md` — portfolio rule (Pattern B preservation)
- `labsmith/.claude/rules/portfolio.md` § Asset Consumer Audit — required step before closing
- `dialoguequest-app/Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` — previous handoff (Patter + 5 LESSONS-layer cast)
- `dialoguequest-app/CLAUDE.md` — current app state

---

## 11. Open questions for the implementing session

1. **Cluster-shared asset bundle integration**: same question as LyricForge / HaikuQuest / CharacterForge handoffs — do you prefer (a) cross-bundle reference from `Branding/Cluster/WritingCraft/`, or (b) local copy into `Docs/HandoffAssets/distributed_narrative_v2/cluster_shared/`? Default (a).
2. **Audience Aria kit-count**: § 4.2 flags Aria at 2 kit appearances (below the cluster methodology minimum of 4 for META). Default recommendation: extend Aria to kits 11 / 12 / 13 / 14 (4 total — Aria as anthology-reader). The implementing session has final say.
3. **Kit 5 density**: kit 5 features 4 cast members (Patter + Sprig + Glance + Weigh + Heralda + Murmur — that's actually 6 if all stay). Per density rule (max 4 in voice-editor synthesis), drop one LESSONS char from kit 5's intro card view — recommend dropping Sprig from kit 5 (Sprig is lead in kits 1, 3, 11; absence in kit 5 doesn't hurt). The Heralda + Murmur register-juxtaposition is the load-bearing pedagogy; preserve it.
4. **Kit 11 density**: kit 11 features 5 cast members (Patter + Sprig + Rest + Heralda + Vesperline + Aria). Density at 5 sits ABOVE the Pattern B cap (max 4). Drop one — recommend dropping Heralda from kit 11 (Heralda's lead is kit 8 + recur; she's not load-bearing for branch-meaningfulness work). Vesperline + Aria carry kit 11's elegiac-audience pairing.
5. **Quip Goodfellow soft-collision audit**: § 3.6 flags soft collision with JestForge mentor "Quip" — same name family, different work. Full-name "Quip Goodfellow" disambiguates in text but in audio context (TTS), the kid hearing both apps might confuse them. Recommend: in CONTENT_STYLE_GUIDE codify Patter always referring to "Quip Goodfellow" (full name) when introducing him in kit 7; "Quip" alone reserved for shorter back-references after kit 9.
6. **WORLD-character non-comparison rule**: § 7 rule 6 is load-bearing — Patter must NEVER compare the learner's character voice to Heralda/Murmur/Quip Goodfellow/Vesperline. CONTENT_STYLE_GUIDE should codify this explicitly. Test gate: any prompt that includes both `learnerCharacterVoice` AND `castWorldMember` must be reviewed for comparison-language.
7. **Audience Aria reader-response framing**: § 7 rule 7 is load-bearing — Aria's reactions are data, not corrective feedback. CONTENT_STYLE_GUIDE should codify the "Aria heard it that way — is that what you wanted her to hear?" template explicitly.

Respond via a `HANDOFF_FROM_APP_DN_ENHANCEMENT_REPLY.md` if any of these need labsmith input before you proceed.
