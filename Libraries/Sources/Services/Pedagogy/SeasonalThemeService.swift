import Foundation
import ForgeEvents

/// Advisory seasonal-theme surface for DialogueQuest. Surfaces a
/// kid-readable writing prompt at the Write tab when one of a small
/// curated set of writing-friendly windows is active in the calendar.
///
/// **What this is**: a thin consumer of `ForgeEvents.ForgeEventDateRule`
/// used to decide "is today inside a window worth surfacing a writing
/// theme?". The themes themselves are domain-specific to dialogue craft
/// — none of the 41 built-in `ForgeEvents` events fit because their
/// register is celebration-oriented (Halloween, Christmas, etc.). The
/// service uses ForgeEvents' date-rule primitives only.
///
/// **What this is NOT**: a content gate, a grader, or a behavioral
/// change. The bubble line surfaces in the existing mutually-exclusive
/// `rareVoiceCraftTip` slot at a lower probability than the 4 existing
/// paths so it stays rare-but-special. Off the active window, the
/// service returns nil and the slot routes through the existing paths.
///
/// **Date-rule shape**: each theme uses
/// `ForgeEventDateRule.fixedRange(...)` so the window covers a calendar
/// span (typically 2-3 weeks) — long enough for the kid to encounter
/// the prompt at least once during a normal play cadence. No nth-
/// weekday / lunar-date / lookup-table complexity because writing
/// themes don't need that precision.
///
/// **Per-theme dedup**: a UserDefaults key
/// (`dq.seasonalTheme.shownAt.<themeID>.<yearTag>`) ensures the kid
/// sees the theme bubble at most once per active window. Year-tag is
/// the window's year-of-windowStart so the same theme can re-surface
/// in subsequent years.
///
/// **Register**: bubble lines stay in the age-9-14 reader register —
/// no engineering jargon (per `.claude/rules/distributed-narrative.md`
/// § Chapter content register stoplist; no "load-bearing" / "canonical"
/// / "primitive" / "codified" etc.).
@MainActor
public final class SeasonalThemeService {
    public static let shared = SeasonalThemeService()

    /// Probability that the bubble fires when an active theme is found
    /// AND the per-theme dedup is clear. Matches the lower bound of
    /// the existing slot ordering (mood callback + voice-pattern
    /// callback both fire at 0.08).
    public nonisolated static let presentationProbability: Double = 0.08

    /// Storage-key prefix exposed for tests + future audit surfaces.
    public nonisolated static let storageKeyPrefix: String = "dq.seasonalTheme.shownAt."

    private let defaults: UserDefaults
    private let calendar: Calendar

    public init(
        defaults: UserDefaults = .standard,
        calendar: Calendar = .current
    ) {
        self.defaults = defaults
        self.calendar = calendar
    }

    /// All curated themes — pure value-type, safe to surface from any
    /// isolation context. 4 narrowly-scoped windows that each touch a
    /// distinct dialogue-craft register. Spaced ~3 months apart so a
    /// kid playing through the year encounters one rare-but-special
    /// seasonal-theme bubble per season at most.
    public nonisolated static let curatedThemes: [SeasonalTheme] = [
        // Late September → late October — anchored loosely to
        // National Dialogue Day (Oct 16) without naming it. Window
        // catches the back-to-school write-more-this-year vibe.
        SeasonalTheme(
            id: "conversation_month",
            displayName: "Conversation Month",
            // Sept 26 → Oct 26; event-day Oct 16
            dateRule: .fixedRange(
                startMonth: 9, startDay: 26,
                endMonth: 10, endDay: 26,
                eventDayMonth: 10, eventDayDay: 16
            ),
            bubbleLine: "It's Conversation Month — try a scene where two characters disagree without anyone raising their voice. Quiet conflict is a craft you can practice.",
            accessibilityLabel: "Conversation month writing prompt: try a scene with quiet disagreement."
        ),
        // Mid-March around World Storytelling Day (Mar 20). Window
        // spans a couple weeks so kids encounter it across normal play.
        SeasonalTheme(
            id: "storytelling_days",
            displayName: "Storytelling Days",
            // Mar 14 → Mar 28; event-day Mar 20
            dateRule: .fixedRange(
                startMonth: 3, startDay: 14,
                endMonth: 3, endDay: 28,
                eventDayMonth: 3, eventDayDay: 20
            ),
            bubbleLine: "Storytelling days are here — pick a character and write a line they'd only say if no one else was in the room. That's where their real voice lives.",
            accessibilityLabel: "Storytelling days writing prompt: write a private line for a character."
        ),
        // Late May → mid-June — anchored loosely on the start of
        // summer writers' camp / the "what story will you write this
        // summer?" register. Event-day June 1 captures the
        // first-day-of-summer feel for most school calendars without
        // naming a holiday. Pairs cleanly with the kid's looser summer
        // play cadence so a seasonal-theme bubble can land before the
        // long break.
        SeasonalTheme(
            id: "summer_writers_days",
            displayName: "Summer Writers' Days",
            // May 25 → June 14; event-day June 1
            dateRule: .fixedRange(
                startMonth: 5, startDay: 25,
                endMonth: 6, endDay: 14,
                eventDayMonth: 6, eventDayDay: 1
            ),
            bubbleLine: "Summer Writers' Days are here — pick a character who's about to spend a long afternoon doing nothing, and write the small line they say when no one expects them to say anything.",
            accessibilityLabel: "Summer Writers' Days writing prompt: write a quiet line for a character with nothing to do."
        ),
        // Late December → early January. Reflective register; pair
        // with the welcome-back banner cadence so the kid sees both
        // signals in their seasonal return.
        SeasonalTheme(
            id: "year_close",
            displayName: "Author Your Year",
            // Dec 28 → Jan 8; event-day Jan 1 (year-wrapping rule)
            dateRule: .fixedRange(
                startMonth: 12, startDay: 28,
                endMonth: 1, endDay: 8,
                eventDayMonth: 1, eventDayDay: 1
            ),
            bubbleLine: "End-of-year writers' moment — write a short conversation that holds a feeling from this year you want to carry forward.",
            accessibilityLabel: "Year-close writing prompt: write a conversation that holds a memorable feeling."
        )
    ]

