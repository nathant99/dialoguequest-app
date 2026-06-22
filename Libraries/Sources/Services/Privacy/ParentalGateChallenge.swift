import Foundation

/// Lightweight parental-gate challenge. Phase 1 ships a 1-digit multiplication
/// challenge that a tween reader can shoulder-surf-resist (the answer pool is
/// large enough — 6×6 through 9×9 — that random guessing has < 1/16 odds per
/// attempt). Full Family Controls integration replaces this gate once the
/// `*.entitlements` GUI work lands per `Docs/HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md`.
///
/// The gate exists to be reusable across surfaces:
/// - Settings → "Record parental consent" (existing consumer)
/// - Future: external link affordances (privacy policy / studio website /
///   donation link) per `.claude/rules/age-assurance.md` + `Docs/FEATURE_PLAN.md`
///   § "Parental gates — Required for external links and data-sharing permissions"
public nonisolated struct ParentalGateChallenge: Sendable, Equatable, Hashable {
    public let a: Int
    public let b: Int

    public init(a: Int, b: Int) {
        self.a = a
        self.b = b
    }

    public var expected: Int { a * b }

    public var prompt: String { "What's \(a) × \(b)?" }

    /// Generate a fresh challenge. Uses a single-digit multiplication
    /// in the 6×6...9×9 range — large enough to deter shoulder-surfing
    /// but trivially solvable by an adult.
    public static func random(
        using generator: inout some RandomNumberGenerator
    ) -> ParentalGateChallenge {
        let a = Int.random(in: 6...9, using: &generator)
        let b = Int.random(in: 6...9, using: &generator)
        return ParentalGateChallenge(a: a, b: b)
    }

    public static func random() -> ParentalGateChallenge {
        var rng = SystemRandomNumberGenerator()
        return random(using: &rng)
    }

    /// Return true when the supplied raw answer matches the expected
    /// product. Whitespace + non-numeric input fail closed.
    public func accepts(_ answer: String) -> Bool {
        guard let parsed = Int(answer.trimmingCharacters(in: .whitespaces)) else {
            return false
        }
        return parsed == expected
    }
}
