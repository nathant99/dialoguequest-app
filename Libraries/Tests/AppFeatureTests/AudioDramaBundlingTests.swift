import Testing
import Foundation
@testable import AppFeature

/// Wave 1 (2026-08-02) — `Docs/HANDOFF_FROM_HUB_AUDIO_DRAMA_VERIFY_AND_WIRE.md`.
///
/// The load-bearing "bundled ≠ wired" gap for audio dramas is that a `.caf`
/// referenced by the catalog can silently ship in no bundle (the repo-root
/// staging mirror is outside every SPM target). These tests run against the
/// real `Bundle.module` of AppFeature, so a regression in the
/// `.copy("AudioDramas")` rule OR the relocated files fails here.
@MainActor
@Suite("Audio-drama bundling + catalog decode")
struct AudioDramaBundlingTests {

    @Test("Catalog decodes to a non-empty drama set")
    func catalogDecodes() {
        let service = AudioDramaService()
        #expect(!service.catalog.dramas.isEmpty, "The bundled catalog.json should decode ≥1 drama.")
    }

    @Test("Every catalog bundlePath resolves in Bundle.module")
    func everyBundlePathResolves() {
        let service = AudioDramaService()
        for path in service.bundlePaths {
            let url = AudioDramaService.resolvedURL(forBundlePath: path)
            #expect(url != nil, "Catalog bundlePath did not resolve in Bundle.module: \(path)")
            if let url {
                #expect(
                    FileManager.default.fileExists(atPath: url.path),
                    "Resolved URL does not exist on disk: \(url.path)"
                )
            }
        }
    }

    @Test("Every drama has a synthesized opener chapter and positive duration")
    func dramasAreWellFormed() {
        let service = AudioDramaService()
        for drama in service.catalog.dramas {
            #expect(drama.durationSeconds > 0, "\(drama.title) has non-positive duration.")
            #expect(!drama.chapters.isEmpty, "\(drama.title) must have ≥1 chapter (the opener).")
            #expect(!drama.sourceChapterSlugs.isEmpty, "\(drama.title) should map to ≥1 cast slug.")
        }
    }

    @Test("dramas(forCharacter:) filters by source cast slug")
    func filterByCharacter() {
        let service = AudioDramaService()
        // Every drama's own source slug must find that drama.
        for drama in service.catalog.dramas {
            for slug in drama.sourceChapterSlugs {
                let matches = service.dramas(forCharacter: slug)
                #expect(matches.contains(where: { $0.id == drama.id }),
                        "dramas(forCharacter: \(slug)) should include \(drama.title).")
            }
        }
        #expect(service.dramas(forCharacter: "not-a-cast-member").isEmpty)
    }
}
