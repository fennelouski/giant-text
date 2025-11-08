# Widget Setup Instructions

## Overview
The widget has been updated to properly display text from the main app using App Groups for data sharing.

## Changes Made

### 1. App Group Configuration
- Added App Group entitlement to main app: `group.com.nathanfennel.gianttext`
- Created entitlements file for widget extension with same App Group
- Updated code to use shared UserDefaults instead of standard UserDefaults

### 2. Data Sharing
- Main app now saves text data to shared UserDefaults when:
  - Document is loaded
  - Document is updated
  - New document is created
- Widget reads from shared UserDefaults to display current text
- Font size and formatting preferences are also shared

### 3. Widget Updates
- Widget refreshes every 5 minutes (reduced from 15)
- Widget shows "GIANT TEXT" as default when no text is available
- Added debug logging to help troubleshoot data sharing

## Required Xcode Configuration

### 1. Enable App Groups
1. Select your project in Xcode
2. Select the main app target
3. Go to "Signing & Capabilities"
4. Click "+ Capability" and add "App Groups"
5. Add the group: `group.com.nathanfennel.gianttext`

### 2. Configure Widget Extension
1. Select the widget extension target
2. Go to "Signing & Capabilities"
3. Click "+ Capability" and add "App Groups"
4. Add the same group: `group.com.nathanfennel.gianttext`

### 3. Verify Entitlements
- Main app: `Giant Text/Giant_Text.entitlements`
- Widget: `Giant Text Widget/GiantTextWidget.entitlements`

Both should contain the App Group configuration.

## Testing
1. Build and run the app
2. Add some text in the main app
3. Add the widget to your home screen
4. The widget should display the text from the app
5. Check console logs for debug information

## Troubleshooting
- If the widget still shows "GIANT TEXT", check that App Groups are properly configured
- Verify both targets have the same App Group identifier
- Check console logs for debug messages from both app and widget
- Try removing and re-adding the widget after making changes 