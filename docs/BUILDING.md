# Building KidPad

This guide covers the public, reproducible build path. Classic JSKidPix data is
downloaded after user consent and is never part of the compiled app bundle.

## Requirements

- macOS with Xcode and the project’s supported iOS SDK
- An iPad Simulator runtime; the UAT reference device is iPad Pro 11-inch (M5)
- Apple Developer signing only when installing on physical hardware

## Public Simulator build

From a clean checkout:

```bash
git clone https://github.com/chrissotraidis/kidpad.git
cd kidpad
Scripts/build_public.sh
```

The script builds `ReleasePublic` for `iphonesimulator` in a temporary derived
data directory, locates `KidPad.app`, and runs the release asset scanner. It
must pass before sharing a Simulator app or creating a release artifact.

## Unsigned iPad IPA

```bash
Scripts/package_public_ipa.sh
```

This produces `build/releases/KidPad-v1.0.0-unsigned.ipa` and a `.sha256`
checksum from a generic iOS `ReleasePublic` build. The package script verifies
the app version and confirms that Version 1 advertises only the iPad device
family. It runs the same asset scanner and verifies the new ZIP before replacing
any previous artifact. A sideloading tool must re-sign it for the user's iPad.
The Classic Pack is not inside the IPA; the installed app asks before
downloading it from the pinned upstream revision.

For a development build with code signing disabled:

```bash
xcodebuild -project KidPad.xcodeproj -scheme KidPad -configuration DebugPublic \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M5)' \
  CODE_SIGNING_ALLOWED=NO build
```

Install and launch the resulting app with the Simulator or Xcode. To start a
fresh document, launch with `--reset-document`; launch without that argument to
exercise persistence.

## Tests and release checks

```bash
zsh -n Scripts/*.sh
Scripts/verify_public_repo.sh
Scripts/verify_no_network.sh .

xcodebuild -project KidPad.xcodeproj -scheme KidPad -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M5)' \
  CODE_SIGNING_ALLOWED=NO test

Scripts/verify_release_assets.sh /path/to/KidPad.app
```

The release scanner rejects Classic Pack resources, the optional JSKidPix
reference bundle, and development-only WebKit linkage. The public build
contains the native runtime only. `Scripts/verify_fidelity_assets.sh` verifies
the ignored private test cache and is not a publication check.

## Xcode workflow

Open `KidPad.xcodeproj`, select the `KidPad` scheme, choose an iPad Simulator,
and run. All configurations keep the Classic Pack out of the app bundle;
`ReleasePublic` is the supported distribution configuration.

## Physical devices

A physical-device build requires an Apple Developer team, provisioning, and
signing configured in Xcode. Select a connected iPad, choose the project team,
and build `ReleasePublic`.

The Version 1 candidate was installed cleanly on an iPad Pro 12.9-inch (6th
generation) through AltStore on 2026-08-23. First-run Classic Pack setup,
Apple Pencil drawing, pressure response, and the lower-latency brush path were
accepted by hands-on testing. Altitude, azimuth, hover, double-tap, squeeze,
roll, and the complete palm-rejection matrix remain targeted checks. Record
those results in
[`HARDWARE_VALIDATION_REQUIRED.md`](../HARDWARE_VALIDATION_REQUIRED.md).

## Asset and network boundaries

Public builds must use `DebugPublic` or `ReleasePublic`. On first launch, the
user can approve a roughly 2 MB download directly from the pinned JSKidPix
revision. KidPad verifies the complete 228-file digest before atomically
installing the pack in Application Support. The app downloads data only, never
JavaScript or executable code. Read
[`RIGHTS_AND_LICENSES.md`](../RIGHTS_AND_LICENSES.md) before changing resource
membership or adding images, audio, fonts, or third-party code.

See [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) before changing repository
visibility, tagging a release, or hosting an unsigned IPA.
