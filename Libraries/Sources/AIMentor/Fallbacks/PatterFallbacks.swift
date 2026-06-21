import Foundation
import Models

/// Static fallback content for every `@Generable` shipped from the
/// AIMentor target. Used when `SystemLanguageModel.default.availability`
/// is anything other than `.available` — per
/// `.claude/rules/foundationmodels.md` every AI path needs a static
/// fallback the kid can still complete the loop with.
///
/// Keyed by the dimensions that change the right coaching beat:
/// `DialogueMood` for line analysis, `DialogueTag.Classification` for
/// tag-balance tips. Branch-meaningfulness keys off `DialogueMood` as
/// well so the questions feel scene-appropriate.
public nonisolated enum PatterFallbacks {

    // MARK: - DialogueLineAnalysis

    public static func lineAnalysisFallback(
        for surfaceText: String,
        mood: DialogueMood?
    ) -> DialogueLineAnalysis {
        let subtext: String
        switch mood {
        case .warmReunion?:
            subtext = "There's relief here. They've been holding this in."
        case .quietConflict?:
            subtext = "The words are gentle but the feelings are loud."
        case .playfulRivalry?:
            subtext = "They're testing how far they can go without breaking the joke."
        case .awkwardSilence?:
            subtext = "Something they almost said is staying unsaid."
        case .openingCuriosity?:
            subtext = "They're feeling out the shape of the conversation."
        case nil:
            subtext = ""
        }
        return DialogueLineAnalysis(
            surfaceText: surfaceText,
            inferredSubtext: subtext,
            voiceMatchScore: 0.75
        )
    }

    // MARK: - BranchMeaningfulnessCheck

    public static func branchCheckFallback(
        for mood: DialogueMood?
    ) -> BranchMeaningfulnessCheck {
        switch mood {
        case .warmReunion?:
            return BranchMeaningfulnessCheck(
                question1: "What does each branch cost — even when it ends well?",
                question2: "Which branch sounds more like who this character usually is?",
                question3: "How does each ending change the moment AFTER the scene ends?"
            )
        case .quietConflict?:
            return BranchMeaningfulnessCheck(
                question1: "Which branch turns down the heat? Which turns it up?",
                question2: "What does the kinder branch hide? What does the harder one reveal?",
                question3: "Which branch makes the next scene harder to write — and why?"
            )
        case .playfulRivalry?:
            return BranchMeaningfulnessCheck(
                question1: "Which branch keeps the game going? Which ends it?",
                question2: "What does each branch tell us about who's actually winning?",
                question3: "Which branch makes the next move possible — and which one closes the door?"
            )
        case .awkwardSilence?:
            return BranchMeaningfulnessCheck(
                question1: "What is each branch trying NOT to say?",
                question2: "Which branch breaks the silence? Which keeps it?",
                question3: "What happens to the silence itself if you pick each branch?"
            )
        case .openingCuriosity?, nil:
            return BranchMeaningfulnessCheck(
                question1: "What does the speaker want to know — and which branch helps them find out?",
                question2: "Which branch invites the other character in? Which keeps them out?",
                question3: "How does each branch shape what they ask next?"
            )
        }
    }

    // MARK: - TagBalanceTip

    public static func tagBalanceFallback(
        dominant: DialogueTag.Classification
    ) -> TagBalanceTip {
        switch dominant {
        case .saidVerb:
            return TagBalanceTip(
                observation: "A lot of your lines end with 'said'.",
                suggestion: "Try one line where a small action tells us who's speaking — like a shrug, a sigh, or a glance away."
            )
        case .actionBeat:
            return TagBalanceTip(
                observation: "You're using actions to attribute every line.",
                suggestion: "Drop one action and let a plain 'said' carry the line — actions feel bigger when 'said' surrounds them."
            )
        case .unattributed:
            return TagBalanceTip(
                observation: "Many lines have no attribution.",
                suggestion: "Add one clear 'X said' so the reader doesn't have to count back to figure out who's speaking."
            )
        }
    }
}
