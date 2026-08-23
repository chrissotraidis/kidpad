import UIKit
import CoreImage

private struct KidPadManifest: Codable {
    let version: Int
    let width: Int
    let height: Int
    let updatedAt: Date
}

struct RecentDrawingSummary: Identifiable, Equatable {
    let id: String
    let updatedAt: Date
}

struct WackyBrushDescriptor: Identifiable, Equatable {
    let id: Int
    let name: String
    let assetName: String
}

enum CanvasTool: String, CaseIterable { case pencil, line, rectangle, oval, brush, mixer, fill, eraser, alphabet, stamp, truck, clear }

enum PencilTexture: String, CaseIterable {
    case solid, partial1, partial2, partial3, partialArtifact, speckles, stripes, thatch, shingles
    case bubbles, diamond, ribbon, sand, brick, chevron, stairs, cross, diagonalBrick, cornerStair, houndstooth, rainbow

    var displayName: String {
        switch self {
        case .solid: return "Solid"
        case .partial1: return "Partial 1"
        case .partial2: return "Partial 2"
        case .partial3: return "Partial 3"
        case .partialArtifact: return "Partial Artifact"
        case .speckles: return "Speckles"
        case .stripes: return "Stripes"
        case .thatch: return "Thatch"
        case .shingles: return "Shingles"
        case .bubbles: return "Bubbles"
        case .diamond: return "Diamond"
        case .ribbon: return "Ribbon"
        case .sand: return "Sand"
        case .brick: return "Brick"
        case .chevron: return "Chevron"
        case .stairs: return "Stairs"
        case .cross: return "Cross"
        case .diagonalBrick: return "Diagonal Brick"
        case .cornerStair: return "Corner Stair"
        case .houndstooth: return "Houndstooth"
        case .rainbow: return "Rainbow"
        }
    }
}

struct NormalizedInput {
    enum Phase: Equatable { case began, moved, ended, cancelled }
    let phase: Phase
    let point: CGPoint
    let pressure: CGFloat
    let altitude: CGFloat
    let azimuth: CGFloat
    let kind: UITouch.TouchType
}

struct PressureStrokeSample: Equatable {
    let point: CGPoint
    let pressure: CGFloat
}

protocol DrawingInputSource {
    func events() -> AsyncStream<NormalizedInput>
}

struct InputTrace: Codable {
    let name: String
    let tool: String
    let canvasWidth: Int
    let canvasHeight: Int
    let events: [InputTraceEvent]
}

struct InputTraceEvent: Codable {
    let phase: String
    let x: CGFloat
    let y: CGFloat
    let pressure: CGFloat
    let altitude: CGFloat
    let azimuth: CGFloat
    let kind: String

    enum DecodeError: Error { case unknownPhase(String) }

    func normalizedInput() throws -> NormalizedInput {
        let normalizedPhase: NormalizedInput.Phase
        switch phase {
        case "began": normalizedPhase = .began
        case "moved": normalizedPhase = .moved
        case "ended": normalizedPhase = .ended
        case "cancelled": normalizedPhase = .cancelled
        default: throw DecodeError.unknownPhase(phase)
        }
        let touchType: UITouch.TouchType
        switch kind {
        case "pencil": touchType = .pencil
        case "indirect": touchType = .indirect
        case "indirectPointer": touchType = .indirectPointer
        default: touchType = .direct
        }
        return NormalizedInput(phase: normalizedPhase, point: CGPoint(x: x, y: y), pressure: pressure, altitude: altitude, azimuth: azimuth, kind: touchType)
    }
}

extension InputTrace {
    func normalizedInputs() throws -> [NormalizedInput] { try events.map { try $0.normalizedInput() } }
}

struct InputTraceSource: DrawingInputSource {
    let trace: InputTrace

    func events() -> AsyncStream<NormalizedInput> {
        AsyncStream { continuation in
            if let inputs = try? trace.normalizedInputs() {
                inputs.forEach { continuation.yield($0) }
            }
            continuation.finish()
        }
    }
}

final class RasterDocument {
    static let referenceCanvasSize = CGSize(width: 1920, height: 1200)
    static nonisolated(unsafe) var persistenceRootOverride: URL?
    static let wackyBrushes: [WackyBrushDescriptor] = [
        .init(id: 0, name: "Leaky Pen", assetName: "tool-menu-wacky-brush-70"),
        .init(id: 1, name: "Zig Zag", assetName: "tool-menu-wacky-brush-71"),
        .init(id: 2, name: "Dots", assetName: "tool-menu-wacky-brush-72"),
        .init(id: 3, name: "Bubbly", assetName: "tool-menu-wacky-brush-73"),
        .init(id: 4, name: "Pies", assetName: "tool-menu-wacky-brush-74"),
        .init(id: 5, name: "Echoes", assetName: "tool-menu-wacky-brush-75"),
        .init(id: 6, name: "Northern Lights", assetName: "tool-menu-wacky-brush-76"),
        .init(id: 7, name: "Fuzzer", assetName: "tool-menu-wacky-brush-77"),
        .init(id: 8, name: "Magnifying Glass", assetName: "tool-menu-wacky-brush-78"),
        .init(id: 9, name: "Spray Paint", assetName: "tool-menu-wacky-brush-79"),
        .init(id: 10, name: "Pine Needles", assetName: "tool-menu-wacky-brush-80"),
        .init(id: 11, name: "3-D", assetName: "tool-menu-wacky-brush-81"),
        .init(id: 12, name: "Kaleidoscope", assetName: "tool-menu-wacky-brush-82"),
        .init(id: 13, name: "Connect The Dots", assetName: "tool-menu-wacky-brush-84"),
        .init(id: 14, name: "Swirl", assetName: "tool-menu-wacky-brush-86"),
        .init(id: 15, name: "Rotating Dots", assetName: "br12"),
        .init(id: 16, name: "Inverter", assetName: "tool-menu-wacky-brush-87"),
        .init(id: 17, name: "Geometry", assetName: "tool-menu-wacky-brush-88"),
        .init(id: 18, name: "XY to XY", assetName: "br16"),
        .init(id: 19, name: "Tree", assetName: "tool-menu-wacky-brush-89"),
        .init(id: 20, name: "Splatter Paint", assetName: "tool-menu-wacky-brush-91"),
        .init(id: 21, name: "Starburst", assetName: "br-starburst"),
        .init(id: 22, name: "The Looper", assetName: "tool-menu-wacky-brush-92"),
        .init(id: 23, name: "A Galaxy of Stars", assetName: "tool-menu-wacky-brush-94"),
        .init(id: 24, name: "Lots of Hugs and Xs", assetName: "tool-menu-wacky-brush-95"),
        .init(id: 25, name: "A Full Deck of Cards", assetName: "tool-menu-wacky-brush-96"),
        .init(id: 26, name: "Shapes and More Shapes", assetName: "tool-menu-wacky-brush-97"),
        .init(id: 27, name: "Paw Prints", assetName: "system-pawprint")
    ]
    let size: CGSize
    private(set) var image: UIImage
    private var undoImages: [UIImage] = []
    private var redoImages: [UIImage] = []
    private var transactionImage: UIImage?
    private var undoGuyWillRedo = false
    private(set) var selectedStampIndex = 0
    private var spriteMode = false
    private var spriteSheetIndex = 0
    private var spriteColumn = 0
    private var spriteRow = 0
    private var brushVariant = 0
    private var mixerVariant = 0
    private var pencilTexture: PencilTexture = .solid
    private var shapeFillEnabled = false
    private var eraserVariant = 0
    private var eraserStrokeStep = 0
    private var hiddenPictureIndex = 0
    private(set) var truckVariant = 0
    private(set) var truckCopiesSource = false
    private var alphabetCharacter = "A"
    private var brushStrokeStep = 0
    private(set) var brushSequenceStep = 0
    private var leakyPenSize: CGFloat = 3
    private var brushStrokeOrigin: CGPoint?
    private var brushLastSamplePoint: CGPoint?
    private(set) var lastSaveErrorDescription: String?
    private(set) var lastArchiveErrorDescription: String?
    private let referenceStampNames = ["kp-h-bear", "kp-h-bison", "kp-h-corn", "kp-h-eye", "kp-h-fox", "kp-h-horse", "kp-h-hummingbird", "kp-h-ladybug", "kp-h-lion", "kp-h-magnet", "kp-h-moth", "kp-h-octopus", "kp-sticker-1", "kp-sticker-2", "kp-sticker-3", "kp-sticker-4", "kp-sticker-5", "kp-sticker-6"]

