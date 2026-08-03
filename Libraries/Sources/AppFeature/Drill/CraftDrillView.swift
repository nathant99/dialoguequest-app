import SwiftUI
import SharedUI

/// Reusable tap-to-select craft drill surface — shared by the Punctuation
/// Fix-It (Wave 2) and Write-It-in-Character (Wave 3) modes. Loads a deck
/// by id, walks its drills, and on reveal shows an anti-shame `why` for a
/// wrong pick plus the `teach` reframe. First-try scoring; the round
/// always advances (anti-shame — a miss never blocks progress).
struct CraftDrillView: View {
    let deckID: String
    var onComplete: (Int, Int) -> Void = { _, _ in }

    @State private var machine = CraftDrillMachine()
    @State private var loadFailure: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if let failure = loadFailure {
                    ContentUnavailableView(
                        "Couldn't load this drill",
                        systemImage: "exclamationmark.triangle",
                        description: Text(failure)
                    )
                } else if machine.isComplete {
                    completionScreen
                } else if let drill = machine.currentDrill {
                    drillScreen(for: drill)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            .background(DialoguePalette.cream.opacity(0.6))
            .navigationTitle(machine.deck?.title ?? "Drill")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        guard machine.deck == nil else { return }
        do {
            machine.load(try CraftDrillLoader.load(id: deckID))
        } catch {
            loadFailure = String(describing: error)
        }
    }

    @ViewBuilder
    private func drillScreen(for drill: CraftDrill) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ProgressView(value: machine.progressFraction)
                    .tint(DialoguePalette.rust)

                Text(drill.kindLabel.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DialoguePalette.rust)
                    .accessibilityHidden(true)

                Text(drill.setup)
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Text(drill.prompt)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(DialoguePalette.inkBlue)

                VStack(spacing: 8) {
                    ForEach(drill.options) { option in
                        optionButton(drill: drill, option: option)
                    }
                }

                if machine.hasRevealed {
                    revealBlock(for: drill)
                    Button {
                        machine.advance()
                    } label: {
                        Label(
                            machine.currentIndex + 1 >= machine.drillCount ? "Finish" : "Next",
                            systemImage: "arrow.right.circle.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(DialoguePalette.rust)
                    .accessibilityIdentifier("drill.next")
                } else {
                    Button {
                        machine.revealCurrent()
                    } label: {
                        Label("Check", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(machine.selectedOptionID == nil)
                    .accessibilityIdentifier("drill.check")
                    .accessibilityHint(
                        machine.selectedOptionID == nil
                        ? Text("Pick one of the options first.")
                        : Text("Check your answer.")
                    )
                }
            }
        }
    }

    private func optionButton(drill: CraftDrill, option: CraftDrill.Option) -> some View {
        let isSelected = machine.selectedOptionID == option.id
        let revealed = machine.hasRevealed
        return Button {
            machine.select(option.id)
        } label: {
            HStack(alignment: .top) {
                Text(option.text)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(DialoguePalette.inkBlue)
                Spacer(minLength: 8)
                if revealed && option.correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else if revealed && isSelected && !option.correct {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.orange)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(rowBackground(isSelected: isSelected, revealed: revealed, isCorrect: option.correct))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? DialoguePalette.rust : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(revealed)
    }

    /// After reveal: the anti-shame diagnostic for a wrong pick (if any)
    /// + the teach reframe. Verdict is carried by icon + text, never colour
    /// alone.
    @ViewBuilder
    private func revealBlock(for drill: CraftDrill) -> some View {
        if let picked = machine.selectedOption, !picked.correct, let why = picked.why {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb")
                    .foregroundStyle(DialoguePalette.rust)
                Text(why)
                    .font(.footnote)
                    .foregroundStyle(DialoguePalette.inkBlue)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DialoguePalette.warmGold.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        MentorBubbleView(message: drill.teach)
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
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(DialoguePalette.rust)
            Text("Nicely polished")
                .font(.title.weight(.bold))
                .foregroundStyle(DialoguePalette.inkBlue)
            Text("You got \(machine.correctCount) of \(machine.drillCount) on the first try.")
                .font(.callout)
                .foregroundStyle(.secondary)
            MentorBubbleView(message: "Punctuation and voice are the small choices readers feel without noticing. You're making them on purpose now.")
            Button {
                onComplete(machine.correctCount, machine.drillCount)
                dismiss()
            } label: {
                Label("Done", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(DialoguePalette.rust)
            .accessibilityIdentifier("drill.done")
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
