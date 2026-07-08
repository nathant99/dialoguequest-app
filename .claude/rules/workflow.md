# Workflow & Definition of Done

## Definition of Done (every feature, no exceptions)

1. Build succeeds (all targets)
2. Unit tests + UI tests written and passing
3. **Code review checklist**: no force unwraps, no prohibited patterns (Combine, SceneKit, AnyView, `@unchecked Sendable`), no parameterless `.animation()`, no `.accessibilityLabel()` on buttons (breaks XCUITest matching — use `.accessibilityHint()`), disabled buttons have `accessibilityHint` explaining WHY disabled
4. Update CLAUDE.md with any new patterns, gotchas, or anti-patterns discovered during implementation
5. Only THEN mark the task as complete

## Branching

- Feature branches off `main`, named `feature/<kebab-case-description>` (e.g., `feature/bar-model-canvas-accessibility`)
- One PR per feature branch, merged to `main` via merge commit (preserves branch history)
- Delete feature branches after merge — don't accumulate stale branches
- Keep feature branches current: merge `main` into the feature branch before PR to resolve conflicts
- Checkpoint commits on feature branches are encouraged — fine-grained history is squashed or preserved at PR merge time
- Push feature branches to `origin` for PR creation: `git push -u origin feature/<name>`
- When hub distributes shared rule updates while a feature branch is active, merge `main` into the feature branch to pick them up

## Auto-Cycle Default (Multi-Commit Work)

**For multi-commit / multi-round work in hub (and any session-recurrent autocycle pattern the user has established), the DEFAULT loop is `branch → commit → push → gh pr create → gh pr merge --merge --delete-branch → verify` — no per-step confirmation prompts.** This applies when:

- The user has previously approved an autocycle pattern in the session (e.g., "go with your recs", "pre-approved", "start next round")
- The change is research / documentation / queue update / planning (low-risk; reversible via git)
- The PR is in a hub-owned repo (hub / spark-anvil-site per Round 76 scope-rule change)

**Do NOT auto-cycle for**:
- Cross-repo PRs touching app-repo Swift source code (still scope-rule-bound; app sessions own implementation)
- Force-pushes, --no-verify, rebase --interactive, or any destructive op
- Production deployment / DNS / hosting changes
- First-time scope-rule changes (those need explicit user "go")

Codified in memory `feedback_branch_workflow.md`. The verify step (`gh pr view <n> --json state,mergedAt`) is REQUIRED per the rule below; auto-cycle does not skip verification.

## CRITICAL: Verify PR Merged Before Claiming SHIPPED

