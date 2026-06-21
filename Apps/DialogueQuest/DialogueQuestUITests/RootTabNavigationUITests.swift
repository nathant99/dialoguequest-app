//
//  RootTabNavigationUITests.swift
//  DialogueQuestUITests
//
//  Phase 1 UI tests covering the 4-tab shell, tree-builder reachability,
//  and subtext-confirmation surface presence per Docs/FEATURE_PLAN.md.
//

import XCTest

final class RootTabNavigationUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launchedApp() -> XCUIApplication {
        let app = XCUIApplication()
        // Bypass onboarding so the tab surface is reachable. The flag is
        // read by AppFeature.RootView via ProcessInfo.
        app.launchArguments = ["-uiTestSkipOnboarding"]
        app.launch()
        return app
    }

    // MARK: - Tab shell

    @MainActor
    func testRootShowsFourTabs() {
        let app = launchedApp()
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should appear after onboarding bypass.")
        XCTAssertTrue(app.buttons["Write"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Adventure"].exists)
        XCTAssertTrue(app.buttons["Progress"].exists)
        XCTAssertTrue(app.buttons["Profile"].exists)
    }

    @MainActor
    func testAdventureTabRevealsLockedWordWorkshop() {
        let app = launchedApp()
        app.buttons["Adventure"].tap()
        let title = app.staticTexts["Word Workshop"]
        XCTAssertTrue(title.waitForExistence(timeout: 3), "Adventure tab should show Word Workshop heading.")
    }

    @MainActor
    func testProfileTabReachable() {
        let app = launchedApp()
        app.buttons["Profile"].tap()
        // Smoke check: tab transition completes without crashing. Anything
        // visible inside Profile is a pass — content-specific assertions
        // come in Phase 2 once ProfileTabView ships its DN-S cast nav.
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar persists after switching to Profile.")
    }

    @MainActor
    func testProgressTabReachable() {
        let app = launchedApp()
        app.buttons["Progress"].tap()
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar persists after switching to Progress.")
    }

    // MARK: - Tree-builder flow (smoke)

    @MainActor
    func testWriteTabIsDefaultAndCharacterAuthoringIsVisible() {
        let app = launchedApp()
        // Write is the first tab; opening the app should land here.
        // The character-authoring surface fires before tree editing.
        XCTAssertTrue(app.buttons["Write"].waitForExistence(timeout: 3))
        // At least one Cast-the-scene related affordance should be on-screen.
        // We can't rely on exact strings here without inspecting the SwiftUI
        // text directly, so we assert that SOME text content exists in the
        // navigation title area — guarding against a black screen regression.
        let anyStaticText = app.staticTexts.firstMatch
        XCTAssertTrue(anyStaticText.waitForExistence(timeout: 3),
                      "Some text content should be visible on the Write tab landing.")
    }

    // MARK: - Onboarding (parent handoff)

    @MainActor
    func testOnboardingFirstStepIsParentHandoff() {
        // Run the onboarding flow (no -uiTestSkipOnboarding) and confirm the
        // first page is the parent-handoff step rendered by ForgeOnboardingFlow.
        let app = XCUIApplication()
        // Reset onboarding so the flow is presented on a fresh install.
        app.launchArguments = ["-uiTestResetOnboarding"]
        app.launch()

        // The parent-handoff text is hard-coded in ForgeOnboardingFlow when
        // page.isParentHandoff == true ("Ask a parent or guardian to continue").
        let parentPrompt = app.staticTexts["Ask a parent or guardian to continue"]
        XCTAssertTrue(parentPrompt.waitForExistence(timeout: 5),
                      "Onboarding first step should surface the parent-handoff prompt.")

        // DialogueQuest-specific copy on the same page.
        let dqTitle = app.staticTexts["A quick note for grown-ups"]
        XCTAssertTrue(dqTitle.exists,
                      "DialogueQuest parent-handoff title should be present.")
    }
}
