import Combine
import CryptoKit
import Foundation
import SwiftUI

struct ClassicAssetDescriptor: Hashable, Sendable {
    let localName: String
    let sourcePath: String

    var sourceURL: URL {
        ClassicAssetCatalog.rawBaseURL.appending(path: sourcePath)
    }
}

enum ClassicAssetCatalog {
    static let sourceRepository = URL(string: "https://github.com/vikrum/kidpix")!
    static let sourceCommit = "99c67f3427d229f7db60b03dcf19df4d8c2a8ecf"
    static let sourceLicense = URL(string: "https://github.com/vikrum/kidpix/blob/\(sourceCommit)/LICENSE")!
    static let expectedCombinedSHA256 = "95c89533074aa082e3030fac622997e1fb48c701ef34da2e956c154ff4c3be0f"
    static let rawBaseURL = URL(string: "https://raw.githubusercontent.com/vikrum/kidpix/\(sourceCommit)/")!

    static let assets: [ClassicAssetDescriptor] = {
        let imageNames =
            (27...39).map { "kp-m_\($0).png" } +
            ["kidpix.png", "kidpix-guy.png"] +
            ["bear", "bison", "corn", "eye", "fox", "horse", "hummingbird", "ladybug", "lion", "magnet", "moth", "octopus"]
                .map { "kp-h-\($0).png" } +
            (1...6).map { "tool-submenu-pencil-size-\($0).png" } +
            (70...97).map { "tool-menu-wacky-brush-\($0).png" } +
            ["cursor-tnt-0.png"] +
            (164...177).map { "tool-submenu-wacky-mixer-\($0).png" } +
            (192...205).map { "tool-submenu-truck-\($0).png" } +
            ["kidpix-spritesheet-0.png", "kidpix-spritesheet-0b.png"] +
            (1...8).map { "kidpix-spritesheet-\($0).png" } +
            (1...6).map { "pw\($0).png" } +
            (178...190).map { "tool-submenu-eraser-\($0).png" } +
            (1...6).map { "kp-sticker-\($0).png" }

        let spokenNames = [
            "alpha-a-WAVSOUND.R_0007d8f2.wav",
            "alpha-b-WAVSOUND.R_0007ee1f.wav",
            "alpha-c-WAVSOUND.R_000803fc.wav",
            "alpha-d-WAVSOUND.R_000815df.wav",
            "alpha-e-WAVSOUND.R_00082fcc.wav",
            "alpha-f-WAVSOUND.R_00084629.wav",
            "alpha-g-WAVSOUND.R_000853d0.wav",
            "alpha-h-WAVSOUND.R_00086213.wav",
            "alpha-i-WAVSOUND.R_00087a00.wav",
            "alpha-j-WAVSOUND.R_00088ced.wav",
            "alpha-k-WAVSOUND.R_0008a72e.wav",
            "alpha-l-WAVSOUND.R_0008bda3.wav",
            "alpha-m-WAVSOUND.R_0008d0f8.wav",
            "alpha-n-WAVSOUND.R_0008e695.wav",
            "alpha-o-WAVSOUND.R_0008fcaa.wav",
            "alpha-p-WAVSOUND.R_00091bdb.wav",
            "alpha-q-WAVSOUND.R_00092aee.wav",
            "alpha-r-WAVSOUND.R_0009639f.wav",
            "alpha-s-WAVSOUND.R_00097948.wav",
            "alpha-t-WAVSOUND.R_00099085.wav",
            "alpha-u-WAVSOUND.R_0009a406.wav",
            "alpha-v-WAVSOUND.R_0009bbcf.wav",
            "alpha-w-WAVSOUND.R_0009d8cc.wav",
            "alpha-x-WAVSOUND.R_0009ff1d.wav",
            "alpha-y-WAVSOUND.R_000a177a.wav",
            "alpha-z-WAVSOUND.R_000a2fe7.wav",
            "number-0-WAVSOUND.R_000a7832.wav",
            "number-1-WAVSOUND.R_000a9f1f.wav",
            "number-2-WAVSOUND.R_000ab58c.wav",
            "number-3-WAVSOUND.R_000aca17.wav",
            "number-4-WAVSOUND.R_000ae7a4.wav",
            "number-5-WAVSOUND.R_000afbb1.wav",
            "number-6-WAVSOUND.R_000b205a.wav",
            "number-7-WAVSOUND.R_000b43e7.wav",
            "number-8-WAVSOUND.002_000555ac.wav",
            "number-9-WAVSOUND.R_000b7db1.wav",
            "number-ampersand-WAVSOUND.R_000be96f.wav",
            "number-eclamation-WAVSOUND.R_000a5774.wav",
            "number-equals-WAVSOUND.R_000bce22.wav",
            "number-minus-WAVSOUND.R_000bb0e5.wav",
            "number-plus-WAVSOUND.R_000b9a58.wav",
            "number-question-mark-WAVSOUND.R_000a661d.wav",
        ]

        let soundNames = [
            "bubble-pop-2WAVSOUND.R_0004edd3.wav",
            "bubble-pop-3WAVSOUND.R_0004fccd.wav",
            "bubble-pop-4WAVSOUND.R_0004f480.wav",
            "bubble-pop-WAVSOUND.R_000031f6.wav",
            "bubble-pop-WAVSOUND.R_00050452.wav",
            "chord.wav",
            "electric-mixer-inverter-rolling-sound-WAVSOUND.R_0001fcfa.wav",
            "electric-mixer-pip-drum-crash-1WAVSOUND.R_0002d96e.wav",
            "electric-mixer-shadow-boxes-WAVSOUND.R_0002a07a.wav",
            "electric-mixer-venetian-WAVSOUND.R_0001df56.wav",
            "electric-mixer-wallpaper-jitter-boingo-WAVSOUND.R_00024fcc.wav",
            "eraser-tool-fade-2WAVSOUND.R_0002f58b.wav",
            "flood0.wav",
            "kidpix-eraser-doorbell-ding-dong.wav",
            "kidpix-eraser-doorbell-door-creak.wav",
            "kidpix-eraser-doorbell-wwoooowwww.wav",
            "kidpix-menu-click-main-tools.wav",
            "kidpix-menu-click-submenu-color.wav",
            "kidpix-menu-click-submenu-options.wav",
            "kidpix-submenu-brush-bubbly.wav",
            "kidpix-submenu-brush-cards.wav",
            "kidpix-submenu-brush-dots.wav",
            "kidpix-submenu-brush-fuzzer.wav",
            "kidpix-submenu-brush-guilloche.wav",
            "kidpix-submenu-brush-inverter.wav",
            "kidpix-submenu-brush-kaliediscope.wav",
            "kidpix-submenu-brush-leaky-pen.wav",
            "kidpix-submenu-brush-northern.wav",
            "kidpix-submenu-brush-owl.wav",
            "kidpix-submenu-brush-pies.wav",
            "kidpix-submenu-brush-pines.wav",
            "kidpix-submenu-brush-prints.wav",
            "kidpix-submenu-brush-rollingdots.wav",
            "kidpix-submenu-brush-shapes.wav",
            "kidpix-submenu-brush-spraypaint.wav",
            "kidpix-submenu-brush-stars.wav",
            "kidpix-submenu-brush-tree.wav",
            "kidpix-submenu-brush-twirly.wav",
            "kidpix-submenu-brush-xos.wav",
            "kidpix-submenu-brush-xy-during.wav",
            "kidpix-submenu-brush-xy-end.wav",
            "kidpix-submenu-brush-xy-start.wav",
            "kidpix-submenu-brush-zigzag.wav",
            "kidpix-submenu-brush-zoom.wav",
            "kidpix-tool-box-during-approx.wav",
            "kidpix-tool-circle-during-approx.wav",
            "kidpix-tool-eraser-tnt-explosion.wav",
            "kidpix-tool-line-during.wav",
            "kidpix-tool-line-end.wav",
            "kidpix-tool-line-start.wav",
            "kidpix-tool-pencil.wav",
            "kidpix-truck-skid.wav",
            "kidpix-truck-truckin-go.wav",
            "kidpix-truck-truckin.wav",
            "oops0.wav",
            "oops1.wav",
            "oops2.wav",
            "oops3.wav",
            "stamp0.wav",
            "western-gun-shot-twirl-WAVSOUND.R_0005ed70.wav",
        ]

        let images = imageNames.map { ClassicAssetDescriptor(localName: $0, sourcePath: "img/\($0)") }
        let spoken = spokenNames.map { ClassicAssetDescriptor(localName: $0, sourcePath: "snd/english/\($0)") }
        let sounds = soundNames.map { ClassicAssetDescriptor(localName: $0, sourcePath: "snd/\($0)") }
        let splash = ClassicAssetDescriptor(localName: "jskidpix-splash.png", sourcePath: "static/splash.png")
        return (images + spoken + sounds + [splash]).sorted { $0.localName < $1.localName }
    }()

