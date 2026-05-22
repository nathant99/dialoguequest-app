# Implementation Handoff — DialogueQuest

**Status**: Placeholder (scaffold-only 2026-05-22). Full handoff content pending labsmith Tier 2 doc wave.

## Read First

1. **Labsmith concept doc**: `labsmith/Docs/DialogueQuest/README.md` — full vision, Phase 1 scope, mascot, hero color, ForgeKit modules to wire
2. **This repo's CLAUDE.md** — portfolio tech stack + reference doc index
3. **Portfolio patterns**: `labsmith/Docs/PORTFOLIO_PATTERNS.md` § Implementation Prep Checklist Steps 3-7

## Phase 1 Scope (Summary — Pending Detail)

See the labsmith concept doc Phase 1 scope section. At a high level:

- Build the app shell + SPM package per the Apps/Packages layout (or flat layout — see `.claude/rules/spm-architecture.md`)
- Wire ForgeKit modules per the concept doc's list
- Implement the core primitive (the unique-to-this-app domain logic)
- Author the pending Tier 2 docs (TECHNICAL_DESIGN, FEATURE_PLAN, CONTENT_STYLE_GUIDE, TESTING_STRATEGY, PERFORMANCE_BUDGET, KIDSAFE_PREPARATION, DOCUMENT_CATALOG) as you build

## Sequencing Constraints (Reminder)

Re-read the concept doc's "Sequencing constraint" section before starting — most cluster apps have explicit dependencies on prior-Wave apps shipping their shared engines first (e.g., VoiceTale blocks on LyricForge's `ParentalConsentService` voice-opt-in design; DialogueQuest blocks on CharacterForge's `CharacterEngine` voice-consistency check).

## What This Doc Will Become

After labsmith's Tier 2 doc wave (queued in `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` Round 45 #197 follow-up), this doc gets the standard 9-section structure (Overview, Phase 1 Scope, Domain Types, Rendering Decision, AI Mentor Persona, Question Kits, ForgeKit Modules, Constraints, Definition of Done) per `labsmith/Docs/PORTFOLIO_PATTERNS.md` Implementation Handoff Workflow.
