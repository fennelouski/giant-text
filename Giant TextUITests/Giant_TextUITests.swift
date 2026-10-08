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
        let getStartedButton = app.buttons["GetStartedButton"]
        XCTAssertTrue(getStartedButton.exists, "Get Started button should exist")
        XCTAssertTrue(getStartedButton.isEnabled, "Get Started button should be enabled")
        
        capture(app, name: "Welcome")
        // Test tapping the button
        getStartedButton.tap()
        
        // Verify the welcome screen disappears
        XCTAssertTrue(welcomeScreen.waitForNonExistence(timeout: 5), "Welcome screen should disappear after tapping Get Started")
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
        XCTAssertTrue(welcomeScreen.waitForNonExistence(timeout: 5), "Welcome screen should disappear after tapping outside")
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
        let getStartedButton = app.buttons["GetStartedButton"]
        getStartedButton.tap()
        
        XCTAssertTrue(welcomeScreen.waitForNonExistence(timeout: 5), "Welcome screen should disappear")
        XCTAssertTrue(keyboard.waitForExistence(timeout: 5), "Starting a message should open the editor")
    }

    @MainActor
    func testOverflowHelpAndEditing() throws {
        exerciseOverflowHelpAndEditing()
    }

    @MainActor
    func testOverflowHelpWithLargeTextAndDarkAppearance() throws {
        exerciseOverflowHelpAndEditing(arguments: ["-appearanceMode", "dark", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
    }

    @MainActor
    private func exerciseOverflowHelpAndEditing(arguments: [String] = []) {
        let app = XCUIApplication()
        app.launchArguments = ["--ss-text", "HELLO"] + arguments
        app.launch()

        let menu = app.buttons["OverflowMenu"]
        XCTAssertTrue(menu.waitForExistence(timeout: 5))
        XCTAssertFalse(menu.staticTexts["Options"].exists)
        capture(app, name: "Display")
        menu.tap()
        app.buttons["HelpMenuItem"].tap()
        XCTAssertTrue(app.staticTexts["Open editing actions, Settings, and Help."].waitForExistence(timeout: 5))
        capture(app, name: "Help")
        app.buttons["CloseHelpButton"].tap()

        menu.tap()
        app.buttons["Edit Text"].tap()
        let keyboardTip = app.buttons["Continue"]
        if keyboardTip.waitForExistence(timeout: 2) { keyboardTip.tap() }
        let done = app.buttons["done_editing_accessibility"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        XCTAssertEqual(done.label, "Done editing")
        XCTAssertFalse(done.staticTexts["Done"].exists)
        capture(app, name: "Editor")
        app.buttons["text_animation"].tap()
        XCTAssertTrue(app.buttons["Bloom"].waitForExistence(timeout: 5))
        app.buttons["None"].tap()
        done.tap()
        XCTAssertFalse(app.keyboards.firstMatch.exists)

        menu.tap()
        app.buttons["Settings"].tap()
        let help = app.buttons["SettingsHelpButton"]
        XCTAssertTrue(help.waitForExistence(timeout: 5))
        let animations = ["None", "Bloom", "Jitter", "Ripple"].map { app.buttons[$0] }
        for index in animations.indices {
            for other in animations.indices where other > index {
                XCTAssertFalse(animations[index].frame.intersects(animations[other].frame), "Animation controls must not overlap")
            }
        }
        capture(app, name: "Settings")
        help.tap()
        XCTAssertTrue(app.staticTexts["Open editing actions, Settings, and Help."].waitForExistence(timeout: 5))
    }

    @MainActor
    private func capture(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
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

    @MainActor
    func testGenerateAppStoreScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()

        // Dismiss welcome screen if it appears
        let getStartedButton = app.buttons["GetStartedButton"]
        if getStartedButton.waitForExistence(timeout: 2) {
            getStartedButton.tap()
        }

        // Wait a moment for the welcome screen to disappear
        sleep(1)

        // Tap to enter editing mode
        app.tap()
        sleep(1)

        // Enter placeholder text
        let placeholderTexts = [
            "HELLO",
            "SALE\n50% OFF",
            "OPEN",
            "WELCOME",
            "NEW\nARRIVALS"
        ]

        for (index, text) in placeholderTexts.enumerated() {
            // Type the text
            app.typeText(text)
            sleep(1)

            // Tap "Done" button to exit editing mode
            let doneButton = app.buttons["done_editing_accessibility"]
            if doneButton.exists {
                doneButton.tap()
            }
            sleep(1)

            // Take screenshot
            let screenshot = app.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = "screenshot-\(index + 1)"
            attachment.lifetime = .keepAlways
            add(attachment)

            sleep(1)

            // If not the last item, tap to edit again and clear
            if index < placeholderTexts.count - 1 {
                app.tap()
                sleep(1)

                // Select all and delete
                let clearButton = app.buttons["clear_text_accessibility"]
                if clearButton.exists {
                    clearButton.tap()
                }
                sleep(1)
            }
        }
    }
}
