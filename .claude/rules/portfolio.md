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

### Asset generation ownership + handoff requirement (2026-05-19 STANDING RULE)

Labsmith **owns portfolio-wide asset generation**. Apps don't run Gemini Nano Banana Pro/Flash, Lyria 3, or any other generative pipeline — labsmith runs them per `GUIDE_ILLUSTRATION_PIPELINE.md`. Cost discipline: stay within published ceilings (mascot: ~$0.27/app, accessory pack: ~$0.36/app, full illustration set: depends on app's question-kit topic density).

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

## ForgeKit

All portfolio apps share a common SPM framework at `../forgekit/` (49 modules, semver 0.75.0+; sources soft-split into `Client/` + `Server/` + `Shared/`). Apps import only the modules they need. See `@.claude/rules/forgekit.md` for the full module catalog.
