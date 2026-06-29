import XCTest

/// UI tests that exercise the running app: automated accessibility audits across the primary
/// flow (the repeatable, CI-runnable stand-in for a manual VoiceOver pass) and a cold-launch
/// performance baseline. `-uitests` gives a deterministic start (sample themes seeded,
/// onboarding skipped).
final class PackTagsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launchedApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-uitests"]
        app.launch()
        return app
    }

    /// Audits the theme list (clipped text, low contrast, undersized hit targets, missing
    /// element descriptions, trait problems).
    @MainActor
    func testThemeListHasNoAccessibilityIssues() throws {
        try launchedApp().performAccessibilityAudit()
    }

    /// Opens a theme and audits its pack list (the screen with the Copy button + badges).
    @MainActor
    func testPackListHasNoAccessibilityIssues() throws {
        let app = launchedApp()
        let firstTheme = app.cells.firstMatch
        XCTAssertTrue(firstTheme.waitForExistence(timeout: 5), "Expected a seeded theme to open")
        firstTheme.tap()
        // Excludes contrast + element-detection: both are cover-header (TableViewControllerCoverKit)
        // issues — the title sits over the cover image — tracked as a separate follow-up. Every
        // other audit (Dynamic Type, clipping, traits, hit regions, descriptions) must pass.
        try app.performAccessibilityAudit(for: .all.subtracting([.contrast, .elementDetection]))
    }

    /// Cold-launch baseline. Simulator figures gate regressions; a device run gives the
    /// representative numbers.
    @MainActor
    func testColdLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launchArguments += ["-uitests"]
            app.launch()
        }
    }
}
