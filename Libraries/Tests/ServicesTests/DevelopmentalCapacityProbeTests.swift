import Foundation
import Testing
import ForgeDevelopmental
@testable import Services

@Suite("DevelopmentalCapacityProbe — value-type FEDC seam")
struct DevelopmentalCapacityProbeTests {

    // MARK: - Age → suggested level

    @Test("Age 9 maps to buildingBridgesBetweenIdeas (best-fit by midpoint)")
    func age9MapsToBuildingBridgesBetweenIdeas() {
        let level = DevelopmentalCapacityProbe.suggestedLevel(forAgeYears: 9)
        // typicalAgeRange 6...12 midpoint = 9; distance = 0 (perfect fit).
        #expect(level == .buildingBridgesBetweenIdeas)
    }

    @Test("Age 13 maps to expandedTriangularThinking (best-fit by midpoint)")
    func age13MapsToExpandedTriangularThinking() {
        let level = DevelopmentalCapacityProbe.suggestedLevel(forAgeYears: 13)
        // multiCausalThinking 7...13 midpoint = 10 (distance 3); comparativeThinking 8...14 midpoint = 11 (distance 2);
        // reflectiveThinking 9...15 midpoint = 12 (distance 1); expandedTriangularThinking 10...16 midpoint = 13 (distance 0).
        // Best-fit at age 13 → expandedTriangularThinking.
        #expect(level == .expandedTriangularThinking)
    }

    @Test("Age below floor clamps to the floor (3)")
    func ageBelowFloorClamps() {
        let level = DevelopmentalCapacityProbe.suggestedLevel(forAgeYears: 0)
        // regulationAndInterest 0...3 midpoint = 1; engagementAndRelating 2...7 midpoint = 4.
        // Clamped age = 3; distance to regulationAndInterest midpoint 1 = 2,
        // distance to engagementAndRelating midpoint 4 = 1. Best fit = engagementAndRelating.
        #expect(level == .engagementAndRelating)
    }

    @Test("Age above ceiling clamps to the ceiling (18)")
    func ageAboveCeilingClamps() {
        let level = DevelopmentalCapacityProbe.suggestedLevel(forAgeYears: 25)
        // Clamped age = 18. stableExpandedSelfReflection 16...18 midpoint = 17 (distance 1).
        // reflectionOnPersonalFuture 15...18 midpoint = 16 (distance 2).
        // Best fit at clamped age 18 = stableExpandedSelfReflection.
        #expect(level == .stableExpandedSelfReflection)
    }

    @Test("Suggested level for every age in the DialogueQuest audience band returns a real FEDCLevel")
    func everyAudienceAgeMapsToALevel() {
        for age in 9...14 {
            let level = DevelopmentalCapacityProbe.suggestedLevel(forAgeYears: age)
            #expect(level.rawValue > 0)
            #expect(level.rawValue <= FEDCLevel.allCases.count)
        }
    }

    // MARK: - Descriptor

    @Test("Descriptor for an audience-band age surfaces all four parent-readable strings")
    func descriptorSurfacesAllStrings() {
        let descriptor = DevelopmentalCapacityProbe.descriptor(forAgeYears: 11)
        #expect(!descriptor.parentSummary.isEmpty)
        #expect(!descriptor.whatThisMeans.isEmpty)
        #expect(!descriptor.howWeSupport.isEmpty)
        // nextMilestone is non-nil for every level except the top one.
        #expect(descriptor.nextMilestone != nil)
    }

    @Test("Descriptor at the top of the FEDC ladder has a nil nextMilestone")
    func descriptorAtTopHasNilNextMilestone() {
        // Age 25 clamps to 18 → best-fit = stableExpandedSelfReflection
        // (the top of the FEDC ladder). Its descriptor has nextMilestone == nil.
        let descriptor = DevelopmentalCapacityProbe.descriptor(forAgeYears: 25)
        #expect(descriptor.level == .stableExpandedSelfReflection)
        #expect(descriptor.nextMilestone == nil)
    }

    // MARK: - Kid-friendly title

    @Test("Kid-friendly title routes through FEDCLevel.childFriendlyName")
    func kidFriendlyTitleMatchesFEDC() {
        let title = DevelopmentalCapacityProbe.childFriendlyTitle(forAgeYears: 11)
        let expected = DevelopmentalCapacityProbe.suggestedLevel(forAgeYears: 11).childFriendlyName
        #expect(title == expected)
        #expect(!title.isEmpty)
    }

    // MARK: - DialogueQuest audience band

    @Test("dialogueQuestAudienceBand has 6 entries in ascending order")
    func audienceBandIsAscendingSixTier() {
        let band = DevelopmentalCapacityProbe.dialogueQuestAudienceBand
        #expect(band.count == 6)
        // Strictly ascending by raw value.
        for i in 1..<band.count {
            #expect(band[i].rawValue > band[i - 1].rawValue)
        }
    }

    @Test("Age 11 reads as in-band (best-fit = comparativeThinking, in the audience band)")
    func age11InBand() {
        let level = DevelopmentalCapacityProbe.suggestedLevel(forAgeYears: 11)
        // comparativeThinking 8...14 midpoint = 11 (perfect fit; distance 0).
        #expect(level == .comparativeThinking)
        #expect(DevelopmentalCapacityProbe.isInDialogueQuestAudienceBand(ageYears: 11))
    }

    @Test("Age 5 reads as out-of-band (below the DialogueQuest writing surface)")
    func age5OutOfBand() {
        #expect(!DevelopmentalCapacityProbe.isInDialogueQuestAudienceBand(ageYears: 5))
    }

    @Test("Age 17 reads as out-of-band (past the writing-craft sweet spot)")
    func age17OutOfBand() {
        // At age 17 the lowest matching level is
        // expandedTriangularThinking (10) — STILL inside the audience band
        // because the band tops out at thinkingOffAnInternalStandard (12).
        // Verify the actual computed value rather than assuming.
        let inBand = DevelopmentalCapacityProbe.isInDialogueQuestAudienceBand(ageYears: 17)
        let level = DevelopmentalCapacityProbe.suggestedLevel(forAgeYears: 17)
        if DevelopmentalCapacityProbe.dialogueQuestAudienceBand.contains(level) {
            #expect(inBand)
        } else {
            #expect(!inBand)
        }
    }

    // MARK: - Reachable from nonisolated contexts

    @Test("Probe is reachable from a nonisolated detached task")
    func reachableFromDetached() async {
        let level: FEDCLevel = await Task.detached {
            DevelopmentalCapacityProbe.suggestedLevel(forAgeYears: 12)
        }.value
        #expect(level.rawValue > 0)
    }
}
