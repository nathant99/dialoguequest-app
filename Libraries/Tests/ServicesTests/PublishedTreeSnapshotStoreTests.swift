import Testing
import Foundation
@testable import Models
@testable import Services

@MainActor
@Suite("PublishedTreeSnapshotStore")
struct PublishedTreeSnapshotStoreTests {

    /// Isolated UserDefaults per test so suites don't cross-contaminate.
    private func makeDefaults() -> UserDefaults {
        let suite = "PublishedTreeSnapshotStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func makeSnapshot(
        id: UUID = UUID(),
        title: String = "Tree",
        nodeCount: Int = 5,
        mood: DialogueMood? = .warmReunion,
        treeAverage: Double? = 0.6,
        publishedAt: Date = Date(timeIntervalSince1970: 1000)
    ) -> PublishedTreeSnapshot {
        PublishedTreeSnapshot(
            id: id,
            title: title,
            nodeCount: nodeCount,
            mood: mood,
            treeAverageVoiceMatch: treeAverage,
            characterVoices: [],
            publishedAt: publishedAt
        )
    }

    @Test("fresh store returns empty")
    func freshEmpty() {
        let store = PublishedTreeSnapshotStore(defaults: makeDefaults())
        #expect(store.recent().isEmpty)
        #expect(store.mostRecent() == nil)
        #expect(store.longest() == nil)
    }

    @Test("record then recent returns most-recent-first")
    func recordOrder() {
        let store = PublishedTreeSnapshotStore(defaults: makeDefaults())
        let first = makeSnapshot(title: "First")
        let second = makeSnapshot(title: "Second")
        store.record(first)
        store.record(second)
        #expect(store.recent().map(\.title) == ["Second", "First"])
        #expect(store.mostRecent()?.title == "Second")
    }

    @Test("longest returns the tree with most nodes")
    func longestByNodes() {
        let store = PublishedTreeSnapshotStore(defaults: makeDefaults())
        store.record(makeSnapshot(title: "Short", nodeCount: 5))
        store.record(makeSnapshot(title: "Long", nodeCount: 14))
        store.record(makeSnapshot(title: "Medium", nodeCount: 9))
        #expect(store.longest()?.title == "Long")
    }

    @Test("longest tie resolves to the more recent tree")
    func longestTieMostRecent() {
        let store = PublishedTreeSnapshotStore(defaults: makeDefaults())
        store.record(makeSnapshot(title: "OlderTie", nodeCount: 10))
        store.record(makeSnapshot(title: "NewerTie", nodeCount: 10))
        // NewerTie was recorded last => most-recent-first => it wins the tie.
        #expect(store.longest()?.title == "NewerTie")
    }

    @Test("re-publishing the same tree id de-dups and moves to front")
    func dedupByID() {
        let store = PublishedTreeSnapshotStore(defaults: makeDefaults())
        let id = UUID()
        store.record(makeSnapshot(id: id, title: "v1", nodeCount: 5))
        store.record(makeSnapshot(title: "Other", nodeCount: 6))
        store.record(makeSnapshot(id: id, title: "v2", nodeCount: 8))
        let recent = store.recent()
        #expect(recent.count == 2)
        #expect(recent.first?.title == "v2")
        #expect(recent.filter { $0.id == id }.count == 1)
    }

    @Test("ring buffer caps at capacity, dropping oldest")
    func ringBufferCap() {
        let store = PublishedTreeSnapshotStore(defaults: makeDefaults())
        let cap = PublishedTreeSnapshotStore.capacity
        for i in 0..<(cap + 5) {
            store.record(makeSnapshot(title: "T\(i)"))
        }
        let recent = store.recent()
        #expect(recent.count == cap)
        // Most recent is the last recorded; oldest 5 dropped.
        #expect(recent.first?.title == "T\(cap + 4)")
        #expect(recent.last?.title == "T5")
    }

    @Test("reset clears the buffer")
    func resetClears() {
        let store = PublishedTreeSnapshotStore(defaults: makeDefaults())
        store.record(makeSnapshot())
        store.reset()
        #expect(store.recent().isEmpty)
    }

    @Test("persistence survives a new store instance on same defaults")
    func persistsAcrossInstances() {
        let defaults = makeDefaults()
        let writer = PublishedTreeSnapshotStore(defaults: defaults)
        writer.record(makeSnapshot(title: "Persisted", nodeCount: 11))
        let reader = PublishedTreeSnapshotStore(defaults: defaults)
        #expect(reader.mostRecent()?.title == "Persisted")
        #expect(reader.longest()?.nodeCount == 11)
    }

    @Test("corrupt stored data degrades to empty, not crash")
    func corruptDataGraceful() {
        let defaults = makeDefaults()
        defaults.set(Data("not json".utf8), forKey: PublishedTreeSnapshotStore.defaultsKey)
        let store = PublishedTreeSnapshotStore(defaults: defaults)
        #expect(store.recent().isEmpty)
        // A subsequent record still works (overwrites the corrupt blob).
        store.record(makeSnapshot(title: "Recovered"))
        #expect(store.mostRecent()?.title == "Recovered")
    }
}
