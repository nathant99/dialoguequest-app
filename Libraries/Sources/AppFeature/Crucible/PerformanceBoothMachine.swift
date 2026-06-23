import Foundation
import Models
import Services

/// Performance Booth adventure-mode state machine. Composes the two
/// Phase 3 audio surfaces (`DialogueReadAloudService` + `DialogueAudioExporter`)
/// into a single kid-facing adventure card: pick a published tree, hear it
/// read aloud in per-character voices, then export the rendering as an
/// AIFF the kid can share via the system share sheet.
///
/// Per `.claude/rules/state-machines.md` § "`*Machine` Structs": top-level
/// value type, organized via `// MARK:`, `mutating func reset()` re-assigns
/// `self` to a fresh instance. Pure logic — no UI, no services.
///
/// The 3-stage flow mirrors `VoiceCrucibleMachine` so the kid can find the
/// pattern across Adventure modes: pick a target → engage → see the result.
public nonisolated struct PerformanceBoothMachine: Sendable, Equatable {

    // MARK: - Stage

    /// Performance Booth's 3-stage lifecycle. Each stage carries only what
    /// the next transition needs — no overlapping state.
    public enum Stage: Sendable, Equatable {
        /// Kid is choosing which published tree to perform. The anthology
        /// snapshot is supplied by the view layer (SwiftData fetch on
        /// `onAppear`), so the machine itself never touches `ModelContext`.
        case choosingTree
        /// Kid has picked a tree; playback + optional export are available.
        /// `lastVoiceMatchAverage` records the analyzer-reported average
        /// from the per-character voice baselines so the achievement gate
        /// can verify "three voices distinguishable" before exporting.
        case performing(treeID: UUID)
        /// Export complete. URL is the AIFF location ready for `ShareLink`.
        case exported(treeID: UUID, audioURL: URL)
    }

    // MARK: - State

    public var stage: Stage = .choosingTree

    /// Number of completed exports this session. Bumps on `markExported(...)`.
    /// `WriteTabView` / `PerformanceBoothView` reads this for the analytics
    /// event + achievement criteria.
    public private(set) var exportCount: Int = 0

    /// Whether the kid has tapped the listen button on the current tree at
    /// least once during this `.performing` stage. Used by the
    /// achievement-criteria projection (`performance_booth_premiere`
    /// requires at least one read-aloud before the export).
    public private(set) var hasListenedThisRound: Bool = false

    public init() {}

    // MARK: - Transitions

    /// Pick a tree to perform. `tree.id` becomes the active target.
    /// Guards against entering `.performing` with a not-yet-published tree
    /// — `PerformanceBoothView` filters the picker to published entries.
    public mutating func selectTree(id: UUID) {
        stage = .performing(treeID: id)
        hasListenedThisRound = false
    }

    /// Mark that the kid has played the current tree at least once. The view
    /// layer calls this when `DialogueReadAloudService.phase` transitions to
    /// `.playing(...)`. Idempotent — repeat calls stay at `true`.
    public mutating func markListened() {
        guard case .performing = stage else { return }
        hasListenedThisRound = true
    }

    /// Mark an export complete and transition into `.exported`. The view
    /// layer hands in the resolved AIFF URL produced by `DialogueAudioExporter`.
    public mutating func markExported(audioURL: URL) {
        guard case let .performing(treeID) = stage else { return }
        stage = .exported(treeID: treeID, audioURL: audioURL)
        exportCount += 1
    }

    /// Drop back to tree selection. Used by the "Perform another" button
    /// after `.exported`.
    public mutating func reselectTree() {
        stage = .choosingTree
        hasListenedThisRound = false
    }

    /// Required by the portfolio state-machine convention. Re-assigns
    /// `self` to a fresh instance so every field including `exportCount`
    /// resets.
    public mutating func reset() {
        self = PerformanceBoothMachine()
    }

    // MARK: - Derived helpers

    /// The currently selected tree id, or `nil` when at `.choosingTree`.
    public var selectedTreeID: UUID? {
        switch stage {
        case .choosingTree: return nil
        case .performing(let id): return id
        case .exported(let id, _): return id
        }
    }

    /// The current export URL, or `nil` when not at `.exported`.
    public var currentExportURL: URL? {
        if case .exported(_, let url) = stage { return url }
        return nil
    }
}
