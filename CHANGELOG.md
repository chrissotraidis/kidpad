# Changelog

All notable public releases of KidPad are documented here.

## 2.0.1 - 2026-11-21

KidPad 2.0.1 works on a TV or monitor connected to an iPad, and PadMint can open it.

### Highlights

- On an iPad's extended display, KidPad now fills the screen the right way up; the iPad accepts every orientation so iPadOS no longer leaves it rotated or squeezed on the external screen. iPhone keeps portrait and landscape.
- KidPad answers `padmint-kidpad://`, so PadMint's library shows it as installed and starts it.

### Validation

- Installed over 2.0.0 on an iPad Pro and played on a 1280×720 TV with the Classic Pack and saved drawings kept (November 2026).
- The public release gate (repository and network boundaries, public build, IPA packaging and asset policy) passes from a clean checkout of `main`.

## 2.0.0 - 2026-08-23

KidPad Version 2 adds native iPhone support while preserving the accepted iPad experience.

### Highlights

- One universal iOS IPA for iPhone and iPad.
- A compact, paged iPhone toolbar that keeps the familiar Kid Pix controls at the top.
- A collapsible File, Edit, and Goodies menu that reclaims drawing space in portrait and landscape.
- A full-height iPhone canvas with two-finger zoom and pan that does not leave accidental marks.
- Touch targets and option shelves sized for smaller displays without changing the iPad layout.

### Validation

- The final iPhone layout was accepted by hands-on testing on a physical iPhone 14 in portrait and landscape.
- Focused canvas-navigation, phone-layout, and menu-collapse tests pass.
- The public asset scan and universal unsigned IPA packaging pass.

## 1.0.0 - 2026-08-23

KidPad Version 1 is the first stable public iPad release.

### Highlights

- Native Swift, SwiftUI, UIKit, and Core Graphics recreation of the early Kid Pix experience.
- Apple Pencil pressure support with coalesced input and lower-latency predicted-stroke feedback.
- Pencil, shapes, Wacky Brush, Electric Mixer, Fill, Eraser, Alphabet, Rubber Stamps, Moving Van, TNT, Undo, and Redo.
- Autosave, recovery, recent drawings, PNG export, responsive layouts, and left-handed mode.
- iPadOS 17 or later support plus Mac Catalyst support.
- The distributed Version 1 IPA is iPad-only. Native iPhone support is planned for Version 2.
- User-approved Classic Pack download from a pinned JSKidPix revision with a fixed catalog and SHA-256 verification.
- Public build and unsigned IPA workflows that keep the Classic Pack and development reference harness outside the app bundle.

### Validation

- Clean AltStore installation and first-run Classic Pack setup accepted on an iPad Pro 12.9-inch (6th generation).
- Apple Pencil latency and pressure feel accepted on physical hardware.
- Public simulator build, public asset scan, and unsigned arm64 IPA packaging pass.

### Known boundaries

- Tilt, hover, double-tap, squeeze, roll, the full palm-rejection matrix, and retained audible-output evidence remain incomplete checks.
- Historical artwork, sounds, naming, and trademark rights are not independently cleared by this project. See [`RIGHTS_AND_LICENSES.md`](RIGHTS_AND_LICENSES.md).
