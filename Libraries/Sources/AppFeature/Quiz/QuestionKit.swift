import Foundation
import Services

/// One of the 4 Phase 1 question kits the kid plays from the Adventure
/// surface or the Onboarding flow. Loaded from `Bundle.module` JSON.
public nonisolated struct QuestionKit: Codable, Sendable, Hashable, Identifiable {
    public let id: String              // e.g., "kit_01_voice_consistency"
    public let title: String
    public let theme: Theme
    public let questions: [Question]

    public enum Theme: String, Codable, Sendable, CaseIterable {
        case voiceConsistency = "voice_consistency"
        case subtextDetection = "subtext_detection"
        case tagBalance = "tag_balance"
        case branching = "branching"
    }

    public struct Question: Codable, Sendable, Hashable, Identifiable {
        public let id: String          // e.g., "kit_01_q_03"
        public let prompt: String
        public let options: [Option]
        /// `id` of the canonical answer; UI compares against this. Free-text
        /// kits use `correctOptionID == nil` and grade via `freeTextRubric`.
        public let correctOptionID: String?
        public let freeTextRubric: String?
        public let mentorPostScript: String

        public init(
            id: String,
            prompt: String,
            options: [Option],
            correctOptionID: String?,
            freeTextRubric: String?,
            mentorPostScript: String
        ) {
            self.id = id
            self.prompt = prompt
            self.options = options
            self.correctOptionID = correctOptionID
            self.freeTextRubric = freeTextRubric
            self.mentorPostScript = mentorPostScript
        }
    }

    public struct Option: Codable, Sendable, Hashable, Identifiable {
        public let id: String
        public let label: String

        public init(id: String, label: String) {
            self.id = id
            self.label = label
        }
    }

    public init(id: String, title: String, theme: Theme, questions: [Question]) {
        self.id = id
        self.title = title
        self.theme = theme
        self.questions = questions
    }
}

/// Loads question kits from the `Bundle.module` `Resources/Questions`
/// directory. Phase 1 ships 4 kits; Phase 2+ swap to hub-distributed
/// kits via the standard ForgeContent pipeline.
public enum QuestionKitLoader {
    public enum LoaderError: Error, Sendable {
        case kitNotFound(String)
        case decodeFailed(String, any Error)
    }

    public nonisolated static func load(id: String) throws -> QuestionKit {
        // Delegates to `QuestionKitContentService` (Services/Persistence/)
        // which wraps `ForgeContentLoader` for a portfolio-canonical
        // two-tier lookup: disk cache first, `Bundle.module` (AppFeature)
        // second. Today the disk cache is always empty (no hub-shipped
        // kit manifest URL), so behavior is identical to the prior
        // pure-Bundle.module path. The seam is ready when hub ships
        // a kit manifest — see `Docs/HANDOFF_TO_HUB_HUBCONTRIBUTION_LEVEL_1.md`
        // for the cross-repo path.
        let service = QuestionKitContentService(bundle: .module)
        do {
            return try service.load(QuestionKit.self, filename: "\(id).json")
        } catch let error as QuestionKitContentService.LoadError {
            switch error {
            case .notFound:
                throw LoaderError.kitNotFound(id)
            case .decodeFailed(let detail):
                throw LoaderError.decodeFailed(id, KitDecodeDetail(detail))
            }
        } catch {
            throw LoaderError.decodeFailed(id, error)
        }
    }

    /// Lightweight error carrier that preserves the underlying decoder
    /// detail string for `LoaderError.decodeFailed`'s `any Error`
    /// requirement without dragging `DecodingError` (or
    /// `ForgeContentError`) through the AppFeature surface.
    public nonisolated struct KitDecodeDetail: Error, Sendable, Equatable {
        public let detail: String
        public init(_ detail: String) { self.detail = detail }
    }

    /// All 4 Phase 1 kit identifiers in canonical order.
    public nonisolated static let phase1Kits: [String] = [
        "kit_01_voice_consistency",
        "kit_02_subtext_detection",
        "kit_03_tag_balance",
        "kit_04_branching",
    ]

    /// Phase 2 kits — triangle authoring + voice differentiation + the
    /// multi-listener subtext crucible + branch consequences + action
    /// beats / silence-as-subtext. Kits 05–09 ship now; kits 10+ are
    /// reserved for Phase 3 (read-aloud performance + voice-acting coach).
    public nonisolated static let phase2Kits: [String] = [
        "kit_05_triangle_voices",
        "kit_06_voice_crucible",
        "kit_07_subtext_crucible",
        "kit_08_branch_consequences",
        "kit_09_action_beats",
    ]

    /// Phase 3 kits — read-aloud register / pause pacing / voice-acting
    /// choices / audio export craft. Per `Docs/FEATURE_PLAN.md` § Phase 3.
    public nonisolated static let phase3Kits: [String] = [
        "kit_10_read_aloud_register",
        "kit_11_pause_pacing",
        "kit_12_voice_acting_choices",
        "kit_13_audio_export_craft",
    ]

    /// Phase 4 kits — synthesis / cross-craft / writing process. Per
    /// `Docs/FEATURE_PLAN.md` § Phase 4 row 161 "Add 3 final question kits
    /// (kits 14-16; synthesis / cross-craft / writing process)". Closes
    /// the 16-kit set the Phase 4 exit criterion targets.
    public nonisolated static let phase4Kits: [String] = [
        "kit_14_synthesis",
        "kit_15_cross_craft",
        "kit_16_writing_process",
    ]

    /// Every kit identifier in canonical order — Phase 1 / 2 / 3 / 4.
    public nonisolated static let allKits: [String] = phase1Kits + phase2Kits + phase3Kits + phase4Kits

    /// Convenience: try-loading every Phase 1 kit, returning a tuple of
    /// kits + per-kit failures. Useful at app startup for telemetry.
    public nonisolated static func loadAll() -> (kits: [QuestionKit], failures: [(String, any Error)]) {
        loadAll(ids: phase1Kits)
    }

    /// Try-loading every kit registered in `allKits` (Phase 1 + Phase 2).
    public nonisolated static func loadAllPhases() -> (kits: [QuestionKit], failures: [(String, any Error)]) {
        loadAll(ids: allKits)
    }

    private nonisolated static func loadAll(ids: [String]) -> (kits: [QuestionKit], failures: [(String, any Error)]) {
        var loaded: [QuestionKit] = []
        var failures: [(String, any Error)] = []
        for id in ids {
            do {
                loaded.append(try load(id: id))
            } catch {
                failures.append((id, error))
            }
        }
        return (loaded, failures)
    }
}
