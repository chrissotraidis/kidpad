#!/bin/zsh
set -euo pipefail

app_path="${1:?usage: verify_fidelity_assets.sh /path/to/KidPad.app [ref/source-jskidpix]}"
script_dir="${0:A:h}"
source_root="${2:-$script_dir/../ref/source-jskidpix}"
[[ -d "$source_root" ]] || { print -u2 "Missing pinned source repository: $source_root"; exit 1; }
resource_root="$app_path"
[[ -d "$app_path/Contents/Resources" ]] && resource_root="$app_path/Contents/Resources"
resources=(
  kp-m_27.png kp-m_28.png kp-m_29.png kp-m_30.png kp-m_31.png kp-m_32.png kp-m_33.png
  kp-m_34.png kp-m_35.png kp-m_36.png kp-m_37.png kp-m_38.png kp-m_39.png
  kp-h-bear.png kp-h-bison.png kp-h-corn.png kp-h-eye.png kp-h-fox.png kp-h-horse.png
  kp-h-hummingbird.png kp-h-ladybug.png kp-h-lion.png kp-h-magnet.png kp-h-moth.png kp-h-octopus.png
  kp-sticker-1.png kp-sticker-2.png kp-sticker-3.png kp-sticker-4.png kp-sticker-5.png kp-sticker-6.png
  oops0.wav oops1.wav oops2.wav oops3.wav
  kidpix-spritesheet-0.png kidpix-spritesheet-0b.png kidpix-spritesheet-1.png kidpix-spritesheet-2.png
  kidpix-spritesheet-3.png kidpix-spritesheet-4.png kidpix-spritesheet-5.png kidpix-spritesheet-6.png
  kidpix-spritesheet-7.png kidpix-spritesheet-8.png
  jskidpix-splash.png
  cursor-tnt-0.png
  tool-submenu-pencil-size-1.png tool-submenu-pencil-size-2.png tool-submenu-pencil-size-3.png
  tool-submenu-pencil-size-4.png tool-submenu-pencil-size-5.png tool-submenu-pencil-size-6.png
  pw1.png pw2.png pw3.png pw4.png pw5.png pw6.png
  tool-submenu-eraser-178.png tool-submenu-eraser-179.png tool-submenu-eraser-180.png tool-submenu-eraser-181.png
  tool-submenu-eraser-182.png tool-submenu-eraser-183.png tool-submenu-eraser-184.png tool-submenu-eraser-185.png
  tool-submenu-eraser-186.png tool-submenu-eraser-187.png tool-submenu-eraser-188.png tool-submenu-eraser-189.png
  tool-submenu-eraser-190.png
  tool-menu-wacky-brush-70.png tool-menu-wacky-brush-71.png tool-menu-wacky-brush-72.png
  tool-menu-wacky-brush-73.png tool-menu-wacky-brush-74.png tool-menu-wacky-brush-75.png
  tool-menu-wacky-brush-76.png tool-menu-wacky-brush-77.png tool-menu-wacky-brush-78.png tool-menu-wacky-brush-79.png
  tool-menu-wacky-brush-80.png tool-menu-wacky-brush-81.png tool-menu-wacky-brush-82.png tool-menu-wacky-brush-83.png
  tool-menu-wacky-brush-84.png tool-menu-wacky-brush-85.png tool-menu-wacky-brush-86.png tool-menu-wacky-brush-87.png
  tool-menu-wacky-brush-88.png tool-menu-wacky-brush-89.png tool-menu-wacky-brush-90.png tool-menu-wacky-brush-91.png
  tool-menu-wacky-brush-92.png tool-menu-wacky-brush-93.png tool-menu-wacky-brush-94.png tool-menu-wacky-brush-95.png
  tool-menu-wacky-brush-96.png tool-menu-wacky-brush-97.png
  kidpix-tool-pencil.wav kidpix-tool-line-start.wav kidpix-tool-line-end.wav
  kidpix-tool-box-during-approx.wav kidpix-tool-circle-during-approx.wav stamp0.wav
  kidpix-truck-truckin.wav kidpix-truck-truckin-go.wav kidpix-truck-skid.wav
  kidpix-tool-line-during.wav kidpix-menu-click-submenu-color.wav kidpix-menu-click-submenu-options.wav
  electric-mixer-inverter-rolling-sound-WAVSOUND.R_0001fcfa.wav
  eraser-tool-fade-2WAVSOUND.R_0002f58b.wav
  alpha-a-WAVSOUND.R_0007d8f2.wav alpha-b-WAVSOUND.R_0007ee1f.wav alpha-c-WAVSOUND.R_000803fc.wav
  alpha-d-WAVSOUND.R_000815df.wav alpha-e-WAVSOUND.R_00082fcc.wav alpha-f-WAVSOUND.R_00084629.wav
  alpha-g-WAVSOUND.R_000853d0.wav alpha-h-WAVSOUND.R_00086213.wav alpha-i-WAVSOUND.R_00087a00.wav
  alpha-j-WAVSOUND.R_00088ced.wav alpha-k-WAVSOUND.R_0008a72e.wav alpha-l-WAVSOUND.R_0008bda3.wav
  alpha-m-WAVSOUND.R_0008d0f8.wav alpha-n-WAVSOUND.R_0008e695.wav alpha-o-WAVSOUND.R_0008fcaa.wav
  alpha-p-WAVSOUND.R_00091bdb.wav alpha-q-WAVSOUND.R_00092aee.wav alpha-r-WAVSOUND.R_0009639f.wav
  alpha-s-WAVSOUND.R_00097948.wav alpha-t-WAVSOUND.R_00099085.wav alpha-u-WAVSOUND.R_0009a406.wav
  alpha-v-WAVSOUND.R_0009bbcf.wav alpha-w-WAVSOUND.R_0009d8cc.wav alpha-x-WAVSOUND.R_0009ff1d.wav
  alpha-y-WAVSOUND.R_000a177a.wav alpha-z-WAVSOUND.R_000a2fe7.wav
  number-0-WAVSOUND.R_000a7832.wav number-1-WAVSOUND.R_000a9f1f.wav number-2-WAVSOUND.R_000ab58c.wav
  number-3-WAVSOUND.R_000aca17.wav number-4-WAVSOUND.R_000ae7a4.wav number-5-WAVSOUND.R_000afbb1.wav
  number-6-WAVSOUND.R_000b205a.wav number-7-WAVSOUND.R_000b43e7.wav number-8-WAVSOUND.002_000555ac.wav
  number-9-WAVSOUND.R_000b7db1.wav number-ampersand-WAVSOUND.R_000be96f.wav
  number-eclamation-WAVSOUND.R_000a5774.wav number-equals-WAVSOUND.R_000bce22.wav
  number-minus-WAVSOUND.R_000bb0e5.wav number-plus-WAVSOUND.R_000b9a58.wav
  number-question-mark-WAVSOUND.R_000a661d.wav
  chord.wav
  bubble-pop-2WAVSOUND.R_0004edd3.wav bubble-pop-3WAVSOUND.R_0004fccd.wav bubble-pop-4WAVSOUND.R_0004f480.wav
  bubble-pop-WAVSOUND.R_000031f6.wav bubble-pop-WAVSOUND.R_00050452.wav
  kidpix-eraser-doorbell-ding-dong.wav kidpix-eraser-doorbell-door-creak.wav kidpix-eraser-doorbell-wwoooowwww.wav
  kidpix-submenu-brush-leaky-pen.wav kidpix-menu-click-main-tools.wav flood0.wav
  kidpix-submenu-brush-bubbly.wav kidpix-submenu-brush-dots.wav kidpix-submenu-brush-owl.wav
  kidpix-submenu-brush-pies.wav kidpix-submenu-brush-zigzag.wav kidpix-tool-eraser-tnt-explosion.wav
  kidpix-submenu-brush-cards.wav kidpix-submenu-brush-fuzzer.wav kidpix-submenu-brush-guilloche.wav
  kidpix-submenu-brush-inverter.wav kidpix-submenu-brush-kaliediscope.wav kidpix-submenu-brush-northern.wav
  kidpix-submenu-brush-pines.wav kidpix-submenu-brush-prints.wav kidpix-submenu-brush-rollingdots.wav
  kidpix-submenu-brush-shapes.wav kidpix-submenu-brush-spraypaint.wav kidpix-submenu-brush-stars.wav
  kidpix-submenu-brush-tree.wav kidpix-submenu-brush-twirly.wav kidpix-submenu-brush-xos.wav
  kidpix-submenu-brush-xy-during.wav kidpix-submenu-brush-xy-end.wav kidpix-submenu-brush-xy-start.wav
  kidpix-submenu-brush-zoom.wav
  tool-submenu-wacky-mixer-164.png tool-submenu-wacky-mixer-166.png tool-submenu-wacky-mixer-168.png
  tool-submenu-wacky-mixer-165.png tool-submenu-wacky-mixer-167.png tool-submenu-wacky-mixer-169.png
  tool-submenu-wacky-mixer-170.png tool-submenu-wacky-mixer-171.png tool-submenu-wacky-mixer-172.png
  tool-submenu-wacky-mixer-173.png tool-submenu-wacky-mixer-174.png tool-submenu-wacky-mixer-175.png
  tool-submenu-wacky-mixer-176.png tool-submenu-wacky-mixer-177.png
  tool-submenu-truck-192.png tool-submenu-truck-193.png tool-submenu-truck-194.png tool-submenu-truck-195.png
  tool-submenu-truck-196.png tool-submenu-truck-197.png tool-submenu-truck-198.png tool-submenu-truck-199.png
  tool-submenu-truck-200.png tool-submenu-truck-201.png tool-submenu-truck-202.png tool-submenu-truck-203.png
  tool-submenu-truck-204.png tool-submenu-truck-205.png
  electric-mixer-wallpaper-jitter-boingo-WAVSOUND.R_00024fcc.wav
  electric-mixer-venetian-WAVSOUND.R_0001df56.wav electric-mixer-shadow-boxes-WAVSOUND.R_0002a07a.wav
  electric-mixer-pip-drum-crash-1WAVSOUND.R_0002d96e.wav western-gun-shot-twirl-WAVSOUND.R_0005ed70.wav
)

