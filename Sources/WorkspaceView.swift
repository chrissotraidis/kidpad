import SwiftUI
import UIKit

private enum KidPixChrome {
    static let menuHeight: CGFloat = 50
    static let toolCell: CGFloat = 88
    static let optionHeight: CGFloat = 80
    static let optionCell: CGFloat = 64
    static let optionLabelWidth: CGFloat = 132
    static let optionContentHeight: CGFloat = 76
    static let paletteWidth: CGFloat = 116
    static let swatchWidth: CGFloat = 58
    static let swatchHeight: CGFloat = 33
    static let fieldGrey = Color(white: 0.78)
    static let chromeGrey = Color(white: 0.9)
    static let ruleGrey = Color(white: 0.34)
    static let selectionRed = Color(red: 0.92, green: 0.08, blue: 0.04)
}

private extension Font {
    /// ChiKareGo2 is a freely licensed bitmap homage to the classic Macintosh
    /// system face used by the original Kid Pix shell.
    static func kidPix(_ size: CGFloat, weight _: Weight = .regular) -> Font {
        // ChiKareGo2 contains one bitmap weight. Asking SwiftUI to synthesize
        // bold produces a gray doubled edge that reads like a drop shadow.
        .custom("ChiKareGo2", fixedSize: size)
    }
}

