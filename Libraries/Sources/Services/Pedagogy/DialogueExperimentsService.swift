import Foundation
import ForgeExperiments

/// Phase Delight follow-up wrapper around ForgeKit's `ForgeExperiments`
/// on-device A/B harness. Surfaces a deterministic-per-install variant
/// assignment for DialogueQuest's existing experiment flags
/// (`dq.experiments.castVoicing` + `dq.experiments.thirdCharacter`).
///
/// **Why this seam exists**: the existing `@AppStorage` flags ship as
/// operator-toggle controls (Settings exposes them so a parent or kid
/// can flip on Phase 2 surfaces directly). They're the load-bearing
/// shipping control. The experiment seam sits ALONGSIDE — it does NOT
/// replace the flags. It surfaces "if the kid hadn't flipped a flag,
/// what variant would the deterministic A/B assigner have picked?".
/// Future Patter coaching surfaces + retention dashboards can read the
/// experiment variant as the analytical seam without mutating the
/// flag itself.
///
/// **Discipline**: this wrapper does NOT mutate any `@AppStorage` key.
/// It only reads `dq.experiments.installSeed` (auto-generated on first
/// access) and surfaces the deterministic variant assignment derived
/// from that seed. The two existing `*FeatureFlag.isEnabled` accessors
/// remain the source of truth for runtime behavior.
///
/// **What this wrapper does NOT do** (intentional; mirrors the
/// `DialogueEmotionalStateProbe` + `DevelopmentalCapacityProbe` precedent):
/// - It does NOT register telemetry events. The
///   `DialogueQuestAnalytics` event vocabulary is already stable; a
///   future round adds an `experiment_variant_assigned` event if + when
///   the on-device retention pipeline ships.
/// - It does NOT activate any GUI surface today. The wrapper is a pure
///   value-type seam; the parent-progress dashboard + a future
///   experiment-results surface can adopt it without rewiring callers.
/// - It does NOT persist variant assignments. The deterministic
///   SHA-256 hash-bucket assignment derived from
///   `installSeed + experimentID` is stable across launches — no cache
///   needed. (See `ForgeExperiments.ExperimentAssigner.assignVariant`.)
///
/// **Reference impl pattern**: matches last round's
/// `DialogueEmotionalStateProbe` shape — pure value-type seam, no
/// behavioral wiring, future consumers adopt it without changes here.
/// ForgeKit module count grows 22 → 23 with the dep + this wrapper.
@MainActor
public final class DialogueExperimentsService {

    /// Shared singleton for callers that need the default install seed
    /// (loaded once from `dq.experiments.installSeed` UserDefaults).
    /// Tests should construct their own instance with an explicit
    /// `installSeed` for determinism.
    public static let shared = DialogueExperimentsService()

    /// Stable per-install seed used by
    /// `ExperimentAssigner.assignVariant`. Auto-generated UUID string
    /// on first access; persists across launches via UserDefaults.
    public let installSeed: String

    /// Catalog of DialogueQuest's active experiment definitions. Phase 1
    /// ships two definitions (castVoicing + thirdCharacter); future
    /// rounds extend the catalog as new experiments land. Definitions
    /// are read-only Sendable values.
    public let definitions: [ExperimentDefinition]

    private let userDefaults: UserDefaults

    /// Default initializer for the shared singleton. Reads / writes
    /// `dq.experiments.installSeed` in `UserDefaults.standard`.
    public convenience init() {
        let defaults = UserDefaults.standard
        let seed = Self.loadOrGenerateInstallSeed(in: defaults)
        self.init(
            installSeed: seed,
            definitions: Self.defaultDefinitions(),
            userDefaults: defaults
        )
    }

    /// Test-friendly initializer. Pass an explicit seed for
    /// deterministic variant assignment, an explicit definitions list
    /// for narrow-coverage tests, and an isolated `UserDefaults` suite
    /// per `.claude/rules/testing.md` § Crash-Resilience Defaults #5.
    public init(
        installSeed: String,
        definitions: [ExperimentDefinition],
        userDefaults: UserDefaults = UserDefaults.standard
    ) {
        self.installSeed = installSeed
        self.definitions = definitions
        self.userDefaults = userDefaults
    }

    // MARK: - Variant assignment

    /// Returns the variant the `ExperimentAssigner` picked for the
    /// experiment matching `id` — or `nil` when no matching definition
    /// is registered. Deterministic across launches for a given seed.
    public func variant(forExperimentID id: String) -> Variant? {
        guard let definition = definitions.first(where: { $0.id == id }) else {
            return nil
        }
        return ExperimentAssigner.assignVariant(
            experimentID: definition.id,
            variants: definition.variants,
            seed: installSeed
        )
    }

