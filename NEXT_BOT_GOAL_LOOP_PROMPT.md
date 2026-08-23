# KidPad Next-Bot Goal Loop Prompt

You are the next engineering agent continuing the KidPad task in:

`/Users/chrissotraidis/GitHub/kidpad`

Your objective is to make KidPad increasingly accurate to the original Kid Pix / JSKidPix experience while preserving a native iPad implementation, direct source-asset usage, reproducibility, and truthful legal and hardware status.

Do not stop at a plan, a compile, or a green subset of tests. Continue the loop: inspect → compare → implement → build → run in Simulator → capture evidence → audit → iterate.

## Required first actions

1. Read these files completely before changing code:

   - `docs/KidPad_Agent_Goal_Loop.md`
   - `docs/KidPad_iPadOS_PRD.md`
   - `AGENT_STATE.md`
   - `BUILD_STATUS.json`
   - `FIDELITY_MATRIX.md`
   - `AssetLedger.json`
   - `KNOWN_ISSUES.md`
   - `HARDWARE_VALIDATION_REQUIRED.md`
   - `/Users/chrissotraidis/.codex/attachments/15305c8c-1351-44c0-bd77-a58c0554200d/pasted-text-1.txt`

2. Inspect the current worktree and preserve existing user work. Do not reset or discard changes.

3. Inspect the pinned source repository and its current lock before relying on any asset or behavior:

   - `ref/source-jskidpix`
   - `ref/sources.lock.json`
   - pinned commit recorded in the lock

4. Review the live/reference materials already captured under `ref/visual-references/` and the current Simulator captures under `artifacts/simulator/`.

5. Select the highest-priority unmet goal from the loop. Keep the goal active until the highest achievable simulator-complete state is genuinely verified.

## Core fidelity rule

KidPad must directly use the original materials from the pinned open-source reference repository wherever those materials are available and legally retained for the private FidelityDev build:

- original PNG toolbar and submenu sprites;
- original palette values and texture catalogs;
- original stamp, sticker, and Sprite Stamp assets;
- original WAV audio and source sound mappings;
- original source-defined colors, action names, menus, and variant catalogs.

Do not redraw, regenerate, imitate, or substitute an available original asset. Do not invent a replacement sound when an original sound exists. If the source itself has no sound for a variant, document the silent behavior explicitly. If a source sound exists but is not wired, fix the wiring before claiming fidelity.

Keep exact historical assets quarantined from public builds until clearance is verified. Never infer permission merely because a repository is public.

## Mandatory sound and effects sanity pass

This pass is required before making broad visual claims:

1. Inventory every P0 action and variant in the pinned JSKidPix source.
2. For each action, identify the exact source sound file, source trigger timing, and whether it plays on selection, press, drag, progress, release, or completion.
3. Compare that inventory with `Sources/SoundPlayer.swift`, `Resources/FidelityDev/`, `Scripts/verify_fidelity_assets.sh`, and `AssetLedger.json`.
4. Remove any accidental clean-room or invented audio where a source WAV exists.
5. Verify sound playback in the running Simulator, not only by checking filenames:

   - sound enabled by default;
   - mute/unmute works;
   - rapid actions do not exhaust the player pool;
   - selection sounds are distinct from action-progress sounds;
   - line, truck, brush, mixer, fill, eraser, stamp, alphabet, and TNT timing are exercised;
   - unavailable source sounds remain intentionally silent and are documented.

6. Add or strengthen unit/UI tests for the source sound mapping and bounded playback policy.
7. Capture Simulator evidence for representative sound/effect actions where the environment permits it. Record limitations honestly when audio cannot be heard or captured by the available harness.

## Mandatory visual/effects pass

Use the reference site, pinned source repo, source HTML/CSS/JS behavior, and lawful screenshots as comparison material. Iterate on:

- classic toolbar geometry and spacing;
- menu bar and menu behavior;
- canvas placement and logical dimensions;
- palette colors and palette navigation;
- pencil sizes and texture previews;
- line, square, circle, fill, eraser, Wacky Brush, Electric Mixer, Alphabet, Rubber Stamps, Moving Van, and TNT behaviors;
- source sprite nearest-neighbor sampling and aspect preservation;
- hover, predicted-stroke, pressure-policy, and preview behavior;
- animation/effect timing where Simulator can verify it;
- portrait, landscape, compact-width, and any possible multitasking state.

Treat native deterministic approximations as approximations. Do not claim exact historical behavior unless the corresponding reference evidence supports it.

## Implementation constraints

- Native Swift/UIKit/SwiftUI implementation remains canonical.
- Core drawing truth remains the native raster document engine.
- The pinned web implementation may remain an opt-in reference harness, but it must not become the core drawing engine.
- Keep the private FidelityDev/reference profile separate from ReleasePublic.
- Keep network and telemetry disabled in normal workflows.
- Use `apply_patch` for source and documentation edits.
- Preserve unrelated user changes.
- Do not delete broad directories or use destructive repository commands.

## Verification loop

For every meaningful change:

1. Add or update the relevant fidelity row, test, asset-ledger entry, or known-issue record.
2. Run focused unit/UI tests first.
3. Run the complete native Simulator suite.
4. Install and launch the exact tested app on the available iPad Simulator.
5. Capture a fresh screenshot or retained XCTest attachment.
6. Run:

   - `Scripts/verify_fidelity_assets.sh`
   - `Scripts/verify_no_network.sh`
   - `Scripts/build_public.sh`

7. Confirm `AssetLedger.json` and `BUILD_STATUS.json` remain valid JSON.
8. Update `AGENT_STATE.md`, `BUILD_STATUS.json`, `docs/SIMULATOR_SCENARIOS.md`, `FIDELITY_MATRIX.md`, `KNOWN_ISSUES.md`, and `artifacts/reports/FINAL_REPORT.md` as needed.
9. Re-check that every claim in the report points to current evidence.

## Completion discipline

Do not mark the goal complete merely because tests pass. Completion requires current evidence for:

- all P0 tools and variants;
- persistence, autosave, recovery, thumbnail, undo/redo, and PNG export;
- direct source asset and sound provenance;
- simulator launch, visible workspace, drawing, tool selection, menus, rotation, and compact behavior;
- automated unit/UI coverage;
- public-profile asset policy;
- no-network policy;
- truthful physical Apple Pencil limitations;
- truthful historical asset, trademark, and license limitations;
- documented visual/audio differences.

If a hardware, legal, or environment dependency blocks a final gate, keep working on everything else, record the blocker in the persistent state files, and do not silently downgrade the objective. Use `update_goal` with `complete` only when the requested highest-achievable state is objectively verified and all remaining external blockers are explicitly documented. Use `blocked` only after the same blocker has prevented meaningful progress for three consecutive goal turns.

## Handoff format

At the end of each iteration, report briefly:

- what changed;
- what original source materials are now directly used;
- which focused and full tests passed;
- which Simulator screenshot/evidence was captured;
- whether public build and offline audits passed;
- what remains unverified and why;
- the next highest-leverage action.

Then continue the loop if meaningful work remains.