    static func combinedSHA256(for files: [String: Data]) -> String {
        var hasher = SHA256()
        for asset in assets {
            guard let data = files[asset.localName] else { return "" }
            hasher.update(data: Data(asset.localName.utf8))
            hasher.update(data: Data([0]))
            hasher.update(data: data)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }
}

enum KidPadResource {
    static nonisolated(unsafe) var classicRootOverrideForTesting: URL?
    static nonisolated(unsafe) var installationRootOverrideForTesting: URL?

    static func url(forResource name: String, withExtension fileExtension: String?) -> URL? {
        let fileName = fileExtension.map { "\(name).\($0)" } ?? name
        if let root = activeClassicRoot {
            let candidate = root.appending(path: fileName)
            if FileManager.default.fileExists(atPath: candidate.path) { return candidate }
        }
        return Bundle.main.url(forResource: name, withExtension: fileExtension)
    }

    static var activeClassicRoot: URL? {
        if let classicRootOverrideForTesting { return classicRootOverrideForTesting }
        guard let root = try? installedRootURL() else { return nil }
        let marker = root.appending(path: "pack.sha256")
        guard let value = try? String(contentsOf: marker, encoding: .utf8),
              value.trimmingCharacters(in: .whitespacesAndNewlines) == ClassicAssetCatalog.expectedCombinedSHA256
        else { return nil }
        guard ClassicAssetCatalog.assets.allSatisfy({ asset in
            FileManager.default.fileExists(atPath: root.appending(path: asset.localName).path)
        }) else { return nil }
        return root
    }

