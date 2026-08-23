# KidPad

Native drawing for iPad, inspired by the playful creative experience of the
classic Kid Pix.

KidPad is an independent Swift app with a native Core Graphics raster canvas,
SwiftUI workspace, UIKit drawing input, touch tools, sound effects, documents,
and an iPad-first layout. The shipping canvas is native; the optional web
reference harness is only a local comparison tool.

KidPad is not Kid Pix and is not affiliated with any Kid Pix rights holder. The
app does not bundle JSKidPix or its classic artwork and sounds.

## Current status

The native workspace and P0 drawing workflow are active and verified in the iPad
Simulator. Physical Apple Pencil pressure, tilt, hover, roll, squeeze, and palm
rejection still require hardware validation; see
[`HARDWARE_VALIDATION_REQUIRED.md`](HARDWARE_VALIDATION_REQUIRED.md).

## What works

| Area | Current result |
| --- | --- |
| Canvas | Native 1920×1200 raster document with an 8:5 letterboxed presentation |
| Drawing | Pencil, line, rectangle, oval, Wacky Brush, fill, eraser, Undo, and Redo |
| Creative tools | Electric Mixer, TNT, Alphabet, Rubber Stamps, Moving Van |
| Workspace | File, Edit, and Goodies menus with click-away dismissal |
| Layout | Portrait, landscape, compact-width, and left-handed toolbar layouts |
| Documents | Autosave, backup recovery, thumbnails, Save, and PNG export |
| Audio | Goodies mute control and bounded sound playback policy |
| First launch | With the user's consent, downloads and verifies a pinned JSKidPix Classic Pack |
| Public profile | App bundle excludes the Classic Pack and the web reference bundle |

## Get started

Requirements: macOS with Xcode installed and an iPad Simulator runtime. The
project currently targets the iPad Simulator; physical-device builds require
your own Apple signing setup.

```bash
git clone https://github.com/chrissotraidis/kidpad.git
cd kidpad
Scripts/build_public.sh
```

`Scripts/build_public.sh` builds the `ReleasePublic` configuration in isolated
derived data and scans the resulting app bundle for excluded research assets.
For the full clean-machine workflow, simulator launch steps, tests, and device
signing notes, see [`docs/BUILDING.md`](docs/BUILDING.md).

On first launch, KidPad explains that it needs the Classic Pack. If the user
chooses Download, the app fetches 228 PNG/WAV data files directly from the
immutable `vikrum/kidpix@99c67f3427d229f7db60b03dcf19df4d8c2a8ecf`
revision, verifies the complete pack digest, and installs it in Application
Support. No executable code is downloaded.

To create an unsigned device IPA for a sideloading service to re-sign:

```bash
Scripts/package_public_ipa.sh
```

The results are `build/releases/KidPad-unsigned.ipa` and its `.sha256` checksum.
The IPA contains the app code, asset catalog, and licensed font only. A user
installs it with their own signing method, approves the Classic Pack download,
and then uses KidPad normally.

To run the native app in the Simulator from Xcode, open
`KidPad.xcodeproj`, select the `KidPad` scheme, choose an iPad Simulator, and
Run. The default bundle identifier is `com.chrissotraidis.kidpad`.

## Build profiles

| Configuration | Intended use | Historical/reference assets |
| --- | --- | --- |
| `DebugPublic` | Public development | Not bundled; downloaded after consent |
| `ReleasePublic` | Public/release engineering | Not bundled; verified by scanner |
| `Debug` / `FidelityDev` | Fidelity development and tests | Not bundled; may use an ignored local cache in tests |

Use `ReleasePublic` for any binary that leaves the development environment.

## Test and verify

```bash
xcodebuild -project KidPad.xcodeproj -scheme KidPad -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M5)' \
  CODE_SIGNING_ALLOWED=NO test

Scripts/verify_release_assets.sh /path/to/ReleasePublic/KidPad.app
```

The Simulator UAT evidence map is in
[`docs/SIMULATOR_SCENARIOS.md`](docs/SIMULATOR_SCENARIOS.md). Remaining known
limitations are tracked in [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md).

## Public-source boundary

The repository intentionally separates native source from research material:

- `Sources/`, `Tests/`, `UITests/`, and the Xcode project are the native app.
- `Resources/FidelityDev` is an ignored private test cache; only its README is
  tracked.
- `Resources/JSKidPix` and `ref/` support an opt-in local comparison harness;
  they are excluded from public builds.
- `Sources/ClassicAssetPack.swift` pins the upstream commit, exact data-file
  catalog, download URLs, and whole-pack digest.
- `Scripts/build_public.sh` and `Scripts/verify_release_assets.sh` are the
  publication boundary. Read [`RIGHTS_AND_LICENSES.md`](RIGHTS_AND_LICENSES.md)
  before adding assets or sharing a binary.

## Project map

- [`Sources/`](Sources/) — native Swift application and canvas engine
- [`Tests/`](Tests/) and [`UITests/`](UITests/) — automated coverage
- [`docs/BUILDING.md`](docs/BUILDING.md) — build and validation guide
- [`FIDELITY_MATRIX.md`](FIDELITY_MATRIX.md) — behavior-by-behavior status
- [`docs/SIMULATOR_SCENARIOS.md`](docs/SIMULATOR_SCENARIOS.md) — live UAT map
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — contribution workflow
- [`SECURITY.md`](SECURITY.md) — private vulnerability reporting guidance
- [`RIGHTS_AND_LICENSES.md`](RIGHTS_AND_LICENSES.md) — source and asset boundary

## Contributing and support

Bug reports, focused improvements, documentation fixes, and clean-room asset
contributions are welcome. Please include the build profile, device or
Simulator runtime, reproduction steps, expected behavior, and screenshots when
they clarify a UI issue. Start with [`CONTRIBUTING.md`](CONTRIBUTING.md).

Do not commit credentials, ROMs, copied historical assets, or the local web
reference bundle. For security-sensitive problems, follow
[`SECURITY.md`](SECURITY.md) instead of opening a public issue.

## License and acknowledgements

Native KidPad source is licensed under the Apache License 2.0; see
[`LICENSE`](LICENSE) and [`NOTICE`](NOTICE). Downloaded and third-party material
has separate terms documented in
[`RIGHTS_AND_LICENSES.md`](RIGHTS_AND_LICENSES.md).

KidPad is an independent project inspired by the design language and creative
spirit of early Kid Pix. It is not endorsed by, sponsored by, or affiliated
with The Software MacKiev Company, Craig Hickman, or any current Kid Pix rights
holder.

## Optional web reference

`--reference-web` loads a local pinned copy of the JSKidPix HTML/JS inside a
`WKWebView` for comparison only. It is not the product canvas and is excluded
from `DebugPublic` and `ReleasePublic`.