    /// Returns the parameter value `key` declared on the assigned
    /// variant — or `nil` when the experiment / variant / key is not
    /// found. Sugar over `variant(forExperimentID:).parameters[key]`.
    public func parameter(
        forExperimentID experimentID: String,
        key: String
    ) -> ParameterValue? {
        variant(forExperimentID: experimentID)?.parameters[key]
    }

    // MARK: - Public flag-shape API

    /// Whether the deterministic A/B assigner picked the treatment
    /// variant for the cast-voicing experiment. Callers wiring
    /// telemetry can compare this against
    /// `CastVoicingFeatureFlag.isEnabled` to spot flag overrides; the
    /// flag still controls runtime behavior.
    public var isCastVoicingTreatmentVariant: Bool {
        variant(forExperimentID: Self.castVoicingExperimentID)?.id == Self.treatmentVariantID
    }

    /// Whether the deterministic A/B assigner picked the treatment
    /// variant for the third-character experiment. Same disclaimer as
    /// `isCastVoicingTreatmentVariant`.
    public var isThirdCharacterTreatmentVariant: Bool {
        variant(forExperimentID: Self.thirdCharacterExperimentID)?.id == Self.treatmentVariantID
    }

    /// Resets the persisted install seed. Test-only escape hatch — the
    /// shared singleton's seed should remain stable across the
    /// device's lifetime in production.
    public func resetInstallSeedForTesting() {
        userDefaults.removeObject(forKey: Self.installSeedStorageKey)
    }

    // MARK: - Canonical experiment definitions

    /// Storage key for the per-install seed.
    public static let installSeedStorageKey = "dq.experiments.installSeed"

    /// Canonical experiment IDs. Public so callers consulting
    /// `variant(forExperimentID:)` use the same constants as the
    /// definitions list.
    public static let castVoicingExperimentID = "dq.experiment.castVoicing"
    public static let thirdCharacterExperimentID = "dq.experiment.thirdCharacter"

    /// Canonical variant IDs. Public so callers comparing assigned
    /// variants to "the treatment cohort" use the same constants.
    public static let controlVariantID = "control"
    public static let treatmentVariantID = "treatment"

    /// The two definitions DialogueQuest ships. The 50/50 weight split
    /// gives an even cohort distribution; the `parameters["enabled"]`
    /// bool surfaces a future read by callers that want a single API
    /// to consult ("is the treatment cohort flag on?").
    public static func defaultDefinitions() -> [ExperimentDefinition] {
        let castVoicingControl = Variant(
            id: controlVariantID,
            name: "Control",
            weight: 50,
            parameters: ["enabled": .bool(false)]
        )
        let castVoicingTreatment = Variant(
            id: treatmentVariantID,
            name: "Treatment",
            weight: 50,
            parameters: ["enabled": .bool(true)]
        )
        let thirdCharacterControl = Variant(
            id: controlVariantID,
            name: "Control",
            weight: 50,
            parameters: ["enabled": .bool(false)]
        )
        let thirdCharacterTreatment = Variant(
            id: treatmentVariantID,
            name: "Treatment",
            weight: 50,
            parameters: ["enabled": .bool(true)]
        )
        // A 90-day default window. Start date is the static reference
        // point so deterministic seed-based assignment doesn't drift
        // across launches. Window is advisory metadata only — the
        // assigner doesn't time-gate.
        let referenceStart = Date(timeIntervalSince1970: 1_700_000_000)
        let referenceEnd = referenceStart.addingTimeInterval(60 * 60 * 24 * 90)
        return [
            ExperimentDefinition(
                id: castVoicingExperimentID,
                name: "Cast voicing — DN-S Move D Step 3",
                description: "Whether the five DN cast members speak alongside Patter at the coaching surfaces.",
                variants: [castVoicingControl, castVoicingTreatment],
                startDate: referenceStart,
                endDate: referenceEnd,
                minimumSessions: 30,
                primaryMetric: .retention(.d7)
            ),
            ExperimentDefinition(
                id: thirdCharacterExperimentID,
                name: "Third character — triangle dynamics",
                description: "Whether the kid can author a third character so the tree carries triangle alliance / jealousy / arbitration patterns.",
                variants: [thirdCharacterControl, thirdCharacterTreatment],
                startDate: referenceStart,
                endDate: referenceEnd,
                minimumSessions: 30,
                primaryMetric: .retention(.d7)
            )
        ]
    }

    // MARK: - Install seed loader

    private static func loadOrGenerateInstallSeed(in defaults: UserDefaults) -> String {
        if let existing = defaults.string(forKey: installSeedStorageKey),
           !existing.isEmpty {
            return existing
        }
        let fresh = UUID().uuidString
        defaults.set(fresh, forKey: installSeedStorageKey)
        return fresh
    }
}
