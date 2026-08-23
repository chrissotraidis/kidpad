import XCTest
import UIKit
import CryptoKit
@testable import KidPad

private final class MockClassicAssetURLProtocol: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

final class CanvasCoreTests: XCTestCase {
    private var persistenceRoot: URL!
    private var classicRoot: URL!
    private var classicAssetsAvailable = false

    override func setUpWithError() throws {
        try super.setUpWithError()
        persistenceRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("KidPadTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: persistenceRoot, withIntermediateDirectories: true)
        RasterDocument.persistenceRootOverride = persistenceRoot
        let repositoryRoot = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        classicRoot = repositoryRoot.appending(path: "Resources/FidelityDev", directoryHint: .isDirectory)
        classicAssetsAvailable = FileManager.default.fileExists(
            atPath: classicRoot.appending(path: "kidpix-spritesheet-0.png").path
        )
        KidPadResource.classicRootOverrideForTesting = classicAssetsAvailable ? classicRoot : nil
    }

    override func tearDownWithError() throws {
        RasterDocument.persistenceRootOverride = nil
        KidPadResource.classicRootOverrideForTesting = nil
        KidPadResource.installationRootOverrideForTesting = nil
        MockClassicAssetURLProtocol.handler = nil
        if let persistenceRoot { try? FileManager.default.removeItem(at: persistenceRoot) }
        try super.tearDownWithError()
    }

    private func requireClassicAssets() throws {
        try XCTSkipUnless(classicAssetsAvailable, "Classic raster verification requires the locally downloaded JSKidPix pack.")
    }

    private func canonicalPixelHash(_ image: UIImage) throws -> String {
        let size = image.size
        let width = Int(size.width)
        let height = Int(size.height)
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let context = try XCTUnwrap(CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.interpolationQuality = .none
        context.draw(try XCTUnwrap(image.cgImage), in: CGRect(x: 0, y: 0, width: width, height: height))
        return SHA256.hash(data: Data(pixels)).map { String(format: "%02x", $0) }.joined()
    }

    private func rgbaPixels(_ image: UIImage) throws -> [UInt8] {
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let context = try XCTUnwrap(CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.interpolationQuality = .none
        context.draw(try XCTUnwrap(image.cgImage), in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixels
    }

    func testRepresentativeP0RastersMatchGoldenPixelHashes() throws {
        try requireClassicAssets()
        var outputs: [String: UIImage] = [:]

        let pencil = RasterDocument(size: CGSize(width: 180, height: 120))
        pencil.beginTransaction()
        pencil.apply(tool: .pencil, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 150, y: 90), color: .red, width: 10, pressure: 0.7)
        outputs["pencil"] = pencil.image

        let line = RasterDocument(size: CGSize(width: 180, height: 120))
        line.beginTransaction()
        line.apply(tool: .line, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 150, y: 90), color: .blue, width: 8)
        outputs["line"] = line.image

        let rectangle = RasterDocument(size: CGSize(width: 180, height: 120))
        rectangle.beginTransaction()
        rectangle.apply(tool: .rectangle, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 150, y: 90), color: .green, width: 8)
        outputs["rectangle"] = rectangle.image

        let oval = RasterDocument(size: CGSize(width: 180, height: 120))
        oval.beginTransaction()
        oval.apply(tool: .oval, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 150, y: 90), color: .purple, width: 8)
        outputs["oval"] = oval.image

        let fill = RasterDocument(size: CGSize(width: 180, height: 120))
        fill.beginTransaction()
        fill.apply(tool: .rectangle, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 150, y: 90), color: .black, width: 6)
        fill.beginTransaction()
        fill.apply(tool: .fill, from: CGPoint(x: 40, y: 40), to: CGPoint(x: 40, y: 40), color: .red, width: 1)
        outputs["fill"] = fill.image

        let eraser = RasterDocument(size: CGSize(width: 180, height: 120))
        eraser.beginTransaction()
        eraser.apply(tool: .pencil, from: CGPoint(x: 20, y: 60), to: CGPoint(x: 150, y: 60), color: .black, width: 12)
        eraser.beginTransaction()
        eraser.apply(tool: .eraser, from: CGPoint(x: 50, y: 60), to: CGPoint(x: 120, y: 60), color: .black, width: 12)
        outputs["eraser"] = eraser.image

        let brush = RasterDocument(size: CGSize(width: 180, height: 120))
        brush.setBrushVariant(5)
        brush.beginTransaction()
        brush.apply(tool: .brush, from: CGPoint(x: 20, y: 60), to: CGPoint(x: 20, y: 60), color: .orange, width: 12, pressure: 1)
        brush.apply(tool: .brush, from: CGPoint(x: 20, y: 60), to: CGPoint(x: 150, y: 60), color: .orange, width: 12, pressure: 1)
        outputs["brush-echoes"] = brush.image

