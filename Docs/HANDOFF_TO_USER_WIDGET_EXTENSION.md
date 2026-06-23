---
status: ACTIVE
date: 2026-06-23
direction: agent → user
audience: Nghi (Xcode operator)
intent: add a Widget Extension target so DialogueQuest can surface the kid's current writing session on the Lock Screen + Dynamic Island via ActivityKit Live Activities
freshness-horizon: 90 days
---

# Handoff to User — Widget Extension target for Live Activities

The agent cannot create a Widget Extension target in Xcode per `@.claude/rules/xcode-agent-safety.md` (every `*.xcodeproj/**` write is in the forbidden-globs list). The Live Activity surface requires a Widget Extension target before the app can register a Live Activity at runtime; until that target ships, the Swift-side scaffold (`Libraries/Sources/Services/Sensory/DialogueWritingSessionActivity.swift`) stays in `.notWired` and every public surface is a safe no-op.

## Why this matters

Live Activities are how iOS 16+ apps surface in-progress activity on the Lock Screen + the Dynamic Island. For DialogueQuest the canonical use case is "the kid is mid-write" — the Lock Screen card shows the current node count, the characters in the scene, the mood, and elapsed minutes. The card disappears when the kid finishes the tree or backgrounds the app past the activity timeout. Apple's HIG calls these out as a key engagement surface for "active session" apps.

The scaffold is wired so adding the Widget Extension turns the feature on without any code changes to `DialogueWritingSessionActivity`. The class checks `Bundle.main.object(forInfoDictionaryKey: "NSSupportsLiveActivities")` at static-let init; once the key is present, every public entry point starts proxying to ForgeKit's `ForgeActivityManager` (which in turn calls `ActivityKit.Activity.request(...)`).

## What you need to do in Xcode (~30 min)

### Step 1 — Add a new Widget Extension target

1. Open `DialogueQuest.xcworkspace` in Xcode
2. **File → New → Target…**
3. Pick **Widget Extension** under iOS
4. Name it `DialogueQuestWidgets`
5. Bundle identifier: `com.dialoguequest.DialogueQuest.Widgets` (Xcode autogenerates from app id)
6. Make sure "Include Live Activity" is **checked**
7. Make sure "Embed in Application" → `DialogueQuest` is **selected**
8. Click **Finish**

Xcode creates `Apps/DialogueQuest/DialogueQuestWidgets/` with stub `WidgetBundle` + `LiveActivity` + Info.plist + entitlement.

### Step 2 — Add the `NSSupportsLiveActivities` key to the APP target's Info.plist

1. Select the `DialogueQuest` project in the Project Navigator
2. Select the `DialogueQuest` **app target** (NOT the new widget target)
3. **Info** tab → **+** at bottom of Custom iOS Target Properties
4. Add:

| Key | Type | Value |
|---|---|---|
| `NSSupportsLiveActivities` | Boolean | `YES` |

Once committed, `DialogueWritingSessionActivity.isWired` flips to `true` and the static-let probe stays cached for the app process lifetime.

### Step 3 — Wire the widget bundle's Live Activity view to the canonical attributes/state shape

The agent's scaffold exposes the canonical Live Activity shape at:

- `DialogueWritingSessionActivity.WritingSessionAttributes` (subjectName + iconName + totalNodesTarget)
- `DialogueWritingSessionActivity.WritingSessionContentState` (currentNodeCount + totalNodesTarget + moodLabel + elapsedMinutes + isPaused)

Both wrap ForgeKit's `ForgeSessionAttributes` + `ForgeSessionContentState`. In the new widget target's `LiveActivity.swift`, the Activity definition should look like:

```swift
import ActivityKit
import WidgetKit
import SwiftUI

struct DialogueWritingActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var currentNodeCount: Int
        var totalNodesTarget: Int
        var moodLabel: String
        var elapsedMinutes: Int
        var isPaused: Bool
    }
    var subjectName: String
    var iconName: String
    var totalNodesTarget: Int
}

struct DialogueWritingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DialogueWritingActivityAttributes.self) { context in
            // Lock Screen / Banner / Notification UI
            VStack(alignment: .leading) {
                Text(context.attributes.subjectName).font(.headline)
                Text("\(context.state.currentNodeCount) of \(context.state.totalNodesTarget) lines")
                if !context.state.moodLabel.isEmpty {
                    Text("Mood: \(context.state.moodLabel)").font(.caption)
                }
            }.padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) { /* ... */ }
                DynamicIslandExpandedRegion(.trailing) { /* ... */ }
                DynamicIslandExpandedRegion(.bottom) { /* ... */ }
            } compactLeading: {
                Image(systemName: "text.bubble")
            } compactTrailing: {
                Text("\(context.state.currentNodeCount)")
            } minimal: {
                Image(systemName: "text.bubble")
            }
        }
    }
}
```

