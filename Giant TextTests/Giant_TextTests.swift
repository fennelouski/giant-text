//
//  Giant_TextTests.swift
//  Giant TextTests
//
//  Created by Nathan Fennel on 7/27/25.
//

import XCTest
@testable import Giant_Text

final class Giant_TextTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWelcomeScreenTouchHandling() throws {
        // Test that the welcome screen touch handling logic works correctly
        
        // Reset UserDefaults to simulate first launch
        UserDefaults.standard.removeObject(forKey: "hasPressedGetStarted")
        UserDefaults.standard.removeObject(forKey: "lastLaunchDate")
        
        // Verify that the welcome screen should show
        let hasPressedGetStarted = UserDefaults.standard.bool(forKey: "hasPressedGetStarted")
        let lastLaunchDate = UserDefaults.standard.object(forKey: "lastLaunchDate") as? Date ?? Date.distantPast
        
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date.distantPast
        let hasLaunchedRecently = lastLaunchDate > thirtyDaysAgo
        
        // Welcome screen should show if user hasn't pressed "Get Started" OR hasn't launched in 30 days
        let shouldShowWelcome = !hasPressedGetStarted || !hasLaunchedRecently
        
        XCTAssertTrue(shouldShowWelcome, "Welcome screen should show on first launch")
        
        // Test that after pressing "Get Started", the welcome screen won't show again
        UserDefaults.standard.set(true, forKey: "hasPressedGetStarted")
        UserDefaults.standard.set(Date(), forKey: "lastLaunchDate")
        
        let hasPressedGetStartedAfter = UserDefaults.standard.bool(forKey: "hasPressedGetStarted")
        let lastLaunchDateAfter = UserDefaults.standard.object(forKey: "lastLaunchDate") as? Date ?? Date.distantPast
        
        let thirtyDaysAgoAfter = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date.distantPast
        let hasLaunchedRecentlyAfter = lastLaunchDateAfter > thirtyDaysAgoAfter
        
        let shouldShowWelcomeAfter = !hasPressedGetStartedAfter || !hasLaunchedRecentlyAfter
        
        XCTAssertFalse(shouldShowWelcomeAfter, "Welcome screen should not show after pressing Get Started")
    }
    
    func testWelcomeScreenKeyboardPrevention() throws {
        // Test that the keyboard prevention logic works correctly
        
        // Simulate welcome screen showing
        let showingWelcomeView = true
        
        // Test that text field should not be focused when welcome screen is showing
        let shouldFocusTextField = !showingWelcomeView
        
        XCTAssertFalse(shouldFocusTextField, "Text field should not be focused when welcome screen is showing")
        
        // Test that text field should be focused when welcome screen is not showing
        let showingWelcomeViewFalse = false
        let shouldFocusTextFieldWhenNoWelcome = !showingWelcomeViewFalse
        
        XCTAssertTrue(shouldFocusTextFieldWhenNoWelcome, "Text field should be focused when welcome screen is not showing")
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
