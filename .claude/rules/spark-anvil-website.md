# Spark & Anvil Company Website

The studio brand (Spark & Anvil) ships a company website at `spark-and-anvil.com` (planned domain) that introduces parents/educators/press/kids to the 131-app portfolio.

## Scope of labsmith for the website (UPDATED 2026-05-25)

**Labsmith owns the website end-to-end.** The app-repo scope rule (labsmith ≠ implementation) does NOT apply to the website because the site is markup/content (Astro + Tailwind + TypeScript data files), not portfolio Swift app code. Per user 2026-05-25: "web site is not really code so it's okay" + "you own the website."

Labsmith owns:

- **Brand assets**: palette, typography, logo (generated 2026-05-20 to `Branding/Logo/PNG/`), brand guidelines
- **Research + plans**: `Docs/RESEARCH_SPARK_ANVIL_WEBSITE.md`, `Docs/PLAN_SPARK_ANVIL_WEBSITE.md`, `Docs/PLAN_SPARK_ANVIL_LOGO.md`, `Docs/DECISION_FIGMA_FOR_SPARK_ANVIL_WEBSITE.md`
- **Content sourcing**: per-app taglines + descriptions + curriculum mapping sourced from each app's `CLAUDE.md` and `Docs/`
- **Asset reuse choreography**: which existing per-app assets surface on the website
- **Site code itself**: Astro pages, Tailwind config, TypeScript data files, build scripts at `/Volumes/Data/Projects/GitHub/spark-anvil-site/`
- **PRs against `spark-anvil-site`**: open, ship, merge from labsmith session

Labsmith does NOT own:

- Site deployment / DNS / hosting accounts (Cloudflare Pages — user-managed)
- Production domain configuration (Cloudflare account-level)

### Workflow

When making site changes from labsmith:

1. `cd ../spark-anvil-site && git pull --ff-only` (always pull first)
2. Branch: `feature/<topic>` in the site repo
3. Edit `src/pages/*.astro`, `src/data/*.ts`, `tailwind.config.js`, etc. directly
4. `npm install` if needed; `npm run build` to verify
5. `gh pr create` + `gh pr merge --merge --delete-branch` from the site repo
6. Pair with a labsmith doc update if the change reflects a research/plan delta

### Handoff doc convention (legacy + audit trail)

`spark-anvil-site/Docs/HANDOFF_FROM_LABSMITH_*.md` docs are NO LONGER required for site work (labsmith implements directly). They MAY still be authored when:
- A major IA change deserves a durable audit-trail artifact (e.g., the Reflect-pillar 4th-modality rollout)
- The change spans multiple sessions and the next session needs a self-contained brief

If the change is small (palette tweak, copy edit, new page from existing pattern), skip the handoff doc — just ship the PR.

## Asset reuse policy

The website MUST reuse existing portfolio assets. Generation budget for website-specific assets is constrained to:

- ✅ **Brand logo** — completed 2026-05-20 (Gemini Nano Banana Pro). One-time gen.
- ❌ **Topic illustrations** — DEFERRED per user policy 2026-05-20. Site v1 uses mascots + backdrops for visual variety; topic-level illustration not needed for site-level pages.
- ❌ **Per-app screenshots** — apps not built yet. Defer to v2 after first apps ship.
- ❌ **Demo videos** — same as screenshots.
- 🟡 **Press kit downloadable bundle** — assemble from existing assets (logos + per-app icons + mascots). Composition only; no new generation.

Any other website-specific asset request requires:
1. Confirming the asset cannot be sourced from an existing app's bundle
2. User approval before generation (cost discipline per `portfolio.md` § Asset generation ownership)
3. Per-pipeline ceiling adherence (mascot ~$0.27, accessory pack ~$0.36, etc.)

## Brand asset locations

| Asset | Path | Format | Generated |
|---|---|---|---|
| Brand palette (tokens) | `Branding/Colors/spark-anvil-palette.md` | Markdown table | Pre-existing |
| Brand README (asset directory + quick reference) | `Branding/README.md` | Markdown | Pre-existing |
| Logomark (color) | `Branding/Logo/PNG/spark_anvil_logomark_v1.png` | PNG 1024×1024 | 2026-05-20 Nano Banana Pro |
| Full lockup (with wordmark) | `Branding/Logo/PNG/spark_anvil_lockup_v2.png` | PNG 1024×1024 | 2026-05-20 Nano Banana Pro |
| Logomark variants (sizes, dark/light) | `Branding/Logo/PNG/*.png` | (To export) | TODO post-v1 launch |
| Brand guidelines doc | `Branding/Guidelines/brand-usage.md` | (To author) | TODO Phase 1.3 of PLAN |