private struct PNGExportPicker: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [fileURL], asCopy: true)
        picker.shouldShowFileExtensions = true
        picker.directoryURL = try? FileManager.default.url(
            for: .downloadsDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

struct WorkspaceView: View {
    static let sourceBrightRGB: [[Int]] = [[255, 0, 0], [255, 255, 0], [0, 255, 0], [0, 0, 255], [0, 255, 255], [255, 0, 255]]
    static let sourceGreyscaleValues = [0, 8, 16, 24, 32, 40, 48, 56, 64, 72, 80, 88, 96, 104, 112, 120, 128, 136, 144, 152, 160, 168, 176, 184, 192, 200, 208, 216, 224, 232, 242, 255]
    static let sourcePalettePageCount = 8
    static let sourceAdditionalPaletteStrings: [[String]] = [
        ["rgb(0,0,0)", "rgb(255,255,255)", "rgb(34,32,52)", "rgb(69,40,60)", "rgb(102,57,49)", "rgb(143,86,59)", "rgb(223,113,38)", "rgb(217,160,102)", "rgb(238,195,154)", "rgb(251,242,54)", "rgb(153,229,80)", "rgb(106,190,48)", "rgb(55,148,110)", "rgb(75,105,47)", "rgb(82,75,36)", "rgb(50,60,57)", "rgb(63,63,116)", "rgb(48,96,130)", "rgb(91,110,225)", "rgb(99,155,255)", "rgb(95,205,228)", "rgb(203,219,252)", "rgb(155,173,183)", "rgb(132,126,135)", "rgb(105,106,106)", "rgb(89,86,82)", "rgb(118,66,138)", "rgb(172,50,50)", "rgb(217,87,99)", "rgb(215,123,186)", "rgb(143,151,74)", "rgb(138,111,48)"],
        ["rgb(24,20,37)", "rgb(255,255,255)", "rgb(190,74,47)", "rgb(215,118,67)", "rgb(234,212,170)", "rgb(228,166,114)", "rgb(184,111,80)", "rgb(115,62,57)", "rgb(62,39,49)", "rgb(162,38,51)", "rgb(228,59,68)", "rgb(247,118,34)", "rgb(254,174,52)", "rgb(254,231,97)", "rgb(99,199,77)", "rgb(62,137,72)", "rgb(38,92,66)", "rgb(25,60,62)", "rgb(18,78,137)", "rgb(0,153,219)", "rgb(44,232,245)", "rgb(192,203,220)", "rgb(139,155,180)", "rgb(90,105,136)", "rgb(58,68,102)", "rgb(38,43,68)", "rgb(255,0,68)", "rgb(104,56,108)", "rgb(181,80,136)", "rgb(246,117,122)", "rgb(232,183,150)", "rgb(194,133,105)"],
        ["#84dcce", "#e8a2bd", "#9dd9b3", "#e5b8e7", "#d2f5c1", "#b8abe1", "#e0d59c", "#87afd9", "#f0b097", "#7cdfea", "#f7abb0", "#5cbbb7", "#cc9dc6", "#aed09e", "#f3daff", "#baab79", "#acd6ff", "#c5a780", "#5bb8cf", "#d1a189", "#acf9ff", "#c1a4b0", "#c8fff6", "#9eadbf", "#fffbe2", "#a6ada7", "#e5fff7", "#a7af93", "#dfe5ff", "#ffdfcb", "#fff5f8", "#ffe3ed"],
        ["#d170e6", "#984060", "#9d6fe8", "#e02f87", "#6d4bba", "#ea90b4", "#8a4bc8", "#e9a6db", "#9935b8", "#ba749c", "#b032a2", "#d6a5f2", "#b32c7c", "#a78ad1", "#af3b70", "#785bae", "#e969a2", "#72619d", "#db49af", "#864b6f", "#e97ad3", "#704889", "#c1589b", "#76409a", "#9a4876", "#9c52b5", "#8c588c", "#9c3d92", "#ba76b1", "#8c468c", "#b672c7", "#9166aa"],
        ["#52e2ff", "#0065cd", "#83fae3", "#0e59ac", "#01ecf1", "#6d91fd", "#5cc4b1", "#596fbb", "#41ebff", "#0065a6", "#8df0fd", "#6b7abc", "#00988c", "#91a6ff", "#02c0c2", "#8cb0ff", "#46adb2", "#007cc5", "#02d8fd", "#476c9c", "#5ed5ff", "#006994", "#a3bdff", "#00a6c5", "#9ba6dd", "#69cae1", "#57b1ff", "#009dc4", "#6ec0ff", "#588cbb", "#00aeeb", "#0098dc"],
        ["#22FFFF", "#44FFFF", "#2AF7FF", "#31F0FF", "#39E8FF", "#40E1FF", "#48D9FF", "#50D1FF", "#57CAFF", "#5FC2FF", "#67BAFF", "#6EB3FF", "#76ABFF", "#7DA4FF", "#859CFF", "#8D94FF", "#948DFF", "#9C85FF", "#A47DFF", "#AB76FF", "#B36EFF", "#BA67FF", "#C25FFF", "#CA57FF", "#D150FF", "#D948FF", "#E140FF", "#E839FF", "#F031FF", "#F72AFF", "#FF88FF", "#FF22FF"]
    ]
    @State private var selectedColor = Color.black
    @State private var selectedTool: CanvasTool = .pencil
    @State private var selectedWidth: CGFloat = 10
    @State private var selectedPencilTexture: PencilTexture = .solid
    @State private var shapeFillEnabled = false
    @State private var selectedEraserVariant = 0
    @State private var selectedBrushVariant = 0
    @State private var selectedMixerVariant = 0
    @State private var selectedTruckVariant = 0
    @State private var truckCopiesSource = false
    @State private var selectedAlphabetCharacter: Character = "A"
    @State private var alphabetPage = 0
    @State private var pencilOptionPage = 0
    @State private var lineOptionPage = 0
    @State private var shapeOptionPage = 0
    @State private var brushOptionPage = 0
    @State private var mixerOptionPage = 0
    @State private var eraserOptionPage = 0
    @State private var truckOptionPage = 0
    @State private var stampPage: Int
    @State private var selectedStampIndex = 0
    @State private var selectedSpriteColumn = 0
    @State private var spriteSheetPage = 0
    @State private var spriteRow = 0
    @State private var palettePage = 0
    @State private var canvasView: RasterCanvasView?
    @State private var openMenuID: String?
    @State private var exportMessage = ""
    @State private var pendingExportURL: URL?
    @State private var recentDrawings: [RecentDrawingSummary]
    @State private var canvasRevision = 0
    @State private var viewportSize = CGSize(width: 1024, height: 768)
    @AppStorage("KidPad.soundEnabled") private var soundEnabled = true
    @AppStorage("KidPad.pressureEnabled") private var pressureEnabled = true
    @AppStorage("KidPad.leftHandedMode") private var leftHandedMode = false
    private var isLeftHanded: Bool {
        leftHandedMode
    }
    // Keep one document object for the lifetime of this workspace. A plain `let`
    // on a SwiftUI View is recreated as the view value is rebuilt, which left the
    // UIKit canvas holding an older document while File/Edit commands mutated a
    // newer one. That made New, Recent, Undo, Redo, and export appear inert.
    @State private var document: RasterDocument
    private let stampNames = ["kp-h-bear", "kp-h-bison", "kp-h-corn", "kp-h-eye", "kp-h-fox", "kp-h-horse", "kp-h-hummingbird", "kp-h-ladybug", "kp-h-lion", "kp-h-magnet", "kp-h-moth", "kp-h-octopus", "kp-sticker-1", "kp-sticker-2", "kp-sticker-3", "kp-sticker-4", "kp-sticker-5", "kp-sticker-6"]
    private let tools: [(CanvasTool, String, String)] = [
        (.pencil, "kp-m_28", "Wacky Pencil"), (.line, "kp-m_29", "Line"), (.rectangle, "kp-m_30", "Rectangle"),
        (.oval, "kp-m_31", "Oval"), (.brush, "kp-m_32", "Wacky Brush"), (.mixer, "kp-m_33", "Electric Mixer"),
        (.fill, "kp-m_34", "Paint Can"), (.eraser, "kp-m_35", "Eraser"), (.alphabet, "kp-m_36", "Alphabet"),
        (.stamp, "kp-m_37", "Rubber Stamps"), (.truck, "kp-m_38", "Moving Van"), (.clear, "cursor-tnt-0", "TNT Clear")
    ]

    init() {
        // Match the pinned source launch behavior: a fresh document shows the original
        // splash on the canvas until the user draws or opens a saved drawing.
        if CommandLine.arguments.contains("--left-handed-mode") {
            UserDefaults.standard.set(true, forKey: "KidPad.leftHandedMode")
        }
        let restored = RasterDocument.splashSeededDocument(size: RasterDocument.referenceCanvasSize)
        try? restored.loadSaved()
        _document = State(initialValue: restored)
        _recentDrawings = State(initialValue: (try? restored.recentDrawings()) ?? [])
        _stampPage = State(initialValue: 3)
    }

    private func showStatus(_ message: String) {
        withAnimation(.linear(duration: 0.08)) { exportMessage = message }
    }

    private func refreshRecentDrawings() {
        recentDrawings = (try? document.recentDrawings()) ?? []
    }

    private var adaptiveToolCell: CGFloat {
        Self.primaryToolbarLayout(viewportWidth: viewportSize.width, itemCount: tools.count + 2).cellSide
    }

    struct PrimaryToolbarLayout: Equatable {
        let columns: Int
        let rows: Int
        let cellSide: CGFloat
    }

    static func primaryToolbarLayout(viewportWidth: CGFloat, itemCount: Int) -> PrimaryToolbarLayout {
        let safeItemCount = max(1, itemCount)
        let minimumTouchSide: CGFloat = 44
        if viewportWidth >= CGFloat(safeItemCount) * minimumTouchSide {
            return PrimaryToolbarLayout(
                columns: safeItemCount,
                rows: 1,
                cellSide: min(KidPixChrome.toolCell, viewportWidth / CGFloat(safeItemCount))
            )
        }
        let columns = min(7, safeItemCount)
        return PrimaryToolbarLayout(
            columns: columns,
            rows: Int(ceil(Double(safeItemCount) / Double(columns))),
            cellSide: viewportWidth / CGFloat(columns)
        )
    }

    private var adaptivePaletteWidth: CGFloat {
        max(72, min(KidPixChrome.paletteWidth, viewportSize.width * 0.12))
    }

    private var adaptiveOptionPageSize: Int {
        max(1, min(10, Int((viewportSize.width - optionPageHeaderWidth) / KidPixChrome.optionCell)))
    }

    private var optionArrowWidth: CGFloat { viewportSize.width < 420 ? 52 : 56 }
    private var optionLabelWidth: CGFloat { viewportSize.width < 420 ? 76 : 96 }
    private var optionPageHeaderWidth: CGFloat { optionArrowWidth * 2 + optionLabelWidth }

    private func optionPageCount(itemCount: Int, pageSize: Int? = nil) -> Int {
        let size = max(1, pageSize ?? adaptiveOptionPageSize)
        return max(1, Int(ceil(Double(itemCount) / Double(size))))
    }

    private func optionPageSlice<T>(_ items: [T], page: Int, pageSize: Int? = nil) -> ArraySlice<T> {
        let size = max(1, pageSize ?? adaptiveOptionPageSize)
        let safePage = min(max(0, page), optionPageCount(itemCount: items.count, pageSize: size) - 1)
        let start = min(items.count, safePage * size)
        return items[start..<min(items.count, start + size)]
    }

    static func isImplementedTruckOption(_ index: Int) -> Bool {
        index >= 0 && index < RasterDocument.movingVanVariantCount
    }

    private func selectStampPage(offset: Int) {
        stampPage = (stampPage + offset + 4) % 4
        if stampPage == 3 {
            selectedSpriteColumn = 0
            document.setSpriteSelection(sheet: spriteSheetPage, row: spriteRow, column: 0)
        } else {
            selectedStampIndex = stampPage * 6
            document.setStampIndex(selectedStampIndex)
        }
        canvasView?.refreshFromDocument()
        SoundPlayer.submenuOptionClick()
    }

    private func advanceStampPage() { selectStampPage(offset: 1) }

    private func selectSpritePack(offset: Int) {
        spriteSheetPage = (spriteSheetPage + offset + 10) % 10
        selectedSpriteColumn = 0
        document.setSpriteSelection(sheet: spriteSheetPage, row: spriteRow, column: 0)
        canvasView?.refreshFromDocument()
        SoundPlayer.submenuOptionClick()
    }

    private func advanceSpritePack() { selectSpritePack(offset: 1) }

    private func selectSpriteRow(offset: Int) {
        spriteRow = (spriteRow + offset + 8) % 8
        selectedSpriteColumn = 0
        document.setSpriteSelection(sheet: spriteSheetPage, row: spriteRow, column: 0)
        canvasView?.refreshFromDocument()
        SoundPlayer.submenuOptionClick()
    }

    private func advanceSpriteRow() { selectSpriteRow(offset: 1) }

    private func selectAlphabetPage(offset: Int) {
        alphabetPage = (alphabetPage + offset + 2) % 2
        selectedAlphabetCharacter = alphabetPage == 0 ? "A" : "!"
        document.setAlphabetCharacter(selectedAlphabetCharacter)
        SoundPlayer.setAlphabetCharacter(selectedAlphabetCharacter)
        SoundPlayer.submenuOptionClick()
    }

    private func chooseTool(_ tool: CanvasTool) {
        openMenuID = nil
        exportMessage = ""
        selectedTool = tool
        if tool == .stamp {
            stampPage = 3
            spriteSheetPage = 0
            spriteRow = 0
            selectedSpriteColumn = 0
            document.setSpriteSelection(sheet: 0, row: 0, column: 0)
            canvasView?.refreshFromDocument()
        } else if tool == .brush {
            // The pinned source always selects Leaky Pen when Wacky Brush opens.
            selectedBrushVariant = 0
            // Keep the user's active size so the same Pencil/pressure control can
            // scale Wacky Brush effects instead of silently snapping back to 10.
            document.setBrushVariant(0)
            SoundPlayer.setBrushVariant(0)
        }
        SoundPlayer.menuClick()
    }

    private func performExport() {
        do {
            let url = try document.exportPNG()
            if CommandLine.arguments.contains("--reset-document") {
                showStatus("PNG prepared as \(url.lastPathComponent)")
            } else {
                pendingExportURL = url
            }
        } catch {
            showStatus("PNG export failed")
        }
    }

    private func performSave() {
        document.commit()
        if document.lastSaveErrorDescription == nil {
            showStatus("Drawing saved")
        } else {
            showStatus("Drawing save failed")
        }
    }

    private func startNewDrawing() {
        document.resetToBlank()
        canvasView?.refreshFromDocument()
        canvasRevision += 1
        refreshRecentDrawings()
        exportMessage = ""
    }

    private func openRecentDrawing(id: String? = nil) {
        do {
            let opened = try id.map { try document.loadRecent(id: $0) } ?? document.loadRecent()
            if opened { exportMessage = "" }
            else { showStatus("No recent drawing found") }
        } catch {
            showStatus("Could not open recent drawing")
        }
        canvasView?.refreshFromDocument()
        canvasRevision += 1
        refreshRecentDrawings()
    }

    private func performUndo() {
        SoundPlayer.menuClick()
        SoundPlayer.oops()
        document.toggleUndo()
        canvasView?.refreshFromDocument()
        canvasRevision += 1
    }

    private func performEditUndo() {
        SoundPlayer.menuClick()
        SoundPlayer.oops()
        _ = document.undo()
        canvasView?.refreshFromDocument()
        canvasRevision += 1
    }

    private func performRedo() {
        SoundPlayer.menuClick()
        _ = document.redo()
        canvasView?.refreshFromDocument()
        canvasRevision += 1
    }

    var body: some View {
        Group {
        if CommandLine.arguments.contains("--ui-test") || CommandLine.arguments.contains("--ui-test-mode") || CommandLine.arguments.contains("--ui-test-compact") {
            GeometryReader { geometry in
                let compactTestMode = CommandLine.arguments.contains("--ui-test-compact")
                ZStack(alignment: .topLeading) {
                    Color.white.ignoresSafeArea()
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 28)
                        if compactTestMode || geometry.size.width > geometry.size.height || geometry.size.width < 900 {
                            landscapeWorkspace
                        } else {
                            HStack(alignment: .top, spacing: 0) { referenceToolbar; canvasSurface }
                            optionStrip
                            referencePalette
                        }
                    }
                    .padding(geometry.size.width > geometry.size.height ? 4 : 2)
                    menuDismissScrim
                    classicMenuDropdown
                    referenceMenuBar
                        .zIndex(20)
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("workspace")
                .frame(width: compactTestMode ? 700 : geometry.size.width, height: geometry.size.height, alignment: .topLeading)
            }.preferredColorScheme(.light)
        } else {
            sourceNativeWorkspace
        }
        }
        .sheet(isPresented: Binding(
            get: { pendingExportURL != nil },
            set: { if !$0 { pendingExportURL = nil } }
        )) {
            if let pendingExportURL {
                PNGExportPicker(fileURL: pendingExportURL)
            }
        }
    }

    private var openMenuItems: [ClassicMacMenuItem] {
        switch openMenuID {
        case "File":
            var items: [ClassicMacMenuItem] = [
                .action("New Drawing") {
                    startNewDrawing()
                },
                .action("Open Recent") {
                    openRecentDrawing(id: recentDrawings.first?.id)
                }
            ]
            items += recentDrawings.dropFirst().prefix(7).enumerated().map { index, recent in
                .action("Recent \(index + 2) · \(recent.updatedAt.formatted(date: .omitted, time: .shortened))", id: "recent.\(recent.id)") {
                    openRecentDrawing(id: recent.id)
                }
            }
            items += [
                .action("Export PNG") {
                    performExport()
                },
                .toggle("Left-Handed Mode", isOn: leftHandedMode) { enabled in
                    leftHandedMode = enabled
                }
            ]
            return items
        case "Edit":
            return [
                .action("Undo") {
                    performEditUndo()
                },
                .action("Redo") {
                    performRedo()
                }
            ]
        case "Goodies":
            return [
                .toggle("Sound", isOn: soundEnabled) { enabled in
                    soundEnabled = enabled
                    SoundPlayer.setEnabled(enabled)
                },
                .toggle("Pressure", isOn: pressureEnabled) { enabled in
                    pressureEnabled = enabled
                    canvasView?.pressureEnabled = enabled
                }
            ]
        default:
            return []
        }
    }

    private var openMenuOffsetX: CGFloat {
        switch openMenuID {
        case "File": return 14
        case "Edit": return 86
        case "Goodies": return 164
        default: return 14
        }
    }

    @ViewBuilder private var classicMenuDropdown: some View {
        if openMenuID != nil {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(openMenuItems) { item in
                    switch item.kind {
                    case .action(let name, let handler):
                        Button {
                            handler()
                            openMenuID = nil
                        } label: {
                            Text(name)
                                .font(.kidPix(22))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .frame(minWidth: 208, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .kidPixHoverHighlight()
                        .accessibilityLabel(name)
                        .accessibilityIdentifier("menuItem." + name)
                    case .toggle(let name, let isOn, let handler):
                        Button {
                            handler(!isOn)
                            openMenuID = nil
                        } label: {
                            Text(name)
                            .font(.kidPix(22))
                            .foregroundStyle(isOn ? Color.white : Color.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .frame(minWidth: 208, alignment: .leading)
                            .background(isOn ? Color.black : Color.clear)
                        }
                        .buttonStyle(.plain)
                        .kidPixHoverHighlight()
                        .accessibilityLabel(name)
                        .accessibilityValue(isOn ? "On" : "Off")
                        .accessibilityIdentifier("menuItem." + name)
                    }
                }
            }
            .background(Color.white)
            .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
            .offset(x: openMenuOffsetX, y: KidPixChrome.menuHeight)
            .zIndex(40)
            .accessibilityElement(children: .contain)
        }
    }

    @ViewBuilder private var menuDismissScrim: some View {
        if openMenuID != nil {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .padding(.top, KidPixChrome.menuHeight)
                .onTapGesture { openMenuID = nil }
                .accessibilityIdentifier("menu.dismiss")
                .accessibilityLabel("Dismiss Menu")
        }
    }

    private var sourceNativeWorkspace: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                KidPixChrome.fieldGrey.ignoresSafeArea()
                VStack(spacing: 0) {
                    referenceMenuBar
                    sourceToolbarResponsive
                    optionStrip
                    HStack(alignment: .top, spacing: 0) {
                        if !isLeftHanded {
                            sourceColorBar(width: adaptivePaletteWidth)
                        }
                        canvasSurface
                            .padding(8)
                            .background(KidPixChrome.fieldGrey)
                            .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                        if isLeftHanded {
                            sourceColorBar(width: adaptivePaletteWidth)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .clipped()
                menuDismissScrim
                classicMenuDropdown
                statusToast
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("workspace")
            .onAppear { viewportSize = geometry.size }
            .onChange(of: geometry.size) { _, nextSize in viewportSize = nextSize }
        }
        .onChange(of: openMenuID) { _, menu in
            if menu != nil { exportMessage = "" }
        }
        .preferredColorScheme(.light)
    }

    private var sourceLandscapeWorkspace: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 28)
            if isLeftHanded {
                HStack(alignment: .top, spacing: 0) {
                    VStack(spacing: 0) {
                        sourceToolbarHorizontal()
                        optionStrip
                        canvasSurface
                    }
                    sourceColorBar()
                }
            } else {
                HStack(alignment: .top, spacing: 0) {
                    sourceColorBar()
                    VStack(spacing: 0) {
                        sourceToolbarHorizontal()
                        optionStrip
                        canvasSurface
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder private var statusToast: some View {
        if !exportMessage.isEmpty {
            Text(exportMessage)
                .font(.kidPix(18, weight: .bold))
                .foregroundStyle(exportMessage.contains("failed") || exportMessage.contains("Could not") ? .red : .black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white)
                .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .padding(.top, KidPixChrome.menuHeight + 6)
                .padding(.trailing, 8)
                .zIndex(30)
                .accessibilityIdentifier("export.status.native")
                .onTapGesture { exportMessage = "" }
                .task(id: exportMessage) {
                    try? await Task.sleep(nanoseconds: 1_600_000_000)
                    guard !Task.isCancelled else { return }
                    withAnimation(.linear(duration: 0.12)) { exportMessage = "" }
                }
        }
    }

    private func sourceColorBar(width: CGFloat = KidPixChrome.paletteWidth) -> some View {
        let swatchWidth = width / 2
        let swatchHeight = max(24, min(KidPixChrome.swatchHeight, width * 0.285))
        return VStack(spacing: 0) {
            Rectangle()
                .fill(selectedColor)
                .frame(width: max(50, width - 12), height: 52)
                .padding(5)
                .background(KidPixChrome.chromeGrey)
                .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
                .accessibilityIdentifier("palette.current")
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.fixed(swatchWidth), spacing: 0), GridItem(.fixed(swatchWidth), spacing: 0)], spacing: 0) {
                    ForEach(Array(referencePaletteColors.enumerated()), id: \.offset) { index, color in
                        Button {
                            selectedColor = color
                            canvasView?.inkColor = UIColor(color)
                            SoundPlayer.submenuColorClick()
                        } label: {
                            Rectangle()
                                .fill(color)
                                .frame(width: swatchWidth, height: swatchHeight)
                                .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                .overlay(Rectangle().inset(by: 2).stroke(selectedColor == color ? KidPixChrome.selectionRed : Color.clear, lineWidth: 2))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Color \(index + 1)")
                        .accessibilityIdentifier("palette.color.\(index + 1)")
                    }
                }
                .frame(width: width)
            }
            .frame(maxHeight: .infinity)
            HStack(spacing: 0) {
                Button { palettePage = (palettePage + Self.sourcePalettePageCount - 1) % Self.sourcePalettePageCount; SoundPlayer.submenuColorClick() } label: { Image(systemName: "arrow.left").frame(width: swatchWidth, height: 34) }.accessibilityLabel("Previous Palette")
                Button { palettePage = (palettePage + 1) % Self.sourcePalettePageCount; SoundPlayer.submenuColorClick() } label: { Image(systemName: "arrow.right").frame(width: swatchWidth, height: 34) }.accessibilityLabel("Next Palette")
            }
            .font(.kidPix(20, weight: .bold))
            .background(KidPixChrome.chromeGrey)
            .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
            Spacer(minLength: 0)
        }
        .frame(width: width)
        .background(KidPixChrome.chromeGrey)
        .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
        .buttonStyle(.plain)
    }

    private var sourceToolbar: some View {
        VStack(spacing: 0) {
            Button { performSave() } label: { referenceImage("kp-m_27") }
                .accessibilityLabel("Save")
                .accessibilityIdentifier("tool.save")
                .kidPixHoverHighlight()
                .contextMenu {
                    Button("New Drawing") {
                        startNewDrawing()
                    }
                    .accessibilityIdentifier("source.newDrawing")
                    Button("Open Recent") {
                        openRecentDrawing()
                    }
                    .accessibilityIdentifier("source.openRecent")
                    Button("Export PNG") {
                        performExport()
                    }
                    .accessibilityIdentifier("source.exportPNG")
                }
            ForEach(Array(tools.enumerated()), id: \.offset) { _, item in
                Button {
                    chooseTool(item.0)
                } label: {
                    referenceImage(item.1, selected: selectedTool == item.0)
                }
                .accessibilityLabel(item.2)
                .accessibilityIdentifier(item.0 == .truck ? "tool.movingVan" : "tool.\(item.0.rawValue)")
                .kidPixHoverHighlight()
            }
            Button { performUndo() } label: { referenceImage("kp-m_39") }
                .accessibilityLabel("Undo Guy")
                .accessibilityIdentifier("tool.undo")
                .kidPixHoverHighlight()
            Spacer(minLength: 0)
        }
        .frame(width: 50)
        .background(Color.white)
        .overlay(Rectangle().stroke(Color.gray, lineWidth: 0.75))
    }

    private func sourceToolbarHorizontal(cellSide: CGFloat = KidPixChrome.toolCell) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                Button { performSave() } label: { referenceImage("kp-m_27", side: cellSide) }
                    .accessibilityLabel("Save")
                    .accessibilityIdentifier("tool.save")
                    .kidPixHoverHighlight()
                    .contextMenu {
                        Button("New Drawing") { startNewDrawing() }
                        Button("Open Recent") { openRecentDrawing() }
                        Button("Export PNG") { performExport() }
                    }
                ForEach(Array(tools.enumerated()), id: \.offset) { _, item in
                    Button {
                        chooseTool(item.0)
                    } label: {
                        referenceImage(item.1, selected: selectedTool == item.0, side: cellSide)
                    }
                    .accessibilityLabel(item.2)
                    .accessibilityIdentifier(item.0 == .truck ? "tool.movingVan" : "tool.\(item.0.rawValue)")
                    .kidPixHoverHighlight()
                }
                Button { performUndo() } label: { referenceImage("kp-m_39", side: cellSide) }
                    .accessibilityLabel("Undo Guy")
                    .accessibilityIdentifier("tool.undo")
                    .kidPixHoverHighlight()
            }
        }
        .frame(height: cellSide, alignment: .leading)
        .background(KidPixChrome.chromeGrey)
        .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
        .buttonStyle(.plain)
    }

    @ViewBuilder private var sourceToolbarResponsive: some View {
        let layout = Self.primaryToolbarLayout(viewportWidth: viewportSize.width, itemCount: tools.count + 2)
        if layout.rows == 1 {
            sourceToolbarHorizontal(cellSide: layout.cellSide)
        } else {
            let columns = Array(
                repeating: GridItem(.fixed(layout.cellSide), spacing: 0),
                count: layout.columns
            )
            LazyVGrid(columns: columns, alignment: .leading, spacing: 0) {
                sourceToolbarItems(cellSide: layout.cellSide)
            }
            .frame(maxWidth: .infinity, minHeight: layout.cellSide * CGFloat(layout.rows), alignment: .topLeading)
            .background(KidPixChrome.chromeGrey)
            .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
            .buttonStyle(.plain)
            .accessibilityIdentifier("toolbar.compact")
        }
    }

    @ViewBuilder private func sourceToolbarItems(cellSide: CGFloat) -> some View {
        Button { performSave() } label: { referenceImage("kp-m_27", side: cellSide) }
            .accessibilityLabel("Save")
            .accessibilityIdentifier("tool.save")
            .kidPixHoverHighlight()
            .contextMenu {
                Button("New Drawing") { startNewDrawing() }
                Button("Open Recent") { openRecentDrawing() }
                Button("Export PNG") { performExport() }
            }
        ForEach(Array(tools.enumerated()), id: \.offset) { _, item in
            Button { chooseTool(item.0) } label: {
                referenceImage(item.1, selected: selectedTool == item.0, side: cellSide)
            }
            .accessibilityLabel(item.2)
            .accessibilityIdentifier(item.0 == .truck ? "tool.movingVan" : "tool.\(item.0.rawValue)")
            .kidPixHoverHighlight()
        }
        Button { performUndo() } label: { referenceImage("kp-m_39", side: cellSide) }
            .accessibilityLabel("Undo Guy")
            .accessibilityIdentifier("tool.undo")
            .kidPixHoverHighlight()
    }

    private var landscapeWorkspace: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                referenceLandscapeToolbar
            }.frame(height: 50)
            HStack(alignment: .top, spacing: 0) {
                referenceColorRail
                VStack(spacing: 0) {
                    canvasSurface
                    optionStrip
                    referencePalette
                }
            }
        }
    }

    private var referenceMenuBar: some View {
        HStack(spacing: 8) {
            ClassicMacMenu(openMenuID: $openMenuID, title: "File")
            .accessibilityIdentifier("menu.file")
            ClassicMacMenu(openMenuID: $openMenuID, title: "Edit")
            .accessibilityIdentifier("menu.edit")
            ClassicMacMenu(openMenuID: $openMenuID, title: "Goodies")
            .accessibilityIdentifier("menu.goodies")
            Spacer()
        }
        .font(.kidPix(24, weight: .bold))
        .foregroundStyle(.black)
        .padding(.horizontal, 6)
        .frame(height: KidPixChrome.menuHeight, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .contentShape(Rectangle())
        .onTapGesture {
            openMenuID = nil
        }
        .background(Color.white)
        .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
        .zIndex(20)
    }

    private var referenceToolbar: some View {
        VStack(spacing: 0) {
            Button { performSave() } label: { referenceImage("kp-m_27") }.accessibilityLabel("Save").accessibilityIdentifier("tool.save")
            ForEach(Array(tools.enumerated()), id: \.offset) { _, item in
                Button { chooseTool(item.0) } label: { referenceImage(item.1, selected: selectedTool == item.0) }.accessibilityLabel(item.2).accessibilityIdentifier(item.0 == .truck ? "tool.movingVan" : "tool.\(item.0.rawValue)")
            }
            Button { performUndo() } label: { referenceImage("kp-m_39") }.accessibilityLabel("Undo Guy").accessibilityIdentifier("tool.undo")
            Spacer(minLength: 0)
        }.frame(width: 54).background(Color.white)
    }

    private var referenceLandscapeToolbar: some View {
        HStack(spacing: 0) {
            Button { performSave() } label: { referenceImage("kp-m_27") }.accessibilityLabel("Save").accessibilityIdentifier("tool.save")
            ForEach(Array(tools.enumerated()), id: \.offset) { _, item in
                Button { chooseTool(item.0) } label: { referenceImage(item.1, selected: selectedTool == item.0) }.accessibilityLabel(item.2).accessibilityIdentifier(item.0 == .truck ? "tool.movingVan" : "tool.\(item.0.rawValue)")
            }
            Button { performUndo() } label: { referenceImage("kp-m_39") }.accessibilityLabel("Undo Guy").accessibilityIdentifier("tool.undo")
            Spacer(minLength: 0)
        }.frame(height: 50).background(Color.white).overlay(Rectangle().stroke(Color.black, lineWidth: 0.75))
    }

    private var referenceColorRail: some View {
        VStack(spacing: 0) {
            ForEach(Array(referencePaletteColors.enumerated()), id: \.offset) { index, color in
                Button { selectedColor = color; canvasView?.inkColor = UIColor(color); SoundPlayer.submenuColorClick() } label: {
                    Rectangle().fill(color).frame(width: 28, height: 22).overlay(Rectangle().stroke(Color.gray, lineWidth: 0.5))
                }.accessibilityLabel("Rail Color \(index + 1)")
            }
            Spacer(minLength: 0)
        }.frame(width: 30).background(Color.white)
    }

    private var canvasSurface: some View {
        CanvasRepresentable(
            document: document,
            color: selectedColor,
            tool: selectedTool,
            width: selectedWidth,
            pencilTexture: selectedPencilTexture,
            shapeFillEnabled: shapeFillEnabled,
            eraserVariant: selectedEraserVariant,
            brushVariant: selectedBrushVariant,
            mixerVariant: selectedMixerVariant,
            truckVariant: selectedTruckVariant,
            truckCopiesSource: truckCopiesSource,
            alphabetCharacter: selectedAlphabetCharacter,
            stampPage: stampPage,
            stampIndex: selectedStampIndex,
            spriteSheet: spriteSheetPage,
            spriteRow: spriteRow,
            spriteColumn: selectedSpriteColumn,
            pressureEnabled: pressureEnabled,
            revision: canvasRevision,
            canvasView: $canvasView
        )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
            .accessibilityLabel("Drawing canvas")
    }

    @ViewBuilder private func referenceImage(_ name: String, selected: Bool = false, side: CGFloat = KidPixChrome.optionCell) -> some View {
        if let url = KidPadResource.url(forResource: name, withExtension: "png"),
           let image = UIImage(contentsOfFile: url.path) {
            Image(uiImage: image)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .padding(max(2, side * 0.05))
                .frame(width: side, height: side)
                .background(Color.white)
                .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                .overlay(Rectangle().inset(by: 2).stroke(selected ? KidPixChrome.selectionRed : Color.clear, lineWidth: selected ? 3 : 0))
        } else {
            // ReleasePublic deliberately has no historical reference files. Keep the
            // controls discoverable and functional with clean-room text glyphs.
            Text(publicGlyph(for: name)).font(.kidPix(16, weight: .bold)).frame(width: side, height: side)
        }
    }

    @ViewBuilder private func brushOptionImage(_ brush: WackyBrushDescriptor) -> some View {
        if brush.assetName == "system-pawprint" {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Color.black)
                .frame(width: KidPixChrome.optionCell, height: KidPixChrome.optionCell)
                .background(Color.white)
                .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                .overlay(Rectangle().inset(by: 2).stroke(selectedBrushVariant == brush.id ? KidPixChrome.selectionRed : Color.clear, lineWidth: 2))
        } else {
            referenceImage(brush.assetName, selected: selectedBrushVariant == brush.id, side: KidPixChrome.optionCell)
        }
    }

    private func optionPageHeader(
        _ title: String,
        page: Int,
        pageCount: Int,
        previous: @escaping () -> Void,
        next: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 0) {
            Button(action: previous) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 26, weight: .black))
                    .frame(width: optionArrowWidth, height: KidPixChrome.optionContentHeight)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Previous \(title) page")
            .disabled(pageCount <= 1)
            .opacity(pageCount <= 1 ? 0.25 : 1)
            VStack(spacing: 1) {
                Text(title).font(.kidPix(20))
                Text("\(min(page + 1, pageCount))/\(pageCount)").font(.kidPix(15))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .frame(width: optionLabelWidth, height: KidPixChrome.optionContentHeight)
            Button(action: next) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 26, weight: .black))
                    .frame(width: optionArrowWidth, height: KidPixChrome.optionContentHeight)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Next \(title) page")
            .disabled(pageCount <= 1)
            .opacity(pageCount <= 1 ? 0.25 : 1)
        }
        .background(KidPixChrome.chromeGrey)
        .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
        .accessibilityElement(children: .contain)
    }

    private func cycleControl(
        _ title: String,
        value: String,
        previous: @escaping () -> Void,
        next: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 0) {
            Button(action: previous) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .black))
                    .frame(width: 50, height: KidPixChrome.optionContentHeight)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Previous \(title)")
            VStack(spacing: 1) {
                Text(title).font(.kidPix(17))
                Text(value).font(.kidPix(15))
            }
            .frame(width: 74, height: KidPixChrome.optionContentHeight)
            Button(action: next) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 22, weight: .black))
                    .frame(width: 50, height: KidPixChrome.optionContentHeight)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Next \(title)")
        }
        .background(Color.white)
        .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
        .accessibilityElement(children: .contain)
    }

    private func publicGlyph(for name: String) -> String {
        if name.contains("cursor-tnt") { return "TNT" }
        if name.contains("kp-m_27") { return "SAVE" }
        if name.contains("kp-m_28") { return "✎" }
        if name.contains("kp-m_29") { return "╱" }
        if name.contains("kp-m_30") { return "□" }
        if name.contains("kp-m_31") { return "○" }
        if name.contains("kp-m_32") { return "✳" }
        if name.contains("kp-m_33") { return "✦" }
        if name.contains("kp-m_34") { return "▣" }
        if name.contains("kp-m_35") { return "⌫" }
        if name.contains("kp-m_36") { return "A" }
        if name.contains("kp-m_37") { return "★" }
        if name.contains("kp-m_38") { return "▰" }
        if name.contains("kp-m_39") { return "↶" }
        if name.hasPrefix("kp-h-") { return "★" }
        return "•"
    }

    private var referencePalette: some View {
        HStack(spacing: 0) {
            Text("COLOR").font(.system(size: 11, weight: .bold)).frame(width: 54, height: 28).accessibilityIdentifier("palette.current")
            Button { palettePage = (palettePage + Self.sourcePalettePageCount - 1) % Self.sourcePalettePageCount; SoundPlayer.submenuColorClick() } label: { Text("‹").font(.system(size: 18, weight: .bold)).frame(width: 20, height: 28) }.accessibilityLabel("Previous Palette")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(referencePaletteColors.enumerated()), id: \.offset) { index, color in
                        Button { selectedColor = color; canvasView?.inkColor = UIColor(color); SoundPlayer.submenuColorClick() } label: { Rectangle().fill(color).frame(width: 28, height: 28).overlay(Rectangle().stroke(selectedColor == color ? Color.white : Color.gray, lineWidth: selectedColor == color ? 2 : 0.5)) }.accessibilityLabel("Color \(index + 1)").accessibilityIdentifier("palette.color.\(index + 1)")
                    }
                }
            }.frame(maxWidth: .infinity)
            Button { palettePage = (palettePage + 1) % Self.sourcePalettePageCount; SoundPlayer.submenuColorClick() } label: { Text("›").font(.system(size: 18, weight: .bold)).frame(width: 20, height: 28) }.accessibilityLabel("Next Palette")
            Button { startNewDrawing() } label: { Text("NEW").font(.system(size: 10, weight: .bold)).frame(width: 42, height: 28) }.accessibilityLabel("New Drawing").accessibilityHint("Starts a blank drawing and saves it locally.")
            Button { openRecentDrawing() } label: { Text("RECENT").font(.system(size: 9, weight: .bold)).frame(width: 52, height: 28) }.accessibilityLabel("Open Recent").accessibilityHint("Reopens the last autosaved drawing.")
            Button { performExport() } label: { Image(systemName: "square.and.arrow.up").frame(width: 34, height: 28) }.accessibilityLabel("Export PNG")
            if !exportMessage.isEmpty {
                Text(exportMessage)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(exportMessage == "PNG export failed" ? .red : .black)
                    .accessibilityIdentifier("export.status")
                    .task(id: exportMessage) {
                        try? await Task.sleep(nanoseconds: 1_600_000_000)
                        guard !Task.isCancelled else { return }
                        withAnimation(.linear(duration: 0.12)) { exportMessage = "" }
                    }
            }
            Button { soundEnabled.toggle(); SoundPlayer.setEnabled(soundEnabled) } label: { Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill").frame(width: 34, height: 28) }.accessibilityLabel(soundEnabled ? "Mute Sounds" : "Unmute Sounds")
            Button { pressureEnabled.toggle(); canvasView?.pressureEnabled = pressureEnabled } label: { Text(pressureEnabled ? "P+" : "P−").font(.system(size: 10, weight: .bold)).frame(width: 34, height: 28) }.accessibilityLabel(pressureEnabled ? "Pressure Sensitivity On" : "Pressure Sensitivity Off").accessibilityIdentifier("control.pressure")
            Spacer()
        }.background(Color.white).overlay(Rectangle().stroke(Color.gray, lineWidth: 0.5))
    }

    private var referencePaletteColors: [Color] {
        switch palettePage {
        case 1...6: // KiddoPaint.Colors.All: DawnBringer through CyanMagenta
            return Self.sourceAdditionalPaletteStrings[palettePage - 1].map(sourceColor)
        case 7: // KiddoPaint.Colors.Palette.Greyscale
            return Self.sourceGreyscaleValues.map { rgb(Double($0), Double($0), Double($0)) }
        default:
            return [rgb(0,0,0), rgb(255,255,255), rgb(32,32,32), rgb(64,64,64), rgb(128,128,128), rgb(192,192,192), rgb(128,0,0), rgb(255,0,0), rgb(128,128,0), rgb(255,255,1), rgb(0,64,64), rgb(0,100,0), rgb(0,128,0), rgb(0,255,0), rgb(0,128,128), rgb(128,255,255), rgb(0,0,128), rgb(0,0,255), rgb(0,64,128), rgb(0,128,255), rgb(128,0,255), rgb(128,128,255), rgb(128,0,128), rgb(255,0,255), rgb(128,0,64), rgb(255,0,128), rgb(73,61,38), rgb(136,104,67), rgb(128,64,0), rgb(255,128,64), rgb(225,135,0), rgb(255,195,30)]
        }
    }

    private func rgb(_ red: Double, _ green: Double, _ blue: Double) -> Color { Color(red: red / 255, green: green / 255, blue: blue / 255) }

    private func sourceColor(_ value: String) -> Color {
        if value.hasPrefix("#"), let number = Int(value.dropFirst(), radix: 16) {
            return rgb(Double((number >> 16) & 0xff), Double((number >> 8) & 0xff), Double(number & 0xff))
        }
        let numbers = value.filter { $0.isNumber || $0 == "," }.split(separator: ",").compactMap { Double($0) }
        guard numbers.count == 3 else { return .black }
        return rgb(numbers[0], numbers[1], numbers[2])
    }

    private func pencilWidthButton(_ index: Int, line: Bool = false) -> some View {
        let widths = [2, 4, 8, 14, 24, 40]
        return Button {
            selectedWidth = CGFloat(widths[index - 1])
            SoundPlayer.submenuOptionClick()
        } label: {
            referenceImage(
                line ? "pw\(index)" : "tool-submenu-pencil-size-\(index)",
                selected: Int(selectedWidth) == widths[index - 1],
                side: KidPixChrome.optionCell
            )
        }
        .accessibilityLabel("\(line ? "Line" : "Pencil") Size \(index)")
        .accessibilityIdentifier("\(line ? "line" : "pencil").size.\(index)")
    }

    private func pencilTextureButton(_ texture: PencilTexture) -> some View {
        Button {
            selectedPencilTexture = texture
            document.setPencilTexture(texture)
            if selectedTool == .rectangle || selectedTool == .oval {
                shapeFillEnabled = true
                document.setShapeFillEnabled(true)
            }
            SoundPlayer.submenuOptionClick()
        } label: {
            // The pinned source's makeIcon helper shows a complete 30×30 sample
            // inside a 50×50 cell. Scaling the raw 2 to 8 pixel texture tile made
            // partial fills look like two oversized blocks stuck together.
            Image(uiImage: document.pencilTexturePreview(texture, shape: selectedTool))
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: KidPixChrome.optionCell, height: KidPixChrome.optionCell)
                .background(Color.white)
                .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                .overlay(Rectangle().inset(by: 2).stroke(
                    selectedPencilTexture == texture && (selectedTool == .line || selectedTool == .fill || shapeFillEnabled || selectedTool == .pencil)
                        ? KidPixChrome.selectionRed : Color.clear,
                    lineWidth: 2
                ))
        }
        .accessibilityLabel("\(selectedTool.rawValue.capitalized) \(texture.displayName)")
        .accessibilityIdentifier("\(selectedTool.rawValue).texture.\(texture.rawValue)")
    }

    @ViewBuilder private var optionStrip: some View {
        Group {
            if selectedTool == .pencil {
                let textures = Array(PencilTexture.allCases)
                let texturePages = optionPageCount(itemCount: textures.count)
                let pageCount = 1 + texturePages
                let page = min(pencilOptionPage, pageCount - 1)
                HStack(spacing: 0) {
                    optionPageHeader(page == 0 ? "SIZE" : "PATTERN", page: page, pageCount: pageCount) {
                        pencilOptionPage = (page + pageCount - 1) % pageCount
                    } next: {
                        pencilOptionPage = (page + 1) % pageCount
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 2) {
                            if page == 0 {
                                ForEach(1...6, id: \.self) { pencilWidthButton($0) }
                            } else {
                                ForEach(optionPageSlice(textures, page: page - 1), id: \.self) { pencilTextureButton($0) }
                            }
                        }
                    }
                }
            } else if selectedTool == .line {
                let textures = Array(PencilTexture.allCases)
                let texturePages = optionPageCount(itemCount: textures.count)
                let pageCount = 1 + texturePages
                let page = min(lineOptionPage, pageCount - 1)
                HStack(spacing: 0) {
                    optionPageHeader(page == 0 ? "LINE SIZE" : "LINE", page: page, pageCount: pageCount) {
                        lineOptionPage = (page + pageCount - 1) % pageCount
                    } next: {
                        lineOptionPage = (page + 1) % pageCount
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 2) {
                            if page == 0 {
                                ForEach(1...6, id: \.self) { pencilWidthButton($0, line: true) }
                            } else {
                                ForEach(optionPageSlice(textures, page: page - 1), id: \.self) { pencilTextureButton($0) }
                            }
                        }
                    }
                }
            } else if [.rectangle, .oval, .fill].contains(selectedTool) {
                let textures = Array(PencilTexture.allCases)
                let pageCount = optionPageCount(itemCount: textures.count)
                let page = min(shapeOptionPage, pageCount - 1)
                let title = selectedTool == .rectangle ? "SQUARE" : (selectedTool == .oval ? "CIRCLE" : "FILL")
                HStack(spacing: 0) {
                    optionPageHeader(title, page: page, pageCount: pageCount) {
                        shapeOptionPage = (page + pageCount - 1) % pageCount
                    } next: {
                        shapeOptionPage = (page + 1) % pageCount
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 2) {
                            if page == 0 && (selectedTool == .rectangle || selectedTool == .oval) {
                                Button {
                                    shapeFillEnabled = false
                                    document.setShapeFillEnabled(false)
                                    SoundPlayer.submenuOptionClick()
                                } label: {
                                    Image(uiImage: document.pencilTexturePreview(nil, shape: selectedTool))
                                        .resizable()
                                        .interpolation(.none)
                                        .scaledToFit()
                                        .frame(width: KidPixChrome.optionCell, height: KidPixChrome.optionCell)
                                        .background(Color.white)
                                        .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                        .overlay(Rectangle().inset(by: 2).stroke(shapeFillEnabled ? Color.clear : KidPixChrome.selectionRed, lineWidth: 2))
                                }
                                .accessibilityLabel("\(title.capitalized) No Fill")
                                .accessibilityIdentifier("\(selectedTool.rawValue).texture.none")
                            }
                            ForEach(optionPageSlice(textures, page: page), id: \.self) { pencilTextureButton($0) }
                        }
                    }
                }
            } else if selectedTool == .eraser {
                let items = Array(eraserOptions.enumerated())
                let pageCount = optionPageCount(itemCount: items.count)
                let page = min(eraserOptionPage, pageCount - 1)
                HStack(spacing: 0) {
                    optionPageHeader("ERASER", page: page, pageCount: pageCount) {
                        eraserOptionPage = (page + pageCount - 1) % pageCount
                    } next: {
                        eraserOptionPage = (page + 1) % pageCount
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 2) {
                            ForEach(optionPageSlice(items, page: page), id: \.offset) { index, option in
                                Button {
                                    selectedEraserVariant = index
                                    selectedWidth = option.width
                                    document.setEraserVariant(index)
                                    SoundPlayer.setEraserVariant(index)
                                    SoundPlayer.submenuOptionClick()
                                } label: {
                                    referenceImage("tool-submenu-eraser-\(option.asset)", selected: selectedEraserVariant == index)
                                }
                                .accessibilityLabel(option.name)
                                .accessibilityIdentifier("eraser.variant.\(index + 1)")
                            }
                        }
                    }
                }
            } else if selectedTool == .brush {
                let brushes = RasterDocument.wackyBrushes
                let pageCount = optionPageCount(itemCount: brushes.count)
                let page = min(brushOptionPage, pageCount - 1)
                HStack(spacing: 0) {
                    optionPageHeader("BRUSH", page: page, pageCount: pageCount) {
                        brushOptionPage = (page + pageCount - 1) % pageCount
                    } next: {
                        brushOptionPage = (page + 1) % pageCount
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 2) {
                            ForEach(optionPageSlice(brushes, page: page)) { brush in
                                Button {
                                    selectedBrushVariant = brush.id
                                    document.setBrushVariant(brush.id)
                                    SoundPlayer.setBrushVariant(brush.id)
                                    canvasView?.refreshFromDocument()
                                    SoundPlayer.submenuOptionClick()
                                    exportMessage = ""
                                } label: { brushOptionImage(brush) }
                                .kidPixHoverHighlight()
                                .accessibilityLabel(brush.name)
                                .accessibilityIdentifier("brush.variant.\(brush.id + 1)")
                            }
                        }
                    }
                }
            } else if selectedTool == .mixer {
                let names = ["Invert", "Raindrops", "Checkerboard", "Wallpaper", "Venetian Blinds", "The Outliner", "Shadow Boxes", "Zoom In", "Broken Glass", "Picture In A Picture", "The Highlighter", "Pattern Maker", "Wrap Around", "Snowflakes"]
                let indices = Array(names.indices)
                let pageCount = optionPageCount(itemCount: indices.count)
                let page = min(mixerOptionPage, pageCount - 1)
                HStack(spacing: 0) {
                    optionPageHeader("MIXER", page: page, pageCount: pageCount) {
                        mixerOptionPage = (page + pageCount - 1) % pageCount
                    } next: {
                        mixerOptionPage = (page + 1) % pageCount
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 2) {
                            ForEach(optionPageSlice(indices, page: page), id: \.self) { index in
                                Button {
                                    selectedMixerVariant = index
                                    document.setMixerVariant(index)
                                    SoundPlayer.setMixerVariant(index)
                                    SoundPlayer.submenuOptionClick()
                                } label: {
                                    referenceImage("tool-submenu-wacky-mixer-\(164 + index)", selected: selectedMixerVariant == index)
                                }
                                .accessibilityLabel(names[index])
                                .accessibilityIdentifier("mixer.variant.\(index + 1)")
                            }
                        }
                    }
                }
            } else if selectedTool == .alphabet {
                HStack(spacing: 0) {
                    optionPageHeader(alphabetPage == 0 ? "ABC" : "SYMBOLS", page: alphabetPage, pageCount: 2) {
                        selectAlphabetPage(offset: -1)
                    } next: {
                        selectAlphabetPage(offset: 1)
                    }
                    .accessibilityIdentifier("alphabet.page.\(alphabetPage + 1)")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(alphabetCharacters, id: \.self) { character in
                                Button {
                                    selectedAlphabetCharacter = character
                                    document.setAlphabetCharacter(character)
                                    SoundPlayer.setAlphabetCharacter(character)
                                    SoundPlayer.submenuOptionClick()
                                } label: {
                                    Text(String(character)).font(.kidPix(28))
                                        .frame(width: 48, height: KidPixChrome.optionContentHeight)
                                        .background(Color.white)
                                        .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                        .overlay(Rectangle().inset(by: 2).stroke(selectedAlphabetCharacter == character ? KidPixChrome.selectionRed : Color.clear, lineWidth: 2))
                                }
                                .accessibilityLabel(character.isLetter ? "Letter \(String(character))" : "Character \(String(character))")
                                .accessibilityIdentifier("alphabet.character.\(String(character))")
                            }
                        }
                    }
                }
            } else if selectedTool == .stamp {
                let modeTitle = stampPage < 2 ? "STAMPS" : (stampPage == 2 ? "STICKERS" : "SPRITES")
                HStack(spacing: 0) {
                    optionPageHeader(modeTitle, page: stampPage, pageCount: 4) {
                        selectStampPage(offset: -1)
                    } next: {
                        selectStampPage(offset: 1)
                    }
                    .accessibilityIdentifier("stamp.mode")
                    if stampPage < 3 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 2) {
                                ForEach(Array(stampNames.enumerated()).filter { $0.offset / 6 == stampPage }, id: \.offset) { index, name in
                                    Button {
                                        selectedStampIndex = index
                                        document.setStampIndex(index)
                                        canvasView?.refreshFromDocument()
                                        SoundPlayer.submenuOptionClick()
                                    } label: {
                                        referenceImage(name, selected: selectedStampIndex == index)
                                    }
                                    .accessibilityLabel(stampPage == 2 ? "Sticker \(index - 11)" : "Stamp \(index + 1)")
                                    .accessibilityIdentifier(stampPage == 2 ? "sticker.\(index - 11)" : "stamp.\(index + 1)")
                                }
                            }
                        }
                    } else {
                        cycleControl("PACK", value: "\(spriteSheetPage + 1)/10") {
                            selectSpritePack(offset: -1)
                        } next: {
                            selectSpritePack(offset: 1)
                        }
                        .accessibilityIdentifier("sprite.pack.control")
                        cycleControl("ROW", value: "\(spriteRow + 1)/8") {
                            selectSpriteRow(offset: -1)
                        } next: {
                            selectSpriteRow(offset: 1)
                        }
                        .accessibilityIdentifier("sprite.row.control")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 2) {
                                ForEach(0..<14, id: \.self) { column in
                                    Button {
                                        selectedSpriteColumn = column
                                        document.setSpriteSelection(sheet: spriteSheetPage, row: spriteRow, column: column)
                                        canvasView?.refreshFromDocument()
                                        SoundPlayer.submenuOptionClick()
                                    } label: {
                                        Image(uiImage: document.spritePreview(sheet: spriteSheetPage, row: spriteRow, column: column))
                                            .resizable().interpolation(.none)
                                            .frame(width: KidPixChrome.optionCell, height: KidPixChrome.optionCell)
                                            .background(Color.white)
                                            .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                            .overlay(Rectangle().inset(by: 2).stroke(selectedSpriteColumn == column ? KidPixChrome.selectionRed : Color.clear, lineWidth: 2))
                                    }
                                    .accessibilityLabel("Sprite \(column + 1)")
                                    .accessibilityIdentifier("sprite.\(column + 1)")
                                }
                            }
                        }
                    }
                }
            } else if selectedTool == .truck {
                let indices = Array(0..<14)
                let pageCount = optionPageCount(itemCount: indices.count)
                let page = min(truckOptionPage, pageCount - 1)
                HStack(spacing: 0) {
                    optionPageHeader("VAN", page: page, pageCount: pageCount) {
                        truckOptionPage = (page + pageCount - 1) % pageCount
                    } next: {
                        truckOptionPage = (page + 1) % pageCount
                    }
                    HStack(spacing: 0) {
                        Button {
                            truckCopiesSource = false
                            document.setTruckCopiesSource(false)
                            SoundPlayer.submenuOptionClick()
                        } label: {
                            Text("MOVE").font(.kidPix(18)).frame(width: 64, height: KidPixChrome.optionContentHeight)
                                .background(Color.white)
                                .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                .overlay(Rectangle().inset(by: 2).stroke(truckCopiesSource ? Color.clear : KidPixChrome.selectionRed, lineWidth: 2))
                        }
                        .accessibilityLabel("Truck Move Mode")
                        .accessibilityIdentifier("truck.mode.move")
                        Button {
                            truckCopiesSource = true
                            document.setTruckCopiesSource(true)
                            SoundPlayer.submenuOptionClick()
                        } label: {
                            Text("COPY").font(.kidPix(18)).frame(width: 64, height: KidPixChrome.optionContentHeight)
                                .background(Color.white)
                                .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                .overlay(Rectangle().inset(by: 2).stroke(truckCopiesSource ? KidPixChrome.selectionRed : Color.clear, lineWidth: 2))
                        }
                        .accessibilityLabel("Truck Copy Mode")
                        .accessibilityIdentifier("truck.mode.copy")
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 2) {
                            ForEach(optionPageSlice(indices, page: page), id: \.self) { index in
                                Button {
                                    if Self.isImplementedTruckOption(index) {
                                        selectedTruckVariant = index
                                        document.setTruckVariant(index)
                                        SoundPlayer.submenuOptionClick()
                                    } else {
                                        // Exact pinned-source behavior: the final magnet tile
                                        // is a visible placeholder whose handler only plays
                                        // `Sounds.unimpl()`; it does not select a cut size.
                                        SoundPlayer.unimplemented()
                                    }
                                } label: {
                                    referenceImage(
                                        "tool-submenu-truck-\(192 + index)",
                                        selected: Self.isImplementedTruckOption(index) && selectedTruckVariant == index
                                    )
                                }
                                .accessibilityLabel(Self.isImplementedTruckOption(index) ? "Truck Size \(index + 1)" : "Magnet")
                                .accessibilityHint(Self.isImplementedTruckOption(index) ? "" : "Not implemented in the original Kid Pix source")
                                .accessibilityIdentifier("truck.size.\(index + 1)")
                            }
                        }
                    }
                }
            } else {
                // TNT has no choices in the original interface, but the submenu
                // band remains present. Keeping a real transparent view here
                // prevents the canvas from jumping when a no-options tool is
                // selected after Stamp, Brush, Fill, or another populated strip.
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityHidden(true)
            }
        }
        .frame(height: KidPixChrome.optionHeight)
        .background(Color.white)
        .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
        .buttonStyle(.plain)
        .accessibilityIdentifier("option.strip.\(selectedTool.rawValue)")
    }

    private var alphabetCharacters: [Character] {
        alphabetPage == 0 ? Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ") : Array("!?0123456789+-<>$%^&@*()~|")
    }

    private var eraserOptions: [(asset: Int, name: String, width: CGFloat)] {
        [
            (178, "Square Eraser 20", 20),
            (179, "Circle Eraser 10", 10),
            (180, "Square Eraser 10", 10),
            (181, "Square Eraser 2", 2),
            (182, "Firecracker", 20),
            (183, "Hidden Pictures", 32),
            (184, "White Circles", 25),
            (185, "Slip-Sliding Away", 20),
            (186, "#$%!*!!", 20),
            (187, "Fade Away", 20),
            (189, "Black Hole", 20),
            (190, "Count Down", 20)
        ]
    }
}

