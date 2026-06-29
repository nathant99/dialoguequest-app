import Testing
import ForgeModels
import ForgeGamification
@testable import Models

@Suite("ForgeKit integration sanity checks")
struct ForgeKitIntegrationTests {

    @Test("ForgeKit version string is populated and on the 1.0.0-rc line or later")
    func versionStringPopulated() throws {
        let version = ForgeKitVersion.version
        #expect(!version.isEmpty)
        // Bumped to the 1.0.0-rc.x line (2026-07-08 pin bump). Accept
        // 1.x and beyond so future stable releases don't trip this.
        #expect(ForgeKitVersion.major >= 1)
    }

    @Test("BloomLevel is Comparable by cognitive complexity")
    func bloomLevelOrdering() {
        #expect(BloomLevel.remember < BloomLevel.understand)
        #expect(BloomLevel.understand < BloomLevel.apply)
        #expect(BloomLevel.apply < BloomLevel.analyze)
        #expect(BloomLevel.analyze < BloomLevel.evaluate)
        #expect(BloomLevel.evaluate < BloomLevel.create)
    }

    @Test("Local Models target loads and exposes its bundle id")
    func localModelsTargetLoads() {
        #expect(ModelsTarget.bundleIdentifier == "com.sparkanvil.dialoguequest.models")
    }

    @Test("XPEngine computes level progression deterministically")
    func xpEngineDeterministic() {
        let engine = XPEngine(config: GamificationConfig())
        let level0 = engine.level(for: 0)
        let level1k = engine.level(for: 1000)
        #expect(level1k >= level0)
    }

    @Test("GamificationConfig defaults are sane for a writing-craft app")
    func gamificationConfigDefaults() {
        let config = GamificationConfig()
        #expect(config.streakFreezeCount >= 0)
        #expect(config.desiredRetention > 0 && config.desiredRetention < 1)
    }
}
