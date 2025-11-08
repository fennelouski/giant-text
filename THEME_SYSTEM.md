# Color Theme System Documentation

## Overview
The Giant Text app now features a comprehensive color theme system with 20 curated themes, each automatically adapting to light and dark mode. Users can manually select themes or enable automatic randomization that changes the theme daily.

## Features

### 20 Curated Themes
Each theme has been carefully designed with distinct color palettes for both light and dark modes:

1. **Classic** - Traditional black/white (default)
2. **Ocean Breeze** - Cool blues
3. **Forest Twilight** - Deep greens
4. **Sunset Glow** - Warm oranges and pinks
5. **Lavender Dreams** - Soft purples
6. **Crimson Night** - Bold reds
7. **Golden Hour** - Warm yellows
8. **Midnight Blue** - Deep blues
9. **Cherry Blossom** - Soft pinks
10. **Mint Fresh** - Cool mint greens
11. **Amber Warmth** - Rich amber
12. **Slate Gray** - Professional grays
13. **Coral Reef** - Vibrant coral
14. **Teal Wave** - Aqua teals
15. **Plum Twilight** - Deep plums
16. **Sage Garden** - Earthy sage
17. **Mocha Delight** - Rich browns
18. **Electric Violet** - Vibrant purples
19. **Peachy Keen** - Soft peaches
20. **Steel Blue** - Industrial blues

### Automatic Light/Dark Mode Adaptation
- Each theme automatically adjusts colors when the system switches between light and dark mode
- Background and text colors are optimized for readability in each mode
- Smooth transitions maintain visual consistency

### Random Theme Mode
- Enable "Random Theme (Daily)" in settings
- Theme automatically changes every 24 hours
- Changes also occur when app is foregrounded after being backgrounded for 24+ hours
- Always selects a different theme from the current one

### Widget Support
- Themes automatically sync to home screen widgets
- Widget background and text colors match the app theme
- Updates occur within 5 minutes of theme changes

## Implementation Details

### Architecture

#### Core Files
- **`ColorTheme.swift`** - Theme definitions and color management
  - 20 pre-defined themes with light/dark variants
  - `ColorTheme` struct with `Codable` support for persistence
  - `CodableColor` wrapper for SwiftUI Color serialization

- **`UserDefaults+AppGroup.swift`** - Shared storage for app and widget
  - Uses App Group `group.com.fennel.Giant-Text`
  - Enables theme sharing between main app and widget

- **`ContentViewState.swift`** - Theme state management
  - `selectedThemeId`: Currently selected theme identifier
  - `useRandomTheme`: Boolean for random theme mode
  - `lastThemeChangeDate`: Timestamp for 24-hour check
  - `currentTheme()`: Returns active ColorTheme instance
  - `checkAndUpdateThemeIfNeeded()`: Handles automatic randomization
  - `randomizeTheme()`: Selects a new random theme

#### UI Components
- **`OptionsMenuSheet.swift`** - Theme selection interface
  - Grid layout showing all 20 themes with color previews
  - "Random Theme (Daily)" toggle
  - Shows current theme when randomization is enabled

- **`ContentViewModifiers.swift`** - Theme application
  - `contentViewBackgroundModifiers()`: Applies theme background colors

- **`CharacterAnimation.swift`** - Themed text rendering
  - Applies theme text colors to animated characters

- **`AnimatedTextDisplay.swift`** - Multi-line text display
  - Supports theme colors in all animation modes

- **`GiantTextView.swift`** - Main text view
  - Theme-aware background and text colors

- **Widget Files**:
  - `GiantTextWidget.swift` - Widget entry and provider
  - `WidgetTextDisplay.swift` - Widget text rendering
  - Both read theme from shared App Group storage

### Data Flow

1. **Theme Selection**:
   ```
   User selects theme → ContentViewState.selectedThemeId updated
   → Theme saved to App Group UserDefaults
   → UI updates with new colors
   → Widget receives update within 5 minutes
   ```

2. **Random Theme**:
   ```
   App launch/foreground → checkAndUpdateThemeIfNeeded()
   → Check 24-hour elapsed → randomizeTheme()
   → Select new theme → Save to UserDefaults
   → UI and widget update
   ```

