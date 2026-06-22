import SwiftUI
import SharedUI

/// Plain-language privacy policy surface per `@Docs/FEATURE_PLAN.md` §
/// "Privacy policy — Plain-language policy accessible from Settings and
/// App Store listing". Phase 1 ships an in-app summary; future App Store
/// submission Phase 4 pairs this with the externally-hosted Spark & Anvil
/// site privacy page (gated via `ParentalGateChallenge` per the same
/// feature plan row).
///
/// Content rules per `.claude/rules/age-assurance.md` § "2026 FTC COPPA
/// Rule Amendments" + portfolio Tech Stack stance:
/// - No PII collection
/// - No third-party analytics SDKs (ForgeAnalytics is on-device only)
/// - No advertising; no in-app purchases
/// - SwiftData persistence is local-only — no cloud sync of child data
/// - Parental consent record expires after 12 months per FTC 2026
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                section(
                    title: "What we do",
                    body: "DialogueQuest is a dialogue-craft writing tool. Everything the kid writes — characters, dialogue trees, anthology entries — stays on this device."
                )
                section(
                    title: "What stays on the device",
                    body: "Dialogue trees, character profiles, anthology entries, mentor session context, badges, streak history, and parental-consent records all live in SwiftData + UserDefaults on this device only."
                )
                section(
                    title: "What never leaves the device",
                    body: "Nothing the kid writes is uploaded, synced to the cloud, or shared with any third party. There is no telemetry SDK, no advertising network, no analytics partner. On-device retention metrics + event counters use Apple's local storage and never leave the phone."
                )
                section(
                    title: "Parental consent",
                    body: "If a parent records consent in Settings, we save the date locally. Per the 2026 FTC COPPA amendment we ask for fresh consent every 12 months. Consent can be revoked at any time."
                )
                section(
                    title: "AI mentor",
                    body: "Patter — the writing mentor — runs entirely on the device using Apple's on-device language model (FoundationModels). The kid's dialogue text never leaves the device for AI analysis."
                )
                section(
                    title: "Pass-and-play mode",
                    body: "When two writers share the device (Write Together), each takes a turn behind a privacy curtain. The session lives in memory only — closing the app discards it. Nothing is sent over the network."
                )
                section(
                    title: "Crisis resources",
                    body: "The Settings → Need help? section lists the 988 Suicide & Crisis Lifeline, Childhelp, and Crisis Text Line. We provide phone + text contacts only; we never log or share what the kid taps."
                )
                section(
                    title: "App Store age rating",
                    body: "DialogueQuest is rated for ages 9+ per the 2026 App Store rating questionnaire. Apple's Declared Age Range API will gate access tier in a future release; the integration scaffold lives in Services/Privacy."
                )
                section(
                    title: "Questions?",
                    body: "Adults can contact Spark & Anvil via the studio website. We won't ask for the kid's name, email, or any other identifier."
                )
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Privacy")
        .background(DialoguePalette.cream.opacity(0.6))
    }

    @ViewBuilder
    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(DialoguePalette.inkBlue)
            Text(body)
                .font(.callout)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(body)")
    }
}

#Preview {
    NavigationStack { PrivacyPolicyView() }
}
