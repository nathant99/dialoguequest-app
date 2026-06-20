import SwiftUI
import SharedUI

/// Hosts XP / streak / badge / dialogue-craft-attunement views. Phase 1
/// placeholder; concrete charts wire after the XPEngine + StreakManager
/// are bound to the `Services` layer.
struct ProgressTabView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Your craft, growing",
                systemImage: "chart.line.uptrend.xyaxis",
                description: Text("Streak, XP, badges, and dialogue-craft attunement land here once you've shipped your first tree.")
            )
            .navigationTitle("Progress")
        }
    }
}

#Preview {
    ProgressTabView()
}
