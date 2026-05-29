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

## Timer.scheduledTimer + `Task { @MainActor in }` on @Observable @MainActor classes — the `_dispatch_assert_queue_fail` Heisenbug class

**Symptom**: `_dispatch_assert_queue_fail` / `EXC_BREAKPOINT (code=1, brk #0x1)` on a non-main thread (typically Thread 4-8 — a Swift cooperative-pool worker). Crash surfaces after **minutes** of normal app use, often during navigation-heavy sessions. Pre-crash log lines show all `@Observable` state mutations on `[thread=main]` so the crash looks unrelated. Adding `print` statements may temporarily mask it (timing-sensitive Heisenbug). Stack trace bottom shows `_dispatch_log` → `_dispatch_assert_queue_fail`.

**Root cause**: `Timer.scheduledTimer` fires on the main runloop. Wrapping the callback body in `Task { @MainActor in self?.tick() }` schedules onto the Swift cooperative-pool, which then hops back to MainActor via continuation resumption. The `@Observable` registrar's queue-identity assertion (introduced by `@Observable`'s macro-generated setter) checks `dispatch_assert_queue(.main)` which validates the **actual dispatch queue identity**, not the Swift actor. The cooperative-pool resumption can land on a queue that isn't the canonical main dispatch queue → assertion fires → trap.

**Fix**: `DispatchQueue.main.async { [weak self] in self?.tick() }`. Timer is already on main runloop, so `DispatchQueue.main.async` is a no-op queue-identity-wise but keeps the call on the canonical main dispatch queue the `@Observable` registrar checks against. Reference impl (curiosityquest-app): `SessionTimerService.startTimer` + `CampfireFocusService.startTimer` (post-PR #123, 2026-05-28).

```swift
// ❌ Anti-pattern — eventually crashes Thread N with _dispatch_assert_queue_fail
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    Task { @MainActor [weak self] in
        self?.tick()    // mutates @Observable state
    }
}

// ✅ Canonical
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    DispatchQueue.main.async { [weak self] in
        self?.tick()
    }
}
```

**Generalization**: same rule applies to any callback that runs on the main runloop but isn't `@MainActor`-isolated — including `CADisplayLink`, `CFRunLoopTimer`, `DispatchSource.makeTimerSource(queue: .main)` callbacks, etc. If the body mutates a `@Observable @MainActor` property, use `DispatchQueue.main.async`, NOT `Task { @MainActor in }`.

**Extension to SpriteKit scenes** (curiosityquest-app PR #124 + #125 swept 7 sites across 6 SKScene files 2026-05-28): the same Heisenbug class fires on a different thread (Thread 27 in CQ's case, vs Thread 6 for the timer case) when an `SKScene` subclass uses `Task { @MainActor [weak self] in try? await Task.sleep(for: .milliseconds(N)); ... }` inside a tap/touch handler to schedule the "advance to next round after a brief delay" flow. The `Task.sleep` resumption races the SpriteKit scheduler queue identity check.

Use `SKScene.run(.wait(forDuration:))` — the SpriteKit-native scheduling that respects the scene's update queue:

```swift
// ❌ Anti-pattern — eventually crashes Thread N with _dispatch_assert_queue_fail
//    after enough tap-advance cycles
Task { @MainActor [weak self] in
    try? await Task.sleep(for: .milliseconds(800))
    guard let self else { return }
    self.currentRound += 1
    self.loadRound()
}

// ✅ Canonical
run(.wait(forDuration: 0.8)) { [weak self] in
    guard let self else { return }
    self.currentRound += 1
    self.loadRound()
}
```

**Sweep grep** (run periodically to catch new regressions):

```bash
grep -rn 'Task\s*{\s*@MainActor' Packages/Libraries/Sources/GameEngine | grep -B1 -A2 'Task.sleep'
```

Zero hits is the expected steady state.

### Diagnostic checklist for `_dispatch_assert_queue_fail` on a non-main thread

When this crash class surfaces (CuriosityQuest or any portfolio app), walk this list before guessing:

1. **Confirm the crash is dispatch-asserted vs Swift-asserted**: stack bottom shows `_dispatch_assert_queue_fail` (libdispatch) OR `swift_task_assert_queue` (Swift runtime). Different fix paths.
2. **Identify the thread**: `bt` in lldb; the trapping thread's stack shows the racing call. Top frame is usually `@Observable` synthesized setter (`_<propname>` accessor) or `swift_task_continuation_resume`.
3. **Grep recent `@Observable @MainActor` services** for `Timer.scheduledTimer` / `CADisplayLink` / `URLSession(delegateQueue: nil)` / NWPathMonitor callbacks. Specifically look for `Task { @MainActor in }` inside those callback bodies.
4. **Check the `nonisolated func` set** for delegate methods (`MCSessionDelegate`, `URLSessionWebSocketDelegate`, `AVSpeechSynthesizerDelegate`, etc.). Confirm each one uses `DispatchQueue.main.async { [weak self] in }` — not `Task { @MainActor in }`.
5. **Inspect log context**: does `[thread=main]` precede the crash for every `@Observable` write, or is one off-main? `DebugLog`'s thread tag is decisive here.

Reference research: `labsmith/Docs/RESEARCH_DISPATCH_ASSERT_QUEUE_FAIL_HEISENBUG_2026-05-28.md` — full CQ diagnosis trail + symptom-vs-reality table + pre-crash log signature pattern.
<!-- END LABSMITH-SYNCED CONTENT -->