// Classic Mac System 6/7 menu chrome: flat white panel, hard black border,
// square corners, Chicago-style monospaced type. Matches the original Kid Pix
// menu strip look on the reference site.
struct ClassicMacMenuItem: Identifiable {
    enum Kind {
        case action(String, () -> Void)
        case toggle(String, Bool, (Bool) -> Void)
    }
    let id: String
    let kind: Kind

    static func action(_ title: String, id: String? = nil, _ handler: @escaping () -> Void) -> ClassicMacMenuItem {
        .init(id: id ?? title, kind: .action(title, handler))
    }
    static func toggle(_ title: String, isOn: Bool, _ handler: @escaping (Bool) -> Void) -> ClassicMacMenuItem {
        .init(id: title, kind: .toggle(title, isOn, handler))
    }
}

struct ClassicMacMenu: View {
    @Binding var openMenuID: String?
    let title: String

    var body: some View {
        let isOpen = openMenuID == title
        Button(action: {
            openMenuID = isOpen ? nil : title
            SoundPlayer.menuClick()
        }) {
            Text(title)
                .font(.kidPix(24, weight: .bold))
                .foregroundStyle(isOpen ? Color.white : Color.black)
                .padding(.horizontal, 10)
                .frame(height: KidPixChrome.menuHeight - 4)
                .background(isOpen ? Color.black : Color.clear)
        }
        .buttonStyle(.plain)
        .kidPixHoverHighlight()
    }
}

