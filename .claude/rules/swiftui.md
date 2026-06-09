---
paths:
  - "**/*.swift"
---

# SwiftUI Patterns

Learned from CuriosityQuest.

1. **State machines** — See `state-machines.md` for full patterns (`*Machine` structs, enum-based state, anti-patterns, testing)
2. **`navigationDestination(item:)` over `fullScreenCover(isPresented:)`** when parent has `@Observable` dependencies
3. **`@Entry` macro** for environment values instead of verbose `EnvironmentKey` boilerplate
4. **`ContentUnavailableView`** for empty states; **`containerRelativeFrame`** over `GeometryReader` when possible
5. **No `AnyView`** — Use `@ViewBuilder`, `Group`, or conditional modifiers instead
<!-- END LABSMITH-SYNCED CONTENT -->
