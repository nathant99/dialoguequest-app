import Foundation
import Testing
@testable import Services

@Suite("DDAEngine")
struct DDAEngineTests {

    @Test("Fresh engine sits at midpoint between floor + ceiling")
    func midpointInit() throws {
        let engine = DDAEngine()
        let expectedReflection = (DDAEngine.Config.default.branchReflectionFloor
            + DDAEngine.Config.default.branchReflectionCeiling) / 2
        let expectedVoice = (DDAEngine.Config.default.voiceMatchFloor
            + DDAEngine.Config.default.voiceMatchCeiling) / 2
        #expect(abs(engine.currentReflectionThreshold - expectedReflection) < 1e-9)
        #expect(abs(engine.currentVoiceMatchFloor - expectedVoice) < 1e-9)
        #expect(engine.recentOutcomes.isEmpty)
    }

    @Test("High performance ramps thresholds up toward the ceiling")
    func rampsUpOnHighPerformance() throws {
        var engine = DDAEngine()
        for _ in 0..<10 {
            engine.record(outcome: DDAEngine.RecentOutcome(
                reflectionRatio: 1.0,
                averageVoiceMatch: 1.0
            ))
        }
        // Should be at or near the ceiling.
        #expect(engine.currentReflectionThreshold >= engine.config.branchReflectionCeiling - 0.01)
        #expect(engine.currentVoiceMatchFloor >= engine.config.voiceMatchCeiling - 0.01)
    }

    @Test("Struggling sessions ramp thresholds down toward the floor")
    func rampsDownOnLowPerformance() throws {
        var engine = DDAEngine()
        for _ in 0..<10 {
            engine.record(outcome: DDAEngine.RecentOutcome(
                reflectionRatio: 0.0,
                averageVoiceMatch: 0.0
            ))
        }
        #expect(engine.currentReflectionThreshold <= engine.config.branchReflectionFloor + 0.01)
        #expect(engine.currentVoiceMatchFloor <= engine.config.voiceMatchFloor + 0.01)
    }

    @Test("Single high-performance outlier cannot exceed rampStep delta")
    func singleOutlierBoundedByRampStep() throws {
        var engine = DDAEngine()
        let initialThreshold = engine.currentReflectionThreshold
        engine.record(outcome: DDAEngine.RecentOutcome(
            reflectionRatio: 1.0,
            averageVoiceMatch: 1.0
        ))
        let delta = engine.currentReflectionThreshold - initialThreshold
        #expect(delta <= engine.config.rampStep + 1e-9, "Threshold moved more than rampStep in a single record call: \(delta)")
    }

    @Test("Window size limits how many outcomes are retained")
    func windowCapped() throws {
        var engine = DDAEngine(config: .init(windowSize: 3))
        for _ in 0..<10 {
            engine.record(outcome: DDAEngine.RecentOutcome(
                reflectionRatio: 0.5,
                averageVoiceMatch: 0.5
            ))
        }
        #expect(engine.recentOutcomes.count == 3)
    }

    @Test("Reset returns the engine to its initial state but keeps config")
    func resetIsTotal() throws {
        var engine = DDAEngine(config: .init(windowSize: 2))
        engine.record(outcome: DDAEngine.RecentOutcome(reflectionRatio: 1, averageVoiceMatch: 1))
        engine.reset()
        let expectedReflection = (engine.config.branchReflectionFloor
            + engine.config.branchReflectionCeiling) / 2
        #expect(abs(engine.currentReflectionThreshold - expectedReflection) < 1e-9)
        #expect(engine.recentOutcomes.isEmpty)
        #expect(engine.config.windowSize == 2)
    }

    @Test("Thresholds never escape floor / ceiling bounds")
    func boundsAreRespected() throws {
        // Use extreme rampStep to try to escape bounds — engine must clamp.
        var engine = DDAEngine(config: .init(
            windowSize: 1,
            rampStep: 5.0,
            branchReflectionFloor: 0.20,
            branchReflectionCeiling: 0.90,
            voiceMatchFloor: 0.30,
            voiceMatchCeiling: 0.80
        ))
        engine.record(outcome: DDAEngine.RecentOutcome(reflectionRatio: 1, averageVoiceMatch: 1))
        #expect(engine.currentReflectionThreshold <= 0.90)
        #expect(engine.currentReflectionThreshold >= 0.20)
        #expect(engine.currentVoiceMatchFloor <= 0.80)
        #expect(engine.currentVoiceMatchFloor >= 0.30)
    }

    @Test("Variable-reward bonus surfaces approximately at the target rate")
    func variableRewardRate() throws {
        // Stat-rate test: 1000 trials, ~20% rate ± slack.
        var hits = 0
        let trials = 1000
        for i in 0..<trials {
            var rng = SeedableLCG(seed: UInt64(i + 1))
            if VariableReward.shouldShowBonus(probability: 0.20, rng: &rng) {
                hits += 1
            }
        }
        let observedRate = Double(hits) / Double(trials)
        #expect(observedRate > 0.14 && observedRate < 0.26, "Rate \(observedRate) outside tolerance")
    }
}

/// Lightweight deterministic RNG for the rate-stat test only. Real-app
/// variable-reward uses `SystemRandomNumberGenerator` per `VariableReward`.
private struct SeedableLCG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state
    }
}
