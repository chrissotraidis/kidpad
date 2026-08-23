import AVFoundation

@MainActor
enum SoundPlayer {
    private static var players: [String: AVAudioPlayer] = [:]
    private static var playbackOrder: [String] = []
    private static let maxConcurrentPlayers = 8
    private static let enabledKey = "KidPad.soundEnabled"
    private static var brushVariant = 0
    private static var mixerVariant = 0
    private static var eraserVariant = 0
    private static var alphabetCharacter = "A"

    static var isEnabled: Bool {
        if UserDefaults.standard.object(forKey: enabledKey) == nil { return true }
        return UserDefaults.standard.bool(forKey: enabledKey)
    }

    static func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: enabledKey)
        if !enabled {
            players.values.forEach { $0.stop() }
            players.removeAll()
            playbackOrder.removeAll()
        }
    }
    static func toggle() { setEnabled(!isEnabled) }
    static func setBrushVariant(_ variant: Int) { brushVariant = max(0, min(variant, RasterDocument.wackyBrushes.count - 1)) }
    static func setMixerVariant(_ variant: Int) { mixerVariant = max(0, min(variant, 13)) }
    static func setEraserVariant(_ variant: Int) { eraserVariant = max(0, min(variant, 11)) }
    static func setAlphabetCharacter(_ character: Character) { alphabetCharacter = String(character) }

    /// Maps an alphabet/number/symbol character to its source WAV filename.
    /// Mirrors JSKidPix snd/english/ catalog exactly (42 entries).
    private static let alphabetSoundMap: [String: String] = [
        "a" : "alpha-a-WAVSOUND.R_0007d8f2.wav",
        "b" : "alpha-b-WAVSOUND.R_0007ee1f.wav",
        "c" : "alpha-c-WAVSOUND.R_000803fc.wav",
        "d" : "alpha-d-WAVSOUND.R_000815df.wav",
        "e" : "alpha-e-WAVSOUND.R_00082fcc.wav",
        "f" : "alpha-f-WAVSOUND.R_00084629.wav",
        "g" : "alpha-g-WAVSOUND.R_000853d0.wav",
        "h" : "alpha-h-WAVSOUND.R_00086213.wav",
        "i" : "alpha-i-WAVSOUND.R_00087a00.wav",
        "j" : "alpha-j-WAVSOUND.R_00088ced.wav",
        "k" : "alpha-k-WAVSOUND.R_0008a72e.wav",
        "l" : "alpha-l-WAVSOUND.R_0008bda3.wav",
        "m" : "alpha-m-WAVSOUND.R_0008d0f8.wav",
        "n" : "alpha-n-WAVSOUND.R_0008e695.wav",
        "o" : "alpha-o-WAVSOUND.R_0008fcaa.wav",
        "p" : "alpha-p-WAVSOUND.R_00091bdb.wav",
        "q" : "alpha-q-WAVSOUND.R_00092aee.wav",
        "r" : "alpha-r-WAVSOUND.R_0009639f.wav",
        "s" : "alpha-s-WAVSOUND.R_00097948.wav",
        "t" : "alpha-t-WAVSOUND.R_00099085.wav",
        "u" : "alpha-u-WAVSOUND.R_0009a406.wav",
        "v" : "alpha-v-WAVSOUND.R_0009bbcf.wav",
        "w" : "alpha-w-WAVSOUND.R_0009d8cc.wav",
        "x" : "alpha-x-WAVSOUND.R_0009ff1d.wav",
        "y" : "alpha-y-WAVSOUND.R_000a177a.wav",
        "z" : "alpha-z-WAVSOUND.R_000a2fe7.wav",
        "0" : "number-0-WAVSOUND.R_000a7832.wav",
        "1" : "number-1-WAVSOUND.R_000a9f1f.wav",
        "2" : "number-2-WAVSOUND.R_000ab58c.wav",
        "3" : "number-3-WAVSOUND.R_000aca17.wav",
        "4" : "number-4-WAVSOUND.R_000ae7a4.wav",
        "5" : "number-5-WAVSOUND.R_000afbb1.wav",
        "6" : "number-6-WAVSOUND.R_000b205a.wav",
        "7" : "number-7-WAVSOUND.R_000b43e7.wav",
        "8" : "number-8-WAVSOUND.002_000555ac.wav",
        "9" : "number-9-WAVSOUND.R_000b7db1.wav",
        "&" : "number-ampersand-WAVSOUND.R_000be96f.wav",
        "!" : "number-eclamation-WAVSOUND.R_000a5774.wav",
        "=" : "number-equals-WAVSOUND.R_000bce22.wav",
        "-" : "number-minus-WAVSOUND.R_000bb0e5.wav",
        "+" : "number-plus-WAVSOUND.R_000b9a58.wav",
        "?" : "number-question-mark-WAVSOUND.R_000a661d.wav",
    ]
    static func alphabetSound(for character: String) -> String? {
        alphabetSoundMap[character.lowercased()]
    }

    static func play(_ resource: String) {
        guard isEnabled else { return }
        guard let url = KidPadResource.url(forResource: resource, withExtension: nil) else { return }
        do {
            if let existing = players.removeValue(forKey: resource) {
                existing.stop()
                playbackOrder.removeAll { $0 == resource }
            }
            while players.count >= maxConcurrentPlayers, let oldest = playbackOrder.first {
                playbackOrder.removeFirst()
                players.removeValue(forKey: oldest)?.stop()
            }
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[resource] = player
            playbackOrder.append(resource)
            player.play()
        } catch { }
    }

    private static func playSingle(_ resource: String) {
        guard players[resource]?.isPlaying != true else { return }
        play(resource)
    }

    static var activePlayerCountForTesting: Int { players.count }

    static func menuClick() { play("kidpix-menu-click-main-tools.wav") }
    static func submenuColorClick() { play("kidpix-menu-click-submenu-color.wav") }
    static func submenuOptionClick() { play("kidpix-menu-click-submenu-options.wav") }
    static let unimplementedResource = "chord.wav"
    static func unimplemented() { playSingle(unimplementedResource) }
    static func fill() { play("flood0.wav") }
    static let oopsResources = ["oops0.wav", "oops1.wav", "oops2.wav", "oops3.wav"]
    static let brushMovementSounds: [String?] = [
        "kidpix-submenu-brush-leaky-pen.wav",
        "kidpix-submenu-brush-zigzag.wav",
        "kidpix-submenu-brush-dots.wav",
        "kidpix-submenu-brush-bubbly.wav",
        "kidpix-submenu-brush-pies.wav",
        "kidpix-submenu-brush-owl.wav",
        "kidpix-submenu-brush-northern.wav",
        "kidpix-submenu-brush-fuzzer.wav",
        "kidpix-submenu-brush-zoom.wav",
        "kidpix-submenu-brush-spraypaint.wav",
        "kidpix-submenu-brush-pines.wav",
        nil,
        "kidpix-submenu-brush-kaliediscope.wav",
        "kidpix-submenu-brush-twirly.wav",
        "kidpix-submenu-brush-twirly.wav",
        "kidpix-submenu-brush-rollingdots.wav",
        "kidpix-submenu-brush-inverter.wav",
        "kidpix-submenu-brush-guilloche.wav",
        "kidpix-submenu-brush-xy-during.wav",
        nil,
        "kidpix-submenu-brush-bubbly.wav",
        "kidpix-tool-line-during.wav",
        nil,
        "kidpix-submenu-brush-stars.wav",
        "kidpix-submenu-brush-xos.wav",
        "kidpix-submenu-brush-cards.wav",
        "kidpix-submenu-brush-shapes.wav",
        "kidpix-submenu-brush-prints.wav"
    ]
    static func oops() {
        play(oopsResources.randomElement()!)
    }
    static func actionStarted(for tool: CanvasTool) {
        switch tool {
        case .pencil: play("kidpix-tool-pencil.wav")
        case .line: play("kidpix-tool-line-start.wav")
        case .rectangle: play("kidpix-tool-box-during-approx.wav")
        case .oval: play("kidpix-tool-circle-during-approx.wav")
        case .brush:
            // The source starts only gesture-specific sounds here. Most brush
            // effects make their sound while moving, not merely on selection.
            switch brushVariant {
            case 1: playSingle("kidpix-submenu-brush-zigzag.wav")
            case 18: play("kidpix-submenu-brush-xy-start.wav")
            case 19: play("kidpix-submenu-brush-tree.wav")
            case 21: play("kidpix-tool-line-start.wav")
            default: break
            }
        case .mixer:
            // Source mapping (JSKidPix Submenu.jumble, app.js ~8264):
            // 0 Invert=mixerinvert, 1 Raindrops=bubblepops(rand), 2 Checkerboard=silent,
            // 3 Wallpaper=boingo, 4 Venetian=venetian, 5 Outliner=unimpl(chord),
            // 6 ShadowBoxes=shadowbox, 7 ZoomIn=unimpl(chord), 8 BrokenGlass=unimpl(chord),
            // 9 PiP=mixerpip, 10 Highlighter=unimpl(chord), 11 Pattern=western-gun-shot-twirl,
            // 12 WrapAround=unimpl(chord), 13 Swirl/Pancake=no sound in source.
            let sounds: [String?] = [
                "electric-mixer-inverter-rolling-sound-WAVSOUND.R_0001fcfa.wav",
                "bubblepops",
                nil,
                "electric-mixer-wallpaper-jitter-boingo-WAVSOUND.R_00024fcc.wav",
                "electric-mixer-venetian-WAVSOUND.R_0001df56.wav",
                "chord.wav",
                "electric-mixer-shadow-boxes-WAVSOUND.R_0002a07a.wav",
                "chord.wav",
                "chord.wav",
                "electric-mixer-pip-drum-crash-1WAVSOUND.R_0002d96e.wav",
                "chord.wav",
                "western-gun-shot-twirl-WAVSOUND.R_0005ed70.wav",
                "chord.wav",
                nil
            ]
            if let sound = sounds[mixerVariant] {
                if sound == "bubblepops" { bubblePop() } else { play(sound) }
            }
        case .eraser:
            // Active pinned-source order excludes commented-out asset 188.
            if eraserVariant == 4 { play("kidpix-tool-eraser-tnt-explosion.wav") }
            else if eraserVariant == 6 { bubblePop() }
            else if eraserVariant == 7 { eraserClearAll() }
            else if eraserVariant == 8 { play("electric-mixer-shadow-boxes-WAVSOUND.R_0002a07a.wav") }
            else if eraserVariant == 9 { play("eraser-tool-fade-2WAVSOUND.R_0002f58b.wav") }
            else if eraserVariant == 10 || eraserVariant == 11 { play("chord.wav") }
        case .alphabet:
            if let sound = alphabetSound(for: alphabetCharacter) { play(sound) }
        case .stamp: play("stamp0.wav")
        case .truck: play("kidpix-truck-truckin.wav")
        case .fill: fill()
        case .clear: play("kidpix-tool-eraser-tnt-explosion.wav")
        }
    }
    static func actionEnded(for tool: CanvasTool) {
        switch tool {
        case .line: play("kidpix-tool-line-end.wav")
        case .truck: play("kidpix-truck-skid.wav")
        default: break
        }
    }

    static func actionProgressed(for tool: CanvasTool) {
        switch tool {
        case .line: play("kidpix-tool-line-during.wav")
        case .brush:
            if let sound = brushMovementSounds[brushVariant] { playSingle(sound) }
        case .truck: play("kidpix-truck-truckin-go.wav")
        default: break
        }
    }
    static func actionReleased(for tool: CanvasTool) {
        switch tool {
        case .brush where brushVariant == 18: play("kidpix-submenu-brush-xy-end.wav")
        case .brush where brushVariant == 21: play("kidpix-tool-line-end.wav")
        default: break
        }
    }
    /// Source: Raindrops mixer uses randomized bubble-pop WAVs per stroke tick.
    private static func bubblePop() {
        let pops = [
            "bubble-pop-2WAVSOUND.R_0004edd3.wav",
            "bubble-pop-3WAVSOUND.R_0004fccd.wav",
            "bubble-pop-4WAVSOUND.R_0004f480.wav",
            "bubble-pop-WAVSOUND.R_000031f6.wav",
            "bubble-pop-WAVSOUND.R_00050452.wav",
        ]
        play(pops.randomElement()!)
    }
    /// Source: clear-all plays doordingdong then doorcreak sequentially.
    static func eraserClearAll() {
        play("kidpix-eraser-doorbell-ding-dong.wav")
        let delay = players["kidpix-eraser-doorbell-ding-dong.wav"]?.duration ?? 0
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(max(0, delay) * 1_000_000_000))
            guard isEnabled else { return }
            play("kidpix-eraser-doorbell-door-creak.wav")
        }
    }
    /// Source: eraser reaching canvas edge plays doorwow.
    static func eraserReachedEdge() {
        play("kidpix-eraser-doorbell-wwoooowwww.wav")
    }
}
