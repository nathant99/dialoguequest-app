import Foundation
import Testing
import ForgeModels
import ForgeReporting
@testable import Services

@Suite("DialogueQuestProgressReportBuilder — Inputs → ForgeReporting StudentReportData")
struct DialogueQuestProgressReportBuilderTests {

    private func sampleInputs(
        published: Int = 5,
        streak: Int = 3,
        badges: Int = 4,
        activeDays: Int = 7,
        averageVoice: Double = 0.72,
        confirmedSubtext: Int = 8,
        branchesReflected: Int = 6
    ) -> DialogueQuestProgressReportBuilder.Inputs {
        DialogueQuestProgressReportBuilder.Inputs(
            studentName: "Iris",
            publishedTreeCount: published,
            currentStreak: streak,
            longestStreak: streak,
            badgesEarned: badges,
            activeDays: activeDays,
            totalXP: published * 75,
            averageVoiceMatchScore: averageVoice,
            confirmedSubtextCount: confirmedSubtext,
            branchesReflectedCount: branchesReflected
        )
    }

    @Test("Fresh-install inputs (zero everything) returns nil")
    func freshInstallReturnsNil() {
        let inputs = DialogueQuestProgressReportBuilder.Inputs(
            studentName: "Iris",
            publishedTreeCount: 0,
            currentStreak: 0,
            longestStreak: 0,
            badgesEarned: 0,
            activeDays: 0,
            totalXP: 0,
            averageVoiceMatchScore: 0,
            confirmedSubtextCount: 0,
            branchesReflectedCount: 0
        )
        #expect(DialogueQuestProgressReportBuilder().build(from: inputs) == nil)
    }

    @Test("Any-activity inputs build a non-nil report")
    func anyActivityProducesReport() {
        let report = DialogueQuestProgressReportBuilder().build(from: sampleInputs())
        #expect(report != nil)
    }

    @Test("Report carries the 4 canonical standards in canonical order")
    func reportShipsFourCanonicalStandards() {
        let report = DialogueQuestProgressReportBuilder().build(from: sampleInputs())
        #expect(report?.standardProficiencies.count == 4)
        let codes = report?.standardProficiencies.map(\.standard.code) ?? []
        #expect(codes == [
            "CCSS.ELA-Literacy.W.6-8.3.B",
            "CCSS.ELA-Literacy.RL.6-8.6",
            "NCAS.TH:Cr3",
            "NCAS.LA:Cr2"
        ])
    }

    @Test("Voice-match score clamps to 0...1 at the input boundary")
    func voiceMatchClamps() {
        let high = sampleInputs(averageVoice: 1.5)
        #expect(high.averageVoiceMatchScore == 1.0)
        let low = sampleInputs(averageVoice: -0.5)
        #expect(low.averageVoiceMatchScore == 0.0)
    }

    @Test("Writing-standard proficiency tracks the voice-match average")
    func writingProficiencyMatchesVoice() throws {
        let inputs = sampleInputs(averageVoice: 0.8)
        let report = try #require(DialogueQuestProgressReportBuilder().build(from: inputs))
        let writing = try #require(report.standardProficiencies.first { $0.standard.code == "CCSS.ELA-Literacy.W.6-8.3.B" })
        #expect(writing.percentage == 80.0)
        #expect(writing.proficiency == .meeting)
        #expect(writing.attemptCount == inputs.publishedTreeCount)
    }

    @Test("Reading-standard proficiency tracks subtext-confirmation density")
    func readingProficiencyMatchesSubtext() throws {
        // 8 subtext confirmations across 5 trees → 8/5 * 50 = 80%
        let inputs = sampleInputs(published: 5, confirmedSubtext: 8)
        let report = try #require(DialogueQuestProgressReportBuilder().build(from: inputs))
        let reading = try #require(report.standardProficiencies.first { $0.standard.code == "CCSS.ELA-Literacy.RL.6-8.6" })
        #expect(reading.percentage == 80.0)
        #expect(reading.attemptCount == 8)
    }

    @Test("Standards proficiency percentage caps at 100")
    func proficiencyCapsAt100() throws {
        // 100 subtext / 1 tree → 100/1 * 50 = 5000 → capped at 100
        let inputs = sampleInputs(published: 1, confirmedSubtext: 100)
        let report = try #require(DialogueQuestProgressReportBuilder().build(from: inputs))
        let reading = try #require(report.standardProficiencies.first { $0.standard.code == "CCSS.ELA-Literacy.RL.6-8.6" })
        #expect(reading.percentage <= 100.0)
    }

    @Test("XP + sessions + streak populate from inputs")
    func topLevelMetricsPopulate() throws {
        let inputs = sampleInputs(published: 7, streak: 4, activeDays: 10)
        let report = try #require(DialogueQuestProgressReportBuilder().build(from: inputs))
        #expect(report.activitiesCompleted == 7)
        #expect(report.currentStreak == 4)
        #expect(report.activeDays == 10)
        #expect(report.totalXP == 7 * 75)
        #expect(report.totalSessions == 10)
    }

    @Test("averageSessionMinutes derives sensibly from active days + duration estimate")
    func averageSessionMinutesIsSensible() throws {
        // 5 published trees × 10 min each = 50 total minutes; activeDays
        // 5 → averageSessionMinutes = 10.
        let inputs = sampleInputs(published: 5, activeDays: 5)
        let report = try #require(DialogueQuestProgressReportBuilder().build(from: inputs))
        #expect(report.averageSessionMinutes == 10.0)
    }

    @Test("Grade-level default is seventh (mid age 9-14)")
    func gradeLevelDefaultIsSeventh() throws {
        let report = try #require(DialogueQuestProgressReportBuilder().build(from: sampleInputs()))
        #expect(report.gradeLevel == .seventh)
    }

    @Test("Canonical standards include both CCSS + NCAS frameworks")
    func canonicalStandardsCoverFrameworks() {
        let frameworks = Set(DialogueQuestProgressReportBuilder.canonicalStandards.map(\.standard))
        #expect(frameworks.contains(.ccss))
        #expect(frameworks.contains(.ncas))
    }

    @Test("All canonical standard descriptions stay in reader-facing register")
    func standardDescriptionsStayReaderFacing() {
        let stoplist = ["load-bearing", "codified", "canonical", "primitive",
                        "SAMHSA", "ADR-", "Phase 1", "Phase 2"]
        for standard in DialogueQuestProgressReportBuilder.canonicalStandards {
            let body = standard.description.lowercased()
            for token in stoplist {
                #expect(!body.contains(token.lowercased()),
                        "Standard \(standard.code) description leaks token '\(token)': \(standard.description)")
            }
        }
    }
}
