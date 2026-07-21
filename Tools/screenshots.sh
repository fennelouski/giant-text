#!/bin/bash
#
# Capture App Store screenshots for every platform Giant Text ships on.
#
#   ./Tools/screenshots.sh iphone|ipad|tv|vision|mac|all
#
# Output goes to AppStore/screenshots/<Platform>/ which is gitignored — upload
# the files to App Store Connect, don't commit them.
#
# This drives the DEBUG-only `--ss-*` launch arguments in ContentView.swift, so
# it must be run against a **Debug** build. The arguments only exist in DEBUG
# and are compiled out of Release/App Store builds.
#
set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
OUTROOT="$REPO/AppStore/screenshots"
BID="com.fennel.Giant-Text"
PROJ="$REPO/Giant Text.xcodeproj"
SCHEME="Giant Text"

# Devices chosen so the captured pixel sizes exactly match App Store Connect specs.
IPHONE_DEVICE="iPhone 17 Pro Max"                             # 1320 x 2868  (6.9")
IPAD_DEVICE="iPad Pro 13-inch (M5)"                           # 2064 x 2752  (13")
TV_DEVICE="Apple TV 4K (3rd generation) (at 1080p)"           # 1920 x 1080
VISION_DEVICE="Apple Vision Pro"                              # 3840 x 2160

# name:args — one line per screenshot
SHOTS=(
  "01-hero|--ss-text|GIANT TEXT|--ss-theme|classic"
  "02-sunset|--ss-text|ON MY WAY|--ss-theme|sunset"
  "03-ocean|--ss-text|HELLO|--ss-theme|ocean|--ss-animation|ripple"
  "04-options|--ss-text|GIANT TEXT|--ss-theme|classic|--ss-options"
  "05-themes|--ss-text|GIANT TEXT|--ss-theme|classic|--ss-options|--ss-expand-theme"
)

build() { # build <destination> <label>
  echo "Building ($2)…"
  xcodebuild -project "$PROJ" -scheme "$SCHEME" -destination "$1" \
    -configuration Debug build CODE_SIGNING_ALLOWED=NO 2>&1 |
    grep -E "error:|BUILD SUCCEEDED|BUILD FAILED" | head -5
}

product() { find ~/Library/Developer/Xcode/DerivedData/Giant_Text-*/Build/Products/"$1" \
  -maxdepth 1 -name "Giant Text.app" 2>/dev/null | head -1; }

shoot_sim() { # shoot_sim <device> <outdir> [max-shots]
  local dev="$1" out="$2" limit="${3:-5}" i=0
  mkdir -p "$out"
  # Force dark appearance so each platform's set is internally consistent.
  xcrun simctl ui "$dev" appearance dark >/dev/null 2>&1
  for entry in "${SHOTS[@]}"; do
    i=$((i+1)); [ "$i" -gt "$limit" ] && break
    local IFS='|'; read -r name args <<< "$entry"; unset IFS
    IFS='|' read -r -a parts <<< "$entry"
    local shot_name="${parts[0]}"; local shot_args=("${parts[@]:1}")
    xcrun simctl terminate "$dev" "$BID" >/dev/null 2>&1; sleep 2
    local pid=""
    for _ in 1 2 3; do
      pid=$(xcrun simctl launch "$dev" "$BID" "${shot_args[@]}" 2>/dev/null | awk '{print $2}')
      [ -n "$pid" ] && break; sleep 2
    done
    sleep 7
    xcrun simctl io "$dev" screenshot "$out/$shot_name.png" >/dev/null 2>&1
    if [ -f "$out/$shot_name.png" ]; then
      echo "  ✓ $shot_name.png $(sips -g pixelWidth -g pixelHeight "$out/$shot_name.png" 2>/dev/null | awk '/pixel/{printf "%s ", $2}')"
    else
      echo "  ✗ $shot_name.png FAILED"
    fi
  done
  xcrun simctl terminate "$dev" "$BID" >/dev/null 2>&1
}

