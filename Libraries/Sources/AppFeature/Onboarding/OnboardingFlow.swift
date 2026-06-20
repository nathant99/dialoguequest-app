import SwiftUI
import ForgeUI
import SharedUI

/// Phase 1 5-step onboarding per `Docs/FEATURE_PLAN.md` § Onboarding:
/// welcome → meet 2 characters → first 3-node tree → first subtext check →
/// first published tree. Wraps `ForgeUI.ForgeOnboardingFlow` with a
/// DialogueQuest-themed Patter hero.
struct OnboardingFlow: View {
    let onComplete: () -> Void

    var body: some View {
        ForgeOnboardingFlow(pages: Self.pages, onComplete: onComplete)
            .environment(\.forgeTheme, DialogueQuestTheme())
    }

    private static let pages: [ForgeOnboardingFlow.Page] = [
        ForgeOnboardingFlow.Page(
            title: "Welcome to DialogueQuest",
            body: "Write a conversation, not a paragraph. Every line counts.",
            imageName: "bubble.left.and.text.bubble.right"
        ),
        ForgeOnboardingFlow.Page(
            title: "Meet your cast",
            body: "Pick two characters and give each one a voice — a rhythm, a few words they love or avoid.",
            imageName: "person.2"
        ),
        ForgeOnboardingFlow.Page(
            title: "Write your first 3 lines",
            body: "Three lines is all you need to start. Patter will listen for what isn't being said.",
            imageName: "text.bubble"
        ),
        ForgeOnboardingFlow.Page(
            title: "Spot the subtext",
            body: "Patter will surface what your character might really mean. You decide if Patter got it right.",
            imageName: "ear.and.waveform"
        ),
        ForgeOnboardingFlow.Page(
            title: "Ready when you are",
            body: "Save your conversation to the anthology any time. You can keep writing tomorrow.",
            imageName: "books.vertical",
            isParentHandoff: false
        )
    ]
}
