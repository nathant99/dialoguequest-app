import Testing
@testable import Services
import Models

/// Closes Phase Accessibility & Trauma-Informed Polish checkbox (per
/// `Docs/AUDIT_TRAUMA_INFORMED_GATE_REVIEW_2026-06-23.md`).
///
/// Tests assert the ADVISORY-only posture — the gate never blocks a kid's
/// draft and never grades content. The lexical surface is deliberately
/// narrow; common conflict-craft words MUST pass through silently.
@Suite("TraumaAxisAdvisoryService")
struct TraumaAxisAdvisoryServiceTests {

    let advisor = TraumaAxisAdvisoryService()

    @Test("Common conflict-craft writing passes through silently")
    func conflictCraftPassesThrough() {
        // These are the bread-and-butter of dialogue-craft authoring.
        // Surfacing an advisory on these would BREAK the app.
        let craft = [
            "I'm fine.",
            "She pushed past him without looking back.",
            "Don't go.",
            "He hurt me. I want him to know how it felt.",
            "We lost the game.",
            "I don't want to talk about it.",
            "She slammed the door.",
            "He cried out, then laughed.",
            "I miss the way it was before.",
            "Why did you leave?"
        ]
        for line in craft {
            #expect(advisor.inspect(line: line, mood: .quietConflict) == nil,
                    "advisory should NOT fire on craft writing: \(line)")
        }
    }

    @Test("Strong crisis cues fire .crisisCue band")
    func crisisCuesFireStrongBand() {
        let cues = [
            "I want to die.",
            "I'm going to kill myself.",
            "There's no point living.",
            "I hurt myself last night.",
            "He hits me when no one's looking."
        ]
        for line in cues {
            #expect(advisor.inspect(line: line, mood: nil) == .crisisCue,
                    "crisis cue line should fire .crisisCue: \(line)")
        }
    }

    @Test("Tender themes fire .tenderTheme band, not .crisisCue")
    func tenderThemesFireSofterBand() {
        let themes = [
            "Mom is gone forever.",
            "I'm worthless.",
            "Nobody listens to me.",
            "She died last summer.",
            "Everyone leaves me."
        ]
        for line in themes {
            #expect(advisor.inspect(line: line, mood: nil) == .tenderTheme,
                    "tender-theme line should fire .tenderTheme: \(line)")
        }
    }

    @Test("Mood alone (without a line cue) never fires an advisory")
    func moodAloneDoesNotFire() {
        // Every mood — including the canonical hard scene markers — must
        // pass through cleanly when the LINE itself is benign. This is
        // the gate that lets a kid write a quiet-conflict scene without
        // the banner appearing on every keystroke.
        for mood in DialogueMood.allCases {
            #expect(advisor.inspect(line: "Hello there.", mood: mood) == nil,
                    "mood \(mood) alone should not fire an advisory")
        }
        #expect(advisor.inspect(line: "Hello there.", mood: nil) == nil)
    }

    @Test("Empty + whitespace line never fires an advisory")
    func emptyLineDoesNotFire() {
        #expect(advisor.inspect(line: "", mood: nil) == nil)
        #expect(advisor.inspect(line: "   ", mood: nil) == nil)
        #expect(advisor.inspect(line: "\n\n", mood: nil) == nil)
    }

    @Test("Case-insensitive matching on crisis cues")
    func caseInsensitiveMatching() {
        #expect(advisor.inspect(line: "I WANT TO DIE", mood: nil) == .crisisCue)
        #expect(advisor.inspect(line: "I Want To Die", mood: nil) == .crisisCue)
        #expect(advisor.inspect(line: "she DIED last week", mood: nil) == .tenderTheme)
    }

    @Test("Crisis band foregrounds resources; tender band does not")
    func bandsDifferentiateResourceForeground() {
        let crisis: TraumaAxisAdvisoryService.Advisory = .crisisCue
        let tender: TraumaAxisAdvisoryService.Advisory = .tenderTheme
        #expect(crisis.foregroundsResources == true)
        #expect(tender.foregroundsResources == false)
    }

    @Test("Banner copy stays in age-9-14 SAMHSA TIP 57 register (validate-then-inform)")
    func bannerCopyRegisterStoplist() {
        let banned = [
            "load-bearing", "codified", "ADR-", "Phase A",
            "engineer", "PII", "COPPA",
            "concerning content",
            "graded", "wrong", "incorrect", "bad writing"
        ]
        for advisory: TraumaAxisAdvisoryService.Advisory in [.crisisCue, .tenderTheme] {
            for token in banned {
                let combined = "\(advisory.bannerTitle) \(advisory.bannerBody)".lowercased()
                #expect(!combined.contains(token.lowercased()),
                        "banner copy must not contain '\(token)'")
            }
        }
    }

    @Test("Lexical surface stays narrow — single-word verbs do not fire")
    func narrowLexicalSurface() {
        // The whole point: dialogue craft IS conflict craft. Single-word
        // verbs like "kill" / "die" / "hurt" / "cry" must NEVER fire on
        // their own. Only multi-word phrases that explicitly name a
        // crisis or tender theme cross the surface.
        let nearby = [
            "Time to kill before the bell.",
            "The plant might die if we forget it.",
            "It really hurt when I lost.",
            "She started to cry over the painting."
        ]
        for line in nearby {
            #expect(advisor.inspect(line: line, mood: .quietConflict) == nil,
                    "single-word adjacent token should not fire: \(line)")
        }
    }

    @Test("Banner titles + bodies are nonempty for every band")
    func everyBandHasCopy() {
        for advisory: TraumaAxisAdvisoryService.Advisory in [.crisisCue, .tenderTheme] {
            #expect(!advisory.bannerTitle.isEmpty)
            #expect(!advisory.bannerBody.isEmpty)
        }
    }
}
