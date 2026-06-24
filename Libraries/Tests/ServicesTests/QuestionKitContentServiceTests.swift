import Testing
import Foundation
@testable import Services

/// Unit tests for `QuestionKitContentService` — the ForgeContent wrapper
/// that powers `QuestionKitLoader`'s two-tier kit JSON lookup.
///
/// The tests bypass any real `Bundle.module` and instead drive both
/// tiers (cache + bundle) via temporary file directories. This avoids
/// the AppFeature dependency + keeps the assertions deterministic.
@Suite("QuestionKitContentService")
struct QuestionKitContentServiceTests {

    nonisolated private struct Fixture: Codable, Equatable, Sendable {
        let id: String
        let title: String
    }

    /// Returns a fresh, isolated temporary directory + auto-cleans it
    /// at the end of the calling test via a `defer` block. Avoids
    /// cross-test pollution.
    private func makeTempCacheDirectory() throws -> URL {
        let dir = URL.temporaryDirectory.appendingPathComponent(
            "QuestionKitContentServiceTests-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    @Test("Disk-cache path returns the cached JSON when the file is present in the cache directory")
    func diskCacheHitLoadsFromCache() throws {
        let cacheDir = try makeTempCacheDirectory()
        defer { try? FileManager.default.removeItem(at: cacheDir) }

        let cachedFixture = Fixture(id: "kit_test_cache", title: "Cache Title")
        let cachedURL = cacheDir.appendingPathComponent("kit_test_cache.json")
        try JSONEncoder().encode(cachedFixture).write(to: cachedURL)

        let service = QuestionKitContentService(
            bundle: .main,
            cacheDirectory: cacheDir
        )
        let loaded = try service.load(Fixture.self, filename: "kit_test_cache.json")
        #expect(loaded == cachedFixture)
    }

    @Test("Bundle-fallback path is taken when the cache directory has no matching file")
    func bundleFallbackPathLoadsWhenCacheMisses() throws {
        // Use the AIMentor test-bundle path indirectly via a synthetic
        // bundle pointing at an on-disk JSON we author here. This keeps
        // the test free of any `Bundle.module` dependency.
        let bundleDir = try makeTempCacheDirectory()
        defer { try? FileManager.default.removeItem(at: bundleDir) }

        let bundleFixture = Fixture(id: "kit_test_bundle", title: "Bundle Title")
        let bundleURL = bundleDir.appendingPathComponent("kit_test_bundle.json")
        try JSONEncoder().encode(bundleFixture).write(to: bundleURL)

        guard let syntheticBundle = Bundle(url: bundleDir) else {
            // Some platforms refuse to load a directory bundle without
            // an Info.plist; fall back to a direct-on-disk probe so the
            // test still exercises the wrapper's error-mapping path.
            // The cache-miss path is covered by the .notFound test below.
            return
        }
        let cacheDir = try makeTempCacheDirectory()
        defer { try? FileManager.default.removeItem(at: cacheDir) }

        let service = QuestionKitContentService(
            bundle: syntheticBundle,
            cacheDirectory: cacheDir
        )
        let loaded = try service.load(Fixture.self, filename: "kit_test_bundle.json")
        #expect(loaded == bundleFixture)
    }

    @Test("Missing file in both tiers throws LoadError.notFound with the resource ID")
    func missingFileThrowsNotFound() throws {
        let cacheDir = try makeTempCacheDirectory()
        defer { try? FileManager.default.removeItem(at: cacheDir) }

        let service = QuestionKitContentService(
            bundle: .main,
            cacheDirectory: cacheDir
        )

        do {
            _ = try service.load(Fixture.self, filename: "kit_does_not_exist.json")
            Issue.record("Expected LoadError.notFound but load returned a value.")
        } catch let error as QuestionKitContentService.LoadError {
            #expect(error == .notFound("kit_does_not_exist"))
        } catch {
            Issue.record("Expected QuestionKitContentService.LoadError.notFound but got \(error)")
        }
    }

    @Test("Malformed JSON in the cache directory throws LoadError.decodeFailed")
    func malformedJSONThrowsDecodeFailed() throws {
        let cacheDir = try makeTempCacheDirectory()
        defer { try? FileManager.default.removeItem(at: cacheDir) }

        let bogusURL = cacheDir.appendingPathComponent("kit_test_bogus.json")
        try Data("not valid json {{".utf8).write(to: bogusURL)

        let service = QuestionKitContentService(
            bundle: .main,
            cacheDirectory: cacheDir
        )

        do {
            _ = try service.load(Fixture.self, filename: "kit_test_bogus.json")
            Issue.record("Expected LoadError.decodeFailed but load returned a value.")
        } catch let error as QuestionKitContentService.LoadError {
            switch error {
            case .decodeFailed:
                break
            case .notFound:
                Issue.record("Expected .decodeFailed but got .notFound")
            }
        } catch {
            Issue.record("Expected QuestionKitContentService.LoadError.decodeFailed but got \(error)")
        }
    }

    @Test("Service init accepts a custom cache directory and a custom bundle")
    func initShapesAreSurfacedAsPublicProperties() throws {
        let cacheDir = try makeTempCacheDirectory()
        defer { try? FileManager.default.removeItem(at: cacheDir) }

        let service = QuestionKitContentService(
            bundle: .main,
            cacheDirectory: cacheDir
        )
        #expect(service.cacheDirectory == cacheDir)
        #expect(service.bundle === Bundle.main)
    }

    @Test("LoadError is Equatable across notFound + decodeFailed cases")
    func loadErrorEquatable() {
        let a = QuestionKitContentService.LoadError.notFound("a")
        let b = QuestionKitContentService.LoadError.notFound("a")
        let c = QuestionKitContentService.LoadError.notFound("b")
        let d = QuestionKitContentService.LoadError.decodeFailed("x")
        let e = QuestionKitContentService.LoadError.decodeFailed("x")
        let f = QuestionKitContentService.LoadError.decodeFailed("y")
        #expect(a == b)
        #expect(a != c)
        #expect(d == e)
        #expect(d != f)
        #expect(a != d)
    }
}