    /// The currently active theme (or nil if no curated window covers
    /// `now`). Pure value-type read; safe to call from any isolation
    /// context.
    public nonisolated func currentTheme(now: Date = .now) -> SeasonalTheme? {
        Self.curatedThemes.first(where: { $0.dateRule.isActive(on: now) })
    }

    /// Resolve the dedup storage key for a theme on a given date.
    /// Includes the start-of-window year so the same theme can
    /// re-surface in subsequent years' windows.
    public nonisolated func storageKey(for theme: SeasonalTheme, on date: Date) -> String {
        let year = calendar.component(.year, from: date)
        // Year-wrapping windows (Dec → Jan) attribute to the start
        // year (Dec) consistently so the dedup stays stable across
        // the new-year boundary inside the same window.
        let month = calendar.component(.month, from: date)
        let attributedYear: Int
        if case let .fixedRange(startMonth, _, endMonth, _, _, _) = theme.dateRule, startMonth > endMonth, month <= endMonth {
            attributedYear = year - 1
        } else {
            attributedYear = year
        }
        return "\(Self.storageKeyPrefix)\(theme.id).\(attributedYear)"
    }

    /// True when the theme has not yet been shown in this active
    /// window. The dashboard/Write tab consults this before deciding
    /// whether the seasonal theme is eligible to fill the bubble slot.
    public func isPresentable(_ theme: SeasonalTheme, now: Date = .now) -> Bool {
        let key = storageKey(for: theme, on: now)
        return defaults.object(forKey: key) == nil
    }

    /// Mark the theme as shown — call AFTER the bubble surfaces. This
    /// stamps the dedup key with the current timestamp so future reads
    /// of `isPresentable(_:)` return false until the next window opens.
    public func markShown(_ theme: SeasonalTheme, now: Date = .now) {
        let key = storageKey(for: theme, on: now)
        defaults.set(now, forKey: key)
    }

    /// Probability gate used by the bubble-slot selector. Pure read;
    /// the caller stamps `markShown(_:)` AFTER it actually surfaces the
    /// bubble so a probabilistic skip doesn't burn the window.
    public nonisolated func shouldSurface<RNG: RandomNumberGenerator>(rng: inout RNG) -> Bool {
        Double.random(in: 0..<1, using: &rng) < Self.presentationProbability
    }

    /// Reset persisted state — exposed for tests + future parental
    /// "reset progress" surface. Production paths don't call this.
    public func reset() {
        for theme in Self.curatedThemes {
            let prefix = "\(Self.storageKeyPrefix)\(theme.id)."
            for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(prefix) {
                defaults.removeObject(forKey: key)
            }
        }
    }
}

/// A single curated theme — id + display name + date-rule (delegates
/// to `ForgeEvents.ForgeEventDateRule.isActive`) + reader-facing
/// bubble line + accessibility label. Sendable nonisolated so the
/// bubble-slot decision can flow across the actor boundary cheaply.
public nonisolated struct SeasonalTheme: Sendable, Identifiable, Equatable {
    public let id: String
    public let displayName: String
    public let dateRule: ForgeEventDateRule
    public let bubbleLine: String
    public let accessibilityLabel: String

    public init(
        id: String,
        displayName: String,
        dateRule: ForgeEventDateRule,
        bubbleLine: String,
        accessibilityLabel: String
    ) {
        self.id = id
        self.displayName = displayName
        self.dateRule = dateRule
        self.bubbleLine = bubbleLine
        self.accessibilityLabel = accessibilityLabel
    }

    public nonisolated static func == (lhs: SeasonalTheme, rhs: SeasonalTheme) -> Bool {
        lhs.id == rhs.id
            && lhs.displayName == rhs.displayName
            && lhs.bubbleLine == rhs.bubbleLine
            && lhs.accessibilityLabel == rhs.accessibilityLabel
    }
}
