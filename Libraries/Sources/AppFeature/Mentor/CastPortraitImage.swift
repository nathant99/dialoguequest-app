import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Bundle-resolved cast portrait lookup. Portraits ship via the hub
/// `gen_cast_portraits.py` pipeline + `copy_cast_to_repos.sh` distribution
/// (per `Docs/HANDOFF_FROM_HUB_CAST_PORTRAITS.md`). Files live at
/// `Libraries/Sources/AppFeature/Resources/Cast/<slug>.webp` and resolve
/// via `Bundle.module` thanks to `.process("Resources/Cast")` in
/// `Libraries/Package.swift`.
///
/// Pattern B per `.claude/rules/distributed-narrative.md`: only the 5
/// LESSONS-layer cast members (brogue / glance / rest / sprig / weigh)
/// have shipped portraits in this repo — WORLD/META archetypes inherit
/// from cluster-shared gen and the hub `/cast/<app>` site index, not the
/// app bundle.
public enum CastPortraitImage {

    /// Bundle URL for the given cast slug, or `nil` when the slug doesn't
    /// have a shipped portrait. Idempotent + cheap; safe to call from any
    /// isolation context.
    public nonisolated static func url(forSlug slug: String) -> URL? {
        Bundle.module.url(forResource: slug, withExtension: "webp")
    }

    /// `Image` for the given cast slug, or a generic fallback symbol when
    /// the portrait isn't bundled. The fallback keeps the call-site simple
    /// (no `if let`-chain in views) while still surfacing the missing-asset
    /// state visually (the SF Symbol differs from any real portrait).
    @MainActor
    public static func image(forSlug slug: String) -> Image {
        guard let url = url(forSlug: slug) else {
            return Image(systemName: "person.crop.circle.fill")
        }
        #if canImport(UIKit)
        if let ui = UIImage(contentsOfFile: url.path) { return Image(uiImage: ui) }
        #elseif canImport(AppKit)
        if let ns = NSImage(contentsOf: url) { return Image(nsImage: ns) }
        #endif
        return Image(systemName: "person.crop.circle.fill")
    }

    /// LESSONS-layer slugs with shipped portraits — keeps the call-site
    /// from guessing which slugs are bundled. Matches `Resources/Cast/cast.json`.
    public nonisolated static let lessonsLayerSlugs: [String] = [
        "brogue", "glance", "rest", "sprig", "weigh"
    ]
}
