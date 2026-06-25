import Foundation
import Testing
@testable import Services

@Suite("SeasonalThemeService")
@MainActor
struct SeasonalThemeServiceTests {
    private func makeIsolatedDefaults() -> UserDefaults {
        let suite = "dq.seasonalTheme.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return Calendar.current.date(from: comps)!
    }

    @Test("curatedThemes contract — 4 themes ship by default")
    func curatedThemesContract() {
        #expect(SeasonalThemeService.curatedThemes.count == 4)
        let ids = Set(SeasonalThemeService.curatedThemes.map { $0.id })
        #expect(ids == ["conversation_month", "storytelling_days", "summer_writers_days", "year_close"])
    }

    @Test("presentationProbability contract — 0.08 lower bound")
    func presentationProbabilityContract() {
        #expect(SeasonalThemeService.presentationProbability == 0.08)
    }

    @Test("storageKeyPrefix contract")
    func storageKeyPrefixContract() {
        #expect(SeasonalThemeService.storageKeyPrefix == "dq.seasonalTheme.shownAt.")
    }

    @Test("Conversation Month active in mid-October")
    func conversationMonthActiveMidOctober() {
        let service = SeasonalThemeService(defaults: makeIsolatedDefaults())
        let theme = service.currentTheme(now: date(2026, 10, 16))
        #expect(theme?.id == "conversation_month")
    }

    @Test("Conversation Month NOT active outside window (mid-November)")
    func conversationMonthInactiveOutsideWindow() {
        let service = SeasonalThemeService(defaults: makeIsolatedDefaults())
        let theme = service.currentTheme(now: date(2026, 11, 15))
        #expect(theme == nil)
    }

    @Test("Storytelling Days active around World Storytelling Day")
    func storytellingDaysActive() {
        let service = SeasonalThemeService(defaults: makeIsolatedDefaults())
        let theme = service.currentTheme(now: date(2026, 3, 20))
        #expect(theme?.id == "storytelling_days")
    }

    @Test("Summer Writers' Days active around June 1")
    func summerWritersDaysActive() {
        let service = SeasonalThemeService(defaults: makeIsolatedDefaults())
        let earlyJune = service.currentTheme(now: date(2026, 6, 1))
        #expect(earlyJune?.id == "summer_writers_days")
        let lateMay = service.currentTheme(now: date(2026, 5, 27))
        #expect(lateMay?.id == "summer_writers_days")
        let midJune = service.currentTheme(now: date(2026, 6, 12))
        #expect(midJune?.id == "summer_writers_days")
    }

    @Test("Summer Writers' Days NOT active just outside window (May 20 / June 20)")
    func summerWritersDaysInactiveOutsideWindow() {
        let service = SeasonalThemeService(defaults: makeIsolatedDefaults())
        let pre = service.currentTheme(now: date(2026, 5, 20))
        #expect(pre == nil)
        let post = service.currentTheme(now: date(2026, 6, 20))
        #expect(post == nil)
    }

    @Test("Author Your Year active late December AND early January")
    func authorYearActiveAcrossWrap() {
        let service = SeasonalThemeService(defaults: makeIsolatedDefaults())
        let dec = service.currentTheme(now: date(2026, 12, 30))
        #expect(dec?.id == "year_close")
        let jan = service.currentTheme(now: date(2027, 1, 5))
        #expect(jan?.id == "year_close")
    }

    @Test("currentTheme nil in dead months (mid-July)")
    func currentThemeNilMidYear() {
        let service = SeasonalThemeService(defaults: makeIsolatedDefaults())
        let theme = service.currentTheme(now: date(2026, 7, 15))
        #expect(theme == nil)
    }

    @Test("storageKey includes theme id + attributed year")
    func storageKeyShape() {
        let service = SeasonalThemeService(defaults: makeIsolatedDefaults())
        let theme = SeasonalThemeService.curatedThemes.first(where: { $0.id == "conversation_month" })!
        let key = service.storageKey(for: theme, on: date(2026, 10, 10))
        #expect(key == "dq.seasonalTheme.shownAt.conversation_month.2026")
    }

