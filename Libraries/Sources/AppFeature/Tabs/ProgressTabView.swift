import SwiftUI
import Services
import SharedUI

/// Hosts the XP / streak / badge dashboard. Phase 1 persistence uses
/// `@AppStorage` for total XP + current streak + earned badge IDs —
/// SwiftData-backed analytics joins in Phase 2 when session-history
/// telemetry surfaces.
struct ProgressTabView: View {
    @AppStorage("dq.totalXP") private var totalXP: Int = 0
    @AppStorage("dq.currentStreak") private var currentStreak: Int = 0
    @AppStorage("dq.streakFreezes") private var availableFreezes: Int = 2
    @AppStorage("dq.earnedBadgeIDs") private var earnedBadgeIDsRaw: String = ""

    /// Per-pillar mastery bars + focus caption (Priority B → P-follow). Loaded
    /// from `DialogueCraftMasteryService` in `.task` so `ProgressDashboardView`
    /// stays a pure renderer. The FSRS-6 mastery state is captured at each
    /// publish in `WriteTabView`.
    @State private var craftBars: [DialogueCraftMasteryService.CraftMasteryReadout] = []
    @State private var craftFocusName: String?

    var body: some View {
        NavigationStack {
            anthologyStripeHost {
                ProgressDashboardView(
                    totalXP: totalXP,
                    currentStreak: currentStreak,
                    availableFreezes: availableFreezes,
                    earnedBadgeIDs: earnedBadgeIDs,
                    craftBars: craftBars,
                    craftFocusName: craftFocusName
                )
            }
            .navigationTitle("Progress")
            .task {
                craftBars = DialogueCraftMasteryService.shared.masteryReadouts()
                craftFocusName = DialogueCraftMasteryService.shared.nextFocusTopic()?.displayName
            }
        }
    }

    private var earnedBadgeIDs: Set<String> {
        let parts = earnedBadgeIDsRaw
            .split(separator: ",")
            .map(String.init)
            .filter { !$0.isEmpty }
        return Set(parts)
    }

    @ViewBuilder
    private func anthologyStripeHost<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
    }
}

#Preview {
    ProgressTabView()
}
