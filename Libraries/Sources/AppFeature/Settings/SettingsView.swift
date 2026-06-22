import SwiftUI
import Services
import SharedUI

/// Phase 1 Settings — minimal first pass. COPPA-2026 parental consent
/// scaffold + crisis-resources surface land here; full Family Controls
/// + Declared Age Range API wiring needs the Info.plist + entitlements
/// GUI edits per `@Docs/HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md`.
struct SettingsView: View {
    @AppStorage("dq.dailySessionMinutesLimit") private var dailySessionMinutes: Int = 30
    @AppStorage("dq.weeklySummaryOptIn") private var weeklySummaryOptIn: Bool = false
    @State private var consentService = ParentalConsentService.shared
    @State private var showConsentGate: Bool = false

    var body: some View {
        Form {
            Section("Daily session") {
                Stepper("Daily limit: \(dailySessionMinutes) min", value: $dailySessionMinutes, in: 10...60, step: 5)
                Text("DialogueQuest gently ends the session after this many minutes.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("Parental controls") {
                NavigationLink {
                    ParentProgressDashboardView()
                } label: {
                    Label("Parent progress dashboard", systemImage: "chart.bar.doc.horizontal")
                }
                NavigationLink {
                    CompanionPackView()
                } label: {
                    Label("For parents & educators", systemImage: "doc.richtext.fill")
                }
                Toggle(isOn: $weeklySummaryOptIn) {
                    Label("Weekly summary", systemImage: "calendar")
                }
                Text("When on, DialogueQuest will surface a weekly summary on the dashboard. Delivery is in-app only — no email or notifications.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                consentStatusRow
                if consentService.hasValidConsent {
                    Button("Revoke parental consent", role: .destructive) {
                        consentService.revoke()
                    }
                } else {
                    Button("Record parental consent") {
                        showConsentGate = true
                    }
                }
            }
            Section("Need help?") {
                NavigationLink {
                    CrisisResourcesView()
                } label: {
                    Label("Crisis resources", systemImage: "lifepreserver.fill")
                }
                Text("Open the crisis-resources list any time — 988, Childhelp, Crisis Text Line.")
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
        .sheet(isPresented: $showConsentGate) {
            ParentalConsentGateView(
                onGranted: {
                    consentService.grant()
                    showConsentGate = false
                },
                onCancel: { showConsentGate = false }
            )
            .presentationDetents([.medium])
        }
    }

    @ViewBuilder
    private var consentStatusRow: some View {
        if consentService.hasValidConsent, let granted = consentService.grantedAt {
            VStack(alignment: .leading, spacing: 4) {
                Label("Parental consent on file", systemImage: "checkmark.shield.fill")
                    .foregroundStyle(DialoguePalette.rust)
                Text("Granted \(granted.formatted(date: .abbreviated, time: .omitted)).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if let days = consentService.daysUntilReconsent {
                    Text("Re-consent in \(days) day\(days == 1 ? "" : "s") per the 2026 FTC COPPA rule.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } else if consentService.isExpired {
            Label("Parental consent expired", systemImage: "exclamationmark.shield.fill")
                .foregroundStyle(.orange)
        } else {
            Label("No parental consent recorded", systemImage: "shield")
                .foregroundStyle(.secondary)
        }
    }
}

/// Light parental-gate sheet. Phase 1 ships a math challenge that the
/// kid can't shoulder-surf past; the full Family Controls flow lands
/// once the entitlement GUI handoff completes.
private struct ParentalConsentGateView: View {
    let onGranted: () -> Void
    let onCancel: () -> Void

    @State private var challenge = MathChallenge.random()
    @State private var typedAnswer: String = ""
    @State private var showError: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Parent or guardian check")
                .font(.title3.weight(.semibold))
            Text("What's \(challenge.a) × \(challenge.b)?")
                .font(.title2.monospacedDigit())
                .foregroundStyle(DialoguePalette.inkBlue)
            TextField("Answer", text: $typedAnswer)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 200)
            if showError {
                Text("That's not quite right — try the next challenge.")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            HStack {
                Button("Cancel", role: .cancel, action: onCancel)
                Spacer()
                Button("Confirm") {
                    if Int(typedAnswer) == challenge.expected {
                        onGranted()
                    } else {
                        showError = true
                        challenge = MathChallenge.random()
                        typedAnswer = ""
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(DialoguePalette.rust)
                .disabled(typedAnswer.isEmpty)
            }
        }
        .padding()
    }

    private struct MathChallenge {
        let a: Int
        let b: Int
        var expected: Int { a * b }
        static func random() -> MathChallenge {
            MathChallenge(a: Int.random(in: 6...9), b: Int.random(in: 6...9))
        }
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
