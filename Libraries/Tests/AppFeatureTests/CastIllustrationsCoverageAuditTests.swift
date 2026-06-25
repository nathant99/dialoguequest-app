import Foundation
import Testing
import ForgeIllustrations
@testable import AppFeature

@Suite("CastIllustrationsCoverageAudit")
struct CastIllustrationsCoverageAuditTests {

    // MARK: - Report value-type contracts

    @Test("Report.isFullyCovered true only when nothing missing")
    func reportFullyCoveredHappyPath() {
        let report = CastIllustrationsCoverageAudit.Report(
            expectedAssetCount: 7,
            registeredAssetCount: 7,
            missingAssetIDs: [],
            assetIDsMissingAltText: []
        )
        #expect(report.isFullyCovered == true)
    }

    @Test("Report.isFullyCovered false when missing IDs present")
    func reportFullyCoveredFalseWhenMissing() {
        let report = CastIllustrationsCoverageAudit.Report(
            expectedAssetCount: 7,
            registeredAssetCount: 6,
            missingAssetIDs: ["cast.brogue.portrait"],
            assetIDsMissingAltText: []
        )
        #expect(report.isFullyCovered == false)
    }

    @Test("Report.isFullyCovered false when alt-text missing")
    func reportFullyCoveredFalseWhenAltTextMissing() {
        let report = CastIllustrationsCoverageAudit.Report(
            expectedAssetCount: 7,
            registeredAssetCount: 7,
            missingAssetIDs: [],
            assetIDsMissingAltText: ["cast.brogue.portrait"]
        )
        #expect(report.isFullyCovered == false)
    }

    @Test("Report.isFullyCovered false when count mismatches even with no missing IDs")
    func reportFullyCoveredFalseWhenCountMismatch() {
        // Defensive: if the contract's expectedAssetCount and the
        // observed registeredAssetCount disagree but missingAssetIDs
        // is empty, the report still considers itself not-covered.
        // Catches a hypothetical regression where the canonical IDs
        // list and the expectedAssetCount drift apart.
        let report = CastIllustrationsCoverageAudit.Report(
            expectedAssetCount: 7,
            registeredAssetCount: 5,
            missingAssetIDs: [],
            assetIDsMissingAltText: []
        )
        #expect(report.isFullyCovered == false)
    }

    @Test("Report.summary register stoplist clean (full coverage path)")
    func reportSummaryRegisterStoplistFullCoverage() {
        let report = CastIllustrationsCoverageAudit.Report(
            expectedAssetCount: 7,
            registeredAssetCount: 7,
            missingAssetIDs: [],
            assetIDsMissingAltText: []
        )
        let summary = report.summary.lowercased()
        // Engineering / methodology jargon stoplist per
        // .claude/rules/distributed-narrative.md § Chapter content
        // register. Surface might land on a parent-readable debug
        // panel; copy stays reader-clean.
        let banned = [
            "load-bearing", "canonical", "primitive", "codified",
            "single source of truth", "registry", "actor", "isolation",
            "samhsa", "phase a", "phase b", "phase c", "phase d"
        ]
        for token in banned {
            #expect(!summary.contains(token), "summary contains banned token \"\(token)\": \(summary)")
        }
        #expect(!summary.isEmpty)
    }

    @Test("Report.summary differentiates missing-assets vs missing-alt-text")
    func reportSummaryDifferentiatesGapKinds() {
        let withMissingAssets = CastIllustrationsCoverageAudit.Report(
            expectedAssetCount: 7,
            registeredAssetCount: 4,
            missingAssetIDs: ["cast.brogue.portrait", "cast.glance.portrait", "cast.rest.portrait"],
            assetIDsMissingAltText: []
        )
        let withAltGap = CastIllustrationsCoverageAudit.Report(
            expectedAssetCount: 7,
            registeredAssetCount: 7,
            missingAssetIDs: [],
            assetIDsMissingAltText: ["cast.brogue.portrait"]
        )
        #expect(withMissingAssets.summary != withAltGap.summary)
        #expect(withMissingAssets.summary.contains("4 of 7"))
        #expect(withAltGap.summary.contains("7"))
    }

