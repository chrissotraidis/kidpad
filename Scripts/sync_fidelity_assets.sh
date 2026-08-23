#!/bin/zsh
set -euo pipefail

# Copy original PNG/WAV files from the pinned JSKidPix clone into the private
# FidelityDev profile. These files remain research-only and are gitignored.
root="$(cd "$(dirname "$0")/.." && pwd)"
source_root="${1:-$root/ref/source-jskidpix}"
dest="$root/Resources/FidelityDev"
[[ -d "$source_root" ]] || { print -u2 "Missing pinned source: $source_root"; exit 1; }
mkdir -p "$dest"

copy_named() {
  local name="$1" dest_name="${2:-$1}"
  local found
  found="$(find "$source_root" -type f -name "$name" -print -quit)"
  [[ -n "$found" ]] || { print -u2 "Missing source asset $name"; exit 1; }
  cp "$found" "$dest/$dest_name"
}

copy_named splash.png jskidpix-splash.png
for name in \
  kp-m_27.png kp-m_28.png kp-m_29.png kp-m_30.png kp-m_31.png kp-m_32.png kp-m_33.png \
  kp-m_34.png kp-m_35.png kp-m_36.png kp-m_37.png kp-m_38.png kp-m_39.png \
  kp-h-bear.png kp-h-bison.png kp-h-corn.png kp-h-eye.png kp-h-fox.png kp-h-horse.png \
  kp-h-hummingbird.png kp-h-ladybug.png kp-h-lion.png kp-h-magnet.png kp-h-moth.png kp-h-octopus.png \
  kp-sticker-1.png kp-sticker-2.png kp-sticker-3.png kp-sticker-4.png kp-sticker-5.png kp-sticker-6.png \
  kidpix-spritesheet-0.png kidpix-spritesheet-0b.png kidpix-spritesheet-1.png kidpix-spritesheet-2.png \
  kidpix-spritesheet-3.png kidpix-spritesheet-4.png kidpix-spritesheet-5.png kidpix-spritesheet-6.png \
  kidpix-spritesheet-7.png kidpix-spritesheet-8.png cursor-tnt-0.png kidpix.png kidpix-guy.png; do
  copy_named "$name"
done
print "Synced FidelityDev originals into $dest"
