---
status: DECIDED
date: 2026-07-08
decision: DEFER — do NOT put Patter behind ForgeAvatar's composable/customizable avatar system
freshness-horizon: 90 days
relates-to: Priority O (carried; explore-then-decide) from Docs/SESSION_HANDOFF_2026-07-07_ROUND_CLOSE.md
---

# Decision — `ForgeAvatar` surface for the Patter mascot

> **Direction**: in-repo decision (app session). Resolves the carried "explore-then-decide" Priority O. The explore half is this doc; the decision is **DEFER**.

## Status

**DECIDED — DEFER.** Patter stays a fixed, hand-authored identity. DialogueQuest does **not** route its mentor mascot through `ForgeAvatar`'s composable/customizable avatar system (`AvatarConfig` / `AvatarLayer` / `AvatarStudioView`). No code change ships this round. Re-evaluation triggers are listed under *Consequences → Reversibility*.

## Context

Priority O (carried across several rounds) asked whether the Patter mascot should adopt a `ForgeAvatar` surface for "avatar customization", flagged explicitly as *explore-then-decide* because the risk surface is **Patter identity drift** — Patter is the protagonist mentor per the distributed-narrative (DN) methodology.

State of the world today:

- **Patter is rendered text-only.** `Libraries/Sources/SharedUI/Mentor/MentorBubbleView.swift` is a `message:`-only speech bubble with an SF Symbol (`bubble.left.and.bubble.right.fill`) tinted `DialoguePalette.rust`. Its doc comment notes: *"Phase 1 is a text-only speech bubble; Phase 2+ swaps in the Patter illustration + wobbly tail."* There is no Patter illustration in the bundle yet.
- **`ForgeAvatar` is already adopted — for the KID's avatar, not Patter.** `Libraries/Sources/AppFeature/Profile/ProfileDashboardView.swift` hosts `ForgeAvatar.AvatarStudioView` (with the `getOrCreateForgeID` seeding gotcha handled) so the kid customizes *their own* avatar. That is the canonical, correct use of `ForgeAvatar`: player self-representation that propagates across the portfolio via `AppGroupStore`.
- **Patter's palette is brand identity.** `DialoguePalette.rust` (#A05A4B, "Conversation Rust") is DialogueQuest's hero color and Patter's signature tint. It is not a per-kid-tunable surface.
- **DN methodology — Pattern B.** Per `.claude/rules/distributed-narrative.md` § "Hero mascot vs. cast (the protagonist question)", DialogueQuest is a Pattern B app: the hero mascot (**Patter**) stays the primary protagonist; the cast (Sprig / Glance / Weigh / Brogue / Rest) supports. The recurring-character pedagogy depends on Patter being a **consistent, recognizable** guide across the 16-kit arc.

The question therefore reduces to: should Patter be made **kid-customizable / palette-tunable** via `ForgeAvatar`, or stay a **fixed authored identity**?

## Decision

**Do not integrate Patter with `ForgeAvatar`'s composable/customizable system.** Keep Patter a fixed authored identity.

The reasoning, in priority order:

1. **DN methodology makes Patter a fixed protagonist, not a customizable surface.** The entire pedagogical premise of the distributed-narrative method is that the cast (and the mentor) *recur* with stable identity so the kid builds a relationship with a consistent guide. A re-skinnable / re-palettable Patter directly undermines "recurring-character" — it is the precise *anti*-pattern the DN rule's § "What the cast is NOT" warns against (mascots in costumes / identity dilution). `ForgeAvatar`'s value proposition (player-customizable self-representation) is misaligned with a mentor whose value *is* its stability.

2. **`ForgeAvatar` already plays its correct role here — for the KID.** `AvatarStudioView` in `ProfileDashboardView` lets the kid express *themselves*. The kid avatar and the mentor mascot are different roles (self vs. guide); routing both through the same customization surface conflates them and dilutes both. Per `.claude/rules/forgekit.md` § "Local cosmetics still OK", app-only personalization that does **not** overlap `AvatarLayer` is fine — but Patter is not the player's avatar, so it does not belong in the `Avatar*` namespace at all.

