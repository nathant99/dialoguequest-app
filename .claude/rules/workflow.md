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
- When labsmith distributes shared rule updates while a feature branch is active, merge `main` into the feature branch to pick them up

## Auto-Cycle Default (Multi-Commit Work)

**For multi-commit / multi-round work in labsmith (and any session-recurrent autocycle pattern the user has established), the DEFAULT loop is `branch → commit → push → gh pr create → gh pr merge --merge --delete-branch → verify` — no per-step confirmation prompts.** This applies when:

- The user has previously approved an autocycle pattern in the session (e.g., "go with your recs", "pre-approved", "start next round")
- The change is research / documentation / queue update / planning (low-risk; reversible via git)
- The PR is in a labsmith-owned repo (labsmith / spark-anvil-site per Round 76 scope-rule change)

**Do NOT auto-cycle for**:
- Cross-repo PRs touching app-repo Swift source code (still scope-rule-bound; app sessions own implementation)
- Force-pushes, --no-verify, rebase --interactive, or any destructive op
- Production deployment / DNS / hosting changes
- First-time scope-rule changes (those need explicit user "go")

Codified in memory `feedback_branch_workflow.md`. The verify step (`gh pr view <n> --json state,mergedAt`) is REQUIRED per the rule below; auto-cycle does not skip verification.

## CRITICAL: Verify PR Merged Before Claiming SHIPPED

**Never mark a PR "SHIPPED" until you have confirmed the merge.** This rule was codified after 3 orphan-PR incidents in labsmith (Round 70 #377 LiveKit DECISION on PR #208; Round 73 PR title-mismatch on PR #220; Round 76 #392 beta-testing surface on PR #86) where queue docs falsely claimed "SHIPPED" while the PR sat OPEN on its feature branch.

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
2. **Pair-check (1:1 keyword matching)**: for every `HANDOFF_FROM_APP_*.md` (or `HANDOFF_FROM_FORGEKIT_*.md`) found, grep the same repo for sibling `HANDOFF_FROM_LABSMITH_*.md` files. Use keyword-overlap (Jaccard ≥ 0.5), not exact-name match — the `_SHIPPED` suffix convention means filenames diverge. An app-side request is **only** OPEN-NEEDS-LABSMITH-ACTION if it has NO paired sibling response.
3. **Split-row granularity**: if a request bundles ≥ 2 distinct asks (signaled by "AND" in the filename OR multiple `##` subsections in the body), split the audit row into N sub-rows (e.g., A52a + A52b). Each sub-row independently classified — captures partial-ship state.
4. **Freshness horizon (applies to STATUS + RECOMMENDATION audits)**: every audit doc gets a `freshness-horizon: <N days>` field in YAML front-matter (default 7 days). OPEN rows older than the horizon are auto-flagged "needs-re-verification"; rounds attempting to action them MUST first re-pull + re-pair-check. **Extension (Round 116 #537)**: Rule 4 applies to **recommendation audits** (e.g., ranking audits identifying "next-N pilots" / cluster pilot suggestions / forward-looking candidate lists) NOT just status audits. Before listing items as actionable candidates, the audit MUST verify the recommended artifact doesn't already exist. Empirical evidence: Round 113 found 14 DN orphan PRs already merged (Round 106 #518 audit listed them as remediation candidates); Round 115 found 3 pillar-deepening pilot handoffs already shipped Rounds 82-85 (Round 109 #529 audit listed them as Round 115 candidates). Net session savings: ~8-10h via Rule 4 verify-before-action.
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

### CRITICAL: Save Research, Plans, and Audits to Docs/ Immediately

Every time you do research (web search, codebase analysis, design exploration), create a feature plan, or run an audit (handoff coverage, asset state, ranking, sweep, color-scheme alignment, anything that produces a structured finding), write it to a file in `Docs/` BEFORE presenting results or implementing changes. Never leave research / plans / audits only in conversation context or in temp locations (`/tmp/`, scratch files).

**Audit-specific** (codified Round 119 #544 user-direct): every audit must persist in the repo at `Docs/AUDIT_<TOPIC>_<DATE>.md`. NEVER store audit results in `/tmp/` or as untracked files. The audit doc is the durable artifact; conversation context is ephemeral. This applies to labsmith audits (`labsmith/Docs/AUDIT_*.md`) AND per-app audits (`<app>-app/docs/AUDIT_*.md`). YAML front-matter recommended: `status` + `date` + `round` + `freshness-horizon`.

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
