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
    @AppStorage(TriangleAuthoringFeatureFlag.storageKey) private var thirdCharacterEnabled: Bool = false
    @AppStorage(CastVoicingFeatureFlag.storageKey) private var castVoicingEnabled: Bool = false
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
            Section("Privacy") {
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    Label("Privacy policy", systemImage: "lock.shield.fill")
                }
                Text("Plain-language summary. Nothing the kid writes leaves this device.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                ageBandRow
            }
            Section {
                Toggle(isOn: $thirdCharacterEnabled) {
                    Label("Three-character scenes", systemImage: "person.3.fill")
                }
                .accessibilityIdentifier("labs.thirdCharacter.toggle")
                .accessibilityHint("Turn on triangle dialogues: stories with three characters. Default is two.")
                Toggle(isOn: $castVoicingEnabled) {
                    Label("Patter's writing friends", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .accessibilityIdentifier("labs.castVoicing.toggle")
                .accessibilityHint("Let Sprig, Glance, Weigh, Brogue, and Rest chime in alongside Patter.")
                Text("Labs features are early experiments. Turn them off any time.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Labs")
            } footer: {
                Text("For grown-ups: flip these on if your kid wants to try DialogueQuest's newer surfaces.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            #if DEBUG
            diagnosticsSection
            #endif
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
    private var ageBandRow: some View {
        // Read-only surface for the Declared Age Range API scaffold.
        // Stays at "not wired" until the user completes the Xcode GUI
        // entitlement + Info.plist key handoff. The text + icon are
        // safe to render unconditionally — DeclaredAgeRangeGate is a
        // pure-Swift status probe that NEVER invokes the FamilyControls
        // API until a future PR adds the opt-in request flow.
        let gate = DeclaredAgeRangeGate.shared
        VStack(alignment: .leading, spacing: 4) {
            Label(
                "Family Age Band",
                systemImage: DeclaredAgeRangeGate.isWired ? "person.2.fill" : "person.2.slash"
            )
            .foregroundStyle(DeclaredAgeRangeGate.isWired ? DialoguePalette.rust : .secondary)
            Text(gate.statusDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Family Age Band. \(gate.statusDescription)")
    }

    #if DEBUG
    /// Developer-only diagnostics surface. Compiles to nothing in
    /// release builds (the entire section is `#if DEBUG`-gated, the
    /// section binding is `#if DEBUG`-gated, and the consumed audit
    /// helper is reachable from any build). Surfaces the
    /// `CastIllustrationsCoverageAudit` report so a developer can
    /// confirm at a glance whether the shared registry populated
    /// correctly at cold-launch without writing a unit test.
    ///
    /// Copy stays in the kid / parent register stoplist by virtue of
    /// the audit's `summary` value already being scrubbed; the
    /// section label + footer copy are also reader-clean.
    @ViewBuilder
    private var diagnosticsSection: some View {
        Section {
            CastIllustrationsCoverageRow()
        } header: {
            Text("Diagnostics (debug)")
        } footer: {
            Text("Visible in development builds only. Not shipped to TestFlight or the App Store.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    #endif

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

/// Light parental-gate sheet backed by `Services.ParentalGateChallenge`.
/// Phase 1 uses a 6×6...9×9 multiplication challenge that a tween can't
/// shoulder-surf past; the full Family Controls flow lands once the
/// entitlement GUI handoff completes. The challenge logic itself lives
/// in `Services/Privacy/ParentalGateChallenge.swift` so external-link
/// affordances (privacy policy off-app links / donate / studio site) can
/// reuse the same UX consistently.
private struct ParentalConsentGateView: View {
    let onGranted: () -> Void
    let onCancel: () -> Void

    @State private var challenge = ParentalGateChallenge.random()
    @State private var typedAnswer: String = ""
    @State private var showError: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Parent or guardian check")
                .font(.title3.weight(.semibold))
            Text(challenge.prompt)
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
                    if challenge.accepts(typedAnswer) {
                        onGranted()
                    } else {
                        showError = true
                        challenge = ParentalGateChallenge.random()
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
}

#Preview {
    NavigationStack { SettingsView() }
}

#if DEBUG
/// Read-only diagnostics row that runs the
/// `CastIllustrationsCoverageAudit` against the shared registry on
/// appear + render. Shows the report `summary` line + count when
/// the audit is ready. Re-runs on tap so a developer can probe a
/// fresh populate state without leaving Settings.
///
/// Pure debug-only surface — wrapped in `#if DEBUG` at the
/// `SettingsView` call site AND on the type itself. Release builds
/// never see this code. The view does not write to UserDefaults +
/// does not fire analytics.
private struct CastIllustrationsCoverageRow: View {
    @State private var report: CastIllustrationsCoverageAudit.Report?
    @State private var isAuditing: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Cast illustrations", systemImage: "photo.on.rectangle.angled")
                .foregroundStyle(DialoguePalette.inkBlue)
            if let report {
                Text(report.summary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if !report.missingAssetIDs.isEmpty {
                    Text("Missing: " + report.missingAssetIDs.joined(separator: ", "))
                        .font(.caption.monospaced())
                        .foregroundStyle(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else if isAuditing {
                Text("Reading registry…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("Tap to run.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            Task { await runAudit() }
        }
        .task {
            await runAudit()
        }
    }

    private func runAudit() async {
        isAuditing = true
        defer { isAuditing = false }
        report = await CastIllustrationsCoverageAudit.auditShared()
    }
}
#endif
