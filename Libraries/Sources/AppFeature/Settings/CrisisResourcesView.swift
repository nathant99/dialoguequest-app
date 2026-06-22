import SwiftUI
import Services
import SharedUI

/// "Need help?" disclosure surface in Settings. Renders the
/// `CrisisResourcesProvider.resources` list with tap-to-call /
/// tap-to-text affordances and the supporting URL. Lives next to
/// Settings (not on the kid's main loop) so it's reachable without
/// being intrusive.
struct CrisisResourcesView: View {
    private let resources = CrisisResourcesProvider.resources

    var body: some View {
        List(resources) { resource in
            VStack(alignment: .leading, spacing: 8) {
                Text(resource.title)
                    .font(.headline)
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text(resource.oneLineDescription)
                    .font(.callout)
                    .foregroundStyle(.secondary)

                if let phone = resource.phoneNumber,
                   let phoneURL = URL(string: "tel://\(phone.filter { $0.isNumber })") {
                    Link(destination: phoneURL) {
                        Label(phone, systemImage: "phone.fill")
                            .font(.callout)
                    }
                    .accessibilityHint("Call \(phone)")
                }
                if let text = resource.textInstructions {
                    Label(text, systemImage: "message.fill")
                        .font(.callout)
                        .foregroundStyle(.primary)
                }
                if let url = resource.url {
                    Link(destination: url) {
                        Label(url.host ?? url.absoluteString, systemImage: "safari.fill")
                            .font(.callout)
                    }
                    .accessibilityHint("Open \(url.absoluteString) in your browser")
                }
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Need help?")
    }
}

#Preview {
    NavigationStack { CrisisResourcesView() }
}
