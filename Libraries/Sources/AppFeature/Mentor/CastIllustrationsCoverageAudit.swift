import Foundation
import ForgeIllustrations

/// Coverage diagnostic for `CastIllustrationsRegistry.shared`. Reads
/// the populated registry + reports which canonical assets are
/// registered, which are missing, and which carry non-empty alt-text.
///
/// **Why this exists**: now that `CastIllustrationsRegistry.populateShared()`
/// fires at cold-launch (Priority F closure, 2026-06-29), the registry
/// becomes a queryable source of truth for illustration metadata. The
/// audit turns "is the populate path working?" into a single Report
/// value-type readable from anywhere — a debug-only Settings surface,
/// a future cast-portrait sheet's accessibility-metadata smoke test,
/// or a unit-test consumer wanting to assert coverage without
/// re-asserting the canonical ID list at every call site.
///
/// **Shape**: pure async value-type computation. `audit(registry:)`
/// reads the actor; `Report` carries derived sets that are cheap to
/// inspect. No side effects on the registry; no UI; no app-storage.
public enum CastIllustrationsCoverageAudit {

    /// Read-only coverage snapshot. Pure value type so consumers
    /// (tests, debug surfaces, future audit reports) can pass it
    /// across isolation boundaries safely.
    public nonisolated struct Report: Sendable, Equatable {
        /// Number of expected canonical assets (5 cast portraits +
        /// 2 book covers = 7). Mirrors
        /// `CastIllustrationsRegistry.expectedAssetCount`.
        public let expectedAssetCount: Int

        /// Number of canonical assets that the registry returned a
        /// non-nil lookup for. ≤ `expectedAssetCount`.
        public let registeredAssetCount: Int

        /// Canonical IDs (from `CastIllustrationsRegistry.castPortraitIDs`
        /// + `.bookCoverIDs`) the registry could NOT resolve. Sorted
        /// for deterministic comparison.
        public let missingAssetIDs: [String]

        /// Canonical IDs whose registered asset carries empty or
        /// whitespace-only alt-text. Empty in the canonical-populate
        /// path; surfaces a regression if someone ships a registry
        /// entry without accessibility copy. Sorted for determinism.
        public let assetIDsMissingAltText: [String]

        public init(
            expectedAssetCount: Int,
            registeredAssetCount: Int,
            missingAssetIDs: [String],
            assetIDsMissingAltText: [String]
        ) {
            self.expectedAssetCount = expectedAssetCount
            self.registeredAssetCount = registeredAssetCount
            self.missingAssetIDs = missingAssetIDs
            self.assetIDsMissingAltText = assetIDsMissingAltText
        }

        /// True when every canonical ID resolves AND every resolved
        /// asset carries non-empty alt-text. The single boolean that
        /// debug surfaces + smoke tests can short-circuit on.
        public var isFullyCovered: Bool {
            missingAssetIDs.isEmpty
                && assetIDsMissingAltText.isEmpty
                && registeredAssetCount == expectedAssetCount
        }

        /// Reader-facing one-line summary. Stays in the register-clean
        /// dev / parent register — no engineering jargon per
        /// `.claude/rules/distributed-narrative.md` § Chapter content
        /// register stoplist. Safe to surface in a debug Settings row.
        public var summary: String {
            if isFullyCovered {
                return "All \(expectedAssetCount) cast illustrations ready."
            }
            let registered = registeredAssetCount
            let total = expectedAssetCount
            if !missingAssetIDs.isEmpty {
                return "\(registered) of \(total) cast illustrations ready."
            }
            // All registered but some missing alt-text — surface the
            // accessibility-gap explicitly.
            return "All \(total) cast illustrations registered; \(assetIDsMissingAltText.count) need accessibility copy."
        }
    }

    /// Run the audit against the given registry. Resolves each
    /// canonical ID via `registry.asset(id:)`, classifies missing IDs
    /// vs missing-alt-text IDs, and returns a sorted `Report`.
    ///
    /// Pure read — does NOT mutate the registry.
    public static func audit(registry: IllustrationRegistry) async -> Report {
        let canonicalIDs = CastIllustrationsRegistry.castPortraitIDs
            + CastIllustrationsRegistry.bookCoverIDs
        var missing: [String] = []
        var emptyAltText: [String] = []
        var registered = 0
        for id in canonicalIDs {
            guard let asset = await registry.asset(id: id) else {
                missing.append(id)
                continue
            }
            registered += 1
            let altText = asset.accessibility.altText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            if altText.isEmpty {
                emptyAltText.append(id)
            }
        }
        return Report(
            expectedAssetCount: CastIllustrationsRegistry.expectedAssetCount,
            registeredAssetCount: registered,
            missingAssetIDs: missing.sorted(),
            assetIDsMissingAltText: emptyAltText.sorted()
        )
    }

    /// Convenience: run the audit against the shared singleton.
    /// Use from debug Settings + smoke tests.
    public static func auditShared() async -> Report {
        await audit(registry: CastIllustrationsRegistry.shared)
    }
}
