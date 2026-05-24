# Implementation Handoff — Companion Pack PDFs

This app repo's `Resources/CompanionPack/` was bundled by the labsmith companion-pack PDF pipeline (queue #332, per `Docs/RESEARCH_STORYTIME_LEARNING_GENERALIZATION.md` § 5.4). This doc tells the implementing Claude Code session what's in the bundle, how to surface it in-app, and how to keep it in sync with the website.

## What's in `Resources/CompanionPack/`

```
Resources/CompanionPack/
├── coloring.pdf         # 4-up cast portrait line-art coloring sheets + cover
├── puzzle_sampler.pdf   # 6 representative kit-01 questions + answer key
├── cast_poster.pdf      # 6-up grid of cast portraits + names + roles
├── parent_letter.pdf    # 1-page mission-first intro from the AI mentor
└── companion_pack.json  # Manifest
```

Each PDF is letter-size (US Letter / 8.5 × 11 in), kid-and-parent print-friendly, ~5-200 KB except `coloring.pdf` and `cast_poster.pdf` which embed raster portrait art (~0.3-5 MB).

**Manifest schema** (`companion_pack.json`):

```json
{
  "app": "{appname}",
  "format": "pdf",
  "source": "labsmith scripts/build_companion_pack.py (queue #332)",
  "spec": "Docs/RESEARCH_STORYTIME_LEARNING_GENERALIZATION.md § 5.4",
  "pdfs": ["cast_poster.pdf", "coloring.pdf", "parent_letter.pdf", "puzzle_sampler.pdf"],
  "count": 4,
  "loading_hint": "Print-friendly PDFs for in-app share-to-Files / AirPrint and /apps/<slug> downloads."
}
```

## Why these exist

The pedagogical insight (from § 5 of the research): Storytime Chess's commercial moat is **the same cast appears on every learning surface — in-app, in print workbooks, in coloring books, in posters, in classroom curriculum**. Spark & Anvil already has the cast (586 portraits live across 108 apps as of 2026-05-23) and the question kits (~55K questions across ~138 apps). The companion-pack PDFs are the print + screen-free reinforcement layer — free, downloadable, AirPrint-able from the app, distributable in district pilots.

The PDFs MUST stay free, MUST carry the 501(c)(3) non-profit (pending) framing in headers/footers, and MUST NOT include third-party tracking or analytics URLs.

## How to surface in-app (recommended)

Add a **"For Parents & Educators"** section inside the app — typically reachable from the Settings tab or from the AdventureHub-style parent surface. The section presents the four PDFs as tappable cards:

```swift
// Pseudocode — adopt your app's design tokens
struct CompanionPackView: View {
    let app: AppData  // your app's identity (slug, name, heroColor)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CompanionPDFCard(
                    title: "Coloring Sheets",
                    description: "Print and color the cast",
                    pdf: "coloring.pdf",
                    icon: "paintpalette.fill"
                )
                CompanionPDFCard(
                    title: "Puzzle Sampler",
                    description: "6 puzzles to print and solve with a pencil",
                    pdf: "puzzle_sampler.pdf",
                    icon: "puzzlepiece.fill"
                )
                CompanionPDFCard(
                    title: "Cast Poster",
                    description: "Meet the cast — print and hang on the wall",
                    pdf: "cast_poster.pdf",
                    icon: "person.3.fill"
                )
                CompanionPDFCard(
                    title: "Parent Letter",
                    description: "A note about what your child is learning",
                    pdf: "parent_letter.pdf",
                    icon: "envelope.fill"
                )
            }
        }
        .navigationTitle("For Parents & Educators")
    }
}
```

Each card, when tapped, should:

1. Load the PDF via `Bundle.module.url(forResource: name, withExtension: "pdf")` (the resource lives in whichever target owns `Resources/CompanionPack/` — typically `SharedUI` or `AppFeature`)
2. Present a `ShareLink` so the parent can save to Files, AirDrop, or AirPrint
3. Optionally render an inline preview via SwiftUI `QuickLookPreview`

