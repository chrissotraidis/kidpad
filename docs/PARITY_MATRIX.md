# KidPad behavior matrix

KidPad is an unofficial native Swift recreation of the early Kid Pix
experience. The matrix below records the current native behavior against the
pinned JSKidPix revision used for engineering comparison. It is not a claim of
complete pixel or algorithm parity with every commercial Kid Pix release.

## Reference boundary

- Engineering oracle: `vikrum/kidpix` commit
  `99c67f3427d229f7db60b03dcf19df4d8c2a8ecf`.
- Public builds contain no JSKidPix source and no Classic Pack artwork or audio.
- A local FidelityDev cache may be used for development, but it is ignored by
  Git and rejected by the public release scanner.
- The optional first-run Classic Pack contains data files only and is installed
  only after user consent and whole-pack verification.

## Tool status

| Tool or area | Version 1 result | Remaining difference |
| --- | --- | --- |
| Pencil | Six widths, texture choices, Apple Pencil pressure, coalesced input, and predicted-stroke feedback | Some texture details remain native approximations |
| Line | Width and texture choices render through the native shape path | Source-specific stomp behavior is not implemented |
| Rectangle and Oval | No Fill and textured fills reach the canvas with a fixed outline | Several texture patterns remain approximations |
| Wacky Brush | All 28 enabled entries are reachable, deterministic, distinct, and mapped to the pinned sound catalog | Several complex source algorithms remain approximations |
| Electric Mixer | Fourteen distinct whole-canvas effects | Several algorithms intentionally differ from the source |
| Paint Can | Bounded native flood fill with the shared texture catalog | Source compositing is not yet exact |
| Eraser | Twelve active entries dispatch separately, including clear and animated final-frame effects | Black Hole and Count Down remain explicit placeholders |
| Alphabet | Two character pages, native placement, and mapped sounds | Font metrics and placement are native rather than exact source behavior |
| Rubber Stamps | Stamps, stickers, and sprite selection persist correctly; first-row sprite outputs are distinct and upright | Full catalog parity depends on the optional Classic Pack |
| Moving Van | Thirteen real region sizes, Move and Copy modes, upright payloads, and an inert source-compatible magnet placeholder | Interaction timing differs from the browser reference |
| Undo Guy | Toggle-style last-decision behavior with four mapped Oops sounds | None known for the supported behavior |
| File and Edit | New, Save, Open Recent, multi-level Undo and Redo, and PNG export act on the live canvas | Platform document-picking chrome remains native |
| Layout | Landscape, portrait, compact width, left-handed mirroring, two-finger zoom, and two-finger pan | System-owned iPad and Catalyst chrome is intentionally native |

## Version 1 acceptance

- The complete `KidPadTests` suite passed 69 tests with zero failures on
  2026-08-23.
- The isolated `ReleasePublic` build passed its excluded-asset scanner.
- The network audit passed, with outbound access limited to the consent-driven
  Classic Pack installer.
- A clean AltStore installation, first-run pack setup, Apple Pencil drawing,
  pressure response, and the lower-latency brush path were accepted on an iPad
  Pro 12.9-inch (6th generation).
- The current Mac Catalyst workflow has been built and exercised, including
  document commands and responsive workspace behavior.

## Open validation

- Tilt, hover, double-tap, squeeze, roll, and the complete palm-rejection matrix
  have not all been physically exercised.
- Audible playback has automated resource and player-pool coverage but no
  retained physical-device audio recording.
- Historical artwork, audio, naming, and trademark rights are not declared
  public domain or legally cleared by this technical matrix.

See [`HARDWARE_VALIDATION_REQUIRED.md`](../HARDWARE_VALIDATION_REQUIRED.md),
[`KNOWN_ISSUES.md`](../KNOWN_ISSUES.md), and
[`RIGHTS_AND_LICENSES.md`](../RIGHTS_AND_LICENSES.md) for the remaining gates.
