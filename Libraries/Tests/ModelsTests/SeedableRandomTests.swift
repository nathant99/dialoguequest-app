import Foundation
import Testing
@testable import Models

@Suite("SeedableRandom — deterministic LCG")
struct SeedableRandomTests {

    @Test("Same seed produces identical sequences")
    func sameSeedReplays() {
        var a = SeedableRandom(seed: 42)
        var b = SeedableRandom(seed: 42)
        for _ in 0..<32 {
            #expect(a.next() == b.next())
        }
    }

    @Test("Different seeds diverge within first call")
    func differentSeedsDiverge() {
        var a = SeedableRandom(seed: 1)
        var b = SeedableRandom(seed: 2)
        #expect(a.next() != b.next())
    }

    @Test("Seed 0 is rewritten to 1 (avoid all-zero LCG collapse)")
    func zeroSeedRewritten() {
        var a = SeedableRandom(seed: 0)
        var b = SeedableRandom(seed: 1)
        #expect(a.next() == b.next())
    }

    @Test("pick(from:) returns nil for empty collection without trapping")
    func pickFromEmptyReturnsNil() {
        var rng = SeedableRandom(seed: 7)
        let empty: [Int] = []
        #expect(rng.pick(from: empty) == nil)
    }

    @Test("pick(from:) returns elements from within the source collection")
    func pickFromNonEmptyReturnsContained() {
        var rng = SeedableRandom(seed: 13)
        let choices = ["a", "b", "c", "d"]
        for _ in 0..<16 {
            let picked = rng.pick(from: choices)
            #expect(picked != nil)
            #expect(choices.contains(picked ?? ""))
        }
    }

    @Test("Sequence is reproducible after copy")
    func valueSemanticsSnapshot() {
        var primary = SeedableRandom(seed: 99)
        _ = primary.next()
        let snapshot = primary
        var fork = snapshot
        #expect(primary.next() == fork.next())
    }
}
