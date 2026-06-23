import SwiftUI
import ForgeProgression
import SharedUI

/// Word Workshop adventure tab. The `DialogueQuestHubContribution`
/// Level-2 overlay ships in this target and is wired into AdventureHub
/// from the cross-app shell (see `Docs/HANDOFF_TO_HUB_HUBCONTRIBUTION_LEVEL_1.md`).
///
/// Within DialogueQuest, the Adventure tab progressively discloses the
/// Word Workshop entry behind a `ForgeProgressionManager` session gate:
/// kids see a friendly nudge during sessions 1-2; on session 3+ the
/// Workshop card unlocks and surfaces the cross-app destination cue.
struct AdventureTabView: View {
    /// Persisted session-day counter — calendar-aware (one bump per day).
    @AppStorage("dq.adventure.sessionCount") private var sessionCount: Int = 0
    @AppStorage("dq.adventure.lastSessionDate") private var lastSessionTimestamp: Double = 0

    /// Word Workshop unlocks after 3 distinct session-days. Matches the
    /// Phase 1 onboarding ladder so kids who've built a couple of trees
    /// (firstSession + earlySessions tiers) are the ones who see Adventure
    /// content first.
    private static let wordWoodsGate = ContentGate(
        id: "word-woods",
        requiredSessions: 3,
        displayName: "Word Workshop",
        unlockHint: "Write trees on 3 different days to open the Workshop."
    )

    /// Whether the Voice Crucible sheet is up.
    @State private var isCruciblePresented: Bool = false

    /// Reconstructed each render from the persisted counters so the
    /// gate evaluation always reflects current state.
    private var progressionManager: ForgeProgressionManager {
        var manager = ForgeProgressionManager(
            gates: [Self.wordWoodsGate],
            persistenceKey: "dq.adventure"
        )
        // Seed historical session-days. The manager is a value type; we
        // replay one `recordSession(date:)` per recorded day so the
        // internal counter matches what's been persisted via @AppStorage.
        if sessionCount > 0 {
            for offset in 0..<sessionCount {
                let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now) ?? .now
                _ = manager.recordSession(date: date)
            }
        }
        return manager
    }

    private var isUnlocked: Bool {
        progressionManager.isUnlocked(Self.wordWoodsGate.id)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: isUnlocked ? "tree.fill" : "tree")
                    .font(.system(size: 64))
                    .foregroundStyle(DialoguePalette.rust)
                    .frame(maxWidth: .infinity)

                Text("Word Workshop")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(DialoguePalette.inkBlue)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isUnlocked {
                    unlockedContent
                } else {
                    lockedContent
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Adventure")
            .background(DialoguePalette.cream.opacity(0.6))
            .task { recordSessionIfNeeded() }
            .sheet(isPresented: $isCruciblePresented) {
                VoiceCrucibleView()
            }
        }
    }

    @ViewBuilder
    private var unlockedContent: some View {
        Text("DialogueQuest's contribution to the cross-app AdventureHub. Tap a kit when the hub-side Level-1 tile is live.")
            .font(.callout)
            .foregroundStyle(.secondary)

        MentorBubbleView(
            message: "You opened the Workshop! Pick a kit to try a quick scene with the cast."
        )

        Button {
            isCruciblePresented = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "waveform.path.ecg")
                    .foregroundStyle(DialoguePalette.rust)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Voice Crucible")
                        .font(.headline)
                        .foregroundStyle(DialoguePalette.inkBlue)
                    Text("Pick a cast voice. Write one line in their register. See how close you got.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(DialoguePalette.rust)
            }
            .padding()
            .background(DialoguePalette.cream.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("crucible.entry")
        .accessibilityHint(Text("Open the Voice Crucible adventure mode."))
    }

    @ViewBuilder
    private var lockedContent: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .foregroundStyle(.secondary)
            Text(Self.wordWoodsGate.unlockHint)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Locked. Write dialogue trees on \(Self.wordWoodsGate.requiredSessions) different days to unlock.")

        ProgressView(
            value: Double(min(sessionCount, Self.wordWoodsGate.requiredSessions)),
            total: Double(Self.wordWoodsGate.requiredSessions)
        ) {
            Text("Day \(sessionCount) of \(Self.wordWoodsGate.requiredSessions)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .tint(DialoguePalette.rust)

        MentorBubbleView(
            message: "While the Workshop is being built, keep writing in the Write tab. Every day of writing brings the door closer."
        )
    }

    /// Bump the persisted session-day counter the first time the
    /// Adventure tab is opened today. Calendar-aware via the manager's
    /// `recordSession(date:)` same-day guard.
    private func recordSessionIfNeeded() {
        let now = Date.now
        let last = Date(timeIntervalSince1970: lastSessionTimestamp)
        if lastSessionTimestamp == 0 || !Calendar.current.isDate(last, inSameDayAs: now) {
            sessionCount += 1
            lastSessionTimestamp = now.timeIntervalSince1970
        }
    }
}

#Preview {
    AdventureTabView()
}
