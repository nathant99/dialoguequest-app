import SwiftUI
import AIMentor
import SharedUI

/// Voice Crucible adventure-mode surface. The kid picks a LESSONS-layer
/// cast member (Brogue / Glance / Rest / Sprig / Weigh), writes one line
/// targeting that character's voice register, and sees a Jaccard voice-
/// match score + a register-clean coaching line keyed to the cast and
/// band (drifting / on-register / locked).
///
/// Feature-plan provenance: Phase 2 row 131
/// "Add ForgeAdventure mode: Voice Crucible (target voice + write a line
/// in their register)". The hub Level-1 JSON tile that wires this into
/// AdventureHub itself is filed at
/// `Docs/HANDOFF_TO_HUB_HUBCONTRIBUTION_LEVEL_1.md`; until that ships,
/// the Crucible is reachable from `AdventureTabView`'s unlocked content.
public struct VoiceCrucibleView: View {
    @State private var machine = VoiceCrucibleMachine()
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dismiss) private var dismiss

    /// Cast slugs available as Voice Crucible targets. LESSONS-layer
    /// only — WORLD / META are demonstration surfaces, not authoring
    /// targets (per `CastVoiceRegistry` shape).
    private static let targetCastIDs: [String] = ["brogue", "glance", "rest", "sprig", "weigh"]

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    switch machine.stage {
                    case .selectingCast:
                        castPicker
                    case .writing(let castID):
                        writingSurface(targetCastID: castID)
                    case .scored(let castID, let score):
                        scoredSurface(targetCastID: castID, score: score)
                    }
                }
                .padding()
            }
            .background(DialoguePalette.cream.opacity(0.6))
            .navigationTitle("Voice Crucible")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pick a voice. Write one line in it.")
                .font(.headline)
                .foregroundStyle(DialoguePalette.inkBlue)
            Text("Each voice teaches a different part of dialogue craft. Try one. Patter will listen.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Cast picker

    private var castPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Self.targetCastIDs, id: \.self) { castID in
                castCard(castID: castID)
            }
        }
    }

    private func castCard(castID: String) -> some View {
        let display = CastVoiceRegistry.displayName(for: castID) ?? castID.capitalized
        let primitive = CastVoiceRegistry.lessonsLayerPrimitive(for: castID) ?? ""
        return Button {
            machine.selectCast(id: castID)
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(display)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(DialoguePalette.inkBlue)
                    Text(primitive)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(DialoguePalette.rust)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(display). \(primitive)")
        .accessibilityHint("Pick this voice to write a line in their register.")
    }

    // MARK: - Writing surface

    private func writingSurface(targetCastID: String) -> some View {
        let display = CastVoiceRegistry.displayName(for: targetCastID) ?? targetCastID.capitalized
        let primitive = CastVoiceRegistry.lessonsLayerPrimitive(for: targetCastID) ?? ""
        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Target voice: \(display)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DialoguePalette.rust)
                Text(primitive)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 4)

            MentorBubbleView(
                message: "Write one line in \(display)'s voice. Borrow their signature words, their rhythm, their register."
            )

            TextEditor(text: $machine.draft)
                .frame(minHeight: 120)
                .padding(8)
                .background(panelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .accessibilityLabel("Your line")
                .accessibilityHint("Type one line of dialogue in \(display)'s voice.")

            HStack {
                Button("Pick a different voice") {
                    machine.reselectCast()
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Submit") {
                    machine.submit()
                }
                .buttonStyle(.borderedProminent)
                .tint(DialoguePalette.rust)
                .disabled(machine.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityHint(
                    machine.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? Text("Disabled. Type at least one word to submit.")
                    : Text("Score this line against \(display)'s voice.")
                )
            }
        }
    }

    // MARK: - Scored surface

    private func scoredSurface(targetCastID: String, score: Double) -> some View {
        let display = CastVoiceRegistry.displayName(for: targetCastID) ?? targetCastID.capitalized
        let band = VoiceCrucibleMachine.VoiceBand(score: score)
        let coaching = VoiceCrucibleMachine.coachingLine(targetCastID: targetCastID, band: band)
        let scorePercent = Int((score * 100).rounded())
        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Voice-match: \(scorePercent)%")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(scoreTint(band: band))
                ProgressView(value: score)
                    .tint(scoreTint(band: band))
                Text(bandHeadline(band: band, display: display))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 4)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "Voice match \(scorePercent) percent. \(bandHeadline(band: band, display: display))"
            )

            VStack(alignment: .leading, spacing: 4) {
                Text("Your line")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(machine.draft)
                    .font(.body)
                    .foregroundStyle(DialoguePalette.inkBlue)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(panelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            MentorBubbleView(message: coaching)

            HStack {
                Button("Pick a different voice") {
                    machine.reselectCast()
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Try again") {
                    machine.retryWithSameCast()
                }
                .buttonStyle(.borderedProminent)
                .tint(DialoguePalette.rust)
                .accessibilityHint(Text("Write another line for \(display)."))
            }
        }
    }

    private func bandHeadline(band: VoiceCrucibleMachine.VoiceBand, display: String) -> String {
        switch band {
        case .drifting:
            return "\(display)'s voice is still finding you. Try again."
        case .onRegister:
            return "\(display)'s voice is close. Keep going."
        case .locked:
            return "\(display)'s voice is locked in."
        }
    }

    private func scoreTint(band: VoiceCrucibleMachine.VoiceBand) -> Color {
        switch band {
        case .drifting:   return DialoguePalette.rust
        case .onRegister: return DialoguePalette.warmGold
        case .locked:     return DialoguePalette.inkBlue
        }
    }

    @ViewBuilder
    private var panelBackground: some View {
        if reduceTransparency {
            DialoguePalette.cream
        } else {
            Color.clear.background(.thinMaterial)
        }
    }
}

#Preview {
    VoiceCrucibleView()
}
