# Concurrency Rules

## Build Settings (Xcode 26 defaults)

- **Swift Language Version**: Swift 6
- **Default Actor Isolation**: `MainActor` — all code is implicitly `@MainActor` unless opted out
- **Approachable Concurrency**: Enabled (`NonisolatedNonsendingByDefault`, `InferIsolatedConformances`)

## Guidelines

- Everything runs on MainActor by default — only opt out when you need real concurrency
- Use `nonisolated` to remove MainActor isolation from specific declarations
- Use `@concurrent` to explicitly run async functions off the main actor (networking, heavy data parsing)
- `@concurrent` implies `nonisolated` — don't use both together
- Pure value types used cross-isolation must be `nonisolated struct/enum`
- Use `.task {}` and `.task(id:)` for async work in SwiftUI — never use unstructured `Task {}` for fire-and-forget
- Favor **value types** (structs, enums) for data models — they are implicitly `Sendable`
- Never use `@unchecked Sendable` — fix the isolation issue properly
- Avoid `@preconcurrency import` unless dealing with a third-party library that hasn't adopted concurrency
- Macros (`@Observable`, `@Model`) can't detect default MainActor isolation — behavior may differ vs explicit `@MainActor`
- Extensions on value types inherit MainActor — mark properties `nonisolated` when accessed from nonisolated contexts (e.g., `simd_quatf` extensions, geometry helpers)
- **Extension methods inherit MainActor too** — methods in extensions on `nonisolated` types still default to MainActor. Every extension method/property/computed property must be explicitly marked `nonisolated` or you get "call to main actor-isolated instance method in a synchronous nonisolated context"
- **Protocol conformances in extensions get MainActor isolation** — `extension MyType: CustomStringConvertible` makes the conformance MainActor-isolated, breaking `"\(value)"` in nonisolated contexts. Fix: declare the protocol conformance on the type itself: `nonisolated enum MyType: ..., CustomStringConvertible {`. Same rule for `Comparable`, `Equatable`, etc.
- **`Codable` on `nonisolated struct` is the most common case** — With `InferIsolatedConformances`, `Codable` conformance added in an extension gets `@MainActor` isolation even on `nonisolated struct` types. This causes "Main actor-isolated conformance cannot be used in nonisolated context" when decoding from nonisolated code. Fix: declare `Codable` on the struct itself and implement `init(from:)`/`encode(to:)` inside the struct body, not in an extension
- **`Sendable & Identifiable` (or any `Sendable + X` composition) applies to test fixtures too** — A test-local value type that satisfies a generic constraint like `<T: Sendable & Identifiable>` must be `nonisolated public struct` (or `nonisolated private struct` inside the test) even though it's only used in tests. With `InferIsolatedConformances`, the `Identifiable` conformance picks up MainActor isolation and refuses to satisfy the `Sendable` constraint on the generic parameter. **Rule: any value type — production OR test fixture — consumed by an API requiring `Sendable` in a protocol composition must be `nonisolated`.** Discovered in `ForgeGamificationTests.DomainBadge` 2026-05-19 during ForgeKit 0.86 ship

## Async/Await Safety

- **`[weak self]` inside `for await` loops** — Always capture weak; `guard let self` inside the loop body
- **`.sensoryFeedback` in SwiftUI** — Use SwiftUI's built-in haptic modifier for views; use a dedicated feedback service for SpriteKit/RealityKit scenes
- **`DispatchQueue.main.asyncAfter` for haptic sequencing** — Sequential haptic events need GCD timing, NOT `Task.sleep`

## SpriteKit Thread Safety

**IMPORTANT**: Never modify SpriteKit nodes outside of scene delegate callbacks (`update(_:)`, `didEvaluateActions()`, etc.) or the main thread. SpriteKit is single-threaded. If you compute data on a background thread, set a flag and apply changes in the next `update(_:)` call.

## Server Concurrency (Hummingbird 2)

- Use **actors** for shared mutable state (`ConnectionManager`, `GameRoom`, `LobbyManager`)
- Use **`TaskGroup`** for per-connection handling (one task per WebSocket)
- Use **`@concurrent`** for CPU-bound work (question shuffling, score aggregation)
- Graceful shutdown via **`ServiceLifecycle`**
- All WebSocket messages are Codable enums (tagged union pattern) encoded as JSON
<!-- END LABSMITH-SYNCED CONTENT -->
