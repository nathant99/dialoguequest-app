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

## Cross-references

- `labsmith/.claude/rules/ai-content.md` — AI-generated content accuracy policy (TI applies on top of accuracy)
- `labsmith/.claude/rules/age-assurance.md` — COPPA / age-range API context (some TI affordances are required by COPPA + state laws independently)
- `labsmith/Docs/RESEARCH_DIR_FEDC_DEEP_DEVELOPMENTAL_AUDIT.md` § 8 — full evidence base + citations
- `mindforge-app/Docs/TECHNICAL_DESIGN.md` — portfolio gold-standard implementation (explicit SAMHSA + NCTSN cited)

## References

- Substance Abuse and Mental Health Services Administration. (2014). *SAMHSA's concept of trauma and guidance for a trauma-informed approach* (TIP 57, HHS Publication No. SMA 14-4884).
- Eggleston, M., Jones, E. P., Khan, N., Romani, W. A., McQuillan, K., Otero, J., & Chen, E. (2025). A scoping review of trauma-informed care principles applied in design and technology. *Digital Health*, 11. https://doi.org/10.1177/20552076251360925
- Stoltenburg, S., et al. (2024). STRYV365 peak team and Brain agents: Teacher perspectives on school impact of a trauma-informed, social-emotional learning approach for students facing adverse childhood experiences. *Frontiers in Psychology*. PMC11494034.
- *JMIR Pediatrics and Parenting* (2024). Digital health innovations for ACE mitigation narrative review.
