# Agent State

## Current goal

Publish the physically accepted KidPad Version 1 source tree without bundling
the optional Classic Pack or overstating the remaining legal and hardware
validation boundaries.

## Version 1 acceptance

- Branch: `codex/v1-release`
- Target: iPadOS 17 or later and macOS through Mac Catalyst
- Physical device: iPad Pro 12.9-inch (6th generation)
- Installation: a separately identified clean build was signed and installed
  through AltStore without replacing the previously accepted KidPad install.
- First launch: the user-approved Classic Pack download completed, verified,
  installed, and opened the drawing workspace.
- Apple Pencil: drawing, pressure response, and the latency-sensitive Pencil
  and Wacky Brush paths were accepted by hands-on testing on 2026-08-23.
- Setup UI: duplicate-shadow rendering was removed and the final no-shadow
  layout was visually verified on the physical iPad.
- Distribution: source and local unsigned-IPA packaging are ready; no hosted
  IPA is part of this release.

## Preserved baseline

The previous working public snapshot remains reachable at branch
`codex/public-clean-root` (`5cbfc15249a5ec9004d4b9986d60b706a3235038`).
The existing installed KidPad app was not removed during the clean-install
audit.

## Remaining boundaries

- Tilt, hover, double-tap, squeeze, roll, and the complete palm-rejection
  matrix have not all been physically exercised.
- Historical artwork, sound, naming, and trademark rights are not declared
  public domain or legally cleared by this repository.
- Public builds omit the Classic Pack. The app can download only the pinned
  data-file catalog after user consent and verifies the complete digest before
  installation.
- Audible playback still lacks a retained physical-device recording.

## Release rule

Any distributed build must use `ReleasePublic`, pass
`Scripts/verify_release_assets.sh`, and keep the Classic Pack and optional web
reference outside the compiled app bundle.
