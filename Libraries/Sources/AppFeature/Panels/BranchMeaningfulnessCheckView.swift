import SwiftUI
import Models
import AIMentor
import SharedUI

/// Socratic 3-question prompt the kid sees when they tap a branch-point.
/// The reflection text is not graded; recording any answer marks the
/// branch as "reflected upon" — drives `BranchMeaningfulnessScorer.reflectionRatio`.
struct BranchMeaningfulnessCheckView: View {
    @Binding var machine: DialogueTreeMachine
    let mentor: PatterMentor
    /// The branch-point node the kid just opened. Closes (via `onClose`)
    /// when reflection is recorded.
    let branchPointID: UUID
    var onClose: () -> Void = {}

    @State private var check: BranchMeaningfulnessCheck?
    @State private var reflection: String = ""
    @State private var isLoading: Bool = false

    /// Scales the reflection editor's minimum height with Dynamic Type so
    /// kids on `accessibility5` settings don't see the editor clip to a
    /// 100pt fixed box. Default 100pt mirrors the pre-a11y-round height.
    @ScaledMetric(relativeTo: .body) private var reflectionEditorMinHeight: CGFloat = 100

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                if let check {
                    questionRow(index: 1, text: check.question1)
                    questionRow(index: 2, text: check.question2)
                    questionRow(index: 3, text: check.question3)
                } else if isLoading {
                    ProgressView("Patter is thinking…")
                        .frame(maxWidth: .infinity)
                }

                Divider()

                Text("Your reflection")
                    .font(.headline)
                    .foregroundStyle(DialoguePalette.rust)
                TextEditor(text: $reflection)
                    .frame(minHeight: reflectionEditorMinHeight)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(DialoguePalette.rust.opacity(0.3), lineWidth: 1)
                    )

                Button {
                    machine.recordReflection(for: branchPointID)
                    onClose()
                } label: {
                    Label("Save and continue", systemImage: "checkmark.seal.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(DialoguePalette.rust)
                .disabled(reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityHint("Mark this branch point as reflected upon. Patter will not grade your answer.")
            }
            .padding()
            .navigationTitle("Branching here?")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { onClose() }
                }
            }
        }
        .task(id: branchPointID) {
            await loadCheck()
        }
    }

    private func questionRow(index: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(index).")
                .font(.callout.weight(.semibold))
                .foregroundStyle(DialoguePalette.rust)
            Text(text)
                .font(.callout)
                .foregroundStyle(DialoguePalette.inkBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func loadCheck() async {
        isLoading = true
        let result = await mentor.branchCheck(for: machine.tree.mood)
        check = result
        isLoading = false
    }
}
