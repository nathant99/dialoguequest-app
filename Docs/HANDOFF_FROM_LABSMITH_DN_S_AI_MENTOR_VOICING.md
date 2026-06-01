---
status: NEW
date: 2026-06-01
round: Round 400 #823 (labsmith DN-S Integration Phase 1D portfolio rollout — dialoguequest)
parent-decision: labsmith/Docs/DECISION_DN_S_AI_MENTOR_PORTFOLIO_ROLLOUT.md
parent-plan: labsmith/Docs/PLAN_DN_S_PORTFOLIO_ROLLOUT_WAVES_2026-06-01.md
template-source: labsmith/Docs/TEMPLATE_HANDOFF_FROM_LABSMITH_DN_S_AI_MENTOR_VOICING.md
forgekit-version-required: 0.97.0 (CastDialog API)
trauma-gating: NONE
moderation-sensitivity: .normal
---

# Handoff from Labsmith — DN-S AI-Mentor Voicing for Dialoguequest

Direction: **labsmith → dialoguequest-app**. Operationalizes Option D of labsmith's `PLAN_DN_S_INTEGRATION_PHASES_2026-06-01.md` (ADR-019; Phase 1D approved per `DECISION_DN_S_AI_MENTOR_PORTFOLIO_ROLLOUT.md` R394 #818) for dialoguequest.

## What this handoff delivers

A per-app `CastVoiceRegistry` (Swift) mapping dialoguequest's 5 cast members' chapter voice-register cards into `CastVoiceProfile` instances consumable by ForgeKit 0.97.0's `CastDialog` API. When wired, the AI mentor can speak AS any cast member in the character's voice register.

## Pre-requisites

- [ ] ForgeKit pin in `Libraries/Package.swift` is `from: "0.97.0"` or higher
- [x] `Docs/dn-s/chapters/*.md` files exist for every cast member (5 of 5 shipped; total 4899 words)
- [ ] App's existing AI mentor service uses `FoundationModels.LanguageModelSession`
- [x] App is in the Phase 1D portfolio rollout (post-pilot trio)

## Dialoguequest cast inventory + voicing priority

| Order | Character | Slug | Primitive embodied | Chapter words | Priority rationale |
|---|---|---|---|---|---|
| 1 | Brogue | `brogue` | (derive from chapter) | 985 | Lead — establishes CastVoiceRegistry baseline; voice-clarity heuristic |
| 2 | Glance | `glance` | (derive from chapter) | 934 | Secondary lead — order 2 |
| 3 | Rest | `rest` | (derive from chapter) | 993 | Secondary lead — order 3 |
| 4 | Sprig | `sprig` | (derive from chapter) | 1156 | Wave-batch — order 4 |
| 5 | Weigh | `weigh` | (derive from chapter) | 831 | Wave-batch — order 5 |

**Cast total**: 5 chapters; 4899 words.

## Implementation steps

Follow `labsmith/Docs/TEMPLATE_HANDOFF_FROM_LABSMITH_DN_S_AI_MENTOR_VOICING.md` § Implementation, customized to dialoguequest's cast:

1. Derive `CastVoiceProfile` per chapter using `labsmith/Docs/SCHEMA_CAST_VOICE_REGISTRY.md`
2. Build `CastVoiceRegistry` at app launch
3. Wire AI mentor call sites to invoke `castDialog.respondAs(.character(slug), prompt:, context:)`
4. Feature-flag via `ForgeExperiments.castVoicing` (default off; TestFlight enable)
5. Regression-test moderation pipeline (100 sample interactions across diverse contexts)

## Pilot-derived learnings (codified per `DECISION_DN_S_AI_MENTOR_PORTFOLIO_ROLLOUT.md`)

1. **Prompt-budget calibration FIRST** — for any app with chapters > 1500w, measure input tokens before authoring all profiles
2. **12-profile perf ceiling validated** — `CastVoiceRegistry` at 12-profile scale fits on iPad Mini 2026
3. **Paired-voicing API works without extension** — `respondAs(.character(slug), ...)` handles "we"/plural automatically for paired chapters
4. **Crisis-keyword fallback is universal** — ForgeKit's built-in moderation handles distress signals
5. **Voicing-priority order matters** — start with most-formal-register character

## Success criteria

- [ ] Voice fidelity: 100 sample audit; ≥ 90% rated "clearly this character" for each profile
- [ ] Character drift rate: < 2% per session
- [ ] Engagement parity: session length / kit completion / hint frequency ≥ baseline single-mentor
- [ ] Crisis-keyword fallback verified
- [ ] Feature-flag shipped (default off)

## Effort estimate

- 5 `CastVoiceProfile`s × ~15-20 min/profile derivation = ~2-4h
- Registry + wiring + regression-test = ~1-2h
- Total per-app CC session: ~3-7h
- ~14d telemetry observation (optional; gated on app-side decision)

## Cross-references

- `labsmith/Docs/DECISION_DN_S_AI_MENTOR_PORTFOLIO_ROLLOUT.md` — parent decision (R394 #818)
- `labsmith/Docs/PLAN_DN_S_PORTFOLIO_ROLLOUT_WAVES_2026-06-01.md` — rollout sequencing
- `labsmith/Docs/TEMPLATE_HANDOFF_FROM_LABSMITH_DN_S_AI_MENTOR_VOICING.md` — template
- `labsmith/Docs/SCHEMA_CAST_VOICE_REGISTRY.md` — `CastVoiceProfile` schema
- `labsmith/Docs/ADR-019_DN_S_INTEGRATION_OVER_ENSEMBLE_STORIES.md` — decision rationale
- `forgekit/Docs/CHANGELOG.md` (0.97.0) — `CastDialog` API
- `.claude/rules/distributed-narrative.md` § DN-S Integration — portfolio rule
- `.claude/rules/foundationmodels.md` — FoundationModels safety patterns


- Local: `Docs/dn-s/chapters/*.md` (5 chapters, 4899 words total) — source content

---

**Disposition**: ✅ HANDED OFF — implementation belongs to dialoguequest-app's CC session. No retrospective required (portfolio rollout proceeds without per-app retrospective gating).