    @Test("storageKey attributes year-wrapping window to start year")
    func storageKeyWrappingAttribution() {
        let service = SeasonalThemeService(defaults: makeIsolatedDefaults())
        let theme = SeasonalThemeService.curatedThemes.first(where: { $0.id == "year_close" })!
        let decKey = service.storageKey(for: theme, on: date(2026, 12, 30))
        let janKey = service.storageKey(for: theme, on: date(2027, 1, 5))
        // Same window (Dec 28 2026 → Jan 8 2027) — same dedup key.
        #expect(decKey == janKey)
        #expect(decKey == "dq.seasonalTheme.shownAt.year_close.2026")
    }

    @Test("isPresentable returns true on fresh install")
    func isPresentableFreshInstall() {
        let service = SeasonalThemeService(defaults: makeIsolatedDefaults())
        let theme = SeasonalThemeService.curatedThemes.first!
        #expect(service.isPresentable(theme, now: date(2026, 10, 10)) == true)
    }

    @Test("markShown flips isPresentable to false for the active window")
    func markShownFlipsPresentable() {
        let service = SeasonalThemeService(defaults: makeIsolatedDefaults())
        let theme = SeasonalThemeService.curatedThemes.first(where: { $0.id == "conversation_month" })!
        let now = date(2026, 10, 10)
        service.markShown(theme, now: now)
        #expect(service.isPresentable(theme, now: now) == false)
    }

    @Test("markShown does NOT block the same theme in the NEXT year's window")
    func markShownDoesNotBlockNextYear() {
        let service = SeasonalThemeService(defaults: makeIsolatedDefaults())
        let theme = SeasonalThemeService.curatedThemes.first(where: { $0.id == "conversation_month" })!
        service.markShown(theme, now: date(2026, 10, 10))
        // Next year's window — should be presentable again
        #expect(service.isPresentable(theme, now: date(2027, 10, 10)) == true)
    }

    @Test("reset clears all per-theme dedup keys")
    func resetClears() {
        let service = SeasonalThemeService(defaults: makeIsolatedDefaults())
        let theme = SeasonalThemeService.curatedThemes.first!
        service.markShown(theme, now: date(2026, 10, 10))
        #expect(service.isPresentable(theme, now: date(2026, 10, 10)) == false)
        service.reset()
        #expect(service.isPresentable(theme, now: date(2026, 10, 10)) == true)
    }

    @Test("shouldSurface respects the probability gate (deterministic RNG)")
    func shouldSurfaceProbabilityGate() {
        let service = SeasonalThemeService(defaults: makeIsolatedDefaults())
        // RNG that always yields ~0.0 — gate ALWAYS fires (0.0 < 0.08)
        var alwaysLow = ZeroRNG()
        #expect(service.shouldSurface(rng: &alwaysLow) == true)
        // RNG that always yields ~0.99 — gate NEVER fires (0.99 > 0.08)
        var alwaysHigh = MaxRNG()
        #expect(service.shouldSurface(rng: &alwaysHigh) == false)
    }

    @Test("each curated theme has reader-register bubble line — no engineering jargon")
    func bubbleLineRegisterStoplist() {
        let stoplist = ["load-bearing", "canonical", "codified", "primitive", "regression", "ADR-",
                       "SAMHSA", "Phase A", "Phase B", "Phase C", "Phase D"]
        for theme in SeasonalThemeService.curatedThemes {
            for forbidden in stoplist {
                #expect(
                    theme.bubbleLine.localizedCaseInsensitiveContains(forbidden) == false,
                    "theme \(theme.id) leaked engineering jargon '\(forbidden)' in bubble line"
                )
            }
        }
    }

    @Test("each curated theme has non-empty bubble line + accessibility label")
    func bubbleLineNonEmpty() {
        for theme in SeasonalThemeService.curatedThemes {
            #expect(theme.bubbleLine.isEmpty == false)
            #expect(theme.accessibilityLabel.isEmpty == false)
            #expect(theme.displayName.isEmpty == false)
        }
    }

    @Test("bubble line length kept under 280 chars (kid-readable)")
    func bubbleLineLengthCap() {
        for theme in SeasonalThemeService.curatedThemes {
            #expect(theme.bubbleLine.count < 280, "theme \(theme.id) bubble line is too long: \(theme.bubbleLine.count) chars")
        }
    }
}

// Test helpers — deterministic RNGs for probability-gate verification.
private struct ZeroRNG: RandomNumberGenerator {
    mutating func next() -> UInt64 { 0 }
}

private struct MaxRNG: RandomNumberGenerator {
    mutating func next() -> UInt64 { .max }
}
