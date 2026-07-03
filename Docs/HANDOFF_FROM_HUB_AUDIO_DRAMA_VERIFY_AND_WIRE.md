# Handoff from Hub — Audio dramas: relocate → bundle → wire (`dialoguequest`)

Direction: **hub → app**. Portfolio-wide codification of the FractionForge audio-drama wiring resolution (2026-07-02→03). Hub **stages** drama assets at repo-root `Resources/AudioDramas/<app>/`, but that path **ships in nothing**. Three states — **staged ≠ bundled ≠ wired** — and hub delivery only reaches "staged." This handoff is the per-app checklist to reach "wired."

## Why this exists

FractionForge wired audio dramas first and found: repo-root `Resources/` is a distribution **staging mirror** (outside `Libraries/`, so no `Bundle.module` sees it; not in the app target's synchronized group, so not in `Bundle.main` either). A drama left there plays in nothing. The reference impl relocated the assets under the SPM target + `.copy("AudioDramas")` + wired `AudioDramaPlayer`. See `fractionforge-app/Libraries/Sources/AppFeature/AudioDramaSupport.swift`.

## THIS app's current status (filesystem scan at distribution time)

- **Staged at repo-root `Resources/AudioDramas/dialoguequest/`:** ✅ 7 `.caf` staged
- **Relocated into an SPM target (`.copy("AudioDramas")`):** ❌ NOT relocated — staging assets ship in no bundle
- **`AudioDramaPlayer` wired:** ❌ NOT wired — no `AudioDramaPlayer(` render site

### ⚠️ Gaps 1–3 open — dramas are STAGED but ship in nothing.

The `.caf`/`.m4a`/`.vtt`/`catalog.json` sit at repo-root `Resources/AudioDramas/` — outside every SPM target, so they're in no bundle. Do **Gap 1** (relocate + `.copy`), **Gap 2** (catalog adapter), **Gap 3** (wire), per the checklist below. This is the ~140-app remediation class.

## The 3-gap remediation checklist (per R-AUDIO-DRAMA-BUNDLE-AND-WIRE)

**Gap 1 — relocate to a bundled SPM location.** Move `Resources/AudioDramas/dialoguequest/` → `Libraries/Sources/<Target>/AudioDramas/dialoguequest/` (`<Target>` = your primary UI target, e.g. `AppFeature`), then in `Package.swift`:
```swift
resources: [.process("Resources"), .copy("AudioDramas")],
```
Use **`.copy` (NOT `.process`)** — `.copy` preserves the `AudioDramas/dialoguequest/` subdirectory that `ForgeAudio.AudioDramaPlayer.resolveBundleURL` expects; `.process` flattens it to the bundle root (the cast-portrait/audio flatten-gotcha class). Keep it a **sibling to `Resources/`** so it doesn't double-match `.process("Resources")`. **Delete the stale repo-root staging copy after relocating** (don't let it rot — see the Cast 5-vs-10 drift anti-pattern).

**Gap 2 — catalog decode.** The hub `catalog.json` is **not** directly `Codable` into ForgeAudio's `AudioDramaCatalog` (hub `chapters[]` are per-line TTS timing markers; ForgeAudio wants navigable `{title, startSeconds, skipSummary}`; there's no `AudioDramaCatalog.load(from:)`). Until the hub-side fix lands (`forgekit/Docs/HANDOFF_FROM_HUB_AUDIODRAMA_CATALOG_SCHEMA.md`), decode a lightweight shape + construct `AudioDrama` with a synthesized opener chapter — copy the adapter from `fractionforge-app/.../AudioDramaSupport.swift`. **Trauma-gated apps:** the synthesized-single-chapter shortcut loses skip-to-chapter (a required off-ramp) — prefer waiting for / requesting the native catalog before wiring.

**Gap 3 — wire the player.** `AudioDramaPlayer(bundle: .module, dramaCatalog:)` + a "Listen to the audio drama" surface gated to catalog membership + an availability badge on the cast surface + off-ramps (skip ±15s / stop; trauma-gated add skip-to-chapter + `OutputModerationService.canPlay`). Consumer audit: `grep -rl 'AudioDramaPlayer(' Sources/ Libraries/ Packages/` must return a real render site. Add a bundling test asserting every catalog `bundlePath` resolves in `Bundle.module` (see `fractionforge-app` `AudioDramaCatalogTests`).

All of the above is **app-side Swift/Package.swift** — hub owns asset gen + staging delivery, never app implementation code.

## Scope boundary

Audio-drama-only. Cast **chapters** are a website + PDF surface by default (synced to `spark-anvil-site/cast/<app>/<char>`); if you also want an in-app chapter reader, that's a separate app-feature decision (FractionForge did it via `.copy("Chapters")` — same relocate pattern). Missing dramas for any cast member are a separate hub asset-gen request (script authoring + paid TTS), tracked as the drama axis of `R-CAST-EXPANSION-INTEGRATION`.

## Cross-references

- `.claude/rules/audio-pipeline.md` § R-AUDIO-DRAMA-BUNDLE-AND-WIRE — the canonical rule
- `fractionforge-app` — reference impl (`AudioDramaSupport.swift`, `Package.swift` `.copy("AudioDramas")`, `AudioDramaCatalogTests`)
- `forgekit/Docs/HANDOFF_FROM_HUB_AUDIODRAMA_CATALOG_SCHEMA.md` — the Gap 2 catalog-schema fix
- `.claude/rules/portfolio.md` § Asset Consumer Audit — bundled ≠ wired parent rule
- `forgekit/Sources/Client/ForgeAudio/{AudioDrama,AudioDramaPlayer}.swift` — consumer types
