import SwiftUI
import SharedUI
#if canImport(UIKit)
import UIKit
#endif

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
                BookCoverShelf()
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

    /// Bundled catalog. 3 PDFs ship today; the 4th (`curating_together`)
    /// lands once hub generates the asset per
    /// `Docs/HANDOFF_TO_HUB_CURATING_TOGETHER_PDF.md`. When the PDF
    /// arrives, uncomment the reserved entry below — `Bundle.module`
    /// resolution + the `companion_pack.json` manifest update are
    /// hub-owned.
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
        // RESERVED — pending hub asset gen per
        // `Docs/HANDOFF_TO_HUB_CURATING_TOGETHER_PDF.md`. Uncomment when
        // `curating_together.pdf` lands in `Resources/CompanionPack/`.
        // CompanionPackEntry(
        //     id: "curating_together",
        //     title: "Curating Together",
        //     subtitle: "How to talk with your kid about the new anthology curation surface — and the five themed collections.",
        //     filename: "curating_together",
        //     systemImage: "books.vertical.fill"
        // ),
    ]
}

// MARK: - Book covers

/// Read-only shelf surfacing the dual-tier chapter-book covers shipped by
/// hub per `Docs/HANDOFF_FROM_HUB_BOOK_COVERS.md`. The PDFs themselves are
/// hosted on spark-and-anvil.com — the bundle ships the artwork for an
/// in-app preview. Covers resolve via `Bundle.module` thanks to
/// `.process("Resources/CustomArt")` in `Libraries/Package.swift`.
private struct BookCoverShelf: View {
    var body: some View {
        if entries.isEmpty { EmptyView() } else {
            VStack(alignment: .leading, spacing: 10) {
                Text("Read the chapter book")
                    .font(.headline)
                    .foregroundStyle(DialoguePalette.inkBlue)
                Text("Patter's writing-craft friends each get a chapter — printable for bedtime, lap-time, or classroom share.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    ForEach(entries, id: \.tier) { entry in
                        BookCoverCard(entry: entry)
                    }
                }
            }
            .padding(.top, 4)
            .accessibilityElement(children: .contain)
        }
    }

    private var entries: [BookCoverEntry] { BookCoverEntry.bundled }
}

private struct BookCoverCard: View {
    let entry: BookCoverEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            coverImage
                .aspectRatio(0.75, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DialoguePalette.rust.opacity(0.18), lineWidth: 1)
                )
            Text(entry.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)
            Text(entry.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(DialoguePalette.rust.opacity(0.18), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.title). \(entry.subtitle)")
        .accessibilityIdentifier("companionPack.book.\(entry.tier)")
    }

    @ViewBuilder
    private var coverImage: some View {
        if let url = entry.url {
            BookCoverImage(url: url)
                .accessibilityHidden(true)
        } else {
            Rectangle()
                .fill(DialoguePalette.warmGold.opacity(0.35))
                .overlay(
                    Image(systemName: "book.closed.fill")
                        .font(.title2)
                        .foregroundStyle(DialoguePalette.rust)
                )
        }
    }
}

private struct BookCoverImage: View {
    let url: URL

    var body: some View {
        #if canImport(UIKit)
        if let ui = UIImage(contentsOfFile: url.path) {
            Image(uiImage: ui)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            placeholder
        }
        #else
        placeholder
        #endif
    }

    private var placeholder: some View {
        Rectangle()
            .fill(DialoguePalette.warmGold.opacity(0.35))
            .overlay(
                Image(systemName: "book.closed.fill")
                    .font(.title2)
                    .foregroundStyle(DialoguePalette.rust)
            )
    }
}

/// Catalog of bundled chapter-book covers. The PDFs live on
/// spark-and-anvil.com (`/books/dialoguequest-book.pdf` for Tier-1
/// Standard, `/books/advanced/dialoguequest-book.pdf` for Tier-2 Advanced).
public struct BookCoverEntry: Equatable {
    public let tier: String              // "standard" | "advanced"
    public let title: String
    public let subtitle: String
    public let filename: String          // bundle filename minus extension

    public var url: URL? {
        Bundle.module.url(forResource: filename, withExtension: "webp")
    }

    public init(tier: String, title: String, subtitle: String, filename: String) {
        self.tier = tier
        self.title = title
        self.subtitle = subtitle
        self.filename = filename
    }

    public static let bundled: [BookCoverEntry] = [
        BookCoverEntry(
            tier: "standard",
            title: "Standard edition",
            subtitle: "Ages 9–12 — the read-aloud-friendly cut.",
            filename: "cover_book_standard"
        ),
        BookCoverEntry(
            tier: "advanced",
            title: "Advanced edition",
            subtitle: "Ages 11–14 — denser register for older readers.",
            filename: "cover_book_advanced"
        ),
    ]
}

#Preview {
    NavigationStack { CompanionPackView() }
}
