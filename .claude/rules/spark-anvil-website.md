# Spark & Anvil Company Website

The studio brand (Spark & Anvil) ships a company website at `spark-and-anvil.com` (planned domain) that introduces parents/educators/press/kids to the 131-app portfolio.

## Scope of hub for the website (UPDATED 2026-05-25)

**Hub owns the website end-to-end.** The app-repo scope rule (hub ≠ implementation) does NOT apply to the website because the site is markup/content (Astro + Tailwind + TypeScript data files), not portfolio Swift app code. Per user 2026-05-25: "web site is not really code so it's okay" + "you own the website."

**Web clones too (reaffirmed 2026-07-10, ADR-033 / work-queue V67-A):** hub owns the `/play/<app>` web clone of every portfolio app — current AND all future clones — not just the marketing site. The iOS↔web learning-design sync flows through R-CLONE-BIDIRECTIONAL-BACKPORT (hub files a handoff for the iOS direction; the app session files back). Web clones are organized per-app inside the single `spark-anvil-site` Astro project (per-app `src/{pages,lib,data}/play/<app>/` + `public/play/<app>/`, a per-app hub `Docs/web/<app>/` doc folder, a `Docs/REGISTRY_WEB_CLONES.txt`, a `scaffold_web_clone.py`, per-cluster deploy units) — the canonical structure + rationale live in **`Docs/ADR-033_WEB_CLONE_ARTIFACT_ORGANIZATION.md`**.

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

## Web-clone parity is a two-axis Definition-of-Done gate (R-WEB-CLONE-PARITY-DOD; 2026-07-10)

**A `/play/<app>` web clone is NOT "done" — and must NOT be marked shipped — until it satisfies BOTH parity axes against its iOS app, each recorded in the clone's `Docs/web/<app>/PARITY_WEB_VS_IOS.md` ledger with ZERO unexplained 🟡:**

1. **Feature parity** — `R-WEB-CLONE-PARITY` (§ below): every in-scope iOS learning-relevant feature is ✅ parity / 🔄 adapted / ⛔ waived-with-rationale (never a bare 🟡). Recorded in the ledger's feature table + measured against the `## iOS feature inventory`.
2. **UI/UX parity** — `R-WEB-CLONE-UX-PARITY` (§ below): the clone carries the app's visual + interaction *character* (accent/semantic palette from the iOS `*Theme.swift`, IA, per-screen flow, HUD, feedback/motion, states, a11y). Recorded in the ledger's `## UI/UX parity` section + measured against `Docs/web/<app>/AUDIT_UX_PARITY_<date>.md`. **The UI/UX axis is verified by SCREENSHOT ANALYSIS, not by the automated suite alone** — see `R-WEB-CLONE-SCREENSHOT-DOD` (a UI/UX change is not DoD-complete until the surface is rendered, captured, and visually analyzed at desktop + mobile).

