import SwiftUI
import SharedUI

/// Hosts the Adventure-mode mode-card grid (Word Workshop zone in
/// AdventureHub per `Docs/TECHNICAL_DESIGN.md` § Adventure Mode
/// Integration). Phase 1 placeholder; mode-card wiring lands after
/// the Level-2 Swift overlay (`DialogueQuestHubContribution`) is
/// authored against `HubContributionConfig`.
struct AdventureTabView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Adventure mode unlocks after a few sessions",
                systemImage: "map",
                description: Text("Word Workshop zone — Phase 1 wires the mode-cards once the kid has shipped their first tree.")
            )
            .navigationTitle("Adventure")
        }
    }
}

#Preview {
    AdventureTabView()
}
