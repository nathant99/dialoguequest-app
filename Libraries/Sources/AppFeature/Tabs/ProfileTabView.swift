import SwiftUI
import SharedUI

/// Hosts the avatar studio + settings entry. Phase 1 ships the
/// composable avatar editor per writing-craft cluster pattern; the
/// parental-gate flow is stubbed in Settings and lands in a follow-up
/// round.
struct ProfileTabView: View {
    var body: some View {
        NavigationStack {
            ProfileDashboardView()
                .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileTabView()
}
