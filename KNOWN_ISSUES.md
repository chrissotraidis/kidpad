# Known issues

## Apple Pencil coverage

Drawing latency and pressure-sensitive width were accepted on an iPad Pro
12.9-inch (6th generation). Tilt, hover, double-tap, squeeze, roll, and the
complete palm-rejection matrix have not all been exercised on compatible
hardware.

## Audio evidence

Automated tests cover resource lookup, sound mapping, and the bounded playback
pool. The Version 1 acceptance session did not retain an isolated physical-device
audio recording. Checkerboard and Swirl/Pancake are intentionally silent to
match the pinned JSKidPix behavior.

## Behavioral parity

Several complex Wacky Brush, Electric Mixer, texture, timing, and animation
details are native approximations. See [`docs/PARITY_MATRIX.md`](docs/PARITY_MATRIX.md)
for the tool-by-tool boundary.

## Classic Pack availability

The first-run Classic Pack requires network access to the pinned GitHub source.
If GitHub is unavailable, the app cannot complete first-run setup. Interrupted,
incomplete, or digest-mismatched downloads are rejected and can be retried.

## Rights and naming

The public app bundle contains no Classic Pack, but historical media and the
KID PIX trademark have not been independently cleared by this project. See
[`RIGHTS_AND_LICENSES.md`](RIGHTS_AND_LICENSES.md).