    init(size: CGSize = RasterDocument.referenceCanvasSize) { self.size = size; image = Self.blank(size: size) }
    func beginTransaction() {
        transactionImage = image
        brushStrokeStep = 0
        leakyPenSize = 3
        brushStrokeOrigin = nil
        brushLastSamplePoint = nil
        eraserStrokeStep = 0
    }
    func cancelTransaction() {
        if let before = transactionImage { image = before }
        transactionImage = nil
        brushStrokeStep = 0
        leakyPenSize = 3
        brushStrokeOrigin = nil
        brushLastSamplePoint = nil
        eraserStrokeStep = 0
    }
    @discardableResult
    func undo() -> Bool {
        if let before = transactionImage, before.pngData() != image.pngData() {
            transactionImage = nil
            redoImages.append(image)
            image = before
            undoGuyWillRedo = true
            try? save()
            return true
        }
        transactionImage = nil
        guard let previous = undoImages.popLast() else { return false }
        redoImages.append(image)
        image = previous
        undoGuyWillRedo = true
        try? save()
        return true
    }
    @discardableResult
    func redo() -> Bool {
        transactionImage = nil
        guard let next = redoImages.popLast() else { return false }
        appendToUndoHistory(image)
        image = next
        undoGuyWillRedo = false
        try? save()
        return true
    }
    func toggleUndo() {
        if undoGuyWillRedo { _ = redo() }
        else { _ = undo() }
    }
    func commit() {
        if let before = transactionImage, before.pngData() != image.pngData() {
            appendToUndoHistory(before)
            redoImages.removeAll()
            undoGuyWillRedo = false
        }
        transactionImage = nil
        do {
            try save()
            lastSaveErrorDescription = nil
        } catch {
            lastSaveErrorDescription = error.localizedDescription
        }
    }
    func resetToBlank() {
        do {
            try archiveCurrentAsRecent()
            lastArchiveErrorDescription = nil
        } catch {
            lastArchiveErrorDescription = error.localizedDescription
        }
        beginTransaction()
        clear()
        commit()
    }

    // The pinned JSKidPix source draws static/splash.png onto the canvas whenever no
    // saved drawing exists (KiddoPaint.Display.loadFromLocalStorage). KidPad mirrors
    // that launch behavior by seeding a fresh document with the original splash.
    static func splashSeededDocument(size: CGSize = referenceCanvasSize) -> RasterDocument {
        let document = RasterDocument(size: size)
        guard let splashURL = KidPadResource.url(forResource: "jskidpix-splash", withExtension: "png"),
              let splash = UIImage(contentsOfFile: splashURL.path) else { return document }
        document.image = render(size: size, base: nil) { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            // Keep the original square splash undistorted on the 1920x1200 document.
            // Portrait/landscape warping is a view-letterbox problem, not a document-scale problem.
            let scale = min(size.width / splash.size.width, size.height / splash.size.height)
            let drawSize = CGSize(width: splash.size.width * scale, height: splash.size.height * scale)
            let origin = CGPoint(x: (size.width - drawSize.width) / 2, y: (size.height - drawSize.height) / 2)
            context.interpolationQuality = .none
            splash.draw(in: CGRect(origin: origin, size: drawSize))
        }
        return document
    }
    func setStampIndex(_ index: Int) { spriteMode = false; selectedStampIndex = max(0, min(index, referenceStampNames.count - 1)) }
    func setSpriteSelection(sheet: Int, row: Int, column: Int) { spriteMode = true; spriteSheetIndex = max(0, min(sheet, 9)); spriteRow = max(0, min(row, 7)); spriteColumn = max(0, min(column, 13)) }
    func setBrushVariant(_ index: Int) {
        let next = max(0, min(index, Self.wackyBrushes.count - 1))
        if next != brushVariant { brushSequenceStep = 0 }
        brushVariant = next
    }
    func setMixerVariant(_ index: Int) { mixerVariant = max(0, min(index, 13)) }
    func setPencilTexture(_ texture: PencilTexture) { pencilTexture = texture }
    func setShapeFillEnabled(_ enabled: Bool) { shapeFillEnabled = enabled }
    func setEraserVariant(_ index: Int) {
        let next = max(0, min(index, 11))
        if next == 5, eraserVariant != next { hiddenPictureIndex = (hiddenPictureIndex + 1) % 12 }
        eraserVariant = next
    }
    func setTruckVariant(_ index: Int) { truckVariant = max(0, min(index, Self.truckSizes.count - 1)) }
    func setTruckCopiesSource(_ copies: Bool) { truckCopiesSource = copies }
    func setAlphabetCharacter(_ character: Character) { alphabetCharacter = String(character) }

    func apply(tool: CanvasTool, from start: CGPoint, to end: CGPoint, color: UIColor, width: CGFloat, pressure: CGFloat = 0.7) {
        switch tool {
        case .pencil: drawStroke(from: start, to: end, color: color, width: width * pressure, texture: pencilTexture)
        case .eraser:
            applyEraser(from: start, to: end, width: width * pressure)
        case .line: drawShape(.line, from: start, to: end, color: color, width: width, texture: pencilTexture)
        case .rectangle: drawShape(.rectangle, from: start, to: end, color: color, width: width, texture: pencilTexture)
        case .oval: drawShape(.oval, from: start, to: end, color: color, width: width, texture: pencilTexture)
        case .brush: drawWackyBrush(from: start, to: end, color: color, width: width * pressure)
        case .mixer: applyMixer()
        case .fill: floodFill(at: end, color: color, texture: pencilTexture)
        case .alphabet: stampText(at: end, color: color)
        case .stamp: stampReference(at: end)
        case .truck: moveRegion(from: start, to: end)
        case .clear: clear()
        }
    }

    /// Draw one UIKit delivery of coalesced Pencil input with a single bitmap
    /// copy. Rendering each sample separately made one touch event copy the
    /// entire 1920x1200 canvas several times before the next frame appeared.
    func applyPencilStroke(from start: CGPoint, samples: [PressureStrokeSample], color: UIColor, width: CGFloat) {
        guard !samples.isEmpty else { return }
        image = Self.render(size: size, base: image) { context in
            let strokeColor = pencilTexture == .solid
                ? color
                : UIColor(patternImage: texturePatternImage(pencilTexture, color: color))
            context.setStrokeColor(strokeColor.cgColor)
            context.setFillColor(strokeColor.cgColor)
            context.setLineCap(.round)

            var previous = start
            for sample in samples {
                let lineWidth = max(1, width * sample.pressure)
                context.setLineWidth(lineWidth)
                if previous == sample.point {
                    context.fillEllipse(in: CGRect(
                        x: sample.point.x - lineWidth / 2,
                        y: sample.point.y - lineWidth / 2,
                        width: lineWidth,
                        height: lineWidth
                    ))
                } else {
                    context.move(to: previous)
                    context.addLine(to: sample.point)
                    context.strokePath()
                }
                previous = sample.point
            }
        }
    }

