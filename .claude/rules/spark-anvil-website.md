# Spark & Anvil Company Website

The studio brand (Spark & Anvil) ships a company website at `spark-and-anvil.com` (planned domain) that introduces parents/educators/press/kids to the 131-app portfolio.


> **⚡ THIS IS A CARD (V447-P4b progressive disclosure).** Each rule below keeps its heading (so `§ R-…` cross-references still resolve) + its load-bearing INVARIANT. The FULL detail — rationale, when-it-applies, cross-references, incident histories, reference-impls, examples — lives in **`Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md`** (fetch on demand; same `## ` headings). Regenerate this card: `scripts/split_rule_to_reference.py spark-anvil-website REFERENCE_SPARK_ANVIL_WEBSITE --apply`.

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

→ **Sub-rules** defined here (full detail in reference): (R-CLOUDFLARE-SCOPED-DEPLOY) · (R-SITE-DOMAINS).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## The site is organized into 3 audience/purpose hubs — Play · Story · For Parents & Educators (R-SITE-3HUB-IA; 2026-07-15)

> **⚠ AMENDED 2026-07-16 (founder-direct, V275+V276 · ADR-039 update · site PR #735):** the 3 hubs stand, but two sub-decisions below are SUPERSEDED to consolidate + simplify:
> - **Homepage is a LEAN FEATURED-TEASER SPLASH, not the full catalog** (supersedes principle 2 "`/play` catalog IS the homepage"). `/` now carries exactly three teaser sections — **featured web clones → `/play`**, **featured stories → `/story`**, **key parents/educators info → `/for-parents-educators`** — *and nothing else*. The full catalogs live on their hubs (every playable clone at the primary `/play` hub; the full library at the primary `/story` hub; the flat all-143-apps list at the **deprioritized/secondary** `/apps`, see the reaffirmation bullet below). Featured lists are **hand-curated for v1** (filtered to shipping slugs/chapters so no card breaks); a future "most-loved" aggregate (R-SITE-FEEDBACK) can drive them. The compact **orientation/trust band still gates the homepage** (Decision 2's surviving half — never a bare grid).
> - **Nav = exactly THREE plain top-level links, NO dropdowns** (Play · Story · For Parents & Educators). Supersedes the "each hub parent is a link + hover/focus dropdown of top spokes" model — spokes now live on each hub LANDING page, not the header. Donate is not a nav CTA (footer + grownup hub).
> - **Prioritize** web clones + stories + key grownup pages; **deprioritize (NOT delete)** everything else — **cast · books · the flat `/apps` + `/subjects` + `/cluster` catalog** drop off the nav + homepage but stay reachable via the hub landings + footer (deprioritize ≠ delete; the link-checker + surface-wiring gates stay green).
> - **🔎 REAFFIRMED + SHARPENED 2026-07-16 (founder-direct): `/play` and `/story` are the ONLY two MAIN (primary browse) hubs; the flat `/apps` catalog is DEPRIORITIZED — a secondary surface, not a co-equal "full catalog."** The two kid content hubs are **`/play`** (the playable web-clone catalog — "what you can do right now") and **`/story`** (the illustrated-story + audio-drama library). `/apps` (the full 143-app flat list, most not yet playable) is deprioritized to a secondary/reference surface reachable from the hub landings + footer — it must NOT be presented as a primary/co-equal browse path, and its wording in this rule ("all 143 apps at `/apps`" as a "full catalog") is downgraded accordingly. (`/for-parents-educators` remains the adult side-door — a "for X" audience hub, not a kid browse hub.) Consequence for feature-wiring: a kid-facing browse feature (e.g. the Like/favorites affordance, R-SITE-FEEDBACK) MUST be present on **`/play`** (+ `/story`) — being wired only on `/apps`/`AppCard` leaves it invisible on the main hubs (the 2026-07-16 "I don't see the Save button" gap). **Deprioritize ≠ delete still holds** (orphan-check per § R-SITE-DEPRIORITIZE-REACHABILITY; `/apps` keeps ≥1 inbound link).
> - **UNCHANGED + still load-bearing:** Decision 4 — the **prominent, independent Privacy link on every page** (global footer; also surfaced in the homepage grownup card). The hybrid-hub principle, `/story` faceting, `/play`↔`/story` integration, and SEO-N/A all stand.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Deprioritizing a page off nav/homepage OBLIGATES an orphan check — and the scan MUST match data-array `href:` links, not just HTML-attribute `href="…"` (R-SITE-DEPRIORITIZE-REACHABILITY; 2026-07-16)

**Whenever you deprioritize a page off the nav/homepage (the R-SITE-3HUB-IA "deprioritize ≠ delete" move) OR simplify the nav, you MUST run an orphan check confirming every deprioritized page STILL has ≥1 inbound link from a hub landing (`/play`, `/story`, `/for-parents-educators`) or the global footer — because "deprioritize" silently becomes "delete-from-discovery" the moment a page's last inbound link is the thing you removed. `check-site-internal-links.py` will NOT catch this — it flags BROKEN links (href → missing route), never an ORPHAN (a real page nothing links to).** Codified per the V279 session (`Docs/AUDIT_SITE_HUB_LANDING_COMPLETENESS_2026-07-16.md`): the featured-teaser/3-link-nav consolidation (V275/V276) deprioritized pages off the nav+homepage, and a follow-up sweep found `/educators` (the working educator portal) had gone to **zero inbound links** — a real orphan fixed by adding it as a spoke on the grown-up hub landing (site PR #737), exactly per deprioritize≠delete.

**The load-bearing scan gotcha (both false-orphan AND false-reachable):** an inbound-link/orphan scan MUST match BOTH link forms the site uses, or it lies in either direction:
- `href="/route"` — a literal HTML attribute (most links).
- `href: '/route'` / `href: "/route"` — a **data-array entry** rendered via a `.map()` (the hub landings' `spokes[]`/`groups[]`, the nav `items[]`, footer columns — a large share of IA links).

A grep for only `href="…"` mis-reported `/welcome` as orphaned in the V279 handoff when it was actually reachable from the `/for-parents-educators` landing as a single-quote `href: '/welcome'` spoke — nearly triggering the deletion of a functional, linked page (a verify-before-action near-miss). Use a scan that matches both forms (the audit's Python scanner is the reference: `href="/%s(["/#?])` OR `href:\s*['\"]/%s(['\"/#?])`), enumerate every top-level `src/pages/*.astro` route, and treat any 0-inbound route as an orphan to fix (add a hub-landing/footer link) or a founder-confirmed retire.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Every per-clone `NEXT_WEB_CLONE` pickup doc ANCHORS to the current site IA (never hardcodes a stale route) (R-WEB-CLONE-PICKUP-DOC-IA; 2026-07-15)

**Every `CONTEXT_HANDOFF_*_NEXT_WEB_CLONE_<app>.md` pickup handoff MUST carry a "Site IA anchor" that states the CURRENT site IA + defers to `WEB_CLONE_PICKUP_RUNBOOK.md` § "Site-IA context" — and MUST NOT hardcode a stale route (`/stories`, the old marketing homepage, the old flat nav). A pickup doc that references the old IA, or that omits the anchor and silently assumes pre-V257 structure, is a defect.** Codified per founder-direct 2026-07-15 (*"the existing web-clone pickup docs are now incorrect because of website reorganization … fix and codify"*), after a two-pass V265 audit: the founder's concern was the **per-clone** pickup docs (not the generic runbook, which V265 already reconciled). An exhaustive (zsh-safe) re-verify found the 18 flagged docs carry **no hardcoded stale-IA route** — they *defer* IA to the runbook (V265-corrected) + `<PlayNarrative>` (which auto-links to `/story`) — so nothing was silently stale; BUT there was **no guard** keeping the class IA-correct and **nothing made the IA-correctness explicit** to a builder picking one up. This rule closes both gaps.

**The anchor (what every pickup doc carries):** the clone lives under `/play/<app>/*` (unmoved by the reorg); **homepage `/` = the 143-app catalog** (old marketing home at `/welcome`); **stories at `/story`** (`/stories` redirects); **3-hub nav** (Play · Story · For Parents & Educators + Donate); **`/play`↔`/story` auto-wired** by `<PlayNarrative>` (landing→`/story` cast pages) + `clone-lookup.ts` (cast page→"Play <app> →") — **no per-clone IA wiring needed**; full detail in the runbook's Site-IA-context section. Reference impls: the 18 apps flagged 2026-07-15 (creaturecare · dancequest · ensemblequest · fitquest · harvestforge · huggyhabits · labsmith · melodymice · rupturerepair · saffronlab · taleforge · taletrail · tempcheck · terrawatch · tinyletters · trailforge · voicetale · wellnessforge) each got the anchor inserted before their `## Why` section.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Every per-clone `NEXT_WEB_CLONE` pickup doc carries an explicit CLONE-ELIGIBILITY verdict — never auto-queue a questionable candidate as a standard clone (R-WEB-CLONE-PICKUP-DOC-ELIGIBILITY; 2026-07-15)

**Every `CONTEXT_HANDOFF_*_NEXT_WEB_CLONE_<app>.md` pickup doc MUST carry an explicit "Clone eligibility (verdict)" section that classifies the app BEFORE proposing surfaces — because "next web clone" pickup docs are auto/hand-generated from a standard tween-16×25-MC template, and that template is WRONG for younger-cluster, device-first, SEL/reflection, out-of-band-age, and no-portable-core apps. A pickup doc that assumes the standard MC-clone shape for a non-standard app, or that queues a questionable candidate for build without a verdict, is a defect.** Codified per founder-direct 2026-07-15 (*"per-doc eligibility"*), the companion to R-WEB-CLONE-PICKUP-DOC-IA (same V265 lane): the IA rule keeps the docs route-correct; THIS rule keeps them from mis-scoping the app itself.

**The verdict taxonomy (pick exactly one per doc; confirm in the Phase-2 deep-read):**
- **✅ ELIGIBLE** — standard tween (9–14) 16×25-MC clone.
- **🧒 ELIGIBLE (younger-track, ages 5–8)** — **NO MC kits** (R-YOUNGER-CLUSTER-NO-MC-KITS); port **activity formats** (tap/drag/trace/audio-first), not a Concepts-MC surface.
- **🔄 ELIGIBLE (adapted)** — a device-first / composition / collaborative app: **port the learning core**, waive the device feature (R-WEB-CLONE-DEVICE-FEATURE-SKIP) or the networked/social mode (R-WEB-CLONE-SOCIAL-MODES), and **author kits with in-session Opus if the app has none** (R-WEB-CLONE-KITS-OPUS-AUTHOR). Device-centric apps still have a high knowledge-layer yield — don't dismiss as a thin port.
- **🛑 ELIGIBLE (gated)** — port with a **trauma / SEL / cultural (Indigenous-TEK / food-justice / body-image)** gate active; SEL/reflection surfaces waive competitive/social modes; crisis resources where relevant.
- **⚠ RE-ASSESS** — candidacy is genuinely questionable: **out-of-band age** (outside 9–14, e.g. an ages-16–40 app), documented **"weak web fit"**, a **portable-core-unconfirmed** sandbox, or **no solo learner-facing learning surface** (a purely dyadic/real-time instrument). **Do NOT auto-queue for build** — needs a Phase-2 deep-read or a founder candidacy call first.
- **⛔ NOT A CLONE** — no portable learning core at all.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Provisioning an account-managed Cloudflare backend follows ONE reusable pattern (R-CLOUDFLARE-BACKEND-PROVISIONING; 2026-07-16)

**Every new account-managed Cloudflare backend behind `spark-and-anvil.com` (a Worker + its storage + its route) follows the single reusable playbook in `Docs/GUIDE_CLOUDFLARE_BACKEND_PROVISIONING.md`, and each instance ships a deep-web-researched, cited per-instance RUNBOOK.** Codified per founder-direct 2026-07-16 ("codify the previous cloudflare provision work too"), generalizing the two shipped instances into one discipline. This is the *how-to-stand-up-a-backend* umbrella; `R-CLOUDFLARE-SCOPED-DEPLOY` is the *who-may-run-the-deploy* authorization rule they both obey.

**The load-bearing invariants (author + review any Cloudflare-backend work against these):**
1. **Ownership split** — hub owns the Worker/storage/client CODE (ships via a worktree branch + PR, R-SITE-BUILD-SPLIT); the founder owns the ACCOUNT (token, storage-resource creation, route/domain, build-watch, go/no-go, counsel).
2. **Pick the store by WORKLOAD** — **coordination/realtime/atomic-per-session → Durable Objects** (one object per entity; ~500–1k req/s/object ceiling → shard); **aggregation/counts/relational → D1** (atomic single-statement UPSERT `… ON CONFLICT DO UPDATE SET count=count+1`, no read-modify-write race; native aggregate SQL + `WHERE count>=k`); **read-heavy static config → KV** (NEVER counters — eventual + 1 write/s/key → lost increments).
3. **`wrangler whoami` confirms the CORRECT account BEFORE any account-mutating op** (R-CLOUDFLARE-SCOPED-DEPLOY) — the most load-bearing step; a wrong-account create/deploy makes un-undoable resources.
4. **Route via a direct Worker Route** (`/api/<x>/*`, precedence over the dispatcher Custom Domain; WS rides it) — pick ONE model per path; deploy the target Worker before any service-binding caller.
5. **Build-watch is per-unit + account-managed** — a backend Worker is a SEPARATE deploy surface (no core/play rebuild); flag any watch-path change in the PR.
6. **Rollback = remove the route** → the site reverts with no data loss; never make a route the only path to a learning-critical feature.
7. **Origin-locked + rate-limited (coarse key, never per-child) + no PII/accounts/identifier; counsel-gate any kid-facing backend before launch; deep-web-research foreground-sequential** (the parallel `deep-research` fan-out rate-limits — `workflow.md` § R-WEBSEARCH-FANOUT-RATELIMIT).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## User feedback (likes) → CROSS-USER recommendations via ANONYMOUS AGGREGATES — never per-child profiles, never a dark-pattern (R-SITE-FEEDBACK; 2026-07-15)

**Any user-feedback / like / favorite / recommendation / "kids also liked" / "most-loved" feature on the site MUST deliver its CROSS-USER signal (other users' feedback → other users' recs, per founder-direct) from ANONYMOUS AGGREGATE item statistics that are never tied to any individual child — NEVER from accounts, PII, a persistent per-child identifier, a raw per-user event log, or account-based collaborative filtering; and it MUST be GENTLE + non-manipulative (no engagement dark-patterns; likes never gate content).** Codified per founder-direct 2026-07-15 (*"let users provide feedback … such as liking an app/web clone/story … use those signals for recommendations and feature for new users"* + clarification *"i actually meant using users' feedback for recommendations for other users not on the same device"*). Decision: `ADR-040`; research: `RESEARCH_SITE_FEEDBACK_RECOMMENDATIONS_2026-07-15.md`; plan: `PLAN_SITE_FEEDBACK_RECOMMENDATIONS_2026-07-15.md`. **✅ COUNSEL APPROVED 2026-07-16** (the ADR-040 launch gate is CLEARED, on the strict-anonymity basis below); **the store choice is settled = D1 (atomic-UPSERT counters + k-anonymity `WHERE count>=k`), see `Docs/RUNBOOK_CLOUDFLARE_FEEDBACK_AGGREGATE_PROVISIONING_2026-07-16.md`.**

**The load-bearing principles (author + review any feedback/recs surface against these):**
1. **Cross-user signal = anonymous AGGREGATE counters only.** The collaborative benefit ("kids who liked X also liked Y", "most-loved") comes from (a) per-item **like counts** (popularity) + (b) item-item **co-occurrence counts** — the recognized privacy-friendly collaborative method (aggregate *item relationships*, never per-user profiles). Stored in an aggregate backend (a Cloudflare Worker + KV/D1/Durable-Object; account-provisioned by the founder, **hub owns the code**) as **counters only — increment-and-discard, no raw per-device/per-session event log, no identifier**.
2. **The COPPA line (stricter than on-device — this transmits a like off-device).** An anonymous aggregate counter with no identifier tied to a user is not "personal information." Compliance requires ALL of: **no accounts · no PII · no persistent per-child identifier · no cross-site tracking · aggregate counts only (no re-identifiable event log) · a mandatory k-anonymity minimum-support threshold** (expose a co-occurrence pair / "loved" item ONLY once ≥k anonymous contributions back it, default k ≥ 20 — mitigates the documented "You might also like" aggregate-leakage attack) · **retention-minimized** (2025 COPPA amendments: counts only, no indefinite raw history) · **rate-limited + origin-locked** write endpoint · **disclosed in the privacy policy** ("we count likes anonymously to recommend popular items — we never store who liked what") · **counsel-reviewed before launch**. NO third-party like/share widgets or hosted recsys SaaS. NO account-based collaborative filtering / per-child behavioral profile (that IS COPPA collection). Optional differential-privacy noise is a stronger guarantee (defer unless cheap).
3. **HYBRID with content-based for cold-start + diversity.** Co-occurrence is empty for a new item + below the k-threshold → fall back to a **build-time content-based similarity map** (TF-IDF + cosine over existing metadata: cluster · subject · gradeBand · primitive · modes · type → static JSON; we already ship all this → zero new data) for "More like this", and diversify (cap same-cluster repeats). New-user featuring = measured "Most-loved" once warm, with a hub-**curated "Loved by learners"** bootstrap (honest "hand-picked" label) before the aggregate clears the threshold. Cross-type recs (app↔clone↔stories) ride the existing `/play`↔`/story` mapping (V257 Phase 2).
4. **On-device like store still exists** (localStorage, no identifier) as the device's own "Your favorites" + the source of the anonymous like *event* that fires the aggregate increment (fire-and-forget; the like still saves locally if the endpoint is unreachable). It is not the cross-user engine — the aggregate backend is.
5. **No engagement dark-patterns (FTC §5).** The 2025 COPPA amendments dropped the explicit engagement-technique ban BUT the FTC reserved §5 authority over "practices that unfairly manipulate children's engagement" (+ state dark-pattern laws). Calm rails ("Kids also liked", "Most-loved") as gentle discovery; NO scarcity/urgency/streak/guilt copy, NO push re-engagement, NO like-driven autoplay, NO leaderboard-to-chase. Likes never gate content (everything free + open).
6. **Accessible + dark-safe + reversible.** First-party like control: ≥44px, `aria-pressed`, keyboard + visible focus, verdict-not-by-colour-alone (icon fill + label), reduced-motion-safe, themed via `--sa-*` (R-WEB-CLONE-DARK-MODE-SUPPORT). A "Your favorites" surface (local) with a "saved only on this device" note + clear control. Placement at browse/discovery + session boundaries, never mid-practice (R-NARRATIVE-BETWEEN-NOT-DURING). Rails link only to real routes (R-WEB-CLONE-NO-DARK-SURFACE). Screenshot-DoD (dark+light, desktop+mobile) + Vitest (content rec-map invariant + aggregate-schema/k-threshold) + a11y + zero-broken-links gate on every phase. The aggregate Worker + its dispatcher route + build-watch are **account-managed** (flag in the PR).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Room-code networked multiplayer for web clones — Durable Objects + WebSocket, NO chat, NO accounts (R-WEB-CLONE-MULTIPLAYER; 2026-07-15)

> **🔴 CRITICAL — the counsel-review launch gate is CLEARED (COUNSEL APPROVED 2026-07-16, founder-direct; ADR-041). Networked room-code multiplayer is UNBLOCKED for shipping to kids.** The V261 transport (`spark-anvil-room` Worker + `Room` Durable Object) is DEPLOYED LIVE on `spark-and-anvil.{com,org}/api/room/*`, AND the "counsel-reviewed before launch" condition that every principle below refers to has been **satisfied once, portfolio-wide** — a clone surfacing the room mode does NOT need a fresh counsel review; it inherits the cleared ADR-041 gate. So Shell B (networked room mode, `_shared/roomMode.ts`) is now a **first-class, shippable** engagement mode alongside pass-and-play + adventure (R-WEB-CLONE-SOCIAL-MODES): wire it onto the ✅-MP archetypes (turn-based/board/deduction/MC-quiz-duel), each with the two-client Playwright smoke below. The safety-BY-DESIGN invariants (NO free-text chat / NO voice / pre-set emotes only / ephemeral generated names / code-gated ephemeral rooms / no accounts / no PII / origin-locked + rate-limited) remain **hard, non-waivable gates** — counsel approval was granted ON THE BASIS of those invariants, so shipping a room mode that violates any of them (e.g. adds free-text chat) FORFEITS the cleared gate and is a critical defect. What is cleared is the *launch gate*; the *design invariants* are permanent. Codified per founder-direct 2026-07-17 ("counsel has approved and it has been codified in the repo. make this critical").

**A `/play/<app>` web clone's room-code networked multiplayer (iOS parity: host mints a short code → peers join by code → networked co-op/competitive play) MUST be built on Cloudflare Durable Objects + WebSocket (a DO named by the room code = the room's single authority + message fan-out + server-authoritative), with safety guaranteed BY DESIGN — NO free-text chat / NO voice (pre-set emotes only), ephemeral generated display names (no PII), code-gated ephemeral rooms (no accounts, no persistence, no retention, no discovery). NOT WebRTC, NOT a third-party realtime SaaS, NOT accounts/persistent identifiers.** Codified per founder-direct 2026-07-15 (*"our ios apps already has the room code feature to enable networked multiplayer play. i want to build that for the web clones too."*). Decision: `ADR-041`; research: `RESEARCH_WEB_CLONE_ROOM_CODE_MULTIPLAYER_2026-07-15.md`; plan: `PLAN_WEB_CLONE_ROOM_CODE_MULTIPLAYER_2026-07-15.md`. This is the web parity for the iOS ForgeKit server-room model (R-WEB-CLONE-PARITY: multiplayer is an iOS learning feature → web parity).

→ **Sub-rules** defined here (full detail in reference): (R-CLONE-BIDIRECTIONAL-BACKPORT).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Pass-and-play + multiplayer + adventure engagement modes for appropriate `/play` clones — shared shells, eligibility-by-archetype, adventure BOUNDARY-ONLY (R-WEB-CLONE-SOCIAL-MODES; 2026-07-15)

**Appropriate `/play/<app>` clones carry three iOS-parity engagement modes — (1) pass-and-play same-device hotseat, (2) networked room-code multiplayer, (3) adventure/progression framing — built as SHARED `_shared/` shells and scoped by a per-clone ELIGIBILITY-BY-ARCHETYPE matrix (NOT all clones); pass-and-play is serverless + trivially COPPA-compliant, multiplayer RIDES the V261 transport (never a new one), and adventure mode is BOUNDARY-ONLY + guard-the-ratio (never a decorated critical-path mini-game). A clone that forces multiplayer onto a solo-reflection/solo-tool surface, invents a second multiplayer transport instead of riding V261, or puts adventure narrative/decoration on the active problem-solving loop is a defect — as is an eligible clone that omits a mode without a documented waiver.** Codified per founder-direct 2026-07-15 (*"i want to add pass-and-play, multi-player play and adventure modes to all web clones that are appropriate for them. do deep web research, plan, create adr and codify."*). Decision: `ADR-042`; research: `RESEARCH_WEB_CLONE_SOCIAL_ADVENTURE_MODES_2026-07-15.md`; plan: `PLAN_WEB_CLONE_SOCIAL_ADVENTURE_MODES_2026-07-15.md`. This is the **umbrella** over the three modes; the networked-multiplayer transport lives in § R-WEB-CLONE-MULTIPLAYER (ADR-041), which this consumes.

**The load-bearing principles (author + review any clone engagement-mode surface against these):**
1. **Shared shells, opt clones in.** Pass-and-play = a serverless `_shared/passAndPlay.ts` wrapping `_shared/mcRound` (quiz-duel) + native for turn-based board clones; adventure = a `_shared/adventureMap.ts` re-skin of the existing kit-index; networked MP = wrap the pass-and-play game-state logic in the V261 room. Build the shell ONCE; a clone opts in with a per-app registry flag (R-WEB-CLONE-MERGE-HYGIENE per-app-file model) — never hand-roll a bespoke per-clone version of a shared mode.
2. **Pass-and-play = iOS `ForgePassAndPlay` parity, serverless.** Explicit **End-Turn** → auto-save state → **privacy curtain** (hide the board + "Pass to Player N → tap when ready" reveal — the direct web analog of the iOS 4-stage privacy curtain) → **seat labels are generated** (adjective+animal / "Player N", NEVER a typed real name) → per-seat first-try score race, anti-shame (private-per-turn, round always advances). No network, no accounts, no PII → ships without an account/counsel gate. **Build this FIRST.**
3. **Networked multiplayer RIDES V261, never a new transport.** The room = the V261 Cloudflare Durable-Objects + WebSocket transport (§ R-WEB-CLONE-MULTIPLAYER / ADR-041) wrapping the pass-and-play game-state logic; safety-by-design (NO free-text chat / NO voice; pre-set emotes; ephemeral generated names; code-gated ephemeral rooms) + account-provisioning are INHERITED from V261. Do NOT design/duplicate a transport. **🔴 V261 is now LIVE + the counsel-review launch gate is CLEARED (2026-07-16, ADR-041) — so the networked mode is UNBLOCKED and shippable to kids** (see § R-WEB-CLONE-MULTIPLAYER 🔴 CRITICAL banner); wire `_shared/roomMode.ts` onto the ✅-MP archetypes with the two-client Playwright smoke, inheriting the cleared gate (no fresh review) as long as the safety-by-design invariants hold.
4. **Adventure mode is BOUNDARY-ONLY + GUARDED (the evidence-hardest rule).** The 2024–2025 evidence is decisive: **behavioral engagement (clicking through a map) does NOT predict learning gains — only COGNITIVE engagement does**; narrative aids *behavioral* not *cognitive* outcomes; decoration on the critical path is a seductive detail (g ≈ −0.16, worst when the task is hard). So the adventure map is a **progression organizer over the clone's EXISTING kits** at session boundaries (map → pick a stop → the UNCHANGED, schematic practice loop → return), NEVER a decorated mini-game, NEVER narrative/animation on the active loop (`R-NARRATIVE-BETWEEN-NOT-DURING`), and the game-to-learning ratio is guarded (`R-GUARD-THE-RATIO`). An adventure surface that decorates the critical path or that a review can't trace to real practice is a defect.
5. **Eligibility by mechanic ARCHETYPE, documented waivers.** MC-kit clones → all three; turn-based board/deduction → pass-and-play + MP (strongest) + optional campaign; deterministic sim/POE → adventure + optional co-op predict; solo creative tools → adventure-optional, pass-and-play/MP ⛔; solo reflection/SEL/focus → ⛔ (reflection is private+solo by pillar design — forcing multiplayer violates the pillar) or a gentle non-competitive path only. Every mode a clone omits carries a one-line ⛔ rationale (R-WEB-CLONE-DEVICE-FEATURE-SKIP style); "it was more work" is never a waiver (that's a tracked 🟡). New clones inherit their archetype's row (see the `PLAN` matrix).
6. **Parity + symmetric backport + full DoD.** These are learning/engagement-relevant parity features (R-WEB-CLONE-PARITY): a web-pioneered mode iOS lacks → an iOS handoff; an iOS mode the web lacks → a 🟡 ledger gap (R-CLONE-BIDIRECTIONAL-BACKPORT). Each mode updates the clone's `PARITY_WEB_VS_IOS.md` ledger + passes the two-axis DoD + no-dark-surface + screenshot-DoD (dark+light, desktop+mobile) + Vitest/Playwright — plus a **two-client Playwright smoke** for networked MP and a **two-seat hotseat walk** for pass-and-play. On-device / COPPA / no third-party trackers throughout.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Web-clone parity is a two-axis Definition-of-Done gate (R-WEB-CLONE-PARITY-DOD; 2026-07-10)

**A `/play/<app>` web clone is NOT "done" — and must NOT be marked shipped — until it satisfies BOTH parity axes against its iOS app, each recorded in the clone's `Docs/web/<app>/PARITY_WEB_VS_IOS.md` ledger with ZERO unexplained 🟡:**

1. **Feature parity** — `R-WEB-CLONE-PARITY` (§ below): every in-scope iOS learning-relevant feature is ✅ parity / 🔄 adapted / ⛔ waived-with-rationale (never a bare 🟡). Recorded in the ledger's feature table + measured against the `## iOS feature inventory`.
2. **UI/UX parity** — `R-WEB-CLONE-UX-PARITY` (§ below): the clone carries the app's visual + interaction *character* (accent/semantic palette from the iOS `*Theme.swift`, IA, per-screen flow, HUD, feedback/motion, states, a11y). Recorded in the ledger's `## UI/UX parity` section + measured against `Docs/web/<app>/AUDIT_UX_PARITY_<date>.md`. **The UI/UX axis is verified by SCREENSHOT ANALYSIS, not by the automated suite alone** — see `R-WEB-CLONE-SCREENSHOT-DOD` (a UI/UX change is not DoD-complete until the surface is rendered, captured, and visually analyzed at desktop + mobile).

Both are **default-parity-with-documented-exceptions**, NOT pixel/behavior identity. The exception taxonomy is shared (platform-only affordance · site-chrome-cohesion substrate · web-platform norm · on-device/COPPA · documented diminishing-returns · founder-direct) — *"it was more work"* is never a waiver (that's a tracked 🟡). Both axes are **symmetric**: a learning-relevant feature or interaction that exists on only ONE surface must be backported to the other or waived, per `R-CLONE-BIDIRECTIONAL-BACKPORT` (hub files the iOS-direction handoff; the app session ships it back).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## A clone is not shipped until its HUB-SIDE artifacts land + are verified — not just the site PR (R-WEB-CLONE-HUB-SIDE-DOD; 2026-07-15)

**A `/play/<app>` clone is NOT "shipped" — and MUST NOT be claimed shipped — until BOTH halves land: (1) the SITE PR (routes + lib + kits + per-app CSS + `clone.meta.ts`, merged + live-verified) AND (2) the HUB-SIDE artifacts. A clone whose site code is live but whose hub-side artifacts are absent is *site-shipped-but-hub-dark* — a Definition-of-Done violation on the same footing as a missing parity axis.** Codified per founder-direct 2026-07-15 (*"codify the hub-side DoD rule"*). The runbook § 7 already says "two PRs per clone" procedurally; this makes the hub half an explicit, enforceable ship gate — because a clone genuinely *can* merge site-only, and when it does, the hub carries no signal that the clone exists or is done.

→ **Sub-rules** defined here (full detail in reference): (R-CLONE-BIDIRECTIONAL-BACKPORT).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## A spawned app's `/play` clone is a TRACKED follow-on — a `planned` registry row at clone-readiness, so it can't go silently un-built (R-WEB-CLONE-SPAWN-TRACKED; 2026-07-16)

**Every spawned portfolio app's `/play/<app>` web clone is a tracked follow-on deliverable: the instant the app reaches CLONE-READINESS it MUST get a `planned` row in `Docs/REGISTRY_WEB_CLONES.txt` (which enters it into the clone-candidate pipeline / `AUDIT_WEB_CLONE_NEXT_RANKING`), so it can never sit clone-ready-but-invisible. A clone-ready spawned app with NO registry row (planned / building / shipped) is a tracking defect.** Codified per founder-direct 2026-07-16 (*"what about web clone builds for the 4 new apps greenlit before? … codify this issue and resolution … add them to the work queue and prioritize"*).

→ **Sub-rules** defined here (full detail in reference): (R-SPAWN-KIT-ARC-SCAFFOLD).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Every active portfolio app has a web-clone row OR a documented exclusion — a standing coverage guard so no clone is silently forgotten (R-WEB-CLONE-COVERAGE-COMPLETENESS; 2026-07-20)

**Every ACTIVE portfolio app (`Docs/REGISTRY_ACTIVE_PORTFOLIO_APPS.txt`) MUST have EITHER a `planned`/`building`/`shipped` row in `Docs/REGISTRY_WEB_CLONES.txt` (R-WEB-CLONE-SPAWN-TRACKED — it's in the clone pipeline) OR a machine-parseable documented coverage entry (`# EXCLUDED: <app> — <reason>` = never a standard clone, web analog documented; `# DEFERRED: <app> — <reason>` = clone-ready-when-content-lands → flips to a `planned` row). An active app with NEITHER is *silently forgotten* — a coverage defect on the same footing as a missing gen-asset guard.** `scripts/check_web_clone_coverage.py --ci-mode` is the standing guard (set-difference of the two registries; fails on any un-covered active app). This is the `/play`-clone sibling of `portfolio.md` § R-ASSET-GEN-COMPLETENESS + § R-CHAPTER-MULTIBEAT-COMPLETENESS: a **self-checking registry so a clone-eligible app can never fall through** — codified per founder-direct 2026-07-20 (*"audit … we are not missing any portfolio web-clones or not silently forgotten. codify"*), after `AUDIT_WEB_CLONE_COVERAGE_2026-07-20` found 8 active apps with no clone row (+ 1 registry-drift orphan).

**The load-bearing distinction — a buried comment is NOT coverage.** The aggregator/out-of-band exclusions had been noted in a *prose comment* in the registry, which the guard can't parse and a resuming session won't find → the two newly-spawned younger-cluster apps (calmcubs/storypals) had drifted to zero coverage signal. So exclusions/deferrals MUST be the **machine-parseable `# EXCLUDED:`/`# DEFERRED: <app> —`** form (leading marker so the shipped/planned data-row parsers + distribution scripts skip them; the guard greps them explicitly). Reasons must name the **web analog** (why no clone is correct): aggregator → the `/play` index/zones · MP-platform → the shared room-MP shells · teacher-tool/accounts → COPPA-infeasible, analog = on-device `<ProgressReport>` · launcher → the site IA · out-of-band audience → outside the 3-5/6-8/9-14/15-18 clone bands · younger-activity-port → DEFERRED until activity banks land.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## The canonical UI/UX best-practices reference for every clone (R-WEB-CLONE-UI-UX-BEST-PRACTICES; 2026-07-14)

**Every `/play/<app>` clone — current AND all future — follows the canonical, evidence-based UI/UX best-practices reference at `Docs/GUIDE_WEB_CLONE_UI_UX_BEST_PRACTICES.md`.** It distills what the portfolio has SHIPPED (the prominence program across ~60 themed clones, the shared `.pc-q-*` / `.ff-stage` design system, the screenshot-DoD discipline) into ONE authoring + review guide, grounded in the learning-science + accessibility literature (cognitive-load theory; the 2025 JSIR children's ed-gaming multicriteria study; elaborated-feedback superiority [Shute; Hattie & Timperley]; the seductive-details meta-analysis; WCAG 2.2 target-size/dragging/focus criteria; POE). Codified per founder-direct 2026-07-14 (*"codify the UI/UX best practices for all future web-clones using what we have shipped so far"*).

**This rule is the umbrella** over the per-axis UI/UX rules — it does NOT replace them; it ties them into one reference so a new-clone author has a single entry point + checklist:
- The **3-card color-coded prominence stack** (accent question card → accent-topped manipulative stage → semantic feedback panel) — § R-WEB-CLONE-QA-PROMINENCE + § R-WEB-CLONE-MANIPULATIVE-PROMINENCE.
- **Reuse the shipped design system** (studio substrate + `.pc-theme-<app>` tokens + shared `mcRound`/`customRound` shells + `.ff-stage`) — never hand-roll; bespoke CSS per-app only (§ R-WEB-CLONE-MERGE-HYGIENE).
- **Accessibility floor** (WCAG 2.2: ≥44px kid targets, keyboard + single-pointer drag alt, visible focus, AA contrast, verdict-not-by-colour, reduced-motion) — a HARD obligation, never waived.
- **Anti-patterns** (decoration on the critical path / clutter / muted feedback / weak hierarchy / dark surface) — the documented flaws.
- **Register + narrative placement** (ages 9–14 warm copy; narrative only at session boundaries).
- **Verification** — the mandatory screenshot-DoD pass (§ R-WEB-CLONE-SCREENSHOT-DOD) + the reusable prominence-treatment recipe.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Web clones have an automated test suite — Vitest units + Playwright a11y/SEL smoke (R-WEB-CLONE-TEST; 2026-07-12)

**Every `/play/<app>` clone is covered by an automated test suite in `spark-anvil-site`: `npm test` (Vitest — the SPM-unit analog) asserts mechanic LOGIC + hand-authored bank invariants + the shared `_shared/` round-shell contract; `npm run test:e2e` (Playwright — the XCUITest analog) drives every `/play` route headless to assert it renders + throws zero console/runtime errors + (SEL routes) exposes the crisis footer. This layer catches the "builds green, ships wrong" class the build-time gates cannot see (a bank with a wrong answer, a mechanic that throws on load).** Codified per founder-direct 2026-07-12 (*"prioritize testing"*) after implementing `Docs/PLAN_WEB_CLONE_TESTING_STRATEGY_2026-07-12.md` (site PR #483). On its first run the Playwright smoke gate found + fixed a real production crash (`/play/sleuthlab/casefiles` `RangeError` on difficulty-5 cases).

→ **Sub-rules** defined here (full detail in reference): (R-WEB-CLONE-SEL-CRISIS-FOOTER-SCOPE) · (R-WEB-CLONE-TEST-PERF).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Screenshot analysis is a MANDATORY gate for UI/UX + Definition of Done (R-WEB-CLONE-SCREENSHOT-DOD; 2026-07-13, made mandatory-per-clone 2026-07-14)

**Screenshot analysis is a MANDATORY ship gate — not optional, not "when convenient." Any UI/UX-affecting change to a `/play` clone (or any site surface), AND every NEW clone at ship time, is NOT done — and NOT DoD-complete — until the surface(s) have been RENDERED, CAPTURED as a screenshot, and VISUALLY ANALYZED by the agent, at BOTH a desktop and a mobile viewport, with the analysis recorded (before/after where it's a refinement).** A clone whose registry row is flipped to `shipped` without a recorded screenshot pass is a DoD violation, exactly as if it were missing a parity axis. The automated suite (R-WEB-CLONE-TEST) asserts a surface *renders, doesn't throw, is keyboard-operable, and has accessible names* — it is BLIND to whether the surface actually *looks right*: visual hierarchy, prominence, colour use, contrast, spacing/dead-space, alignment, font sizing, clipping/overflow, and the question→manipulative→answer→feedback reading order. Only looking at the pixels catches the **"builds green + passes every test + looks wrong"** class. Codified per founder-direct 2026-07-13 (*"codify the rule that screenshots analysis are required for ui/ux testing and definition of done"*), after the prominence-program screenshots drove real fixes automated tests could never have surfaced (a muted "Solve for x", answer options weaker than the question card, an under-used app accent, a small math readout).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## UI testing + screenshot-DoD MUST cover DARK MODE, not just light (R-WEB-CLONE-DARK-MODE-TEST; 2026-07-14)

**Every `/play` clone (and every site surface) MUST be verified in BOTH color schemes — `prefers-color-scheme: light` AND `prefers-color-scheme: dark` — by the automated Playwright gate AND the screenshot-DoD pass. A surface that renders + reads correctly in light but is broken in dark (unreadable text on a dark panel, AA-contrast failure, an accent/semantic colour that vanishes, an un-themed white flash) is a defect, exactly as if it failed in light.** Codified per founder-direct 2026-07-14 (*"make sure the UI testing cover dark mode as well because there are a lot of dark mode issues with the web site."*). The site themes via **media queries** (`@media (prefers-color-scheme: dark)` in `global.css` + `play.css` + per-app `.pc-theme-<app>` tokens), so dark mode is the OS/browser default for a large fraction of real users and was previously **untested + un-screenshotted**.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Dark-mode SUPPORT best practices — theme through the shared vars; never render light-in-dark (R-WEB-CLONE-DARK-MODE-SUPPORT; 2026-07-15)

**Every `/play` clone MUST render correctly in `prefers-color-scheme: dark` by theming through the SHARED design-system variables — never by hardcoding light hex on its own surfaces. A clone (or a shared-surface change) that renders bright-white-in-dark, or dark-on-dark / light-on-light unreadable, is a defect on the same footing as a failed parity axis.** This is the *design/authoring* companion to `R-WEB-CLONE-DARK-MODE-TEST` (which is the *gate*): -TEST tells you dark is verified; -SUPPORT tells you how to build so it passes. Codified per founder-direct 2026-07-15 (*"codify dark mode support best practices in repo"*) after V237 found the entire `/play` layer rendered light-in-dark and fixed it with one shared block.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Dark-mode coverage is WHOLE-SITE, not just /play — marketing/company chrome + light-only imagery (R-SITE-DARK-MODE-WHOLE-SITE; 2026-07-15)

**Dark-mode support + verification apply to EVERY site surface — the marketing/company pages (home, `/for-parents`, `/for-educators`, `/mission`, `/about`, `/press`, `/apps`, `/cast`, `/stories`, `/books`, the `/play` index) and the shared chrome (Nav, Footer, hybrid-glass) — NOT only the `/play` clones.** `R-WEB-CLONE-DARK-MODE-TEST` / `-SUPPORT` were written `/play`-scoped; this rule extends them site-wide. Codified per founder-direct 2026-07-15 (*"the rest of the web site also have dark-mode issues too, not just the /play unit"* + *"fix and codify"*) after the V251 audit (`Docs/AUDIT_SITE_DARK_MODE_2026-07-15.md`).

- **Theme through the shared `--sa-*` tokens** (`global.css` `:root` + its `@media (prefers-color-scheme: dark)` flip) — never hardcode a light surface hex on a company page; a new `--sa-*` token gets a dark value in the same change (the marketing-side analog of R-WEB-CLONE-DARK-MODE-SUPPORT's `--ff-*`/`play.css` discipline).
- **Light-only RASTER imagery is the load-bearing trap** (the motivating defect): a PNG/JPG with a **baked opaque light background + no alpha** (logos, badges, illustrations) is invisible on a light surface but renders a **glaring light box on a dark surface**. `lockup.png` (Nav) + `logomark.png` (Footer) did exactly this on every page. Fix options, in order of preference: (a) a transparent-background asset with a **dark-mode variant** (light-ink) swapped via `<picture>`/`prefers-color-scheme`; (b) a **deliberate rounded brand tile/plate** (rounded corners + soft dark-mode ring/border) so the light chip reads as intentional, not accidental — the accepted dark-header pattern for light-only logos (the V251 fix, site PR #700); NEVER (c) leave a full-bleed sharp light rectangle. A CSS `dark:` background/ring on an opaque-bg image only *frames* it — it cannot make the baked background transparent, so rounding+plating is the honest interim until a real dark asset exists.
- **The gate is the SAME two-layer gate, now over marketing routes too:** ✅ **IMPLEMENTED (V252, site PR #711):** the `chromium-dark` Playwright project (R-WEB-CLONE-DARK-MODE-TEST) now enumerates the top-level marketing/company routes via `tests/e2e/routes.ts marketingRoutes()` (filesystem-enumerated, never-scoped) — the smoke + a11y specs run them in both the light + `chromium-dark` projects for the render-+-operable + WCAG-shell assertion (this surfaced + fixed a real WCAG 1.3.1 `/today` duplicate-`<main>` bug). The mandatory **dark screenshot-DoD** (R-WEB-CLONE-SCREENSHOT-DOD, in-session-Opus-analyzed) covers any company-page or shared-chrome visual change, dual-scheme at desktop+mobile.
- **When it applies:** any change to Nav/Footer/BaseLayout/global.css/`--sa-*`/a company page/a shared raster asset → screenshot-verify dark + light; a light-in-dark surface, a baked-light-bg image box, or a sub-AA company-page text is a defect on the same footing as a `/play` dark defect.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Toggle visibility via the `[hidden]` attribute, backed by a global `[hidden]{display:none!important}` — a component's own `display:` silently defeats `[hidden]` → "stuck" UI (R-SITE-HIDDEN-ATTR-DISPLAY; 2026-07-20)

**Any element shown/hidden at runtime by toggling the `hidden` attribute / `.hidden` property (the site's near-universal pattern — `AffectCheckIn`, `MasteryProgress`, `AgencyLoop`, the feedback rails, `ReadingAccess`, etc.) RELIES on the global base rule `[hidden] { display: none !important; }` (in BOTH `src/styles/global.css` site-wide AND `src/styles/play.css` /play base). Never rely on a component's own `display` cooperating with the UA `[hidden]{display:none}`, and never "hide" by only setting the attribute if the element also has an explicit CSS `display`.** Codified after the founder-reported fractionforge **"Before you start" (the `<AffectCheckIn>` card) stuck-after-tap** bug (site PR #1108).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## One shared layout system — 8pt spacing scale + container + reading-measure + section rhythm (R-SITE-LAYOUT-SPACING; 2026-07-15)

**Every site page lays out through ONE shared system — an 8pt spacing scale, a single content container, a 66ch reading-measure for long-form copy, and a consistent section-rhythm token — defined in `global.css`; pages MUST NOT hand-roll ad-hoc widths + spacing per page.** Codified per founder-direct 2026-07-15 (*"almost all web pages on the website have layout and spacing issues. do deep web research if needed"* + *"fix and codify"*). Evidence base: `Docs/RESEARCH_SITE_LAYOUT_SPACING_BEST_PRACTICES_2026-07-15.md`; audit: `Docs/AUDIT_SITE_LAYOUT_SPACING_2026-07-15.md`.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## A device-specific feature is SKIPPED, never a reason to skip the whole app (R-WEB-CLONE-DEVICE-FEATURE-SKIP; 2026-07-12)

**Requiring device-specific functionality is NOT a clone-eligibility blocker. If a feature needs a capability the browser cannot deliver on-device — AR/RealityKit/ARKit, Vision, CoreMotion/gyroscope, camera/mic capture, real-time haptics, Game Center, MultipeerConnectivity, SpriteKit *physics*, on-device FoundationModels — that ONE feature is skipped for the web clone (⛔ waived · platform-only, OR 💡 iOS-ENHANCE if it delivers novel LEARNING); the REST of the app MUST still be ported to the web.** Codified per founder-direct 2026-07-12 (*"loosen the blocker check: if a feature requires device-specific functionality, then that feature can be skipped for the web clone. the rest of the app should be ported to web"*).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Web-app clones must keep feature parity with their iOS app (R-WEB-CLONE-PARITY; 2026-07-08)

**A browser learning-app clone of a portfolio iOS app (the `/play/<app>/*` route tree — FractionForge is the first, `/play/fractionforge`) MUST maintain feature parity with that app's LEARNING-RELEVANT features, UNLESS a specific delta is EXPLICITLY WAIVED with a documented rationale in the app's parity ledger.** Parity is the default; every gap is either closed or explicitly justified — never silently dropped. Codified per user-direct 2026-07-08 (*"codify the requirement that fractionforge iOS app and web page need to have feature parity unless explicitly allowed not to"*).

→ **Sub-rules** defined here (full detail in reference): (R-CLONE-BIDIRECTIONAL-BACKPORT).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Web-clone UI/UX parity — the clone must carry its iOS app's visual + interaction character (R-WEB-CLONE-UX-PARITY; 2026-07-10)

**A `/play/<app>` web clone MUST reproduce its iOS app's UI/UX *character* — visual identity + interaction design — to a reasonable degree, UNLESS a specific delta is EXPLICITLY WAIVED with a documented rationale in the clone's UI/UX parity ledger.** This is the visual/interaction sibling of `R-WEB-CLONE-PARITY` (which governs *learning-feature* parity). Codified per user-direct 2026-07-10 (*"do full audit of fractionforge and grammarforge ios app ui/ux and create ui/ux parity for their web clones with reasonable exceptions. codify the ui/ux parity requirements with reasonable exceptions"*).

`R-WEB-CLONE-PARITY` says the clone must have the same *features*; this rule says it must *look and feel like the same app*. Both are default-parity-with-documented-exceptions; neither is pixel-matching.

→ **Sub-rules** defined here (full detail in reference): (R-CLONE-BIDIRECTIONAL-BACKPORT).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

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
- **Optional self-explanation reconcile (DEPTH lever — use SPARINGLY)** — where warranted, a boundary-placed "Why?"/choose-the-reason micro-step after an answer (pick the reason from 2–3 options — no free-text/AI evaluator → COPPA-safe; the `R-WEB-CLONE-POE` Explain step generalized). Strongly evidenced (Bisra 2018 g≈0.55) BUT **selective + adaptive, never on every item** — over-prompting causes documented "metacognitive overload" (Guo 2022); surface it after a first miss or on misconception-bearing items. Distinct from the DIR/FEDC *affect* reflection (cognition ≠ affect). Folded into the manipulative/QA DEPTH axis, NOT a co-equal expansion axis — see `R-WEB-CLONE-PRACTICE-SCHEDULING` § Companion DEPTH lever.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## The manipulative is a prominent CARD/STAGE — same studio treatment as the Q&A cards, quiet background (R-WEB-CLONE-MANIPULATIVE-PROMINENCE; 2026-07-13)

**The interactive MANIPULATIVE (the hands-on surface — fraction bar, ray-trace bench, cipher wheel, spinner, grid…) is, together with the Q&A flow, the most prominent element of a clone, and it wears the SAME studio card treatment as the `.pc-q-*` question/answer cards** — the shared `.ff-stage` class (bold outline + hard drop-shadow + whitespace isolation + centering). Codified per founder-direct 2026-07-13 (*"make all the manipulatives prominent too"* + *"should the manipulatives have the card treatment like the question and answer cards too?"* → **yes**), on the evidence in `Docs/RESEARCH_WEB_CLONE_MANIPULATIVE_PROMINENCE_2026-07-13.md`; foundation shipped site PR #531 (fractionforge pilot).

- **The card frame is a STRUCTURAL signifier, not decoration** (research directive 2) — it says "this is the work surface," so it's on-thesis, and it makes the screen read as a coherent hierarchy: **question card → manipulative stage-card → feedback card.**
- **The seductive-detail guardrail (directive 5, load-bearing):** the CARD/CONTAINER gets the outline+shadow, but the manipulative's **background stays quiet** — flat fill, **never a `background-image`**, no ambient/idle animation on the stage; saturated accent lives on the manipulable **OBJECTS**, not the surface; no mascots/particles on the active stage (narrative stays at session boundaries — R-NARRATIVE-BETWEEN-NOT-DURING + R-GUARD-THE-RATIO). Prominence comes from **size + isolation + instant responsiveness**, never spectacle.
- **Shared primitives** (base `play.css`, adopt per-clone): `.ff-stage` (the card — carries an **accent top-edge** in the app's `--pc-select` so the practice stack reads as a color-coded hierarchy [accent question card → accent-topped stage → semantic feedback] instead of three identical beige boxes; colour rides the frame, the surface stays quiet), `.ff-stage--dominant` (opt-in viewport-share — a blanket `min-height` distorts small manipulatives, so it's per-clone), `.ff-draggable` (grab-cursor + grabbing shadow-lift affordance — directive 3), `--ff-snap-duration` + `.ff-valid-drop`/`.ff-invalid-drop` (non-color + color constraint cues — directives 4/7), all reduced-motion-safe.
- **Rollout:** unlike the Q&A flow (one shared shell), there is **no single shared manipulative surface** — most manipulatives sit in bespoke per-clone wrappers, so a clone adopts prominence by wrapping its manipulative in `.ff-stage` (+ `--dominant` where it helps). Per-clone rollout across the ~50 non-fractionforge clones is tracked continuation (work-queue V181; the portfolio-wide sweep pass completed V221, `Docs/AUDIT_WEB_CLONE_PROMINENCE_SWEEP_2026-07-14.md`). A11y (keyboard-adjust, single-pointer drag alternative per WCAG 2.5.7, ≥44px handles, `aria-valuetext`, non-color cues) is a hard obligation per adopting clone.
- **▶ Playbook:** the treat-vs-no-op decision tree (the sweep's key finding: shared-shell clones are already prominent; only genuine *floaters* need treatment) + copy-paste CSS recipes (accent-topped stage / accent question-card / tabular readouts) + per-manipulative-type reference treatments live in **`Docs/GUIDE_WEB_CLONE_PROMINENCE_BEST_PRACTICES.md`**.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Every DRAG / positional / slider manipulative MUST have a single-pointer + keyboard alternative AND a ≥44px handle with a drag affordance — drag-only is a defect (R-WEB-CLONE-DRAG-TARGET; 2026-07-20)

**Any manipulative a learner moves by DRAGGING — a slider knob, a draggable marker/token/handle, a drag-to-place tile, a pinch/drag surface — MUST ship ALL of: (1) a discoverable SINGLE-POINTER alternative to the drag (visible ◀▶/±/tap-to-place buttons or tap-the-track — WCAG 2.5.7 Dragging Movements); (2) KEYBOARD operability (arrow keys / Home-End on a focusable `role="slider"`, WCAG 2.1.1); AND (3) a ≥44px pointer/touch target for the handle, verified ON MOBILE where a fixed-viewBox SVG shrinks the handle below the CSS size (WCAG 2.5.8 + the portfolio kid-target standard), WITH a clear drag AFFORDANCE (raised drop-shadow "knob" + `grab`/`grabbing` cursor) so it reads as grabbable. A drag-ONLY manipulative, or one whose handle renders < ~44px on a phone, is a defect on the same footing as a missing parity axis.** Codified per founder-report 2026-07-20 (the FractionForge number line: drag was the only way to place the marker + the handle was a 26px dot, "very small on mobile"). This makes the a11y obligation that R-WEB-CLONE-MANIPULATIVE-PROMINENCE already *names* ("single-pointer drag alternative per WCAG 2.5.7, ≥44px handles") into an ENFORCEABLE, audited gate — because naming it did not stop the number line shipping drag-only + 26px.

**The load-bearing gotchas (author + review against these):**
1. **A fixed-`viewBox` SVG handle is NOT a fixed CSS size — it SHRINKS with the responsive svg, so a radius that's ≥44px on desktop is < 44px on a phone (the exact mobile-target complaint).** A `r=24` svg-unit halo measured **48px desktop but only 31px on a 402px mobile viewport** (the svg scales down). FIX = a geometry-CSS media query bumping the handle's `r` at narrow widths (`@media (max-width:640px){ .handle-hit { r: 34px; } }` → back to ~44px), OR a non-SVG DOM handle. **Always MEASURE the handle's rendered `boundingBox()` at a ~390–402px mobile viewport**, never trust the svg-unit radius.
2. **The ≥44px target is best delivered by a transparent HIT-HALO** (a `fill:transparent; pointer-events:all` circle/rect ≥44px carrying the pointerdown/drag) BEHIND a tastefully-sized visible handle — so the touch target is big without a giant visible dot. Track the halo's position alongside the visible handle.
3. **Tap-the-track is the most intuitive single-pointer path** for a slider/number-line: a tap/click anywhere on the track jumps the handle to the nearest valid stop and starts a drag (standard "click-to-seek"). SNAP to valid stops (the same quantizer the drag uses — e.g. `posForX`), so a tap can only land on a legal value (a divider tick), never between.
4. **The drag AFFORDANCE is required, not optional** — a raised drop-shadow (physical "knob"), `cursor:grab`→`grabbing`, and a track `cursor:pointer` tell the learner what's draggable/tappable. Animate only GLOW/shadow, never the bounding box (R-WEB-CLONE-TEST — an animated bounding box breaks Playwright actionability).
5. **The instruction text names every path** ("Tap the line, drag the marker, or use the ◀▶ buttons / arrow keys") so all three are discoverable.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Manipulative/representation expansion follows the CRA ladder + an Applications rung — and it generalizes to NON-math clones via Bruner's modes (R-WEB-CLONE-CRA-LADDER; 2026-07-17)

**The manipulative BREADTH+DEPTH expansion axis (ADR-048 / `PLAYBOOK_WEB_CLONE_EXPANSION.md`) is ORGANIZED by the CRA ladder — Concrete → Representational → Abstract — plus a fourth APPLICATIONS / transfer rung; and it applies to BOTH math AND non-math clones (the ladder generalizes via Bruner's enactive→iconic→symbolic modes, which are domain-general).** When expanding a clone's manipulatives/representations, audit its surfaces by rung and expand to fill missing rungs — a primitive taught only ABSTRACTLY (an MC/Concepts surface) earns a Concrete + Representational surface; a primitive with only a manipulative earns an Applications/transfer surface. Codified per founder-direct 2026-07-17 (*"apply the cra model of singapore math to our expansion playbook … more concrete/manipulatives, more representational modes and more abstract modes"* + *"can we apply the cra model to non-math web clones?"* + *"add 'applications' as another axis"* + *"codify … especially the one about applying cra model to both math and non-math web-clones"*).

**Evidence (sourced — `RESEARCH_WEB_CLONE_EXPANSION_2026-07-17.md` § CRA):** CRA **is** Singapore math's CPA (Concrete-Pictorial-Abstract), both grounded in **Bruner's** three modes of representation (enactive / iconic / symbolic, 1960s → Mercer & Miller 1992). The **Ebner et al. (2025)** meta-analysis (30 single-case studies, *Learning Disabilities Research & Practice*) found a **very large** overall effect; the IES **What Works Clearinghouse (2021)** rates concrete + semi-concrete representations **strong evidence**; and **virtual ≈ concrete** manipulatives (equally effective) — so the web's virtual manipulatives are legitimate CRA stand-ins. Honest-yield caveat: the strongest RCT base is MATH/quantitative; for non-math it's an **evidence-aligned ANALOGY via Bruner's domain-general modes**, applied as a representation-progression heuristic, NOT a claim of the math effect size.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Prefer Predict-Observe-Explain (predict-before-reveal) when a clone re-renders a deterministic sim/mechanic (R-WEB-CLONE-POE; 2026-07-14)

**When a `/play/<app>` clone re-renders a DETERMINISTIC, model-predictable simulation or mechanic (a phase cycle, an energy-flow graph, a truth table, a physics/parameter model, a rule the learner can reason toward), the DEFAULT framing is a scored Predict-Observe-Explain (POE) loop — the learner commits a prediction BEFORE the outcome is revealed, then reconciles the reveal — NOT a free-play "tap-and-watch" arena.** POE is one of the best-evidenced moves in science-education research (meta-analysis of 35 studies: Hedges' **g ≈ 0.98** on science achievement), and the cognitive engine is **errorful generation + prediction error** (committing a prediction — even a wrong one — then getting feedback encodes the answer better than watching), not "the sim is fun." Free-play iOS SpriteKit sims (and apps like Tinybop) leave this on the table, which is why a POE re-render is the portfolio's reference **web-pioneered → iOS-backport** feature. Full evidence base + design spec + worked examples: **`Docs/RESEARCH_PREDICT_OBSERVE_EXPLAIN_MECHANIC_2026-07-14.md`**. First consumer: `/play/curiosityquest` (Water Cycle predict-the-phase · Food Web predict-the-cascade · Logic Lab predict-then-run).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Practice-scheduling is the 7th expansion axis — spaced retrieval + interleaving + edge-of-competence, ON-DEVICE + calm-rails (R-WEB-CLONE-PRACTICE-SCHEDULING; 2026-07-18)

**A `/play/<app>` clone's EXPANSION includes a distinct 7th axis — PRACTICE-SCHEDULING / MASTERY SEQUENCING: the cross-item, cross-session lever governing WHICH item the learner sees next + WHEN a learned item RESURFACES (spaced retrieval + interleaved "Mixed practice" + edge-of-competence next-item selection). It is ORTHOGONAL to the manipulative "assessment depth"/"bank depth" (those are within-surface + within-session); it is realized ON-DEVICE (`localStorage`, no identifier → COPPA-trivial); and it MUST be calm-rails (no due-count dread / streak-guilt / gating). A discrete-item clone (MC-kit / manipulative-POE bank) with no resurfacing/interleaving/adaptive-next is a parity gap; a solo-creative-tool / solo-reflection clone waives it with a one-line rationale.** Codified per founder-greenlight 2026-07-18 (add a full 7th expansion axis) on the evidence in `Docs/RESEARCH_WEB_CLONE_EXPANSION_ADDITIONAL_AXES_2026-07-17.md` (ADR-048 amendment). This is the sequencing sibling of `R-WEB-CLONE-POE` (a mechanic) + `R-WEB-CLONE-CRA-LADDER` (representation breadth) — the same expansion program, a different lever.

**The three sub-mechanisms (build/audit against these):**
1. **Spaced retrieval** — resurface an introduced item on an expanding due-based schedule (FSRS-lite), not only in the kit that introduced it. Spacing is one of the most robust findings in learning science (300+ studies); learners do NOT adopt it spontaneously, so the app automates it.
2. **Interleaving** — offer a "Mixed practice" round mixing item types/kits (improves discrimination + retention) — but ONLY over *already-acquired* items, NEVER during a primitive's first teaching, and the app must curate the mix (learners are biased toward blocking).
3. **Edge-of-competence next-item** — pick the next item near the mastery frontier (Vygotsky ZPD: extend/consolidate/stretch) — the sequencing half the iOS `ForgeMasteryEngine.NextProblemPicker` already implements.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Mastery-progression is the 8th expansion axis — intrapersonal progress + achievements + goals, ON-DEVICE + calm-rails, NO leaderboards/currency/streak-guilt (R-WEB-CLONE-MASTERY-PROGRESSION; 2026-07-18)

**A `/play/<app>` clone's EXPANSION includes a distinct 8th axis — MASTERY-PROGRESSION / GOAL & ACHIEVEMENT: the clone-wide, cross-session lever that gives a persistent sense of ACCOMPLISHMENT + a reason to return — a calm progress bar (XP-from-first-try-mastery), an achievements shelf keyed to LEARNING milestones, and optional learner-set goals / personal-best ("beat YOUR best"). It is realized ON-DEVICE (`localStorage`, no identifier → COPPA-trivial), it is DEFINED by its EXCLUSION of the evidence-flagged maladaptive forms, and it MUST be mastery-oriented + intrapersonal. A discrete/gradeable clone (MC-kit · manipulative/POE bank · board/strategy) with no progress/achievement/goal layer is a parity gap; a solo-reflection/SEL clone ⛔-waives it (progress-tracking undermines the private pillar); a pure solo-creative clone ⛔/🔄 (a gentle "pieces you've made" shelf only, never scored); and a **BESPOKE-STORE / BESPOKE-ENGINE clone ⛔-waives it** — a clone whose progress lives in a bespoke store (IndexedDB / a non-`${ns}.progress.v1` key) or a bespoke adaptive/gamification system supersedes the shared card, and wiring `<MasteryProgress namespace="ns">` (which reads `${ns}.progress.v1`) would render a permanently-EMPTY card = a defect (fractionforge = bespoke IndexedDB store + richer bespoke boss/XP system; alcumusforge = bespoke adaptive mastery engine, no discrete MC-kit bank; both 2026-07-18). Documented non-build, NOT a gap — the SAME ⛔ criterion binds axis-7 (§ R-WEB-CLONE-PRACTICE-SCHEDULING), since both axes read the shared `${ns}.progress.v1` store. **Verify before waiving:** grep `progress.ts` for `makeProgress('<ns>')` + a `kits-index.ts`.** Codified per founder-greenlight 2026-07-18 (add a full 8th expansion axis, mastery-progression) on the evidence in `Docs/RESEARCH_WEB_CLONE_EXPANSION_GAMIFICATION_2026-07-18.md` (ADR-048 amendment). This is the reward+goal+recognition sibling of `R-WEB-CLONE-PRACTICE-SCHEDULING` (sequencing) — distinct because adventure is a progression *map*, practice-scheduling is the mastery *state/sequence*, and this is the *accomplishment/recognition* layer on top.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Scaffolded hint-ladder is the 9th expansion axis — articulate-before-hint · PROGRESSIVE multi-level hints · FADED worked example · misconception-targeted remediation, ON-DEVICE (R-WEB-CLONE-SCAFFOLDED-HINTS; 2026-07-18)

**A `/play/<app>` clone's EXPANSION includes a distinct 9th axis — SCAFFOLDED HINT-LADDER: the in-round pedagogy lever that turns a stuck attempt into a PROGRESSIVE, FADED scaffold instead of a one-shot hint. The web round shells (`_shared/mcRound`/`customRound`) shipped one-shot elaborated feedback + a single hint; this axis adds a shared `_shared/scaffold.ts` engine that drives (i) an ARTICULATE-BEFORE-HINT gate (no hint before the first wrong attempt), (ii) PROGRESSIVE multi-level hints (one rung per wrong attempt, least→most revealing), (iii) an optional FADED WORKED EXAMPLE as the terminal rung before the answer is revealed, and (iv) optional per-wrong-option MISCONCEPTION-targeted remediation. It is realized ON-DEVICE (pure TS, no PII, no AI evaluator → COPPA-trivial) and the portfolio ALREADY owns the engine on iOS (`ForgePedagogy`: `PolyaScaffold` · `WorkedExampleProvider` · `MisconceptionDetector`).** A discrete-item archetype (MC-kit · manipulative/POE bank) whose wrong-answer path is a single hint → generic reveal is a DEPTH gap; a solo-creative-tool / solo-reflection clone with no gradeable item ⛔-waives it (one line). Codified per founder-greenlight 2026-07-18 (ForgeKit-mining wave, ADR-048 Decision 9) on `Docs/RESEARCH_WEB_CLONE_EXPANSION_FORGEKIT_MINING_2026-07-18.md`.

**The evidence DEFINES the guardrails (build/audit against these — the design IS the evidence):**
- **Articulate-before-hint** — a hint is NEVER offered before the learner's first attempt; premature + superficial hint use *consistently reduces* learning ("gaming the system" — LAK26 2026, 999 K-12 students). The engine stays LOCKED until `unlock()` (the shell calls it after the first wrong try). A give-away "Hint" button up front is a **defect**, not this axis.
- **Progressive + FADED** — hints reveal least→most, one rung per attempt, ending in a faded worked example (fading is the strongest intra-example feature — Barbieri et al. 2023 meta; worked examples ≈ **0.48 SD** on math). Never dump the whole answer at once; never a single give-away.
- **NO mandatory self-explanation on the worked example** — Barbieri 2023 found self-explanation prompts *negatively moderated* the worked-example effect. Self-explanation stays the SPARING, adaptive axis-6 fold-in (`R-WEB-CLONE-QA-PROMINENCE` — after a first miss / misconception item, not on every hint). Bolting a mandatory "explain" onto the worked example is a defect.
- **Misconception remediation = a DETERMINISTIC map** (wrong-option → targeted note), NO AI evaluator (COPPA-safe, nothing transmitted) — the `MisconceptionDetector` parity. Anti-shame register; the round ALWAYS advances (reveal when the ladder is exhausted); boundary-in-round, quiet stage.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Standards-mapped parent/educator report is the 10th expansion axis — the FIRST adult-facing axis, ON-DEVICE + export-on-demand, NO accounts/server/PII (R-WEB-CLONE-PROGRESS-REPORT; 2026-07-18)

**A `/play/<app>` clone's EXPANSION includes a distinct 10th axis — the FIRST ADULT-facing one — a STANDARDS-MAPPED PROGRESS REPORT: a read-only "how it's going" view for a parent/educator + an EXPORT-ON-DEMAND (CSV / print), DERIVED ON-DEVICE from the SAME `${ns}.progress.v1` store the learner-facing axes (7/8) write. It is DEFINED by COPPA-avoidance-by-construction: NO accounts, NO server, NO hosted dashboard, NO PII off-device — a private, on-device view + a user-triggered export.** Every other axis is learner-facing; a clone has no adult-facing surface, though the site has a `/for-parents-educators` hub + per-app standards mapping + grade/level chips, and iOS owns the engine (`ForgeReporting`: `parentConferenceReport` · `standardsCSV` · `strengths`/`growthAreas`/`recommendations` · `StandardProficiency`). A discrete/gradeable clone (MC-kit · manipulative/POE bank) writing the shared `makeProgress('ns')` store with no adult report is a parity gap; a solo-creative/reflection clone or a bespoke-store clone ⛔-waives it (the SAME eligibility criterion as axes 7/8 — it reads `${ns}.progress.v1`; a bespoke IndexedDB store → an empty report = a defect, so verify `makeProgress('<ns>')` + a `kits-index.ts` before wiring). Codified per founder-greenlight 2026-07-18 (ForgeKit-mining wave, ADR-048 Decision 10) on `Docs/RESEARCH_WEB_CLONE_EXPANSION_FORGEKIT_MINING_2026-07-18.md`.

**Why it's a clean, defensible axis (the scoping IS the point):** family engagement → learning outcomes is well-established (ReadyRosie / ParentPowered), and a standards-mapped strand breakdown is the credible report shape; parents + educators are the buyers/gatekeepers (the site trust-sell). Building it **on-device + export-on-demand** sidesteps the entire 2025-COPPA parental-consent/retention burden (the hosted-account model we deliberately avoid) — the same on-device posture as `R-SITE-FEEDBACK` / ReadingAccess / the offline PWA. **HARD guardrails:** on-device only (nothing transmitted); export is USER-triggered (a Blob CSV download / `window.print`, never auto-upload); plain-language + a "saved only on this device" note; standards labels from the clone's own kit metadata; dark-safe (`--ff-*`/`--pc-*`). **NO** learner-shaming framing — it RECOGNIZES progress + names growth areas gently (anti-shame, same register as axis 8).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Affect / self-regulation check-in is the 11th expansion axis — GENTLE session-start check-in + co-regulation off-ramp, ON-DEVICE, NO mood-surveillance (R-WEB-CLONE-AFFECT-CHECKIN; 2026-07-18)

**A `/play/<app>` clone MAY carry a distinct 11th axis — an AFFECT / SELF-REGULATION CHECK-IN: a GENTLE, OPTIONAL, dismissible session-START check-in ("how are you arriving?") + an on-demand CALM-DOWN / co-regulation off-ramp (a short tap-through grounding + breathing sequence), placed at a session boundary. It is DEFINED by its guardrails — because the evidence is context-dependent, not universally positive.** Distinct from the results `reflect.ts` (a one-shot post-round reflection): this is the session-start affect-labeling moment + a between-practice calm-down a stuck learner can reach. iOS parity: `ForgeEmotionAware` (`AffectCalibrator`/`CoRegulationEngine`/`SensoryRamp`) + DIR/FEDC. Codified per founder-greenlight 2026-07-18 (ForgeKit-mining wave, ADR-048 Decision 11) on `Docs/RESEARCH_WEB_CLONE_EXPANSION_FORGEKIT_MINING_2026-07-18.md`.

**The evidence + the HARD guardrails (a violation is a defect, on the `R-SITE-FEEDBACK` footing):** RULER Mood Meter + affect-labeling (Lieberman 2007: labeling engages PFC, dampens amygdala → incidental regulation) support a gentle check-in — BUT affect-labeling benefits are **CONTEXT-DEPENDENT**: a broader *negative* emotion vocabulary can correlate with distress (Vine 2020 / DeLap 2024). So the axis MUST be: **GENTLE + OPTIONAL** (dismissible; the round works without it) · **NON-diagnostic + NON-scored** · **NOTHING stored or transmitted about the feeling** (only an ephemeral session-only "hide" flag — NO mood log, NO trend-tracking; a mood log/score/trend is the exact surveillance to avoid) · **body-sensation register (SAMHSA-aligned)**, every arrival normalized ("all of these are fine") · **calm-rails · reduced-motion-safe · dark-safe** · boundary-placed only (`R-NARRATIVE-BETWEEN-NOT-DURING`). It is **NOT a mental-health screener**; **⛔/careful for anxiety-sensitive clusters** — a genuine affect-crisis SEL clone keeps its own 988/crisis footer (`R-WEB-CLONE-SEL-CRISIS-FOOTER-SCOPE`), and math-anxiety-flagged / younger clusters get the gentlest framing or a waiver.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Every clone's progress-store namespace MUST be globally UNIQUE — a shared ns commingles two clones' on-device stores (R-WEB-CLONE-PROGRESS-NS-UNIQUE; 2026-07-19)

**Every `/play/<app>` clone's PRIMARY progress namespace — the `makeProgress('<ns>')` value, which keys the on-device store at `localStorage['<ns>.progress.v1']` and is read by `<MasteryProgress>` (axis 8), the practice-scheduling review (axis 7), and `<ProgressReport>` (axis 10) — MUST be GLOBALLY UNIQUE across the whole fleet. Two clones sharing one namespace write the SAME localStorage key, so their per-kit progress / mastery / XP / streak / report COMMINGLE — a real on-device data-corruption bug (clone A's kit results pollute clone B's mastery + report, and vice-versa). A duplicate namespace is a defect on the same footing as a dark route.** Codified after the axis-10 rollout surfaced **11 pre-existing collision groups** (e.g. `gf` shared by grammarforge/geometryforge/gridforge; `dq` by dancequest/deducequest/discretequest; `cf`/`df`/`eq`/`lf`/`pq`/`rr`/`sl`/`spl`/`tt` each by a pair) — each had been silently commingling since those clones shipped.

**The gate (build-time + PR-CI, mirroring `R-WEB-CLONE-GRADE-LEVEL`'s two-layer model):** `scripts/check-play-namespace-unique.mjs` scans every clone's `progress.ts` for its primary `makeProgress('ns')` (ignoring `*-mech` secondary stores), FAILS the build on any namespace used by >1 clone, AND cross-checks that the clone's `<MasteryProgress>`/`<ProgressReport>` `namespace=` matches its `makeProgress` value (a mismatch = the surface reads the wrong store). Wired into **`prebuild` + `prebuild:play`** (the Cloudflare build) AND a **Vitest PR-CI sibling** `src/data/play/namespace-unique.test.ts` (so a collision fails the PR, not just the deploy — the load-bearing "a prebuild-only gate is invisible to PR CI" lesson from `R-WEB-CLONE-GRADE-LEVEL`).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Learner AGENCY is the 12th expansion axis — meaningful CHOICE (autonomy-support) + an explicit AAR loop, ON-DEVICE + calm-rails, that COMPOSES the existing axes (does not rebuild them) (R-WEB-CLONE-AGENCY; 2026-07-19)

**A `/play/<app>` clone's EXPANSION includes a distinct 12th axis — LEARNER AGENCY: developing the learner's agentic capacity (Bandura's four properties via the OECD Anticipation-Action-Reflection loop) by giving them REAL, learning-RELEVANT CHOICE over what/how to learn next + threading goal→choose→predict/act→self-assess/reflect into ONE learner-directed, on-device, calm-rails loop. Its scope is DELIBERATELY NARROW + honest-yield: agency is MOSTLY ALREADY OWNED by the LIVE axes — forethought/goal-setting by axis-8 (learner-set goals), anticipation by POE, self-reactiveness by PolyaScaffold, self-reflectiveness by DIR/FEDC reflection + the self-explanation fold — so this axis adds ONLY the un-owned MEANINGFUL-CHOICE lever + the AAR orchestration, and it COMPOSES (never rebuilds) the others. A clone that ships a decorative/irrelevant "choice," a system that auto-drives the path under an agency label, or an agency surface on the active solve-path is a defect.** Codified per founder-greenlight 2026-07-19 ("everything is approved") on the evidence in `Docs/RESEARCH_WEB_CLONE_EXPANSION_AGENCY_AXIS_2026-07-19.md` (ADR-048 Decision 12). Sibling to axis-7 (§ R-WEB-CLONE-PRACTICE-SCHEDULING) + axis-8 (§ R-WEB-CLONE-MASTERY-PROGRESSION) — same on-device / calm-rails / compose-shared-shell shape.

**The loop (build/audit against these — all at SESSION BOUNDARIES, never the solve path):** (a) **INTENTION** — learner sets/confirms a learning goal (reuse axis-8's learner-set goal; prefer a *learning* goal for complex material — Locke & Latham); (b) **CHOICE** — learner picks the next activity / representation (CRA rung) / difficulty / path from a REAL, learning-relevant menu (**the un-owned lever** — Schneider et al. 2018: choice causally raises retention+transfer in digital media, mediated by perceived autonomy, ONLY for learning-relevant choices); (c) **ACT** — the chosen surface runs UNCHANGED (predict-then-act where a POE surface supports it); (d) **REFLECT** — a boundary self-assessment against the learner's OWN goal (reuse DIR/FEDC reflection + the self-explanation fold; self-assessment d≈0.78 on performance), feeding the next INTENTION (loop closes — OECD AAR).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## A board/strategy-game clone = PURE engine + Vitest-pinned + a GRADED HEURISTIC AI (not a strong solver) + engine-verified puzzle legality (R-WEB-CLONE-BOARD-GAME-ENGINE; 2026-07-16)

**When a `/play/<app>` clone ships a real playable board/strategy game (chess/draughts/Connect-4/Reversi/Gomoku/Hex/Dots-&-Boxes/backgammon/…), build it as a PURE, exported engine (`legalMoves`/`applyMove`/`winner`/`chooseMove` — no DOM) with a Vitest invariant spec, mounted by a thin `run<Game>()` UI; the AI opponent is a GRADED HEURISTIC sized to be a credible kid opponent, NOT a strong/perfect solver; and any position-PUZZLE surface's stated solution is cross-checked LEGAL against that same engine by the Vitest suite.** This consolidates the pattern proven across the strategy/board clones (chess-puzzle legality precedent → CrownTales draughts + Find-the-Shot, GridForge's five games + transfer POE, V270 #3/#4) into one entry-point so the next board-game-clone author doesn't re-derive it. It does NOT replace the per-axis rules — it ties them together.

- **Pure engine + Vitest (joins R-WEB-CLONE-TEST):** the rules engine is a pure module (exported for tests, DOM-free); its invariant spec asserts the mechanic (win/legal-move/capture/flip/connection/parity), not just "renders." A bespoke board game with no engine-invariant spec is a gap (same weight as a missing parity axis).
- **Graded heuristic AI, not a solver:** match the search to the branching — negamax+alpha-beta for small trees (Connect-4, draughts), a 1-ply threat heuristic for large branching (Gomoku), positional-weight for Reversi, chain-aware sacrifice/double-cross for Dots-&-Boxes, Dijkstra connection-distance for Hex. Expose a Gentle/Steady/Sharp difficulty where the game supports depth. Credible-for-kids + snappy beats optimal; a Vitest test asserts `chooseMove ∈ legalMoves` (+ takes an immediate win / blocks an immediate loss).
- **Engine-verified puzzle legality is NECESSARY-NOT-SUFFICIENT — the solution's CORRECTNESS (best + winning + non-naive) must be engine-verified too (R-WEB-CLONE-PUZZLE-ENGINE-VERIFIED; 2026-07-17, GambitTales).** A position-puzzle bank (e.g. CrownTales Find the Shot) is Vitest-pinned by importing the engine and asserting each `correctMove ∈ legalMoves(position)` — an illegal "solution" fails the build. **BUT legality (and even a structural "is it a fork?" check) is BLIND to whether the solution is a GOOD puzzle**, and that gap shipped a bank where **63 of 119 GambitTales tactics were defective**: the tactical piece landed on a square the enemy defended → it just **hung** (solution loses material); the "tactic" **won nothing** (the attacked piece simply escaped); or a **simpler free capture won as much** → the tactic was **naive/pointless** (the founder's exact report: "the rook can just take the bishop for free"). So a position-puzzle bank MUST additionally be Vitest-pinned by a **quiescence-aware search** (negamax over the same engine model) asserting the intended solution is a **clean, BEST, non-trivial material win (or forced mate)**: (a) not < any legal alternative by > ~40cp (not suboptimal / doesn't hang), (b) nets ≥ ~a minor over the start eval or forces mate (actually wins something), (c) no non-solution immediate capture of ≥ a minor scores as high (not replaceable by "just take the free piece"). This gate is cheap (depth-4 + quiescence over sparse positions ≈ 7s for 119 puzzles) and PROVEN meaningful (65 defects flagged on the old bank, 0 on the fixed one). Author verified banks with a **deterministic, engine-verified GENERATOR** (seeded PRNG → reproduces the shipped bank; reference: hub `scripts/gen_gambittales_puzzles.mjs`) rather than hand-constructing sparse positions (the hand-authored bank is exactly how the 53% defect rate happened — a coincidentally-guarded tactical square or a free escape is invisible without a search). Reference: `spark-anvil-site/src/lib/play/gambittales/puzzles.test.ts` (the material-correctness gate) + `Docs/AUDIT_GAMBITTALES_PUZZLE_CORRECTNESS_2026-07-17.md`.
- **Board rendering is dark-mode-safe by construction (joins R-WEB-CLONE-DARK-MODE-SUPPORT + R-WEB-CLONE-MANIPULATIVE-PROMINENCE):** the checkerboard/grid TONE is `color-mix(in oklab, var(--pc-select) N%, var(--ff-paper))` (NOT `--ff-warm` vs `--ff-paper`, ~3% apart → washes out); discs/stones carry a saturated fill with a `var(--ff-outline)` rim so they read on BOTH light and dark boards; the stage stays quiet (no `background-image`, no ambient motion), colour rides the pieces. Verified by the mandatory dark+light screenshot-DoD (R-WEB-CLONE-SCREENSHOT-DOD).
- **Spawn-app board clones are the maximal web-pioneer case** (R-WEB-CLONE-SPAWN-TRACKED): every game engine + the transfer/puzzle surface is web-pioneered → a filed `HANDOFF_FROM_HUB_<FEATURE>_WEB_BACKPORT.md` (related engines may share ONE consolidated handoff — GridForge's five engines rode one) + a 🟡 ledger row; a shared **turn-based board-game engine** across GambitTales/DealTales/CrownTales/GridForge is a candidate ForgeKit lift (propose via handoff; hub never writes Swift).
- **Native two-human HOTSEAT (pass-and-play) is an ADDITIVE `{ mode?: 'ai' | 'hotseat' }` param over an EXISTING playable `run<Game>` — and its LOAD-BEARING PRECONDITION is that such a playable vs-AI game loop actually EXISTS in the clone; VERIFY that before applying the recipe, because a handoff's "board-engine clone" label is NOT proof (2026-07-18, Logic-hotseat next-pass).** The reusable recipe (default `'ai'` keeps the shipped AI path byte-identical; the `hotseat` branch drops the `turn==='you'` clickability clause + applies for the current turn + no AI call/`setTimeout`, honoring each game's special turn logic; palette-accurate PII-free "Player 1/2" seats; **a HIDDEN-information game — Mastermind/Battleship — DOES need a privacy curtain, unlike perfect-information boards which don't**; dark-safe pieces; one picker/toggle + landing link; full dark+light×desktop+mobile screenshot-DoD) applies ONLY when the clone has a real playable game loop (`applyMove`/`legalMoves`/`winner`/`chooseMove` + an AI turn) to add the param to. **Many "board" clones DON'T** — their `engine.ts` is a PURE RULES ENGINE feeding SINGLE-SOLVER puzzle surfaces (a Board Reader `studio`, a find-the-move `tactics`, an odds POE), with NO game loop and NO AI opponent. There, native hotseat is either **⛔ WAIVED (single-solver, no board to alternate over — document it)** OR a **FROM-SCRATCH new game UI = its own sized wave, NOT the additive recipe** — assess build-vs-⛔ per clone; the pass-1 MC-quiz Duel + room already cover the together/social axis regardless. Reference verify-before-action outcomes (2026-07-18): ✅ deducequest (Mastermind `scoreGuess` → real codemaker↔codebreaker hotseat + privacy curtain, site PR #892) · ⛔ strategyforge/dealtales/tableforge/sleuthlab (no playable board loop — `Docs/web/<app>/AUDIT_WEB_CLONE_EXPANSION_<app>_HOTSEAT_2026-07-18.md`) · pipquest = a from-scratch backgammon UI (pure `legalPlays`, no game loop — flagged, not the additive recipe).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## A ported LEVEL/PROGRAM bank is FILTERED to provably-solvable + Vitest-pinned; a block-coding clone is a HAND-WRITTEN deterministic interpreter, never a JS eval (R-WEB-CLONE-PORTED-PUZZLE-SOLVABILITY; 2026-07-16)

**When a `/play` clone ports a LEVEL / MAZE / program-execution bank from its iOS app (grid puzzles, robot-programming levels, any bank with a "is this solvable?" property), the porter MUST filter the bank to PROVABLY-SOLVABLE entries with a solver (BFS over the state space) + pin solvability with a Vitest invariant, and any excluded malformed source entry MUST be documented in the parity ledger — never shipped. AND: a block-coding / robot-command clone's execution engine is a PURE, HAND-WRITTEN deterministic interpreter (exported for Vitest), NEVER a JS `eval` / `Function()`.** This is the LEVEL/execution sibling of R-WEB-CLONE-BOARD-GAME-ENGINE's "engine-verified puzzle legality" (that rule pins a position-puzzle's `correctMove ∈ legalMoves`; this pins a whole level as *reachable* + the interpreter as *faithful + safe*). Codified from the CodeRealm build (2026-07-16), where **6 of 30 shipped iOS levels were malformed** — Bit starts walled-in / the goal is unreachable via the builder's forward+turn palette — and would have shipped as **unplayable-but-green** clones (they build, smoke-pass, and *look* fine; only a solver catches them). This is the DATA-level form of the R-WEB-CLONE-SCREENSHOT-DOD "looks-right-but-unplayable" trap: the eye can miss an unsolvable grid, a BFS cannot.

**The load-bearing invariants (author + review against these):**
1. **Solver-filter in the porter.** The porter runs a solver (BFS over `(x,y,facing)` for a maze; the appropriate reachability check for the mechanic) and emits ONLY solvable entries. A malformed source entry is *excluded + logged*, not shipped. Reference: `port_coderealm_kits_to_web.py` `_solvable()` (excluded `sm_05 sm_06 ll_04 ll_07 ll_09 cc_02`).
2. **Vitest pins it.** A `every ported level is solvable + well-formed` invariant re-runs the solver over the shipped bank (tiles length = w·h, start in-bounds + not on a wall, goal present, BFS reaches it) — so a future re-port can't silently ship an unsolvable level. Reference: `src/lib/play/coderealm/coderealm.test.ts`.
3. **Document the exclusion** in `PARITY_WEB_VS_IOS.md` (an ⛔ excluded-with-rationale row, not a silent drop) — the source app's own bug is disclosed, not hidden.
4. **The interpreter is PURE + HAND-WRITTEN + never `eval`.** Port the iOS execution semantics verbatim (coords, facing/rotation table, wall/goal rules, an iteration guard mirroring the iOS `maxIterations` infinite-loop trip) into a DOM-free module returning a step trace the UI animates. On-device + deterministic + safe is the whole point; a JS `eval` of learner input is a security + determinism defect. Reference: `program.ts` (faithful port of `ProgramExecutor`+`WorldState`+`turned()`).
5. **A hand-authored puzzle bank derived from the engine is engine-CROSS-CHECKED** (the R-WEB-CLONE-BOARD-GAME-ENGINE precedent): e.g. a Debug-It "fix the one block" bank asserts, per puzzle, that `run(buggy)` fails, `run(buggy with fix)` reaches the goal, and `correct ∈ options`. Reference: CodeRealm Debug-It bank + its Vitest cross-check.
6. **Peel-back to real code, when the source app has it** (blocks → the actual language): port the block→source mapping (CodeRealm `CodeBlock.swiftCode` → the "Show Swift" panel) — it's a genuine UI/UX-parity feature (🔄 adapted), and fewest-blocks grading rides the ported `optimalBlockCount`.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Every clone declares a GRADE BAND + LEVEL, shown on /play and sorted within its cluster (R-WEB-CLONE-GRADE-LEVEL; 2026-07-13)

**Every `/play/<app>` clone MUST declare a grade band + a level in its per-app registry entry (`src/data/play/<app>/clone.meta.ts`), the `/play` index MUST render a grade-band + level chip on each clone card, and clones MUST be sorted within each subject/cluster section by grade band then level (youngest/easiest first).** Codified per founder-direct 2026-07-13 (*"add grade band and level for each web clone on the /play page and sort the web clones by level grade bands for each subject/cluster"* + *"codify the grade band and level rule for all future web clone builds"*). Standing requirement for **every** clone — current (backfill) AND all future builds.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## The hub agent CLASSIFIES a clone's /play cluster by curricular judgment — free-text keyword matching is a fallback, not the source of truth (R-WEB-CLONE-CLUSTER-MAP; 2026-07-14)

**A `/play` clone's subject-cluster grouping (the section it renders under on the `/play` index) is a CURRICULAR CLASSIFICATION the hub agent makes IN-SESSION — recorded explicitly, not left to fragile free-text keyword matching.** The `/play` index groups clones into a fixed pedagogical cluster set — **9 clusters as of V288 (2026-07-17): Math · English & Language Arts · Science · Computer Science · Logic & Puzzles · Social Studies · SEL · Visual Arts & Design · Music & Performing Arts** (the V288 reorg added Computer Science [CSTA] and split the overloaded "Create" → Visual Arts & Design + Music & Performing Arts [National Core Arts]; see `RESEARCH_WEB_CLONE_SUBJECT_TAXONOMY_2026-07-16.md` + `AUDIT_WEB_CLONE_SUBJECT_REORG_2026-07-16.md`). The 2026-07-14 narrative below references the pre-V288 7-cluster set (…SEL · **Create**); the order-is-load-bearing principle it establishes is unchanged — it now applies to the new branches (see the ordering note at the end of this rule). Codified per founder-direct 2026-07-14 (*"a couple of english language arts web clones are grouped in the Create cluster … do full audit and fix all the groupings and codify"* + *"should we codify a rule saying that the hub agent must use in-session Opus to classify the web clone for grouping?"* → yes).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## `/play` splits into THREE age-band zones — Ages 3–5 · 6–8 · 9–14 — before subject clusters (R-WEB-CLONE-AGE-BAND-ZONES, formerly R-WEB-CLONE-YOUNGER-CLUSTER-SPLIT; 3-band reband 2026-07-18, ADR-052)

**The `/play` catalog splits by AGE BAND at the top level into THREE zones, rendered top-to-bottom — `Ages 3–5` (Pre-K/K) → `Ages 6–8` (grades 1–3, early elementary) → `Ages 9–14` (grades 4–8, the tween core; no clone exceeds grade 8) — each a labeled band with a divider. The 3–5 and 6–8 zones are subject-MINIMAL (flat, subject as a card badge); the 9–14 zone keeps its 9 subject clusters + youngest-first sort. A clone rendered in the wrong age zone — especially a grade-1–3 clone (incl. grade 3: ReadRise/TimesQuest) intermixed into the 9–14 subject clusters — is a defect.** Rebanded per founder-direct 2026-07-18 (*"rethink the age bands … 3-5 and 6-8 and 9-14 … fix it for the whole portfolio hub and website too and codify"*, ADR-052), superseding the 2-band (5–8 younger / 9–14 tween) model + the ad-hoc grade-3 bridge placement. This sits ABOVE `R-WEB-CLONE-CLUSTER-MAP` (subject grouping) — age is the FIRST split, subject the second (within 9–14).

**Why (deep-web-researched — `Docs/RESEARCH_AGE_BAND_TAXONOMY_2026-07-18.md` + `RESEARCH_PLAY_YOUNGER_CLUSTER_SEPARATION_2026-07-16.md`):** the three-band split (3–5 / 6–8 / 9–12→14) is the canonical children's-app taxonomy AND the NAEYC early-childhood banding (Preschoolers 3–5 · Primary/Early-grades 6–8/K–3) mapped onto Piaget (preoperational 2–7 · concrete-operational 7–11 · formal-operational 11+). Early childhood runs **through age 8**, so **grade 3 (age 8) belongs in the 6–8 band**, not bridged into 9–14 — which is the fix for the grade-3-clones-are-hard-to-find incident. Children also react negatively to a catalog that mixes their band with an older one, so age is the decisive first grouping.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## The deep-research step MUST yield an explicit backport-candidate list — mined CROSS-PLATFORM, "strict port" is earned, never assumed (R-WEB-CLONE-BACKPORT-MINING; 2026-07-11)

**The Phase-2 deep research (`WEB_CLONE_PICKUP_RUNBOOK` § 3.2b) is the designated "well for novel features," and its source landscape is CROSS-PLATFORM — web + iOS + Android + physical/board-game/research — NOT web-only. Every clone's `RESEARCH.md` MUST carry a `## Domain landscape` survey (of the best-in-class in the domain across ALL those surfaces) ending in an explicit, evidence-based `## Backport candidates` list — the best learning-relevant ideas OUR apps (iOS AND web) LACK — and classify EACH one. A conclusion of "strict port → no backport" is VALID ONLY after that list exists and every candidate is classified; it must be EARNED by the mining, NEVER asserted by default.** Codified per user-direct 2026-07-11 (*"the deep web research step should have provided a lot of novel ideas for iOS backport, correct?"* → *"codify this requirement"*; then *"why are we doing deep web research for web-based novel features only? why not including novel features and ideas from ios and android apps too?"* → *"make sure to backfill and also codify it as a rule too"*), after the V95/V97/V98 clones (claimcraft/jestforge/witquest) each defaulted to "strict port" and skipped producing the candidate list — using the research only for positioning, not for its load-bearing backport-discovery purpose — AND after the mining was found to be artificially scoped to the *browser* landscape only.

→ **Sub-rules** defined here (full detail in reference): (R-WEB-CLONE-TRACK-B-BUILD-DEFAULT).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Missing question kits are AUTHORED by in-session Opus to match the portfolio — never skipped, never Gemini-gen (R-WEB-CLONE-KITS-OPUS-AUTHOR; 2026-07-14)

**When a clone's source app has NO question-kit banks (a composition-only app, a docs-only app with unwritten kits, or any app lacking the portfolio-standard 16×25 MC set), the kits are AUTHORED FRESH by the in-session Opus model (the running Claude Code session) to match the other portfolio apps — a full 16 kits × 25 = 400 MC items — NOT skipped, NOT waived as "bespoke-only," and NOT generated by Gemini.** Codified per founder-direct 2026-07-14 (*"you build the question kits and ship them too"* + *"ship the question kits to the ios app repo too"* + *"codify the rule that if question kits are missing, use the in-session Opus to author them to match other portfolio apps"*). This **supersedes** the earlier "a composition-only app is an all-bespoke clone with no MC Concepts surface (⛔-waived, HaikuQuest precedent)" posture — the portfolio standard is that **every** clone has a Concepts MC surface, and a missing bank is an *authoring task*, not a waiver.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Younger-cluster (ages 5-8) apps are EXEMPT from the 16×25 MC-kit obligation — activity-based formats, not multiple-choice banks (R-YOUNGER-CLUSTER-NO-MC-KITS; 2026-07-14)

**The portfolio-standard 16 kits × 25 = 400 CCSS-tagged, Bloom-leveled, TEXT multiple-choice bank MUST NOT be authored for younger-cluster (ages 5-8 / K-2) apps. It is the documented, research-backed ⛔ EXCEPTION to `R-WEB-CLONE-KITS-OPUS-AUTHOR`** — a younger-cluster app with no `kit_*.json` is NOT a coverage gap, and authoring one would ship a developmentally-inappropriate, low-validity surface. Younger-cluster apps use **audio-first, low-text, manipulative/tap/drag** activity formats instead. Codified per founder-direct 2026-07-14 (*"should the younger cluster app repos have the question kits? … codify the research-backed evidence"*), full evidence in `Docs/RESEARCH_YOUNGER_CLUSTER_QUESTION_KITS_2026-07-14.md`.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## No feature may ship dark — every clone route + novel feature must be wired + visible (R-WEB-CLONE-NO-DARK-SURFACE; 2026-07-11)

**A `/play/<app>` clone is NOT done until EVERY route AND every novel/web-pioneered feature it ships is REACHABLE + VISIBLE to a user — linked from the landing (or from another linked, reachable surface) — and the clone has its `src/data/play/clones.ts` registry row. A surface that exists in the code but no user can navigate to is *shipped-but-dark* and is a defect.** This is the web-clone analogue of the portfolio **Asset Consumer Audit** (`.claude/rules/portfolio.md` § "registered ≠ wired") and the DN **authored ≠ integrated** discipline (`R-CAST-EXPANSION-INTEGRATION`): building the feature is the START of the obligation, wiring it into the user's navigable path is the completion. Codified per user-direct 2026-07-11 (*"how do we make sure all the features including novel features are wired and visible to the users and not remaining dark? do full audit and backfill wiring if needed. codify these too"*).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Every clone must tightly integrate the DN narrative assets — mascot, cast portraits, storybooks, audio dramas, DIR/FEDC reflection (R-WEB-CLONE-NARRATIVE-INTEGRATION; 2026-07-11)

**Every `/play/<app>` clone landing MUST surface the portfolio's Distributed-Narrative assets — the app MASCOT, the CAST PORTRAITS, a link from each cast member to their illustrated T1/T2 multi-beat STORYBOOK + AUDIO DRAMA, and a between-practice DIR/FEDC affect-recognition REFLECTION — not a bare cast name-list.** A clone that ports the learning kits but leaves the mascot, portraits, storybooks, and audio dramas dark is only half-built: the DN thesis is *"the cast IS the curriculum"* (Naul+Liu empathetic-characters + distributed-narrative axes), so the characters + their stories are load-bearing motivation, not decoration. Codified per user-direct 2026-07-11 (*"why the mascot illustrations, cast characters portraits, t1/t2 multi-beat storybooks with illustrations, audio dramas are not tightly integrated with the web clones? … and dir/fedc reflections too … fix for all shipped web clones and codify as a rule"*).

**DN-S is a BASELINE + a DEPTH FOLD, NOT a new expansion axis (2026-07-18 assessment).** Founder asked whether to add a "DN-S axis" to the expansion playbook; the audit + deep-web-research answer (`RESEARCH_WEB_CLONE_DN_S_AXIS_ASSESSMENT_2026-07-18.md`) is NO co-equal axis: the **surfacing above is the BASELINE** (this rule, auto-surfaced by `<PlayNarrative>` + enforced by the surface-wiring audit — every clone inherits it, nothing per-clone to grow), and the one genuine per-clone DEPTH gap is a **DEPTH FOLD**, not a growth axis. **Evidence is favorable but bounded:** recurring, familiar, intrinsically-integrated characters *reduce* working-memory load (they are NOT a seductive detail) — but only while **boundary-placed + integrated**; front-loaded / high-load / critical-path narrative carries the seductive-details penalty (g≈−0.16). So the DN ratchet is DEPTH (richer boundary integration), never "surface MORE narrative on screen." **The buildable DEPTH FOLD = between-practice cast CAMEOS (iOS Move B `castCameos[]` web parity):** a boundary-only (kit-preview / results) cameo surface, mastery-keyed variant, honoring `R-NARRATIVE-BETWEEN-NOT-DURING` + `R-GUARD-THE-RATIO` + `R-DN-PARITY` (swap test) — the schematic active-solve loop stays cameo-free. A web between-practice cameo iOS-parity of Move B is web-pioneered-surfacing → a `castCameos` parity note. The Phase-1(k) DN-S lens (`PLAYBOOK_WEB_CLONE_EXPANSION.md`) audits: surfacing-baseline present · between-practice cameo wired · `/play`↔`/story` bidirectional complete. (The founder MAY elevate DN-S depth to a formally-numbered axis for visibility; the build deliverable — boundary cameos — is identical either way.)

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Web-clone user + developer guides must track the code (R-WEB-CLONE-GUIDE-SYNC; 2026-07-08)

**Every `/play/<app>` web clone has TWO living guides that MUST be updated in the SAME change-set as any code change that affects what they document — a visitor-facing USER guide and a maintainer-facing DEVELOPER guide.** A code change that lands without the matching guide update is incomplete, exactly like a cross-repo PR that ships without verifying the merge. Codified per user-direct 2026-07-08 (*"codify the requirement that user guide and developer guide for the web clone of fractionforge be kept up-to-date with the web clone code"*). Follows the precedent set by the `/cast` page guides (`GUIDE_CAST_PAGE_USER.md` + `GUIDE_CAST_PAGE_DEVELOPER.md`).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

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

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

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

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Tech stack (locked in)

- **Static site generator**: Astro 4.x (per `DECISION_FIGMA_FOR_SPARK_ANVIL_WEBSITE.md` + `PLAN_SPARK_ANVIL_WEBSITE.md`)
- **Styling**: Tailwind CSS with token-mapped brand palette (`tailwind.config.js` defines `forge`, `anvil`, `spark`, `warm`, `slate`)
- **Hosting**: Cloudflare Workers (static assets, via Workers Builds Git integration; migrated from Cloudflare Pages)
- **Analytics**: Plausible (privacy-first, no cookies, COPPA-safe)
- **Forms**: Formspree or Netlify Forms (press contact, parent feedback)
- **No third-party SDKs** — preserves the "no tracking, no kid data leaves the device" trust signal

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Design workflow (locked in)

- **No Figma for v1** — code-first; Astro + Tailwind authored via Claude Code / Cursor; iterate in browser DevTools; Cloudflare Workers per-version preview deploys for review (per `DECISION_FIGMA_FOR_SPARK_ANVIL_WEBSITE.md`)
- Brand palette doc + logo PNGs + per-app CLAUDE.md = the spec. No parallel design artifacts.

Revisit if: designer joins team, marketing landing page needs novel composition, press-kit / Apple Design Award submission requires pixel-precision.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

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

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

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

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

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

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## DN-S chapter-book pages (Wave 1 SHIPPED 2026-06-02; spark-anvil-site PRs #104 + #105)

The site now ships **663 illustrated chapter-book pages** at `/cast/<app>/<char>` + `/stories` aggregate index. Per `Docs/PLAN_DN_S_WEBSITE_WAVE_1_2026-06-02.md` + `Docs/ADR-022_DN_S_WEBSITE_WAVE_1_OPEN_QUESTIONS.md`. Editing rules below:

→ **Sub-rules** defined here (full detail in reference): (R-PREBUILD-PLAY-NORMALIZE).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## The site is a multi-UNIT build split — one Astro repo, many deploy units behind a path-routing dispatcher (R-SITE-BUILD-SPLIT; 2026-07-10)

**The `spark-anvil-site` repo is ONE Astro project that builds into MULTIPLE independent Cloudflare deploy units, fronted by a single host-agnostic dispatcher Worker that routes purely by URL path.** This is the load-bearing architecture behind the `/play` clones, the `.org`/`.com` dual-serve, and the (planned) per-cluster + cast/chapters carve-outs. It is codified here — not only in `ADR-032` — because every session loads the rules file, and a decision doc "decays in visibility" (workflow.md § Audit-to-canonical-propagation). ADR-032 is the full decision + rationale; THIS is the standing convention.

→ **Sub-rules** defined here (full detail in reference): (R-SITE-DOMAINS).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Automate the build-time fix via native caching — NOT hand-rolled units or dashboard work (R-SITE-BUILD-AUTOMATION; 2026-07-20)

**The core-build bottleneck (prerendering ~1,981 routes, ~90% of them the 1,776 cast/chapter pages) is attacked by AUTOMATION in a fixed priority order, and the site stays SSG-first. Do NOT hand-roll another per-unit relocate script (like `build-play.mjs`) and do NOT create Cloudflare build units by dashboard clicking — both are superseded by the levers below.** Codified per founder-direct 2026-07-20 (deep-web-researched: `RESEARCH_BUILD_AUTOMATION_ASTRO5_UPGRADE_2026-07-20.md` + `RESEARCH_SSG_VS_SSR_ARCHITECTURE_2026-07-20.md`). Keep SSG (no wholesale SSR — our pages have no per-user data, so SSR only relocates the render build→first-request at added cost; `RESEARCH_SSG_VS_SSR`).

**The decision tree (do in order; stop when builds are fast enough):**
1. **Astro 5 Content-Layer incremental caching — the primary automated fix. ✅ EXECUTED 2026-07-20 (site PRs #1101 Stage A + #1102 Stage B).** The **Astro 4.16→5** upgrade shipped in two staged, worktree-proven PRs: **Stage A** (`astro ^4.16.18→^5` [5.18.2] + `@astrojs/cloudflare 11→^12` [12.6.13] + `output:"hybrid"→"static"` + `legacy.collections:true` bridge + `engines.node>=18.17.1`; `@astrojs/tailwind`/`@vite-pwa/astro` already peered ^5 — no bump) and **Stage B** (moved `src/content/config.ts` → **`src/content.config.ts`** with a `glob()` loader for the ONE `chapters` collection; `entry.render()`→`render(entry)`; dropped `legacy.collections`). **⚠ MEASURED reality — NOT the docs-site −92%:** the full local core build went ~5.5–7.5 min (Astro-4 CF baseline) → **~3 min** (Stage-B cold 199s / warm 177s; astro-build 110s→85s; content-ingest 43s→31s) = a real **~2×** win, but far short of −92% because (a) the docs-site number was **content-INGEST-only** and (b) **native per-route incremental PRERENDER is still an open Astro roadmap item** (the dominant cost — generating 3,922 HTML — is NOT cached), and (c) our prebuild normalizer + strip rewrite the chapters that are committed in RAW form (~1,880 necessary writes/build) — but this does NOT materially bust the cache (see the ⚠ correction below). Output is byte-identical (7,427 paths / 3,922 HTML, link-check OK). `getCollection` order is now non-deterministic — `story/index` already sorts explicitly, other sites iterate/filter (order-safe); **`entry.id` LOST the `.md` extension** under the glob loader (was `<app>/<char>.md`, now `<app>/<char>`) → every `.endsWith('-advanced.md')` / exact-`.md` match was fixed (`.replace('.md','')` calls are safe no-ops post-migration). The 6 chapter scripts + normalizer read raw MD via `fs` (not `astro:content`) → unaffected. **Cloudflare Workers Builds `build_caching_enabled` is ALREADY on** (both units) — it compounds. **⚠ CF-BUILD OOM (load-bearing, site #1101 build `a68cbfb0`):** Astro 5's **client (vite) build** OOM'd the Cloudflare build container — `FATAL ERROR: JavaScript heap out of memory` at the **~2 GB default V8 heap** — on the full ~3,922-route CORE build (the server build finished; the client transform blew the heap). It surfaced ONLY on CF (local Node 26 had ample RAM), so a green local build does NOT prove the CF deploy. **Fix (hub-owned, ships in the PR): `NODE_OPTIONS=--max-old-space-size=6144` on the `build` + `build:play` npm scripts** (headroom under the 8 GB container). The PLAY unit did NOT OOM (small route subset). Any future big Astro/vite bump: expect this + set the heap. **Node version is HUB-OWNED via a repo-root `.nvmrc` (`22`), NOT account-managed (site #1103→#1104):** CF Workers Builds resolves Node from a version file (`.nvmrc`/`.node-version`, checked first) → else a dashboard `NODE_VERSION` var → and **ignores `package.json` `engines`**. Because we ship a `wrangler.jsonc` (config source-of-truth), a dashboard `NODE_VERSION` can be IGNORED — so **`.nvmrc` (exact numeric, no `lts/*`) is the reliable pin**, one file for both units, shipped in a PR (no dashboard work). **⚠ The pin MUST satisfy the DEPLOY toolchain, not just Astro — `wrangler@4.x deploy` requires Node ≥ 22.0.0.** `.nvmrc=20` (site #1103) **built green then FAILED `npx wrangler deploy`** (`Wrangler requires at least Node.js v22.0.0`, CF build `13b062dc`) — a build that passes the Astro step can still fail the deploy step on too-low a Node; fixed to `22` (#1104). So pin **`22`** = ≥ wrangler 22 + Astro-6 22.12 + Astro-5 18.17.1 (CF's own default is already ≥22 — a `20` pin actively DOWNGRADED below wrangler's floor). Read the full build log (R-BUILD-FAILURE-READ-FULL-LOG-FIRST) — a "Node broke Astro" guess would have been wrong; the failure was wrangler at the deploy step. **⚠ CORRECTION (investigated 2026-07-20) — the "normalizer skip-unchanged" follow-on was a NON-ISSUE, do NOT chase it:** both `normalize-chapter-frontmatter.py` (`if not changed: return False`) and `strip-chapter-methodology-sections.py` (`if final == original: continue`) ALREADY skip writing unchanged files. The ~1,880 rewrites/build are NECESSARY (chapters are committed in RAW form by design — the app-repo sync brings raw YAML; R-PREBUILD-PLAY-NORMALIZE normalizes at build-time deliberately), not rewrite-unchanged waste. And the content cache SURVIVES those rewrites (Stage-B warm ingest 31s < cold 43s → Astro's glob loader is CONTENT-DIGEST-based, not mtime-based → deterministic normalized output ⇒ same digest ⇒ cache hit regardless of the write). **So the core-build floor is the per-route PRERENDER (~2,000 HTML, not natively incrementally cached), NOT the ingest/normalizer.** Lowering it further needs a bigger, deliberately-deferred change (SSR-tail + Workers-Cache SWR, or CI-build-sharding→single-deploy) — NOT worth it now that the CI dev-loop bottleneck is solved (Ubicloud) and ~6–8 min deploy latency is acceptable.
2. **If build wall-clock is still too slow, ONE automated parallelism path — both dashboard-free:**
   - **No-account, single unit:** CI matrix build-shard → `dist`-merge → one `wrangler deploy` (N GitHub-Actions jobs each build a self-partitioned route shard — Astro has NO native `--shard`, so generalize the play-relocate "keep-subset" into "keep-shard-i/N"; balance by TIME not file-count; merge-then-single-deploy). Changes the deploy model (CF-Builds-on-push → GH-Actions + `wrangler deploy`), NOT the account topology.
   - **Automated MULTI-unit (no dashboard):** a hub `provision-build-unit.py` over the **CF Builds API** (create Worker + connect Git + set build/deploy-`--name`/watch-paths + dispatcher route — the Builds API supports this even though the Terraform provider doesn't, bug #6924) + a **parametric `build-unit.mjs <cluster>` + declarative `site-units.config.mjs`** (never a hand-coded per-unit script). Workers-for-Platforms (dispatch namespace + KV path→cluster routing) is the larger-scale end-state (paid product) — reserve for a high unit count.
3. **Workers Cache (`stale-while-revalidate`)** for any route moved to on-demand (`prerender=false`) — makes SSR "feel static" (mind per-request billing; the Astro CF adapter wires it).
4. **Combine `/play` back into core (drop the split)? — ✅ DECIDED: NO, KEEP THE SPLIT (founder, 2026-07-20).** Astro-5 + the 100k-file Workers limit + the R2 purges *unblocked* consolidation (a single unit now fits + builds ~3 min), so the split's SIZE/BUILD-TIME motivations dissolved — BUT its **deploy-independence** value is actively realized while the clone/cameo/DN-S fleet is the dominant activity (a clone-only change rebuilds the fast ~3-min play unit, not the ~5-8-min core; a core-build hiccup — e.g. an OOM/Node break — can't block clone deploys). Merging would slow every clone change onto the core build to buy already-tamed simplicity → net-negative now. **Keep the two-unit split + dispatcher.** REVISIT only if the fleet goes durably quiet AND the split ops-cost outweighs the fading independence value → then consolidate to ONE unit (+ CI-shard), **never MORE units** (per-cluster / Workers-for-Platforms stays rejected — WfP is multi-tenant; splitting is justified only by team-autonomy, not size — micro-frontend evidence). Full analysis: `RESEARCH_COMBINE_PLAY_CORE_UNITS_2026-07-20.md`.

→ **Sub-rules** defined here (full detail in reference): (R-SITE-REPOS-PRIVATE).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## `build:play` is not a full verification — a core-only lib's syntax error slips past it (R-SITE-CORE-PARSE-GATE; 2026-07-11)

**Verifying a change with `npm run build:play` does NOT prove the CORE build is green — the play unit relocates the `/cast` + chapter routes out of `src/pages/`, so any module imported ONLY by those core routes (e.g. `src/lib/image-url.ts`, `audio-url.ts`, chapter/cast components) is never bundled by `build:play` and its syntax errors go uncaught until the Cloudflare CORE build fails.** Any change that touches a **core-only** lib/component MUST be parse-verified against the core build (a `tsc --noEmit`, a full `npm run build`, or at minimum an `esbuild` transform of the changed file), not just `build:play`. Codified per user-direct 2026-07-11 after a P0: `image-url.ts` broke the core Cloudflare build (`Unexpected "*"`) while every `build:play` verification (mine + the parallel clone agents') stayed green.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## The shared `play.css` tail-append is a merge-collision hotspot — parse-gate it at prebuild (R-PLAY-CSS-PARSE-GATE; 2026-07-12)

**`src/styles/play.css` is a SHARED, tail-appended surface — every `/play/<app>` clone build appends its `.pc-theme-<app>` block to the end under R-PARALLEL-WEB-CLONE-BUILD single-flight — and concurrent clone merges routinely collide on that tail. A botched tail-append conflict resolution that DROPS a closing `}` red-builds the Cloudflare `build:play` with `[postcss] play.css:<EOF>:1: Unclosed block` — a P0 that surfaces ~1.6s deep in vite (after the whole prebuild) with the error line reported at EOF (useless for localizing).** The gate `scripts/check-play-css-parse.mjs` (postcss parse + a brace-balance localizer) is wired into BOTH `prebuild` and `prebuild:play` so this class fails LOUDLY at prebuild with the real unclosed-block line, not deep in the build. Codified per founder-direct 2026-07-12 (*"fix and codify"*) after the V121 P0.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Kill the parallel-fleet merge-races structurally — union-merge the append-only shared surfaces + per-app CSS files (R-WEB-CLONE-MERGE-HYGIENE; 2026-07-12)

**The parallel web-clone fleet's push/merge conflicts come almost entirely from a handful of APPEND-ONLY shared files that every clone touches at the same spot (the tail / the closing bracket). Three structural changes remove the conflicts at the source instead of resolving them by hand every time.** Codified per founder-direct 2026-07-12 (*"there are a lot of push/merge conflicts with all the parallel hub agents. what can we do about it?"*). The reactive discipline (rebase-then-resolve, keep-both, renumber-on-conflict — R-PARALLEL-WEB-CLONE-BUILD / R-PARALLEL-HUB-AGENTS) stays as the fallback, but these make it rarely needed.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## All hub-side `spark-anvil-site` work happens in a throwaway `git worktree` off `origin/main` — never the shared clone (R-SITE-WORKTREE; 2026-07-13)

**Any hub session touching `spark-anvil-site` — building a clone, authoring tests, verifying a build, a docs/rule edit that must compile against the site — MUST work in a fresh `git worktree` checked out from `origin/main`, NOT in the shared `/Volumes/.../spark-anvil-site` working clone.** Codified per founder-direct 2026-07-13 (*"codify the site worktree approach"*) after the shared clone was found 8 commits behind with untracked parallel-session build dirs (a mid-build `heatforge`, a stray `waveforge` lib) that **aborted `git pull --ff-only`** — the exact stale/dirty-shared-clone trap this rule removes.

→ **Sub-rules** defined here (full detail in reference): (R-SITE-LOCAL-BUILD-R2-ENV).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Parallel clone-building — one agent per app, disjoint by construction (R-PARALLEL-WEB-CLONE-BUILD; 2026-07-10)

**Multiple hub agents MAY build multiple `/play/<app>` clones in parallel — a specialization of `R-PARALLEL-HUB-AGENTS` (workflow.md) enabled by ADR-033 per-app namespacing.** Because every clone lives in its own disjoint `src/{pages,lib,data}/play/<app>/` + `public/play/<app>/` + `Docs/web/<app>/` subtree, two agents building different apps touch **zero common files** in the normal path — which designs out the dominant parallel-agent failure mode (shared-hotspot merge conflicts).

> **The single-entry pickup runbook:** an agent (parallel or solo) starting the next clone should read **`Docs/WEB_CLONE_PICKUP_RUNBOOK.md`** — it sequences this rule + the ranking + the 5-phase spawn + the shared-surface single-flight list + the R-WEB-CLONE-PARITY-DOD ship gate + the ship/backport steps + the gotchas (incl. the subagent-scope discipline) into one checklist so nothing is skipped and two agents don't collide.

The discipline:

- **One agent per app, one `git worktree` each** off `origin/main` (R-SITE-BUILD-SPLIT); symlink `node_modules`; no dependency changes in parallel sessions (lockfile churn).
- **R-WEB-CLONE-BUILD-STALE-DEPS — a stale symlinked `node_modules` red-fails `build:play` on ANOTHER clone's dep, not yours.** The build worktree symlinks the MAIN clone's `node_modules`; if a *parallel* session's clone added a new npm dependency after that main clone was last installed, `build:play` fails with **`[vite] Rollup failed to resolve import "<pkg>" from "src/lib/play/<other-app>/*.ts"`** for a package that IS in `package.json` + `package-lock.json` (so Cloudflare `npm ci` builds fine) but is absent from the shared `node_modules`. It is NOT your bug and NOT a broken `main` — it's a stale install. Fix: **`npm install <pkg>@<range-from-package.json> --no-save`** (materializes the declared dep WITHOUT touching the lockfile — verify `git status package.json package-lock.json` stays clean), then re-run `build:play`. Never run bare `npm install` / edit deps in a parallel worktree (lockfile churn — violates the discipline above); `--no-save` only fills the gap. Reference: the 2026-07-12 quillspell Track-B build failed on `cubesensei/net.ts` importing `cubing/twisty` (declared in the lockfile, uninstalled in the stale shared `node_modules`); `npm install cubing@^0.63.3 --no-save` unblocked it. Full runbook step: `WEB_CLONE_PICKUP_RUNBOOK.md` § 2 (Environment).
  - **Companion case — the WHOLE dev toolchain is missing (not just one parallel dep): the shared install is INCOMPLETE / prod-only (2026-07-17).** If `build:play` fails with **`astro: command not found`** (or `check-play-css-parse` reports **postcss not installed**, or a worktree `vitest` config load throws **`ERR_MODULE_NOT_FOUND: Cannot find package 'vitest'`**) and `ls node_modules/.bin/{astro,vitest}` shows them MISSING, the shared `node_modules` was installed **prod-only** (devDeps absent) — a different failure than one-parallel-dep-behind. `--no-save`-per-package is the wrong fix here. Run a **completing `npm install` (no args, no `--save`) in the MAIN clone** — with the existing `package-lock.json` present it reconciles `node_modules` to the lockfile WITHOUT changing deps (verify `git status package.json package-lock.json` stays clean afterward) — then re-symlink/re-run `build:play` + `npx vitest run …` in the worktree. This is the one time a bare `npm install` is correct (it matches the lockfile → no churn); it is NOT the parallel-dep case. Reference: the 2026-07-17 FractionForge tape-diagram build — astro/vitest/postcss all missing from the shared install; a completing `npm install` restored the full toolchain (lockfile unchanged) and unblocked build:play + Vitest + the standalone-dist screenshot-DoD.
  - **Companion case — an `astro.config.mjs`-level dep shows a CONFIG-LOAD error, not a Rollup-resolve error (2026-07-18).** When the missing parallel dep is imported by **`astro.config.mjs` itself** (a build-config plugin, not a clone's `src/lib` — e.g. the ADR-049 PWA work added **`@vite-pwa/astro`**), `build:play` fails EARLIER, at config load, with a DIFFERENT symptom: **`[vite] Failed to load url @vite-pwa/astro (resolved id: @vite-pwa/astro) in …/astro.config.mjs`** + **`Cannot find module '@vite-pwa/astro' imported from …/astro.config.mjs`** + `[astro] Unable to load your Astro config` — NOT the `Rollup failed to resolve import` message above. Same root cause (declared in `package.json`+lockfile, absent from the stale shared `node_modules`), same fix: **`npm install <pkg>@<range-from-package.json> --no-save`** (verify `git status package.json package-lock.json` stays clean), then re-run `build:play`. Do NOT misread the config-load error as a broken `main` or a bad worktree checkout. Reference: the 2026-07-18 ELA axis-7 pass-3 rollout — the just-merged PWA work added `@vite-pwa/astro` to `astro.config.mjs`; `npm install @vite-pwa/astro@^0.5.1 --no-save` unblocked build:play (lockfile unchanged).
  - **Companion case — a MAJOR FRAMEWORK UPGRADE on main + a stale shared `node_modules` → an ADAPTER / CONFIG-VALIDATION error, NOT module-not-found; ALL local `build:play` are broken fleet-wide until reinstall; fix = an ISOLATED worktree `npm ci` (2026-07-20, Astro 4→5).** When a big upgrade lands on `main` (e.g. Astro 4.16→5 + `@astrojs/cloudflare` 11→12 + `@vite-pwa/astro` 1→0.5, PRs #1101/#1102/#1104) it bumps `package.json`+lock, but the SHARED clone's `node_modules` is only reinstalled locally by a human — **Cloudflare `npm ci`'s fresh every deploy, so the deploy is GREEN while every LOCAL `build:play` in the fleet is broken**. The symptom is NOT the `Rollup failed to resolve import` / `command not found` of the cases above — it's a **framework/adapter behavior mismatch**: the config was rewritten for the NEW major (Astro 5's `output: "static"` = the merged-in `hybrid`) but the OLD adapter is what's installed, so config validation throws **`[@astrojs/cloudflare] output: "server" or "hybrid" is required to use this adapter`** at `astro:config:done`. Reading it as "the config is broken / `main` is bad" is the trap — the config is correct for the version on `main`; the INSTALLED version is stale. **Confirm** by comparing declared-vs-installed: `node -e "console.log(require('astro/package.json').version)"` (installed 4.x) vs `package.json` (`^5`). **Fix — do NOT `--no-save`-per-package (many transitive deps changed across a major); give the worktree its OWN isolated `node_modules`: `rm node_modules` (drops the SYMLINK only, not the shared dir) then `npm ci` in the worktree** (R-SITE-WORKTREE dep-worktree exception) — this gets the correct major WITHOUT wiping the shared `node_modules` out from under a concurrent sibling build (a bare `npm ci` in the MAIN clone also fixes it fleet-wide but disrupts any in-flight sibling build → prefer the isolated install when the fleet is active). Reference: the 2026-07-20 StoryPals prek5-clone build — shared `node_modules` was `astro 4.16.19`/`@astrojs/cloudflare 11.2.0` while `main` was `astro ^5`/`cloudflare ^12`; the adapter-static error resolved after an isolated `npm ci` (astro 5.18.2 / cloudflare 12.6.13) in the worktree.
- **Claim the app** in `.claude/CLAIMS.md` before starting (R-PARALLEL-HUB-AGENTS territory claiming); pull the next unclaimed app from `AUDIT_WEB_CLONE_NEXT_RANKING`.
- **Single-flight ONLY the enumerated shared surfaces** — `src/lib/play/_shared/`, `astro.config.mjs`, `package.json build:*`, `src/components/play/`, `REGISTRY_WEB_CLONES.txt`, the work-queue numbers, and the Gemini key (only if a clone gens new assets — clones normally PORT, so this is the exception). Everything else is disjoint and parallelizes freely.
- **Push via the gh Git Data API** (base=main tree-merge → disjoint pushes merge cleanly); **merge PRs sequentially**, update-branch-then-retry on a merge-race (never `--admin` past a real conflict).
- **Scale:** ~4–8 parallel clone-agents (review-bound); a `staging/web-clones-<batch>` branch for large batches; per-cluster build units + Turborepo `affected`/remote-cache as the CI escalation (ADR-033 §4). Full contention table + per-agent workflow + external-research mapping: **`Docs/PLAN_PARALLEL_WEB_CLONE_DEVELOPMENT_2026-07-10.md`**.

→ **Sub-rules** defined here (full detail in reference): (R-SITE-BUILD-QUIET-PRERENDER).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Build-disk budget + R2 media hosting (R-SITE-BUILD-DISK-BUDGET + R-SITE-MEDIA-R2; 2026-06-30)

**The site build has a finite disk budget, and heavy media committed into `public/` is the thing that blows it.** Codified after a 2026-06-30 Cloudflare `ENOSPC: no space left on device` build failure (during Astro `staticBuild` → `generatePath`, writing prerendered HTML). Work-queue § "V28 P0 — Cloudflare Pages build FAIL: ENOSPC".

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Offline / installable PWA is a SITE-WIDE capability, not a per-clone axis — hybrid precache/runtime, persist, never-precache-media, room-MP-stays-online (R-SITE-OFFLINE-PWA; 2026-07-18)

**`spark-and-anvil.com` ships an offline-capable, installable PWA as ONE site-wide shell (service worker + Web App Manifest via `@vite-pwa/astro`/Workbox), NOT as an ADR-048 per-clone expansion axis — and it obeys the caching + degradation + persistence guardrails below. Offline is an ACCESS/DELIVERY baseline (equity / the homework-connectivity gap), inherited by every `/play` clone for free; it teaches nothing new, so it is a portfolio-wide capability like the `R-COGNITIVE-ACCESSIBILITY` `ReadingAccess` backbone — never an expansion lever an agent adds per clone.** Codified per founder-approval 2026-07-18 (ADR-049) on the evidence in `Docs/RESEARCH_SITE_OFFLINE_PWA_2026-07-18.md`; phased rollout in `Docs/PLAN_SITE_OFFLINE_PWA_2026-07-18.md`. **We are the CLEAN case:** prerendered-everything (`output:"hybrid"`, no `prerender=false` → CDN-cached static files; § R-SITE-BUILD-QUIET-PRERENDER) = exactly what Workbox precache wants (NOT the Cloudflare-SSR precaching pitfall), and the `/play` clones are already ~offline by construction (static kit JSON + client-side deterministic engines + no-identifier `localStorage` state).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Diagnose a FAILED build from its ACTUAL error line — never from inference, and never from a TRUNCATED log (R-BUILD-FAILURE-READ-FULL-LOG-FIRST; 2026-07-19)

**When a build FAILS (Cloudflare Workers Builds, CI, or local), the FIRST step is to read the COMPLETE build log and find the actual error/failure line — BEFORE forming any theory about the cause. NEVER infer a build-failure cause from indirect signals (build duration, "killed mid-output", a resource-limit guess, "it OOM'd") or from a TRUNCATED log tail. The error message is authoritative; a theory built on a partial log wastes hours and misdirects the fix (and the money).** Codified per founder 2026-07-19 (*"why you didn't check the build logs before?"* + *"codify this"*).

**The load-bearing gotcha — the Cloudflare Builds API `/logs` endpoint TRUNCATES.** `GET /accounts/{acct}/builds/builds/{uuid}/logs` returns a CAPPED window (often ~2–3k lines, ending mid-*prebuild*), NOT the full log — so reading only that tail can make a **postbuild / late-stage** failure look like an **early-stage OOM/kill** (the log just stops mid-output because the API cut it, not because the process died there). To get the REAL error, do ONE of:
1. **Reproduce locally** — `source ~/.r2-env.sh && npm run build` (R-SITE-LOCAL-BUILD-R2-ENV) and read the actual failing step + its exit. This is usually fastest + definitive.
2. **Get the full dashboard build log** — the Cloudflare dashboard → Workers & Pages → the project → the failed build shows the COMPLETE log (its LAST lines are the real error). Ask the founder to grab it if the API is all you have.
3. **Pull the FULL log from the Builds API by CURSOR-PAGINATING** (2026-07-20 — the API is NOT hopelessly truncated; a single page is, but the cursor pages to completion). A single `GET …/logs` returns a capped window with a `cursor` + `truncated:true`; loop `GET /accounts/{acct}/builds/builds/{uuid}/logs?per_page=200&cursor=<cursor>` until the response `cursor` is empty (last page shows `truncated:false`) — this yields the WHOLE log (this session pulled **11,478 lines over 9 pages** for a failed core build, and its last lines were the real error: `astro build … Complete!` then `postbuild check-site-internal-links.py FAIL — broken /apps/<slug>/mascot.webp`). So "the API truncates" means *one page* truncates — paginate and you get the definitive tail without needing the dashboard.
   - **The working endpoints (read-only; token-verify the account first, R-CLOUDFLARE-SCOPED-DEPLOY):** find the project tag via `GET /accounts/{acct}/workers/scripts` (grep the id); list builds via **`GET /accounts/{acct}/builds/workers/{tag}/builds?per_page=N`** (NOT `/builds/triggers/{uuid}/builds` — that 404s); log via `GET /accounts/{acct}/builds/builds/{build_uuid}/logs`.
   - **🔑 Read `build_outcome`, NOT `status` — `status` is `stopped` for EVERY finished build (success included).** The real signal is the separate **`build_outcome`** field: `success` (deployed) · `fail` (a step exited non-zero — read the log) · `terminated` (superseded/cancelled by a newer push mid-build — the merge-burst amplifier, benign). Judging a build by `status` alone mislabels a `stopped`+`success` as a failure. (This supersedes the older R-SITE-BUILD-SPLIT invariant-7 shorthand "status `stopped` = superseded" — `stopped` is merely *finished*; `build_outcome` says how.)

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## A published chapter's HERO ART ships in the same wave — and an art-less chapter can NEVER break the build OR be silently forgotten (R-CHAPTER-ART-COMPLETION; 2026-07-19)

**Publishing chapter CONTENT (a `src/content/chapters/<app>/<char>.md`, i.e. an app-repo `Docs/dn-s/chapters/` chapter synced to the site, or a DN-S/spawn integration that registers chapter MDs) OBLIGATES shipping that chapter's HERO ILLUSTRATION in the SAME wave. A chapter with content but no hero is not "done" — it is a tracked debt that MUST be drained (generate + distribute the art), never a silent gap. The build is protected so an art-less chapter can NEVER again break it, and the gap is surfaced three ways so it can NEVER be silently forgotten.** Codified per founder-direct 2026-07-19 (*"codify the workflow so that the missing illustrations gen is guaranteed to be picked up and completed"* + *"and not forgotten silently"*), after the V385 younger-3 incident (see § R-BUILD-FAILURE-READ-FULL-LOG-FIRST): a DN-S `/story` integration registered 12 chapter MDs + 12 portraits but generated NO chapter illustrations, so `ChapterIllustration`'s non-multibeat fallback emitted 12 broken `chapter_<char>_opener.webp` links → the postbuild `check-site-internal-links.py` gate failed the WHOLE core build → **every core-page deploy was blocked** (the `/story` age-band selector + all core changes stuck) until the links were fixed.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Missing MULTI-BEAT chapters are a TRACKED backlog, never silently forgotten — a standing coverage queue + build-log signal (R-CHAPTER-MULTIBEAT-COMPLETENESS; 2026-07-20)

**R-MULTIBEAT-DEFAULT makes the 5-beat chapter the forward authoring standard, and the opportunistic-upgrade discipline converts legacy single-beat chapters on-touch — but for a long time NOTHING surfaced HOW MANY chapters were still single-beat, so the conversion backlog was silently forgotten (audit 2026-07-20: 626 of 1,161 T1 chapters — only 46% multi-beat). Every published T1 chapter that is NOT yet multi-beat MUST appear in a standing, committed coverage queue that regenerates every build + logs a build-line — so the backlog (and its drain) is always visible, never silently forgotten.** Codified per founder-direct 2026-07-20 (*"audit for missing … multi-beat chapters. codify so they are [not] silently forgotten"*). This is the multi-beat-coverage sibling of § R-CHAPTER-ART-COMPLETION (hero art) — same anti-silent-forget discipline, the coverage axis.

**The guard (`scripts/build-chapters-pending-multibeat-manifest.mjs`, CORE prebuild):** scans every T1 content chapter + the fresh multibeat manifest (a chapter is "covered" iff it's IN `multibeat-chapters.json` — the same source-of-truth `ChapterIllustration` uses to pick beat-0-hero vs opener, so membership == what actually renders multi-beat, NOT a raw sidecar-file count) and emits the committed **`Docs/REGISTRY_CHAPTERS_PENDING_MULTIBEAT.txt`** pickup queue (its diff surfaces in every content PR as "+N / −N pending multi-beat") + a build-log line on every Cloudflare + local build. A chapter auto-drops from the queue the moment its complete 5-beat set ships. Runs right after `build-chapters-pending-art-manifest.mjs` (both read the fresh manifest).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Slimming `spark-anvil-site` git history — large-push + purge-during-active-content discipline (R-SITE-HISTORY-PURGE; 2026-07-11)

**When rewriting `spark-anvil-site` history to reclaim git bloat (committed regenerable media — see ADR-034), two things are load-bearing and were learned the hard way in the V89 purge (which took the repo 9.13 → 2.84 GiB).** This rule is the standing distillation; ADR-034 + `RUNBOOK_SITE_GIT_HISTORY_PURGE_2026-07-10.md` are the full method, `PLAN_SITE_REPO_FURTHER_REDUCTION_2026-07-11.md` is the remaining-levers roadmap.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

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

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Distribute ≠ upload: audio must reach R2 in the same wave (R-R2-AUDIO-UPLOAD-COMPLETENESS; 2026-07-03)

**The site serves EVERY chapter-narration + audio-drama `.m4a` from Cloudflare R2 (`cdn.spark-and-anvil.com`), NOT from the repo. A content wave that distributes a chapter but forgets to push its `.m4a` to R2 ships a SILENT production 404 — the audio player renders (its `.vtt` is committed) but the audio fails to load, with ZERO build-time signal.** This is the load-bearing companion to R-SITE-MEDIA-R2: that rule says "`git rm` the `.m4a` out of `public/`"; THIS rule says "…but only AFTER it is verified on R2." The two together are the complete discipline; doing the `git rm` without the upload is the exact defect this rule exists to prevent.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Wave-runner idempotency is `.vtt`-present, NOT `.m4a`-present (R-WAVE-RUNNER-R2-IDEMPOTENCY; 2026-07-08)

**A chapter-audio wave runner's "already shipped?" skip-check MUST treat a chapter as shipped when EITHER the local site `.m4a` exists OR the committed site `.vtt` exists — NEVER a bare `[ -f "$site_m4a" ]`.** Post-`R-SITE-MEDIA-R2` the chapter-narration `.m4a` is pruned from `spark-anvil-site/public/` and lives ONLY on R2, so a local-`.m4a`-only test fails for **every** already-shipped chapter, and the runner **over-regenerates all of them** — burning paid Gemini TTS, overwriting the shipped R2 audio take, and desyncing the committed `.vtt` (line-cue timings drift against the new take). This is the idempotency companion to R-SITE-MEDIA-R2 (which does the `git rm`) and R-R2-AUDIO-UPLOAD-COMPLETENESS (which does the upload): those two rules jointly make the `.m4a` R2-only, so the `.vtt` — which STAYS committed — is the durable proxy for "this chapter shipped."

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## R2 is the system-of-record for audio — it MUST be backed up off-R2 (R-R2-SYSTEM-OF-RECORD; 2026-07-07)

**Because R-SITE-MEDIA-R2 `git rm`'d the chapter-narration + audio-drama `.m4a` out of `spark-anvil-site/public/`, Cloudflare R2 (`spark-anvil-books`) is the SYSTEM-OF-RECORD for that audio — not a rebuildable cache. R2 has no automatic backup; a bucket deletion / corruption / accidental lifecycle purge would lose the exact shipped audio take with no one-command restore. Therefore every R2-only `.m4a` MUST have a byte-identical copy committed off-R2 (GitHub).** Codified after the V32 P0 backup audit (`Docs/AUDIT_ASSET_BACKUP_COVERAGE_2026-07-06.md`) proved 0 permanent-loss orphans but surfaced 744 `.m4a` (717 chapter-narration + 27 dramas) whose only copy was on R2 — regenerable from committed text via paid Gemini TTS (~$75–150, and a DIFFERENT voice take with drifted VTT), which is a lossy fallback, **not** a backup.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Cast portrait slug convention (R-CAST-PORTRAIT-SLUG; 2026-06-05)

**The portrait file at `spark-anvil-site/public/cast/<app>/<char>.webp` MUST match the chapter MD filename slug at `src/content/chapters/<app>/<char>.md`.** Both are the same `<char>` token. This is load-bearing because chapter pages at `/cast/<app>/<char>` render `<img src="/cast/<app>/<char>.webp">` with no fallback; Astro static-build doesn't verify `<img src>` targets, so a slug mismatch ships as a silently-broken portrait link with no build-time error.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Chapter front-matter duplicate-key gate (R-CHAPTER-YAML-DUP-KEY; 2026-06-26)

**Chapter MD YAML front-matter MUST NOT have any top-level key listed twice.** js-yaml strict mode (used by Astro's `gray-matter` content-collection loader) rejects duplicate keys with `duplicated mapping key` error → Cloudflare Workers Builds prebuild fails. Closes the V21+ P0 incident class surfaced 2026-06-26 evening (depthquest/trench.md + numbersense/pivot-pia.md both shipped with `gate-allow-text: []` listed twice).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Cast-member route-link coverage (R-CAST-ROUTE-COVERAGE; 2026-06-27)

**Any component or page that renders a `/cast/<app>/<char>` LINK from a cast member MUST guard it with `hasChapter(app, member.name)` AND derive the slug with `chapterSlugFor(app, member.name)` — never `slugChar()` directly, and never an unguarded `chapterSlugFor()`.** A member with no authored chapter has no route; linking to it ships a broken internal link → `check-site-internal-links.py` FAIL → red Cloudflare deploy.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Multi-beat chapter snapshot convention (R-MULTIBEAT-SNAPSHOT; 2026-06-10)

**Multi-beat chapter pages read prose from a SNAPSHOT at `public/chapters/<app>/chapter_<char>.md` — NOT from `src/content/chapters/<app>/<char>.md`.** When the source-of-truth chapter MD is rewritten (e.g., Option C register cleanup, content corrections, register rewrites), **the snapshot must be regenerated alongside the per-beat sidecar + illustrations + audio**, because the sidecar's `prose-range: { from-line, to-line }` indexes against the snapshot's line numbers AND the per-beat audio narration speaks the snapshot's prose.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Path B illustration prompt parity (R-PATH-B-PROMPT-PARITY; 2026-06-11)

**Per-beat illustration prompts in `scripts/pilot_interleaved_ensemble_chapter.py` MUST include (a) chapter prose for the beat's `prose-range`, (b) a character-identity block from the chapter's YAML front-matter + opening passage, AND (c) a per-app `base_style` resolved via `STYLE_REGISTRY`.** The auto-segmenter sidecar's `scene` field is structural metadata, not artistic direction; never use it as the sole content cue.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Pre-distribute anatomy gate (R-ANATOMY-GATE; 2026-06-29)

**Every newly-generated cast artifact (chapter beat / cast portrait / book cover) MUST pass an anatomy-defect gate before distribution, the same way it must pass the text-leak gate.** Sister rule to R-PATH-B-TEXT-LEAK-GATE. Codified after a user-reported defect ("cast character has 3 hands") + the V25 portfolio anatomy sweep (`scripts/audit_image_anatomy.py --all-sweep`), which surfaced glitches the text-leak gate never looked at (e.g. `chanceforge/flipside` — two faces on one head).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Every generated illustration is visually reviewed for UNINTENDED INAPPROPRIATE READINGS — anatomically-suggestive shapes + racial/cultural caricature (R-IMAGE-APPROPRIATENESS; 2026-07-18)

**Every generated character/scene illustration on a kid-facing surface (chapter beat / opener / spot · cast portrait · book cover · mascot · any `/story`, `/cast`, `/play`, or homepage art) MUST be VISUALLY REVIEWED by the in-session agent — the agent Reads the rendered image — for UNINTENDED INAPPROPRIATE READINGS before it ships, and any image that carries one is regenerated with a tightened prompt, never shipped. This is the appropriateness sibling of R-ANATOMY-GATE + R-PATH-B-TEXT-LEAK-GATE, and — like the screenshot-DoD — it is a HUMAN/agent VISUAL judgment, because an automated classifier cannot reliably catch "this shape/feature happens to look like X."** Codified per founder-flag 2026-07-18 (the bugscamp `/story` "Wiggle" card: the under-stone garden grub — a pale, smooth, C-curled tubular form with a rounded tip — read as **anatomically suggestive (a male private part)**; regenerated + shipped as bugscamp-app #53 / site #1029).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Chapter hero source-of-truth (R-CHAPTER-HERO-SOURCE; 2026-06-11)

**For multi-beat chapters, beat 0 IS the chapter hero. The top-of-page `chapter_<char>_opener.webp` (rendered via `<ChapterIllustration variant="opener" />`) MUST NOT also render** — doing both creates visual redundancy (two opening-scene heroes within 200px) and wastes gen budget at portfolio scale.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Content upload + manifest rebuild discipline (R-CONTENT-UPLOAD-MANIFEST-DISCIPLINE; 2026-06-19)

**Every content upload to spark-anvil-site MUST result in the corresponding freshness manifest being rebuilt before/during the next Cloudflare Workers Builds deploy.** The site's `package.json` `prebuild` chain handles 5 of 6 manifests automatically via filesystem-scan or git-mtime-scan builders. The 6th manifest (`pdfs-recency.json`) lives hub-side and requires explicit re-run after every PDF render wave.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Sidecar `tier` field required (R-SIDECAR-TIER-REQUIRED; 2026-06-19)

**Every multi-beat sidecar manifest MUST carry a `tier` field with integer value 1 or 2.** Applies to BOTH source-of-truth sidecars in `labsmith/Resources/AutoSegmentedChapters/<app>/<char>.beats.json` AND distributed copies in `spark-anvil-site/public/chapters/<app>/chapter_<char>.beats.json`.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Tier-2 `/advanced` route needs a content-collection entry (R-TIER-2-CONTENT-ENTRY; 2026-06-30)

**A Tier-2 `/advanced` page ONLY builds if a `src/content/chapters/<app>/<char>-advanced.md` content-collection entry exists.** Shipping the `public/chapters/<app>/chapter_<char>-advanced.*` asset set (snapshot + sidecar + beats + audio + vtt) and getting the chapter into `multibeat-chapters.json` is **NOT sufficient** — the route `src/pages/cast/[app]/[char]/advanced.astro` builds its paths from `getCollection('chapters')` filtered to `*-advanced.md`, so with no content entry the route never generates and the page **404s** despite every asset being present.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Gemini API key single-flight discipline (R-GEMINI-KEY-SERIAL; 2026-06-30)

**The entire hub content-generation pipeline shares ONE Gemini API key (`~/.config/labsmith/gemini_api_key`), and that key throttles HARD under load. Run exactly ONE key-consuming operation at a time. NEVER run generation, image-gating, and portrait/cover gen concurrently — serialize them.** Codified after the throttle bit every V24–V28 cast-expansion wave (recurring "gen ONE app at a time; don't run gating concurrently with gen" gotcha in the wave handoffs + memory `cast-expansion-program.md` + `[[spark-anvil-gen-pipeline]]`).

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Long single-flight gen pipelines are DRIVEN with foreground sleep-waits — never background-and-stop (R-GEN-FOREGROUND-DRIVE; 2026-07-14)

**When the founder has said "do not stop until fully done" (or otherwise authorized an autonomous multi-app run), a long single-flight gen pipeline — the coverage program, a cast-expansion wave, any pipeline whose steps serialize on the shared Gemini key (R-GEMINI-KEY-SERIAL) — MUST be driven by the agent with FOREGROUND `sleep`-poll waits between the key-serialized steps, NOT by launching a background gen and ENDING the turn to await a task-notification.** Codified per founder-direct 2026-07-14 (*"resume and do not stop. use sleep if needed"* → *"again: resume and do not stop. use sleep instead"* → *"codify this rule in repo"*), after a session repeatedly backgrounded each ~15-min pilot / ~35-min T2 gen and ended its turn, forcing the founder to type "resume" once per step — which defeats the auto-cycle and stalls a weeks-long program on human keystrokes.

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

## Prefer `-latest` model aliases in pipeline scripts (R-GEMINI-MODEL-ALIAS; 2026-07-09)

**Every Gemini-backed pipeline script MUST reference a rotation-proof `-latest` model alias (or the current preview family) — NEVER a pinned mid-generation version ID like `gemini-2.5-flash` that a family rotation can silently 404 out from under a running batch.** Codified after the V60 incident (2026-07-09): mid-V45 the **entire `gemini-2.5` `generateContent` family was retired** — `gemini-2.5-flash`, `gemini-2.5-pro`, `gemini-2.0-flash`, `gemini-2.5-flash-image-preview` all began returning **`404 NOT_FOUND`** — while ~1300 in-flight text-leak audit images errored and every pipeline script hardcoding a 2.5 ID broke at once. (Wrinkle: the retired IDs still appear in `models.list()` with lagging metadata, so a list check is NOT sufficient to confirm a model is live — you must probe `generateContent`.)

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).

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

→ **Full detail:** `Docs/REFERENCE_SPARK_ANVIL_WEBSITE.md` § (this heading).
<!-- END LABSMITH-SYNCED CONTENT -->
