import Foundation

/// Portfolio-canonical categorized detection-logging seam per
/// `.claude/rules/debug-logging.md`. Every emission is `#if DEBUG`-gated
/// at the emitter so release builds compile to `()` with zero overhead —
/// callers never need to wrap their own call sites in `#if DEBUG`.
///
/// **Why a seam, not naked `print()`**: a naked `print` is invisible to
/// release builds (Apple stdout doesn't show), unsearchable when there
/// are thousands, and unstructured. The seam gives every emission:
///
/// - **Category prefix** (`[DATA]` / `[ERR]` / `[LIFE]` / ...) — maps to
///   "what kind of bug it catches" so the reader can immediately
///   classify the line
/// - **Thread tag** (`[thread=main]` / `[thread=bg(name)]`) — correlates
///   with crash thread numbers from sysdiagnose / Xcode debug navigator
/// - **Caller name** (`#function` default) — surface tag without the
///   call site having to repeat itself
///
/// **Categories chosen for DialogueQuest's surface area** (no `.network`
/// because the app is fully on-device; no `.websocket` because there
/// is no server):
///
/// | Category | What kind of bug it catches |
/// |---|---|
/// | `.startup`    | Launch crashes, ModelContainer recovery, registry populate failures |
/// | `.lifecycle`  | Scene-phase races, tab-switch unexpected sequencing, sheet present/dismiss |
/// | `.data`       | Silent SwiftData `try? save()` failures, encode/decode regressions |
/// | `.state`      | DialogueTreeMachine illegal transitions, missing `reset()` paths |
/// | `.permission` | Privacy-gated probe decisions (DeclaredAgeRangeGate, VoiceActingCoach, Live Activity) |
/// | `.error`      | Non-fatal errors otherwise swallowed by `try?` — always-emit register |
///
/// **Why `nonisolated public enum`**: pure value-typed namespace so
/// callers across MainActor / nonisolated boundaries reach it without
/// a hop. The emitter itself only touches `Thread.current` + `print`,
/// both safe from any context.
public nonisolated enum DialogueQuestDebugLog {

    /// Launch crashes, ModelContainer recovery, registry populate paths.
    public static func startup(
        _ message: @autoclosure () -> String,
        _ context: StaticString = #function
    ) {
        emit("STARTUP", message(), context)
    }

    /// Scene-phase / tab / sheet lifecycle.
    public static func lifecycle(
        _ message: @autoclosure () -> String,
        _ context: StaticString = #function
    ) {
        emit("LIFE", message(), context)
    }

    /// SwiftData saves, encode/decode roundtrips, UserDefaults writes.
    /// Convenience overload that captures the underlying Error.
    public static func data(
        _ message: @autoclosure () -> String,
        error: Error? = nil,
        _ context: StaticString = #function
    ) {
        if let error {
            emit("DATA", "\(message()) — error: \(error)", context)
        } else {
            emit("DATA", message(), context)
        }
    }

    /// State-machine transitions + invalid-input rejections.
    public static func state(
        _ message: @autoclosure () -> String,
        _ context: StaticString = #function
    ) {
        emit("STATE", message(), context)
    }

    /// Privacy-gated probe decisions.
    public static func permission(
        _ message: @autoclosure () -> String,
        _ context: StaticString = #function
    ) {
        emit("PERM", message(), context)
    }

    /// Non-fatal errors that would otherwise be silently swallowed.
    public static func error(
        _ message: @autoclosure () -> String,
        error: Error? = nil,
        _ context: StaticString = #function
    ) {
        if let error {
            emit("ERR", "\(message()) — error: \(error)", context)
        } else {
            emit("ERR", message(), context)
        }
    }

    /// Single emission seam. `#if DEBUG`-gated so release builds compile
    /// to `()`. The `@autoclosure` parameter on the public methods means
    /// release builds don't even pay the string-interpolation cost when
    /// the body is non-trivial.
    private static func emit(
        _ category: String,
        _ message: String,
        _ context: StaticString
    ) {
        #if DEBUG
        let thread: String
        if Thread.isMainThread {
            thread = "main"
        } else {
            let name = Thread.current.name ?? "unnamed"
            thread = "bg(\(name))"
        }
        print("[\(category)] \(context) — \(message) [thread=\(thread)]")
        #endif
    }
}
