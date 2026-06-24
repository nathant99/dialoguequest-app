import Foundation
import Testing
import ForgeIllustrations
@testable import AppFeature

@Suite("CastIllustrationsRegistry")
struct CastIllustrationsRegistryTests {

    @Test("expected asset count contract — 5 cast + 2 covers = 7")
    func expectedAssetCountContract() {
        #expect(CastIllustrationsRegistry.expectedAssetCount == 7)
        #expect(CastIllustrationsRegistry.castPortraitIDs.count == 5)
        #expect(CastIllustrationsRegistry.bookCoverIDs.count == 2)
    }

    @Test("cast portrait IDs follow the cast.<slug>.portrait convention")
    func castPortraitIDConvention() {
        let expected: Set<String> = [
            "cast.brogue.portrait",
            "cast.glance.portrait",
            "cast.rest.portrait",
            "cast.sprig.portrait",
            "cast.weigh.portrait"
        ]
        #expect(Set(CastIllustrationsRegistry.castPortraitIDs) == expected)
    }

    @Test("book cover IDs follow the anthology.cover.<tier> convention")
    func bookCoverIDConvention() {
        let expected: Set<String> = [
            "anthology.cover.standard",
            "anthology.cover.advanced"
        ]
        #expect(Set(CastIllustrationsRegistry.bookCoverIDs) == expected)
    }

    @Test("canonicalAssets emits exactly 7 entries")
    func canonicalAssetCount() {
        let assets = CastIllustrationsRegistry.canonicalAssets()
        #expect(assets.count == 7)
    }

    @Test("every canonical asset has non-empty alt-text")
    func canonicalAssetsAltText() {
        for asset in CastIllustrationsRegistry.canonicalAssets() {
            #expect(asset.accessibility.altText.isEmpty == false, "asset \(asset.id) missing alt-text")
            #expect(asset.accessibility.isDecorative == false, "asset \(asset.id) wrongly marked decorative")
        }
    }

    @Test("cast portrait assets are .mascot category; covers are .hero")
    func categoryDiscipline() {
        let assets = CastIllustrationsRegistry.canonicalAssets()
        for asset in assets {
            if asset.id.hasPrefix("cast.") {
                #expect(asset.category == .mascot, "\(asset.id) should be .mascot")
            } else if asset.id.hasPrefix("anthology.cover.") {
                #expect(asset.category == .hero, "\(asset.id) should be .hero")
            } else {
                Issue.record("Unexpected asset id: \(asset.id)")
            }
        }
    }

    @Test("every asset uses .raster tier (webp on disk)")
    func rasterTierDiscipline() {
        for asset in CastIllustrationsRegistry.canonicalAssets() {
            #expect(asset.tier == .raster, "asset \(asset.id) should be .raster tier")
        }
    }

    @Test("assetName matches the on-disk file basename convention")
    func assetNameMatchesBundle() {
        let assets = CastIllustrationsRegistry.canonicalAssets()
        // 5 cast portraits — assetName is the lowercase slug
        let castAssetNames = Set(assets.filter { $0.id.hasPrefix("cast.") }.map { $0.assetName })
        #expect(castAssetNames == ["brogue", "glance", "rest", "sprig", "weigh"])

        // 2 covers — assetName matches the actual webp filename root
        let coverAssetNames = Set(assets.filter { $0.id.hasPrefix("anthology.cover.") }.map { $0.assetName })
        #expect(coverAssetNames == ["cover_book_standard", "cover_book_advanced"])
    }

    @Test("populate registers all 7 assets into an empty registry")
    func populatePopulatesAll() async throws {
        let registry = IllustrationRegistry()
        try await CastIllustrationsRegistry.populate(registry)
        let count = await registry.count()
        #expect(count == 7)
    }

    @Test("populate is idempotent — repeat calls do not throw duplicate-ID")
    func populateIdempotent() async throws {
        let registry = IllustrationRegistry()
        try await CastIllustrationsRegistry.populate(registry)
        try await CastIllustrationsRegistry.populate(registry)
        let count = await registry.count()
        #expect(count == 7)
    }

    @Test("each cast portrait is registered + recoverable by id")
    func castPortraitsLookupByID() async throws {
        let registry = IllustrationRegistry()
        try await CastIllustrationsRegistry.populate(registry)
        for id in CastIllustrationsRegistry.castPortraitIDs {
            let asset = await registry.asset(id: id)
            #expect(asset != nil, "\(id) not found in registry")
            #expect(asset?.category == .mascot)
        }
    }

    @Test("each book cover is registered + recoverable by id")
    func bookCoversLookupByID() async throws {
        let registry = IllustrationRegistry()
        try await CastIllustrationsRegistry.populate(registry)
        for id in CastIllustrationsRegistry.bookCoverIDs {
            let asset = await registry.asset(id: id)
            #expect(asset != nil, "\(id) not found in registry")
            #expect(asset?.category == .hero)
        }
    }

    @Test("registry filtering by .mascot category returns only cast portraits")
    func mascotFilterReturnsCast() async throws {
        let registry = IllustrationRegistry()
        try await CastIllustrationsRegistry.populate(registry)
        let mascots = await registry.assets(in: .mascot)
        #expect(mascots.count == 5)
        let mascotIDs = Set(mascots.map { $0.id })
        #expect(mascotIDs == Set(CastIllustrationsRegistry.castPortraitIDs))
    }

    @Test("registry filtering by .hero category returns only book covers")
    func heroFilterReturnsCovers() async throws {
        let registry = IllustrationRegistry()
        try await CastIllustrationsRegistry.populate(registry)
        let heroes = await registry.assets(in: .hero)
        #expect(heroes.count == 2)
        let heroIDs = Set(heroes.map { $0.id })
        #expect(heroIDs == Set(CastIllustrationsRegistry.bookCoverIDs))
    }

    @Test("alt-text references the curricular primitive for cast portraits")
    func altTextReferencesPrimitive() {
        let assets = CastIllustrationsRegistry.canonicalAssets()
        let brogueAsset = assets.first(where: { $0.id == "cast.brogue.portrait" })
        #expect(brogueAsset?.accessibility.altText.contains("voice") == true)
        let glanceAsset = assets.first(where: { $0.id == "cast.glance.portrait" })
        #expect(glanceAsset?.accessibility.altText.contains("subtext") == true)
        let sprigAsset = assets.first(where: { $0.id == "cast.sprig.portrait" })
        #expect(sprigAsset?.accessibility.altText.contains("branch") == true)
        let weighAsset = assets.first(where: { $0.id == "cast.weigh.portrait" })
        #expect(weighAsset?.accessibility.altText.contains("tag") == true || weighAsset?.accessibility.altText.contains("attribution") == true)
    }
}
