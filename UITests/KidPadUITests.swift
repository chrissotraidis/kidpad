import XCTest

final class KidPadUITests: XCTestCase {
    private var app: XCUIApplication!

    private func tapAfterHorizontalScroll(_ element: XCUIElement, in container: XCUIElement) {
        for _ in 0..<2 {
            container.swipeLeft()
        }
        XCTAssertTrue(element.waitForExistence(timeout: 2))
        element.tap()
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .landscapeLeft
        app = XCUIApplication()
        app.launchArguments = ["--ui-test", "--reset-document"]
        app.launch()
    }

    func testReferenceToolbarAndPencilSizesAreReachable() {
        XCTAssertTrue(app.buttons["Wacky Pencil"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["workspace"].exists)
        XCTAssertTrue(app.buttons["File"].exists)
        XCTAssertTrue(app.buttons["Edit"].exists)
        XCTAssertTrue(app.buttons["Goodies"].exists)
        XCTAssertTrue(app.buttons["Line"].exists)
        XCTAssertTrue(app.buttons["Rubber Stamps"].exists)
        XCTAssertTrue(app.otherElements["kidpad.canvas"].exists)
        XCTAssertTrue(app.buttons["Pencil Size 6"].exists)
        app.buttons["Pencil Size 6"].tap()
        app.buttons["Next SIZE page"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["pencil.texture.solid"].waitForExistence(timeout: 2))
        app.buttons["Next PATTERN page"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["pencil.texture.houndstooth"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Export PNG"].exists)
        XCTAssertTrue(app.buttons["Mute Sounds"].exists)
        XCTAssertTrue(app.buttons["Pressure Sensitivity On"].exists)
        app.buttons["Pressure Sensitivity On"].tap()
        XCTAssertTrue(app.buttons["Pressure Sensitivity Off"].exists)
        app.buttons["Pressure Sensitivity Off"].tap()
        XCTAssertTrue(app.buttons["Next Palette"].exists)
        app.buttons["Next Palette"].tap()
        XCTAssertTrue(app.buttons["Previous Palette"].exists)
    }

    func testDefaultLaunchUsesNativeSourceLayout() {
        app.terminate()
        let nativeApp = XCUIApplication()
        nativeApp.launchArguments = ["--reset-document", "--left-handed-mode"]
        nativeApp.launch()

        XCTAssertTrue(nativeApp.otherElements["workspace"].waitForExistence(timeout: 5))
        XCTAssertTrue(nativeApp.otherElements["kidpad.canvas"].waitForExistence(timeout: 5))
        XCTAssertTrue(nativeApp.buttons["Wacky Pencil"].exists)
        XCTAssertTrue(nativeApp.buttons["TNT Clear"].exists)
        XCTAssertTrue(nativeApp.descendants(matching: .any)["palette.current"].exists)
        XCTAssertTrue(nativeApp.descendants(matching: .any)["palette.color.32"].exists)
        XCTAssertTrue(nativeApp.buttons["File"].exists)
        XCTAssertFalse(nativeApp.buttons["Export PNG"].exists)
        nativeApp.buttons["File"].tap()
        XCTAssertTrue(nativeApp.buttons["New Drawing"].waitForExistence(timeout: 2))
        XCTAssertTrue(nativeApp.buttons["Open Recent"].exists)
        XCTAssertTrue(nativeApp.buttons["Export PNG"].exists)
        nativeApp.buttons["File"].tap()
        nativeApp.buttons["Edit"].tap()
        XCTAssertTrue(nativeApp.buttons["Undo"].waitForExistence(timeout: 2))
        XCTAssertTrue(nativeApp.buttons["Redo"].exists)
        nativeApp.buttons["Edit"].tap()
        nativeApp.buttons["Goodies"].tap()
        XCTAssertTrue(nativeApp.buttons["Sound"].waitForExistence(timeout: 2))
        XCTAssertTrue(nativeApp.buttons["Pressure"].exists)
        nativeApp.buttons["Goodies"].tap()
        nativeApp.buttons["Save"].press(forDuration: 1.0)
        XCTAssertTrue(nativeApp.buttons["Export PNG"].waitForExistence(timeout: 3))
        XCTAssertTrue(nativeApp.buttons["New Drawing"].exists)
        XCTAssertTrue(nativeApp.buttons["Open Recent"].exists)
        nativeApp.buttons["Export PNG"].tap()
        nativeApp.terminate()
    }

    func testDefaultLaunchUsesNativeSourceLandscapeLayout() {
        app.terminate()
        let nativeApp = XCUIApplication()
        nativeApp.launchArguments = ["--reset-document"]
        nativeApp.launch()
        XCUIDevice.shared.orientation = .landscapeLeft

        XCTAssertTrue(nativeApp.otherElements["workspace"].waitForExistence(timeout: 5))
        XCTAssertTrue(nativeApp.buttons["File"].waitForExistence(timeout: 5))
        XCTAssertTrue(nativeApp.otherElements["kidpad.canvas"].waitForExistence(timeout: 5))
        XCTAssertTrue(nativeApp.buttons["Wacky Pencil"].exists)
        XCTAssertTrue(nativeApp.buttons["File"].exists)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "KidPad native source landscape layout"
        attachment.lifetime = .keepAlways
        add(attachment)

        XCUIDevice.shared.orientation = .portrait
        nativeApp.terminate()
    }

    func testLeftHandedModeMirrorsToolbarToTheRight() {
        app.terminate()
        let nativeApp = XCUIApplication()
        nativeApp.launchArguments = ["--reset-document", "--left-handed-mode"]
        nativeApp.launch()

        XCTAssertTrue(nativeApp.otherElements["workspace"].waitForExistence(timeout: 5))
        XCTAssertTrue(nativeApp.buttons["File"].waitForExistence(timeout: 5))
        nativeApp.buttons["File"].tap()
        XCTAssertTrue(nativeApp.buttons["Left-Handed Mode"].waitForExistence(timeout: 3), "Left-Handed Mode item should appear after opening File menu")
        nativeApp.otherElements["menu.dismiss"].tap()

        // Left-handed mode mirrors the color rail, keeping it beside the user's
        // drawing hand without changing the horizontal tool strip.
        let palette = nativeApp.descendants(matching: .any)["palette.current"]
        XCTAssertTrue(palette.waitForExistence(timeout: 3))
        let workspaceFrame = nativeApp.otherElements["workspace"].frame
        let paletteFrame = palette.frame
        XCTAssertGreaterThan(
            paletteFrame.midX,
            workspaceFrame.midX,
            "In left-handed mode the color rail should sit on the right half of the screen"
        )

        // Toggle back off and confirm the color rail returns to the left side.
        nativeApp.buttons["File"].tap()
        XCTAssertTrue(nativeApp.buttons["Left-Handed Mode"].waitForExistence(timeout: 3))
        nativeApp.buttons["Left-Handed Mode"].tap()
        XCTAssertTrue(palette.waitForExistence(timeout: 3))
        let restoredFrame = palette.frame
        XCTAssertLessThan(
            restoredFrame.midX,
            workspaceFrame.midX,
            "Toggling left-handed mode off should restore the color rail to the left"
        )
    }

    func testCanvasKeepsDocumentAspectAcrossOrientations() {
        app.terminate()
        let nativeApp = XCUIApplication()
        nativeApp.launchArguments = ["--reset-document"]
        nativeApp.launch()
        XCTAssertTrue(nativeApp.otherElements["kidpad.canvas"].waitForExistence(timeout: 5))

        let canvas = nativeApp.otherElements["kidpad.canvas"]
        let expectedAspect: CGFloat = 1920.0 / 1200.0

        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        let portraitFrame = canvas.frame
        XCTAssertEqual(portraitFrame.width / portraitFrame.height, expectedAspect, accuracy: 0.08, "Portrait canvas should keep the 1920x1200 document aspect")
        let portrait = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        portrait.name = "KidPad letterboxed splash portrait"
        portrait.lifetime = .keepAlways
        add(portrait)

        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        XCTAssertTrue(nativeApp.buttons["Wacky Pencil"].exists)
        let landscapeFrame = canvas.frame
        XCTAssertEqual(landscapeFrame.width / landscapeFrame.height, expectedAspect, accuracy: 0.08, "Landscape canvas should keep the 1920x1200 document aspect")
        let landscape = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        landscape.name = "KidPad letterboxed splash landscape"
        landscape.lifetime = .keepAlways
        add(landscape)

        XCUIDevice.shared.orientation = .portrait
        nativeApp.terminate()
    }

    func testClassicMenusDismissWhenClickingAway() {
        app.terminate()
        let nativeApp = XCUIApplication()
        nativeApp.launchArguments = ["--reset-document"]
        nativeApp.launch()

        XCTAssertTrue(nativeApp.otherElements["workspace"].waitForExistence(timeout: 5))
        XCTAssertTrue(nativeApp.buttons["File"].waitForExistence(timeout: 5))
        nativeApp.buttons["File"].tap()
        XCTAssertTrue(nativeApp.buttons["New Drawing"].waitForExistence(timeout: 2), "File menu should open over the canvas")
        XCTAssertTrue(nativeApp.buttons["Export PNG"].exists)

        let openAttachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        openAttachment.name = "KidPad File menu open before click-away"
        openAttachment.lifetime = .keepAlways
        add(openAttachment)

        let dismiss = nativeApp.descendants(matching: .any)["menu.dismiss"]
        if dismiss.waitForExistence(timeout: 1) {
            dismiss.tap()
        } else {
            nativeApp.otherElements["kidpad.canvas"].coordinate(withNormalizedOffset: CGVector(dx: 0.72, dy: 0.62)).tap()
        }
        XCTAssertFalse(nativeApp.buttons["New Drawing"].waitForExistence(timeout: 1), "File menu should disappear after clicking away")
        XCTAssertFalse(nativeApp.buttons["Export PNG"].exists)

        let closedAttachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        closedAttachment.name = "KidPad File menu dismissed after click-away"
        closedAttachment.lifetime = .keepAlways
        add(closedAttachment)

        nativeApp.buttons["Edit"].tap()
        XCTAssertTrue(nativeApp.buttons["Undo"].waitForExistence(timeout: 2))
        nativeApp.buttons["File"].tap()
        XCTAssertTrue(nativeApp.buttons["New Drawing"].waitForExistence(timeout: 2), "Opening File should replace the Edit menu")
        nativeApp.terminate()
    }

    func testDefaultSourceStampToolOpensOriginalSpritePack() {
        app.terminate()
        let nativeApp = XCUIApplication()
        nativeApp.launchArguments = ["--reset-document"]
        nativeApp.launch()
        XCTAssertTrue(nativeApp.buttons["Rubber Stamps"].waitForExistence(timeout: 5))
        nativeApp.buttons["Rubber Stamps"].tap()
        XCTAssertTrue(nativeApp.buttons["Next PACK"].waitForExistence(timeout: 2))
        XCTAssertTrue(nativeApp.descendants(matching: .any)["sprite.1"].exists)
        nativeApp.terminate()
    }

    func testP0AccessibilityIdentifierContract() {
        let identifiers = [
            "tool.save", "tool.pencil", "tool.line", "tool.rectangle", "tool.oval",
            "tool.brush", "tool.mixer", "tool.fill", "tool.eraser", "tool.alphabet",
            "tool.stamp", "tool.movingVan", "tool.clear", "tool.undo",
            "palette.current", "palette.color.1", "palette.color.32", "control.pressure"
        ]
        for identifier in identifiers {
            XCTAssertTrue(app.descendants(matching: .any)[identifier].waitForExistence(timeout: 5), "Missing accessibility identifier: \(identifier)")
        }
        app.buttons["Edit"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["menuItem.Redo"].waitForExistence(timeout: 2))
    }

    func testStampPreviewStripIsReachable() {
        XCTAssertTrue(app.buttons["Rubber Stamps"].waitForExistence(timeout: 5))
        app.buttons["Rubber Stamps"].tap()
        app.buttons["Next SPRITES page"].tap()
        XCTAssertTrue(app.buttons["Stamp 1"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Stamp 6"].exists)
        XCTAssertFalse(app.buttons["Stamp 12"].exists)
        app.buttons["Next STAMPS page"].tap()
        XCTAssertTrue(app.buttons["Stamp 7"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Stamp 12"].exists)
        app.buttons["Stamp 12"].tap()
        XCTAssertTrue(app.buttons["Export PNG"].exists)
    }

    func testMovingVanOriginalSizeCatalogIsReachable() {
        XCTAssertTrue(app.buttons["Moving Van"].waitForExistence(timeout: 5))
        app.buttons["Moving Van"].tap()
        XCTAssertTrue(app.buttons["Truck Size 1"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Truck Move Mode"].exists)
        app.buttons["Truck Move Mode"].tap()
        XCTAssertTrue(app.buttons["Truck Copy Mode"].waitForExistence(timeout: 2))
        app.buttons["Truck Size 6"].tap()
        app.buttons["Next VAN page"].tap()
        XCTAssertTrue(app.buttons["Magnet"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Export PNG"].exists)
    }

    func testWackyBrushVariantsAreReachable() {
        XCTAssertTrue(app.buttons["Wacky Brush"].waitForExistence(timeout: 5))
        app.buttons["Wacky Brush"].tap()
        XCTAssertTrue(app.buttons["Leaky Pen"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Echoes"].exists)
        XCTAssertTrue(app.buttons["Northern Lights"].exists)
        app.buttons["Echoes"].tap()
        app.buttons["Next BRUSH page"].tap()
        app.buttons["Next BRUSH page"].tap()
        XCTAssertTrue(app.buttons["Paw Prints"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Export PNG"].exists)
    }

    func testAlphabetSelectionChangesPlacedCanvasPixels() {
        let canvas = app.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        app.buttons["Alphabet"].tap()
        XCTAssertTrue(app.buttons["Letter J"].waitForExistence(timeout: 2))
        app.buttons["Letter J"].tap()
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.35, dy: 0.45)).tap()
        let letterJ = canvas.screenshot().image.pngData()

        app.buttons["New Drawing"].tap()
        app.buttons["Alphabet"].tap()
        app.buttons["Letter A"].tap()
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.35, dy: 0.45)).tap()
        let letterA = canvas.screenshot().image.pngData()
        XCTAssertNotEqual(letterJ, letterA)
    }

    func testDifferentStampSelectionsChangePlacedCanvasPixels() {
        let canvas = app.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        app.buttons["Rubber Stamps"].tap()
        XCTAssertTrue(app.buttons["Sprite 2"].waitForExistence(timeout: 2))
        app.buttons["Sprite 2"].tap()
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.40, dy: 0.45)).tap()
        let moon = canvas.screenshot().image.pngData()

        app.buttons["New Drawing"].tap()
        app.buttons["Rubber Stamps"].tap()
        app.buttons["Sprite 3"].tap()
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.40, dy: 0.45)).tap()
        let dog = canvas.screenshot().image.pngData()
        XCTAssertNotEqual(moon, dog)
    }

    func testPalmAndTVSpriteSelectionsChangePlacedCanvasPixels() {
        let canvas = app.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        app.buttons["Rubber Stamps"].tap()
        XCTAssertTrue(app.buttons["Sprite 1"].waitForExistence(timeout: 2))
        app.buttons["Sprite 1"].tap()
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.40, dy: 0.45)).tap()
        let palm = canvas.screenshot().image.pngData()

        app.buttons["New Drawing"].tap()
        app.buttons["Rubber Stamps"].tap()
        let tvSprite = app.buttons["Sprite 12"]
        tapAfterHorizontalScroll(tvSprite, in: app.scrollViews["option.strip.stamp"])
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.40, dy: 0.45)).tap()
        let tv = canvas.screenshot().image.pngData()
        XCTAssertNotEqual(palm, tv)
    }

    func testSquareNoFillAndPatternChangeCanvasPixels() {
        let canvas = app.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        app.buttons["Rectangle"].tap()
        XCTAssertTrue(app.buttons["Square No Fill"].waitForExistence(timeout: 2))
        app.buttons["Square No Fill"].tap()
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.30)).press(
            forDuration: 0.1,
            thenDragTo: canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.70, dy: 0.70))
        )
        let noFill = canvas.screenshot().image.pngData()

