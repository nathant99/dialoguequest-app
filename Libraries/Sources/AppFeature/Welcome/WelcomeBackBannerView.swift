import SwiftUI
import SharedUI

/// Banner surfaced by `RootView` when `ReturnLoopService.shouldShowWelcomeBack`
/// returns true. Renders the warm greeting + a 1-tap "Write" affordance
/// that jumps the kid back to the Write tab.
///
/// Reduce-Motion-aware: the appearance transition collapses to opacity
/// per `.claude/rules/swiftui.md`. Reduce-Transparency-aware: the
/// background flips from `.thinMaterial` to `DialoguePalette.cream`
/// per the portfolio Liquid Glass policy.
struct WelcomeBackBannerView: View {
    let message: String
    let onWrite: () -> Void
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "bubble.left.and.text.bubble.right")
                .imageScale(.large)
                .foregroundStyle(DialoguePalette.rust)
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 4)
            VStack(spacing: 6) {
                Button(action: onWrite) {
                    Text("Write")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .tint(DialoguePalette.rust)
                .accessibilityHint("Open the Write tab to continue your anthology.")
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Dismiss the welcome-back banner.")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(DialoguePalette.rust.opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Welcome back. \(message)")
    }

    @ViewBuilder
    private var background: some View {
        if reduceTransparency {
            DialoguePalette.cream
        } else {
            Color.clear.background(.thinMaterial)
        }
    }
}

#Preview {
    WelcomeBackBannerView(
        message: "Welcome back. Your 5 conversations are in the anthology — want to add one more?",
        onWrite: {},
        onDismiss: {}
    )
    .padding()
}
