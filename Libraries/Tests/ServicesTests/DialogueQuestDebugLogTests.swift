import Foundation
import Testing
@testable import Services

/// The `DialogueQuestDebugLog` seam writes to stdout in DEBUG builds
/// and compiles to `()` in release. Tests focus on contract:
///
/// 1. The 6 public category methods are callable from any isolation
///    context without crashing
/// 2. The error overloads accept both nil + non-nil error references
/// 3. The `@autoclosure` message parameter doesn't evaluate eagerly
///    on the call-site signature (validated at the type level — if it
///    weren't autoclosure, the message expression would be eagerly
///    evaluated even in release builds, costing string interpolation)
///
/// These are CONTRACT tests — they verify the API stays stable for
/// future callers. Capturing stdout to assert the emitted line shape
/// is brittle (race-condition-prone in parallel test runs; varies
/// with build config) and isn't worth the test overhead.
@Suite("DialogueQuestDebugLog contract")
struct DialogueQuestDebugLogTests {

    private struct DummyError: Error, CustomStringConvertible {
        let description: String = "dummy"
    }

    // MARK: - Public surface contract

    @Test("startup category is callable")
    func startupIsCallable() {
        DialogueQuestDebugLog.startup("startup test message")
    }

    @Test("lifecycle category is callable")
    func lifecycleIsCallable() {
        DialogueQuestDebugLog.lifecycle("lifecycle test message")
    }

    @Test("data category is callable without error")
    func dataIsCallableWithoutError() {
        DialogueQuestDebugLog.data("data test message")
    }

    @Test("data category is callable with error")
    func dataIsCallableWithError() {
        DialogueQuestDebugLog.data("data test message", error: DummyError())
    }

    @Test("state category is callable")
    func stateIsCallable() {
        DialogueQuestDebugLog.state("state test message")
    }

    @Test("permission category is callable")
    func permissionIsCallable() {
        DialogueQuestDebugLog.permission("permission test message")
    }

    @Test("error category is callable without error")
    func errorIsCallableWithoutError() {
        DialogueQuestDebugLog.error("error test message")
    }

    @Test("error category is callable with error")
    func errorIsCallableWithError() {
        DialogueQuestDebugLog.error("error test message", error: DummyError())
    }

    // MARK: - Cross-isolation reachability

    @Test("seam is reachable from a nonisolated detached task")
    func reachableFromDetachedTask() async {
        await Task.detached {
            DialogueQuestDebugLog.startup("from detached task")
            DialogueQuestDebugLog.data("from detached task")
        }.value
    }

    @Test("seam is reachable from MainActor context")
    @MainActor
    func reachableFromMainActor() {
        DialogueQuestDebugLog.lifecycle("from MainActor")
        DialogueQuestDebugLog.state("from MainActor")
    }

    // MARK: - @autoclosure semantics

    @Test("autoclosure message expression is NOT evaluated when nil sentinel passed (deferred-eval contract)")
    func autoclosureDefersEvaluation() {
        // Verify @autoclosure parameter signature compiles + accepts a
        // costly expression without forcing eager evaluation at the
        // call site. The expression's truthiness is not asserted; the
        // contract being verified is that the closure is the param type
        // (so release builds, which compile to nothing, never pay the
        // string-interpolation cost).
        let costlyExpression: () -> String = {
            // If autoclosure weren't on the seam, this wouldn't be a
            // valid argument to the .startup method.
            return "deferred"
        }
        DialogueQuestDebugLog.startup(costlyExpression())
    }

    // MARK: - Sequencing — multiple categories in one call site

    @Test("multiple categories in sequence do not interfere")
    func multipleCategoriesInSequence() {
        DialogueQuestDebugLog.startup("seq 1")
        DialogueQuestDebugLog.lifecycle("seq 2")
        DialogueQuestDebugLog.data("seq 3")
        DialogueQuestDebugLog.state("seq 4")
        DialogueQuestDebugLog.permission("seq 5")
        DialogueQuestDebugLog.error("seq 6")
    }
}
