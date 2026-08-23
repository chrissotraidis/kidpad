#!/bin/zsh
set -euo pipefail

project_dir="${PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
output_dir="${KIDPAD_OUTPUT_DIR:-$project_dir/build/releases}"
derived_dir="$(mktemp -d /tmp/kidpad-public-device.XXXXXX)"
stage_dir="$(mktemp -d /tmp/kidpad-public-ipa.XXXXXX)"

cleanup() {
  rm -rf "$derived_dir" "$stage_dir"
}
trap cleanup EXIT

xcodebuild \
  -project "$project_dir/KidPad.xcodeproj" \
  -scheme KidPad \
  -configuration ReleasePublic \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$derived_dir" \
  CODE_SIGNING_ALLOWED=NO \
  build

app_path="$(find "$derived_dir/Build/Products" -type d -name KidPad.app -print -quit)"
[[ -n "$app_path" ]] || { print -u2 "Device build did not produce KidPad.app"; exit 1; }
"$project_dir/Scripts/verify_release_assets.sh" "$app_path"

mkdir -p "$stage_dir/Payload" "$output_dir"
ditto "$app_path" "$stage_dir/Payload/KidPad.app"
ipa_path="$output_dir/KidPad-unsigned.ipa"
temporary_ipa="$stage_dir/KidPad-unsigned.ipa"
(cd "$stage_dir" && /usr/bin/zip -qry "$temporary_ipa" Payload)
/usr/bin/unzip -tq "$temporary_ipa"
cp -f "$temporary_ipa" "$ipa_path"

print "Public IPA: $ipa_path"
checksum="$(shasum -a 256 "$ipa_path" | awk '{print $1}')"
print -r -- "$checksum  KidPad-unsigned.ipa" | tee "$ipa_path.sha256"
