import AppIntents
import Foundation
import ForgeIntents

/// Siri / Shortcuts integration for DialogueQuest. Each intent maps to
/// a deep-link destination inside the app and posts
/// `DialogueQuestIntentNavigation.notificationName` carrying the target
/// `AppTab`. `RootView` observes the notification and updates its
/// `AppNavigationMachine.selectedTab`.
///
/// Per `.claude/rules/concurrency.md` § Async/Await: we use the
/// `NotificationCenter.default.notifications(named:)` async sequence in
/// `RootView` — no Combine, no `Task.sleep`-based delivery races.
///
/// **Why these surfaces?** App Intents shine when they map to a stable
/// in-app destination the kid (or their parent) might want to reach
/// fast: starting a new dialogue, checking progress, opening the app
/// from a watch-face complication or a Shortcut on the home screen.
/// The portfolio-shared `ForgeShortcutPhraseBuilder` keeps Siri phrasing
/// consistent across apps.

// MARK: - Destination

/// Destinations the App Intent layer can deep-link to. Maps 1:1 onto
/// the `AppTab` cases the kid can reach via the in-app TabView.
public nonisolated enum DialogueQuestDestination: String, Sendable, Hashable, CaseIterable {
    case write
    case adventure
    case progress

    /// Convert to the matching `AppTab`. Voice Crucible is *inside*
    /// the Adventure tab, so an "Open Voice Crucible" intent lands on
    /// `.adventure` and the kid taps once more — that's the right UX
    /// tradeoff for a SwiftUI sheet that needs a parent view to host it.
    public var tab: AppTab {
        switch self {
        case .write:     return .write
        case .adventure: return .adventure
        case .progress:  return .progress
        }
    }
}

// MARK: - Notification bridge

/// Notification surface the intents post on `perform()`. `RootView`
/// observes `notificationName` via an `async` sequence and updates
/// `AppNavigationMachine.selectedTab`.
public nonisolated enum DialogueQuestIntentNavigation {
    public static let notificationName = Notification.Name("DialogueQuestIntentNavigation")
    public static let destinationKey = "destination"

    /// Read the destination off an incoming notification. Returns `nil`
    /// when the userInfo payload is malformed (defensive — should never
    /// happen given the only emitter is our own intents).
    public static func destination(from notification: Notification) -> DialogueQuestDestination? {
        guard let raw = notification.userInfo?[destinationKey] as? String else { return nil }
        return DialogueQuestDestination(rawValue: raw)
    }

    /// Emit the navigation notification. Public so the intents (and
    /// tests) can use the same emitter — keeps the userInfo shape in
    /// one place.
    public static func post(_ destination: DialogueQuestDestination) {
        NotificationCenter.default.post(
            name: notificationName,
            object: nil,
            userInfo: [destinationKey: destination.rawValue]
        )
    }
}

// MARK: - Phrase builder

/// App name surfaced in Siri phrases. Kept as a single constant so future
/// rename (unlikely) is a one-line change.
public nonisolated let dialogueQuestAppName: String = "DialogueQuest"

/// Phrase builder pre-instantiated with the app name. Cross-target callers
/// (tests, the AppShortcutsProvider) use this to build canonical phrases.
public nonisolated let dialogueQuestPhrases = ForgeShortcutPhraseBuilder(appName: dialogueQuestAppName)

// MARK: - Intents

/// "Open DialogueQuest" — lands on the Write tab (the canonical landing
/// surface; matches the icon-tap behavior on Springboard).
@available(iOS 26.0, macOS 26.0, *)
public struct OpenDialogueQuestIntent: AppIntent, ForgeOpenAppIntentProviding {
    public static let title: LocalizedStringResource = "Open DialogueQuest"
    public static let description = IntentDescription(
        "Open DialogueQuest to keep writing a dialogue tree."
    )
    public static let openAppWhenRun: Bool = true

    public init() {}

    public var destination: DialogueQuestDestination { .write }

    @MainActor
    public func perform() async throws -> some IntentResult {
        DialogueQuestIntentNavigation.post(.write)
        return .result()
    }
}

/// "Start a new dialogue" — lands on the Write tab and the kid can begin
/// authoring. Same destination as Open intent, but separated so Siri's
/// trigger phrase is "start" not "open".
@available(iOS 26.0, macOS 26.0, *)
public struct StartDialogueIntent: AppIntent, ForgeOpenAppIntentProviding {
    public static let title: LocalizedStringResource = "Start a dialogue"
    public static let description = IntentDescription(
        "Open DialogueQuest and jump to the Write tab to start a new conversation."
    )
    public static let openAppWhenRun: Bool = true

    public init() {}

    public var destination: DialogueQuestDestination { .write }

    @MainActor
    public func perform() async throws -> some IntentResult {
        DialogueQuestIntentNavigation.post(.write)
        return .result()
    }
}

/// "Show my progress" — lands on the Progress tab so the kid sees XP /
/// streak / badges at a glance.
@available(iOS 26.0, macOS 26.0, *)
public struct ShowMyProgressIntent: AppIntent, ForgeOpenAppIntentProviding {
    public static let title: LocalizedStringResource = "Show my progress"
    public static let description = IntentDescription(
        "Open DialogueQuest and jump to the Progress tab."
    )
    public static let openAppWhenRun: Bool = true

    public init() {}

    public var destination: DialogueQuestDestination { .progress }

    @MainActor
    public func perform() async throws -> some IntentResult {
        DialogueQuestIntentNavigation.post(.progress)
        return .result()
    }
}

/// "Open the Word Workshop" — lands on the Adventure tab, surfacing the
/// progression-gated Word Workshop card + Voice Crucible entry.
@available(iOS 26.0, macOS 26.0, *)
public struct OpenWordWorkshopIntent: AppIntent, ForgeOpenAppIntentProviding {
    public static let title: LocalizedStringResource = "Open the Word Workshop"
    public static let description = IntentDescription(
        "Open DialogueQuest and jump to the Adventure tab where Word Workshop lives."
    )
    public static let openAppWhenRun: Bool = true

    public init() {}

    public var destination: DialogueQuestDestination { .adventure }

    @MainActor
    public func perform() async throws -> some IntentResult {
        DialogueQuestIntentNavigation.post(.adventure)
        return .result()
    }
}

// MARK: - Shortcuts provider

/// Registers the 4 intents with Siri + Shortcuts. iOS auto-discovers
/// the provider at app launch (no app-shell wiring required when the
/// type is reachable in the linked binary).
@available(iOS 26.0, macOS 26.0, *)
public struct DialogueQuestShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenDialogueQuestIntent(),
            phrases: [
                "Open \(.applicationName)",
                "Launch \(.applicationName)"
            ],
            shortTitle: "Open",
            systemImageName: "bubble.left.and.text.bubble.right"
        )
        AppShortcut(
            intent: StartDialogueIntent(),
            phrases: [
                "Start a dialogue in \(.applicationName)",
                "Start writing in \(.applicationName)"
            ],
            shortTitle: "Start a dialogue",
            systemImageName: "pencil.and.scribble"
        )
        AppShortcut(
            intent: ShowMyProgressIntent(),
            phrases: [
                "Show my progress in \(.applicationName)",
                "How am I doing in \(.applicationName)"
            ],
            shortTitle: "Show progress",
            systemImageName: "chart.line.uptrend.xyaxis"
        )
        AppShortcut(
            intent: OpenWordWorkshopIntent(),
            phrases: [
                "Open the Word Workshop in \(.applicationName)",
                "Open Word Workshop in \(.applicationName)"
            ],
            shortTitle: "Word Workshop",
            systemImageName: "map"
        )
    }
}
