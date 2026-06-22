import SwiftUI
import Services
import SharedUI

/// End-of-session summary rendered when `SessionTimerService.phase`
/// reaches `.endingSummaryReady`. Per `@Docs/FEATURE_PLAN.md` § Parent
/// Integration "Session closer" + Delight "Session closer" — one
/// screen, warm tone, lists what the kid did + previews the next
/// session.
///
/// Pure read-only view: pulls the kid's published-tree count, current
/// streak, and most-recent achievement from `@AppStorage`. Dismissing
/// the sheet calls `onClose` so the host can reset
/// `SessionTimerService` for the next window.
struct SessionCloserSheet: View {
    let onClose: () -> Void

    @AppStorage("dq.publishedTreeCount") private var publishedTreeCount: Int = 0
    @AppStorage("dq.currentStreak") private var currentStreak: Int = 0
    @AppStorage("dq.earnedBadgeIDs") private var earnedBadgeIDsRaw: String = ""

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good stopping point")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text("Here's what you did this session.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            VStack(spacing: 10) {
                summaryRow(
                    icon: "tray.full.fill",
                    title: "\(publishedTreeCount) conversation\(publishedTreeCount == 1 ? "" : "s") in the anthology"
                )
                summaryRow(
                    icon: "flame.fill",
                    title: currentStreak > 0
                        ? "Streak: \(currentStreak) day\(currentStreak == 1 ? "" : "s")"
                        : "First session of a new streak"
                )
                summaryRow(
                    icon: "rosette",
                    title: "\(earnedBadgeCount) badge\(earnedBadgeCount == 1 ? "" : "s") earned"
                )
            }
            .padding()
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text("Up next")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text(nextSessionPreview)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            Spacer(minLength: 4)
            Button(action: onClose) {
                Text("Close")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .tint(DialoguePalette.rust)
            .accessibilityHint("Close the session summary and return to the app.")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DialoguePalette.cream.opacity(0.6))
    }

    // MARK: - Helpers

    private var earnedBadgeCount: Int {
        earnedBadgeIDsRaw
            .split(separator: ",", omittingEmptySubsequences: true)
            .count
    }

    private var nextSessionPreview: String {
        switch publishedTreeCount {
        case 0:
            return "Your first tree is waiting. Try one branch and see Patter respond."
        case 1...2:
            return "Try a 5-line conversation next session. Patter will help you balance the tags."
        default:
            return "You're ready for harder branches — try a scene where one character is hiding something."
        }
    }

    @ViewBuilder
    private func summaryRow(icon: String, title: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(DialoguePalette.rust)
            Text(title)
                .font(.body)
                .foregroundStyle(DialoguePalette.inkBlue)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }

    @ViewBuilder
    private var panelBackground: some View {
        if reduceTransparency {
            DialoguePalette.cream
        } else {
            Color.clear.background(.thinMaterial)
        }
    }
}

#Preview {
    SessionCloserSheet(onClose: {})
}
