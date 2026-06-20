import Foundation

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
        // `.process("Resources/Questions")` flattens the JSON files into
        // the root of `Bundle.module`, so we look up without a subdirectory.
        guard let url = Bundle.module.url(forResource: id, withExtension: "json") else {
            throw LoaderError.kitNotFound(id)
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(QuestionKit.self, from: data)
        } catch let error as LoaderError {
            throw error
        } catch {
            throw LoaderError.decodeFailed(id, error)
        }
    }

    /// All 4 Phase 1 kit identifiers in canonical order.
    public nonisolated static let phase1Kits: [String] = [
        "kit_01_voice_consistency",
        "kit_02_subtext_detection",
        "kit_03_tag_balance",
        "kit_04_branching",
    ]

    /// Convenience: try-loading every Phase 1 kit, returning a tuple of
    /// kits + per-kit failures. Useful at app startup for telemetry.
    public nonisolated static func loadAll() -> (kits: [QuestionKit], failures: [(String, any Error)]) {
        var loaded: [QuestionKit] = []
        var failures: [(String, any Error)] = []
        for id in phase1Kits {
            do {
                loaded.append(try load(id: id))
            } catch {
                failures.append((id, error))
            }
        }
        return (loaded, failures)
    }
}
