import Foundation
import Testing
@testable import AppFeature

/// Verifies the Labs section in SettingsView reads + writes the canonical
/// UserDefaults keys for the two experiment flags. The toggle UI binds
/// directly via `@AppStorage(flag.storageKey)`, so all this test needs
/// to assert is that the two storage keys haven't drifted from their
/// canonical values — any rename would silently disconnect the toggle
/// from the consumer logic.
@MainActor
@Suite("Settings Labs flags")
struct SettingsLabsFlagTests {

    private func makeSuite(name: String = UUID().uuidString) -> UserDefaults {
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    // MARK: - Storage-key contracts

    @Test func triangleAuthoringStorageKeyIsCanonical() {
        #expect(TriangleAuthoringFeatureFlag.storageKey == "dq.experiments.thirdCharacter")
    }

    @Test func castVoicingStorageKeyIsCanonical() {
        #expect(CastVoicingFeatureFlag.storageKey == "dq.experiments.castVoicing")
    }

    // MARK: - Read / write round-trip

    @Test func triangleAuthoringFlagDefaultsFalse() {
        let suite = makeSuite()
        #expect(suite.bool(forKey: TriangleAuthoringFeatureFlag.storageKey) == false)
    }

    @Test func castVoicingFlagDefaultsFalse() {
        let suite = makeSuite()
        #expect(suite.bool(forKey: CastVoicingFeatureFlag.storageKey) == false)
    }

    @Test func togglingTriangleAuthoringFlagPersists() {
        let suite = makeSuite()
        suite.set(true, forKey: TriangleAuthoringFeatureFlag.storageKey)
        #expect(suite.bool(forKey: TriangleAuthoringFeatureFlag.storageKey) == true)
        suite.set(false, forKey: TriangleAuthoringFeatureFlag.storageKey)
        #expect(suite.bool(forKey: TriangleAuthoringFeatureFlag.storageKey) == false)
    }

    @Test func togglingCastVoicingFlagPersists() {
        let suite = makeSuite()
        suite.set(true, forKey: CastVoicingFeatureFlag.storageKey)
        #expect(suite.bool(forKey: CastVoicingFeatureFlag.storageKey) == true)
        suite.set(false, forKey: CastVoicingFeatureFlag.storageKey)
        #expect(suite.bool(forKey: CastVoicingFeatureFlag.storageKey) == false)
    }

    @Test func flagStorageKeysAreDistinct() {
        // Sanity guard against accidental key collision when adding a
        // third lab flag in a future round.
        #expect(TriangleAuthoringFeatureFlag.storageKey != CastVoicingFeatureFlag.storageKey)
    }
}
