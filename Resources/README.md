`Resources/FidelityDev` is a local research build profile containing original
reference PNG/WAV files from the pinned upstream repository. These assets are
used directly for fidelity work and are not cleared for public distribution.

Only clean-room or rights-cleared release assets may be added to a future
public asset profile. Run `Scripts/verify_release_assets.sh` against a release
app bundle; it must pass before publication.

The generated project now exposes `DebugPublic`, `FidelityDev`, and
`ReleasePublic` configurations. Use `Scripts/build_public.sh` to build and
scan the public profile. `ReleasePublic` excludes the entire FidelityDev
resource group and the copied JSKIDPIX reference bundle; its UI and stamp
action use clean-room procedural fallbacks when the historical files are
absent. The JSKIDPIX bundle is available only for the opt-in
`--reference-web` comparison harness.
