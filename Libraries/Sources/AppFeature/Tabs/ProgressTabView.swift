import SwiftUI
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

    var body: some View {
        NavigationStack {
            anthologyStripeHost {
                ProgressDashboardView(
                    totalXP: totalXP,
                    currentStreak: currentStreak,
                    availableFreezes: availableFreezes,
                    earnedBadgeIDs: earnedBadgeIDs
                )
            }
            .navigationTitle("Progress")
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
