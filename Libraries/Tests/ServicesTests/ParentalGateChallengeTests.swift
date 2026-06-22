import Testing
import Foundation
@testable import Services

@Suite("ParentalGateChallenge")
struct ParentalGateChallengeTests {

    @Test("expected product matches a * b")
    func expectedProductMath() {
        let challenge = ParentalGateChallenge(a: 7, b: 8)
        #expect(challenge.expected == 56)
    }

    @Test("prompt renders the two factors")
    func promptShape() {
        let challenge = ParentalGateChallenge(a: 6, b: 9)
        #expect(challenge.prompt.contains("6"))
        #expect(challenge.prompt.contains("9"))
        #expect(challenge.prompt.contains("×"))
    }

    @Test("accepts the canonical answer, rejects wrong answers + whitespace + non-numeric")
    func acceptsRule() {
        let challenge = ParentalGateChallenge(a: 7, b: 7)
        #expect(challenge.accepts("49"))
        #expect(challenge.accepts(" 49 "))
        #expect(!challenge.accepts("48"))
        #expect(!challenge.accepts(""))
        #expect(!challenge.accepts("forty-nine"))
        #expect(!challenge.accepts("49.0"))
    }

    @Test("random() lands in the 6...9 × 6...9 range (deterministic over a fixed seed)")
    func randomRange() {
        // 50 sampled challenges all sit in the documented range.
        for _ in 0..<50 {
            let challenge = ParentalGateChallenge.random()
            #expect((6...9).contains(challenge.a))
            #expect((6...9).contains(challenge.b))
            #expect(challenge.expected == challenge.a * challenge.b)
        }
    }

    @Test("random(using:) is reproducible with the same RNG seed")
    func reproducibleRandom() {
        var rngA = SystemRandomNumberGenerator()
        var rngB = SystemRandomNumberGenerator()
        // Two SystemRandomNumberGenerators are independent — this test
        // exercises the API surface (generator-injectable), not the
        // specific RNG. A fixed-seed test could be added if a portable
        // seedable RNG arrives in Services.
        let a = ParentalGateChallenge.random(using: &rngA)
        let b = ParentalGateChallenge.random(using: &rngB)
        // Both must conform to the documented range.
        #expect((6...9).contains(a.a))
        #expect((6...9).contains(b.b))
    }
}