Logomark and lockup are both visually-audited and aesthetically aligned with the chunky-cartoon portfolio style (Toca-Boca / Animal-Crossing register: bold `#2A1F1A` outlines, Forge Orange + Spark Gold + Anvil Charcoal palette).

## Tech stack (locked in)

- **Static site generator**: Astro 4.x (per `DECISION_FIGMA_FOR_SPARK_ANVIL_WEBSITE.md` + `PLAN_SPARK_ANVIL_WEBSITE.md`)
- **Styling**: Tailwind CSS with token-mapped brand palette (`tailwind.config.js` defines `forge`, `anvil`, `spark`, `warm`, `slate`)
- **Hosting**: Cloudflare Pages (preferred) or Vercel
- **Analytics**: Plausible (privacy-first, no cookies, COPPA-safe)
- **Forms**: Formspree or Netlify Forms (press contact, parent feedback)
- **No third-party SDKs** — preserves the "no tracking, no kid data leaves the device" trust signal

## Design workflow (locked in)

- **No Figma for v1** — code-first; Astro + Tailwind authored via Claude Code / Cursor; iterate in browser DevTools; Cloudflare Pages preview deploys for review (per `DECISION_FIGMA_FOR_SPARK_ANVIL_WEBSITE.md`)
- Brand palette doc + logo PNGs + per-app CLAUDE.md = the spec. No parallel design artifacts.

Revisit if: designer joins team, marketing landing page needs novel composition, press-kit / Apple Design Award submission requires pixel-precision.

## Content sourcing pattern

Per-app website pages auto-populate from labsmith state:

```
spark-anvil-site/scripts/build-apps-data.mjs reads:
  ├── labsmith/Docs/<AppName>/README.md          → tagline + summary
  ├── <app>-app/CLAUDE.md                         → tech stack + safety statement
  ├── <app>-app/.../Resources/Illustrations/      → visuals
  ├── labsmith/Docs/REGISTRY_APP_HERO_COLORS.md   → per-app theming
  └── labsmith/Docs/RESEARCH_CURRICULUM_STANDARDS_MAPPING.md → curriculum chips
```

For 131 apps, the script generates 131 templated pages. Phase 3 of PLAN: manually populate 10 flagship apps first; Phase 4: bulk-generate the rest with skeleton + "Coming soon" tags for apps with insufficient assets.

## COPPA + trust signal requirements

Per 2026 FTC COPPA amendments effective April 22 2026:

