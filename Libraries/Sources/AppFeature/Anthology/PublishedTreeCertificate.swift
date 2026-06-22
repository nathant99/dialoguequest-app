import SwiftUI
import Models
import SharedUI

/// Share-worthy certificate for a published dialogue tree. Per
/// `@Docs/FEATURE_PLAN.md` § Delight & Polish — Share-worthy moments.
///
/// A SwiftUI-rendered card (~600 × 800 logical points) showing:
/// - Tree title
/// - Mood emoji + label
/// - Cast list
/// - Node count
/// - Published-date stamp
/// - Spark & Anvil studio attribution (matches ADR-025 chrome — no
///   PII, just "Made in DialogueQuest by a writer aged 9-14.")
///
/// Designed to render cleanly via `ImageRenderer` for PNG export +
/// ShareLink dispatch. Stays in the age-9-14 register stoplist per
/// `.claude/rules/distributed-narrative.md` § R-CHAPTER-REGISTER.
public struct PublishedTreeCertificate: View {
    public let tree: DialogueTree
    public let publishedAt: Date

    public init(tree: DialogueTree, publishedAt: Date = .now) {
        self.tree = tree
        self.publishedAt = publishedAt
    }

    public var body: some View {
        VStack(spacing: 24) {
            header
            Divider()
                .frame(maxWidth: 240)
            castLine
            statsLine
            Spacer(minLength: 16)
            footer
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 36)
        .frame(width: 600, height: 800)
        .background(
            LinearGradient(
                colors: [
                    DialoguePalette.cream,
                    DialoguePalette.warmGold.opacity(0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(DialoguePalette.rust.opacity(0.5), lineWidth: 4)
                .padding(12)
        )
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(moodEmoji)
                .font(.system(size: 64))
                .accessibilityHidden(true)
            Text(displayTitle)
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(DialoguePalette.inkBlue)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            if let moodLabel {
                Text(moodLabel)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(DialoguePalette.rust)
            }
        }
    }

    private var castLine: some View {
        VStack(spacing: 4) {
            Text("Featuring")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DialoguePalette.rust)
                .textCase(.uppercase)
                .tracking(2)
            Text(castNames)
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundStyle(DialoguePalette.inkBlue)
                .multilineTextAlignment(.center)
        }
    }

    private var statsLine: some View {
        HStack(spacing: 32) {
            stat(label: "Lines", value: "\(tree.nodes.count)")
            stat(label: "Cast", value: "\(tree.characters.count)")
            stat(label: "Branches", value: "\(branchPointCount)")
        }
    }

    private func stat(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(DialoguePalette.rust)
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1.5)
        }
    }

    private var footer: some View {
        VStack(spacing: 6) {
            Text("Published \(publishedAt.formatted(date: .long, time: .omitted))")
                .font(.footnote)
                .foregroundStyle(DialoguePalette.inkBlue.opacity(0.7))
            Text("Made in DialogueQuest. Every line by a writer aged 9–14.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Derived

    private var displayTitle: String {
        tree.title.isEmpty ? "An untitled conversation" : tree.title
    }

    private var moodLabel: String? {
        tree.mood?.displayName
    }

    private var moodEmoji: String {
        switch tree.mood {
        case .warmReunion?:       return "🤝"
        case .quietConflict?:     return "🌪️"
        case .playfulRivalry?:    return "🎯"
        case .awkwardSilence?:    return "🤐"
        case .openingCuriosity?:  return "🔎"
        case nil:                 return "📜"
        }
    }

    private var castNames: String {
        let names = tree.characters.map(\.name)
        switch names.count {
        case 0: return "no cast set"
        case 1: return names[0]
        case 2: return "\(names[0]) and \(names[1])"
        default:
            let head = names.dropLast().joined(separator: ", ")
            return "\(head), and \(names.last ?? "")"
        }
    }

    private var branchPointCount: Int {
        tree.nodes.reduce(0) { running, node in
            running + (node.children.count >= 2 ? 1 : 0)
        }
    }
}

/// Sheet host for `PublishedTreeCertificate`. Renders a preview at
/// scaled-to-fit size + offers a ShareLink that exports the
/// certificate as a PNG via `ImageRenderer`.
struct CertificateSheet: View {
    let tree: DialogueTree
    let publishedAt: Date
    let onClose: () -> Void

    @State private var renderedImage: Image?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button("Close") { onClose() }
                    .accessibilityHint("Dismiss the certificate.")
            }
            .padding(.horizontal)

            ScrollView {
                PublishedTreeCertificate(tree: tree, publishedAt: publishedAt)
                    .scaleEffect(0.55, anchor: .top)
                    .frame(width: 600 * 0.55, height: 800 * 0.55)
                    .padding(.bottom)
            }
            .accessibilityHidden(true)

            if let image = renderedImage {
                ShareLink(
                    item: image,
                    preview: SharePreview(
                        tree.title.isEmpty ? "Dialogue certificate" : tree.title,
                        image: image
                    )
                ) {
                    Label("Share certificate", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(DialoguePalette.rust)
                .accessibilityHint("Export the certificate as an image via AirDrop, Files, Photos, or Mail.")
                .padding(.horizontal)
            } else {
                ProgressView()
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .task {
            await renderCertificate()
        }
        .presentationDetents([.large])
    }

    @MainActor
    private func renderCertificate() async {
        let renderer = ImageRenderer(
            content: PublishedTreeCertificate(tree: tree, publishedAt: publishedAt)
        )
        // @3x covers Retina + photo-style exports without ballooning the
        // PNG past ~2-3 MB for the canonical 600×800 logical canvas.
        renderer.scale = 3
        #if canImport(UIKit)
        if let ui = renderer.uiImage {
            renderedImage = Image(uiImage: ui)
        }
        #elseif canImport(AppKit)
        if let ns = renderer.nsImage {
            renderedImage = Image(nsImage: ns)
        }
        #endif
    }
}
