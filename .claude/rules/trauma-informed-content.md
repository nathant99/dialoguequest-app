# Trauma-Informed Content Design

Portfolio standard codified 2026-05-19, grounded in SAMHSA TIP 57 (2014) + Eggleston et al. (2025) scoping review + Stoltenburg et al. (2024) STRYV365 evaluation. See `labsmith/Docs/RESEARCH_DIR_FEDC_DEEP_DEVELOPMENTAL_AUDIT.md` § 8 for the full evidence chain.

## When this rule applies

Any app that engages **trauma-adjacent content** must adopt a documented trauma-informed (TI) posture in `Docs/TECHNICAL_DESIGN.md`. Trauma-adjacent content includes:

- Historical violence, war, slavery, genocide, displacement (ChronoQuest, MythForge, HistoryForge, TaleWeave, LoreQuest)
- Climate collapse, extinction, environmental loss (ClimateQuest, WildLens, EcoSphere, TerraVoyage, TerraWatch, BiomeForge)
- Medical procedures, animal injury or death, illness (CreatureCare, MedicQuest, BodyForge, BioForge, GeneForge)
- Civic conflict, propaganda, misinformation, ethical dilemmas (CivicForge, TruthQuest, NewsForge, EthosForge, DebateForge)
- Mental-health themes, ACEs, peer rejection, identity stress (MindForge, FocusForge, WellnessForge)

If your app's curriculum touches any of these, you MUST include a TI posture section. MindForge is the portfolio gold-standard (explicit SAMHSA + NCTSN citation).

## The six SAMHSA principles translated to design constraints

| SAMHSA TIP 57 Principle | Design Constraint |
|---|---|
| **Safety** | Predictable session structure; no sudden jump-scares, gore, or distressing audio. Content warnings before chapters on heavy topics. Visible "leave" affordance always available |
| **Trustworthiness & transparency** | Tell the learner what's coming before they enter heavy content. "This chapter covers the Trail of Tears" with a one-line summary, NOT a surprise reveal |
| **Peer support** | Where multiplayer/social features touch trauma-adjacent content, never expose learners to anonymous peer reactions (no comments, no reactions) without moderation. Asynchronous mentor-mediated peer presence preferred over real-time |
| **Collaboration & mutuality** | The AI mentor co-explores; never lectures down. Use "Let's think about this together" not "Here's what happened" framing. Learner can ask the mentor to pause, slow, or skip |
| **Empowerment, voice & choice** | Always offer an off-ramp on heavy content: skip-with-summary, audio-only, slower pacing, alternate framing (symbolic-distance variant). Learner controls re-exposure |
| **Cultural, historical & gender issues** | Content authored or reviewed by people from the depicted community when possible. Multiple perspectives surfaced, not single-narrative. No "model minority" framing, no white-savior narrative, no romanticized colonization |

## Symbolic distance as evidence-supported scaffold

Symbolic-distance approaches are evidence-supported trauma-informed design patterns (Eggleston et al., 2025, identifies them as a recurring design move in successful TI digital products; CreatureCare's animal-patient framing, TaleWeave's mythic distance, SpectrumCanvas's abstract-visual modality, LyricForge's verse formalism are portfolio examples).

When designing a unit on a heavy topic:

1. **First-pass framing should be symbolic** — fable, animal analog, hypothetical scenario, abstracted system
2. **Direct engagement is optional** — offer it as a deeper-dive after the symbolic frame is established; never the only path
3. **Never collapse the distance unrequested** — if the symbolic frame is "the forest's animals are displaced by fire," do not surprise the learner with "this is what happened to <specific community> in <specific year>" mid-scene

## Off-ramps (required for all trauma-adjacent units)

Every trauma-adjacent unit MUST provide:

1. **Pre-content content warning** — one-line topic disclosure + "you can skip this section" affordance
2. **In-content skip affordance** — visible "I want to move on" button accessible from any screen in the unit
3. **Skip-with-summary** — choosing to skip surfaces a 1-paragraph summary so the learner doesn't lose curricular continuity
4. **Audio-only / silent mode** — for learners whose distress is image-driven, audio narration with placeholder visuals
5. **Pacing control** — learner can slow down or speed up; default pacing favors the slower end
6. **Optional debrief** — after a heavy unit, mentor offers reflection: "How are you doing? Want to talk about what we just saw?" — learner can decline or engage

