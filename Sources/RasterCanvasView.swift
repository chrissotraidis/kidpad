import UIKit

final class LetterboxedCanvasHost: UIScrollView, UIScrollViewDelegate {
    let canvasView: RasterCanvasView
    private var lastViewportSize = CGSize.zero

    init(document: RasterDocument) {
        canvasView = RasterCanvasView(document: document)
        super.init(frame: .zero)
        backgroundColor = .white
        isOpaque = true
        delegate = self
        minimumZoomScale = 1
        maximumZoomScale = 6
        bouncesZoom = true
        delaysContentTouches = false
        canCancelContentTouches = true
        contentInsetAdjustmentBehavior = .never
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        scrollsToTop = false
        panGestureRecognizer.minimumNumberOfTouches = 2
        addSubview(canvasView)
        isAccessibilityElement = false
        accessibilityElements = [canvasView]
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else { return }
        if lastViewportSize != bounds.size {
            let preservedZoom = zoomScale
            setZoomScale(1, animated: false)
            let fitted = RasterCanvasView.displayRect(
                forDocumentSize: canvasView.document.size,
                in: CGRect(origin: .zero, size: bounds.size)
            )
            canvasView.frame = CGRect(origin: .zero, size: fitted.size)
            contentSize = fitted.size
            lastViewportSize = bounds.size
            setZoomScale(min(max(preservedZoom, minimumZoomScale), maximumZoomScale), animated: false)
        }
        centerCanvas()
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? { canvasView }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerCanvas()
        let percent = Int((zoomScale * 100).rounded())
        canvasView.accessibilityValue = "Canvas zoom \(percent) percent"
    }

    private func centerCanvas() {
        let horizontal = max(0, (bounds.width - contentSize.width) / 2)
        let vertical = max(0, (bounds.height - contentSize.height) / 2)
        let nextInset = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        if contentInset != nextInset { contentInset = nextInset }
    }
}

final class RasterCanvasView: UIView, UIPencilInteractionDelegate {
    let document: RasterDocument
    var inkColor: UIColor = .systemBlue
    var inkWidth: CGFloat = 10
    var activeTool: CanvasTool = .pencil
    var pencilTexture: PencilTexture = .solid
    var shapeFillEnabled = false
    var eraserVariant = 0
    var truckVariant = 0
    var truckCopiesSource = false
    var brushVariant = 0
    var mixerVariant = 0
    var alphabetCharacter: Character = "A"
    var stampPage = 3
    var stampIndex = 0
    var spriteSheet = 0
    var spriteRow = 0
    var spriteColumn = 0
    var pressureEnabled = true
    private var lastPoint: CGPoint?
    private var previewImage: UIImage?
    private(set) var lastInput: NormalizedInput?
    private var hoverPoint: CGPoint?
    private var didPlayProgressSound = false

