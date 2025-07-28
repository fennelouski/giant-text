//
//  Giant_TextUITests.swift
//  Giant TextUITests
//
//  Created by Nathan Fennel on 7/27/25.
//

import XCTest

final class Giant_TextUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testWelcomeScreenTouchHandling() throws {
        // Reset UserDefaults to ensure welcome screen shows
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-welcome-screen"]
        app.launch()
        
        // Wait for app to launch and welcome screen to appear
        let welcomeScreen = app.otherElements["WelcomeView"]
        XCTAssertTrue(welcomeScreen.waitForExistence(timeout: 5), "Welcome screen should appear")
        
        // Test that we can tap the "Get Started" button
        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists, "Get Started button should exist")
        XCTAssertTrue(getStartedButton.isEnabled, "Get Started button should be enabled")
        
        // Test tapping the button
        getStartedButton.tap()
        
        // Verify the welcome screen disappears
        XCTAssertFalse(welcomeScreen.exists, "Welcome screen should disappear after tapping Get Started")
    }
    
    @MainActor
    func testWelcomeScreenScrolling() throws {
        // Reset UserDefaults to ensure welcome screen shows
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-welcome-screen"]
        app.launch()
        
        // Wait for welcome screen to appear
        let welcomeScreen = app.otherElements["WelcomeView"]
        XCTAssertTrue(welcomeScreen.waitForExistence(timeout: 5), "Welcome screen should appear")
        
        // Test scrolling by attempting to scroll the welcome screen
        let scrollView = welcomeScreen.scrollViews.firstMatch
        XCTAssertTrue(scrollView.exists, "ScrollView should exist in welcome screen")
        
        // Perform a scroll gesture
        scrollView.swipeUp()
        
        // Verify the scroll view is still accessible
        XCTAssertTrue(scrollView.exists, "ScrollView should still exist after scrolling")
    }
    
    @MainActor
    func testWelcomeScreenDismissGesture() throws {
        // Reset UserDefaults to ensure welcome screen shows
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-welcome-screen"]
        app.launch()
        
        // Wait for welcome screen to appear
        let welcomeScreen = app.otherElements["WelcomeView"]
        XCTAssertTrue(welcomeScreen.waitForExistence(timeout: 5), "Welcome screen should appear")
        
        // Test tapping outside the welcome screen to dismiss
        // Tap in the top-left corner of the screen (outside the welcome screen)
        let screen = app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1))
        screen.tap()
        
        // Verify the welcome screen disappears
        XCTAssertFalse(welcomeScreen.exists, "Welcome screen should disappear after tapping outside")
    }
    
    @MainActor
    func testWelcomeScreenContentInteraction() throws {
        // Reset UserDefaults to ensure welcome screen shows
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-welcome-screen"]
        app.launch()
        
        // Wait for welcome screen to appear
        let welcomeScreen = app.otherElements["WelcomeView"]
        XCTAssertTrue(welcomeScreen.waitForExistence(timeout: 5), "Welcome screen should appear")
        
        // Test that we can interact with content elements
        let appLogo = welcomeScreen.images["AppLogo"]
        XCTAssertTrue(appLogo.exists, "App logo should exist")
        
        let titleText = welcomeScreen.staticTexts["Welcome to Giant Text!"]
        XCTAssertTrue(titleText.exists, "Title text should exist")
        
        // Test tapping on the welcome screen content (should not dismiss)
        titleText.tap()
        
        // Verify the welcome screen is still visible
        XCTAssertTrue(welcomeScreen.exists, "Welcome screen should still be visible after tapping content")
    }
    
    @MainActor
    func testWelcomeScreenKeyboardNotShown() throws {
        // Reset UserDefaults to ensure welcome screen shows
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-welcome-screen"]
        app.launch()
        
        // Wait for welcome screen to appear
        let welcomeScreen = app.otherElements["WelcomeView"]
        XCTAssertTrue(welcomeScreen.waitForExistence(timeout: 5), "Welcome screen should appear")
        
        // Verify that no keyboard is shown
        let keyboard = app.keyboards.firstMatch
        XCTAssertFalse(keyboard.exists, "Keyboard should not be shown when welcome screen is displayed")
        
        // Test tapping the Get Started button
        let getStartedButton = app.buttons["Get Started"]
        getStartedButton.tap()
        
        // Verify welcome screen disappears and no keyboard appears
        XCTAssertFalse(welcomeScreen.exists, "Welcome screen should disappear")
        XCTAssertFalse(keyboard.exists, "Keyboard should still not be shown after dismissing welcome screen")
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
