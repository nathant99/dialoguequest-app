# Portfolio Cross-Repo Rules

**IMPORTANT**: Labsmith must NEVER write implementation code (Swift files, tests, views, services) to app repos. Implementation belongs exclusively to each app's own Claude Code session, which can build, test, and integrate against the real Xcode project. Labsmith's role is limited to research, planning, and documentation.

**EXCEPTION**: Labsmith MAY update `CLAUDE.md` and `Docs/*.md` files in app repos for cross-repo consistency (e.g., adding `@Docs/` references to design documents, updating project metadata, fixing documentation links). This does not extend to source code, tests, or Xcode project files.

## Cross-Repo Plan Handoff

Plans created in labsmith that target a specific app repo must be copied to the app repo for implementation:

1. Create the plan in labsmith `Docs/` — this is the research hub copy
2. Copy the plan to the target app repo's `Docs/`
3. The app repo's Claude Code session implements from its local copy
4. The labsmith copy remains as the archival research artifact

## App Repos

All app repos live at `../[appname]-app/`. Discover them with `ls ../` — do not rely on hardcoded lists.

### CRITICAL: Pull Before ANY Cross-Repo Read

**`git pull --ff-only` EVERY repo you are about to read, analyze, or modify — BEFORE the first file read or grep.** This is non-negotiable. Another Claude Code session may have pushed changes from within that app's Xcode project. Stale local clones produce wrong conclusions.

This applies to ALL cross-repo operations:
- Reading Package.swift to check dependencies
- Grepping for imports or API usage
- Checking file existence or structure
- Running readiness audits or adoption analysis
- Copying docs to app repos
- Any `git log` or `git diff` on app repos

**When delegating to subagents**: The parent must pull before spawning, OR the subagent prompt must explicitly instruct the agent to pull first. Subagents inherit stale working trees if nobody pulls.

**Hard-earned lesson (2026-05-17)**: pulling matters most when **authoring canonical content for a target app** — manifests, configs, schemas, anything that gets bundled into the app's repo or that references the app's data model. The cost of NOT pulling is producing a doc/config that disagrees with the app's shipped reality, then having to author a reconciliation handoff. Concrete failure mode: labsmith authored AdventureHub `HubContribution` Level 1 configs assuming Phase 1 hadn't started; it had shipped 13 PRs with different engine bindings, mentor names, and zone slugs. Reconciliation took a full PR cycle. **Always pull the target app before authoring labsmith content that targets it.** Same rule applies to ForgeKit: never claim a feature ships at version X without `git pull forgekit && head Docs/CHANGELOG.md` first.

**Pull command** (for targeted repos):
```bash
export PATH="/opt/homebrew/bin:$PATH"
cd /Volumes/Data/Projects/GitHub
for d in repo1-app repo2-app forgekit; do
    [ -d "$d/.git" ] && echo -n "$d: " && (cd "$d" && git pull --ff-only 2>&1 | tail -1)
done
```

If `--ff-only` fails for any repo, stop and investigate — it means there are local uncommitted changes or diverged history that needs manual resolution.

### CRITICAL: Per-repo pull-then-audit BEFORE work, ONE AT A TIME (R420 #910; user-direct 2026-06-01)

**For each target repo in a multi-repo workflow, perform pull-then-audit SEQUENTIALLY — not batched — BEFORE any work touches that repo.** Reinforced per user-direct 2026-06-01 R420 ("pull origin for each repo, one at a time before auditing and doing work").

Required per-repo sequence (one at a time, in order, output shown):

```bash
cd /Volumes/Data/Projects/GitHub/<app>-app
git checkout main              # ensure on main (NOT a leftover feature branch)
git pull --ff-only              # pull origin/main; refuses if diverged
git status -s                   # audit: must be clean (no uncommitted changes)
git log -1 --format='%h %s'     # verify HEAD; sanity-check what you're branching from
```

Display the output for each step so the audit is visible. Only proceed to branching + work when:

- ✅ Current branch is `main`
- ✅ `git pull --ff-only` returns "Already up to date." OR a clean fast-forward
- ✅ `git status -s` is empty (zero uncommitted files)
- ✅ HEAD matches the expected baseline (no unexpected commits since last interaction)