    init(document: RasterDocument) {
        self.document = document
        super.init(frame: .zero)
        isMultipleTouchEnabled = false
        isOpaque = true
        backgroundColor = .white
        accessibilityIdentifier = "kidpad.canvas"
        accessibilityTraits = .allowsDirectInteraction
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 2
        accessibilityHint = "Drawing surface. Pencil pressure, tilt, coalesced input, and hover diagnostics are exposed in the accessibility value."
        let hover = UIHoverGestureRecognizer(target: self, action: #selector(handleHover(_:)))
        addGestureRecognizer(hover)
        let pencil = UIPencilInteraction()
        pencil.delegate = self
        addInteraction(pencil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    /// Letterbox the fixed 1920x1200 document into the current view so portrait and
    /// landscape do not independently stretch the bitmap.
    static func displayRect(forDocumentSize documentSize: CGSize, in bounds: CGRect) -> CGRect {
        guard bounds.width > 0, bounds.height > 0, documentSize.width > 0, documentSize.height > 0 else { return bounds }
        let scale = min(bounds.width / documentSize.width, bounds.height / documentSize.height)
        let width = documentSize.width * scale
        let height = documentSize.height * scale
        return CGRect(
            x: bounds.minX + (bounds.width - width) / 2,
            y: bounds.minY + (bounds.height - height) / 2,
            width: width,
            height: height
        )
    }

    static func logicalPoint(_ point: CGPoint, documentSize: CGSize, in bounds: CGRect) -> CGPoint {
        let fitted = displayRect(forDocumentSize: documentSize, in: bounds)
        guard fitted.width > 0, fitted.height > 0 else { return .zero }
        let x = (point.x - fitted.minX) / fitted.width * documentSize.width
        let y = (point.y - fitted.minY) / fitted.height * documentSize.height
        return CGPoint(
            x: min(max(x, 0), documentSize.width),
            y: min(max(y, 0), documentSize.height)
        )
    }

    override func draw(_ rect: CGRect) {
        UIColor.white.setFill()
        UIRectFill(bounds)
        (previewImage ?? document.image).draw(in: bounds)
        if let hoverPoint, activeTool != .stamp && activeTool != .alphabet {
            let context = UIGraphicsGetCurrentContext()
            context?.setStrokeColor(UIColor.systemBlue.withAlphaComponent(0.65).cgColor)
            context?.setLineWidth(1)
            context?.strokeEllipse(in: CGRect(x: hoverPoint.x - inkWidth / 2, y: hoverPoint.y - inkWidth / 2, width: inkWidth, height: inkWidth))
        }
    }

    func refreshFromDocument() {
        previewImage = nil
        hoverPoint = nil
        lastPoint = nil
        setNeedsDisplay()
    }

    func synchronizeDocumentOptions() {
        document.setPencilTexture(pencilTexture)
        document.setShapeFillEnabled(shapeFillEnabled)
        document.setEraserVariant(eraserVariant)
        document.setBrushVariant(brushVariant)
        document.setMixerVariant(mixerVariant)
        document.setTruckVariant(truckVariant)
        document.setTruckCopiesSource(truckCopiesSource)
        document.setAlphabetCharacter(alphabetCharacter)
        if stampPage == 3 {
            document.setSpriteSelection(sheet: spriteSheet, row: spriteRow, column: spriteColumn)
        } else {
            document.setStampIndex(stampIndex)
        }
    }

    private func logicalPoint(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: min(max(point.x / max(bounds.width, 1) * document.size.width, 0), document.size.width),
            y: min(max(point.y / max(bounds.height, 1) * document.size.height, 0), document.size.height)
        )
    }

    static func mappedPressure(force: CGFloat, maximumPossibleForce: CGFloat, type: UITouch.TouchType, pressureEnabled: Bool) -> CGFloat {
        guard type == .pencil, pressureEnabled else { return 1.0 }
        return max(0.25, force / max(0.01, maximumPossibleForce))
    }
    private func pressure(_ touch: UITouch) -> CGFloat { Self.mappedPressure(force: touch.force, maximumPossibleForce: touch.maximumPossibleForce, type: touch.type, pressureEnabled: pressureEnabled) }
    private func record(_ touch: UITouch, phase: NormalizedInput.Phase) {
        let point = logicalPoint(touch.location(in: self))
        lastInput = NormalizedInput(phase: phase, point: point, pressure: pressure(touch), altitude: touch.altitudeAngle, azimuth: touch.azimuthAngle(in: self), kind: touch.type)
        let deviceName = touch.type == .pencil ? "Pencil" : "Touch"
        accessibilityValue = "\(deviceName), pressure \(String(format: "%.2f", pressure(touch))), altitude \(String(format: "%.2f", touch.altitudeAngle)), azimuth \(String(format: "%.2f", touch.azimuthAngle(in: self)))"
    }
    private var isShape: Bool { [.line, .rectangle, .oval].contains(activeTool) }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }; synchronizeDocumentOptions(); record(touch, phase: .began); didPlayProgressSound = false; Task { @MainActor in SoundPlayer.actionStarted(for: activeTool) }; document.beginTransaction(); let point = logicalPoint(touch.location(in: self)); lastPoint = point
        if [.fill, .mixer, .clear].contains(activeTool) { document.apply(tool: activeTool, from: point, to: point, color: inkColor, width: inkWidth, pressure: pressure(touch)); document.commit(); lastPoint = nil; setNeedsDisplay(); if activeTool == .clear { UIView.animate(withDuration: 0.12, animations: { self.alpha = 0.18 }) { _ in UIView.animate(withDuration: 0.24) { self.alpha = 1 } } } }
        else if activeTool == .brush { document.apply(tool: activeTool, from: point, to: point, color: inkColor, width: inkWidth, pressure: pressure(touch)); setNeedsDisplay() }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let lastPoint else { return }
        record(touch, phase: .moved)
        if activeTool == .brush {
            Task { @MainActor in SoundPlayer.actionProgressed(for: activeTool) }
        } else if !didPlayProgressSound && (activeTool == .line || activeTool == .truck) {
            didPlayProgressSound = true
            Task { @MainActor in SoundPlayer.actionProgressed(for: activeTool) }
        }
        let samples = event?.coalescedTouches(for: touch) ?? [touch]
        for sample in samples {
            let point = logicalPoint(sample.location(in: self))
            if activeTool == .pencil || activeTool == .eraser || activeTool == .brush { document.apply(tool: activeTool, from: lastPoint, to: point, color: inkColor, width: inkWidth, pressure: pressure(sample)); self.lastPoint = point }
            else if isShape { previewImage = document.previewShape(activeTool, from: lastPoint, to: point, color: inkColor, width: inkWidth) }
            else if activeTool == .stamp { previewImage = document.previewStamp(at: point) }
            else if activeTool == .alphabet { previewImage = document.previewAlphabet(at: point, color: inkColor) }
            else if activeTool == .truck { previewImage = document.previewTruck(from: lastPoint, to: point) }
        }
        if activeTool == .pencil, let predicted = event?.predictedTouches(for: touch), !predicted.isEmpty, let actualPoint = self.lastPoint {
            let predictedPoints = predicted.map { logicalPoint($0.location(in: self)) }
            previewImage = document.previewStroke(from: actualPoint, through: predictedPoints, color: inkColor, width: inkWidth, pressure: pressure(touch))
            accessibilityValue = "Pencil predicted preview (predictedPoints.count) points"
        }
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let lastPoint else { return }; record(touch, phase: .ended); Task { @MainActor in SoundPlayer.actionEnded(for: activeTool); SoundPlayer.actionReleased(for: activeTool) }; let point = logicalPoint(touch.location(in: self))
        if isShape { document.apply(tool: activeTool, from: lastPoint, to: point, color: inkColor, width: inkWidth); document.commit(); previewImage = nil; setNeedsDisplay() }
        else if activeTool == .pencil || activeTool == .eraser || activeTool == .brush {
            document.apply(tool: activeTool, from: lastPoint, to: point, color: inkColor, width: inkWidth, pressure: pressure(touch))
            if activeTool == .eraser { document.finishEraserStroke() }
            document.commit(); previewImage = nil; setNeedsDisplay()
        }
        else if activeTool == .stamp || activeTool == .alphabet { document.apply(tool: activeTool, from: lastPoint, to: point, color: inkColor, width: inkWidth, pressure: pressure(touch)); document.commit(); previewImage = nil; setNeedsDisplay() }
        else if activeTool == .truck { document.apply(tool: activeTool, from: lastPoint, to: point, color: inkColor, width: inkWidth, pressure: pressure(touch)); document.commit(); previewImage = nil; setNeedsDisplay() }
        self.lastPoint = nil; didPlayProgressSound = false
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { if let touch = touches.first { record(touch, phase: .cancelled) }; document.cancelTransaction(); lastPoint = nil; previewImage = nil; didPlayProgressSound = false; setNeedsDisplay() }

    @objc private func handleHover(_ gesture: UIHoverGestureRecognizer) {
        let point = gesture.location(in: self)
        switch gesture.state {
        case .began, .changed:
            synchronizeDocumentOptions()
            hoverPoint = point
            let logical = logicalPoint(point)
            accessibilityValue = "Hover x \(Int(logical.x)), y \(Int(logical.y)); tool \(activeTool.rawValue)"
            if activeTool == .stamp { previewImage = document.previewStamp(at: logical) }
            else if activeTool == .alphabet { previewImage = document.previewAlphabet(at: logical, color: inkColor) }
            setNeedsDisplay()
        default:
            hoverPoint = nil
            if lastPoint == nil { previewImage = nil }
            setNeedsDisplay()
        }
    }

    func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
        activeTool = activeTool == .eraser ? .pencil : .eraser
        accessibilityValue = "Pencil double-tap switched to \(activeTool.rawValue)"
    }
}