        let mixer = RasterDocument(size: CGSize(width: 180, height: 120))
        mixer.beginTransaction()
        mixer.apply(tool: .pencil, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 150, y: 90), color: .orange, width: 12)
        mixer.setMixerVariant(4)
        mixer.beginTransaction()
        mixer.apply(tool: .mixer, from: .zero, to: .zero, color: .black, width: 1)
        outputs["mixer-venetian"] = mixer.image

        let stamp = RasterDocument(size: CGSize(width: 180, height: 120))
        stamp.setStampIndex(4)
        stamp.beginTransaction()
        stamp.apply(tool: .stamp, from: CGPoint(x: 90, y: 60), to: CGPoint(x: 90, y: 60), color: .black, width: 1)
        outputs["stamp-fox"] = stamp.image

        let truck = RasterDocument(size: CGSize(width: 180, height: 120))
        truck.beginTransaction()
        truck.apply(tool: .pencil, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 80, y: 70), color: .red, width: 12)
        truck.beginTransaction()
        truck.apply(tool: .truck, from: CGPoint(x: 50, y: 50), to: CGPoint(x: 140, y: 85), color: .black, width: 1)
        outputs["truck-move"] = truck.image

        let hashes = try outputs.keys.sorted().reduce(into: [String: String]()) { result, key in
            result[key] = try canonicalPixelHash(try XCTUnwrap(outputs[key]))
        }
        if ProcessInfo.processInfo.environment["KIDPAD_GENERATE_GOLDENS"] == "1" {
            print("KIDPAD_GOLDENS=" + hashes.map { "\($0.key)=\($0.value)" }.joined(separator: ","))
            return
        }
        let expected = [
            "brush-echoes": "bdf7468d911349e836bbf982db7697fe6fc627aa6162f4fd04f6679828a24cc9",
            "eraser": "d165cca65c5ca88e015bce60cc6786a418953af9005838bfd4b269fb78cef891",
            "fill": "a74515959494bd89f102d5c99c11cb520d6c3883bbbeb1359f5bfb520d4adfea",
            "line": "b2777845f37105193d827ec0fd0fe4fe267b9bfd1422b2bbf5d0538fa7d36747",
            "mixer-venetian": "1de41c835b1c06d3ab63a18c8e88abe22d5b539f9a3508f14357eedd281d43d9",
            "oval": "191bc20de50c7950765148e202ac022efb53897d986a1bf671ae91931dbade07",
            "pencil": "dfa37314b6c38c70c6c527bfff18e076c734b691fb646384e87db004a5dd7865",
            "rectangle": "f88b29c2be2361ee63b4c4f9c2f0dd957f9125f3af32c03af029d97b05e93296",
            "stamp-fox": "645952bec15a9ca85efeae21e9d16cbff2b2c53f9491f7b18ff2f2f7c08f7126",
            "truck-move": "7cf3bef3e11e7ece8294e770f65179399979e550215b1879c33fb8c4762f60a8"
        ]
        XCTAssertEqual(hashes, expected, "Golden pixel hashes changed; review the raster diff before updating the fixture.")
    }

    @MainActor
    func testSoundPolicyDefaultsOnAndCanMuteGlobally() {
        SoundPlayer.setEnabled(true)
        XCTAssertTrue(SoundPlayer.isEnabled)
        SoundPlayer.toggle()
        XCTAssertFalse(SoundPlayer.isEnabled)
        SoundPlayer.setEnabled(true)
    }

    @MainActor
    func testUnimplementedControlUsesPinnedSourceChord() {
        XCTAssertEqual(SoundPlayer.unimplementedResource, "chord.wav")
    }

    @MainActor
    func testSoundPlaybackUsesBoundedChannelsDuringRapidActions() {
        SoundPlayer.setEnabled(true)
        for resource in [
            "kidpix-menu-click-main-tools.wav",
            "flood0.wav",
            "kidpix-tool-pencil.wav",
            "kidpix-tool-line-start.wav",
            "kidpix-tool-line-during.wav",
            "kidpix-tool-line-end.wav",
            "kidpix-menu-click-submenu-color.wav",
            "kidpix-menu-click-submenu-options.wav",
            "stamp0.wav",
            "kidpix-truck-truckin.wav",
            "kidpix-truck-truckin-go.wav",
            "kidpix-truck-skid.wav",
            "electric-mixer-pip-drum-crash-1WAVSOUND.R_0002d96e.wav",
            "western-gun-shot-twirl-WAVSOUND.R_0005ed70.wav",
            "eraser-tool-fade-2WAVSOUND.R_0002f58b.wav",
            "kidpix-tool-eraser-tnt-explosion.wav"
        ] {
            SoundPlayer.play(resource)
        }
        XCTAssertLessThanOrEqual(SoundPlayer.activePlayerCountForTesting, 8)
        SoundPlayer.setEnabled(false)
        XCTAssertEqual(SoundPlayer.activePlayerCountForTesting, 0)
        SoundPlayer.setEnabled(true)
    }

    @MainActor
    func testAlphabetSoundMappingCoversAll42SourceCharacters() {
        let letters = "abcdefghijklmnopqrstuvwxyz".map(String.init)
        let digits = "0123456789".map(String.init)
        let symbols = ["&", "!", "=", "-", "+", "?"]
        for character in letters + digits + symbols {
            let sound = SoundPlayer.alphabetSound(for: character)
            XCTAssertNotNil(sound, "Missing alphabet sound for character \(character)")
        }
        XCTAssertEqual(letters.count, 26)
        XCTAssertEqual(digits.count, 10)
        XCTAssertEqual(symbols.count, 6)
        // Spot-check exact source filenames.
        XCTAssertEqual(SoundPlayer.alphabetSound(for: "a"), "alpha-a-WAVSOUND.R_0007d8f2.wav")
        XCTAssertEqual(SoundPlayer.alphabetSound(for: "z"), "alpha-z-WAVSOUND.R_000a2fe7.wav")
        XCTAssertEqual(SoundPlayer.alphabetSound(for: "8"), "number-8-WAVSOUND.002_000555ac.wav")
        XCTAssertEqual(SoundPlayer.alphabetSound(for: "?"), "number-question-mark-WAVSOUND.R_000a661d.wav")
        XCTAssertNil(SoundPlayer.alphabetSound(for: "~"))
    }

    func testBlankDocumentIsWhiteAndUndoRestoresImage() {
        let document = RasterDocument(size: CGSize(width: 100, height: 60))
        let original = document.image.pngData()
        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 5, y: 5), to: CGPoint(x: 90, y: 50), color: .black, width: 8)
        XCTAssertNotEqual(document.image.pngData(), original)
        document.undo()
        XCTAssertEqual(document.image.pngData(), original)
    }

    func testPencilTapCreatesVisibleMark() {
        let document = RasterDocument(size: CGSize(width: 100, height: 60))
        let blank = document.pngData()
        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 50, y: 30), to: CGPoint(x: 50, y: 30), color: .black, width: 10)
        XCTAssertNotEqual(document.pngData(), blank)
    }

    func testPencilTapUsesTheSelectedColor() {
        let red = RasterDocument(size: CGSize(width: 100, height: 60))
        red.apply(tool: .pencil, from: CGPoint(x: 50, y: 30), to: CGPoint(x: 50, y: 30), color: .red, width: 10)
        let blue = RasterDocument(size: CGSize(width: 100, height: 60))
        blue.apply(tool: .pencil, from: CGPoint(x: 50, y: 30), to: CGPoint(x: 50, y: 30), color: .blue, width: 10)
        XCTAssertNotEqual(red.pngData(), blue.pngData())
    }

    func testFloodFillAcceptsGrayscaleUIKitColors() {
        let document = RasterDocument(size: CGSize(width: 100, height: 60))
        let blank = document.pngData()
        document.apply(tool: .fill, from: .zero, to: CGPoint(x: 50, y: 30), color: .black, width: 1)
        XCTAssertNotEqual(document.pngData(), blank)
    }

    func testUndoAndRedoRestoreCommittedRaster() {
        let document = RasterDocument(size: CGSize(width: 120, height: 80))
        let blank = document.pngData()!
        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 10, y: 10), to: CGPoint(x: 90, y: 60), color: .red, width: 8)
        document.commit()
        let drawn = document.pngData()!
        XCTAssertNotEqual(drawn, blank)
        document.undo()
        XCTAssertEqual(document.pngData(), blank)
        document.redo()
        XCTAssertEqual(document.pngData(), drawn)
    }

    func testUndoGuyTogglesTheLastDecision() throws {
        let document = RasterDocument(size: CGSize(width: 120, height: 80))
        let blank = try XCTUnwrap(document.pngData())
        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 10, y: 10), to: CGPoint(x: 100, y: 60), color: .red, width: 8)
        document.commit()
        let drawn = try XCTUnwrap(document.pngData())

        document.toggleUndo()
        XCTAssertEqual(document.pngData(), blank)
        document.toggleUndo()
        XCTAssertEqual(document.pngData(), drawn)
    }

    func testEditUndoAndRedoWalkMultipleCommittedActions() throws {
        let document = RasterDocument(size: CGSize(width: 120, height: 80))
        let blank = try XCTUnwrap(document.pngData())
        document.beginTransaction()
        document.apply(tool: .stamp, from: CGPoint(x: 35, y: 35), to: CGPoint(x: 35, y: 35), color: .black, width: 8)
        document.commit()
        let first = try XCTUnwrap(document.pngData())
        document.beginTransaction()
        document.apply(tool: .alphabet, from: CGPoint(x: 75, y: 35), to: CGPoint(x: 75, y: 35), color: .blue, width: 8)
        document.commit()
        let second = try XCTUnwrap(document.pngData())

        XCTAssertTrue(document.undo())
        XCTAssertEqual(document.pngData(), first)
        XCTAssertTrue(document.undo())
        XCTAssertEqual(document.pngData(), blank)
        XCTAssertTrue(document.redo())
        XCTAssertEqual(document.pngData(), first)
        XCTAssertTrue(document.redo())
        XCTAssertEqual(document.pngData(), second)
    }

    @MainActor
    func testUndoGuyHasAllFourPinnedOopsSounds() {
        let resources = SoundPlayer.oopsResources
        XCTAssertEqual(resources, ["oops0.wav", "oops1.wav", "oops2.wav", "oops3.wav"])
        let catalog = Set(ClassicAssetCatalog.assets.map(\.localName))
        for resource in resources {
            XCTAssertTrue(catalog.contains(resource), "Missing Undo Guy sound from the pinned catalog: \(resource)")
        }
    }

    @MainActor
    func testEveryMappedBrushSoundIsBundled() {
        XCTAssertEqual(SoundPlayer.brushMovementSounds.count, RasterDocument.wackyBrushes.count)
        let catalog = Set(ClassicAssetCatalog.assets.map(\.localName))
        for resource in Set(SoundPlayer.brushMovementSounds.compactMap { $0 }) {
            XCTAssertTrue(catalog.contains(resource), "Missing brush sound from the pinned catalog: \(resource)")
        }
    }

    func testDefaultDocumentUsesReferenceCompatibleLogicalCanvasProfile() {
        let document = RasterDocument()
        XCTAssertEqual(document.size, CGSize(width: 1920, height: 1200))
    }

    func testReferencePaletteVariantsUsePinnedSourceValues() {
        XCTAssertEqual(WorkspaceView.sourceBrightRGB, [[255, 0, 0], [255, 255, 0], [0, 255, 0], [0, 0, 255], [0, 255, 255], [255, 0, 255]])
        XCTAssertEqual(WorkspaceView.sourcePalettePageCount, 8)
        XCTAssertEqual(WorkspaceView.sourceAdditionalPaletteStrings.count, 6)
        XCTAssertEqual(WorkspaceView.sourceAdditionalPaletteStrings[0].count, 32)
        XCTAssertEqual(WorkspaceView.sourceAdditionalPaletteStrings[5].last, "#FF22FF")
        XCTAssertEqual(WorkspaceView.sourceGreyscaleValues.count, 32)
        XCTAssertEqual(WorkspaceView.sourceGreyscaleValues.last, 255)
        XCTAssertEqual(WorkspaceView.sourceGreyscaleValues[30], 242)
    }

    func testP0RasterToolsProduceDistinctCommittedOutput() {
        let tools: [CanvasTool] = [.line, .rectangle, .oval, .brush, .alphabet, .stamp, .mixer]
        for tool in tools {
            let document = RasterDocument(size: CGSize(width: 160, height: 100))
            let original = document.image.pngData()
            document.beginTransaction()
            document.apply(tool: tool, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 120, y: 70), color: .red, width: 10)
            XCTAssertNotEqual(document.image.pngData(), original, "Tool \(tool.rawValue) did not change the raster")
        }
    }

    func testSourcePencilTextureCatalogProducesDistinctRasterOutput() {
        let baseline = RasterDocument(size: CGSize(width: 160, height: 100))
        baseline.beginTransaction()
        baseline.apply(tool: .pencil, from: CGPoint(x: 20, y: 50), to: CGPoint(x: 140, y: 50), color: .red, width: 10)
        let solid = baseline.pngData()

        for texture in PencilTexture.allCases where texture != .solid {
            let document = RasterDocument(size: CGSize(width: 160, height: 100))
            document.setPencilTexture(texture)
            document.beginTransaction()
            document.apply(tool: .pencil, from: CGPoint(x: 20, y: 50), to: CGPoint(x: 140, y: 50), color: .red, width: 10)
            XCTAssertNotEqual(document.pngData(), solid, "Source pencil texture \(texture.displayName) did not change the raster")
        }
    }

    func testSourceTexturePreviewUsesAFramedShapeInsteadOfAnEnlargedTile() throws {
        let document = RasterDocument(size: CGSize(width: 80, height: 60))
        let solidSquare = document.pencilTexturePreview(.solid, shape: .rectangle)
        let emptySquare = document.pencilTexturePreview(nil, shape: .rectangle)
        let solidCircle = document.pencilTexturePreview(.solid, shape: .oval)
        XCTAssertEqual(solidSquare.size, CGSize(width: 50, height: 50))

        func pixel(_ image: UIImage, x: Int, y: Int) throws -> [UInt8] {
            let pixels = try rgbaPixels(image)
            let index = (y * Int(image.size.width) + x) * 4
            return Array(pixels[index..<index + 4])
        }

        XCTAssertEqual(try pixel(solidSquare, x: 5, y: 5), [255, 255, 255, 255])
        XCTAssertEqual(try pixel(solidSquare, x: 25, y: 25), [0, 0, 0, 255])
        XCTAssertEqual(try pixel(emptySquare, x: 25, y: 25), [255, 255, 255, 255])
        XCTAssertEqual(try pixel(solidCircle, x: 11, y: 11), [255, 255, 255, 255])
        XCTAssertEqual(try pixel(solidCircle, x: 25, y: 25), [0, 0, 0, 255])
    }

    func testPartialTextureDensityMatchesPinnedSourceTiles() throws {
        func inkCount(_ texture: PencilTexture) throws -> Int {
            let document = RasterDocument(size: CGSize(width: 64, height: 64))
            document.setShapeFillEnabled(true)
            document.setPencilTexture(texture)
            document.beginTransaction()
            document.apply(tool: .rectangle, from: CGPoint(x: 8, y: 8), to: CGPoint(x: 56, y: 56), color: .blue, width: 1)
            let pixels = try rgbaPixels(document.image)
            var count = 0
            for y in 12..<52 {
                for x in 12..<52 {
                    let index = (y * 64 + x) * 4
                    if pixels[index] < 250 || pixels[index + 1] < 250 || pixels[index + 2] < 250 { count += 1 }
                }
            }
            return count
        }

        let partial1 = try inkCount(.partial1)
        let partial2 = try inkCount(.partial2)
        let partial3 = try inkCount(.partial3)
        XCTAssertEqual(partial1, 1_200, accuracy: 24)
        XCTAssertEqual(partial2, 800, accuracy: 24)
        XCTAssertEqual(partial3, 400, accuracy: 24)
    }

    func testSourceTexturesApplyToLineAndShapeTools() {
        let solid = RasterDocument(size: CGSize(width: 160, height: 100))
        solid.beginTransaction()
        solid.apply(tool: .line, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 140, y: 80), color: .blue, width: 10)
        let solidLine = solid.pngData()

        let texturedLine = RasterDocument(size: CGSize(width: 160, height: 100))
        texturedLine.setPencilTexture(.brick)
        texturedLine.beginTransaction()
        texturedLine.apply(tool: .line, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 140, y: 80), color: .blue, width: 10)
        XCTAssertNotEqual(texturedLine.pngData(), solidLine)

        let texturedShape = RasterDocument(size: CGSize(width: 160, height: 100))
        texturedShape.setPencilTexture(.chevron)
        texturedShape.beginTransaction()
        texturedShape.apply(tool: .rectangle, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 140, y: 80), color: .blue, width: 10)
        XCTAssertNotEqual(texturedShape.pngData(), solidLine)
    }

    func testSquareNoFillSolidAndPatternProduceDistinctInteriors() {
        func square(fill: Bool, texture: PencilTexture) -> Data? {
            let document = RasterDocument(size: CGSize(width: 160, height: 100))
            document.setShapeFillEnabled(fill)
            document.setPencilTexture(texture)
            document.beginTransaction()
            document.apply(tool: .rectangle, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 140, y: 80), color: .blue, width: 40)
            return document.pngData()
        }

        let noFill = square(fill: false, texture: .solid)
        let solid = square(fill: true, texture: .solid)
        let partial = square(fill: true, texture: .partial1)
        XCTAssertNotEqual(noFill, solid)
        XCTAssertNotEqual(solid, partial)
        XCTAssertNotEqual(noFill, partial)
    }

    func testSourceTextureChangesFloodFillOutput() {
        let solid = RasterDocument(size: CGSize(width: 80, height: 60))
        solid.beginTransaction()
        solid.apply(tool: .fill, from: .zero, to: CGPoint(x: 20, y: 20), color: .red, width: 1)

        let textured = RasterDocument(size: CGSize(width: 80, height: 60))
        textured.setPencilTexture(.stripes)
        textured.beginTransaction()
        textured.apply(tool: .fill, from: .zero, to: CGPoint(x: 20, y: 20), color: .red, width: 1)
        XCTAssertNotEqual(textured.pngData(), solid.pngData())
    }

    func testOriginalStickerAssetsCanBeStamped() {
        let document = RasterDocument(size: CGSize(width: 180, height: 120))
        document.setStampIndex(17)
        document.beginTransaction()
        document.apply(tool: .stamp, from: CGPoint(x: 90, y: 60), to: CGPoint(x: 90, y: 60), color: .black, width: 1)
        XCTAssertNotEqual(document.pngData(), RasterDocument(size: CGSize(width: 180, height: 120)).pngData())
    }

    func testOriginalSpriteSheetCanBeStamped() {
        let document = RasterDocument(size: CGSize(width: 180, height: 120))
        document.setSpriteSelection(sheet: 9, row: 7, column: 13)
        document.beginTransaction()
        document.apply(tool: .stamp, from: CGPoint(x: 90, y: 60), to: CGPoint(x: 90, y: 60), color: .black, width: 1)
        XCTAssertNotEqual(document.pngData(), RasterDocument(size: CGSize(width: 180, height: 120)).pngData())
    }

    func testFirecrackerEraserVariantClearsTheRaster() {
        let document = RasterDocument(size: CGSize(width: 100, height: 70))
        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 10, y: 10), to: CGPoint(x: 80, y: 50), color: .black, width: 12)
        document.setEraserVariant(4)
        document.beginTransaction()
        document.apply(tool: .eraser, from: CGPoint(x: 30, y: 30), to: CGPoint(x: 30, y: 30), color: .black, width: 12)
        XCTAssertEqual(document.image.pngData(), RasterDocument(size: CGSize(width: 100, height: 70)).image.pngData())
    }

    func testActiveEraserSubmenuDispatchMatchesPinnedSourceOrder() throws {
        try requireClassicAssets()
        func inkedDocument() -> RasterDocument {
            let document = RasterDocument(size: CGSize(width: 180, height: 120))
            document.beginTransaction()
            document.apply(tool: .fill, from: .zero, to: CGPoint(x: 20, y: 20), color: .black, width: 1)
            document.commit()
            return document
        }

        let square = inkedDocument()
        square.setEraserVariant(0)
        square.beginTransaction()
        square.apply(tool: .eraser, from: CGPoint(x: 40, y: 60), to: CGPoint(x: 140, y: 60), color: .black, width: 20)

        let circle = inkedDocument()
        circle.setEraserVariant(1)
        circle.beginTransaction()
        circle.apply(tool: .eraser, from: CGPoint(x: 40, y: 60), to: CGPoint(x: 140, y: 60), color: .black, width: 10)
        XCTAssertNotEqual(square.pngData(), circle.pngData(), "Square and circle erasers must not collapse to one brush")

        let firecracker = inkedDocument()
        firecracker.setEraserVariant(4)
        firecracker.beginTransaction()
        firecracker.apply(tool: .eraser, from: CGPoint(x: 90, y: 60), to: CGPoint(x: 90, y: 60), color: .black, width: 20)
        XCTAssertEqual(firecracker.pngData(), RasterDocument(size: CGSize(width: 180, height: 120)).pngData())

        let circles = inkedDocument()
        circles.setEraserVariant(6)
        circles.beginTransaction()
        circles.apply(tool: .eraser, from: CGPoint(x: 90, y: 60), to: CGPoint(x: 90, y: 60), color: .black, width: 20)
        XCTAssertNotEqual(circles.pngData(), square.pngData(), "White Circles must use its canvas-wide circle behavior")

        let fade = inkedDocument()
        fade.setEraserVariant(9)
        fade.beginTransaction()
        fade.apply(tool: .eraser, from: CGPoint(x: 90, y: 60), to: CGPoint(x: 90, y: 60), color: .black, width: 20)
        fade.finishEraserStroke()
        XCTAssertEqual(fade.pngData(), RasterDocument(size: CGSize(width: 180, height: 120)).pngData())
    }

    func testRemainingP0ToolsChangeOrRestoreTheRaster() {
        let fill = RasterDocument(size: CGSize(width: 100, height: 70))
        let blank = fill.pngData()
        fill.beginTransaction()
        fill.apply(tool: .fill, from: .zero, to: CGPoint(x: 20, y: 20), color: .green, width: 1)
        XCTAssertNotEqual(fill.pngData(), blank)

        let eraser = RasterDocument(size: CGSize(width: 100, height: 70))
        eraser.beginTransaction()
        eraser.apply(tool: .pencil, from: CGPoint(x: 10, y: 10), to: CGPoint(x: 80, y: 10), color: .black, width: 12)
        let inked = eraser.pngData()
        eraser.beginTransaction()
        eraser.apply(tool: .eraser, from: CGPoint(x: 10, y: 10), to: CGPoint(x: 80, y: 10), color: .black, width: 12)
        XCTAssertNotEqual(eraser.pngData(), inked)

        let clear = RasterDocument(size: CGSize(width: 100, height: 70))
        clear.beginTransaction()
        clear.apply(tool: .pencil, from: CGPoint(x: 10, y: 10), to: CGPoint(x: 80, y: 50), color: .black, width: 12)
        clear.beginTransaction()
        clear.apply(tool: .clear, from: .zero, to: .zero, color: .black, width: 1)
        XCTAssertEqual(clear.pngData(), RasterDocument(size: CGSize(width: 100, height: 70)).pngData())
    }

    func testEveryP0ToolCommitsOneUndoableAction() throws {
        let tools: [CanvasTool] = [.pencil, .line, .rectangle, .oval, .brush, .mixer, .fill, .alphabet, .stamp]
        for tool in tools {
            let document = RasterDocument(size: CGSize(width: 180, height: 120))
            if tool == .eraser || tool == .truck || tool == .clear {
                document.beginTransaction()
                document.apply(tool: .pencil, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 120, y: 80), color: .red, width: 12)
            }
            let before = try XCTUnwrap(document.pngData())
            document.beginTransaction()
            document.apply(tool: tool, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 120, y: 80), color: .green, width: 10)
            document.commit()
            XCTAssertNotEqual(document.pngData(), before, "Tool \(tool.rawValue) did not create a committed action")
            document.undo()
            XCTAssertEqual(document.pngData(), before, "Tool \(tool.rawValue) did not restore its transaction")
        }

        for tool in [CanvasTool.eraser, .truck, .clear] {
            let document = RasterDocument(size: CGSize(width: 180, height: 120))
            document.beginTransaction()
            document.apply(tool: .pencil, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 120, y: 80), color: .red, width: 12)
            let before = try XCTUnwrap(document.pngData())
            document.beginTransaction()
            document.apply(tool: tool, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 120, y: 80), color: .green, width: 10)
            document.commit()
            XCTAssertNotEqual(document.pngData(), before, "Tool \(tool.rawValue) did not create a committed action")
            document.undo()
            XCTAssertEqual(document.pngData(), before, "Tool \(tool.rawValue) did not restore its transaction")
        }
    }

    func testPredictedStrokePreviewDoesNotChangeCommittedRaster() {
        let document = RasterDocument(size: CGSize(width: 120, height: 80))
        let original = document.pngData()
        let preview = document.previewStroke(from: CGPoint(x: 10, y: 10), through: [CGPoint(x: 50, y: 30), CGPoint(x: 100, y: 60)], color: .blue, width: 8, pressure: 0.8)
        XCTAssertNotEqual(preview.pngData(), original)
        XCTAssertEqual(document.pngData(), original)
    }

    func testResetToBlankCreatesAnUndoableAutosavedBlankDocument() throws {
        let document = RasterDocument(size: CGSize(width: 120, height: 80))
        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 10, y: 10), to: CGPoint(x: 100, y: 60), color: .red, width: 8)
        let inked = try XCTUnwrap(document.pngData())
        document.resetToBlank()
        XCTAssertNotEqual(document.pngData(), inked)
        document.undo()
        XCTAssertEqual(document.pngData(), inked)
    }

    func testSyntheticPencilTraceCarriesNormalizedInputMetadata() {
        let input = NormalizedInput(phase: .moved, point: CGPoint(x: 40, y: 22), pressure: 0.8, altitude: 0.6, azimuth: 1.2, kind: .pencil)
        XCTAssertEqual(input.phase, .moved)
        XCTAssertEqual(input.point, CGPoint(x: 40, y: 22))
        XCTAssertEqual(input.pressure, 0.8, accuracy: 0.001)
        XCTAssertEqual(input.altitude, 0.6, accuracy: 0.001)
        XCTAssertEqual(input.azimuth, 1.2, accuracy: 0.001)
        XCTAssertEqual(input.kind, .pencil)
    }

    func testJSONInputTraceReplaysSyntheticPencilMetadata() throws {
        let fixtureURL = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("../ref/input-traces/synthetic-pencil.json")
        let fixture = try JSONDecoder().decode(InputTrace.self, from: Data(contentsOf: fixtureURL))
        XCTAssertEqual(fixture.tool, "pencil")
        XCTAssertEqual(fixture.canvasWidth, 1920)
        XCTAssertEqual(fixture.canvasHeight, 1200)
        XCTAssertEqual(fixture.events.count, 3)
        let normalizedInputs = try fixture.normalizedInputs()
        XCTAssertEqual(normalizedInputs.count, fixture.events.count)
        let phases: [NormalizedInput.Phase] = [.began, .moved, .ended]
        for (index, event) in fixture.events.enumerated() {
            XCTAssertEqual(event.phase, ["began", "moved", "ended"][index])
            XCTAssertEqual(event.kind, "pencil")
            XCTAssertEqual(event.pressure, [0.35, 0.80, 0.55][index], accuracy: 0.001)
            XCTAssertEqual(event.altitude, [1.20, 0.60, 0.90][index], accuracy: 0.001)
            XCTAssertEqual(event.azimuth, [0.10, 1.20, 2.10][index], accuracy: 0.001)
            let normalized = normalizedInputs[index]
            XCTAssertEqual(normalized.phase, phases[index])
            XCTAssertEqual(normalized.point, CGPoint(x: event.x, y: event.y))
            XCTAssertEqual(normalized.pressure, event.pressure, accuracy: 0.001)
            XCTAssertEqual(normalized.kind, .pencil)
        }
    }

    func testInputTraceSourceStreamsNormalizedEvents() async throws {
        let fixtureURL = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("../ref/input-traces/synthetic-pencil.json")
        let fixture = try JSONDecoder().decode(InputTrace.self, from: Data(contentsOf: fixtureURL))
        var streamed: [NormalizedInput] = []
        for await input in InputTraceSource(trace: fixture).events() {
            streamed.append(input)
        }
        XCTAssertEqual(streamed.count, 3)
        XCTAssertEqual(streamed.first?.phase, .began)
        XCTAssertEqual(streamed.last?.phase, .ended)
        XCTAssertEqual(streamed[1].point, CGPoint(x: 640, y: 420))
    }

    func testCanvasDisplayRectLetterboxesPortraitAndLandscapeWithoutStretching() {
        let document = RasterDocument.referenceCanvasSize
        let portraitBounds = CGRect(x: 0, y: 0, width: 700, height: 1100)
        let portrait = RasterCanvasView.displayRect(forDocumentSize: document, in: portraitBounds)
        XCTAssertEqual(portrait.width / portrait.height, document.width / document.height, accuracy: 0.0001)
        XCTAssertEqual(portrait.width, 700, accuracy: 0.001)
        XCTAssertEqual(portrait.minX, 0, accuracy: 0.001)
        XCTAssertGreaterThan(portrait.minY, 0)
        XCTAssertLessThan(portrait.maxY, portraitBounds.maxY)

        let wideBounds = CGRect(x: 0, y: 0, width: 1600, height: 700)
        let landscape = RasterCanvasView.displayRect(forDocumentSize: document, in: wideBounds)
        XCTAssertEqual(landscape.width / landscape.height, document.width / document.height, accuracy: 0.0001)
        XCTAssertEqual(landscape.height, 700, accuracy: 0.001)
        XCTAssertGreaterThan(landscape.minX, 0)
        XCTAssertLessThan(landscape.maxX, wideBounds.maxX)

        let mapped = RasterCanvasView.logicalPoint(CGPoint(x: portrait.midX, y: portrait.midY), documentSize: document, in: portraitBounds)
        XCTAssertEqual(mapped.x, document.width / 2, accuracy: 1)
        XCTAssertEqual(mapped.y, document.height / 2, accuracy: 1)
    }

    @MainActor
    func testCanvasViewportSupportsTwoFingerZoomWithoutChangingDocumentCoordinates() {
        let document = RasterDocument(size: RasterDocument.referenceCanvasSize)
        let host = LetterboxedCanvasHost(document: document)
        host.frame = CGRect(x: 0, y: 0, width: 390, height: 600)
        host.layoutIfNeeded()

        XCTAssertEqual(host.minimumZoomScale, 1)
        XCTAssertEqual(host.maximumZoomScale, 6)
        XCTAssertEqual(host.panGestureRecognizer.minimumNumberOfTouches, 2)
        XCTAssertEqual(host.canvasView.bounds.size.width / host.canvasView.bounds.size.height, document.size.width / document.size.height, accuracy: 0.0001)

        let canvasBoundsBeforeZoom = host.canvasView.bounds
        host.setZoomScale(2, animated: false)
        XCTAssertEqual(host.zoomScale, 2, accuracy: 0.001)
        XCTAssertEqual(host.canvasView.bounds, canvasBoundsBeforeZoom)
        let midpoint = RasterCanvasView.logicalPoint(
            CGPoint(x: canvasBoundsBeforeZoom.midX, y: canvasBoundsBeforeZoom.midY),
            documentSize: document.size,
            in: canvasBoundsBeforeZoom
        )
        XCTAssertEqual(midpoint.x, document.size.width / 2, accuracy: 1)
        XCTAssertEqual(midpoint.y, document.size.height / 2, accuracy: 1)
    }

    func testCancelledCanvasTransactionRollsBackPartialStroke() {
        let document = RasterDocument(size: CGSize(width: 120, height: 80))
        let original = document.pngData()
        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 10, y: 10), to: CGPoint(x: 100, y: 60), color: .black, width: 12)
        XCTAssertNotEqual(document.pngData(), original)
        document.cancelTransaction()
        XCTAssertEqual(document.pngData(), original)
    }

    func testPrimaryToolbarKeepsTouchTargetsVisibleAtMacAndPhoneWidths() {
        let medium = WorkspaceView.primaryToolbarLayout(viewportWidth: 700, itemCount: 14)
        XCTAssertEqual(medium.rows, 1)
        XCTAssertEqual(medium.columns, 14)
        XCTAssertGreaterThanOrEqual(medium.cellSide, 44)

        let phone = WorkspaceView.primaryToolbarLayout(viewportWidth: 390, itemCount: 14)
        XCTAssertEqual(phone.rows, 2)
        XCTAssertEqual(phone.columns, 7)
        XCTAssertGreaterThanOrEqual(phone.cellSide, 44)
        XCTAssertEqual(phone.cellSide * CGFloat(phone.columns), 390, accuracy: 0.001)
    }

    func testPressurePolicySupportsNativeAndClassicModes() {
        let feather = RasterCanvasView.mappedPressure(force: 0, maximumPossibleForce: 1, type: .pencil, pressureEnabled: true)
        let light = RasterCanvasView.mappedPressure(force: 0.25, maximumPossibleForce: 1, type: .pencil, pressureEnabled: true)
        let medium = RasterCanvasView.mappedPressure(force: 0.5, maximumPossibleForce: 1, type: .pencil, pressureEnabled: true)
        XCTAssertEqual(feather, 0.05, accuracy: 0.001)
        XCTAssertEqual(light, pow(0.25, 1.4), accuracy: 0.001)
        XCTAssertEqual(medium, pow(0.5, 1.4), accuracy: 0.001)
        XCTAssertLessThan(feather, light)
        XCTAssertLessThan(light, medium)
        XCTAssertLessThan(medium, 1)
        XCTAssertEqual(RasterCanvasView.mappedPressure(force: 2, maximumPossibleForce: 1, type: .pencil, pressureEnabled: true), 1.0, accuracy: 0.001)
        XCTAssertEqual(RasterCanvasView.mappedPressure(force: 0.25, maximumPossibleForce: 1, type: .pencil, pressureEnabled: false), 1.0, accuracy: 0.001)
        XCTAssertEqual(RasterCanvasView.mappedPressure(force: 0.25, maximumPossibleForce: 1, type: .direct, pressureEnabled: true), 1.0, accuracy: 0.001)
    }

    func testCoalescedPencilSamplesRenderAsOneContinuousPressureStroke() {
        let document = RasterDocument(size: CGSize(width: 180, height: 120))
        let before = document.pngData()
        document.applyPencilStroke(
            from: CGPoint(x: 20, y: 60),
            samples: [
                PressureStrokeSample(point: CGPoint(x: 60, y: 60), pressure: 0.08),
                PressureStrokeSample(point: CGPoint(x: 110, y: 60), pressure: 0.45),
                PressureStrokeSample(point: CGPoint(x: 160, y: 60), pressure: 1.0),
            ],
            color: .black,
            width: 24
        )
        XCTAssertNotEqual(document.pngData(), before)
    }

    func testApplePencilPressureChangesRenderedStrokeWidth() {
        let lowPressure = RasterDocument(size: CGSize(width: 180, height: 120))
        lowPressure.apply(tool: .pencil, from: CGPoint(x: 20, y: 60), to: CGPoint(x: 160, y: 60), color: .black, width: 24, pressure: 0.25)

        let highPressure = RasterDocument(size: CGSize(width: 180, height: 120))
        highPressure.apply(tool: .pencil, from: CGPoint(x: 20, y: 60), to: CGPoint(x: 160, y: 60), color: .black, width: 24, pressure: 1.0)

        XCTAssertNotEqual(lowPressure.pngData(), highPressure.pngData())
    }

    func testClassicAssetCatalogIsPinnedAndComplete() throws {
        XCTAssertEqual(ClassicAssetCatalog.assets.count, 228)
        XCTAssertEqual(Set(ClassicAssetCatalog.assets.map(\.localName)).count, 228)
        XCTAssertEqual(ClassicAssetCatalog.sourceCommit, "99c67f3427d229f7db60b03dcf19df4d8c2a8ecf")
        XCTAssertEqual(ClassicAssetCatalog.expectedCombinedSHA256.count, 64)
        XCTAssertEqual(
            ClassicAssetCatalog.assets.first { $0.localName == "jskidpix-splash.png" }?.sourcePath,
            "static/splash.png"
        )

        guard classicAssetsAvailable else { return }
        let files = try Dictionary(uniqueKeysWithValues: ClassicAssetCatalog.assets.map { asset in
            let url = try XCTUnwrap(KidPadResource.url(forResource: asset.localName, withExtension: nil))
            return (asset.localName, try Data(contentsOf: url))
        })
        XCTAssertEqual(
            ClassicAssetCatalog.combinedSHA256(for: files),
            ClassicAssetCatalog.expectedCombinedSHA256
        )
    }

    @MainActor
    func testClassicAssetInstallerFailsThenRetriesAtomically() async throws {
        try requireClassicAssets()
        KidPadResource.classicRootOverrideForTesting = nil
        let installRoot = persistenceRoot.appending(path: "DownloadedClassicPack", directoryHint: .isDirectory)
        KidPadResource.installationRootOverrideForTesting = installRoot

        let dataByURL = try Dictionary(uniqueKeysWithValues: ClassicAssetCatalog.assets.map { asset in
            (asset.sourceURL.absoluteString, try Data(contentsOf: classicRoot.appending(path: asset.localName)))
        })
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockClassicAssetURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let failingURL = ClassicAssetCatalog.assets[0].sourceURL.absoluteString
        MockClassicAssetURLProtocol.handler = { request in
            let url = try XCTUnwrap(request.url)
            let status = url.absoluteString == failingURL ? 500 : 200
            let response = try XCTUnwrap(HTTPURLResponse(
                url: url,
                statusCode: status,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/octet-stream"]
            ))
            return (response, dataByURL[url.absoluteString] ?? Data())
        }

        let manager = ClassicAssetPackManager(arguments: [], session: session)
        XCTAssertEqual(manager.phase, .awaitingConsent)
        manager.install()
        for _ in 0..<500 {
            if case .failed = manager.phase { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        guard case .failed = manager.phase else {
            return XCTFail("The rejected upstream response should leave the installer retryable.")
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: installRoot.path))

        MockClassicAssetURLProtocol.handler = { request in
            let url = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/octet-stream"]
            ))
            return (response, dataByURL[url.absoluteString] ?? Data())
        }
        manager.install()
        for _ in 0..<1_000 {
            if manager.phase == .ready { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertEqual(manager.phase, .ready)
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: installRoot.path).count, 229)
        XCTAssertNotNil(KidPadResource.activeClassicRoot)

        try FileManager.default.removeItem(at: installRoot.appending(path: ClassicAssetCatalog.assets[0].localName))
        XCTAssertNil(KidPadResource.activeClassicRoot)
        XCTAssertEqual(ClassicAssetPackManager(arguments: [], session: session).phase, .awaitingConsent)
    }

    @MainActor
    func testAutomatedRunsBypassClassicPackSetup() {
        XCTAssertEqual(ClassicAssetPackManager(arguments: ["--ui-test"]).phase, .ready)
        XCTAssertEqual(ClassicAssetPackManager(arguments: ["--skip-classic-pack"]).phase, .ready)
    }

    func testRasterStrokePerformanceAtReferenceCanvasSize() {
        let document = RasterDocument(size: RasterDocument.referenceCanvasSize)
        measure {
            for index in 0..<24 {
                let y = CGFloat(20 + index * 20)
                document.beginTransaction()
                document.apply(tool: .pencil, from: CGPoint(x: 20, y: y), to: CGPoint(x: 900, y: y + 8), color: .blue, width: 8)
            }
        }
    }

    func testOriginalBrushVariantsProduceDeterministicDistinctOutput() {
        var outputs: [Data] = []
        for variant in RasterDocument.wackyBrushes.indices {
            let document = RasterDocument(size: CGSize(width: 180, height: 120))
            document.apply(tool: .rectangle, from: CGPoint(x: 48, y: 28), to: CGPoint(x: 132, y: 92), color: .blue, width: 10)
            document.setBrushVariant(variant)
            document.beginTransaction()
            document.apply(tool: .brush, from: CGPoint(x: 20, y: 60), to: CGPoint(x: 20, y: 60), color: .purple, width: 12, pressure: 1)
            document.apply(tool: .brush, from: CGPoint(x: 20, y: 60), to: CGPoint(x: 150, y: 60), color: .purple, width: 12, pressure: 1)
            outputs.append(try! XCTUnwrap(document.pngData()))
        }
        let duplicates = RasterDocument.wackyBrushes.indices.compactMap { index -> String? in
            guard let earlier = (0..<index).first(where: { outputs[$0] == outputs[index] }) else { return nil }
            return "\(RasterDocument.wackyBrushes[earlier].name)=\(RasterDocument.wackyBrushes[index].name)"
        }
        XCTAssertEqual(Set(outputs).count, RasterDocument.wackyBrushes.count, "Duplicate brush outputs: \(duplicates)")
    }

    func testBrushCatalogMatchesTheImplementedReferenceEntries() {
        let names = RasterDocument.wackyBrushes.map(\.name)
        XCTAssertEqual(names.count, 28)
        XCTAssertFalse(names.contains("Drippy Paint"))
        XCTAssertFalse(names.contains("Alphabet Line"))
        XCTAssertFalse(names.contains("Caterpillars"))
        XCTAssertTrue(names.contains("Starburst"))
        XCTAssertTrue(names.contains("A Full Deck of Cards"))
        XCTAssertEqual(names.last, "Paw Prints")
        XCTAssertEqual(RasterDocument.wackyBrushes.first?.assetName, "tool-menu-wacky-brush-70")
        XCTAssertEqual(RasterDocument.wackyBrushes.last?.assetName, "system-pawprint")
    }

    func testDifferentSpriteSelectionsProduceDifferentStampRasters() throws {
        try requireClassicAssets()
        let point = CGPoint(x: 90, y: 60)
        let first = RasterDocument(size: CGSize(width: 180, height: 120))
        first.setSpriteSelection(sheet: 0, row: 0, column: 0)
        first.beginTransaction()
        first.apply(tool: .stamp, from: point, to: point, color: .black, width: 10)

        let second = RasterDocument(size: CGSize(width: 180, height: 120))
        second.setSpriteSelection(sheet: 0, row: 0, column: 1)
        second.beginTransaction()
        second.apply(tool: .stamp, from: point, to: point, color: .black, width: 10)

        XCTAssertNotEqual(first.pngData(), second.pngData())
    }

    func testEveryVisibleSpriteInFirstRowProducesDistinctStampPixels() throws {
        try requireClassicAssets()
        let point = CGPoint(x: 90, y: 60)
        let outputs = (0..<14).compactMap { column -> Data? in
            let document = RasterDocument(size: CGSize(width: 180, height: 120))
            document.setSpriteSelection(sheet: 0, row: 0, column: column)
            document.beginTransaction()
            document.apply(tool: .stamp, from: point, to: point, color: .black, width: 10)
            return document.pngData()
        }
        XCTAssertEqual(outputs.count, 14)
        XCTAssertEqual(Set(outputs).count, 14)
    }

    func testLeakyPenProducesVisibleRaster() {
        let document = RasterDocument(size: CGSize(width: 180, height: 120))
        let blank = document.pngData()
        document.setBrushVariant(0)
        document.beginTransaction()
        document.apply(tool: .brush, from: CGPoint(x: 20, y: 60), to: CGPoint(x: 150, y: 60), color: .purple, width: 12)
        XCTAssertNotEqual(document.pngData(), blank)
    }

    func testConnectTheDotsNumberingContinuesAcrossStrokesAndResetsWhenReselected() {
        let document = RasterDocument(size: CGSize(width: 180, height: 120))
        document.setBrushVariant(13)
        document.beginTransaction()
        document.apply(tool: .brush, from: CGPoint(x: 30, y: 40), to: CGPoint(x: 30, y: 40), color: .black, width: 10)
        XCTAssertEqual(document.brushSequenceStep, 1)

        document.beginTransaction()
        document.apply(tool: .brush, from: CGPoint(x: 90, y: 70), to: CGPoint(x: 90, y: 70), color: .black, width: 10)
        XCTAssertEqual(document.brushSequenceStep, 2)

        document.setBrushVariant(12)
        document.setBrushVariant(13)
        XCTAssertEqual(document.brushSequenceStep, 0)
    }

    func testConnectTheDotsUsesSourceSpacingInsteadOfEveryPointerSample() {
        let document = RasterDocument(size: CGSize(width: 180, height: 100))
        document.setBrushVariant(13)
        document.beginTransaction()
        document.apply(tool: .brush, from: CGPoint(x: 10, y: 50), to: CGPoint(x: 10, y: 50), color: .black, width: 10, pressure: 1)
        for x in 11...35 {
            document.apply(tool: .brush, from: CGPoint(x: x - 1, y: 50), to: CGPoint(x: x, y: 50), color: .black, width: 10, pressure: 1)
        }
        XCTAssertEqual(document.brushSequenceStep, 1)
        document.apply(tool: .brush, from: CGPoint(x: 35, y: 50), to: CGPoint(x: 36, y: 50), color: .black, width: 10, pressure: 1)
        XCTAssertEqual(document.brushSequenceStep, 2)
    }

    func testGeometryUsesThePinnedFiftyPixelCadence() throws {
        let document = RasterDocument(size: CGSize(width: 220, height: 120))
        document.setBrushVariant(17)
        document.beginTransaction()
        document.apply(tool: .brush, from: CGPoint(x: 60, y: 60), to: CGPoint(x: 60, y: 60), color: .blue, width: 10, pressure: 1)
        let first = try XCTUnwrap(document.pngData())
        for x in 61...110 {
            document.apply(tool: .brush, from: CGPoint(x: x - 1, y: 60), to: CGPoint(x: x, y: 60), color: .blue, width: 10, pressure: 1)
        }
        XCTAssertEqual(document.pngData(), first)
        document.apply(tool: .brush, from: CGPoint(x: 110, y: 60), to: CGPoint(x: 111, y: 60), color: .blue, width: 10, pressure: 1)
        XCTAssertNotEqual(document.pngData(), first)
    }

    func testTreeUsesSelectedColorAndBrushSize() {
        func tree(color: UIColor, width: CGFloat) -> Data? {
            let document = RasterDocument(size: CGSize(width: 180, height: 140))
            document.setBrushVariant(19)
            document.beginTransaction()
            document.apply(tool: .brush, from: CGPoint(x: 90, y: 120), to: CGPoint(x: 90, y: 120), color: color, width: width)
            return document.pngData()
        }
        XCTAssertNotEqual(tree(color: .purple, width: 10), tree(color: .orange, width: 10))
        XCTAssertNotEqual(tree(color: .purple, width: 5), tree(color: .purple, width: 20))
    }

    func testMixerVariantsProduceDeterministicDistinctOutput() {
        var outputs: [Data] = []
        for variant in 0..<14 {
            let document = RasterDocument(size: CGSize(width: 180, height: 120))
            document.beginTransaction()
            document.apply(tool: .pencil, from: CGPoint(x: 10, y: 10), to: CGPoint(x: 160, y: 100), color: .orange, width: 12)
            document.setMixerVariant(variant)
            document.beginTransaction()
            document.apply(tool: .mixer, from: .zero, to: .zero, color: .black, width: 1)
            outputs.append(try! XCTUnwrap(document.pngData()))
        }
        XCTAssertEqual(Set(outputs).count, 14)
        let repeatDocument = RasterDocument(size: CGSize(width: 180, height: 120))
        repeatDocument.beginTransaction()
        repeatDocument.apply(tool: .pencil, from: CGPoint(x: 10, y: 10), to: CGPoint(x: 160, y: 100), color: .orange, width: 12)
        repeatDocument.setMixerVariant(4)
        repeatDocument.beginTransaction()
        repeatDocument.apply(tool: .mixer, from: .zero, to: .zero, color: .black, width: 1)
        XCTAssertEqual(outputs[4], repeatDocument.pngData())
    }

    func testAlphabetSelectionChangesStampedCharacter() {
        let a = RasterDocument(size: CGSize(width: 180, height: 120))
        a.setAlphabetCharacter("A")
        a.beginTransaction()
        a.apply(tool: .alphabet, from: CGPoint(x: 30, y: 30), to: CGPoint(x: 30, y: 30), color: .black, width: 1)
        let b = RasterDocument(size: CGSize(width: 180, height: 120))
        b.setAlphabetCharacter("Z")
        b.beginTransaction()
        b.apply(tool: .alphabet, from: CGPoint(x: 30, y: 30), to: CGPoint(x: 30, y: 30), color: .black, width: 1)
        XCTAssertNotEqual(a.pngData(), b.pngData())
    }

    func testStampSelectionPersistsAcrossPlacements() {
        let document = RasterDocument(size: CGSize(width: 180, height: 120))
        document.setStampIndex(4)
        document.beginTransaction()
        document.apply(tool: .stamp, from: CGPoint(x: 30, y: 30), to: CGPoint(x: 30, y: 30), color: .black, width: 1)
        document.apply(tool: .stamp, from: CGPoint(x: 120, y: 80), to: CGPoint(x: 120, y: 80), color: .black, width: 1)
        XCTAssertEqual(document.selectedStampIndex, 4)
        XCTAssertNotEqual(document.pngData(), RasterDocument(size: CGSize(width: 180, height: 120)).pngData())
    }

    func testMovingVanMovesACommittedRegion() {
        let document = RasterDocument(size: CGSize(width: 240, height: 160))
        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 25, y: 25), to: CGPoint(x: 80, y: 80), color: .red, width: 12)
        let before = try! XCTUnwrap(document.pngData())
        document.beginTransaction()
        document.apply(tool: .truck, from: CGPoint(x: 50, y: 50), to: CGPoint(x: 180, y: 110), color: .black, width: 1)
        XCTAssertNotEqual(document.pngData(), before)
        document.undo()
        XCTAssertEqual(document.pngData(), before)
    }

    func testMovingVanVariantsUseOriginalSizeCatalogAndPreview() {
        var outputs: [Data] = []
        for variant in [0, 5, 9] {
            let document = RasterDocument(size: CGSize(width: 240, height: 160))
            document.setTruckVariant(variant)
            document.beginTransaction()
            document.apply(tool: .pencil, from: CGPoint(x: 20, y: 20), to: CGPoint(x: 90, y: 70), color: .red, width: 12)
            let preview = document.previewTruck(from: CGPoint(x: 50, y: 50), to: CGPoint(x: 180, y: 100))
            XCTAssertNotEqual(preview.pngData(), document.pngData())
            document.beginTransaction()
            document.apply(tool: .truck, from: CGPoint(x: 50, y: 50), to: CGPoint(x: 180, y: 100), color: .black, width: 1)
            outputs.append(try! XCTUnwrap(document.pngData()))
        }
        XCTAssertEqual(Set(outputs).count, 3)
    }

    func testMovingVanMagnetMatchesPinnedSourcePlaceholder() {
        XCTAssertEqual(RasterDocument.movingVanVariantCount, 13)
        XCTAssertTrue(WorkspaceView.isImplementedTruckOption(12))
        XCTAssertFalse(WorkspaceView.isImplementedTruckOption(13))

        let document = RasterDocument(size: CGSize(width: 240, height: 160))
        document.setTruckVariant(12)
        document.setTruckVariant(13)
        XCTAssertEqual(document.truckVariant, 12)
    }

    func testMovingVanCopyModePreservesTheSourceRegion() {
        let moved = RasterDocument(size: CGSize(width: 240, height: 160))
        let copied = RasterDocument(size: CGSize(width: 240, height: 160))
        for document in [moved, copied] {
            document.beginTransaction()
            document.apply(tool: .pencil, from: CGPoint(x: 25, y: 25), to: CGPoint(x: 80, y: 60), color: .red, width: 12)
        }
        copied.setTruckCopiesSource(true)
        moved.beginTransaction()
        moved.apply(tool: .truck, from: CGPoint(x: 50, y: 50), to: CGPoint(x: 180, y: 100), color: .black, width: 1)
        copied.beginTransaction()
        copied.apply(tool: .truck, from: CGPoint(x: 50, y: 50), to: CGPoint(x: 180, y: 100), color: .black, width: 1)
        XCTAssertNotEqual(moved.pngData(), copied.pngData())
        XCTAssertTrue(copied.truckCopiesSource)
    }

    func testMovingVanPreservesPixelOrientation() throws {
        let document = RasterDocument(size: CGSize(width: 240, height: 160))
        document.setTruckVariant(2)
        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 42, y: 48), to: CGPoint(x: 78, y: 48), color: .red, width: 8, pressure: 1)
        document.apply(tool: .pencil, from: CGPoint(x: 42, y: 72), to: CGPoint(x: 78, y: 72), color: .blue, width: 8, pressure: 1)
        let before = try XCTUnwrap(document.image.cgImage)
        let source = try XCTUnwrap(before.cropping(to: CGRect(x: 40, y: 40, width: 40, height: 40)))

        document.beginTransaction()
        document.apply(tool: .truck, from: CGPoint(x: 60, y: 60), to: CGPoint(x: 180, y: 100), color: .black, width: 1)
        let after = try XCTUnwrap(document.image.cgImage)
        let destination = try XCTUnwrap(after.cropping(to: CGRect(x: 160, y: 80, width: 40, height: 40)))

        XCTAssertEqual(
            try canonicalPixelHash(UIImage(cgImage: source)),
            try canonicalPixelHash(UIImage(cgImage: destination))
        )
    }

    func testSaveCommandCommitPersistsCurrentRaster() throws {
        let document = RasterDocument(size: CGSize(width: 120, height: 80))
        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 10, y: 12), to: CGPoint(x: 105, y: 62), color: .magenta, width: 9)
        let expected = try XCTUnwrap(document.pngData())
        document.commit()
        XCTAssertNil(document.lastSaveErrorDescription)

        let restored = RasterDocument(size: CGSize(width: 120, height: 80))
        try restored.loadSaved()
        XCTAssertEqual(restored.pngData(), expected)
    }

    func testFillAndClearAreUndoableWholeActions() {
        let document = RasterDocument(size: CGSize(width: 80, height: 50))
        let original = document.image.pngData()
        document.beginTransaction()
        document.apply(tool: .fill, from: CGPoint(x: 10, y: 10), to: CGPoint(x: 10, y: 10), color: .green, width: 4)
        XCTAssertNotEqual(document.image.pngData(), original)
        document.undo()
        XCTAssertEqual(document.image.pngData(), original)
        document.beginTransaction()
        document.apply(tool: .clear, from: .zero, to: .zero, color: .black, width: 4)
        XCTAssertEqual(document.image.pngData(), original)
    }

    func testBoundedFillPreservesExteriorPixels() throws {
        let document = RasterDocument(size: CGSize(width: 64, height: 64))
        document.beginTransaction()
        document.apply(tool: .rectangle, from: CGPoint(x: 8, y: 8), to: CGPoint(x: 56, y: 56), color: .black, width: 4)
        document.commit()
        let before = try XCTUnwrap(document.image.cgImage)
        document.beginTransaction()
        document.apply(tool: .fill, from: CGPoint(x: 32, y: 32), to: CGPoint(x: 32, y: 32), color: .red, width: 1)
        let after = try XCTUnwrap(document.image.cgImage)
        func pixel(_ image: CGImage, _ x: Int, _ y: Int) -> [UInt8] {
            var value = [UInt8](repeating: 0, count: 4)
            let context = CGContext(data: &value, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            context.draw(image, in: CGRect(x: -x, y: -y, width: image.width, height: image.height))
            return value
        }
        XCTAssertNotEqual(pixel(after, 32, 32), pixel(before, 32, 32))
        XCTAssertEqual(pixel(after, 2, 2), pixel(before, 2, 2))
    }

    func testPNGExportAndSavedDocumentRoundTrip() throws {
        let document = RasterDocument(size: CGSize(width: 120, height: 80))
        document.beginTransaction()
        document.apply(tool: .rectangle, from: CGPoint(x: 12, y: 12), to: CGPoint(x: 96, y: 60), color: .blue, width: 6)
        let expected = try XCTUnwrap(document.pngData())
        XCTAssertGreaterThan(expected.count, 100)

        try document.save()
        let exportDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("KidPadExportTests-\(UUID().uuidString)", isDirectory: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: exportDirectory) }
        let exportURL = try document.exportPNG(to: exportDirectory)
        XCTAssertEqual(exportURL.lastPathComponent, "KidPad.png")
        XCTAssertEqual(exportURL.deletingLastPathComponent(), exportDirectory)
        XCTAssertTrue(FileManager.default.fileExists(atPath: exportURL.path))
        let exportedData = try Data(contentsOf: exportURL)
        XCTAssertEqual(exportedData, expected)
        let exportedImage = try XCTUnwrap(UIImage(data: exportedData))
        XCTAssertEqual(exportedImage.size, CGSize(width: 120, height: 80))
        XCTAssertEqual(exportedData.count, expected.count)
        let restored = RasterDocument(size: CGSize(width: 120, height: 80))
        try restored.loadSaved()
        XCTAssertEqual(restored.pngData(), expected)
        XCTAssertTrue(FileManager.default.fileExists(atPath: persistenceRoot.appendingPathComponent("LastDrawing.kidpad/manifest.json").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: persistenceRoot.appendingPathComponent("LastDrawing.kidpad/thumbnail.png").path))
    }

    func testNewDrawingThenOpenRecentRestoresThePreviousDrawing() throws {
        let document = RasterDocument(size: CGSize(width: 120, height: 80))
        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 10, y: 10), to: CGPoint(x: 100, y: 60), color: .purple, width: 8)
        document.commit()
        let drawing = try XCTUnwrap(document.pngData())

        document.resetToBlank()
        XCTAssertNotEqual(document.pngData(), drawing)
        XCTAssertTrue(try document.loadRecent())
        XCTAssertEqual(document.pngData(), drawing)
    }

    func testRecentDrawingHistoryKeepsMoreThanOneDrawing() throws {
        let document = RasterDocument(size: CGSize(width: 120, height: 80))
        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 8, y: 8), to: CGPoint(x: 100, y: 20), color: .red, width: 8)
        document.commit()
        let first = try XCTUnwrap(document.pngData())
        document.resetToBlank()
        XCTAssertNil(document.lastArchiveErrorDescription)

        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 8, y: 60), to: CGPoint(x: 100, y: 32), color: .blue, width: 8)
        document.commit()
        let second = try XCTUnwrap(document.pngData())
        document.resetToBlank()
        XCTAssertNil(document.lastArchiveErrorDescription)

        let recent = try document.recentDrawings()
        XCTAssertEqual(recent.count, 2, document.lastArchiveErrorDescription ?? "Recent drawing archive count is wrong")
        let newest = try XCTUnwrap(recent.first)
        let older = try XCTUnwrap(recent.dropFirst().first)
        XCTAssertTrue(try document.loadRecent(id: newest.id))
        XCTAssertEqual(document.pngData(), second)
        XCTAssertTrue(try document.loadRecent(id: older.id))
        XCTAssertEqual(document.pngData(), first)
    }

    func testCorruptPrimaryRecoversFromAtomicBackup() throws {
        let document = RasterDocument(size: CGSize(width: 120, height: 80))
        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 10, y: 10), to: CGPoint(x: 100, y: 60), color: .red, width: 8)
        let first = try XCTUnwrap(document.pngData())
        try document.save()
        document.beginTransaction()
        document.apply(tool: .pencil, from: CGPoint(x: 10, y: 60), to: CGPoint(x: 100, y: 10), color: .blue, width: 8)
        try document.save()
        let primaryDrawing = persistenceRoot.appendingPathComponent("LastDrawing.kidpad/drawing.png")
        try Data("corrupt".utf8).write(to: primaryDrawing, options: .atomic)
        let recovered = RasterDocument(size: CGSize(width: 120, height: 80))
        try recovered.loadSaved()
        XCTAssertEqual(recovered.pngData(), first)
    }
}
