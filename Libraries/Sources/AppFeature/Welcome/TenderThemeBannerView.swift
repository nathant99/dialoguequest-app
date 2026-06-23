import SwiftUI
import SharedUI
import Services

/// Soft, SAMHSA-TIP-57-register banner surfaced by `WriteTabView` when
/// `TraumaAxisAdvisoryService.inspect(line:mood:)` returns a non-nil
/// advisory band. Closes the Phase Accessibility & Trauma-Informed Polish
/// checkbox in `Docs/FEATURE_PLAN.md`.
///
/// **Posture (load-bearing)**: ADVISORY-ONLY. The banner NEVER blocks the
/// kid's draft, NEVER rewrites their line, NEVER grades content. It validates
/// the weight + invites a pause + surfaces `CrisisResourcesView` reachable
/// in one tap.
///
/// Reduce-Motion-aware: the host gates the `.transition` per
/// `.claude/rules/swiftui.md`. Reduce-Transparency-aware: background flips
/// from `.thinMaterial` to a solid `DialoguePalette.cream` per portfolio
/// Liquid Glass policy.
struct TenderThemeBannerView: View {
    let advisory: TraumaAxisAdvisoryService.Advisory
    let onOpenResources: () -> Void
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: leadIcon)
                    .imageScale(.large)
                    .foregroundStyle(DialoguePalette.rust)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(advisory.bannerTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(DialoguePalette.inkBlue)
                    Text(advisory.bannerBody)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 4)
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(.secondary)
                        .padding(8)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dismiss banner")
            }
            Button(action: onOpenResources) {
                Label("Open crisis resources", systemImage: "heart.text.square.fill")
                    .font(.footnote.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(DialoguePalette.rust)
            .accessibilityHint("Show 988, Childhelp, and Crisis Text Line.")
        }
        .padding(14)
        .background(bannerBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(DialoguePalette.rust.opacity(0.25), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(advisory.bannerTitle). \(advisory.bannerBody)")
        .accessibilityIdentifier("tenderTheme.banner.\(advisoryID)")
    }

    private var leadIcon: String {
        switch advisory {
        case .crisisCue:   return "heart.text.square.fill"
        case .tenderTheme: return "wind"
        }
    }

    private var advisoryID: String {
        switch advisory {
        case .crisisCue:   return "crisisCue"
        case .tenderTheme: return "tenderTheme"
        }
    }

    @ViewBuilder
    private var bannerBackground: some View {
        if reduceTransparency {
            DialoguePalette.cream
        } else {
            Color.clear.background(.thinMaterial)
        }
    }
}