**If any step fails**, STOP and surface the discrepancy to the user before proceeding.

**Why one-at-a-time matters**: batched pulls hide per-repo failures behind aggregate success messages. The user explicitly called out the failure mode at R420 #910 after observing that batched pulls obscured the audit signal. Per-repo sequential pulls make any divergence + uncommitted-state issue visible at the moment it surfaces.

**When per-repo audit applies**: every cross-repo work item that will write to a target app repo. NOT just the first repo in a batch; EVERY repo in the batch, in order, individually. The cost of redundant pulls is ~5 seconds per repo; the cost of acting on stale state is reconciliation work.

**Companion**: pair with § Verify Cross-Repo PRs Merged Before Claiming SHIPPED below — pull-audit-then-work on the inbound side; merge-then-verify on the outbound side.

### CRITICAL: Verify Cross-Repo PRs Merged Before Claiming SHIPPED

After every cross-repo PR (spark-anvil-site, app repos, forgekit, forgesync, forgeplay), confirm the merge:

```bash
gh pr merge <number> --merge --delete-branch
gh pr view <number> --json state,mergedAt
```

State must be `MERGED`. Three incidents have hit labsmith via orphan-PR bugs:
- Round 70 #377 (LiveKit DECISION on PR #208 — recovered via PR #213)
- Round 73 (classroom slots PR title-mismatch on PR #220)
- Round 76 #392 (beta-testing surface on PR #86 — recovered today)

Common cause: bg agent creates feature branch + PR, but the agent process ends before `gh pr merge` runs (or fails with `UNSTABLE` due to non-blocking CI checks). Agent reports are NOT authoritative for merge state — the main session must verify.

Before closing any cross-repo round: `gh pr list --state open --author "@me" --repo <repo>` to audit. See `.claude/rules/workflow.md` § "CRITICAL: Verify PR Merged Before Claiming SHIPPED" for full pattern.

## Cross-Repo Handoff Protocol

App sessions and labsmith communicate via paired handoff docs in each repo's `docs/` (or `Docs/`) directory. App sessions don't read labsmith repo state directly — labsmith and apps coordinate by writing handoff docs into each other's repos.

### When to write a handoff to labsmith

From an app session, write a handoff doc when the app needs labsmith to:

- Update a labsmith script (illustration pipeline, kit generator, consolidation rules)
- Update a labsmith template (handoff docs, design docs, kit boilerplate)
- Add a per-app override (output path, mascot config, custom rules)
- Author or revise research that the implementing session can't do alone
- Change a portfolio convention that other apps will inherit

Don't write a handoff to labsmith for:

- App-internal refactors (the implementing session owns app source code)
- Build, test, or signing issues local to the app
- Quick fixes that don't need cross-repo coordination

### File naming + location

Both directions live in the same repo's `docs/` (or `Docs/`) — whichever the repo conventionally uses.

| Direction | Filename pattern | Lives in |
|---|---|---|
| App → labsmith | `docs/HANDOFF_FROM_APP_<TOPIC>.md` | App repo (sender) |
| Labsmith → app | `docs/HANDOFF_FROM_LABSMITH_<TOPIC>.md` | App repo (recipient) |

`<TOPIC>` is a SCREAMING_SNAKE_CASE description — e.g., `ILLUSTRATION_PIPELINE_PATH`, `PER_APP_OUTPUT_PATH`, `FORGEKIT_SOFT_SPLIT_REQUEST`.

### Required structure

Every handoff doc starts with these lines:

```markdown
# Handoff [to|from] Labsmith — <human-readable subject>

Direction: **[app → labsmith | labsmith → app]**. <One-sentence framing>.
```

Body sections (use the ones that apply):

- **The decision** — what's being asked for or what was done, in one paragraph
- **Requested change** (app→labsmith) — concrete pipeline/script/template change with before/after
- **What labsmith did** (labsmith→app) — code references, commit hashes, PR numbers
- **Options considered** — a small table comparing approaches with verdicts (prevents re-litigating)
- **State at this handoff's commit** — current asset locations, branch names, what's already done
- **Sequencing to unblock** — numbered list of what each side does next
- **What this doc does NOT cover** — explicit scope boundary
- **Related commits / PRs** — table cross-referencing both repos

### Lifecycle

1. **App session** writes `HANDOFF_FROM_APP_<TOPIC>.md` in app repo, commits, pushes
2. **App session** signals labsmith by mentioning the doc name in their conversation with the user, who can then surface it to the labsmith session
3. **Labsmith session** reads the handoff (via `git pull` of the app repo), implements the change in labsmith, writes `HANDOFF_FROM_LABSMITH_<TOPIC>.md` in the same app repo's docs/, commits, pushes
4. **App session** (next CC session in the app repo) reads the labsmith response and continues the integration

Both docs stay in the app repo as the durable audit trail. Labsmith doesn't keep its own copy — its action is captured in commits + PR descriptions.

### Reference example

CuriosityQuest's bidirectional exchange (2026-05-15) is the canonical example:

- `curiosityquest-app/docs/HANDOFF_FROM_APP_ILLUSTRATION_PIPELINE_PATH.md` — app asked labsmith to write CuriosityQuest's illustration assets to the SharedUI SPM target's resource root instead of repo root
- `curiosityquest-app/docs/HANDOFF_FROM_LABSMITH_PER_APP_OUTPUT_PATH.md` — labsmith responded with per-app `dest_subpath_for()` override in the bundling script + a one-time `git mv` to relocate existing assets

Reading both in order shows the request, the options considered, the implementation, and the next steps each side owns.

### Asset request sub-pattern

A common case: app needs custom art / audio / icon / illustration assets that labsmith's asset pipelines can generate (or that need a new pipeline). Use the handoff mechanism — don't generate assets in the app repo session, and don't request via Slack / out-of-band.

**Naming**: `HANDOFF_FROM_APP_<ASSET_TYPE>.md` in the app's own `Docs/` (or `docs/`). Examples: `HANDOFF_FROM_APP_BIOME_TILE_ART.md`, `HANDOFF_FROM_APP_AUDIO_SFX.md`, `HANDOFF_FROM_APP_MASCOT_REFRESH.md`, `HANDOFF_FROM_APP_ICON_VARIANTS.md`.

**Required content for an asset request**:

- **What's needed** — concrete table listing every asset (filename, what it represents, where it goes in the app repo)
- **Format constraints** — pixel dimensions, file format, color profile, alpha requirements, tiling rules, total bundle ceiling, naming convention
- **Style spec** — link to your `Docs/DESIGN_ART_DIRECTION.md` / `Docs/DESIGN_AUDIO_DIRECTION.md` or describe inline (palette, mood, art-style cluster name if portfolio-shared)
- **Bundle path** — exact path inside the app repo (`Libraries/Sources/SharedUI/Resources/Illustrations/`, `Libraries/Sources/Services/Resources/Audio/`, etc.)
- **What this unblocks** — the gameplay / UI feature waiting on these assets
- **Options considered** — including the interim placeholder shipping plan (always ship a placeholder so the app doesn't block on labsmith)
- **State at this handoff's commit** — current branch, ForgeKit pin, what code is in place expecting these assets

**Labsmith's possible responses**:

| Response | Trigger | Labsmith side |
|---|---|---|
| **Generate immediately** | Existing pipeline covers this asset class | Run `scripts/gen_app_<class>.py` + distribute to the app repo. Drop a `HANDOFF_FROM_LABSMITH_<TOPIC>.md` confirming what shipped. |
| **Generate with extension** | Existing pipeline needs minor extension (new APP_CONFIGS entry, new cluster prompt) | Author the extension, run, distribute. Same handoff response. |
| **Plan + defer** | No pipeline exists; one-off would not justify the pipeline build | Author a `Docs/PLAN_NEW_ASSET_PIPELINES.md`-style planning doc in labsmith. Respond to the app with a `HANDOFF_FROM_LABSMITH_*.md` explaining the defer + the trigger that would unblock build (typically 2nd app demand). |
| **Reject** | Asset class is too app-specific or violates portfolio conventions | Respond explaining why; suggest in-app pattern instead. |

**Apps in the interim**: always ship a placeholder. The handoff is async — don't block your release on labsmith picking it up.

### Asset generation ownership + handoff requirement (2026-05-19 STANDING RULE; reinforced 2026-06-01 R410 #888)

Labsmith **owns portfolio-wide asset generation — ALL asset classes, no exceptions** (user-direct 2026-06-01 "you own the audio generation. you own all asset generation"). Apps don't run any generative pipeline: not Gemini Nano Banana Pro/Flash, not Lyria 3, not ElevenLabs/Resemble/Play.ht voice gen, not any future asset-gen vendor. Labsmith runs them per `GUIDE_ILLUSTRATION_PIPELINE.md` + pipeline-specific guides.

**Covered asset classes** (non-exhaustive; labsmith owns ALL):

| Class | Pipeline | Vendor | Ceiling (per-app) |
|---|---|---|---|
| Mascot illustrations | `GUIDE_ILLUSTRATION_PIPELINE.md` | Gemini Nano Banana Pro | ~$0.27 |
| Joke / topic / backdrop / modecard illustrations | `GUIDE_ILLUSTRATION_PIPELINE.md` | Gemini Nano Banana Flash | varies by kit density |
| Cast portraits | sub-pipeline of illustrations | Gemini Nano Banana Pro | ~$0.27/char |
| Chapter illustrations | ADR-017 + ADR-018 | Gemini Pro (opener) + Flash (spot) | ~$0.50/chapter (2 per chapter) |
| Avatar accessories | `scripts/copy_avatar_accessories_to_repos.sh` | Gemini Nano Banana Pro | ~$0.36/pack |
| Biome tiles | `Resources/CustomArt/<app>/biome_tiles.json` | Gemini Flash | varies |
| Audio SFX | Lyria 3 / Gemini SFX | Google | ~$0.10/clip |
| **Audio drama (Phase 2 DN-S)** | `PLAN_DN_S_PHASE_2_AUDIO_DRAMA.md` (R395 #819) | **Google Cloud TTS (canonical) + ElevenLabs (Phase 2A pilot A/B)** per R410 #888 | ~$0.20/drama Google TTS Wavenet; ~$30-100/drama ElevenLabs; Phase 2B vendor lock-in decided post-pilot |
| Particle specs | future pipeline | TBD | TBD |
| Lottie celebrations | curated; not gen | N/A (hand-authored / sourced) | N/A |

**Pre-generation discipline** (R409 #882): for audio drama specifically, content is **pre-generated labsmith-side + bundled as static `.caf` per app**. Apps play from local Bundle only — no streaming, no runtime gen, no server round-trip. Inherits to future audio assets unless explicitly superseded by ADR. See `Docs/PLAN_DN_S_PHASE_2_AUDIO_DRAMA.md` § Load-bearing architectural directive.

Cost discipline: stay within published per-class ceilings. New asset classes added to this table when first vendor pipeline is exercised; cost ceiling set per founder approval BEFORE first gen run.

**Standing rule — every asset distribution wave MUST file a per-app handoff doc.** When `scripts/copy_<kind>_to_repos.sh` ships assets to an app's `Resources/` directory, the same wave MUST also file `Docs/HANDOFF_FROM_LABSMITH_<KIND>.md` in that app's repo. The handoff explains:

- **What shipped**: exact file paths + counts (e.g., "5 mascot poses + 70 joke illustrations + 91 topic illustrations under `Resources/Illustrations/`")
- **How to consume**: ForgeKit module + view pattern (e.g., `ForgeIllustrations.IllustrationRegistry` for illustrations, `ForgeAvatar.AvatarAssetCatalog` for accessories, `SFXLibrary` for audio)
- **Manifest schema**: where `illustrations.json` / `accessories.json` / similar manifests live + format
- **App-side integration tasks**: register the bundle, wire `IllustrationResolver`, add fallback content for unavailable assets, configure Reduce-Motion variants
- **What's NOT included**: anything the app session needs to do (e.g., "add Lottie celebrations to your CelebrationCatalog", "wire the mascot to your AI mentor persona")

**Why the rule exists**: 2026-05-19 portfolio audit (per `Docs/AUDIT_ILLUSTRATION_HANDOFF_BACKFILL.md`) found 40+ apps with bundled illustrations BUT zero per-app handoff docs. Implementing sessions had to reverse-engineer the bundled structure. The pipeline shipped assets but skipped the integration handoff. This rule closes that gap.

**For existing assets without handoffs**: backfill per the audit doc, prioritizing mature/active apps first (those with substantial LOC and recent commits).

**For new asset generation waves**: the pipeline script MUST file the handoff in the same wave. Recommended pattern: extend `scripts/copy_<kind>_to_repos.sh` to also copy a per-app handoff template from `labsmith/Docs/TEMPLATE_IMPLEMENTATION_HANDOFF_<KIND>.md` (filling app-specific variables). Don't skip the handoff because "the template covers it" — each app's CC session needs the doc in its OWN repo, not a pointer to labsmith.

### Asset Consumer Audit (2026-05-20 STANDING RULE — closes CubeSensei ASSET_CONSUMER_AUDIT inbound #22)

**Registered ≠ wired.** When an app session adopts a labsmith-delivered asset handoff (illustrations / mascots / topics / backdrops / modecards / portraits / accessories / icons), the Definition of Done MUST include:

1. **Grep for a consumer call site** — at least one view in the app's `Sources/` directory must actually render the asset class via `IllustrationRenderer`, `BackdropView`, `MascotReactionView`, `IllustratedJokeView`, `AvatarRenderer`, `topicContentKey(...)`, or equivalent. `grep -rE 'IllustrationRenderer|BackdropView|MascotReactionView|IllustratedJokeView|topicContentKey|AvatarRenderer|JokeOfTheDayCard' <app>/Packages/Libraries/Sources/`
2. **Zero hits = shipped-but-dark** — `IllustrationRegistry` / `AvatarAssetCatalog` registration alone does NOT mean the asset is visible to the user. File a follow-up wiring task or open an app-internal ticket BEFORE closing the handoff
3. **Auditor**: the app session that adopts the handoff (not labsmith) does the audit. Labsmith's `HANDOFF_FROM_LABSMITH_<KIND>.md` doc lists the consumer-view patterns to look for under "How to consume" — apps grep for those patterns before marking the handoff CLOSED

**Why the rule exists**: CubeSensei discovered 120 illustrations registered in `IllustrationRegistry` but not rendered by any view — silently dark on production-track main for several days. The session was answering "yes, delivered" based on registry registration alone. This rule closes that gap.

**Companion to the asset-delivery rule above**: the asset-delivery handoff ships the bundle + integration guidance; the consumer-audit step verifies the integration actually wired in.

**Templates** (already shipped):

- `labsmith/Docs/TEMPLATE_IMPLEMENTATION_HANDOFF_ILLUSTRATIONS.md`
- `labsmith/Docs/TEMPLATE_IMPLEMENTATION_HANDOFF_PASS_AND_PLAY.md`
- `labsmith/Docs/TEMPLATE_IMPLEMENTATION_HANDOFF_SERVER.md`
- (Future): `TEMPLATE_IMPLEMENTATION_HANDOFF_MASCOT.md`, `_ACCESSORIES.md`, `_AUDIO.md`, `_BIOME_TILES.md`, `_PARTICLES.md` — author as each pipeline ships its first asset wave

### Reference examples (asset request sub-pattern)

| App | Asset request | Labsmith response | Outcome |
|---|---|---|---|
| `labsmith-app` | mascot + topic illustrations | Generated immediately (added APP_CONFIGS for "experimental-notebook" cluster, ran pipeline) | 129 webp shipped in PR #18; humor seeds authored later (PR #20) for joke illustrations |
| `terravoyage-app` | biome tile art (140 tiles + particles) | Plan + defer | `Docs/PLAN_NEW_ASSET_PIPELINES.md` captures the build plan; deferred until 2nd app demand |
| `terravoyage-app` | themed SFX audio (7 CAFs) | Plan + defer | Same plan doc; deferred until Lyria API access or 2nd app demand |
| `geometryforge-app` | (implicit via Wave 30 commits) topic-thumbnail illustrations | Generated immediately via existing pipeline | Bundled to app repo as on-demand fill |

## App Implementation Ranking Methodology (Round 106 #518; codified Round 114 #535)

When labsmith needs to produce a forward-looking ranking of which portfolio apps to BUILD next (founder-direct sequencing or routine ranking refresh), use the **6-axis weighted composite formula** codified in `Docs/DECISION_APP_RANKING_COMPOSITE_SCORING_2026-05-28.md`:

```
composite_0_100 = normalize(
    (ImplReadiness      × 0.25) +
    (DN_maturity        × 0.20) +
    (PillarPRIMARYcount × 0.20) +
    (AssetReadiness     × 0.15) +
    (PillarDeepening    × 0.10) +
    (StrategicValue     × 0.10)
)
```

Each axis scored 0-3 or 0-5 per the per-axis scale (see `DECISION_APP_RANKING_COMPOSITE_SCORING_2026-05-28.md` for full per-axis rubrics).

**Trauma-gate is a FLAG, not a score reducer.** Apps marked trauma-gated retain their natural composite score but display a 🛑 marker. This separates **build-readiness** (what the composite measures) from **gating** (a binary blocker). Trauma-gated apps re-enter their natural rank position when the gate clears (R0 reviewer signoff per ADR-012).

**Anti-criteria flags** are surfaced separately from the composite (recent-churn / known-blocker / asset-gap / dn-partial / retired-marker). They don't reduce score; they surface the dominant blocker per app for the remediation roadmap.

**Data sources** (no fresh 140-repo pull required — these audit docs ARE the data):
- `Docs/AUDIT_IMPLEMENTATION_READINESS.md` (11-criteria per-app readiness)
- `Docs/AUDIT_PORTFOLIO_PILLAR_TAGGING.md` (PRIMARY/SECONDARY pillar classification)
- `Docs/AUDIT_APP_REPOS_DN_HANDOFF_STATUS.md` (DN handoff coverage)
- `Docs/AUDIT_PILLAR_DEEPENING_PER_APP.md` (per-app deepening moves)
- `Docs/AUDIT_PORTFOLIO_INVENTORY_RECONCILIATION_2026-05-26.md` (canonical 140-app list)
- `spark-anvil-site/src/data/apps.generated.ts` (canonical `modes` + `distributedNarrative` + `dnCast`)

**Reference deliverable**: `Docs/AUDIT_APP_IMPLEMENTATION_RANKING_DN_5PILLAR_2026-05-28.md` (Round 106 #518) — Top-4 tied at 90.0 (CubeSensei / CuriosityQuest / FractionForge / SaffronLab READY NOW); Top-20 at 71.7-90.0; Bottom-15 + remediation paths.

**When to use this formula**: founder asks "which apps should we build next?" or routine quarterly portfolio-sequencing refresh. Single ranking doc per refresh date; do NOT fragment into V1/V2 alternates (Round 106 surfaced V2 as a subagent-generated alternate; V1 is canonical per the DECISION doc).

## Color Scheme Audit Methodology (Round 133 #567; codified after R118 incomplete-sweep incident)

When auditing an app's color-scheme alignment to its canonical palette (`docs/DESIGN_ART_DIRECTION.md` § Color Palette), the audit grep pattern MUST catch BOTH SwiftUI color-token forms:

```bash
# CORRECT pattern v2 (Round 137 #568 extension — adds named-param `color: .X` form):
grep -rE "Color\.(blue|purple|teal|cyan|indigo|mint|orange|red|green|yellow|pink|brown)|\.(foregroundStyle|tint|fill|background)\(\.(blue|purple|teal|cyan|indigo|mint|orange|red|green|yellow|pink|brown)\)|\.glassEffect\(\.regular\.tint\(\.(blue|purple|teal|cyan|indigo|mint|orange|red|green|yellow|pink|brown)\)|color: \.(blue|purple|teal|cyan|indigo|mint|orange|red|green|yellow|pink|brown)"

# WRONG pattern v1 (Round 118 #540 incident — caught only explicit Color.X form):
grep -rE "Color\.(blue|purple|orange|red|green)"
```

**Why**: SwiftUI accepts both `Color.blue` (explicit) and `.blue` (shorthand) in styling contexts. The shorthand is heavily used in `.foregroundStyle(.blue)`, `.tint(.blue)`, `.fill(.blue)`, `.background(.blue)`, `.glassEffect(.regular.tint(.blue))`. Audit grep that catches only `Color.X` misses ~50% of real violations.

**Empirical evidence**: Round 118 #540 audit table covered 8 CQ files cleanly (CQ session swept them per R126 ACK), but Round 133 #567 founder visual review found ~15 additional violations in `DailyDashboardView+*` + `TexasMapView+*` — entirely from the shorthand form. Phase 2 sweep filed via R133 #567. **Round 137 #568 extension**: Hero tab review found 13 additional violations including 12 from the `color: .X` **named-parameter** form (e.g., `StatCard(... color: .purple)`, `ProfileMenuRow(... color: .teal)`) that the Phase 2 grep also missed. Phase 3 sweep filed via R137 #568. Grep pattern v2 now catches all three forms (`Color.X` explicit / `.X` modifier shorthand / `color: .X` named-param).

**Codification candidate for audit-script v6+**: extend `scripts/cross_repo_handoff_audit.py` (if/when expanded to color-scheme audits) with both-form regex. For now: human-discipline grep pattern documented here.

**When this rule applies**:
- Any color-scheme audit (per-app or portfolio-wide) per `Docs/AUDIT_PORTFOLIO_COLOR_SCHEME_ALIGNMENT_<date>.md` pattern
- Any color-refresh handoff per `HANDOFF_FROM_LABSMITH_COLOR_SCHEME_REFRESH.md` template
- Verify-before-list audits checking color-scheme alignment of recommendation lists

## Debug Logging (Round 138 #569; lifted from CuriosityQuest 2026-05-28)

Portfolio standard for adding extensive debug logging to detect unexpected runtime behaviors in iOS apps + Hummingbird servers. The single biggest source of "the app didn't crash but something was wrong" bug reports is a swallowed `try?` or a silent fallback path — detection logging makes those paths visible without changing their semantics.

**Canonical rule**: `.claude/rules/debug-logging.md` (477 lines). Codifies: categorized logger from day one (not sprinkled `print()`), category-to-bug-class mapping, auto-included diagnostic context (thread / caller / surface), production-safety (`#if DEBUG`-gated iOS / env-gated server verbose), the `didSet` pattern for state-machine coverage, replace-silent-`try?` discipline, surface-wiring playbook (iOS app shell / tab views / network services / Multipeer / SwiftData / state machines + server controllers / WebSocket / Gemini / safety / admin ops), 11-step categorization decision tree, when NOT to add logging, pre-PR checklist, AND a 2026 production-observability section covering Apple `Logger` migration triggers + privacy-by-default (always-redact list) + audit-logs-≠-debug-logs separation (with retention by regulation: COPPA ~6yr / GDPR data-minimization / PCI 12mo / SOX 7yr) + Swift OTel graduation path + silent-failure detection for AI paths (span schemas) + performance instrumentation (`OSSignposter` + `withSpan`).

**Research provenance**: `Docs/RESEARCH_RUNTIME_BEHAVIOR_AUDIT_LOGGING_2026.md` — 30 sources surveyed across 4 domains (Apple unified logging / Swift server observability / audit-vs-debug compliance / silent-failure + agent observability). 6 codified findings, each mapped to a CuriosityQuest reference impl + a future bug class.

**Reference impls** (canonical templates per portfolio rule):
- iOS: `curiosityquest-app/Packages/Libraries/Sources/Services/DebugLog.swift` (single-seam emitter, 7 categories, `#if DEBUG`-gated, zero-overhead release builds)
- Server (Hummingbird): `curiosityquest-app/Server/CuriosityQuestServer/Sources/Services/DebugFileLog.swift` (8 categories, file+stdout, env-gated verbose)

**Per-app adoption**: each app decides when to wire categorized logging (CQ is the reference impl, not a forced migration). Use the canonical template above as the starting point; adapt categories to the app's surface area (e.g., apps without network can drop `.network`; apps with pass-and-play add `.multipeer`).

**Lift provenance**: CQ shipped the rule + research in PRs #114-#121; filed `HANDOFF_FROM_APP_LIFT_DEBUG_LOGGING_RULE.md` Round 138 #569 requesting portfolio lift. Labsmith lifted + propagated via `scripts/copy_rules_to_repos.sh --apply` in the same round.

## ForgeKit

All portfolio apps share a common SPM framework at `../forgekit/` (49 modules, semver 0.75.0+; sources soft-split into `Client/` + `Server/` + `Shared/`). Apps import only the modules they need. See `@.claude/rules/forgekit.md` for the full module catalog.
<!-- END LABSMITH-SYNCED CONTENT -->
