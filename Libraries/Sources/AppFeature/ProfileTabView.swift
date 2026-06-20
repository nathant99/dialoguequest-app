import SwiftUI
import SharedUI

/// Hosts avatar (`ForgeAvatar.AvatarStudioView(.lite)` per the writing-craft
/// cluster's avatar handoff), settings, parental controls. Phase 1
/// placeholder; the avatar editor adopts in the same PR that wires
/// `getOrCreateForgeID` seeding (per `.claude/rules/forgekit.md`
/// § AvatarStudioView gotcha).
struct ProfileTabView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Make Patter your own",
                systemImage: "person.crop.circle",
                description: Text("Avatar customization, settings, and parental gates land here in the next round.")
            )
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileTabView()
}
