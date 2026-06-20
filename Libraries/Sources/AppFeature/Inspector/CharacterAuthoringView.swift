import SwiftUI
import Models
import SharedUI

/// Phase 1 character setup: the kid names 2 characters and writes the
/// voice register + 3 sample lines for each. Required before tree
/// editing unlocks.
struct CharacterAuthoringView: View {
    @Binding var machine: DialogueTreeMachine

    @State private var characterAName: String = ""
    @State private var characterAVoice: String = ""
    @State private var characterASample1: String = ""
    @State private var characterASample2: String = ""
    @State private var characterASample3: String = ""

    @State private var characterBName: String = ""
    @State private var characterBVoice: String = ""
    @State private var characterBSample1: String = ""
    @State private var characterBSample2: String = ""
    @State private var characterBSample3: String = ""

    @State private var moodSelection: DialogueMood = .openingCuriosity
    @State private var title: String = ""

    var body: some View {
        Form {
            Section("Conversation") {
                TextField("Title", text: $title)
                Picker("Mood", selection: $moodSelection) {
                    ForEach(DialogueMood.allCases) { mood in
                        Text(mood.displayName).tag(mood)
                    }
                }
            }
            characterSection(
                titleKey: "First character",
                name: $characterAName,
                voice: $characterAVoice,
                s1: $characterASample1,
                s2: $characterASample2,
                s3: $characterASample3
            )
            characterSection(
                titleKey: "Second character",
                name: $characterBName,
                voice: $characterBVoice,
                s1: $characterBSample1,
                s2: $characterBSample2,
                s3: $characterBSample3
            )
            Section {
                Button {
                    commitCharacters()
                } label: {
                    Label("Start the conversation", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(DialoguePalette.rust)
                .disabled(!isValid)
                .accessibilityHint(isValid
                    ? Text("Save the two characters and start writing the dialogue tree.")
                    : Text("Fill in both names, both voice registers, and at least one sample line for each character."))
            }
        }
        .scrollContentBackground(.hidden)
        .background(DialoguePalette.cream.opacity(0.6))
    }

    @ViewBuilder
    private func characterSection(
        titleKey: LocalizedStringKey,
        name: Binding<String>,
        voice: Binding<String>,
        s1: Binding<String>,
        s2: Binding<String>,
        s3: Binding<String>
    ) -> some View {
        Section(titleKey) {
            TextField("Name", text: name)
            TextField("Voice register (e.g., clipped, deflects, ends with 'I guess')", text: voice, axis: .vertical)
                .lineLimit(2...4)
            TextField("Sample line 1", text: s1)
            TextField("Sample line 2 (optional)", text: s2)
            TextField("Sample line 3 (optional)", text: s3)
        }
    }

    private var isValid: Bool {
        !characterAName.isEmpty && !characterAVoice.isEmpty && !characterASample1.isEmpty &&
        !characterBName.isEmpty && !characterBVoice.isEmpty && !characterBSample1.isEmpty &&
        !title.isEmpty
    }

    private func commitCharacters() {
        let charA = DialogueCharacterRef(
            name: characterAName,
            voiceRegister: characterAVoice,
            sampleLines: [characterASample1, characterASample2, characterASample3].filter { !$0.isEmpty }
        )
        let charB = DialogueCharacterRef(
            name: characterBName,
            voiceRegister: characterBVoice,
            sampleLines: [characterBSample1, characterBSample2, characterBSample3].filter { !$0.isEmpty }
        )
        machine.updateTitle(title)
        machine.updateMood(moodSelection)
        machine.addCharacter(charA)
        machine.addCharacter(charB)
        machine.finishCharacterAuthoring()
    }
}

#Preview {
    struct Harness: View {
        @State var machine = DialogueTreeMachine()
        var body: some View { CharacterAuthoringView(machine: $machine) }
    }
    return Harness()
}