normalized_pngs=()
decoded_png_dir="$(mktemp -d /tmp/kidpad-fidelity-pngs-XXXXXX)"
for resource in $resources; do
  [[ -f "$resource_root/$resource" ]] || { print -u2 "Missing bundled FidelityDev asset: $resource"; exit 1; }
  source_name="$resource"
  # Bundled names may differ from pinned-source paths; map them explicitly here.
  [[ "$resource" == "jskidpix-splash.png" ]] && source_name="splash.png"
  source_path="$(find "$source_root" -type f -name "$source_name" -print -quit)"
  [[ -n "$source_path" ]] || { print -u2 "Missing source counterpart for bundled asset: $resource"; exit 1; }
  bundled_hash="$(shasum -a 256 "$resource_root/$resource" | awk '{print $1}')"
  source_hash="$(shasum -a 256 "$source_path" | awk '{print $1}')"
  if [[ "$bundled_hash" != "$source_hash" ]]; then
    if [[ "$resource" != *.png ]]; then
      print -u2 "Source hash mismatch for $resource"
      print -u2 "  bundled: $bundled_hash"
      print -u2 "  source:  $source_hash ($source_path)"
      exit 1
    fi
    decoded_path="$decoded_png_dir/$resource"
    sips -s format png "$resource_root/$resource" --out "$decoded_path" >/dev/null 2>&1 || {
      print -u2 "Could not decode normalized PNG for $resource"
      exit 1
    }
    if ! python3 - "$source_path" "$decoded_path" <<'PY'
