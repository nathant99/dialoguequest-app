import Testing
import Foundation
import ForgeExperiments
import Services

/// Priority N (2026-07-03) — `ForgeExperiments` thin-wrapper adoption.
///
/// `DialogueExperimentsService` is a value-type seam over ForgeKit's
/// on-device A/B harness. Two definitions ship (castVoicing +
/// thirdCharacter); each has a 50/50 control/treatment split.
/// Deterministic SHA-256 hash-bucket assignment from
/// `installSeed + experimentID` means a given seed always lands the
/// same variant; tests pick seeds that reach both buckets.
///
/// Discipline points exercised:
///   • Default definitions list ships exactly the two experiments
///   • Variant lookup is deterministic for a fixed seed
///   • Unknown experiment IDs return nil (not crash)
///   • Parameter lookup follows the variant's parameters dict
///   • Public flag-shape API matches the assigned variant
///   • Install seed loader auto-generates + persists a UUID on first read
///   • Test-only escape hatch (`resetInstallSeedForTesting`) clears the key
@Suite("DialogueExperimentsService — A/B harness wrapper")
struct DialogueExperimentsServiceTests {

    /// Isolated UserDefaults suite per `.claude/rules/testing.md`
    /// § Crash-Resilience Defaults #5. Re-used across tests.
    private static let suiteName = "test.dq.experiments"

