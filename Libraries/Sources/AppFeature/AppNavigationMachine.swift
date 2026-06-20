import Foundation

/// View-local navigation state machine per `.claude/rules/state-machines.md`
/// § "`*Machine` Structs". Tracks which root tab is selected; future
/// navigation state (modal overlays, sheet routes) joins as it lands.
public nonisolated struct AppNavigationMachine: Sendable, Equatable {
    public var selectedTab: AppTab

    public init(selectedTab: AppTab = .write) {
        self.selectedTab = selectedTab
    }

    public mutating func reset() {
        self = AppNavigationMachine()
    }
}

/// The 4 root tabs DialogueQuest ships in Phase 1.
public nonisolated enum AppTab: String, Sendable, Hashable, CaseIterable, Identifiable {
    case write
    case adventure
    case progress
    case profile

    public var id: String { rawValue }
}