3. **Even the smallest viable scaffold (a palette tweak) needs a design pass, and the design answer is "no".** Patter's rust palette is brand-load-bearing. Making it tunable is a brand-identity change, not a janitorial wiring round — and the brand intent (a single recognizable Conversation-Rust mentor) argues against tunability.

4. **The real near-term Patter-visual gap is orthogonal to `ForgeAvatar`.** `MentorBubbleView`'s own comment names the actual next step: *swap in the Patter illustration + wobbly tail*. That is a **fixed authored illustration** (an asset-generation request — hub owns asset gen per `.claude/rules/portfolio.md`), not a composable `AvatarConfig`. Shipping a fixed Patter portrait in the bubble delivers the visual upgrade the kid actually benefits from **without** any customization surface. An open hub handoff already exists for the related Patter app-icon PNG (`Docs/HANDOFF_TO_HUB_PATTER_APP_ICON_PNG.md`); a Patter bubble illustration is the same class of ask and the correct forward path for "make Patter look like Patter".

## Alternatives considered

| Option | What it would do | Verdict |
|---|---|---|
| **A. Route Patter through `AvatarConfig` + `AvatarStudioView`** | Make Patter a fully composable, kid-customizable avatar | **Rejected** — directly violates DN recurring-character pedagogy; conflates mentor with player self-representation; high identity-drift risk |
| **B. Palette-only tunable Patter** (smallest scaffold) | Let the kid tint Patter | **Rejected** — `DialoguePalette.rust` is brand identity; tunability is a brand change with no pedagogical upside |
| **C. Fixed Patter illustration in `MentorBubbleView`** (no `ForgeAvatar`) | Swap the SF Symbol for a bundled Patter portrait + tail | **Endorsed as the real forward path**, but it is an **asset-gen request to hub**, not a `ForgeAvatar` integration. Out of scope for this decision; file/extend a hub handoff when prioritized |
| **D. DEFER — keep Patter fixed, no customization** *(chosen)* | No code change; document the reasoning + triggers | **Chosen** — preserves DN integrity; leaves the genuinely-valuable Option C as a clean future asset request |

## Consequences

### Positive
- Patter's recurring-character identity stays intact — no drift risk introduced.
- `ForgeAvatar` keeps a single, clear role in the app (the kid's avatar), avoiding a conflated second use.
- The forward path for Patter visuals (Option C — fixed illustration) is identified and correctly routed to hub asset-gen, not mis-built as a customization surface.
- Zero code/test churn; zero new ForgeKit module dependency. ForgeKit consumed-module count unchanged.

### Negative
- Patter remains a text-bubble-with-SF-Symbol until the Option C illustration ships. (Mitigation: that gap is a hub asset-gen request, trackable independently; the bubble is fully functional + accessible today.)

### Reversibility — re-evaluate this decision if any of the following lands
- A **product decision** explicitly calls for kid-customizable mentors (currently counter to DN methodology — would require a methodology amendment, not just an engineering change).
- The portfolio ships a **mentor-avatar convention** in `ForgeAvatar` that is purpose-built for *fixed authored* mascots (distinct from player-customizable avatars) — at which point adopting it for a fixed Patter portrait could be considered.
- DialogueQuest pivots away from Pattern B (Patter-as-protagonist), which would itself be a large methodology change surfaced to the user first.

## References
- `Docs/SESSION_HANDOFF_2026-07-07_ROUND_CLOSE.md` § "Priority O (carried; explore-then-decide)"
- `.claude/rules/distributed-narrative.md` § "Hero mascot vs. cast (the protagonist question)" (Pattern B) + § "What the cast is NOT"
- `.claude/rules/forgekit.md` § "Avatar Edit Authority" + § "Local cosmetics still OK"
- `Libraries/Sources/SharedUI/Mentor/MentorBubbleView.swift` — current text-only Patter surface (Phase 2+ illustration note)
- `Libraries/Sources/AppFeature/Profile/ProfileDashboardView.swift` — canonical `AvatarStudioView` use (the KID's avatar)
- `Libraries/Sources/SharedUI/DialogueQuestTheme.swift` — `DialoguePalette.rust` (Patter's signature Conversation-Rust tint)
- `Docs/HANDOFF_TO_HUB_PATTER_APP_ICON_PNG.md` — precedent hub asset-gen ask for Patter imagery (the channel Option C would use)