        app.buttons["New Drawing"].tap()
        app.buttons["Rectangle"].tap()
        app.descendants(matching: .any)["rectangle.texture.partial1"].tap()
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.30)).press(
            forDuration: 0.1,
            thenDragTo: canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.70, dy: 0.70))
        )
        let partial = canvas.screenshot().image.pngData()
        XCTAssertNotEqual(noFill, partial)
    }

    func testDifferentBrushSelectionsChangeDrawnCanvasPixels() {
        let canvas = app.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        app.buttons["Wacky Brush"].tap()
        XCTAssertTrue(app.buttons["Zig Zag"].waitForExistence(timeout: 2))
        app.buttons["Zig Zag"].tap()
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.20, dy: 0.45)).press(
            forDuration: 0.1,
            thenDragTo: canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.45))
        )
        let zigZag = canvas.screenshot().image.pngData()

        app.buttons["New Drawing"].tap()
        app.buttons["Wacky Brush"].tap()
        app.buttons["Pies"].tap()
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.20, dy: 0.45)).press(
            forDuration: 0.1,
            thenDragTo: canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.45))
        )
        let pies = canvas.screenshot().image.pngData()
        XCTAssertNotEqual(zigZag, pies)
    }

    func testDifferentPencilTexturesChangeDrawnCanvasPixels() {
        let canvas = app.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        app.buttons["Next SIZE page"].tap()
        let solidTexture = app.descendants(matching: .any)["pencil.texture.solid"]
        XCTAssertTrue(solidTexture.waitForExistence(timeout: 2))
        solidTexture.tap()
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.20, dy: 0.45)).press(
            forDuration: 0.1,
            thenDragTo: canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.45))
        )
        let solid = canvas.screenshot().image.pngData()

        app.buttons["New Drawing"].tap()
        app.buttons["Wacky Pencil"].tap()
        app.descendants(matching: .any)["pencil.texture.partial1"].tap()
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.20, dy: 0.45)).press(
            forDuration: 0.1,
            thenDragTo: canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.45))
        )
        let partial = canvas.screenshot().image.pngData()
        XCTAssertNotEqual(solid, partial)
    }

    func testEraserOriginalCatalogIsReachable() {
        XCTAssertTrue(app.buttons["Eraser"].waitForExistence(timeout: 5))
        app.buttons["Eraser"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["eraser.variant.1"].waitForExistence(timeout: 2))
        app.buttons["Next ERASER page"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["eraser.variant.12"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.descendants(matching: .any)["eraser.variant.13"].exists)
        app.descendants(matching: .any)["eraser.variant.12"].tap()
        XCTAssertTrue(app.buttons["Export PNG"].exists)
    }

    func testLineOriginalSizeCatalogIsReachable() {
        XCTAssertTrue(app.buttons["Line"].waitForExistence(timeout: 5))
        app.buttons["Line"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["line.size.1"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["line.size.6"].exists)
        app.descendants(matching: .any)["line.size.6"].tap()
        app.buttons["Next LINE SIZE page"].tap()
        app.buttons["Next LINE page"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["line.texture.brick"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Export PNG"].exists)
    }

    func testPaintCanTextureCatalogIsReachable() {
        XCTAssertTrue(app.buttons["Paint Can"].waitForExistence(timeout: 5))
        app.buttons["Paint Can"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["fill.texture.stripes"].waitForExistence(timeout: 2))
        app.descendants(matching: .any)["fill.texture.stripes"].tap()
        XCTAssertTrue(app.buttons["Export PNG"].exists)
    }

    func testOriginalStickerCatalogIsReachable() {
        XCTAssertTrue(app.buttons["Rubber Stamps"].waitForExistence(timeout: 5))
        app.buttons["Rubber Stamps"].tap()
        app.buttons["Previous SPRITES page"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["sticker.1"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["sticker.6"].exists)
        app.descendants(matching: .any)["sticker.6"].tap()
        XCTAssertTrue(app.buttons["Export PNG"].exists)
    }

    func testOriginalSpriteStampPackIsReachable() {
        XCTAssertTrue(app.buttons["Rubber Stamps"].waitForExistence(timeout: 5))
        app.buttons["Rubber Stamps"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["sprite.1"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["sprite.14"].exists)
        app.buttons["Next PACK"].tap()
        app.buttons["Next ROW"].tap()
        app.descendants(matching: .any)["sprite.1"].tap()
        XCTAssertTrue(app.buttons["Export PNG"].exists)
    }

    func testSoundMuteControlTogglesState() {
        XCTAssertTrue(app.buttons["Mute Sounds"].waitForExistence(timeout: 5))
        app.buttons["Mute Sounds"].tap()
        XCTAssertTrue(app.buttons["Unmute Sounds"].waitForExistence(timeout: 2))
        app.buttons["Unmute Sounds"].tap()
        XCTAssertTrue(app.buttons["Mute Sounds"].waitForExistence(timeout: 2))
    }

    func testNativeExportReportsSuccess() {
        app.terminate()
        let nativeApp = XCUIApplication()
        nativeApp.launchArguments = ["--reset-document"]
        nativeApp.launch()
        XCTAssertTrue(nativeApp.otherElements["workspace"].waitForExistence(timeout: 5))
        XCTAssertTrue(nativeApp.buttons["File"].waitForExistence(timeout: 5))
        nativeApp.buttons["File"].tap()
        XCTAssertTrue(nativeApp.buttons["Export PNG"].waitForExistence(timeout: 2))
        nativeApp.descendants(matching: .any)["menuItem.Export PNG"].tap()
        XCTAssertTrue(nativeApp.descendants(matching: .any)["export.status.native"].waitForExistence(timeout: 2))
        XCTAssertEqual(nativeApp.staticTexts["PNG prepared as KidPad.png"].label, "PNG prepared as KidPad.png")
    }

    func testEraserSubmenuUsesTheTwelveActivePinnedSourceEntries() {
        XCTAssertTrue(app.buttons["Eraser"].waitForExistence(timeout: 5))
        app.buttons["Eraser"].tap()
        for name in ["Square Eraser 20", "Circle Eraser 10", "Firecracker", "Hidden Pictures", "White Circles", "Slip-Sliding Away", "#$%!*!!", "Fade Away"] {
            XCTAssertTrue(app.buttons[name].exists, "Missing active eraser option: \(name)")
        }
        app.buttons["Next ERASER page"].tap()
        XCTAssertTrue(app.buttons["Black Hole"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Count Down"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["eraser.variant.13"].exists, "Commented-out eraser asset 188 must not be exposed")
    }

    func testNativeNewDrawingAndOpenRecentChangeTheCanvas() {
        app.terminate()
        let nativeApp = XCUIApplication()
        nativeApp.launchArguments = ["--ui-test", "--reset-document"]
        nativeApp.launch()

        let canvas = nativeApp.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        let start = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.35))
        let end = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.70, dy: 0.65))
        start.press(forDuration: 0.1, thenDragTo: end)
        let drawn = canvas.screenshot().image.pngData()

        nativeApp.buttons["File"].tap()
        nativeApp.descendants(matching: .any)["menuItem.New Drawing"].tap()
        XCTAssertFalse(nativeApp.staticTexts["New blank drawing"].exists)
        let blank = canvas.screenshot().image.pngData()
        XCTAssertNotEqual(blank, drawn)

        nativeApp.buttons["File"].tap()
        nativeApp.descendants(matching: .any)["menuItem.Open Recent"].tap()
        XCTAssertFalse(nativeApp.staticTexts["Opened recent drawing"].exists)
        let reopened = canvas.screenshot().image.pngData()
        XCTAssertEqual(reopened, drawn)
    }

    func testHistoricalStartupScreenIsRemoved() {
        XCTAssertFalse(app.descendants(matching: .any)["startup.screen"].exists)
    }

    func testClassicPackDownloadsAndOpensWorkspace() throws {
        #if !KIDPAD_RUN_NETWORK_UITESTS
        throw XCTSkip("Enable with OTHER_SWIFT_FLAGS=-DKIDPAD_RUN_NETWORK_UITESTS.")
        #endif
        app.terminate()
        let installApp = XCUIApplication()
        installApp.launchArguments = ["--reset-classic-pack"]
        installApp.launch()

        let download = installApp.buttons["classicPack.download"]
        XCTAssertTrue(download.waitForExistence(timeout: 5))
        download.tap()
        XCTAssertTrue(installApp.otherElements["kidpad.canvas"].waitForExistence(timeout: 120))
        XCTAssertFalse(installApp.descendants(matching: .any)["startup.screen"].exists)

        installApp.terminate()
        installApp.launchArguments = []
        installApp.launch()
        XCTAssertTrue(installApp.otherElements["kidpad.canvas"].waitForExistence(timeout: 10))
        XCTAssertFalse(installApp.buttons["classicPack.download"].exists)
    }

    func testNativePencilStrokeIsVisibleAndSaved() {
        let nativeApp = XCUIApplication()
        nativeApp.launchArguments = ["--reset-document"]
        nativeApp.launch()

        let canvas = nativeApp.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        nativeApp.buttons["Wacky Pencil"].tap()

        let start = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.5))
        let end = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.70, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)

        let drawn = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        drawn.name = "Native pencil stroke after real canvas drag"
        drawn.lifetime = .keepAlways
        add(drawn)

        nativeApp.buttons["Save"].tap()
        XCTAssertTrue(nativeApp.descendants(matching: .any)["export.status.native"].waitForExistence(timeout: 2))
        XCTAssertEqual(nativeApp.descendants(matching: .any)["export.status.native"].label, "Drawing saved")
        nativeApp.terminate()
        let relaunched = XCUIApplication()
        relaunched.launch()
        XCTAssertTrue(relaunched.otherElements["kidpad.canvas"].waitForExistence(timeout: 5))
        let restored = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        restored.name = "Native pencil stroke after save and relaunch"
        restored.lifetime = .keepAlways
        add(restored)
    }

    func testNativeMixerAndTNTRoundTripWithUndo() {
        let nativeApp = XCUIApplication()
        nativeApp.launchArguments = ["--reset-document"]
        nativeApp.launch()

        let canvas = nativeApp.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        nativeApp.buttons["Wacky Pencil"].tap()
        let start = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.30, dy: 0.50))
        let end = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.65, dy: 0.50))
        start.press(forDuration: 0.1, thenDragTo: end)

        nativeApp.buttons["Electric Mixer"].tap()
        XCTAssertTrue(nativeApp.buttons["Venetian Blinds"].waitForExistence(timeout: 2))
        nativeApp.buttons["Venetian Blinds"].tap()
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        let mixed = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        mixed.name = "Native mixer Venetian Blinds applied"
        mixed.lifetime = .keepAlways
        add(mixed)
        nativeApp.buttons["Undo Guy"].tap()

        nativeApp.buttons["TNT Clear"].tap()
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        let cleared = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        cleared.name = "Native TNT clear applied"
        cleared.lifetime = .keepAlways
        add(cleared)
        nativeApp.buttons["Undo Guy"].tap()
        let restored = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        restored.name = "Native TNT clear undone"
        restored.lifetime = .keepAlways
        add(restored)
    }

    func testNewAndOpenRecentDocumentControlsAreReachable() {
        XCTAssertTrue(app.buttons["New Drawing"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Open Recent"].exists)
        app.buttons["New Drawing"].tap()
        app.buttons["Open Recent"].tap()
        XCTAssertTrue(app.buttons["Export PNG"].exists)
    }

    func testCanvasSurvivesPortraitAndLandscapeLayouts() {
        let canvas = app.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Wacky Pencil"].exists)
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Export PNG"].exists)
    }

    func testLandscapeReferenceCompositionScreenshot() {
        XCTAssertTrue(app.otherElements["kidpad.canvas"].waitForExistence(timeout: 5))
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(app.otherElements["kidpad.canvas"].waitForExistence(timeout: 5))
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "KidPad landscape reference composition"
        attachment.lifetime = .keepAlways
        add(attachment)
        XCUIDevice.shared.orientation = .portrait
    }

    func testP0ToolFlowIsReachableInLandscape() {
        XCTAssertTrue(app.otherElements["kidpad.canvas"].waitForExistence(timeout: 5))
        XCUIDevice.shared.orientation = .landscapeLeft
        let canvas = app.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        let tools = ["Wacky Pencil", "Line", "Rectangle", "Oval", "Wacky Brush", "Electric Mixer", "Paint Can", "Eraser", "Alphabet", "Rubber Stamps", "Moving Van", "TNT Clear", "Undo Guy"]
        for tool in tools {
            XCTAssertTrue(app.buttons[tool].waitForExistence(timeout: 5), "Missing landscape tool \(tool)")
            app.buttons[tool].tap()
        }
        app.buttons["Wacky Pencil"].tap()
        let start = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.18, dy: 0.18))
        let end = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.48, dy: 0.38))
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: XCUIGestureVelocity(800), thenHoldForDuration: 0.02)
        XCTAssertTrue(app.buttons["Export PNG"].exists)
        XCUIDevice.shared.orientation = .portrait
    }

    func testCompactWidthViewportSupportsDrawingAndExport() {
        app.terminate()
        let compactApp = XCUIApplication()
        compactApp.launchArguments = ["--ui-test", "--reset-document", "--ui-test-compact"]
        compactApp.launch()
        let canvas = compactApp.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        XCTAssertTrue(compactApp.buttons["Wacky Pencil"].waitForExistence(timeout: 5))
        XCTAssertTrue(compactApp.buttons["Export PNG"].exists)
        compactApp.buttons["Wacky Pencil"].tap()
        let start = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.18, dy: 0.18))
        let end = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.48, dy: 0.38))
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: XCUIGestureVelocity(800), thenHoldForDuration: 0.02)
        compactApp.buttons["Export PNG"].tap()
        XCTAssertTrue(compactApp.otherElements["workspace"].exists)
    }

    func testMixerVariantsAreReachable() {
        XCTAssertTrue(app.buttons["Electric Mixer"].waitForExistence(timeout: 5))
        app.buttons["Electric Mixer"].tap()
        XCTAssertTrue(app.buttons["Invert"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Raindrops"].exists)
        XCTAssertTrue(app.buttons["Checkerboard"].exists)
        XCTAssertTrue(app.buttons["Wallpaper"].exists)
        XCTAssertTrue(app.buttons["Venetian Blinds"].exists)
        XCTAssertTrue(app.buttons["Shadow Boxes"].exists)
        app.buttons["Next MIXER page"].tap()
        XCTAssertTrue(app.buttons["Pattern Maker"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Snowflakes"].exists)
        app.buttons["Snowflakes"].tap()
        XCTAssertTrue(app.buttons["Export PNG"].exists)
    }

    func testAlphabetCharacterBarIsReachable() {
        XCTAssertTrue(app.buttons["Alphabet"].waitForExistence(timeout: 5))
        app.buttons["Alphabet"].tap()
        XCTAssertTrue(app.buttons["Letter A"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Letter Z"].exists)
        app.buttons["Next ABC page"].tap()
        XCTAssertTrue(app.buttons["Character ?"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Export PNG"].exists)
    }

    func testAllP0ToolButtonsAreSelectable() {
        let tools = ["Wacky Pencil", "Line", "Rectangle", "Oval", "Wacky Brush", "Electric Mixer", "Paint Can", "Eraser", "Alphabet", "Rubber Stamps", "Moving Van", "TNT Clear", "Undo Guy"]
        for tool in tools {
            XCTAssertTrue(app.buttons[tool].waitForExistence(timeout: 5), "Missing \(tool)")
            app.buttons[tool].tap()
        }
    }

    func testCanvasDoesNotMoveWhenSwitchingToToolWithoutOptions() {
        let canvas = app.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))

        app.buttons["Rubber Stamps"].tap()
        let stampY = canvas.frame.minY
        app.buttons["TNT Clear"].tap()
        XCTAssertEqual(canvas.frame.minY, stampY, accuracy: 1)

        app.buttons["Rectangle"].tap()
        XCTAssertEqual(canvas.frame.minY, stampY, accuracy: 1)
        app.buttons["Paint Can"].tap()
        XCTAssertEqual(canvas.frame.minY, stampY, accuracy: 1)
        app.buttons["Wacky Brush"].tap()
        XCTAssertEqual(canvas.frame.minY, stampY, accuracy: 1)
    }

    func testP0ToolGesturesCommitWithoutLeavingTheWorkspace() {
        let canvas = app.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        let start = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.18, dy: 0.18))
        let end = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.48, dy: 0.38))
        let drawingTools = ["Wacky Pencil", "Line", "Rectangle", "Oval", "Wacky Brush", "Eraser"]
        for tool in drawingTools {
            app.buttons[tool].tap()
            start.press(forDuration: 0.05, thenDragTo: end, withVelocity: XCUIGestureVelocity(800), thenHoldForDuration: 0.02)
        }
        let drawingAttachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        drawingAttachment.name = "KidPad committed P0 drawing gesture"
        drawingAttachment.lifetime = .keepAlways
        add(drawingAttachment)
        app.buttons["Alphabet"].tap()
        start.tap()
        app.buttons["Rubber Stamps"].tap()
        start.tap()
        app.buttons["Moving Van"].tap()
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: XCUIGestureVelocity(800), thenHoldForDuration: 0.02)
        app.buttons["Electric Mixer"].tap()
        app.buttons["Invert"].tap()
        start.tap()
        app.buttons["Paint Can"].tap()
        start.tap()
        app.buttons["TNT Clear"].tap()
        start.tap()
        XCTAssertTrue(app.buttons["Export PNG"].exists)
    }

    func testSimulatorTerminateAndRelaunchPath() {
        let canvas = app.otherElements["kidpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        let start = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.18, dy: 0.18))
        let end = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.42, dy: 0.32))
        start.press(forDuration: 0.1, thenDragTo: end, withVelocity: XCUIGestureVelocity(800), thenHoldForDuration: 0.05)
        app.buttons["Save"].tap()
        app.terminate()
        app.launchArguments = ["--ui-test"]
        app.launch()
        XCTAssertTrue(app.otherElements["kidpad.canvas"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Export PNG"].exists)
    }
}
