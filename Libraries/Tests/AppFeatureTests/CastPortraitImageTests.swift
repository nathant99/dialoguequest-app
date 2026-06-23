import Testing
@testable import AppFeature

/// Closes `Docs/HANDOFF_FROM_HUB_CAST_PORTRAITS.md` adoption — proves
/// every LESSONS-layer slug resolves to a real bundle URL + the
/// CastVoicingChip avatar fallback path is reachable for unknown slugs.
@Suite("CastPortraitImage")
struct CastPortraitImageTests {

    @Test("All 5 LESSONS-layer slugs resolve to a bundle URL")
    func lessonsLayerSlugsResolve() {
        for slug in CastPortraitImage.lessonsLayerSlugs {
            let url = CastPortraitImage.url(forSlug: slug)
            #expect(url != nil, "expected portrait for \(slug)")
            #expect(url?.pathExtension == "webp")
        }
    }

    @Test("Unknown slug returns nil (avatar fallback path)")
    func unknownSlugReturnsNil() {
        // Empty resource name behavior is intentionally undefined by Bundle —
        // gate against typo'd cast IDs the chip might pass through.
        #expect(CastPortraitImage.url(forSlug: "not-a-cast-member") == nil)
        #expect(CastPortraitImage.url(forSlug: "unknown-slug") == nil)
    }

    @Test("WORLD/META archetype slugs deliberately not bundled per Pattern B")
    func worldMetaSlugsNotBundled() {
        // heralda / murmur / quip / vesperline / aria are cluster-shared
        // archetypes that ship only via the site /cast index, not the app
        // bundle. The chip falls back to the letter glyph for these.
        let worldMeta = ["heralda", "murmur", "quip", "vesperline", "aria"]
        for slug in worldMeta {
            #expect(CastPortraitImage.url(forSlug: slug) == nil,
                    "WORLD/META slug \(slug) should NOT have an app-bundled portrait")
        }
    }

    @Test("LESSONS-layer slugs match Resources/Cast/cast.json")
    func lessonsLayerSlugsCanonical() {
        // Canonical ordering matches hub registry; defends against silent
        // additions that bypass the cast.json manifest.
        #expect(CastPortraitImage.lessonsLayerSlugs == ["brogue", "glance", "rest", "sprig", "weigh"])
    }

    @Test("Book cover entries resolve via Bundle.module")
    func bookCoversBundled() {
        let entries = BookCoverEntry.bundled
        #expect(entries.count == 2)
        for entry in entries {
            #expect(entry.url != nil, "expected bundled cover for tier \(entry.tier)")
            #expect(entry.url?.pathExtension == "webp")
        }
        #expect(entries.map { $0.tier } == ["standard", "advanced"])
    }
}
