#!/bin/zsh
set -euo pipefail

app_path="${1:?usage: verify_release_assets.sh /path/to/KidPad.app}"
[[ -d "$app_path" ]] || { print -u2 "Missing app bundle: $app_path"; exit 1; }

# The public app is intentionally data-free. Classic PNG/WAV files are fetched
# only after user consent, so the bundle allowlist should stay very small.
python3 - "$app_path" <<'PY'
import pathlib, sys

app = pathlib.Path(sys.argv[1])
historical_prefixes = (
    "kp-m_", "kp-h-", "kidpix", "tool-menu-wacky", "tool-submenu-",
    "electric-mixer-", "eraser-tool-", "alpha-a-", "stamp0", "flood0", "cursor-tnt",
    "jskidpix-", "pw1", "pw2", "pw3", "pw4", "pw5", "pw6",
)
historical_names = {
    "chord.wav", "flood0.wav", "stamp0.wav",
}
blocked_dirs = {"JSKidPix", "FidelityDev"}
found = []
for path in app.rglob("*"):
    if path.is_dir() and path.name in blocked_dirs:
        found.append(str(path.relative_to(app)))
        continue
    if not path.is_file():
        continue
    name = path.name.lower()
    suffix = path.suffix.lower()
    if name in historical_names or name.startswith(historical_prefixes):
        found.append(str(path.relative_to(app)))
    elif suffix == ".wav":
        found.append(str(path.relative_to(app)))
    elif suffix == ".png" and not name.startswith("appicon"):
        found.append(str(path.relative_to(app)))
    elif suffix in {".html", ".js"}:
        found.append(str(path.relative_to(app)))
    elif suffix in {".ttf", ".otf"} and name != "chikarego2.ttf":
        found.append(str(path.relative_to(app)))
found = sorted(set(found))
if found:
    print("Public release blocked: research-only historical assets are bundled:", file=sys.stderr)
    for name in found:
        print(f"  {name}", file=sys.stderr)
    print("Remove them or explicitly update the public allowlist before release.", file=sys.stderr)
    raise SystemExit(1)
print(f"Public asset policy passed for {app}")
PY

binary_path=""
for candidate in "$app_path/KidPad" "$app_path/Contents/MacOS/KidPad"; do
  if [[ -f "$candidate" ]]; then
    binary_path="$candidate"
    break
  fi
done
[[ -n "$binary_path" ]] || { print -u2 "Public release blocked: KidPad executable is missing"; exit 1; }

if /usr/bin/otool -L "$binary_path" | /usr/bin/grep -Fq "/WebKit.framework/"; then
  print -u2 "Public release blocked: development-only WebKit harness is linked"
  exit 1
fi

print "Public executable policy passed for $binary_path"