private struct KidPixHoverHighlight: ViewModifier {
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .background(isHovering ? Color.black.opacity(0.08) : Color.clear)
            .overlay(Rectangle().stroke(isHovering ? Color.black : Color.clear, lineWidth: 1))
            .contentShape(Rectangle())
            .onHover { isHovering = $0 }
            .hoverEffect(.highlight)
    }
}

private extension View {
    func kidPixHoverHighlight() -> some View { modifier(KidPixHoverHighlight()) }
}

// Classic Mac System 6/7 menu chrome: flat white panel, hard black border,
// square corners, Chicago-style monospaced type. Matches the original Kid Pix
// menu strip look on the reference site.

private struct CanvasRepresentable: UIViewRepresentable {
    let document: RasterDocument; let color: Color; let tool: CanvasTool; let width: CGFloat; let pencilTexture: PencilTexture; let shapeFillEnabled: Bool; let eraserVariant: Int; let brushVariant: Int; let mixerVariant: Int; let truckVariant: Int; let truckCopiesSource: Bool; let alphabetCharacter: Character
    let stampPage: Int; let stampIndex: Int; let spriteSheet: Int; let spriteRow: Int; let spriteColumn: Int; let pressureEnabled: Bool; let revision: Int
    @Binding var canvasView: RasterCanvasView?