    // MARK: - audit(registry:) — happy + missing paths

    @Test("audit on freshly populated registry returns full coverage")
    func auditFullyCoveredHappyPath() async throws {
        let registry = IllustrationRegistry()
        try await CastIllustrationsRegistry.populate(registry)
        let report = await CastIllustrationsCoverageAudit.audit(registry: registry)
        #expect(report.expectedAssetCount == 7)
        #expect(report.registeredAssetCount == 7)
        #expect(report.missingAssetIDs.isEmpty)
        #expect(report.assetIDsMissingAltText.isEmpty)
        #expect(report.isFullyCovered == true)
    }

    @Test("audit on empty registry reports all canonical IDs missing")
    func auditEmptyRegistryReportsAllMissing() async {
        let registry = IllustrationRegistry()
        let report = await CastIllustrationsCoverageAudit.audit(registry: registry)
        #expect(report.expectedAssetCount == 7)
        #expect(report.registeredAssetCount == 0)
        #expect(report.missingAssetIDs.count == 7)
        // Missing IDs are sorted for determinism — assert canonical
        // ordering so a future un-sort regression surfaces here.
        let expectedSortedMissing = (
            CastIllustrationsRegistry.castPortraitIDs
                + CastIllustrationsRegistry.bookCoverIDs
        ).sorted()
        #expect(report.missingAssetIDs == expectedSortedMissing)
        #expect(report.isFullyCovered == false)
    }

    @Test("audit on partially populated registry distinguishes missing portrait vs cover")
    func auditPartialCoverageMixedGap() async throws {
        let registry = IllustrationRegistry()
        // Hand-register a single cast portrait + a single book cover
        // so the audit sees 5 missing across the canonical 7.
        let canonical = CastIllustrationsRegistry.canonicalAssets()
        let brogueOnly = canonical.first { $0.id == "cast.brogue.portrait" }
        let standardCover = canonical.first { $0.id == "anthology.cover.standard" }
        try await registry.register([
            try #require(brogueOnly),
            try #require(standardCover)
        ])
        let report = await CastIllustrationsCoverageAudit.audit(registry: registry)
        #expect(report.registeredAssetCount == 2)
        #expect(report.missingAssetIDs.count == 5)
        #expect(report.missingAssetIDs.contains("cast.glance.portrait"))
        #expect(report.missingAssetIDs.contains("anthology.cover.advanced"))
        #expect(!report.missingAssetIDs.contains("cast.brogue.portrait"))
        #expect(report.isFullyCovered == false)
    }

    @Test("audit is read-only — does not mutate registry contents")
    func auditDoesNotMutateRegistry() async throws {
        let registry = IllustrationRegistry()
        try await CastIllustrationsRegistry.populate(registry)
        let beforeCount = await registry.count()
        _ = await CastIllustrationsCoverageAudit.audit(registry: registry)
        let afterCount = await registry.count()
        #expect(beforeCount == afterCount)
        #expect(afterCount == CastIllustrationsRegistry.expectedAssetCount)
    }

    // MARK: - Sendable + Equatable contracts (Report is a value type)

    @Test("Report is Equatable across identical content")
    func reportIsEquatable() {
        let a = CastIllustrationsCoverageAudit.Report(
            expectedAssetCount: 7,
            registeredAssetCount: 6,
            missingAssetIDs: ["cast.brogue.portrait"],
            assetIDsMissingAltText: ["anthology.cover.standard"]
        )
        let b = CastIllustrationsCoverageAudit.Report(
            expectedAssetCount: 7,
            registeredAssetCount: 6,
            missingAssetIDs: ["cast.brogue.portrait"],
            assetIDsMissingAltText: ["anthology.cover.standard"]
        )
        #expect(a == b)
    }
}
