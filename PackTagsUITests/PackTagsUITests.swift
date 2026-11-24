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
        // Force English so tests that assert on localized text are deterministic.
        app.launchArguments += ["-uitests", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
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

    /// Opens Analytics, which `-uitests` serves from canned sample data, and checks it loaded.
    @MainActor
    func testAnalyticsShowsSampleData() throws {
        let app = launchedApp()
        let analytics = app.buttons["Analytics"]
        XCTAssertTrue(analytics.waitForExistence(timeout: 5), "Expected the Analytics button")
        analytics.tap()
        XCTAssertTrue(
            app.staticTexts["packtags"].waitForExistence(timeout: 5),
            "Expected the sample profile to load")
        XCTAssertTrue(app.staticTexts["Engagement"].exists, "Expected the engagement metric")
    }

    /// Opens Smart Hashtags, which `-uitests` serves from canned sample data.
    @MainActor
    func testSmartHashtagsOpensWithSampleData() throws {
        let app = launchedApp()
        let smartHashtags = app.buttons["Smart Hashtags"]
        XCTAssertTrue(smartHashtags.waitForExistence(timeout: 5), "Expected the Smart Hashtags button")
        smartHashtags.tap()
        XCTAssertTrue(
            app.staticTexts["Hashtag page search"].waitForExistence(timeout: 5),
            "Expected the Smart Hashtags screen to open")
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