## The mentor posture for heavy content

Three rules. Apply to every AI-mentor utterance in trauma-adjacent units:

1. **Validate, then inform** — "It makes sense that this is hard to read" before explanation. Never "This is just history, let's move on"
2. **Hold space, don't resolve** — heavy content doesn't get a tidy ending. The mentor names the difficulty without pretending it's been solved
3. **Refer up when out of scope** — if the learner reports distress beyond the unit's scope ("this reminds me of my own family"), the mentor surfaces an "it's okay to talk to a trusted adult" message, NEVER attempts therapy. For acute risk, surface crisis resources (988 Suicide & Crisis Lifeline US; per-locale equivalents for international)

## What NOT to do (portfolio anti-patterns)

- ❌ Use trauma content for shock value, "edgy" tone, or to make the app seem mature
- ❌ Surprise the learner with a heavy reveal mid-quiz / mid-game (e.g., "did you know this character actually died of cholera?")
- ❌ Gamify atrocity ("Score points for surviving the Trail of Tears" — actual real-world failed designs exist)
- ❌ Make heavy content unskippable in service of curriculum completion
- ❌ Use a single dominant-culture narrative for events that affected multiple communities differently
- ❌ Have the mentor minimize ("It's just a story," "Don't worry about it," "Other kids handle this fine")
- ❌ Use real images of suffering (corpses, war wounds, dying animals) when illustration would serve

## CLAUDE.md template addition

Apps engaging trauma-adjacent content must add to `Docs/TECHNICAL_DESIGN.md`:

```markdown
## Trauma-Informed Content Posture

This app engages trauma-adjacent content in: [list units / chapters / mode-cards].

### Framework
SAMHSA TIP 57 (2014) six principles + Eggleston et al. (2025) digital TI design patterns. See `.claude/rules/trauma-informed-content.md`.

### Off-ramps
- Pre-content warnings: [location in flow]
- In-content skip: [implementation]
- Skip-with-summary: [yes/no, location]
- Audio-only mode: [yes/no, gating]
- Pacing control: [implementation]
- Optional debrief: [yes/no, mentor wiring]

### Mentor posture
[Mentor name] follows the validate-then-inform / hold-space / refer-up posture defined in `.claude/rules/trauma-informed-content.md` for trauma-adjacent units.

### Symbolic-distance design
[Describe the symbolic frame used as first-pass approach for each trauma-adjacent unit, e.g., "ChronoQuest's Trail of Tears unit is first introduced via a fictional displaced animal-tribe analog, then optionally deepens to the historical event for learners who choose to engage further."]

### Content review
[List subject-matter expert / community reviewer / sensitivity reader involvement.]
```

## When this rule is a hard requirement vs. a soft recommendation

**Hard requirement** (block ship until met):
- Off-ramp affordances (skip + summary, audio-only, pacing)
- Pre-content warnings for any unit covering: real-world atrocity, animal death, medical procedure, identity-based violence
- Mentor posture rules (validate-then-inform, refer-up on acute distress)
- Crisis resource surfacing where learner reports distress beyond unit scope

**Soft recommendation** (document deviation if not met):
- Subject-matter expert / community sensitivity reviewer for every trauma-adjacent unit (preferred; pragmatic minimum is one external review per major unit)
- Symbolic-distance first-pass framing (preferred for ages 9–11; can be optional for ages 12+ depending on curriculum framing)

