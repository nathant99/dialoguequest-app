import Foundation

/// View-local state for a Mixed practice round — plays an assembled
/// `[RoundItem]` and tracks first-try correctness per source kit so the
/// round can record a per-kit review (quality) on completion.
public nonisolated struct MixedPracticeMachine: Sendable, Equatable {
    public var items: [RoundItem]
    public var currentIndex: Int
    public var selectedOptionID: String?
    public var hasRevealed: Bool
    public var isComplete: Bool
    public var perKitCorrect: [String: Int]
    public var perKitTotal: [String: Int]

    public init(
        items: [RoundItem] = [],
        currentIndex: Int = 0,
        selectedOptionID: String? = nil,
        hasRevealed: Bool = false,
        isComplete: Bool = false,
        perKitCorrect: [String: Int] = [:],
        perKitTotal: [String: Int] = [:]
    ) {
        self.items = items
        self.currentIndex = currentIndex
        self.selectedOptionID = selectedOptionID
        self.hasRevealed = hasRevealed
        self.isComplete = isComplete
        self.perKitCorrect = perKitCorrect
        self.perKitTotal = perKitTotal
    }

    public mutating func reset() { self = MixedPracticeMachine() }

    public mutating func load(_ items: [RoundItem]) {
        self = MixedPracticeMachine(items: items, isComplete: items.isEmpty)
    }

    public var current: RoundItem? {
        items.indices.contains(currentIndex) ? items[currentIndex] : nil
    }

    public var count: Int { items.count }

    public var correctCount: Int { perKitCorrect.values.reduce(0, +) }

    public var progressFraction: Double {
        guard !items.isEmpty else { return 0 }
        return Double(currentIndex + (isComplete ? 1 : 0)) / Double(items.count)
    }

    public mutating func select(_ optionID: String) {
        guard !hasRevealed else { return }
        selectedOptionID = optionID
    }

    /// Reveal + tally the current item (first-try). No-op without a selection.
    public mutating func revealCurrent() {
        guard let item = current, !hasRevealed, let chosen = selectedOptionID else { return }
        hasRevealed = true
        perKitTotal[item.kitID, default: 0] += 1
        if chosen == item.question.correctOptionID {
            perKitCorrect[item.kitID, default: 0] += 1
        }
    }

    public mutating func advance() {
        guard hasRevealed else { return }
        if currentIndex + 1 >= items.count {
            isComplete = true
        } else {
            currentIndex += 1
            selectedOptionID = nil
            hasRevealed = false
        }
    }

    /// First-try quality (0…1) per kit that appeared in the round.
    public var perKitQuality: [String: Double] {
        var out: [String: Double] = [:]
        for (kit, total) in perKitTotal where total > 0 {
            out[kit] = Double(perKitCorrect[kit] ?? 0) / Double(total)
        }
        return out
    }
}