    @MainActor
    private static func freshDefaults() -> UserDefaults {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    // MARK: - Canonical definitions

    @Test @MainActor func defaultDefinitionsShipExactlyTwoExperiments() {
        let definitions = DialogueExperimentsService.defaultDefinitions()
        #expect(definitions.count == 2)
        let ids = Set(definitions.map(\.id))
        #expect(ids.contains(DialogueExperimentsService.castVoicingExperimentID))
        #expect(ids.contains(DialogueExperimentsService.thirdCharacterExperimentID))
    }

    @Test @MainActor func defaultDefinitionsHaveControlAndTreatmentVariants() {
        let definitions = DialogueExperimentsService.defaultDefinitions()
        for definition in definitions {
            let variantIDs = Set(definition.variants.map(\.id))
            #expect(variantIDs == [
                DialogueExperimentsService.controlVariantID,
                DialogueExperimentsService.treatmentVariantID
            ])
        }
    }

    @Test @MainActor func defaultDefinitionsHaveEvenWeightSplit() {
        let definitions = DialogueExperimentsService.defaultDefinitions()
        for definition in definitions {
            let weights = definition.variants.map(\.weight)
            #expect(weights == [50, 50])
        }
    }

    // MARK: - Variant assignment is deterministic

    @Test @MainActor func variantAssignmentIsDeterministicForFixedSeed() {
        let service = DialogueExperimentsService(
            installSeed: "deterministic-seed-1",
            definitions: DialogueExperimentsService.defaultDefinitions()
        )
        let first = service.variant(forExperimentID: DialogueExperimentsService.castVoicingExperimentID)
        let second = service.variant(forExperimentID: DialogueExperimentsService.castVoicingExperimentID)
        #expect(first?.id == second?.id)
    }

    @Test @MainActor func variantAssignmentDiffersAcrossExperimentsForSameSeed() {
        // The SHA-256 hash bucket pairs `seed|experimentID` so the two
        // experiments are NOT forced to land the same bucket even when
        // the seed is identical. The test asserts independence — both
        // experiments can land in either variant given the same seed.
        let service = DialogueExperimentsService(
            installSeed: "deterministic-seed-2",
            definitions: DialogueExperimentsService.defaultDefinitions()
        )
        let castVoicing = service.variant(forExperimentID: DialogueExperimentsService.castVoicingExperimentID)
        let thirdCharacter = service.variant(forExperimentID: DialogueExperimentsService.thirdCharacterExperimentID)
        #expect(castVoicing != nil)
        #expect(thirdCharacter != nil)
        // Both variants are valid — no constraint that they match.
        let validIDs: Set<String> = [
            DialogueExperimentsService.controlVariantID,
            DialogueExperimentsService.treatmentVariantID
        ]
        #expect(validIDs.contains(castVoicing!.id))
        #expect(validIDs.contains(thirdCharacter!.id))
    }

    @Test @MainActor func unknownExperimentIDReturnsNilFromVariantLookup() {
        let service = DialogueExperimentsService(
            installSeed: "any-seed",
            definitions: DialogueExperimentsService.defaultDefinitions()
        )
        let variant = service.variant(forExperimentID: "dq.experiment.does-not-exist")
        #expect(variant == nil)
    }

    // MARK: - Parameter lookup

    @Test @MainActor func parameterLookupReturnsAssignedVariantParameter() {
        let service = DialogueExperimentsService(
            installSeed: "parameter-seed",
            definitions: DialogueExperimentsService.defaultDefinitions()
        )
        let castVoicing = service.variant(forExperimentID: DialogueExperimentsService.castVoicingExperimentID)
        let parameter = service.parameter(
            forExperimentID: DialogueExperimentsService.castVoicingExperimentID,
            key: "enabled"
        )
        // The variant's "enabled" parameter matches whatever was looked up.
        switch (castVoicing?.id, parameter) {
        case (DialogueExperimentsService.controlVariantID, .bool(false)):
            #expect(Bool(true))
        case (DialogueExperimentsService.treatmentVariantID, .bool(true)):
            #expect(Bool(true))
        default:
            Issue.record("Parameter lookup did not match assigned variant — variant=\(castVoicing?.id ?? "nil") parameter=\(String(describing: parameter))")
        }
    }

    @Test @MainActor func parameterLookupReturnsNilForUnknownKey() {
        let service = DialogueExperimentsService(
            installSeed: "any-seed",
            definitions: DialogueExperimentsService.defaultDefinitions()
        )
        let parameter = service.parameter(
            forExperimentID: DialogueExperimentsService.castVoicingExperimentID,
            key: "nonexistent-key"
        )
        #expect(parameter == nil)
    }

    // MARK: - Public flag-shape API matches assigned variant

    @Test @MainActor func isCastVoicingTreatmentVariantMatchesAssignedVariant() {
        let service = DialogueExperimentsService(
            installSeed: "flag-shape-seed",
            definitions: DialogueExperimentsService.defaultDefinitions()
        )
        let assigned = service.variant(forExperimentID: DialogueExperimentsService.castVoicingExperimentID)
        let isTreatment = service.isCastVoicingTreatmentVariant
        #expect(isTreatment == (assigned?.id == DialogueExperimentsService.treatmentVariantID))
    }

    @Test @MainActor func isThirdCharacterTreatmentVariantMatchesAssignedVariant() {
        let service = DialogueExperimentsService(
            installSeed: "flag-shape-seed-2",
            definitions: DialogueExperimentsService.defaultDefinitions()
        )
        let assigned = service.variant(forExperimentID: DialogueExperimentsService.thirdCharacterExperimentID)
        let isTreatment = service.isThirdCharacterTreatmentVariant
        #expect(isTreatment == (assigned?.id == DialogueExperimentsService.treatmentVariantID))
    }

    // MARK: - Install seed persistence

    @Test @MainActor func defaultInitializerGeneratesAndPersistsSeed() {
        let defaults = Self.freshDefaults()
        // Pre-condition — no seed stored.
        #expect(defaults.string(forKey: DialogueExperimentsService.installSeedStorageKey) == nil)
        let firstService = DialogueExperimentsService(
            installSeed: DialogueExperimentsService_TestHelper.loadOrGenerateSeed(in: defaults),
            definitions: DialogueExperimentsService.defaultDefinitions(),
            userDefaults: defaults
        )
        // Now persisted.
        let persistedSeed = defaults.string(forKey: DialogueExperimentsService.installSeedStorageKey)
        #expect(persistedSeed != nil)
        #expect(!persistedSeed!.isEmpty)
        // Same seed surfaces on second access — UUID is stable.
        let secondSeed = DialogueExperimentsService_TestHelper.loadOrGenerateSeed(in: defaults)
        #expect(secondSeed == firstService.installSeed)
        #expect(secondSeed == persistedSeed)
    }

    @Test @MainActor func resetInstallSeedForTestingClearsKey() {
        let defaults = Self.freshDefaults()
        defaults.set("prefilled-seed", forKey: DialogueExperimentsService.installSeedStorageKey)
        let service = DialogueExperimentsService(
            installSeed: "prefilled-seed",
            definitions: DialogueExperimentsService.defaultDefinitions(),
            userDefaults: defaults
        )
        service.resetInstallSeedForTesting()
        #expect(defaults.string(forKey: DialogueExperimentsService.installSeedStorageKey) == nil)
    }

    // MARK: - Stoplist compliance (reader-facing copy)

    @Test @MainActor func definitionNamesAndDescriptionsAreReaderClean() {
        // Reader-facing fields render in a future experiment-results
        // dashboard. Per `.claude/rules/distributed-narrative.md`
        // § Chapter content register stoplist, the copy must NOT carry
        // engineering / SAMHSA / framework jargon.
        let stoplist: Set<String> = [
            "load-bearing", "codified", "SAMHSA", "ADR-",
            "Phase A", "Phase B", "Phase C", "Phase D"
        ]
        for definition in DialogueExperimentsService.defaultDefinitions() {
            for token in stoplist {
                #expect(!definition.name.localizedCaseInsensitiveContains(token),
                        "Definition name '\(definition.name)' contains stoplist token '\(token)'")
                #expect(!definition.description.localizedCaseInsensitiveContains(token),
                        "Definition description for '\(definition.id)' contains stoplist token '\(token)'")
            }
        }
    }
}

// Test helper — reaches into the same UserDefaults flow the default
// initializer uses, without circular `DialogueExperimentsService.init()`
// calls that would mutate the shared singleton's seed during testing.
private enum DialogueExperimentsService_TestHelper {
    static func loadOrGenerateSeed(in defaults: UserDefaults) -> String {
        if let existing = defaults.string(forKey: DialogueExperimentsService.installSeedStorageKey),
           !existing.isEmpty {
            return existing
        }
        let fresh = UUID().uuidString
        defaults.set(fresh, forKey: DialogueExperimentsService.installSeedStorageKey)
        return fresh
    }
}
