import Testing
import Foundation
import Models
@testable import AIMentor

/// Phase 1 performance-budget tests for `PatterFallbacks`.
///
/// `PatterFallbacks` is `PatterMentor`'s always-available fallback path —
/// pure value-type string lookups, no FoundationModels session. It's the
/// canonical hot path whenever the LM is unavailable (no Apple Intelligence
/// device, throttled state, modelNotReady) AND the proxy for "AI analysis
/// call queue-bounded" in the FEATURE_PLAN exit criterion: every call
/// returns within a small bound so re-entrant
/// `.task(id: machine.selectedNodeID)` and `PatterReactionService
/// .onTreeChanged` never accumulate latency.
///
/// We test the fallback path directly (NOT `PatterMentor.analyze`) so
/// the test result is independent of whether `SystemLanguageModel
/// .default.availability == .available` on the build host. When FM is
/// available the LM session takes seconds — that's not the budget we're
/// guarding here.
///
/// Per-call ceiling: 5 ms (≈ ⅓ of a 60 fps frame). The fallbacks are
/// dictionary lookups, so observed mean is sub-millisecond; 5 ms is a
/// regression-detector ceiling, not the target.
@Suite("PatterFallbacks performance budget")
struct PatterMentorFallbackPerformanceTests {

    static let perCallBudgetMs: Double = 5.0

    @Test func lineAnalysisFallbackHotPath() {
        var observations: [Double] = []
        for i in 0..<100 {
            let line = "I'm fine\(i)."
            observations.append(Self.measureMs {
                _ = PatterFallbacks.lineAnalysisFallback(for: line, mood: .quietConflict)
            })
        }
        let p95 = Self.p95(observations)
        #expect(p95 < Self.perCallBudgetMs,
                "lineAnalysisFallback P95 \(p95) ms exceeds \(Self.perCallBudgetMs) ms — fallback path is no longer queue-friendly")
    }

    @Test func branchCheckFallbackAcrossAllMoods() {
        let moods: [DialogueMood?] = DialogueMood.allCases.map { Optional($0) } + [nil]
        var observations: [Double] = []
        for mood in moods {
            for _ in 0..<10 {
                observations.append(Self.measureMs {
                    _ = PatterFallbacks.branchCheckFallback(for: mood)
                })
            }
        }
        let p95 = Self.p95(observations)
        #expect(p95 < Self.perCallBudgetMs)
    }

    @Test func tagBalanceFallbackAcrossAllClassifications() {
        var observations: [Double] = []
        for classification in DialogueTag.Classification.allCases {
            for _ in 0..<10 {
                observations.append(Self.measureMs {
                    _ = PatterFallbacks.tagBalanceFallback(dominant: classification)
                })
            }
        }
        let p95 = Self.p95(observations)
        #expect(p95 < Self.perCallBudgetMs)
    }

    // MARK: - Helpers

    private static func measureMs(_ block: () -> Void) -> Double {
        let start = ContinuousClock().now
        block()
        let end = ContinuousClock().now
        return (end - start).toMilliseconds()
    }

    private static func p95(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let rank = Int(ceil(0.95 * Double(sorted.count))) - 1
        return sorted[max(0, min(sorted.count - 1, rank))]
    }
}

private extension Duration {
    func toMilliseconds() -> Double {
        let components = self.components
        let seconds = Double(components.seconds)
        let attoseconds = Double(components.attoseconds) / 1e18
        return (seconds + attoseconds) * 1_000.0
    }
}