3. **Widget Sync**:
   ```
   Theme change in app → saveThemeToAppGroup()
   → Encode theme as JSON → Store in App Group
   → Widget timeline refresh → Decode theme
   → Apply colors to widget
   ```

### Storage

#### App Group Keys
- `selectedThemeId`: String - Theme identifier (e.g., "classic", "ocean")
- `useRandomTheme`: Bool - Randomization enabled flag
- `lastThemeChangeDate`: Date - Last randomization timestamp
- `currentThemeData`: Data - JSON-encoded ColorTheme for widget

#### Theme Structure
```swift
struct ColorTheme: Codable, Identifiable {
    let id: String
    let name: String
    let lightBackground: CodableColor
    let lightText: CodableColor
    let darkBackground: CodableColor
    let darkText: CodableColor
}
```

### Color Application

#### Main App
- Background: Applied via `contentViewBackgroundModifiers()`
- Text: Applied in CharacterView for each character
- UI Elements: OptionsMenuSheet uses theme colors for previews

#### Widget
- Background: Applied via `containerBackground(for: .widget)`
- Text: Applied in WidgetTextDisplay
- Placeholder: Uses theme colors when no text available

## User Guide

### Selecting a Theme
1. Tap the settings icon (two-finger tap or swipe)
2. Scroll to the "Theme" section
3. Browse through 20 theme options with color previews
4. Tap a theme to apply it immediately
5. Theme persists across app launches

### Enabling Random Themes
1. Open settings
2. Find "Theme" section
3. Toggle "Random Theme (Daily)" on
4. Theme will change automatically every 24 hours
5. Current theme is displayed below the toggle

### Theme on Widgets
1. Add Giant Text widget to home screen
2. Widget automatically uses the same theme as the app
3. Updates appear within 5 minutes of theme changes
4. Works with both manual and random theme modes

## Technical Notes

### Performance
- Theme changes are instantaneous
- No performance impact on animations
- Minimal memory footprint (~5KB per theme)
- Widget updates are throttled to every 5 minutes

### Compatibility
- Requires iOS 18.5 or later
- Works with all animation modes
- Compatible with all device orientations
- Supports light and dark mode system settings

### App Groups
Theme system uses App Group `group.com.fennel.Giant-Text` to share data between the main app and widget extension. This must be configured in Xcode under Signing & Capabilities for both targets.

## Future Enhancements

Potential future additions:
- Custom theme creator
- Import/export themes
- Community theme sharing
- Theme scheduling (different themes for different times of day)
- Theme preview mode
- Per-widget theme settings

## Troubleshooting

### Theme not appearing in widget
- Verify App Group is configured for both app and widget targets
- Check that both use `group.com.fennel.Giant-Text`
- Remove and re-add widget to home screen
- Wait up to 5 minutes for update

### Random theme not changing
- Check that "Random Theme (Daily)" is enabled
- Ensure app has been foregrounded after 24 hours
- Verify lastThemeChangeDate is being saved correctly
- Check App Group UserDefaults access

### Colors look wrong
- Verify system appearance setting (light/dark mode)
- Check that theme has both light and dark variants defined
- Restart app if colors don't update immediately
- Ensure ColorTheme.swift is compiled in both app and widget targets

## Developer Notes

### Adding New Themes
To add a new theme, edit `ColorTheme.swift` and add to the `allThemes` array:

```swift
ColorTheme(
    id: "unique-id",
    name: "Theme Name",
    lightBackground: CodableColor(red: 1.0, green: 1.0, blue: 1.0),
    lightText: CodableColor(red: 0.0, green: 0.0, blue: 0.0),
    darkBackground: CodableColor(red: 0.0, green: 0.0, blue: 0.0),
    darkText: CodableColor(red: 1.0, green: 1.0, blue: 1.0)
)
```

### Theme Testing Checklist
- [ ] Test in light mode
- [ ] Test in dark mode
- [ ] Test with all animation modes
- [ ] Test on widget (small, medium, large)
- [ ] Test random theme switching
- [ ] Test theme persistence across launches
- [ ] Test with different text lengths
- [ ] Test on different device sizes
