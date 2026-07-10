# Spark & Anvil Company Website

The studio brand (Spark & Anvil) ships a company website at `spark-and-anvil.com` (planned domain) that introduces parents/educators/press/kids to the 131-app portfolio.

## Scope of hub for the website (UPDATED 2026-05-25)

**Hub owns the website end-to-end.** The app-repo scope rule (hub ≠ implementation) does NOT apply to the website because the site is markup/content (Astro + Tailwind + TypeScript data files), not portfolio Swift app code. Per user 2026-05-25: "web site is not really code so it's okay" + "you own the website."

Hub owns:

- **Brand assets**: palette, typography, logo (generated 2026-05-20 to `Branding/Logo/PNG/`), brand guidelines
- **Research + plans**: `Docs/RESEARCH_SPARK_ANVIL_WEBSITE.md`, `Docs/PLAN_SPARK_ANVIL_WEBSITE.md`, `Docs/PLAN_SPARK_ANVIL_LOGO.md`, `Docs/DECISION_FIGMA_FOR_SPARK_ANVIL_WEBSITE.md`
- **Content sourcing**: per-app taglines + descriptions + curriculum mapping sourced from each app's `CLAUDE.md` and `Docs/`
- **Asset reuse choreography**: which existing per-app assets surface on the website
- **Site code itself**: Astro pages, Tailwind config, TypeScript data files, build scripts at `/Volumes/Data/Projects/GitHub/spark-anvil-site/`
- **PRs against `spark-anvil-site`**: open, ship, merge from hub session

Hub does NOT own:

- Site deployment / DNS / hosting accounts (Cloudflare Workers — user-managed)
- Production domain configuration (Cloudflare account-level)

### Production domains — `.com` + `.org` both serve (R-SITE-DOMAINS; 2026-07-09)

**Both `spark-and-anvil.com` AND `spark-and-anvil.org` MUST resolve to the live site, serving identical content.** Codified per user-direct 2026-07-09 (*"spark-and-anvil.org should work the same as spark-and-anvil.com too"*).

- **Canonical host:** `spark-and-anvil.com` — Astro `site:` in `astro.config.mjs`, so sitemap / RSS / canonical `<link>` all point at `.com`. `.org` serves the same content; its canonical tags still point to `.com` (single-canonical for SEO — avoids duplicate-content penalties).
- **Implementation (zero code change):** the site is fronted by the `spark-anvil-dispatcher` Worker (ADR-032), which routes purely by URL **path** and is **host-agnostic** — so `.org` serves identically the moment the domain is attached. Account-level (user-managed): add `spark-and-anvil.org` (+ `www.spark-and-anvil.org`) as additional **Custom Domains** on `spark-anvil-dispatcher`.
- **Optional (NOT required):** to force a single visible hostname, add a 301 in the dispatcher — `if (new URL(request.url).hostname.endsWith("spark-and-anvil.org")) return Response.redirect(canonicalUrl, 301)`. Default is serve-identically (no redirect), which satisfies "work the same."
- **Ownership:** attaching the `.org` domain + DNS is account-level (user); the dispatcher code + this policy are hub-owned.

### Workflow

When making site changes from hub:

1. `cd ../spark-anvil-site && git pull --ff-only` (always pull first)
2. Branch: `feature/<topic>` in the site repo
3. Edit `src/pages/*.astro`, `src/data/*.ts`, `tailwind.config.js`, etc. directly
4. `npm install` if needed; `npm run build` to verify
5. `gh pr create` + `gh pr merge --merge --delete-branch` from the site repo
6. Pair with a hub doc update if the change reflects a research/plan delta

### Handoff doc convention (legacy + audit trail)

`spark-anvil-site/Docs/HANDOFF_FROM_HUB_*.md` (canonical 2026-06-11+) or `HANDOFF_FROM_LABSMITH_*.md` (legacy) docs are NO LONGER required for site work (hub implements directly). They MAY still be authored when:
- A major IA change deserves a durable audit-trail artifact (e.g., the Reflect-pillar 4th-modality rollout)
- The change spans multiple sessions and the next session needs a self-contained brief

If the change is small (palette tweak, copy edit, new page from existing pattern), skip the handoff doc — just ship the PR.

## Web-app clones must keep feature parity with their iOS app (R-WEB-CLONE-PARITY; 2026-07-08)

**A browser learning-app clone of a portfolio iOS app (the `/play/<app>/*` route tree — FractionForge is the first, `/play/fractionforge`) MUST maintain feature parity with that app's LEARNING-RELEVANT features, UNLESS a specific delta is EXPLICITLY WAIVED with a documented rationale in the app's parity ledger.** Parity is the default; every gap is either closed or explicitly justified — never silently dropped. Codified per user-direct 2026-07-08 (*"codify the requirement that fractionforge iOS app and web page need to have feature parity unless explicitly allowed not to"*).

### What "feature parity" covers (and what it doesn't)

Parity is measured on **learning-relevant + pedagogy-load-bearing** surfaces, NOT pixel-identical UI:

- **IN scope (must reach parity or be waived):** the curricular manipulatives / scene modes, the question/kit content, the scaffolding discipline (articulate-before-hint / PolyaScaffold), the DN-S cast + narrative surfacing, co-op / pass-and-play modes, the engagement loop (streak / weekly challenge / boss-encounter / mastery gating), progress + mastery tracking, accessibility, and the anti-shame + narrative-placement disciplines (`R-NARRATIVE-BETWEEN-NOT-DURING` / `R-GUARD-THE-RATIO`).
- **OUT of scope (never a parity obligation):** native-only affordances (SpriteKit particle polish, haptics, Live Activities, Widgets, App Intents/Siri, Game Center), platform chrome, and exact visual styling. A web-native equivalent of a native affordance satisfies parity (e.g. SVG manipulative ≈ SpriteKit manipulative; a linked site chapter reader ≈ an in-app reader).

### The parity ledger (required artifact)

Each web-clone app maintains a parity ledger — `spark-anvil-hub/Docs/PARITY_<APP>_WEB_VS_IOS.md` — enumerating every in-scope iOS feature → web status, one of:

| Status | Meaning |
|---|---|
| ✅ **parity** | Present + equivalent on the web |
| 🔄 **adapted** | Present via a web-native equivalent (note the adaptation) |
| 🟡 **gap** | Missing on the web + NOT yet waived → open work item (must be tracked in the work queue) |
| ⛔ **waived** | Deliberately not built on the web, WITH a one-line rationale (see below) |

A 🟡 gap is a defect against this rule; a ⛔ waiver is compliant. The distinction is the documented rationale.

### What counts as a valid waiver

A delta may be waived (⛔) only for a concrete reason, recorded inline in the ledger. Canonical valid rationales:

- **On-device / COPPA guardrail** — a feature that would require a server, accounts, or off-device data collection is auto-waivable under the site's on-device posture (e.g. classroom sharing / Google Classroom / cross-device sync / global leaderboards). This is the strongest waiver and takes precedence over parity.
- **Platform-only affordance** — the out-of-scope list above (haptics, Widgets, Siri, Game Center, etc.).
- **Founder-direct** — the user explicitly approves a specific delta.

"It was more work" is NOT a valid waiver — that's a 🟡 gap (a tracked work item), not a ⛔ waiver.

### The bidirectional-backport rule (R-CLONE-BIDIRECTIONAL-BACKPORT; strengthened 2026-07-08)

**Parity is SYMMETRIC and backport is MANDATORY in BOTH directions. If EITHER surface has a learning-relevant feature the other lacks, that feature MUST be backported to the other surface — unless the delta is EXPLICITLY WAIVED with a documented rationale in the parity ledger.** Codified per user-direct 2026-07-08 (*"codify the requirement that if the web app has a feature that the ios app doesn't have, that feature has to be backported to the ios app and vice versa unless it's explicitly allowed not to."*). This UPGRADES the former soft "note it / the iOS session can *consider* back-porting" to a hard obligation identical in force to the iOS→web direction. A web-only (or iOS-only) learning-relevant feature that is neither backported nor waived is a **defect** against this rule, tracked as a 🟡 gap.

The parity ledger is the single symmetric record for both directions; when EITHER surface gains a learning-relevant feature, the ledger MUST be updated **in the same cycle** and the delta **closed (backported) or explicitly waived**:

- **iOS ships a new mode / mechanic / cast member / engagement feature** → ledger gains a 🟡 gap row (a web work item, closed by hub — hub owns the web) OR a ⛔ waiver. Hub implements the web backport directly.
- **Web ships a new learning-relevant feature the iOS app lacks** → ledger gains a 🟡 gap row (an **iOS backport work item**) OR a ⛔ waiver. **Because hub NEVER writes Swift / iOS app source (the single most load-bearing repo rule), hub discharges the iOS-direction obligation by FILING A HANDOFF** — `<app>-app/Docs/HANDOFF_FROM_HUB_<FEATURE>_WEB_BACKPORT.md` — that specifies the feature + the web reference impl + the proposed iOS surface, for the iOS app's OWN Claude Code session to implement. The gap row stays 🟡 (open) until the iOS session ships it back (a `HANDOFF_FROM_APP_*_SHIPPED` return closes the row to ✅/🔄). Hub filing the handoff is the *start* of the obligation, not its completion — "handoff filed ≠ backported," mirroring "authored ≠ integrated."

