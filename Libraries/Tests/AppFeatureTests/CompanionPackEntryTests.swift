import Foundation
import Testing
@testable import AppFeature

@Suite("CompanionPackEntry — bundle resolution + catalog shape")
struct CompanionPackEntryTests {

    @Test("Bundled catalog matches the 3 PDFs shipped in companion_pack.json")
    func bundledCatalogHasExpectedThreeEntries() {
        let entries = CompanionPackEntry.bundled
        #expect(entries.count == 3)
        let ids = entries.map(\.id)
        #expect(ids.contains("cast_poster"))
        #expect(ids.contains("coloring"))
        #expect(ids.contains("parent_letter"))
    }

    @Test("Every bundled entry resolves to a real PDF URL via Bundle.module")
    func everyEntryResolvesToBundledPDF() {
        for entry in CompanionPackEntry.bundled {
            let url = entry.url
            #expect(url != nil, "Missing bundled PDF for \(entry.id) (filename: \(entry.filename).pdf)")
            if let url {
                #expect(url.pathExtension == "pdf")
                #expect(FileManager.default.fileExists(atPath: url.path))
            }
        }
    }

    @Test("Entries carry distinct filenames + system images (UI-uniqueness)")
    func entriesHaveDistinctFilenamesAndIcons() {
        let entries = CompanionPackEntry.bundled
        let filenames = Set(entries.map(\.filename))
        let icons = Set(entries.map(\.systemImage))
        #expect(filenames.count == entries.count)
        #expect(icons.count == entries.count)
    }

    @Test("Titles + subtitles are non-empty + register-appropriate (no engineering jargon)")
    func titlesAndSubtitlesAreReaderFacing() {
        let stoplist = ["load-bearing", "ADR", "ForgeKit", "TODO", "FIXME", "BUG", "SAMHSA", "Phase A", "Phase B", "Phase C", "Phase D"]
        for entry in CompanionPackEntry.bundled {
            #expect(!entry.title.isEmpty)
            #expect(!entry.subtitle.isEmpty)
            for token in stoplist {
                #expect(!entry.title.contains(token), "Engineering token '\(token)' leaked into title: \(entry.title)")
                #expect(!entry.subtitle.contains(token), "Engineering token '\(token)' leaked into subtitle: \(entry.subtitle)")
            }
        }
    }
}
