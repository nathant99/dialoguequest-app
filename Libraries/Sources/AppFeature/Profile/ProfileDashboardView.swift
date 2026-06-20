import SwiftUI
import ForgeAvatar
import ForgeModels
import ForgeSync
import SharedUI

/// Phase 1 Profile surface. Hosts `ForgeAvatar.AvatarStudioView` per the
/// writing-craft cluster pattern. Seeds the ForgeID on appearance per
/// `.claude/rules/forgekit.md` § AvatarStudioView gotcha.
struct ProfileDashboardView: View {
    @State private var store = AppGroupStore(achievements: [])
    @State private var catalog = AvatarAssetCatalog()
    @State private var displayName: String = "Dialogue Quester"
    @State private var currentAvatar: AvatarConfig = .default
    @State private var baselineEditedAt: Date?
    @State private var isStudioOpen: Bool = false
    @State private var isSeeded: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                profileHeader
                avatarTeaser
                settingsLinkRow
            }
            .padding()
        }
        .background(DialoguePalette.cream.opacity(0.6))
        .sheet(isPresented: $isStudioOpen) {
            AvatarStudioView(
                initialConfig: currentAvatar,
                baselineEditedAt: baselineEditedAt,
                catalog: catalog,
                presentation: .lite,
                appGroupStore: store,
                onSaved: { saved in
                    currentAvatar = saved
                    baselineEditedAt = .now
                    isStudioOpen = false
                },
                onCancelled: { isStudioOpen = false }
            )
            .environment(\.forgeTheme, DialogueQuestTheme())
        }
        .task {
            await seedIdentity()
        }
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(displayName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)
            Text("Storyteller in the making")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var avatarTeaser: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(DialoguePalette.warmGold.opacity(0.35))
                .overlay(
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(DialoguePalette.rust)
                )
                .frame(width: 80, height: 80)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text("Your avatar")
                    .font(.headline)
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text("Pick a color and a glyph. You can change it anytime.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button {
                    isStudioOpen = true
                } label: {
                    Label("Customize", systemImage: "paintpalette")
                }
                .buttonStyle(.borderedProminent)
                .tint(DialoguePalette.rust)
                .disabled(!isSeeded)
                .accessibilityHint(
                    isSeeded
                    ? Text("Open the avatar editor.")
                    : Text("Setting up your identity. The button activates once ready.")
                )
            }
            Spacer()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var settingsLinkRow: some View {
        NavigationLink {
            SettingsView()
        } label: {
            HStack {
                Image(systemName: "gear")
                Text("Settings")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .foregroundStyle(DialoguePalette.inkBlue)
    }

    private func seedIdentity() async {
        // Critical: per .claude/rules/forgekit.md AvatarStudioView seeds
        // setAvatar(_:editedAt:) which throws `.forgeIDMissing` ("error 0")
        // unless a ForgeID has been created first.
        _ = await store.getOrCreateForgeID(displayName: displayName)
        if let current = await store.currentForgeID() {
            if let avatar = current.avatar { currentAvatar = avatar }
            baselineEditedAt = current.avatarEditedAt
        }
        isSeeded = true
    }
}
