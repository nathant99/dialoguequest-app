---
status: ACTIVE
date: 2026-06-23
direction: app → hub
audience: hub session owning asset-gen pipelines
intent: generate the 1024×1024 Patter source PNG that Icon Composer needs to emit DialogueQuest's 6-variant Liquid Glass `.icon` bundle
freshness-horizon: 60 days
---

# Handoff to Hub — Patter App Icon source PNG

Direction: **app → hub**. DialogueQuest needs a single 1024×1024 source PNG of **Patter** (the hero mascot) for Apple Icon Composer to derive the 6-variant Liquid Glass icon set. Per `.claude/rules/portfolio.md` § "Asset generation ownership", **hub owns ALL portfolio-wide asset generation** — apps don't run generative pipelines. Filing this so hub picks it up.

## What hub needs to ship

A single PNG file at `Resources/Art/patter_icon_source.png` in this app repo:

| Field | Value |
|---|---|
| Filename | `patter_icon_source.png` |
| Path in app repo | `Resources/Art/patter_icon_source.png` (create the directory if needed) |
| Dimensions | 1024 × 1024 |
| Format | PNG with alpha channel |
| Style register | Chunky-cartoon (Toca-Boca / Animal-Crossing) — bold `#2A1F1A` outlines, soft solid fills |

## Visual brief

Per `@Docs/IMPLEMENTATION_HANDOFF.md` § 1 and `@Docs/HANDOFF_TO_USER_APP_ICON.md`:

- **Subject**: **Patter** — a two-toned speech bubble with a wobbly tail
- **Palette**: Conversation rust `#A05A4B` (top half) + Cream `#F1E7D8` (bottom half / accent); ink-blue `#2A1F1A` outline
- **Aesthetic register**: chunky-cartoon writing-craft cluster style; same register as the LyricForge / HaikuQuest / CharacterForge / VoiceTale / MotifLab portfolio neighbors
- **Composition**: speech-bubble glyph centered + filling ~80% of the safe-area; wobbly tail anchors lower-left so the bubble reads as "in conversation"
- **Background**: cream `#F1E7D8` wash with a subtle two-character speech-bubble silhouette echoing the writing-craft register
- **No text in the icon** — Apple HIG; the wordmark lives outside the glyph

## Why hub generates this

Per `.claude/rules/portfolio.md` § "Asset generation ownership + handoff requirement" (STANDING RULE 2026-05-19):

> Hub **owns portfolio-wide asset generation — ALL asset classes, no exceptions**. Apps don't run any generative pipeline.

The matching pipeline:

| Asset class | Pipeline | Vendor | Ceiling |
|---|---|---|---|
| Mascot illustrations (icon source PNG variant) | `GUIDE_ILLUSTRATION_PIPELINE.md` (or a one-off via `gen_app_illustrations.py`) | Gemini Nano Banana Pro | ~$0.27 |

If a one-off icon-source variant doesn't fit the existing mascot-illustration pipeline cleanly, hub may either (a) generate ad-hoc via Nano Banana Pro, or (b) extend the pipeline with an `iconSource` pose variant for this app + future portfolio uses.

## What hub does NOT need to ship

- **Icon Composer-emitted `.icon` bundle** — that's user GUI work per `Docs/HANDOFF_TO_USER_APP_ICON.md`
- **Asset-catalog wiring** — same; user GUI work in Xcode
- **6 rendered variants** — Icon Composer derives them from the source PNG

## What this unblocks

The 6-variant Liquid Glass icon set for App Store submission. This is on the Phase 4 punch list:

- `@Docs/FEATURE_PLAN.md` § Phase 4: "App icon (6-variant Liquid Glass set) — filed `@Docs/HANDOFF_TO_USER_APP_ICON.md`"
- `@Docs/IMPLEMENTATION_HANDOFF.md` § 9 Definition of Done: "App icon (6-variant Liquid Glass set) — handoff to user via Icon Composer"

The user-side GUI handoff (`HANDOFF_TO_USER_APP_ICON.md`) is currently blocked-on-PNG. Once hub drops the PNG into `Resources/Art/`, the user can proceed with Icon Composer + asset-catalog wiring.

## State at this handoff's commit

- DialogueQuest branch: `main` at SHA (filled in at merge time of this PR)
- No PNG currently exists at the requested path; first time the asset is being requested
- ForgeKit pin: `from: "0.99.0"` (no upstream dep change needed for this work)

## Sequencing to unblock

1. **Hub**: pick the right pipeline (one-off Nano Banana Pro vs an `iconSource` pose extension to the mascot pipeline) and generate the PNG
2. **Hub**: distribute the PNG into `dialoguequest-app/Resources/Art/patter_icon_source.png` + file `Docs/HANDOFF_FROM_HUB_APP_ICON_SOURCE_PNG.md` confirming what shipped + cost
3. **DialogueQuest app session**: stage + commit the PNG (per the Xcode-agent-safety carve-out — PNG is non-Xcode-managed)
4. **User**: complete `Docs/HANDOFF_TO_USER_APP_ICON.md` Steps 1-3 (Icon Composer GUI work)
5. **DialogueQuest app session**: stage + commit the resulting `Assets.xcassets` diff per the Xcode-managed-files carve-out

## Cross-references

- `@Docs/HANDOFF_TO_USER_APP_ICON.md` — user-side GUI handoff (blocked on PNG)
- `@.claude/rules/portfolio.md` § "Asset generation ownership + handoff requirement"
- `@.claude/rules/liquid-glass.md` § "Icon Composer (standalone app)"
- `@.claude/rules/forgekit.md` § "ForgeBranding" — portfolio palette consistency
- `@Docs/IMPLEMENTATION_HANDOFF.md` § 1 Patter persona
- `@Docs/HANDOFF_FROM_HUB_BOOK_COVERS.md` — sister hub-shipped asset wave (style baseline reference)

## When hub completes this

Either:
- Drop the PNG into `Resources/Art/patter_icon_source.png` directly via a hub PR (preferred), OR
- File `Docs/HANDOFF_FROM_HUB_APP_ICON_SOURCE_PNG.md` with the PNG attached / referenced and the app session will stage + commit

Mark this handoff CLOSED via a status frontmatter update + cross-reference the delivery PR.
