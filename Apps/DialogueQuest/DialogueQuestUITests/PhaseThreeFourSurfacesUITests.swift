//
//  PhaseThreeFourSurfacesUITests.swift
//  DialogueQuestUITests
//
//  Phase 3 + Phase 4 surface smoke tests — verifies that the Performance
//  Booth (row 148) and Anthology Curation (row 158) surfaces are reachable
//  through the navigation flows the kid would actually take. No deep UX
//  assertions; the goal is to guard against a black-screen regression on
//  the two newest adventure / parent surfaces.
//

import XCTest

final class PhaseThreeFourSurfacesUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launchedApp(unlockAdventure: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        // Bypass onboarding so the tab surface is reachable. The flag is
        // read by AppFeature.RootView via ProcessInfo. Optionally also
        // bypass the Adventure tab's session-day gate so the Performance
        // Booth + Voice Crucible affordances surface without driving
        // 3 distinct session bumps from the UI.
        var args: [String] = ["-uiTestSkipOnboarding"]
        if unlockAdventure {
            args.append("-uiTestUnlockAdventure")
        }
        app.launchArguments = args
        app.launch()
        return app
    }

    // MARK: - Performance Booth (Phase 3 row 148)

    @MainActor
    func testAdventureTabExposesPerformanceBoothEntry() {
        let app = launchedApp(unlockAdventure: true)
        app.buttons["Adventure"].tap()
        // The entry accessibilityIdentifier is set in AdventureTabView.
        let entry = app.buttons["performanceBooth.entry"]
        XCTAssertTrue(entry.waitForExistence(timeout: 5),
                      "Performance Booth entry should be visible on the Adventure tab.")
    }

    @MainActor
    func testTappingPerformanceBoothEntryOpensTheSheet() {
        let app = launchedApp(unlockAdventure: true)
        app.buttons["Adventure"].tap()
        let entry = app.buttons["performanceBooth.entry"]
        XCTAssertTrue(entry.waitForExistence(timeout: 5))
        entry.tap()
        // The Performance Booth sheet renders a navigation title with the
        // matching string; we use staticTexts so we don't depend on the
        // exact label cascade.
        let title = app.staticTexts["Performance Booth"]
        XCTAssertTrue(title.waitForExistence(timeout: 3),
                      "Performance Booth sheet should surface its navigation title.")
    }

    @MainActor
    func testPerformanceBoothEmptyStateGuidesTowardPublishing() {
        let app = launchedApp(unlockAdventure: true)
        app.buttons["Adventure"].tap()
        let entry = app.buttons["performanceBooth.entry"]
        XCTAssertTrue(entry.waitForExistence(timeout: 5))
        entry.tap()
        // Without any published trees, the surface renders an empty-state
        // pointing the kid toward the Write tab. The exact copy may evolve;
        // we assert that SOME guidance text is visible (guard against a
        // black-screen regression).
        let emptyStateGuidance = app.staticTexts["Publish a tree first"]
        let alternativeGuidance = app.staticTexts["Hear your scene. Send it anywhere."]
        XCTAssertTrue(
            emptyStateGuidance.waitForExistence(timeout: 3) || alternativeGuidance.exists,
            "Performance Booth should surface either the empty-state guidance or the header copy."
        )
    }

    // MARK: - Anthology Curation (Phase 4 row 158)

    @MainActor
    func testProfileTabExposesAnthologyAndCurationRows() {
        let app = launchedApp()
        app.buttons["Profile"].tap()
        let anthologyRow = app.buttons["profile.anthologyEntry"]
        XCTAssertTrue(anthologyRow.waitForExistence(timeout: 5),
                      "Anthology row should be visible on Profile tab.")
        // Curation row sits beneath Anthology in the same Profile dashboard
        // section — same identifier convention.
        let curationRow = app.buttons["profile.curationEntry"]
        XCTAssertTrue(curationRow.exists,
                      "Curate-collections row should be visible on Profile tab.")
    }

    @MainActor
    func testTappingCurationEntryOpensCurationSurface() {
        let app = launchedApp()
        app.buttons["Profile"].tap()
        let curationRow = app.buttons["profile.curationEntry"]
        XCTAssertTrue(curationRow.waitForExistence(timeout: 5))
        curationRow.tap()
        // The curation surface always renders a header even when there are
        // no collections yet. Either the navigation title OR the empty-state
        // copy surfacing is the pass condition (guards against a black-screen
        // regression when there are no published trees).
        let navTitle = app.staticTexts["Curate anthology"]
        let headerCopy = app.staticTexts["Pick the trees you want to share."]
        let emptyCollectionsCopy = app.staticTexts["No collections yet"]
        XCTAssertTrue(
            navTitle.waitForExistence(timeout: 3) || headerCopy.exists || emptyCollectionsCopy.exists,
            "Curation surface should render either the nav title, the header, or the empty-state copy."
        )
    }
}
