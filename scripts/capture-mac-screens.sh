#!/usr/bin/env bash
# Captures the README screenshots from the macOS build of the SyncDemo example app.
#
# The script builds the app for the Mac, opens each demo with `-demo <name>` (the demo then plays
# its scenario with the real package: eight tasks incrementing a @Synchronized counter, an upload
# whose @Streamed progress two views follow), waits for it to finish and captures the app's window
# in light and dark appearance (`-appearance light|dark`), without the window shadow.
#
# It needs the Screen Recording permission for the terminal that runs it (System Settings ›
# Privacy & Security), which `screencapture` asks for on the first run.
#
# Usage: scripts/capture-mac-screens.sh            Output: docs/images/demo-<name>-<appearance>.png
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
# demo name and the seconds its scenario needs before the screenshot
demos=("counter 4" "upload 4")
output_dir="$repo_root/docs/images"
build_dir="$repo_root/.build/example-screens-mac"
mkdir -p "$output_dir"

echo "Building SyncDemo for macOS"
xcodebuild build \
  -project "$repo_root/Examples/SyncDemo/SyncDemo.xcodeproj" \
  -scheme SyncDemo \
  -destination 'platform=macOS' \
  -derivedDataPath "$build_dir" \
  -skipMacroValidation \
  -quiet
app="$build_dir/Build/Products/Debug/SyncDemo.app"

# Prints the id of the first normal window that the process `$1` shows on screen.
window_id() {
  swift - "$1" <<'SWIFT'
import CoreGraphics
let pid = Int32(CommandLine.arguments[1])!
let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
for window in windows where window[kCGWindowOwnerPID as String] as? Int32 == pid
    && window[kCGWindowLayer as String] as? Int == 0 {
    print(window[kCGWindowNumber as String]!)
    break
}
SWIFT
}

for appearance in light dark; do
  for entry in "${demos[@]}"; do
    read -r demo wait_seconds <<< "$entry"
    "$app/Contents/MacOS/SyncDemo" -demo "$demo" -appearance "$appearance" \
      -AppleLanguages "(en)" -AppleLocale en_US >/dev/null 2>&1 &
    pid=$!
    sleep "$wait_seconds"
    id="$(window_id "$pid")"
    if [[ -z "$id" ]]; then
      kill "$pid"
      echo "SyncDemo showed no window for -demo $demo" >&2
      exit 1
    fi
    file="$output_dir/demo-$demo-$appearance.png"
    screencapture -o -x -l "$id" "$file"
    kill "$pid"
    wait "$pid" 2>/dev/null || true
    # Half the width of a Retina capture keeps the README light.
    sips --resampleWidth 480 "$file" >/dev/null
    echo "$file"
  done
done