The shape matches the agent's Swift scaffold so when the active path lands in a follow-up PR (agent-author OK; it's pure SPM source), it'll do `Activity.request(attributes:contentState:)` with this exact `ContentState` type. The widget bundle exists once + serves the Live Activity rendering forever.

### Step 4 — Add the Widget Extension's Info.plist key

The widget target needs `NSExtension` with `NSExtensionPointIdentifier = com.apple.widgetkit-extension` (Xcode's template does this automatically) AND the per-extension entitlement `com.apple.security.application-groups` to share data with the host app if needed (deferred — DialogueQuest's Live Activity reads everything from the `WritingSessionContentState` push).

### Step 5 — Commit the diff

After Steps 1-4, `git status` should show:

- `M Apps/DialogueQuest/DialogueQuest.xcodeproj/project.pbxproj` (new target + Info key)
- `A Apps/DialogueQuest/DialogueQuestWidgets/` (new directory with widget bundle Swift files)
- `A Apps/DialogueQuest/DialogueQuestWidgets/Info.plist` (Xcode-generated)
- `A Apps/DialogueQuest/DialogueQuestWidgets.entitlements` (if Apple Push Notifications enabled for remote-push state updates)

The agent will stage + commit these via the Xcode-safety carve-out (the rule is about authoring content from disk; staging GUI diffs is fine).

## What the agent ships in a follow-up PR (post-handoff)

Once Steps 1-5 complete:

1. **Active path** — `DialogueWritingSessionActivity.start(attributes:state:)` proxies to `ForgeActivityManager.start(...)`, which in turn calls `ActivityKit.Activity.request(...)`. The wired version of the manager is already in ForgeKit 0.99; no app-side changes needed beyond the gated check that's already in the scaffold.
2. **Wiring into `WriteTabView` / `SessionTimerService`** — start the Live Activity when the kid begins writing in earnest (e.g., after the first node lands), update it every node-count change, end it on `.published` OR when the kid backgrounds the app for > 8 hours (Apple's Live Activity max duration).
3. **The widget UI itself** — the snippet in Step 3 is the canonical shape; the follow-up PR fills in the Liquid Glass styling + the per-character portrait if the kid's authoring a known LESSONS-layer cast.

## Why this is a handoff and not an agent edit

- Widget Extension targets live entirely inside `*.xcodeproj/project.pbxproj`. Every line of that file is on the agent's forbidden-globs list per `@.claude/rules/xcode-agent-safety.md`. The pbxproj's bundle-id mapping is what tells Apple's build system to package the widget alongside the app — there's no SPM-source equivalent.
- `NSSupportsLiveActivities` is an Info.plist key. Same forbidden-globs reason as the voice-acting coach handoff (`@Docs/HANDOFF_TO_USER_VOICE_ACTING_COACH_INFOPLIST.md`).

## Scope boundary

This handoff covers ONLY the Widget Extension target creation + the `NSSupportsLiveActivities` Info.plist key. It does NOT cover:

- The active `Activity.request(...)` path — agent-author once the target ships.
- ForgeWidgets integration — separate work; ForgeWidgets requires its own Widget target (one per surface) and a separate handoff once the first home-screen widget is designed.
- Push notification entitlements for remote state updates — deferred until the active path proves a need.

## Cross-references

- `Libraries/Sources/Services/Sensory/DialogueWritingSessionActivity.swift` — Swift scaffold
- `Libraries/Tests/ServicesTests/DialogueWritingSessionActivityTests.swift` — 8 tests covering the entitlement-gated probe + value-type shape mapping to ForgeKit
- `@.claude/rules/warnings.md` § Privacy-Gated Frameworks + Entitlement-Gated Frameworks — the rule the scaffold follows
- `@.claude/rules/forgekit.md` § ForgeLiveActivities — module catalog entry
- `@Docs/FEATURE_PLAN.md` Phase 4 / Phase 5+ — Live Activity surface lives in the post-MVP roadmap
