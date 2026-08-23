import SwiftUI
import UIKit
import CoreText

private enum KidPixFontRegistrar {
    static func registerBundledFont() {
        guard let url = Bundle.main.url(forResource: "ChiKareGo2", withExtension: "ttf") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}

#if targetEnvironment(macCatalyst)
private struct CatalystWindowChrome: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        DispatchQueue.main.async { configure(view) }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async { configure(uiView) }
    }

    private func configure(_ view: UIView) {
        guard let titlebar = view.window?.windowScene?.titlebar else { return }
        titlebar.toolbar = nil
        titlebar.titleVisibility = .visible
        titlebar.separatorStyle = .none
    }
}
#endif

private struct KidPadRootView: View {
    @StateObject private var classicPack = ClassicAssetPackManager()

    var body: some View {
        Group {
            if classicPack.phase == .ready {
                WorkspaceView()
            } else {
                ClassicAssetInstallView(manager: classicPack)
            }
        }
        #if targetEnvironment(macCatalyst)
        .background(CatalystWindowChrome().frame(width: 0, height: 0))
        #endif
    }
}

@main
struct KidPadApp: App {
    init() {
        KidPixFontRegistrar.registerBundledFont()
        if CommandLine.arguments.contains("--ui-test") || CommandLine.arguments.contains("--ui-test-mode") {
            UserDefaults.standard.set(true, forKey: "KidPad.soundEnabled")
        }
        if CommandLine.arguments.contains("--reset-document") {
            let testStorage = FileManager.default.temporaryDirectory
                .appendingPathComponent("KidPadUITestState-\(ProcessInfo.processInfo.processIdentifier)", isDirectory: true)
            try? FileManager.default.removeItem(at: testStorage)
            try? FileManager.default.createDirectory(at: testStorage, withIntermediateDirectories: true)
            RasterDocument.persistenceRootOverride = testStorage
            UserDefaults.standard.set(CommandLine.arguments.contains("--left-handed-mode"), forKey: "KidPad.leftHandedMode")
        } else if CommandLine.arguments.contains("--left-handed-mode") {
            UserDefaults.standard.set(true, forKey: "KidPad.leftHandedMode")
        }
    }

    var body: some Scene {
        WindowGroup {
            if CommandLine.arguments.contains("--reference-web") {
                WebKidPixView()
            } else {
                KidPadRootView()
            }
        }
    }
}
