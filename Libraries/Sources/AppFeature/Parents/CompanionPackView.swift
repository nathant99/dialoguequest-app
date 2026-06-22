import SwiftUI
import SharedUI

/// "For Parents & Educators" surface — lists the bundled companion-pack PDFs
/// (cast poster, coloring sheets, parent letter) as tappable cards that
/// expose a `ShareLink` so the OS routes the file to Files / AirPrint /
/// AirDrop. PDFs live in the SPM `AppFeature` bundle under
/// `Resources/CompanionPack/` and are loaded via `Bundle.module`.
///
/// Source of truth + provenance: `Docs/HANDOFF_FROM_LABSMITH_COMPANION_PACK.md`.
struct CompanionPackView: View {
    private let entries: [CompanionPackEntry] = CompanionPackEntry.bundled

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                ForEach(entries) { entry in
                    CompanionPackCard(entry: entry)
                }
                footer
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(DialoguePalette.cream.opacity(0.6))
        .navigationTitle("For Parents & Educators")
        .accessibilityIdentifier("companionPack.root")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Print-friendly companion pack")
                .font(.title3.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)
            Text("Free downloads to print at home, share with classrooms, or send to grandparents. No tracking; no logins.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var footer: some View {
        Text("Spark & Anvil is a 501(c)(3) public charity. DialogueQuest stays free forever.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .padding(.top, 8)
    }
}

// MARK: - Card

private struct CompanionPackCard: View {
    let entry: CompanionPackEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Image(systemName: entry.systemImage)
                    .font(.title2)
                    .foregroundStyle(DialoguePalette.rust)
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.headline)
                        .foregroundStyle(DialoguePalette.inkBlue)
                    Text(entry.subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            if let url = entry.url {
                ShareLink(item: url) {
                    Label("Share, print, or save", systemImage: "square.and.arrow.up")
                        .font(.callout.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(DialoguePalette.rust)
                .accessibilityIdentifier("companionPack.share.\(entry.filename)")
            } else {
                Text("Unavailable in this build")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(DialoguePalette.rust.opacity(0.18), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(entry.title). \(entry.subtitle)")
    }
}

// MARK: - Entry

/// Catalog of bundled companion-pack PDFs. Each entry resolves its URL via
/// `Bundle.module` on first access — when a future asset wave adds the
/// optional `puzzle_sampler.pdf`, the catalog stays a one-liner edit here.
public struct CompanionPackEntry: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let filename: String
    public let systemImage: String

    public var url: URL? {
        Bundle.module.url(forResource: filename, withExtension: "pdf")
    }

    public init(
        id: String,
        title: String,
        subtitle: String,
        filename: String,
        systemImage: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.filename = filename
        self.systemImage = systemImage
    }

    /// Bundled catalog (3 PDFs as of `Resources/CompanionPack/companion_pack.json`).
    public static let bundled: [CompanionPackEntry] = [
        CompanionPackEntry(
            id: "cast_poster",
            title: "Cast poster",
            subtitle: "Sprig, Glance, Weigh, Brogue, Rest — Patter's writing-craft friends, on one printable page.",
            filename: "cast_poster",
            systemImage: "person.3.fill"
        ),
        CompanionPackEntry(
            id: "coloring",
            title: "Cast coloring sheets",
            subtitle: "Line-art portraits of the cast, ready to color while you talk dialogue craft.",
            filename: "coloring",
            systemImage: "paintbrush.fill"
        ),
        CompanionPackEntry(
            id: "parent_letter",
            title: "Parent & educator letter",
            subtitle: "A 1-page intro from Patter — what DialogueQuest teaches and why dialogue craft matters.",
            filename: "parent_letter",
            systemImage: "envelope.fill"
        ),
    ]
}

#Preview {
    NavigationStack { CompanionPackView() }
}