**Trauma-adjacent art generation** (amended per ADR-012, Round 104 #506, 2026-05-28):

External R0 sensitivity-reviewer signoff is the **preferred path** for trauma-adjacent art gen, but **founder-ADR-approved AI gen is an accepted alternative** subject to ALL of the following constraints:

1. **Single-instance ADR per gen wave** — author `Docs/ADR-NNN_<topic>.md` documenting the wave's scope + cost + visual-audit results + decision rationale. Founder ACK in the ADR's "Status: ACCEPTED" line is the signoff.
2. **4/4 random-sample visual audit** using the `Read` tool per memory `feedback_read_tool_sees_images.md` BEFORE distribution. Audit must confirm the chunky-cartoon TI register holds.
3. **No realistic distress imagery** (no tears, blood, body wounds, panic-coded facial expressions); **no lean-coded body imagery** for body-image-risk apps; **no Indigenous TEK appropriation** for Indigenous-content clusters; **no specific cultural-deity references** for religion/origin-myth apps.
4. **Trauma-adjacent CONTENT** (cast dialogue / mentor posture / off-ramp copy / hint scaffolding / question-kit text) STILL requires R0 reviewer signoff — this amendment only carves out the **art axis**. R0 signoff remains load-bearing for the content axis.
5. The ADR notes which app cluster(s) the gen covers + what R0 reviewer signoff (if any) is preserved for downstream content work.

**Why this carve-out**: SAMHSA TIP 57's actual load-bearing concerns are off-ramps + mentor posture + content framing — not visual art per se. The portfolio's chunky-cartoon visual register inherently avoids realistic distress imagery, so the art axis is the lowest-risk axis. R0 signoff is preserved where it's actually load-bearing (content).

**Reversibility**: a future ADR can supersede ADR-012 to re-tighten the rule. Each founder-ADR-approved gen wave creates an audit trail for retrospective review.

**Trauma-adjacent DN-S story authoring** (amended per ADR-016, Round 363 #798, 2026-05-31):

External R0 sensitivity-reviewer signoff is the **preferred path** for trauma-gated DN-S chapter authoring (story-axis), but **user-direct ADR-016 approval is an accepted alternative** subject to ALL of the following constraints:

1. **Standing user-direct approval** — R363 user-direct "approve all trauma-gated work items" delivers the umbrella authorization for the ~25-app trauma-gated cluster (HarvestForge / FarmQuest / EthosForge / ClaimCraft / NewsForge / TruthQuest / MindForge / ChronoQuest / MythForge / HistoryForge / BioForge / MedicQuest / CreatureCare / FitQuest / DanceQuest / WellnessForge / SaffronLab / CivicForge / DataForge / OriginForge / LoreQuest / BiomeForge TEK / TerraVoyage / TrailForge / DigQuest)
2. **SAMHSA TIP 57 register MANDATORY** — every trauma-gated chapter authored with validate-then-inform / hold-space / refer-up mentor posture
3. **Off-ramps + content warnings + crisis-resource lists MANDATORY** in chapter content + companion off-ramp copy
4. **Cultural-respect framing** — Indigenous + traditional + community-domain knowledge credited explicitly without mascotization or appropriation
5. **Anti-shame framing** — structural / systems-level framings replace personal-failing / individual-virtue framings for any access / inequality content
6. **Anti-evangelism for contested life-questions** — cast does NOT advocate single positions on contested questions (vegetarian/vegan/omnivore for FarmQuest; political position for CivicForge; religion for OriginForge; etc.)
7. Per-app handoff MUST cite ADR-016 + the specific trauma-axis flag(s) (e.g., `food-justice + farmworker-labor + Indigenous-knowledge-credit`)
8. **Trauma-adjacent ART (per-app cast portraits + scene illustrations)** STILL requires the ADR-012 art-axis path (R0 reviewer OR founder-ADR-approved AI gen) — this amendment only carves out the **story-axis**. ADR-012 art-axis path remains load-bearing for downstream art generation.

**Why this carve-out**: cumulative R0 reviewer envelope (~$5-7.5K) blocking ~25 apps indefinitely is a practical blocker, not a moral one. The load-bearing trauma-informed concerns (off-ramps + mentor posture + content framing + cultural-respect + anti-shame) move INTO the chapter content itself as MANDATORY constraints. The user holds the authorial-care load directly via ADR-016; per-chapter SAMHSA-register discipline replaces the external sensitivity-reviewer gate for the story-axis specifically.

**Reversibility**: a future ADR can supersede ADR-016 + require R0 reviewer signoff on already-authored trauma-gated chapters. Each chapter is markdown in the per-app repo; revision is straightforward. ADR-016 + per-app handoff citations + memory `feedback_trauma_gated_dns_approved.md` create the audit trail for retrospective review.

**Trauma-adjacent AUDIO generation** (amended per ADR-020, Round 416 #898, 2026-06-01):

User-direct ADR-020 approval is an accepted alternative to R0 audio-reviewer signoff for trauma-gated DN-S audio drama gen — **parallel to ADR-016 for text**. Each trauma-gated audio drama wave under this carve-out:

1. **Single-instance ADR per gen wave** — gen scopes covered by ADR-020 directly OR a follow-on ADR-NNN if scope changes; record per-app trauma-axis flag in round-close + audio drama handoff
2. **Per-app pre-listen audit** RECOMMENDED CONCURRENT — labsmith manually listens to each trauma-gated audio drama before cross-repo PR ship; flag any drift from SAMHSA TIP 57 register or vendor-filter softening for re-gen
3. **SAMHSA TIP 57 register STILL applies**: validate-then-inform / hold-space / refer-up across all spoken lines; mentor posture preserved
4. **Off-ramp affordances STILL required** via `AudioDramaPlayer.skipToChapter` (ForgeKit 0.99.11+ `AudioDramaPlayer` API) + pacing control + audio-only-mode option per `.claude/rules/distributed-narrative.md` § Off-ramps
5. **Crisis-resource surfacing** at app-integration time remains MANDATORY per § The mentor posture above; trauma-gated `AudioDramaModerationGate` implementation per app
6. **Cultural-credit + descendant-community-respect rules** per `.claude/rules/distributed-narrative.md` § Cultural-sensitivity gates STILL apply to script-adaptation BEFORE TTS gen — Indigenous TEK references credited; specific cultural-deity / sacred-text references abstracted to archetypes; no romanticized colonization framing
7. **Vendor-side content-filter softening** is an accepted script-adaptation move when Gemini 2.5 TTS (or other vendor) flags specific historical-violence terms — softening preserves curriculum while changing surface language (e.g., "Trail of Tears" → "the Cherokee Nation's forced removal"). This is a vendor-side constraint not a labsmith-policy constraint; document the softening in script.md front-matter for audit trail
8. **R0 audio-reviewer signoff remains deferred-but-not-waived** for future regulatory or platform-review needs (school-district procurement, etc.)

**Why this carve-out**: same logic as ADR-016 for text — the load-bearing trauma-informed concerns (off-ramps + register + crisis-resource + cultural-respect + vendor-filter discipline) move INTO the audio gen pipeline as MANDATORY constraints. The user holds the authorial-care load directly via ADR-020; per-script SAMHSA-register discipline + per-app pre-listen audit replace the external R0 audio-reviewer gate for the audio-axis specifically. Cumulative R0 audio-reviewer envelope blocking ~25 trauma-gated apps' Phase 2 audio drama indefinitely is a practical blocker, not a moral one.

**Reversibility**: a future ADR can supersede ADR-020 + require R0 audio-reviewer signoff on already-generated audio dramas. Each drama is a bundled CAF in the per-app repo; revision via re-gen + cross-repo PR revert is straightforward.

## Cross-references

- `labsmith/.claude/rules/ai-content.md` — AI-generated content accuracy policy (TI applies on top of accuracy)
- `labsmith/.claude/rules/age-assurance.md` — COPPA / age-range API context (some TI affordances are required by COPPA + state laws independently)
- `labsmith/Docs/RESEARCH_DIR_FEDC_DEEP_DEVELOPMENTAL_AUDIT.md` § 8 — full evidence base + citations
- `mindforge-app/Docs/TECHNICAL_DESIGN.md` — portfolio gold-standard implementation (explicit SAMHSA + NCTSN cited)
- `labsmith/Docs/ADR-012_TI_RULE_FOUNDER_ADR_APPROVED_AI_GEN.md` — art-axis carve-out for trauma-adjacent AI gen
- `labsmith/Docs/ADR-016_DN_S_TRAUMA_GATED_STORY_AXIS_APPROVAL.md` — story-axis carve-out for trauma-gated DN-S chapter authoring (user-direct R363 approval)

## References

- Substance Abuse and Mental Health Services Administration. (2014). *SAMHSA's concept of trauma and guidance for a trauma-informed approach* (TIP 57, HHS Publication No. SMA 14-4884).
- Eggleston, M., Jones, E. P., Khan, N., Romani, W. A., McQuillan, K., Otero, J., & Chen, E. (2025). A scoping review of trauma-informed care principles applied in design and technology. *Digital Health*, 11. https://doi.org/10.1177/20552076251360925
- Stoltenburg, S., et al. (2024). STRYV365 peak team and Brain agents: Teacher perspectives on school impact of a trauma-informed, social-emotional learning approach for students facing adverse childhood experiences. *Frontiers in Psychology*. PMC11494034.
- *JMIR Pediatrics and Parenting* (2024). Digital health innovations for ACE mitigation narrative review.
<!-- END LABSMITH-SYNCED CONTENT -->
