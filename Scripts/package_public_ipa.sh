#!/bin/zsh
set -euo pipefail

project_dir="${PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
output_dir="${KIDPAD_OUTPUT_DIR:-$project_dir/build/releases}"
release_version="${KIDPAD_RELEASE_VERSION:-1.0.0}"
release_basename="KidPad-v${release_version}-unsigned"
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

python3 - "$app_path/Info.plist" "$release_version" <<'PY'
import plistlib
import sys

with open(sys.argv[1], "rb") as handle:
    info = plistlib.load(handle)

expected_version = sys.argv[2]
actual_version = info.get("CFBundleShortVersionString")
if actual_version != expected_version:
    raise SystemExit(f"Version mismatch: expected {expected_version}, found {actual_version}")

families = info.get("UIDeviceFamily")
if families != [2]:
    raise SystemExit(f"Version 1 must be iPad-only; UIDeviceFamily is {families!r}")
PY

mkdir -p "$stage_dir/Payload" "$output_dir"
ditto "$app_path" "$stage_dir/Payload/KidPad.app"
ipa_path="$output_dir/$release_basename.ipa"
temporary_ipa="$stage_dir/$release_basename.ipa"
(cd "$stage_dir" && /usr/bin/zip -qry "$temporary_ipa" Payload)
/usr/bin/unzip -tq "$temporary_ipa"
cp -f "$temporary_ipa" "$ipa_path"

print "Public IPA: $ipa_path"
checksum="$(shasum -a 256 "$ipa_path" | awk '{print $1}')"
print -r -- "$checksum  $release_basename.ipa" | tee "$ipa_path.sha256"
(cd "$output_dir" && shasum -a 256 -c "$release_basename.ipa.sha256")
