# KidPad

<p align="center">
  <strong>A playful, native drawing app for iPad and Mac.</strong><br>
  Built in Swift with Apple Pencil support, pressure-sensitive brushes, classic creative tools, sound, and real documents.
</p>

<p align="center">
  <img alt="Version 1" src="https://img.shields.io/badge/version-1.0-blue">
  <img alt="iPadOS 17 or later" src="https://img.shields.io/badge/iPadOS-17%2B-000000?logo=apple">
  <img alt="macOS via Mac Catalyst" src="https://img.shields.io/badge/macOS-Mac%20Catalyst-000000?logo=apple">
  <img alt="Swift 6" src="https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white">
  <img alt="Physical iPad tested" src="https://img.shields.io/badge/physical%20iPad-tested-34C759">
  <img alt="Apache 2.0 source license" src="https://img.shields.io/badge/source%20license-Apache--2.0-blue">
</p>

![KidPad Version 1 running on a physical iPad](docs/readme/kidpad-ipad-v1.png)

KidPad brings the speed and playful spirit of early creative software to a modern native app. The canvas is powered by Core Graphics, the workspace is built with SwiftUI and UIKit, and drawing stays local to the device. There is no emulator or web runtime behind the product canvas.

Version 1 has been exercised end to end on a physical iPad Pro with Apple Pencil. Installation, first-run setup, the optional Classic Pack download, drawing, pressure response, and the latency-sensitive brush path have all been tested on hardware.

> [!IMPORTANT]
> KidPad is an independent project inspired by classic creative software. It is not Kid Pix, and it is not endorsed by or affiliated with any Kid Pix rights holder.

## Version 1 status

| Distribution path | Status |
| --- | --- |
| Build from source with Xcode | Available |
| Run on iPad and Mac Catalyst | Available |
| Create a local unsigned IPA | Available through `Scripts/package_public_ipa.sh` |
| Download a hosted IPA | Not published yet |
| App Store or TestFlight | Not announced |

The current Version 1 candidate was accepted on an iPad Pro 12.9-inch (6th generation) after a clean AltStore installation. Apple Pencil drawing and pressure feel were accepted by hands-on testing, including the lower-latency brush pipeline. Tilt, hover, double-tap, squeeze, roll, and the complete palm-rejection matrix remain targeted hardware checks rather than completed claims.

## What works

| Area | Current result |
| --- | --- |
| Canvas | Native 1920 x 1200 raster document with an 8:5 letterboxed presentation |
| Drawing | Pencil, line, rectangle, oval, Wacky Brush, fill, eraser, Undo, and Redo |
| Apple Pencil | Coalesced input, predicted-stroke feedback, and pressure-sensitive width |
| Creative tools | Electric Mixer, TNT, Alphabet, Rubber Stamps, and Moving Van |
| Workspace | File, Edit, and Goodies menus with click-away dismissal |
| Layout | Portrait, landscape, compact-width, and left-handed toolbar layouts |
| Documents | Autosave, backup recovery, thumbnails, Save, and PNG export |
| Audio | Goodies mute control and bounded sound playback |
| Platforms | iPadOS 17 or later and macOS through Mac Catalyst |

## First launch

KidPad's public app bundle contains the native app, its original interface resources, and a separately licensed font. It does not contain the classic artwork or sounds.

On first launch:

1. KidPad explains the optional Classic Pack download.
2. If the user chooses **Download Classic Pack**, KidPad fetches 228 PNG and WAV data files from the immutable [`vikrum/kidpix@99c67f3`](https://github.com/vikrum/kidpix/tree/99c67f3427d229f7db60b03dcf19df4d8c2a8ecf) revision.
3. KidPad verifies the complete pack digest, then installs the data atomically in Application Support.
4. The drawing workspace opens and uses the installed data normally.

No JavaScript or executable code is downloaded. The choice is user initiated, and a failed or incomplete verification does not install the pack.

## Build and run

Requirements:

- macOS with Xcode
- an iPad Simulator runtime, or an iPad with your own signing setup
- iPadOS 17 or later for the iPad target

```bash
git clone https://github.com/chrissotraidis/kidpad.git
cd kidpad
Scripts/build_public.sh
```

The script builds the `ReleasePublic` configuration in isolated derived data and scans the resulting app bundle for excluded research assets. To run from Xcode, open `KidPad.xcodeproj`, select the `KidPad` scheme, choose an iPad Simulator or connected iPad, and press Run.

For Mac, select **My Mac (Mac Catalyst)** and build the `ReleasePublic` configuration. A raw iOS `.app` cannot be copied into `/Applications`; Mac Catalyst produces the correct macOS executable format.

See [`docs/BUILDING.md`](docs/BUILDING.md) for clean-machine steps, tests, signing notes, and the local packaging workflow.

## Create a local unsigned IPA

```bash
Scripts/package_public_ipa.sh
```

This creates `build/releases/KidPad-unsigned.ipa` and a SHA-256 checksum. The unsigned IPA must be signed for the destination device by Xcode, AltStore, or another signing service. It contains no Classic Pack and prompts for the optional download after installation.

KidPad does not currently publish a prebuilt IPA from this repository. That release artifact can be added separately without changing the source or asset boundary.

## Why the public bundle is data-free

The repository keeps the native application separate from historical reference material:

- `Sources/`, `Tests/`, `UITests/`, and `KidPad.xcodeproj` are the native app.
- `Resources/Licensed/` contains only resources whose redistribution terms are documented.
- `Resources/FidelityDev/` is an ignored local test cache; only its README is tracked.
- `Resources/JSKidPix/` and the optional local web reference are excluded from public builds.
- `Sources/ClassicAssetPack.swift` pins the approved file catalog, upstream URLs, and whole-pack digest.
- `Scripts/verify_release_assets.sh` scans every public build before it is shared.

This technical separation reduces accidental redistribution. It is not a statement that third-party artwork, sounds, names, or trademarks are in the public domain. Read [`RIGHTS_AND_LICENSES.md`](RIGHTS_AND_LICENSES.md) before distributing a binary or changing the resource boundary.

## Test and verify

```bash
xcodebuild -project KidPad.xcodeproj -scheme KidPad -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M5)' \
  CODE_SIGNING_ALLOWED=NO test

Scripts/verify_release_assets.sh /path/to/ReleasePublic/KidPad.app
```

Behavior status and remaining validation gaps are tracked in [`docs/PARITY_MATRIX.md`](docs/PARITY_MATRIX.md), [`HARDWARE_VALIDATION_REQUIRED.md`](HARDWARE_VALIDATION_REQUIRED.md), and [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md).

## Project map

- [`Sources/`](Sources/) contains the Swift app, native canvas, input, documents, audio, and Classic Pack installer.
- [`Tests/`](Tests/) and [`UITests/`](UITests/) contain automated coverage.
- [`docs/BUILDING.md`](docs/BUILDING.md) is the reproducible build and validation guide.
- [`docs/PARITY_MATRIX.md`](docs/PARITY_MATRIX.md) records tool-by-tool behavior status.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) explains the contribution workflow.
- [`SECURITY.md`](SECURITY.md) explains private vulnerability reporting.
- [`RIGHTS_AND_LICENSES.md`](RIGHTS_AND_LICENSES.md) defines the source and asset boundary.

## Contributing

Focused fixes, documentation improvements, clean-room assets, and reproducible bug reports are welcome. Include the build profile, device or Simulator version, reproduction steps, expected behavior, and a screenshot when it helps explain the issue.

Do not commit credentials, signing material, copied historical assets, or a local JSKidPix reference bundle. Start with [`CONTRIBUTING.md`](CONTRIBUTING.md), and use [`SECURITY.md`](SECURITY.md) for security-sensitive reports.

## License and acknowledgements

KidPad's native source is licensed under the [Apache License 2.0](LICENSE). Third-party and downloaded material has separate terms documented in [`NOTICE`](NOTICE), [`RIGHTS_AND_LICENSES.md`](RIGHTS_AND_LICENSES.md), and [`docs/THIRD_PARTY_FONTS.md`](docs/THIRD_PARTY_FONTS.md).

KidPad is inspired by the design language and creative spirit of early Kid Pix. It is not endorsed by, sponsored by, or affiliated with The Software MacKiev Company, Craig Hickman, or any current Kid Pix rights holder.
