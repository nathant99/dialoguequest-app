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

## Development Practices

- Use plan mode for non-trivial features — explore the codebase, design the approach, get approval before writing code
- Search Apple developer docs (`DocumentationSearch`) before using unfamiliar or potentially new APIs — don't assume training data is current
- Build after every edit to verify compilation
- Build for all platforms (iOS + macOS + visionOS as applicable) to catch missing platform guards — not just the active scheme
- Write unit + UI tests for all new features
- All tests must pass before committing
- Commit working checkpoints during multi-step features — not just at the end

### CRITICAL: Save Research & Plans to Docs/ Immediately

Every time you do research (web search, codebase analysis, design exploration) or create a feature plan, write it to a file in `Docs/` BEFORE presenting results or implementing changes. Never leave research or plans only in conversation context.

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
