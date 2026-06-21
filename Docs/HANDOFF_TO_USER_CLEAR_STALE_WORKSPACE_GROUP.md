---
status: CLOSED
date: 2026-06-21
closed-at: 2026-06-21
direction: agent → user
audience: Nghi (Xcode operator)
intent: clear a stale workspace group reference (`DialogueQuestUITests` at repo root) that Xcode keeps regenerating in `contents.xcworkspacedata` AND may be causing `AIMentorTests` to silently drop out of `DialogueQuest.xctestplan`
freshness-horizon: 14 days
---

# Handoff to User — Clear stale `DialogueQuestUITests` workspace group

> **STATUS — CLOSED 2026-06-21**: User cleared the orphan group + verified `AIMentorTests` remains in the test plan. Post-fix verification:
> - Working tree clean (no stale workspace regen)
> - `grep -c "group:DialogueQuestUITests" DialogueQuest.xcworkspace/contents.xcworkspacedata` → `0`
> - `grep -c "AIMentorTests" DialogueQuest.xctestplan` → `2`
> - `BuildProject` ✅ (2.7s)
> - `RunSomeTests AIMentorTests/PatterFallbacksTests` → **19/19 passed**

## What happened

During PR #38 (UI tests), the agent's MCP `XcodeWrite` tool created `RootTabNavigationUITests.swift` at a synthesized navigator path that resolved to repo root (`/DialogueQuestUITests/RootTabNavigationUITests.swift`) instead of the canonical synchronized-folder path (`Apps/DialogueQuest/DialogueQuestUITests/`). The agent reverted that workspace addition and `git mv`'d the file into the correct directory; the file is now in the right place AND the test target picks it up via `PBXFileSystemSynchronizedRootGroup` (5 UI tests visible in `GetTestList`).

But Xcode **kept the in-memory project reference** to the repo-root group. Every time Xcode saves the workspace (after a build, after a test run, after a scheme edit), it rewrites `DialogueQuest.xcworkspace/contents.xcworkspacedata` to re-add this orphan group:

```xml
<Group
   location = "group:DialogueQuestUITests"
   name = "DialogueQuestUITests">
   <FileRef
      location = "group:RootTabNavigationUITests.swift">
   </FileRef>
</Group>
```

The file the group claims to reference (`/DialogueQuestUITests/RootTabNavigationUITests.swift` at repo root) does **not** exist — the canonical copy lives at `Apps/DialogueQuest/DialogueQuestUITests/RootTabNavigationUITests.swift`.

## Why this matters

1. **Workspace file churn**: every Xcode save regenerates this diff. The agent has to revert it each session to avoid committing an orphan reference.
2. **`AIMentorTests` may be silently dropped from `DialogueQuest.xctestplan`**: observed at end of 2026-06-21 session — after PR #39 added `AIMentorTests` to the test plan via your Xcode GUI step, a subsequent Xcode save dropped the entry. Likely Xcode's scheme/test-plan auto-regen got confused by the orphan group and rewrote both files together.

## What you need to do

1. **Open `DialogueQuest.xcworkspace` in Xcode**
2. In the **Project Navigator** (left sidebar), find the `DialogueQuestUITests` **group** (the one that's a sibling of `DialogueQuest` and `Libraries` — NOT the test target inside `DialogueQuest.xcodeproj`). It should be greyed out / show a red icon because the file it references doesn't exist on disk.
3. Right-click the orphan `DialogueQuestUITests` group → **Delete** → **Remove Reference** (the file doesn't exist on disk anyway; nothing to move to trash)
4. Save the workspace (Cmd+S)
5. **Verify `AIMentorTests` is still in the test plan**: Product → Scheme → Edit Scheme → Test → Test Plans → `DialogueQuest.xctestplan` → Edit → Tests list should contain `AIMentorTests` alongside `ModelsTests` / `ServicesTests` / `AppFeatureTests` / `ForgeKitIntegrationTests` / `DialogueQuestTests` / `DialogueQuestUITests`. If `AIMentorTests` is missing, re-add it via **+** → `AIMentorTests` (under `Libraries`).
6. `git status` in the repo root — should show `M DialogueQuest.xcworkspace/contents.xcworkspacedata` (the orphan group removed) and possibly `M DialogueQuest.xctestplan` (if you re-added `AIMentorTests`). The agent will commit these next session per the carve-out.

## Why the agent can't just do this

The orphan reference lives in `DialogueQuest.xcworkspace/contents.xcworkspacedata` — a forbidden glob per `@.claude/rules/xcode-agent-safety.md`. The agent can revert the file via `git checkout` (as a recovery escape hatch), but each Xcode save regenerates the orphan. The only durable fix is removing the reference from inside Xcode so the in-memory state stops emitting it.

## Cross-references

- `@.claude/rules/xcode-agent-safety.md` § "Staging + committing Xcode-managed files IS allowed" (the carve-out)
- PR #38 — where the MCP write originally created the wrong-path file
- PR #39 — added `AIMentorTests` to the test plan (which may have been silently dropped after this issue surfaced)
