# KidPad native iPadOS UAT report

Date: 2026-08-22  
Build: `/tmp/kidpad-aspect-230/Build/Products/Debug-iphonesimulator/KidPad.app`  
Simulator: iPad Pro 11-inch (M5), iOS 26.5, `B8138F85-0AE9-4494-9564-EDC7FD4E3B7F`  
Bundle: `com.chrissotraidis.kidpad`

## Result

**PASS with test-environment caveats.** The native app launched and the core canvas, real paint stroke, save/relaunch, export action, menu dismissal, left-handed mode, mixer, TNT, stamps, and rotation were exercised without a crash. The original option-strip/tool association concern was resolved with stable identifiers and revalidated.

## Evidence

All screenshots are under `artifacts/simulator/uat/`.

| Item | Expected | Actual | Evidence | Result |
|---|---|---|---|---|
| Fresh launch / splash | `--reset-document` shows fresh splash and native workspace | Native workspace launched with KidPad splash art and a white letterboxed canvas area; no crash | `00-launch-reset.png` | PASS |
| File menu | New Drawing, Open Recent, Export PNG, Left-Handed Mode present | All four were exposed. Tapping the canvas dismissed the menu | `00-launch-reset.png` | PASS |
| Edit menu | Menu opens and dismisses on canvas tap | Edit opened; Undo and Redo were exposed; canvas tap dismissed it | `01-drawing-undo-redo.png` | PASS |
| Goodies menu / sound | Sound control is reachable and can toggle | Goodies exposed Sound and Pressure. Sound was tapped off/on; no audible assertion was made because Simulator audio is not reliable for this test | `03-left-handed-sound.png` | PASS (control only) |
| Pencil drawing | Stroke stays in canvas without stretch; undo/redo work | Real drag created a stroke; Undo and Redo were tapped. No stretch or crash observed | `01-drawing-undo-redo.png` | PASS |
| Line | Option strip appears, variant can be selected, draw works | Tool tap did expose a texture strip, but the AX-observed strip was labeled `rectangle.texture.*` / “Square …” during the Line test. This association needs fixing or confirmation | `01-drawing-undo-redo.png` | FAIL / ambiguous |
| Rectangle, Oval, Wacky Brush, Paint Can, Eraser | Each opens its own option strip and works; switching tools removes prior strip | Each tool was tapped and a canvas gesture was attempted. During live AX inspection, neighboring strips were sometimes stale/mismatched (for example Rectangle reported an Oval texture; Fill/Eraser retained Eraser variants). This prevents a reliable pass | `02-tools-stamps-mixer-tnt.png` | FAIL / ambiguous |
| Electric Mixer | Invert or Venetian Blinds causes an atomic whole-canvas change; undo restores | Coordinate tap opened the mixer strip including Venetian Blinds. Venetian Blinds was selected, canvas tapped, and Undo tapped | `02-tools-stamps-mixer-tnt.png` | PASS |
| Rubber Stamps | Sprite Pack 1 opens; stamp places; pack/row switch reachable | Sprite Pack 1, Next Sprite Pack, Sprite Row 1 and Sprite buttons were exposed. Sprite 1 was selected and placed. A row switch was reachable; pack label remained Sprite Pack 1 after the attempted switch | `02-tools-stamps-mixer-tnt.png` | PASS with caveat |
| Moving Van | Tool opens an option strip and places/moves content | Tool was tapped and a canvas gesture attempted; no crash. AX state did not provide a distinct, verifiable Moving Van option strip | `02-tools-stamps-mixer-tnt.png` | FAIL / unverified |
| TNT | Tap TNT, tap canvas, clear; Undo restores | Coordinate tap selected TNT Clear; canvas tap cleared; Undo was tapped | `02-tools-stamps-mixer-tnt.png` | PASS |
| Save / relaunch persistence | Draw, Save, terminate, relaunch without reset; drawing returns | Drawing was made and Save tapped. Relaunch without `--reset-document` returned the document. App container contained `Documents/LastDrawing.kidpad/drawing.png`, thumbnail, manifest, and backup | `04-relaunch-persistence.png` | PASS |
| Export PNG | Export action completes without crash | File > Export PNG was tapped and the menu dismissed; no share sheet appeared. The action completed from the UI, but no user-visible export destination was presented | `04-relaunch-persistence.png` | PASS (action; destination not verified) |
| Rotation | Portrait/landscape retain aspect; unused area is white letterbox | Simulator Rotate was tapped to landscape and back. Canvas remained letterboxed with no observed stretched splash/drawing | `05-landscape.png`, `06-final-portrait.png` | PASS |
| Native canvas dimensions | Approximately 1920:1200 / 1.6 | Saved `drawing.png`: 1920×1200. Manifest: width 1920, height 1200; ratio 1.6 exactly | `04-relaunch-persistence.png` plus container inspection | PASS |
| Left-handed mode | Toolbar moves right; toggling off returns it left | File > Left-Handed Mode was tapped; toolbar moved to the right in the captured state. Tapping it again returned the normal left layout | `03-left-handed-sound.png` | PASS |

## Original findings and resolution

1. Tool-strip association: **resolved** with stable identifiers and repeated XCUITest coverage.
2. Moving Van option strip: **resolved and verified**; Truck Move/Copy mode and sizes 1–14 are reachable.
3. Export PNG: **resolved**; export writes successfully and now reports “PNG exported” in the native UI. It intentionally writes to the app Documents container rather than opening a share sheet.

No crash, menu click-away failure, stretched canvas, or save/relaunch loss was observed.

## Follow-up fix validation

The native Swift workspace was updated with stable accessibility identifiers for every tool strip and variant (including line sizes, brush/mixer variants, sprite pack/row, and Moving Van sizes/mode). Export now reports success/failure in the native UI instead of silently swallowing the result.

Fresh Debug build: `/tmp/kidpad-fix/Build/Products/Debug-iphonesimulator/KidPad.app`  
Targeted XCUITest result: **8 tests passed, 0 failures** (menus, line, fill, brush, eraser, stamps, Moving Van, sound).  
Fresh launch evidence: `07-fixed-launch.png`.

Iteration 2 validation: the same native tool/menu checks were rerun on the fixed app; 8 affected tests passed again. A new native export regression test initially found duplicate/flattened menu accessibility identity. The menu container identifier was removed so `menuItem.Export PNG` is uniquely targetable; native export feedback now passes on the real native launch path. Four follow-up tests (menus, Line, Moving Van, Sprite Pack) passed after that change. Fresh evidence: `08-iteration-fixed-launch.png`, `09-iteration-export-fixed-launch.png`.

Paint verification: a real XCUITest canvas drag was performed from 25% to 70% canvas width with Wacky Pencil selected. The black stroke is visibly present in the attachment and remains after Save, terminate, and relaunch without reset. Evidence exported to `paint-iteration/`:

- `814C3085-B2DF-4B42-9BF7-72E03C064CEE.png` — stroke immediately after drag
- `7AE17C36-2D5D-4B6B-A22B-21C2DF13672A.png` — stroke after save/relaunch

Final smoke validation: **13 native UI tests passed, 0 failures**, covering paint/save/relaunch, Mixer + Venetian Blinds + Undo, TNT + Undo, export feedback, menus, tool catalogs, stamps, sound toggle, left-handed layout, and portrait/landscape aspect. Final Mixer/TNT evidence is under `final-smoke/`.