    static func installedRootURL() throws -> URL {
        if let installationRootOverrideForTesting { return installationRootOverrideForTesting }
        let support = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return support
            .appending(path: "KidPad", directoryHint: .isDirectory)
            .appending(path: "ClassicAssetPack", directoryHint: .isDirectory)
            .appending(path: ClassicAssetCatalog.expectedCombinedSHA256, directoryHint: .isDirectory)
    }
}

enum ClassicAssetPackError: LocalizedError {
    case invalidResponse(String)
    case unexpectedFileSize(String)
    case verificationFailed

    var errorDescription: String? {
        switch self {
        case .invalidResponse(let name): "GitHub did not return \(name). Please try again."
        case .unexpectedFileSize(let name): "The downloaded \(name) file was invalid."
        case .verificationFailed: "The classic pack did not match the pinned JSKidPix version."
        }
    }
}

@MainActor
final class ClassicAssetPackManager: ObservableObject {
    enum Phase: Equatable {
        case awaitingConsent
        case downloading
        case ready
        case failed(String)
    }

    @Published private(set) var phase: Phase
    @Published private(set) var progress = 0.0
    private let session: URLSession

    init(arguments: [String] = CommandLine.arguments, session: URLSession = .shared) {
        self.session = session
        if arguments.contains("--reset-classic-pack"), let root = try? KidPadResource.installedRootURL() {
            try? FileManager.default.removeItem(at: root)
        }
        if arguments.contains("--ui-test") || arguments.contains("--reset-document") || arguments.contains("--skip-classic-pack") || KidPadResource.activeClassicRoot != nil {
            phase = .ready
        } else {
            phase = .awaitingConsent
        }
    }

    func install() {
        guard phase != .downloading else { return }
        phase = .downloading
        progress = 0

        Task {
            do {
                let downloaded = try await downloadAssets()
                guard ClassicAssetCatalog.combinedSHA256(for: downloaded) == ClassicAssetCatalog.expectedCombinedSHA256 else {
                    throw ClassicAssetPackError.verificationFailed
                }
                try installAtomically(downloaded)
                progress = 1
                phase = .ready
            } catch {
                phase = .failed(error.localizedDescription)
            }
        }
    }