Same waiver criteria as § "What counts as a valid waiver" apply in BOTH directions: on-device/COPPA guardrail · platform-only affordance · founder-direct. Platform-native equivalents are ⛔/🔄, not 🟡 (e.g. the PWA offline install is a *web-native* affordance whose iOS equivalent is the OS's native offline execution — already satisfied, so ⛔ waived, not an iOS backport gap). "It's only on one surface because that's where we built it" is NOT a waiver — that's a 🟡 gap (a tracked backport item).

The `R-CAST-EXPANSION-INTEGRATION` "authored ≠ integrated" discipline (`.claude/rules/distributed-narrative.md`) is the sibling pattern one axis over: there, a new cast member opens per-axis integration debt; here, a new feature on either surface opens a cross-surface backport gap. Both are "the ship isn't done until every downstream surface is closed or explicitly waived."

### When this rule applies

- Authoring or extending any `/play/<app>` web clone.
- Auditing a web clone for completeness — enumerate the ledger; every 🟡 gap is a work item, every ⛔ needs a rationale.
- Any iOS-app round that adds a learning-relevant feature to an app that HAS a web clone — update the clone's ledger (hub-side; the iOS session need not) and close the web gap or waive it.
- **Any web-clone round that adds a learning-relevant feature the iOS app lacks** → add a 🟡 iOS-backport gap row to the ledger in the same cycle AND file `<app>-app/Docs/HANDOFF_FROM_HUB_<FEATURE>_WEB_BACKPORT.md` for the iOS session (or record a ⛔ waiver). The row closes only when the iOS session ships the backport (R-CLONE-BIDIRECTIONAL-BACKPORT).

### Cross-references

- `Docs/PARITY_FRACTIONFORGE_WEB_VS_IOS.md` — the first/reference parity ledger
- `Docs/PLAN_FRACTIONFORGE_WEB_CLONE_2026-07-08.md` + `Docs/RESEARCH_FRACTIONFORGE_WEB_CLONE_2026-07-08.md` — the web-clone design
- `Docs/AUDIT_FRACTIONFORGE_PORTFOLIO_LIFT_2026-07-08.md` — the iOS feature inventory the ledger measures against
- `.claude/rules/distributed-narrative.md` § R-CAST-EXPANSION-INTEGRATION — sibling "authored ≠ integrated" discipline
- § "Web-app clone" scope above (hub owns the web; `/play/*` is a learning app distinct from the marketing site)

## Web-clone user + developer guides must track the code (R-WEB-CLONE-GUIDE-SYNC; 2026-07-08)

**Every `/play/<app>` web clone has TWO living guides that MUST be updated in the SAME change-set as any code change that affects what they document — a visitor-facing USER guide and a maintainer-facing DEVELOPER guide.** A code change that lands without the matching guide update is incomplete, exactly like a cross-repo PR that ships without verifying the merge. Codified per user-direct 2026-07-08 (*"codify the requirement that user guide and developer guide for the web clone of fractionforge be kept up-to-date with the web clone code"*). Follows the precedent set by the `/cast` page guides (`GUIDE_CAST_PAGE_USER.md` + `GUIDE_CAST_PAGE_DEVELOPER.md`).

### The two guides (per web-clone app)

| Guide | Path | Audience | Register |
|---|---|---|---|
| **User guide** | `spark-anvil-hub/Docs/GUIDE_<APP>_WEB_USER.md` | Parents / educators / kids (ages 9-14 readable) | Warm, non-jargon (per § R-SITE-CHROME register discipline — no engineering terms, file paths, ticket numbers) |
| **Developer guide** | `spark-anvil-hub/Docs/GUIDE_<APP>_WEB_DEVELOPER.md` | The next maintainer session | Architecture + data flow + file map + load-bearing rules + extension recipes + gotchas + test/verify plan |

### The sync obligation (what "track the code" means)

A change is guide-affecting — and therefore MUST carry the matching guide edit in the same commit/PR — when it:

- **User guide** — adds/removes/renames a mode or screen, changes how a learner does something (controls, keyboard, flow), changes what data is stored or the privacy posture, or changes any user-visible label the guide names.
- **Developer guide** — adds/removes/renames a file or module, changes the data model or kit schema, changes the build/port pipeline, adds a manipulative mode or a new island, changes a load-bearing rule the guide cites, or introduces a gotcha the next maintainer needs.

Trivial changes (a copy typo, a CSS tweak that doesn't change behavior) don't require a guide edit — the bar is "does this change what the guide asserts?", the same bar the multi-beat-snapshot / register rules use.

### When this rule applies

- Authoring or extending any `/play/<app>` web clone → the guide-affecting parts of the diff pair with a guide edit.
- Reviewing a web-clone PR → check the diff against both guides; a guide-affecting change with no guide edit is a defect.
- The parity ledger (`R-WEB-CLONE-PARITY`) and the developer guide overlap intentionally: the ledger tracks iOS↔web feature deltas; the dev guide tracks how the web code is built. Update both when a feature lands.

### Cross-references

- `Docs/GUIDE_FRACTIONFORGE_WEB_USER.md` + `Docs/GUIDE_FRACTIONFORGE_WEB_DEVELOPER.md` — the first/reference web-clone guides
- `Docs/GUIDE_CAST_PAGE_USER.md` + `Docs/GUIDE_CAST_PAGE_DEVELOPER.md` — the two-guide precedent this rule generalizes
- § R-WEB-CLONE-PARITY (above) — sibling web-clone completeness rule
- § R-SITE-CHROME (in `.claude/rules/distributed-narrative.md`) — the register discipline the USER guide follows

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
- **Hosting**: Cloudflare Workers (static assets, via Workers Builds Git integration; migrated from Cloudflare Pages)
- **Analytics**: Plausible (privacy-first, no cookies, COPPA-safe)
- **Forms**: Formspree or Netlify Forms (press contact, parent feedback)
- **No third-party SDKs** — preserves the "no tracking, no kid data leaves the device" trust signal

## Design workflow (locked in)

- **No Figma for v1** — code-first; Astro + Tailwind authored via Claude Code / Cursor; iterate in browser DevTools; Cloudflare Workers per-version preview deploys for review (per `DECISION_FIGMA_FOR_SPARK_ANVIL_WEBSITE.md`)
- Brand palette doc + logo PNGs + per-app CLAUDE.md = the spec. No parallel design artifacts.

Revisit if: designer joins team, marketing landing page needs novel composition, press-kit / Apple Design Award submission requires pixel-precision.

## Content sourcing pattern

Per-app website pages auto-populate from hub state:

```
spark-anvil-site/scripts/build-apps-data.mjs reads:
  ├── spark-anvil-hub/Docs/<AppName>/README.md          → tagline + summary
  ├── <app>-app/CLAUDE.md                         → tech stack + safety statement
  ├── <app>-app/.../Resources/Illustrations/      → visuals
  ├── spark-anvil-hub/Docs/REGISTRY_APP_HERO_COLORS.md   → per-app theming
  └── spark-anvil-hub/Docs/RESEARCH_CURRICULUM_STANDARDS_MAPPING.md → curriculum chips
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

**When updating the policy**: edit `Docs/ADR-014_HYBRID_LIQUID_GLASS_WEBSITE.md` + this section + open a hub PR. The site itself is the implementation source of truth for the actual utility class definitions.

## DN-S chapter-book pages (Wave 1 SHIPPED 2026-06-02; spark-anvil-site PRs #104 + #105)

The site now ships **663 illustrated chapter-book pages** at `/cast/<app>/<char>` + `/stories` aggregate index. Per `Docs/PLAN_DN_S_WEBSITE_WAVE_1_2026-06-02.md` + `Docs/ADR-022_DN_S_WEBSITE_WAVE_1_OPEN_QUESTIONS.md`. Editing rules below:

### Content source-of-truth

- **DO NOT edit `spark-anvil-site/src/content/chapters/<app>/<char>.md` directly.** They are sync targets, not source. The source-of-truth is `<app>-app/Docs/dn-s/chapters/<char>.md`.
- To update chapter text: edit the app-repo chapter MD, then re-run `spark-anvil-hub/scripts/sync_content_to_site.sh --app <slug> --apply`.
- The sync also distributes chapter illustrations (to `public/chapters/`) + audio M4A + VTT (to `public/audio/`).

### Astro Content Layer schema

- Schema lives at `src/content/config.ts` (Astro 4.16 content-collections API).
- **Permissive schema required**: chapter front-matter conventions vary across 663 entries; twin/cohort chapters use `primitive (X):` instead of flat `primitive:`. Use `.passthrough()` + make all non-essential fields optional. Only `character` + `app` are hard requirements.
- Astro 4.x uses `gray-matter` + `js-yaml` for front-matter parsing; **unquoted YAML values with embedded colons / markdown emphasis (`*...*`) / em-dashes fail at parse time.** `spark-anvil-hub/scripts/normalize_chapter_frontmatter.py` quotes fields known to contain these (`primitive` / `role` / `register` / `audience` / `chapter-round` / `character`) in the SYNC TARGET copies only — source repos stay untouched.

### CRITICAL: Normalizer auto-runs in site `prebuild` — do NOT remove (2026-06-04 regression-pattern lift)

**The normalizer is wired into `spark-anvil-site/package.json` `prebuild`** so every build (local OR Cloudflare Workers Builds) self-heals from YAML drift. **Never remove the normalizer call from the prebuild chain** — doing so re-opens the regression class below.

```jsonc
"prebuild": "bash scripts/lint-ios-caps.sh && python3 scripts/normalize-chapter-frontmatter.py && node scripts/build-cast-manifest.mjs && ..."
```

**Regression pattern** — codified after two consecutive Cloudflare-deploy failures (PR #160 fix → sync re-broke it → PR #162 final fix, 2026-06-04 evening):

1. Hub sync writes fresh chapter MDs from `<app>-app/Docs/dn-s/chapters/` → `spark-anvil-site/src/content/chapters/`.
2. Source chapters use unquoted YAML (`primitive: CAESAR SHIFT — *the simplest cipher: shift every letter by N.*` — embedded `:` after "cipher" trips js-yaml).
3. Local Astro dev may not surface the bug if cached; Cloudflare's fresh-clone build always re-parses → fails with `incomplete explicit mapping pair; a key node is missed`.
4. Point-in-time normalizer runs fix the symptom but the NEXT sync re-introduces the drift.

**The auto-run prebuild is the only durable fix.** Running the normalizer once-per-sync is racy against any sync landing between that run and the build.

**Two copies of the normalizer exist + are intentional**:
- `spark-anvil-hub/scripts/normalize_chapter_frontmatter.py` — source of truth; canonical implementation
- `spark-anvil-site/scripts/normalize-chapter-frontmatter.py` — in-repo mirror (path-relative; works on Cloudflare's `/opt/buildhome/repo`) so the build agent doesn't clone hub

When the normalizer's quoting rules change, **update BOTH copies in the same change-set**. The site copy resolves `CHAPTERS_ROOT` from `__file__` so it works in any environment; otherwise it's byte-for-byte identical to hub's.

**When in doubt — run the normalizer**: it's idempotent. Re-running on already-normalized YAML produces zero diff.

**Companion sync rule for hub-side workflow**: when authoring a new chapter or rewriting an existing one, do NOT pre-quote the source MD's YAML — leave the unquoted convention. The prebuild normalizer is responsible for quoting the sync-target copy. This preserves authoring ergonomics on the hub side while keeping the site build resilient.

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
- `spark-anvil-hub/scripts/gen_dn_s_audio_drama.py --apply` now emits all three; legacy CAFs need backfill via `afconvert -f m4af -d aac -b 64000 -c 1 <input>.caf <output>.m4a` + VTT placeholder (better: re-gen).

### Build performance (post Wave 1b)

- 828 total site pages built in ~28s on Astro 4.16 (663 dynamic chapter routes + /stories + existing 24 site pages).
- Static output mode preserved per existing `astro.config.mjs` lock-in; no SSR adapter added.
- Build-time content-collection load handles 663 entries cleanly with the permissive schema.

### R-SITE-BUILD-QUIET-PRERENDER — the build looks hung but isn't (2026-06-29)

**The site has since grown to ~9000+ routes on the `@astrojs/cloudflare` HYBRID adapter, and a full `rm -rf dist && npm run build` now takes ~12-20 min.** The phase after the log line `building client (vite) ✓ N modules transformed` is SILENT — Astro emits no further stdout while it **generates the prerendered route HTML (~8.5 min of Rollup route-gen)** and copies the entire `public/` tree (chapters + cast + audio + books = thousands of files) into `dist/`. During this phase the PARENT node process sits at **0.0% CPU** (a child worker does the work at low, I/O-bound CPU).

> **Correction (V56, 2026-07-09):** an earlier version of this note claimed most routes (cast/cluster) are **SSR, not prerendered**, living in `_worker.js` with `find dist -name '*.html'` near 0. **That is wrong.** The site is `output:"hybrid"` (prerender-by-default), every dynamic tree uses `getStaticPaths()`, and **no page sets `prerender=false`** — so essentially **everything is PRERENDERED** (verified: the live `/cast/…` page returns `cf-cache-status: HIT`, a cached static asset, not a `DYNAMIC` Worker-SSR response; `AUDIT_SITE_PRERENDER_SURFACE_2026-07-09.md`). Consequently `find dist -name '*.html'` **climbs to thousands** as the build progresses — it does NOT stay near 0. The "looks hung but isn't" guidance below is still exactly right; only the SSR-vs-prerender mechanism was mis-attributed. Use `find dist -type f | wc -l` (below), which works regardless.

**DO NOT kill the build because the log is quiet, the parent shows 0% CPU, or there's no HTML yet.** All three are normal. The definitive "working vs hung" test is whether `find dist -type f | wc -l` is GROWING over ~15-20s:

```bash
a=$(find dist -type f|wc -l); sleep 15; b=$(find dist -type f|wc -l); echo "$a -> $b"
```

If it's climbing (even ~50-100 files/15s), the build is fine — wait for it. Only suspect a real hang if the file count is flat for several minutes AND no child node proc shows any CPU. **Reference incident (2026-06-29 ELA wave):** a build was killed + restarted twice on the false belief it had hung at "10 modules transformed"; each was actually prerendering/copying normally. Net waste ~20 min. Verify growth before ever killing a site build.

## Build-disk budget + R2 media hosting (R-SITE-BUILD-DISK-BUDGET + R-SITE-MEDIA-R2; 2026-06-30)

**The site build has a finite disk budget, and heavy media committed into `public/` is the thing that blows it.** Codified after a 2026-06-30 Cloudflare `ENOSPC: no space left on device` build failure (during Astro `staticBuild` → `generatePath`, writing prerendered HTML). Work-queue § "V28 P0 — Cloudflare Pages build FAIL: ENOSPC".

### Why it happens (the doubling)

Cloudflare **clones the whole git repo** (media included), then Astro **copies the entire `public/` tree into `dist/`** during build, then writes prerendered HTML for the ~9000 routes. Peak build disk ≈ `repo (public/) + dist/ copy of public/ + node_modules + generated HTML`. When `public/` is multiple GB, the copy alone doubles it and the container runs out of disk.

Measured 2026-06-30: `public/` ≈ **4.7 GB** — `public/chapters` 2.5 GB (742 chapter `.m4a` = 2.0 GB + 3716 beat `.webp` = 0.54 GB), `public/audio` 1.4 GB (audio dramas), `public/books` 0.77 GB (PDFs). **`.m4a` audio is 3.4 GB of the 4.7 GB — the dominant cost.** Every cast-expansion wave (each chapter = 5 beat WebPs + a narration `.m4a` + portrait) pushes the budget up; this is a growth cliff, not a one-off.

### R-SITE-MEDIA-R2 — heavy binary media belongs on R2, and the `git rm` is the load-bearing step

**R2 IS already provisioned** (`cdn.spark-and-anvil.com`; ADR-031 for PDFs, § V18 P1 for audio). The code-side is done: `src/lib/{audio-url,pdf-url}.ts` resolve to the CDN when `PUBLIC_AUDIO_CDN_URL` / `PUBLIC_PDF_CDN_URL` are set; `scripts/upload_{audio,pdfs}_to_r2.py` push to the bucket; the audio players consume the helpers. **The 2026-06-30 ENOSPC recurrence was NOT "we don't have R2" — it was that the local copies were never removed from `public/` (964 audio m4a + 742 chapter-narration m4a + 244 PDFs still git-tracked).**

**THE LOAD-BEARING LESSON: uploading to R2 + adding env-gated URL indirection does NOTHING for build disk. Cloudflare clones the whole repo and Astro copies `public/` into `dist/` regardless of where the runtime serves from. A media R2 migration is ONLY complete when the files are `git rm`'d out of `public/`.** Leaving them gives runtime CDN serving but zero build-disk relief — exactly the trap that recurred here.

The target split:
- **On R2 (removed from the repo):** `.m4a` audio (chapter narration `public/chapters/**/*_chapter.m4a` + audio dramas `public/audio/`) + book `.pdf` (`public/books/`). Large, binary, never Astro-processed — serve only.
- **Stay in-repo `public/`:** small per-page assets — beat `.webp` (image pipeline + gates depend on local presence), cast portrait `.webp` (R-CAST-PORTRAIT-SLUG CI check needs them local), `.vtt`, `.beats.json`, snapshot `.md`.

**Completing / re-verifying the migration (the checklist that was skipped):**
1. Confirm the surface is uploaded to R2 (`upload_audio_to_r2.py` / `upload_pdfs_to_r2.py` ran for it).
2. Confirm `PUBLIC_AUDIO_CDN_URL` + `PUBLIC_PDF_CDN_URL` are set in the Cloudflare Workers env (Production **and** Preview) — else the site 404s after removal.
3. `git rm` the local copies: `git rm -r public/audio public/books` + `git rm public/chapters/**/chapter_*_chapter.m4a public/chapters/**/chapter_*_chapter.vtt`.
4. Grep for any unconditional local-path reference (`/audio/`, `/books/`, `_chapter.m4a`) that bypasses the URL helper — there must be none.
5. Verify `du -sh public` dropped (audio+PDF removal → ~4.7 GB → ~0.6 GB).

**Ownership split:** account-level (R2 bucket, custom domain, Pages env vars) is user-managed; the upload + `git rm` + helper wiring is hub-side. Beat-`.webp` migration (V18 P1 § Tier 2) is a separate, higher-complexity effort — do NOT bundle it with the audio/PDF `git rm`.

### R-SITE-BUILD-DISK-BUDGET — watch the number every content wave

- Before a large content wave, check `du -sh spark-anvil-site/public` and `du -sh public/*`. Treat **`public/` > ~4 GB** as the danger zone until the R2 `git rm` completes; **> ~5 GB** risks ENOSPC on Cloudflare.
- The single biggest lever is `.m4a` audio. New audio-bearing chapters are the fastest way to grow the budget.
- **Never** re-encode or delete shipped audio to save space without user approval (destructive to a shipped surface).
- Interim mitigations if a deploy is blocked before R2: (1) lower audio bitrate (48 kbps mono) — destructive, needs approval; (2) prune verified-orphaned dirs (`public/pilot`, `public/companion-pack`) — small; (3) pause new audio-bearing content. None substitute for R2.

### Cross-references

- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § "V28 P0 — Cloudflare Pages build FAIL: ENOSPC" — the incident + full fix plan
- § R-SITE-BUILD-QUIET-PRERENDER (above) — sibling build-behavior note (the same `public/`-copy phase that overflows here is the one that looks "hung")
- `.claude/rules/spark-anvil-website.md` "Tech stack" / "Hub does NOT own" — R2 bucket + DNS are user-managed; hub owns the code-side migration

## Distribute ≠ upload: audio must reach R2 in the same wave (R-R2-AUDIO-UPLOAD-COMPLETENESS; 2026-07-03)

**The site serves EVERY chapter-narration + audio-drama `.m4a` from Cloudflare R2 (`cdn.spark-and-anvil.com`), NOT from the repo. A content wave that distributes a chapter but forgets to push its `.m4a` to R2 ships a SILENT production 404 — the audio player renders (its `.vtt` is committed) but the audio fails to load, with ZERO build-time signal.** This is the load-bearing companion to R-SITE-MEDIA-R2: that rule says "`git rm` the `.m4a` out of `public/`"; THIS rule says "…but only AFTER it is verified on R2." The two together are the complete discipline; doing the `git rm` without the upload is the exact defect this rule exists to prevent.

### Why it's invisible (the trap)

Nothing catches a missing-from-R2 `.m4a` at build time. The R2-aware build gates (multibeat-snapshot / audio-drama) **skip local `.m4a` entirely** when `PUBLIC_AUDIO_CDN_URL` is set (which it is, on Cloudflare Prod+Preview), precisely so they don't false-fail on the R2-migrated files. So a `.vtt`-present / `.m4a`-absent-from-R2 chapter passes every gate and deploys green — then 404s the audio in production. The only detector is an explicit R2-coverage audit.

### Reference incident (2026-07-03)

A CDN + R2-bucket diff found **141 chapter `.m4a` returning 404 live** — essentially every cast-expansion wave's new-member narration (Math V24 / ELA V25 / Science D-1 / SEL Wave 1) that was distributed around/after the 2026-06-30 ENOSPC `git rm` (site PR #340) but never uploaded to R2. Science Wave 2 was the only wave that had uploaded (it did so by hand). **136 were RECOVERABLE** (local source `.m4a` still in `Resources/PilotsAndExperiments/**` → re-staged into `public/` + `upload_audio_to_r2.py` + pruned); **5 were NEEDS-REGEN** (fractionforge Tier-2 `-advanced` — never generated; a separate paid-TTS gen wave). Full write-up: `Docs/AUDIT_R2_UPLOAD_COVERAGE_2026-07-03.md`.

### The rule

1. **Every wave that distributes narration `.m4a` MUST upload it to R2 in the SAME wave, and verify.** `distribute_cast_chapters.py` now does this by default: it uploads via `upload_audio_to_r2.py` then prunes the local `.m4a` from `public/` (keeping the small committed `.vtt`). It **fails loud** if R2 creds are absent and does NOT prune — so a wave can never again silently leave audio un-uploaded. `--no-r2` is an explicit escape hatch that prints a warning.
2. **Creds live in `~/.r2-env.sh`** (mode 600, auto-sourced from `~/.zshrc`): `R2_ENDPOINT` / `R2_ACCESS_KEY_ID` / `R2_SECRET_ACCESS_KEY` (+ `PUBLIC_AUDIO_CDN_URL` / `PUBLIC_PDF_CDN_URL` for local build-gate parity). Bucket `spark-anvil-books`. `source ~/.r2-env.sh` before any upload; run uploads with a `python3` that has `boto3` (`python3 -m pip install --user boto3` if missing — the sandbox Xcode python 3.9 needs it installed once). NEVER commit the creds file. **Bootstrap (fresh env):** if `~/.r2-env.sh` is absent, the user drops the Cloudflare R2 API token at `~/Downloads/r2.txt` (labels `Access Key ID` / `Secret Access Key` / `Endpoint`); build the env file by parsing that (don't retype secrets) + `chmod 600`.
3. **Verify with the auditor** after any audio-bearing wave — and periodically as a portfolio backstop: `source ~/.r2-env.sh && /usr/bin/python3 scripts/audit_r2_upload_coverage.py --verify-cdn 5`. Zero RECOVERABLE gaps = clean. It classifies MISSING into RECOVERABLE (re-upload) vs NEEDS-REGEN, prints a `--recover-list` stage+upload recipe, and `--ci-mode` exits non-zero on any recoverable gap.
4. **`.vtt` stays in `public/` (committed); `.m4a` lives ONLY on R2.** Never commit `.m4a` under `public/chapters/` (R-SITE-MEDIA-R2). If you stage `.m4a` locally to run an upload, delete them after: `find ../spark-anvil-site/public/chapters -name '*_chapter.m4a' -delete`.

### Gotchas

- **CDN bot-block on non-browser UAs**: `cdn.spark-and-anvil.com` returns **403** (not 200) to `urllib`'s default user-agent — a false signal. Use `curl -I` or send a browser UA (the auditor's `--verify-cdn` does). A 403 from a bare script is almost always this, not a real permission problem.
- **404 caching**: Cloudflare may briefly cache a prior 404; after an upload, allow a few seconds and re-HEAD before concluding it failed.
- **App+char-aware source resolution**: chapter slugs collide across apps (`surge`, `chain`, `hush`, `sort` exist in multiple apps). When locating a local source `.m4a`, match on BOTH `<app>` dir AND `<char>` filename — a filename-only index picks the wrong app's audio.

### Cross-references

- `Docs/AUDIT_R2_UPLOAD_COVERAGE_2026-07-03.md` — the 141-gap incident + remediation
- `scripts/audit_r2_upload_coverage.py` — the detector (expected-from-`.vtt` vs R2-bucket diff + local-source classification)
- `scripts/distribute_cast_chapters.py` — now uploads-then-prunes by default (the source-side fix)
- `scripts/upload_audio_to_r2.py` — canonical uploader
- § R-SITE-MEDIA-R2 (above) — the `git rm` half of the discipline; this rule is the upload half
- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § "V29 — Full audit of the R2 audio/PDF uploads" — the queued ask this closes

## Wave-runner idempotency is `.vtt`-present, NOT `.m4a`-present (R-WAVE-RUNNER-R2-IDEMPOTENCY; 2026-07-08)

**A chapter-audio wave runner's "already shipped?" skip-check MUST treat a chapter as shipped when EITHER the local site `.m4a` exists OR the committed site `.vtt` exists — NEVER a bare `[ -f "$site_m4a" ]`.** Post-`R-SITE-MEDIA-R2` the chapter-narration `.m4a` is pruned from `spark-anvil-site/public/` and lives ONLY on R2, so a local-`.m4a`-only test fails for **every** already-shipped chapter, and the runner **over-regenerates all of them** — burning paid Gemini TTS, overwriting the shipped R2 audio take, and desyncing the committed `.vtt` (line-cue timings drift against the new take). This is the idempotency companion to R-SITE-MEDIA-R2 (which does the `git rm`) and R-R2-AUDIO-UPLOAD-COMPLETENESS (which does the upload): those two rules jointly make the `.m4a` R2-only, so the `.vtt` — which STAYS committed — is the durable proxy for "this chapter shipped."

### Why it's the right signal

`.vtt` and `.m4a` are a matched pair emitted by the same gen (`pilot_interleaved_ensemble_chapter.py`). The `.vtt` stays in `public/chapters/<app>/` (committed) precisely because the audio player needs it locally; the `.m4a` goes to R2 only. So `.vtt`-present is a zero-cost, always-available proxy that a chapter's narration was generated + shipped. Confirmed bitten twice: V29 (T1 regens) + V40 (fractionforge T2 — the runner over-regen'd `dot`, was reverted, and the wave had to be hand-run per-sidecar to dodge the bug).

### The corrected contract (both runners)

`path_b_wave_runner.sh` (T1) and `path_b_tier2_audio_wave_runner.sh` (T2) share an `already_shipped <local-m4a> <committed-vtt> <cdn-m4a-url>` helper:

- local `.m4a` present ⇒ shipped (skip) — pre-migration / not-yet-pruned case
- `.vtt` present (no local `.m4a`) ⇒ shipped (skip) — the R2-migrated case (default)
- `--verify-r2` flag ⇒ when only the `.vtt` is present, HEAD the CDN (browser UA — the CDN 403s bare UAs per R-R2-AUDIO-UPLOAD-COMPLETENESS § Gotchas) for certainty before skipping; regen if the HEAD is not 2xx
- neither present ⇒ regen

`--verify-r2` is opt-in (one HTTP HEAD per chapter). `CDN_BASE` defaults to `https://cdn.spark-and-anvil.com`, overridable via `PUBLIC_AUDIO_CDN_URL`.

### When this rule applies

- Any NEW or edited chapter-audio wave runner, or any script that decides "regen vs skip" for a chapter whose `.m4a` may be R2-only.
- Do NOT re-introduce a bare `[ -f "$site_m4a" ]` skip-check anywhere in the gen pipeline.
- A per-sidecar targeted gen (V40's recipe) is still fine for one-off single-chapter regens; this rule fixes the BATCH runners so they no longer need the targeted-gen dodge.

### Cross-references

- `scripts/path_b_wave_runner.sh` + `scripts/path_b_tier2_audio_wave_runner.sh` — the `already_shipped()` helper
- § R-SITE-MEDIA-R2 (the `git rm`) + § R-R2-AUDIO-UPLOAD-COMPLETENESS (the upload) — the two rules that make the `.m4a` R2-only, which is what makes `.vtt`-present the correct proxy
- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § V41 — the queued ask this closes; § V40 — the incident recipe-correction

## R2 is the system-of-record for audio — it MUST be backed up off-R2 (R-R2-SYSTEM-OF-RECORD; 2026-07-07)

**Because R-SITE-MEDIA-R2 `git rm`'d the chapter-narration + audio-drama `.m4a` out of `spark-anvil-site/public/`, Cloudflare R2 (`spark-anvil-books`) is the SYSTEM-OF-RECORD for that audio — not a rebuildable cache. R2 has no automatic backup; a bucket deletion / corruption / accidental lifecycle purge would lose the exact shipped audio take with no one-command restore. Therefore every R2-only `.m4a` MUST have a byte-identical copy committed off-R2 (GitHub).** Codified after the V32 P0 backup audit (`Docs/AUDIT_ASSET_BACKUP_COVERAGE_2026-07-06.md`) proved 0 permanent-loss orphans but surfaced 744 `.m4a` (717 chapter-narration + 27 dramas) whose only copy was on R2 — regenerable from committed text via paid Gemini TTS (~$75–150, and a DIFFERENT voice take with drifted VTT), which is a lossy fallback, **not** a backup.

### Why "regenerable from committed text" is NOT a backup

The source text (chapter MD / drama script) being committed makes the audio *recoverable in content* but not *in fact*: re-running TTS produces a new take with different prosody + re-timed VTT cues. The shipped `.m4a` + its committed `.vtt` are a matched pair; a re-gen breaks that pairing. So committed-text ≠ backed-up-audio. Treat R2 audio as authoritative binary that needs its own durable copy.

### The two-layer backup discipline (both belong; neither alone is complete)

| Layer | What | Owner | Covers |
|---|---|---|---|
| **1. Hub byte-backup (load-bearing)** | Commit the R2-only `.m4a` into the hub repo at `Resources/R2AudioBackup/<r2-key>` (mirrors the R2 key path so restore = re-upload at the same key). The hub is NOT Cloudflare-built, so R-SITE-MEDIA-R2's ENOSPC constraint does NOT apply here (same reason the 139 pilot `.m4a` are already committed). | **Hub** — fully executable, no account access | The R2-only `.m4a` set (byte-identical) |
| **2. Whole-bucket off-site sync + versioned archive (belt-and-suspenders)** | `scripts/sync_r2_to_backup.sh` = `rclone sync spark-anvil-books → <store>` with `--backup-dir` (the script owns the exact flags): keeps a FRESH mirror of the source AND moves every overwritten/deleted object into a timestamped archive. So the live mirror tracks the source, no accidental source-delete removes the only copy, and every superseded version is retained — the pull-based equivalent of the object versioning R2 lacks. **RUNNING 2026-07-08** to a local archive (`/Volumes/Data/Backups/r2/spark-anvil-books`, 3,824 objects / 7.97 GiB, verified 0 diffs) on a **daily launchd schedule** (`com.spark-anvil.r2-backup`, 03:00) via `scripts/r2_backup_cron.sh`. | **Account-level, user-managed** (hub owns the *scripts*; the destination store + creds are user-managed — per "Hub does NOT own") | The WHOLE bucket incl. the 3,060 already-git-backed + 265 PDFs; protects against bucket-level deletion |

> **⚠ R2 has NO native object versioning (verified 2026-07-07).** Both `PutBucketVersioning`/`GetBucketVersioning` are **unimplemented** in R2's S3 API (the 2022 `GetBucketVersioning` is a dummy stub returning S3's "not enabled" default); there is **no dashboard toggle**. Version history is instead provided **pull-side** by layer 2's `--backup-dir` archive (every overwrite/delete is preserved under a run timestamp). An in-R2 alternative, if ever wanted, is **Event Notifications → Cloudflare Queue → a consumer Worker** that copies each changed/deleted object into a backup bucket with a version-suffixed key — an optional account/Worker-side build, not required given layers 1 + 2.

**The `git rm` in R-SITE-MEDIA-R2 stays** — this rule does NOT reverse it. `public/` (the Cloudflare-built tree) stays `.m4a`-free for build-disk; the backup lives in the **hub** repo (`Resources/R2AudioBackup/`), which Cloudflare never clones or copies into `dist/`. The two rules are orthogonal: R-SITE-MEDIA-R2 governs the *site* tree; R-R2-SYSTEM-OF-RECORD governs *durability* via the *hub* tree.

### The discipline going forward

1. **Every audio-bearing wave that uploads new `.m4a` to R2 MUST also add the byte-copy to `Resources/R2AudioBackup/`** — in the same wave, exactly as R-R2-AUDIO-UPLOAD-COMPLETENESS requires the R2 upload itself. The two rules chain: distribute → upload-to-R2 (R-R2-AUDIO-UPLOAD-COMPLETENESS) → byte-backup-to-hub (this rule).
2. **`scripts/backup_r2_audio_to_hub.py`** pulls the current R2-only `.m4a` set (idempotent: skips size-matching files already present) and refreshes `Resources/R2AudioBackup/MANIFEST.json` (key + size + md5). Run it after any audio wave, and periodically as a portfolio backstop.
3. **`scripts/audit_asset_backup_coverage.py --ci-mode`** is the backstop detector — it now counts `Resources/R2AudioBackup/` as a committed binary source, so a newly-uploaded-but-not-yet-backed-up `.m4a` classifies 🟠 REGENERABLE-TTS (not ✅) and `--ci-mode` exits non-zero. Wire it into audio-wave round-close alongside `audit_r2_upload_coverage.py`.
4. **Off-site sync (running):** `scripts/sync_r2_to_backup.sh` (`--backup-dir` versioned mirror) runs daily via the `com.spark-anvil.r2-backup` launchd agent (`scripts/r2_backup_cron.sh`; log `~/Library/Logs/r2-backup.log`). The current destination is a **local** archive on the same machine — for off-machine durability, point `RCLONE_DST` at a second R2 bucket / B2 / NAS (user-provisioned). The in-R2 Event-Notifications→Queue→Worker pattern remains an optional alternative.

### Cross-references

- `Docs/AUDIT_ASSET_BACKUP_COVERAGE_2026-07-06.md` — the audit that surfaced the 744 + ranked the recs this rule codifies
- `scripts/backup_r2_audio_to_hub.py` — hub byte-backup (layer 1)
- `scripts/sync_r2_to_backup.sh` — whole-bucket off-site sync recipe (layer 2; user runs)
- `scripts/audit_asset_backup_coverage.py` — the `--ci-mode` backstop detector
- § R-SITE-MEDIA-R2 — the `git rm`-from-`public/` rule this one is orthogonal to (site tree vs hub tree)
- § R-R2-AUDIO-UPLOAD-COMPLETENESS — the upload-to-R2 half; this rule adds the backup-off-R2 half
- `.claude/rules/spark-anvil-website.md` "Tech stack" / "Hub does NOT own" — R2 bucket + off-site-sync destination + DNS are user-managed (R2 has no native versioning to configure)

## Cast portrait slug convention (R-CAST-PORTRAIT-SLUG; 2026-06-05)

**The portrait file at `spark-anvil-site/public/cast/<app>/<char>.webp` MUST match the chapter MD filename slug at `src/content/chapters/<app>/<char>.md`.** Both are the same `<char>` token. This is load-bearing because chapter pages at `/cast/<app>/<char>` render `<img src="/cast/<app>/<char>.webp">` with no fallback; Astro static-build doesn't verify `<img src>` targets, so a slug mismatch ships as a silently-broken portrait link with no build-time error.

### Why the rule exists (2026-06-05 user report)

User-reported "a lot of cast characters with broken links for portrait images on the website" surfaced 48 of 754 chapter pages (6.4%) rendering broken `<img>` against missing files. Root cause: slug-mismatch between chapter MD filenames and portrait WebP filenames in 5 distinct patterns:

| Pattern | Where | Example chapter slug → portrait slug |
|---|---|---|
| **A. Underscore vs dash** | adventurehub / generalstale / stonesong | `archivist_atlas.md` ↔ `archivist-atlas.webp` |
| **B. `the-` prefix on portraits** | cardforge / dealtales | `bluffer.md` ↔ `the-bluffer.webp` |
| **C. Role-suffix descriptor on portraits** | chanceforge / discretequest / mythforge / ratiorealm | `display.md` ↔ `display-the-picture-maker.webp` |
| **D. App-repo `cast_<char>_<pose>` convention** | quillspell | `ember.md` ↔ `cast_ember_demonstrating.webp` |
| **E. Accent stripping** | cipherforge | `vigenere.md` ↔ `Vigenère` name in registry → `vigen-re.webp` from naive slugify |

Phase A + B remediation shipped via spark-anvil-site PR #175 (33 renames + 2 syncs; coverage 93.6% → 98.3%); Phase C gen + slug-fix shipped 2026-06-05 (registry additions + 13 portraits genned + Phase B re-run; coverage to 100%).

### The canonical slug derivation

```python
def canonical_slug(name: str) -> str:
    # NFKD-normalize to strip diacritics (Vigenère → Vigenere)
    s = unicodedata.normalize("NFKD", name)
    s = s.encode("ascii", "ignore").decode("ascii")
    s = s.lower()
    # Ampersand → "-and-"
    s = re.sub(r"&", "-and-", s)
    # Non-alphanumeric → "-"
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s or "char"
```

This matches `slugChar` in `spark-anvil-site/src/pages/cast/[app]/[char].astro` AND the canonical implementation in `spark-anvil-hub/scripts/gen_cast_portraits.py` (fixed 2026-06-05).

### Source of truth for `<char>`

The chapter MD filename (Tier-1 lives at `<app>-app/Docs/dn-s/chapters/<char>.md`; Tier-2 at `spark-anvil-hub/Resources/DN-S-Tier-Upper/chapters/<app>/<char>.md`) is the canonical slug. Portrait filenames must match. The character's display name in `dnCast.members[]` MAY differ from the slug (e.g., "The Bluffer" → `bluffer.md`); when the registry-derived slug doesn't match the chapter slug, the canonical slug is the chapter filename, and the post-gen fix script (`fix_cast_portrait_slugs.py`) renames the portrait to the chapter slug.

### CI check (prebuild) — defense-in-depth with the sync-time gate

Two complementary gates BOTH stay in place; neither replaces the other.

| Gate | Where | When it fires | Coverage class | Bypass |
|---|---|---|---|---|
| **Sync-time portrait gate** (V20 W1; 2026-06-26) | `spark-anvil-hub/scripts/sync_content_to_site.sh` | Per-app sync (post-content-copy / pre-commit) | **NEW gaps** — chapters being synced in this invocation | `--skip-portrait-gate` (trauma-axis carve-outs) |
| **Cloudflare prebuild audit** (R-CAST-PORTRAIT-SLUG; 2026-06-05) | `spark-anvil-site/package.json` `prebuild` → `audit_cast_portrait_coverage.py` | Every spark-anvil-site build | **HISTORICAL gaps** — any chapter page in any app, regardless of last-sync time | `SKIP_CAST_PORTRAIT_CHECK=1 npm run build` (emergency only) |

The prebuild gate makes the regression class build-time-visible — a chapter MD without a matching portrait file blocks deploy. Local dev catches the regression before commit; the Cloudflare build catches it before deploy.

Per `.claude/rules/spark-anvil-website.md` § "CRITICAL: Normalizer auto-runs in site prebuild" the prebuild chain is the canonical self-healing seam. The cast portrait audit joins it.

**Historical-gap class (V21 P0 2026-06-26 incident)**: when a new gate ships, it does NOT retroactively audit historical content. Pre-gate chapter MDs that have a portrait gap stay invisible to the sync gate until the app is re-synced for some other reason. The prebuild gate's enumeration-over-all-chapter-pages model catches these. Reference incident: `readquest/frame-and-plume` shipped 2026-06-24 (V12 ensemble round) without the V16-step-6.5 pair portrait gen step. Sync-time gate didn't catch it (it landed AFTER the V12 sync). Cloudflare prebuild gate caught it on the next site build. **Do NOT remove either gate** — they cover different failure modes. See `Docs/AUDIT_READQUEST_FRAME_AND_PLUME_PORTRAIT_GAP_2026-06-26.md` for the full post-mortem.

### When this rule applies

- **Authoring a new chapter MD**: name the file with the kebab-case slug of the character name; verify a matching `public/cast/<app>/<char>.webp` exists OR queue gen via `scripts/gen_cast_portraits.py --app <slug> --yes`.
- **Authoring a new ensemble pair / cohort chapter** (any chapter where `pair-bonds:` is declared in front-matter OR `role: Ensemble*` is set): MUST run `gen_cast_portraits.py --app <slug> --pairs <slug>:<chapter-slug> --include-gated --yes` in the same round as chapter authoring. Per V16 step 6.5 (§ "V15 reference-impl in-session polish discipline" in `.claude/rules/distributed-narrative.md`) — V15 omitted this and 4 chapters tripped Cloudflare; V12 (2026-06-24) omitted it for `readquest/frame-and-plume` and tripped Cloudflare again 2026-06-26 (V21 P0); V21 P0 (PM) caught **23 more historical gaps at once** across V12-V21 ensemble-pair authoring rounds. The portrait belongs to the chapter slug, NOT to the individual member names.
- **Cloudflare prebuild surfaces N>1 missing pair portraits at once** (the V21 P0 PM scenario): use the BATCH RECOVERY RECIPE:
  ```bash
  # 1. Get the full missing-portrait inventory
  python3 scripts/audit_cast_portrait_coverage.py --json > /tmp/missing.json

  # 2. Build comma-separated pairs argument
  python3 -c "import json; d=json.load(open('/tmp/missing.json')); print(','.join(f\"{r['app']}:{r['char']}\" for r in d['missing']))"

  # 3. Batch-gen via --all --pairs <list>
  python3 scripts/gen_cast_portraits.py --all --pairs "<comma-list>" --include-gated --yes
  ```
  Cost: ~$0.045 per pair (Gemini Nano Banana Flash). For 23 pairs: ~$1.04. **The 3-step recipe is faster + cheaper than running per-app gen for each app**.
- **Authoring a new app**: the per-app gen workflow already aligns; the `dnCast.members[]` `name` field flows through canonical slug derivation.
- **Renaming a chapter MD**: rename the portrait file in the same PR. The prebuild CI check will block the merge if not.
- **Adding a mentor or ensemble char** that doesn't fit `dnCast.members[]`: add it anyway (Captain Castle + The Pawn Cohort precedent — gambittales gained 2 entries 2026-06-05 to close the chapter-page broken-link surface).

### Tools

- `spark-anvil-hub/scripts/audit_cast_portrait_coverage.py` — enumerate (app, char) pairs; classify missing portraits by remediation path (B1 site rename / B2 app sync / C gen); `--json` machine-readable.
- `spark-anvil-hub/scripts/fix_cast_portrait_slugs.py` — Phase B one-shot remediation (B1 site `git mv` + B2 app-repo `cp`). Dry-run by default.
- `spark-anvil-hub/scripts/gen_cast_portraits.py` — Phase C gen pipeline; uses canonical slug derivation; idempotent (skip-if-exists).

### What this rule does NOT enforce (yet)

- **Per-cluster trauma-axis review on portrait gen** — Phase C portrait gen still gates on ADR-012 founder-ADR-approved AI gen for trauma-adjacent clusters; the CI check only catches "missing file", not "trauma-axis-unsafe content".
- **Mentor / ensemble chars in dnCast.members[]**: this rule documents the precedent but doesn't enforce that every chapter MD has a matching `dnCast.members[]` entry. File a per-app handoff to add mentors/ensembles to the registry when a gap surfaces.
- **App-repo Resources/Cast slug**: the rule applies to spark-anvil-site portraits only. App-bundle conventions per `.claude/rules/forgekit.md` § "Cast asset filename convention" (`cast_<character_slug>_<pose>.webp`) remain orthogonal.

### Cross-references

- `Docs/AUDIT_CAST_PORTRAIT_BROKEN_LINKS_2026-06-05.md` — Phase A + B remediation audit
- `Docs/AUDIT_READQUEST_FRAME_AND_PLUME_PORTRAIT_GAP_2026-06-26.md` — V21 P0 morning historical-gap incident post-mortem (V12 ensemble round; sync-time gate vs Cloudflare prebuild gate defense-in-depth)
- `Docs/AUDIT_CAST_PORTRAIT_GAPS_BATCH_2026-06-26.md` — V21 P0 PM batch-recovery audit (23 portraits across 23 apps; same pattern at scale)
- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § cast portrait broken-image + V21 P0 readquest/frame-and-plume + V21 P0 PM batch
- `.claude/rules/distributed-narrative.md` § "V15 reference-impl in-session polish discipline" step 6.5 — pair portrait gen for ensemble chapters (the discipline this rule depends on)
- `.claude/rules/forgekit.md` § "Cast asset filename convention" (app-bundle orthogonal convention)
- `.claude/rules/portfolio.md` § "Asset Consumer Audit" (precedent for "registered ≠ wired" / "synced ≠ rendered")

## Chapter front-matter duplicate-key gate (R-CHAPTER-YAML-DUP-KEY; 2026-06-26)

**Chapter MD YAML front-matter MUST NOT have any top-level key listed twice.** js-yaml strict mode (used by Astro's `gray-matter` content-collection loader) rejects duplicate keys with `duplicated mapping key` error → Cloudflare Workers Builds prebuild fails. Closes the V21+ P0 incident class surfaced 2026-06-26 evening (depthquest/trench.md + numbersense/pivot-pia.md both shipped with `gate-allow-text: []` listed twice).

### Why the V20 W1 portrait gate didn't catch this

The portrait gate validates portrait-coverage; it doesn't parse YAML. The portfolio normalizer (`normalize_chapter_frontmatter.py`) quotes unquoted values that contain colons/em-dashes but doesn't detect DUPLICATE KEYS. The js-yaml parser is the only thing that does — and it fails at site-build time, not sync time, leaving Cloudflare red until a hub session intervenes.

### The two-gate defense-in-depth (same pattern as R-CAST-PORTRAIT-SLUG)

| Gate | Where | When it fires | Coverage class | Bypass |
|---|---|---|---|---|
| **Sync-time duplicate-key gate** (V21+ 2026-06-26) | `spark-anvil-hub/scripts/sync_content_to_site.sh` | Per-app sync (post-content-copy / pre-commit) | **NEW duplicates** introduced in source MDs by a current sync | (none — duplicate keys are always defects) |
| **Cloudflare prebuild gate** (V21+ 2026-06-26) | `spark-anvil-site/package.json` `prebuild` → `check-chapter-frontmatter-duplicates.py` | Every spark-anvil-site build | **HISTORICAL duplicates** in any synced chapter, regardless of last-sync time | `SKIP_FRONTMATTER_DUP_CHECK=1 npm run build` (emergency only) |

Both gates check ONLY top-level keys. Nested mapping keys (e.g., the `name:` field repeated across sibling items in `pair-bonds:`) are NOT counted as duplicates — they're legitimately repeated per the YAML spec.

### When this rule applies

- **Authoring a new chapter MD front-matter**: never copy-paste a line that already exists at top level. The pattern surfaced this round was `gate-allow-text: []` accidentally pasted twice when an author meant to author the entry once and `gate-allow-text-pattern:` once.
- **Adding `gate-allow-text` to satisfy R-PATH-B-TEXT-LEAK-GATE**: if a `gate-allow-text:` line already exists in the front-matter, EXTEND it (add list items beneath) — don't add a second `gate-allow-text:` line.
- **Running `rewrite_chapter_register.py` or any other tool that edits front-matter**: tools MUST preserve the single-occurrence invariant. If a tool needs to add a value to an existing key, it MUST extend the existing entry, not add a parallel one.

### Tools

- `spark-anvil-hub/scripts/check_chapter_frontmatter_duplicates.py` — portfolio-wide scanner (T1 sources + T2 sources + site-synced copies); `--ci-mode` exits non-zero on any finding
- `spark-anvil-site/scripts/check-chapter-frontmatter-duplicates.py` — in-repo mirror that runs in Cloudflare prebuild; resolves paths relative to `__file__` so it works in any environment

### Companion to R-CAST-PORTRAIT-SLUG defense-in-depth

R-CAST-PORTRAIT-SLUG and R-CHAPTER-YAML-DUP-KEY use the same two-gate pattern (sync-time gate catches new defects in active workflow; Cloudflare prebuild gate catches historical defects across all chapters). The two rules are companion defenses against site-deploy failures at the chapter-content axis. Removing either gate in either rule re-opens an unbounded regression class.

### Cross-references

- `Docs/AUDIT_CHAPTER_YAML_DUPLICATE_KEY_2026-06-26.md` — V21+ P0 incident post-mortem + remediation
- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § V21+ P0 — work-queue entry
- `spark-anvil-hub/scripts/check_chapter_frontmatter_duplicates.py` — hub-side audit
- `spark-anvil-site/scripts/check-chapter-frontmatter-duplicates.py` — site-side prebuild gate
- `spark-anvil-hub/scripts/sync_content_to_site.sh` — sync-time gate (post-content-copy / pre-commit)
- `.claude/rules/spark-anvil-website.md` § R-CAST-PORTRAIT-SLUG — sister two-gate defense-in-depth pattern

## Cast-member route-link coverage (R-CAST-ROUTE-COVERAGE; 2026-06-27)

**Any component or page that renders a `/cast/<app>/<char>` LINK from a cast member MUST guard it with `hasChapter(app, member.name)` AND derive the slug with `chapterSlugFor(app, member.name)` — never `slugChar()` directly, and never an unguarded `chapterSlugFor()`.** A member with no authored chapter has no route; linking to it ships a broken internal link → `check-site-internal-links.py` FAIL → red Cloudflare deploy.

### Why the rule exists (2026-06-27 incident)

User-reported Cloudflare FAIL: `[route] 1 unique / 1 refs — /cast/mathcircle/circle`. Root mechanism: `chapterSlugFor(app, name)` (in `src/lib/castSlug.ts`) returns `SLUG_MAP[\`${app}/${name}\`] ?? slugChar(name)`. When a name is NOT in the slug map (e.g. an individual ensemble member "Circle" whose only route is the cohort chapter `circle-circe-echo-edie`), it **falls back to `slugChar("Circle")` = `circle`** — a slug with no route. Rendering that as a link 404s. `hasChapter(app, name)` returns true ONLY when `app/name` is a real slug-map key, so filtering members through it before linking is the fix.

### The guarded pattern (all current call-sites already follow it)

```astro
{(appData?.dnCast?.members ?? [])
  .filter((m) => hasChapter(app, m.name))      // ← REQUIRED guard
  .map((m) => {
    const slug = chapterSlugFor(app, m.name);  // never slugChar() for a route
    return <a href={`/cast/${app}/${slug}`}>…</a>;
  })}
```

Audited 2026-06-27 — **7 route-link generators, all guarded**: `SiblingCastStrip.astro`, `cast/[app]/[char].astro` (ensemble grid), `cast/[app]/[char]/advanced.astro`, `apps/[slug].astro`, `cast.astro`, `index.astro` (featured + daily carousel). The homepage recency strips key off `recency.cast` (real chapter slugs) so they link only to existing routes. Current `main` builds clean (0 broken refs); the failing build was an earlier state, fixed by these guards.

### Enforcement gate

`spark-anvil-site/scripts/check-site-internal-links.py` (postbuild, runs on every Cloudflare build) resolves every `href`/`src` against `dist/` and FAILS on any unresolved `/cast/...` route. This is the backstop — **never bypass it with `SKIP_SITE_INTERNAL_LINK_CHECK=1` to ship a real broken route.** When it flags a `/cast/<app>/<char>`, the cause is almost always an unguarded link-generator (add the `hasChapter` filter) or a genuinely missing chapter route (author the chapter or stop linking the member).

### When authoring a new link-generator

Any NEW component/page that turns `dnCast.members[]` (or `pair-bonds[]` members, or any member-name list) into `/cast/...` links MUST apply the `hasChapter` filter. Do NOT render individual ensemble/cohort members as separate links unless each has its own authored chapter route — link the cohort chapter instead.

### Hardcoded curated lists bypass the guard — validate them at build time (2026-06-28)

**A hand-authored list of `(app, char)` link targets — e.g. `today.astro`'s `FLAGSHIP_POOL`, or any curated "featured chapter" / "story of the day" pool — bypasses the `hasChapter()` filter entirely, because the slugs are typed by a human, not derived from `dnCast.members`.** A stale entry (a renamed chapter, a member with no individual route) ships a broken `/cast/...` link.

**This failure is INTERMITTENT and that's the trap.** `today.astro` picks ONE entry by `dayOfYear % poolLength`, so a bad entry only renders — and only fails the build — on the specific day-of-year it's selected. Local builds and Cloudflare builds on every *other* day pass, so the bug looks "already fixed" when it's merely dormant. The 2026-06-28 incident: `FLAGSHIP_POOL` had `mathcircle/circle` (no route; real route is `circle-circe-echo-edie`) at index 3 and `cubesensei/look-ahead` (real: `look`) at index 7 — each failed Cloudflare ~1 day in 8, producing a recurring "`/cast/mathcircle/circle` broken again" report that three prior static audits couldn't reproduce because they ran on the wrong day.

**Required pattern for any curated `(app, char)` pool**: validate the WHOLE pool against the real chapter collection at build time, so a bad entry fails LOUDLY on EVERY build (not 1-in-N days):

```astro
import { getCollection } from 'astro:content';
const _validChapterIds = new Set(
  (await getCollection('chapters')).map((c) => c.id.replace(/\.md$/, '')),
);
for (const entry of FLAGSHIP_POOL) {
  if (!_validChapterIds.has(`${entry.app}/${entry.char}`)) {
    throw new Error(`[<page>] curated entry has no chapter route: /cast/${entry.app}/${entry.char}`);
  }
}
```

**Reproducing a day-dependent route failure**: a clean-room build is the only reliable repro — `rm -rf dist && npm run build` on the actual failing day, then `grep -rl 'cast/<app>/<char>"' dist/`. The day-of-year is `new Date()`-derived, so the failing entry rotates daily; if the static checks all pass but Cloudflare keeps failing, suspect a `new Date()`/`Math.random()`-seeded picker over a curated or member-derived list.

### Cross-references

- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § "V23 P0 — Cloudflare build FAIL: broken /cast/mathcircle/circle route"
- `spark-anvil-site/src/lib/castSlug.ts` — `chapterSlugFor` / `hasChapter` / `slugChar`
- `spark-anvil-site/scripts/check-site-internal-links.py` — the postbuild enforcement gate
- `.claude/rules/spark-anvil-website.md` § R-CAST-PORTRAIT-SLUG — sister rule (portrait-file coverage; same "member without asset" failure family)

## Multi-beat chapter snapshot convention (R-MULTIBEAT-SNAPSHOT; 2026-06-10)

**Multi-beat chapter pages read prose from a SNAPSHOT at `public/chapters/<app>/chapter_<char>.md` — NOT from `src/content/chapters/<app>/<char>.md`.** When the source-of-truth chapter MD is rewritten (e.g., Option C register cleanup, content corrections, register rewrites), **the snapshot must be regenerated alongside the per-beat sidecar + illustrations + audio**, because the sidecar's `prose-range: { from-line, to-line }` indexes against the snapshot's line numbers AND the per-beat audio narration speaks the snapshot's prose.

### CRITICAL: the snapshot `.md` is a SEPARATE copy — distribute it explicitly (2026-06-27 incident)

**When distributing a NEW multibeat chapter to `public/chapters/<app>/`, the snapshot `chapter_<char>.md` is a DISTINCT file that must be copied separately** — it is a byte copy of the segmented source MD (`<app>-app/Docs/dn-s/chapters/<char>.md`):

```bash
cp <app>-app/Docs/dn-s/chapters/<char>.md \
   spark-anvil-site/public/chapters/<app>/chapter_<char>.md
```

**Do NOT rely on a `chapter_<char>_*` (underscore) glob to carry it** — that glob matches the beat/audio/vtt files (`chapter_<char>_beat_00.webp`, `chapter_<char>_chapter.m4a`, …) but **MISSES the no-underscore snapshot `chapter_<char>.md`** (and the `chapter_<char>.beats.json` sidecar). Use `chapter_<char>.*` (dot) OR copy the snapshot explicitly.

**Why this is load-bearing**: `build-multibeat-chapter-manifest.mjs` requires the snapshot (+ audio + vtt + every beat image) and **SILENTLY rejects** any chapter missing one. A rejected chapter is absent from `multibeat-chapters.json`, so its page evaluates `hasMultibeat === false` and renders `<ChapterIllustration variant="opener">` → `chapter_<char>_opener.webp` which forward-authored (post 2026-06-13 no-opener) chapters never generate → 404 → red Cloudflare deploy.

**Build-time backstop (gate)**: `spark-anvil-site/scripts/check-multibeat-snapshot-coverage.py` runs in `prebuild` (ahead of the manifest builder) and FAILS the build LOUDLY with the exact missing file for any sidecar whose companion set (snapshot/audio/vtt/beat0) is incomplete — turning the silent reject into an actionable error. Bypass: `SKIP_MULTIBEAT_SNAPSHOT_CHECK=1`. **Reference incident**: 2026-06-27 — 5 FractionForge V22 chapters shipped without snapshots; all 5 silently rejected → 10 broken opener refs caught by the postbuild link checker (work-queue § "V23 P0 — Cloudflare build FAIL").

### Why two prose paths exist

The chapter template at `src/pages/cast/[app]/[char].astro` checks the `multibeat-chapters.json` manifest (built by prebuild from `public/chapters/<app>/chapter_<char>.beats.json` presence):

- **Multi-beat present** → `<InterleavedChapterAudioPlayer mode="multi-beat" />` reads beat-prose from the snapshot via the manifest's `beatProse[]` (sliced from `public/chapters/<app>/chapter_<char>.md` by `build-multibeat-chapter-manifest.mjs`)
- **Multi-beat absent** → `<InterleavedChapterAudioPlayer mode="single-chapter" />` OR plain `<Content />` renders from `src/content/chapters/<app>/<char>.md` (Astro content collection)

The snapshot was introduced to keep beat-prose-range slicing stable + decoupled from content-collection schema. But the dual paths mean a chapter can have STALE multi-beat prose while the content-collection version is current.

### Required workflow when rewriting a chapter that's already in multi-beat mode

For any chapter where `public/chapters/<app>/chapter_<char>_chapter.m4a` exists (i.e., Path B has shipped for it):

1. **Rewrite source** via `scripts/rewrite_chapter_register.py --app <slug> --chapter <char> --tier 1 [--model gemini-2.5-pro] [--force]` — updates `<app>-app/Docs/dn-s/chapters/<char>.md`
2. **Commit + push source app-repo PR** (cross-repo write per hub-as-research-hub Docs/ exception)
3. **Delete stale multi-beat assets**:
   ```bash
   rm Resources/AutoSegmentedChapters/<app>/<char>.beats.json
   rm <pilot-or-wave-out-dir>/<char>_receipt.json <pilot-or-wave-out-dir>/<char>_beat_*.png <pilot-or-wave-out-dir>/<char>_chapter.*
   rm /Volumes/Data/Projects/GitHub/spark-anvil-site/public/chapters/<app>/chapter_<char>.beats.json
   rm /Volumes/Data/Projects/GitHub/spark-anvil-site/public/chapters/<app>/chapter_<char>.md
   rm /Volumes/Data/Projects/GitHub/spark-anvil-site/public/chapters/<app>/chapter_<char>_beat_*.png
   rm /Volumes/Data/Projects/GitHub/spark-anvil-site/public/chapters/<app>/chapter_<char>_chapter.*
   ```
4. **Re-run the surgical regen** (target the single chapter; do NOT use `path_b_wave_runner.sh` which iterates ALL chapters in an app):
   ```bash
   /usr/bin/python3 scripts/auto_segment_chapter.py --chapter <md-path> --out Resources/AutoSegmentedChapters/<app> --app <app>
   /usr/bin/python3 scripts/pilot_interleaved_ensemble_chapter.py --manifest Resources/AutoSegmentedChapters/<app>/<char>.beats.json --out-dir <out-dir>
   # then cp the chapter_<char>.* family into spark-anvil-site/public/chapters/<app>/
   ```
5. **Sync content collection** via `scripts/sync_content_to_site.sh --apply --app <slug>` (also updates `src/content/chapters/<app>/<char>.md` + opener/spot illustrations + audio drama if any)
6. **Commit + push spark-anvil-site** (one commit per app-batch is fine)

Per-chapter regen cost: **~$0.32** (Pro opener $0.134 + 4 × Flash $0.045 + Gemini TTS ~$0.10).

### Why `sync_content_to_site.sh` does NOT also update the snapshot

The snapshot at `public/chapters/<app>/chapter_<char>.md` is paired with the sidecar `chapter_<char>.beats.json` whose `prose-range` indexes lines into the snapshot. If `sync_content_to_site.sh` copied the new source MD over the snapshot without re-segmenting the sidecar AND re-genning per-beat assets, the chapter would render with:

- Wrong text per beat (sidecar's `from-line/to-line` point to wrong lines in the new MD)
- Audio narration speaks OLD prose (per-beat audio was generated from the OLD snapshot)
- Per-beat illustrations depict OLD scenes

So `sync_content_to_site.sh` deliberately leaves the snapshot alone. Snapshot ownership lives with `path_b_wave_runner.sh` (or the surgical regen recipe above).

### Methodology-section stop in the segmenter (2026-06-10 fix)

**The auto-segmenter STOPS collecting paragraphs at the first methodology H2** (`## Voice register` / `## Arc across kits` / `## Relationships` / `## Cultural-sensitivity gate` / `## Cultural-context note` / `## Author's note` / `## Sample lines` / `## A note for grown-ups` / `## What's the big idea here?` etc.). Beats only cover the narrative body; methodology stays in the snapshot file for reference but is **never sliced into a beat**.

**Why this is in the segmenter, not the snapshot**:

Multi-beat pages render exclusively from beat prose. The chapter template does NOT fall back to `<Content />` on the content-collection MD when multi-beat is active. So the spark-anvil-site-side `strip-chapter-methodology-sections.py` (which processes `src/content/chapters/<app>/<char>.md`) has zero effect on multi-beat pages — its strip-output is never rendered. Methodology leaked into beats whenever the segmenter included those lines in its even-paragraph-count split.

The fix lives in `spark-anvil-hub/scripts/auto_segment_chapter.py` `_METHODOLOGY_H2_PATTERNS` set + `_is_methodology_h2()` hard-stop in `collect_paragraphs()`. The strip-script's pattern set + the segmenter's pattern set MUST stay in sync — adding a new methodology H2 to one requires adding it to the other.

**Companion implication for per-beat audio**: the pilot script's per-beat TTS sources prose from sidecar's `prose-range` slice of the snapshot. With the segmenter stopping at methodology, beats only contain narrative, so per-beat audio only narrates narrative. No "Voice register" / "Arc across kits" speech leaks into the audio drama.

**Discovered 2026-06-10** when user-flagged the live cosmosforge/gleam page rendering "## Voice register", "## Arc across kits", "## Relationships" sections under the beats UI. Root cause: pre-fix segmenter included methodology lines in beat 4 (closer); multi-beat renderer sliced beat 4 from snapshot lines 51-100 which contained all the methodology content.

**Future enhancement idea**: extend `sync_content_to_site.sh` to detect multi-beat chapters + automatically run the surgical regen. Out of scope for the current convention; for now, the human/agent operator handles regen explicitly when rewriting multi-beat chapters.

### When the rule applies

- Author rewriting a chapter MD for register / content / accuracy: check `ls /Volumes/Data/Projects/GitHub/spark-anvil-site/public/chapters/<app>/chapter_<char>_chapter.m4a` — if present, the chapter is multi-beat; follow the workflow above
- Portfolio-wide Option C rewrite + Path B regen rollout: bake the regen step into the per-app wave driver (see Work Queue § Option C portfolio rewrite for the operational pattern)
- Content corrections that don't change line structure (typo fix, single-word swap): `sync_content_to_site.sh` is sufficient — sidecar line-ranges still point to valid lines; audio is only off by one word

### Verification

After regen, verify:

1. **Local snapshot matches source**: `diff <(head -30 <app>-app/Docs/dn-s/chapters/<char>.md) <(head -30 /Volumes/Data/Projects/GitHub/spark-anvil-site/public/chapters/<app>/chapter_<char>.md)` should show only YAML front-matter quoting differences (from the prebuild normalizer)
2. **Receipt shows uniform cost**: `Resources/PilotsAndExperiments/<wave>/<app>/<char>_receipt.json` `total_cost_usd` should be ~$0.32
3. **Live URL**: hard-refresh `https://spark-and-anvil.com/cast/<app>/<char>` after Cloudflare redeploys; check that opener prose + first-beat prose match the rewritten source

### Cross-references

- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § "Option C portfolio rewrite — multi-beat snapshot staleness gotcha + remediation" — operational rollout plan
- `spark-anvil-hub/scripts/sync_content_to_site.sh` — content-collection sync (does NOT touch multi-beat snapshot)
- `spark-anvil-hub/scripts/path_b_wave_runner.sh` — multi-beat batch driver (idempotent — skip if `site_m4a` exists; delete to force regen)
- `spark-anvil-hub/scripts/auto_segment_chapter.py` — segmenter (creates sidecar with prose-range against current MD line numbers)
- `spark-anvil-hub/scripts/pilot_interleaved_ensemble_chapter.py` — per-beat illustration + audio gen
- `spark-anvil-site/scripts/build-multibeat-chapter-manifest.mjs` — prebuild manifest builder (slices snapshot prose by sidecar line-ranges)
- `spark-anvil-site/src/pages/cast/[app]/[char].astro` — chapter template (decides single-chapter vs multi-beat based on manifest)

## Path B illustration prompt parity (R-PATH-B-PROMPT-PARITY; 2026-06-11)

**Per-beat illustration prompts in `scripts/pilot_interleaved_ensemble_chapter.py` MUST include (a) chapter prose for the beat's `prose-range`, (b) a character-identity block from the chapter's YAML front-matter + opening passage, AND (c) a per-app `base_style` resolved via `STYLE_REGISTRY`.** The auto-segmenter sidecar's `scene` field is structural metadata, not artistic direction; never use it as the sole content cue.

### Why the rule exists

`Docs/AUDIT_PATH_B_WRONG_CHARACTER_2026-06-11.md` surfaced a systemic regression where Path B beat illustrations rendered the wrong character. Root cause: the pre-2026-06-11 `build_illustration_prompt()`:

1. Never received chapter prose (it was extracted only for TTS)
2. Used `auto_segment_chapter.py`'s generic `"scene": "<Char> beat N of M"` placeholder verbatim
3. Inherited a hard-coded `GAMBITTALES_STYLE` (warm amber + cream + tan fairy-tale palette) as the unconditional default

Under those constraints, Pro hallucinated a generic warm-amber Animal-Crossing bear in a fairy-tale village for ANY chapter where the character was non-conventional (paper fence, mathematical-concept embodiment, abstract entity). Apps with conventional kid/animal casts survived by coincidence; non-conventional casts shipped visibly wrong art.

### The 3 load-bearing prompt blocks

The 2026-06-11 v2 prompt adds three blocks before the existing `ANTI_TEXT` clause:

| Block | Source | Why it's load-bearing |
|---|---|---|
| **CHARACTER IDENTITY (LOAD-BEARING)** | YAML front-matter (`character:` + `role:` + `primitive:`) + first beat's `prose-range` + species-defaulting clause | Locks the species + role; the species-defaulting clause ("if the chapter does NOT describe a specific non-human form, render as a HUMAN child or adult appropriate to the role + scene — NOT a generic anthropomorphic animal") prevents the badger-in-medieval-village failure mode for chapters whose prose lacks visual character description |
| **STORY EXCERPT (this beat's prose)** | `beat_prose(beat, md_lines)` trimmed to ~220 words | Gives Pro the actual scene + action context for THIS beat; without it the model invents a fairy-tale-village backdrop regardless of chapter content |
| **STYLE** | `STYLE_REGISTRY.get(app, _DEFAULT_STYLE)` | Per-app palette + register override. `_DEFAULT_STYLE` deliberately drops the amber/cream/tan palette and tells the model to derive palette from the CHARACTER IDENTITY + STORY EXCERPT blocks |

### `STYLE_REGISTRY` ownership

The `STYLE_REGISTRY` dict in `pilot_interleaved_ensemble_chapter.py` is the canonical per-app style override surface. Default behavior (when the app slug is not in the registry) is `_DEFAULT_STYLE` which prescribes ONLY the chunky-cartoon outline + cell-shading register, NOT a specific palette.

Add a per-app entry only when:
- The app has a distinctive visual register that prose alone won't trigger (e.g., `gambittales` fairy-tale fantasy palette; an `aiforge` paper-craft palette if the prose-injection alone proves insufficient)
- 1+ chapters of the app ship visibly off-register after the v2 prompt baseline

Per-app overrides should pass a Phase B-equivalent proof regen before being committed.

### Companion: when chapter prose lacks species cues

Some chapters describe characters by behavior + setting but NOT species (proofquest/direct-proof-dora was the canonical 2026-06-11 incident — Dora described as "step-by-step talkative kid who walked the bridge to school," no species cue). The species-defaulting clause inside `extract_character_identity()` defaults to "human child or adult" for these chapters. If a chapter SHOULD render a non-human form (paper / fence / robot / animal / object / abstract entity), make sure the chapter's opening prose explicitly states that form. Don't rely on the cast portrait as the only species signal — Pro doesn't see the portrait during gen unless we wire it as a ref-image (see Phase A+ future enhancement).

### Don'ts

- Don't remove the `_DEFAULT_STYLE` "Derive the specific palette + setting from the CHARACTER IDENTITY + STORY EXCERPT blocks below" instruction — it's the seam that keeps Pro on-prose
- Don't reintroduce the hard-coded `GAMBITTALES_STYLE` as default for non-Gambittales apps; that was the original regression
- Don't strip the species-defaulting clause from `extract_character_identity()` — it's the only signal preventing Pro from rendering "mathematician archetype" as an anthropomorphic badger
- Don't bypass `build_illustration_prompt()` and call the gen API directly with a custom prompt unless you also pass the 3 load-bearing blocks — duplicate prompt construction is the regression class

### When the rule applies

- Any `path_b_wave_runner.sh` invocation — auto-applies (the runner calls `pilot_interleaved_ensemble_chapter.py`)
- Any one-off chapter regen via `pilot_interleaved_ensemble_chapter.py --manifest <sidecar>` — auto-applies
- Any new Path B / Path C ensemble chapter gen script (e.g., future `gen_app_illustrations.py --interleaved` portfolio rollout) — MUST adopt the same 3-block pattern. The blocks are reusable via the same helper functions (`extract_character_identity()` + `_trim_excerpt_for_prompt()` + `STYLE_REGISTRY` lookup)
- **Cast portrait gen (`scripts/gen_cast_portraits.py`)** — applies the 3-block pattern with POSE / FRAMING substituted for STORY EXCERPT (portraits are neutral 3/4 head-and-shoulders, not beat-scene depictions). Imports `STYLE_REGISTRY` + `_DEFAULT_STYLE` + `_parse_frontmatter` + `_trim_excerpt_for_prompt` directly from `pilot_interleaved_ensemble_chapter` so the per-app palette + species-defaulting + front-matter parsing helpers are shared, not duplicated. Codified after `Docs/AUDIT_CAST_PORTRAIT_VS_BEAT_0_COHERENCE_2026-06-11.md` surfaced 100% portrait-vs-beat-0 drift across 58 multi-beat chapters. See § "Portrait companion (cast portrait gen)" below
- **Book cover gen (`scripts/gen_book_covers.py`)** — SHIPPED 2026-06-11 (commit 3057c177; "Sister-of-Phase-A book cover refactor + 286-cover portfolio regen wave"). Applies the 3-block pattern with COMPOSITION substituted for STORY EXCERPT (covers are tier-specific layout: top 60% character + bottom 40% title typography + Spark & Anvil footer; per-tier register from `TIER_REGISTERS`). Imports `STYLE_REGISTRY` + `_DEFAULT_STYLE` + `_parse_frontmatter` + `_trim_excerpt_for_prompt` directly from `pilot_interleaved_ensemble_chapter` so the cover, the cast portrait, and beat 0 all inherit the same per-app visual register. See `Docs/AUDIT_PDF_BOOK_COVER_COHERENCE_2026-06-11.md` for the parent audit + `scripts/gen_book_covers.py::build_prompt()` for the canonical 3-block impl.

### Portrait companion (cast portrait gen)

The `scripts/gen_cast_portraits.py` prompt pipeline (refactored 2026-06-11) adopts the R-PATH-B-PROMPT-PARITY 3-block pattern with portrait-specific framing:

| Block | Source for portraits | Differs from beat-illustration use |
|---|---|---|
| **CHARACTER IDENTITY (LOAD-BEARING)** | YAML front-matter (`character:` + `role:` + `primitive:`) + first 30 body lines of the chapter MD (trimmed to ~220 words) + species-defaulting clause | Beat pipeline takes prose from beat-0's `prose-range` slice; portrait pipeline takes from the chapter MD's opening passage directly (no sidecar dependency since portrait gen runs before any sidecar exists) |
| **POSE / FRAMING** | Neutral 3/4 head-and-shoulders portrait; character fills ~65% of square 1:1 frame; transparent background; signature visual trait visible IF described in CHARACTER IDENTITY | Beat pipeline uses `build_composition_direction(beat)` for per-beat cinematic shots; portrait pipeline uses a fixed neutral pose (`_PORTRAIT_POSE_FRAMING` constant) since portraits are character-identity sidebars, not scene depictions |
| **STYLE** | `STYLE_REGISTRY.get(app_slug, _DEFAULT_STYLE)` — same registry as the beat pipeline | Identical; shared lookup so per-app palette overrides cascade to BOTH portrait + beat 0 simultaneously |

**Chapter MD lookup**: `_load_chapter_md_for_char(app_slug, char_slug)` resolves `<app>-app/Docs/dn-s/chapters/<char_slug>.md`. When the chapter MD doesn't exist (cast member present in `apps.generated.ts` but no DN-S chapter authored yet), the prompt falls back to a legacy name+role construction with STYLE_REGISTRY still applied — so per-app palette consistency holds across both paths.

**Regen wave discipline**: `gen_cast_portraits.py --regen` overwrites existing portraits. The `convert_to_webp()` helper accepts `overwrite=True` when `--regen` is set; without this guard, the old WebP would persist even after a successful Flash gen + PNG write. Reference fix: 2026-06-11 portrait remediation wave (PR following this codification).

**Don'ts (portrait-specific)**:

- Don't hand-roll a parallel `extract_character_identity()` in the portrait script — import from the pilot module so the species-defaulting clause and front-matter parsing stay synchronized
- Don't expand `_PORTRAIT_POSE_FRAMING` to include scene depiction — portraits are character-identity sidebars; scene context belongs to beat 0
- Don't skip `--regen` when remediating drift; the default `--regen=False` behavior is intentional for first-emit waves but blocks remediation
- Don't add a per-character chapter MD path override unless the character genuinely lives in a non-canonical location — the Tier-1 source-of-truth `<app>-app/Docs/dn-s/chapters/<char_slug>.md` is the rule

### Cross-references

- `Docs/AUDIT_PATH_B_WRONG_CHARACTER_2026-06-11.md` — root-cause audit + Phase A patch + Phase B proof regen receipts
- `Docs/AUDIT_CAST_PORTRAIT_VS_BEAT_0_COHERENCE_2026-06-11.md` — portrait companion audit (100% drift across 58 chapters); triggered portrait-companion codification
- `Docs/AUDIT_PDF_BOOK_COVER_COHERENCE_2026-06-11.md` — sister audit for the book cover gen pipeline; refactor pending
- `labsmith/scripts/pilot_interleaved_ensemble_chapter.py:446` — `build_illustration_prompt()` canonical impl (beat illustrations)
- `labsmith/scripts/gen_cast_portraits.py` — `build_prompt()` portrait impl (imports STYLE_REGISTRY + helpers from pilot module)
- `labsmith/scripts/auto_segment_chapter.py:278` — generic `scene` placeholder upstream (treated as structural metadata, not artistic direction)
- `Docs/SPEC_INTERLEAVED_ENSEMBLE_CHAPTER.md` — ensemble sidecar manifest schema (parent spec)

### Pre-distribute text-leak gate (R-PATH-B-TEXT-LEAK-GATE; 2026-06-13)

**`path_b_wave_runner.sh` MUST run `audit_image_text_leaks.py` against each newly-generated beat PNG BEFORE distributing to spark-anvil-site. If any beat verdicts LEAK, the wave runner fails-fast for that chapter — no distribution to public/chapters/ — and the operator regenerates with a tightened prompt.**

#### Why the gate exists

Queue #971 Phase 2 portfolio sweep (`Docs/AUDIT_IMAGE_TEXT_LEAKS_PORTFOLIO_SWEEP_2026-06-13.md`) classified 397 site beat PNGs and surfaced **62 LEAKs (15.6%)**. Without a pre-distribute gate, future Path B waves can ship new leaks. The top-3 leakers (BeatForge 11 + GambitTales 10 + BridgeForge 9 = 48% of total) demonstrate the regression class.

Pre-distribute is the right seam (NOT post-distribute or runtime detection) because:

1. Audit cost is sub-cent per image (~$0.001 Gemini 2.5 Flash); cumulative gate cost per chapter is ~$0.005 (5 beats × $0.001)
2. Re-running the gen for a failed chapter is cheaper than syncing a leak + then remediating it (avoids cascade through `sync_content_to_site.sh` → site prebuild → Cloudflare deploy)
3. The operator sees the leak verdict + detected text strings inline in the wave runner output

#### Gate mechanics (`scripts/path_b_wave_runner.sh` step 2.5)

```bash
if [ "${SKIP_TEXT_LEAK_GATE:-0}" != "1" ]; then
    for beat in beat_00..beat_04; do
        audit_image_text_leaks.py --image $beat --json-out tmp
        verdict=$(jq -r '.results[0].verdict' tmp)
        if [ "$verdict" = "LEAK" ]; then
            echo "✗ $app/$slug — text-leak gate FAIL on beat $i"
            mark-failed; break-chapter
        fi
    done
fi
```

The gate enumerates each `${slug}_beat_0N.png` produced by `pilot_interleaved_ensemble_chapter.py`, calls the audit script per-beat, and parses the per-image verdict. LEAK verdict → fail the chapter; the wave runner records `<app>/<slug>:text-leak-gate` in the FAILED_LIST and moves to the next chapter. Operator inspects the leak diagnostics + reruns the wave.

#### Override

Set `SKIP_TEXT_LEAK_GATE=1` to bypass. Use sparingly:

- Trauma-axis carve-outs where transient text leaks are operationally acceptable
- Diagnostic runs where the operator wants to ship + inspect the leak in-context
- Math-app override is already handled inside `audit_image_text_leaks.py` (MULTI_DIGIT is OK for math apps; see `MATH_APPS` set) — don't reach for `SKIP_TEXT_LEAK_GATE` for math apps unless the gate misfires

Default = gate enabled. Anytime a math-app beat surfaces a false-positive LEAK because of legitimate single-digit / multi-digit numerals not caught by the math-app override, FIRST extend `MATH_APPS` in the audit script; only use the env-var bypass when extension isn't appropriate.

#### Companion: per-app remediation queue (R1)

The 62 LEAKs surfaced in the portfolio sweep are NOT auto-remediated by adding this gate. R1 remediation per `Docs/AUDIT_IMAGE_TEXT_LEAKS_PORTFOLIO_SWEEP_2026-06-13.md` § Recommendations:

1. Per-app regen for top-3 leakers (BeatForge / GambitTales / BridgeForge = 30 of 62)
2. Per-app spot-check + selective regen for tail-15 apps (32 of 62)
3. Verify post-regen via `audit_image_text_leaks.py --app <slug>` returning 0 LEAKs

The gate prevents NEW leaks; R1 remediates EXISTING leaks. Both are required for full closure of Queue #971.

#### When this rule applies

- Every `path_b_wave_runner.sh` invocation — auto-applies via step 2.5 (chapter beats)
- Every `gen_cast_portraits.py` invocation — auto-applies via `gate_single_image()` between PNG render and WebP conversion (R-PATH-B-TEXT-LEAK-GATE companion, 2026-06-15)
- Every `gen_book_covers.py` invocation — auto-applies via `gate_single_image()` between PNG render and WebP conversion (R-PATH-B-TEXT-LEAK-GATE companion, 2026-06-15)
- Any one-off chapter regen via direct `pilot_interleaved_ensemble_chapter.py` invocation — operator MUST manually run `audit_image_text_leaks.py --image <beat>.png` before copying to spark-anvil-site (the gate is currently wired into the wave runner only; one-off path is operator-discipline)
- Future Path C ensemble gen (when portfolio-scale `gen_app_illustrations.py --interleaved` ships) — MUST adopt the same pre-distribute gate pattern

#### Reusable gate function

The per-image gate is canonicalized in `audit_image_text_leaks.py:gate_single_image()`. New gen scripts MUST import + call this function rather than re-implement the audit + verdict logic. Signature:

```python
from audit_image_text_leaks import gate_single_image

passed, audit = gate_single_image(
    image_path,                # Path to the rendered PNG
    app_slug="myapp",          # Optional explicit override; falls back to path detection
    client=client,             # Optional google.genai.Client; lazy-built if None
    skip_env="SKIP_TEXT_LEAK_GATE",  # Env override knob
)
if not passed:
    # quarantine, log, continue (don't crash; assets are independent)
```

The function respects `SKIP_TEXT_LEAK_GATE=1` for trauma-axis carve-outs + diagnostic runs. `passed=False` only on `verdict == "LEAK"`; CLEAN / BORDERLINE / NON_ENGLISH_FLAG / GATE_SKIPPED all pass.

`app_slug_from_path()` recognizes three layouts: `chapters/<app>/`, `cast/<app>/`, and `CustomArt/<app>/`. The math-app override (multi-digit numerals OK for `MATH_APPS`) carries through.

#### Gate quarantine

Gate-blocked assets are moved to `labsmith/tmp/text-leak-gate-failed/<asset-kind>/<app-slug>/` (NOT distributed). Inspect, manually decide whether to regen or accept; do NOT `mv` back to the source path without re-auditing.

#### INTENTIONAL_CURRICULUM_SIGNAGE — 6th-category allow-list (2026-06-16)

For chapters where curricular signage (compass cardinals N/E/S/W on a compass scene; angle measures 60° / 120° on a polygon; variable letters x / y in equation visuals; cable-tension RATIOS in bridge engineering scenes; etc.) is intentional and load-bearing per the chapter's curricular surface, declare the allow-list IN the chapter MD's YAML front-matter:

```yaml
---
character: Apprentice Sides
role: ...
gate-allow-text:
  - N
  - E
  - S
  - W
  - 60
  - 120
gate-allow-text-pattern: '^[0-9]{1,3}°?$'   # OPTIONAL regex for ranges (e.g., any angle measure)
---
```

When the audit detects text that would normally LEAK (ENGLISH_WORDS or non-math-app MULTI_DIGIT), it consults the chapter MD's front-matter. If ALL detected text matches the `gate-allow-text` list OR the `gate-allow-text-pattern` regex, the verdict downgrades from `LEAK` → `LEAK_ALLOWLISTED` (PASSING). The audit emits the allow-list match in the per-image JSON for audit-trail clarity.

**Resolution mechanism**:

| Image path pattern | Resolved chapter MD |
|---|---|
| `spark-anvil-site/public/chapters/<app>/chapter_<char>_beat_NN.png` | `<app>-app/Docs/dn-s/chapters/<char>.md` (Tier-1) |
| `spark-anvil-site/public/chapters/<app>/chapter_<char>-advanced_beat_NN.png` | `labsmith/Resources/DN-S-Tier-Upper/chapters/<app>/<char>.md` (Tier-2) |

**When to use the allow-list**:

- Chapter prose explicitly references curricular signage (compass / angle measures / equation variables / ratios / scale labels / etc.)
- Math-app chapters where multi-digit signage IS the curriculum (already handled by `MATH_APPS` set; allow-list is BELT-AND-SUSPENDERS for non-math-app math content like cable-tension RATIOS)
- Trauma-gated chapters where SAMHSA register intentionally surfaces small affect labels in the scene
- Op β R1 accept-residual chapters: bridgeforge/cable (cable-tension RATIOS), fractionforge/equi (equivalent-fraction labels), numbersense/splitter-sasha (digit-split visuals), quillspell/ember (spelling letters)
- Geometryforge curricular bypasses surfaced 2026-06-16: apprentice-sides + compass-wraith (N/E/S/W cardinals), captain-construction (workshop labels), madame-polygon (angle measures + variables), axia-and-theora (background village signage)

**Don'ts**:

- Don't use the allow-list to bypass real defect text (typos / hallucinated brand names / wrong-character signage). The allow-list is for INTENTIONAL curricular content, not accidental leaks
- Don't make the allow-list too permissive (e.g., `gate-allow-text-pattern: '.*'` accepts everything; defeats the gate's purpose)
- Don't omit `gate-allow-text` when SKIP_TEXT_LEAK_GATE=1 was used as the bypass — codify the allow-list in the MD so the next audit doesn't need the env override

**Companion**: when SKIP_TEXT_LEAK_GATE=1 is used to bypass the gate, the OPERATOR SHOULD also add a `gate-allow-text:` entry to the chapter MD so future re-audits don't re-flag the same intentional signage.

#### What this rule does NOT cover

- **`copy_cast_portraits_to_site.sh`** — the gen-side gate inside `gen_cast_portraits.py` is sufficient. Optionally extend the sync script with `--gate-on-sync=1` for belt-and-suspenders. Default off
- **Mascot / topic / modecard / backdrop gen** — separate scripts (`gen_app_illustrations.py` variants); the gate doesn't auto-apply there yet. Pending Item 1 (Queue #971 Phase 5+ portfolio sweep)
- **Achievement badge gen (`gen_app_badges.py`)** — rarity-tier frame treatment merges text via design; flagged but not gate-wired. Future: extend gate to recognize intentional title typography vs accidental signage leaks

#### Audit script resilience flags (Item 4 — codified V9; expanded V10 2026-06-23)

`scripts/audit_image_text_leaks.py` exposes three resilience knobs added after the V8 stall incident (Gemini API hung 14+ min mid-call; killed via SIGINT lost 1197/1692 images of progress with no JSON written):

| Flag | Default | Behavior |
|---|---|---|
| `--call-timeout <seconds>` | 60 | Wraps each `client.models.generate_content()` call in `concurrent.futures.ThreadPoolExecutor.submit().result(timeout=...)`. On timeout, raises + falls into the retry path |
| `--max-retries <N>` | 1 | Total attempts = `max_retries + 1`. On transient failure (timeout / 503 / 429), retries with backoff |
| `--checkpoint-every <N>` | 50 | After every N completed classifications, writes partial JSON to `--json-out` so a stall doesn't lose all progress |
| `--resume <partial.json>` | off | Skips images whose absolute path already appears in `partial.results`. Combine with `--checkpoint-every` for stall recovery |

`SIGINT` (`Ctrl-C`) writes a final checkpoint before `sys.exit(130)` — partial JSON is always preserved.

**When this rule applies** — every audit invocation (portfolio-wide sweep, per-app sweep, spot-check, single-image, gate-mode). The flags are optional but the defaults are tuned for portfolio-scale (1500+ images in ~30 min on Gemini 2.5 Flash classification, with stall-resilient checkpointing).

**Canonical full-portfolio invocation**:

```bash
/usr/bin/python3 scripts/audit_image_text_leaks.py \
    --site-sweep \
    --json-out Docs/AUDIT_IMAGE_TEXT_LEAKS_FULL_<date>.json \
    --call-timeout 60 \
    --checkpoint-every 50
# If a stall recurs mid-sweep:
/usr/bin/python3 scripts/audit_image_text_leaks.py \
    --site-sweep \
    --json-out Docs/AUDIT_IMAGE_TEXT_LEAKS_FULL_<date>.json \
    --resume Docs/AUDIT_IMAGE_TEXT_LEAKS_FULL_<date>.json
```

#### Wave Q CI guardrail (Item 5 — codified V9 + Round 488 audit-script discipline + V10 rule-sync 2026-06-23)

`scripts/check_no_hardcoded_paths.sh` + `.github/workflows/check-no-hardcoded-paths.yml` enforce the § P1 standing directive that scripts MUST use relative paths (not `/Volumes/Data/Projects/GitHub/...` hardcodes). Runs on every PR open + push to main that touches `scripts/**.{py,sh}`.

**Why**: per V8 stall incident root-cause + Round 488 `Docs/AUDIT_DOCS_ONLY_APP_RANKING_2026-06-02.md` inventory bug — scripts with hardcoded absolute paths to the (now-moved) `/Volumes/Data/Projects/GitHub/` root silently fail when the portfolio root moves. The CI guardrail prevents regression at PR time.

**Self-skip mechanism**: the check script reconstructs the forbidden pattern from variables (so its own grep doesn't self-flag) AND filters out its own filename (`check_no_hardcoded_paths.sh`) from the match set. Verified: PASS on clean tree; FAIL with exit 1 on planted regression script containing the hardcoded path.

**Companion rule**: `.claude/rules/portfolio.md` § "P1 — Scripts must use relative paths" is the authoritative spec; this CI guardrail is the automated enforcement. Distributed to portfolio app repos via `scripts/copy_rules_to_repos.sh --apply` (V10 round-close).

#### Cross-references

- `Docs/AUDIT_IMAGE_TEXT_LEAKS_PORTFOLIO_SWEEP_2026-06-13.md` — parent audit (62 LEAKs surfaced)
- `Docs/AUDIT_TEXT_IN_IMAGE_LEAK_SCAN_2026-06-13.md` — original audit policy + category framework
- `Docs/AUDIT_PORTRAIT_BOOK_COVER_TEXT_LEAK_GATE_WIRE_UP_2026-06-15.md` — companion gate adoption audit (this expansion)
- `Docs/RESEARCH_OPTION_V_P3_CARRY_ITEMS_SCOPING_2026-06-15.md` § Item 2 — parent scoping for this expansion
- `labsmith/scripts/audit_image_text_leaks.py` — audit tool + `gate_single_image()` reusable function
- `labsmith/scripts/path_b_wave_runner.sh:96-122` — wave runner gate impl
- `labsmith/scripts/gen_cast_portraits.py` — portrait gate wire-up
- `labsmith/scripts/gen_book_covers.py` — book cover gate wire-up

## Pre-distribute anatomy gate (R-ANATOMY-GATE; 2026-06-29)

**Every newly-generated cast artifact (chapter beat / cast portrait / book cover) MUST pass an anatomy-defect gate before distribution, the same way it must pass the text-leak gate.** Sister rule to R-PATH-B-TEXT-LEAK-GATE. Codified after a user-reported defect ("cast character has 3 hands") + the V25 portfolio anatomy sweep (`scripts/audit_image_anatomy.py --all-sweep`), which surfaced glitches the text-leak gate never looked at (e.g. `chanceforge/flipside` — two faces on one head).

### What the gate blocks (and what it must NOT)

`scripts/audit_image_anatomy.py:gate_single_image()` returns `passed=False` ONLY on verdict `ANATOMY_DEFECT` — a clear UNINTENTIONAL glitch: extra hand/arm/leg/head, six fingers, fused/duplicated/detached limbs, two faces on one head, impossible joints. `CLEAN` and `BORDERLINE` both PASS.

**CRITICAL — intentional stylized/non-human anatomy is NOT a defect and must never be blocked**: octopus-tween with 8 arms, hand-less creatures (snails, birds with wings-not-arms, blobs), cartoon 4-finger hands, partly-hidden hands. The classifier prompt biases toward CLEAN when uncertain to stay low-false-positive. Smoke-tested: Eight-the-octopus (characterforge) = CLEAN ("8 arms, anatomically correct").

### Where it is wired (auto-applies)

| Surface | Wire point | Behavior |
|---|---|---|
| Chapter beats (Path B wave) | `path_b_wave_runner.sh` step 2.6 | Per-beat; fail-fast → `<app>/<slug>:anatomy-gate` in FAILED_LIST; operator regens the beat with `--beat-idx N --no-audio` |
| Cast portraits | `gen_cast_portraits.py` (after text-leak gate, before WebP) | Quarantine to `tmp/anatomy-gate-failed/cast-portraits/<app>/`; retry with `--regen` |
| Book covers | `gen_book_covers.py` (after text-leak gate, before WebP) | Quarantine to gate-quarantine root with `_ANATOMY_FAIL` suffix |

**Direct-pilot workflow** (gen via `pilot_interleaved_ensemble_chapter.py` + manual audit, not the wave runner): the operator MUST run a per-beat anatomy loop alongside the text-leak loop before distributing — `audit_image_anatomy.py --image <beat>.png` per beat; regen any `ANATOMY_DEFECT`.

### Reusable gate function

```python
from audit_image_anatomy import gate_single_image as anatomy_gate
passed, audit = anatomy_gate(png_path, client=client)  # passed=False only on ANATOMY_DEFECT
```

Respects `SKIP_ANATOMY_GATE=1` (rare; deliberately surreal scenes). **Fails OPEN on API error** (a transient classifier failure does not block a wave) — the periodic `--all-sweep` (run after big gen rounds, → `Docs/AUDIT_IMAGE_ANATOMY_*.json`) is the historical-gap backstop, exactly as the Cloudflare prebuild gate backstops the cast-portrait-slug rule.

### Two-gate defense-in-depth (same pattern as R-CAST-PORTRAIT-SLUG)

| Gate | When | Coverage |
|---|---|---|
| Gen-time `gate_single_image()` | every new artifact gen | NEW artifacts in the active gen round |
| Periodic `--all-sweep` | after major gen rounds / on demand | HISTORICAL artifacts across the whole portfolio (~870 portraits + ~3147 beats) |

Both stay; neither replaces the other. New gen scripts MUST call `anatomy_gate()` alongside the text-leak gate.

### Cross-references

- `scripts/audit_image_anatomy.py` — auditor + `gate_single_image()`
- `scripts/audit_image_text_leaks.py` — sibling (text) gate this mirrors
- `Docs/AUDIT_IMAGE_ANATOMY_FULL_2026-06-29.json` — V25 portfolio sweep results
- `.claude/rules/spark-anvil-website.md` § R-PATH-B-TEXT-LEAK-GATE — sister rule

## Chapter hero source-of-truth (R-CHAPTER-HERO-SOURCE; 2026-06-11)

**For multi-beat chapters, beat 0 IS the chapter hero. The top-of-page `chapter_<char>_opener.webp` (rendered via `<ChapterIllustration variant="opener" />`) MUST NOT also render** — doing both creates visual redundancy (two opening-scene heroes within 200px) and wastes gen budget at portfolio scale.

### When the rule applies

| Surface | Multi-beat chapter | Path-A-only chapter |
|---|---|---|
| Cast page `/cast/<app>/<char>` | beat 0 hero (via `InterleavedChapterAudioPlayer`); NO top opener WebP | top opener WebP (no beat 0 exists) |
| Tier-2 page `/cast/<app>/<char>/advanced` | same as above (advanced variant of multi-beat sidecar) | same as above |
| `/stories` index thumbnail | uses `chapter_<char>_opener.webp` (cached on disk; not rendered on chapter page itself) | uses `chapter_<char>_opener.webp` |
| PDF book cover (per-app anthology) | uses `<app>-app/Resources/CustomArt/<app>/cover_book_<tier>.webp` from `gen_book_covers.py` (NOT a chapter asset; #812 premise corrected per `Docs/AUDIT_PDF_BOOK_COVER_COHERENCE_2026-06-11.md`) | same per-app cover (not a per-chapter asset) |

The gate in the Astro template is `!hasMultibeat` for the top opener. `hasMultibeat` derives from `multibeat-chapters.json` (prebuild manifest indexing chapters with sidecar + beat PNGs + audio shipped).

### Why this rule exists

Per user-direct 2026-06-11 late ("should we even need opener illustration now that we have multi-beat illustrations?") + Option B selection of the 5-option opener-deprecation decision matrix in `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md`. Visual redundancy + gen-budget waste + storybook-format intent (text+image alternating from the START) all favored dropping the separate top-hero for multi-beat chapters.

### Don'ts

- Don't render `<ChapterIllustration variant="opener" />` unconditionally on a chapter page — always gate on `!hasMultibeat` (OR equivalent feature-detection if the file naming convention evolves)
- Don't DELETE `chapter_<char>_opener.webp` from `spark-anvil-site/public/chapters/<app>/` — the file still serves `/stories` thumbnail role (per `Docs/AUDIT_PDF_BOOK_COVER_COHERENCE_2026-06-11.md` the PDF cover is `cover_book_<tier>.webp`, NOT `_opener.webp`; the `_opener.webp` only feeds the site thumbnail + Path-A-only chapter-page hero)
- Don't render BOTH `<ChapterIllustration variant="opener" />` AND beat 0 in the same page — that's exactly the visual redundancy the rule eliminates
- Don't bypass `.ic-beat-image-opener` styling — beat 0's hero treatment (max-width 960px + heavier shadow + 18px radius) is what makes it read as a chapter cover rather than another beat. Reducing those values reverts to "just another beat" UX

### Reference impl

- `spark-anvil-site/src/pages/cast/[app]/[char].astro` — gate at line 105 (`{!hasMultibeat && <ChapterIllustration ... />}`)
- `spark-anvil-site/src/pages/cast/[app]/[char]/advanced.astro` — same gate for Tier-2 register
- `spark-anvil-site/src/components/InterleavedChapterAudioPlayer.astro` — `.ic-beat-image-opener` hero styling (960px / 18px / 0 6px 24px)

### Forward gen policy (2026-06-13) — DO NOT generate new opener WebPs

Per user-direct 2026-06-13 ("we are not going with openers anymore. this should be documented in the repo folder"): the gen-side stance is STRONGER than the render-side gate above. **NEW chapter authoring does NOT emit `chapter_<char>_opener.webp` assets.** Multi-beat (5-beat canonical per `.claude/rules/distributed-narrative.md` § R-MULTIBEAT-DEFAULT) is the forward standard; beat 0 (Pro tier) IS the chapter hero on the site AND in the PDF book.

| Direction | Pre-2026-06-13 | Post-2026-06-13 (this directive) |
|---|---|---|
| **New chapter gen** | `gen_app_illustrations.py --chapters` → Pro `_opener.webp` + Flash `_spot.webp` (~$0.18/chapter) | `auto_segment_chapter.py` + `pilot_interleaved_ensemble_chapter.py` → 5 beats (Pro beat 0 + 4 Flash; ~$0.32/chapter). NO standalone opener gen |
| **Forward authoring path** | Single-beat allowed as default | Multi-beat 5-beat canonical (R-MULTIBEAT-DEFAULT); single-beat is a narrow carve-out |
| **Legacy opener WebPs on disk (769 across portfolio)** | Live as chapter-page hero + `/stories` thumbnail + (some) PDF cover | STAY on disk as legacy asset; serve `/stories` thumbnail for Path-A-only chapters + chapter-page hero for the dwindling pre-2026-06-12 single-beat set. Do NOT delete |
| **`/stories` thumbnail for multi-beat chapters** | `chapter_<char>_opener.webp` | **MIGRATION NEEDED** to beat 0 source (`chapter_<char>_beat_00.png`); work-queue item filed |

### Downstream work items (filed 2026-06-13)

Filed in `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § "Opener illustration deprecation":

1. ✅ **SHIPPED 2026-06-27 (V23)** — Migrate `/stories` + cluster thumbnail source for multi-beat chapters → beat 0. `src/components/ChapterIllustration.astro` now imports the `multibeat-chapters.json` manifest and resolves `thumbnail` + `opener` variants to `chapter_<char>_beat_00.webp` for any multibeat chapter (all 582 have `beat_00.webp`). **CRITICAL CONSTRAINT**: the resolver MUST use the static manifest import, NOT `node:fs` existence checks — `node:fs` cannot be bundled under the `@astrojs/cloudflare` hybrid adapter (cluster pages are SSR) and breaks the build. This closed a Cloudflare deploy FAIL where forward-authored multibeat chapters (no legacy `_opener.webp` on disk) 404'd the thumbnail. See work-queue § "V23 P0 — Cloudflare build FAIL: broken `chapter_<char>_opener.webp` thumbnail refs".
2. Strip opener gen from `gen_app_illustrations.py --chapters` (~30 min)
3. Audit non-GambitTales PDF builders for legacy opener-only fallback (~15 min)
4. Companion deletion sweep (DEFERRED until app reaches 100% multi-beat coverage)

### What this rule does NOT cover

- **PDF book cover source-of-truth transition** — separate work item `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § "PDF book cover coherence audit vs PDF book content" handles the PDF builder change from `_opener.webp` to `_beat_00.png`
- **Legacy `chapter_<char>_opener.webp` deletion** — the file remains on disk for `/stories` thumbnail use + Path-A-only chapter-page hero use. Deletion is deferred until both downstream uses have migrated (work items 1 + 2 above + per-app multi-beat 100% coverage)
- **Ensemble chapter Path B** — same rule applies (beat 0 is the hero); no special-casing needed once ensemble chapters move to Path B
- **Edge-case forced single-beat chapters** — extremely rare (trauma-axis chapters where SAMHSA register makes 5-beat infeasible). If a chapter genuinely needs single-beat, surface to user; the chapter retains the legacy `_opener.webp` + `_spot.webp` treatment as documented carve-out

### Cross-references

- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § "Should the opener illustration still exist now that multi-beat illustrations ship?" — the parent strategic question + Option B selection
- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § "PDF book cover coherence audit vs PDF book content" — downstream PDF-axis transition
- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § "Cast portrait + opener illustration coherence audit vs prose + multi-beat illustrations" — audit scope collapses from 3 axes to 2 axes for multi-beat chapters under this rule (portrait + beat 0)
- `.claude/rules/spark-anvil-website.md` § R-PATH-B-PROMPT-PARITY — beat 0 (Pro tier) is the reference seed for downstream Flash beats; removing the separate opener-gen step doesn't change this because beat 0 IS the opener in `pilot_interleaved_ensemble_chapter.py`'s pipeline
- `Docs/CONTEXT_HANDOFF_2026-06-11_P0_ROUND_CLOSED.md` — predecessor round confirming all 53 chapters have beat 0 Pro-tier assets

## Content upload + manifest rebuild discipline (R-CONTENT-UPLOAD-MANIFEST-DISCIPLINE; 2026-06-19)

**Every content upload to spark-anvil-site MUST result in the corresponding freshness manifest being rebuilt before/during the next Cloudflare Workers Builds deploy.** The site's `package.json` `prebuild` chain handles 5 of 6 manifests automatically via filesystem-scan or git-mtime-scan builders. The 6th manifest (`pdfs-recency.json`) lives hub-side and requires explicit re-run after every PDF render wave.

### 6 manifests + rebuild discipline

| Manifest | Builder | Trigger | Operator responsibility |
|---|---|---|---|
| `src/data/cast-recency.json` | `scripts/build-cast-recency-manifest.mjs` | site prebuild | None — auto. Reads git mtime of sidecars + reads `pdfs-recency.json` mirror |
| `src/data/multibeat-chapters.json` | `scripts/build-multibeat-chapter-manifest.mjs` | site prebuild | None — auto. Scans `public/chapters/<app>/` for sidecar + snapshot + per-beat PNG + M4A + VTT sets |
| `src/data/audio-drama-manifest.json` | `scripts/build-audio-drama-manifest.mjs` | site prebuild | None — auto. Scans `public/audio/<app>/*.m4a` |
| `src/data/books-manifest.json` | `scripts/build-books-manifest.mjs` | site prebuild | None — auto. Scans `public/books/*-book.pdf` + `public/books/covers/<app>/{standard,advanced}.webp` |
| `src/data/cast.json` + `src/data/cast-slug-map.json` | `scripts/build-cast-manifest.mjs` + `build-cast-slug-map.mjs` | site prebuild | None — auto |
| **`src/data/pdfs-recency.json`** | hub-side `scripts/build_pdfs_recency_manifest.py` | **manual after every PDF render wave** | MANDATORY: run hub-side; copy to site; commit |

### PDF-recency refresh recipe (after every PDF render wave)

```bash
# In labsmith/
python3 scripts/build_pdfs_recency_manifest.py

# Mirror to spark-anvil-site/
cp Resources/PDFBooks/pdfs-recency.json \\
   ../spark-anvil-site/src/data/pdfs-recency.json

# Commit in spark-anvil-site/
cd ../spark-anvil-site
git add src/data/pdfs-recency.json
git commit -m "PDF recency manifest refresh after <wave-name> render wave"
git push origin <branch>
```

If the manifest isn't refreshed after a PDF render wave, the homepage "Freshly Updated PDFs" strip + the per-app PDF-weight bonuses on the recency comparator stale out — newly-rendered PDFs DON'T surface above older ones, even though they're fresher.

### What NOT to do

- **Do NOT skip the PDF-recency refresh after a render wave** — site prebuild can't know about hub-side `.pdf` mtimes unless the mirror is committed
- **Do NOT auto-run `build-apps-data.mjs`** — destructive; wipes the rich 136-app schema (see ⚠️ banner at `scripts/build-apps-data.mjs:3`). Use targeted Python read+modify+write edits to `apps.generated.ts` instead
- **Do NOT trust filesystem mtime in cast-recency** — it scans git mtime via `git log -1 --format=%aI`; untracked sidecars get `null` and are excluded from the manifest (correct behavior — only committed content surfaces)

### RSS + sitemap per-entry freshness (this PR codification)

`feed.xml.ts` `<entry><updated>` + `sitemap.xml.ts` `<url><lastmod>` use per-entry mtime sourced from `books-manifest.json` (book entries) + `cast-recency.json` (chapter URLs). Build-time `new Date()` is NOT acceptable for either surface — RSS subscribers + search-engine crawlers depend on these timestamps for novelty / recrawl-priority decisions.

When adding new RSS entry types OR new sitemap URL classes, the per-entry mtime MUST be sourced from an existing manifest OR a fresh one MUST be added to the prebuild chain.

### Cross-references

- `Docs/AUDIT_HOMEPAGE_FRESHNESS_UPDATE_DISCIPLINE_2026-06-19.md` — parent audit
- `scripts/build-cast-recency-manifest.mjs` — canonical recency builder (git-mtime based)
- `scripts/build_pdfs_recency_manifest.py` — hub-side PDF recency builder

## Sidecar `tier` field required (R-SIDECAR-TIER-REQUIRED; 2026-06-19)

**Every multi-beat sidecar manifest MUST carry a `tier` field with integer value 1 or 2.** Applies to BOTH source-of-truth sidecars in `labsmith/Resources/AutoSegmentedChapters/<app>/<char>.beats.json` AND distributed copies in `spark-anvil-site/public/chapters/<app>/chapter_<char>.beats.json`.

### Why this rule exists

Surfaced via Wave 4 chanceforge T2 center fix (2026-06-18). The pilot script `scripts/pilot_interleaved_ensemble_chapter.py` resolves the chapter MD path from the sidecar's `tier` field:

- `tier: 1` → `<app>-app/Docs/dn-s/chapters/<char>.md` (Tier-1 source-of-truth)
- `tier: 2` → `labsmith/Resources/DN-S-Tier-Upper/chapters/<app>/<char>.md` (Tier-2 source-of-truth)

Sidecars missing the field silently default to T1 path. Failure mode: T2 chapter regen reads T1 prose → per-beat audio narrates T1 text → audio + on-page T2 prose mismatch → reader perceives the page as broken.

### How to apply

When `auto_segment_chapter.py` emits a new sidecar, it must include `tier: 1` (default) or `tier: 2` (if `--tier 2` flag set). The flag MUST be threaded through wave runners (`path_b_wave_runner.sh --tier 2`).

When manually authoring a sidecar (rare; usually regenerated):

```json
{
  "chapter": "<char>",
  "app": "<app>",
  "tier": 2,
  "beats": [...]
}
```

### Canonical Tier-2 sidecar location + use the full wave runner (2026-07-02)

**Tier-2 sidecars live in a SEPARATE root from Tier-1, keyed by BARE slug — the `-advanced` suffix appears only in OUTPUT filenames, never in the sidecar's own path.** Codified after the 2026-06-30 FractionForge session placed `auto_segment_chapter.py --tier 2` output (which emits `<slug>-advanced.beats.json`) into the Tier-1 root, mixing the two tiers' sidecars.

| Tier | Canonical sidecar path |
|---|---|
| Tier-1 | `Resources/AutoSegmentedChapters/<app>/<slug>.beats.json` |
| Tier-2 | `Resources/AutoSegmentedChapters-Tier2/<app>/<slug>.beats.json` (**bare slug** — NOT `<slug>-advanced.beats.json`) |

**Don't hand-assemble a Tier-2 chapter.** For an end-to-end Tier-2 ship (audio + the full 9-file site set + Tier-1 beat reuse per R-TIER-2-MULTIBEAT-REUSE), use `scripts/t2_coverage_wave_runner.sh <app>:<slug,...>` — it emits the sidecar at the correct Tier-2 root, gens audio-only, distributes m4a/vtt/sidecar/snapshot to `spark-anvil-site/public/chapters/`, mirrors the Tier-1 beats, AND (step 5b, per R-TIER-2-CONTENT-ENTRY) writes the `src/content/chapters/<app>/<slug>-advanced.md` content entry that makes the `/advanced` route build. Hand-assembly reliably misses one of these seams.

### Cross-references

- `Docs/AUDIT_HOMEPAGE_FRESHNESS_UPDATE_DISCIPLINE_2026-06-19.md` § "Companion finding" — surfacing audit
- `scripts/pilot_interleaved_ensemble_chapter.py` — consumer (MD path resolution)
- `scripts/auto_segment_chapter.py` — emitter (`--tier 2` → Tier-2 root)
- `scripts/t2_coverage_wave_runner.sh` — canonical end-to-end Tier-2 wave runner
- `.claude/rules/distributed-narrative.md` § "Dual-tier chapter editions" — parent dual-tier spec
- `.claude/rules/distributed-narrative.md` § "R-TIER-2-MULTIBEAT-REUSE" — Tier-2 illustration-reuse companion rule
- § R-TIER-2-CONTENT-ENTRY (below) — the content-entry seam the wave runner's step 5b closes

## Tier-2 `/advanced` route needs a content-collection entry (R-TIER-2-CONTENT-ENTRY; 2026-06-30)

**A Tier-2 `/advanced` page ONLY builds if a `src/content/chapters/<app>/<char>-advanced.md` content-collection entry exists.** Shipping the `public/chapters/<app>/chapter_<char>-advanced.*` asset set (snapshot + sidecar + beats + audio + vtt) and getting the chapter into `multibeat-chapters.json` is **NOT sufficient** — the route `src/pages/cast/[app]/[char]/advanced.astro` builds its paths from `getCollection('chapters')` filtered to `*-advanced.md`, so with no content entry the route never generates and the page **404s** despite every asset being present.

### Why this bites

The two Tier-2 distribution seams write to **different trees**:

| Tool | Writes | Creates the content entry? |
|---|---|---|
| `scripts/t2_coverage_wave_runner.sh` (full end-to-end) | `public/chapters/` (snapshot/sidecar/beats/audio/vtt) **+ `src/content/chapters/<app>/<char>-advanced.md` (step 5b, added 2026-06-30)** | ✅ now yes |
| `scripts/path_b_tier2_audio_wave_runner.sh` (audio-only) | `public/chapters/` audio + vtt only | ❌ no — assumes sidecar/snapshot/**content entry** already exist |
| `scripts/sync_content_to_site.sh` | both trees (`cp <tier2>.md → <char>-advanced.md`) | ✅ yes (canonical) |

**Reference incident (2026-06-30):** the FractionForge expansion-5 Tier-2 wave (`liner/gather/times/tenth/rank`) distributed all `public/chapters/` assets and the multibeat manifest accepted all 5 (`accepted=728`), but the 5 `/advanced` pages 404'd on the live site — the founding-5 had `src/content/chapters/fractionforge/*-advanced.md` entries and rendered; the expansion-5 did not. Fixed by adding the 5 content entries (spark-anvil-site PR #341) + the wave-runner step 5b (this codification).

### When this rule applies

- Any Tier-2 wave that uses `path_b_tier2_audio_wave_runner.sh` (or hand-distributes only `public/chapters/`) MUST separately ensure the content entry exists (`cp <hub>/Resources/DN-S-Tier-Upper/chapters/<app>/<char>.md → src/content/chapters/<app>/<char>-advanced.md`), or run `sync_content_to_site.sh --app <slug>`.
- `t2_coverage_wave_runner.sh` now does this automatically (step 5b).
- **Verification:** after distribution, `git status src/content/chapters/<app>/` MUST show a `<char>-advanced.md` per shipped Tier-2 chapter. If it doesn't, the `/advanced` pages will 404 post-deploy.

### Companion to R-MULTIBEAT-SNAPSHOT

R-MULTIBEAT-SNAPSHOT ensures the `public/chapters/` snapshot + companion assets are complete (else the manifest silently rejects). R-TIER-2-CONTENT-ENTRY ensures the `src/content/` entry exists (else the route never builds). Both must hold for a Tier-2 `/advanced` page to render — the first governs the multibeat manifest, the second governs `getStaticPaths`.

### Cross-references

- `scripts/t2_coverage_wave_runner.sh` step 5b — the fix
- `spark-anvil-site/src/pages/cast/[app]/[char]/advanced.astro` — `getStaticPaths()` (the consumer that enumerates `*-advanced.md`)
- `scripts/sync_content_to_site.sh` — canonical both-trees sync
- `.claude/rules/distributed-narrative.md` § "R-TIER-2-MULTIBEAT-REUSE" + § "Dual-tier chapter editions" — parent Tier-2 spec

## Gemini API key single-flight discipline (R-GEMINI-KEY-SERIAL; 2026-06-30)

**The entire hub content-generation pipeline shares ONE Gemini API key (`~/.config/labsmith/gemini_api_key`), and that key throttles HARD under load. Run exactly ONE key-consuming operation at a time. NEVER run generation, image-gating, and portrait/cover gen concurrently — serialize them.** Codified after the throttle bit every V24–V28 cast-expansion wave (recurring "gen ONE app at a time; don't run gating concurrently with gen" gotcha in the wave handoffs + memory `cast-expansion-program.md` + `[[spark-anvil-gen-pipeline]]`).

### What shares the key (all of these compete)

Every one of these calls the same Gemini key — running any two concurrently saturates the rate limit and causes stalls / failed calls / degraded throughput:

| Script | Key use | Notes |
|---|---|---|
| `pilot_interleaved_ensemble_chapter.py` | Pro beat 0 + 4× Flash beats + **Gemini 2.5 TTS narration** | ~4–5 min/chapter; **TTS is the slowest step** |
| `path_b_wave_runner.sh` | wraps the pilot script | iterates ALL chapters in an app |
| `gen_cast_portraits.py` | Flash image gen | + inline text-leak + anatomy gates (also key calls) |
| `gen_book_covers.py` | Pro/Flash image gen | + inline gates |
| `audit_image_text_leaks.py` (`gate_single_image`) | Gemini 2.5 Flash classifier | per-image; the text-leak gate |
| `audit_image_anatomy.py` (`gate_single_image`) | Gemini 2.5 Flash classifier | per-image; the anatomy gate |

### The symptom (how to recognize the throttle)

- Generation slows to **~3 images/min** after a heavy run (e.g., a full anatomy `--all-sweep` immediately before a gen wave leaves the key hot).
- Individual `generate_content()` calls **hang** (the V8 stall incident: 14+ min mid-call). The audit script's `--call-timeout` / `--max-retries` / `--checkpoint-every` / `--resume` flags (per § R-PATH-B-TEXT-LEAK-GATE Item 4) exist specifically to survive this.
- Parallel streams don't 2× throughput — they **halve** it (or fail), because the shared limit is the bottleneck, not local CPU.

### The rule (single-flight + overlap only non-Gemini work)

1. **One key-op at a time.** Gen OR gate OR portraits — never two at once. This holds across background jobs too: if a `pilot`/wave gen is running in the background, do NOT start portraits/gating/cover-gen in the foreground.
2. **One app at a time for generation.** Don't fan out gen across multiple apps' chapters concurrently.
3. **Overlap ONLY non-Gemini work with a single background gen stream.** The productive pattern: background ONE gen loop (the long pole), and in the foreground do work that never touches the key — `distribute_cast_chapters.py` (local PIL→WebP), `add_cast_members.py` (targeted `apps.generated.ts` edit), git/`gh` app-repo PRs, doc/queue/memory edits. Portrait gen and image-gating are Gemini work → they must WAIT for the gen stream to finish.
4. **Sequence a wave as:** (a) background the gen for the ungenned apps → (b) during gen, do all non-Gemini distribution + `apps.generated.ts` edits + app-repo PRs for already-genned apps → (c) after gen completes, run image-gating on the new beats → (d) then run ALL portraits serially → (e) then finish distribution + site/hub PRs.
5. **Cool-down before a gen wave.** If a portfolio image sweep (`audit_image_anatomy.py --all-sweep` / `audit_image_text_leaks.py --site-sweep`) just ran, expect the key to be hot; the first gen chapter may crawl. Prefer running big sweeps AFTER a gen wave, not immediately before.

### Bounded-wait pattern for background gen

When a background gen stream holds the key and the remaining work is all Gemini/portrait-dependent, don't idle-poll every few seconds. Run a bounded wait loop that returns when the expected artifact count is reached OR a timeout elapses:

```bash
for i in $(seq 1 18); do
  done=$(find <pilot-dir> -name '*_chapter.m4a' | wc -l | tr -d ' ')
  grep -q "GEN-REST DONE" <gen.log> && { echo "complete"; break; }
  [ "$done" -ge "$EXPECTED" ] && break
  echo "$done/$EXPECTED"; sleep 30
done
```

### When this rule applies

- Every cast-expansion wave (the round-robin program) — the canonical consumer.
- Any one-off chapter regen, portrait remediation batch, or book-cover regen wave.
- Any new Gemini-backed gen script added to the pipeline — it inherits this discipline.

### Cross-references

- `.claude/rules/spark-anvil-website.md` § R-PATH-B-TEXT-LEAK-GATE Item 4 — audit-script resilience flags (`--call-timeout` / `--max-retries` / `--checkpoint-every` / `--resume`) that survive a mid-call stall
- `.claude/rules/distributed-narrative.md` § R-MULTIBEAT-DEFAULT / R-DIR-FEDC-CHAPTER — the authoring + gen pipeline this throttles
- `.claude/rules/audio-pipeline.md` — Gemini 2.5 TTS payload handling (the slowest key-op in the pilot)
- memory `cast-expansion-program.md` + `[[spark-anvil-gen-pipeline]]` — where this gotcha lived pre-codification
- `Docs/CONTEXT_HANDOFF_2026-06-30_V28_SEL_WAVE1_ENOSPC_FIX_SCIENCE_WAVE2.md` § "Key gotchas carried forward" — V28 statement of the same discipline

## Prefer `-latest` model aliases in pipeline scripts (R-GEMINI-MODEL-ALIAS; 2026-07-09)

**Every Gemini-backed pipeline script MUST reference a rotation-proof `-latest` model alias (or the current preview family) — NEVER a pinned mid-generation version ID like `gemini-2.5-flash` that a family rotation can silently 404 out from under a running batch.** Codified after the V60 incident (2026-07-09): mid-V45 the **entire `gemini-2.5` `generateContent` family was retired** — `gemini-2.5-flash`, `gemini-2.5-pro`, `gemini-2.0-flash`, `gemini-2.5-flash-image-preview` all began returning **`404 NOT_FOUND`** — while ~1300 in-flight text-leak audit images errored and every pipeline script hardcoding a 2.5 ID broke at once. (Wrinkle: the retired IDs still appear in `models.list()` with lagging metadata, so a list check is NOT sufficient to confirm a model is live — you must probe `generateContent`.)

### The alias map (verified live 2026-07-09)

| Use | Prefer | NOT (retired/404) |
|---|---|---|
| Flash text / judge / classifier | `gemini-flash-latest` | `gemini-2.5-flash`, `gemini-2.0-flash` |
| Pro text / authoring / rephrase | `gemini-pro-latest` | `gemini-2.5-pro` |
| Flash image gen | `gemini-3.1-flash-image-preview` | `gemini-2.5-flash-image(-preview)` |
| Pro image gen | `gemini-3-pro-image-preview` | — |
| **TTS** (separate lifecycle — see below) | keep `gemini-2.5-flash-preview-tts` **for now** | — |

### TTS is a SEPARATE lifecycle — do not blanket-migrate it

The 2.5 **TTS** models (`gemini-2.5-flash-preview-tts` / `gemini-2.5-pro-preview-tts`) are on a different deprecation lifecycle than the retired 2.5 `generateContent` models and were **re-probed 2026-07-09 as STILL LIVE** (returned audio OK). **Keep them** — changing the TTS model would drift new chapters' voices from the ~819 shipped narrations + dramas all voiced on 2.5 TTS (a founder-level re-voicing decision, not a mechanical migration). The **validated successor** for when 2.5 TTS eventually retires is `gemini-3.1-flash-tts-preview` (also probed OK 2026-07-09). There is no TTS `-latest` alias, so TTS migration is a deliberate, documented switch — not automatic.

### When this rule applies

- Authoring or editing ANY Gemini-backed pipeline script (audit judges, gen, gates, rewriters, TTS).
- A batch/gate suddenly 404s mid-run on a `models/<id>` path → first suspect a family rotation; migrate the pinned ID to the `-latest` alias (or current preview), re-run with `--resume`.
- **Verify a model is live by probing `generateContent`**, never by presence in `models.list()` (the retired 2.5 IDs still list).

### Cross-references

- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § V60 — the incident + full per-script migration table.
- § R-GEMINI-KEY-SERIAL (above) — the sibling single-flight discipline (both govern the one shared Gemini key).
- `Docs/AUDIT_DN_S_MULTI_AXIS_FULL_2026-07-08.md` — V45, where the retirement surfaced.

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
- `Docs/GUIDE_CAST_PAGE_USER.md` — visitor-facing /cast page guide (warm + non-jargon; ages 9-14 readable per R-SITE-CHROME)
- `Docs/GUIDE_CAST_PAGE_DEVELOPER.md` — maintainer-facing /cast page guide (architecture + data sources + load-bearing rules + extension recipes + gotchas + test plan)
- `spark-anvil-hub/scripts/sync_content_to_site.sh` — chapter/audio/illustration distribution from app repos
- `spark-anvil-hub/scripts/normalize_chapter_frontmatter.py` — YAML normalizer for synced chapter MDs (source of truth)
- `spark-anvil-site/scripts/normalize-chapter-frontmatter.py` — in-repo mirror; auto-runs in prebuild on every site build
<!-- END LABSMITH-SYNCED CONTENT -->