boot() { # boot <device>
  open -a Simulator; sleep 8
  xcrun simctl boot "$1" >/dev/null 2>&1
  for _ in $(seq 1 20); do
    xcrun simctl list devices | grep -F "$1" | grep -q Booted && return 0
    sleep 3
  done
  echo "  ! $1 did not boot"; return 1
}

do_iphone() { build "platform=iOS Simulator,name=$IPHONE_DEVICE" iOS
  boot "$IPHONE_DEVICE" && xcrun simctl install "$IPHONE_DEVICE" "$(product Debug-iphonesimulator)" &&
  shoot_sim "$IPHONE_DEVICE" "$OUTROOT/iPhone-6.9"; }

do_ipad() { build "platform=iOS Simulator,name=$IPAD_DEVICE" iPadOS
  boot "$IPAD_DEVICE" && xcrun simctl install "$IPAD_DEVICE" "$(product Debug-iphonesimulator)" &&
  shoot_sim "$IPAD_DEVICE" "$OUTROOT/iPad-13"; }

# tvOS uses the simplified options menu (no theme grid), so only the 3 hero shots.
do_tv() { build "platform=tvOS Simulator,name=$TV_DEVICE" tvOS
  boot "$TV_DEVICE" && xcrun simctl install "$TV_DEVICE" "$(product Debug-appletvsimulator)" &&
  shoot_sim "$TV_DEVICE" "$OUTROOT/AppleTV" 3; }

do_vision() { build "platform=visionOS Simulator,name=$VISION_DEVICE" visionOS
  boot "$VISION_DEVICE" && xcrun simctl install "$VISION_DEVICE" "$(product Debug-xrsimulator)" &&
  shoot_sim "$VISION_DEVICE" "$OUTROOT/VisionPro"; }

# macOS captures BY WINDOW ID, so an image can only ever contain the app's own
# window — never the surrounding desktop.
do_mac() {
  build "platform=macOS" macOS
  local app out wid; app="$(product Debug)"; out="$OUTROOT/Mac"; mkdir -p "$out"
  local helper="$REPO/Tools/.winid"
  swiftc -O -o "$helper" "$REPO/Tools/winid.swift" 2>/dev/null || { echo "  ! could not build winid helper"; return 1; }
  for entry in "${SHOTS[@]}"; do
    IFS='|' read -r -a parts <<< "$entry"
    local name="${parts[0]}"; local args=("${parts[@]:1}")
    [ "$name" = "04-options" ] && continue          # macOS: keep 3 heroes + theme grid
    pkill -f "Giant Text.app/Contents/MacOS" 2>/dev/null; sleep 2
    open -a "$app" --args "${args[@]}"; sleep 6
    osascript -e 'tell application "Giant Text" to activate' >/dev/null 2>&1; sleep 1
    osascript -e 'tell application "System Events" to tell process "Giant Text"
       set position of window 1 to {80, 80}
       set size of window 1 to {1440, 900}
     end tell' >/dev/null 2>&1
    sleep 2
    wid="$("$helper" "Giant Text" 2>/dev/null)"
    [ -z "$wid" ] && { echo "  ✗ $name (no window)"; continue; }
    screencapture -x -o -l "$wid" "$out/$name.png" 2>/dev/null
    echo "  ✓ $name.png $(sips -g pixelWidth -g pixelHeight "$out/$name.png" 2>/dev/null | awk '/pixel/{printf "%s ", $2}')"
  done
  pkill -f "Giant Text.app/Contents/MacOS" 2>/dev/null
  rm -f "$helper"
}

case "${1:-all}" in
  iphone) do_iphone ;;
  ipad)   do_ipad ;;
  tv)     do_tv ;;
  vision) do_vision ;;
  mac)    do_mac ;;
  all)    do_iphone; do_ipad; do_tv; do_vision; do_mac ;;
  *) echo "usage: $0 iphone|ipad|tv|vision|mac|all"; exit 1 ;;
esac
echo "Done. Screenshots in $OUTROOT"
