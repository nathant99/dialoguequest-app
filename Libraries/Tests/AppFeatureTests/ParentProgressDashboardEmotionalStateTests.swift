import Testing
import Foundation
import Services
import ForgeEmotionAware
@testable import AppFeature

/// Priority M.3 (2026-07-04) — `ParentProgressDashboardView` consumes
/// the persisted `EmotionalSignalsPersistence` snapshot and renders the
/// matching `DialogueEmotionalStateDescriptor` as a read-only section.
///
/// The dashboard view itself is SwiftUI + `@State`-driven, so these
/// tests cover the **integration seam** between persistence + probe
/// without instantiating the view. The view's render path is
/// dispatched off the same descriptor surface; preview verification +
/// the descriptor stoplist test in `EmotionalSignalsPersistenceTests`
/// jointly cover the rendered output.
@Suite("ParentProgressDashboardView emotional-state reader")
struct ParentProgressDashboardEmotionalStateTests {

    private func makeDefaults() -> UserDefaults {
        let name = "dq.test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @Test("fresh-install reader returns nil descriptor (section omits)")
    func freshInstallNilDescriptor() {
        let defaults = makeDefaults()
        let signals = EmotionalSignalsPersistence.latest(defaults: defaults)
        #expect(signals == nil)
    }

    @Test("persistence-fed signals resolve to the .frustrated descriptor")
    func frustratedReaderPath() {
        let defaults = makeDefaults()
        // Tier-1 saturation: 3+ voice drifts.
        let recorded = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 3,
            tagImbalanceCount: 1,
            branchReflectionRatio: 0.5,
            minutesSinceLastPublish: 8.0
        )
        EmotionalSignalsPersistence.record(signals: recorded, defaults: defaults)
        let readBack = try? #require(EmotionalSignalsPersistence.latest(defaults: defaults))
        guard let readBack else { return }
        let descriptor = DialogueEmotionalStateProbe.descriptor(forSignals: readBack)
        #expect(descriptor.parentSummary == "Same notes keep coming up")
        #expect(descriptor.nextMilestone.contains("different next line"))
    }

    @Test("persistence-fed signals resolve to the .confident descriptor")
    func confidentReaderPath() {
        let defaults = makeDefaults()
        // Tier-5: recent publish + 0 drifts + ≥ 0.5 reflection ratio.
        let recorded = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 0,
            tagImbalanceCount: 0,
            branchReflectionRatio: 0.75,
            minutesSinceLastPublish: 2.0
        )
        EmotionalSignalsPersistence.record(signals: recorded, defaults: defaults)
        let readBack = try? #require(EmotionalSignalsPersistence.latest(defaults: defaults))
        guard let readBack else { return }
        let descriptor = DialogueEmotionalStateProbe.descriptor(forSignals: readBack)
        #expect(descriptor.parentSummary == "Steady hand on a fresh publish")
    }

    @Test("flow descriptor is the default when no friction signals fire")
    func flowDescriptorDefault() {
        let signals = DialogueEmotionalStateProbe.Signals(
            voiceDriftCount: 0,
            tagImbalanceCount: 0,
            branchReflectionRatio: 1.0,
            minutesSinceLastPublish: nil
        )
        let descriptor = DialogueEmotionalStateProbe.descriptor(forSignals: signals)
        #expect(descriptor.parentSummary == "Settled writing rhythm")
    }

    // MARK: - Priority M.4 (2026-07-05) — stale-snapshot framing

    @Test("staleness framing reads 'just now' for snapshots under 60s")
    func stalenessJustNow() {
        let now = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let snapshotAt = now.addingTimeInterval(-30)
        let framing = ParentProgressDashboardView.stalenessFraming(for: snapshotAt, now: now)
        #expect(framing == "Last read just now")
    }

    @Test("staleness framing reads minutes for snapshots within an hour")
    func stalenessMinutes() {
        let now = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let snapshotAt = now.addingTimeInterval(-4 * 60)
        let framing = ParentProgressDashboardView.stalenessFraming(for: snapshotAt, now: now)
        #expect(framing == "Last read 4 minutes ago")
    }

    @Test("staleness framing reads hours for snapshots within a day")
    func stalenessHours() {
        let now = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let snapshotAt = now.addingTimeInterval(-2 * 60 * 60)
        let framing = ParentProgressDashboardView.stalenessFraming(for: snapshotAt, now: now)
        #expect(framing == "Last read about 2 hours ago")
    }

    @Test("staleness framing reads days for snapshots beyond a day")
    func stalenessDays() {
        let now = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let snapshotAt = now.addingTimeInterval(-3 * 24 * 60 * 60)
        let framing = ParentProgressDashboardView.stalenessFraming(for: snapshotAt, now: now)
        #expect(framing == "Last read 3 days ago")
    }

    @Test("staleness framing returns nil when timestamp is nil (omits the line)")
    func stalenessNilWhenNoTimestamp() {
        let framing = ParentProgressDashboardView.stalenessFraming(for: nil, now: Date())
        #expect(framing == nil)
    }

    @Test("staleness framing pluralizes 1-minute / 1-hour / 1-day correctly")
    func stalenessSingularPlurals() {
        let now = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let oneMin = ParentProgressDashboardView.stalenessFraming(
            for: now.addingTimeInterval(-65),
            now: now
        )
        #expect(oneMin == "Last read 1 minute ago")
        let oneHour = ParentProgressDashboardView.stalenessFraming(
            for: now.addingTimeInterval(-60 * 60 + -30),
            now: now
        )
        #expect(oneHour == "Last read about 1 hour ago")
        let oneDay = ParentProgressDashboardView.stalenessFraming(
            for: now.addingTimeInterval(-24 * 60 * 60 - 60),
            now: now
        )
        #expect(oneDay == "Last read 1 day ago")
    }
}
