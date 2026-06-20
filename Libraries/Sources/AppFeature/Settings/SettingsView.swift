import SwiftUI
import SharedUI

/// Phase 1 Settings — minimal first pass. Parental controls / consent
/// surface lands in a follow-up handoff per the COPPA-2026 phase plan.
struct SettingsView: View {
    @AppStorage("dq.dailySessionMinutesLimit") private var dailySessionMinutes: Int = 30
    @AppStorage("dq.parentalGateUnlocked") private var parentalGateUnlocked: Bool = false

    var body: some View {
        Form {
            Section("Daily session") {
                Stepper("Daily limit: \(dailySessionMinutes) min", value: $dailySessionMinutes, in: 10...60, step: 5)
                Text("DialogueQuest gently ends the session after this many minutes.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("Parental controls") {
                Toggle("Parent / guardian unlocked", isOn: $parentalGateUnlocked)
                    .disabled(true)
                Text("Parental gate flow lands in the next session. For now, no settings require parental authorization.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("Phase 1")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Built with")
                    Spacer()
                    Text("Patter, somewhere quiet")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(DialoguePalette.cream.opacity(0.6))
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