    func clear() { image = Self.blank(size: size) }
    func finishEraserStroke() {
        // The source's animated letter storm and Fade Away both finish on a
        // blank canvas. KidPad commits that final frame after the gesture.
        if eraserVariant == 8 || eraserVariant == 9 { clear() }
    }
    func pngData() -> Data? { image.pngData() }
    func save() throws {
        guard let data = pngData() else { throw CocoaError(.fileWriteUnknown) }
        let fileManager = FileManager.default
        let storage = try Self.persistenceDirectory()
        let package = storage.appendingPathComponent("LastDrawing.kidpad", isDirectory: true)
        let backup = storage.appendingPathComponent("LastDrawing.kidpad.backup", isDirectory: true)
        let staging = storage.appendingPathComponent("LastDrawing.kidpad.staging-\(UUID().uuidString)", isDirectory: true)
        try fileManager.createDirectory(at: staging, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: staging) }
        let manifest = KidPadManifest(version: 1, width: Int(size.width), height: Int(size.height), updatedAt: Date())
        let manifestData = try JSONEncoder().encode(manifest)
        try manifestData.write(to: staging.appendingPathComponent("manifest.json"), options: .atomic)
        try data.write(to: staging.appendingPathComponent("drawing.png"), options: .atomic)
        try thumbnailData().write(to: staging.appendingPathComponent("thumbnail.png"), options: .atomic)
        if fileManager.fileExists(atPath: backup.path) { try fileManager.removeItem(at: backup) }
        if fileManager.fileExists(atPath: package.path) { try fileManager.moveItem(at: package, to: backup) }
        try fileManager.moveItem(at: staging, to: package)
    }
    func exportPNG(to directory: URL? = nil) throws -> URL {
        let destination = try directory ?? Self.defaultExportDirectory()
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        let url = destination.appendingPathComponent("KidPad.png")
        guard let data = pngData() else { throw CocoaError(.fileWriteUnknown) }
        try data.write(to: url, options: .atomic)
        return url
    }
    func loadSaved() throws {
        let storage = try Self.persistenceDirectory()
        let package = storage.appendingPathComponent("LastDrawing.kidpad", isDirectory: true)
        let backup = storage.appendingPathComponent("LastDrawing.kidpad.backup", isDirectory: true)
        if let restored = Self.loadPackage(at: package) ?? Self.loadPackage(at: backup) { image = restored; return }
    }

    func recentDrawings() throws -> [RecentDrawingSummary] {
        let directory = try Self.recentDirectory()
        let urls = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        return urls.compactMap { url in
            guard let manifest = Self.loadManifest(at: url), Self.loadPackage(at: url) != nil else { return nil }
            return RecentDrawingSummary(id: url.lastPathComponent, updatedAt: manifest.updatedAt)
        }
        .sorted { $0.updatedAt > $1.updatedAt }
    }

    @discardableResult
    func loadRecent(id: String) throws -> Bool {
        guard id == URL(fileURLWithPath: id).lastPathComponent else { return false }
        let package = try Self.recentDirectory().appendingPathComponent(id, isDirectory: true)
        guard let restored = Self.loadPackage(at: package) else { return false }
        appendToUndoHistory(image)
        redoImages.removeAll()
        undoGuyWillRedo = false
        image = restored
        try save()
        return true
    }

    @discardableResult
    func loadRecent() throws -> Bool {
        if let first = try recentDrawings().first, try loadRecent(id: first.id) { return true }
        let storage = try Self.persistenceDirectory()
        let backup = storage.appendingPathComponent("LastDrawing.kidpad.backup", isDirectory: true)
        let primary = storage.appendingPathComponent("LastDrawing.kidpad", isDirectory: true)
        guard let restored = Self.loadPackage(at: backup) ?? Self.loadPackage(at: primary) else { return false }
        appendToUndoHistory(image)
        redoImages.removeAll()
        undoGuyWillRedo = false
        image = restored
        return true
    }

    private func archiveCurrentAsRecent() throws {
        guard let data = pngData() else { throw CocoaError(.fileWriteUnknown) }
        let fileManager = FileManager.default
        let directory = try Self.recentDirectory()
        let identifier = "Drawing-\(Int(Date().timeIntervalSince1970 * 1_000))-\(UUID().uuidString).kidpad"
        let package = directory.appendingPathComponent(identifier, isDirectory: true)
        let staging = directory.appendingPathComponent(".staging-\(UUID().uuidString)", isDirectory: true)
        try fileManager.createDirectory(at: staging, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: staging) }
        let manifest = KidPadManifest(version: 1, width: Int(size.width), height: Int(size.height), updatedAt: Date())
        try JSONEncoder().encode(manifest).write(to: staging.appendingPathComponent("manifest.json"), options: .atomic)
        try data.write(to: staging.appendingPathComponent("drawing.png"), options: .atomic)
        try thumbnailData().write(to: staging.appendingPathComponent("thumbnail.png"), options: .atomic)
        try fileManager.moveItem(at: staging, to: package)

        for old in try recentDrawings().dropFirst(8) {
            try? fileManager.removeItem(at: directory.appendingPathComponent(old.id, isDirectory: true))
        }
    }

    func thumbnailData() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 160, height: 100))
        return renderer.pngData { _ in image.draw(in: CGRect(x: 0, y: 0, width: 160, height: 100)) }
    }

    func previewShape(_ shape: CanvasTool, from start: CGPoint, to end: CGPoint, color: UIColor, width: CGFloat) -> UIImage {
        Self.render(size: size, base: image) { context in self.strokeShape(shape, context: context, from: start, to: end, color: color, width: width, texture: pencilTexture) }
    }

    func previewStamp(at point: CGPoint) -> UIImage { previewStamp(at: point, alpha: 0.45) }
    func previewAlphabet(at point: CGPoint, color: UIColor) -> UIImage {
        Self.render(size: size, base: image) { _ in NSString(string: alphabetCharacter).draw(at: point, withAttributes: [.font: UIFont.boldSystemFont(ofSize: 64), .foregroundColor: color.withAlphaComponent(0.45)]) }
    }
    func previewStroke(from start: CGPoint, through points: [CGPoint], color: UIColor, width: CGFloat, pressure: CGFloat) -> UIImage {
        Self.render(size: size, base: image) { context in
            context.setStrokeColor(color.withAlphaComponent(0.45).cgColor)
            context.setLineWidth(max(1, width * pressure))
            context.setLineCap(.round)
            context.move(to: start)
            for point in points { context.addLine(to: point) }
            context.strokePath()
        }
    }
    func previewTruck(from start: CGPoint, to end: CGPoint) -> UIImage {
        moveRegionImage(from: start, to: end, base: image, clearsSource: !truckCopiesSource)
    }

    func pencilTexturePreview(_ texture: PencilTexture?, shape: CanvasTool = .rectangle) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50), format: format).image { renderer in
            let context = renderer.cgContext
            context.setShouldAntialias(false)
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 50, height: 50))

            let swatch = CGRect(x: 10, y: 10, width: 30, height: 30)
            if let texture {
                context.setFillColor(UIColor(patternImage: texturePatternImage(texture, color: .black)).cgColor)
                if shape == .oval { context.fillEllipse(in: swatch) }
                else { context.fill(swatch) }
            }
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(1)
            if shape == .oval { context.strokeEllipse(in: swatch) }
            else { context.stroke(swatch) }
        }
    }
    func spritePreview(sheet: Int, row: Int, column: Int) -> UIImage { Self.spriteImage(sheet: sheet, row: row, column: column) ?? UIImage() }

    private func appendToUndoHistory(_ snapshot: UIImage) {
        undoImages.append(snapshot)
        if undoImages.count > 32 { undoImages.removeFirst(undoImages.count - 32) }
    }

    private func applyEraser(from start: CGPoint, to end: CGPoint, width: CGFloat) {
        switch eraserVariant {
        case 0: drawSquareEraser(from: start, to: end, side: max(20, width))
        case 1: drawStroke(from: start, to: end, color: .white, width: max(15, width), texture: .solid)
        case 2: drawSquareEraser(from: start, to: end, side: max(10, width))
        case 3: drawSquareEraser(from: start, to: end, side: max(2, width * 0.25))
        case 4: clear() // Firecracker / TNT.
        case 5: drawHiddenPicture(from: start, to: end)
        case 6: drawWhiteCircleEraser()
        case 7: clear() // Slip-Sliding Away / Doorbell final frame.
        case 8: drawEraserLetter() // Final blank frame is committed in finishEraserStroke().
        case 9: fadeEraser()       // Final blank frame is committed in finishEraserStroke().
        case 10, 11:
            // Black Hole and Count Down are explicit `unimpl` placeholders in
            // the pinned JS source and fall back to the ordinary eraser there.
            drawSquareEraser(from: start, to: end, side: max(20, width))
        default: break
        }
        eraserStrokeStep += 1
    }

    private func drawSquareEraser(from start: CGPoint, to end: CGPoint, side: CGFloat) {
        let distance = hypot(end.x - start.x, end.y - start.y)
        let steps = max(1, Int(distance / max(1, side / 3)))
        image = Self.render(size: size, base: image) { context in
            context.setFillColor(UIColor.white.cgColor)
            for index in 0...steps {
                let amount = CGFloat(index) / CGFloat(steps)
                let point = CGPoint(x: start.x + (end.x - start.x) * amount, y: start.y + (end.y - start.y) * amount)
                context.fill(CGRect(x: point.x - side / 2, y: point.y - side / 2, width: side, height: side))
            }
        }
    }

    private func drawHiddenPicture(from start: CGPoint, to end: CGPoint) {
        let name = referenceStampNames[hiddenPictureIndex % 12]
        guard let url = KidPadResource.url(forResource: name, withExtension: "png"),
              let stamp = UIImage(contentsOfFile: url.path) else { return }
        let side: CGFloat = 64
        let distance = hypot(end.x - start.x, end.y - start.y)
        let steps = max(1, Int(distance / (side / 2)))
        image = Self.render(size: size, base: image) { context in
            context.interpolationQuality = .none
            for index in 0...steps {
                let amount = CGFloat(index) / CGFloat(steps)
                let point = CGPoint(x: start.x + (end.x - start.x) * amount, y: start.y + (end.y - start.y) * amount)
                stamp.draw(in: CGRect(x: point.x - side / 2, y: point.y - side / 2, width: side, height: side))
            }
        }
    }

    private func drawWhiteCircleEraser() {
        let seed = UInt64(eraserStrokeStep &* 1_103_515_245 &+ 12_345)
        let x = CGFloat(seed % 10_000) / 10_000 * size.width
        let y = CGFloat((seed / 97) % 10_000) / 10_000 * size.height
        let radius = min(200, CGFloat(25 + eraserStrokeStep))
        image = Self.render(size: size, base: image) { context in
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
        }
    }

    private func drawEraserLetter() {
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let letter = String(letters[eraserStrokeStep % letters.count]) as NSString
        let x = CGFloat((eraserStrokeStep * 137) % max(1, Int(size.width)))
        let y = CGFloat((eraserStrokeStep * 251) % max(1, Int(size.height)))
        let pointSize = CGFloat(48 + (eraserStrokeStep * 29) % 180)
        image = Self.render(size: size, base: image) { _ in
            letter.draw(at: CGPoint(x: x, y: y), withAttributes: [.font: UIFont.systemFont(ofSize: pointSize), .foregroundColor: UIColor.white])
        }
    }

    private func fadeEraser() {
        image = Self.render(size: size, base: image) { context in
            context.setFillColor(UIColor.white.withAlphaComponent(0.34).cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func drawStroke(from start: CGPoint, to end: CGPoint, color: UIColor, width: CGFloat, texture: PencilTexture = .solid) { image = Self.render(size: size, base: image) { c in
        let lineWidth = max(1, width)
        if texture == .solid {
            c.setStrokeColor(color.cgColor)
            c.setFillColor(color.cgColor)
        } else {
            let pattern = UIColor(patternImage: texturePatternImage(texture, color: color)).cgColor
            c.setStrokeColor(pattern)
            c.setFillColor(pattern)
        }
        c.setLineWidth(lineWidth)
        c.setLineCap(.round)
        if start == end {
            c.fillEllipse(in: CGRect(x: start.x - lineWidth / 2, y: start.y - lineWidth / 2, width: lineWidth, height: lineWidth))
        } else {
            c.move(to: start); c.addLine(to: end); c.strokePath()
        }
    } }

    private func texturePatternImage(_ texture: PencilTexture, color: UIColor) -> UIImage {
        let size = Self.textureTileSize(texture)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        return UIGraphicsImageRenderer(size: size, format: format).image { renderer in
            let context = renderer.cgContext
            context.setShouldAntialias(false)
            if texture == .rainbow {
                let colors: [UIColor] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple]
                for (index, stripe) in colors.enumerated() {
                    context.setFillColor(stripe.cgColor)
                    context.fill(CGRect(x: index * 5, y: 0, width: 5, height: 20))
                }
                return
            }
            context.setFillColor(color.cgColor)
            for y in 0..<Int(size.height) {
                for x in 0..<Int(size.width) where Self.textureInk(texture, x: x, y: y) {
                    context.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
    }
    private func drawShape(_ shape: CanvasTool, from start: CGPoint, to end: CGPoint, color: UIColor, width: CGFloat, texture: PencilTexture = .solid) { image = Self.render(size: size, base: image) { c in self.strokeShape(shape, context: c, from: start, to: end, color: color, width: width, texture: texture) } }
    private func strokeShape(_ shape: CanvasTool, context: CGContext, from start: CGPoint, to end: CGPoint, color: UIColor, width: CGFloat, texture: PencilTexture = .solid) {
        let rect = CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
        let patternColor = texture == .solid ? color : UIColor(patternImage: texturePatternImage(texture, color: color))
        context.setLineJoin(.round)

        if shape == .line {
            context.setStrokeColor(patternColor.cgColor)
            context.setLineWidth(max(1, width))
            context.move(to: start)
            context.addLine(to: end)
            context.strokePath()
            return
        }

        // JSKidPix fills Square and Circle with the selected texture. The old
        // native path only changed the outline, so every option looked empty.
        if shapeFillEnabled {
            context.setFillColor(patternColor.cgColor)
            if shape == .rectangle { context.fill(rect) }
            else if shape == .oval { context.fillEllipse(in: rect) }
        }
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(1.5)
        if shape == .rectangle { context.stroke(rect) }
        else if shape == .oval { context.strokeEllipse(in: rect) }
    }

    private func drawWackyBrush(from start: CGPoint, to end: CGPoint, color: UIColor, width: CGFloat) {
        let sourceImage = image.cgImage
        let origin = brushStrokeOrigin ?? start
        brushStrokeOrigin = origin
        let scale = max(0.5, min(2.25, width / 10))
        // JSKidPix keeps the last *accepted* pointer event and emits one mark only
        // after the pointer crosses that brush's source spacing. Using every
        // coalesced UIKit sample made numbered, geometric, and print brushes pile
        // up into an unreadable smear.
        let sourceSpacing: [Int: CGFloat] = [
            1: 5, 2: 22, 4: 40, 5: 1, 10: 3, 11: 5,
            13: 25, 14: 1, 15: 1, 17: 50, 19: 9999,
            23: 36, 24: 36, 25: 36, 26: 36, 27: 25
        ]
        let cadenceBrushes = Set(sourceSpacing.keys)
        let previousSample = brushLastSamplePoint
        if cadenceBrushes.contains(brushVariant), let previousSample {
            let spacing = (sourceSpacing[brushVariant] ?? 5) * scale
            let distance = hypot(end.x - previousSample.x, end.y - previousSample.y)
            guard distance > spacing else { return }
        }
        brushLastSamplePoint = end
        let previousPoint = previousSample ?? start
        let distance = hypot(end.x - previousPoint.x, end.y - previousPoint.y)
        let initialStep = brushVariant == 13 ? brushSequenceStep : brushStrokeStep
        if brushVariant == 13 { brushSequenceStep += 1 }
        else { brushStrokeStep += 1 }
        if brushVariant == 0 {
            leakyPenSize = distance < 2 ? min(15, leakyPenSize + 1.5) : 3
        }

        func randomUnit(_ seed: Int) -> CGFloat {
            let value = UInt64(truncatingIfNeeded: seed &* 1_103_515_245 &+ 12_345)
            return CGFloat(value % 10_000) / 10_000
        }
        func starPath(center: CGPoint, radius: CGFloat) -> CGPath {
            let path = CGMutablePath()
            for point in 0..<10 {
                let angle = -.pi / 2 + CGFloat(point) * .pi / 5
                let currentRadius = point.isMultiple(of: 2) ? radius : radius * 0.42
                let p = CGPoint(x: center.x + cos(angle) * currentRadius, y: center.y + sin(angle) * currentRadius)
                point == 0 ? path.move(to: p) : path.addLine(to: p)
            }
            path.closeSubpath()
            return path
        }

        image = Self.render(size: size, base: image) { c in
            func drawTree(_ start: CGPoint, length: CGFloat, angle: CGFloat, depth: Int, lineWidth: CGFloat, seed: Int) {
                guard depth > 0, lineWidth >= 0.55 else { return }
                let end = CGPoint(x: start.x + cos(angle) * length, y: start.y + sin(angle) * length)
                // The modern color rail remains authoritative. Keep the lighter
                // twig contrast from the source tree without hard-coding green.
                c.setStrokeColor(color.withAlphaComponent(depth <= 2 ? 0.68 : 1).cgColor)
                c.setLineCap(.round); c.setLineWidth(lineWidth); c.move(to: start); c.addLine(to: end); c.strokePath()
                let spread: CGFloat = .pi / 5
                let left = angle - spread * (0.65 + randomUnit(seed) * 0.45)
                let right = angle + spread * (0.65 + randomUnit(seed + 1) * 0.45)
                drawTree(end, length: length * (0.72 + randomUnit(seed + 2) * 0.12), angle: left, depth: depth - 1, lineWidth: lineWidth * 0.7, seed: seed * 2 + 3)
                drawTree(end, length: length * (0.72 + randomUnit(seed + 3) * 0.12), angle: right, depth: depth - 1, lineWidth: lineWidth * 0.7, seed: seed * 2 + 7)
            }

            let step = initialStep
            let point = end
            let previous = previousPoint
                switch brushVariant {
                case 0: // Leaky Pen
                    let radius = leakyPenSize * scale
                    c.setFillColor(color.cgColor)
                    c.saveGState(); c.translateBy(x: point.x, y: point.y); c.rotate(by: .pi / 4)
                    c.fillEllipse(in: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2)); c.restoreGState()
                case 1: // Scribble / Zig Zag
                    let jitterX = (randomUnit(step * 11) - 0.5) * 20 * scale
                    let jitterY = (randomUnit(step * 17) - 0.5) * 20 * scale
                    c.setStrokeColor(color.cgColor); c.setLineWidth(max(1, scale)); c.setLineJoin(.round)
                    c.move(to: previous); c.addLine(to: CGPoint(x: point.x + jitterX, y: point.y + jitterY)); c.strokePath()
                case 2: // Alternating filled and outline circles
                    let radius = 10 * scale; let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
                    c.setStrokeColor(color.cgColor); c.setLineWidth(2 * scale)
                    if step.isMultiple(of: 2) { c.setFillColor(color.cgColor); c.fillEllipse(in: rect) }
                    c.strokeEllipse(in: rect)
                case 3: // Bubbly cluster
                    for row in -2...2 { for column in -2...2 where randomUnit(step * 41 + row * 7 + column) > 0.46 {
                        let center = CGPoint(x: point.x + CGFloat(column) * 4 * scale, y: point.y + CGFloat(row) * 4 * scale)
                        let rect = CGRect(x: center.x - 4 * scale, y: center.y - 4 * scale, width: 8 * scale, height: 8 * scale)
                        c.setStrokeColor(color.cgColor); c.setLineWidth(max(1, scale)); c.strokeEllipse(in: rect)
                        c.setFillColor((randomUnit(step + row + column) > 0.35 ? color : UIColor.white).cgColor); c.fillEllipse(in: rect.insetBy(dx: scale, dy: scale))
                    }}
                case 4: // Pies with a transparent wedge
                    let radius = 20 * scale
                    let gapStart = randomUnit(step * 13) * .pi * 2
                    let gapSize = (.pi * 0.25) + randomUnit(step * 29) * .pi * 0.5
                    c.setFillColor(color.cgColor); c.move(to: point)
                    c.addArc(center: point, radius: radius, startAngle: gapStart + gapSize, endAngle: gapStart + .pi * 2, clockwise: false)
                    c.closePath(); c.fillPath()
                case 5: // Echoes / one cycling concentric ring
                    let radius = CGFloat((step % 7) * 5 + 5) * scale
                    c.setStrokeColor(color.cgColor); c.setLineWidth(max(1, scale)); c.strokeEllipse(in: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
                case 6: // Northern Lights: source fans from the first horizontal anchor
                    c.setStrokeColor(color.cgColor); c.setLineWidth(max(1, 2 * scale))
                    c.move(to: CGPoint(x: point.x, y: origin.y)); c.addLine(to: point); c.strokePath()
                case 7: // Fuzzer: offset-copy the pixels beneath the brush
                    if let sourceImage {
                        let radius = Int(13 * scale)
                        let cropRect = CGRect(x: max(0, Int(point.x) - radius), y: max(0, Int(point.y) - radius), width: min(radius * 2, sourceImage.width), height: min(radius * 2, sourceImage.height))
                        if let crop = sourceImage.cropping(to: cropRect) {
                            let dx = (randomUnit(step * 17) - 0.5) * 14
                            let dy = (randomUnit(step * 23) - 0.5) * 14
                            c.draw(crop, in: CGRect(x: point.x - CGFloat(radius) + dx, y: point.y - CGFloat(radius) + dy, width: CGFloat(crop.width), height: CGFloat(crop.height)))
                        }
                    }
                case 8: // Magnifying Glass: commit a 2x nearest-neighbor pixel region
                    if let sourceImage {
                        let radius = Int(36 * scale)
                        let x = max(0, min(sourceImage.width - radius * 2, Int(point.x) - radius))
                        let y = max(0, min(sourceImage.height - radius * 2, Int(point.y) - radius))
                        if let crop = sourceImage.cropping(to: CGRect(x: x, y: y, width: radius * 2, height: radius * 2)) {
                            c.interpolationQuality = .none
                            c.draw(crop, in: CGRect(x: point.x - CGFloat(radius * 2), y: point.y - CGFloat(radius * 2), width: CGFloat(radius * 4), height: CGFloat(radius * 4)))
                        }
                    }
                case 9: // Spray Paint
                    c.setFillColor(color.cgColor)
                    for dot in 0..<34 {
                        let angle = randomUnit(step * 101 + dot * 13) * .pi * 2
                        let radius = sqrt(randomUnit(step * 107 + dot * 17)) * 18 * scale
                        let dotSize = max(1, randomUnit(step + dot) * 2.5 * scale)
                        c.fillEllipse(in: CGRect(x: point.x + cos(angle) * radius, y: point.y + sin(angle) * radius, width: dotSize, height: dotSize))
                    }
                case 10: // Pine Needles
                    c.setStrokeColor(color.cgColor); c.setLineWidth(max(1, scale))
                    for needle in 0..<7 {
                        let jitterX = (randomUnit(step * 31 + needle) - 0.5) * 50 * scale
                        let jitterY = (randomUnit(step * 37 + needle) - 0.5) * 50 * scale
                        c.move(to: point); c.addLine(to: CGPoint(x: previous.x + jitterX, y: previous.y + jitterY)); c.strokePath()
                    }
                case 11: // 3-D blocks with source-style contrasting quarter
                    let side = 16 * scale; let rect = CGRect(x: point.x, y: point.y, width: side, height: side)
                    c.setFillColor(color.cgColor); c.fill(rect)
                    let shade = color == UIColor.white ? UIColor.black : UIColor.white
                    c.setFillColor(shade.withAlphaComponent(0.72).cgColor); c.fill(CGRect(x: point.x, y: point.y, width: side / 2, height: side / 2))
                case 12: // Kaleidoscope: mirror the stroke in four quadrants around touch-down
                    c.setStrokeColor(color.cgColor); c.setLineWidth(max(1, 2 * scale)); c.setLineCap(.round)
                    let a = CGPoint(x: previous.x - origin.x, y: previous.y - origin.y)
                    let b = CGPoint(x: point.x - origin.x, y: point.y - origin.y)
                    for sx in [CGFloat(-1), 1] { for sy in [CGFloat(-1), 1] {
                        c.move(to: CGPoint(x: origin.x + a.x * sx, y: origin.y + a.y * sy))
                        c.addLine(to: CGPoint(x: origin.x + b.x * sx, y: origin.y + b.y * sy)); c.strokePath()
                    }}
                case 13: // Connect The Dots
                    let label = "• \(step + 1)" as NSString
                    label.draw(at: CGPoint(x: point.x, y: point.y - 8 * scale), withAttributes: [.font: UIFont.systemFont(ofSize: 16 * scale), .foregroundColor: color])
                case 14: // Swirl / Twirly
                    let angle = CGFloat(step % 24) / 24 * .pi * 2; let radius = 25 * scale
                    c.setStrokeColor(color.cgColor); c.setLineWidth(max(1, scale)); c.move(to: point); c.addLine(to: CGPoint(x: point.x + cos(angle) * radius, y: point.y + sin(angle) * radius)); c.strokePath()
                case 15: // Rotating Dots / Following Sine
                    c.setFillColor(color.cgColor); let radius = 33 * scale
                    for dot in 0..<6 { let angle = (CGFloat(step % 50) / 50 + CGFloat(dot) * 0.2) * .pi * 2; c.fill(CGRect(x: point.x + cos(angle) * radius, y: point.y + sin(angle) * radius, width: 3 * scale, height: 3 * scale)) }
                case 16: // Inverter
                    let side = 25 * scale
                    c.setBlendMode(.difference); c.setFillColor(UIColor.white.cgColor); c.fill(CGRect(x: point.x - side / 2, y: point.y - side / 2, width: side, height: side)); c.setBlendMode(.normal)
                case 17: // Geometry / Guilloche
                    c.setStrokeColor(color.cgColor); c.setLineWidth(max(0.75, scale * 0.5)); let radius = 28 * scale
                    for segment in 0...180 {
                        let angle = CGFloat(segment) / 180 * .pi * 4
                        let x = point.x + cos(angle * 3) * radius * 0.72 + cos(angle * 7) * radius * 0.28
                        let y = point.y + sin(angle * 3) * radius * 0.72 + sin(angle * 7) * radius * 0.28
                        segment == 0 ? c.move(to: CGPoint(x: x, y: y)) : c.addLine(to: CGPoint(x: x, y: y))
                    }
                    c.strokePath()
                case 18: // XY to XY: source-style line fan between three gesture anchors
                    c.setStrokeColor(color.cgColor); c.setLineWidth(max(1, scale))
                    let pivot = start
                    let third = end
                    for line in 0...37 {
                        let amount = CGFloat(line) / 37
                        let a = CGPoint(x: origin.x + (pivot.x - origin.x) * amount, y: origin.y + (pivot.y - origin.y) * amount)
                        let b = CGPoint(x: pivot.x + (third.x - pivot.x) * amount, y: pivot.y + (third.y - pivot.y) * amount)
                        c.move(to: a); c.addLine(to: b)
                    }
                    c.strokePath()
                case 19: // Tree: a single recursive tree on touch-down
                    if initialStep == 0 { drawTree(point, length: 32 * scale, angle: -.pi / 2, depth: 8, lineWidth: 10 * scale, seed: Int(point.x + point.y)) }
                case 20: // Splatter Paint
                    let palette: [UIColor] = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple, .systemPink]
                    for dot in 0..<4 {
                        let radius = (1 + randomUnit(step * 59 + dot) * 6) * scale
                        let dx = (randomUnit(step * 61 + dot) - 0.5) * 27 * scale
                        let dy = (randomUnit(step * 67 + dot) - 0.5) * 27 * scale
                        c.setFillColor(palette[(step + dot) % palette.count].cgColor); c.fillEllipse(in: CGRect(x: point.x + dx - radius, y: point.y + dy - radius, width: radius * 2, height: radius * 2))
                    }
                case 21: // Starburst is the reference's thin line tool
                    c.setStrokeColor(color.cgColor); c.setLineWidth(max(2, scale * 2)); c.move(to: previous); c.addLine(to: point); c.strokePath()
                case 22: // The Looper
                    let radius = 32 * scale
                    let priorAngle = CGFloat(max(0, step - 1)) * 0.15
                    let angle = CGFloat(step) * 0.15
                    c.setStrokeColor(color.cgColor); c.setLineWidth(max(2, 5 * scale)); c.setLineCap(.round)
                    c.move(to: CGPoint(x: previous.x + sin(-priorAngle) * radius, y: previous.y + cos(priorAngle) * radius))
                    c.addLine(to: CGPoint(x: point.x + sin(-angle) * radius, y: point.y + cos(angle) * radius)); c.strokePath()
                case 23: // A Galaxy of Stars
                    c.addPath(starPath(center: point, radius: 14 * scale)); c.setFillColor(color.cgColor); c.fillPath()
                case 24: // Lots of Hugs and Xs
                    let radius = 12 * scale; c.setStrokeColor(color.cgColor); c.setLineWidth(max(2, 2 * scale))
                    if step.isMultiple(of: 2) { c.move(to: CGPoint(x: point.x - radius, y: point.y - radius)); c.addLine(to: CGPoint(x: point.x + radius, y: point.y + radius)); c.move(to: CGPoint(x: point.x + radius, y: point.y - radius)); c.addLine(to: CGPoint(x: point.x - radius, y: point.y + radius)); c.strokePath() }
                    else { c.strokeEllipse(in: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)) }
                case 25: // A Full Deck of Cards
                    let card = CGRect(x: point.x - 11 * scale, y: point.y - 16 * scale, width: 22 * scale, height: 32 * scale)
                    c.setFillColor(UIColor.white.cgColor); c.fill(card); c.setStrokeColor(color.cgColor); c.setLineWidth(max(1, scale)); c.stroke(card)
                    let pip = CGRect(x: point.x - 3 * scale, y: point.y - 3 * scale, width: 6 * scale, height: 6 * scale); c.setFillColor(color.cgColor); c.fillEllipse(in: pip)
                case 26: // Shapes and More Shapes
                    let radius = 13 * scale; c.setFillColor(color.cgColor)
                    switch step % 3 {
                    case 0: c.fillEllipse(in: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
                    case 1: c.fill(CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
                    default: c.move(to: CGPoint(x: point.x, y: point.y - radius)); c.addLine(to: CGPoint(x: point.x + radius, y: point.y + radius)); c.addLine(to: CGPoint(x: point.x - radius, y: point.y + radius)); c.closePath(); c.fillPath()
                    }
                case 27: // Paw Prints
                    let angle = atan2(end.y - start.y, end.x - start.x) + .pi / 2
                    c.saveGState()
                    c.translateBy(x: point.x, y: point.y)
                    c.rotate(by: angle)
                    c.setFillColor(color.cgColor)
                    c.fillEllipse(in: CGRect(x: -9 * scale, y: -2 * scale, width: 18 * scale, height: 15 * scale))
                    for toe in 0..<4 {
                        let x = CGFloat(toe) * 6 * scale - 11 * scale
                        let y = (toe == 0 || toe == 3 ? -8 : -11) * scale
                        c.fillEllipse(in: CGRect(x: x, y: y, width: 5 * scale, height: 7 * scale))
                    }
                    c.restoreGState()
                default: break
            }
        }
    }

    private func stampReference(at point: CGPoint) {
        let stamp = referenceStampImage()
        image = Self.render(size: size, base: image) { context in
            context.interpolationQuality = .none
            stamp.draw(in: stampRect(for: stamp, centeredAt: point))
        }
    }

    private func previewStamp(at point: CGPoint, alpha: CGFloat) -> UIImage {
        let stamp = referenceStampImage()
        return Self.render(size: size, base: image) { context in
            context.saveGState()
            context.interpolationQuality = .none
            context.setAlpha(alpha)
            stamp.draw(in: stampRect(for: stamp, centeredAt: point))
            context.restoreGState()
        }
    }

    private func stampRect(for stamp: UIImage, centeredAt point: CGPoint) -> CGRect {
        let maximumDimension: CGFloat = 96
        let sourceSize = stamp.size
        let scale = min(maximumDimension / max(1, sourceSize.width), maximumDimension / max(1, sourceSize.height))
        let drawSize = CGSize(width: max(1, floor(sourceSize.width * scale)), height: max(1, floor(sourceSize.height * scale)))
        return CGRect(x: floor(point.x - drawSize.width / 2), y: floor(point.y - drawSize.height / 2), width: drawSize.width, height: drawSize.height)
    }

    private func referenceStampImage() -> UIImage {
        if spriteMode, let sprite = Self.spriteImage(sheet: spriteSheetIndex, row: spriteRow, column: spriteColumn) { return sprite }
        let name = referenceStampNames[selectedStampIndex % referenceStampNames.count]
        let url = KidPadResource.url(forResource: name, withExtension: "png")
            ?? KidPadResource.url(forResource: "kidpix-guy", withExtension: "png")
        if let url, let image = UIImage(contentsOfFile: url.path) { return image }
        // ReleasePublic has no historical stamp files. Keep stamping functional
        // with a small clean-room geometric mark.
        let side: CGFloat = 96
        return UIGraphicsImageRenderer(size: CGSize(width: side, height: side)).image { renderer in
            let context = renderer.cgContext
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: side, height: side))
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(6)
            context.strokeEllipse(in: CGRect(x: 12, y: 12, width: 72, height: 72))
            context.setFillColor(UIColor.black.cgColor)
            context.fillEllipse(in: CGRect(x: 32, y: 34, width: 8, height: 8))
            context.fillEllipse(in: CGRect(x: 56, y: 34, width: 8, height: 8))
            context.move(to: CGPoint(x: 32, y: 60))
            context.addLine(to: CGPoint(x: 64, y: 60))
            context.strokePath()
        }
    }

    private static func spriteImage(sheet: Int, row: Int, column: Int) -> UIImage? {
        let names = ["kidpix-spritesheet-0", "kidpix-spritesheet-0b", "kidpix-spritesheet-1", "kidpix-spritesheet-2", "kidpix-spritesheet-3", "kidpix-spritesheet-4", "kidpix-spritesheet-5", "kidpix-spritesheet-6", "kidpix-spritesheet-7", "kidpix-spritesheet-8"]
        guard let url = KidPadResource.url(
            forResource: names[max(0, min(sheet, names.count - 1))],
            withExtension: "png"
        ), let source = UIImage(contentsOfFile: url.path)?.cgImage else { return nil }
        let crop = CGRect(x: max(0, min(column, 13)) * 32, y: max(0, min(row, 7)) * 32, width: 32, height: 32)
        guard let image = source.cropping(to: crop) else { return nil }
        return UIImage(cgImage: image, scale: 1, orientation: .up)
    }

    private func stampText(at point: CGPoint, color: UIColor) { image = Self.render(size: size, base: image) { _ in NSString(string: alphabetCharacter).draw(at: point, withAttributes: [.font: UIFont.boldSystemFont(ofSize: 64), .foregroundColor: color]) } }

    private func applyMixer() {
        switch mixerVariant {
        case 1: applyRaindropsMixer()
        case 2: applyCheckerboardMixer()
        case 3: applyWallpaperMixer()
        case 4: applyVenetianMixer()
        case 5: applyOutlineMixer()
        case 6: applyShadowBoxesMixer()
        case 7: applyZoomMixer()
        case 8: applyBrokenGlassMixer()
        case 9: applyPictureInPictureMixer()
        case 10: applyHighlighterMixer()
        case 11: applyPatternMixer()
        case 12: applyWrapAroundMixer()
        case 13: applySnowflakesMixer()
        default: applyInvertMixer()
        }
    }

    private func applyRaindropsMixer() {
        image = Self.render(size: size, base: image) { c in
            c.setStrokeColor(UIColor.systemBlue.withAlphaComponent(0.65).cgColor)
            c.setLineWidth(3)
            let columns = Int(size.width / 72), rows = Int(size.height / 72)
            for row in 0...rows {
                for column in 0...columns {
                    let x = CGFloat(column * 72 + (row.isMultiple(of: 2) ? 18 : 0))
                    let y = CGFloat(row * 72 + 18)
                    c.strokeEllipse(in: CGRect(x: x, y: y, width: 24, height: 24))
                }
            }
        }
    }

    private func applyInvertMixer() {
        guard let cgImage = image.cgImage else { return }
        let input = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CIColorInvert")
        filter?.setValue(input, forKey: kCIInputImageKey)
        guard let output = filter?.outputImage, let rendered = CIContext(options: nil).createCGImage(output, from: input.extent) else { return }
        image = UIImage(cgImage: rendered, scale: 1, orientation: .up)
    }

    private func applyCheckerboardMixer() {
        let tile: CGFloat = 32
        image = Self.render(size: size, base: image) { c in
            c.setBlendMode(.difference)
            c.setFillColor(UIColor.white.cgColor)
            let columns = Int(ceil(size.width / tile)); let rows = Int(ceil(size.height / tile))
            for row in 0..<rows {
                for column in 0..<columns where (row + column).isMultiple(of: 2) {
                    c.fill(CGRect(x: CGFloat(column) * tile, y: CGFloat(row) * tile, width: tile, height: tile))
                }
            }
        }
    }

    private func applyWallpaperMixer() {
        guard let source = image.cgImage else { return }
        let tile = CGRect(x: source.width / 3, y: source.height / 3, width: source.width / 3, height: source.height / 3)
        guard let crop = source.cropping(to: tile) else { return }
        image = Self.render(size: size, base: nil) { c in
            for row in 0..<3 {
                for column in 0..<3 {
                    c.draw(crop, in: CGRect(x: CGFloat(column) * size.width / 3, y: CGFloat(row) * size.height / 3, width: size.width / 3, height: size.height / 3))
                }
            }
        }
    }

    private func applyOutlineMixer() {
        guard let cgImage = image.cgImage else { return }
        let input = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CIEdges")
        filter?.setValue(input, forKey: kCIInputImageKey)
        filter?.setValue(2.5, forKey: kCIInputIntensityKey)
        guard let output = filter?.outputImage, let rendered = CIContext(options: nil).createCGImage(output, from: input.extent) else { return }
        image = UIImage(cgImage: rendered, scale: 1, orientation: .up)
    }

    private func applyShadowBoxesMixer() {
        guard let source = image.cgImage else { return }
        image = Self.render(size: size, base: image) { c in
            for index in 0..<8 {
                let width = max(24, size.width * (0.05 + CGFloat(index % 3) * 0.025))
                let height = max(24, size.height * (0.05 + CGFloat((index + 1) % 3) * 0.025))
                let sourceRect = CGRect(x: CGFloat((index * 137) % max(1, source.width - Int(width))), y: CGFloat((index * 83) % max(1, source.height - Int(height))), width: width, height: height).integral
                let destination = CGRect(x: CGFloat((index * 211) % max(1, Int(size.width - width))), y: CGFloat((index * 97) % max(1, Int(size.height - height))), width: width, height: height)
                guard let crop = source.cropping(to: sourceRect) else { continue }
                c.saveGState(); c.setShadow(offset: CGSize(width: 5, height: 5), blur: 4, color: UIColor.black.cgColor); c.draw(crop, in: destination); c.restoreGState()
            }
        }
    }

    private func applyZoomMixer() {
        guard let source = image.cgImage else { return }
        let crop = CGRect(x: source.width / 4, y: source.height / 4, width: source.width / 2, height: source.height / 2)
        guard let center = source.cropping(to: crop) else { return }
        image = Self.render(size: size, base: image) { c in c.draw(center, in: CGRect(x: 0, y: 0, width: size.width, height: size.height)) }
    }

    private func applyBrokenGlassMixer() {
        guard let source = image.cgImage else { return }
        image = Self.render(size: size, base: nil) { c in
            c.setFillColor(UIColor.white.cgColor); c.fill(CGRect(origin: .zero, size: size))
            for index in 0..<12 {
                let sourceRect = CGRect(x: CGFloat(index % 4) * size.width / 4, y: CGFloat(index / 4) * size.height / 3, width: size.width / 4, height: size.height / 3)
                let destination = CGRect(x: CGFloat((index * 5) % 4) * size.width / 4, y: CGFloat((index * 7) % 3) * size.height / 3, width: size.width / 4, height: size.height / 3)
                if let crop = source.cropping(to: sourceRect.integral) { c.draw(crop, in: destination) }
            }
        }
    }

    private func applyPictureInPictureMixer() {
        image = Self.render(size: size, base: image) { c in
            c.setShadow(offset: CGSize(width: 6, height: 6), blur: 8, color: UIColor.black.cgColor)
            image.draw(in: CGRect(x: size.width * 0.58, y: size.height * 0.58, width: size.width * 0.3, height: size.height * 0.3))
        }
    }

    private func applyHighlighterMixer() {
        image = Self.render(size: size, base: image) { c in
            c.setBlendMode(.screen); c.setFillColor(UIColor.yellow.withAlphaComponent(0.45).cgColor); c.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func applyPatternMixer() {
        image = Self.render(size: size, base: image) { c in
            c.setBlendMode(.difference); c.setStrokeColor(UIColor.white.withAlphaComponent(0.8).cgColor); c.setLineWidth(6)
            let spacing: CGFloat = 48
            for x in stride(from: -size.height, through: size.width, by: spacing) { c.move(to: CGPoint(x: x, y: 0)); c.addLine(to: CGPoint(x: x + size.height, y: size.height)) }
            c.strokePath()
        }
    }

    private func applyWrapAroundMixer() {
        guard let source = image.cgImage else { return }
        image = Self.render(size: size, base: nil) { c in
            c.draw(source, in: CGRect(x: size.width / 2, y: size.height / 2, width: size.width / 2, height: size.height / 2))
            c.draw(source, in: CGRect(x: 0, y: size.height / 2, width: size.width / 2, height: size.height / 2))
            c.draw(source, in: CGRect(x: size.width / 2, y: 0, width: size.width / 2, height: size.height / 2))
            c.draw(source, in: CGRect(x: 0, y: 0, width: size.width / 2, height: size.height / 2))
        }
    }

    private func applySnowflakesMixer() {
        image = Self.render(size: size, base: image) { c in
            c.setStrokeColor(UIColor.white.withAlphaComponent(0.8).cgColor); c.setLineWidth(3)
            for index in 0..<80 {
                let x = CGFloat((index * 97) % max(1, Int(size.width)))
                let y = CGFloat((index * 53) % max(1, Int(size.height)))
                c.move(to: CGPoint(x: x - 6, y: y)); c.addLine(to: CGPoint(x: x + 6, y: y)); c.move(to: CGPoint(x: x, y: y - 6)); c.addLine(to: CGPoint(x: x, y: y + 6))
            }
            c.strokePath()
        }
    }

    private func applyVenetianMixer() {
        guard let source = image.cgImage else { return }
        let bandHeight = max(1, Int(source.height / 10))
        image = Self.render(size: size, base: nil) { c in
            c.setFillColor(UIColor.white.cgColor); c.fill(CGRect(origin: .zero, size: size))
            for index in 0..<10 {
                let sourceIndex = (index * 3) % 10
                let crop = CGRect(x: 0, y: sourceIndex * bandHeight, width: source.width, height: index == 9 ? source.height - sourceIndex * bandHeight : bandHeight)
                if let band = source.cropping(to: crop) {
                    c.draw(band, in: CGRect(x: 0, y: CGFloat(index) * size.height / 10, width: size.width, height: size.height / 10))
                }
            }
        }
    }

    private static let truckSizes: [(CGFloat, CGFloat)] = [
        (100, 100), (50, 50), (20, 20), (10, 10), (2, 2),
        (100, 50), (50, 20), (20, 10), (10, 4),
        (50, 100), (20, 50), (10, 20), (4, 10)
    ]

    /// The pinned source exposes 14 Moving Van tiles, but tile 14 (the magnet)
    /// only plays `Sounds.unimpl()` and never changes the active cut size.
    static var movingVanVariantCount: Int { truckSizes.count }

    private func truckRegion(from start: CGPoint) -> CGRect {
        let (halfWidth, halfHeight) = Self.truckSizes[truckVariant]
        return CGRect(
            x: max(0, min(size.width - halfWidth * 2, start.x - halfWidth)),
            y: max(0, min(size.height - halfHeight * 2, start.y - halfHeight)),
            width: halfWidth * 2,
            height: halfHeight * 2
        ).integral
    }

    private func moveRegion(from start: CGPoint, to end: CGPoint) {
        image = moveRegionImage(from: start, to: end, base: image, clearsSource: !truckCopiesSource)
    }

    private func moveRegionImage(from start: CGPoint, to end: CGPoint, base: UIImage, clearsSource: Bool) -> UIImage {
        let sourceRect = truckRegion(from: start)
        let destinationRect = CGRect(
            x: max(0, min(size.width - sourceRect.width, end.x - sourceRect.width / 2)),
            y: max(0, min(size.height - sourceRect.height, end.y - sourceRect.height / 2)),
            width: sourceRect.width,
            height: sourceRect.height
        ).integral
        guard let crop = base.cgImage?.cropping(to: sourceRect) else { return base }
        let movedImage = UIImage(cgImage: crop, scale: 1, orientation: .up)
        return Self.render(size: size, base: base) { c in
            if clearsSource {
                c.setFillColor(UIColor.white.cgColor)
                c.fill(sourceRect)
            }
            // UIImage.draw uses the renderer's UIKit coordinate system. Drawing
            // the raw CGImage here inverted every Moving Van payload vertically.
            movedImage.draw(in: destinationRect)
        }
    }

    private func floodFill(at point: CGPoint, color: UIColor, texture: PencilTexture = .solid) {
        guard let source = image.cgImage else { return }
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return }
        let width = source.width
        let height = source.height
        let bytesPerRow = width * 4
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: &pixels, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }
        context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))
        let seedX = min(width - 1, max(0, Int(point.x)))
        let seedY = min(height - 1, max(0, Int(point.y)))
        let targetIndex = seedY * bytesPerRow + seedX * 4
        let target = Array(pixels[targetIndex..<targetIndex + 4])
        let replacement: [UInt8] = [UInt8(red * 255), UInt8(green * 255), UInt8(blue * 255), 255]
        guard target != replacement else { return }

        var filled = [Bool](repeating: false, count: width * height)
        func matches(_ x: Int, _ y: Int) -> Bool {
            guard x >= 0, x < width, y >= 0, y < height else { return false }
            let index = y * bytesPerRow + x * 4
            return !filled[y * width + x] && pixels[index] == target[0] && pixels[index + 1] == target[1] && pixels[index + 2] == target[2] && pixels[index + 3] == target[3]
        }

        var spans = [(Int, Int)]()
        spans.reserveCapacity(min(width * height, 4096))
        spans.append((seedX, seedY))
        while let (seed, y) = spans.popLast() {
            guard matches(seed, y) else { continue }
            var left = seed
            while matches(left - 1, y) { left -= 1 }
            var right = seed
            while matches(right + 1, y) { right += 1 }
            for x in left...right {
                let index = y * bytesPerRow + x * 4
                filled[y * width + x] = true
                if texture == .solid || Self.textureInk(texture, x: x, y: y) {
                    pixels[index] = replacement[0]
                    pixels[index + 1] = replacement[1]
                    pixels[index + 2] = replacement[2]
                    pixels[index + 3] = replacement[3]
                }
            }
            for neighborY in [y - 1, y + 1] where neighborY >= 0 && neighborY < height {
                var x = left
                while x <= right {
                    while x <= right && !matches(x, neighborY) { x += 1 }
                    guard x <= right else { break }
                    let runStart = x
                    while x <= right && matches(x, neighborY) { x += 1 }
                    spans.append((runStart, neighborY))
                }
            }
        }
        if let output = context.makeImage() { image = UIImage(cgImage: output, scale: 1, orientation: .up) }
    }

    private static func textureTileSize(_ texture: PencilTexture) -> CGSize {
        switch texture {
        case .solid: return CGSize(width: 1, height: 1)
        case .partial1, .partialArtifact: return CGSize(width: 4, height: 2)
        case .partial2, .partial3: return CGSize(width: 2, height: 2)
        case .stripes: return CGSize(width: 4, height: 4)
        case .chevron: return CGSize(width: 8, height: 5)
        case .houndstooth: return CGSize(width: 9, height: 11)
        case .rainbow: return CGSize(width: 35, height: 20)
        default: return CGSize(width: 8, height: 8)
        }
    }

    private static func textureInk(_ texture: PencilTexture, x: Int, y: Int) -> Bool {
        let size = textureTileSize(texture)
        let width = max(1, Int(size.width))
        let height = max(1, Int(size.height))
        let px = ((x % width) + width) % width
        let py = ((y % height) + height) % height
        func inRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) -> Bool {
            px >= x && px < x + width && py >= y && py < y + height
        }
        switch texture {
        case .solid, .rainbow: return true
        case .partial1:
            return inRect(0, 0, 2, 1) || inRect(1, 1, 3, 1) || inRect(3, 0, 1, 1)
        case .partial2: return px == py
        case .partial3: return px == 0 && py == 0
        case .partialArtifact: return py == 0 || px == 0
        case .stripes:
            return [(0, 2), (1, 1), (2, 0), (3, 3)].contains { $0 == (px, py) }
        case .speckles:
            return inRect(1, 0, 2, 2) || inRect(4, 0, 2, 1) || inRect(6, 1, 2, 2)
                || inRect(2, 3, 2, 2) || inRect(5, 4, 2, 2) || inRect(0, 5, 2, 2)
                || inRect(4, 7, 2, 1)
        case .bubbles:
            return inRect(2, 0, 5, 1) || inRect(0, 1, 2, 1) || inRect(3, 1, 3, 1)
                || inRect(7, 1, 1, 1) || inRect(1, 2, 2, 3) || inRect(0, 3, 2, 3)
                || inRect(6, 2, 1, 3) || inRect(7, 3, 1, 3) || inRect(3, 5, 3, 1)
                || inRect(2, 6, 1, 2) || inRect(3, 7, 4, 1) || inRect(5, 6, 2, 1)
        case .thatch:
            return inRect(2, 1, 5, 1) || inRect(4, 0, 1, 4) || inRect(3, 0, 3, 3)
                || inRect(7, 0, 1, 1) || inRect(1, 2, 1, 1) || inRect(0, 3, 1, 5)
                || inRect(1, 4, 1, 3) || inRect(2, 5, 1, 1) || inRect(3, 6, 1, 1)
                || inRect(4, 7, 1, 1) || inRect(5, 4, 1, 1) || inRect(6, 5, 1, 1)
                || inRect(7, 6, 1, 1) || inRect(7, 4, 1, 2)
        case .shingles:
            return inRect(0, 0, 5, 1) || inRect(2, 1, 1, 2) || inRect(1, 3, 1, 1)
                || inRect(0, 4, 1, 1) || inRect(3, 3, 1, 1) || inRect(4, 4, 4, 1)
                || inRect(6, 5, 1, 2) || inRect(5, 7, 1, 1) || inRect(7, 7, 1, 1)
        case .diamond:
            for startY in 0..<4 {
                let startX = 3 - startY
                for offset in 0..<4 where px == startX + offset && py == startY + offset { return true }
            }
            return false
        case .ribbon:
            return [(4, 1), (3, 2), (2, 3), (6, 5), (7, 6), (0, 7)].contains { $0 == (px, py) }
        case .sand:
            return [(0, 0), (5, 1), (2, 2), (7, 3), (3, 4), (6, 5), (1, 6), (4, 7)].contains { $0 == (px, py) }
        case .brick:
            return inRect(0, 0, 1, 3) || inRect(0, 3, 8, 1) || inRect(4, 4, 1, 3) || inRect(0, 7, 8, 1)
        case .chevron:
            return [(0, 0), (1, 1), (2, 2), (3, 3), (4, 4), (5, 3), (6, 2), (7, 1)].contains { $0 == (px, py) }
        case .stairs:
            return inRect(0, 0, 5, 1) || inRect(4, 1, 1, 4) || inRect(5, 4, 3, 1) || inRect(0, 4, 1, 4)
        case .cross:
            return px == py || (px > 0 && px == 8 - py)
        case .diagonalBrick:
            return inRect(2, 0, 1, 1) || inRect(1, 1, 1, 1) || inRect(0, 2, 1, 2)
                || inRect(1, 3, 1, 1) || inRect(2, 4, 1, 1) || inRect(3, 5, 3, 1)
                || inRect(4, 6, 1, 1) || inRect(3, 7, 1, 1) || inRect(6, 4, 1, 1)
                || inRect(7, 3, 1, 1)
        case .cornerStair:
            return inRect(2, 6, 6, 2) || inRect(4, 4, 4, 2) || inRect(6, 2, 2, 2)
        case .houndstooth:
            return inRect(0, 4, 1, 2) || inRect(1, 3, 1, 2) || inRect(6, 0, 1, 1)
                || inRect(5, 1, 2, 1) || inRect(2, 2, 7, 1) || inRect(2, 3, 6, 1)
                || inRect(2, 4, 5, 2) || inRect(2, 6, 7, 1) || inRect(8, 5, 1, 1)
                || inRect(4, 7, 2, 1) || inRect(3, 8, 2, 1) || inRect(2, 9, 2, 1)
                || inRect(2, 10, 1, 1)
        }
    }

    private static func blank(size: CGSize) -> UIImage { render(size: size, base: nil) { c in c.setFillColor(UIColor.white.cgColor); c.fill(CGRect(origin: .zero, size: size)) } }
    private static func render(size: CGSize, base: UIImage?, draw: (CGContext) -> Void) -> UIImage { let format = UIGraphicsImageRendererFormat(); format.scale = 1; format.opaque = true; return UIGraphicsImageRenderer(size: size, format: format).image { r in if let base { base.draw(in: CGRect(origin: .zero, size: size)) }; draw(r.cgContext) } }
    private static func defaultExportDirectory() throws -> URL {
        let directory = try persistenceDirectory().appendingPathComponent("Exports", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
    static func persistenceDirectory() throws -> URL {
        let directory: URL
        if let override = persistenceRootOverride {
            directory = override
        } else {
            let support = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            directory = support.appendingPathComponent("KidPad", isDirectory: true)
        }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
    private static func recentDirectory() throws -> URL {
        let directory = try persistenceDirectory().appendingPathComponent("RecentDrawings", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
    private static func loadManifest(at package: URL) -> KidPadManifest? {
        let url = package.appendingPathComponent("manifest.json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(KidPadManifest.self, from: data)
    }
    private static func loadPackage(at package: URL) -> UIImage? {
        let drawing = package.appendingPathComponent("drawing.png")
        guard FileManager.default.fileExists(atPath: package.appendingPathComponent("manifest.json").path), let image = UIImage(contentsOfFile: drawing.path) else { return nil }
        return image
    }
}