- Opt-in default for ad data sharing (we don't share — one-line copy)
- Separate verifiable parental consent flows (per-app, surfaced via screenshots)
- Defined data retention periods (no indefinite storage)
- Written security program (linked policy)

Trust signals visible above-the-fold on home + `/for-parents`:
- "No ads · No in-app purchases · COPPA compliant · iOS 26 native"
- "All data on-device — nothing leaves the device"
- "No third-party SDKs / no tracking"

Per `RESEARCH_SPARK_ANVIL_WEBSITE.md`, third-party certifications (iKeepSafe COPPA, Common Sense Privacy Seal, KidSAFE) are aspirational v2+ goals — pursue once portfolio has shipping apps + revenue justifies audit fees.

## Liquid Glass policy (ADR-014, Round 149 #580, 2026-05-29)

The website adopts a **HYBRID** Liquid-Glass-inspired accent layer: chunky-cartoon brand register remains the primary visual identity; 3-5 narrowly-scoped accent surfaces use mature Glassmorphism 2.0 (semi-opaque overlay + `backdrop-filter: blur(8-16px)` + thin border). **No SVG-displacement refraction** — Chromium-only, broken on mobile Safari, GPU-expensive on school iPads. See `Docs/ADR-014_HYBRID_LIQUID_GLASS_WEBSITE.md` + `Docs/RESEARCH_LIQUID_GLASS_WEBSITE_2026-05-29.md` for the full decision + 29-source research.

**Authorized glass surfaces** (all live in `src/styles/global.css` + `src/components/Nav.astro`):

| Utility | Where | Pattern |
|---|---|---|
| Sticky top nav | `Nav.astro` | `bg-warm/85 backdrop-blur-md border-b border-anvil/10` (+ dark variant) |
| `.btn-glass` | Secondary CTAs over imagery | `bg-white/25 backdrop-blur-md border border-white/40` |
| `.card-glass` | Hero / feature overlay cards | `bg-warm/70 backdrop-blur-lg border border-warm/40 rounded-2xl` |
| `.chip-glass` | Tags / badges over hero color bands | `bg-white/30 backdrop-blur-sm border border-white/40` |

**Hard constraints**:

1. ≤ 3 concurrent active glass panels per page (2026 production guidance — `backdrop-filter` forces GPU screen-buffer copy + blur + paste; > ~50 instances crash mobile browsers)
2. Body text NEVER on glass — text sits on solid surfaces inside the glass card
3. WCAG AA contrast verified at light + dark mode + multiple scroll positions
4. `@media (prefers-reduced-transparency: reduce)` MUST collapse all glass to solid brand-palette colors
5. `@media (prefers-reduced-motion: reduce)` MUST drop any glass-morph transitions
6. Pages OFF-LIMITS to glass (always solid): `donate.astro`, `privacy.astro`, `terms.astro`, `annual-report.astro`, `for-parents.astro` body, `for-educators.astro` body, `press.astro`, `mission.astro`, `about.astro`, `board.astro`. Trust-sell + legal + long-form copy stays solid
7. Primary CTAs (`btn-primary`) stay solid — trust + max contrast

**Reversibility is HIGH** — removing the layer is a 5-line revert of `global.css` + `Nav.astro`. If field metrics surface AA failures or perf issues on school devices, revert without ceremony.

**When updating the policy**: edit `Docs/ADR-014_HYBRID_LIQUID_GLASS_WEBSITE.md` + this section + open a labsmith PR. The site itself is the implementation source of truth for the actual utility class definitions.

## DN-S chapter-book pages (Wave 1 SHIPPED 2026-06-02; spark-anvil-site PRs #104 + #105)

The site now ships **663 illustrated chapter-book pages** at `/cast/<app>/<char>` + `/stories` aggregate index. Per `Docs/PLAN_DN_S_WEBSITE_WAVE_1_2026-06-02.md` + `Docs/ADR-022_DN_S_WEBSITE_WAVE_1_OPEN_QUESTIONS.md`. Editing rules below:

### Content source-of-truth

- **DO NOT edit `spark-anvil-site/src/content/chapters/<app>/<char>.md` directly.** They are sync targets, not source. The source-of-truth is `<app>-app/Docs/dn-s/chapters/<char>.md`.
- To update chapter text: edit the app-repo chapter MD, then re-run `labsmith/scripts/sync_content_to_site.sh --app <slug> --apply`.
- The sync also distributes chapter illustrations (to `public/chapters/`) + audio M4A + VTT (to `public/audio/`).

### Astro Content Layer schema

- Schema lives at `src/content/config.ts` (Astro 4.16 content-collections API).
- **Permissive schema required**: chapter front-matter conventions vary across 663 entries; twin/cohort chapters use `primitive (X):` instead of flat `primitive:`. Use `.passthrough()` + make all non-essential fields optional. Only `character` + `app` are hard requirements.
- Astro 4.x uses `gray-matter` + `js-yaml` for front-matter parsing; **unquoted YAML values with embedded colons / markdown emphasis (`*...*`) / em-dashes fail at parse time.** `labsmith/scripts/normalize_chapter_frontmatter.py` quotes fields known to contain these (`primitive` / `role` / `register` / `audience` / `chapter-round` / `character`) in the SYNC TARGET copies only — source repos stay untouched.
- Run the normalizer after every sync: `python3 labsmith/scripts/normalize_chapter_frontmatter.py`.

### Reusable components (3 shipped; reused across #1 / #3 / #4 per ADR-022)

- `<ChapterIllustration app="..." char="..." variant="opener|spot|thumbnail" />` — consumes `public/chapters/<app>/chapter_<char>_<variant>.webp`
- `<SiblingCastStrip app="..." currentChar="..." />` — persistent-sticky on desktop / header-pinned on mobile / `prefers-reduced-motion` fallback; reads `apps.generated.ts dnCast.members`
- `<AudioDramaPlayer app="..." drama="..." characterName="..." traumaGated={...} traumaAxis={...} />` — HTML5 `<audio>` + WebVTT chapters track + inline interactive transcript with active-line highlight; vanilla JS only (no third-party SDKs; COPPA-safe); WCAG AA keyboard support

### Typography

- **Chapter prose: Lora serif** (locally hosted at `public/fonts/Lora-Variable.ttf`) per ADR-022 Q6.
- Sans-serif (site default) for chrome / infobox / nav / strips / cards.
- `chapter-body` class applies the serif + generous line-height + max-width 36rem reading column.

### Trauma-safety per-page surface (per ADR-021)

- 24 chapters across the portfolio are trauma-gated (PASS-CLEARED audits in `Docs/AUDIT_TRAUMA_GATED_AUDIO_*_2026-06-02.md`). Their pages auto-detect via `register` front-matter field (regex match on `trauma|SAMHSA|anti-shame|anti-colonial|cultural-respect|food-justice|sensory-regulation|body-image|crisis|overwhelm|panic`).
- Trauma-gated pages render: content-warning between opener illustration + body; trauma-tag in infobox; trauma-rating chip in audio player; crisis-resources footer (988 / Childhelp / Crisis Text Line).
- DO NOT remove these guardrails when editing the chapter-book template; ADR-021 enforces them as load-bearing for the trauma-axis carve-out.

### Audio sibling files (per ADR-022 Q2)

- App repos bundle `.caf` (iOS-native, app-bundled only).
- Site `public/audio/<app>/` requires `.m4a` (web-distribution; universal browser support) + `.vtt` (WebVTT chapters + transcript).
- `labsmith/scripts/gen_dn_s_audio_drama.py --apply` now emits all three; legacy CAFs need backfill via `afconvert -f m4af -d aac -b 64000 -c 1 <input>.caf <output>.m4a` + VTT placeholder (better: re-gen).

### Build performance (post Wave 1b)

- 828 total site pages built in ~28s on Astro 4.16 (663 dynamic chapter routes + /stories + existing 24 site pages).
- Static output mode preserved per existing `astro.config.mjs` lock-in; no SSR adapter added.
- Build-time content-collection load handles 663 entries cleanly with the permissive schema.

## Cross-references

- `Docs/RESEARCH_SPARK_ANVIL_WEBSITE.md` — research synthesis (~2026-05-20 web search + competitive analysis)
- `Docs/RESEARCH_LIQUID_GLASS_WEBSITE_2026-05-29.md` — Liquid Glass website research synthesis (Round 149 #580; 29 sources)
- `Docs/ADR-014_HYBRID_LIQUID_GLASS_WEBSITE.md` — hybrid Liquid Glass accent adoption decision
- `Docs/PLAN_SPARK_ANVIL_WEBSITE.md` — 7-phase Astro build plan, 3-week v1 launch
- `Docs/PLAN_SPARK_ANVIL_LOGO.md` — logo design plan (Concept C selected)
- `Docs/DECISION_FIGMA_FOR_SPARK_ANVIL_WEBSITE.md` — no Figma for v1
- `.claude/rules/liquid-glass.md` — native iOS 26 Liquid Glass APIs (portfolio-side; distinct from web-side hybrid policy above)
- `Branding/` — brand asset directory
- `Docs/REGISTRY_APP_HERO_COLORS.md` — per-app theming source
- `Docs/RESEARCH_CURRICULUM_STANDARDS_MAPPING.md` — curriculum chips source
- `Docs/DESIGN_BRAND_ARCHITECTURE.md` — brand architecture rules (must apply across portfolio + website)
- `Docs/PLAN_DN_S_WEBSITE_WAVE_1_2026-06-02.md` — Wave 1 implementation plan (8-stage; mostly shipped 2026-06-02)
- `Docs/ADR-022_DN_S_WEBSITE_WAVE_1_OPEN_QUESTIONS.md` — Wave 1 decisions (8 questions resolved)
- `Docs/RESEARCH_DN_S_WEBSITE_INTEGRATION_NEXT_STEPS_2026-06-02.md` — Wave 1 research foundation (24 sources)
- `Docs/AUDIT_DN_S_6_PILLAR_FINAL_2026-06-02.md` — DN-S 6-pillar coverage baseline + chapter-book content source
- `labsmith/scripts/sync_content_to_site.sh` — chapter/audio/illustration distribution from app repos
- `labsmith/scripts/normalize_chapter_frontmatter.py` — YAML normalizer for synced chapter MDs
<!-- END LABSMITH-SYNCED CONTENT -->
