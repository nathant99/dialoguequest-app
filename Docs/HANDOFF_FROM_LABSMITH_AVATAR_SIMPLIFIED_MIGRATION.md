# Handoff from Labsmith — Avatar system simplified (Contacts-style)

Direction: **labsmith → app**. ForgeAvatar's composable chunky-cartoon avatar system has been replaced with a simplified Contacts-style design (tint circle + initial / SF Symbol / emoji glyph + optional per-app themed glyph override). Per ADR-022 (**ACCEPTED 2026-06-02** — founder ACK). **ForgeKit 1.0.0-rc.1 SHIPPED 2026-06-02** — tag pushed, 29 ForgeAvatarTests + 103 ForgeSyncTests green, API conforms to spec exactly. CQ + CubeSensei sessions are now UNBLOCKED to execute their per-app migration handoffs. This handoff is distributed to every app repo as a heads-up; the **action required** column below tells each app what (if anything) it needs to do.

> **Canonical artifact**: `labsmith/Docs/ADR-022_AVATAR_SIMPLIFIED_CONTACTS_STYLE.md` — read this first for the full rationale + alternatives considered + 12-color palette spec + per-app themed glyph protocol.

## TL;DR

| If your app... | Action required |
|---|---|
| Already imports `ForgeAvatar` (currently: **cubesensei**, **curiosityquest**) | **Active now**. ForgeKit 1.0.0-rc.1 is tagged. Execute the per-app migration handoff: `Docs/HANDOFF_FROM_LABSMITH_AVATAR_MIGRATION.md` (CQ PR #217, CubeSensei PR #131 — already in your repo) |
| Has a planned-adoption row in `labsmith/Docs/AUDIT_AVATAR_STUDIO_ADOPTION_RANKS_5_20_2026-05-28.md` but hasn't integrated yet (~30 apps) | **Adopt directly against 1.0.0-rc.1.** Don't adopt the pre-1.0 composable API. Schema spec is in `forgekit/Docs/HANDOFF_FROM_LABSMITH_AVATAR_1_0_RC_1_SCHEMA.md` |
| Has not yet touched ForgeAvatar | **No action**. This is FYI only. When you do adopt the avatar, you'll get the simplified API directly |
| Shipped M9 themed accessory bundles (~62 apps, including yours if `Resources/CustomArt/<your-app>/avatar_accessories.json` exists OR `Resources/AvatarShared/accessories/*.webp` exists in your bundle) | **Cleanup available**. The accessory bundles are now dark code (no `AvatarAssetCatalog` in 1.0-rc.1). Safe to `git rm` whenever; a follow-up portfolio sweep handoff will batch-clean these |

## What's changing

### Old API (deprecated in ForgeKit 1.0.0-rc.1)

```swift
// 10+ field config with anchor / accessory / frame / background IDs + 3 tint hex
let config = AvatarConfig(
    skinToneIndex: 3,
    hairColorHex: "#3B2410",
    outfitColorHex: "#4A6FA5",
    eyesColorHex: "#33271E",
    backgroundID: "sunrise_gradient",
    frameID: "gold_round_frame",
    accessoryIDs: ["scarf_winter_red", "round_glasses_gold"]
)

// Rendered via:
AvatarRenderer(config: config, catalog: catalog, size: 100)
```

### New API (lands in ForgeKit 1.0.0-rc.1)

```swift
public nonisolated struct AvatarConfig: Codable, Sendable, Equatable, Hashable {
    public let tintColorHex: String   // one of 12 palette swatches
    public let glyph: AvatarGlyph     // .initial / .symbol / .emoji
}

public nonisolated enum AvatarGlyph: Codable, Sendable, Equatable, Hashable {
    case initial(Character)           // derived from displayName
    case symbol(String)               // SF Symbol from curated 30-set
    case emoji(String)                // Unicode from curated 30-set
}

// Rendered via:
AvatarRenderer(config: config, size: 100)   // No catalog parameter; pure SwiftUI
```

### Per-app themed glyph override (NEW)

If your app wants to express character through the avatar (e.g., **cubesensei** showing a Rubik's cube glyph instead of generic `.symbol("cube.fill")`), conform to:

```swift
public protocol AvatarThemedGlyphProvider: Sendable {
    func themedGlyph(for config: AvatarConfig, in context: AvatarRenderContext) -> AnyView?
}
```

Register your provider at app launch:

```swift
ForgeAvatarRegistry.shared.register(provider: CubeSenseiThemedGlyphProvider())
```

- The provider is consulted FIRST; if it returns `nil`, the renderer falls back to the portfolio glyph
- Themed glyphs are app-local (stored in your app's SwiftData if you want a state-tracked override; ephemeral if just a render replacement)
- Themed glyphs do NOT propagate via `AppGroupStore.forgeID.avatar` — they're additive personalization, not cross-app identity

See ADR-022 for example providers + the 12-color palette spec.

## What's being deleted from ForgeKit 1.0.0-rc.1

- `AvatarLayer` enum + `AvatarLayer.anchorRect` extension
- `AvatarAssetCatalog` actor (108 WebPs no longer needed)
- `AvatarRenderer.tintedLayerImage` + the layer compositing pipeline
- `AvatarSpriteNode` (SpriteKit version of the old renderer)
- `Resources/AvatarBase/`, `Resources/AvatarLayers/`, `Resources/AvatarShared/{accessories,frames}/` (108 WebP files, ~10–15 MB)
- `Resources/AvatarShared/backgrounds/` — kept for now in case any app uses these for a non-avatar surface

## Migration for currently-integrating apps (cubesensei + curiosityquest)

**Phase 1 — ForgeKit 1.0.0-rc.1 — ✅ SHIPPED 2026-06-02**. Tag pushed; SHIPPED handoff at `forgekit/Docs/HANDOFF_FROM_FORGEKIT_AVATAR_1_0_RC_1_SHIPPED.md`.

**Phase 2 — Per-app migration PR** (execute now):

1. Update `Libraries/Package.swift` to pin `from: "1.0.0-rc.1"` (or `branch: "main"` if you're on tracking-main)
2. Find your `AvatarConfig` construction sites — `grep -r "AvatarConfig(" Packages/Libraries/Sources/`. Replace each with the simplified two-field init
3. Find your `AvatarRenderer` call sites — drop the `catalog:` parameter
4. Find your `AvatarAssetCatalog` references — delete them entirely
5. If you have a per-app `AvatarConfigAdapter` (bridges your local persistence struct to `AvatarConfig`) — simplify or delete it. Recommended: store `AvatarConfig` directly in SwiftData (no bridge struct)
6. **SwiftData migration**: detect old `ComposableAvatarConfig` records on launch, reset to default `AvatarConfig` with a deterministic-color default. Pre-launch — wipe acceptable, no real user data at risk
7. If you want app-themed glyphs: implement `AvatarThemedGlyphProvider` + register at app launch
8. Visual smoke test: edit avatar → save → confirm Howdy card / profile / wherever-you-display shows the new style
9. Build clean; zero warnings; commit + PR + merge
10. File `Docs/HANDOFF_FROM_APP_AVATAR_SIMPLIFIED_MIGRATION_SHIPPED.md` to close the loop

**Estimated effort per app**: 1 day (mostly migration + smoke test; the rendering code is trivial vs. the old compositor)

## Migration for planned-adopter apps

If your `Docs/IMPLEMENTATION_HANDOFF.md` references ForgeAvatar adoption but you haven't started integration:

- **Defer until ForgeKit 1.0.0-rc.1 ships**. Adopting the old composable API now means doing the migration above immediately after
- When you do adopt, use the new API directly; your integration is simpler than the current cubesensei/curiosityquest paths

## Migration for M9-accessory-only apps

If your repo has `Resources/CustomArt/<your-app>/avatar_accessories.json` or `Resources/AvatarShared/accessories/*.webp` but you never adopted `ForgeAvatar.AvatarRenderer`:

- The accessory bundle goes dark. No code references it. **No action needed**
- A follow-up portfolio-wide sweep (labsmith script) may `git rm` the obsolete files once ForgeKit 1.0.0-rc.1 ships. If you want them gone sooner, run `rm -rf Resources/CustomArt/<your-app>/AvatarAccessories Resources/AvatarShared/accessories` yourself + commit

## Why this change

Founder direct 2026-06-02: "scrap this complicated avatar design and go a simple avatar design like Apple Contacts app, and somehow let individual app choose appropriate theme too if possible, like cubesensei could have rubik's cube as avatar for example."

Backing context: the previous composable design hit a structural blocker — image generation models (Gemini Nano Banana Pro / Imagen 4) don't reliably produce transparent backgrounds, so the 108-WebP bundled-asset pipeline kept producing rendering bugs (founder screenshot CDAAA247, 2026-06-01). Three rounds of fixes (PRs #134/#135/#208/#210/#211/#214/#215) couldn't resolve it because the root cause is gen-pipeline reliability, not asset content. Full rationale + alternatives considered in `labsmith/Docs/ADR-022_AVATAR_SIMPLIFIED_CONTACTS_STYLE.md`.

## Cross-references

- `labsmith/Docs/ADR-022_AVATAR_SIMPLIFIED_CONTACTS_STYLE.md` — canonical decision
- `labsmith/Docs/AUDIT_AVATAR_STUDIO_ADOPTION_RANKS_5_20_2026-05-28.md` — planned-adopter list
- `forgekit/Docs/CHANGELOG.md` — will document the 1.0.0-rc.1 schema break when shipped
- `labsmith/.claude/rules/forgekit.md` § Avatar Edit Authority — to be updated by follow-up ADR-023

## Status

- [x] Labsmith authored ADR-022 (PROPOSED)
- [x] Founder ACK on ADR-022 → ACCEPTED 2026-06-02
- [x] ForgeKit 1.0.0-rc.1 SHIPPED 2026-06-02 (tag pushed; SHIPPED handoff filed)
- [ ] cubesensei + curiosityquest migrate (Phase 2 above)
- [ ] Labsmith files SHIPPED handoff per app
- [ ] Follow-up `ADR-023_AVATAR_EDIT_AUTHORITY_SIMPLIFIED.md` collapses the lite/full editor distinction
