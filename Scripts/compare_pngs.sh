#!/bin/zsh
set -euo pipefail

if [[ $# -lt 2 || $# -gt 4 ]]; then
  print -u2 "usage: $0 reference-image candidate-image [mean-error-threshold] [--resize-candidate]"
  exit 2
fi

reference="$1"
candidate="$2"
threshold="${3:-0}"
resize_mode="${4:-}"
python3 - "$reference" "$candidate" "$threshold" "$resize_mode" <<'PY'
import json
import pathlib
import sys

from PIL import Image, ImageChops, ImageStat

reference_path, candidate_path, threshold_text, resize_mode = sys.argv[1:]
reference = Image.open(reference_path).convert("RGBA")
candidate = Image.open(candidate_path).convert("RGBA")
original_candidate_size = candidate.size
resized = False
if candidate.size != reference.size:
    if resize_mode != "--resize-candidate":
        report = {
            "reference": reference_path,
            "candidate": candidate_path,
            "referenceSize": list(reference.size),
            "candidateSize": list(candidate.size),
            "comparable": False,
            "reason": "dimension mismatch; pass --resize-candidate for normalized comparison",
        }
        print(json.dumps(report, sort_keys=True))
        raise SystemExit(2)
    candidate = candidate.resize(reference.size, Image.Resampling.LANCZOS)
    resized = True

diff = ImageChops.difference(reference, candidate)
stats = ImageStat.Stat(diff)
channels = reference.width * reference.height * 4
raw = diff.tobytes()
different_pixels = sum(1 for index in range(0, len(raw), 4) if raw[index:index + 4] != b"\x00\x00\x00\x00")
max_error = max(raw) if raw else 0
mean_error = sum(raw) / channels if channels else 0
threshold = float(threshold_text)
report = {
    "reference": reference_path,
    "candidate": candidate_path,
    "referenceSize": list(reference.size),
    "candidateSize": list(original_candidate_size),
    "comparisonSize": list(candidate.size),
    "resizedCandidate": resized,
    "comparable": True,
    "differentPixels": different_pixels,
    "totalPixels": reference.width * reference.height,
    "differentPixelRatio": different_pixels / (reference.width * reference.height),
    "meanAbsoluteChannelError": mean_error,
    "maxChannelError": max_error,
    "threshold": threshold,
    "passed": mean_error <= threshold,
}
print(json.dumps(report, sort_keys=True))
raise SystemExit(0 if report["passed"] else 1)
PY
