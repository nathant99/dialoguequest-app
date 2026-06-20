import SwiftUI
import ForgeAdventure
import ForgeModels
import SharedUI

/// Level-2 overlay for DialogueQuest's contribution to AdventureHub's
/// Word Workshop zone. The companion Level-1 JSON config lives at
/// `labsmith/Resources/HubContributions/dialoguequest.json` (hub-side;
/// see `Docs/HANDOFF_TO_HUB_HUBCONTRIBUTION_LEVEL_1.md` if missing).
///
/// Renders a themed "open DialogueQuest" call-to-action that bridges the
/// AdventureHub UI to the kid's existing tree-builder. AdventureHub
/// players see this when they tap the Word Workshop tile.
///
/// `AnyView` here is at the protocol boundary — the
/// `.claude/rules/swiftui.md` "No AnyView" rule does NOT apply to
/// erasure at framework API surfaces (per portfolio convention).
public struct DialogueQuestHubContribution: HubContribution {

    public init() {}

    public let sourceAppID: String = "dialoguequest"
    public let sourceAppDisplayName: String = "DialogueQuest"
    public let zone: ZoneID = .wordWoods
    public let supportedEngines: [GameModeType] = [.quest, .builder]
    public let preferredPresentation: HubPresentation = .tileEmbedded

    public var themeAccent: Color {
        // Inline the rust hex per DialogueQuestTheme.primaryColor — the
        // theme value is MainActor-isolated and the protocol requirement
        // is `nonisolated`. Color literals are pure + safe to construct
        // in any isolation context.
        Color(red: 160.0 / 255.0, green: 90.0 / 255.0, blue: 75.0 / 255.0)
    }

    public let mentorPersona: MentorPersona = MentorPersona(
        id: "patter",
        displayName: "Patter",
        avatarAssetName: "patter_idle",
        voiceProfile: .warmMid,
        systemPromptHeader: "You are Patter from DialogueQuest. You listen for what isn't being said in a kid's dialogue tree. Speak warmly, never grade."
    )

    public let kitResources: [HubKitResource] = [
        HubKitResource(
            kitID: "kit_01_voice_consistency",
            resourceName: "kit_01_voice_consistency",
            bloomBand: .analyze,
            gradeBand: .middle
        ),
        HubKitResource(
            kitID: "kit_02_subtext_detection",
            resourceName: "kit_02_subtext_detection",
            bloomBand: .analyze,
            gradeBand: .middle
        ),
        HubKitResource(
            kitID: "kit_03_tag_balance",
            resourceName: "kit_03_tag_balance",
            bloomBand: .apply,
            gradeBand: .middle
        ),
        HubKitResource(
            kitID: "kit_04_branching",
            resourceName: "kit_04_branching",
            bloomBand: .create,
            gradeBand: .middle
        )
    ]

    public func makeChallengeView(
        engine: GameModeType,
        kit: HubQuestionKit,
        context: HubChallengeContext
    ) -> AnyView {
        AnyView(
            HubChallengeBridge(kit: kit, context: context)
                .environment(\.forgeTheme, DialogueQuestTheme())
        )
    }
}

/// Bridges AdventureHub's Level-2 challenge slot to DialogueQuest's
/// `QuizView` so kids stay in the same Patter-coached question loop
/// whether they enter via the Write tab or AdventureHub.
private struct HubChallengeBridge: View {
    let kit: HubQuestionKit
    let context: HubChallengeContext

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MentorBubbleView(
                message: "We're in the Word Workshop now. Same listening, different scene."
            )
            QuizView(kitID: kit.id) { correct, total in
                Task {
                    await context.onComplete(
                        HubChallengeResult(
                            score: correct,
                            total: total,
                            durationSeconds: context.elapsedSeconds(),
                            bloomMastered: [kit.bloomBand],
                            moveCount: nil,
                            efficiencyScore: nil
                        )
                    )
                }
            }
        }
        .padding()
        .background(DialoguePalette.cream.opacity(0.6))
    }
}
