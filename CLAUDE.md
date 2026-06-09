# DialogueQuest

Branching-dialogue craft workshop for tweens. Write a conversation, not a paragraph: each line scored for voice consistency, subtext, tag balance, and branch meaningfulness.

> **Deeper context**: `@Docs/TECHNICAL_DESIGN.md` (architecture), `@Docs/FEATURE_PLAN.md` (in-flight work), `@Docs/IMPLEMENTATION_HANDOFF.md` (handoff state), `@Docs/APP_SPECIFIC_NOTES.md` (preserved prior CLAUDE.md content). Portfolio-wide rules auto-load from `@.claude/rules/`.

## Tech Stack

- **Language**: Swift 6 (strict concurrency)
- **UI**: SwiftUI
- **AI**: FoundationModels (on-device)
- **Persistence**: SwiftData
- **Testing**: Swift Testing (`@Test`, `#expect`)
- **Min Target**: iOS 26 / Xcode 26
- **Architecture**: App shell + local Swift Package (`Libraries/Package.swift`)
- **Framework**: ForgeKit (pinned via `.package(url:, from: "0.99.0")`)

Portfolio-wide tech stack rules live in `@.claude/rules/forgekit.md` + `@.claude/rules/concurrency.md` + `@.claude/rules/swiftui.md` + `@.claude/rules/swiftdata.md` + `@.claude/rules/spritekit.md` + `@.claude/rules/foundationmodels.md`. All auto-load with this file.

## Commands

```bash
# Build (iOS Simulator)
xcodebuild -workspace DialogueQuest.xcworkspace -scheme DialogueQuest \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# Tests
xcodebuild test -workspace DialogueQuest.xcworkspace -scheme DialogueQuest \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Prefer MCP `BuildProject` / `RunSomeTests` over `xcodebuild` when Xcode is open (per `@.claude/rules/workflow.md` § "MCP-First Testing Workflow").

## App-Specific Conventions

See `@Docs/APP_SPECIFIC_NOTES.md` for the preserved prior CLAUDE.md content (architecture / domain patterns / gotchas accumulated through development). Portfolio-wide rules — Swift 6 concurrency, SwiftData patterns, testing conventions, ForgeKit module APIs, Liquid Glass register, distributed-narrative methodology, trauma-informed gates, COPPA / age-assurance — auto-load from `@.claude/rules/` (24+ files synced from labsmith). Do NOT re-state portfolio-wide rules here.

## Reference Documents

- `@Docs/TECHNICAL_DESIGN.md` — architecture, state machines, domain model
- `@Docs/IMPLEMENTATION_HANDOFF.md` — labsmith-shipped implementation context
- `@Docs/HANDOFF_FROM_LABSMITH_DISTRIBUTED_NARRATIVE_RETROFIT.md` (or `_ENHANCEMENT.md`) — cast + curricular embedding
- `@Docs/APP_SPECIFIC_NOTES.md` — content preserved from prior CLAUDE.md (pre-v2)
- `@.claude/rules/` — portfolio-wide rules (24+ auto-loaded files)