import sys
from PIL import Image, ImageChops

source = Image.open(sys.argv[1]).convert("RGBA")
bundled = Image.open(sys.argv[2]).convert("RGBA")
if source.size != bundled.size or ImageChops.difference(source, bundled).getbbox() is not None:
    raise SystemExit(1)
PY
    then
      print -u2 "Decoded pixel mismatch for $resource"
      print -u2 "  bundled: $bundled_hash"
      print -u2 "  source:  $source_hash ($source_path)"
      exit 1
    fi
    normalized_pngs+=($resource)
  fi
done

font_path="$resource_root/ChiKareGo2.ttf"
[[ -f "$font_path" ]] || { print -u2 "Missing bundled FidelityDev font: ChiKareGo2.ttf"; exit 1; }
font_hash="$(shasum -a 256 "$font_path" | awk '{print $1}')"
[[ "$font_hash" == "fba98c4ed1fb9da8d7c18e84209304941fe47b8e88472a795bb08ccb607588f7" ]] || {
  print -u2 "Unexpected ChiKareGo2.ttf hash: $font_hash"
  exit 1
}

print "Verified ${#resources[@]} original Kid Pix assets against $source_root in $app_path"
print "Exact file hashes: $((${#resources[@]} - ${#normalized_pngs[@]})); decoded pixel-equivalent PNGs normalized by Xcode: ${#normalized_pngs[@]}"
