import Testing
import ForgeModels
import ForgeGamification
@testable import Models

@Suite("ForgeKit integration sanity checks")
struct ForgeKitIntegrationTests {

    @Test("ForgeKit version string is populated and matches the 0.99 line")
    func versionStringPopulated() throws {
        let version = ForgeKitVersion.version
        #expect(!version.isEmpty)
        #expect(ForgeKitVersion.major == 0)
        #expect(ForgeKitVersion.minor >= 99)
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
