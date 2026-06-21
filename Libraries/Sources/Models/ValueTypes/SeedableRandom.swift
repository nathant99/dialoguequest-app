import Foundation

/// Deterministic linear-congruential generator used to make tree-builder
/// reset states reproducible in tests + onboarding flows.
///
/// Uses the Numerical Recipes constants (a = 1664525, c = 1013904223) so
/// the sequence is well-studied and small enough to fold through Swift's
/// `RandomNumberGenerator` protocol without 64-bit overflow gymnastics.
public nonisolated struct SeedableRandom: RandomNumberGenerator, Sendable, Hashable {

    private var state: UInt64

    public init(seed: UInt64) {
        // Seed 0 collapses the LCG to all-zero output. Bump to 1 silently
        // — callers passing 0 want determinism, not the zero sequence.
        self.state = seed == 0 ? 1 : seed
    }

    public mutating func next() -> UInt64 {
        // Two 32-bit LCG steps, packed into a 64-bit result. The high and
        // low halves come from distinct iterations so the output stream
        // doesn't inherit the LCG's well-known low-bit cycle.
        let high = step()
        let low = step()
        return (UInt64(high) << 32) | UInt64(low)
    }

    private mutating func step() -> UInt32 {
        state = (state &* 1_664_525) &+ 1_013_904_223
        return UInt32(truncatingIfNeeded: state >> 16)
    }
}

public extension SeedableRandom {
    /// Pick a uniformly-distributed element from a non-empty collection.
    /// Returns `nil` for empty collections rather than trapping.
    mutating func pick<T>(from collection: [T]) -> T? {
        guard !collection.isEmpty else { return nil }
        return collection[Int(next() % UInt64(collection.count))]
    }
}
