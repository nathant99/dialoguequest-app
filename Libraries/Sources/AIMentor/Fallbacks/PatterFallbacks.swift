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

    // MARK: - MultiSpeakerSubtextAnalysis (Phase 2 — triangle path)

    /// Phase 2 multi-listener fallback. Returns a per-listener subtext
    /// pair keyed off `DialogueMood` so the kid sees scene-appropriate
    /// readings even when FoundationModels is unavailable.
    ///
    /// The fallback is deliberately register-neutral — it doesn't try
    /// to characterize the specific listener relationships (sibling /
    /// friend / antagonist), only the mood-shape of how the SAME line
    /// reads to two different listeners. Phase 2+ AI passes will
    /// inject relationship-specific cues when CharacterForge import
    /// lands.
    public static func multiSpeakerSubtextFallback(
        for surfaceText: String,
        speakerName: String,
        primaryListenerName: String,
        secondaryListenerName: String,
        mood: DialogueMood?
    ) -> MultiSpeakerSubtextAnalysis {
        let primary: String
        let secondary: String
        switch mood {
        case .warmReunion?:
            primary = "Said for \(primaryListenerName), but every word is true."
            secondary = "\(secondaryListenerName) hears the relief between the words."
        case .quietConflict?:
            primary = "Soft enough for \(primaryListenerName) to hear it without breaking."
            secondary = "\(secondaryListenerName) hears what \(speakerName) didn't quite say."
        case .playfulRivalry?:
            primary = "A joke aimed at \(primaryListenerName) — half-real, half-not."
            secondary = "\(secondaryListenerName) hears the dare underneath the joke."
        case .awkwardSilence?:
            primary = "Said to keep \(primaryListenerName) close without saying more."
            secondary = "\(secondaryListenerName) hears the silence \(speakerName) is protecting."
        case .openingCuriosity?:
            primary = "A question \(primaryListenerName) might answer."
            secondary = "\(secondaryListenerName) hears the question \(speakerName) hasn't asked yet."
        case nil:
            primary = ""
            secondary = ""
        }
        return MultiSpeakerSubtextAnalysis(
            surfaceText: surfaceText,
            speakerName: speakerName,
            primaryListenerName: primaryListenerName,
            primaryListenerSubtext: primary,
            secondaryListenerName: secondaryListenerName,
            secondaryListenerSubtext: secondary,
            voiceMatchScore: 0.75
        )
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
