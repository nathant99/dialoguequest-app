import SwiftUI
import Models
import SharedUI

/// Character setup. Phase 1 ships 2 characters; Phase 2 unlocks an
/// optional third character + per-character archetype role when the
/// `dq.experiments.thirdCharacter` flag is on. The third row + role
/// pickers stay hidden until the flag flips so existing Phase-1
/// flows are untouched.
struct CharacterAuthoringView: View {
    @Binding var machine: DialogueTreeMachine
    @AppStorage(TriangleAuthoringFeatureFlag.storageKey) private var thirdCharacterEnabled: Bool = false

    @State private var characterAName: String = ""
    @State private var characterAVoice: String = ""
    @State private var characterARole: DialogueCharacterRole = .unspecified
    @State private var characterASample1: String = ""
    @State private var characterASample2: String = ""
    @State private var characterASample3: String = ""

    @State private var characterBName: String = ""
    @State private var characterBVoice: String = ""
    @State private var characterBRole: DialogueCharacterRole = .unspecified
    @State private var characterBSample1: String = ""
    @State private var characterBSample2: String = ""
    @State private var characterBSample3: String = ""

    @State private var characterCName: String = ""
    @State private var characterCVoice: String = ""
    @State private var characterCRole: DialogueCharacterRole = .unspecified
    @State private var characterCSample1: String = ""
    @State private var characterCSample2: String = ""
    @State private var characterCSample3: String = ""

    @State private var moodSelection: DialogueMood = .openingCuriosity
    @State private var title: String = ""

    var body: some View {
        Form {
            Section("Conversation") {
                TextField("Title", text: $title)
                    .accessibilityHint("A title for this conversation. Shows up in the anthology gallery once you publish.")
                Picker("Mood", selection: $moodSelection) {
                    ForEach(DialogueMood.allCases) { mood in
                        Text(mood.displayName).tag(mood)
                    }
                }
                .accessibilityHint("The emotional weather of the scene. Mood influences how the AI mentor reads subtext and how the streak holds on hard scenes.")
            }
            characterSection(
                titleKey: "First character",
                name: $characterAName,
                voice: $characterAVoice,
                role: $characterARole,
                s1: $characterASample1,
                s2: $characterASample2,
                s3: $characterASample3
            )
            characterSection(
                titleKey: "Second character",
                name: $characterBName,
                voice: $characterBVoice,
                role: $characterBRole,
                s1: $characterBSample1,
                s2: $characterBSample2,
                s3: $characterBSample3
            )
            if thirdCharacterEnabled {
                characterSection(
                    titleKey: "Third character (optional)",
                    name: $characterCName,
                    voice: $characterCVoice,
                    role: $characterCRole,
                    s1: $characterCSample1,
                    s2: $characterCSample2,
                    s3: $characterCSample3
                )
            }
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
                    ? Text("Save the characters and start writing the dialogue tree.")
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
        role: Binding<DialogueCharacterRole>,
        s1: Binding<String>,
        s2: Binding<String>,
        s3: Binding<String>
    ) -> some View {
        Section(titleKey) {
            TextField("Name", text: name)
                .accessibilityHint("The character's name. Appears next to every line they say.")
            TextField("Voice register (e.g., clipped, deflects, ends with 'I guess')", text: voice, axis: .vertical)
                .lineLimit(2...4)
                .accessibilityHint("A one-paragraph description of how this character talks. Used by the AI mentor to check voice consistency across lines.")
            if thirdCharacterEnabled {
                Picker("Role", selection: role) {
                    ForEach(DialogueCharacterRole.allCases, id: \.self) { roleCase in
                        Text(roleCase.displayName).tag(roleCase)
                    }
                }
                .accessibilityHint(Text(role.wrappedValue.coachingHint))
            }
            TextField("Sample line 1", text: s1)
                .accessibilityHint("A real line this character might say. The mentor uses this to build the voice baseline.")
            TextField("Sample line 2 (optional)", text: s2)
                .accessibilityHint("A second sample line, optional. More samples means a stronger voice baseline.")
            TextField("Sample line 3 (optional)", text: s3)
                .accessibilityHint("A third sample line, optional. More samples means a stronger voice baseline.")
        }
    }

    private var isValid: Bool {
        let twoCharactersValid =
            !characterAName.isEmpty && !characterAVoice.isEmpty && !characterASample1.isEmpty &&
            !characterBName.isEmpty && !characterBVoice.isEmpty && !characterBSample1.isEmpty &&
            !title.isEmpty
        guard thirdCharacterEnabled else { return twoCharactersValid }
        // Phase 2: third character is OPTIONAL — if any field is provided,
        // all three (name + voice + first sample) must be provided.
        let thirdCharacterTouched =
            !characterCName.isEmpty || !characterCVoice.isEmpty || !characterCSample1.isEmpty
        let thirdCharacterComplete =
            !characterCName.isEmpty && !characterCVoice.isEmpty && !characterCSample1.isEmpty
        if thirdCharacterTouched {
            return twoCharactersValid && thirdCharacterComplete
        }
        return twoCharactersValid
    }

    private func commitCharacters() {
        let charA = DialogueCharacterRef(
            name: characterAName,
            voiceRegister: characterAVoice,
            sampleLines: [characterASample1, characterASample2, characterASample3].filter { !$0.isEmpty },
            role: characterARole
        )
        let charB = DialogueCharacterRef(
            name: characterBName,
            voiceRegister: characterBVoice,
            sampleLines: [characterBSample1, characterBSample2, characterBSample3].filter { !$0.isEmpty },
            role: characterBRole
        )
        machine.updateTitle(title)
        machine.updateMood(moodSelection)
        machine.addCharacter(charA)
        machine.addCharacter(charB)
        if thirdCharacterEnabled && !characterCName.isEmpty {
            let charC = DialogueCharacterRef(
                name: characterCName,
                voiceRegister: characterCVoice,
                sampleLines: [characterCSample1, characterCSample2, characterCSample3].filter { !$0.isEmpty },
                role: characterCRole
            )
            machine.addCharacter(charC)
        }
        machine.finishCharacterAuthoring()
    }
}

/// `dq.experiments.thirdCharacter` feature flag — defaults to `false`.
/// Mirrors `CastVoicingFeatureFlag` shape so flag toggling stays
/// uniform across DialogueQuest experiments.
public enum TriangleAuthoringFeatureFlag {
    public static let storageKey = "dq.experiments.thirdCharacter"

    public static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: storageKey)
    }

    public static func set(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: storageKey)
    }
}

#Preview {
    struct Harness: View {
        @State var machine = DialogueTreeMachine()
        var body: some View { CharacterAuthoringView(machine: $machine) }
    }
    return Harness()
}
