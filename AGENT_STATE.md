# Agent State

## Current goal
Highest achievable Simulator-complete private fidelity state, with File/Edit/Goodies click-away dismissal verified on the live iPad Simulator and a GitHub-ready source tree. Hardware Pencil validation and historical asset/trademark clearance remain open gates.

## Last verified result
- Branch: `feature/native-kidpad`
- Commit: `b0db358`
- iPad Simulator: iPad Pro 11-inch (M5), iOS 26.5, `B8138F85-0AE9-4494-9564-EDC7FD4E3B7F`
- Canvas letterbox: COMPLETE — the 1920x1200 document is no longer stretched to fill portrait/landscape leftover space. `LetterboxedCanvasHost` sizes `kidpad.canvas` to 8:5; unused area is white. XCUITest `testCanvasKeepsDocumentAspectAcrossOrientations` passed (`artifacts/logs/aspect-229.log`). Evidence: `artifacts/simulator/aspect-live-portrait-229.png`, `artifacts/simulator/aspect-portrait-letterboxed-229.png`, `artifacts/simulator/aspect-landscape-letterboxed-229.png`.
- Classic menu click-away: COMPLETE — File/Edit/Goodies dropdowns now float over the canvas as a workspace overlay; tapping away (or choosing another menu) dismisses them. XCUITest `testClassicMenusDismissWhenClickingAway` passed on the live iPad (`artifacts/logs/menu-dismiss-219.log`, `artifacts/logs/native-full-suite-223.log`). Evidence: `artifacts/simulator/filemenu-open-219.png`, `artifacts/simulator/filemenu-dismissed-219.png`, `artifacts/simulator/launch-final-223.png`.
- Left-handed mode: COMPLETE — File > Left-Handed Mode mirrors the toolbar; toggling it off restores left-side tools. Launch flag `--left-handed-mode` only seeds the preference and no longer pins the layout. Test `testLeftHandedModeMirrorsToolbarToTheRight` passed (`artifacts/logs/left-handed-222.log`).
- Full suite: PASS, 37 unit + 26 UI, zero failures (`artifacts/logs/native-full-suite-223.log`, TEST SUCCEEDED).
- Fidelity assets: PASS, 222 original PNG/WAV files match pinned `ref/source-jskidpix@99c67f3` (133 exact hashes, 89 pixel-equivalent PNGs, `artifacts/logs/fidelity-assets-223.log`).
- Offline audit: PASS (`artifacts/logs/no-network-audit-223.log`).
- Public build: PASS; ReleasePublic bundle contains no historical names and no JSKidPix folder (`artifacts/logs/public-build-223.log`).
- Live Simulator: app installed from the exact full-suite Debug products and relaunched after reboot (`artifacts/simulator/launch-final-223.png`).

## Current blocker
Physical iPad and Apple Pencil are unavailable. Historical/public asset and trademark clearance remains unverified. Actual split-view capture remains unverified. Audible Simulator audio capture remains unavailable (KI-003).

## Decisions made
- Native Core Graphics raster document remains the drawing truth.
- Classic Mac menus are custom SwiftUI overlays, not UIKit popovers, so they can float and dismiss like System 6/7 menus.
- `--left-handed-mode` seeds `KidPad.leftHandedMode`; `--reset-document` resets that preference unless the seed flag is also present.
- `Resources/FidelityDev` stays in this private repository for the FidelityDev/Debug profile and is omitted from Release/ReleasePublic/DebugPublic.
- `Resources/JSKidPix` remains gitignored; it is only for the opt-in `--reference-web` harness.
- KidPad remains the canonical name; public commercial/App Store clearance is still required.

## Next highest-leverage action
Execute the physical Apple Pencil checklist on compatible hardware, and obtain written historical-asset / trademark clearance or ship only the public clean-room profile.
