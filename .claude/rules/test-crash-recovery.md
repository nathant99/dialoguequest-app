# Test Crash Recovery (Agent Procedure)

**Companion to `xcode-agent-safety.md`.** This rule governs how an in-Xcode Claude agent responds to test crashes WITHOUT triggering the workspace-reload failure mode.

## The compounding problem

**Xcode 26 introduced a regression**: when a test crashes (any reason — `fatalError`, force-unwrap, EXC_BAD_ACCESS, MainActor deinit SIGABRT, etc.), the simulator can become unbootable for subsequent runs. Every subsequent `RunSomeTests` / `RunAllTests` either fails immediately or returns garbage. This regression did NOT exist pre-26.

For the in-Xcode agent (per `xcode-agent-safety.md`), this means a single test crash compounds — the next 5 attempts also fail until reset. The naive "just re-run the test" loop is exactly wrong; it produces a session full of false-failure signals AND wastes agent context.

## Detection signals

The agent should treat the following as **probable test crash + simulator brick**, not as a real test failure:

1. `RunSomeTests` returns `notRun > 0` AND `failed == 0` (build failure OR simulator stuck)
2. `RunSomeTests` returns "test runner crashed" or "The test runner hung before establishing connection"
3. `RunSomeTests` / `RunAllTests` hangs > 60 seconds with no progress
4. Second consecutive run of the same test returns different results (transient simulator state)
5. `GetBuildLog` shows compilation succeeded but test bundle won't launch
6. MCP returns `summary.counts.notRun > 0` despite the test list being non-empty

## Recovery procedure (in order)

### Step 1 — Run simulator recovery (~10s)

Via Bash:

```bash
xcrun simctl shutdown all && xcrun simctl erase all
```

This shuts down all simulators and erases their state. Re-issuing tests boots a fresh simulator.

**Do NOT close Xcode.** Xcode-cache invalidation (delete `Libraries/.swiftpm/`, DerivedData purge, package re-add) is a separate, user-driven recovery — not the simctl-brick path.

### Step 2 — Diagnostic re-run

Re-issue `RunSomeTests` on the **same suite** that crashed. Three outcomes:

| Outcome | Interpretation |
|---|---|
| Passes | **Flake on Xcode 26 simulator regression**; no source change made; log "transient simulator brick, recovered via simctl erase" and continue |
| Fails with same crash signature | Real test failure — proceed to Step 3 |
| Different failure | Likely a second issue surfaced; investigate independently |

### Step 3 — Isolate the offending function

If Step 2 confirms a real crash:

1. Run `RunSomeTests` on the **suite minus the suspected crashing test** (use `arguments` or `tags` to exclude). If the rest pass cleanly, the previously failing test is the culprit
2. Read the crashing test function source via `XcodeRead`
3. Apply the `testing.md` § "Crash-Resilience Defaults" checklist to the function:
   - Is the suite a `struct`? If `class`, is there `nonisolated deinit {}`?
   - Are parameterized `@Test arguments:` deduplicated?
   - Is any `ModelConfiguration` missing `cloudKitDatabase: .none`?
   - Are FoundationModels calls gated on `SystemLanguageModel.default.availability`?
   - Are any `@unchecked Sendable` annotations present?
   - Is `Bundle.module` accessed from a `nonisolated` context without an isolation hop?

### Step 4 — Capture stack trace

Get the crash details from xcresult before they're overwritten:

```bash
xcrun xcresulttool get \
    --path ~/Library/Developer/Xcode/DerivedData/<Workspace>-*/Logs/Test/*.xcresult \
    --id <crash-id> \
    --format json
```

For Xcode 26+, use the new `xcresulttool graph` subcommand:

```bash
xcrun xcresulttool graph --path ~/Library/Developer/Xcode/DerivedData/<Workspace>-*/Logs/Test/*.xcresult
```

**Never ask the user to paste the crash log.** The agent has access to xcresult via Bash; use it.

### Step 5 — Fix in source

Once the root cause is identified, apply the appropriate fix from `testing.md` § Crash-Resilience Defaults. Common fixes:

- Add `nonisolated deinit {}` to `final class` test fixtures
- Convert `final class` test suite to `struct` (no deinit needed)
- Add `cloudKitDatabase: .none` to `ModelConfiguration`
- Wrap FoundationModels test in `try #require(SystemLanguageModel.default.availability == .available)`
- Deduplicate `@Test arguments:` with `zip()` or `Array(Set(…))`
- Replace `@unchecked Sendable` with proper `nonisolated` + actor refactor
- Mark `Bundle.module`-using helpers with explicit isolation

### Step 6 — Verify fix

Re-run the offending suite via `RunSomeTests`. If it now passes:

- Capture the diagnosis + fix in `CLAUDE.md` § "Things That Will Bite You" (single line summary)
- Continue with the original task

If it still crashes:

- Run with TSan enabled: `xcodebuild test -enableThreadSanitizer YES -destination 'platform=iOS Simulator,name=iPhone 17'` via Bash (`run_in_background: true`)
- Read TSan output for race conditions
- If TSan reveals nothing, escalate to user with full xcresult dump + identified fix candidates

## What NOT to do

1. **Do NOT close Xcode** without explicit user request — the agent's IDE context is shared with the workspace per `xcode-agent-safety.md`
2. **Do NOT run `xcodebuild clean`** unless the test crash is build-failure-related (per Step 1's `GetBuildLog` check)
3. **Do NOT delete DerivedData** without explicit user request — same Xcode-cache invalidation concern as item 1
4. **Do NOT loop simulator-reset → re-run more than 3 times** — if 3 consecutive Step 2 attempts fail the same way, the failure is real (Step 3 onward)
5. **Do NOT use `.serialized` to "fix" parallel crashes** without identifying the underlying race — `.serialized` masks rather than fixes (per `testing.md`)
6. **Do NOT swallow crashes with `try?` in production code** to make tests pass — fix the underlying issue

## Quick-reference: which Step matches which symptom

| Symptom | Start at Step |
|---|---|
| Single `RunSomeTests` returns notRun > 0 | 1 |
| Test that passed earlier suddenly hangs | 1 |
| Same test crashes twice in a row | 3 |
| MainActor deinit SIGABRT (swift#87316) | 5 — add `nonisolated deinit {}` |
| Duplicate parameterized argument crash (swift-testing#1027) | 5 — deduplicate |
| SwiftData "cannot create container" | 5 — add `cloudKitDatabase: .none` |
| FoundationModels session hang | 5 — gate on availability + add timeout |
| EXC_BAD_ACCESS with no clear stack | 6 — enable TSan |

## References

- `xcode-agent-safety.md` — companion rule (agent operates in Xcode; never restart Xcode)
- `testing.md` § Crash-Resilience Defaults — the canonical fix checklist
- `Docs/RESEARCH_TEST_CRASH_PATTERNS.md` — full research artifact with sources
- [Apple — `xcresulttool`](https://developer.apple.com/documentation/xcode/diagnosing-memory-thread-and-crash-issues-early)
- [swiftlang/swift#87316](https://github.com/swiftlang/swift/issues/87316) — MainActor deinit SIGABRT
- [swift-testing#1027](https://github.com/swiftlang/swift-testing/issues/1027) — Duplicate arguments crash
<!-- END LABSMITH-SYNCED CONTENT -->
