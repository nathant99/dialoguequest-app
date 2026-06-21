import SwiftUI
import SharedUI

/// The 4-tab DialogueQuest root view per `Docs/TECHNICAL_DESIGN.md`
/// § Home Screen & Navigation. App's `@main` should host this view.
///
/// Liquid Glass: per `.claude/rules/liquid-glass.md` we do NOT set
/// `toolbarBackground` / `toolbarColorScheme` / `UITabBar.appearance` —
/// iOS 26 auto-renders the chrome as glass. `.tint(...)` colors the
/// icons through the glass material.
public struct RootView: View {
    @State private var machine = AppNavigationMachine()
    @AppStorage("dq.hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    /// UI tests pass `-uiTestSkipOnboarding YES` so the tab surface is
    /// reachable without driving the onboarding flow.
    private static let isUITestSkippingOnboarding: Bool = {
        ProcessInfo.processInfo.arguments.contains("-uiTestSkipOnboarding")
    }()

    /// UI tests pass `-uiTestResetOnboarding` to clear the persisted
    /// completion flag at launch, guaranteeing the onboarding flow surfaces
    /// even after a prior test run completed it.
    private static let isUITestResettingOnboarding: Bool = {
        ProcessInfo.processInfo.arguments.contains("-uiTestResetOnboarding")
    }()

    public init() {
        if Self.isUITestResettingOnboarding {
            UserDefaults.standard.removeObject(forKey: "dq.hasCompletedOnboarding")
        }
    }

    public var body: some View {
        TabView(selection: $machine.selectedTab) {
            Tab("Write", systemImage: "bubble.left.and.text.bubble.right", value: AppTab.write) {
                WriteTabView()
            }
            .accessibilityIdentifier("tab.write")
            Tab("Adventure", systemImage: "map", value: AppTab.adventure) {
                AdventureTabView()
            }
            .accessibilityIdentifier("tab.adventure")
            Tab("Progress", systemImage: "chart.line.uptrend.xyaxis", value: AppTab.progress) {
                ProgressTabView()
            }
            .accessibilityIdentifier("tab.progress")
            Tab("Profile", systemImage: "person.crop.circle", value: AppTab.profile) {
                ProfileTabView()
            }
            .accessibilityIdentifier("tab.profile")
        }
        .tint(DialoguePalette.rust)
        .fullScreenCoverIfPossible(
            isPresented: .constant(!hasCompletedOnboarding && !Self.isUITestSkippingOnboarding)
        ) {
            OnboardingFlow {
                hasCompletedOnboarding = true
            }
        }
    }
}

private extension View {
    /// `fullScreenCover` is iOS / visionOS only — fall back to `.sheet`
    /// on macOS per `.claude/rules/warnings.md` § Platform Availability.
    @ViewBuilder
    func fullScreenCoverIfPossible<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        #if os(iOS) || os(visionOS)
        fullScreenCover(isPresented: isPresented, content: content)
        #else
        sheet(isPresented: isPresented, content: content)
        #endif
    }
}

#Preview {
    RootView()
}
