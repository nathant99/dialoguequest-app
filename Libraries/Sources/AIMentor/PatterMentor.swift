import Foundation
import FoundationModels
import Models

/// DialogueQuest's mentor mascot. Patter is a two-toned speech-bubble
/// character who listens for rhythm, register, and subtext in the kid's
/// dialogue.
///
/// Reuses one `LanguageModelSession` across calls (per
/// `.claude/rules/foundationmodels.md` — never create per-call). Every
/// `respond*` method has a static fallback path (`PatterFallbacks`) so
/// the UX completes the loop whether or not FoundationModels is
/// available.
@Observable
@MainActor
public final class PatterMentor {

    /// Stored model reference per the canonical lazy-availability
    /// pattern. We re-read `.availability` on each call rather than
    /// caching, so an "Apple Intelligence not enabled" → "enabled"
    /// transition is observable mid-session.
    private let model: SystemLanguageModel = .default

    @ObservationIgnored
    private lazy var session: LanguageModelSession? = makeSession()

    public init() {}

    public var availability: SystemLanguageModel.Availability {
        model.availability
    }

    public var isAvailable: Bool {
        if case .available = model.availability { return true }
        return false
    }

    // MARK: - Public coaching API

    public func analyze(line: String, mood: DialogueMood?) async -> DialogueLineAnalysis {
        guard isAvailable, let session else {
            return PatterFallbacks.lineAnalysisFallback(for: line, mood: mood)
        }
        do {
            let prompt = makeLineAnalysisPrompt(line: line, mood: mood)
            let response = try await session.respond(
                to: prompt,
                generating: DialogueLineAnalysis.self
            )
            return response.content
        } catch {
            return PatterFallbacks.lineAnalysisFallback(for: line, mood: mood)
        }
    }

    public func branchCheck(for mood: DialogueMood?) async -> BranchMeaningfulnessCheck {
        guard isAvailable, let session else {
            return PatterFallbacks.branchCheckFallback(for: mood)
        }
        do {
            let prompt = makeBranchCheckPrompt(mood: mood)
            let response = try await session.respond(
                to: prompt,
                generating: BranchMeaningfulnessCheck.self
            )
            return response.content
        } catch {
            return PatterFallbacks.branchCheckFallback(for: mood)
        }
    }

    public func tagBalanceTip(dominant: DialogueTag.Classification) async -> TagBalanceTip {
        guard isAvailable, let session else {
            return PatterFallbacks.tagBalanceFallback(dominant: dominant)
        }
        do {
            let prompt = makeTagBalancePrompt(dominant: dominant)
            let response = try await session.respond(
                to: prompt,
                generating: TagBalanceTip.self
            )
            return response.content
        } catch {
            return PatterFallbacks.tagBalanceFallback(dominant: dominant)
        }
    }

    // MARK: - Private

    private func makeSession() -> LanguageModelSession? {
        guard isAvailable else { return nil }
        return LanguageModelSession(instructions: Self.patterPersonaInstructions)
    }

    private static let patterPersonaInstructions: String = """
    You are Patter, a friendly mentor in a kids' writing app called DialogueQuest. \
    You listen to short dialogues between two characters and surface what isn't being said. \
    You speak warmly and concisely, in the age 9-14 register (think Roald Dahl or Magic Tree House). \
    Never grade or shame. Never propose specific rewrites — only invite the kid to try alternatives. \
    Never use clinical or therapeutic language.
    """

    private func makeLineAnalysisPrompt(line: String, mood: DialogueMood?) -> String {
        let moodHint = mood.map { "Scene mood: \($0.displayName)." } ?? ""
        return """
        \(moodHint)
        Line: "\(line)"
        Echo the line as surfaceText, name the inferredSubtext in one kid-readable sentence \
        (or empty string if no clear subtext), and rate the speaker's voiceMatchScore 0.0 to 1.0.
        """
    }

    private func makeBranchCheckPrompt(mood: DialogueMood?) -> String {
        let moodHint = mood.map { "Scene mood: \($0.displayName)." } ?? ""
        return """
        \(moodHint)
        The kid is about to choose between two branches in a dialogue. \
        Write three Socratic questions that help them feel why each branch matters — \
        question1 on stakes, question2 on character, question3 on consequence. \
        Don't tell them which to pick.
        """
    }

    private func makeTagBalancePrompt(dominant: DialogueTag.Classification) -> String {
        let classification: String
        switch dominant {
        case .saidVerb: classification = "many lines using 'said'"
        case .actionBeat: classification = "many lines using action beats"
        case .unattributed: classification = "many lines with no attribution"
        }
        return """
        The kid's dialogue currently has \(classification). \
        Write a 1-sentence observation Patter would share, plus 1 concrete alternative \
        they could try. Warm, never prescriptive.
        """
    }
}
