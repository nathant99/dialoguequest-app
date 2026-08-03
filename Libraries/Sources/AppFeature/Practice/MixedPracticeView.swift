import SwiftUI
import Models
import SharedUI

/// Mixed practice — a calm, boundary-placed refresher that resurfaces +
/// interleaves what you've already practised. Orders/resurfaces, never
/// gates (`Docs/HANDOFF_FROM_HUB_PRACTICE_SCHEDULING_WEB_BACKPORT.md`).
struct MixedPracticeView: View {
    @State private var machine = MixedPracticeMachine()
    @State private var service = MixedPracticeService.shared
    @State private var recorded = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if machine.count == 0 {
                    emptyState
                } else if machine.isComplete {
                    completionScreen
                } else if let item = machine.current {
                    roundScreen(for: item)
                } else {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            .background(DialoguePalette.cream.opacity(0.6))
            .navigationTitle("Mixed practice")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear(perform: assembleIfNeeded)
        }
    }

    private func assembleIfNeeded() {
        guard machine.items.isEmpty else { return }
        machine.load(service.assembleRound().items)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Nothing to mix yet", systemImage: "square.stack.3d.up.slash")
        } description: {
            Text("Practice a few kits first, then come back for a gentle mixed refresher. No rush.")
        }
    }

    @ViewBuilder
    private func roundScreen(for item: RoundItem) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ProgressView(value: machine.progressFraction)
                    .tint(DialoguePalette.rust)

                Text(item.question.prompt)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(DialoguePalette.inkBlue)

                VStack(spacing: 8) {
                    ForEach(item.question.options) { option in
                        optionButton(item: item, option: option)
                    }
                }

                if machine.hasRevealed {
                    MentorBubbleView(message: item.question.mentorPostScript)
                    Button {
                        machine.advance()
                    } label: {
                        Label(
                            machine.currentIndex + 1 >= machine.count ? "Finish" : "Next",
                            systemImage: "arrow.right.circle.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(DialoguePalette.rust)
                    .accessibilityIdentifier("mixedPractice.next")
                } else {
                    Button {
                        machine.revealCurrent()
                    } label: {
                        Label("Check", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(machine.selectedOptionID == nil)
                    .accessibilityIdentifier("mixedPractice.check")
                    .accessibilityHint(
                        machine.selectedOptionID == nil
                        ? Text("Pick one of the options first.")
                        : Text("Check your answer.")
                    )
                }
            }
        }
    }

    private func optionButton(item: RoundItem, option: QuestionKit.Option) -> some View {
        let isSelected = machine.selectedOptionID == option.id
        let isCorrect = item.question.correctOptionID == option.id
        let revealed = machine.hasRevealed
        return Button {
            machine.select(option.id)
        } label: {
            HStack(alignment: .top) {
                Text(option.label)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(DialoguePalette.inkBlue)
                Spacer(minLength: 8)
                if revealed && isCorrect {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                } else if revealed && isSelected && !isCorrect {
                    Image(systemName: "minus.circle.fill").foregroundStyle(.orange)
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
    private var completionScreen: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 56))
                .foregroundStyle(DialoguePalette.rust)
            Text("Nice refresher")
                .font(.title.weight(.bold))
                .foregroundStyle(DialoguePalette.inkBlue)
            Text("You mixed \(machine.perKitQuality.count) kit\(machine.perKitQuality.count == 1 ? "" : "s") and got \(machine.correctCount) of \(machine.count) on the first try.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            MentorBubbleView(message: "Coming back to old scenes with fresh eyes is where it really sticks. See you next time.")
            Button {
                dismiss()
            } label: {
                Label("Done", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(DialoguePalette.rust)
            .accessibilityIdentifier("mixedPractice.done")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .onAppear(perform: recordIfNeeded)
    }

    /// Record the round's per-kit quality exactly once (advances/relearns
    /// each kit's spaced-retrieval ladder).
    private func recordIfNeeded() {
        guard !recorded else { return }
        recorded = true
        let quality = machine.perKitQuality
        if !quality.isEmpty {
            service.recordRoundResults(perKitQuality: quality)
        }
    }
}