**Never mark a PR "SHIPPED" until you have confirmed the merge.** This rule was codified after 3 orphan-PR incidents in hub (Round 70 #377 LiveKit DECISION on PR #208; Round 73 PR title-mismatch on PR #220; Round 76 #392 beta-testing surface on PR #86) where queue docs falsely claimed "SHIPPED" while the PR sat OPEN on its feature branch.

**Required verification after every PR creation**:

```bash
gh pr merge <number> --merge --delete-branch
# Then verify:
gh pr view <number> --json state,mergedAt
# State must be MERGED. mergedAt must be non-null.
```

If `gh pr merge` returns "Pull Request is not mergeable" (status `UNSTABLE`):
- Check what's blocking: `gh pr view <number> --json mergeStateStatus,statusCheckRollup`
- If it's a non-blocking CI check (Cloudflare Workers build IN_PROGRESS, optional lints), use `--admin` to merge
- If it's a real failure or merge conflict, fix before merging — do NOT close the round with the PR still OPEN

**Before closing any multi-PR round**:

```bash
# Audit any feature branches that haven't been merged
gh pr list --state open --author "@me"
```

If the queue claims SHIPPED but `gh pr list --state open` shows the branch, the round is NOT actually closed. Fix immediately by merging or marking IN-FLIGHT.

**Common failure mode**: bg agents create a feature branch + PR but the agent process ends before `gh pr merge` runs (or runs but check-blocks). The agent's report says "shipped" but the merge never happened. **The main session must verify** — agent reports are not authoritative for merge state.

## CRITICAL: Verify origin state before claiming portfolio-wide content coverage

**This rule extends "Verify PR Merged" to cover content distribution.** Wave runners that `cp` assets directly into a sibling repo's working tree (e.g., `t2_coverage_wave_runner.sh` → `spark-anvil-site/public/chapters/`) do NOT auto-commit. The operator MUST run a separate commit + push cycle, AND verify origin reflects the new state, BEFORE authoring any handoff doc that quotes coverage numbers.

**Codified after V10 (2026-06-23) — the 1497-file orphan-state incident**: V10's wave runner generated 252 Tier-2 chapters + distributed to the site working tree, but a mid-round P0 YAML drift incident pulled the operator's attention. The bulk content sat staged-but-unpushed while the V10 handoff doc claimed "252/252 Tier-2 audio drama m4a files at site, zero partials, 100% portfolio coverage" — true locally, false at origin (origin had 86). V11 Wave 1 had to ship a P0 sync push (spark-anvil-site PR #280) to close the gap before continuing.

### Required verification before authoring any handoff coverage claim

```bash
# 1. Fetch origin to ensure local view of origin is current
cd ../spark-anvil-site && git fetch origin main

# 2. Verify origin state matches local state for the path in question
git ls-tree -r origin/main public/chapters/ | grep -c '\-advanced_chapter\.m4a'  # origin count
git ls-tree -r HEAD public/chapters/ | grep -c '\-advanced_chapter\.m4a'         # local-tracked count

# 3. Check for uncommitted local state — MUST be empty before SHIPPED claim
git status --porcelain public/chapters/ | wc -l                                  # MUST = 0
```

If `git status --porcelain` shows ≥1 file in the distribution path, the round is NOT actually shipped. Either commit + push the pending state, OR change the handoff to mark IN-FLIGHT.

### Wave-runner self-report (enforcement at source)

All three wave runners (`t2_coverage_wave_runner.sh` / `path_b_wave_runner.sh` / `path_b_tier2_audio_wave_runner.sh`) end with a check that warns when the site working tree has uncommitted content in `public/chapters/` + `src/data/`. Codified V11 (2026-06-23). Sample output:

```
⚠  spark-anvil-site has 1497 uncommitted files in public/chapters/ + src/data/.
   Run cd ../spark-anvil-site && git status to inspect; commit + push before claiming coverage.
   Origin state ≠ local state; handoff docs MUST verify against origin.
```

Operators must heed the warning before round-close. The warning fires regardless of context-switch / interruption / etc. — it's the last line of defense against the V10 failure mode.

### When this rule applies

- Every wave runner that distributes assets to a sibling repo's working tree (current: 3 site wave runners; future: any new `gen_*_to_site.py` / `copy_*_to_repos.sh` script that produces site assets)
- Every handoff doc that quotes site coverage numbers (e.g., "X/Y chapters at site", "100% coverage")
- Every round-close that bundles cross-repo content distribution

### Companion to existing rules

- `.claude/rules/workflow.md` § "CRITICAL: Verify PR Merged Before Claiming SHIPPED" — sister rule for PRs (this rule extends to direct-distribution paths)
- `.claude/rules/workflow.md` § "CRITICAL: Pull origin BEFORE freshness queries" — reads against origin, not local
- `.claude/rules/portfolio.md` § "Per-repo pull-then-audit BEFORE work" — pull-audit-then-work; this rule extends to push-verify-then-claim

## Stale-clone recovery — verify 3 safety conditions before `git reset --hard` (2026-07-02)

**When a clone shows a large "modified + untracked" working tree AND `git pull --ff-only` aborts, do NOT assume it's an orphan-state (unpushed local work) and do NOT blindly reset.** The far more common cause is a **stale local `main` pointer** — the branch is dozens/hundreds of commits behind origin with a superseded working tree, and the "untracked" files are already tracked upstream. Codified after the 2026-06-30 FractionForge session: the hub clone showed **822 "modified" + 467 untracked** files with `--ff-only` aborting; it turned out `main` was **563 commits behind** origin with a ~2026-06-11-era tree — zero real local work. This is DISTINCT from the V10 orphan-state rule above (that was genuinely *unpushed local content*; this is *stale pointer + superseded tree*).

**Before any `git reset --hard origin/main`, verify all 3 safety conditions — and STOP if any fails:**

```bash
git fetch origin main
# (a) No unpushed commits on HEAD (== 0)
git rev-list --count origin/main..HEAD          # MUST print 0
# (b) HEAD is a strict ancestor of origin/main (reset is a pure fast-forward, loses no commits)
git merge-base --is-ancestor HEAD origin/main && echo "ff-safe" || echo "DIVERGED — STOP"
# (c) Sampled "untracked" files already exist on origin (they're not new local work)
for f in <sample-untracked-path-1> <sample-untracked-path-2>; do
  git cat-file -e "origin/main:$f" 2>/dev/null && echo "$f: on origin (safe)" || echo "$f: NOT on origin — INVESTIGATE"
done
```

Only when (a) == 0 AND (b) is ff-safe AND (c) all sampled untracked files exist on origin → `git reset --hard origin/main` is safe (it discards a stale tree, not real work). If (a) > 0 or (b) reports DIVERGED or (c) finds a genuinely-new file, STOP and surface to the user — that IS unpushed work and needs the orphan-state handling, not a reset.

## CRITICAL: Stagger Background Agents — Never 4+ in Parallel

**Spawn background agents one at a time (sequentially), not 4+ simultaneously.** Codified after a Round 90 (2026-05-27) incident where 4 parallel `run_in_background: true` agents all hit the Anthropic API rate-limit cap within ~12 minutes wall-clock with zero/minimal work completed across the wave. Round 91 (same day) re-ran the same 4 work items staggered (1 at a time) and shipped all 4 successfully — total ~552K agent tokens, no rate-limit caps.

### Empirical pattern

| Strategy | Outcome | Tokens spent |
|---|---|---|
| **4 bg agents parallel** (Round 90) | ALL 4 capped within 12 min; #466 hygiene got furthest at 2,999 tokens / 59 tool calls — others 400-1,000 tokens each | ~5K total before cap |
| **1 bg agent at a time** (Round 91) | 3 of 3 completed cleanly: #468 P0 fix (180K tokens / 48 tools / 54 min) + #469 Wave D (272K / 74 / 34 min) + #470 Gemma research (75K / 41 / 14 min) | ~552K total, no caps |

### Recommended workflow

For multi-bg-agent rounds:

1. **Spawn agent #1** in background via `Agent({run_in_background: true})`
2. **Do main-session foreground work in parallel** — independent docs, queue updates, drift fixes, planning. Main session and bg agent run on separate token budgets
3. **Wait for the `<task-notification>` completion message** for agent #1 (do NOT poll; the system notifies)
4. **Spawn agent #2** once #1 completes
5. **Repeat** for #3, #4, etc.

### Why parallel saturates

Background agents share the same Anthropic API limit pool as the main session. Each agent's first turn does discovery (reads, greps, doc surveys) consuming 5-20K tokens. Four parallel discoveries = 20-80K tokens within minutes, saturating the limit before any productive work lands. Sequential spawning lets each agent run its discovery + work phases without competing for the same window.

### Exceptions

- **2 bg agents parallel** is usually safe if both have small scopes (≤ ~50K tokens estimated each; ≤ 30 tool calls)
- **Foreground main-session work alongside 1 bg agent** is the canonical pattern — exploit it for productivity. Round 91 main session shipped 3 PRs (#315 / #316 / #318) in parallel with #468 running
- **Quick utility agents** (e.g., a focused grep across the portfolio that returns in 1-2 tool calls) can run in parallel without saturating

### Companion gotcha: shared working tree contention

Background agents and the main session **share the same working tree on the filesystem** — `git status` shows files staged by either side. If the main session runs `git add <specific-file> && git commit`, but another agent has staged different files concurrently, `git commit` includes ALL staged files. Observed Round 90 #466's AGENTS.md getting committed to #465's PR.

**Mitigation**: when running main-session work in parallel with a bg agent, use **branches** (not staged files on main) and explicit `git add <path>` per file. Don't trust `git status` cleanliness between bg-agent operations.

### Companion utility: `--admin` for non-blocking CI

When `gh pr merge` reports `UNSTABLE`:

```bash
gh pr view <n> --json mergeStateStatus,statusCheckRollup
# If only non-blocking checks (Cloudflare Workers IN_PROGRESS, optional lints):
gh pr merge <n> --merge --delete-branch --admin
```

Pattern proven across Round 91 #468 + #469 (68 cross-repo PRs total).

## R-PARALLEL-HUB-AGENTS — coordination protocol for concurrent hub sessions (2026-07-08)

**Multiple Claude Code sessions run against this hub (and the shared portfolio) at the same time. They share ONE git origin per repo, ONE Gemini API key, ONE R2 bucket, and ONE working tree per clone — so uncoordinated concurrent writes collide.** This section is the single consolidated protocol; the sibling sections it references (§ Stagger Background Agents / § Pre-work origin verification / § Verify origin state before claiming coverage / § Stale-clone recovery / `portfolio.md` § Per-repo pull-then-audit / `spark-anvil-website.md` § R-GEMINI-KEY-SERIAL) remain the detailed treatments — this rule unifies them and adds the cross-session coordination the individual rules didn't cover.

### Why this exists — collisions observed in a single session (all from concurrent hub agents)

1. **Queue-number collision** — a parallel session and this one BOTH added `## V35` to the work queue → git merge conflict; resolved by renumbering to `V36` and keeping BOTH entries.
2. **Rule-sync `set -e` abort** — `copy_rules_to_repos.sh` committed to a diverged app (a parallel session pushed between the sync's pull and push); the failing `git push` under `set -e` aborted the whole run, silently skipping ~54 apps (fixed reactively via resilient push, hub PR #1157 — but the ROOT is concurrent pushes).
3. **Per-app push race** — an app needed a rebase onto a parallel commit before its rule push landed.
4. **PR-merge races** — origin/main advanced mid-round (parallel merges), so hub PRs needed branch-update-then-merge.
5. **R2 bucket mutated mid-audit** — a backup audit's bucket count grew +20 objects (a parallel creative wave uploaded new audio + left `.vtt` uncommitted) between snapshot and hardening.
6. **Stale-clone / `index.lock` contention** — a backgrounded `git add` left a stale lock; a stale local `main` pointer.

### The protocol (7 disciplines)

1. **Queue-number allocation — never hard-code the next `V<N>`.** At the moment you commit a work-queue entry, `git pull` the queue first and take `max(existing V-numbers) + 1`. Expect + resolve queue merge-conflicts by **renumbering your entry and keeping BOTH** (the V35/V36 precedent) — never clobber the other session's entry. Same discipline for ADR numbers (`ADR-NNN`) and any other monotonic ID authored across sessions.

2. **Rule-sync single-flight.** Only ONE session runs `copy_rules_to_repos.sh --apply` (or any full portfolio distribution) at a time — concurrent runs race per-app pushes. Acquire the hub lockfile `.claude/.rule-sync.lock` (PID + ISO-timestamp + short purpose) before starting; remove it when done. If the lock exists and its PID is alive, WAIT or coordinate — do not start a second sync. A stale lock (dead PID, or timestamp > ~30 min old) may be reclaimed after verifying no sync is actually running (`ps` the PID). The resilient push (PR #1157) is the SAFETY NET, not a substitute for the lock.

   ```bash
   LOCK=.claude/.rule-sync.lock
   if [ -f "$LOCK" ] && kill -0 "$(cut -d' ' -f1 "$LOCK" 2>/dev/null)" 2>/dev/null; then
     echo "rule-sync in progress by PID $(cat "$LOCK") — WAIT/coordinate"; exit 1
   fi
   echo "$$ $(date -u +%FT%TZ) rule-sync" > "$LOCK"
   trap 'rm -f "$LOCK"' EXIT
   ```

3. **Bucket-/key-mutating single-flight.** Extend R-GEMINI-KEY-SERIAL's "one op at a time" to ANY shared-resource-mutating op: R2 uploads/prunes, the R2 backup sync, and any Gemini gen/gate/portrait run. An audit or backup must not race a live upload wave. After any wave that mutated R2, re-run the backstop auditor (`audit_r2_upload_coverage.py` / `audit_asset_backup_coverage.py --ci-mode`). If a bucket count shifts mid-audit, a parallel wave is writing — pause, let it finish, re-snapshot.

4. **PR-merge-race discipline.** Immediately before `gh pr merge`, `git pull --ff-only` your branch's base (or fetch + rebase the branch). If `gh pr merge` reports not-mergeable because origin/main advanced, **update-branch-then-retry** — do NOT `--admin`-force past a real divergence. `--admin` is only for genuinely non-blocking CI (Cloudflare build IN_PROGRESS, optional lints) per § Companion utility above, never to bypass a merge conflict a parallel session created.

5. **Territory claiming (lightweight).** A session doing sustained work in a specific app repo, or on a portfolio-scale wave (e.g., the multi-beat chapter sweep, a per-cluster gen wave), ANNOUNCES it — a line in the session handoff doc AND/OR a `.claude/CLAIMS.md` entry (`<repo-or-wave> · <session/PID> · <ISO-timestamp> · <purpose>`). Other sessions read claims before starting concurrent writes to a claimed repo/wave and pick different territory. The "V35 owned by parallel session" note is the informal precedent this formalizes. Claims are advisory, not locks — they prevent the expensive collisions (duplicate paid gen, working-tree churn), not every edit.

6. **Distribution scripts must be concurrency-safe.** Any script that writes to multiple repos MUST: (a) `git pull` per repo immediately before its push; (b) be **resilient** — never `set -e`-abort the whole batch on one repo's push failure; on failure `git pull --rebase` + retry, else record `PUSH-FAILED`, leave the commit local, and CONTINUE the loop (the V32 P2 resilient-push template); (c) be **idempotent / re-runnable** — a second run over already-synced repos is a no-op (merge-aware sync, skip-if-present gen); (d) **commit only its own pathspec, NEVER the whole index** — use `git commit <path> -m …` (pathspec commit), not `git add <path> && git commit` (which commits the ENTIRE index). A parallel session — or this environment's auto-staging of Write-created files — may leave UNRELATED files staged in the target repo's index; a whole-index commit sweeps them into the distribution commit. (2026-07-08 incident: a straggler `copy_rules_to_repos.sh` run swept another workflow's auto-staged untracked `HANDOFF_*` doc into an app's rule-sync commit because the commit wasn't pathspec-scoped. Fixed: `git commit .claude/rules/ -m …`.) Never source the target list from a filesystem glob — use the canonical registry per `portfolio.md` § Distribution scripts MUST source from canonical portfolio registry.

7. **Pull-first / verify-origin everywhere (the umbrella).** Every freshness query, every pre-work step, every coverage claim reads/writes against ORIGIN, not stale local state — per the sibling sections. In a parallel-session world these are not optional politeness; they are the only thing that keeps two sessions from acting on each other's stale view.

### When this rule applies

- Any hub session that MIGHT be running alongside another (assume yes by default — the portfolio routinely has ≥2 concurrent sessions).
- Before any: work-queue/ADR number allocation · portfolio rule sync · R2-mutating op · cross-repo PR merge · sustained per-app or portfolio-wave work.

### Cross-references

- § Stagger Background Agents — Never 4+ in Parallel (intra-session bg agents; this rule is the inter-SESSION analog)
- § Pre-work origin verification · § Verify origin state before claiming coverage · § Stale-clone recovery
- `portfolio.md` § Per-repo pull-then-audit BEFORE work, ONE AT A TIME · § Distribution scripts MUST source from canonical portfolio registry
- `.claude/rules/spark-anvil-website.md` § R-GEMINI-KEY-SERIAL (single-flight the shared Gemini key — the resource-contention precedent this generalizes)
- hub PRs #1157 (resilient push) · #1161 (V35↔V36 queue-collision resolution)

## Architecture Decision Records (MADR convention)

**When a non-trivial decision is made — author a MADR.** Industry-standard Markdown Architecture Decision Record format. Captures the decision + alternatives + consequences in a durable, scannable form so future sessions don't re-litigate.

**When to author**:
- Non-trivial architectural / process / scope choice with alternatives considered
- Reversal of a prior decision (use `supersedes:` front-matter)
- Standing rule that affects future work (e.g., scope-rule changes, methodology rule changes)
- Defer / no-action decision that needs to be documented so future sessions don't re-litigate

**When NOT to author**:
- Tactical fixes (commit messages suffice)
- Routine queue items (those live in the work queue)
- Research artifacts (those go in `RESEARCH_*.md` docs; the MADR may cite the research)

**Format**: `Docs/ADR-NNN_<TITLE_SLUG>.md` with YAML front-matter (`status`, `last-reviewed`, `adr-id`, optional `supersedes` / `superseded-by`). Body sections: `## Status` → `## Context` → `## Decision` → `## Alternatives considered` → `## Consequences` (Positive / Negative / Reversibility) → `## References`.

**Index**: `Docs/ADR_INDEX.md` is the canonical list of ADRs + the template + the relationship between MADR-numbered docs and the historical `DECISION_*.md` docs (ADR-001 through ADR-007 are the 7 pre-MADR `DECISION_*.md` files; ADR-008+ are post-Round-95 MADRs).

**Existing `DECISION_*.md` docs** (7 total, all pre-MADR) are NOT renamed retroactively — they're reclassified as ADR-001 through ADR-007 in the index. Backfilling front-matter on them is a deferred / opportunistic task.

## Cross-Repo Audit Methodology (5 rules — ADR-011)

When authoring or refreshing a cross-repo handoff / portfolio audit, apply these 5 rules jointly. Rules 1-4 codified after Round 96 #487 surfaced that the Round 89 #458 audit mis-classified 3 already-shipped items as OPEN. Rule 5 added Round 112 #532 after Round 109 #529 documented a portfolio-wide finding (R3 "both surfaces" reference impl) in an audit doc that future sessions wouldn't naturally find. See ADR-011.

1. **Pull-first (mandatory)**: `git pull --ff-only` every target repo BEFORE the first grep / read. If `--ff-only` fails on any repo, abort the audit and surface the failure. Stale local clones are the #1 audit failure mode (Round 89 #458 root cause).
2. **Pair-check (1:1 keyword matching)**: for every `HANDOFF_FROM_APP_*.md` (or `HANDOFF_FROM_FORGEKIT_*.md`) found, grep the same repo for sibling responses across BOTH conventions: `HANDOFF_FROM_HUB_*.md` (canonical, 2026-06-11+), `HANDOFF_FROM_SPARK_ANVIL_HUB_*.md` (verbose, 2026-06-11+), AND `HANDOFF_FROM_LABSMITH_*.md` (legacy, pre-2026-06-11). Use keyword-overlap (Jaccard ≥ 0.5), not exact-name match — the `_SHIPPED` suffix convention means filenames diverge. An app-side request is **only** OPEN-NEEDS-HUB-ACTION if it has NO paired sibling response across all three filename forms.
3. **Split-row granularity**: if a request bundles ≥ 2 distinct asks (signaled by "AND" in the filename OR multiple `##` subsections in the body), split the audit row into N sub-rows (e.g., A52a + A52b). Each sub-row independently classified — captures partial-ship state.
4. **Freshness horizon (applies to STATUS + RECOMMENDATION audits)**: every audit doc gets a `freshness-horizon: <N days>` field in YAML front-matter (default 7 days). OPEN rows older than the horizon are auto-flagged "needs-re-verification"; rounds attempting to action them MUST first re-pull + re-pair-check. **Extension (Round 116 #537)**: Rule 4 applies to **recommendation audits** (e.g., ranking audits identifying "next-N pilots" / cluster pilot suggestions / forward-looking candidate lists) NOT just status audits. Before listing items as actionable candidates, the audit MUST verify the recommended artifact doesn't already exist. Empirical evidence: Round 113 found 14 DN orphan PRs already merged (Round 106 #518 audit listed them as remediation candidates); Round 115 found 3 pillar-deepening pilot handoffs already shipped Rounds 82-85 (Round 109 #529 audit listed them as Round 115 candidates). Net session savings: ~8-10h via Rule 4 verify-before-action. **Tooling (Round 128 #553)**: `scripts/recommendation_audit_verify.py` implements the 5-step verify-before-list mechanic at script level. Input: YAML with `audit:` metadata + `candidates:` list (each with `app` + `expected_artifact` + `candidate_class` + `priority`). Output: markdown report classifying ALREADY-SHIPPED / IN-FLIGHT / NEW-CANDIDATE per candidate + actionable-list (NEW-CANDIDATE only) + verify-before-action savings count. Future recommendation audits should pipe candidate lists through this script before listing actionable work.
5. **Audit-to-canonical-propagation**: when an audit yields a portfolio-wide finding — a new pattern, reference implementation, policy clarification, or methodology rule — the round-close MUST include propagation to relevant canonical references BEFORE closing the round. Canonical refs are: (a) `.claude/rules/*.md` (loaded into every CC session), (b) `Docs/TEMPLATE_*.md` (read by implementing sessions), (c) `Docs/DECISION_*.md` / `Docs/ADR-*.md` (canonical policy artifacts). Audit docs alone are insufficient — they decay in visibility, and future sessions read rules/template/decision-doc, not audit-doc history. If portfolio rule sync is needed after a `.claude/rules/*.md` update, run `scripts/copy_rules_to_repos.sh --apply` in the same or immediately following round.

See `Docs/ADR-011_AUDIT_METHODOLOGY_PULL_PAIR_SPLIT.md` for the full rationale + alternatives considered + migration path.

## Development Practices

- Use plan mode for non-trivial features — explore the codebase, design the approach, get approval before writing code
- Search Apple developer docs (`DocumentationSearch`) before using unfamiliar or potentially new APIs — don't assume training data is current
- Build after every edit to verify compilation
- Build for all platforms (iOS + macOS + visionOS as applicable) to catch missing platform guards — not just the active scheme
- Write unit + UI tests for all new features
- All tests must pass before committing
- Commit working checkpoints during multi-step features — not just at the end

### CRITICAL: Pull origin BEFORE freshness queries (in-repo or cross-repo)

When the user asks any "freshness" question — *"any new handoff?"*, *"what changed?"*, *"any open PRs?"*, *"what's the current status?"*, *"what did hub ship?"*, *"cq might have new X"* — the **first tool call must be `git pull --ff-only`** before any filesystem inspection (`ls`, `Grep`, `Read`).

Why: filesystem queries return ground truth for the LOCAL commit, not for origin. Concurrent hub / app sessions ship handoffs + rule updates frequently (5 hub PRs landed during a single CQ session 2026-05-29). Answering a freshness query from stale main produces a wrong answer dressed up as authoritative.

Trigger phrases: "any new", "what's open", "what changed", "what landed", "is there new", "current status", "what's pending", "might have new". When any of these appear with a freshness verb, **pull first, query second**.

If `--ff-only` fails (diverged history), surface that to the user before continuing — don't auto-rebase / auto-merge without acknowledgment.

This is the in-repo analog of the cross-repo Rule 1 in § "Cross-Repo Audit Methodology" + `.claude/rules/portfolio.md` § "Pull Before ANY Cross-Repo Read". Same underlying principle: **never answer a freshness question from stale state**.

Codified 2026-05-29 by CQ session after user-direct: agent answered "any new handoff?" from stale main (2 hub PRs behind) and user had to ask "did you pull origin?" to surface the omission. Lifted to hub canonical R168 #600.

### CRITICAL: Save Research, Plans, and Audits to Docs/ Immediately

Every time you do research (web search, codebase analysis, design exploration), create a feature plan, or run an audit (handoff coverage, asset state, ranking, sweep, color-scheme alignment, anything that produces a structured finding), write it to a file in `Docs/` BEFORE presenting results or implementing changes. Never leave research / plans / audits only in conversation context or in temp locations (`/tmp/`, scratch files).

**Audit-specific** (codified Round 119 #544 user-direct): every audit must persist in the repo at `Docs/AUDIT_<TOPIC>_<DATE>.md`. NEVER store audit results in `/tmp/` or as untracked files. The audit doc is the durable artifact; conversation context is ephemeral. This applies to hub audits (`spark-anvil-hub/Docs/AUDIT_*.md`) AND per-app audits (`<app>-app/docs/AUDIT_*.md`). YAML front-matter recommended: `status` + `date` + `round` + `freshness-horizon`.

### CRITICAL: Pre-work origin verification (parallel-session collision avoidance)

**Before doing WORK that produces files in an app repo (asset generation, illustration distribution, audio bundles, etc.), `git fetch origin main` for that repo AND verify the target files DON'T already exist on origin.** Codified Round 481 #YYY 2026-06-01 after this session burned ~$5+ on redundant illustration generations where the parallel hub session had already shipped the same content to origin.

**Verification pattern**:
```bash
cd <app-repo>
git fetch origin main 2>&1 | tail -1
# Check if target files already exist on origin
origin_count=$(git ls-tree -r origin/main <target-dir>/ 2>/dev/null | grep -c <pattern>)
[ "$origin_count" -gt 0 ] && echo "SKIP — already on origin" || echo "PROCEED — origin empty"
```

**Why this matters**: when multiple hub sessions race the same trauma-gated cluster work (chapter illustrations / cast portraits / audio dramas), the LATE-arriving session generates redundant assets, hits merge conflicts at PR time, closes its own PR as redundant, AND wastes API spend. The pre-work fetch+check eliminates the race.

**Apply to**:
- Per-app asset generation (`gen_app_illustrations.py --chapters` / `gen_cast_portraits.py` / etc.)
- Per-app handoff doc creation if a sibling hub session may also be authoring
- Bulk distribution scripts (`copy_*_to_repos.sh`) — though these are typically idempotent

**Don't apply to** (these are fine without pre-fetch):
- Hub-local doc edits (rules / ADRs / audits — single session owns these)
- Code changes to hub scripts
- Memory file updates

**Companion to** § "CRITICAL: Pull origin BEFORE freshness queries" above. That rule is about READING origin state; this rule is about WRITING after-verification. Both stem from the same principle: never assume your local view matches origin.

**Implementation hook**: pull-and-check can be added to gen scripts as a default-on flag. Until then, the pattern is human-discipline-driven.

### CRITICAL: Inventory script discipline — use `find`, not multi-glob `ls`

**For per-app filesystem inventory scripts that check file presence across many repos, use `find -maxdepth N -name PATTERN` per check; never use multi-pattern `ls`.** Codified Round 488 2026-06-02 after the `Docs/AUDIT_DOCS_ONLY_APP_RANKING_2026-06-02.md` inventory bug.

**Anti-pattern**:

```bash
cast=$(ls "$d"/Resources/Cast/*.webp "$d"/Resources/Illustrations/cast_*.webp 2>/dev/null | wc -l | tr -d ' ')
```

In zsh under `NO_EXTENDED_GLOB`, when ANY one of multiple glob patterns has no matches, `ls` errors out completely AND outputs nothing → `wc -l = 0`. Result: false-zero report for files that DO exist at the matching path. This bit the R488 docs-only audit by reporting "99/99 missing cast portraits" when the truth was "0/99 missing".

**Canonical**:

```bash
cast=$(find "$d/Resources/Cast" -maxdepth 2 -name "*.webp" 2>/dev/null | wc -l | tr -d ' ')
cast2=$(find "$d/Packages/Libraries/Sources/SharedUI/Resources/Cast" -maxdepth 2 -name "*.webp" 2>/dev/null | wc -l | tr -d ' ')
cast=$((cast + cast2))
```

`find` returns empty output (not an error) when no matches; `wc -l` correctly returns 0; multi-path checks compose cleanly via summation.

**Companion rule** — when inventory across N apps shows a uniform value for a presence check, **verify against 2-3 sample apps directly** before reporting:

```bash
# Spot-check the column on 3 known-good apps
for app in proofquest cubesensei curiosityquest; do
  ls /Volumes/Data/Projects/GitHub/$app-app/Resources/Cast/*.webp 2>/dev/null | wc -l
done
```

If your inventory says "0" but spot-check says "7", the inventory has a bug. **Never publish a portfolio-wide gap count without spot-check verification.**

### CRITICAL: Update CLAUDE.md After Every Implementation

After every implementation, update CLAUDE.md with any new patterns, anti-patterns, gotchas, or constants discovered. Examples: new rendering constants, API quirks, things that bit you. Future sessions depend on CLAUDE.md being accurate and complete.

## File Management: MCP vs Filesystem Tools

| Task | Use This | NOT This | Why |
|------|----------|----------|-----|
| Create/edit app target files (.swift) | `XcodeWrite` / `XcodeUpdate` | `Write` / `Edit` | Filesystem writes are invisible to Xcode — files won't be added to the xcodeproj or compiled |
| Create/edit SPM package files (.swift) | `Write` / `Edit` | — | SPM auto-discovers source files from directory structure; no project membership needed. `XcodeWrite`/`XcodeUpdate` also work but aren't required |
| Read source files | `XcodeRead` | `Read` | Uses project navigator paths; consistent with other MCP tools |
| Search code | `XcodeGrep` | `Grep` | Searches within project structure |
| Find files | `XcodeGlob` | `Glob` | Finds files in Xcode project structure |
| List directory | `XcodeLS` | `ls` | Shows Xcode project organization |
| Create directories | `XcodeMakeDir` | `mkdir` | Creates Xcode groups, not just filesystem directories |
| Delete files | `XcodeRM` | `rm` | Removes from Xcode project AND filesystem |
| Move/rename files | `XcodeMV` | `mv` | Updates Xcode project references |

**App target** = files under `[AppName]/` listed in the xcodeproj. **SPM package** = files under `Libraries/` managed by `Package.swift`. Since nearly all source code lives in `Libraries/`, filesystem tools (`Write`/`Edit`) work for most file operations.

**Always use filesystem tools for**: non-source files (`Docs/*.md`, `CLAUDE.md`, `.gitignore`), git operations, shell commands.

## Service Architecture

- Services (AI mentors, engines, persistence) are ViewModel properties, not singletons
- `HapticService` static methods for feedback — call from ViewModel, not views
- `ModelContext` injection: pass from view's `onAppear` to ViewModel, NOT in `init` — `@Environment(\.modelContext)` only works in views

## Content Gating

When gating content behind progression, all four channels must agree:
1. Lock icon visible
2. Gray tint applied
3. Interaction disabled
4. `accessibilityHint` explains unlock requirement
<!-- END LABSMITH-SYNCED CONTENT -->
