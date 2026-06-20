import SwiftUI
import Models

/// Placeholder for the Phase 1 dialogue-tree builder. Real 2-D graph
/// editor (per `Docs/TECHNICAL_DESIGN.md` § Full-App UI/UX Patterns)
/// lands in a follow-on PR; this exists so AppFeature's Write tab
/// renders something coherent immediately.
public struct DialogueTreeBuilderPlaceholder: View {
    private let title: String

    public init(title: String = "Write a conversation") {
        self.title = title
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.text.bubble.right")
                .font(.system(size: 56))
                .foregroundStyle(DialoguePalette.rust)
                .accessibilityHidden(true)

            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)

            Text("Two characters. One scene. Every line counts.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            MentorBubbleView(
                message: "Pick a mood, name your two characters, and write the first line. I'll listen for what isn't said."
            )
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DialoguePalette.cream.opacity(0.6))
    }
}

#Preview {
    DialogueTreeBuilderPlaceholder()
}
