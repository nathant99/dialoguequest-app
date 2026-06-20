import SwiftUI
import SharedUI

/// The 4-tab DialogueQuest root view per `Docs/TECHNICAL_DESIGN.md`
/// § Home Screen & Navigation. Apps's `@main` should host this view.
///
/// Liquid Glass: per `.claude/rules/liquid-glass.md` we do NOT set
/// `toolbarBackground` / `toolbarColorScheme` / `UITabBar.appearance` —
/// iOS 26 auto-renders the chrome as glass. `.tint(...)` colors the
/// icons through the glass material.
public struct RootView: View {
    @State private var machine = AppNavigationMachine()

    public init() {}

    public var body: some View {
        TabView(selection: $machine.selectedTab) {
            Tab("Write", systemImage: "bubble.left.and.text.bubble.right", value: AppTab.write) {
                WriteTabView()
            }
            Tab("Adventure", systemImage: "map", value: AppTab.adventure) {
                AdventureTabView()
            }
            Tab("Progress", systemImage: "chart.line.uptrend.xyaxis", value: AppTab.progress) {
                ProgressTabView()
            }
            Tab("Profile", systemImage: "person.crop.circle", value: AppTab.profile) {
                ProfileTabView()
            }
        }
        .tint(DialoguePalette.rust)
    }
}

#Preview {
    RootView()
}
