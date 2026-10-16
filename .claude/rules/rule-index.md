# Rule Index — always-on invariants for the path-gated rule files

`spark-anvil-website.md` (~234k tokens) and `portfolio.md` (~170k tokens) are **path-gated** (`paths:` frontmatter, ADR-111 follow-on): they load only when a matching file is in context, NOT every session. Together they once pushed a hub session's memory files past the 1M window. This card is their always-on surface. Keep it SHORT: an invariant + a pointer, never detail (R-RULE-CONTEXT-BUDGET).

## When to Read the full file (do this BEFORE acting, not after)

- **Any website / `spark-anvil-site` / `/play` web-clone / Astro / Cloudflare / R2-media / site-build work** → `Read .claude/rules/spark-anvil-website.md` (full detail: `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md`).
- **Any cross-repo write, app-repo handoff, distribution script, asset rollout, concept-brief / program mining, spawn, or "is app X ready?" check** → `Read .claude/rules/portfolio.md` (detail: `Docs/REFERENCE_PORTFOLIO_CROSSREPO.md`, `Docs/REFERENCE_PORTFOLIO_CONCEPT_PROGRAMS.md`).
- **Any `spark-anvil-site` deploy, release-train promote, Cloudflare build/alias check, GitHub Actions/CI workflow or cost change, prod-monitoring change, or new npm dependency** → `Read .claude/rules/site-deploy-ops.md`.
- **Any PDF chapter-book or companion-book build, render, layout, QR or KDP work** → `Read .claude/rules/pdf-books.md`.
- **A `§ R-…` reference you can't resolve** in the always-on rules: `R-SITE-FORCE-PROMOTE-*` / `R-PROD-*` / `R-DEPLOY-*` / `R-CI-*` / `R-CLOUDFLARE-*` / `R-RELEASE-TRAIN-*` / `R-DEPENDENCY-SUPPLY-CHAIN` → site-deploy-ops file; `R-PDF-BOOK-*` → pdf-books file; other `R-WEB-*` / `R-SITE-*` → website file; `R-FABLE-*` / `R-HUB-*` / `R-APP-*` / `R-KIT-*` / `R-PORTFOLIO-*` / concept-program IDs → portfolio file. Otherwise grep `.claude/rules/` for the ID.

## Portfolio — always-on invariants (full text: `portfolio.md`)

- **Hub NEVER writes implementation code** (Swift, tests, views, services, Xcode project files) to app repos. That belongs to each app's own session. Hub MAY update app `CLAUDE.md` + `Docs/*.md` for cross-repo consistency, and owns app `Resources/` assets (see `CLAUDE.md`).
- **Pull before ANY cross-repo read**: `git pull --ff-only` each repo BEFORE the first read/grep, sequentially, one repo at a time, then audit, then work.
- **Cross-repo WRITES go through a FRESH throwaway clone** off origin (`/tmp/wt-<slug>`), never the shared `../<app>-app/` sibling clone (that is the READ path).
- **Distribution scripts source targets from `Docs/REGISTRY_ACTIVE_PORTFOLIO_APPS.txt`**, never a `ls *-app/` glob (R-PORTFOLIO-INVENTORY).
- **Verify cross-repo PRs MERGED before claiming SHIPPED.**

## Website — always-on CRITICAL invariants (full text: `spark-anvil-website.md`)

- **R-WEB-CLONE-IMMERSION-ALL-PAGES**: EVERY `/play` page of an immersed clone carries the ChessKid immersion treatment. Solve surfaces stay quiet; boundary/reward surfaces keep the env.
- **R-WEB-CLONE-NAV-DIRECTIVE-WEB-ONLY**: the bottom-nav → left-drawer directive (and every `/play` nav/layout/immersion directive) is WEB-ONLY. NEVER propagate it to iOS via handoff.
- **R-APP-ICON-SURFACE**: app icons are the ADULT app-evaluation identity, not the `/play` kid-browse card. A NON-NULL asset path to a MISSING file breaks the prod build.
- **R-SITE-LOCAL-BUILD-R2-ENV**: a local `spark-anvil-site` build MUST `source ~/.r2-env.sh` AND export all three `PUBLIC_{AUDIO,IMAGE,PDF}_CDN_URL`. Otherwise media manifests are empty and link-check/render-parity gates false-fail or vacuously false-pass.

## Site deploy & CI — always-on CRITICAL invariants (full text: `site-deploy-ops.md`)

- **Merged or green is NOT live** (R-SITE-FORCE-PROMOTE-AND-VERIFY · R-DEPLOY-STATUS-FROM-CF-BUILD-LOGS): never record a site change SHIPPED from a merged PR, a green Actions run or a green CF build alone. Read the CF build log of every affected unit and grep the SERVED prod content for the change.
- **R-PROD-POST-DEPLOY-UIUX-SWEEP**: a prod deploy is not verified until the surfaces its commits touched are captured light+dark × desktop+mobile on LIVE prod and the screenshots are actually looked at. Functional gates alone never count.

## Keeping this bounded

A new CRITICAL rule in any gated file gets ONE line here (invariant + rule ID), nothing more. Never remove the `paths:` frontmatter from the gated files to "make sure it's seen": put the trigger here instead. `scripts/check_rule_context_budget.py` counts this card as always-on.
<!-- END LABSMITH-SYNCED CONTENT -->
