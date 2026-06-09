---
paths:
  - "**/*.swift"
---

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

**Extension to SwiftUI view callbacks** (curiosityquest-app PR #126 swept 15 sites): the same Heisenbug class also fires in SwiftUI views when an `onAppear` / dismiss / setup method uses `Task { @MainActor in try? await Task.sleep(for: .seconds(N)); withAnimation { ... } }` to delay a state mutation. View body is already MainActor-isolated, so the Task hop is unnecessary AND `Task.sleep` resumption races. Use `DispatchQueue.main.asyncAfter` instead:

```swift
// ❌ Anti-pattern — accumulates over a session, eventually races
Task { @MainActor in
    try? await Task.sleep(for: .seconds(0.5))
    withAnimation { startupOverlay = .streakRescue }
}

// ✅ Canonical
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    withAnimation { startupOverlay = .streakRescue }
}
```

Reference impl (CQ PR #126): 14 sites in `RootTabView.swift` (startup overlay setup, seasonal events, tooltips, feature spotlights, login rewards) + 1 in `CampfireTimerView.swift` (Sage pause bubble). Pattern is most common in view-setup flows that schedule "show overlay after a brief delay" UX behavior.

**Caveat for `Duration` typed locals**: when migrating, watch for `let delay: Duration = reduceMotion ? .zero : .milliseconds(N)` — `DispatchTime + Duration` is not a valid operator. Change the type to `TimeInterval` and the literals to seconds (`Double`) so `.now() + delay` works.

### Extension to AVAudioNodeTap closures (the persistent crash class — TWO-PART rule)

curiosityquest-app PR #127 (insufficient) → PR #128 (canonical) — `AVAudioNode.installTap(onBus:bufferSize:format:block:)` invokes its tap closure on AVFAudio's realtime background workloop via `AVAudioNodeTap::TapMessage::RealtimeMessenger_Perform()`. This is a different mechanism from Timer/SKScene/SwiftUI — AVFAudio holds a C function pointer and calls it directly, bypassing Swift's actor system. If the closure synchronously accesses `self` (a `@MainActor @Observable` class), Swift 6 infers the closure as `@MainActor`-isolated; the runtime executor check (`_swift_task_checkIsolatedSwift` → `swift_task_isCurrentExecutorWithFlagsImpl`) then traps on the workloop with `_dispatch_assert_queue_fail` / `EXC_BREAKPOINT`.

**The rule has TWO parts — both required**. Removing `guard let self` alone is INSUFFICIENT (PR #127 attempted this and the crash recurred with the same `bt` signature). Swift 6 inherits the enclosing function's `@MainActor` isolation onto closures when the closure-parameter type isn't `@Sendable` AND the closure captures any `@MainActor`-isolated value — including `[weak self]` of a `@MainActor` class. So `[weak self] buffer, _ in ... DispatchQueue.main.async { self?.foo.append(...) }` STILL traps because `[weak self]` capture + `self?` reference forces the outer closure to inherit `@MainActor` from `startRecording()`.

**The canonical fix** (PR #128, post-recurrence):

1. **Take `self` out of the tap closure entirely.** No `[weak self]`, no `[unowned self]`, no `self` reference anywhere in the closure body — outer or nested.
2. **Capture a Sendable, nonisolated accumulator** (e.g. `OSAllocatedUnfairLock<[Float]>`) and a Sendable invocation-counter for diagnostics. Both are value types with stable `Sendable` conformance; `withLock` is a synchronous, lock-free way to mutate state from any thread.
3. **Mark the closure `@Sendable`** to force the inference rule even if Swift would otherwise inherit isolation.

```swift
// ❌ Anti-pattern variant A — synchronous `self` access (PR #127 fixed this case).
inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { [weak self] buffer, _ in
    guard let self else { return }   // ← forces @MainActor inference
    if let channelData = buffer.floatChannelData?[0] {
        let frameCount = Int(buffer.frameLength)
        let samples = Array(UnsafeBufferPointer(start: channelData, count: frameCount))
        DispatchQueue.main.async { [weak self] in self?.audioBuffer.append(contentsOf: samples) }
    }
}

// ❌ Anti-pattern variant B — no sync access but `[weak self]` capture + nested
//    `self?.foo` still inherits @MainActor. THE CRASH RECURS with the same bt.
inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { [weak self] buffer, _ in
    guard let channelData = buffer.floatChannelData?[0] else { return }
    let frameCount = Int(buffer.frameLength)
    let samples = Array(UnsafeBufferPointer(start: channelData, count: frameCount))
    DispatchQueue.main.async {
        self?.audioBuffer.append(contentsOf: samples)   // self capture forces inheritance
    }
}

// ✅ Canonical — no self capture; Sendable accumulator + @Sendable annotation.
@ObservationIgnored private let bufferAccumulator = OSAllocatedUnfairLock<[Float]>(initialState: [])

// In startRecording:
let accumulator = bufferAccumulator   // local Sendable binding — captured by value
inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { @Sendable buffer, _ in
    guard let channelData = buffer.floatChannelData?[0] else { return }
    let frameCount = Int(buffer.frameLength)
    let samples = Array(UnsafeBufferPointer(start: channelData, count: frameCount))
    accumulator.withLock { $0.append(contentsOf: samples) }
}

// In stopRecording (already on MainActor):
let drained = bufferAccumulator.withLock { state -> [Float] in
    let result = state
    state.removeAll(keepingCapacity: true)
    return result
}
// hand `drained` off to transcription via Task.detached as before.
```

**Why `@Sendable` + Sendable captures jointly**: the `@Sendable` annotation tells the compiler the closure must satisfy `Sendable`. The compiler then refuses to inherit `@MainActor` (which would be incompatible with `Sendable`). But a `@Sendable` closure can ONLY capture Sendable types — so you must already have eliminated `self` capture. The two work together; neither alone is sufficient.

**Generalization to all C-callback APIs**: the same rule applies to any callback that runs off a Swift actor's queue and is invoked by a C/Objective-C framework via a raw function pointer — including `CMSampleBuffer` callbacks (`AVCaptureVideoDataOutput`), `AudioQueueNewInput` callbacks, `CGEventTapCreate` event handlers, `IOHIDDeviceRegisterInputValueCallback`, and any other CoreFoundation-style "give us a closure we'll call from our own thread" API. **Rule**: in those closures, NEVER capture `self` (any flavor). Capture a Sendable accumulator + mark `@Sendable`. Drain the accumulator at the actor-boundary call site (the function that installed the callback, which is already on the actor).

### Extension to framework-delegate protocols invoked off-actor

curiosityquest-app PR #129 — `MXMetricManagerSubscriber.didReceive(_:)` is invoked by MetricKit on `com.apple.metrickit.manager.queue` — a background dispatch queue. Under Swift 6 with `-default-isolation MainActor`, the conforming class is implicitly `@MainActor`, so the protocol method inherits `@MainActor`. The runtime executor check then traps with `_dispatch_assert_queue_fail` / `EXC_BREAKPOINT` on the MetricKit queue the moment a daily report or crash diagnostic is delivered. `bt` signature: frame #5 = `_checkExpectedExecutor`, frame #7 = `MXMetricManager deliverDiagnosticPayload_block_invoke`, queue = `com.apple.metrickit.manager.queue`.

**Fix**: mark both `didReceive` overloads `nonisolated`. The body can compute on the MetricKit queue (value types only — payload reads, metadata building) and hop to Main via `DispatchQueue.main.async` for `@MainActor` service access. Snapshot any captured value into a Sendable local before the hop:

```swift
// ❌ Anti-pattern — inherits @MainActor from the class default-isolation
public func didReceive(_ payloads: [MXDiagnosticPayload]) {
    for payload in payloads {
        AnalyticsService.shared.track(...)   // runtime trap on MetricKit queue
    }
}

// ✅ Canonical
public nonisolated func didReceive(_ payloads: [MXDiagnosticPayload]) {
    for payload in payloads {
        let snapshot = ... // value-type computation on MetricKit queue
        DispatchQueue.main.async {
            AnalyticsService.shared.track(..., metadata: snapshot)
        }
    }
}
```

**Generalization — every protocol-conformance callback method MUST be `nonisolated` when the framework invokes it on its own queue**. Audit list (each has bitten the portfolio at least once OR is a known off-actor delegate from Apple's framework docs):

| Framework / protocol | Queue used to invoke the callback |
|---|---|
| `MXMetricManagerSubscriber` (this rule) | `com.apple.metrickit.manager.queue` |
| `MCSessionDelegate` / `MCNearbyServiceBrowserDelegate` / `MCNearbyServiceAdvertiserDelegate` | MultipeerConnectivity internal queue |
| `URLSessionWebSocketDelegate` / `URLSessionDelegate` (with non-main `delegateQueue`) | The `OperationQueue` supplied at session init |
| `AVSpeechSynthesizerDelegate` | AVSpeechSynthesizer's internal queue |
| `AVAudioPlayerDelegate` | AVAudioPlayer's internal queue |
| `NWPathMonitor.pathUpdateHandler` | The queue passed to `monitor.start(queue:)` — `.main` is safe, anything else needs `nonisolated` |
| `UNUserNotificationCenterDelegate` | `com.apple.usernotifications.delegate` |
| `SKPaymentTransactionObserver` (StoreKit 1) / `Transaction.updates` (StoreKit 2) | Background |
| `CMSampleBufferDelegate` (AVCaptureVideoDataOutput) | The capture-output queue |
| `AVAudioNodeTap` block (covered above) | AVFAudio realtime workloop |
| `AudioQueueNewInput` callbacks | The queue passed to AudioQueueNewInput |
| `CGEventTapCreate` event handlers | The run loop the tap is attached to |
| `IOHIDDeviceRegisterInputValueCallback` | The dispatch queue passed to `IOHIDDeviceScheduleWithRunLoop` |

**Rule (one-liner)**: any class that conforms to a framework delegate protocol invoked off-actor MUST mark every protocol method `nonisolated`. Inside, snapshot to Sendable locals then `DispatchQueue.main.async` for actor access. Failing to do this in Swift 6 = guaranteed `_dispatch_assert_queue_fail` trap on first callback.

### Sweep grep (run periodically to catch new regressions)

```bash
# Run from repo root. Returns sites that need conversion.
grep -rn 'Task\s*{\s*@MainActor' Packages/Libraries/Sources \
  | grep -B0 -A1 'Task.sleep' \
  | grep -v 'DispatchQueue.main'
```

Zero hits (excluding the canonical emitters and comment mentions) is the expected steady state. CQ codebase reached zero after PR #126 (Task.sleep cases) + PR #128 (AVAudioNodeTap) + PR #129 (MetricKit).

### Diagnostic checklist for `_dispatch_assert_queue_fail` on a non-main thread

When this crash class surfaces (CuriosityQuest or any portfolio app), walk this list before guessing:

1. **Confirm the crash is dispatch-asserted vs Swift-asserted**: stack bottom shows `_dispatch_assert_queue_fail` (libdispatch) OR `swift_task_assert_queue` (Swift runtime). Different fix paths.
2. **Identify the thread**: `bt` in lldb; the trapping thread's stack shows the racing call. Top frame is usually `@Observable` synthesized setter (`_<propname>` accessor) or `swift_task_continuation_resume`.
3. **Read `bt` for the framework frame**: this is the SINGLE MOST IMPORTANT diagnostic. If `bt` shows AVFAudio in frame #7 → AVAudioNodeTap variant (TWO-PART rule above). If it shows `MXMetricManager` → MetricKit subscriber variant. If it shows SpriteKit / RootTabView / GameEngine → Task.sleep variant. The framework name in the bt narrows the fix path immediately.
4. **Grep recent `@Observable @MainActor` services** for `Timer.scheduledTimer` / `CADisplayLink` / `URLSession(delegateQueue: nil)` / NWPathMonitor callbacks. Specifically look for `Task { @MainActor in }` inside those callback bodies.
5. **Check the `nonisolated func` set** for delegate methods using the audit table above (`MCSessionDelegate`, `URLSessionWebSocketDelegate`, `AVSpeechSynthesizerDelegate`, `MXMetricManagerSubscriber`, etc.). Confirm each one uses `DispatchQueue.main.async { [weak self] in }` — not `Task { @MainActor in }`.
6. **Check AVAudioNodeTap closures** for ANY `self` capture (`[weak self]` / `[unowned self]` / direct). If found, refactor per the TWO-PART rule.
7. **Inspect log context**: does `[thread=main]` precede the crash for every `@Observable` write, or is one off-main? `DebugLog`'s thread tag is decisive here.

**Common false-positive recurrence pattern**: a PR fixes the first identified site but the crash recurs with the same `bt` signature. This means the actual root cause is at a DIFFERENT site (often deeper in the framework chain). PR #127 → PR #128 in CQ is the canonical example — PR #127 removed `guard let self` from AVAudioNodeTap but `[weak self]` capture + `self?` reference in a nested `DispatchQueue.main.async` STILL forced `@MainActor` inheritance. PR #128 applied the full TWO-PART rule and the crash stopped. **Read the bt AGAIN after each fix attempt**; if the framework frame is identical, you fixed the wrong site or fixed it incompletely.

Reference research: `labsmith/Docs/RESEARCH_DISPATCH_ASSERT_QUEUE_FAIL_HEISENBUG_2026-05-28.md` — full CQ diagnosis trail + symptom-vs-reality table + pre-crash log signature pattern.
<!-- END LABSMITH-SYNCED CONTENT -->
