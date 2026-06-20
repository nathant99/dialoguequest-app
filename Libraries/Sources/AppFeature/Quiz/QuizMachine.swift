import Foundation
import Models

/// View-local quiz state per `.claude/rules/state-machines.md`.
public nonisolated struct QuizMachine: Sendable, Equatable {
    public var kit: QuestionKit?
    public var currentIndex: Int
    public var correctCount: Int
    public var selectedOptionID: String?
    public var hasRevealedAnswer: Bool
    public var isComplete: Bool

    public init(
        kit: QuestionKit? = nil,
        currentIndex: Int = 0,
        correctCount: Int = 0,
        selectedOptionID: String? = nil,
        hasRevealedAnswer: Bool = false,
        isComplete: Bool = false
    ) {
        self.kit = kit
        self.currentIndex = currentIndex
        self.correctCount = correctCount
        self.selectedOptionID = selectedOptionID
        self.hasRevealedAnswer = hasRevealedAnswer
        self.isComplete = isComplete
    }

    public mutating func reset() {
        self = QuizMachine()
    }

    public mutating func load(_ kit: QuestionKit) {
        self = QuizMachine(kit: kit)
    }

    public var currentQuestion: QuestionKit.Question? {
        guard let kit, kit.questions.indices.contains(currentIndex) else { return nil }
        return kit.questions[currentIndex]
    }

    public var progressFraction: Double {
        guard let kit, !kit.questions.isEmpty else { return 0 }
        return Double(currentIndex + (isComplete ? 1 : 0)) / Double(kit.questions.count)
    }

    public mutating func select(_ optionID: String) {
        guard !hasRevealedAnswer else { return }
        selectedOptionID = optionID
    }

    /// Reveal the answer for the current question and update tally.
    public mutating func revealCurrent() {
        guard let question = currentQuestion, !hasRevealedAnswer else { return }
        hasRevealedAnswer = true
        if let chosen = selectedOptionID, chosen == question.correctOptionID {
            correctCount += 1
        }
    }

    /// Advance to the next question. Marks the quiz complete after the
    /// last reveal.
    public mutating func advance() {
        guard hasRevealedAnswer, let kit else { return }
        if currentIndex + 1 >= kit.questions.count {
            isComplete = true
        } else {
            currentIndex += 1
            selectedOptionID = nil
            hasRevealedAnswer = false
        }
    }
}