**Do NOT** parse the PDF — these are leaf assets, treat them as opaque blobs.

## Package.swift setup

The PDFs land alongside other bundled resources (illustrations, cast portraits, audio). Treat them like any other `.process` resource:

```swift
.target(
    name: "SharedUI",
    dependencies: [
        .product(name: "ForgeUI", package: "forgekit"),
    ],
    resources: [
        .process("Resources/CompanionPack"),
        .process("Resources/Cast"),
        // ... other resources
    ]
)
```

## Asset consumer audit (required per `.claude/rules/portfolio.md`)

Per the 2026-05-20 standing rule, **registered ≠ wired**. Before closing this handoff:

1. Grep your app's `Sources/` for at least one consumer call site:
   ```bash
   grep -rE 'companion_pack|CompanionPack|companion-pack' <app>/Packages/Libraries/Sources/
   ```
2. Zero hits = **shipped-but-dark**. File a follow-up task to wire `CompanionPackView` (or equivalent) into the app's navigation BEFORE marking the handoff CLOSED.
3. Recommended consumer surfaces:
   - Settings → "For Parents & Educators" → 4 cards
   - Optional: in-app "Print this!" button after a kit completion
   - Optional: surface on first-launch parent handoff

## Regeneration

These PDFs are NOT hand-authored — they're generated from labsmith state (cast portraits + kit JSONs + apps.generated.ts metadata). To regenerate:

```bash
cd /Volumes/Data/Projects/GitHub/labsmith
python3 scripts/build_companion_pack.py --app {appname}
./scripts/copy_companion_pack_to_repos.sh --app {appname} --apply
```

Triggers for regeneration:
- Cast portraits regenerated (new chars, refresh wave)
- Kit-01 content changed materially
- App's `dnCast.intro` or mentor name changed
- Spark & Anvil branding refresh (palette / typography)
- Mission-statement / 501(c)(3) language change

## Known limitations

1. **Line-art conversion quality** — characters with very dark hair or backgrounds (~5-10% of portraits across the portfolio) come out with partly-filled black regions on the coloring sheet. The character is still recognizable and partially colorable. Future improvement: switch to potrace + SVG conversion for cleaner outlines (deferred — not blocking).
2. **No kit-01 = no puzzle sampler** — some board-game-shaped apps (GambitTales, MotifLab, StoneSong, GeneralsTale) don't have a question-kit JSON in labsmith. Their puzzle_sampler.pdf is absent. Future: extend `build_companion_pack.py` to consume custom puzzle sources for board-game apps.
3. **Single page sizes only** — letter-only for v1. A4 variants are a future enhancement when international school pilots begin.
4. **No localization** — English only for v1. The PDF text + mentor letter are static; localized variants are out of scope until the portfolio adopts portfolio-wide localization.
5. **No screenshots in PDFs** — apps without shipping App Store screenshots can't include them. Reserve for v2.

## Definition of Done for this handoff

- [ ] All 4 PDFs render in your local build (test via `xcrun simctl` or device)
- [ ] At least one `CompanionPackView` consumer is wired into the app's navigation
- [ ] Each card surfaces a working `ShareLink` (test AirDrop + Save to Files)
- [ ] Print quality verified on a real printer (or at least a high-quality digital preview)
- [ ] No third-party URLs / analytics — only spark-and-anvil.com links

## Cross-references

- `labsmith/Docs/RESEARCH_STORYTIME_LEARNING_GENERALIZATION.md` § 5 — full research grounding
- `labsmith/scripts/build_companion_pack.py` — generator
- `labsmith/scripts/copy_companion_pack_to_repos.sh` — distributor
- `.claude/rules/portfolio.md` § "Asset generation ownership" — standing rule that requires this handoff doc
- `.claude/rules/distributed-narrative.md` — DN methodology; cast IS the curriculum
