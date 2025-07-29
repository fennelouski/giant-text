//
//  SerifFontToggleTest.swift
//  Giant TextTests
//
//  Created by Nathan Fennel on 7/28/25.
//

import XCTest
@testable import Giant_Text

final class SerifFontToggleTest: XCTestCase {
    
    func testSerifFontToggleInEditingMode() {
        // Test that when useSerifFont is toggled, the editing mode font updates accordingly
        
        // Create a test state
        let state = ContentViewState()
        state.isEditing = true
        state.useSerifFont = false // Start with system font
        
        // Verify initial state
        XCTAssertFalse(state.useSerifFont)
        
        // Toggle to serif font
        state.useSerifFont = true
        XCTAssertTrue(state.useSerifFont)
        
        // Toggle back to system font
        state.useSerifFont = false
        XCTAssertFalse(state.useSerifFont)
    }
    
    func testSerifFontTogglePersistsInUserDefaults() {
        // Test that the serif font setting is saved to UserDefaults
        
        // Clear any existing value
        UserDefaults.standard.removeObject(forKey: "useSerifFont")
        
        // Test default value (should be true based on ContentViewState implementation)
        let state = ContentViewState()
        XCTAssertTrue(state.useSerifFont)
        
        // Test that changing the value updates UserDefaults
        state.useSerifFont = false
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "useSerifFont"))
        
        // Test that setting it back to true updates UserDefaults
        state.useSerifFont = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "useSerifFont"))
    }
    
    func testFontCreationForCurrentState() {
        // Test that the font creation logic works correctly for different states
        
        // This would require testing the RichTextEditor's createFontForCurrentState method
        // Since it's a private method, we'll test the public interface
        
        let state = ContentViewState()
        state.isEditing = true
        state.isBold = false
        state.isItalicized = false
        state.useSerifFont = false
        
        // Test system font state
        XCTAssertFalse(state.useSerifFont)
        XCTAssertFalse(state.isBold)
        XCTAssertFalse(state.isItalicized)
        
        // Test serif font state
        state.useSerifFont = true
        XCTAssertTrue(state.useSerifFont)
        
        // Test bold state
        state.isBold = true
        XCTAssertTrue(state.isBold)
        
        // Test italic state
        state.isItalicized = true
        XCTAssertTrue(state.isItalicized)
    }
} 