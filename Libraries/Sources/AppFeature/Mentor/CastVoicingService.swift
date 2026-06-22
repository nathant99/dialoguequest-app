import Foundation
import SwiftUI
import ForgeAI
import AIMentor

/// DN-S Move D Step 3 — orchestrates DialogueQuest's per-surface cast
/// utterances on top of ForgeKit 0.97.0+'s `CastDialog` actor.
///
/// Pattern B (per `.claude/rules/distributed-narrative.md`): Patter remains
/// the protagonist. Cast utterances are *additive* coaching moments
/// produced at trigger boundaries (branch-point reached, tag-balance
/// imbalance crossed, subtext discovered/confirmed, voice drift detected,
/// reflective pause). When a profile speaks, its slug + utterance are
/// published so views may render a thin "Glance hears…" / "Weigh notes…"
/// chip alongside Patter's own bubble — never replacing it.
///
/// **Feature flag**: gated by the `dq.experiments.castVoicing` user-default
/// (default off; see `castVoicingFlag`). When the flag is off, every
/// public method returns `nil` immediately without contacting `CastDialog`
/// or FoundationModels. This keeps the surface dark by default and lets
/// TestFlight rollout flip it without code changes.
///
/// **ForgeExperiments note**: the original handoff named
/// `ForgeExperiments.castVoicing` as the gate. ForgeKit 0.99's
/// `ForgeExperiments` module exposes an A/B `ExperimentAssigner` API
/// (`ExperimentDefinition` / `VariantAssignment`), not a single boolean.
/// A per-app `@AppStorage`-backed flag matches the IMPLEMENTATION_HANDOFF
/// convention for default-off feature gates (`@AppStorage("dq.*")`) and
/// stays out of the experimentation pipeline until DN-S Phase 2 lights
/// up the proper experiment.
///
/// **Sentinel for unavailable cast**: when `CastDialog.respond(as:)` returns
/// `"…"` (the unregistered-cast sentinel), this service surfaces it as
/// `nil` instead — views never render an ellipsis. The fallback path
/// also returns `nil` for empty utterances.
@MainActor
@Observable
public final class CastVoicingService {

    /// Most-recently produced cast utterance + the slug that voiced it.
    /// Cleared on `reset()`. Views observe this for chip rendering.
    public private(set) var lastVoicing: Voicing?

    @ObservationIgnored
    private let appIdentifier: String

    /// Lazily-initialized dialog actor (per `.claude/rules/foundationmodels.md`
    /// — never create the LM-backed session per-call).
    @ObservationIgnored
    private var dialogBox: DialogBox = .pending

    @ObservationIgnored
    private let flagAccessor: () -> Bool

    public init(
        appIdentifier: String = "dialoguequest",
        flagAccessor: @escaping () -> Bool = { CastVoicingFeatureFlag.isEnabled }
    ) {
        self.appIdentifier = appIdentifier
        self.flagAccessor = flagAccessor
    }

    /// Public test/seam: rebuild the dialog so the next `respond` call
    /// uses the supplied actor. Call sites in production never reach this.
    public func injectDialogForTesting(_ dialog: CastDialog?) {
        if let dialog {
            dialogBox = .ready(dialog)
        } else {
            dialogBox = .pending
        }
    }

    /// Produce a cast utterance for the supplied surface. Returns `nil` when
    /// the feature flag is off, when the underlying registry is empty, or
    /// when `CastDialog` has no profile registered for the surface's slug.
    @discardableResult
    public func respond(
        to surface: CastVoiceRegistry.CoachingSurface,
        topic: String? = nil,
        kitNumber: Int = 1
    ) async -> Voicing? {
        guard flagAccessor() else { return nil }
        // Pattern B preservation: WORLD + META utterances are gated by
        // the layer's `minimumKitNumber`. Calling the surface earlier
        // than that returns `nil` so Patter (LESSONS-layer) stays the
        // protagonist during early-arc coaching.
        guard kitNumber >= surface.layer.minimumKitNumber else { return nil }
        let dialog: CastDialog
        do {
            dialog = try await loadOrBuildDialog()
        } catch {
            return nil
        }
        let context = CastDialogContext(
            appIdentifier: appIdentifier,
            kitNumber: kitNumber,
            recentQuestionTopic: topic,
            priorEncounterCount: 0,
            emotionContext: .unknown
        )
        let utterance = await dialog.respond(
            as: surface.castID,
            trigger: surface.trigger,
            context: context
        )
        guard !utterance.isEmpty, utterance != Self.unregisteredSentinel else {
            return nil
        }
        let voicing = Voicing(
            surface: surface,
            castID: surface.castID,
            displayName: CastVoiceRegistry.profile(id: surface.castID)?.displayName ?? surface.castID,
            utterance: utterance
        )
        lastVoicing = voicing
        return voicing
    }

    /// Clear any pending voicing (e.g., when the kid resets the tree).
    public func reset() {
        lastVoicing = nil
    }

    private func loadOrBuildDialog() async throws -> CastDialog {
        switch dialogBox {
        case .ready(let dialog):
            return dialog
        case .pending:
            let dialog = try await CastVoiceRegistry.makeCastDialog()
            dialogBox = .ready(dialog)
            return dialog
        }
    }

    /// `"…"` is `CastDialog`'s public sentinel for unregistered castIDs.
    /// Lifted as a constant so the comparison reads at the call site.
    private static let unregisteredSentinel = "…"

    /// A single cast utterance + provenance.
    public nonisolated struct Voicing: Sendable, Equatable, Identifiable {
        public let id: UUID
        public let surface: CastVoiceRegistry.CoachingSurface
        public let castID: String
        public let displayName: String
        public let utterance: String

        public init(
            id: UUID = UUID(),
            surface: CastVoiceRegistry.CoachingSurface,
            castID: String,
            displayName: String,
            utterance: String
        ) {
            self.id = id
            self.surface = surface
            self.castID = castID
            self.displayName = displayName
            self.utterance = utterance
        }
    }

    private enum DialogBox {
        case pending
        case ready(CastDialog)
    }
}

/// The `dq.experiments.castVoicing` feature flag — defaults to `false`.
/// Surfaced as a stand-alone enum so non-`@MainActor` callers (e.g., the
/// `CastVoicingService.flagAccessor` default) can read it without an
/// isolation hop, and so tests can stub the gate.
public enum CastVoicingFeatureFlag {
    /// `UserDefaults` key — kept in sync with the `@AppStorage` accessors
    /// used in `SettingsView` and elsewhere.
    public static let storageKey = "dq.experiments.castVoicing"

    /// Current value (defaults to `false` when unset).
    public static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: storageKey)
    }

    /// Setter — for use in `SettingsView` or by UI tests via `-uiTest…` args.
    public static func set(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: storageKey)
    }
}
