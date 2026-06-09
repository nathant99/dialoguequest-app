---
paths:
  - "**/*DebugLog*.swift"
  - "**/*DebugFileLog*.swift"
  - "**/Server/**/*.swift"
  - "**/Services/**/*.swift"
---

# Debug Logging for Runtime-Behavior Auditing

Portfolio-wide best practices for adding extensive debug logging to detect unexpected runtime behaviors in iOS apps + Hummingbird servers. Codified 2026-05-28 after a 4-PR rollout in curiosityquest (PRs #114 → #117) that wired ~110 log call sites across 18 services / controllers / view layers.

The single biggest source of "the app didn't crash but something was wrong" bug reports is a swallowed `try?` or a silent fallback path. Detection logging makes those paths visible without changing their semantics.

## Design principles

### 1. Build a categorized logger from day one — don't sprinkle `print()`

A naked `print()` is invisible to release builds (Apple stdout doesn't show), unsearchable in a stream of thousands, and overhead-positive (the string allocation happens even when nobody reads it). The portfolio convention is **one canonical `DebugLog` (iOS) / `DebugFileLog` (server) utility per target**, with typed category methods, single emission seam, and `#if DEBUG` / env-var gating.

Reference impls in curiosityquest:
- `Packages/Libraries/Sources/Services/DebugLog.swift` (iOS)
- `Server/CuriosityQuestServer/Sources/Services/DebugFileLog.swift` (server)

### 2. Choose categories that map to "what kind of bug"

Map categories to **detection domains**, not implementation layers. The reader of a log line should immediately know "this is a thing that might be wrong" (vs "this is a thing that happened in module X").

| Category | iOS | Server | What kind of bug it catches |
|---|---|---|---|
| `STARTUP` | ✅ | ✅ | Launch crashes, missing entitlements, model container recovery |
| `LIFE` | ✅ | — | Eager `@State` allocation, missing `onAppear`, scene phase races |
| `NET` | ✅ | — | Network failures, retries, on-device fallback decisions |
| `DATA` | ✅ | ✅ (Fluent) | Silent `try? save()` failures, fetch errors |
| `STATE` | ✅ | — | State-machine illegal transitions, missing `reset()` |
| `PERM` | ✅ | — | Runtime entitlement / Info.plist gate decisions |
| `ERR` | ✅ | ✅ | Non-fatal errors otherwise swallowed by `try?` |
| `REQ` / `RES` | — | ✅ | Per-request entry/exit (verbose; off in steady-state) |
| `GEMINI` (or other vendor) | — | ✅ | External API call lifecycle (always emit — operational signal) |
| `WS` (WebSocket) | — | ✅ | Connect / disconnect / message relay |
| `SAFETY` | — | ✅ | Input/output moderation decisions, COPPA-relevant operations |

Always emit operational signals (errors, API calls, safety decisions, admin ops). Gate verbose categories (per-request entry, routine WebSocket messages, per-frame state) behind a runtime toggle so production stdout isn't flooded.

### 3. Auto-include diagnostic context

Every log line should carry, without the caller specifying:

- **Thread info** — `[thread=main]` / `[thread=bg(name)]` — correlates with crash thread numbers from sysdiagnose / Xcode debug navigator
- **Caller name** — `#function` default parameter so the calling function shows up
- **Surface tag** — service / controller name prefixed in the message (`"MultipeerService — peer X connected"`) for grep-ability when categories collide

iOS template:

```swift
public static func network(_ message: String, _ context: StaticString = #function) {
    emit("NET", message, context)
}

private static func emit(_ category: String, _ message: String, _ context: StaticString) {
    #if DEBUG
    let thread = Thread.isMainThread ? "main" : "bg(\(Thread.current.name ?? "unnamed"))"
    print("[\(category)] \(context) — \(message) [thread=\(thread)]")
    #endif
}
```

Server template (Swift / Hummingbird):

```swift
static func gemini(_ message: String, file: String = #file, line: Int = #line) {
    log("[GEMINI] \(message)", file: file, line: line)  // always emit — operational signal
}

static func request(_ message: String, file: String = #file, line: Int = #line) {
    guard verboseEnabled else { return }                // gated by CQ_DEBUG_VERBOSE=1
    log("[REQ] \(message)", file: file, line: line)
}
```

### 4. Production-safety is non-negotiable

- **iOS release builds**: every `DebugLog.*` call must compile to `()` with zero overhead. The `#if DEBUG` lives **inside** the emitter, not at every call site, so callers don't need to wrap and can read naturally. The argument expression is still constructed at the call site, but that's the only cost — and string interpolations on debug-only paths are fine.
- **Server steady-state**: gate verbose categories (per-request entry, routine WebSocket relay) behind an env var (`CQ_DEBUG_VERBOSE=1`). Always-emit categories (errors, vendor API calls, safety decisions) stay visible in production stdout because they're operational signals.

### 5. The `didSet` pattern for uniform state-machine coverage

When a state property is mutated in 10+ places, do NOT instrument every mutation site. Add `didSet` on the property; every mutation now flows through one observation point. Suppress no-op writes so a `set foo = foo` reassignment doesn't spam.

```swift
public private(set) var transportState: TransportState = .idle {
    didSet {
        if String(describing: oldValue) != String(describing: transportState) {
            DebugLog.network("MyService.transportState \(oldValue) → \(transportState)")
        }
    }
}
```

Reference impl: `Packages/Libraries/Sources/Services/InternetBattleService.swift:201`. Covers 13 mutation sites with one observation.

### 6. Replace silent `try?` with logged catches

The `try?` pattern is the **single biggest cause of "the app silently corrupted something"** bugs. Replace every `try? modelContext.save()` with a `do { try } catch { DebugLog.data(...) }` block — preserves the swallow-on-failure UX semantics, but failure now surfaces in the log.

```swift
// Before
try? modelContext.save()

// After
do {
    try modelContext.save()
} catch {
    DebugLog.data("ShopService.purchase — modelContext.save failed", error: error)
}
```

For inline conditional saves, the same pattern works in one line:

```swift
if tagged > 0 {
    do { try modelContext.save() } catch { DebugLog.data("ProgressTracker — save failed", error: error) }
}
```

## Wiring playbook by surface type

### iOS — app shell (top of `*App.swift`)

Log every coarse lifecycle event the OS gives you. The cumulative trace is invaluable for diagnosing first-launch crashes, background-task expirations, deep-link routing, and scene-phase races.

```swift
@main
struct MyApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup { ContentView() }
            .onChange(of: scenePhase) { old, new in
                DebugLog.lifecycle("scenePhase \(old) → \(new)")
            }
            .onOpenURL { url in
                DebugLog.lifecycle("onOpenURL — scheme=\(url.scheme ?? "<nil>") host=\(url.host ?? "<nil>")")
            }
            #if os(iOS) || os(visionOS) || os(tvOS)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                DebugLog.lifecycle("memory warning")
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                DebugLog.lifecycle("willTerminate")
            }
            #endif
    }
}
```

### iOS — tab views

Log every tab selection with **human-readable names** (not just `0 → 3`). Names help when the log line shows up out of context.

```swift
.onChange(of: selectedTab) { old, new in
    let names = ["Quest", "Sage", "Duel", "HQ", "Hero"]
    let from = names.indices.contains(old) ? names[old] : "tab(\(old))"
    let to = names.indices.contains(new) ? names[new] : "tab(\(new))"
    DebugLog.lifecycle("tab switch \(from) → \(to)", in: "RootTabView")
}
```

### iOS — network services (Gemini, REST clients, WebSockets)

Log the **decision tree**, not just the result. The most useful logs trace "we tried X, it failed because Y, so we fell back to Z". A single "request failed" line is less actionable.

```swift
DebugLog.network("GeminiTutorService.sendMessage — starting SSE stream (history=\(history.count))")
do {
    try await streamResponse(...)
    DebugLog.network("GeminiTutorService.sendMessage — server SSE stream completed")
} catch {
    DebugLog.network("GeminiTutorService.sendMessage — server stream FAILED: \(error)")
    if isNetworkError(error), onDeviceService.isAvailable {
        DebugLog.network("GeminiTutorService — falling back to on-device tutor")
        // ...
    } else {
        DebugLog.error("GeminiTutorService — no fallback available (network=\(isNetworkError(error)), onDevice=\(onDeviceService.isAvailable))", error: error)
    }
}
```

### iOS — MultipeerConnectivity / Network framework delegate callbacks

Log the state transition **at the delegate callback before any DispatchQueue hop**. The hop can race with `@Observable` registrars; logging on the callback thread captures the actual transition independent of whether the UI update succeeds.

```swift
public nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    let label: String
    switch state {
    case .connected:    label = "connected"
    case .connecting:   label = "connecting"
    case .notConnected: label = "notConnected"
    @unknown default:   label = "unknown(\(state.rawValue))"
    }
    DebugLog.network("MultipeerService — peer \(peerID.displayName) → \(label)")
    DispatchQueue.main.async { [weak self] in /* UI updates */ }
}
```

### iOS — SwiftData save sites

See § "Replace silent `try?` with logged catches" above. Audit grep:

```bash
grep -rn "try? modelContext.save()" Packages/Libraries/Sources/Services/
grep -rn "try? context.save()" Packages/Libraries/Sources/Services/
```

Every hit is a detection-blind spot.

### iOS — state machines (`*Machine` structs)

Apply the `didSet` pattern from § 5 on the `phase` / `state` property. Do not wire every mutation site individually. Reference impl: `InternetBattleService.transportState`.

For machines whose mutations live across many files (e.g., `QuizMachine` mutated by `QuizView+Logic`, `QuizView+Result`, etc.), `didSet` is the only sane option.

### Server — Hummingbird controllers

Log entry + each error path. Hummingbird's `LogRequestsMiddleware` already emits a baseline per-request line — use `DebugFileLog.request(_)` (verbose-gated) for deeper context (decoded body shape, validation outcomes).

```swift
@Sendable
func generateContent(request: Request, context: some RequestContext) async throws -> ContentResponse {
    DebugFileLog.request("ContentController — received /content/generate")
    let body = try await request.decode(as: ContentRequest.self, context: context)
    DebugFileLog.request("ContentController — decoded body: imageCount=\(body.images.count), grade=\(body.gradeLevel)")
    // ... process ...
    DebugFileLog.response("ContentController — success; \(topics.count) topic(s) generated")
}
```

### Server — WebSocket handlers

Log connect + disconnect **at the boundary**. The `defer` block on the upgrade handler is the canonical disconnect site.

```swift
.ws("/api/v1/rooms/:code/ws") { _, _, _ in .upgrade([:]) } onUpgrade: { inbound, outbound, context in
    let roomCode = try context.requestContext.parameters.require("code", as: String.self).uppercased()
    let playerId = String(context.request.uri.queryParameters["playerId"] ?? "")
    DebugFileLog.websocket("MyController — WS connect: room=\(roomCode) playerId=\(playerId)")

    defer {
        Task {
            DebugFileLog.websocket("MyController — WS disconnect: room=\(roomCode) playerId=\(playerId)")
            // cleanup
        }
    }
    // handler body
}
```

### Server — external API calls (Gemini, vendor APIs)

Log the **entire lifecycle**: start with payload summary → HTTP status → parse outcome → validation result. Always emit (`.gemini` category). Reference impl: `Server/CuriosityQuestServer/Sources/Services/GeminiService.swift` — 35 lifecycle log lines covering content gen, image gen, validation, parse, retry.

### Server — safety / moderation / COPPA-relevant ops

Always emit (`.safety` category). The paper trail is load-bearing for incident response.

```swift
DebugFileLog.safety("TutorController — crisis detected; returning safety response")
DebugFileLog.safety("ConsentController — consent revoked for device \(token.prefix(8))...")
DebugFileLog.safety("AccountController — data deletion complete for device \(token.prefix(8))...")
```

### Server — admin operations

Always emit, with `DebugFileLog.data(_, alwaysEmit: true)` since admin ops are low-traffic but the audit trail matters. Reference impl: `AdminCurriculumController` — 12 admin CRUD calls forced always-emit, plus a `.gemini` for the AI-gen entry point and `.error` for validation failures.

## Categorization decision tree

When adding a new log line, walk the tree:

1. **External API call lifecycle?** → `.gemini` (or vendor-specific category — always emit)
2. **Persistence operation (Fluent / SwiftData)?** → `.data` (verbose by default; `alwaysEmit: true` for migrations + admin)
3. **Permission / entitlement gate decision?** → `.permission` (iOS) / `.safety` (server, for COPPA)
4. **Moderation / safety pipeline decision?** → `.safety` (server only — always emit)
5. **WebSocket connect / disconnect / message handling?** → `.websocket` (verbose-gated)
6. **HTTP request entry / response shape?** → `.request` / `.response` (verbose-gated)
7. **View / scene lifecycle / tab switch / memory warning?** → `.lifecycle` (iOS)
8. **State-machine transition?** → `.state` (iOS)
9. **Network operation start / completion / error?** → `.network` (iOS) / vendor category (server)
10. **Silently-swallowed error (`try?`, ignored catch)?** → `.error` (always emit)
11. **Boot / init sequence?** → `.startup`

When in doubt, prefer `.error` (always-emit) over `.network` / `.data` (verbose-gated) for anything that smells like a "should be visible if it happens" path.

## When NOT to add logging

- **Per-frame paths** (SpriteKit `update(_:)`, `body` re-evaluations in tight loops). Sampling instead, or trigger-based logs (only on state change).
- **After every value-type assignment** (mutating a `Point` struct). Pointless — no observation possible.
- **Inside protocol default implementations** that fire many times per body evaluation. Log at the call site instead.
- **In test code paths** (unit tests don't need runtime-behavior detection — they ARE the detection).

## When NOT to use `print()`

After the canonical logger exists, the only acceptable `print()` calls are:

- **Test diagnostic output** when a test failure needs immediate stderr visibility
- **Migration scripts / build tools** that run outside the app/server target
- **Temporary debugging** that gets deleted before commit

Production-path `print()` calls in committed code are a regression and should be replaced with `DebugLog.*` / `DebugFileLog.*`.

## Pre-PR checklist

When wiring detection logging across a new surface:

- [ ] Categorized logger utility exists for the target (iOS app or server)
- [ ] All new log lines use a typed category method (`.network`, `.data`, `.error`, etc.) — not the raw emitter
- [ ] No naked `print()` in the diff (verify with `git diff | grep -E '^\+.*print\('`)
- [ ] Silent `try?` save sites in touched files were converted to logged catches
- [ ] `XcodeRefreshCodeIssuesInFile` returns 0 issues on every touched file
- [ ] For server: high-volume categories are env-gated; operational signals are always-emit
- [ ] For iOS: every emission is inside `#if DEBUG` (verified by reading the emitter, not every call site)

## Beyond the basics — production observability (2026 web-research synthesis)

The patterns above are the right entry-level approach for a debug stream that detects unexpected runtime behaviors. Once the app/server grows past early dev or the COPPA / audit surface area expands, six additional concerns surface that the basic `DebugLog` / `DebugFileLog` model doesn't address. Research conducted 2026-05-28 across Apple's unified logging guidance, the Swift server observability ecosystem, and 2026 audit-compliance + silent-failure-detection literature.

### 1. Apple's unified logging (`OSLog` / `Logger`) — when to migrate

The portfolio's iOS `DebugLog` deliberately uses `print()` inside `#if DEBUG` because (a) release builds compile every call to `()` with zero overhead, (b) the grep workflow is trivial, (c) thread-info correlation is straightforward. This is the right default for **detection** during active development.

It is the wrong default for **production diagnostics from real users**. Apple's `Logger` (iOS 14+, supersedes `os_log`) offers:

- **Auto-managed log store** — debug + info levels don't persist by default (you can log liberally without bloat), `notice`+ persists for a few days, `fault`+ for 30 days. The system manages rotation; you don't need to.
- **Subsystem + category** — `Logger(subsystem: "com.cq.app", category: "net")` lets you filter in Console.app and via `log show` to just the area you're debugging across a noisy device stream.
- **Privacy annotations** — `Logger.net.info("device \(token, privacy: .private)")` — Console.app readers see the redacted form, the local debug session sees the full value. **Critical for COPPA-bound apps.**
- **`OSLogStore`-based export** — implement a one-tap "Export logs" button in Settings that pulls process-scoped log entries into a `.json` for parents / support; works in TestFlight + production.
- **Signposts** — `OSSignposter` events surface in Instruments for performance-sensitive ops (`signposter.beginInterval(...)` / `.endInterval(...)`).

**When to migrate from `DebugLog` (print-based) → `Logger`** in CuriosityQuest:

| Trigger | Action |
|---|---|
| App Store launch + need to diagnose user-reported issues without Xcode attached | Migrate or dual-emit |
| TestFlight beta with parents who can't run Xcode but can hit "Export logs" | Migrate `DebugLog.error` + `.permission` to `Logger.error` / `.warning` (which persist by default); rest stays as `print` for dev grep |
| Privacy review surfaces user data flowing into a debug log line | Migrate that specific category to `Logger` with `.private` annotations; or redact at the call site before passing to `DebugLog.*` |
| Performance regression that's hard to find via `print` timestamps | Add `OSSignposter` events for the hot path; keep `DebugLog` for the surrounding decision tree |

The portfolio's `DebugLog` emitter can dual-emit: a one-line addition to the `emit(_:_:_:)` body routes the same message through `Logger` per-category. Migration is non-disruptive: existing call sites stay; the emitter delivers to both streams.

### 2. Privacy by default — never log raw user data

Even in `#if DEBUG`-gated debug streams, treat user data as if it might leak. Reasons: (a) screenshots of dev Console get shared in Slack / GitHub issues; (b) TestFlight users connect their device to Xcode and see your `print` output; (c) future Logger migration assumes you've already classified data.

**Always-redact list** (apply at the call site, before passing to `DebugLog.*`):

- Device tokens: `\(token.prefix(8))...` — first 8 chars are debugging-useful (uniqueness) without being PII-equivalent
- Email addresses: `\(email.prefix(5))***`
- Player display names in multiplayer: keep — they're already user-chosen identifiers, not raw PII
- Auth tokens / JWTs / API keys: **never log**, even prefixed. If a token leaks, rotate the whole credential.
- Full request bodies / response payloads: never log; log shape (`imageCount=3 gradeLevel=4`) not content
- Full URLs with query strings: redact query string when it might contain identifiers (`url.path` not `url.absoluteString`)

Reference impl (CuriosityQuest already follows this pattern in some places):

```swift
// ConsentController — device token redacted before logging
DebugFileLog.safety("ConsentController — consent revoked for device \(token.prefix(8))...")

// AccountController — same pattern
DebugFileLog.safety("AccountController — data deletion requested for device \(token.prefix(8))...")
```

For surfaces that have user-display-name-in-the-clear (multiplayer lobby join logs, etc.), the display name is already a user-chosen alias and isn't raw PII. Server log retention for COPPA is the constraint; redaction at the source is the line of defense.

### 3. Audit logs ≠ debug logs — separate streams

The single most-load-bearing distinction from 2026 compliance research: audit logs are immutable, tamper-evident, retention-policy-bound, access-controlled records of **what users did to the system**. Debug logs are ephemeral records of **what the system did internally**. They have different security profiles, retention requirements, and access controls.

In CuriosityQuest, the following events are **audit-grade** and should NOT live only in `DebugFileLog` (which writes to `/tmp/curiosityquest-server.log` — ephemeral, world-readable, no retention):

| Event | Why audit-grade | Current handling (debug stream only) | What audit-grade adds |
|---|---|---|---|
| `ConsentController` consent verified | COPPA — parental consent record is the legal basis for collecting any kid data | `DebugFileLog.safety(...)` (PR #117) | Persistent record in a dedicated DB table with: device token (redacted), email hash, audit ID, timestamp, IP, user-agent, expiry. Already implemented via the consent record store; the debug log is the index, not the source of truth. ✅ |
| `ConsentController` consent revoked | Same — must be provable that revocation happened on the stated date | `DebugFileLog.safety(...)` | Same — persistent revocation record + retention policy (typically 6 years for COPPA per HIPAA-style guidance). Verify the consent revocation table actually persists this. |
| `AccountController` data deletion request | GDPR Article 17 — right to erasure must be auditable | `DebugFileLog.safety(...)` | Persistent deletion-receipt record with: device token (redacted), request timestamp, completion timestamp, what was deleted (counts, not content). Retention ≥ 3 years to defend against re-request claims. |
| `TutorController` crisis-keyword detected | Safety incident — minor reported a crisis signal | `DebugFileLog.safety(...)` | Append-only incident log + (optionally) operator alert. Retention as long as the per-locale child-safety regulator requires. |

**Pattern**: `DebugFileLog.safety(...)` calls flag "this event happened, here's the line"; the **authoritative record** of the event lives in a dedicated, append-only, retention-managed store. The debug log is the index for live debugging; the audit store is the legal record.

**Retention guidance** (by regulation):

- **COPPA** — consent records retained "for a reasonable time" after the kid's account is deleted; practical floor is 6 years to match HIPAA-style audit norms
- **GDPR** — data-minimization principle; only as long as necessary; document retention policy with a defensible justification
- **PCI DSS 4.0** — 12 months for security logs (3 months hot, 9 months cold) — applies if payment ever ships
- **SOX** — 7 years for financial systems — not currently applicable to CuriosityQuest

Verify that the existing consent + account-deletion tables on the server are actually persisting (not just logging) and have a documented retention policy in `Server/CuriosityQuestServer/docs/data-retention-policy.md`.

### 4. Graduating to a production observability stack (Swift OTel + Grafana / Datadog / Honeycomb)

`DebugFileLog` is sufficient through early Railway deployment + manual SSH log inspection. Past a certain traffic / distribution / SLO threshold, the next stack is **Swift OTel** (`swift-otel/swift-otel`) which provides OTLP-compliant backends for the Swift server observability ecosystem (`swift-log` / `swift-metrics` / `swift-distributed-tracing`).

**Graduation triggers**:

- Traffic exceeds ~1,000 req/min sustained (per-minute log volume exceeds human grep capacity)
- Multi-service deployment (correlating a Gemini SSE stream timeout across the app + server + Gemini takes traces, not log grep)
- Real users are paying or relying on SLOs — silent failure detection (§ 5 below) requires structured traces, not unstructured logs
- COPPA / GDPR audit asks for "show me every consent action on 2026-04-15 between 14:00 and 15:00 UTC" — Loki / Elasticsearch handles this; `grep /tmp/curiosityquest-server.log` does not

**Recommended graduation stack** (open-source-leaning, vendor-neutral via OTLP):

| Layer | Tool |
|---|---|
| Tracing | `swift-distributed-tracing` → Swift OTel OTLP exporter → Grafana Tempo (or Honeycomb hosted) |
| Metrics | `swift-metrics` → Swift OTel OTLP → Prometheus (or Grafana Cloud) |
| Logs | `swift-log` (replaces `DebugFileLog`) → Vector router (PII redaction layer) → Grafana Loki |
| Dashboards | Grafana (or Datadog hosted) |

Swift OTel ships gRPC + HTTP OTLP exporters (recent releases — Alpha 2 added HTTP/Protobuf, mTLS, custom headers, console-log exporter for dev). The migration from `DebugFileLog` to `swift-log` is mostly a search-replace; the typed category methods (`.gemini`, `.websocket`, `.safety`, `.error`) map directly to `swift-log` `Logger` instances with metadata keys.

**When NOT to graduate yet**:

- Pre-launch / early dev — `DebugFileLog` covers the surface area
- Single-VM Railway deployment with one operator — log grep is faster than dashboard config
- The traffic isn't there yet — premature observability infra is its own bug surface

The portfolio rule: graduate when an actual operational pain point (slow MTTR, silent failures, audit asks) forces it; don't graduate as a green-field design choice.

### 5. Silent failure detection — traces > logs (especially for AI / Gemini paths)

The 2026 industry takeaway: distributed traces (with span-typed events) catch silent failures that log-grepping misses. The CuriosityQuest surface most exposed to silent failures is the Gemini tutor / content-generation path:

- `GeminiTutorService` returns a confident-but-wrong response — no exception thrown; nothing logs an error
- `OnDeviceTutorService` falls back but produces a degraded response — fallback flag logged, quality not measured
- Output moderation flags but the user-facing UI doesn't reflect it — server logs `.safety` block; client doesn't surface
- A Gemini SSE stream times out mid-response — connection closes; partial response shows; nothing alerts

**Minimum span schema for AI / tool-using paths** (per 2026 agent-observability guidance):

| Span type | What it captures | Maps to current CQ surface |
|---|---|---|
| **Tool span** | Tool name, args, raw output, duration, retry count, error state | Each Gemini API call. Currently 35 `.gemini` log lines; a span would capture the same data structured for query (`p95 latency by model`, `error rate by endpoint`) |
| **Reasoning span** | The model's plan, action picked, observation, next decision | Lumen's chain-of-thought when it picks a Socratic follow-up. Currently invisible; spans would let you see "the model planned X but executed Y" drift |
| **Retry span** | Each retry attempt + cause | Currently a single fallback-decision log line; spans would show retry storms |
| **Fallback span** | Decision to fall back + which path was taken | Already logged (PR #114); spans would let you measure fallback-rate alerts |

For now (pre-graduation), the `.gemini` category logs are the right entry point. When the GraduationTrigger fires for production observability, the migration is: convert each `DebugFileLog.gemini(...)` call site into `withSpan("gemini.\(operation)") { span in ... }` — span attributes replace the log message parts.

### 6. Performance instrumentation — signposts (iOS) + spans (server)

`DebugLog.network("...")` timestamps in Console give you a rough sense of how long an operation took. For real performance instrumentation:

- **iOS**: `OSSignposter` events surface in **Instruments**. Wrap any operation > ~100ms (model container load, illustration resolver build, Gemini SSE stream, simulation init) in `signposter.beginInterval(...)` / `.endInterval(...)`. Free for release builds — signposts are part of Apple's unified logging and use the same auto-managed store.
- **Server**: `swift-distributed-tracing` `withSpan { }` blocks are the equivalent. Each span has start + end + attributes + error state. Free if Swift OTel exporter is off; when on, ships to Grafana Tempo / Honeycomb / Datadog.

**Rule of thumb**: any operation whose duration could matter to a user (perceived latency, dropped frame) deserves a signpost / span. The decision-tree logs (`DebugLog.network("starting X")` / `"completed X"`) are the next-best thing during dev, but signposts give you the Instruments timeline view.

## Cross-references

- `labsmith/.claude/rules/portfolio.md` § Debug Logging — portfolio cross-ref + lift provenance
- `labsmith/Docs/RESEARCH_RUNTIME_BEHAVIOR_AUDIT_LOGGING_2026.md` — research synthesis behind this rule (30 sources surveyed across 4 domains; 6 codified findings)
- `curiosityquest-app/Packages/Libraries/Sources/Services/DebugLog.swift` — iOS reference impl (single-seam emitter, 7 categories, `#if DEBUG`-gated)
- `curiosityquest-app/Server/CuriosityQuestServer/Sources/Services/DebugFileLog.swift` — server reference impl (8 categories, file+stdout, env-gated verbose)
- `.claude/rules/warnings.md` § Privacy-Gated Frameworks / Entitlement-Gated Frameworks — defensive-gate pattern that `DebugLog.permission` instruments
- `.claude/rules/xcode-agent-safety.md` — why the agent cannot inject `print()` into `.entitlements` / `Info.plist` to detect missing keys (must defer to runtime gates instead)
- `.claude/rules/workflow.md` § "Save Research & Plans to Docs/" — the rule that drove the research artifact's separate persistence

### Research artifact

The raw 2026-05-28 research findings (the reasoning behind each of the 6 § "Beyond the basics" sections above, methodology, sources surveyed, open follow-ups) live as a separate artifact at `labsmith/Docs/RESEARCH_RUNTIME_BEHAVIOR_AUDIT_LOGGING_2026.md` per the `.claude/rules/workflow.md` § "Save Research & Plans to Docs/" rule. Future sessions auditing this synthesis should read the research doc to see what was considered + rejected before updating this rule.

### External research sources (2026-05-28)

- [SwiftLee — OSLog and Unified Logging](https://www.avanderlee.com/debugging/oslog-unified-logging/) — privacy annotations, log levels, subsystem/category pattern
- [Donny Wals — Modern logging with the OSLog framework](https://www.donnywals.com/modern-logging-with-the-oslog-framework-in-swift/) — `Logger` vs `os_log`, `OSLogStore` export pattern
- [BleepingSwift — Structured Logging in Swift](https://bleepingswift.com/blog/structured-logging-logger-oslog) — production logging patterns, retention defaults
- [swift-otel/swift-otel](https://github.com/swift-otel/swift-otel) — OTLP backend for swift-log + swift-metrics + swift-distributed-tracing
- [OpenTelemetry Swift](https://opentelemetry.io/docs/languages/swift/) — official OTel Swift docs (last updated January 2026)
- [Audit Logging vs Debug Logging — Compliance Best Practices 2026](https://www.netwitness.com/blog/compliance-ready-logging-best-practices/) — separation of streams, retention requirements by regulation
- [Audit Logging Without Compromising Privacy](https://dasroot.net/posts/2026/01/audit-logging-privacy-security/) — PII redaction, tokenization, retention policy alignment
- [How to Detect Silent Failures in Microservices](https://www.frugaltesting.com/blog/how-to-detect-silent-failures-in-microservices-using-advanced-observability-techniques) — span schemas for AI / tool-using paths, trace-based vs log-based detection
- [Microservices Observability: Distributed Tracing 2026](https://dasroot.net/posts/2026/03/microservices-observability-distributed-tracing-logging-2026/) — AIOps trends, MTTR improvements from trace-based observability
- [Agent observability complete guide 2026 (Braintrust)](https://www.braintrust.dev/articles/agent-observability-complete-guide-2026) — minimum viable span schema for AI agents (tool / reasoning / retry / fallback)
- [The complete guide to LLM observability 2026 (Portkey)](https://portkey.ai/blog/the-complete-guide-to-llm-observability/) — quality-aware alerting, drift detection

## Real-world cascade lessons (R151 #583; lifted from CQ TTS cascade 2026-05-29)

Codified after CuriosityQuest TTS cascade (PRs #130 → #138) walked through 7 distinct root causes stacked on top of each other. The instrumentation pattern paid off — pre-existing per-chunk SSE + TTS lifecycle logs (PR #130) and body-sniff cap (PR #136) were what made the next layer's bug observable.

### Body-sniff sizing — default 1500-2000 bytes, not 200

When adding a `#if DEBUG` body-content log line for non-200 responses:

```swift
// ❌ Too small — upstream JSON error bodies routinely exceed 200B
let sample = String(data: data.prefix(200), encoding: .utf8) ?? "<binary>"

// ✅ Canonical
let sample = String(data: data.prefix(1500), encoding: .utf8) ?? "<binary>"
```

**Cost-benefit**: 1.5KB log line on rare error paths costs nothing; one-glance diagnosis vs an extra PR round-trip when the upstream error JSON exceeds the cap. CQ PR #136 (200 → 1500) directly enabled PR #137 (disable gzip on TTS).

### Auth header consistency check — first diagnostic for "silently fails"

When an endpoint "silently fails" (200 status but empty body, or 401 with no clear cause), the first diagnostic is **comparing its auth header set against every other server-facing client in the codebase**. The outlier is usually the bug.

```bash
# Find auth-header attachment sites across the iOS service layer
grep -rn 'X-API-Key\|Authorization' Packages/Libraries/Sources/Services/

# The endpoint missing the header (or using a stale one) is the silent-failure source.
```

CQ PR #131 fix: TTS endpoint was missing `X-API-Key`. Discovered by comparing TTSService.swift's header set against ContentService / TutorService / GeminiService.

### "Don't declare fixed until end-to-end terminal success log appears"

In a layered system, each fix can reveal the next layer. **Write "next test should show X" rather than "this should be the final fix"** until the observable success log line is in hand.

CQ TTS cascade had 7 PRs before the terminal success log (`[TTS] playback started; duration=2.4s`) appeared. Every PR before #138 felt like "the final fix" until the next layer surfaced.

### Pre-instrument before diagnosis

The cascade worked because PRs #130 (per-chunk SSE + TTS lifecycle) and #136 (1500-byte body sniff) were already in place when the layered bugs surfaced. **The debug-logging rule's "wire instrumentation early" pattern paid full cost back on the first real diagnostic.** Don't wait for a bug to wire diagnostic logs; wire them when the code is first authored.

### Cross-references

- `labsmith/.claude/rules/audio-pipeline.md` — companion rule from the same cascade (gzip + WAV-wrap + OSStatus FourCC)
- `labsmith/.claude/rules/forgekit.md` § Server `/version` endpoint — sibling lift from same cascade
- `labsmith/Docs/RESEARCH_TTS_AUDIO_PIPELINE_CASCADE_2026-05-29.md` — full 8-lesson cascade table + per-layer diagnosis methodology
<!-- END LABSMITH-SYNCED CONTENT -->
