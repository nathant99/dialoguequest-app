import SwiftUI

/// Renders a line from Patter, DialogueQuest's mentor mascot. Phase 1
/// is a text-only speech bubble; Phase 2+ swaps in the Patter
/// illustration + wobbly tail.
public struct MentorBubbleView: View {
    private let message: String

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.title2)
                .foregroundStyle(DialoguePalette.rust)
                .accessibilityHidden(true)

            Text(message)
                .font(.callout)
                .foregroundStyle(DialoguePalette.inkBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(DialoguePalette.cream)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(DialoguePalette.rust.opacity(0.4), lineWidth: 1)
                )
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Patter says: \(message)"))
    }
}

#Preview {
    MentorBubbleView(message: "Iris said 'I'm fine.' But she didn't look up. What is she really telling Cal?")
        .padding()
}
