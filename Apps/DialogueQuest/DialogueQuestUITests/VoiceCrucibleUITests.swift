//
//  VoiceCrucibleUITests.swift
//  DialogueQuestUITests
//
//  Phase 2 row 131 surface smoke tests — verifies that the Voice Crucible
//  adventure mode (Brogue / Glance / Rest / Sprig / Weigh voice picker +
//  writing surface + scored surface) is reachable through the navigation
//  flow the kid would actually take. Mirrors the
//  PhaseThreeFourSurfacesUITests.swift pattern: no deep UX assertions; the
//  goal is to guard against a black-screen regression on this adventure
//  surface, especially under future Adventure-tab redesigns.
//

import XCTest

final class VoiceCrucibleUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launchedApp(unlockAdventure: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        // Bypass onboarding so the tab surface is reachable. The flag is
        // read by AppFeature.RootView via ProcessInfo. Also bypass the
        // Adventure tab's 3-distinct-session-day unlock gate so the
        // Voice Crucible affordance surfaces without driving session
        // bumps from the UI.
        var args: [String] = ["-uiTestSkipOnboarding"]
        if unlockAdventure {
            args.append("-uiTestUnlockAdventure")
        }
        app.launchArguments = args
        app.launch()
        return app
    }

    // MARK: - Entry (Phase 2 row 131)

    @MainActor
    func testAdventureTabExposesVoiceCrucibleEntry() {
        let app = launchedApp()
        app.buttons["Adventure"].tap()
        // The entry accessibilityIdentifier is set in AdventureTabView.
        let entry = app.buttons["crucible.entry"]
        XCTAssertTrue(entry.waitForExistence(timeout: 5),
                      "Voice Crucible entry should be visible on the Adventure tab.")
    }

    @MainActor
    func testTappingVoiceCrucibleEntryOpensTheSheet() {
        let app = launchedApp()
        app.buttons["Adventure"].tap()
        let entry = app.buttons["crucible.entry"]
        XCTAssertTrue(entry.waitForExistence(timeout: 5))
        entry.tap()
        // The Voice Crucible sheet renders a navigation title with the
        // matching string; we use staticTexts so we don't depend on the
        // exact label cascade.
        let title = app.staticTexts["Voice Crucible"]
        XCTAssertTrue(title.waitForExistence(timeout: 3),
                      "Voice Crucible sheet should surface its navigation title.")
    }

    // MARK: - Cast picker

    @MainActor
    func testVoiceCrucibleSurfacesAllFiveLessonsCastVoices() {
        let app = launchedApp()
        app.buttons["Adventure"].tap()
        let entry = app.buttons["crucible.entry"]
        XCTAssertTrue(entry.waitForExistence(timeout: 5))
        entry.tap()
        // The cast picker renders a card per LESSONS-layer cast member
        // (Brogue / Glance / Rest / Sprig / Weigh). Each card's display
        // name comes through CastVoiceRegistry.displayName(for:).
        // We assert that ALL FIVE display names are reachable on-screen
        // (with scroll fallback so we don't depend on which ones are
        // above the fold).
        let castDisplayNames = ["Brogue", "Glance", "Rest", "Sprig", "Weigh"]
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 3),
                      "Voice Crucible cast picker should render inside a scroll view.")
        for name in castDisplayNames {
            let label = app.staticTexts[name]
            // First check if visible already; if not, scroll a bit and re-check.
            if !label.exists {
                scrollView.swipeUp()
            }
            XCTAssertTrue(label.waitForExistence(timeout: 2),
                          "Cast picker should surface the '\(name)' voice.")
        }
    }

    // MARK: - Writing surface

    @MainActor
    func testPickingACastVoiceRevealsTheWritingSurface() {
        let app = launchedApp()
        app.buttons["Adventure"].tap()
        let entry = app.buttons["crucible.entry"]
        XCTAssertTrue(entry.waitForExistence(timeout: 5))
        entry.tap()
        // Tap any cast voice card to advance to .writing(targetCastID:).
        // The card's display name is the kid-facing label; tap by that.
        let brogueLabel = app.staticTexts["Brogue"]
        XCTAssertTrue(brogueLabel.waitForExistence(timeout: 3))
        brogueLabel.tap()
        // The writing surface ships a "Target voice: <Name>" header line
        // and a Submit button (disabled until the kid types one word).
        let header = app.staticTexts["Target voice: Brogue"]
        let submit = app.buttons["Submit"]
        XCTAssertTrue(
            header.waitForExistence(timeout: 3) || submit.waitForExistence(timeout: 3),
            "Voice Crucible writing surface should render either the target-voice header or a Submit button."
        )
        // Submit must be present AND disabled when no text has been typed.
        // (Empty-draft submit guard is part of the machine's contract.)
        XCTAssertTrue(submit.exists,
                      "Submit button should be visible on the writing surface.")
        XCTAssertFalse(submit.isEnabled,
                       "Submit button should be disabled when the draft is empty.")
    }
}
