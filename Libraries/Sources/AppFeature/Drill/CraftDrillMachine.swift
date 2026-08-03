import Foundation

/// View-local state for a `CraftDrill` run, per
/// `.claude/rules/state-machines.md`. First-try scoring: a drill counts
/// toward `correctCount` only if the option selected at reveal time is the
/// canonical answer (single selection, no retry — mirrors the web shell).
public nonisolated struct CraftDrillMachine: Sendable, Equatable {
    public var deck: CraftDrillDeck?
    public var currentIndex: Int
    public var selectedOptionID: String?
    public var hasRevealed: Bool
    public var correctCount: Int
    public var isComplete: Bool

    public init(
        deck: CraftDrillDeck? = nil,
        currentIndex: Int = 0,
        selectedOptionID: String? = nil,
        hasRevealed: Bool = false,
        correctCount: Int = 0,
        isComplete: Bool = false
    ) {
        self.deck = deck
        self.currentIndex = currentIndex
        self.selectedOptionID = selectedOptionID
        self.hasRevealed = hasRevealed
        self.correctCount = correctCount
        self.isComplete = isComplete
    }

    public mutating func reset() {
        self = CraftDrillMachine()
    }

    public mutating func load(_ deck: CraftDrillDeck) {
        self = CraftDrillMachine(deck: deck)
    }

    public var currentDrill: CraftDrill? {
        guard let deck, deck.drills.indices.contains(currentIndex) else { return nil }
        return deck.drills[currentIndex]
    }

    public var drillCount: Int { deck?.drills.count ?? 0 }

    public var progressFraction: Double {
        guard let deck, !deck.drills.isEmpty else { return 0 }
        return Double(currentIndex + (isComplete ? 1 : 0)) / Double(deck.drills.count)
    }

    /// The option the learner selected (if any) for the current drill.
    public var selectedOption: CraftDrill.Option? {
        guard let selectedOptionID, let drill = currentDrill else { return nil }
        return drill.options.first(where: { $0.id == selectedOptionID })
    }

    public mutating func select(_ optionID: String) {
        guard !hasRevealed else { return }
        selectedOptionID = optionID
    }

    /// Reveal + score the current drill (first-try). No-op if nothing is
    /// selected or the drill is already revealed.
    public mutating func revealCurrent() {
        guard let drill = currentDrill, !hasRevealed, let chosen = selectedOptionID else { return }
        hasRevealed = true
        if let picked = drill.options.first(where: { $0.id == chosen }), picked.correct {
            correctCount += 1
        }
    }

    /// Advance to the next drill; marks complete after the last reveal.
    public mutating func advance() {
        guard hasRevealed, let deck else { return }
        if currentIndex + 1 >= deck.drills.count {
            isComplete = true
        } else {
            currentIndex += 1
            selectedOptionID = nil
            hasRevealed = false
        }
    }
}
