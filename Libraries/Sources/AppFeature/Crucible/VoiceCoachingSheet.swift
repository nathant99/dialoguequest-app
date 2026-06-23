import SwiftUI
import Models
import Services
import SharedUI

/// Voice-acting coaching surface. The kid picks a cast member's sample
/// line, taps "Record", reads the line aloud, then sees how close the
/// reading matches the character's voice baseline.
///
/// **Wired-vs-scaffold posture**: this view ALWAYS renders. When
/// `VoiceActingCoachService.isWired` is true (Info.plist usage
/// descriptions present), the Record button is active and recording
/// flows through `VoiceActingCoachActiveSession`. When unwired, the view
/// surfaces a parent-handoff message explaining that microphone +
/// speech recognition need to be enabled for DialogueQuest first.
///
/// Reachable from `PerformanceBoothView` (cast picker → voice-acting
/// option). Could also be surfaced from `WriteTabView` directly per
/// future product decisions.
public struct VoiceCoachingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private let castID: String
    private let castDisplayName: String
    private let promptLine: String

    @State private var coachService = VoiceActingCoachService.shared
    @State private var activeSession: VoiceActingCoachActiveSession?
    @State private var currentPhase: VoiceActingCoachActiveSession.Phase = .idle
    @State private var lastScore: Double?
    @State private var lastBand: WritingEvaluator.VoiceBand?
    @State private var coachingMessage: String?
    @State private var pollingTask: Task<Void, Never>?

    public init(castID: String, castDisplayName: String, promptLine: String) {
        self.castID = castID
        self.castDisplayName = castDisplayName
        self.promptLine = promptLine
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    promptCard
                    recordSurface
                    if let coachingMessage {
                        coachingCard(message: coachingMessage)
                    }
                }
                .padding()
            }
            .background(DialoguePalette.cream.opacity(0.6))
            .navigationTitle("Voice coach")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        teardown()
                        dismiss()
                    }
                }
            }
            .onAppear { activeSession = coachService.makeActiveSession() }
            .onDisappear { teardown() }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sound like \(castDisplayName).")
                .font(.headline)
                .foregroundStyle(DialoguePalette.inkBlue)
            Text("Read the line aloud. The coach listens, then tells you how close your reading matches \(castDisplayName)'s voice.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Prompt card

    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(castDisplayName) says:")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(promptLine)
                .font(.title3)
                .foregroundStyle(DialoguePalette.inkBlue)
                .accessibilityLabel("Practice line: \(promptLine)")
        }
        .padding()
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Record surface

    @ViewBuilder
    private var recordSurface: some View {
        if !VoiceActingCoachService.isWired {
            scaffoldExplainerCard
        } else {
            wiredRecordCard
        }
    }

    private var scaffoldExplainerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Coach not yet enabled", systemImage: "mic.slash")
                .font(.headline)
                .foregroundStyle(DialoguePalette.rust)
            Text("To use the voice coach, a parent or guardian needs to enable microphone and speech recognition for DialogueQuest. Once they do, this surface activates automatically.")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text(coachService.availabilityDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var wiredRecordCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            phaseStatusRow
            recordButton
            if case .failed(let reason) = currentPhase {
                Text(reason)
                    .font(.caption)
                    .foregroundStyle(DialoguePalette.rust)
            }
        }
        .padding()
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var phaseStatusRow: some View {
        HStack(spacing: 10) {
            Image(systemName: phaseIconName)
                .font(.title3)
                .foregroundStyle(phaseTint)
            Text(phaseLabel)
                .font(.callout.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)
        }
    }

    private var recordButton: some View {
        Button {
            Task { await runRecordTap() }
        } label: {
            Label(buttonTitle, systemImage: buttonIcon)
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(DialoguePalette.rust)
        .disabled(!buttonEnabled)
        .accessibilityIdentifier("voiceCoach.recordButton")
    }

    @ViewBuilder
    private func coachingCard(message: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let lastBand {
                Label(bandLabel(for: lastBand), systemImage: bandIcon(for: lastBand))
                    .font(.headline)
                    .foregroundStyle(bandTint(for: lastBand))
            }
            Text(message)
                .font(.callout)
                .foregroundStyle(DialoguePalette.inkBlue)
            if let lastScore {
                Text("Voice match: \(Int(lastScore * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Phase-derived view-state

    private var phaseIconName: String {
        switch currentPhase {
        case .idle: return "mic"
        case .requesting: return "lock.rotation"
        case .authorized: return "checkmark.circle"
        case .recording: return "waveform"
        case .finalizing: return "hourglass"
        case .completed: return "checkmark.seal"
        case .failed: return "xmark.octagon"
        }
    }

    private var phaseTint: Color {
        switch currentPhase {
        case .failed: return DialoguePalette.rust
        case .recording: return DialoguePalette.rust
        case .completed: return .green
        default: return DialoguePalette.inkBlue
        }
    }

    private var phaseLabel: String {
        switch currentPhase {
        case .idle: return "Ready when you are."
        case .requesting: return "Asking for permission…"
        case .authorized: return "Microphone ready."
        case .recording: return "Listening…"
        case .finalizing: return "Scoring your reading…"
        case .completed: return "Got it."
        case .failed: return "Something went wrong."
        }
    }

    private var buttonTitle: String {
        switch currentPhase {
        case .idle: return "Allow microphone"
        case .requesting: return "Asking…"
        case .authorized, .completed, .failed: return "Record"
        case .recording: return "Stop"
        case .finalizing: return "Wait…"
        }
    }

    private var buttonIcon: String {
        switch currentPhase {
        case .recording: return "stop.circle.fill"
        default: return "mic.circle.fill"
        }
    }

    private var buttonEnabled: Bool {
        switch currentPhase {
        case .requesting, .finalizing: return false
        default: return true
        }
    }

    // MARK: - Band display helpers (kid-register; no engineering jargon)

    private func bandLabel(for band: WritingEvaluator.VoiceBand) -> String {
        switch band {
        case .strong: return "Spot on."
        case .acceptable: return "Close."
        case .drifting: return "Drifted."
        }
    }

    private func bandIcon(for band: WritingEvaluator.VoiceBand) -> String {
        switch band {
        case .strong: return "star.fill"
        case .acceptable: return "checkmark.circle"
        case .drifting: return "arrow.uturn.left.circle"
        }
    }

    private func bandTint(for band: WritingEvaluator.VoiceBand) -> Color {
        switch band {
        case .strong: return .green
        case .acceptable: return DialoguePalette.inkBlue
        case .drifting: return DialoguePalette.rust
        }
    }

    // MARK: - Side effects

    private func runRecordTap() async {
        guard let session = activeSession else { return }
        switch currentPhase {
        case .idle, .failed:
            currentPhase = await session.requestAuthorization()
            if currentPhase == .authorized {
                currentPhase = session.startRecording()
                startPolling(session: session)
            }
        case .authorized, .completed:
            currentPhase = session.startRecording()
            startPolling(session: session)
        case .recording:
            currentPhase = session.stopRecording()
        case .requesting, .finalizing:
            return
        }
    }

    private func startPolling(session: VoiceActingCoachActiveSession) {
        pollingTask?.cancel()
        pollingTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(150))
                let snapshot = session.phase
                if snapshot != currentPhase {
                    currentPhase = snapshot
                    if case .completed(let transcript) = snapshot {
                        scoreTranscript(transcript)
                        break
                    }
                    if case .failed = snapshot {
                        break
                    }
                }
            }
        }
    }

    private func scoreTranscript(_ transcript: String) {
        let baseline = promptLine
        let score = VoiceActingCoachService.scoreTranscript(transcript, against: baseline)
        let band = VoiceActingCoachService.band(forScore: score)
        lastScore = score
        lastBand = band
        coachingMessage = VoiceActingCoachService.coachingLine(forBand: band, characterName: castDisplayName)
    }

    private func teardown() {
        pollingTask?.cancel()
        pollingTask = nil
        activeSession?.cancel()
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
