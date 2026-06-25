import Foundation
import ForgeIllustrations

/// Canonical `ForgeIllustrations.IllustrationRegistry` consumer for
/// DialogueQuest's bundled illustration assets — the 5 LESSONS-layer
/// cast portraits (per `Docs/HANDOFF_FROM_HUB_CAST_PORTRAITS.md`) plus
/// the 2 anthology book covers (per `Docs/HANDOFF_FROM_HUB_BOOK_COVERS.md`).
///
/// **Why the canonical seam matters**: the hub-shipped illustrations
/// pipeline guarantees every asset has an alt-text + accessibility
/// metadata + tier classification (`R-CAST-PORTRAIT-SLUG` +
/// `R-PATH-B-PROMPT-PARITY`). Registering through `IllustrationRegistry`
/// lets future surfaces (a future Patter portrait sheet; a future
/// cast-coverage audit) query the registry for accessibility metadata
/// without re-deriving it from the file system. The file-loading path
/// (`Bundle.module.url(forResource:withExtension:)`) stays unchanged
/// in `CastPortraitImage` — the registry is metadata, not file I/O.
///
/// **Population shape**: 7 assets registered on first access — 5 cast
/// portraits + 2 book covers. Cast portraits are `.mascot` category
/// (matches the cast-IS-curriculum framing per
/// `.claude/rules/distributed-narrative.md`); book covers are `.hero`.
/// Both use `.raster` tier (webp files; no Lottie / SVG / AI gen).
/// Alt-text is keyed to the cast member's curricular primitive
/// (voice consistency / subtext / etc.).
///
/// **Idempotent populate**: `populate()` calls `clear()` first so
/// repeat populates (test isolation; future hot-reload path) don't
/// trip the registry's duplicate-ID guard.
public enum CastIllustrationsRegistry {
    /// Shared `IllustrationRegistry` instance for DialogueQuest. App
    /// launch (`RootView.task`) fires `populateShared()` exactly once
    /// per cold-launch so future surfaces (Patter portrait sheet,
    /// cast-coverage audit, accessibility-metadata query) hit a single
    /// populated registry rather than re-deriving from disk.
    ///
    /// `nonisolated static let` is required so consumers in nonisolated
    /// contexts (value-type machines, test fixtures, the future audit
    /// surface) can grab the reference without a MainActor hop.
    /// Constructing the underlying actor is cheap and side-effect-free.
    public nonisolated static let shared: IllustrationRegistry = IllustrationRegistry()

    /// Canonical IDs for the 5 LESSONS-layer cast portraits.
    public nonisolated static let castPortraitIDs: [String] = [
        "cast.brogue.portrait",
        "cast.glance.portrait",
        "cast.rest.portrait",
        "cast.sprig.portrait",
        "cast.weigh.portrait"
    ]

    /// Canonical IDs for the 2 anthology book covers.
    public nonisolated static let bookCoverIDs: [String] = [
        "anthology.cover.standard",
        "anthology.cover.advanced"
    ]

    /// Total registered asset count when `populate()` completes
    /// successfully. Surfaced for tests + future audit surfaces.
    public nonisolated static let expectedAssetCount: Int =
        castPortraitIDs.count + bookCoverIDs.count

    /// Build the canonical asset list. Pure value-type computation;
    /// safe to call from any isolation context. Each asset carries
    /// non-empty alt-text + raster tier + the file basename in
    /// `assetName` (matching the on-disk `<slug>.webp` convention).
    public nonisolated static func canonicalAssets() -> [IllustrationAsset] {
        let castEntries: [(slug: String, name: String, altText: String)] = [
            ("brogue", "Brogue", "Brogue — voice consistency mentor; the same character sounds the same on every line."),
            ("glance", "Glance", "Glance — subtext mentor; the line says one thing and means two."),
            ("rest",   "Rest",   "Rest — rhythm and silence mentor; the pause between lines is also a line."),
            ("sprig",  "Sprig",  "Sprig — branch meaningfulness mentor; choices that actually re-route the story."),
            ("weigh",  "Weigh",  "Weigh — tag balance mentor; the rhythm of attributions and action beats.")
        ]
        var assets: [IllustrationAsset] = castEntries.map { entry in
            IllustrationAsset(
                id: "cast.\(entry.slug).portrait",
                assetName: entry.slug,
                tier: .raster,
                accessibility: IllustrationAccessibility(
                    altText: entry.altText,
                    isDecorative: false,
                    respectsReducedMotion: true
                ),
                tintRole: nil,
                preferredAspect: 1.0,
                category: .mascot
            )
        }
        assets.append(
            IllustrationAsset(
                id: "anthology.cover.standard",
                assetName: "cover_book_standard",
                tier: .raster,
                accessibility: IllustrationAccessibility(
                    altText: "DialogueQuest anthology cover — standard edition for ages 9 through 12.",
                    isDecorative: false,
                    respectsReducedMotion: true
                ),
                tintRole: nil,
                preferredAspect: 0.75,
                category: .hero
            )
        )
        assets.append(
            IllustrationAsset(
                id: "anthology.cover.advanced",
                assetName: "cover_book_advanced",
                tier: .raster,
                accessibility: IllustrationAccessibility(
                    altText: "DialogueQuest anthology cover — advanced edition for ages 11 through 14.",
                    isDecorative: false,
                    respectsReducedMotion: true
                ),
                tintRole: nil,
                preferredAspect: 0.75,
                category: .hero
            )
        )
        return assets
    }

    /// Populate the given registry with the 7 canonical assets.
    /// Clears the registry first so repeat populates (test isolation;
    /// future hot-reload path) don't trip the duplicate-ID guard.
    /// Throws the underlying `IllustrationError` if registration fails.
    public static func populate(_ registry: IllustrationRegistry) async throws {
        await registry.clear()
        try await registry.register(canonicalAssets())
    }

    /// Populate the shared registry. Convenience wrapper called from
    /// `RootView.task` so app-launch wiring stays a single-liner.
    /// Idempotent because `populate(_:)` clears first.
    public static func populateShared() async throws {
        try await populate(shared)
    }
}
