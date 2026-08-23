#!/bin/zsh
set -euo pipefail

# Build the public profile into an isolated derived-data directory, then run the
# same bundle scanner used by the release gate. FidelityDev remains the normal
# exact-reference development profile; this script never copies those files.
project_dir="${PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
derived_dir="$(mktemp -d /tmp/kidpad-public-build.XXXXXX)"

xcodebuild \
  -project "$project_dir/KidPad.xcodeproj" \
  -scheme KidPad \
  -configuration ReleasePublic \
  -sdk iphonesimulator \
  -derivedDataPath "$derived_dir" \
  build

app_path="$(find "$derived_dir/Build/Products" -type d -name KidPad.app -print -quit)"
[[ -n "$app_path" ]] || { print -u2 "Public build did not produce KidPad.app"; exit 1; }
"$project_dir/Scripts/verify_release_assets.sh" "$app_path"
print "Public build passed: $app_path"
