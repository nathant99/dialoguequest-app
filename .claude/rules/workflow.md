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
