import SwiftUI
import Models
import SharedUI

/// Phase 1 quiz renderer. Loads a kit, walks questions, surfaces
/// Patter's post-question script. Reveal-on-tap (not auto-grade).
struct QuizView: View {
    let kitID: String
    var onComplete: (Int, Int) -> Void = { _, _ in }

    @State private var machine = QuizMachine()
    @State private var loadFailure: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let failure = loadFailure {
                ContentUnavailableView(
                    "Couldn't load this kit",
                    systemImage: "exclamationmark.triangle",
                    description: Text(failure)
                )
            } else if machine.isComplete, let kit = machine.kit {
                completionScreen(for: kit)
            } else if let question = machine.currentQuestion {
                questionScreen(for: question)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .background(DialoguePalette.cream.opacity(0.6))
        .onAppear { load() }
    }

    private func load() {
        guard machine.kit == nil else { return }
        do {
            let kit = try QuestionKitLoader.load(id: kitID)
            machine.load(kit)
        } catch {
            loadFailure = String(describing: error)
        }
    }

    @ViewBuilder
    private func questionScreen(for question: QuestionKit.Question) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressView(value: machine.progressFraction)
                .tint(DialoguePalette.rust)

            Text(question.prompt)
                .font(.title3.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)

            VStack(spacing: 8) {
                ForEach(question.options) { option in
                    optionButton(question: question, option: option)
                }
            }

            if machine.hasRevealedAnswer {
                MentorBubbleView(message: question.mentorPostScript)
                Button {
                    machine.advance()
                } label: {
                    Label("Next", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(DialoguePalette.rust)
            } else {
                Button {
                    machine.revealCurrent()
                } label: {
                    Label("Reveal", systemImage: "eye")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(machine.selectedOptionID == nil)
                .accessibilityHint(
                    machine.selectedOptionID == nil
                    ? Text("Pick one of the options first.")
                    : Text("Show Patter's note.")
                )
            }
            Spacer()
        }
    }

    private func optionButton(question: QuestionKit.Question, option: QuestionKit.Option) -> some View {
        let isSelected = machine.selectedOptionID == option.id
        let isCorrect = question.correctOptionID == option.id
        let revealed = machine.hasRevealedAnswer

        return Button {
            machine.select(option.id)
        } label: {
            HStack {
                Text(option.label)
                    .multilineTextAlignment(.leading)
                Spacer()
                if revealed && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else if revealed && isSelected && !isCorrect {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.orange)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(rowBackground(isSelected: isSelected, revealed: revealed, isCorrect: isCorrect))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? DialoguePalette.rust : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(revealed)
    }

    private func rowBackground(isSelected: Bool, revealed: Bool, isCorrect: Bool) -> Color {
        if revealed && isCorrect { return .green.opacity(0.2) }
        if revealed && isSelected && !isCorrect { return .orange.opacity(0.2) }
        if isSelected { return DialoguePalette.warmGold.opacity(0.25) }
        return .white
    }

    @ViewBuilder
    private func completionScreen(for kit: QuestionKit) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(DialoguePalette.rust)
            Text("Nice work")
                .font(.title.weight(.bold))
                .foregroundStyle(DialoguePalette.inkBlue)
            Text("You answered \(machine.correctCount) of \(kit.questions.count) right.")
                .font(.callout)
                .foregroundStyle(.secondary)
            MentorBubbleView(message: "Every answer here is a small bet on what you noticed. The noticing is the craft.")
            Button {
                onComplete(machine.correctCount, kit.questions.count)
            } label: {
                Label("Done", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(DialoguePalette.rust)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