    private func downloadAssets() async throws -> [String: Data] {
        let assets = ClassicAssetCatalog.assets
        let session = session
        var downloaded: [String: Data] = [:]
        let batchSize = 10

        for start in stride(from: 0, to: assets.count, by: batchSize) {
            let end = min(start + batchSize, assets.count)
            let batch = Array(assets[start..<end])
            let results = try await withThrowingTaskGroup(of: (String, Data).self) { group in
                for asset in batch {
                    group.addTask {
                        var request = URLRequest(url: asset.sourceURL)
                        request.timeoutInterval = 30
                        request.cachePolicy = .reloadIgnoringLocalCacheData
                        let (data, response) = try await session.data(for: request)
                        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                            throw ClassicAssetPackError.invalidResponse(asset.localName)
                        }
                        guard !data.isEmpty, data.count <= 5_000_000 else {
                            throw ClassicAssetPackError.unexpectedFileSize(asset.localName)
                        }
                        return (asset.localName, data)
                    }
                }

                var values: [(String, Data)] = []
                for try await value in group { values.append(value) }
                return values
            }

            for (name, data) in results { downloaded[name] = data }
            progress = Double(downloaded.count) / Double(assets.count)
        }
        return downloaded
    }

    private func installAtomically(_ files: [String: Data]) throws {
        let fileManager = FileManager.default
        let destination = try KidPadResource.installedRootURL()
        let parent = destination.deletingLastPathComponent()
        try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)
        let staging = parent.appending(path: ".installing-\(UUID().uuidString)", directoryHint: .isDirectory)
        try fileManager.createDirectory(at: staging, withIntermediateDirectories: true)

        do {
            for asset in ClassicAssetCatalog.assets {
                guard let data = files[asset.localName] else { throw ClassicAssetPackError.verificationFailed }
                try data.write(to: staging.appending(path: asset.localName), options: .atomic)
            }
            try Data(ClassicAssetCatalog.expectedCombinedSHA256.utf8)
                .write(to: staging.appending(path: "pack.sha256"), options: .atomic)
            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }
            try fileManager.moveItem(at: staging, to: destination)
        } catch {
            try? fileManager.removeItem(at: staging)
            throw error
        }
    }
}

struct ClassicAssetInstallView: View {
    @ObservedObject var manager: ClassicAssetPackManager

    var body: some View {
        ZStack {
            Color(red: 0.69, green: 0.75, blue: 0.91).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack(spacing: 6) {
                    ForEach([Color.red, .yellow, .green, .cyan, .blue, .purple], id: \.self) { color in
                        color.frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 12)
                .overlay(Rectangle().stroke(.black, lineWidth: 2))

                VStack(spacing: 18) {
                    Text("KIDPAD SETUP")
                        .font(.custom("ChiKareGo2", fixedSize: 44))
                        .foregroundStyle(.black)

                    Text("One quick download, then you can draw.")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)

                    VStack(spacing: 12) {
                        Text("KidPad will download the classic artwork and sounds from the pinned JSKidPix project.")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .lineSpacing(4)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 520)
                        Text("About 2 MB  •  One time  •  No executable code")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(white: 0.28))
                    }

                    switch manager.phase {
                    case .awaitingConsent:
                        downloadButton
                    case .downloading:
                        VStack(spacing: 8) {
                            ProgressView(value: manager.progress)
                                .tint(.black)
                            Text("Installing Classic Pack…  \(Int(manager.progress * 100))%")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .frame(maxWidth: 380)
                        .accessibilityIdentifier("classicPack.progress")
                    case .failed(let message):
                        Text(message)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(red: 0.72, green: 0.05, blue: 0.03))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 520)
                        downloadButton
                    case .ready:
                        EmptyView()
                    }

                    HStack(spacing: 24) {
                        Link("VIEW SOURCE", destination: ClassicAssetCatalog.sourceRepository)
                        Link("GPL-3.0 LICENSE", destination: ClassicAssetCatalog.sourceLicense)
                    }
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(.blue)
                    .underline()
                }
                .padding(.horizontal, 38)
                .padding(.vertical, 30)
            }
            .background(Color(white: 0.91))
            .overlay(Rectangle().stroke(.black, lineWidth: 3))
            .frame(maxWidth: 680)
            .padding(32)
        }
        .preferredColorScheme(.light)
    }

    private var downloadButton: some View {
        Button("Download Classic Pack") { manager.install() }
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(red: 0.06, green: 0.22, blue: 0.66))
            .overlay(Rectangle().stroke(.black, lineWidth: 3))
            .accessibilityIdentifier("classicPack.download")
    }
}
