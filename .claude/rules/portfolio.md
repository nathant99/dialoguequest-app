# Portfolio Cross-Repo Rules

**IMPORTANT**: Hub must NEVER write implementation code (Swift files, tests, views, services) to app repos. Implementation belongs exclusively to each app's own Claude Code session, which can build, test, and integrate against the real Xcode project. Hub's role is limited to research, planning, and documentation.

**EXCEPTION**: Hub MAY update `CLAUDE.md` and `Docs/*.md` files in app repos for cross-repo consistency (e.g., adding `@Docs/` references to design documents, updating project metadata, fixing documentation links). This does not extend to source code, tests, or Xcode project files.

## Cross-Repo Plan Handoff

Plans created in hub that target a specific app repo must be copied to the app repo for implementation:

1. Create the plan in hub `Docs/` — this is the research hub copy
2. Copy the plan to the target app repo's `Docs/`
3. The app repo's Claude Code session implements from its local copy
4. The hub copy remains as the archival research artifact

## App Repos

All app repos live at `../[appname]-app/`. **For READING / pulling / auditing**: discover via `ls -d ../*-app/` — do not rely on hardcoded lists. **For WRITING / distributing content (handoffs, asset bundles, rule syncs)**: use the canonical 140-app registry, NOT a filesystem glob — see § "CRITICAL: Distribution scripts MUST source from canonical portfolio registry" below.

### CRITICAL: Distribution scripts MUST source from canonical portfolio registry (R-PORTFOLIO-INVENTORY 2026-06-04)

**For any script that WRITES to multiple app repos (per-app handoff distribution, asset bundle distribution, doc sync, etc.) — the script MUST source the target app list from `spark-anvil-hub/Docs/REGISTRY_ACTIVE_PORTFOLIO_APPS.txt` (the canonical 140-app registry), NOT from a `ls *-app/` filesystem glob.**

**Why**: filesystem globs pick up the entire `~/Projects/GitHub/*-app/` directory tree which includes:

- **140 active portfolio apps** (the target set)
- **7 retired apps** (geoforge / arcadeforge / etymonrealm / bodyforge / mintquest / forgeworks / punchlineforge — per `Docs/PORTFOLIO_PATTERNS.md` § Retired Repos)
- **10 archived mega-app planning repos** (mathquest / physicsforge / languageforge / earthforge / mediaforge / healthforge / historyforge / economicsforge / engineerforge / lifeforge — per `Docs/PORTFOLIO_PATTERNS.md` § Archived Mega-App Planning)
- **2 non-portfolio side projects** (cartunes / karaokemuxer — per `Docs/PORTFOLIO_PATTERNS.md`)

Distribution to non-portfolio repos is a real bug (R-PORTFOLIO-INVENTORY 2026-06-04 incident: `distribute_forgekit_bootstrap_handoff.sh` initially used a filesystem glob and pushed the bootstrap handoff to `bodyforge-app` (retired) + `earthforge-app` / `economicsforge-app` / `engineerforge-app` (archived mega) before the user caught the over-reach. 4 reverts shipped, registry-based filtering added).

**Canonical registry**:
- **Source of truth**: `Docs/PORTFOLIO_PATTERNS.md` § "App Repos (140)" — human-readable fenced block
- **Machine-readable copy**: `Docs/REGISTRY_ACTIVE_PORTFOLIO_APPS.txt` — one app slug per line; lines starting with `#` are comments
- **Regenerator**: `scripts/regenerate_portfolio_registry.py` — re-extracts from PORTFOLIO_PATTERNS.md after every inventory change

**Distribution script pattern**:

```bash
REGISTRY="$LABSMITH_DIR/Docs/REGISTRY_ACTIVE_PORTFOLIO_APPS.txt"
[ -f "$REGISTRY" ] || { echo "ERROR: registry missing"; exit 1; }
APPS=()
while IFS= read -r app; do
    [ -z "$app" ] && continue
    [[ "$app" =~ ^# ]] && continue
    appdir="${app}-app"
    [ -d "$GITHUB_DIR/$appdir/.git" ] && APPS+=("$appdir")
done < "$REGISTRY"
```

**Single-app override** still validates against the registry:

```bash
if [[ -n "$SINGLE_APP" ]]; then
    grep -q "^${SINGLE_APP}$" "$REGISTRY" || { echo "ERROR: $SINGLE_APP not in portfolio"; exit 1; }
    APPS=("${SINGLE_APP}-app")
fi
```

**Reference impl**: `scripts/distribute_forgekit_bootstrap_handoff.sh` (post-2026-06-04 update). Other distribution scripts (`copy_rules_to_repos.sh` / `copy_illustrations_to_repos.sh` / `copy_kits_to_repos.sh` / `sync_content_to_site.sh` / `backfill_audio_m4a_vtt.sh` / etc.) should be migrated to the same pattern — audit pending per work queue item.

**When you UPDATE the portfolio inventory** (add an app / retire an app / etc.):
1. Update `Docs/PORTFOLIO_PATTERNS.md` § "App Repos (140)" (update the count if changed)
2. Run `python3 scripts/regenerate_portfolio_registry.py` to refresh `Docs/REGISTRY_ACTIVE_PORTFOLIO_APPS.txt`
3. Commit both changes in a single hub PR



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

**Hard-earned lesson (2026-05-17)**: pulling matters most when **authoring canonical content for a target app** — manifests, configs, schemas, anything that gets bundled into the app's repo or that references the app's data model. The cost of NOT pulling is producing a doc/config that disagrees with the app's shipped reality, then having to author a reconciliation handoff. Concrete failure mode: hub authored AdventureHub `HubContribution` Level 1 configs assuming Phase 1 hadn't started; it had shipped 13 PRs with different engine bindings, mentor names, and zone slugs. Reconciliation took a full PR cycle. **Always pull the target app before authoring hub content that targets it.** Same rule applies to ForgeKit: never claim a feature ships at version X without `git pull forgekit && head Docs/CHANGELOG.md` first.

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

**Multiple hub sessions run concurrently — see `.claude/rules/workflow.md` § R-PARALLEL-HUB-AGENTS** for the consolidated coordination protocol (queue-number allocation, rule-sync single-flight `.claude/.rule-sync.lock`, R2-mutating single-flight, PR-merge-race discipline, lightweight territory claiming via `.claude/CLAIMS.md`, concurrency-safe distribution scripts). The per-repo pull-then-audit above is the inbound-read discipline within that protocol.

### CRITICAL: Verify Cross-Repo PRs Merged Before Claiming SHIPPED

After every cross-repo PR (spark-anvil-site, app repos, forgekit, forgesync, forgeplay), confirm the merge:

```bash
gh pr merge <number> --merge --delete-branch
gh pr view <number> --json state,mergedAt
```