Both are **default-parity-with-documented-exceptions**, NOT pixel/behavior identity. The exception taxonomy is shared (platform-only affordance · site-chrome-cohesion substrate · web-platform norm · on-device/COPPA · documented diminishing-returns · founder-direct) — *"it was more work"* is never a waiver (that's a tracked 🟡). Both axes are **symmetric**: a learning-relevant feature or interaction that exists on only ONE surface must be backported to the other or waived, per `R-CLONE-BIDIRECTIONAL-BACKPORT` (hub files the iOS-direction handoff; the app session ships it back).

**Codified per founder-direct 2026-07-10** (*"make sure the web clones … are at feature and ui/ux parity with iOS apps"* + *"codify the feature and ui/ux parity requirements too"*). This clause consolidates the two axis-rules below into one standing ship gate so neither can be silently skipped: it applies to **every** clone (current + future), it is verified at ship time (per the `WEB_CLONE_PATTERNS.md` ship-gate checklist + `WEB_CLONE_SPAWN_WORKFLOW.md` Phase 4), and it is re-verified whenever EITHER surface gains a learning-relevant or UI/UX-character change. **The two `PARITY_WEB_VS_IOS.md` ledger sections are the required, living artifacts** — a clone with an unfilled or stale ledger fails this gate.

## A clone is not shipped until its HUB-SIDE artifacts land + are verified — not just the site PR (R-WEB-CLONE-HUB-SIDE-DOD; 2026-07-15)

**A `/play/<app>` clone is NOT "shipped" — and MUST NOT be claimed shipped — until BOTH halves land: (1) the SITE PR (routes + lib + kits + per-app CSS + `clone.meta.ts`, merged + live-verified) AND (2) the HUB-SIDE artifacts. A clone whose site code is live but whose hub-side artifacts are absent is *site-shipped-but-hub-dark* — a Definition-of-Done violation on the same footing as a missing parity axis.** Codified per founder-direct 2026-07-15 (*"codify the hub-side DoD rule"*). The runbook § 7 already says "two PRs per clone" procedurally; this makes the hub half an explicit, enforceable ship gate — because a clone genuinely *can* merge site-only, and when it does, the hub carries no signal that the clone exists or is done.

### The required hub-side artifacts (the "second PR")

1. **`Docs/web/<app>/` doc-set** — at minimum `RESEARCH.md` (incl. the classified `## Backport candidates` list, R-WEB-CLONE-BACKPORT-MINING), `PARITY_WEB_VS_IOS.md` (the two-axis ledger — the living artifact R-WEB-CLONE-PARITY-DOD gates on), `FEATURE_PLAN.md`, `GUIDE_USER.md`, `GUIDE_DEVELOPER.md` (R-WEB-CLONE-GUIDE-SYNC). `scaffold_web_clone.py` also emits `DEPLOYMENT_RUNBOOK.md` / `PERFORMANCE_BUDGET.md` / `TESTING.md` / `DOCUMENT_CATALOG.md` — keep them.
2. **Porter committed to hub** — `scripts/port_<app>_kits_to_web.py`. The generated `src/data/play/<app>/kits-index.ts` header credits this script by name; a **referenced-but-absent porter is a defect** (the kits-index can't be regenerated / re-verified). The porter MUST reproduce the shipped kits-index + kit JSON exactly (re-runnable / idempotent).
3. **`REGISTRY_WEB_CLONES.txt` row** — appended and flipped to `shipped` (+ authoritative `grep -c '| shipped |'`) AFTER live-verify (R-WEB-CLONE-NO-DARK-SURFACE § merged≠deployed). A live clone with no registry row is hub-dark.
4. **Work-queue `V<N>` entry** — the ship record (pull-first `max+1`; renumber-on-conflict).
5. **iOS backport handoffs** — one `<app>-app/Docs/HANDOFF_FROM_HUB_<FEATURE>_WEB_BACKPORT.md` per ✅ FILE candidate + its 🟡 ledger row (R-CLONE-BIDIRECTIONAL-BACKPORT).

### Why it's load-bearing (the motivating incident)

**2026-07-15 lifequest parallel collision.** A sibling hub session merged the `/play/lifequest` site clone (site PR #684) while the hub-side artifacts landed only in *follow-up* commits. During that window the clone was **site-live but hub-dark**: no `Docs/web/lifequest/` doc-set, no registry row, no work-queue entry. A second session (building the same clone in parallel per the pickup handoff) could not tell *from the hub* that the clone was already done — the hub's own "is this claimed/shipped?" signals (the registry row + the parity ledger + CLAIMS) were the missing half — and duplicated the entire build before the collision surfaced at rebase (R-PARALLEL-HUB-AGENTS 5b). The hub-side artifacts are not paperwork: **the registry row + ledger + CLAIMS release are the coordination signals** that stop parallel duplication, and the parity ledger is where R-WEB-CLONE-PARITY-DOD actually lives.

### When it applies
- **Authoring any clone** → the site PR and the hub-side artifacts are ONE deliverable; don't mark a lane shipped (CLAIMS / work-queue / registry) until both are merged + live-verified. Flip the registry row to `shipped` only after the live-verify (§ 7a).
- **Reviewing a clone / auditing `/play`** → a live `/play/<app>` with a missing `Docs/web/<app>/` doc-set, absent registry row, or referenced-but-absent porter is a defect (site-shipped-but-hub-dark), same weight as a missing parity axis.
- **Resuming / picking the next clone** → read the hub signals first (registry row + `Docs/web/<app>/PARITY_WEB_VS_IOS.md` + CLAIMS). Their *absence* is what makes a half-shipped clone look un-built; their *presence* is the sibling-first "already done, pick another" signal (R-PARALLEL-HUB-AGENTS 5a/5b).

### Cross-references
- `Docs/WEB_CLONE_PICKUP_RUNBOOK.md` § 7 (the "two PRs per clone" the gate formalizes) + § 7a (live-verify before the registry flip)
- § R-WEB-CLONE-PARITY-DOD (the parity ledger this gate ensures actually ships) · § R-WEB-CLONE-NO-DARK-SURFACE (the site-side wired+visible sibling; this is its hub-side analog) · § R-WEB-CLONE-BACKPORT-MINING / § R-CLONE-BIDIRECTIONAL-BACKPORT (the handoff artifacts) · § R-WEB-CLONE-GUIDE-SYNC (the two guides)
- `.claude/rules/workflow.md` § R-PARALLEL-HUB-AGENTS 5a/5b (the collision protocol whose signals are these hub-side artifacts) · § "Verify origin state before claiming coverage"

## The canonical UI/UX best-practices reference for every clone (R-WEB-CLONE-UI-UX-BEST-PRACTICES; 2026-07-14)

**Every `/play/<app>` clone — current AND all future — follows the canonical, evidence-based UI/UX best-practices reference at `Docs/GUIDE_WEB_CLONE_UI_UX_BEST_PRACTICES.md`.** It distills what the portfolio has SHIPPED (the prominence program across ~60 themed clones, the shared `.pc-q-*` / `.ff-stage` design system, the screenshot-DoD discipline) into ONE authoring + review guide, grounded in the learning-science + accessibility literature (cognitive-load theory; the 2025 JSIR children's ed-gaming multicriteria study; elaborated-feedback superiority [Shute; Hattie & Timperley]; the seductive-details meta-analysis; WCAG 2.2 target-size/dragging/focus criteria; POE). Codified per founder-direct 2026-07-14 (*"codify the UI/UX best practices for all future web-clones using what we have shipped so far"*).

**This rule is the umbrella** over the per-axis UI/UX rules — it does NOT replace them; it ties them into one reference so a new-clone author has a single entry point + checklist:
- The **3-card color-coded prominence stack** (accent question card → accent-topped manipulative stage → semantic feedback panel) — § R-WEB-CLONE-QA-PROMINENCE + § R-WEB-CLONE-MANIPULATIVE-PROMINENCE.
- **Reuse the shipped design system** (studio substrate + `.pc-theme-<app>` tokens + shared `mcRound`/`customRound` shells + `.ff-stage`) — never hand-roll; bespoke CSS per-app only (§ R-WEB-CLONE-MERGE-HYGIENE).
- **Accessibility floor** (WCAG 2.2: ≥44px kid targets, keyboard + single-pointer drag alt, visible focus, AA contrast, verdict-not-by-colour, reduced-motion) — a HARD obligation, never waived.
- **Anti-patterns** (decoration on the critical path / clutter / muted feedback / weak hierarchy / dark surface) — the documented flaws.
- **Register + narrative placement** (ages 9–14 warm copy; narrative only at session boundaries).
- **Verification** — the mandatory screenshot-DoD pass (§ R-WEB-CLONE-SCREENSHOT-DOD) + the reusable prominence-treatment recipe.

**When it applies:** authoring any new clone (follow the § 10 checklist from day one); reviewing a clone PR (a UI/UX change that violates the 3-card hierarchy, the quiet-stage guardrail, the accessibility floor, or ships an anti-pattern is a defect — same weight as a missing parity axis); any shared `.pc-q-*` / `.ff-stage` change (it lifts every clone — screenshot at least one adopter). Keep the guide current as the shipped patterns evolve (freshness-horizon 180d).

**Cross-references:** `Docs/GUIDE_WEB_CLONE_UI_UX_BEST_PRACTICES.md` (the guide) · `Docs/WEB_CLONE_PATTERNS.md` (structure + ship gate — the companion) · every § R-WEB-CLONE-* UI/UX rule below · `Docs/RESEARCH_WEB_CLONE_QA_FLOW_PROMINENCE_2026-07-13.md` + `RESEARCH_WEB_CLONE_MANIPULATIVE_PROMINENCE_2026-07-13.md` + `RESEARCH_PREDICT_OBSERVE_EXPLAIN_MECHANIC_2026-07-14.md`.

## Web clones have an automated test suite — Vitest units + Playwright a11y/SEL smoke (R-WEB-CLONE-TEST; 2026-07-12)

**Every `/play/<app>` clone is covered by an automated test suite in `spark-anvil-site`: `npm test` (Vitest — the SPM-unit analog) asserts mechanic LOGIC + hand-authored bank invariants + the shared `_shared/` round-shell contract; `npm run test:e2e` (Playwright — the XCUITest analog) drives every `/play` route headless to assert it renders + throws zero console/runtime errors + (SEL routes) exposes the crisis footer. This layer catches the "builds green, ships wrong" class the build-time gates cannot see (a bank with a wrong answer, a mechanic that throws on load).** Codified per founder-direct 2026-07-12 (*"prioritize testing"*) after implementing `Docs/PLAN_WEB_CLONE_TESTING_STRATEGY_2026-07-12.md` (site PR #483). On its first run the Playwright smoke gate found + fixed a real production crash (`/play/sleuthlab/casefiles` `RangeError` on difficulty-5 cases).

### The two layers (both real, both green — **83 unit spec files + 7 e2e specs** as of 2026-07-14; expanded in site PRs #491 → the 7-wave deepening #499/#502/#503/#506/#508/#510/#514 → the all-shipped-clones deepening #515/#518/#519 → the V178 deepening #525 (**portfolio-wide MC-kit STRUCTURAL invariant gate** over all 821 banks / ~3285 checks) + #526 (**keyboard-nav + accessible-name** e2e gates) — per-mechanic bank-invariant specs for the engine-rich + bespoke clones that had none, **including the chess-engine ⇄ 119-puzzle-bank legality cross-check that caught + fixed 2 real puzzle-data defects** [4 illegal `alternativeMoves`], + the a11y-shell e2e spec. A separate in-session **SEMANTIC** kit audit (V178 workstream 3, `Docs/AUDIT_QUESTION_KITS_SEMANTIC_2026-07-13.md`) caught + fixed real WRONG-answer/mislabel defects the structural gate can't see — fractionforge + discretequest, site PR #529. **Perf refactor (site PR #591, 2026-07-14 — see § R-WEB-CLONE-TEST-PERF below):** as routes grew ~20→414 across 66 clones, the unsharded per-PR run trended toward 30–45 min. The e2e gate is now (a) **sharded** across a CI matrix, (b) **scoped** to the clones a PR touches via `PLAY_ROUTE_FILTER` (a one-clone PR runs ~48 tests, not ~2,138; shared-surface change → FULL), and (c) **tiered** — the heavy `round-play` deep-walk moved OFF the PR gate into a **full sweep** (`play-tests-full.yml`, merge-to-main + nightly). `control-names` was folded into `a11y.spec.ts` (one page load/route), so per-route specs dropped 6→5.)

| Layer | Command | What it asserts | Analog |
|---|---|---|---|
| **Vitest** (`happy-dom`) | `npm test` | `_shared` engine (star bands, streak tiers, level curve, best%/XP/day-streak, first-try scoring contract) + **portfolio-wide MC-kit STRUCTURAL invariants** (`_shared/kits.test.ts`, V178 — globs all 821 `public/play/<app>/kits/*.json`: non-empty prompt+correct, correct ∈ options exactly once, options unique, bloom valid-when-present, ids unique; schema-aware over both authored shapes) + per-mechanic **bank invariants**: tessellation =360°, constellation valid star indices, dichotomous-key terminates, prob-tree branches sum to 1, sentence-combine exactly-one-best, SEL DIR-FEDC fields, sleuthlab difficulty ∈ [1,5], **affine cipher `coprime` items have exactly one option coprime to 26 + `E(x)=(ax+b) mod 26`, null-cipher extraction reproduces `hidden` from `cover`, symbol-cipher encodings don't collide under the Polybius I/J merge, discretequest `computeAnswer` ⇄ explanation cross-check + nPr/nCr/pigeonhole/gcd/isPrime, circle-of-fifths one-accidental-per-step ordering + dominant/subdominant inverse, stellar tracks reference real stages + correct fates, distance-ladder rungs ordered/overlapping + each challenge's method range contains its distance, geometry proof final step reaches its goal, equation-slip brokenIndex/why integrity** | SPM unit tests |
| **Playwright** (Chromium vs `astro dev`) | `npm run test:e2e` (full) · `npm run test:e2e:pr` (round-play excluded) · CI: sharded + scoped, see § R-WEB-CLONE-TEST-PERF | (1) **smoke** — every `/play` route resolves + `<main id="main-content">` renders + **zero console/runtime errors**; (2) **interaction** (`tests/e2e/interaction.spec.ts`) — every route **survives a first interaction** (click the first in-`<main>` control, re-assert zero console/runtime errors — the "a click handler crashes the mechanic" class, one step past a load crash); (3) **round-play deep walk** (`tests/e2e/round-play.spec.ts`) — drives every route through **up to 8 sequential in-`<main>` button clicks** (answer → feedback → Next → results) re-asserting the island never blanks + zero errors across the WHOLE walk (the "2nd click / advance-to-results handler throws" class; flash-aware retry for timed reveals; only clicks `<button>`s so it never navigates off-route). **⚠ Tiered OFF the PR gate (PR #591)** — the wall-clock hog runs in the **full sweep** (`play-tests-full.yml`, merge-to-main + nightly), not per-PR; (4) **SEL-safety** — every SEL (mindforge/coregrealm) route exposes the always-visible crisis footer; reduced-motion honored (never scoped — `routesForApp` enumerates unfiltered); (5) **/play-index** (`play-index.spec.ts`) — the landing's grouped sections + filter; (6) **a11y shell + control names** (`tests/e2e/a11y.spec.ts`) — every route inherits the WCAG shell contract from BaseLayout: `<html lang>` set (3.1.1), non-empty `<title>` (2.4.2), exactly ONE `<main>` landmark (1.3.1), landing routes expose a hero `<h1>` (2.4.6), **AND every visible in-`<main>` `<button>` has a non-empty accessible name (aria-label/text/title/labelledby; WCAG 4.1.2 — folded from the former `control-names.spec.ts` into ONE page load/route by PR #591)**; (7) **keyboard-nav** (`tests/e2e/keyboard-nav.spec.ts`) — every route's first in-`<main>` control is programmatically focusable + Enter-activation doesn't crash the island (WCAG 2.1.1 — the keyboard sibling of (2)) | XCUITest |

### The discipline (joins R-WEB-CLONE-PARITY-DOD + R-WEB-CLONE-GUIDE-SYNC)

- **A new clone / new mechanic ships with tests.** Building a bespoke mechanic with a hand-authored bank → add a Vitest invariant spec next to it (export the bank; the round-shell + a11y are already covered by the shared specs + the auto-enumerated Playwright smoke). A logic change pairs with a test update, exactly like the guide-sync rule.
- **Routes auto-cover:** `tests/e2e/routes.ts` enumerates `/play` routes from `src/pages/play/**`, so a new clone's routes are BOTH smoke-tested AND interaction-tested the moment they land — no spec edit. A new SEL clone must be added to `SEL_APPS` in `routes.ts`. **On a PR the run is SCOPED to touched clones** via `PLAY_ROUTE_FILTER` (§ R-WEB-CLONE-TEST-PERF), so a new clone's routes run on its own PR + then in the full sweep; a shared-surface change runs FULL.
- **Bank export is the only source change units need** — mechanic banks are module-private `const`; add `export` (non-breaking; not imported by `astro build`, so `build:play` is unaffected).
- **Dev-server caveat:** `astro dev` does NOT run the prebuild chapter normalizer, so the Playwright `webServer` command runs `normalize-chapter-frontmatter.py` first (else js-yaml crashes content parsing + breaks island render). Never remove it.
- **Calibration gotchas** (see PLAN § 6): MC/custom rounds SHUFFLE item order (answer by reading the shown prompt, not a fixed label); `/play/<app>/play` routes are param-driven launchers (`?kit=`) that render a no-heading "pick one" fallback bare (assert the `<main>` shell, not a heading).
- **Subresource-404/403 noise is EXCUSED, not a runtime-error failure** (`BENIGN_CONSOLE_NOISE` in `tests/e2e/routes.ts`, shared by smoke + interaction). Chromium reports a failed cross-unit/CDN chrome asset (a `/cast` or `/apps` image, a CDN font/logo) as a **bare `"Failed to load resource: the server responded with a status of 4xx/5xx"` with NO URL in the message text** — so the URL-only benign filter (`favicon|analytics|plausible|cdn\.spark-and-anvil`) can't see it, and it **false-failed every clone's smoke + interaction suite in a play-only / CDN-offline run** (e.g. a local worktree verify). The gate's job is *runtime/script errors* ("a mechanic that THROWS on load / a click handler crashes"); **asset reachability is owned by `check-site-internal-links.py`** (which already excuses cross-unit refs), so the benign filter also excuses `Failed to load resource: the server responded with a status of`. A missing PLAY-unit asset still surfaces via the mechanic's own `fetch().catch` + surface-wiring + the link checker, so no real coverage is lost. **Keep both specs importing the single `BENIGN_CONSOLE_NOISE` constant** — don't re-inline a divergent regex. (Codified 2026-07-12 during the heatforge clone build; site PR with the heatforge clone.)
- **CI (Phase D):** `.github/workflows/play-tests.yml` runs the Vitest + Playwright suites on PRs; `.github/workflows/play-tests-full.yml` runs the exhaustive sweep on merge-to-main + nightly (§ R-WEB-CLONE-TEST-PERF). Editing `.github/workflows/` needs a `workflow`-scoped token the hub PAT lacks — same class as the Cloudflare watch-paths; a workflow-file change ships via a worktree branch + PR (as PR #591 did).

### R-WEB-CLONE-TEST-PERF — the e2e gate is SHARDED + SCOPED + TIERED so per-PR cost doesn't grow with portfolio size (2026-07-14, site PR #591)

**The Playwright cost = `routes × per-route-specs`, and BOTH grow with the portfolio (routes ~20→414 across 66 clones in days). An unsharded, unscoped, all-specs run trended toward 30–45 min and climbing ~linearly. Three standing levers keep the PR gate flat:**

1. **Shard** — the PR e2e job is a CI matrix (`--shard=i/N`, blob reports merged by an aggregator job). The aggregator job keeps the exact required-check name **`Playwright (a11y + SEL-safety smoke)`** (+ `Vitest (bank invariants + shell)`) so branch protection stays valid — **never rename those two job names**; the matrix children (`e2e shard`) are NOT required contexts.
2. **Scope** — a `scope` job diffs the PR: touches a shared surface (`_shared/`, `play.css`, `components/play/`, `pages/play/index.astro`, `clone-types.ts`/`clones.ts`, `layouts/`, `tests/e2e/`, `playwright.config.ts`, `astro.config.mjs`, `package*.json`, build scripts) → **FULL** run (4 shards, `PLAY_ROUTE_FILTER=""`); else → **scoped** to the touched clone slugs (single runner, `PLAY_ROUTE_FILTER=app1,app2`); neither → `__none__` (only the never-scoped SEL crisis-footer + `/play-index` specs run). `routes.ts` reads `PLAY_ROUTE_FILTER`; `routesForApp` (SEL) always enumerates unfiltered. A one-clone PR runs **~48 tests, not ~2,138**.
3. **Tier** — the heavy `round-play` deep-walk (the wall-clock hog, `test.setTimeout(120s)` + 45s walk budget/route) is **excluded from the PR gate** (`--grep-invert "plays a round error-free"`, or `npm run test:e2e:pr`) and runs only in the **full sweep** (`play-tests-full.yml`: push-to-main + nightly cron + dispatch, 6 shards, all specs, all routes). `control-names` was folded into `a11y.spec.ts` (one page load/route).

**When authoring/reviewing:** a new clone's PR auto-scopes to itself (its routes still get the full sweep post-merge). Do NOT add a monotonic/`workers`-halving hack; scale by shard count. If you add a NEW shared build/test input, extend the `SHARED_RE` in the `scope` job so a change to it triggers a FULL run. Local: `npm run test:e2e` (full) · `npm run test:e2e:pr` (round-play excluded) · `PLAY_ROUTE_FILTER=<app> npm run test:e2e:app` (one clone). Reference timing (PR #591 dogfood): full run = 4 shards × ~3.2 min ≈ ~4 min wall-clock vs. the old single ~30–45 min job; scoped one-clone ≈ ~1 min.

### When this rule applies
- Authoring/extending any `/play/<app>` clone → add/extend the mechanic's Vitest invariant spec; run `npm test` + `npm run test:e2e` before shipping (they join `build:play` + surface-wiring in the DoD).
- Reviewing a clone PR that adds a bespoke mechanic with a hand-authored bank + no invariant spec → that's a gap (same weight as a missing parity axis).

### Cross-references
- `Docs/PLAN_WEB_CLONE_TESTING_STRATEGY_2026-07-12.md` (the adopted strategy + implementation record) · site PR #483
- `spark-anvil-site/{vitest.config.ts,vitest.setup.ts,playwright.config.ts}` · `src/lib/play/**/*.test.ts` · `tests/e2e/*` · `.github/workflows/{play-tests.yml,play-tests-full.yml}` (the PR gate + full sweep; § R-WEB-CLONE-TEST-PERF) · site PR #591 (shard + scope + tier)
- § R-WEB-CLONE-PARITY-DOD (the ship gate this joins) · § R-WEB-CLONE-GUIDE-SYNC (the sibling "keep it in sync with the code" discipline) · § R-WEB-CLONE-NO-DARK-SURFACE / § R-PLAY-CSS-PARSE-GATE / § R-SITE-CORE-PARSE-GATE (the build-time gates this complements)

## Screenshot analysis is a MANDATORY gate for UI/UX + Definition of Done (R-WEB-CLONE-SCREENSHOT-DOD; 2026-07-13, made mandatory-per-clone 2026-07-14)

**Screenshot analysis is a MANDATORY ship gate — not optional, not "when convenient." Any UI/UX-affecting change to a `/play` clone (or any site surface), AND every NEW clone at ship time, is NOT done — and NOT DoD-complete — until the surface(s) have been RENDERED, CAPTURED as a screenshot, and VISUALLY ANALYZED by the agent, at BOTH a desktop and a mobile viewport, with the analysis recorded (before/after where it's a refinement).** A clone whose registry row is flipped to `shipped` without a recorded screenshot pass is a DoD violation, exactly as if it were missing a parity axis. The automated suite (R-WEB-CLONE-TEST) asserts a surface *renders, doesn't throw, is keyboard-operable, and has accessible names* — it is BLIND to whether the surface actually *looks right*: visual hierarchy, prominence, colour use, contrast, spacing/dead-space, alignment, font sizing, clipping/overflow, and the question→manipulative→answer→feedback reading order. Only looking at the pixels catches the **"builds green + passes every test + looks wrong"** class. Codified per founder-direct 2026-07-13 (*"codify the rule that screenshots analysis are required for ui/ux testing and definition of done"*), after the prominence-program screenshots drove real fixes automated tests could never have surfaced (a muted "Solve for x", answer options weaker than the question card, an under-used app accent, a small math readout).

### The required step (how)
Render the surface headless and read the PNG back — the agent literally looks at it:
```bash
# In the site worktree (R-SITE-WORKTREE). A tiny throwaway Playwright spec drives the
# route (clicking into a round for practice surfaces) + screenshots at two widths:
#   desktop ≥1280×900  AND  mobile ~402×860  (fullPage)
npx playwright test tests/e2e/_shot.spec.ts   # writes /tmp/shots/<name>-<desktop|mobile>.png
```
Then **Read each PNG and analyze it** against the checklist below; iterate CSS/markup until it holds; **re-screenshot to confirm**. Delete the throwaway `_shot*.spec.ts` before committing (never ship it). The screenshots are a verification artifact, not a committed file.

> **Capture gotcha (V250/V251):** a `fullPage` screenshot of a LONG page (marketing/company pages, `/cast`, a tall practice surface) is downscaled so far when Read back that you **cannot judge spacing/contrast detail** — it's only good for gross "whole-page light-in-dark" scans. To judge layout/spacing, colour/AA, and font sizing, capture **viewport (fold) shots at native resolution** (`fullPage: false` at 1440×900 desktop / 390×844 mobile) plus a mid-scroll shot for section rhythm — those read legibly. Use both: `fullPage` for the overview, fold/native for the verdict. (Iterating against a live `astro dev` in the worktree is fastest — HMR picks up each edit, so re-screenshot is a re-run, not a rebuild.)

### What the analysis MUST cover (the visual checklist)
- **Prominence + hierarchy** — the question card, the manipulative stage, the answer surface, and the feedback panel each read at the intended weight, in the intended order (per R-WEB-CLONE-QA-PROMINENCE + R-WEB-CLONE-MANIPULATIVE-PROMINENCE). No surface out-muscles or is out-muscled by another unintentionally.
- **Colour** — the app accent/semantic palette actually surfaces (not a monochrome beige blur); WCAG-AA contrast holds; verdict never by colour alone.
- **Font** — sizing/weight reads at the child-typography register; math/state readouts are prominent + `tabular-nums`; nothing is too small.
- **Layout** — no dead space that starves the manipulative; no clipping/overflow; the reading column holds; **mobile** is checked, not just desktop (the width where clipping/stacking bugs live).
- **States** — where relevant, capture the answered/feedback/results state, not just the initial load.

### MANDATORY per-clone ship gate (not just per-change)
- **Every NEW clone MUST have a screenshot-analysis pass over EVERY surface it ships** (landing + each learning/practice surface), at desktop + mobile, BEFORE its `REGISTRY_WEB_CLONES.txt` row flips to `shipped`. This is a hard gate on the same footing as the two parity axes + no-dark-surface + the automated suite — a clone is not shippable without it. Capture at least one *interactive* state (answered/feedback/reveal) where a surface has one.
- **The analysis MUST be recorded** — a dated line in the clone's `Docs/web/<app>/PARITY_WEB_VS_IOS.md` DoD sign-off naming the surfaces shot + the verdict (PASS, or the fixes it drove). "I looked at it" with no recorded artifact does not satisfy the gate. Reference pass: MintForge (2026-07-14) — 4 surfaces × desktop+mobile + a Lab feedback state + Budget mobile shock state, PASS.

### When this rule applies
- **A NEW clone at ship time** → the mandatory all-surface pass above (hard gate; gates the registry `shipped` flip).
- Authoring or extending any `/play` clone with a UI/UX change; any edit to the shared `.pc-q-*` / `.ff-stage` prominence surfaces (they lift every clone — screenshot at least one adopting clone); any marketing/site surface change.
- **Reviewing** a clone/site PR with a visual change → the PR body / parity ledger MUST reference the screenshot analysis (before/after for a refinement). A visual change with no recorded screenshot analysis is a DoD gap, same weight as a missing parity axis.
- It IS a MANDATORY axis of the ship gate alongside: R-WEB-CLONE-PARITY-DOD (feature + UI/UX parity) + R-WEB-CLONE-NO-DARK-SURFACE (wired + visible) + R-WEB-CLONE-TEST (renders + a11y) + **this** (looks right, recorded).

### Cross-references
- § R-WEB-CLONE-TEST (the automated suite this complements — tests assert *renders*, screenshots assert *looks right*) · § R-WEB-CLONE-QA-PROMINENCE / § R-WEB-CLONE-MANIPULATIVE-PROMINENCE (the prominence intents the screenshot verifies) · § R-WEB-CLONE-UX-PARITY (the visual-character parity the screenshot measures) · § R-WEB-CLONE-PARITY-DOD (the ship gate this joins) · § R-SITE-WORKTREE (where the render happens)
- `Docs/RESEARCH_WEB_CLONE_QA_FLOW_PROMINENCE_2026-07-13.md` + `Docs/RESEARCH_WEB_CLONE_MANIPULATIVE_PROMINENCE_2026-07-13.md` (the prominence work that screenshot analysis drove)

## UI testing + screenshot-DoD MUST cover DARK MODE, not just light (R-WEB-CLONE-DARK-MODE-TEST; 2026-07-14)

**Every `/play` clone (and every site surface) MUST be verified in BOTH color schemes — `prefers-color-scheme: light` AND `prefers-color-scheme: dark` — by the automated Playwright gate AND the screenshot-DoD pass. A surface that renders + reads correctly in light but is broken in dark (unreadable text on a dark panel, AA-contrast failure, an accent/semantic colour that vanishes, an un-themed white flash) is a defect, exactly as if it failed in light.** Codified per founder-direct 2026-07-14 (*"make sure the UI testing cover dark mode as well because there are a lot of dark mode issues with the web site."*). The site themes via **media queries** (`@media (prefers-color-scheme: dark)` in `global.css` + `play.css` + per-app `.pc-theme-<app>` tokens), so dark mode is the OS/browser default for a large fraction of real users and was previously **untested + un-screenshotted**.

### The two layers (both must cover dark)
1. **Automated (Playwright) — the `chromium-dark` project.** `playwright.config.ts` carries a second project `chromium-dark` (`use: { colorScheme: 'dark' }`) scoped via `testMatch` to the **cheap contract specs** — `smoke` (every route renders + zero console/runtime errors) + `a11y` (shell contract + accessible names) — so every `/play` route + site surface is asserted to render and stay operable in dark too. It is **NOT** run over the heavy `round-play` deep-walk (R-WEB-CLONE-TEST-PERF — the dark axis rides the light gate's shards; CI runs all projects, no workflow edit). This catches the *dark render-crash / dark-only console-error* class automatically going forward. Adding the dark axis is a `playwright.config.ts` change (a shared surface → triggers a FULL scoped run).
2. **Screenshot-DoD (visual) — dark is a required capture, analyzed by IN-SESSION Opus.** The mandatory screenshot-DoD pass (R-WEB-CLONE-SCREENSHOT-DOD) MUST capture **dark AND light** at desktop + mobile for a new clone's surfaces (and for any UI/UX change), because the automated gate is BLIND to *contrast/visibility* — only looking at the dark pixels catches "text disappears on the dark card," a washed-out accent, or an un-themed panel. The `_shot.spec.ts` recipe adds `colorScheme: 'dark'` captures (`test.use({ colorScheme: 'dark' })` or a second context). **The dark PNGs are analyzed by the IN-SESSION Opus agent — the running Claude Code session Reads each PNG and judges it** (founder-direct 2026-07-14: *"should we use in-session Opus to analyze the dark-mode screenshots as part of DoD?"* → **yes**). This is the SAME mechanism the base screenshot-DoD already uses ("the agent literally looks at it") and the same in-session-Opus-judgment precedent as R-WEB-CLONE-CLUSTER-MAP + R-AUTHOR-MODEL-CHOICE — **NOT** a paid vision API. The division of labor: the automated `chromium-dark` gate asserts *renders + operable*; in-session Opus asserts *looks right in dark*. The analysis checks the § R-WEB-CLONE-SCREENSHOT-DOD visual checklist under dark (AA contrast on the dark surface, verdict-not-by-colour still holds, no white flash, accent/semantic colours still legible) and is recorded in the clone's `PARITY_WEB_VS_IOS.md` DoD sign-off naming the dark surfaces shot + the verdict — a dark capture with no recorded in-session analysis does not satisfy the gate.

### Distinct from R-WEB-CLONE-NO-DARK-SURFACE
"Dark **surface**" (R-WEB-CLONE-NO-DARK-SURFACE) = a route/feature that exists in code but is **unwired / unreachable** (nothing to do with colour). "Dark **mode**" (this rule) = the `prefers-color-scheme: dark` *rendering*. Both use the word "dark"; they are unrelated gates — a clone must pass both.

### When it applies
- **Authoring any new clone** → its screenshot-DoD sign-off in `PARITY_WEB_VS_IOS.md` MUST name dark + light captures; the `chromium-dark` gate covers its routes automatically (auto-enumerated, like the light gate).
- **Any UI/UX / CSS change** (`play.css`, `global.css`, a `.pc-theme-<app>` block, a shared `.pc-q-*`/`.ff-stage` surface) → screenshot-verify in dark too; a dark regression is a defect.
- **Reviewing a clone/site PR with a visual change** → the PR must reference the dark screenshot analysis, same weight as the light one.

### Cross-references
- `spark-anvil-site/playwright.config.ts` (`chromium-dark` project) · `tests/e2e/{smoke,a11y}.spec.ts` · `src/styles/{global,play}.css` `@media (prefers-color-scheme: dark)` · ADR-014 (hybrid Liquid Glass — the glass surfaces most at risk in dark)
- § R-WEB-CLONE-TEST (the suite this extends) · § R-WEB-CLONE-TEST-PERF (why dark is scoped to smoke+a11y, not round-play) · § R-WEB-CLONE-SCREENSHOT-DOD (the visual gate this makes dual-scheme) · § R-WEB-CLONE-NO-DARK-SURFACE (the unrelated *unwired* gate) · work-queue V235

## Dark-mode SUPPORT best practices — theme through the shared vars; never render light-in-dark (R-WEB-CLONE-DARK-MODE-SUPPORT; 2026-07-15)

**Every `/play` clone MUST render correctly in `prefers-color-scheme: dark` by theming through the SHARED design-system variables — never by hardcoding light hex on its own surfaces. A clone (or a shared-surface change) that renders bright-white-in-dark, or dark-on-dark / light-on-light unreadable, is a defect on the same footing as a failed parity axis.** This is the *design/authoring* companion to `R-WEB-CLONE-DARK-MODE-TEST` (which is the *gate*): -TEST tells you dark is verified; -SUPPORT tells you how to build so it passes. Codified per founder-direct 2026-07-15 (*"codify dark mode support best practices in repo"*) after V237 found the entire `/play` layer rendered light-in-dark and fixed it with one shared block.

### Why it was broken (the root cause every author must avoid)
The `/play` design system defines its OWN neutral palette vars in `play.css` `:root` — `--ff-paper` (card surface), `--ff-warm` (inset/track/chip), `--ff-anvil` (text), `--ff-outline` (border + hard drop-shadow), `--ff-empty` (manipulable "empty" fill), and the semantic feedback tints `--pc-correct-bg` / `--pc-incorrect-bg`. These are SEPARATE from the site-wide `--sa-*` vars (which `global.css` flips for dark). For a long time the `--ff-*` / `--pc-*-bg` neutrals had **no dark variant anywhere**, so while the marketing/`/cast` pages went fully dark, every `/play` surface stayed bright-white on the dark site. The fix (V237, site PR #683) is a single `@media (prefers-color-scheme: dark)` block near the TOP of `play.css` that dark-themes those shared neutrals + tints, scoped `:root, [class*="pc-theme-"]` with `!important` so it also overrides the ~40 per-app `.pc-theme-<app>` light surface vars without editing each block.

### The best practices (author + review against these)
1. **Theme through the shared vars, never hardcode surface hex.** A clone's bespoke CSS (`src/styles/play/<app>.css`) + its manipulative markup MUST use `var(--ff-paper)` / `var(--ff-warm)` / `var(--ff-anvil)` / `var(--ff-outline)` / `var(--ff-empty)` / `var(--pc-*-bg)` for surfaces, text, borders, and feedback tints — so it inherits the shared dark flip for free. A literal `#fff` / `#faf8f5` / `#2d2d2d` background or text color on a clone surface is the defect: it won't flip and will render wrong in one scheme. (Exception: `color: #fff` ON a saturated accent fill — e.g. a button/chip whose bg is `--ff-forge`/`--pc-correct` — is fine in both schemes; and saturated MANIPULABLE OBJECT colors [the fraction rods, cipher tiles, constellation stars] are intentionally vivid on the quiet stage, per R-WEB-CLONE-MANIPULATIVE-PROMINENCE.)
2. **The stage stays quiet + dark-adaptive; objects stay saturated.** `.ff-stage` uses `--ff-paper` (dark in dark mode) with an accent top-edge; the manipulable objects carry the saturated color. Never give a stage a `background-image` or a hardcoded light fill (both break dark + violate the seductive-detail guardrail).
3. **Per-app `.pc-theme-<app>` blocks set ACCENT identity, not a dark theme.** Keep setting accent vars (`--pc-select`, `--ff-forge`, `--ff-slate`, `--pc-correct`, `--pc-incorrect`) per app; do NOT add a per-clone dark `@media` block — the shared `play.css` block handles neutrals for everyone. If a clone's accent is so dark it's low-contrast as a border/bar on the dark card, pick a slightly lighter accent (identity), don't re-theme surfaces.
4. **Verdict never by colour alone, in EITHER scheme** (WCAG 1.4.1): icon + word + semantic colour; light text on the dark `-bg` tints (`#22371f` green / `#3a2222` rose) keeps AA, exactly as dark text on the light tints does in light mode.
5. **WCAG-AA both ways.** Light text (`#ECE8E3`) on dark surfaces (`#33333a`) ≈ 11:1; verify any bespoke surface pairing holds ≥4.5:1 in BOTH schemes.
   - **When a SHARED dark override must serve a broad accent set, COMPUTE the contrast + prefer the guaranteed-AA neutral over a hue-preserving `color-mix` (V251 lesson).** Flipping the accent-TEXT vars (`--ff-*-text`) for ~40+ clones' worth of accents, a hue-preserving `color-mix(in oklab, var(--ff-forge) N%, #ECE8E3)` **fails AA for dark accents** at every safe ratio (worst accent #1A237E deep-indigo = 3.99:1 at 50/50, still < the 4.5:1 body floor), whereas the light ink `var(--ff-anvil)` clears 11.69:1 vs the darkest surface. So the shared value is `var(--ff-anvil)`; accent HUE still shows in dark via borders/fills/left-bars (`--ff-forge`/`--ff-slate`, not flipped). **General rule:** don't eyeball a shared dark-override colour — compute the WCAG ratio for the WORST member of the set against the darkest surface it lands on; if a hue-preserving mix can't clear AA for all, use the neutral light ink (hue survives elsewhere). A quick oklab-mix + WCAG-contrast calc is a ~30-line script; run it before shipping a portfolio-wide colour override.
6. **Verify by looking, in dark AND light** (the mandatory gate): the screenshot-DoD pass (R-WEB-CLONE-SCREENSHOT-DOD) captures dark + light at desktop + mobile, in-session-Opus-analyzed; the automated `chromium-dark` smoke+a11y (R-WEB-CLONE-DARK-MODE-TEST) asserts render + operable. A shared-substrate CSS change (`play.css`/`global.css`) MUST re-screenshot at least one adopting clone in dark (it lifts all 99).
7. **The `*/`-in-a-block-comment trap** (bit V237): never put a glob/regex/`ff-*`-style token containing `*/` inside a `/* */` CSS comment — it closes the comment early and the css-parse gate fails. Reword (space the stars, or use the var names plainly). See § R-SITE-CORE-PARSE-GATE for the sibling TS form.

### When it applies
- Authoring/extending any `/play` clone → use the shared vars for all surfaces from day one; the shared dark block themes them automatically.
- Reviewing a clone PR → a hardcoded light surface hex, a `background-image` stage, a per-clone dark `@media` block, or a missing dark screenshot is a defect.
- Any change to the shared `play.css` dark block or `global.css` `--sa-*` dark block → re-screenshot an adopting clone in dark (it's portfolio-wide).

### Cross-references
- `src/styles/play.css` `@media (prefers-color-scheme: dark)` (the shared block, V237 site PR #683) · `src/styles/global.css` (`--sa-*` dark) · `Docs/GUIDE_WEB_CLONE_UI_UX_BEST_PRACTICES.md` § dark mode
- § R-WEB-CLONE-DARK-MODE-TEST (the gate this supports) · § R-WEB-CLONE-SCREENSHOT-DOD (dual-scheme visual gate) · § R-WEB-CLONE-MANIPULATIVE-PROMINENCE (quiet stage / saturated objects) · § R-WEB-CLONE-QA-PROMINENCE (the `.pc-q-*` feedback surfaces) · § R-WEB-CLONE-MERGE-HYGIENE (why the theme block stays in `play.css` + bespoke CSS is per-app) · § R-SITE-CORE-PARSE-GATE (the `*/`-in-comment trap) · § R-WEB-CLONE-NO-DARK-SURFACE (the unrelated *unwired* gate) · work-queue V237

## Dark-mode coverage is WHOLE-SITE, not just /play — marketing/company chrome + light-only imagery (R-SITE-DARK-MODE-WHOLE-SITE; 2026-07-15)

**Dark-mode support + verification apply to EVERY site surface — the marketing/company pages (home, `/for-parents`, `/for-educators`, `/mission`, `/about`, `/press`, `/apps`, `/cast`, `/stories`, `/books`, the `/play` index) and the shared chrome (Nav, Footer, hybrid-glass) — NOT only the `/play` clones.** `R-WEB-CLONE-DARK-MODE-TEST` / `-SUPPORT` were written `/play`-scoped; this rule extends them site-wide. Codified per founder-direct 2026-07-15 (*"the rest of the web site also have dark-mode issues too, not just the /play unit"* + *"fix and codify"*) after the V251 audit (`Docs/AUDIT_SITE_DARK_MODE_2026-07-15.md`).

- **Theme through the shared `--sa-*` tokens** (`global.css` `:root` + its `@media (prefers-color-scheme: dark)` flip) — never hardcode a light surface hex on a company page; a new `--sa-*` token gets a dark value in the same change (the marketing-side analog of R-WEB-CLONE-DARK-MODE-SUPPORT's `--ff-*`/`play.css` discipline).
- **Light-only RASTER imagery is the load-bearing trap** (the motivating defect): a PNG/JPG with a **baked opaque light background + no alpha** (logos, badges, illustrations) is invisible on a light surface but renders a **glaring light box on a dark surface**. `lockup.png` (Nav) + `logomark.png` (Footer) did exactly this on every page. Fix options, in order of preference: (a) a transparent-background asset with a **dark-mode variant** (light-ink) swapped via `<picture>`/`prefers-color-scheme`; (b) a **deliberate rounded brand tile/plate** (rounded corners + soft dark-mode ring/border) so the light chip reads as intentional, not accidental — the accepted dark-header pattern for light-only logos (the V251 fix, site PR #700); NEVER (c) leave a full-bleed sharp light rectangle. A CSS `dark:` background/ring on an opaque-bg image only *frames* it — it cannot make the baked background transparent, so rounding+plating is the honest interim until a real dark asset exists.
- **The gate is the SAME two-layer gate, now over marketing routes too:** the `chromium-dark` Playwright project (R-WEB-CLONE-DARK-MODE-TEST) SHOULD enumerate the top-level marketing/company routes (not just `/play/**`) for the render-+-operable assertion; and the mandatory **dark screenshot-DoD** (R-WEB-CLONE-SCREENSHOT-DOD, in-session-Opus-analyzed) covers any company-page or shared-chrome visual change, dual-scheme at desktop+mobile.
- **When it applies:** any change to Nav/Footer/BaseLayout/global.css/`--sa-*`/a company page/a shared raster asset → screenshot-verify dark + light; a light-in-dark surface, a baked-light-bg image box, or a sub-AA company-page text is a defect on the same footing as a `/play` dark defect.

### Cross-references
- `Docs/AUDIT_SITE_DARK_MODE_2026-07-15.md` (the V251 audit) · site PR #700 (Nav/Footer logo tile + `/play` accent-text) · `src/styles/global.css` `--sa-*` dark · `src/components/{Nav,Footer}.astro`
- § R-WEB-CLONE-DARK-MODE-TEST / § R-WEB-CLONE-DARK-MODE-SUPPORT (the `/play` rules this generalizes) · § R-WEB-CLONE-SCREENSHOT-DOD (the dual-scheme visual gate) · § R-SITE-LAYOUT-SPACING (the sibling site-quality rule) · § Liquid Glass policy (the glass surfaces most at risk in dark)

## One shared layout system — 8pt spacing scale + container + reading-measure + section rhythm (R-SITE-LAYOUT-SPACING; 2026-07-15)

**Every site page lays out through ONE shared system — an 8pt spacing scale, a single content container, a 66ch reading-measure for long-form copy, and a consistent section-rhythm token — defined in `global.css`; pages MUST NOT hand-roll ad-hoc widths + spacing per page.** Codified per founder-direct 2026-07-15 (*"almost all web pages on the website have layout and spacing issues. do deep web research if needed"* + *"fix and codify"*). Evidence base: `Docs/RESEARCH_SITE_LAYOUT_SPACING_BEST_PRACTICES_2026-07-15.md`; audit: `Docs/AUDIT_SITE_LAYOUT_SPACING_2026-07-15.md`.

### Why (the systemic root)
"Almost all pages" = a MISSING SHARED SYSTEM, not N page bugs. `global.css` had `--sa-*` *colour* tokens but **no spacing scale, container, section-rhythm, or measure primitive**, and `BaseLayout` wraps content in a bare `<main><slot/></main>` — so every page hand-rolled its container width + spacing, and they drifted (measured: content max-width across `src/pages/*.astro` split six ways — `max-w-3xl` ×70, `max-w-4xl` ×54, `max-w-6xl` ×24, `max-w-2xl` ×19, `max-w-5xl` ×8, `max-w-7xl` ×1). Columns + section gaps jump page-to-page. Same structural cause + fix as the dark substrate (V237): add the shared system, theme through it.

### The standard (author + review against these)
1. **8pt spacing scale** — all padding/margin/gap from `--space-*` (4·8·12·16·24·32·48·64·96; 4pt half-step for fine cases). No arbitrary one-off values. Odd bases (5pt) forbidden (split-pixel centering).
2. **`internal ≤ external`** (Gestalt proximity) — space *around* a group ≥ space *within* it (card outer margin ≥ inner padding; section rhythm ≥ item gaps). Cramped or floating groupings are the violation.
3. **One container** — `.sa-container` (single content `max-width` + responsive gutters 16→24→32px), NOT per-page `max-w-3xl/4xl/6xl/...` drift. Always `max-width`, never fixed `width` (WCAG 1.4.10 Reflow).
4. **Reading measure ≤ 66ch** for long-form copy (`.sa-prose`, `max-width: 66ch`) — classic 50–75ch optimum; **WCAG hard cap 80ch**; mobile 30–50ch. Long-form pages (mission/about/method) are the ones most at risk.
5. **Consistent section rhythm** — section-to-section vertical spacing is a token (`--sa-section-y`, responsive clamp), not eyeballed per page. Inconsistent section rhythm is the #1 "unpolished" signal.
6. **Accessibility floor (hard, never waived)** — WCAG **1.4.10 Reflow** (reflow to 320px-equiv, no 2-axis scroll; `max-width` + flex/grid + `overflow-wrap: break-word`, never `overflow:hidden` clipping zoom) + **1.4.12 Text Spacing** (layout survives user line-height 1.5 / paragraph 2× / letter 0.12× / word 0.16× → no fixed heights on text containers; size in rem/em) + ≥44px kid targets + body line-height ≥ 1.5.
7. **The scale is a guide, not a straitjacket** — a deliberate off-scale value that reads better is fine; document it. The scale removes *arbitrary* decisions, not *deliberate* ones.
8. **Verify by looking** (the mandatory gate) — any layout/spacing change is screenshot-DoD'd (R-WEB-CLONE-SCREENSHOT-DOD) at desktop+mobile, dark+light.

### Rollout
- The shared system (`--space-*` + `.sa-container` + `.sa-prose` + `.sa-section` + `--sa-section-y`) is added to `global.css` as **non-breaking additions** (nothing consumes them until migrated → zero regression risk). V250.
- **New pages MUST use it from day one.** Existing pages **migrate opportunistically, in small screenshot-verified batches** — NOT a blind 26-page rewrite (a bad blanket container change regresses intentional wide grids like `/apps` filters + `/cast` gallery). The per-page migration is tracked (work-queue V250).

### When it applies
Authoring any new site page (use `.sa-container`/`.sa-prose`/`.sa-section` + the scale from the start); any layout/spacing edit (through the tokens, screenshot-verified); reviewing a site PR (a new ad-hoc `max-w-*` + hand-rolled spacing instead of the shared system is a defect; an un-verified visual change is a defect).

### Cross-references
- `Docs/RESEARCH_SITE_LAYOUT_SPACING_BEST_PRACTICES_2026-07-15.md` (evidence) · `Docs/AUDIT_SITE_LAYOUT_SPACING_2026-07-15.md` (audit + per-page migration tracklist) · `src/styles/global.css` (the shared system) · `src/layouts/BaseLayout.astro`
- § R-WEB-CLONE-SCREENSHOT-DOD (the mandatory visual gate) · § R-SITE-DARK-MODE-WHOLE-SITE (the sibling site-quality rule) · § Liquid Glass policy (ADR-014) · work-queue V250

## A device-specific feature is SKIPPED, never a reason to skip the whole app (R-WEB-CLONE-DEVICE-FEATURE-SKIP; 2026-07-12)

**Requiring device-specific functionality is NOT a clone-eligibility blocker. If a feature needs a capability the browser cannot deliver on-device — AR/RealityKit/ARKit, Vision, CoreMotion/gyroscope, camera/mic capture, real-time haptics, Game Center, MultipeerConnectivity, SpriteKit *physics*, on-device FoundationModels — that ONE feature is skipped for the web clone (⛔ waived · platform-only, OR 💡 iOS-ENHANCE if it delivers novel LEARNING); the REST of the app MUST still be ported to the web.** Codified per founder-direct 2026-07-12 (*"loosen the blocker check: if a feature requires device-specific functionality, then that feature can be skipped for the web clone. the rest of the app should be ported to web"*).

### What this changes — the "hard-blocker count" is a FEATURE filter, not an APP gate

The census method in `AUDIT_WEB_CLONE_NEXT_RANKING*` historically used a **hard-blocker grep** (`import RealityKit|ARKit|Vision|CoreMotion|AVAudioEngine`, `SKPhysicsBody`, `MultipeerConnectivity`) and **deferred whole apps** when the count was high (e.g. cubesensei hard-blk=29 → "deferred / not-yet-portable"). **That whole-app-defer is now wrong.** A high hard-blocker count means "this app has *several* device-specific features to waive," NOT "this app can't be cloned." Almost every portfolio app has a **portable learning core** — the 16×25 (or richer) MC kit banks + the deterministic mechanics + the theme + the DN narrative — and that core MUST be ported even when the flashiest native feature can't come along.

- **The blocker grep now answers "which features do I waive?"**, per-feature, during the Phase-2 deep-read + the parity ledger — NOT "do I clone this app?" at selection time.
- **Selection eligibility** is now: does the app have a **built, portable learning core** (real Swift + kits OR a deterministic bespoke mechanic)? If yes → it is a clone candidate. The device-specific features are handled by the waiver taxonomy, exactly like any other parity gap.
- **The waiver is still documented, never silent** — each skipped device feature is a ⛔ row (platform-only affordance) OR a 💡 iOS-ENHANCE advisory (if it's a *novel learning* surface the web genuinely can't deliver, per `R-WEB-CLONE-BACKPORT-MINING`), each with a one-line rationale in the parity ledger / RESEARCH candidate list. A skipped device feature is compliant; an *undocumented* skip is a defect. "It was more work" is still never a waiver — that's a 🟡 gap.
- **SpriteKit alone is still not even a waiver trigger** — decorative SpriteKit arenas re-render as SVG/DOM (the learning surface ports); only genuine *physics* (`SKPhysicsBody`) or the other device capabilities above are candidates to skip.

### The newly-eligible tail (this rule unlocks)

Apps previously parked in the ranking's *"Deferred / not-yet-portable"* bucket for a high hard-blocker count — **cubesensei · labsmith · curiosityquest · quillspell · wildlens · levelforge · escapeforge** — are now **clone-eligible**: port their learning core + deterministic mechanics, waive the device-specific feature(s). Each still needs a Phase-2 deep-read to (a) confirm a portable learning core exists and (b) enumerate which features get the ⛔/💡 treatment. They join the candidate pool as a BATCH6 tier.

### When this rule applies
- **Clone selection** — never defer an app *solely* because of a hard-blocker count; assess the portable learning core instead.
- **Phase-2 deep-read + parity ledger** — classify each device-specific feature as ⛔ (platform-only) or 💡 (iOS-ENHANCE novel learning); port everything else.
- **Reviewing a clone PR / ranking doc** — a whole-app "deferred: not portable" verdict that is justified *only* by a blocker count (not by "no portable learning core") is now a defect.

### Cross-references
- § R-WEB-CLONE-PARITY (the waiver taxonomy this rule feeds) · § R-WEB-CLONE-BACKPORT-MINING (the 💡 iOS-ENHANCE class for device-specific *novel learning*) · § R-WEB-CLONE-PARITY-DOD (the ship gate)
- `Docs/AUDIT_WEB_CLONE_NEXT_RANKING_BATCH4_2026-07-11.md` § "Census method" + § "Deferred / not-yet-portable" (updated to reflect this loosening)
- `Docs/WEB_CLONE_PICKUP_RUNBOOK.md` § 0 (SELECT) — the selection step this rule governs

## Web-app clones must keep feature parity with their iOS app (R-WEB-CLONE-PARITY; 2026-07-08)

**A browser learning-app clone of a portfolio iOS app (the `/play/<app>/*` route tree — FractionForge is the first, `/play/fractionforge`) MUST maintain feature parity with that app's LEARNING-RELEVANT features, UNLESS a specific delta is EXPLICITLY WAIVED with a documented rationale in the app's parity ledger.** Parity is the default; every gap is either closed or explicitly justified — never silently dropped. Codified per user-direct 2026-07-08 (*"codify the requirement that fractionforge iOS app and web page need to have feature parity unless explicitly allowed not to"*).

### What "feature parity" covers (and what it doesn't)

Parity is measured on **learning-relevant + pedagogy-load-bearing** surfaces, NOT pixel-identical UI:

- **IN scope (must reach parity or be waived):** the curricular manipulatives / scene modes, the question/kit content, the scaffolding discipline (articulate-before-hint / PolyaScaffold), the DN-S cast + narrative surfacing, co-op / pass-and-play modes, the engagement loop (streak / weekly challenge / boss-encounter / mastery gating), progress + mastery tracking, accessibility, and the anti-shame + narrative-placement disciplines (`R-NARRATIVE-BETWEEN-NOT-DURING` / `R-GUARD-THE-RATIO`).
- **OUT of scope (never a parity obligation):** native-only affordances (SpriteKit particle polish, haptics, Live Activities, Widgets, App Intents/Siri, Game Center), platform chrome, and **pixel-identical** layout/styling. A web-native equivalent of a native affordance satisfies parity (e.g. SVG manipulative ≈ SpriteKit manipulative; a linked site chapter reader ≈ an in-app reader). **Note:** the app's *visual identity + interaction character* (palette, typographic register, IA, feedback/motion patterns) is a SEPARATE, IN-scope obligation governed by **`R-WEB-CLONE-UX-PARITY`** below — "not pixel-identical" is not "not visually faithful."

### The parity ledger (required artifact)

Each web-clone app maintains a parity ledger — `spark-anvil-hub/Docs/web/<app>/PARITY_WEB_VS_IOS.md` (per ADR-033; legacy flat `Docs/PARITY_<APP>_WEB_VS_IOS.md` for pre-2026-07-10 clones) — enumerating every in-scope iOS feature → web status, one of:

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

- `Docs/web/fractionforge/PARITY_WEB_VS_IOS.md` — the first/reference parity ledger
- `Docs/web/fractionforge/PLAN_WEB_CLONE.md` + `Docs/web/fractionforge/RESEARCH.md` — the web-clone design
- `Docs/AUDIT_FRACTIONFORGE_PORTFOLIO_LIFT_2026-07-08.md` — the iOS feature inventory the ledger measures against
- `.claude/rules/distributed-narrative.md` § R-CAST-EXPANSION-INTEGRATION — sibling "authored ≠ integrated" discipline
- § "Web-app clone" scope above (hub owns the web; `/play/*` is a learning app distinct from the marketing site)

## Web-clone UI/UX parity — the clone must carry its iOS app's visual + interaction character (R-WEB-CLONE-UX-PARITY; 2026-07-10)

**A `/play/<app>` web clone MUST reproduce its iOS app's UI/UX *character* — visual identity + interaction design — to a reasonable degree, UNLESS a specific delta is EXPLICITLY WAIVED with a documented rationale in the clone's UI/UX parity ledger.** This is the visual/interaction sibling of `R-WEB-CLONE-PARITY` (which governs *learning-feature* parity). Codified per user-direct 2026-07-10 (*"do full audit of fractionforge and grammarforge ios app ui/ux and create ui/ux parity for their web clones with reasonable exceptions. codify the ui/ux parity requirements with reasonable exceptions"*).

`R-WEB-CLONE-PARITY` says the clone must have the same *features*; this rule says it must *look and feel like the same app*. Both are default-parity-with-documented-exceptions; neither is pixel-matching.

### What UI/UX parity covers (IN scope)

Measured on the app's **identity + interaction character**, NOT pixel geometry:

- **Visual identity** — the app's signature **accent/primary palette** (from its iOS theme file, e.g. `<App>Theme.swift` — the authoritative source, NOT the descriptive hero-color registry), **semantic colors** (correct-green / incorrect-red / hint-amber), **typographic register** (weight/scale/rounded-vs-serif feel), and **corner-radius + surface** language. **Accent-source precedence when there is NO `*Theme.swift`** (2026-07-15, focusforge): many apps ship no theme file and use the system `AccentColor` asset (often empty/default). Then the authoritative accent identity is the app's **`apps.generated.ts` `heroColor`** (the live site data), NOT the `Docs/REGISTRY_APP_HERO_COLORS.md` entry — that registry frequently carries a speculative/"TBD-verify" descriptor that contradicts the shipped heroColor (focusforge: registry said "Focus-purple TBD" while heroColor + the DN retrofit said `#81C784` SEL green → the green is authoritative). Precedence: `*Theme.swift` → `apps.generated.ts heroColor` → (only if both absent) the hero-color registry as a last-resort hint to confirm with the founder.
- **Information architecture + navigation** — the home/landing IA, the way modes/mechanics/kits are presented (tile grid vs list), and the home → practice → results flow.
- **Interaction + feedback** — selection states, correct/incorrect treatment (color + the *kind* of motion), hint reveal, explanation surfacing, and the results/celebration moment (stars / XP tally / level).
- **Gamification chrome** — the score/XP/level/streak HUD *presence* and shape.
- **States + a11y** — empty/loading/error treatment; reduced-motion, ARIA/VoiceOver-equivalent labels, WCAG-AA contrast (a11y is a HARD obligation, never waived for cost).

### What counts as a REASONABLE exception (the waiver taxonomy)

A UI/UX delta may be recorded **⛔ waived** (or **🔄 adapted** when a web-native equivalent stands in) only for a concrete, documented reason:

1. **Platform-only affordance** — haptics, SpriteKit particle polish, Live Activities, Widgets, native nav chrome, the avatar studio. A web-native equivalent (CSS transition ≈ UIKit spring; a color-flash ≈ haptic; an SVG scene ≈ a SpriteKit scene) is **🔄 adapted**, not a gap.
2. **Site-chrome cohesion (the canonical example)** — the clone lives inside `spark-and-anvil.com`, whose brand register is the **chunky-cartoon studio identity** + hybrid Liquid-Glass accent (ADR-014 / § R-SITE-CHROME). Retaining that shared **material substrate** (bold outline + hard drop-shadow cards from `play.css`) instead of pixel-matching the iOS app's flat-glass surface is a legitimate **🔄 adaptation** — the clone adopts the app's *accent palette + semantic colors + IA + interaction patterns* on top of the studio substrate. Per-app *identity* is IN scope; the *substrate* is a documented adaptation.
3. **Web-platform norm** — a native pattern whose web-idiomatic form differs (e.g. a native menu-picker → a `<select>`; a tab bar → top nav) is 🔄 adapted.
4. **On-device / COPPA** — anything needing accounts/server/off-device data (parent dashboards behind auth, cross-device sync) — auto-waivable, strongest waiver.
5. **Diminishing-returns, DOCUMENTED** — a high-effort, low-learning-value surface (e.g. a full progress-dashboard with heatmaps/trend-charts, a 16-mode adventure hub) may be scoped down with a one-line rationale + a 🟡 follow-up if worth revisiting. **"It was more work" ALONE is NOT a waiver** — that's a 🟡 gap (a tracked item). Diminishing-returns means *effort ≫ learner/identity value*, stated explicitly.
6. **Founder-direct** — the user approves a specific delta.

### The UI/UX parity ledger (required artifact)

Each clone's `PARITY_WEB_VS_IOS.md` gains a **`## UI/UX parity`** section (a sibling to the feature table), enumerating each UI/UX surface (visual identity · IA/nav · each screen · HUD · feedback/motion · states · a11y) → status: ✅ **parity** · 🔄 **adapted** (web-native/substrate equivalent — note it) · 🟡 **gap** (open work item) · ⛔ **waived** (rationale). Same discipline as the feature ledger: a 🟡 is a defect, a ⛔/🔄 needs a rationale. Measured against the app's iOS UI/UX inventory — captured in `Docs/web/<app>/AUDIT_UX_PARITY_<date>.md` (the audit this ledger scores against; parallels how the feature ledger measures against the `## iOS feature inventory`).

### Symmetric backport (inherits R-CLONE-BIDIRECTIONAL-BACKPORT)

UI/UX parity is symmetric like feature parity: a *learning-relevant* interaction the web clone introduces that the iOS app lacks (e.g. a keyboard-first speed mode) must be backported (iOS handoff) or waived. Pure web-substrate styling (the chunky-cartoon cards) is NOT a backportable feature — it's a 🔄 adaptation, never an iOS-backport gap.

### When this rule applies

- Authoring or extending any `/play/<app>` clone → theme it to the app's palette + semantic colors + IA from day one; fill the `## UI/UX parity` ledger section.
- Auditing a clone → enumerate the UI/UX ledger; every 🟡 is a work item, every ⛔/🔄 needs a rationale.
- The two-guide sync (`R-WEB-CLONE-GUIDE-SYNC`) + the feature ledger (`R-WEB-CLONE-PARITY`) + this UI/UX ledger update together when a clone's look/feel changes.

### Cross-references
- `Docs/web/fractionforge/PARITY_WEB_VS_IOS.md` + `Docs/web/grammarforge/PARITY_WEB_VS_IOS.md` — the `## UI/UX parity` ledger sections
- `Docs/web/fractionforge/AUDIT_UX_PARITY_2026-07-10.md` + `Docs/web/grammarforge/AUDIT_UX_PARITY_2026-07-10.md` — the iOS UI/UX inventories this rule measures against
- § R-WEB-CLONE-PARITY (feature sibling) · § R-CLONE-BIDIRECTIONAL-BACKPORT (symmetric backport) · § R-SITE-CHROME + ADR-014 (the studio substrate the site-cohesion exception rests on)
- `src/styles/play.css` — the shared `/play` stylesheet; per-app themes are `.pc-theme-<app>` scopes that override the palette variables (the implementation seam for accent parity)

## The question→answer→feedback flow is the shared PROMINENT surface — feedback is the climax, not a muted footnote (R-WEB-CLONE-QA-PROMINENCE; 2026-07-13)

**The question→answer→feedback flow is, after the manipulative itself, the MOST prominent element of every clone — and it is rendered by TWO shared shells (`src/lib/play/_shared/mcRound.ts` for the 16×25 MC kits + `customRound.ts` for bespoke mechanics), so its design is portfolio-canonical, not per-clone.** Codified per founder-direct 2026-07-13 (*"the question then answer flow for all web clones … should be the most prominent besides the actual manipulatives themselves … more functional, intuitive and engaging and especially prominent."*), implemented in site PR #527 on the evidence in `Docs/RESEARCH_WEB_CLONE_QA_FLOW_PROMINENCE_2026-07-13.md`.

The shared, canonical treatment (do NOT regress it, and reuse it — never hand-roll a per-clone Q&A surface):
- **Feedback is the dominant post-answer element** — a full-width `.pc-q-feedback` panel (bold outline + hard shadow + per-app `-bg` tint) carrying an **icon + verdict WORD + the explanation at body scale**. Elaborated feedback is the biggest learning lever (Hattie & Timperley / Shute); it was previously buried in muted `.ff-meta`. `customRound` keeps its write-`textContent` `ctx.feedback` contract (`:empty` hides until written; `complete(scored)` color-codes).
- **Verdict never by color alone** (WCAG 1.4.1): ✓/✗ icon + word + semantic color; **dark text on the `-bg` tint keeps AA** (color rides border + icon), so a low-contrast green/red is never text.
- **Big labeled choice cards** (`.pc-q-choice`, ≥48px, A/B/C key chip that is `aria-hidden` so the accessible name stays the option text) and a **goal-gradient progress bar** (`.pc-q-progress`). **The answer surface must carry the SAME weight as the question card** — a bespoke manipulative's answer options (e.g. EquationQuest's `.eq-move`) are upgraded to answer-cards (≥52px, bold, an accent left-edge, a hover lift), never left as plain footnote buttons that the question card out-muscles.
- **State/math readouts are prominent + `tabular-nums`** — a manipulative's equation/state readout (e.g. `2x + 3 = 11`, `So far: x − 3`) is a focal element (large, bold, tabular numerals), not small serif text lost beside the stage.
- **The question is a prominent accent "question card"** (`.pc-q-stem`, V180) — big bold type on the studio card substrate (bold outline + hard shadow) with a per-app `--pc-select` **accent left-bar**, as visually weighty as the answer surface. This is load-bearing: when V179 first shipped, the plain-text stem was out-muscled by the bordered feedback/choices ("not prominent at all" — founder). The hierarchy reads accent **question card → choices → semantic feedback panel** (the question's left-bar is accent-colored; the feedback's is green/red). Keep the ≤~62ch reading column.
- **Anti-shame** — neutral wrong-answer copy, private, the round always advances; bespoke reveal uses a neutral tint, never a harsh red.
- **Prominence via clarity, NOT decoration** — no ambient/during-solve motion (the seductive-detail trap; honors R-NARRATIVE-BETWEEN-NOT-DURING + R-GUARD-THE-RATIO); reduced-motion fallbacks; `aria-live` feedback + focus-to-Continue.

The shared `.pc-q-*` classes live in the base `play.css` (not a per-app block). A clone gets this for free by rendering through the shared shells; the `_shared` Vitest contract + the Playwright round-play/interaction/keyboard/control-names/a11y gates (R-WEB-CLONE-TEST) keep it green. When editing either shell, keep the public API (`McRoundOpts`/`CustomRoundOpts`/`RoundCtx`) identical — ~200 call sites depend on it.

**▶ Playbook:** the prescriptive treat-vs-no-op decision tree + copy-paste CSS recipes + per-manipulative-type reference treatments live in **`Docs/GUIDE_WEB_CLONE_PROMINENCE_BEST_PRACTICES.md`** (distilled from the 2026-07 sweep). Use it when building/reviewing any practice surface.

## The manipulative is a prominent CARD/STAGE — same studio treatment as the Q&A cards, quiet background (R-WEB-CLONE-MANIPULATIVE-PROMINENCE; 2026-07-13)

**The interactive MANIPULATIVE (the hands-on surface — fraction bar, ray-trace bench, cipher wheel, spinner, grid…) is, together with the Q&A flow, the most prominent element of a clone, and it wears the SAME studio card treatment as the `.pc-q-*` question/answer cards** — the shared `.ff-stage` class (bold outline + hard drop-shadow + whitespace isolation + centering). Codified per founder-direct 2026-07-13 (*"make all the manipulatives prominent too"* + *"should the manipulatives have the card treatment like the question and answer cards too?"* → **yes**), on the evidence in `Docs/RESEARCH_WEB_CLONE_MANIPULATIVE_PROMINENCE_2026-07-13.md`; foundation shipped site PR #531 (fractionforge pilot).

- **The card frame is a STRUCTURAL signifier, not decoration** (research directive 2) — it says "this is the work surface," so it's on-thesis, and it makes the screen read as a coherent hierarchy: **question card → manipulative stage-card → feedback card.**
- **The seductive-detail guardrail (directive 5, load-bearing):** the CARD/CONTAINER gets the outline+shadow, but the manipulative's **background stays quiet** — flat fill, **never a `background-image`**, no ambient/idle animation on the stage; saturated accent lives on the manipulable **OBJECTS**, not the surface; no mascots/particles on the active stage (narrative stays at session boundaries — R-NARRATIVE-BETWEEN-NOT-DURING + R-GUARD-THE-RATIO). Prominence comes from **size + isolation + instant responsiveness**, never spectacle.
- **Shared primitives** (base `play.css`, adopt per-clone): `.ff-stage` (the card — carries an **accent top-edge** in the app's `--pc-select` so the practice stack reads as a color-coded hierarchy [accent question card → accent-topped stage → semantic feedback] instead of three identical beige boxes; colour rides the frame, the surface stays quiet), `.ff-stage--dominant` (opt-in viewport-share — a blanket `min-height` distorts small manipulatives, so it's per-clone), `.ff-draggable` (grab-cursor + grabbing shadow-lift affordance — directive 3), `--ff-snap-duration` + `.ff-valid-drop`/`.ff-invalid-drop` (non-color + color constraint cues — directives 4/7), all reduced-motion-safe.
- **Rollout:** unlike the Q&A flow (one shared shell), there is **no single shared manipulative surface** — most manipulatives sit in bespoke per-clone wrappers, so a clone adopts prominence by wrapping its manipulative in `.ff-stage` (+ `--dominant` where it helps). Per-clone rollout across the ~50 non-fractionforge clones is tracked continuation (work-queue V181; the portfolio-wide sweep pass completed V221, `Docs/AUDIT_WEB_CLONE_PROMINENCE_SWEEP_2026-07-14.md`). A11y (keyboard-adjust, single-pointer drag alternative per WCAG 2.5.7, ≥44px handles, `aria-valuetext`, non-color cues) is a hard obligation per adopting clone.
- **▶ Playbook:** the treat-vs-no-op decision tree (the sweep's key finding: shared-shell clones are already prominent; only genuine *floaters* need treatment) + copy-paste CSS recipes (accent-topped stage / accent question-card / tabular readouts) + per-manipulative-type reference treatments live in **`Docs/GUIDE_WEB_CLONE_PROMINENCE_BEST_PRACTICES.md`**.

## Prefer Predict-Observe-Explain (predict-before-reveal) when a clone re-renders a deterministic sim/mechanic (R-WEB-CLONE-POE; 2026-07-14)

**When a `/play/<app>` clone re-renders a DETERMINISTIC, model-predictable simulation or mechanic (a phase cycle, an energy-flow graph, a truth table, a physics/parameter model, a rule the learner can reason toward), the DEFAULT framing is a scored Predict-Observe-Explain (POE) loop — the learner commits a prediction BEFORE the outcome is revealed, then reconciles the reveal — NOT a free-play "tap-and-watch" arena.** POE is one of the best-evidenced moves in science-education research (meta-analysis of 35 studies: Hedges' **g ≈ 0.98** on science achievement), and the cognitive engine is **errorful generation + prediction error** (committing a prediction — even a wrong one — then getting feedback encodes the answer better than watching), not "the sim is fun." Free-play iOS SpriteKit sims (and apps like Tinybop) leave this on the table, which is why a POE re-render is the portfolio's reference **web-pioneered → iOS-backport** feature. Full evidence base + design spec + worked examples: **`Docs/RESEARCH_PREDICT_OBSERVE_EXPLAIN_MECHANIC_2026-07-14.md`**. First consumer: `/play/curiosityquest` (Water Cycle predict-the-phase · Food Web predict-the-cascade · Logic Lab predict-then-run).

### The POE surface contract (on-device / COPPA-safe)
1. **Commit a prediction before any reveal** — the outcome is hidden until the learner chooses/constructs an answer.
2. **A real, unconstrained choice** — plausible distractors (map to common misconceptions where possible), NOT a near-give-away. **Load-bearing boundary condition:** the generation benefit *disappears* when the guess is over-constrained (Grimaldi & Karpicke 2012) — never auto-fill or pre-narrow the prediction to a coin-flip.
3. **First-try scoring + articulate-before-hint** — credit the first try; a hint appears only AFTER a first miss (never up front), preserving the generation effect (joins `R-FORGEPEDAGOGY-SCAFFOLDING`).
4. **An explicit "Explain" reconcile on the reveal** — feedback names *why* (the rule/mechanism), not just ✓/✗ (rides the shared prominent feedback panel, `R-WEB-CLONE-QA-PROMINENCE`).
5. **Anti-shame** — a wrong prediction is the point (errorful generation / hypercorrection); neutral copy, round always advances, never a harsh red.
6. **Deterministic + engine-derived answers** — computed from the model (never hardcoded) so a Vitest invariant asserts the bank matches the engine (`R-WEB-CLONE-TEST`).
7. **Quiet stage** — NO decoration/animation/narrative on the predict→reveal path (the seductive-details caution: a 2025 meta-analysis finds narrative/decoration on the critical path *hurts* learning, **g = −0.16**, via extraneous cognitive load). Honors `R-NARRATIVE-BETWEEN-NOT-DURING` + `R-GUARD-THE-RATIO` + `R-WEB-CLONE-MANIPULATIVE-PROMINENCE` (quiet background).

### Honest yield — POE is NOT universal
POE fits **predictable-from-a-model** surfaces with a real misconception space. It is NOT for vocabulary recall, aesthetic-choice creative tools, or random-outcome games — forcing a "prediction" there is decoration, and the honest classification is a plain MC round (`_shared/mcRound`) or a different mechanic, not a mislabeled POE lab. Apply POE where the phenomenon is model-predictable; elsewhere, don't. A clone that ports a deterministic sim as free-play *without considering* a POE framing is a review flag (was it a deliberate, documented choice, or an un-earned "strict port"?) — the same "earned, not assumed" bar as `R-WEB-CLONE-BACKPORT-MINING`.

### When this rule applies
- Authoring a clone with a deterministic sim/mechanic surface → default to POE; a genuine POE feature the iOS app lacks is a ✅ FILE candidate (web-pioneered → iOS backport, `R-CLONE-BIDIRECTIONAL-BACKPORT`).
- Reviewing a clone PR → a free-play re-render of a predictable sim with no prediction step is a flag (POE was the higher-value option); verify it was a documented choice.

### Cross-references
- `Docs/RESEARCH_PREDICT_OBSERVE_EXPLAIN_MECHANIC_2026-07-14.md` (the evidence base + design spec) · `Docs/web/curiosityquest/{RESEARCH,PARITY_WEB_VS_IOS,FEATURE_PLAN}.md` (the first consumer)
- § R-WEB-CLONE-QA-PROMINENCE (the Explain panel) · § R-WEB-CLONE-MANIPULATIVE-PROMINENCE (quiet stage) · § R-WEB-CLONE-BACKPORT-MINING (POE as a FILE candidate) · § R-WEB-CLONE-TEST (engine-derived bank invariant)
- `.claude/rules/forgekit.md` § R-FORGEPEDAGOGY-SCAFFOLDING (articulate-before-hint / productive failure — the sibling pedagogy) · `.claude/rules/distributed-narrative.md` § "Counter-evidence + design-principle layer" (the seductive-details caution) + § R-NARRATIVE-BETWEEN-NOT-DURING + § R-GUARD-THE-RATIO

## Every clone declares a GRADE BAND + LEVEL, shown on /play and sorted within its cluster (R-WEB-CLONE-GRADE-LEVEL; 2026-07-13)

**Every `/play/<app>` clone MUST declare a grade band + a level in its per-app registry entry (`src/data/play/<app>/clone.meta.ts`), the `/play` index MUST render a grade-band + level chip on each clone card, and clones MUST be sorted within each subject/cluster section by grade band then level (youngest/easiest first).** Codified per founder-direct 2026-07-13 (*"add grade band and level for each web clone on the /play page and sort the web clones by level grade bands for each subject/cluster"* + *"codify the grade band and level rule for all future web clone builds"*). Standing requirement for **every** clone — current (backfill) AND all future builds.

### Required `clone.meta.ts` fields (extend `PlayClone` in `src/data/play/clone-types.ts`)
- **`gradeBand: string`** — the human display label for the app's CORE/target grade band, e.g. `"Gr 4–6"`, `"Gr 7–8"`. Shown as a chip on the clone card.
- **`gradeMin: number`** — the numeric lowest grade in the CORE band (K = 0), the primary **sort key**. For an ages-only band, map age→grade (`grade ≈ age − 5`).
- **`level: number`** — a 1-based within-SUBJECT **difficulty ordinal** (1 foundational … 5 advanced) reflecting the app's position in its subject's learning sequence (the tie-breaker + the "level" chip).

**The band + level are CURATED from the app's CURRICULAR IDENTITY — NOT a min-max span of the kit labels (V186 audit correction, founder-direct 2026-07-13).** The kit `gradeBand`s legitimately scaffold intro→capstone (e.g. functionforge kit 1 "input/output machines" `gr4-5` … kit 8 "function analysis" `gr7-8`), so the **min-max span is uninformative** — the V183 backfill's span rule made 48/58 clones read "Gr 4–8", and its modal-band level made most read "Level 3". Worse, **subject-sequence position is curricular knowledge absent from the kit data**: the kits can't distinguish fractionforge (fractions, elementary — Gr 4–6 / L1) from functionforge (functions, algebra — Gr 7–8 / L4) because both *span* 4-8 with mode 6-7. So:
- **Derive the CORE band from the app's curricular topic** (CCSS / typical US sequence), using the kit **mode** (not min-max) + the app's identity as the cross-check — never the raw min-max span. Show a tight core range (e.g. "Gr 4–6"), not the full scaffolded span.
- **Assign `level` by the app's position in its SUBJECT sequence** (Math: number-sense/fractions = 1 → ratio/probability = 2 → early-algebra/geometry = 3 → functions/proof = 4 → competition-enrichment = 5). Enrichment apps (alcumusforge, mathcircle) get a HIGH level even at a modest gradeMin.
- A bespoke-mechanic-only clone with no kits sets the fields from its design target audience + subject sequence.
- The canonical curated values live in the per-app `clone.meta.ts` (disjoint files) + the audit `Docs/AUDIT_WEB_CLONE_GRADE_LEVEL_2026-07-13.md`. Founder is the authority on positioning — a flagged app is a one-line `clone.meta.ts` edit.

### Sort + surface
- **Sort** within each subject/cluster group on the `/play` index by **`(gradeMin` asc, `level` asc, `name` asc)`** — a deterministic comparator (no `Math.random`/`Date`).
- **Surface** a grade-band chip + a level chip on each clone card (readable register per § R-SITE-CHROME — "Gr 4–5", not "gradeMin:4").

### Gate — TWO layers (build-time + PR-CI), joins the dark-clone backstop
1. **Build-time (prebuild):** `scripts/check-play-clone-registry.mjs` fails the build if any clone's `clone.meta.ts` lacks `gradeBand`/`gradeMin`/`level` — same class as a missing theme (R-WEB-CLONE-NO-DARK-SURFACE). The Playwright `/play-index` spec asserts the chip renders + the per-cluster sort order holds.
2. **PR-CI (Vitest):** `src/data/play/clone-registry.test.ts` globs `PLAY_CLONES` and asserts every clone has the string identity fields + a valid `gradeBand` + numeric `gradeMin`(0..12)/`level`(1..5). **This layer is load-bearing:** the prebuild gate runs ONLY on the Cloudflare BUILD, NOT in PR CI — so a clone missing the fields passes its PR's Vitest+Playwright and only RED-BUILDS after merge (the roboforge incident, 2026-07-13: a parallel-session clone merged green, then the deploy went red — the "merged ≠ deployed" trap). The Vitest spec moves the check into a REQUIRED PR check so a missing/invalid field fails the PR, not the deploy. **General lesson: when a build-time (prebuild) registry/gate is added, add its PR-CI (Vitest) sibling too** — a prebuild-only gate is invisible to PR CI.

### When this rule applies
- **Authoring any new clone** → set `gradeBand`/`gradeMin`/`level` in `clone.meta.ts` from day one (from the kit metadata / design audience); it's part of the registry row, so the merge-hygiene per-app-file model (R-WEB-CLONE-MERGE-HYGIENE) keeps it collision-free.
- **Reviewing a clone PR** → a `clone.meta.ts` missing the fields, or a `/play` card without the chip, is a defect (build-gated).
- **Backfill: SHIPPED (V183, site PR #533) + CURATED (V186, site PR #540).** All 58 clone.meta.ts carry `gradeBand`/`gradeMin`/`level`; `/play` renders the grade + level chips + sorts each cluster by `(gradeMin, level, name)`; `check-play-clone-registry.mjs` fails the build on a missing field; `play-index.spec.ts` asserts the chips + per-cluster order. **V183's min-max-span/modal derivation was replaced by the curated curricular values (see the § above + `Docs/AUDIT_WEB_CLONE_GRADE_LEVEL_2026-07-13.md`)** after the founder audit (fractionforge L3→L1, functionforge "Gr 4–8"→"Gr 7–8"). New clones set the CURATED fields from day one (build-gated).

### Cross-references
- `src/data/play/clone-types.ts` (`PlayClone`) + `src/data/play/<app>/clone.meta.ts` (per-app registry) · `src/pages/play/index.astro` (the grouped index) · `scripts/check-play-clone-registry.mjs` (the gate) · `tests/e2e/play-index.spec.ts`
- § R-WEB-CLONE-MERGE-HYGIENE (the glob-derived per-app registry these fields live in) · § R-WEB-CLONE-NO-DARK-SURFACE (the sibling build-gate this joins) · § R-SITE-CHROME (chip register) · work-queue V183 (implementation)

## The hub agent CLASSIFIES a clone's /play cluster by curricular judgment — free-text keyword matching is a fallback, not the source of truth (R-WEB-CLONE-CLUSTER-MAP; 2026-07-14)

**A `/play` clone's subject-cluster grouping (the section it renders under on the `/play` index) is a CURRICULAR CLASSIFICATION the hub agent makes IN-SESSION — recorded explicitly, not left to fragile free-text keyword matching.** The `/play` index groups clones into a fixed pedagogical cluster set (Math · English & Language Arts · Science · Logic & Puzzles · Social Studies · SEL · Create). Codified per founder-direct 2026-07-14 (*"a couple of english language arts web clones are grouped in the Create cluster … do full audit and fix all the groupings and codify"* + *"should we codify a rule saying that the hub agent must use in-session Opus to classify the web clone for grouping?"* → yes).

### Why (the same fragility as grade bands)
The clones' `subject` is free-text (30+ spellings), so the index maps subject→cluster with `clusterOf()` (`src/lib/play/clusters.ts`) by keyword. Keyword matching is **inherently brittle to substring collisions**: the 2026-07-14 bug had `clusterOf` checking the broad **Create** branch (`s.includes('art')`) *before* ELA — and **"language arts" contains "art"** — so every "English / Language Arts" clone (figureforge/grammarforge/jestforge/mythforge/readquest) was silently grouped under Create; "Media Literacy" (truthquest, critical-evaluation) likewise fell into Create via `s.includes('media')`. This is the SAME lesson as R-WEB-CLONE-GRADE-LEVEL: a free-text→derivation heuristic mis-classifies, and the durable fix is **explicit curated classification by the agent's judgment** + a test that pins it.

### The mechanism (curate-record-test, not re-run-an-LLM-each-build)
"In-session classification" means: **when building/reviewing a clone, the hub agent DECIDES its cluster by curricular judgment** (what subject does this app actually teach?) and VERIFIES it lands there on `/play` (screenshot / the test) — it does NOT trust the keyword function blindly. Recorded two ways:
1. **`clusterOf()` is the tested keyword fallback** — hardened (ELA + Logic branches run BEFORE the broad Create branch; added coding/robotics/cipher + `media literacy`→Logic keywords) and **pinned by `src/lib/play/clusters.test.ts`** (Vitest, a required PR check): representative subject→cluster cases incl. the "language arts"→ELA + "Media Literacy"→Logic bugs, plus **every shipped clone must cluster (never `'More'`)** and **no English/ELA clone may land in Create**.
2. **`clone.meta.ts` optional `cluster` override** — the agent's RECORDED classification. Set it explicitly whenever the free-text subject would mis-route under `clusterOf()` (or is ambiguous); it overrides the keyword fallback. Validated by the test to be a real `CLUSTER_ORDER` value. Most clean-subject clones need no override (the tested fallback suffices); the override is the escape hatch that removes keyword-guessing for the ambiguous tail.

### When this rule applies
- **Authoring a new clone** → classify its cluster by curricular judgment; if `clusterOf(subject)` wouldn't place it correctly, set an explicit `cluster` in `clone.meta.ts` (and/or add a `clusters.test.ts` case for the new subject spelling). Do NOT ship trusting the keyword match unverified.
- **Reviewing a clone PR / auditing /play** → verify each clone's section is curricularly correct (a screenshot of the index, per R-WEB-CLONE-SCREENSHOT-DOD); a mis-grouped clone is a defect. Adding a Create-branch keyword that is a substring of another cluster's subjects (like `art` ⊂ `language arts`) requires re-checking the branch ORDER.
- **Changing `clusterOf` keywords/order** → keep ELA + Logic before the broad Create branch; add/adjust `clusters.test.ts` cases.

### Cross-references
- `src/lib/play/clusters.ts` (`clusterOf` + `CLUSTER_ORDER`/`CLUSTER_META`, extracted from index.astro so it's unit-testable) · `src/lib/play/clusters.test.ts` (the pin) · `src/data/play/clone-types.ts` (`cluster?` override) · `src/pages/play/index.astro` (`clusterFor` = override ?? fallback)
- § R-WEB-CLONE-GRADE-LEVEL (the sibling curate-don't-derive rule for the same `/play` cards) · § R-WEB-CLONE-SCREENSHOT-DOD (verify the grouping by looking) · § R-AUTHOR-MODEL-CHOICE (`.claude/rules/distributed-narrative.md` — in-session-Opus-judgment-over-scripted precedent) · site PR #548 · work-queue V191

## The deep-research step MUST yield an explicit backport-candidate list — mined CROSS-PLATFORM, "strict port" is earned, never assumed (R-WEB-CLONE-BACKPORT-MINING; 2026-07-11)

**The Phase-2 deep research (`WEB_CLONE_PICKUP_RUNBOOK` § 3.2b) is the designated "well for novel features," and its source landscape is CROSS-PLATFORM — web + iOS + Android + physical/board-game/research — NOT web-only. Every clone's `RESEARCH.md` MUST carry a `## Domain landscape` survey (of the best-in-class in the domain across ALL those surfaces) ending in an explicit, evidence-based `## Backport candidates` list — the best learning-relevant ideas OUR apps (iOS AND web) LACK — and classify EACH one. A conclusion of "strict port → no backport" is VALID ONLY after that list exists and every candidate is classified; it must be EARNED by the mining, NEVER asserted by default.** Codified per user-direct 2026-07-11 (*"the deep web research step should have provided a lot of novel ideas for iOS backport, correct?"* → *"codify this requirement"*; then *"why are we doing deep web research for web-based novel features only? why not including novel features and ideas from ios and android apps too?"* → *"make sure to backfill and also codify it as a rule too"*), after the V95/V97/V98 clones (claimcraft/jestforge/witquest) each defaulted to "strict port" and skipped producing the candidate list — using the research only for positioning, not for its load-bearing backport-discovery purpose — AND after the mining was found to be artificially scoped to the *browser* landscape only.

### The source landscape is CROSS-PLATFORM, not web-only (broadened 2026-07-11)

The mining was originally framed as "deep **web** research" because the step lives inside the *web-clone* build (you're building a browser surface, so you looked at browser competitors). **That scope was an accident of location, not a principle, and it is now broadened.** The well for novel learning-design ideas is the WHOLE domain across every surface:

- **web** tools/sites in the domain (the original scope);
- **iOS** best-in-class apps (App Store editorial / education charts) — frequently *ahead* of browser tools on learning design;
- **Android** best-in-class apps (Play Store education / Google Kids Space);
- **physical / board-game / research** exemplars (the portfolio already treats Storytime Chess + Backgammon as first-class design exemplars — being web-only was inconsistent with our own practice).

The candidate **test is unchanged** — a candidate must be (1) absent from OUR app(s), (2) learning-relevant, (3) on-device + COPPA-feasible. Only the SOURCE breadth changed. Consequently a candidate can flow to **BOTH** surfaces: a novel idea our iOS app lacks is a web build-candidate *and* an iOS backport; a novel idea our web clone lacks is a web build-candidate. Do not privilege browser-native gimmicks over pedagogy — the point of widening the aperture is to surface the strongest *learning* ideas wherever they live.

### Why this rule exists

The runbook already says the novel-feature list *"must be evidence-based (from this research), not guessed … It's what earns the clone its Phase-5 backport value."* But that instruction was being satisfied *narratively* (a "here's how we're differentiated" paragraph) rather than *mechanically* (a classified candidate list that feeds `R-CLONE-BIDIRECTIONAL-BACKPORT`). This rule makes the list a **required, inspectable artifact** so the web→iOS backport direction actually gets fed, and so "strict port" can't silently swallow a real net-new idea the research surfaced. It is the **discovery mechanism** that supplies candidates to `R-CLONE-BIDIRECTIONAL-BACKPORT` (which governs the *obligation* once a candidate is a real feature).

### The candidate test + classification (each item in `## Backport candidates`)

A domain-landscape feature — from **any** surface (web / iOS / Android / physical) — is a **live backport candidate** only if it is ALL of: **(1) absent from OUR app(s)** (checked against the deep-read `## iOS feature inventory` — and, for a web-only idea, against the web clone — don't claim absence without checking), **(2) learning-relevant** (pedagogy-load-bearing, per `R-WEB-CLONE-PARITY` § in-scope), AND **(3) on-device / COPPA-feasible** (no server, accounts, or off-device data). Classify every surfaced idea as exactly one of:

| Class | Meaning | Action |
|---|---|---|
| **FILE** ✅ candidate | passes all 3 tests | file `<app>-app/Docs/HANDOFF_FROM_HUB_<FEATURE>_WEB_BACKPORT.md` + add a 🟡 iOS-backport row to the parity ledger — **whether or not it's built on the web yet** (a strong candidate is worth surfacing to the iOS session even before the web ships it). If the web clone ships it, the 🟡 row + handoff are already mandatory per `R-CLONE-BIDIRECTIONAL-BACKPORT`. |
| 💡 **iOS-ENHANCE** | learning-relevant + iOS-appropriate but **web-INFEASIBLE** (needs an iOS-only capability — AR/RealityKit, CoreMotion, Vision, camera/mic, haptics-as-pedagogy, Live Activities — to deliver the LEARNING, not just polish), AND absent from the iOS app | **advisory, NON-obligation** — add it to the per-app **`<app>-app/Docs/HANDOFF_FROM_HUB_<APP>_IOS_ENHANCEMENT_IDEAS.md`** (a single consolidated advisory doc per app; feature + why-it-needs-iOS + proposed iOS surface). **NO 🟡 parity-ledger row** — the feature exists on NEITHER surface, so it is NOT a symmetric-backport gap; it is an *opportunity*, and the iOS session triages/decides (it may decline). This is the iOS-direction mirror of build-by-default and is deliberately kept OUT of `R-CLONE-BIDIRECTIONAL-BACKPORT` (which governs parity gaps) so "handoff filed = obligation started" stays reserved for real obligations. |
| ⛔ **waived** | fails (2) or (3), OR the iOS app already has it, OR it's a platform-only DECORATION (haptic buzz / particle polish / a nav chrome affordance — carries no distinct LEARNING) | list it with a one-line rationale — the canonical waiver reasons are **already-in-iOS**, **on-device/COPPA-infeasible** (accounts / collaboration / cloud sync / server AI-gen — e.g. Kialo's collaborative trees, Witscript's cloud generator), or **platform-only decoration**. A waived candidate is COMPLIANT; the point is it's *documented*, not silently dropped. |
| 🔄 **adaptation** | a web-native rendering of something iOS already does | not a backport (e.g. the claimcraft committed-fallacy hard-gate; jestforge structure-only scoring). |

**⛔ platform-only vs 💡 iOS-ENHANCE — the distinction (codified 2026-07-11, founder-direct):** a platform-only *affordance* that is mere **decoration** (haptics-as-feedback, SpriteKit particle polish, a nav-chrome flourish) stays **⛔ waived**. But a platform-only capability that would deliver a **genuine novel LEARNING experience the iOS app lacks** (e.g. an AR angle/area manipulative, a CoreMotion tilt-balance for equations, a Vision hand-drawing/geometry-construction check, a haptic rhythm/meter trainer) is a **💡 iOS-ENHANCE** — surfaced to the iOS session as an advisory opportunity, never silently dropped as "platform-only." The web can't build it (that's why it's not FILE), but the iOS app can, and the cross-platform research already found it — so it flows one-way to iOS. Honest-yield applies here too: for mature apps the iOS-ENHANCE yield is usually small; a zero-yield app files no advisory doc.

**Honest-yield clause:** for *mature* source apps (the high-ranked clone candidates are mature by construction), the FILE yield is often small and the list may be mostly ⛔ — **that is an acceptable outcome, but the list must still be produced and every item classified.** A short, mostly-waived, well-reasoned list is compliant; an absent list is a defect. Never pad the list with guessed or weak candidates to inflate the yield (the runbook's "evidence-based, not guessed" bar).

### Where the artifacts live

- **`RESEARCH.md` → `## Backport candidates`** — the classified list (this rule's required artifact), directly under the sourced `## Domain landscape` (legacy clones' `## Web landscape` heading is accepted; new clones use `## Domain landscape`). Note each candidate's SOURCE platform (web / iOS / Android / physical) so the cross-platform breadth is inspectable.
- **`FEATURE_PLAN.md`** — the FILE candidates become tracked items with an `iOS-backport:` line each; the ⛔/🔄 ones are noted.
- **`PARITY_WEB_VS_IOS.md`** — each FILE candidate that the web clone SHIPS is a 🟡 iOS-backport row (per `R-CLONE-BIDIRECTIONAL-BACKPORT`); a FILE candidate not-yet-built on the web is still surfaced via the handoff but need not be a ledger row until built.
- **`<app>-app/Docs/HANDOFF_FROM_HUB_<FEATURE>_WEB_BACKPORT.md`** — the filed handoff for each FILE candidate (feature + web reference impl if built + proposed iOS surface). Filing the handoff is the START of the obligation, not its completion.
- **`<app>-app/Docs/HANDOFF_FROM_HUB_<APP>_IOS_ENHANCEMENT_IDEAS.md`** — ONE consolidated **advisory** doc per app holding all its 💡 iOS-ENHANCE ideas (web-infeasible, iOS-appropriate novel learning). Explicitly labelled non-obligation; **no 🟡 ledger row**; the iOS session triages. Omit the doc for an app with zero qualifying ideas.

### Build the FILE candidates on the web — the clone PIONEERS, then backports (founder-direct 2026-07-11)

**The default for a genuine ✅ FILE candidate is to BUILD it into the web clone, not merely file the handoff.** Per founder-direct 2026-07-11 (*"implement all the backfilled features in the web clones too"*), the `/play` clone is not just a mirror of iOS — it is a place to **pioneer web-native learning features that then flow back to iOS**. So the full loop for a FILE candidate is: **mine → classify → file the iOS handoff → BUILD it on the web → open a 🟡 iOS-backport row in `PARITY_WEB_VS_IOS.md` (Axis 1) → update the two guides in the same change-set (R-WEB-CLONE-GUIDE-SYNC).** Once built on the web, the 🟡 row is MANDATORY (a web-shipped, iOS-absent, learning-relevant feature is exactly R-CLONE-BIDIRECTIONAL-BACKPORT's trigger); the row + filed handoff are the *compliant* open state (not a defect), and it closes only when the iOS session ships it back (or replies with a documented waiver, e.g. "already covered by <surface>").

This UPGRADES the earlier "parity-first, web-only features open debt so defer them (Track B)" default: a genuine FILE candidate is now **build-by-default**, because building it is what earns the program its cross-surface leadership (the web validates the feature; iOS inherits a proven reference impl). Reference impl: `/play/claimcraft` shipped **learner-set per-link evidence strength** + **argument-map → essay export** (site PR #395), backported via `claimcraft-app/Docs/HANDOFF_FROM_HUB_ARGUMENT_{LINK_STRENGTH,MAP_ESSAY_EXPORT}_WEB_BACKPORT.md` (PR #52) — the first two web-pioneered→iOS backports of the program.

Build-scope discipline still applies: build a FILE candidate only when it's genuinely learning-relevant + on-device-feasible (the candidate test); ⛔-waived items (accounts/collab/cloud/platform-only/already-in-iOS) are NOT built. A mostly-⛔ / zero-FILE clone builds nothing extra and ships as a strict port — that remains a valid, earned outcome.

### Every Track-B FILE item MUST be built by the hub web-clone agent — "booking" needs a VALID reason (R-WEB-CLONE-TRACK-B-BUILD-DEFAULT; 2026-07-12)

**Every Track-B (web-pioneered FILE) item in a clone's `FEATURE_PLAN.md` MUST be BUILT on the web by the hub web-clone agent, in the same wave that classifies it — UNLESS there is a specific, documented, VALID reason not to. "It was more work," "data-heavy," "overlaps another surface," or a bare "honest-yield deferral" is NOT a valid reason.** This CLOSES the de-facto escape hatch where a genuine ✅ FILE candidate got parked as a `BOOKED` Track-B line and never built. It is the hardening of the § "Build the FILE candidates on the web" default above: build-by-default was the *posture*; this is the *obligation*. Codified per founder-direct 2026-07-12 (*"all track-b items in web clone feature plans should be implemented by web clone hub agents unless there's a valid reason not to"* + *"audit all shipped web clones for these track-b items and build them too"*).

#### Why it exists

A Track-B item is, BY CONSTRUCTION, a candidate that already passed the 3-test (absent-from-iOS ∧ learning-relevant ∧ on-device/COPPA-feasible) — so it is buildable by definition. Parking a passed candidate as `BOOKED` for effort/yield reasons produced clones that *claimed* a rich backport posture in `RESEARCH.md` while shipping a thin surface, and left the web→iOS backport pipeline starved (a booked item files no handoff, opens no 🟡 row, validates nothing). The value of the program is the *built* pioneering feature; an unbuilt Track-B line delivers none of it.

#### The valid-reason taxonomy (the ONLY grounds to not build a Track-B item)

A Track-B item may remain unbuilt ONLY when one of these is recorded inline in `FEATURE_PLAN.md` (one line, specific):

1. **COPPA / AI-evaluator-infeasible** — the feature genuinely needs a server, accounts, off-device data, or an AI evaluator to deliver its LEARNING (e.g. open free-write graded by a model). *If it's infeasible it was misclassified — reclassify it ⛔-waived, not BOOKED.*
2. **Asset-gated** — it needs NEW asset generation the clone program doesn't have yet (e.g. per-region SVG map outlines, bespoke illustrations). Record the exact asset blocker + what would unblock it. *This is the one legitimate "not yet" — but the default is still to build the parts that don't need the asset.*
3. **Platform-only** — needs an iOS-only capability (AR/Vision/CoreMotion/camera/mic/haptics-as-pedagogy). *Then it's ⛔ or 💡 iOS-ENHANCE, not Track-B.*
4. **Genuinely-infeasible content-authoring scale** — building it correctly requires hand-authoring content at a scale that is itself a separate, sized wave (NOT "a bit more content"). Record the item count + why it's a distinct wave, and file it as a tracked follow-up, not a silent book.
5. **Founder-direct** — the founder explicitly defers a specific item.

Anything outside this list — including "overlaps the free-text Workshop," "the MC surface roughly covers it," "diminishing returns" — means either (a) it's really a 🔄 adaptation (already covered → reclassify, it was never a FILE) or (b) it must be BUILT. When in doubt, build it.

#### The retroactive backfill (one-time + standing)

The obligation is retroactive: **audit EVERY shipped clone in `REGISTRY_WEB_CLONES.txt` for Track-B items that are booked/not-yet-built, and BUILD them** (or reclassify to a valid-reason bucket above). This runs as part of / alongside the § Portfolio audit sweep below; record it in `Docs/AUDIT_WEB_CLONE_TRACK_B_BUILD_BACKFILL_<date>.md`. Going forward, a clone is not DoD-complete (§ R-WEB-CLONE-PARITY-DOD) while it carries an un-built Track-B item without a valid-reason line.

#### When this rule applies

- Authoring/extending any `/play/<app>` clone → every FILE candidate you classify into Track B, you BUILD in the same wave (or attach a valid-reason line).
- Reviewing a clone PR → a `FEATURE_PLAN.md` with a `BOOKED`/deferred Track-B item lacking a valid-reason line is a defect (same weight as a missing parity axis).
- Resuming the clone program → run the retroactive backfill across all shipped clones.

#### Cross-references
- § "Build the FILE candidates on the web" (the build-by-default posture this hardens) · § R-WEB-CLONE-BACKPORT-MINING (the parent mining rule + candidate test) · § R-WEB-CLONE-PARITY-DOD (the ship gate this feeds) · § R-CLONE-BIDIRECTIONAL-BACKPORT (the 🟡-row obligation each built item opens)
- `Docs/AUDIT_WEB_CLONE_TRACK_B_BUILD_BACKFILL_<date>.md` — the retroactive backfill record

### Portfolio audit sweep — backfill + verify EVERY shipped clone (the standing conformance check)

The mining+build loop is retroactive to all existing clones, and a periodic sweep keeps them conformant. For **each** row in `REGISTRY_WEB_CLONES.txt`, verify: (1) `RESEARCH.md` has a classified `## Backport candidates` list; (2) it also appears in `FEATURE_PLAN.md` (Track B); (3) every ✅ FILE candidate has a filed `<app>-app/Docs/HANDOFF_FROM_HUB_<FEATURE>_WEB_BACKPORT.md`; (4) every FILE candidate BUILT on the web has a 🟡 row in `PARITY_WEB_VS_IOS.md`; (5) "strict port / 0-FILE" is traceable to a produced-and-classified list. The audit-sweep quick check:

```bash
for app in $(grep -vE '^\s*#|^\s*$' Docs/REGISTRY_WEB_CLONES.txt | grep shipped | cut -d'|' -f1 | tr -d ' '); do
  grep -qi 'backport' "Docs/web/$app/RESEARCH.md" && echo "$app: list ✓" || echo "$app: MISSING candidate list"
  ls ../$app-app/Docs/HANDOFF_FROM_HUB_*WEB_BACKPORT*.md 2>/dev/null | wc -l | xargs echo "  $app filed handoffs:"
done
```

Record the sweep in `Docs/AUDIT_WEB_CLONE_BACKPORT_MINING_<date>.md`. **Reference sweep (2026-07-11, V99):** all 8 shipped clones conformant — fractionforge (3 handoffs, built) + readquest (1, built) + claimcraft (2, built PR #395) = 6 web-pioneered backports filed; grammarforge/proofquest/chanceforge/jestforge/witquest = mined + classified + 0 genuine FILE (all ⛔ already-in-iOS / accounts-cloud-COPPA / platform-only or 🔄 web-native), earned strict-port.

**Cross-platform backfill sweep (2026-07-11, V109):** after the source-scope broadening above, all shipped clones were re-mined against the iOS + Android + physical landscape (not just web) and each `## Backport candidates` list was refreshed with source-tagged candidates. Recorded in `Docs/AUDIT_WEB_CLONE_BACKPORT_MINING_CROSSPLATFORM_2026-07-11.md`; any genuine FILE candidate surfaced by the widened aperture got a filed `<app>-app/Docs/HANDOFF_FROM_HUB_<FEATURE>_WEB_BACKPORT.md` + a 🟡 ledger row.

**💡 iOS-ENHANCE backfill sweep (2026-07-11, V118):** after the 💡 iOS-ENHANCE class was codified, every shipped clone's `## Backport candidates` list was re-triaged to pull the web-infeasible-but-iOS-appropriate **novel LEARNING** ideas out of the ⛔ bucket (distinct from ⛔ platform-only *decoration*) and file them as advisory `<app>-app/Docs/HANDOFF_FROM_HUB_<APP>_IOS_ENHANCEMENT_IDEAS.md` docs (non-obligation, no 🟡 row). Recorded in `Docs/AUDIT_WEB_CLONE_IOS_ENHANCE_BACKFILL_2026-07-11.md`. When authoring a NEW clone's `## Backport candidates`, classify iOS-only novel-learning ideas as 💡 iOS-ENHANCE from the start (don't dump them in ⛔).

### When this rule applies

- Authoring or extending any `/play/<app>` clone → produce/refresh the `## Backport candidates` list as part of Phase 2 (RESEARCH), before declaring the parity posture; **build the FILE candidates** (default) + open their 🟡 rows.
- The `R-WEB-CLONE-PARITY-DOD` ship gate → a clone is NOT done until its `RESEARCH.md` carries a classified `## Backport candidates` list (in addition to the two parity-ledger axes). "Strict port" in the ledger must be traceable to a produced-and-classified list.
- Reviewing a clone PR → if `RESEARCH.md` has a `## Domain landscape` (or legacy `## Web landscape`) but no `## Backport candidates`, that's a defect (same weight as a missing parity axis); if the landscape surveys only browser tools and no iOS/Android/physical exemplars, that's an incomplete mining (the source scope is cross-platform).
- Periodically (or when resuming the clone program) → run the § Portfolio audit sweep across all shipped clones.

### Cross-references
- `Docs/WEB_CLONE_PICKUP_RUNBOOK.md` § 3.2b (the deep-web-research step this rule makes load-bearing) + § 8 (the DoD gate it joins)
- § R-CLONE-BIDIRECTIONAL-BACKPORT (the obligation this rule's FILE candidates feed) · § R-WEB-CLONE-PARITY / § R-WEB-CLONE-PARITY-DOD (the parity axes it sits beside)
- `Docs/web/{claimcraft,jestforge,witquest}/RESEARCH.md` — the first clones whose `## Backport candidates` lists were added retroactively under this rule (V99)

## Missing question kits are AUTHORED by in-session Opus to match the portfolio — never skipped, never Gemini-gen (R-WEB-CLONE-KITS-OPUS-AUTHOR; 2026-07-14)

**When a clone's source app has NO question-kit banks (a composition-only app, a docs-only app with unwritten kits, or any app lacking the portfolio-standard 16×25 MC set), the kits are AUTHORED FRESH by the in-session Opus model (the running Claude Code session) to match the other portfolio apps — a full 16 kits × 25 = 400 MC items — NOT skipped, NOT waived as "bespoke-only," and NOT generated by Gemini.** Codified per founder-direct 2026-07-14 (*"you build the question kits and ship them too"* + *"ship the question kits to the ios app repo too"* + *"codify the rule that if question kits are missing, use the in-session Opus to author them to match other portfolio apps"*). This **supersedes** the earlier "a composition-only app is an all-bespoke clone with no MC Concepts surface (⛔-waived, HaikuQuest precedent)" posture — the portfolio standard is that **every** clone has a Concepts MC surface, and a missing bank is an *authoring task*, not a waiver.

### Why in-session Opus (not Gemini, not skip)
- **Match the portfolio.** Every kit-bearing clone ships 16×25=400 CCSS-tagged MC items on the portfolio kit schema (`kitId/number/name/topic/gradeBand/track/questions[{id,prompt,correctAnswer,distractors[3],bloomLevel,subtopic,standard,hints[2],explanation}]`). A missing bank is filled to that same standard — same count, same schema, same scaffolded gr4→gr8 arc, same anti-shame register.
- **In-session Opus, $0 marginal.** Kit content is authored by the running session (the Claude Code subscription absorbs it), exactly like `R-COVERAGE-OPUS-AUTHORING` (chapters) + `R-AUTHOR-MODEL-CHOICE` (in-session Opus > API for quality-critical authoring). **Do NOT** reach for Gemini or any paid gen — MC items are hand-authorable and quality/correctness is paramount (a wrong answer is the exact defect the semantic + structural kit gates exist to catch).
- **Deterministic porter.** The authored content lives in a `scripts/port_<app>_kits_to_web.py` porter (the same script name the PORT clones use), holding the items in Python data + emitting the JSON with deterministic `uuid5` ids. Re-runnable/idempotent — the "authored, not ported" kits stay regenerable + reviewable in one place.

### Ship to BOTH surfaces (web + iOS)
Because the authored curriculum did not exist on either surface, it is a **web-pioneered → iOS backport** (`R-CLONE-BIDIRECTIONAL-BACKPORT`). The porter emits to BOTH:
- **Web:** `public/play/<app>/kits/<kitId>.json` + `src/data/play/<app>/kits-index.ts` → the Concepts surface (`kits.ts` loader + `session.ts` `runKit` → `_shared/mcRound` + a `play.astro` `?kit=` launcher + the landing kit list).
- **iOS:** `<app>-app/Resources/Questions/<app>/<kitId>.json` (the portfolio iOS kit schema — top `id/name/description/gradeBand/topic/questions/standardsFramework:"CCSS"`, per-q adds `gradeBand/topic/version`) — an **allowed content-pipeline write** (`portfolio.md` § allowed `Resources/<assets>/` writes) — PLUS a `<app>-app/Docs/HANDOFF_FROM_HUB_QUESTION_KITS.md` for the app's own session to wire the Concepts surface (hub never writes the Swift). A 🟡 iOS-backport ledger row tracks it until the app ships the surface.

### Gates (unchanged — the authored bank rides the existing kit gates)
The shared `_shared/kits.test.ts` STRUCTURAL gate globs `public/play/<app>/kits/*.json` (non-empty prompt+correct, correct ∈ options once, options unique, valid bloom, unique ids) — it validates the authored bank automatically. Add a clone-specific Vitest asserting **16 kits × 25 = 400** via the `kits-index`. Screenshot-DoD covers the Concepts landing list + a live round. CCSS `standard` tags + per-item `explanation` + `hints[2]` are required (portfolio parity).

### When this rule applies
- **Authoring any clone whose source app lacks kit banks** (composition-only like lyricforge/haikuquest; docs-only with unwritten kits) → author the 16×25 with in-session Opus, ship to web + iOS, file the iOS handoff. **A clone shipped with NO Concepts surface because "the app had no kits" is now a defect**, not an earned waiver (reference: lyricforge shipped bespoke-only first, then had its 400-item Concepts surface authored + backfilled the same day per founder-direct).
- **Reviewing a clone PR** → a composition/docs-only clone with no Concepts MC surface + no authored kit bank is a gap unless founder-waived.
- Retroactive: HaikuQuest (the sibling that set the now-superseded "no MC kits" precedent) is a candidate for the same kit-authoring backfill.

### Cross-references
- `scripts/port_lyricforge_kits_to_web.py` — reference impl (authored 16×25, emits web + iOS) · `Docs/web/lyricforge/{RESEARCH,FEATURE_PLAN,PARITY_WEB_VS_IOS}.md`
- `.claude/rules/distributed-narrative.md` § R-COVERAGE-OPUS-AUTHORING + § R-AUTHOR-MODEL-CHOICE (the in-session-Opus-authoring precedents this mirrors) · § R-WEB-CLONE-TEST (`_shared/kits.test.ts` structural gate) · § R-CLONE-BIDIRECTIONAL-BACKPORT (the web→iOS backport obligation) · `portfolio.md` § "Asset generation ownership" (question kits are an allowed `Resources/` content-pipeline write)

## Younger-cluster (ages 5-8) apps are EXEMPT from the 16×25 MC-kit obligation — activity-based formats, not multiple-choice banks (R-YOUNGER-CLUSTER-NO-MC-KITS; 2026-07-14)

**The portfolio-standard 16 kits × 25 = 400 CCSS-tagged, Bloom-leveled, TEXT multiple-choice bank MUST NOT be authored for younger-cluster (ages 5-8 / K-2) apps. It is the documented, research-backed ⛔ EXCEPTION to `R-WEB-CLONE-KITS-OPUS-AUTHOR`** — a younger-cluster app with no `kit_*.json` is NOT a coverage gap, and authoring one would ship a developmentally-inappropriate, low-validity surface. Younger-cluster apps use **audio-first, low-text, manipulative/tap/drag** activity formats instead. Codified per founder-direct 2026-07-14 (*"should the younger cluster app repos have the question kits? … codify the research-backed evidence"*), full evidence in `Docs/RESEARCH_YOUNGER_CLUSTER_QUESTION_KITS_2026-07-14.md`.

### Why (four converging lines)
1. **Internal portfolio norm (decisive):** 0 of 6 ages-5-8 apps (bugscamp · countingpals · huggyhabits · melodymice · taletrail · tinyletters) have EVER carried an MC kit — a deliberate, universal design; each app's `CLAUDE.md` states it is *"NOT the portfolio 9-14 core."* The tween core carries kits ~universally (133/158 repos). The split is intentional.
2. **NAEYC / Developmentally Appropriate Practice:** for ages 5-8, DAP favors **observation-based, authentic, culturally-responsive** assessment over standardized multiple-choice; test-item cultural bias is a first-order DAP concern for this band.
3. **Leading early-childhood apps** (Khan Academy Kids, Todo Math — both built for pre-readers with Stanford/Harvard/XPRIZE credentials) use **audio-first instruction + visual manipulatives + tap/drag**, never a text MC bank — because the users cannot yet read independently.
4. **Reading-load / decoding confound + floor effects:** a 25-item TEXT MC bank measures decoding, not the target skill, for pre/emergent readers ("learning to read," not "reading to learn") — a low-validity instrument with documented false-positive / floor-effect threats.

### The rule
- **Do NOT author 16×25 MC kits for any ages-5-8 app** (current: the 6 above; and every future younger-cluster SPAWN). A missing MC bank in this band is ⛔-by-design, recorded as such in the kit-coverage audit — never a 🟡 gap.
- **Their web clones** port the **activity/manipulative** surfaces (subitizing, tap-count, drag-add, letter-trace, sound-match, sort/observe), NOT a Concepts-MC surface. Reference: the countingpals clone (procedural `earlyMath` engine + `_shared/customRound`, zero MC). A younger-cluster clone shipped WITHOUT a Concepts-MC surface is compliant, not a defect (the inverse of R-WEB-CLONE-KITS-OPUS-AUTHOR's tween default).
- **The boundary is the AGE BAND, not the cluster.** A TWEEN (9-14) SEL / composition / board-game app IS obligated (SEL apps mindforge/safetyforge/wellnessforge/saffronlab all carry 32-36 kits; the LyricForge composition precedent authored 400). Only the ages-5-8 band is exempt. If an app straddles bands, classify by its CORE target audience (per `clone.meta.ts` `gradeMin` / the app's `CLAUDE.md`).

### When it applies
- Authoring/reviewing a younger-cluster app's kits or web clone → do NOT author MC kits; do NOT flag their absence as a gap; port activity formats.
- Any kit-coverage audit (like `Docs/AUDIT_QUESTION_KIT_COVERAGE_2026-07-14.md`) → younger-cluster apps go in the ⛔ bucket with this rule as the rationale, alongside the ⛔ non-standard-content-model apps (aggregator / problem-library / estimation-prompt apps).

### Cross-references
- `Docs/RESEARCH_YOUNGER_CLUSTER_QUESTION_KITS_2026-07-14.md` (the evidence base) · `Docs/AUDIT_QUESTION_KIT_COVERAGE_2026-07-14.md` (the V222 audit that applies it)
- § R-WEB-CLONE-KITS-OPUS-AUTHOR (the tween-core rule this is the exception to) · § R-WEB-CLONE-GRADE-LEVEL (the grade-band declaration that identifies younger-cluster clones) · § R-WEB-CLONE-DEVICE-FEATURE-SKIP (sibling "port the appropriate subset" discipline) · `.claude/rules/distributed-narrative.md` § R-YOUNGER-CLUSTER-CAST-SIZE + `Docs/RESEARCH_YOUNGER_CLUSTER_CAST_SIZE_2026-07-14.md` (the sibling younger-cluster codification — small hero-anchored cast, V224)

## No feature may ship dark — every clone route + novel feature must be wired + visible (R-WEB-CLONE-NO-DARK-SURFACE; 2026-07-11)

**A `/play/<app>` clone is NOT done until EVERY route AND every novel/web-pioneered feature it ships is REACHABLE + VISIBLE to a user — linked from the landing (or from another linked, reachable surface) — and the clone has its `src/data/play/clones.ts` registry row. A surface that exists in the code but no user can navigate to is *shipped-but-dark* and is a defect.** This is the web-clone analogue of the portfolio **Asset Consumer Audit** (`.claude/rules/portfolio.md` § "registered ≠ wired") and the DN **authored ≠ integrated** discipline (`R-CAST-EXPANSION-INTEGRATION`): building the feature is the START of the obligation, wiring it into the user's navigable path is the completion. Codified per user-direct 2026-07-11 (*"how do we make sure all the features including novel features are wired and visible to the users and not remaining dark? do full audit and backfill wiring if needed. codify these too"*).

### Why it matters most for NOVEL features

The web-pioneered FILE features (`R-WEB-CLONE-BACKPORT-MINING`) are the whole point of the program — they're what earns the clone its cross-surface leadership + iOS backport value. A pioneered feature that ships behind a route no page links to is *invisible*: the user never plays it, the backport is never validated, and the parity ledger's "web-shipped" claim is false. So the anti-dark-surface gate is strictest exactly where the value is highest. **A novel feature must be surfaced as a headline card on the landing** (not buried) — reachable AND prominent.

### The three wiring checks (the gate)

`scripts/audit_web_clone_surface_wiring.py` makes dark surfaces build-time-visible. For each clone it verifies:

1. **Route reachability** — every `src/pages/play/<app>/*.astro` route (except the `index` landing) is linked (`href="/play/<app>/<route>"`) from at least one of the clone's own pages. A route no page links to is DARK.
2. **Registry row** — the clone has a row in `src/data/play/clones.ts` (that's what surfaces it on the `/play` index + the homepage; without it the whole clone is dark from the site's entry points). **Build-gated** by `check-play-clone-registry.mjs` (prebuild) — see § "The clones.ts row is build-gated" below.
3. **Bespoke-feature surfacing** — every app-local `run*`-exporting lib module (a distinct mechanic, not `progress`/`kits`/`session`/`devices` plumbing) is imported by some route under the clone. A mechanic with no page that runs it is dark.

```bash
python3 scripts/audit_web_clone_surface_wiring.py --site-root <site-or-worktree> [--app <slug>] [--ci-mode]
```

Run it in the build worktree before shipping every clone (`--app <slug>`), and portfolio-wide as a periodic backstop (no `--app`). It complements — does not replace — the postbuild `check-site-internal-links.py --unit play` (that catches BROKEN links; this catches ABSENT links — a route with no inbound reference at all, which a link checker can't see). **Reference sweep (2026-07-11):** all 12 shipped clones 🟢 wired (zero dark routes / features; every clone in the registry) — recorded in `Docs/AUDIT_WEB_CLONE_SURFACE_WIRING_2026-07-11.md`.

### This joins the two-axis DoD gate

`R-WEB-CLONE-PARITY-DOD` gates on the two parity ledgers; this rule adds a third ship condition: **zero dark surfaces**. A clone with a filled parity ledger but a bespoke mechanic no page links to is still not done. The three together: (a) feature parity, (b) UI/UX parity, (c) every surface wired + visible.

### The clones.ts row is build-gated + "merged ≠ live" (harmonyforge incident, 2026-07-12)

The `/play` index (`src/pages/play/index.astro`) renders **only** the clones in `PLAY_CLONES` (`src/data/play/clones.ts`) — so a clone whose route dir exists but whose `clones.ts` row is absent is **silently dark from the site's main entry point**. Two failure modes, both now gated:

1. **Row-drop / merge-race (within-repo)** — `clones.ts` is a shared, union-merged append hotspot (§ R-WEB-CLONE-MERGE-HYGIENE); a botched conflict resolution can drop a clone's row while its route dir survives, shipping a dark clone with **zero build signal**. **Gated:** `spark-anvil-site/scripts/check-play-clone-registry.mjs` runs in `prebuild` + `prebuild:play` and **fails the build**, naming the app, if any `/play/<app>/index.astro` lacks a `clone.meta.ts` (or the row's `.pc-theme-<app>` accent block is missing from **`play.css`** → renders un-themed on the index, which imports only `play.css`; per Fix 4 the gate checks `play.css` ONLY, not per-app CSS). Bypass: `SKIP_PLAY_CLONE_REGISTRY_CHECK=1` (never to ship a real dark clone).

2. **merged ≠ live / merged ≠ deployed (the actual harmonyforge root cause)** — harmonyforge's row + route + `.pc-theme-harmonyforge` block ALL landed together in one commit (site PR #448) and never diverged, so the on-main code was always complete. It was still "silently dark on /play" because it had been marked **SHIPPED in the hub registry/work-queue (V137) before the change was LIVE on the deployed /play index** — the play deploy-unit hadn't rebuilt yet (build-watch-paths / the Cloudflare build-queue lag, § R-SITE-BUILD-SPLIT invariant 6 + `RUNBOOK_CLOUDFLARE_BUILD_QUEUE_FIX`). **Discipline:** do NOT flip a clone to `shipped` in `REGISTRY_WEB_CLONES.txt` (or claim it done) until you have **verified it renders on the DEPLOYED `/play` page**, not merely that the PR merged — the same "verify PR merged ≠ verify live" gap the workflow's SHIPPED rule warns about, one layer out (merge → deploy). A clone is *live-dark* until the play unit rebuilds; a merged PR is necessary but not sufficient. **How to live-verify (the `-L`/trailing-slash discipline):** the site canonicalizes to trailing-slash URLs, so a bare `/play/<app>` returns a **steady-state `307` to `/play/<app>/` even when fully deployed** — a no-`-L` curl on the non-slash route ALWAYS shows `307`, and reading that as "not deployed yet" is a false negative (cost a wasted deploy-wait, 2026-07-13 scienceforge #40). Verify with a browser UA (the CDN 403s bare UAs) **AND follow redirects**: `curl -sL -w '%{http_code}' -A "<browser-UA>" https://spark-and-anvil.com/play/<app>/designer` must be **200**, and `curl -sL … /play/ | grep -c '<app>'` must be > 0. The real not-yet-deployed signals are a *followed*-redirect **404** or the `/play/` index not listing the clone; the fastest positive tell is a kit-JSON (`/play/<app>/kits/<kitId>.json`) returning **200**. Full recipe: `Docs/WEB_CLONE_PICKUP_RUNBOOK.md` § 7a.

### When this rule applies

- Authoring or extending any `/play/<app>` clone → run the audit for that app before shipping; every route linked from the landing, every novel feature a headline card, the clones.ts row added.
- Reviewing a clone PR → a new `.astro` route or `run*` lib with no inbound link is a defect (same weight as a missing parity axis).
- Periodically / when resuming the clone program → run the portfolio-wide sweep; every 🔴 is a backfill-wiring work item, recorded in `Docs/AUDIT_WEB_CLONE_SURFACE_WIRING_<date>.md`.

### Cross-references
- `scripts/audit_web_clone_surface_wiring.py` — the gate · `Docs/AUDIT_WEB_CLONE_SURFACE_WIRING_2026-07-11.md` — the reference sweep
- `.claude/rules/portfolio.md` § "Asset Consumer Audit" (registered ≠ wired — the parent pattern) · `.claude/rules/distributed-narrative.md` § R-CAST-EXPANSION-INTEGRATION (authored ≠ integrated — sibling)
- § R-WEB-CLONE-PARITY-DOD (the ship gate this joins) · § R-WEB-CLONE-BACKPORT-MINING (the novel features this rule ensures are visible)
- `spark-anvil-site/scripts/check-play-clone-registry.mjs` — the prebuild gate for the clones.ts row + theme (the harmonyforge dark backstop) · `spark-anvil-site/scripts/check-site-internal-links.py` — the complementary broken-link checker (this rule catches ABSENT links, that one catches BROKEN links)
- `Docs/AUDIT_WEB_CLONE_DARK_SURFACE_HARMONYFORGE_2026-07-12.md` — the harmonyforge incident audit + portfolio sweep (0 dark) · `.claude/rules/workflow.md` § "Verify PR Merged" (the merged≠live discipline this extends to merged≠deployed)

## Every clone must tightly integrate the DN narrative assets — mascot, cast portraits, storybooks, audio dramas, DIR/FEDC reflection (R-WEB-CLONE-NARRATIVE-INTEGRATION; 2026-07-11)

**Every `/play/<app>` clone landing MUST surface the portfolio's Distributed-Narrative assets — the app MASCOT, the CAST PORTRAITS, a link from each cast member to their illustrated T1/T2 multi-beat STORYBOOK + AUDIO DRAMA, and a between-practice DIR/FEDC affect-recognition REFLECTION — not a bare cast name-list.** A clone that ports the learning kits but leaves the mascot, portraits, storybooks, and audio dramas dark is only half-built: the DN thesis is *"the cast IS the curriculum"* (Naul+Liu empathetic-characters + distributed-narrative axes), so the characters + their stories are load-bearing motivation, not decoration. Codified per user-direct 2026-07-11 (*"why the mascot illustrations, cast characters portraits, t1/t2 multi-beat storybooks with illustrations, audio dramas are not tightly integrated with the web clones? … and dir/fedc reflections too … fix for all shipped web clones and codify as a rule"*).

### Why they were dark (the gap this closes)

The clones were scoped as self-contained *learning-parity* surfaces: port kits → `_shared/` MC engine + build the bespoke mechanic + theme. The cast was surfaced only as a text name-list (`cast.map(m => m.name).join(' · ')`). Meanwhile the mascots (`/apps/<app>/mascot.webp`), cast portraits (`/cast/<app>/<slug>.webp`), T1/T2 illustrated storybooks (`/cast/<app>/<slug>[/advanced]`), and audio dramas (hosted on those `/cast` pages) all already exist — the clones just never referenced them. It was a scoping gap, not a technical blocker.

### The two required pieces

1. **`<PlayNarrative app="<slug>" />`** on the landing (`src/components/play/PlayNarrative.astro`, the reference impl) — renders the app **mascot** + a rail of **cast portraits**, each linking to its **`/cast/<app>/<slug>`** page (which hosts the T1/T2 storybook + audio drama — three asset types integrated by linking to the page that already serves them). Guarded by `hasChapter(app, name)` (R-CAST-ROUTE-COVERAGE) so only chaptered members are linked; renders nothing for a chapterless cast. Replaces the bare name-list.
2. **DIR/FEDC reflection on the results screen** — `_shared/reflect.ts` `reflectionCard()`, rendered by both `_shared/mcRound.ts` + `_shared/customRound.ts` results by default (opt-out `reflection: false`). A gentle, on-device, non-clinical affect-recognition prompt — companion reflection OUTSIDE the loop (Naul+Liu P4), operationalizing R-DIR-FEDC-CHAPTER at the clone surface.

### Placement discipline (inherits R-NARRATIVE-BETWEEN-NOT-DURING)

The narrative sits at **session boundaries** — the mascot + cast rail on the **landing**, the reflection on the **results** screen — NEVER overlaid on the active practice loop. A cast portrait mid-question would be a seductive detail; on the landing/results it's between-practice motivation. This is the same rule the DN methodology enforces for cameos.

### Cross-unit routing (why it just works)

Mascots (`/apps/*`) are served by the **play** unit (kept in its trimmed `public/`). Cast portraits + storybooks + audio (`/cast/*`) are served by the **core** unit via the host-agnostic path dispatcher — the existing cross-unit link mechanism (the play-unit `check-site-internal-links.py --unit play` *excuses* `/cast` + `/apps` cross-unit refs). So `<img src="/cast/…webp">` + `<a href="/cast/…">` on a play page resolve at runtime with zero extra config.

### Enforcement (joins the DoD gate)

`scripts/audit_web_clone_surface_wiring.py` checks each landing renders `<PlayNarrative>` (a clone whose landing lacks it is flagged **NO NARRATIVE INTEGRATION** — same weight as a dark route). This joins R-WEB-CLONE-NO-DARK-SURFACE + the two parity axes as a ship condition. **Reference backfill (2026-07-11):** all 12 shipped clones integrated (mascot + portraits + storybook/audio links + auto DIR/FEDC reflection); recorded in `Docs/AUDIT_WEB_CLONE_SURFACE_WIRING_2026-07-11.md`.

### When this rule applies

- Authoring any new `/play/<app>` clone → add `<PlayNarrative app>` to the landing from day one; the DIR/FEDC reflection is automatic via `_shared`.
- Reviewing a clone PR → a landing with a bare cast name-list (no `<PlayNarrative>`) is a defect.
- A clone whose app later gains cast portraits / chapters / audio → the component picks them up automatically (it reads `apps.generated.ts` + `hasChapter`), so no per-clone edit is needed when the DN assets land.

### Cross-references

- `src/components/play/PlayNarrative.astro` (reference impl) · `src/lib/play/_shared/reflect.ts` (DIR/FEDC reflection) · `scripts/audit_web_clone_surface_wiring.py` (the enforcement)
- § R-WEB-CLONE-NO-DARK-SURFACE (sibling — this rule ensures the *narrative* surface isn't dark) · § R-CAST-PORTRAIT-SLUG / § R-CAST-ROUTE-COVERAGE (the portrait/route guards it relies on)
- `.claude/rules/distributed-narrative.md` § R-NARRATIVE-BETWEEN-NOT-DURING (placement) · § R-DIR-FEDC-CHAPTER (the reflection discipline) · § DN methodology "the cast IS the curriculum"
- `Docs/ADR-032_SITE_MULTI_PROJECT_SPLIT.md` (the cross-unit dispatcher that makes `/cast` + `/apps` resolve from a play page)

## Web-clone user + developer guides must track the code (R-WEB-CLONE-GUIDE-SYNC; 2026-07-08)

**Every `/play/<app>` web clone has TWO living guides that MUST be updated in the SAME change-set as any code change that affects what they document — a visitor-facing USER guide and a maintainer-facing DEVELOPER guide.** A code change that lands without the matching guide update is incomplete, exactly like a cross-repo PR that ships without verifying the merge. Codified per user-direct 2026-07-08 (*"codify the requirement that user guide and developer guide for the web clone of fractionforge be kept up-to-date with the web clone code"*). Follows the precedent set by the `/cast` page guides (`GUIDE_CAST_PAGE_USER.md` + `GUIDE_CAST_PAGE_DEVELOPER.md`).

### The two guides (per web-clone app)

| Guide | Path | Audience | Register |
|---|---|---|---|
| **User guide** | `spark-anvil-hub/Docs/web/<app>/GUIDE_USER.md` (ADR-033) | Parents / educators / kids (ages 9-14 readable) | Warm, non-jargon (per § R-SITE-CHROME register discipline — no engineering terms, file paths, ticket numbers) |
| **Developer guide** | `spark-anvil-hub/Docs/web/<app>/GUIDE_DEVELOPER.md` (ADR-033) | The next maintainer session | Architecture + data flow + file map + load-bearing rules + extension recipes + gotchas + test/verify plan |

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

- `Docs/web/fractionforge/GUIDE_USER.md` + `Docs/web/fractionforge/GUIDE_DEVELOPER.md` — the first/reference web-clone guides
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

### R-PREBUILD-PLAY-NORMALIZE — the trimmed play build's prebuild MUST normalize too (2026-07-10)

**Every build variant that runs `astro build` — including the route-trimmed `build:play` (ADR-032 Phase 2) — MUST run `normalize-chapter-frontmatter.py` (+ `check-chapter-frontmatter-duplicates.py`) in its prebuild.** `astro build` parses the **ENTIRE `chapters` content collection** at build time **regardless of which routes it generates**, so even a build that emits only the ~8 `/play/**` routes still parses all ~1,776 chapters and trips js-yaml on any unquoted-authoring-convention chapter (the exact `incomplete explicit mapping pair` failure above).

**Reference incident (2026-07-10):** the V62 `prebuild:play` deliberately *dropped* the normalizer + chapter gates on the premise that `build:play` should "never write `src/content/chapters/` → safe alongside a chapter-content session." **That premise is unachievable** — the content collection is always parsed, so the normalizer must run. A parallel content session pushed an unquoted `role:` field (`aiforge/edge-feed-advanced.md`) and the `spark-anvil-play` Cloudflare build failed while core stayed green (core's `prebuild` normalizes). Fixed by re-adding the two parse-critical scripts to `prebuild:play` (spark-anvil-site PR #377). `prebuild:play` still legitimately drops the *quality* gates that don't affect parseability (methodology stripper, multibeat-snapshot + cast-portrait coverage checks, `lint-ios-caps.sh`) — the play unit renders no chapters, so their coverage is irrelevant to it.

**The corrected safety model:** the normalizer *does* write `src/content/chapters/` during `build:play`, so the real concurrency guarantee is NOT "never writes chapters" — it is **"run `build:play` only in an isolated `git worktree` or on Cloudflare's fresh-clone build, never the shared clone."** That discipline was already mandatory anyway, because `build-play.mjs` mutates `src/pages/` (page relocate) + `public/` (Phase 2.5 public relocate) during the build. On a fresh clone / throwaway worktree the normalizer's chapter writes are ephemeral and harmless; committing the regenerated chapters/manifests is forbidden (pathspec-scope every commit).

**Rule:** never strip `normalize-chapter-frontmatter.py` (or the dup-key check) from ANY `astro build` prebuild chain — `prebuild`, `prebuild:play`, and any future per-unit prebuild — for the same reason § "CRITICAL: Normalizer auto-runs" gives for the core prebuild. Companion to that rule; both guard the same js-yaml regression class, now across every build unit.

## The site is a multi-UNIT build split — one Astro repo, many deploy units behind a path-routing dispatcher (R-SITE-BUILD-SPLIT; 2026-07-10)

**The `spark-anvil-site` repo is ONE Astro project that builds into MULTIPLE independent Cloudflare deploy units, fronted by a single host-agnostic dispatcher Worker that routes purely by URL path.** This is the load-bearing architecture behind the `/play` clones, the `.org`/`.com` dual-serve, and the (planned) per-cluster + cast/chapters carve-outs. It is codified here — not only in `ADR-032` — because every session loads the rules file, and a decision doc "decays in visibility" (workflow.md § Audit-to-canonical-propagation). ADR-032 is the full decision + rationale; THIS is the standing convention.

### The model

- **One repo, many units.** The same repo builds different route subsets via different `build:<unit>` scripts. Today: **core** (`npm run build` — everything except the trimmed subset) + **play** (`npm run build:play` — only `/play/**`, ADR-032 Phase 2 route-trim + Phase 2.5 public-trim). Planned: **cast/chapters** (the 1,776-route + media carve-out, `AUDIT_SITE_ROUTE_CENSUS_2026-07-10.md`) + **per-cluster play units** (ADR-033 §4, `spark-anvil-math`/`-ela`/…).
- **The dispatcher routes by PATH and is HOST-AGNOSTIC.** `spark-anvil-dispatcher` (a Worker) maps `/play/*` → the play unit, everything else → core. Host-agnostic ⇒ `.com` and `.org` serve identically the moment a domain is attached (R-SITE-DOMAINS). It passes the FULL path through (so `/play/_astro/*` reaches the play unit).
- **A `build:<unit>` script = page-relocate + public-trim + (if it emits `/play`) the asset-prefix fix.** Reference impls: `build-play.mjs` (relocates non-unit pages out of `src/pages/` during build, finally-trap restores) + `play-public-relocate.mjs` (stashes media dirs the unit doesn't serve; play `dist` 1.4 GB → 33 MB) + `astro.config.mjs` `build.assetsPrefix:'/play'` gated on `PLAY_BUILD=1` (so hashed `/_astro/<hash>` resolve within the unit, not against core's divergent hashes — the P0 fix).

### The load-bearing invariants (do NOT violate)

1. **Every `build:<unit>` prebuild MUST run the parse-critical chapter gates** (normalizer + dup-key check) even if the unit renders no chapters — `astro build` parses the whole `chapters` collection regardless of route subset (R-PREBUILD-PLAY-NORMALIZE is the companion rule; it is the #1 way a split unit's build breaks).
2. **Run any `build:<unit>` ONLY in an isolated `git worktree` or on Cloudflare's fresh clone — never the shared dirty clone.** The build MUTATES `src/pages/` (page-relocate), `public/` (public-trim), and `src/content/chapters/` (normalizer). Commit **pathspec-scoped** to the unit's intended files; the regenerated chapters/manifests are build artifacts and must never be committed (`git checkout -- src/content/ src/data/` before staging).
3. **Only `_astro` needs the asset-prefix fix** (hashed + per-build-divergent). Stable-named public assets (`/fonts`,`/apps`,`/brand`,favicon) present in core are fine to resolve via the dispatcher's core route.
4. **`git push` to the site send-pack STALLS** — push via the gh Git Data API (deletions via `sha:null`); this is orthogonal to the split but always applies to site pushes.
5. **Rollback is a build-command flip.** A unit reverts to serving the full site by flipping its Cloudflare build command back to `npm run build` — all split code is inert under a full build (no code revert needed).
6. **Every deploy unit MUST have its Cloudflare Build-watch-paths scoped to its own inputs** — a push must only rebuild the units it actually affects. Because all units share ONE repo + ONE branch, a push with NO path scoping triggers a build on EVERY unit, and a high-frequency content wave then saturates the shared build queue (2026-07-10 incident: 132 one-commit-per-app content pushes × 2 units ≈ ~100-deep queue that stalled a `/play` deploy for ~40 min). **The play unit (renders no chapters) MUST NOT build on chapter-only pushes** — set its **Settings → Build → Build watch paths** Includes to the `/play`-relevant globs (`src/{pages,lib,data}/play/*`, `public/play/*`, `src/styles/play.css`, **`src/styles/play/*`**, `src/components/play/*`, the `build-play`/`*-relocate` scripts, `astro.config.mjs`, `package.json`); leave the CORE unit broad (it renders `/cast` chapter pages). **⚠ `src/styles/play/*` is REQUIRED since the 2026-07-12 R-WEB-CLONE-MERGE-HYGIENE split** moved every clone's bespoke CSS into `src/styles/play/<app>.css` — the literal `src/styles/play.css` Include does NOT match that new dir, so a per-app-CSS-only push would be **silently skipped** without it. **Glob semantics:** Cloudflare watch-path `*` matches across `/` (evidenced by clones' nested `src/{lib,data}/play/<app>/…` already triggering builds), so `src/data/play/*` already covers the glob-derived per-app registry (`src/data/play/<app>/clone.meta.ts` + `clone-types.ts`) — only the NEW `src/styles/play/` dir needed a new line. This is **account-managed** (Cloudflare dashboard per unit — hub can't set it), so it's a required step whenever a unit is created/flipped **OR a new watched input directory is introduced** (like the per-app CSS dir).

   **⚠ STANDING DISCIPLINE — re-verify the Include list on ANY change to the core files/dirs the play unit builds from.** The Include list is a hand-maintained mirror of the play unit's build-input surface; it does NOT auto-update, and a build input NOT covered by a glob is **silently skipped** (no build, no signal — the change never deploys). So whenever a PR **adds, moves, renames, or introduces a new directory for** a play-unit build input — a new top-level shared file (a new `src/styles/play.css`-sibling, a new shared config, a relocated script), a NEW directory the build reads (the per-app CSS `src/styles/play/` dir was exactly this — site PR #479 moved bespoke CSS there and the literal `src/styles/play.css` Include did not match it), or a new `build:<unit>`/prebuild input — you MUST (a) check whether the documented Include globs (the runbook block below) still cover every build input, (b) if not, update the runbook's Include list in the same PR, and (c) **flag the account-side Cloudflare Include change to the founder in the PR body** (hub can't set it; a merged-but-unwatched input is the "merged ≠ deployed" trap one layer out). The runbook's Include block is the **source-of-truth the founder syncs to the Cloudflare dashboard** — keep it accurate. Reference incident: the per-app CSS dir (2026-07-12) — caught here, not in production, precisely because this was checked. Pairs with **`R-BATCH-DISTRIBUTION-PUSH`** (workflow.md — batch a content wave into ONE squash-merge push, not one-per-app; also dodges the watch-paths bypass that fires at 20+ commits / 3000+ files). Exact globs + drain-the-queue + branch-control steps: **`Docs/RUNBOOK_CLOUDFLARE_BUILD_QUEUE_FIX_2026-07-10.md`** (deep-web-researched, cited); root cause: `Docs/AUDIT_CLOUDFLARE_BUILD_QUEUE_SATURATION_2026-07-10.md`.

### Adding a new build unit (the recipe — mirrors ADR-032 Phase 1/2)

1. Author a `build:<unit>` script pair (page-relocate + public-trim) modeled on `build-play.mjs` + `play-public-relocate.mjs`; keep the parse-critical prebuild.
2. Verify in an isolated worktree: `build:<unit>` exit 0 · expected route count · unit `_astro` assets present · internal-link check `--unit <unit>` OK.
3. **Account-coordinated (user-managed):** create the Cloudflare build unit + add the dispatcher path route (`/<prefix>/*` → the new unit) + **set the unit's Build-watch-paths to its own inputs** (invariant 6 — so the new unit doesn't build on every unrelated push). This asymmetry (code hub-side, Worker/route/watch-paths account-side) is why unit splits are staged, not auto-cycled.

### When this rule applies

- Any change to how the site builds/deploys; adding a `/play/<app>` clone's deploy granularity; the cast/chapters carve-out (V69); per-cluster units (ADR-033 §4); the `.org` dual-serve.
- Reviewing a site PR that touches `build-*.mjs`, `*-relocate.mjs`, `astro.config.mjs` `assetsPrefix`, or `package.json` `build:*`/`prebuild:*` scripts.

### Cross-references

- `Docs/ADR-032_SITE_MULTI_PROJECT_SPLIT.md` — the full decision + phases (Phase 1 dispatcher · Phase 2 route-trim · Phase 2.5 public-trim · P0 asset-prefix)
- `Docs/RUNBOOK_SITE_SPLIT_PHASE_2_CLOUDFLARE_2026-07-09.md` — the build-command flip + rollback runbook
- `Docs/RUNBOOK_CLOUDFLARE_BUILD_QUEUE_FIX_2026-07-10.md` — per-unit Build-watch-paths + drain-the-queue + branch-control steps (invariant 6) · `Docs/AUDIT_CLOUDFLARE_BUILD_QUEUE_SATURATION_2026-07-10.md` — the queue-saturation root cause · `.claude/rules/workflow.md` § R-BATCH-DISTRIBUTION-PUSH
- `Docs/AUDIT_SITE_ROUTE_CENSUS_2026-07-10.md` — the next carve-out (cast/chapters, by data)
- `Docs/ADR-033_WEB_CLONE_ARTIFACT_ORGANIZATION.md` §4 — per-cluster deploy units
- § R-PREBUILD-PLAY-NORMALIZE (companion invariant) · § R-SITE-DOMAINS (host-agnostic dual-serve) · § R-SITE-BUILD-QUIET-PRERENDER · § R-SITE-BUILD-DISK-BUDGET
- `Docs/web/fractionforge/DEPLOYMENT_RUNBOOK.md` — the per-clone deployment runbook that instantiates this

## `build:play` is not a full verification — a core-only lib's syntax error slips past it (R-SITE-CORE-PARSE-GATE; 2026-07-11)

**Verifying a change with `npm run build:play` does NOT prove the CORE build is green — the play unit relocates the `/cast` + chapter routes out of `src/pages/`, so any module imported ONLY by those core routes (e.g. `src/lib/image-url.ts`, `audio-url.ts`, chapter/cast components) is never bundled by `build:play` and its syntax errors go uncaught until the Cloudflare CORE build fails.** Any change that touches a **core-only** lib/component MUST be parse-verified against the core build (a `tsc --noEmit`, a full `npm run build`, or at minimum an `esbuild` transform of the changed file), not just `build:play`. Codified per user-direct 2026-07-11 after a P0: `image-url.ts` broke the core Cloudflare build (`Unexpected "*"`) while every `build:play` verification (mine + the parallel clone agents') stayed green.

### The specific trap that caused it — `*/` inside a `/* */` block comment

**Never place a `*/` sequence inside a `/* … */` (or JSDoc `/** … */`) block comment — it terminates the comment early.** The most common way this sneaks in is an embedded **glob or regex**: `` `public/chapters/**/*.webp` `` contains `**/` whose `*/` closed the JSDoc block, and esbuild then parsed the trailing `*.webp …` as code → `Unexpected "*"`, core build fails in ~5s. Guard:
- In a block comment, reword any glob/regex so no `*/` appears — e.g. write "public/chapters, then any subdir, then any `.webp`", or split the stars (`* /` is still unsafe; avoid the sequence entirely), or use `//` line comments (which have no early-terminator).
- The regression class is *any* `*/`-bearing token in a block comment: globs (`**/*.ext`), regex literals (`/foo.*/`), file lists. Prefer `//` line comments for anything containing `*` next to `/`.

### The fast parse gate (run on any core-lib change)

```bash
# parse-check a changed TS file without a full build (catches the comment-terminator + syntax class):
node -e "require('esbuild').transformSync(require('fs').readFileSync('src/lib/<file>.ts','utf8'),{loader:'ts'}); console.log('PARSE OK')"
# or verify the whole core build when a core-only module changed:
npm run build            # (not just build:play)
```

### When this rule applies
- Any edit to `src/lib/*` or a component imported only by `/cast`/chapter/core routes → parse-verify against core, not just `build:play`.
- Authoring/reviewing ANY `.ts`/`.astro`/`.mjs` with a block comment that embeds a glob, regex, or path with `*` — scan for a stray `*/`.

### Cross-references
- § R-SITE-BUILD-SPLIT (why `build:play` bundles only the play routes) · § R-PREBUILD-PLAY-NORMALIZE (the sibling "a build variant still parses X" invariant)
- spark-anvil-site PR #401 (the P0 fix) · `src/lib/image-url.ts` (the reference incident) · `src/lib/audio-url.ts` / `pdf-url.ts` (sibling core-only libs that carry the same risk)

## The shared `play.css` tail-append is a merge-collision hotspot — parse-gate it at prebuild (R-PLAY-CSS-PARSE-GATE; 2026-07-12)

**`src/styles/play.css` is a SHARED, tail-appended surface — every `/play/<app>` clone build appends its `.pc-theme-<app>` block to the end under R-PARALLEL-WEB-CLONE-BUILD single-flight — and concurrent clone merges routinely collide on that tail. A botched tail-append conflict resolution that DROPS a closing `}` red-builds the Cloudflare `build:play` with `[postcss] play.css:<EOF>:1: Unclosed block` — a P0 that surfaces ~1.6s deep in vite (after the whole prebuild) with the error line reported at EOF (useless for localizing).** The gate `scripts/check-play-css-parse.mjs` (postcss parse + a brace-balance localizer) is wired into BOTH `prebuild` and `prebuild:play` so this class fails LOUDLY at prebuild with the real unclosed-block line, not deep in the build. Codified per founder-direct 2026-07-12 (*"fix and codify"*) after the V121 P0.

### The failure class + why the gate is needed

The handoff/runbook already warns: on a `play.css` merge-race, "resolve the tail-append conflict (delete the 3 marker lines to keep BOTH blocks concatenated)." When that resolution instead drops a `}` — most often a `@media (prefers-reduced-motion: reduce)` block's closer, because it's the LAST line of a clone's append and the easiest to lose to a conflict hunk — every subsequent block nests inside it and postcss hits EOF still open. **Reference incident (V121, site PR #429):** the FossilForge×ProofQuest tail-append collision dropped the FossilForge reduced-motion block's `}` (play.css:1721); `build:play` went red. `check-core-lib-parse.mjs` (the sibling TS gate) never looks at CSS, so nothing caught it pre-deploy.

### The gate (two layers, mirrors check-core-lib-parse.mjs)

1. **postcss.parse** of every `src/styles/*.css` — catches the whole CSS syntax-error class (present during any real build; postcss is a build dep).
2. **Brace-balance localizer** (dependency-free — runs even in a bare worktree with no `node_modules`) — reports open/close counts, final depth, and *the last line at depth 0* (the unclosed block opens just after it), turning postcss's EOF line into an actionable location.

Emergency bypass: `SKIP_PLAY_CSS_CHECK=1` (never to ship a real unclosed block — only if the gate itself misfires).

### When this rule applies
- Authoring/extending any `/play/<app>` clone (every clone appends to `play.css`) — the gate runs automatically in prebuild.
- **Resolving a `play.css` tail-append merge conflict** (the trigger) — after `git rebase --continue`, run `node scripts/check-play-css-parse.mjs` before pushing; a dropped/extra brace fails it immediately.
- Reviewing any PR that touches `src/styles/play.css`.

### Cross-references
- `scripts/check-play-css-parse.mjs` — the gate · spark-anvil-site PR #429 (the V121 P0 fix + gate)
- § R-SITE-CORE-PARSE-GATE (the sibling TS parse gate this mirrors) · § R-PARALLEL-WEB-CLONE-BUILD (the single-flight `play.css` tail-append discipline whose merge-races cause this) · § R-SITE-BUILD-SPLIT invariant on the `play.css` conflict resolution

## Kill the parallel-fleet merge-races structurally — union-merge the append-only shared surfaces + per-app CSS files (R-WEB-CLONE-MERGE-HYGIENE; 2026-07-12)

**The parallel web-clone fleet's push/merge conflicts come almost entirely from a handful of APPEND-ONLY shared files that every clone touches at the same spot (the tail / the closing bracket). Three structural changes remove the conflicts at the source instead of resolving them by hand every time.** Codified per founder-direct 2026-07-12 (*"there are a lot of push/merge conflicts with all the parallel hub agents. what can we do about it?"*). The reactive discipline (rebase-then-resolve, keep-both, renumber-on-conflict — R-PARALLEL-WEB-CLONE-BUILD / R-PARALLEL-HUB-AGENTS) stays as the fallback, but these make it rarely needed.

### The conflict hotspots (measured across the V105–V135 clone waves)

| Shared file | repo | why it collides | fix |
|---|---|---|---|
| `src/styles/play.css` | site | ~~every clone tail-appends its `.pc-theme-<app>` + `.<ns>-*` block~~ → now ONLY the tiny `.pc-theme-<app>` accent block appends here; all `.<ns>-*` bespoke is per-app | **per-app CSS file DONE** (site PR #479) + union-merge on the residual theme-block append |
| `src/data/play/clones.ts` | site | ~~every clone appends one row before `];`~~ → **glob-derived DONE** (site PR #481): each clone owns `src/data/play/<app>/clone.meta.ts`; `clones.ts` assembles via `import.meta.glob`. **Zero shared-file edit to register a clone.** |
| `Docs/REGISTRY_WEB_CLONES.txt` | hub | every clone appends one row + a Count | **union-merge** (now) |
| `.claude/CLAIMS.md` | hub | every session appends a claim line | **union-merge** (now) |
| work-queue `V<N>` | hub | monotonic counter → semantic number collision | **renumber-on-conflict** stays (union is unsafe — see below) |

### Fix 1 — `merge=union` on the pure append-only files (shipped 2026-07-12; the immediate win)

git's built-in **`union` merge driver** resolves an append-race by keeping **BOTH** sides' added lines with **NO conflict markers** — the automatic equivalent of the "keep both" resolution, and it **never drops a closing `}`** (the R-PLAY-CSS-PARSE-GATE breakage class was born from hand-resolving `play.css`). Wired via `.gitattributes` in **both** repos:

- **site `.gitattributes`:** `src/styles/play.css merge=union` **only** — `src/data/play/clones.ts` is now **GLOB-DERIVED** (site PR #481; each clone owns `src/data/play/<app>/clone.meta.ts`), so it no longer receives per-clone appends and its union-merge was **dropped** (see the Deferred/DONE section below + the `.gitattributes` NOTE).
- **hub `.gitattributes`:** `Docs/REGISTRY_WEB_CLONES.txt merge=union` · `.claude/CLAIMS.md merge=union`

**Safe ONLY because these are genuinely append-only** — each clone adds its own DISJOINT block/row and never edits another clone's block. If you ever edit an *existing* clone's block, union can keep both versions (a semantic dup) — so the rule "touch only your own `.pc-theme-<app>` scope / your own row" (R-PARALLEL-WEB-CLONE-BUILD) is what keeps union sound. The `build:play` + `check-play-css-parse.mjs` + `check-site-internal-links.py` gates backstop any bad auto-merge (a union that produced invalid CSS/TS fails the build loudly, exactly as a hand-merge would).

### Fix 2 — every clone's BESPOKE CSS lives in a PER-APP file (MANDATORY; the legacy backfill is DONE 2026-07-12)

A `/play/<app>` clone MUST put its `.<ns>-*` mechanic/bespoke classes in its **own** file `src/styles/play/<app>.css` and import it from its own pages (`import '~/styles/play/<app>.css'`, alongside the shared `import '~/styles/play.css'` base) — **NEVER** append a bespoke block to the shared `play.css` tail. Per-app files are disjoint by construction (ADR-033 namespacing) → **zero cross-clone CSS collision**, and the css-parse-gate's brace-drop class disappears. This is now a hard rule, not a "SHOULD" — a clone PR that appends a `.<ns>-*` block to `play.css` is a defect.

**The one thing that STILL lives in `play.css`: the small `.pc-theme-<app> { --accent-vars }` block.** The `/play` index gallery (`src/pages/play/index.astro`) themes every clone card with `pc-theme-<app>`, so it needs all 39+ theme blocks; and a theme block is single-brace + disjoint (no `@media`) = **not** the collision-heavy / brace-drop part. So a new clone appends ONLY its ~9-line theme var block to `play.css` (union-merged, low-risk) and puts everything else in `src/styles/play/<app>.css`.

**Legacy backfill — DONE (site PR #479, 2026-07-12, founder-directed quiet-window run).** All 39 legacy per-app bespoke blocks were split out of `play.css` (2847 → 802 lines) into `src/styles/play/<app>.css`, with the per-app import added to all 246 `/play` pages. `play.css` now holds only the shared base (`.ff-*`/`.pc-*` primitives, HUD/card/button, cast strip, avatar, results, adventures, the shared DIR/FEDC reflection card + SEL crisis footer) + the 39 `.pc-theme-<app>` accent-var blocks. Method (reusable for any future shared-CSS split): attribute rules by **banner-delimited section, NOT namespace prefix** (`gf-` is shared by geometryforge+grammarforge, `cf-` by chanceforge+cipherforge — prefix attribution is unsafe); anything ambiguous stays in the base (conservative); then **prove safety with a per-page CSS class-coverage fingerprint before/after** (`/tmp/css_coverage.py` pattern: for each built page, the set of rendered classes that resolve in its loaded CSS must be unchanged — it caught the one real regression, the index losing its theme blocks). The `check-play-css-parse.mjs` gate now parse-gates every `src/styles/play/*.css` too.

### Fix 3 — keep per-clone WORK-QUEUE entries tiny + renumber-on-conflict (union is UNSAFE here)

The work-queue `V<N>` is a monotonic counter, so two sessions grabbing the same N is a *semantic* collision union-merge cannot fix (it would keep two `## V134` headers). So: (a) **keep renumber-on-conflict** (pull-first, max+1, renumber your own on a clash — it's a ~30-second fix), and (b) **keep each clone's work-queue entry to a few lines** (a pointer to the authoritative `Docs/web/<app>/` doc-set), NOT a 15-line block — less text = lower collision odds + faster resolution. The full ship record lives in `Docs/web/<app>/`, which is disjoint per clone.

### Deferred (durable end-state — do in a fleet-drain quiet window, not live)

**BOTH big deferred refactors are now DONE (2026-07-12, founder-directed quiet-window runs):**
- **`play.css` per-app-block split** — site PR #479 (+ #480 ambiguous-CSS cleanup). See Fix 2.
- **glob-derived `clones.ts`** — site PR #481. Each clone owns `src/data/play/<app>/clone.meta.ts`; `clones.ts` assembles them via `import.meta.glob` (sorted subject-then-name, deterministic). Registering a clone is now a pure add-a-file-in-your-own-subtree op — **zero shared-array edit**. `check-play-clone-registry.mjs` was repointed at the per-app meta files (route dir with no meta = dark), and `.gitattributes` dropped the now-obsolete `clones.ts` union-merge. This ALSO fixed a live dark-clone bug it surfaced (wildlens + cubesensei had collapsed into one object literal via a botched union-merge → JS last-key-wins dropped wildlens from `PLAY_CLONES` = dark on `/play`; the per-app-file model makes that collapse class structurally impossible). **Follow-up (2026-07-12, escapeforge lane):** the hub `scripts/audit_web_clone_surface_wiring.py` registry check was ALSO stale — it still grepped the central `clones.ts` for `slug:` rows (empty post-#481), so it false-flagged **every** glob-derived clone as `🔴 DARK — MISSING clones.ts registry row`. Repointed to check for `src/data/play/<app>/clone.meta.ts` (with the legacy central-row grep kept as a fallback). Any script that decided "is this clone registered?" by reading `clones.ts` must be repointed the same way.

**The ONLY residual shared-file touch per new clone is the tiny `.pc-theme-<app>` accent block appended to `play.css`** (single-brace, disjoint, union-merged — see Fix 2; the index gallery needs all themes). Everything else — bespoke CSS, registry row, pages, lib, data, docs — is disjoint per clone by construction. A fully-zero-shared-touch end-state (glob-aggregate the theme blocks too, so `play.css` gets no per-clone append) is possible but low-value: the theme-block append is union-merge-safe + brace-drop-immune, so it stays a deliberate, documented residual rather than more machinery.

### Fix 4 — audit-surfaced residual hardening (2026-07-14 shared-surface audit)

The 2026-07-14 full shared-surface audit (`Docs/AUDIT_WEB_CLONE_SHARED_SURFACE_CONFLICTS_2026-07-14.md`, run against `origin/main` with **4 clone lanes building concurrently** — V196–199) confirmed the Fix-1/2/3 model holds (63 clones; `clones.ts` glob-derived with zero appends; 104 disjoint per-app bank specs; registry + CLAIMS union-merged) and surfaced **three residual defects the model created or left open**. All three are now codified:

1. **The `.pc-theme-<app>` accent block MUST live in `play.css`, NEVER only in the per-app `src/styles/play/<app>.css`** — and the registry gate must enforce *that specific location*. Root cause: evading the last shared append (Fix 2 says bespoke CSS goes per-app) tempts an author to also drop the *theme* block into the per-app file. But the `/play` **index gallery (`src/pages/play/index.astro`) imports ONLY `play.css`** — never per-app CSS — so a theme block that lives only in the per-app file renders the clone's index card **un-themed** (default accent). **The gate was blind to this:** `check-play-clone-registry.mjs` built its theme corpus from `play.css` **+ every per-app CSS**, so a per-app-only theme block passed. **Fix:** the gate's theme-presence check now reads **`play.css` ONLY** (bespoke `.<ns>-*` classes may still live per-app; the `.pc-theme-<app>` *accent block* may not). Reference defect: **quillspell** shipped its theme block in `quillspell.css` only → un-themed index card, gate green (fixed in the same change that tightened the gate). This is why Fix 2's "ONLY the small theme block may go in `play.css`" is a *must*, not a *may*.

2. **`Docs/REGISTRY_WEB_CLONES.txt` `# Count:` footer + `planned` rows are UNION-UNSAFE — the count is advisory, `grep -c '| shipped |'` is authoritative.** union-merge keeps BOTH sides' lines with no dedup or arithmetic, so (a) a monotonic `# Count: N` line written by two lanes yields two/again-stale count lines, and (b) a `planned` row for a clone that later ships as a `shipped` row leaves a **stale duplicate** (4 such stale `planned` rows — escapeforge/alcumusforge/haikuquest/machineforge — were purged 2026-07-14). **Discipline:** never trust or hand-bump the `# Count:` line; the authoritative shipped tally is `grep -c '| shipped |' Docs/REGISTRY_WEB_CLONES.txt`. A clone that had a `planned` row MUST have it removed (not left) when its `shipped` row lands — a lane's own row edit, not a shared rewrite. A periodic dedup sweep (`cut -d'|' -f1 | sort | uniq -d`) is part of registry hygiene. **Do NOT add new monotonic counters / totals to any union-merged file** — a counter is the one thing union merge structurally cannot reconcile (same class as the work-queue `V<N>`, Fix 3).

3. **The work-queue `V<N>` remains the DOMINANT hard-conflict surface — and it is unavoidable under union merge (it's a counter).** The audit found 4 lanes concurrently claiming V196/197/198/199, coordinated only by the manual "pull-first `max+1`; renumber-on-conflict" discipline (Fix 3) + `.claude/CLAIMS.md` announcements. This works but is the highest-friction residual. The durable escalation (tracked, not yet built) is to **make the per-clone work-queue entry a glob-derived per-lane FILE** — the same move that killed the `clones.ts` append (Fix 1→per-app `clone.meta.ts`): each lane writes `Docs/work-queue/V<slug>.md` in its own name and an index assembles them, so no two lanes ever pick the same monotonic integer. Until then, `V<N>` clashes are expected and resolved by renumber-keep-both.

### When this rule applies
- Authoring any new `/play/<app>` clone → **Fix 2 is mandatory**: all bespoke `.<ns>-*` CSS in `src/styles/play/<app>.css` (imported from the clone's pages); the `.pc-theme-<app>` accent block **MUST** go in `play.css` (Fix 4 — the index imports only `play.css`), never only per-app; rely on Fix 1 for the registry/clones.ts + theme-block appends.
- Reviewing a clone PR → a `.<ns>-*` bespoke block appended to `play.css` (instead of a per-app file) is a defect; so is a `.pc-theme-<app>` block that lives ONLY in the per-app CSS (Fix 4 — un-themed index card, gate-blind).
- Any parallel hub session hitting an append-race on the four union-merged files → the rebase now auto-resolves; just verify the gates (`build:play` / css-parse / internal-links) pass.
- A work-queue `V<N>` clash → renumber-on-conflict (Fix 3), keep-both.

### Cross-references
- `spark-anvil-site/.gitattributes` + `spark-anvil-hub/.gitattributes` — the union-merge wiring
- § R-PARALLEL-WEB-CLONE-BUILD (the disjoint-namespace + single-flight discipline this makes cheaper) · § R-PLAY-CSS-PARSE-GATE (the backstop for a bad `play.css` auto-merge) · `.claude/rules/workflow.md` § R-PARALLEL-HUB-AGENTS (the portfolio-wide parent) · § R-SITE-BUILD-SPLIT
- `Docs/PLAN_PARALLEL_WEB_CLONE_DEVELOPMENT_2026-07-10.md` — the full contention table (the deferred glob-derivation belongs here as the next escalation)

## All hub-side `spark-anvil-site` work happens in a throwaway `git worktree` off `origin/main` — never the shared clone (R-SITE-WORKTREE; 2026-07-13)

**Any hub session touching `spark-anvil-site` — building a clone, authoring tests, verifying a build, a docs/rule edit that must compile against the site — MUST work in a fresh `git worktree` checked out from `origin/main`, NOT in the shared `/Volumes/.../spark-anvil-site` working clone.** Codified per founder-direct 2026-07-13 (*"codify the site worktree approach"*) after the shared clone was found 8 commits behind with untracked parallel-session build dirs (a mid-build `heatforge`, a stray `waveforge` lib) that **aborted `git pull --ff-only`** — the exact stale/dirty-shared-clone trap this rule removes.

### Why the shared clone is unsafe for hub work

The one on-disk `spark-anvil-site` clone is a shared resource: parallel clone-build sessions leave untracked/mid-build dirs in it, the Playwright/`astro dev` **prebuild normalizer mutates `src/content/chapters/**` on every run** (a build artifact that must never be committed — R-SITE-BUILD-SPLIT invariant 2), and its `main` pointer drifts behind `origin`. Working there means fighting `pull` aborts, accidentally staging another session's files (a whole-index commit sweeps them in — R-PARALLEL-HUB-AGENTS discipline 6), and committing normalizer noise. A worktree off `origin/main` is clean by construction and disjoint from all of that.

### The canonical recipe

```bash
cd /Volumes/Data/Portfolios/spark-anvil-portfolio/spark-anvil-site
git fetch origin main
WT=/tmp/wt-<purpose>            # e.g. /tmp/wt-clone-tests, /tmp/wt-<app>
git worktree prune && git worktree add "$WT" origin/main
ln -s "$(pwd)/node_modules" "$WT/node_modules"   # reuse deps (Playwright browsers are global at ~/Library/Caches/ms-playwright)
cd "$WT"
# …author test-files / clone source / verify build here…
```

Load-bearing discipline inside the worktree:
- **Commit pathspec-scoped, never `git add -A`** — the normalizer will have dirtied `src/content/chapters/**` + `src/data/**`; `git checkout -- src/content/ src/data/` to discard those build artifacts before staging, and stage only your intended files (R-SITE-BUILD-SPLIT invariant 2 + R-PARALLEL-HUB-AGENTS discipline 6).
- **Stale-deps fix is `npm install <pkg>@<range> --no-save`** (never bare `npm install` — lockfile churn), per R-WEB-CLONE-BUILD-STALE-DEPS below.
- **One PR per wave, rebased onto `origin/main`** between merges — disjoint per-app / test-only files → clean rebase (a stacked branch's already-merged commits drop automatically).
- **Remove the worktree when done:** `git worktree remove "$WT"` (or `git worktree prune` after deleting `/tmp/wt-*`). An unchanged worktree is auto-cleanable; never leave it as a second dirty clone.
- **Push works from the worktree** (`git push -u origin <branch>`); the memory note about `git push` stalling applies to bulk history rewrites, not ordinary branch pushes.

### When it applies
- Every hub-side site task: clone builds (R-PARALLEL-WEB-CLONE-BUILD already mandates a per-app worktree — this generalizes it to ALL site work), test-authoring waves, `build:play`/`build` verification, any edit that must compile against the site.
- The `Agent`/subagent equivalent: a delegated site task gets its OWN worktree (never shares one).

### Cross-references
- § R-SITE-BUILD-SPLIT invariant 2 (run any `build:<unit>` only in an isolated worktree; the build mutates `src/pages/` + `public/` + `src/content/chapters/`) · § R-PARALLEL-WEB-CLONE-BUILD (per-app worktree for clone builds) · `.claude/rules/workflow.md` § R-PARALLEL-HUB-AGENTS (discipline 6 pathspec-commit; stale-clone recovery)

## Parallel clone-building — one agent per app, disjoint by construction (R-PARALLEL-WEB-CLONE-BUILD; 2026-07-10)

**Multiple hub agents MAY build multiple `/play/<app>` clones in parallel — a specialization of `R-PARALLEL-HUB-AGENTS` (workflow.md) enabled by ADR-033 per-app namespacing.** Because every clone lives in its own disjoint `src/{pages,lib,data}/play/<app>/` + `public/play/<app>/` + `Docs/web/<app>/` subtree, two agents building different apps touch **zero common files** in the normal path — which designs out the dominant parallel-agent failure mode (shared-hotspot merge conflicts).

> **The single-entry pickup runbook:** an agent (parallel or solo) starting the next clone should read **`Docs/WEB_CLONE_PICKUP_RUNBOOK.md`** — it sequences this rule + the ranking + the 5-phase spawn + the shared-surface single-flight list + the R-WEB-CLONE-PARITY-DOD ship gate + the ship/backport steps + the gotchas (incl. the subagent-scope discipline) into one checklist so nothing is skipped and two agents don't collide.

The discipline:

- **One agent per app, one `git worktree` each** off `origin/main` (R-SITE-BUILD-SPLIT); symlink `node_modules`; no dependency changes in parallel sessions (lockfile churn).
- **R-WEB-CLONE-BUILD-STALE-DEPS — a stale symlinked `node_modules` red-fails `build:play` on ANOTHER clone's dep, not yours.** The build worktree symlinks the MAIN clone's `node_modules`; if a *parallel* session's clone added a new npm dependency after that main clone was last installed, `build:play` fails with **`[vite] Rollup failed to resolve import "<pkg>" from "src/lib/play/<other-app>/*.ts"`** for a package that IS in `package.json` + `package-lock.json` (so Cloudflare `npm ci` builds fine) but is absent from the shared `node_modules`. It is NOT your bug and NOT a broken `main` — it's a stale install. Fix: **`npm install <pkg>@<range-from-package.json> --no-save`** (materializes the declared dep WITHOUT touching the lockfile — verify `git status package.json package-lock.json` stays clean), then re-run `build:play`. Never run bare `npm install` / edit deps in a parallel worktree (lockfile churn — violates the discipline above); `--no-save` only fills the gap. Reference: the 2026-07-12 quillspell Track-B build failed on `cubesensei/net.ts` importing `cubing/twisty` (declared in the lockfile, uninstalled in the stale shared `node_modules`); `npm install cubing@^0.63.3 --no-save` unblocked it. Full runbook step: `WEB_CLONE_PICKUP_RUNBOOK.md` § 2 (Environment).
- **Claim the app** in `.claude/CLAIMS.md` before starting (R-PARALLEL-HUB-AGENTS territory claiming); pull the next unclaimed app from `AUDIT_WEB_CLONE_NEXT_RANKING`.
- **Single-flight ONLY the enumerated shared surfaces** — `src/lib/play/_shared/`, `astro.config.mjs`, `package.json build:*`, `src/components/play/`, `REGISTRY_WEB_CLONES.txt`, the work-queue numbers, and the Gemini key (only if a clone gens new assets — clones normally PORT, so this is the exception). Everything else is disjoint and parallelizes freely.
- **Push via the gh Git Data API** (base=main tree-merge → disjoint pushes merge cleanly); **merge PRs sequentially**, update-branch-then-retry on a merge-race (never `--admin` past a real conflict).
- **Scale:** ~4–8 parallel clone-agents (review-bound); a `staging/web-clones-<batch>` branch for large batches; per-cluster build units + Turborepo `affected`/remote-cache as the CI escalation (ADR-033 §4). Full contention table + per-agent workflow + external-research mapping: **`Docs/PLAN_PARALLEL_WEB_CLONE_DEVELOPMENT_2026-07-10.md`**.

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

**Beat-`.webp` Tier-2 migration — code-prep LANDED, history rewrite GATED (V100, 2026-07-11).** The env-gated CDN-resolution code shipped (**site PR #396**): `src/lib/image-url.ts` (`cdnifyImagePath`, sibling to `audio-url.ts`) + CDN-aware `build-multibeat-chapter-manifest.mjs` + CDN-aware `check-multibeat-snapshot-coverage.py` + the 5 `/chapters/` beat-image emission sites. It is **INERT until `PUBLIC_IMAGE_CDN_URL` is set** on the Cloudflare build units (env unset → byte-identical local behavior), so it changes nothing in prod until the coordinated finale. The finale (upload 5,645 beat `.webp` → R2 via `scripts/upload_beat_images_to_r2.py`, `git rm` from `public/chapters/`, path-scoped `filter-repo 'public/chapters/*/*.webp'` → `.git` 647 → ~50–90 MiB) is a **founder-gated, account-coordinated** operation — full method in **`Docs/RUNBOOK_SITE_BEAT_WEBP_R2_MIGRATION_2026-07-11.md`**. **Scope-preserve (load-bearing):** the purge is `public/chapters/**/*.webp` ONLY — cast portraits (`public/cast/**`; R-CAST-PORTRAIT-SLUG needs them local), book covers (`public/books/covers/**`), `public/brand/**`, and `public/pilot/**` STAY local and must never be swept (same class of mistake the V96 companion-pack scope-correction avoided). The hub byte-backup (R-R2-SYSTEM-OF-RECORD) for images is a documented founder decision in the runbook (recommend the layer-2 off-site rclone mirror over +589 MiB hub bloat). Complements § R-SITE-BLOBLESS-CLONE (the always-safe interim).

### R-SITE-BUILD-DISK-BUDGET — watch the number every content wave

- Before a large content wave, check `du -sh spark-anvil-site/public` and `du -sh public/*`. Treat **`public/` > ~4 GB** as the danger zone until the R2 `git rm` completes; **> ~5 GB** risks ENOSPC on Cloudflare.
- The single biggest lever is `.m4a` audio. New audio-bearing chapters are the fastest way to grow the budget.
- **Never** re-encode or delete shipped audio to save space without user approval (destructive to a shipped surface).
- Interim mitigations if a deploy is blocked before R2: (1) lower audio bitrate (48 kbps mono) — destructive, needs approval; (2) prune verified-orphaned dirs (`public/pilot`, `public/companion-pack`) — small; (3) pause new audio-bearing content. None substitute for R2.

### Cross-references

- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § "V28 P0 — Cloudflare Pages build FAIL: ENOSPC" — the incident + full fix plan
- § R-SITE-BUILD-QUIET-PRERENDER (above) — sibling build-behavior note (the same `public/`-copy phase that overflows here is the one that looks "hung")
- `.claude/rules/spark-anvil-website.md` "Tech stack" / "Hub does NOT own" — R2 bucket + DNS are user-managed; hub owns the code-side migration

## Slimming `spark-anvil-site` git history — large-push + purge-during-active-content discipline (R-SITE-HISTORY-PURGE; 2026-07-11)

**When rewriting `spark-anvil-site` history to reclaim git bloat (committed regenerable media — see ADR-034), two things are load-bearing and were learned the hard way in the V89 purge (which took the repo 9.13 → 2.84 GiB).** This rule is the standing distillation; ADR-034 + `RUNBOOK_SITE_GIT_HISTORY_PURGE_2026-07-10.md` are the full method, `PLAN_SITE_REPO_FURTHER_REDUCTION_2026-07-11.md` is the remaining-levers roadmap.

### 1. A single multi-GB push FAILS — use incremental-to-staging (the send-pack note, corrected)

The `.git` is large, so a rewritten-history force-push is a multi-GB pack. **A single such push fails GitHub with `HTTP 500` / `send-pack: unexpected disconnect`**, and neither fix people reach for is sufficient: `http.postBuffer=3G` + `http.version=HTTP/1.1` alone still 500s, and the standing "push site changes via the gh Git Data API" note (CLAUDE.md § R-SITE-BUILD-SPLIT invariant 4) **cannot push a bulk history rewrite** (the Data API is per-object). SSH transport is unavailable (no keys registered). **The working method is incremental-to-staging:**

- Push the rewritten history's objects to a **staging branch** in ~300-commit slices (`git push -f origin ${sha}:refs/heads/_purge_staging`, oldest→newest) — each slice is a small pack that clears the size limit. This leaves `main` untouched, so **no premature Cloudflare builds** fire.
- Then move `main` ONCE to the tip (`git push -f origin ${tip}:refs/heads/main`) — zero new objects (all already uploaded via staging) → instant, no 500, and exactly **one** production build triggers.
- Push the rewritten feature branches (small deltas now), delete `_purge_staging`.
- **zsh gotcha:** always brace the refspec — `${sha}:refs/heads/...`, never `$sha:refs/...` (bare `$sha:r` triggers zsh's `:r` history-modifier and eats the `:r`, faking a "src refspec does not match" failure).
- **⚠ BRANCH PROTECTION blocks the `main` force-push (2026-07-12).** `main` now carries a branch-protection rule (required status checks `Vitest (bank invariants + shell)` + `Playwright (a11y + SEL-safety smoke)`; `enforce_admins: false`; **`allow_force_pushes: false`**) — see § R-WEB-CLONE-TEST. The `allow_force_pushes: false` setting **rejects the final `git push -f …:refs/heads/main` move** that ends a purge. So a purge session MUST **temporarily lift protection**, do the `main` move, then **restore it** — an admin, account-scoped step: `gh api -X DELETE repos/nathant99/spark-anvil-site/branches/main/protection` before the move, then re-`PUT` the same protection JSON after (keep a copy of the read-back: `gh api repos/nathant99/spark-anvil-site/branches/main/protection`). The staging-branch slices are unaffected (they push to `_purge_staging`, not `main`); only the single `main` tip-move needs the window.

### 2. A history purge push needs the content cascade ACTUALLY STOPPED (not just idle)

A rewrite force-push based on `main==BASE` **clobbers any commit pushed after BASE**. When a content wave (e.g., a V61-style per-app cascade, or any `sync_content_to_site.sh` batch) is running, `main` advances mid-operation and the push either aborts (if guarded) or destroys in-flight commits (if not). In V89 the cascade **broke the coordinated freeze 3×** — a time-based quiescence check (origin stable for N minutes) **cannot distinguish "paused" from "done"**, because the cascade has pauses longer than any practical check window. Therefore:

- **Require the cascade session to be genuinely halted** (paused/killed + confirmed), OR wait until it has fully completed — not merely "quiet right now."
- **Always keep a pre-push guard** — re-check `origin/main == BASE` immediately before the `main` move; abort if it moved (origin is never left half-rewritten — git updates refs only after the full pack lands).
- **Run purge + push in foreground-sized stages, not one long background job** — long background jobs die on harness/connectivity hiccups mid-run (a V89 one-shot got killed after the `.m4a` pass). Stage: mirror → rewrite → guard → staged push, each a discrete step resumable from the last.
- **Take the STEP 0 backup mirror first** (see `BACKUP_SITE_PRE_PURGE_MIRROR_*`) — the only rollback for a rewrite.
- **After the push, the user re-triggers Cloudflare** (SHAs changed → cached commit gone → likely Git disconnect+reconnect) per `RUNBOOK_SITE_PURGE_CLOUDFLARE_RECONNECT_2026-07-10.md`.

### When this rule applies
- Any future `spark-anvil-site` history rewrite (the queued `.pdf` purge / Lever 1; a future beat-`.webp` migration / Lever 2; any re-purge maintenance window once media re-accretes).
- It is `spark-anvil-site`-specific (that repo's size + Cloudflare-Git coupling + active content cascades are what make it load-bearing). The prevention half — *don't commit regenerable media; route it to R2/CDN* — is the durable fix (R-SITE-MEDIA-R2 + R-SITE-BUILD-DISK-BUDGET).

### Cross-references
- `Docs/ADR-034_SITE_GIT_HISTORY_MEDIA_PURGE.md` (EXECUTED) + `Docs/RUNBOOK_SITE_GIT_HISTORY_PURGE_2026-07-10.md` + `Docs/RUNBOOK_SITE_PURGE_CLOUDFLARE_RECONNECT_2026-07-10.md`
- `Docs/PLAN_SITE_REPO_FURTHER_REDUCTION_2026-07-11.md` — remaining levers (PDF purge next) + this discipline restated
- `Docs/CONTEXT_HANDOFF_2026-07-11_SITE_PURGE_EXECUTED.md` — the V89 session record (incl. the harness-specific gotchas that stay out of this rule)
- § R-SITE-MEDIA-R2 / § R-SITE-BUILD-DISK-BUDGET (the prevention half) · CLAUDE.md § R-SITE-BUILD-SPLIT invariant 4 (the send-pack note this corrects)

## Blobless clones are the standing default for `spark-anvil-site` — no history rewrite required (R-SITE-BLOBLESS-CLONE; 2026-07-11)

**Every consumer that clones `spark-anvil-site` — local dev, a CI runner, a throwaway build worktree, a subagent — SHOULD clone it blobless: `git clone --filter=blob:none <url>`.** This is ADR-034 Track A promoted from "decided" to a standing default because it is the single **best bang-for-zero-risk** repo-size lever: it cuts fresh-clone transfer to ~the commit+tree objects (file *contents* are fetched lazily, on demand, only for the blobs you actually touch), it changes **no SHA**, it rewrites **no history**, and it is completely orthogonal to any purge — so it delivers most of the clone-time win **now**, and keeps delivering it as beat `.webp` re-accretes between purge windows.

- **Why it matters here specifically:** post-V96 the `.git` is ~647 MiB and **93% of that is beat `.webp` blobs** most consumers never read (they build `/play` or edit `/cast` prose, not repaint chapter art). A blobless clone skips downloading those ~602 MiB up front and pulls only the blobs a given task opens.
- **The commands:**
  - Full-history, contents-on-demand (recommended default): `git clone --filter=blob:none https://github.com/nathant99/spark-anvil-site.git`
  - Even lighter for a one-shot build/worktree that only needs the tip: add `--depth 1` (shallow + blobless). A shallow clone can't run `filter-repo` or deep `git log`, so use it only for build/verify, not for history work.
  - Existing full clone → convert in place: `git config remote.origin.promisor true && git config remote.origin.partialclonefilter blob:none` (future fetches go partial; already-downloaded blobs stay).
- **Caveats:** operations that must walk every blob (a history rewrite / `filter-repo`, a full `git grep` over all revisions, an offline archive) need the blobs — clone full (or `git fetch` the missing blobs on demand, which partial clone does automatically when online). A blobless clone is a *consumer/build* convenience, never the substrate for a purge session.
- **Account-level (user-managed):** the Cloudflare Workers Builds clone is set on the Cloudflare side; requesting shallow/blobless there is a per-unit account setting, not hub-settable. Local dev + hub build-worktrees adopt it today with zero coordination.
- **Relationship to the purge levers:** blobless is *not* a substitute for Lever 2 (the beat-`.webp`→R2 migration + history rewrite), which is the only thing that shrinks **origin** itself — but it is the correct, immediate, always-safe complement, and it is what makes a large `.git` tolerable in the window before (and between) purges.

### Cross-references
- `Docs/ADR-034_SITE_GIT_HISTORY_MEDIA_PURGE.md` § "Track A" — the decision this codifies
- `Docs/PLAN_SITE_REPO_FURTHER_REDUCTION_2026-07-11.md` § "Lever 3 — PREVENTION" — where blobless is listed as the zero-risk lever
- § R-SITE-HISTORY-PURGE (above) — the destructive lever blobless complements · § R-SITE-MEDIA-R2 (the prevention half)

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

> **FOUNDER DECISION (2026-07-13): layer-1 (hub-git) FULL closure is DECLINED — no git bloat. The removable-drive layer-2 mirror is the accepted off-R2 backup "for now."** Per founder-direct (*"i don't want git bloat. back up on the removable drive for now"*), the ~962-file / ~1.7 GB layer-1 gap is **NOT** to be closed by committing the `.m4a` into hub git. Instead, the **layer-2 byte-mirror on the removable external USB drive `/Volumes/Data` (`/Volumes/Data/Backups/r2/spark-anvil-books`, 1788 `.m4a` / 3.6 GB)** is the sanctioned off-R2 backup. It is a 2nd copy of R2's cloud master (protects against R2 bucket deletion/corruption); it is NOT drive-failure-independent from the project (both live on `/Volumes/Data`), which is the accepted "for now" posture. **Keep it current:** re-run `scripts/mirror_r2_audio_layer2.py` after every audio-bearing wave, and byte-verify with `scripts/verify_r2_backup_byte_integrity.py --backup-dir /Volumes/Data/Backups/r2/spark-anvil-books` (0 stale / 0 missing = good). The layer-1 `Resources/R2AudioBackup/` set (826 `.m4a`) STAYS as-is — do NOT bulk-commit the remainder. The truly-off-machine end-state (rclone → 2nd R2 / B2 / NAS + the `com.spark-anvil.r2-backup` launchd agent) remains the future upgrade when the founder provisions a destination remote; the removable-drive mirror is the interim.

### The discipline going forward

1. **Every audio-bearing wave that uploads new `.m4a` to R2 MUST also add the byte-copy to `Resources/R2AudioBackup/`** — in the same wave, exactly as R-R2-AUDIO-UPLOAD-COMPLETENESS requires the R2 upload itself. The two rules chain: distribute → upload-to-R2 (R-R2-AUDIO-UPLOAD-COMPLETENESS) → byte-backup-to-hub (this rule).
2. **`scripts/backup_r2_audio_to_hub.py`** pulls the current R2-only `.m4a` set (idempotent: skips size-matching files already present) and refreshes `Resources/R2AudioBackup/MANIFEST.json` (key + size + md5). Run it after any audio wave, and periodically as a portfolio backstop.
3. **`scripts/audit_asset_backup_coverage.py --ci-mode`** is the backstop detector — it now counts `Resources/R2AudioBackup/` as a committed binary source, so a newly-uploaded-but-not-yet-backed-up `.m4a` classifies 🟠 REGENERABLE-TTS (not ✅) and `--ci-mode` exits non-zero. Wire it into audio-wave round-close alongside `audit_r2_upload_coverage.py`.
4. **Off-site sync (running):** `scripts/sync_r2_to_backup.sh` (`--backup-dir` versioned mirror) runs daily via the `com.spark-anvil.r2-backup` launchd agent (`scripts/r2_backup_cron.sh`; log `~/Library/Logs/r2-backup.log`). The current destination is a **local** archive on the same machine — for off-machine durability, point `RCLONE_DST` at a second R2 bucket / B2 / NAS (user-provisioned). The in-R2 Event-Notifications→Queue→Worker pattern remains an optional alternative.

### Cross-references

- `Docs/AUDIT_ASSET_BACKUP_COVERAGE_2026-07-06.md` — the audit that surfaced the 744 + ranked the recs this rule codifies
- `scripts/backup_r2_audio_to_hub.py` — hub byte-backup (layer 1)
- `scripts/sync_r2_to_backup.sh` — whole-bucket off-site sync recipe (layer 2; user runs, rclone → off-machine destination)
- `scripts/mirror_r2_audio_layer2.py` — headless boto3 layer-2 byte-mirror (**no new creds**; idempotent skip-if-size-match; the local-mirror interim before the off-machine rclone destination is stood up — run after any audio wave)
- `scripts/verify_r2_backup_byte_integrity.py` — **byte-level** (ContentLength) R2-vs-backup verifier that catches the **STALE-TAKE** class the basename-level auditor misses (a same-key regenerated take: backup holds the old `.m4a`, R2 holds the new; proven in the 2026-07-13 W3 close-out — 40 stale + 17 missing that `audit_asset_backup_coverage.py` reported as 0). Runs against either layer (`--backup-dir`); `--ci-mode` exits non-zero on any stale/missing.
- `scripts/audit_asset_backup_coverage.py` — the `--ci-mode` backstop detector (basename/key-presence level; pair with `verify_r2_backup_byte_integrity.py` for byte-integrity)
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

### There is NO bare `/cast/<app>` route — only `/cast`, `/cast/<app>/<char>`, `/cast/<app>/<char>/advanced` (2026-07-11 SEL-pair P0)

**Never link to a bare `/cast/<app>` (app slug, no `/<char>`).** It resolves in NO deploy unit — the ONLY cast routes are the **aggregate `/cast`** (`src/pages/cast.astro`) and the per-character **`/cast/<app>/<char>`** (+ `/advanced`) generated by `cast/[app]/[char].astro`. There is no `cast/[app]/index.astro`. A "meet the cast / read the stories" link on a clone landing/about page MUST target **`/cast`** (the aggregate, what `PlayNarrative`'s footer uses) or a specific guarded `/cast/<app>/<char>` — never `/cast/<app>`.

**The incident (P0, site PR #410):** the mindforge + coregrealm clone `about.astro` pages hardcoded `<a href="/cast/mindforge">` / `/cast/coregrealm` → 2 broken links → red **core** Cloudflare build. It slipped every fleet agent's `build:play` because `--unit play` excused *all* non-`/play` paths as "cross-unit," so the bad link only failed the ~12–20 min core build.

**The gate was tightened (site PR #411):** `check-site-internal-links.py` `is_invalid_cast_shape()` now **never excuses** a bare `/cast/<app>` in ANY unit — so the fast `build:play` (which every clone agent runs) fails on it immediately, not just the slow core build. Do NOT re-broaden the play-unit cross-unit excuse to cover bare `/cast/<app>`.

**Deferred re-enablement (the "come back later" TODO):** because there is no app-index cast route today, the SEL clones' about pages fall back to the aggregate `/cast`. If an app-level `/cast/<app>` index route is ever built (or a chapterless clone's app gains authored chapters), the app-scoped links can be re-enabled. That revisit is tracked in **`Docs/TODO_WEB_CLONE_CAST_LINK_REENABLE.md`** (greppable: `grep -rn 'href="/cast"' src/pages/play/*/about.astro`). `PlayNarrative` already auto-enables per-char links when chapters land (it reads `apps.generated.ts` + `hasChapter`), so no per-clone edit is needed there when the DN assets arrive.

### Cross-references

- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § "V23 P0 — Cloudflare build FAIL: broken /cast/mathcircle/circle route" + § "V114 — SEL-pair bare /cast/<app> P0 + link-checker tightening"
- `Docs/TODO_WEB_CLONE_CAST_LINK_REENABLE.md` — the deferred app-scoped-cast-link re-enablement tracker
- `spark-anvil-site/src/lib/castSlug.ts` — `chapterSlugFor` / `hasChapter` / `slugChar`
- `spark-anvil-site/scripts/check-site-internal-links.py` — the postbuild enforcement gate (now with `is_invalid_cast_shape`)
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

## Long single-flight gen pipelines are DRIVEN with foreground sleep-waits — never background-and-stop (R-GEN-FOREGROUND-DRIVE; 2026-07-14)

**When the founder has said "do not stop until fully done" (or otherwise authorized an autonomous multi-app run), a long single-flight gen pipeline — the coverage program, a cast-expansion wave, any pipeline whose steps serialize on the shared Gemini key (R-GEMINI-KEY-SERIAL) — MUST be driven by the agent with FOREGROUND `sleep`-poll waits between the key-serialized steps, NOT by launching a background gen and ENDING the turn to await a task-notification.** Codified per founder-direct 2026-07-14 (*"resume and do not stop. use sleep if needed"* → *"again: resume and do not stop. use sleep instead"* → *"codify this rule in repo"*), after a session repeatedly backgrounded each ~15-min pilot / ~35-min T2 gen and ended its turn, forcing the founder to type "resume" once per step — which defeats the auto-cycle and stalls a weeks-long program on human keystrokes.

### Why background-and-stop is the wrong pattern here
Backgrounding a gen with `run_in_background: true` and then producing a final message ENDS the agent turn; the harness only re-invokes the agent when the `<task-notification>` fires. That is correct for a *single* long job the user is waiting on — but for a **pipeline of dozens of serialized gens** it means the agent halts after every step until the user manually resumes. The single-flight key already forbids running two gens at once, so there is no parallelism to gain from backgrounding; the only effect is inserting a human-in-the-loop stop between every step. The founder's "do not stop" directive is explicit that the agent should self-drive to completion.

### The pattern (drive, don't stop)
- **Launch the gen** (background is fine, OR foreground if it fits the tool timeout), then **BLOCK on it with bounded foreground `sleep` polls** — e.g. `sleep 110; <check proc + artifact>` repeated (keep each `sleep` under the ~120 s Bash auto-background threshold so the wait itself stays foreground), or a single `while pgrep -f <gen> …; do sleep 30; done` guarded by a max-iterations cap. When the gen finishes, **immediately proceed to the next step in the SAME turn** — distribute → T2 → portrait → PRs → next app — without yielding to the user.
- **Only end the turn** when: the whole authorized run is complete, a hard blocker needs a founder decision, a gate fails in a way that needs judgment, or the founder-set token/scope budget is exhausted. A step merely "taking ~35 min" is NOT a reason to stop.
- **Keep the single-flight discipline** (R-GEMINI-KEY-SERIAL): one gen at a time; overlap only NON-key work (in-session Opus prose pre-authoring, R2/boto3 uploads + layer-2 mirror, git/PR ops, worktree setup) with a running gen. The foreground sleep-wait is exactly where that non-key work goes.
- **Bounded, not infinite:** every wait loop has a max-iteration cap so a genuinely-stalled gen (the 503 class) surfaces instead of hanging the agent forever; on cap-hit, inspect + retry (audio-only `--no-illustrations` regen for a mid-audio stall; re-run the one failed T2 slug) rather than stopping.

### When this rule applies
- Any autonomous multi-app coverage / cast-expansion / regen run the founder has said to drive to completion.
- Reviewing an agent session that backgrounded a gen and stopped mid-run without a blocker → that's a violation of this rule (it should have sleep-driven the next step).

### Cross-references
- § R-GEMINI-KEY-SERIAL (above) — the single-flight constraint that makes backgrounding pointless here (no parallelism to gain) · § R-GEMINI-MODEL-ALIAS
- `.claude/rules/workflow.md` § "Auto-Cycle Default" — the branch→commit→PR→merge→verify auto-cycle this keeps moving without per-step confirmation · § "Stagger Background Agents" (bg-agent staggering — orthogonal: that's about multiple SUBAGENTS, this is about not halting a single-flight pipeline)
- `.claude/rules/distributed-narrative.md` § R-COVERAGE-OPUS-AUTHORING — the coverage program that is this rule's canonical consumer · memory [[chapter-coverage-program]]

## Prefer `-latest` model aliases in pipeline scripts (R-GEMINI-MODEL-ALIAS; 2026-07-09)

**Every Gemini-backed pipeline script MUST reference a rotation-proof `-latest` model alias (or the current preview family) — NEVER a pinned mid-generation version ID like `gemini-2.5-flash` that a family rotation can silently 404 out from under a running batch.** Codified after the V60 incident (2026-07-09): mid-V45 the **entire `gemini-2.5` `generateContent` family was retired** — `gemini-2.5-flash`, `gemini-2.5-pro`, `gemini-2.0-flash`, `gemini-2.5-flash-image-preview` all began returning **`404 NOT_FOUND`** — while ~1300 in-flight text-leak audit images errored and every pipeline script hardcoding a 2.5 ID broke at once. (Wrinkle: the retired IDs still appear in `models.list()` with lagging metadata, so a list check is NOT sufficient to confirm a model is live — you must probe `generateContent`.)

### The alias map (image row re-verified live 2026-07-13; text/TTS rows 2026-07-09)

| Use | Prefer | NOT (retired/404) |
|---|---|---|
| Flash text / judge / classifier | `gemini-flash-latest` | `gemini-2.5-flash`, `gemini-2.0-flash` |
| Pro text / authoring / rephrase | `gemini-pro-latest` | `gemini-2.5-pro` |
| Flash image gen (Nano Banana 2) | `gemini-3.1-flash-image` | `gemini-3.1-flash-image-preview` (**shut down 2026-06-25**), `gemini-2.5-flash-image(-preview)` |
| Pro image gen (Nano Banana Pro) | `gemini-3-pro-image` | `gemini-3-pro-image-preview` (**shut down 2026-06-25**) |
| Lite image gen (bulk / low-latency) | `gemini-3.1-flash-lite-image` | — (not for multi-reference / sequential edits) |
| **TTS** (separate lifecycle — see below) | keep `gemini-2.5-flash-preview-tts` **for now** | — |

> **⚠ Image models have NO `-latest` alias — they pin to a versioned GA ID, so they DO rotate out.** On 2026-05-28 Google promoted the Nano Banana image models to GA under **un-suffixed** IDs (`gemini-3-pro-image`, `gemini-3.1-flash-image`, `gemini-3.1-flash-lite-image`) and **shut the `-preview` variants down on 2026-06-25** (Vertex/Enterprise gave a 2026-07-17 grace). The 2026-07-09 alias-map row pinned the now-dead `-preview` IDs, so every hub image-gen script (`gen_cast_portraits` / `gen_book_covers` / `gen_app_badges` / `gen_app_icons` / `gen_app_illustrations` / `gen_app_texture_atlases` / `pilot_interleaved_ensemble_chapter` / the pilots) was re-pinned to the GA IDs on 2026-07-13 (this row). The separate **Imagen 4** family (`imagen-4.0-*`) shuts down 2026-08-17 — unrelated to Nano Banana; the hub does not use Imagen. Because image IDs carry no `-latest`, re-check this row every horizon refresh + probe `generateContent` before any large gen wave.

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
