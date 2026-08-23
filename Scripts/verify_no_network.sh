#!/bin/zsh
set -euo pipefail

root="${1:-.}"
[[ -d "$root" ]] || { print -u2 "Missing source root: $root"; exit 1; }

# The only permitted outbound networking is the user-approved Classic Pack
# data download. Keep telemetry and unrelated network clients out of the app.
if rg -n --glob '*.swift' --glob '*.m' --glob '*.mm' --glob '*.h' \
  --glob '!ClassicAssetPack.swift' \
  'URLSession|URLRequest|NWConnection|Network\.framework|NSURLSession|Telemetry|analytics' "$root/Sources" "$root/KidPad.xcodeproj"; then
  print -u2 "Network policy failed: networking or telemetry exists outside ClassicAssetPack.swift."
  exit 1
fi

print "Network policy passed: only the Classic Pack installer may use outbound networking."
