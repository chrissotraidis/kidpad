# KidPad Evidence Report

Updated: 2026-08-21

## Completion state

Highest verified Simulator state: P0 simulator-complete with reference fidelity assets wired into the private FidelityDev/Debug build, classic menu click-away dismissal verified on the live iPad Simulator, and a GitHub-ready source tree.

Separate gates remain `HARDWARE_VALIDATION_PENDING` and `LEGAL_ASSET_BLOCKED`. This report does not claim physical Apple Pencil validation, public-release clearance for historical assets, or exact historical pixel identity where evidence is unavailable.

## Build

- Branch: `feature/native-kidpad`
- Xcode: 26.6 (17F113)
- Simulator SDK: 26.5
- Device: iPad Pro 11-inch (M5), iOS 26.5, `B8138F85-0AE9-4494-9564-EDC7FD4E3B7F`
- Project: `KidPad.xcodeproj`, scheme `KidPad`
- Latest full verification: `xcodebuild -project KidPad.xcodeproj -scheme KidPad -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,id=B8138F85-0AE9-4494-9564-EDC7FD4E3B7F' -derivedDataPath /tmp/kidpad-full-223 CODE_SIGNING_ALLOWED=NO test`
- Result: PASS; log `artifacts/logs/native-full-suite-223.log`

## Tests and Simulator evidence

- 37 unit tests passed, 26 UI tests passed, 0 failures.
- Click-away: File menu opens over the canvas and disappears after tapping away (`testClassicMenusDismissWhenClickingAway`, `artifacts/simulator/filemenu-open-219.png`, `artifacts/simulator/filemenu-dismissed-219.png`).
- Left-handed mode toggle restores the left toolbar (`testLeftHandedModeMirrorsToolbarToTheRight`).
- Live launch after the suite: `artifacts/simulator/launch-final-223.png`.
- Original asset provenance: 222 PNG/WAV assets match pinned `vikrum/kidpix@99c67f3` (`artifacts/logs/fidelity-assets-223.log`).
- Offline audit: PASS (`artifacts/logs/no-network-audit-223.log`).
- Public build: PASS; ReleasePublic bundle has no historical filenames and no JSKidPix folder (`artifacts/logs/public-build-223.log`).

## Feature status

| Feature | Implemented | Simulator verified | Hardware verified | Fidelity status | Asset status |
|---|---:|---:|---:|---|---|
| Pencil, line, rectangle, oval | Yes | Yes | No | Native deterministic raster | Original toolbar assets, research-only |
| Wacky Brushes | Yes, all 28 variants | Yes | No | Native deterministic approximations | Original source assets, research-only |
| Fill, eraser, TNT | Yes | Yes | No | Bounded scanline fill; TNT uses original cursor/sound | Original source assets, research-only |
| Electric Mixer | Yes, 14 variants | Yes | No | Native deterministic approximations | Original source assets, research-only |
| Alphabet and stamps | Yes | Yes | No | Original sprite packs, animal stamps, stickers | Original source assets, research-only |
| Moving Van | Yes, 14 sizes and Move/Copy | Yes | No | Native deterministic approximation | Original source assets, research-only |
| Classic menus | Yes | Yes | N/A | System 6/7 overlay chrome with click-away dismissal | Native chrome; research-only assets elsewhere |
| Undo, autosave, recovery, PNG export | Yes | Yes | N/A | Atomic `.kidpad` package with backup | Clean native implementation |
| Sound policy / mute | Yes | Yes, wiring-level | N/A | Source WAVs in FidelityDev; audible capture unavailable | Original source audio, research-only |

## Legal and asset status

- Native code: Apache-2.0 (`LICENSE`).
- Reference repo: `ref/source-jskidpix` at `vikrum/kidpix@99c67f3`, treated as GPLv3.
- Historical PNG/WAV files in `Resources/FidelityDev` are `research-only`.
- Public validator: PASS because those files and the JSKidPix harness are omitted from ReleasePublic.
- No rights, trademark permission, or public redistribution permission has been inferred.

## Hardware status

No compatible physical iPad/Apple Pencil was available. See `HARDWARE_VALIDATION_REQUIRED.md`.

## Remaining issues

- Physical Pencil checklist.
- Historical asset / trademark / license clearance or a cleared public asset profile.
- Actual split-view/multitasking capture.
- Historical canvas-dimension measurement and Moving Van keyboard-modifier behavior.

## Truthful conclusion

KidPad has reached the highest currently supportable private Simulator fidelity state for the implemented P0 scope, including live iPad verification of classic menu click-away. It is GitHub-ready as a private engineering repository. It is not fully complete because hardware validation and public legal/asset gates remain open.
