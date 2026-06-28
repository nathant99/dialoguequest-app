import Foundation
import Models

/// Ring-buffered persistence for `PublishedTreeSnapshot` records — the
/// per-published-tree artifact the parent-progress dashboard surfaces
/// alongside the rolling emotional snapshot + weekly counters.
///
/// **Why a ring buffer (not append-only)**: the parent dashboard only
/// needs "the longest tree so far" + "the most recent publish" + a
/// handful of recent works. An unbounded list would grow without limit
/// in a private container that nothing prunes. `capacity` (20) is enough
/// to keep "longest so far" meaningful across a few weeks of writing
/// without unbounded growth. Oldest records drop off the back when the
/// buffer is full.
///
/// **Persistence**: a single `UserDefaults` key under the `dq.*`
/// namespace, JSON-encoding `[PublishedTreeSnapshot]` (most-recent-first).
/// Mirrors `VoicePatternHistoryService` — UserDefaults-backed, `@MainActor`
/// final class with a `.shared` singleton, value-type read API. Encode /
/// decode failures route through `DialogueQuestDebugLog.data` (silent-fail
/// detection) and degrade to an empty buffer rather than crashing.
///
/// **No PII / no outbound**: `PublishedTreeSnapshot` carries only
/// categorical fields + clamped 0...1 voice scores + kid-authored cast
/// names. Nothing leaves the device.
///
/// **De-dup on tree id**: re-publishing the same tree replaces its prior
/// record (moved to the front) rather than accumulating duplicates, so
/// "longest" + "recent" reflect the latest state of each distinct tree.
@MainActor
public final class PublishedTreeSnapshotStore {
    public static let shared = PublishedTreeSnapshotStore()

    /// Maximum number of snapshots retained. Oldest drop off when full.
    public nonisolated static let capacity: Int = 20

    /// `UserDefaults` key. Public so tests + the dashboard reader can
    /// reference the canonical key.
    public nonisolated static let defaultsKey = "dq.publishedTreeSnapshots"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Recording

    /// Record a freshly published tree's snapshot. De-dups on the tree
    /// `id` (a re-publish of the same tree replaces its prior record and
    /// moves to the front). Trims to `capacity`, dropping the oldest.
    public func record(_ snapshot: PublishedTreeSnapshot) {
        var stored = decoded()
        stored.removeAll { $0.id == snapshot.id }
        stored.insert(snapshot, at: 0)
        if stored.count > Self.capacity {
            stored = Array(stored.prefix(Self.capacity))
        }
        persist(stored)
    }

    /// Test seam + parental-controls reset hook. Wipes every record.
    public func reset() {
        defaults.removeObject(forKey: Self.defaultsKey)
    }

    // MARK: - Reading

    /// All retained snapshots, most-recent-first. Empty when none have
    /// been recorded (fresh install).
    public func recent() -> [PublishedTreeSnapshot] {
        decoded()
    }

    /// The most recently published tree, or `nil` on a fresh install.
    public func mostRecent() -> PublishedTreeSnapshot? {
        decoded().first
    }

    /// The retained tree with the most nodes, or `nil` on a fresh
    /// install. Ties resolve to the more recently published tree (the
    /// list is most-recent-first, and `max(by:)` keeps the first of an
    /// equal pair). Drives the dashboard's "longest conversation"
    /// readout.
    public func longest() -> PublishedTreeSnapshot? {
        // `max(by:)` returns the last element that is not less than every
        // other; to break ties toward the more-recent tree we compare on
        // nodeCount only and rely on the most-recent-first ordering by
        // scanning manually.
        let all = decoded()
        guard var best = all.first else { return nil }
        for candidate in all.dropFirst() where candidate.nodeCount > best.nodeCount {
            best = candidate
        }
        return best
    }

    // MARK: - Persistence helpers

    private func decoded() -> [PublishedTreeSnapshot] {
        guard let data = defaults.data(forKey: Self.defaultsKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([PublishedTreeSnapshot].self, from: data)
        } catch {
            DialogueQuestDebugLog.data("PublishedTreeSnapshotStore.decoded — decode failed; treating as empty", error: error)
            return []
        }
    }

    private func persist(_ snapshots: [PublishedTreeSnapshot]) {
        do {
            let encoded = try JSONEncoder().encode(snapshots)
            defaults.set(encoded, forKey: Self.defaultsKey)
        } catch {
            DialogueQuestDebugLog.data("PublishedTreeSnapshotStore.persist — encode failed; snapshot not persisted this publish", error: error)
        }
    }
}
