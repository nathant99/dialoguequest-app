# Handoff from Hub — Dialoguequest Book Covers (dual-tier)

Direction: **hub → app**. Per-tier book cover assets shipped to the app repo + distributed to spark-anvil-site `/books` rendering surface.

## The decision

Per `spark-anvil-hub/Docs/AUDIT_NEXT_BATCH_HANDOFF_COMPLETENESS_2026-06-19.md`: BOOK_COVERS axis had universal portfolio-wide handoff debt (only 1 of 8 audited next-batch apps + 0 of 14 math apps had filed handoff docs). Wave 6 of the 2026-06-19 round closes the handoff debt for 124 apps with shipped covers.

## What shipped

| Asset | App-repo path | Site path | Status |
|---|---|---|---|
| Tier-1 Standard cover (Blubook register; ages 9-12) | `Resources/CustomArt/dialoguequest/cover_book_standard.webp` | `spark-anvil-site/public/books/covers/dialoguequest/standard.webp` | ✅ Shipped |
| Tier-2 Advanced cover (Folio register; ages 11-14) | `Resources/CustomArt/dialoguequest/cover_book_advanced.webp` | `spark-anvil-site/public/books/covers/dialoguequest/advanced.webp` | ✅ Shipped |

Manifest at `spark-anvil-site/src/data/books-manifest.json` reports `hasStandardCover: true` + `hasAdvancedCover: true` for dialoguequest.

## Generation pipeline

- **Pipeline**: `spark-anvil-hub/scripts/gen_book_covers.py` (R-PATH-B-PROMPT-PARITY 3-block prompt)
- **Model**: Gemini Nano Banana Flash (`gemini-3.1-flash-image-preview`)
- **Style**: Per-app STYLE_REGISTRY palette + tier-specific composition (top 60% character + bottom 40% title typography + Spark & Anvil footer; per-tier register from `TIER_REGISTERS`)
- **Cost**: ~$0.09 per app (2 tiers × $0.045 Flash)

## How they're used

### Site-side (already wired)

- `/books` grid renders the standard cover as the per-app card thumbnail
- Homepage Strip 3 "Freshly Updated PDFs" can surface this app's cover artwork (no more cover-less card)
- `/books/dialoguequest-book.pdf` (Standard) + `/books/advanced/dialoguequest-book.pdf` (Advanced) ship the PDF content; covers shipped here are the artwork-axis

### App-side (optional integration)

App may surface the covers internally (in-app book viewer / library tab / cast directory hero). The covers live in `Resources/CustomArt/` ready for `Bundle.module.url(forResource: "cover_book_standard", withExtension: "webp")`. Not required for site `/books` rendering.

## Convention compliance

Per `.claude/rules/spark-anvil-website.md` § R-PATH-B-PROMPT-PARITY § "Book cover gen": the covers adopt the same 3-block prompt pattern as chapter beats + cast portraits, so the cover + portrait + beat 0 all inherit the same per-app visual register. Sister rule to R-CAST-PORTRAIT-SLUG.

## What this handoff does NOT cover

- **PDF book content** — separate ship via `render_pdf_book_typora.sh` / `render_pdf_book_puppeteer.mjs`
- **PDF rebuild** — handled per chapter authoring wave
- **App-side integration** — optional; covers live in `Resources/CustomArt/` ready for in-app surfacing

## Cross-references

- `spark-anvil-hub/Docs/AUDIT_NEXT_BATCH_HANDOFF_COMPLETENESS_2026-06-19.md` — gap audit (parent)
- `spark-anvil-hub/scripts/gen_book_covers.py` — pipeline
- `.claude/rules/spark-anvil-website.md` § R-PATH-B-PROMPT-PARITY (book cover companion)
- `.claude/rules/portfolio.md` § Asset generation ownership + handoff requirement
