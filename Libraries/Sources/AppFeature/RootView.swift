import SwiftUI
import Services
import SharedUI
import ForgeCelebration

/// The 4-tab DialogueQuest root view per `Docs/TECHNICAL_DESIGN.md`
/// § Home Screen & Navigation. App's `@main` should host this view.
///
/// Liquid Glass: per `.claude/rules/liquid-glass.md` we do NOT set
/// `toolbarBackground` / `toolbarColorScheme` / `UITabBar.appearance` —
/// iOS 26 auto-renders the chrome as glass. `.tint(...)` colors the
/// icons through the glass material.
public struct RootView: View {
    @State private var machine = AppNavigationMachine()
    @State private var celebrationCoordinator = CelebrationCoordinator()
    @State private var sessionTimer = SessionTimerService()
    @State private var brokenStreakDismissed: Bool = false
    @State private var welcomeBackDismissed: Bool = false
    @State private var welcomeBackMessage: String?
    @State private var showSessionCloser: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("dq.hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("dq.publishedTreeCount") private var publishedTreeCount: Int = 0
    /// Mirror of `MasteryMomentService`'s `dq.firstMasteryAchievedAt`
    /// timestamp key — RootView observes the 0 → set transition + fires
    /// the cinematic mastery-moment celebration. The service is the
    /// source of truth; this AppStorage binding is the observer.
    @AppStorage(MasteryMomentService.defaultsKeyFirstMasteryAt) private var firstMasteryAchievedAt: Double = 0

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
        .celebrationOverlay(celebrationCoordinator)
        .onChange(of: publishedTreeCount) { oldValue, newValue in
            // Cinematic celebration tier for the milestone publish-events:
            // the first tree (the aha-moment seed) earns a `.epic` flourish;
            // every subsequent publish gets the `.medium` cadence Patter
            // would prefer (warm acknowledgement, not party).
            if oldValue == 0 && newValue == 1 {
                celebrationCoordinator.celebrate(
                    .epic,
                    message: "Your first conversation is in the anthology",
                    emoji: "✨"
                )
            } else if newValue > oldValue {
                celebrationCoordinator.celebrate(
                    .medium,
                    message: "Published",
                    emoji: "📜"
                )
            }
        }
        .onChange(of: firstMasteryAchievedAt) { oldValue, newValue in
            // The mastery moment fires EXACTLY ONCE per device — the
            // service guards against re-emission. RootView's job here
            // is just to render the `.epic` cinematic when the
            // timestamp transitions from 0 (never) to a real Date.
            guard oldValue == 0, newValue > 0 else { return }
            celebrationCoordinator.celebrate(
                .epic,
                message: "Your characters sound like THEM. Patter is grinning.",
                emoji: "🎙️"
            )
        }
        .fullScreenCoverIfPossible(
            isPresented: .constant(!hasCompletedOnboarding && !Self.isUITestSkippingOnboarding)
        ) {
            OnboardingFlow {
                hasCompletedOnboarding = true
            }
        }
        .overlay(alignment: .top) {
            VStack(spacing: 8) {
                welcomeBackBanner
                brokenStreakBanner
            }
        }
        .task {
            // Start the soft session window on root appear, once the kid
            // is past onboarding. Phase events fire via the ticker below.
            if hasCompletedOnboarding || Self.isUITestSkippingOnboarding {
                sessionTimer.start()
            }
            // Record this open against the D1/D7/D30 retention baseline.
            RetentionMetricsService.shared.recordAppOpen()
            // Compute the welcome-back message once per root appear.
            let return_ = ReturnLoopService.shared
            if return_.shouldShowWelcomeBack() {
                welcomeBackMessage = return_.welcomeBackMessage()
                DialogueQuestAnalytics.shared.track(.welcomeBackShown)
            }
        }
        .onChange(of: sessionTimer.phase) { _, newPhase in
            switch newPhase {
            case .gentleNudgeReady:
                DialogueQuestAnalytics.shared.track(.sessionTimerGentleNudge)
            case .endingSummaryReady:
                DialogueQuestAnalytics.shared.track(.sessionEndingSummaryShown)
            case .idle, .running:
                break
            }
        }
        .task(id: sessionTimer.phase) {
            // Drive the session-timer ticker. `SessionTimerService.tick`
            // is pure over elapsed time, so the loop is cheap. Per
            // `.claude/rules/concurrency.md`, we do NOT use
            // `Timer.scheduledTimer + Task { @MainActor in }` — `.task`
            // is `@MainActor`-isolated and `Task.sleep` resumes cleanly.
            while !Task.isCancelled, sessionTimer.phase != .endingSummaryReady {
                try? await Task.sleep(for: .seconds(15))
                sessionTimer.tick()
            }
            // Once we cross the soft ceiling, surface the closer sheet
            // (the host view dismisses + resets the timer for the next
            // session window).
            if sessionTimer.phase == .endingSummaryReady {
                showSessionCloser = true
            }
        }
        .sheet(isPresented: $showSessionCloser) {
            SessionCloserSheet {
                showSessionCloser = false
                sessionTimer.reset()
                sessionTimer.start()
            }
            .presentationDetents([.medium, .large])
        }
    }

    /// Welcome-back banner for kids who lapsed ≥ 3 days. Surfaces a
    /// warm greeting + a "Write" affordance that jumps to the Write
    /// tab. Dismissible.
    @ViewBuilder
    private var welcomeBackBanner: some View {
        if !welcomeBackDismissed, let message = welcomeBackMessage {
            WelcomeBackBannerView(
                message: message,
                onWrite: {
                    machine.selectedTab = .write
                    welcomeBackDismissed = true
                },
                onDismiss: {
                    welcomeBackDismissed = true
                }
            )
            .transition(reduceMotion ? .identity : .opacity)
        }
    }

    /// One-line warm nudge surfaced at the top of the root view when the
    /// kid's streak appears broken (≥ 2 calendar days lapsed with
    /// freezes exhausted). Dismissible via tap so a re-launch doesn't
    /// re-pester. Reduce-Motion-aware: the appearance transition
    /// collapses to `.identity` (instant snap) when the kid has
    /// `accessibilityReduceMotion` enabled.
    @ViewBuilder
    private var brokenStreakBanner: some View {
        if !brokenStreakDismissed, case .broken = StreakService.shared.inspectStreakStatus() {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(DialoguePalette.rust)
                Text(StreakService.brokenStreakMessage)
                    .font(.footnote)
                    .foregroundStyle(DialoguePalette.inkBlue)
                Spacer(minLength: 4)
                Button {
                    brokenStreakDismissed = true
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Dismiss this gentle reminder for now.")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(DialoguePalette.cream)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(DialoguePalette.rust.opacity(0.4), lineWidth: 1)
            )
            .padding(.top, 12)
            .padding(.horizontal, 16)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(StreakService.brokenStreakMessage)
            .transition(reduceMotion ? .identity : .opacity)
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
