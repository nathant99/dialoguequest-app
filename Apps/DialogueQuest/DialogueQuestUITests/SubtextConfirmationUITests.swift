//
//  SubtextConfirmationUITests.swift
//  DialogueQuestUITests
//
//  Phase 1 UI test for the Subtext panel confirm-flow per
//  Docs/FEATURE_PLAN.md § Quality. Uses the `-uiTestSeedSubtextLine`
//  launch arg (declared in `AppFeature.WriteTabUITestSeed`) to bypass
//  character authoring and land the kid in `.editingTree` with one
//  populated line + `.quietConflict` mood, which surfaces a non-empty
//  fallback subtext immediately.
//

import XCTest

final class SubtextConfirmationUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launchedApp() -> XCUIApplication {
        let app = XCUIApplication()
        // Both flags required:
        //   -uiTestSkipOnboarding : bypass the 6-page onboarding flow
        //   -uiTestSeedSubtextLine: pre-seed the tree-builder with 2
        //                           characters + 1 populated line in
        //                           `.editingTree` stage
        app.launchArguments = ["-uiTestSkipOnboarding", "-uiTestSeedSubtextLine"]
        app.launch()
        return app
    }

    // MARK: - Happy path

    @MainActor
    func testSubtextPanelReachableWithSeed() {
        let app = launchedApp()
        // The seed lands the kid on the Write tab. The panel's heading
        // appears as soon as the SwiftUI body lays out.
        let heading = app.staticTexts["subtext.panel.heading"]
        XCTAssertTrue(heading.waitForExistence(timeout: 5),
                      "Subtext panel heading should appear once seeded state lands.")

        // The panel may briefly show the "Patter is listening" spinner
        // before the fallback analysis lands. Wait for the message text
        // (the fallback inferredSubtext) to appear.
        let message = app.staticTexts["subtext.panel.message"]
        XCTAssertTrue(message.waitForExistence(timeout: 5),
                      "Inferred subtext message should surface from the fallback path.")
    }

    @MainActor
    func testSubtextConfirmShowsBadge() {
        let app = launchedApp()
        let confirmButton = app.buttons["subtext.panel.confirm"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5),
                      "Confirm button should be reachable in the seeded state.")
        confirmButton.tap()

        // After confirmation, the panel renders the persistent
        // "Saved as a confirmed subtext." badge whenever the selected
        // line's id is in `machine.confirmedSubtextLineIDs`. We use the
        // panel-local badge (always in viewport) rather than the
        // NodeInspector's "Subtext" section (which Form lazy-loads
        // off-screen and is unreliable to find via XCUITest).
        let badge = app.staticTexts["subtext.panel.confirmedBadge"]
        XCTAssertTrue(badge.waitForExistence(timeout: 5),
                      "Confirmation badge should surface after tapping Confirm.")
    }

    @MainActor
    func testSubtextRejectRemovesConfirmationBadge() {
        let app = launchedApp()
        let confirmButton = app.buttons["subtext.panel.confirm"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
        confirmButton.tap()

        // Confirm landed — the badge exists.
        let badge = app.staticTexts["subtext.panel.confirmedBadge"]
        XCTAssertTrue(badge.waitForExistence(timeout: 5))

        // Reject. `rejectSubtext` clears `inferredSubtext` to nil and
        // removes the line id from `confirmedSubtextLineIDs`, so the badge
        // disappears.
        let rejectButton = app.buttons["subtext.panel.reject"]
        XCTAssertTrue(rejectButton.waitForExistence(timeout: 2))
        rejectButton.tap()

        // Poll briefly for the badge to disappear (state change is on the
        // main run loop; XCUITest needs a small window to re-query).
        let badgeGone = NSPredicate(format: "exists == false")
        let exp = expectation(for: badgeGone, evaluatedWith: badge, handler: nil)
        wait(for: [exp], timeout: 2)
    }
}