State must be `MERGED`. Three incidents have hit hub via orphan-PR bugs:
- Round 70 #377 (LiveKit DECISION on PR #208 — recovered via PR #213)
- Round 73 (classroom slots PR title-mismatch on PR #220)
- Round 76 #392 (beta-testing surface on PR #86 — recovered today)

Common cause: bg agent creates feature branch + PR, but the agent process ends before `gh pr merge` runs (or fails with `UNSTABLE` due to non-blocking CI checks). Agent reports are NOT authoritative for merge state — the main session must verify.

Before closing any cross-repo round: `gh pr list --state open --author "@me" --repo <repo>` to audit. See `.claude/rules/workflow.md` § "CRITICAL: Verify PR Merged Before Claiming SHIPPED" for full pattern.

## Cross-Repo Handoff Protocol

App sessions and hub communicate via paired handoff docs in each repo's `docs/` (or `Docs/`) directory. App sessions don't read hub repo state directly — hub and apps coordinate by writing handoff docs into each other's repos.

### When to write a handoff to hub

From an app session, write a handoff doc when the app needs hub to:

- Update a hub script (illustration pipeline, kit generator, consolidation rules)
- Update a hub template (handoff docs, design docs, kit boilerplate)
- Add a per-app override (output path, mascot config, custom rules)
- Author or revise research that the implementing session can't do alone
- Change a portfolio convention that other apps will inherit

Don't write a handoff to hub for:

- App-internal refactors (the implementing session owns app source code)
- Build, test, or signing issues local to the app
- Quick fixes that don't need cross-repo coordination

### File naming + location

Both directions live in the same repo's `docs/` (or `Docs/`) — whichever the repo conventionally uses.

| Direction | Filename pattern | Lives in |
|---|---|---|
| App → hub | `docs/HANDOFF_FROM_APP_<TOPIC>.md` | App repo (sender) |
| Hub → app (NEW, 2026-06-11+) | `docs/HANDOFF_FROM_HUB_<TOPIC>.md` (canonical) **or** `docs/HANDOFF_FROM_SPARK_ANVIL_HUB_<TOPIC>.md` (verbose) | App repo (recipient) |
| Hub → app (LEGACY, pre-2026-06-11) | `docs/HANDOFF_FROM_LABSMITH_<TOPIC>.md` | App repo (recipient — existing files preserved) |

**Filename convention change 2026-06-11** (per user-direct + `Docs/WORK_QUEUE_HANDOFF_CONVENTION_HUB_RENAME_2026-06-11.md`): NEW handoff docs use `HANDOFF_FROM_HUB_<TOPIC>.md`. Existing `HANDOFF_FROM_LABSMITH_*.md` files in 100+ app repos STAY (backward compatibility; historical record — do NOT bulk-rename). Cross-repo audit + pair-check tooling MUST recognize BOTH conventions.

`<TOPIC>` is a SCREAMING_SNAKE_CASE description — e.g., `ILLUSTRATION_PIPELINE_PATH`, `PER_APP_OUTPUT_PATH`, `FORGEKIT_SOFT_SPLIT_REQUEST`.

### Required structure

Every handoff doc starts with these lines:

```markdown
# Handoff [to|from] Hub — <human-readable subject>

Direction: **[app → hub | hub → app]**. <One-sentence framing>.
```

Body sections (use the ones that apply):

- **The decision** — what's being asked for or what was done, in one paragraph
- **Requested change** (app→hub) — concrete pipeline/script/template change with before/after
- **What hub did** (hub→app) — code references, commit hashes, PR numbers
- **Options considered** — a small table comparing approaches with verdicts (prevents re-litigating)
- **State at this handoff's commit** — current asset locations, branch names, what's already done
- **Sequencing to unblock** — numbered list of what each side does next
- **What this doc does NOT cover** — explicit scope boundary
- **Related commits / PRs** — table cross-referencing both repos

### Lifecycle

1. **App session** writes `HANDOFF_FROM_APP_<TOPIC>.md` in app repo, commits, pushes
2. **App session** signals hub by mentioning the doc name in their conversation with the user, who can then surface it to the hub session
3. **Hub session** reads the handoff (via `git pull` of the app repo), implements the change in hub, writes `HANDOFF_FROM_HUB_<TOPIC>.md` (canonical, 2026-06-11+) in the same app repo's docs/, commits, pushes — pre-2026-06-11 hub responses used `HANDOFF_FROM_LABSMITH_<TOPIC>.md` (preserved as-is)
4. **App session** (next CC session in the app repo) reads the hub response and continues the integration

Both docs stay in the app repo as the durable audit trail. Hub doesn't keep its own copy — its action is captured in commits + PR descriptions.

### Reference example

CuriosityQuest's bidirectional exchange (2026-05-15) is the canonical example:

- `curiosityquest-app/docs/HANDOFF_FROM_APP_ILLUSTRATION_PIPELINE_PATH.md` — app asked hub to write CuriosityQuest's illustration assets to the SharedUI SPM target's resource root instead of repo root
- `curiosityquest-app/docs/HANDOFF_FROM_LABSMITH_PER_APP_OUTPUT_PATH.md` — hub responded with per-app `dest_subpath_for()` override in the bundling script + a one-time `git mv` to relocate existing assets

Reading both in order shows the request, the options considered, the implementation, and the next steps each side owns.

### Asset request sub-pattern

A common case: app needs custom art / audio / icon / illustration assets that hub's asset pipelines can generate (or that need a new pipeline). Use the handoff mechanism — don't generate assets in the app repo session, and don't request via Slack / out-of-band.

**Naming**: `HANDOFF_FROM_APP_<ASSET_TYPE>.md` in the app's own `Docs/` (or `docs/`). Examples: `HANDOFF_FROM_APP_BIOME_TILE_ART.md`, `HANDOFF_FROM_APP_AUDIO_SFX.md`, `HANDOFF_FROM_APP_MASCOT_REFRESH.md`, `HANDOFF_FROM_APP_ICON_VARIANTS.md`.

**Required content for an asset request**:

- **What's needed** — concrete table listing every asset (filename, what it represents, where it goes in the app repo)
- **Format constraints** — pixel dimensions, file format, color profile, alpha requirements, tiling rules, total bundle ceiling, naming convention
- **Style spec** — link to your `Docs/DESIGN_ART_DIRECTION.md` / `Docs/DESIGN_AUDIO_DIRECTION.md` or describe inline (palette, mood, art-style cluster name if portfolio-shared)
- **Bundle path** — exact path inside the app repo (`Libraries/Sources/SharedUI/Resources/Illustrations/`, `Libraries/Sources/Services/Resources/Audio/`, etc.)
- **What this unblocks** — the gameplay / UI feature waiting on these assets
- **Options considered** — including the interim placeholder shipping plan (always ship a placeholder so the app doesn't block on hub)
- **State at this handoff's commit** — current branch, ForgeKit pin, what code is in place expecting these assets

**Hub's possible responses**:

| Response | Trigger | Hub side |
|---|---|---|
| **Generate immediately** | Existing pipeline covers this asset class | Run `scripts/gen_app_<class>.py` + distribute to the app repo. Drop a `HANDOFF_FROM_HUB_<TOPIC>.md` confirming what shipped. |
| **Generate with extension** | Existing pipeline needs minor extension (new APP_CONFIGS entry, new cluster prompt) | Author the extension, run, distribute. Same handoff response. |
| **Plan + defer** | No pipeline exists; one-off would not justify the pipeline build | Author a `Docs/PLAN_NEW_ASSET_PIPELINES.md`-style planning doc in hub. Respond to the app with a `HANDOFF_FROM_HUB_*.md` explaining the defer + the trigger that would unblock build (typically 2nd app demand). |
| **Reject** | Asset class is too app-specific or violates portfolio conventions | Respond explaining why; suggest in-app pattern instead. |

**Apps in the interim**: always ship a placeholder. The handoff is async — don't block your release on hub picking it up.

### Asset generation ownership + handoff requirement (2026-05-19 STANDING RULE; reinforced 2026-06-01 R410 #888)

Hub **owns portfolio-wide asset generation — ALL asset classes, no exceptions** (user-direct 2026-06-01 "you own the audio generation. you own all asset generation"). Apps don't run any generative pipeline: not Gemini Nano Banana Pro/Flash, not Lyria 3, not ElevenLabs/Resemble/Play.ht voice gen, not any future asset-gen vendor. Hub runs them per `GUIDE_ILLUSTRATION_PIPELINE.md` + pipeline-specific guides.

#### R-HUB-OWNS-APP-RESOURCES — hub owns the FULL LIFECYCLE of app RESOURCE assets, including deletion (2026-07-27)

**Hub OWNS app repos' non-Swift RESOURCE assets end-to-end — create · distribute · post-process/modify · AND DELETE (`git rm`) — DIRECTLY, without gating any of it (deletion included) behind a per-app handoff. Ownership of "all asset generation" extends to the assets' whole lifecycle, not just their creation.** Codified per founder-direct 2026-07-27 (*"hub owns app resources. codify this"*). This is the natural completion of the asset-generation-ownership rule above (hub already CREATES + DISTRIBUTES every asset class) — the missing piece was that hub may also RETIRE/DELETE and otherwise manage those same assets in place.

**Scope — what "app resources" means:** every non-Swift content asset hub generates/distributes — question kits (`*.json`), illustrations · mascots · cast portraits · chapter art · book covers · badges (`*.webp`), audio (`*.m4a`/`*.caf`), particle/hub configs, manifests — wherever it lives in an app repo: `Resources/**` AND asset bundles nested under an SPM `Sources/**/Resources/**` target (e.g. `Libraries/Sources/SharedUI/Resources/…`). A resource asset that happens to sit under a `Sources/` SPM target is STILL a resource, not source — hub owns it.

**The hard line is UNCHANGED — this does NOT relax the Swift/Xcode SOURCE prohibition (CLAUDE.md § CRITICAL):** hub still MUST NOT write, edit, or `git rm` any `.swift`, Swift test, `Package.swift`, or `.xcodeproj`/`.xcworkspace`/`.pbxproj`/`.xcscheme`/`.xctestplan` file in an app repo. The distinction is FILE-TYPE, not directory: source/project files = never; resource assets = hub-owned.

**Discipline when hub deletes/changes an app resource:**
1. **Pathspec-scoped git ops** — `git rm <exact-paths>` / a scoped `git add <path>`, never `git add -A`/`.` (portfolio.md § Distribution scripts + workflow.md § R-PARALLEL-HUB-AGENTS discipline 6).
2. **Handoff RECORDS, no longer REQUESTS** — when the resource change needs an app-side follow-up (e.g. the app's Swift references a now-deleted asset), file/update the per-app `HANDOFF_FROM_HUB_*.md` NOTING what changed so the app session drops the reference. For a **provably-inert** asset (excluded from build / un-wireable — e.g. an ADR-022-retired avatar accessory) a commit message suffices; no handoff needed.
3. **Don't yank a wired asset out from under a live build uncoordinated** — delete/replace freely when the asset is provably inert or the swap is coordinated; if an active build wires it, do the swap + note it so the app session isn't broken.

**Reference:** 2026-07-27 hub directly `git rm`'d the 9 retired `AvatarShared/accessories/*` assets from `measurequest-app` (ADR-022, inert; PR #24) — the action that prompted this codification. This **SUPERSEDES** the prior "this is app-owned cleanup; hub does not `git rm` app source/resources" carve-out in `.claude/rules/forgekit.md` § RETIRED accessory convention (corrected in the same change). **Cross-refs:** CLAUDE.md § Allowed writes + § CRITICAL never-list (the FILE-TYPE line) · `.claude/rules/forgekit.md` § RETIRED accessory convention · § Asset Consumer Audit (registered ≠ wired) · § R-ASSET-GEN-COMPLETENESS (the gen-lifecycle sibling).

**Covered asset classes** (non-exhaustive; hub owns ALL):

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
| **Background music (Pipeline 3, lifted 2026-06-04)** | `scripts/gen_app_background_music.py` (lifted from `quillspell-app/Scripts/generate_music.py` per user-direct 2026-06-04) | Google Gemini Lyria 3 Pro (`lyria-3-pro-preview`) canonical; Lyria 3 Clip for cheaper 30s outputs | ~$0.40/track Lyria 3 Pro preview; ~$0.10/clip Lyria 3 Clip. Per-app ceiling: ~$3.20 for typical 8-track app (4 music + 4 ambient) |
| **Achievement badges (Pipeline 4, shipped 2026-06-04)** | `scripts/gen_app_badges.py` (standalone; per-app manifest at `Resources/CustomArt/<app>/badges.json`); rarity-tier frame treatment merged at gen time | Gemini Nano Banana Flash (`gemini-3.1-flash-image-preview`) | ~$0.045/badge Nano Banana Flash. Per-app ceiling: ~$1.04 for typical 23-badge catalog (matches BioForge `AchievementBadgeCatalog`) |
| Particle specs | future pipeline | TBD | TBD |
| Lottie celebrations | curated; not gen | N/A (hand-authored / sourced) | N/A |

**Pre-generation discipline** (R409 #882): for audio drama specifically, content is **pre-generated hub-side + bundled as static `.caf` per app**. Apps play from local Bundle only — no streaming, no runtime gen, no server round-trip. Inherits to future audio assets unless explicitly superseded by ADR. See `Docs/PLAN_DN_S_PHASE_2_AUDIO_DRAMA.md` § Load-bearing architectural directive.

Cost discipline: stay within published per-class ceilings. New asset classes added to this table when first vendor pipeline is exercised; cost ceiling set per founder approval BEFORE first gen run.

**Standing rule — every asset distribution wave MUST file a per-app handoff doc.** When `scripts/copy_<kind>_to_repos.sh` ships assets to an app's `Resources/` directory, the same wave MUST also file `Docs/HANDOFF_FROM_HUB_<KIND>.md` (canonical, 2026-06-11+) in that app's repo. Pre-2026-06-11 waves used `HANDOFF_FROM_LABSMITH_<KIND>.md` (preserved). The handoff explains:

- **What shipped**: exact file paths + counts (e.g., "5 mascot poses + 70 joke illustrations + 91 topic illustrations under `Resources/Illustrations/`")
- **How to consume**: ForgeKit module + view pattern (e.g., `ForgeIllustrations.IllustrationRegistry` for illustrations, `ForgeAvatar.AvatarAssetCatalog` for accessories, `SFXLibrary` for audio)
- **Manifest schema**: where `illustrations.json` / `accessories.json` / similar manifests live + format
- **App-side integration tasks**: register the bundle, wire `IllustrationResolver`, add fallback content for unavailable assets, configure Reduce-Motion variants
- **What's NOT included**: anything the app session needs to do (e.g., "add Lottie celebrations to your CelebrationCatalog", "wire the mascot to your AI mentor persona")

**Why the rule exists**: 2026-05-19 portfolio audit (per `Docs/AUDIT_ILLUSTRATION_HANDOFF_BACKFILL.md`) found 40+ apps with bundled illustrations BUT zero per-app handoff docs. Implementing sessions had to reverse-engineer the bundled structure. The pipeline shipped assets but skipped the integration handoff. This rule closes that gap.

**For existing assets without handoffs**: backfill per the audit doc, prioritizing mature/active apps first (those with substantial LOC and recent commits).

**For new asset generation waves**: the pipeline script MUST file the handoff in the same wave. Recommended pattern: extend `scripts/copy_<kind>_to_repos.sh` to also copy a per-app handoff template from `spark-anvil-hub/Docs/TEMPLATE_IMPLEMENTATION_HANDOFF_<KIND>.md` (filling app-specific variables). Don't skip the handoff because "the template covers it" — each app's CC session needs the doc in its OWN repo, not a pointer to hub.

### Asset Consumer Audit (2026-05-20 STANDING RULE — closes CubeSensei ASSET_CONSUMER_AUDIT inbound #22)

**Registered ≠ wired.** When an app session adopts a hub-delivered asset handoff (illustrations / mascots / topics / backdrops / modecards / portraits / accessories / icons), the Definition of Done MUST include:

1. **Grep for a consumer call site** — at least one view in the app's `Sources/` directory must actually render the asset class via `IllustrationRenderer`, `BackdropView`, `MascotReactionView`, `IllustratedJokeView`, `AvatarRenderer`, `topicContentKey(...)`, or equivalent. `grep -rE 'IllustrationRenderer|BackdropView|MascotReactionView|IllustratedJokeView|topicContentKey|AvatarRenderer|JokeOfTheDayCard' <app>/Packages/Libraries/Sources/`
2. **Zero hits = shipped-but-dark** — `IllustrationRegistry` / `AvatarAssetCatalog` registration alone does NOT mean the asset is visible to the user. File a follow-up wiring task or open an app-internal ticket BEFORE closing the handoff
3. **Auditor**: the app session that adopts the handoff (not hub) does the audit. The hub-side handoff (`HANDOFF_FROM_HUB_<KIND>.md` canonical, or `HANDOFF_FROM_LABSMITH_<KIND>.md` legacy) lists the consumer-view patterns to look for under "How to consume" — apps grep for those patterns before marking the handoff CLOSED

**Why the rule exists**: CubeSensei discovered 120 illustrations registered in `IllustrationRegistry` but not rendered by any view — silently dark on production-track main for several days. The session was answering "yes, delivered" based on registry registration alone. This rule closes that gap.

**Companion to the asset-delivery rule above**: the asset-delivery handoff ships the bundle + integration guidance; the consumer-audit step verifies the integration actually wired in.

**Templates** (already shipped):

- `spark-anvil-hub/Docs/TEMPLATE_IMPLEMENTATION_HANDOFF_ILLUSTRATIONS.md`
- `spark-anvil-hub/Docs/TEMPLATE_IMPLEMENTATION_HANDOFF_PASS_AND_PLAY.md`
- `spark-anvil-hub/Docs/TEMPLATE_IMPLEMENTATION_HANDOFF_SERVER.md`
- (Future): `TEMPLATE_IMPLEMENTATION_HANDOFF_MASCOT.md`, `_ACCESSORIES.md`, `_AUDIO.md`, `_BIOME_TILES.md`, `_PARTICLES.md` — author as each pipeline ships its first asset wave

### R-ASSET-GEN-COMPLETENESS — every gen pipeline has a completeness guard; pick the SHAPE by blast-radius × criticality; the gap is never silent (2026-07-19)

**Every asset-generation pipeline (illustrations · mascots · cast portraits · chapter art · book covers · badges · music · SFX · texture atlases · icons · audio drama · question kits · biome tiles) MUST have a completeness guard that AUTO-DETECTS a missing asset from on-disk ground truth and SURFACES the gap — a generated asset can never be silently un-shipped. The guard comes in one of TWO shapes, and choosing the right one is load-bearing:**

| Shape | When | Behavior |
|---|---|---|
| **A. Build-fail gate** | The asset is **required for correctness** AND its absence breaks something with a **local blast radius** (a wrong kit answer; a portrait slug → a 404 that's the only image on the page). | A prebuild/postbuild check **FAILS the build** naming the missing asset. Reference: `R-CAST-PORTRAIT-SLUG` · `R-MULTIBEAT-SNAPSHOT` · kits `kits.test.ts` · `check-site-internal-links`. |
| **B. Fail-safe placeholder + tracked queue** | The asset is **cosmetic / degrades gracefully**, OR a build-fail would take down **unrelated surfaces** (a per-chapter hero blocking a whole-unit deploy). | A prebuild manifest → the surface renders a **placeholder** (build stays green) + a **committed pending-queue** (diff surfaces in the PR) + a **loud build-log warning** + a codified **drain obligation**. Reference: `R-CHAPTER-ART-COMPLETION` (`spark-anvil-website.md`). |

**The load-bearing lesson (why the shape matters):** chapter hero art *had* a shape-A guard (the link-checker) — and blocking a whole core deploy over a **cosmetic** missing hero (2026-07-19, § R-CHAPTER-ART-COMPLETION / § R-BUILD-FAILURE-READ-FULL-LOG-FIRST) was the disease. The fix was to move that class to shape B. So: **an OPTIONAL/cosmetic asset's absence must NEVER be able to fail the build** (shape B); a **REQUIRED-for-correctness** asset's absence should (shape A). When unsure, ask: "if this asset is missing, is the feature *wrong/broken* (→ A) or just *visibly incomplete* (→ B)?" and "does a block here take down anything *unrelated*?" (if yes → B).

**Invariant for BOTH shapes — never silent:** the gap is (1) auto-detected from ground truth every build (a scan/manifest, never a hand-maintained list), (2) surfaced (a committed queue/manifest whose diff shows in the integration PR + a build-log line), and (3) carries a **drain/fix obligation** checked at round/wave-close. A gen pipeline whose missing-asset case is invisible until a founder notices is the defect this rule forbids — the same "registered ≠ wired" root as the Asset Consumer Audit above, one level out (generated ≠ shipped-and-visible).

**Current coverage (2026-07-19/20 scan) — the site-served per-app gen-asset classes {cast-portrait · chapter-beat · book-cover · mascot · icon} are now ALL guarded:**
- ✅ **Automated guard exists:** cast portraits (`check-cast-portrait-coverage.py`, A) · multibeat snapshot (`check-multibeat-snapshot-coverage.py`, A) · chapter hero art (`build-chapters-pending-art-manifest.mjs`, B) · **multi-beat chapter COVERAGE (`build-chapters-pending-multibeat-manifest.mjs`, B-tracking-queue — WARN-only, single-beat chapters render fine so no placeholder/build-fail; committed `Docs/REGISTRY_CHAPTERS_PENDING_MULTIBEAT.txt` surfaces the still-single-beat backlog every build; site PR #1110; § R-CHAPTER-MULTIBEAT-COMPLETENESS)** · **`/play` mascots (`build-mascots-pending.mjs` + the `check-site-internal-links.py` `onerror`-guarded-`<img>` excuse, B — site PR #1077; ⚠ **age-band-aware** since site PR #1166 — it reads `ageBand` from `clone.meta.ts` and puts `15-18` clones in a machine-parseable `# EXCLUDED (15-18 — R-OLDER-TEEN-DN-ADAPTED, no cutesy mascot):` block, NOT the drain queue [the teen band uses realistic personas + a neutral card fallback, so a cutesy mascot is a *rule-violating non-gap*]. **Reusable principle: a gen-asset completeness guard MUST respect the R-OLDER-TEEN age-band exclusion — never flag a 15-18 clone as "pending" a cutesy mascot/chapter/cover.**)** · **book covers (`build-book-covers-pending.mjs`, B — site PR #1077; the `/books` consumer already degrades to a "Meet the Cast" fallback)** · **app icons — TWO guards (the second closes the first's blind spot): (1) `build-icons-pending.mjs`, B — site PR #1094; checks apps that ALREADY declare a non-null `iconPath` → a set-but-missing file; all 6 icon `<img>` sites `onerror="this.remove()"`-hardened; ships 0 pending. ⚠ It is BLIND to active apps with NO icon at all (NULL iconPath) → reports "0 pending" while the real gap is unseen. (2) `check_icon_coverage.py` + `Docs/REGISTRY_ICON_COVERAGE.txt`, B — hub, 2026-07-28 (V633); over the 195-app active registry: 143 covered · 22 EXCLUDED (younger-cluster = mascot IS the adult-card identity, R-APP-ICON-SURFACE) · 30 PENDING (15-18 + 9-14 spawns, founder-gated `gen_missing_icons.py`). Machine-parseable `# ICON-EXCLUDED:` lines preserved across `--write-registry`; WARN-only. § R-APP-ICON-SURFACE / ADR-078)** · question kits (`kits.test.ts`, A) · R2 audio upload (`audit_r2_upload_coverage.py`) · asset backup (`audit_asset_backup_coverage.py`) · **PDF chapter-books (`check_pdf_book_coverage.py` + `Docs/REGISTRY_PDF_BOOK_COVERAGE.txt`, B — hub, 2026-07-28 V634; TWO dimensions: COVERAGE [138 covered · 22 EXCLUDED (15-18 no-cutesy-book) · 10 DEFERRED · 25 PENDING] + FRESHNESS [all 138 covered rendered 2026-06-25 < MULTIBEAT_EPOCH 2026-07-27 → STALE, need regen with real multi-beat illustrations]; both founder-gated render waves; supersedes the expired informational `audit_pdf_multibeat_coverage.py`; § R-PDF-BOOK-COVERAGE)** · **humor seed banks (`check_humor_seed_coverage.py` + `Docs/REGISTRY_HUMOR_SEED_COVERAGE.txt`, B — hub, 2026-07-29; content-pipeline #6, 70/app puns·riddles·absurd·facts; over the 195-app registry: 118 covered · 1 EXCLUDED (aggregator) · 28 DEFERRED (younger bands, auto via `ageBand`) · 48 PENDING (9-14/15-18 drain, founder-gated in-session-Opus authoring). Supersedes the stale CLOSED `AUDIT_HUMOR_SEED_COVERAGE.md` (131-app "100%"); WARN-only. § R-HUMOR-SEED-COVERAGE)** · site links (`check-site-internal-links.py`, A) · untracked assets (`check_untracked_assets.py`).
- ⛔ **iOS-bundle-only → NO automated site guard warranted (verdict, 2026-07-20 ground-truth: these render 0× on the Cloudflare-deployed site):** the rest of the illustration family (joke / topic / backdrop / modecard, `gen_app_illustrations.py`) · achievement badges (`gen_app_badges.py`) · background music (`gen_app_background_music.py`) · texture atlases (`gen_app_texture_atlases.py`) · the iOS *app-icon asset catalog* (`gen_app_icons.py` — distinct from the site's `public/apps/<slug>/icon.webp`, which IS guarded above). A `grep` of `src/` confirms none is referenced by any Astro page/component, so a shape-A build-fail there is **impossible** and a shape-B queue would track an asset **no site build consumes** — the **manual `Asset Consumer Audit`** (§ above, run at iOS adoption time) is their correct + sufficient guard. Do NOT build a site guard for these; if a future site surface ever *starts* rendering one of these classes, re-verdict it (it would become deploy-relevant → add a guard then).
- **The `onerror="this.remove()"` excuse pattern (site PR #1077) is reusable:** a cosmetic site `<img>` that degrades to a fallback should carry `onerror="this.remove()"` (the core `check-site-internal-links.py` now excuses such refs → shape B, never fails the build) AND be paired with a committed pending-queue + build-log warning so the gap stays tracked — the excuse WITHOUT the queue would re-introduce silence.

**⚙ THE ONE-COMMAND AGGREGATE STATUS (the "codify everything" umbrella, 2026-07-29).** The per-class guards above answer "is class X covered?"; the META-question — "what is the status of ALL generated assets?" — is answered by ONE command: **`python3 scripts/check_gen_asset_coverage.py`** (the gen-asset sibling of `check_spawn_completeness.py`). It runs every hub-runnable guard (icons · PDF books · book-cover anatomy · humor seeds · cast portraits) + reads the committed registries (mascots · multi-beat chapters · chapter hero art) + NAMES the deliberate exemptions — one screen, WARN-only, exit 0 (shape-B aggregate). Use it for any "status of the assets?" question instead of re-running ~8 scattered guards. Baseline 2026-07-29: icons 173/22excl/**0 pending** · PDF books 163/**0 pending** (but FRESHNESS-stale, § R-PDF-BOOK-COVERAGE) · book-cover anatomy **0 defect**/10 borderline · humor seeds 118/1/28/**48 PENDING** · cast portraits **195/195** surfaced (3 PARTIAL portrait gaps — WARN) · mascots **3 pending**/13 excl · multi-beat chapters **682 single-beat / 147 apps** (the big DEFERRED drain) · chapter hero art **0 pending**.

**COMPLETENESS INVARIANT — every gen-asset class is EITHER standing-guarded OR a documented exemption; none is silently ungoverned.** The DELIBERATE EXEMPTIONS (documented non-gaps, NOT accidental omissions): the **iOS-bundle-only** classes — joke/topic/backdrop/modecard **illustrations**, achievement **badges**, background **music**, **texture atlases**, and the iOS **app-icon asset catalog** — have **NO hub source-of-record file AND render 0× on the deployed site** (verified 2026-07-20 + re-verified 2026-07-29 — no `IllustratedJoke`/`topicContentKey`/`joke_*.webp` consumer anywhere in `src/`), so there is nothing hub-side or site-side to auto-guard against; their completeness is the app-session's **manual Asset Consumer Audit** (§ Asset Consumer Audit). A site/hub coverage guard for these would track assets no build consumes → it is correctly NOT built. (Contrast humor SEEDS, which ARE hub-authored `CONTENT_HUMOR_SEEDS_<APP>.md` source files → a hub guard is warranted + shipped, § R-HUMOR-SEED-COVERAGE.) **If any exempt class ever gains a hub source-of-record or a deployed-site surface, it graduates from exemption to a standing guard in that same wave.**

**When it applies:** authoring a NEW gen pipeline (ship its completeness guard in the same wave — pick the shape; if the class is iOS-bundle-only with no ground truth, record the exemption in this rule instead); reviewing a gen wave (a pipeline with no completeness guard AND no documented exemption, or a cosmetic asset behind a build-fail gate, or a silent missing-asset case, is a defect); any "status of the assets? / why did the build break / why is this surface dark" investigation (run `check_gen_asset_coverage.py`, then the specific guard + its queue). **Cross-references:** `scripts/check_gen_asset_coverage.py` (the aggregate dashboard) · § Asset Consumer Audit (the manual parent + the exempt-class guard) · `.claude/rules/spark-anvil-website.md` § R-CHAPTER-ART-COMPLETION (the shape-B reference) + § R-CAST-PORTRAIT-SLUG + § R-MULTIBEAT-SNAPSHOT (shape-A references) + § R-BUILD-FAILURE-READ-FULL-LOG-FIRST (the incident that taught the shape choice) + § R-R2-AUDIO-UPLOAD-COMPLETENESS · § Asset generation ownership (the pipelines this governs).

### R-HUMOR-SEED-COVERAGE — the 70/app humor seed bank (puns·riddles·absurd·facts) is a GUARDED per-app content class; a bank-less active app is never silently forgotten (2026-07-29)

**The humor seed bank (content pipeline #6 — 70/app: 20 puns + 20 riddles + 15 absurd + 15 fun facts, the `ForgeJokeData` schema) is a FIRST-CLASS per-app authored content class on the same footing as question kits (dim 7), cast portraits, icons, and PDF books — so it carries a STANDING self-checking coverage guard, NOT just a one-time audit. Every ACTIVE portfolio app MUST have EITHER an authored bank (`Docs/CONTENT_HUMOR_SEEDS_<APP>.md`) OR a machine-parseable `# HUMOR-EXCLUDED:`/`# HUMOR-DEFERRED:` line in `Docs/REGISTRY_HUMOR_SEED_COVERAGE.txt`. An active app with NEITHER is a silently-forgotten humor-bank gap.** Codified per founder-direct 2026-07-29 (*"jokes/puns/riddles kits … are silently forgotten. codify this"*). This is the humor-seed sibling of § R-ASSET-GEN-COMPLETENESS (it IS an instance of that pattern) and a per-app content dimension alongside the § R-SPAWN-COMPLETENESS-DIMENSIONS set.

**Why it was silently forgotten (the exact failure this closes):** the ONLY prior coverage artifact was `Docs/AUDIT_HUMOR_SEED_COVERAGE.md` — a **CLOSED, point-in-time audit dated 2026-05-12, frozen at the 131-app era, claiming "100%"**. The portfolio then grew to **195 active apps with NO standing guard re-checking the class**, so **77 newer/spawned apps silently shipped with no jokes/puns/riddles bank** while the CLOSED audit still read 100% (R-CANONICAL-DOC-GROUND-TRUTH: a stale CLOSED "100%" audit IS the drift). A CLOSED audit can never be the guard — a self-checking registry that re-derives from ground truth every run is.

**SHAPE B (WARN-tracked, never build-fail):** both the iOS `ForgeJokeData` joke surface AND the web `HumorBreak` boundary island (`spark-anvil-website.md` § R-WEB-CLONE-HUMOR-BREAK / ADR-079) DEGRADE GRACEFULLY when no bank exists — the joke/brain-break simply doesn't render; the app is fully usable. So a missing bank is a WARN, `--ci-mode` exits 0.

**The guard:** `python3 scripts/check_humor_seed_coverage.py [--ci-mode] [--write-registry]` over the canonical 195-app registry → the committed `Docs/REGISTRY_HUMOR_SEED_COVERAGE.txt`. Classification (baseline 2026-07-29: **118 covered · 1 excluded · 28 deferred · 48 PENDING**): **COVERED** (bank present); **DEFERRED** — younger bands (`ageBand` 3-5/6-8 in the site clone's `clone.meta.ts`, auto-classified) get a register-appropriate/audio-first humor set, NOT the text-heavy 70-joke bank (§ R-YOUNGER-BAND-CONTENT-REGISTER) — plus hand-authored `# HUMOR-DEFERRED:`; **EXCLUDED** — aggregator/launcher/infra/out-of-band, hand-authored `# HUMOR-EXCLUDED:` (preserved across `--write-registry`); **PENDING** — the genuine 9-14 / 15-18 drain (author a band-appropriate 70-seed bank via **in-session Opus** — 15-18 = mature register, § R-OLDER-TEEN-DN-ADAPTED, no cutesy; founder-gated, single-flight the shared Gemini/gen resources per § R-GEMINI-KEY-SERIAL).

**When it applies:** authoring/reviewing any humor-bank work; any "is the humor-seed program complete?" status question (run the guard, never trust the stale CLOSED audit — that audit now carries a superseding banner pointing here); a new spawn (verify its bank lands, or add a documented exclusion/defer — the spawn-completeness obligation). The **web** rollout of an authored bank (porting it to the `HumorBreak` island) is tracked separately by `Docs/REGISTRY_HUMOR_BREAK_COVERAGE.txt` (§ R-WEB-CLONE-HUMOR-BREAK) — this rule guards the SOURCE bank; that registry guards the web SURFACE. **Cross-refs:** § R-ASSET-GEN-COMPLETENESS (the parent self-checking-registry pattern) · § R-SPAWN-COMPLETENESS-DIMENSIONS (the per-app content dimensions this joins) · `spark-anvil-website.md` § R-WEB-CLONE-HUMOR-BREAK + § R-WEB-CLONE-BRAIN-BREAKS + § R-GEMINI-KEY-SERIAL + § R-YOUNGER-BAND-CONTENT-REGISTER · `distributed-narrative.md` § R-OLDER-TEEN-DN-ADAPTED · `Docs/REGISTRY_HUMOR_SEED_COVERAGE.txt` + `scripts/check_humor_seed_coverage.py` + `Docs/AUDIT_HUMOR_SEED_BANK_QUALITY_2026-07-29.md` (the correctness/quality sibling — a wrong riddle answer is a defect).

### Reference examples (asset request sub-pattern)

| App | Asset request | Hub response | Outcome |
|---|---|---|---|
| `labsmith-app` | mascot + topic illustrations | Generated immediately (added APP_CONFIGS for "experimental-notebook" cluster, ran pipeline) | 129 webp shipped in PR #18; humor seeds authored later (PR #20) for joke illustrations |
| `terravoyage-app` | biome tile art (140 tiles + particles) | Plan + defer | `Docs/PLAN_NEW_ASSET_PIPELINES.md` captures the build plan; deferred until 2nd app demand |
| `terravoyage-app` | themed SFX audio (7 CAFs) | Plan + defer | Same plan doc; deferred until Lyria API access or 2nd app demand |
| `geometryforge-app` | (implicit via Wave 30 commits) topic-thumbnail illustrations | Generated immediately via existing pipeline | Bundled to app repo as on-demand fill |

## R-SPAWN-COMPLETENESS-DIMENSIONS — a spawned app has ELEVEN silently-forgotten completeness dimensions; each has a standing guard OR a documented exclusion, so none goes dark (2026-07-21; expanded 6→11 2026-07-22)

**A newly-spawned portfolio app is not "done" when its repo + kits land — it opens ELEVEN distinct completeness dimensions (the founding six cast/clone dims + five added 2026-07-22: kits · chapter-gen · DN-S integration · iOS-bundle cast · guides), each of which can be silently forgotten because the *repo builds + looks fine* while the dimension is dark. Every active portfolio app MUST satisfy each dimension OR carry a machine-parseable documented exclusion, and each dimension has an owner + a standing GUARD (a self-checking registry/audit that flags a gap, never a hand-maintained list). An active app dark on any dimension with no exclusion is a coverage defect on the same footing as a missing gen-asset guard.** Codified per founder-direct 2026-07-21 (*"another dimension of silently forgotten gen is the cast characters for newly spawned app concepts … audit now … codify this lesson"* + *"do we have the canonical registry [of] all of the portfolio characters? codify this"* + *"[web clones of iOS apps] silently forgotten … codify"* + *"i meant cast roster too"*), after the `AUDIT_SPAWN_CAST_WEBCLONE_COMPLETENESS_2026-07-21.md` audit. This is the SPAWN-level umbrella that ties the per-dimension rules into one checklist — the sibling of `R-ASSET-GEN-COMPLETENESS` (gen assets) at the whole-app grain.

**The eleven dimensions (verify each per spawned app; the audit ground-truth query is in the audit doc). Dims 1–6 = the founding cast/clone set; 7–11 added per `AUDIT_SPAWN_COMPLETENESS_DIMENSIONS_EXPANSION_2026-07-22.md`:**

| # | Dimension | Ground-truth signal | Owner | Standing guard | Exclusion form |
|---|---|---|---|---|---|
| 1 | **DN cast ROSTER** (design) | `<app>-app/Docs/dn-s/README.md` with a named roster (≥ the band's cast-size floor — `distributed-narrative.md` § R-DN-CAST-SIZE / R-YOUNGER-CLUSTER-CAST-SIZE / R-BRIDGE-BAND-DESIGN / R-OLDER-TEEN-DN-ADAPTED) | hub (scaffolds at spawn, `PLAYBOOK_APP_SPAWN.md`) | `check_spawn_cast_coverage.py` ✅ SHIPPED (dims 3+5 hard-fail; 1+2 opportunistic) | aggregator/launcher/out-of-band per R-WEB-CLONE-COVERAGE-COMPLETENESS taxonomy |
| 2 | **Canonical character REGISTRY reservation** | every roster name present in `Docs/REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` (the canonical all-portfolio character registry — **YES, it exists**, 1,274 lines, 700+ reservations) | hub | same guard (cross-checks roster names ⊆ registry) | n/a — a real cast is always reserved |
| 3 | **Cast PORTRAITS** (gen) | `spark-anvil-site/public/cast/<app>/<slug>.webp` per roster member (R-CAST-PORTRAIT-SLUG) | hub (Gemini gen; R-GEMINI-KEY-SERIAL) | `check-cast-portrait-coverage.py` (per `R-ASSET-GEN-COMPLETENESS` shape-A) | 15–18 realistic-persona bands per R-OLDER-TEEN-DN-ADAPTED (no cutesy portrait) |
| 4 | **DN-S CHAPTERS — PROSE** (5-beat authoring) | `Docs/dn-s/chapters/*.md` (5-beat, gate-green) | hub (in-session Opus prose, R-COVERAGE-OPUS-AUTHORING) | narrative-quality + DIR/FEDC + register gates | younger-band activity-port DEFERRED |
| 5 | **Site SURFACING** (`apps.generated.ts` `dnCast` + `/cast`) | an `apps.generated.ts` entry with a non-empty `dnCast.members[]` (R-APP-REGISTER-MIRROR-SHAPE) | hub (site-owned) | the guard's set-difference (registry ∖ apps.generated.ts slugs) | n/a |
| 6 | **`/play` web CLONE** | a `planned`/`building`/`shipped` row in `Docs/REGISTRY_WEB_CLONES.txt` | hub | `check_web_clone_coverage.py --ci-mode` (ALREADY LIVE) + R-WEB-CLONE-SPAWN-TRACKED | `# EXCLUDED:`/`# DEFERRED:` per R-WEB-CLONE-COVERAGE-COMPLETENESS |
| 7 | **Question KITS / learning-content banks** (16×25 MC tween; ~10-12 bridge; younger activity; 15-18 varies) | band-appropriate kit banks anywhere in the app repo (kits live at heterogeneous paths — canonical/legacy/SPM/Packages — so ONLY a full-repo find is reliable; a path-glob false-flags kitted apps, per the 2026-07-22 audit) | hub (Phase 4a, in-session Opus, R-WEB-CLONE-KITS-OPUS-AUTHOR) | ✅ **`check_spawn_kit_coverage.py --ci-mode`** (full-repo find for cloned apps + `Docs/REGISTRY_SPAWN_KIT_COVERAGE.txt` `# KITS-{EXCLUDED,PENDING,SHIPPED}:` for FS-uninferable / uncloned apps; hard-fails a cloned zero-kit non-excluded app OR an uncloned+undocumented app) + per-item `audit_kit_questions.py` | `# KITS-EXCLUDED:` younger activity-bank (R-YOUNGER-CLUSTER-NO-MC-KITS) or bespoke problem/adaptive engine |
| 8 | **DN-S CHAPTERS — GEN** (beat art + TTS narration + `/cast/<app>/<char>` route + R2 upload) | rendered beat assets + audio + the live `/cast` page | hub (Gemini single-flight, R-GEMINI-KEY-SERIAL) | `build-chapters-pending-{art,multibeat}-manifest.mjs` + `REGISTRY_CHAPTERS_PENDING_*.txt` + `audit_r2_upload_coverage.py` + `check-site-internal-links.py` (ALL LIVE — the render half of dim 4) | younger-band activity-port DEFERRED |
| 9 | **DN-S INTEGRATION** (Move B per-kit `castCameos[]` + Move D / TeachableCast AI-mentor voicing) | cast wired into kits (cameos) + a mentor surface — authored ≠ integrated (R-CAST-EXPANSION-INTEGRATION) | hub (web) + app-session (iOS) | web: `audit_web_clone_surface_wiring.py` (⚠ **AGE-BAND-AWARE** since 2026-07-22 — a 15-18 clone's narrative-integration check looks for the adapted `<CaseNarrative>`/`<TeachableCast>` surface, NOT the tween `<PlayNarrative>`; expecting `<PlayNarrative>` on a 15-18 clone is a rule-VIOLATING false flag per R-OLDER-TEEN-DN-ADAPTED — the same age-band-exclusion principle as the mascots guard, § R-ASSET-GEN-COMPLETENESS); iOS: manual | solo-reflection/creative ⛔-waives cameos/mentor per R-CAST-EXPANSION-INTEGRATION |
| 10 | **iOS-bundle CAST assets** (`<app>-app/.../Resources/Cast/*.webp` + `CastMember.all` roster) | app-bundle portrait + roster entry (dim 3 is SITE-only; iOS Move B needs both) | hub ships asset; app-session writes roster Swift (R-CAST-EXPANSION-INTEGRATION axis 4) | **manual Asset Consumer Audit** — iOS-bundle → renders 0× on site, no hub/site guard warranted (same verdict as R-ASSET-GEN-COMPLETENESS iOS-bundle-only classes) | non-DN / aggregator apps |
| 11 | **User + Developer GUIDES** (`GUIDE_<APP>_{WEB,IOS}_{USER,DEVELOPER}.md`) | guides authored + kept in sync with code | hub (web) + app-session (iOS) | review-discipline + opt-in iOS pre-push guide-touch hook (R-APP-GUIDE-SYNC / R-WEB-CLONE-GUIDE-SYNC — no automated CI gate per the per-surface decision) | trivial/pre-flagship apps stage web-first |

**The load-bearing lesson — "repo builds + roster looks fine" ≠ "cast is done."** The 2026-07-21 audit found all 170 site apps have casts AND all 21 newest off-site spawns have a `Docs/dn-s/README.md` roster AND all 21 are already in the canonical character registry — yet **zero of the 21 have cast portraits or `apps.generated.ts` surfacing**, so on the *site* they read as cast-less. The founder's "decodeforge + 3 missing" impression was a SURFACING/GEN gap (dims 3+5), not a roster/registry gap (dims 1+2) — decodeforge in fact has a full roster + 13 chapters. So the dimensions are INDEPENDENT: a spawn can pass 1+2+4 and silently fail 3+5+6. Audit each dimension separately; never infer "cast done" from the roster alone (R-CANONICAL-DOC-GROUND-TRUTH).

**The guard (✅ SHIPPED, hub-owned):** `scripts/check_spawn_cast_coverage.py --ci-mode` — for every active app in `REGISTRY_ACTIVE_PORTFOLIO_APPS.txt` it HARD-FAILS on (a) an app with NO site cast surfacing (no non-empty `apps.generated.ts dnCast.members[]`, dim 5) and NO documented exclusion, OR (b) a SURFACED app whose cast is FULLY-DARK (dnCast but ZERO `public/cast/<app>/<slug>.webp` portraits → broken "Meet the cast", dim 3, R-CAST-PORTRAIT-SLUG). Documented exclusions/deferrals live in `Docs/REGISTRY_SPAWN_CAST_COVERAGE.txt` as machine-parseable `# CAST-EXCLUDED:`/`# CAST-DEFERRED: <app> — <reason>` lines (15–18 adapted-DN-S + aggregators are CAST-EXCLUDED → portrait-exempt, honoring R-OLDER-TEEN-DN-ADAPTED). Portrait slugs are matched via the canonical `slugChar` + `cast-slug-map.json` ported from `spark-anvil-site/src/lib/castSlug.ts` (a naive slug match gives FALSE fully-dark on flagships — spot-check before trusting a portfolio-wide gap count). A PARTIAL portrait gap is a WARN (report), not a hard-fail. Dims 1+2 (roster/registry) are opportunistic INFO when the app repo is cloned locally (the hub CI may not have sibling repos). Dims 4+6+7+8+9 have their own live guards (narrative/DIR-FEDC gates · `check_web_clone_coverage.py` · `audit_kit_questions.py`/`audit_web_clone_banks.py` · `build-chapters-pending-*`/`audit_r2_upload_coverage.py` · `audit_web_clone_surface_wiring.py`); dims 10+11 are owner-tracked (manual Asset Consumer Audit / review-discipline). **⚠ The guard reads the SITE inputs from the site repo's `origin/main` by DEFAULT** (best-effort `git fetch` + `git show`/`git ls-tree`, working-tree fallback; `--worktree` to override) — so a STALE local site clone can NEVER throw a false red (the GOTCHA-3 trap: a 107-commit-behind clone once flagged 8 already-surfaced apps as forgotten, 2026-07-22). **Dim 7 (kits) is guarded by `check_spawn_kit_coverage.py --ci-mode` + `REGISTRY_SPAWN_KIT_COVERAGE.txt`** (SHIPPED 2026-07-22; full-repo find for cloned apps — a path-glob is unreliable because kits live at heterogeneous paths — + registry lines for FS-uninferable/uncloned apps; 168 shipped · 0 pending · 27 excluded — dim-7 drain EMPTY, `AUDIT_SPAWN_KIT_COVERAGE_2026-07-22.md`).

**The ONE-COMMAND aggregate gate:** `python3 scripts/check_spawn_completeness.py --ci-mode` runs the three machine-checkable guards together (cast dims 1-5 · web-clone dim 6 · kits dim 7) and exits non-zero if ANY fails — run it at round-close / spawn-review instead of remembering each scattered guard. Dims 4/8/9 (chapter prose+gen, DN-S integration) have their own live guards; dims 10/11 are owner-tracked.

**When it applies:** spawning any app (walk all eleven at spawn + at each round-close, `PLAYBOOK_APP_SPAWN.md`; the aggregate gate above is the quick check); reviewing a spawn wave (a dark dimension with no exclusion is a defect); any "why is this app cast-less/kit-less/guide-less on the site?" investigation (check the specific dim, not just 1). **Cross-refs:** `Docs/AUDIT_SPAWN_COMPLETENESS_DIMENSIONS_EXPANSION_2026-07-22.md` (dims 7–11 + the origin/main guard fix) · `Docs/AUDIT_SPAWN_CAST_WEBCLONE_COMPLETENESS_2026-07-21.md` (dims 1–6 origin) · § R-ASSET-GEN-COMPLETENESS (the gen-asset sibling) · § R-NEW-APP-SPAWN-DOC + `PLAYBOOK_APP_SPAWN.md` (the spawn workflow) · `distributed-narrative.md` § R-CAST-EXPANSION-INTEGRATION (the 6-axis per-member integration debt this generalizes to whole-app) + § R-DN-CAST-SIZE + § name-collision discipline (the canonical registry) · `spark-anvil-website.md` § R-WEB-CLONE-COVERAGE-COMPLETENESS + § R-WEB-CLONE-SPAWN-TRACKED (dim 6, already codified) · § R-CAST-PORTRAIT-SLUG (dim 3).

## App Implementation Ranking Methodology (Round 106 #518; codified Round 114 #535)

When hub needs to produce a forward-looking ranking of which portfolio apps to BUILD next (founder-direct sequencing or routine ranking refresh), use the **6-axis weighted composite formula** codified in `Docs/DECISION_APP_RANKING_COMPOSITE_SCORING_2026-05-28.md`:

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

## New App Concept Fit-Assessment Methodology (R-NEW-APP-CONCEPT-FIT; 2026-07-15)

**When the founder proposes a NEW app concept (or a batch of them) — "does X fit the portfolio?" — assess it with this method, NOT the ranking formula above (that ranks EXISTING concepts for build order; this decides whether a NEW concept belongs at all).** Codified after the 2026-07-15 games/word-games batch (`Docs/RESEARCH_NEW_APP_CONCEPTS_GAMES_WORDS_FIT_2026-07-15.md`, work-queue V246), where the founder had to correct a naive "it's already listed in an academy app → done" reading — proving the load-bearing distinction below is not obvious.

### The load-bearing distinction — presence in a breadth academy ≠ waiver (the two-layer pattern)

**A subject/game appearing inside a cross-topic *breadth academy* app does NOT foreclose a dedicated *full-depth* app on the same subject.** The portfolio deliberately runs a two-layer pattern, and both layers legitimately coexist:

| Layer | What it is | Example |
|---|---|---|
| **Breadth / academy** | Teaches a *few transferable strategies/lessons* across many topics; NOT a deep full experience of any one | **StrategyForge** (a few strategy lessons across chess·Go·checkers·backgammon·mancala·Connect-4); **CardForge** (card-game genre) |
| **Dedicated full-depth (often DN)** | ONE subject/game rendered to full depth, usually via distributed-narrative character-embodied primitives | **GambitTales** (full chess); **DealTales** (full bridge) |

**The precedent is explicit: chess lives in BOTH StrategyForge (a few lessons) AND GambitTales (a full-depth DN app); bridge in both a card context AND DealTales.** So "an academy app already teaches X" is NOT a fit-waiver for a dedicated X app — the real bar is **standalone depth + differentiation from the academy's shallow treatment**, not mere presence. (Getting this wrong under-counts genuine gaps.)

### The method (per proposed concept)

1. **Adjacent-app census** — grep the registry + read the `CLAUDE.md` identity line of every plausibly-overlapping app; map the *actual* overlap surface. Distinguish academy-shallow coverage from dedicated-deep coverage (the distinction above).
   - **⚠ A RETIRED app is NOT a gap if its concept was ABSORBED into an active SUCCESSOR — verify the successor, not just the retired list (R-CANONICAL-DOC-GROUND-TRUTH; codified 2026-07-19 after the MintQuest error).** When a concept looks uncovered because an app is *retired* — OR when the founder asks *"should we revive \<retired app\>?"* — check `PORTFOLIO_PATTERNS.md` § Retired Repos for its **successor**, then GREP the successor's `CLAUDE.md` to confirm the concept is live. Most portfolio retirements are **retire-by-CONSOLIDATION** (absorbed into an active sibling), NOT abandonment — so the concept is alive and reviving/claiming-its-gap is a **duplicate (🔴)**. The 2026-07-19 incident: a LedgerQuest spawn doc claimed *"MintQuest is retired → no current finance app"* — false; MintQuest was absorbed into the **active VentureQuest** (+ MintForge/MarketQuest), and the spawn's real gap was the 15–18 **band-extension**, not "no finance app." Verifying the retired *list* is not enough; verify the *successor is inactive* before treating a retired concept as an open gap. (A revival is only warranted if the successor is ALSO gone AND the concept has a distinct, un-covered niche — rare.)
   - **⚠ A BAND's coverage comes from the LIVE `ageBand` grep, NEVER a prior research/handoff/spawn doc's "N shipped" count — a doc's count is a point-in-time snapshot that a subsequent spawn wave silently supersedes (R-CANONICAL-DOC-GROUND-TRUTH; codified 2026-07-21 after the 15–18 "3 shipped" error).** When assessing concepts for an age band (esp. the newer 3–5 / 15–18 bands whose spawn cadence outruns the docs), the AUTHORITATIVE app census is **`git grep -lE "ageBand.{0,4}<band>" origin/main -- 'src/data/play/*/clone.meta.ts'`** (the live `clone.meta.ts` `ageBand` field, § R-WEB-CLONE-AGE-BAND-ZONES) — plus each hit's `cluster` + `tagline` to map coverage-by-cluster. Do NOT trust a sibling research doc's shipped-list: the 2026-07-19 agency doc said the 15–18 band had **3** apps (LedgerQuest/StudyForge/NorthQuest), so the 2026-07-21 subject-sweep doc trusted that and proposed 6 "🟢 new" candidates — but a spawn wave had built **14** (calcquest/vaultforge/modelquest/agoraquest/codeforge/forceforge/reactquest/inquiryforge/protoforge/locusforge/nashforge + the 3), so ≥4 proposals (calculus→CalcQuest, crypto→VaultForge, AI-literacy→ModelQuest, civic→AgoraQuest) were **duplicates of already-shipped apps**. The fix (`AUDIT_15_18_BAND_COVERAGE_2026-07-21.md`): grep live `ageBand`, build the coverage-by-cluster map, and target only the genuinely-EMPTY clusters. Same class as the RETIRED-successor gotcha above + § R-NAME-CHECK-LIVE-APPS-GENERATED (grep the shipped reality, not a secondary doc). **Reconcile the stale source too** — when the live grep contradicts a doc's count, correct that doc in the same round (R-CANONICAL-DOC-GROUND-TRUTH), don't just avoid copying it.
   - **⚠ The LIVE-app census is NECESSARY-BUT-NOT-SUFFICIENT — a band's CONCEPT PIPELINE also includes ALREADY-ASSESSED 🟡 / wave-2 / deferred concepts recorded in the PRIOR spawn ADRs' research docs, so "empty in the live `ageBand` grep" ≠ "an un-assessed gap" (codified 2026-07-21, same round, one layer deeper).** After the live-app census flagged the 15–18 ELA + arts + SEL-affect clusters as empty, a follow-up read of the prior 15–18 spawn ADRs (058/059) found **ELA was already assessed as ADR-059 C6 "ProseForge/RhetorQuest" (🟡→🟢 wave-2) and creative-coding as ADR-058 A1 "GenForge" (🟡 deferred)** — so 2 of the 3 "new gaps" were *already-assessed-and-deferred*, not novel (only SEL-affect was genuinely un-assessed). So the concept-fit census is TWO reads: (a) **live `ageBand` grep** → which clusters have shipped apps; AND (b) **the prior spawn ADRs' research docs for that band** (`RESEARCH_NEW_APP_CONCEPTS_*_<band>_*.md` → their 🟢/🟡/🔴/wave-2 concept lists) → which concepts are already assessed-but-deferred. Propose "new" only for a cluster/concept empty in (a) AND absent from (b); an already-assessed 🟡 is a **founder-elevate-from-wave-2** decision, NOT a fresh scope (re-scoping a deferred 🟡 is a duplicate on the same footing as re-building a shipped app).
2. **Standalone-depth vs bundle vs mode test** — is the concept deep enough to sustain a full ~16-kit DN app for the target age, or is it a **single thin mechanic**? A single-mechanic concept (e.g. Connect-4, Mastermind alone) is thin as its own app → **bundle** it into a family app (e.g. a Connection/Territory-games app, a Deduction app) or ship it as a **mode** inside an existing app, rather than a standalone title. Say so explicitly; "it's a classic" is not depth.
3. **Curricular-value grounding** — back the pedagogy claim with evidence (focused web research), portfolio-style; note honest caveats (population/transfer limits). No padding.
4. **DN swap-test applicability** — can the concept decompose into character-embodied primitives whose *defining act IS the rule* (R-DN-PARITY)? A concept that can't (a bare abstract mechanic) is a bundling/mode signal, not a DN-app signal.
5. **Cross-cutting gates** — pillar/cluster placement, name-registry availability, trauma-gate check, `/play` web-clone + iOS-backport potential.
6. **Founder-gate the disposition** — adding a title is a **founder-level portfolio-shape decision** (the portfolio has a standing app-count ceiling). The assessment produces a *recommendation*; the founder greenlights. Record the analysis at `Docs/RESEARCH_NEW_APP_CONCEPTS_*_<date>.md` + a work-queue entry; on approval, the next phase is a per-app concept/spawn doc + the ranking assessment above.

**Verdict vocabulary:** 🟢 build-worthy gap · 🟡 conditional (bundle or mode) · 🔴 do-not-build-standalone. A founder MAY approve past a 🟡/🔴 (as on 2026-07-15) — then the hedge becomes a per-app *shape* decision (standalone vs bundle vs mode), not a ship gate.

**⚠ A RECOMMENDATION/roadmap doc that NAMES candidate "new" apps MUST ground-truth every name against `REGISTRY_ACTIVE_PORTFOLIO_APPS.txt` + `apps.generated.ts` BEFORE treating it as a spawn (R-CANONICAL-DOC-GROUND-TRUTH applied to your own recommendations; 2026-07-20).** A prior research/needs doc can name an app as "needed" while it *already exists as a full shipped app* — proposing to spawn it is then a 🔴 duplicate, and the real bet is **deepen-existing**, not spawn. Reference incident: an innovation-recommendation named AiForge · NeuralQuest · FocusForge · MindForge as candidate builds; a registry + `CLAUDE.md` census found **all four already shipped** (full DN casts + `/play` clones) → R3/R6 were corrected "spawn"→"wire the feature into the existing app" (`PLAN_TEACHABLE_CAST_PILOT_R1_2026-07-20.md`). Grep the slug FIRST; a registry hit = a deepen-existing feature decision, not a concept-spawn.

**Reference deliverable:** `Docs/RESEARCH_NEW_APP_CONCEPTS_GAMES_WORDS_FIT_2026-07-15.md`. **Cross-refs:** § App Implementation Ranking Methodology (the sibling — build-order for approved concepts) · `.claude/rules/distributed-narrative.md` § R-DN-PARITY (the swap test) · § three DN variants (cast sizing).

## The concept/spawn doc is the post-approval hub artifact — and registry-add follows repo-creation, never concept-approval (R-NEW-APP-SPAWN-DOC; 2026-07-15)

**Once a founder APPROVES a new app concept (past the `R-NEW-APP-CONCEPT-FIT` gate), the next hub artifact — before any repo exists — is a per-app concept/spawn doc `Docs/CONCEPT_SPAWN_<APP>_<date>.md` that runs the standard new-app assessment. A newly-approved concept does NOT enter the canonical active registry or the portfolio count at approval time — it enters ONLY at repo-creation time.** Codified per the V247 execution (2026-07-15, ADR-038) — the founder-confirmed sequel to the fit method. R-NEW-APP-CONCEPT-FIT answers *"does this concept belong?"*; this rule is *"what you produce after it's approved, and when it becomes a real registry entry."*

### The concept/spawn doc (the required post-approval artifact)

For each approved concept, author `Docs/CONCEPT_SPAWN_<APP>_<date>.md` with the full assessment (all sections required — a doc missing one is incomplete):

1. **Identity** — proposed name (mark *proposed* — naming is a founder prerogative; verify the slug is registry-clean in `REGISTRY_ACTIVE_PORTFOLIO_APPS.txt`), tagline, cluster, pillars, audience, DN variant, build-order.
2. **Fit + gap + differentiation** — the census-backed reason it's not duplication (name the adjacent apps + how it's distinct; the two-layer breadth-academy-≠-waiver distinction from R-NEW-APP-CONCEPT-FIT applies).
3. **Curricular evidence** — cited, with honest caveats (no padding).
4. **Curriculum + mechanic/format structure** — the 16-kit arc + the manipulatives.
5. **DN cast — R-DN-PARITY swap-test verified per member** — a table where each member's *defining act IS the primitive* (state the swap test explicitly) + a name-registry check (grep `REGISTRY_PORTFOLIO_CHARACTER_NAMES.md`; every name registry-clean).
6. **6-axis composite ranking** — scored honestly (readiness axes are intrinsically low pre-repo; StrategicValue drives relative build-order); the cross-app build-order lives in the batch ADR.
7. **`/play` web-clone twin note** — clonability + web-pioneered→iOS-backport potential + proposed cluster/grade-band.
8. **Cross-cutting gates** — trauma-gate check · pillar mapping · name-registry reservation · the 143-ceiling note · ForgeKit reuse · **explicit division-of-labor scope line** (hub creates + scaffolds the repo + all non-Swift content [docs · CLAUDE.md · rules · kits · DN-S assets] + registry-add; the app's own CC session adds ONLY the Swift/Xcode source — `PLAYBOOK_APP_SPAWN.md` § 0).

Batch close-out: a MADR (`ADR-NNN`) records the greenlight + per-app disposition + composite build-order + any fallback; cast names are reserved in `REGISTRY_PORTFOLIO_CHARACTER_NAMES.md` under a **"Scoped … (pre-dev)"** section (marked scoped, no mascot gen).

### Registry timing — concept-approval ≠ registry-add (the load-bearing rule)

**An approved-but-repo-less concept MUST NOT be added to `Docs/REGISTRY_ACTIVE_PORTFOLIO_APPS.txt` (the canonical registry) and MUST NOT bump the `PORTFOLIO_PATTERNS.md` "App Repos (N)" count. It enters both ONLY when its GitHub repo is created — which is founder-*triggered* but **HUB-executed** (hub creates + scaffolds the repo, `PLAYBOOK_APP_SPAWN.md` Phase 1), not deferred to the app session.** Founder-confirmed 2026-07-15 (work-queue V252; division-of-labor clarified 2026-07-15: *"hub is supposed to create all the new app repos and scaffold them"*).

- **Why:** the canonical registry is the **write-target for distribution scripts** (§ "Distribution scripts MUST source from canonical portfolio registry"). Listing a repo-less app makes the "active" list + count misrepresent reality (breaks § "Verify origin state before claiming coverage"); distribution scripts guard with `[ -d "$appdir/.git" ]` so they *skip* (no crash) — but the list is still a lie. Precedent: the AoPS/ADR-026 apps entered the inventory only *after* their repos were created ("repos created 2026-06-08").
- **Where an approved-but-repo-less concept DOES live (planning visibility, no count bump):** a **"Scoped <date>" section in `PORTFOLIO_PATTERNS.md`** (mirrors the AoPS "Scoped" treatment) + its concept/spawn doc + its cast reservations. That is full planning visibility without faking active state.
- **The flip:** at repo-creation, add the slug to `REGISTRY_ACTIVE_PORTFOLIO_APPS.txt` (regenerate via `scripts/regenerate_portfolio_registry.py`), bump the PORTFOLIO_PATTERNS count, and flip the cast reservations from scoped→shipped — the same PR/step that scaffolds the repo. **Concept-approval = spawn-doc + Scoped section; repo-creation = registry-add + count bump.**
- **Two distinct founder-signal types drive different stopping points (codified 2026-07-16 from ADR-038 vs ADR-043):** a **"approve the concept"** greenlight (ADR-038: *"all app concepts are approved"*) authorizes only the concept-approval artifacts → **STOP at the Scoped section, NO repo, NO count bump** (the repo is a later, separate founder-triggered step). A **"spawn it / build it"** greenlight (ADR-043: founder greenlit V262/V263 *for spawn*) authorizes hub to carry **Phase 1 (repo-creation + full scaffold + registry-add + count bump) THROUGH in the same wave**. So the same slug can sit at Scoped for a while (concept-approved) and only move to active when a *spawn* greenlight lands — but when the greenlight is already "spawn," don't artificially pause at Scoped; carry it through. Reference: ADR-038 stopped at Scoped (repos created later at V255/V256); ADR-043 carried both repos + the 147→149 count bump through in one spawn wave (V262/V263, 2026-07-16). The distinction is the *verb* in the founder signal: **approve → Scoped; spawn/build → Phase 1 through.**

**When this rule applies:** any founder-approved new app concept (single or batch). Reviewing a spawn round → a spawn doc missing an assessment section, a cast member failing the swap test, or a repo-less concept added to the canonical registry / counted, is a defect.

**Cross-refs:** § New App Concept Fit-Assessment Methodology (R-NEW-APP-CONCEPT-FIT — the gate this follows) · § Creation Checklist (the repo-creation step where registry-add happens) · § "Distribution scripts MUST source from canonical portfolio registry" (why repo-less entries are harmful) · `Docs/ADR-038_NEW_GAMES_WORD_APPS_2026-07-15.md` + the 4 `Docs/CONCEPT_SPAWN_*_2026-07-15.md` (the reference concept-approve batch — stopped at Scoped) · `Docs/ADR-043_NEW_PUZZLE_RIDDLE_APPS_2026-07-16.md` + `Docs/CONCEPT_SPAWN_{PUZZLEFORGE,RECKONQUEST}_2026-07-16.md` (the reference spawn batch — carried Phase 1 through) · work-queue V247 (delivery) + V252 (the registry-timing founder decision) + V262/V263 (the spawn-through wave).

## The single end-to-end spawn runbook is `PLAYBOOK_APP_SPAWN.md` — start there when building an approved app (R-APP-SPAWN-PLAYBOOK; 2026-07-15)

**When the founder greenlights BUILDING an app (past the `R-NEW-APP-CONCEPT-FIT` gate + `R-NEW-APP-SPAWN-DOC` spawn doc), the single-entry runbook is `Docs/PLAYBOOK_APP_SPAWN.md` — the reconciled, phase-by-phase sequence from concept-approval → repo → scaffold → content → DoD, with the hub↔app-session division of labor made explicit and the deep-web-research (🔬) step flagged per phase.** Codified per founder-direct 2026-07-15 (*"we don't have a complete app spawn playbook … analyze existing app repos to create one"* + *"include the deep web research step … for any workflow step that requires it"* + *"cover the web-clone workflow too"*). It consolidates the previously-scattered `PORTFOLIO_PATTERNS.md` § Creation Checklist + § Implementation Prep Steps 1–7 + § CLAUDE.md Template v2 + § Standalone Repo Structure into one runbook and **reconciled live drift** those sections carried (18-section → the actual 5-section v2 CLAUDE.md; "25" → the actual 29 `.claude/rules/*.md`; ForgeKit pin `from: "1.0.0-rc.2"`/`.exact "1.0.0-rc.3"` — verify `forgekit/Docs/CHANGELOG.md`).

- **The load-bearing frame it enforces (founder-clarified 2026-07-15):** a spawn is a two-agent relay in which **HUB does almost everything** — it **creates the repo** (`gh repo create` + clone) and **scaffolds it end-to-end** (README · `.gitignore` · `.swiftlint.yml` · `ExportOptions.plist` · `CLAUDE.md` v2 · full `.claude/rules/` · the `Docs/` set · `Resources/`), authors + distributes ALL content (16×25 kits + the full **DN-S workflow**: cast · portraits · chapters · audio dramas) + owns asset distribution to the app repo, does the registry add + count bump, and owns the `/play/<app>` web clone. **The ONLY thing hub does NOT do is write the Swift source** — the app's own CC session adds the Xcode project (`.pbxproj`/`.xcodeproj`/`.xcworkspace`) + `Package.swift` + `.swift` source + Swift tests on top of the hub scaffold. Founder-direct: *"the only thing hub doesn't do is coding the swift files"* + *"hub is supposed to create all the new app repos and scaffold them with all the docs, concept kits, CLAUDE.md file, rules, etc."* + *"hub owns the DN-S workflow and asset distribution to app repos too."* (This does NOT relax CLAUDE.md § CRITICAL — that rule only ever prohibited Swift/Xcode source, never repo-creation; the prior playbook over-read it.)
- **Deep web research (🔬) is REQUIRED, not optional, at:** Phase 0 concept fit (adjacent census + curricular evidence + cross-platform domain landscape) · Phase 2/5 technical-design + pedagogy grounding · Phase 4 curriculum-standards mapping · Phase 6 web-clone `## Backport candidates` mining. Run the `deep-research` skill; persist a cited, adversarially-verified `Docs/RESEARCH_*.md` (`.claude/rules/workflow.md` § Save Research).
- **The `/play/<app>` web clone is a first-class phase** (Phase 6), covering the full web-clone workflow (SELECT → RESEARCH🔬 → DESIGN → PLAN → BUILD → SHIP → BACKPORT + two-axis parity + no-dark-surface + Vitest/Playwright + light-AND-dark screenshot-DoD + hub-side DoD), pointing to the canonical `WEB_CLONE_PICKUP_RUNBOOK.md` / `WEB_CLONE_SPAWN_WORKFLOW.md`.

**When it applies:** building any approved new app (start at the playbook); reviewing a spawn (a phase that skipped its 🔬 research, or left registry-add before repo-creation, or shipped a clone without its hub-side DoD, is a spawn defect). **Cross-refs:** `Docs/PLAYBOOK_APP_SPAWN.md` · § R-NEW-APP-CONCEPT-FIT (the fit gate) · § R-NEW-APP-SPAWN-DOC (the spawn doc + registry timing) · `Docs/PORTFOLIO_PATTERNS.md` § Creation Checklist / Implementation Prep (the detail it consolidates) · `Docs/WEB_CLONE_PICKUP_RUNBOOK.md` (Phase 6) · `.claude/rules/spark-anvil-website.md` § R-WEB-CLONE-* (the web-clone DoD gates).

## Color Scheme Audit Methodology (Round 133 #567; codified after R118 incomplete-sweep incident)

> **The DESIGN STANDARD an audit checks against** (what "good color" IS — functional · intuitive · engaging · prominent) lives in `.claude/rules/spark-anvil-website.md` § R-WEB-CLONE-COLOR-SCHEME (evidence: `Docs/RESEARCH_COLOR_SCHEME_DESIGN_2026-07-28.md`). THIS section is the iOS audit *procedure* (how to grep an app's palette faithfully); the standard is the *bar*. A hub color audit of an app repo is READ-ONLY → findings ship as a `HANDOFF_FROM_HUB_COLOR_SCHEME_REFRESH.md` (the app's own CC session edits Swift; hub never writes it).

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
- Any color-refresh handoff per `HANDOFF_FROM_HUB_COLOR_SCHEME_REFRESH.md` template (canonical, 2026-06-11+; pre-rename was `HANDOFF_FROM_LABSMITH_COLOR_SCHEME_REFRESH.md`)
- Verify-before-list audits checking color-scheme alignment of recommendation lists

## Debug Logging (Round 138 #569; lifted from CuriosityQuest 2026-05-28)

Portfolio standard for adding extensive debug logging to detect unexpected runtime behaviors in iOS apps + Hummingbird servers. The single biggest source of "the app didn't crash but something was wrong" bug reports is a swallowed `try?` or a silent fallback path — detection logging makes those paths visible without changing their semantics.

**Canonical rule**: `.claude/rules/debug-logging.md` (477 lines). Codifies: categorized logger from day one (not sprinkled `print()`), category-to-bug-class mapping, auto-included diagnostic context (thread / caller / surface), production-safety (`#if DEBUG`-gated iOS / env-gated server verbose), the `didSet` pattern for state-machine coverage, replace-silent-`try?` discipline, surface-wiring playbook (iOS app shell / tab views / network services / Multipeer / SwiftData / state machines + server controllers / WebSocket / Gemini / safety / admin ops), 11-step categorization decision tree, when NOT to add logging, pre-PR checklist, AND a 2026 production-observability section covering Apple `Logger` migration triggers + privacy-by-default (always-redact list) + audit-logs-≠-debug-logs separation (with retention by regulation: COPPA ~6yr / GDPR data-minimization / PCI 12mo / SOX 7yr) + Swift OTel graduation path + silent-failure detection for AI paths (span schemas) + performance instrumentation (`OSSignposter` + `withSpan`).

**Research provenance**: `Docs/RESEARCH_RUNTIME_BEHAVIOR_AUDIT_LOGGING_2026.md` — 30 sources surveyed across 4 domains (Apple unified logging / Swift server observability / audit-vs-debug compliance / silent-failure + agent observability). 6 codified findings, each mapped to a CuriosityQuest reference impl + a future bug class.

**Reference impls** (canonical templates per portfolio rule):
- iOS: `curiosityquest-app/Packages/Libraries/Sources/Services/DebugLog.swift` (single-seam emitter, 7 categories, `#if DEBUG`-gated, zero-overhead release builds)
- Server (Hummingbird): `curiosityquest-app/Server/CuriosityQuestServer/Sources/Services/DebugFileLog.swift` (8 categories, file+stdout, env-gated verbose)

**Per-app adoption**: each app decides when to wire categorized logging (CQ is the reference impl, not a forced migration). Use the canonical template above as the starting point; adapt categories to the app's surface area (e.g., apps without network can drop `.network`; apps with pass-and-play add `.multipeer`).

**Lift provenance**: CQ shipped the rule + research in PRs #114-#121; filed `HANDOFF_FROM_APP_LIFT_DEBUG_LOGGING_RULE.md` Round 138 #569 requesting portfolio lift. Hub lifted + propagated via `scripts/copy_rules_to_repos.sh --apply` in the same round.

## App user + developer guides must track the code — both surfaces, every app (R-APP-GUIDE-SYNC; 2026-07-09)

**Every portfolio app keeps a visitor-facing USER guide and a maintainer-facing DEVELOPER guide per SHIPPING SURFACE, and each guide MUST be updated in the SAME change-set as any code change that affects what it documents.** This generalizes `R-WEB-CLONE-GUIDE-SYNC` (`.claude/rules/spark-anvil-website.md`, web clones only) to the whole portfolio and to the iOS surface. Codified per user-direct 2026-07-09 (*"are user guide and developer guide for fractionforge ios app and web automatically updated and synced with the code? codify this rule for all portfolio apps too"*).

### The honest status this rule corrects

Guide-sync today is **review-discipline, not automation** — there is no build that fails on a stale guide (unlike the cast-portrait / multibeat / frontmatter-dup prebuild gates). "Same change-set" is enforced by the author + PR review. Do not describe guides as "auto-synced"; they are *kept* synced by discipline.

### Enforcement decision — per surface (V58 sub-item a, resolved 2026-07-09)

Per `Docs/DECISION_GUIDE_SYNC_CI_GATE_2026-07-09.md` (user-approved):

- **Web clone surface → review-discipline only; NO automated gate.** Web guides live in the **hub** repo while the code lives in **spark-anvil-site** — the two move in separate commits/PRs in separate repos, so neither repo's CI ever sees both diffs. A same-commit "guide-touch" gate is mechanically impossible without cross-repo bot infra (rejected — heavy infra, low ROI; the web surface is hub-owned + single-authored per cycle). The PR-review checklist item is the enforcement.
- **iOS surface → opt-in, same-repo, WARN-by-default pre-push heuristic.** iOS guides live in the **same repo** as the Swift, so a same-repo hook can detect "guide-affecting Swift changed but no `GUIDE_*_IOS_*` changed in this push." Reference hook: `scripts/git-hooks/pre-push-guide-touch.sh` (WARN by default — "guide-affecting" is a heuristic, so a hard block would false-positive on refactors; set `GUIDE_TOUCH_STRICT=1` to block). Opt-in per app, wired exactly like the sibling `pre-push-chapter-checks.sh` (hub ships + distributes the reference hook; each app's CC session installs it — hub never force-installs hooks into app repos).

### What the rule requires (per surface)

| Surface | Guides | Path | Owner |
|---|---|---|---|
| **Web clone** (`/play/<app>/*`) | `GUIDE_<APP>_WEB_USER.md` + `GUIDE_<APP>_WEB_DEVELOPER.md` | `spark-anvil-hub/Docs/` | **Hub** (hub owns the web) — the existing R-WEB-CLONE-GUIDE-SYNC |
| **iOS app** | `GUIDE_<APP>_IOS_USER.md` + `GUIDE_<APP>_IOS_DEVELOPER.md` | `<app>-app/Docs/` | The **app's own CC session** (hub never writes Swift/app source) — hub codifies + distributes the *rule*, the app session authors + syncs the *guides* |

A change is **guide-affecting** — and MUST carry the matching guide edit in the same commit/PR — when it: adds/removes/renames a mode, screen, or user-visible label (USER guide); changes controls / flow / stored data / privacy posture (USER guide); adds/removes/renames a file, module, data model, or build step, changes a load-bearing rule the guide cites, or adds a gotcha the next maintainer needs (DEVELOPER guide). Trivial changes (copy typo, behavior-neutral refactor) don't require a guide edit — same bar as R-WEB-CLONE-GUIDE-SYNC / the multi-beat-snapshot rule.

### Rollout (staged, not all-143-at-once)

- **Web guides:** mandatory for every `/play/<app>` clone from day one (FractionForge is the reference — `GUIDE_FRACTIONFORGE_WEB_{USER,DEVELOPER}.md`).
- **iOS guides:** mandatory for **flagship / shipped** apps first (the app-ranking top tier), then roll out portfolio-wide. A new app SPAWNed post-2026-07-09 authors both iOS guides alongside first feature code.
- Distribution of this rule text to the 143 app repos rides `copy_rules_to_repos.sh --apply` under the `.claude/.rule-sync.lock` single-flight (R-PARALLEL-HUB-AGENTS) — never concurrently with a content-sweep session.

### Cross-references

- `.claude/rules/spark-anvil-website.md` § R-WEB-CLONE-GUIDE-SYNC — the web-surface specialization (this rule's parent pattern)
- `Docs/GUIDE_FRACTIONFORGE_WEB_{USER,DEVELOPER}.md` — reference web guides
- `Docs/DECISION_GUIDE_SYNC_CI_GATE_2026-07-09.md` — the per-surface enforcement decision (V58 sub-item a)
- `scripts/git-hooks/pre-push-guide-touch.sh` — reference opt-in iOS guide-touch hook
- `Docs/WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md` § V58 — the ask + open questions (scope / enforcement / CI-gate decision)

## Git-history bloat is audited + purged with a shared method — hub audits any repo; the APP session (or an explicit per-repo founder GO) executes an app-repo rewrite (R-GIT-BLOAT-HYGIENE; 2026-07-17)

**Committed binary media bloats a repo's `.git` and eventually breaks `git push` (thin-pack negotiation 500s over HTTPS once the store hits multiple GB — even a 1-commit branch). Audit + purge it with the shared backup-mirror → dry-run → `git filter-repo` → self-healing-push method. There are TWO distinct bloat classes + a load-bearing division of labor.** Codified 2026-07-17 after executing the hub purge (`.git` 10 GB → 119 MB) + the curiosityquest-app purge (362 MB → 60 MB) in one session; generalizes the site precedent (§ R-SITE-HISTORY-PURGE) portfolio-wide.

### The two bloat classes
1. **Current-tree regenerable/retired media (the hub + site class).** Directories of regenerable or RETIRED binaries still in the LIVE tree — rendered PDFs, R2 audio byte-backups, `node_modules` (never should be tracked; `npm install` regenerates), ADR-022-RETIRED avatar WebPs. Purge = **untrack-first** (`git rm --cached` KEEPS the physical files on disk) + `.gitignore` + `git filter-repo --path <dir> --invert-paths`. Executed: hub `ADR-047` (PDFBooks + R2AudioBackup + PilotsAndExperiments + node_modules + retired-avatar dirs + CompanionPack), site `ADR-034`.
2. **History-only abandoned-restructure bloat (the app-repo class).** A moved/renamed large-asset tree leaves its OLD path orphaned in history (0 files at HEAD) while the current tree is small — **`.git` ≫ current-tree is the tell** (`du -sh .git` vs the sum of `git ls-tree -r HEAD` blob bytes; enumerate history-only = blob paths ∉ HEAD). Purge = **path-anchored** `git filter-repo --path <old-tree> --invert-paths`. filter-repo paths are ROOT-ANCHORED, so `--path CuriosityQuest` strips the old top-level `CuriosityQuest/` tree while SPARING `Apps/CuriosityQuest/…` and the root file `CuriosityQuest.xcworkspace` (different path components) — **confirm in the dry-run**. **No current content changes → a built app is byte-identical after.** Executed: curiosityquest-app (restructure orphans `CuriosityQuest/`→`Apps/`, `CuriosityQuestServer/`→`Server/` = ~70% of the store).

### Division of labor (load-bearing)
- **Hub AUDITS any repo's bloat** and files the artifacts (allowed cross-repo `Docs/*.md` writes): `<app>/Docs/AUDIT_GIT_BLOAT_<date>.md` (measurements + candidate classification) + `<app>/Docs/HANDOFF_FROM_HUB_GIT_HISTORY_PURGE.md` (the exact purge scope + method).
- **For an APP repo (a built target hub does NOT own), the app's OWN session executes the rewrite by DEFAULT; hub executes it only at an EXPLICIT per-repo founder GO.** A history rewrite + force-push is hard-to-reverse and changes every SHA, so a founder GO on one repo NEVER transfers to another (the confirm-before-hard-to-reverse-in-a-new-context principle). A `git filter-repo` rewrite is **git-maintenance, NOT source authoring**, so it does not violate "hub never writes app Swift/Xcode source" — but it stays founder-gated per-repo regardless. (Reference: hub self-executed under its own GO; curiosityquest-app was hub-executed only after the founder explicitly said "option 1, execute it.")

### Method invariants (every purge, any repo)
1. **Quiet window** — 0 open PRs + no clone mid-push (a rewrite invalidates every clone → all sessions must `git reset --hard origin/main` / re-clone afterward; announce in `.claude/CLAIMS.md`).
2. **Never clobber another session's WIP** — verify the target has NO uncommitted *tracked* changes (`git status --porcelain | grep -v '^??'` empty) before `--force`; untracked files filter-repo leaves alone.
3. **Backup mirror first** — `git clone --mirror --no-hardlinks <repo> <scratch-outside-tree>` = the ONLY rollback.
4. **Dry-run on an APFS COW clone** (`cp -Rc <mirror> <throwaway>`, instant) — run filter-repo + `gc`, confirm the reclaim AND that every current path survives (the path-anchored-match trap is where a mistake hides — ADR-034 + this session both caught issues here).
5. **Re-add origin, `git ls-remote`-confirm it hasn't advanced (NEVER `git fetch` — that re-pulls the old bloat into the clean store), then `git push --force origin main`.** Lift branch protection for the single move + restore (a private/free-plan repo has none → 403 on the protection API). If the shrunken pack still 500s, fall back to the incremental-to-staging push (§ R-SITE-HISTORY-PURGE).
6. **Plain `git push` self-heals** once the store is small — retire the `scripts/gh_data_api_push.py` Data-API detour to emergency-fallback-only.
7. **A `main`-only rewrite is INCOMPLETE until the merged-but-undeleted ORIGIN branches are swept — else the purge NEVER shrinks a FRESH clone (2026-07-17).** `git filter-repo` rewrites only the refs you point it at (`main`), so every already-merged `feature/*` branch left on origin **still points at PRE-purge history** and pins the entire pre-purge pack ON ORIGIN. A default-refspec `git clone` fetches all branches → **re-downloads the full pre-purge pack**, so a fresh clone is still multi-GB even though `origin/main` is lean (the reclaim only ever helped `main`-scoped ops + the purging clone). **The decisive diagnostic** (run on any clone/origin that's bloated-vs-`main`): `git rev-list --disk-usage --objects origin/main` vs `git rev-list --disk-usage --objects --all` — a huge gap (observed **114 MB vs 9147 MB**, ADR-047's 38 undeleted branches) proves non-`main` refs hold the bloat. **So a purge's completion step is a server-side stale-branch sweep** — delete every merged branch on origin (`git push origin --delete <br>`), which is **outward-facing (shared branches) → founder-authorized**, and each branch is verified DELETE-SAFE by the **post-rewrite method (ancestry is USELESS — the rewrite re-SHA'd `main`, so every branch shows as "unmerged" by SHA):** (a) **subject-presence** — `git log <br> --not origin/main --format=%s` and confirm those subjects appear verbatim on `origin/main` (filter-repo PRESERVES subjects); the only expected misses are (i) `Merge …` commits and (ii) **the exact purged-media commits the rewrite excised** (companion-pack PDFs / R2 byte-backups / `V17 PDFs chunk N` / recency-manifest bumps — their absence from `main` is the purge working correctly, NOT lost work); (b) **deliverable-artifact** for any TIP-not-on-main or doc/porter-looking miss — `git ls-tree -r origin/main` for the branch's output files (the `Docs/web/<app>/` set, the research doc, the registry row). A branch whose only misses are Merge/purged-media commits + whose deliverables are on `main` is DELETE-SAFE. After the sweep, a fresh `git clone` finally lands at ~the `origin/main` size. **Prevention:** `gh pr merge --delete-branch` at every round-close stops the re-accumulation (the § Auto-Cycle round-close already mandates it) — the ADR-047 residue was 38 rounds' worth of skipped branch-deletes.

**Reversibility: HIGH** — the backup mirror is a full rollback; current content is preserved (untracked-first keeps files on disk; abandoned-path purges touch only history). **When it applies:** any repo whose `.git` is large relative to its current tree; a portfolio git-hygiene sweep; **before/after a directory restructure** (restructures are the #1 app-repo bloat source — purge in the same maintenance window). **Cross-refs:** `Docs/ADR-047_HUB_GIT_HISTORY_MEDIA_PURGE.md` + `AUDIT_HUB_GIT_BLOAT_2026-07-16.md` · `Docs/ADR-034` + `RUNBOOK_SITE_GIT_HISTORY_PURGE_2026-07-10.md` · `.claude/rules/spark-anvil-website.md` § R-SITE-HISTORY-PURGE + § R-SITE-BLOBLESS-CLONE (the zero-risk clone-time complement) · `.claude/rules/workflow.md` § R-PARALLEL-HUB-AGENTS (quiet-window/fleet-resync) + § Stale-clone recovery (the single-source post-purge LOCAL-reclaim procedure — Refinements 2–4: `reset --hard` doesn't reclaim, sweep every ref namespace, and a bare `git pull`/`fetch` re-bloats after a rewrite → use targeted `origin main` or convert blobless-in-place; every clone follows this after a rewrite) · `scripts/gh_data_api_push.py` (pre-purge interim) · CLAUDE.md § Known limitations.

## The hub repo's OWN bloat is CHURN + ACCRETION, not media — sweep merged branches, rotate the churn-file, archive ephemeral docs, delete gitignored scratch (R-HUB-REPO-HYGIENE; 2026-07-26)

**The hub's git + working-tree bloat, AFTER the ADR-047 media purge, is driven by four RE-ACCRETING sources — none of them committed binary media — and each has a standing hygiene action. A hub whose `.git` re-bloats, whose fresh clones are slow, or whose top-level `Docs/` is diluted by hundreds of stale ephemeral handoffs is suffering this class, NOT a media re-bloat. Audit + attack these four before ever reaching for a history rewrite; the rewrite (R-GIT-BLOAT-HYGIENE) is the last resort, not the first.** Codified per founder-direct 2026-07-26 (*"audit the hub repo and create a plan to clean it up"* + *"codify these lessons"*), from the `AUDIT_HUB_REPO_CLEANUP_2026-07-26.md` measurement: `.git` 569 MB (212 MiB pack ungc'd), the top-15 largest history blobs ALL revisions of ONE file, 104-of-116 remote branches merged-but-undeleted, 508 `CONTEXT_HANDOFF_*` docs in a 2,137-doc top-level `Docs/`. This is the hub-self sibling of § R-GIT-BLOAT-HYGIENE (which audits ANY repo's *media/restructure* bloat); this rule names the hub's own *churn/accretion* bloat + its standing prevention.

**The four re-accreting sources + their standing hygiene action (author + review the hub against these):**
1. **Merged-but-undeleted remote branches are the fresh-clone re-bloat driver.** The § Auto-Cycle / § R-SESSION-CLOSE-OUT `gh pr merge --delete-branch` + return-to-main is load-bearing for CLONE SIZE, not just tidiness: a merged branch left on origin still points at pre-purge history, so a default-refspec `git clone` re-downloads the entire pre-purge pack (the § R-GIT-BLOAT-HYGIENE invariant-7 / Stale-clone Refinement-4 mechanism). **Standing action:** enable GitHub "automatically delete head branches on merge" (one repo setting — the durable fix); and periodically **sweep the accumulated merged remote branches** (each verified delete-safe per R-GIT-BLOAT-HYGIENE invariant 7; outward-facing → founder GO + a genuinely quiet window — NO active gen lane, NO open PRs). Branches are cheap refs (sweeping them reclaims little pack directly) — the win is that every FUTURE fresh clone stops re-downloading pre-purge history.
2. **A single constantly-rewritten LARGE text file is a churn-bloat driver — ROTATE it on a size threshold.** The work-queue (`WORK_QUEUE_INBOUND_HANDOFFS_2026-05-20.md`) reached ~2.9 MB × 1,609 revisions — its revisions ARE the top-15 largest objects in history. A monotonically-growing, edited-every-round text file stores a near-full copy per revision. **Standing action:** when such a file exceeds ~1 MB, ROTATE it — move the closed/superseded top into a dated `Docs/archive/<FILE>_ARCHIVE_<date>.md` and keep the live file small, so future revisions are tiny. This halts the dominant future-bloat driver WITHOUT a history rewrite (non-destructive, keeps the audit trail). Applies to any append-heavy hub ledger (work-queue, a giant registry), never to normal docs.
3. **Ephemeral `CONTEXT_HANDOFF_*` / SUMMARY / DRAFT / TODO docs ACCRETE and dilute the durable corpus — archive past the freshness horizon.** Session handoffs are load-bearing for the NEXT session's pickup (R-SESSION-CLOSE-OUT) but go ephemeral once closed; ~500 of them in top-level `Docs/` bury the durable product (RESEARCH/AUDIT/PLAN/ADR/GUIDE/TEMPLATE/RUNBOOK). **Standing action:** `git mv` closed `CONTEXT_HANDOFF_*` (+ closed SUMMARY/DRAFT/TODO/TRACKING/WORKLIST) older than a ~2-week freshness horizon into `Docs/archive/<quarter>/` (e.g. `2026-Q3/`) — reversible, stays git-tracked. ⚠ **Two ground-truth corrections from the 2026-07-27 execution (R-CANONICAL-DOC-GROUND-TRUTH):** (a) **archived docs LEAVE the graph** — `build_docs_index.py` globs `Docs/*.md` NON-recursively, so `Docs/archive/**` is NOT graph-queryable (git-tracked + greppable only). Archival = **declutter the graph**, not "stays queryable"; keeping it queryable would need an indexer-recursion change. (b) **Select the archive set by CITATION CLOSURE, not a per-candidate `graph_impact`:** archive a doc ONLY when EVERY doc that cites it is ALSO being archived — else a KEPT top-level doc citing an archived one dangles. Compute it transitively: start by excluding any candidate cited by a rule/ADR/durable/live (post-horizon) doc, then iteratively exclude any candidate cited by an already-excluded candidate; the remaining fixed-point is the safe block. (2026-07-27: of 216 pre-horizon closed handoffs, the naive per-candidate filter gave 142 but the transitive closure gave **65** truly-safe — the 77 gap would have dangled.) **First flip stale `status: ACTIVE`→`CLOSED`** on pre-horizon handoffs (the template default is rarely reset at close — the docs analog of stale CLAIMS lanes; makes the candidate set honest), then REGENERATE + ci-mode the index (`scripts/build_docs_index.py --ci-mode` → 0 broken refs proves no dangling). ONE batched PR in a genuinely quiet window (active lanes create new handoffs constantly → a mid-flight mass `git mv` is a conflict storm). Durable RESEARCH/AUDIT/PLAN/ADR always stay top-level (appraisal by ongoing value — the archival-science ephemeral-vs-durable line).
4. **Gitignored on-disk scratch is DELETABLE DISK, not backup — but NEVER delete it during an active gen lane.** `Resources/PilotsAndExperiments/` (~293 MB) + `tmp/` are gitignored runtime scratch that scripts regenerate; they inflate `du` but NOT git. **Standing action:** reclaim them freely — EXCEPT `PilotsAndExperiments/` is where the gen pipeline writes live scratch, so a `pid-*-gen-drain` / any Gemini-key-single-flight lane (R-GEMINI-KEY-SERIAL) may be mid-write → deleting it mid-gen nukes that lane's work. Check `.claude/CLAIMS.md` for an active gen lane first; delete only when the gen lane is idle.

**The load-bearing sequencing:** attack 1–4 FIRST (all non-destructive or trivially reversible) — they capture most of the practical win (fresh clones stop re-bloating, future churn is bounded, the corpus is legible). A `git filter-repo` history rewrite to compress the work-queue's 1,609 revisions (§ R-GIT-BLOAT-HYGIENE) rewrites every SHA + discards granular queue history + demands a backup mirror + a true quiet window — reserve it for explicit founder GO when maximal pack-shrink is actually needed, never as the opening move. **This is NOT a media re-bloat** — do not re-run the ADR-047 media-purge recipe for this class; media is already gitignored and can't re-enter history.

**⚡ ENHANCEMENTS (2026-07-29, deep-web-research-confirmed — `Docs/PLAN_REPO_HEALTH_HYGIENE_2026-07-29.md` § Research):**
- **Documentation archival is an ANSWER-QUALITY lever, not cosmetic disk hygiene — this ELEVATES source-3 (the docs-archival drain) to a standing PRIORITY.** The `Docs/` corpus IS the primary agent-facing navigation surface (the `docs-graph` MCP, R-DOCS-GRAPH-INDEX), and the 2026 doc-lifecycle / KG-decay research is decisive: **ROT (Redundant / Obsolete / Trivial) content swept into an agent's RAG/graph context surfaces obsolete or wrong information in outputs** — so archiving old/outdated docs OUT of the graph (they leave the non-recursive `Docs/*.md` index glob) directly improves agent answers, while a KG *decays without pruning*. Prioritize the archival drain accordingly; it is not just "Docs/ is a mess," it is "the agent is reading stale docs." (Honest-yield: evidence-*aligned* — RAG-quality + KG-decay literature applied to our graph — not a measured A/B; state it as a strong rationale.)
- **ROT taxonomy — archive ≠ delete (the classification the drain applies).** *Archive* (reversible `git mv` → `Docs/archive/`, git-tracked, retained) a doc with residual reference value (a closed handoff, a superseded plan). *Delete* genuine **Trivial** with no retention need (regenerable gitignored scratch, a dead draft) — source 4. **Obsolete/superseded** → archive (keep the audit trail); **Redundant** duplicate → archive the copy, keep the canonical. Never delete a doc with reference value; never archive a still-live/durable one (the citation-closure guard).
- **Periodic ritual, not one-time (2026 canon: "quarterly for a fast-moving monorepo").** All four sources RE-accrete, so the sweep is a standing cadence — the horizon-aged handoff set grows continuously (V622 archived 65; the set is larger again days later). Run the archival + branch-sweep + stale-CLAIMS reconcile on a recurring pass, not only when the founder flags bloat.
- **Branch-sweep DURABLE fix = enable GitHub "automatically delete head branches on merge" (one repo setting).** Source 1's sweep reclaims little pack (the branches descend from current main post-ADR-047) but stops every future default-refspec clone from re-negotiating hundreds of stale refs; the auto-delete setting prevents the 231-branch re-accretion at the source (the skipped-`--delete-branch` round-close gap), so the manual sweep becomes a one-time backfill, not a forever-chore.

**When it applies:** any hub self-cleanup / "the hub `.git` is big again" / "fresh clone is slow" / "Docs/ is a mess or the agent's reading stale docs" investigation; a periodic (≈quarterly) hub-hygiene pass; round-close (the branch-delete half). **Cross-refs:** § R-GIT-BLOAT-HYGIENE (the media/restructure sibling + the rewrite-of-last-resort + branch-sweep invariant 7) · § R-SESSION-CLOSE-OUT + § Auto-Cycle Default (`workflow.md` — the branch-delete + return-to-main that source 1 depends on) · `workflow.md` § R-DOCS-GRAPH-INDEX (regen after a doc-move wave) + § R-PARALLEL-HUB-AGENTS (quiet-window + CLAIMS coordination for sources 1/3/4) · § R-GEMINI-KEY-SERIAL (`spark-anvil-website.md` — the active-gen check for source 4) · `spark-anvil-website.md` § R-SITE-BLOBLESS-CLONE (the zero-risk clone-time complement) · `Docs/AUDIT_HUB_REPO_CLEANUP_2026-07-26.md` + `Docs/PLAN_HUB_REPO_CLEANUP_2026-07-26.md` (the measurement + the tiered execution).

## ForgeKit

All portfolio apps share a common SPM framework at `../forgekit/` (49 modules, semver 0.75.0+; sources soft-split into `Client/` + `Server/` + `Shared/`). Apps import only the modules they need. See `@.claude/rules/forgekit.md` for the full module catalog.
<!-- END LABSMITH-SYNCED CONTENT -->
