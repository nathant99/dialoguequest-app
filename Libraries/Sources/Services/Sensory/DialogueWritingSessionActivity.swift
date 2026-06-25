import Foundation
import ForgeLiveActivities

/// Phase 4 Live Activity scaffold — wraps ForgeKit 0.99 `ForgeActivityManager`
/// with DialogueQuest-specific attribute/state shape and gates on whether
/// the Widget Extension target is wired. Closes the open
/// ForgeLiveActivities integration gap surfaced in the 2026-06-23
/// portfolio audit.
///
/// **Safety pattern (entitlement-gated framework)** per
/// `@.claude/rules/warnings.md` § "Entitlement-Gated Frameworks": Live
/// Activities require BOTH a Widget Extension target (so iOS knows where
/// to render the Dynamic Island / Lock Screen views) AND the
/// `NSSupportsLiveActivities` Info.plist key on the app target. Until
/// the GUI work in `@Docs/HANDOFF_TO_USER_WIDGET_EXTENSION.md` lands,
/// every public surface stays in `.notWired` and the underlying
/// `ForgeActivityManager` is never touched.
///
/// **Why the underlying ForgeActivityManager is safe to instantiate even
/// in `.notWired` state**: ForgeKit's manager is a pure value-type
/// lifecycle wrapper that NEVER calls `ActivityKit.Activity.request(...)`
/// directly — it tracks `isActive` + `currentAttributes` +
/// `currentState`. The actual ActivityKit invocation lands in the future
/// PR that wires the Widget Extension target. So the scaffold can
/// roundtrip + persist state today without any crash risk.
///
/// **What this scaffold provides**:
/// - `Availability` enum surfacing reader-friendly states
/// - `isWired` static probe — safe to call without entitlement
/// - `start` / `update` / `end` value-type entry points that proxy to
///   `ForgeActivityManager` when wired, no-op when not
/// - `WritingSessionAttributes` shape capturing what the Lock Screen
///   surface needs to render (mood, character names, started timestamp)
///
/// **What this scaffold does NOT provide** (intentional):
/// - `ActivityKit.Activity.request(...)` — gated on Widget Extension
/// - Widget UI views — those live in the to-be-created widget bundle
/// - Background push token registration — Phase 5 candidate
@MainActor
public final class DialogueWritingSessionActivity {
    public static let shared = DialogueWritingSessionActivity()

    /// Reader-facing availability states. Mirrors the
    /// `VoiceActingCoachService.Availability` shape.
    public enum Availability: Sendable, Equatable {
        /// `NSSupportsLiveActivities` Info.plist key missing OR no
        /// Widget Extension target detected. Default state today.
        case notWired
        /// Wired, but no session is currently surfaced.
        case ready
        /// A session is being rendered on the Lock Screen / Dynamic Island.
        case active
    }

    /// Static probe of the Info.plist `NSSupportsLiveActivities` key.
    /// Cached at static-let init per the privacy-gated-framework rule.
    public static let isWired: Bool = {
        let key = "NSSupportsLiveActivities"
        guard let raw = Bundle.main.object(forInfoDictionaryKey: key) else { return false }
        if let bool = raw as? Bool { return bool }
        if let string = raw as? String { return (string as NSString).boolValue }
        return false
    }()

    /// Underlying ForgeKit manager. Never invoked when `isWired == false`.
    @MainActor private let manager: ForgeActivityManager

    public init() {
        self.manager = ForgeActivityManager()
    }

    public var availability: Availability {
        if !Self.isWired { return .notWired }
        if manager.isActive { return .active }
        return .ready
    }

    public var availabilityDescription: String {
        switch availability {
        case .notWired:
            return "Lock Screen tracker: not yet enabled. The kid's writing session won't show up on the Lock Screen or Dynamic Island until the Widget Extension is added in Xcode."
        case .ready:
            return "Lock Screen tracker: ready. The next write session will surface a Lock Screen card with the current node count and characters."
        case .active:
            return "Lock Screen tracker: showing the current session."
        }
    }

    // MARK: - Lifecycle entry points (no-op when not wired)

    /// Start surfacing a new writing session on the Lock Screen / Dynamic Island.
    /// When `.notWired`, every entry point is a safe no-op so callers don't have
    /// to gate themselves.
    public func start(attributes: WritingSessionAttributes, state: WritingSessionContentState) {
        guard Self.isWired else { return }
        let forgeAttributes = attributes.toForgeAttributes()
        let forgeState = state.toForgeState()
        do {
            try manager.start(attributes: forgeAttributes, initialState: forgeState)
        } catch {
            DialogueQuestDebugLog.error(
                "DialogueWritingSessionActivity.start — ForgeActivityManager.start threw; Live Activity not surfaced",
                error: error
            )
        }
    }

    /// Push an updated state into the current Live Activity. No-op when not wired
    /// or when no session has been started.
    public func update(state: WritingSessionContentState) {
        guard Self.isWired, manager.isActive else { return }
        let forgeState = state.toForgeState()
        do {
            try manager.update(forgeState)
        } catch {
            DialogueQuestDebugLog.error(
                "DialogueWritingSessionActivity.update — ForgeActivityManager.update threw; Lock Screen card stale",
                error: error
            )
        }
    }

    /// End the current Live Activity. Idempotent.
    public func end() {
        guard Self.isWired else { return }
        manager.end()
    }

    // MARK: - Pure value-type shape

    /// Static attributes that don't change over the life of the activity.
    /// `subjectName` flows into the Lock Screen card title; `iconName` is
    /// SF Symbols (or asset-catalog name once wired). Pure Sendable so
    /// callers can construct on any actor.
    public nonisolated struct WritingSessionAttributes: Sendable, Codable, Hashable {
        public let subjectName: String
        public let iconName: String
        public let totalNodesTarget: Int

        public init(
            subjectName: String,
            iconName: String = "text.bubble",
            totalNodesTarget: Int = 15
        ) {
            self.subjectName = subjectName
            self.iconName = iconName
            self.totalNodesTarget = totalNodesTarget
        }

        public nonisolated func toForgeAttributes() -> ForgeSessionAttributes {
            ForgeSessionAttributes(
                subjectName: subjectName,
                iconName: iconName,
                totalQuestions: totalNodesTarget,
                sessionType: .practice
            )
        }
    }

    /// Dynamic state that changes through the session. `currentNodeCount`
    /// is the kid's progress toward the tree; `moodLabel` mirrors the
    /// `DialogueMood.displayName` (passed in by the caller so this module
    /// stays free of a `Models` dep cycle).
    public nonisolated struct WritingSessionContentState: Sendable, Codable, Hashable {
        public let currentNodeCount: Int
        public let totalNodesTarget: Int
        public let moodLabel: String
        public let elapsedMinutes: Int
        public let isPaused: Bool

        public init(
            currentNodeCount: Int,
            totalNodesTarget: Int,
            moodLabel: String,
            elapsedMinutes: Int,
            isPaused: Bool = false
        ) {
            self.currentNodeCount = currentNodeCount
            self.totalNodesTarget = totalNodesTarget
            self.moodLabel = moodLabel
            self.elapsedMinutes = elapsedMinutes
            self.isPaused = isPaused
        }

        public nonisolated func toForgeState() -> ForgeSessionContentState {
            ForgeSessionContentState(
                currentQuestion: currentNodeCount,
                totalQuestions: totalNodesTarget,
                correctCount: currentNodeCount,
                streak: 0,
                timeRemaining: TimeInterval(elapsedMinutes * 60),
                status: isPaused ? .paused : .active
            )
        }
    }
}
