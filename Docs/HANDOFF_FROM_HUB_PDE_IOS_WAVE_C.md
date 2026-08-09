# Handoff from Hub — PDE Wave-C (iOS) design elevation for dialoguequest

Direction: **hub → dialoguequest**. Date: 2026-08-09. Program: **Professional Design Elevation (ADR-100) / PDE-Fleet Wave-C** (pedagogical-priority round-robin). SPEC handoff — **hub does NOT write Swift/Xcode source**; dialoguequest's OWN CC session implements the steps below against the real Xcode project, then flips its `ios:{tokens,craft,figma,review}` cells in `spark-anvil-hub/Docs/REGISTRY_DESIGN_ELEVATION_FLEET.txt` + files a completion handoff back.

## The recipe (canonical)
Follow **`spark-anvil-hub/Docs/GUIDE_PDE_IOS_WAVE_C_ADOPTION.md`**. Cross-surface target: match this app's shipped **`/play/dialoguequest`** web clone (same brand palette, IA character, feedback register) so iOS + web render one design system.

## ✅ STEP 0 SHIPPED (2026-08-09) — everything below is ACTIONABLE NOW
ForgeKit vendored `ForgeTokens` + rewired `DefaultForgeTheme` (**ForgeKit 1.0.0-rc.5**, PR #156, verified on `forgekit/main`).

- **STEP 1 — tokens.** **Bump this app's ForgeKit pin to ≥`1.0.0-rc.5`** (R-FORGEKIT-PIN-CONSISTENCY), then map `*Theme.swift` → `ForgeTokens.*` (via `import ForgeUI`) / this app's `.pc-theme-dialoguequest` accent; drop generic `.blue`/`.orange`. Flip `ios:tokens`.
- **STEP 2 — Pillar-3 craft:** typographic rhythm + **Dynamic Type**; **functional** micro-interaction feedback (reuse `ForgeUI` `.correctFeedback`/`.incorrectFeedback`/`ForgeScoreHUD`); reduced-motion-safe motion (parameterized `.animation(_, value:)`); polished **empty/loading/error** states (`ForgeEmptyState`, the ⑧ every-state invariant); illustration-at-boundaries; **no** streak/currency dark-patterns. Flip `ios:craft`.
- **STEP 3 — Pillar-4 review:** Nielsen-10 + a11y (VoiceOver `.accessibilityHint()` on buttons NOT `.accessibilityLabel()`; Dynamic Type; AA contrast; reduced-motion; ≥44pt) + cross-surface consistency vs `/play/dialoguequest`. Flip `ios:review`.
- **STEP 4 (optional) — Figma review** (spec/review only, never a code source). Flip `ios:figma`.

## HARD LINE + honest-yield
Figma = spec/review, NEVER a code source; no design-tool-generated code ships. Market cross-surface design-system parity + professional-grade craft, never a learning-outcome claim.

## Cross-references
`spark-anvil-hub/Docs/GUIDE_PDE_IOS_WAVE_C_ADOPTION.md` · `ADR-100` Amd 5 · § R-PDELEV-PORTFOLIO-FANOUT · `forgekit/Docs/HANDOFF_FROM_HUB_DTCG_SWIFT_TOKEN_EMIT.md` (STEP 0, rc.5) · hub queue `q-955a78`.