    final class Coordinator {
        var appliedRevision = -1
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> LetterboxedCanvasHost {
        let host = LetterboxedCanvasHost(document: document)
        apply(to: host.canvasView)
        context.coordinator.appliedRevision = revision
        DispatchQueue.main.async { canvasView = host.canvasView }
        return host
    }
    func updateUIView(_ uiView: LetterboxedCanvasHost, context: Context) {
        apply(to: uiView.canvasView)
        if context.coordinator.appliedRevision != revision {
            uiView.canvasView.refreshFromDocument()
            context.coordinator.appliedRevision = revision
        }
        uiView.setNeedsLayout()
        uiView.canvasView.setNeedsDisplay()
        DispatchQueue.main.async { canvasView = uiView.canvasView }
    }
    private func apply(to view: RasterCanvasView) {
        view.inkColor = UIColor(color)
        view.activeTool = tool
        view.inkWidth = width
        view.pencilTexture = pencilTexture
        view.shapeFillEnabled = shapeFillEnabled
        view.eraserVariant = eraserVariant
        view.truckVariant = truckVariant
        view.truckCopiesSource = truckCopiesSource
        view.brushVariant = brushVariant
        view.mixerVariant = mixerVariant
        view.alphabetCharacter = alphabetCharacter
        view.stampPage = stampPage
        view.stampIndex = stampIndex
        view.spriteSheet = spriteSheet
        view.spriteRow = spriteRow
        view.spriteColumn = spriteColumn
        view.pressureEnabled = pressureEnabled
        view.synchronizeDocumentOptions()
        SoundPlayer.setBrushVariant(brushVariant)
        SoundPlayer.setMixerVariant(mixerVariant)
        SoundPlayer.setEraserVariant(eraserVariant)
        SoundPlayer.setAlphabetCharacter(alphabetCharacter)
    }
}
