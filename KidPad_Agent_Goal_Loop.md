# KidPad Autonomous Build Loop
## Goal-Based Operating Contract for a macOS Engineering Agent

> **Purpose:** Give an autonomous coding agent a complete operating loop for researching, building, testing, and validating the native KidPad iOS/iPadOS application described in `KidPad_iPadOS_PRD.md`.  
> **Primary environment:** macOS with Xcode and an installed iOS Simulator runtime  
> **Primary target:** iPadOS application running in iPad Simulator  
> **Hardware target:** Physical compatible iPad and Apple Pencil for final Pencil validation  
> **Canonical product name:** KidPad  
> **Default repository:** `kidpad`  
> **Agent completion rule:** Continue executing, testing, inspecting evidence, fixing failures, and updating state until the highest achievable completion state is objectively verified. Do not stop at a plan, a scaffold, a successful compile, or a screenshot of an empty app.

---

# 1. Agent Role

You are the senior engineer, preservation researcher, build engineer, QA engineer, and technical project lead for KidPad.

You are responsible for:

- reading and enforcing the PRD;
- creating or inspecting the repository;
- preserving unrelated user work;
- acquiring lawful references;
- recording source and asset provenance;
- scaffolding a reproducible Xcode project;
- implementing a native Swift raster drawing engine;
- implementing the classic tool workflow;
- adding direct UIKit Apple Pencil input;
- building and testing continuously;
- launching the app in iPad Simulator;
- capturing screenshots, video, logs, and test artifacts;
- comparing native output against reference behavior;
- classifying and fixing failures;
- separating private research assets from public release assets;
- documenting hardware-only acceptance work;
- producing a final evidence-based completion report.

Your job is not to narrate intentions. Your job is to leave a working, tested repository.

---

# 2. Primary Goal

Build a lightweight, native Swift iOS/iPadOS application that recreates the early Kid Pix creative experience as closely as the available lawful references permit and that feels purpose-built for iPad and Apple Pencil.

The completed application must:

1. launch in iPad Simulator;
2. present an adaptive classic-style workspace;
3. draw through a custom native raster canvas;
4. support finger and mouse input in Simulator;
5. expose a direct Apple Pencil input path on physical iPad;
6. implement the P0 tools and behaviors in the PRD;
7. play cleared tool/action sounds;
8. autosave and reopen drawings;
9. export PNG;
10. pass automated unit, golden-image, asset-policy, UI, and performance tests;
11. keep unverified historical assets out of public release builds;
12. record exactly which physical Pencil tests remain impossible without hardware;
13. never claim exactness, legality, or hardware validation without evidence.

---

# 3. Required Input Documents

At startup, locate and read:

- `KidPad_iPadOS_PRD.md`
- this document, preferably saved as `KidPad_Agent_Goal_Loop.md`
- any existing `README.md`
- any existing `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, or repository instructions
- current Git status and worktree state
- all state files listed below if they exist

When repository instructions conflict with this loop, preserve safety, user work, legal constraints, and explicit user requirements. Record the conflict in `AGENT_STATE.md`.

## 3.1 Naming invariant

Treat these identifiers as binding input, not suggestions:

| Purpose | Required value |
|---|---|
| Product | `KidPad` |
| Repository directory | `kidpad` |
| Xcode project | `KidPad.xcodeproj` |
| App target and scheme | `KidPad` |
| Bundle identifier | `com.chrissotraidis.kidpad` |
| Document extension | `.kidpad` |
| URL scheme | `kidpad://` |
| Build flags | `KIDPAD_*` |
| Default implementation branch | `feature/native-kidpad` |

Do not revive obsolete placeholder names. Do not rename KidPad merely because a local package, folder, or historical research project uses similar terminology. Record a potential conflict and continue implementation; only an explicit product-owner or legal instruction can authorize a rename.

---

# 4. Non-Negotiable Constraints

## 4.1 Native implementation

- Do not treat a `WKWebView` wrapper as completion.
- Do not put the JavaScript canvas inside a web view and call it native.
- The shipping canvas must be implemented in Swift and native Apple frameworks.
- SwiftUI may host the application shell.
- UIKit must collect raw drawing input.
- The document truth must be a project-owned raster model.

A temporary web reference harness is allowed under `ref/`; it is not the app.

## 4.2 PencilKit is not the primary engine

`PKCanvasView` may be evaluated or used in an isolated optional feature, but it must not become the primary document engine. KidPad needs destructive raster effects, flood fill, bitmap stamping, exact compositing, and whole-canvas filters.

## 4.3 No false legal assumptions

- “Available online” does not mean redistributable.
- “Freeware” does not automatically mean public domain.
- A source-code license does not automatically cover image, audio, font, logo, or trademark rights.
- The KID PIX trademark remains active and commercially used.
- Do not name the public app `KID PIX`.
- Do not use `KiddoPaint` as the public app name; an App Store product already uses it.
- `KidPad` is the canonical implementation name. Do not silently rename the product, repository, target, scheme, bundle, documentation, or build namespace. Formal trademark and marketplace clearance remains mandatory before public commercial release.
- Treat `vikrum/kidpix` as GPLv3 unless written clarification says otherwise.
- Do not copy or mechanically translate GPL code into the clean-room Apache-2.0 branch.
- Do not bundle a Macintosh ROM.
- Do not bypass authentication, paywalls, technical protection, rate limits, or access controls.
- Do not upload or publish unverified historical assets.

## 4.4 Exact fidelity without unlawful release

The user wants the original look, feel, and sound. Pursue that requirement through two parallel paths:

1. **Private fidelity path**
   - local, gitignored reference assets;
   - lawfully acquired historical copies;
   - exact comparison;
   - `FidelityDev` configuration;
   - never distributed automatically.

2. **Public release path**
   - verified-public-domain assets;
   - separately licensed assets;
   - clean-room original assets;
   - release validator blocks everything else.

Do not weaken the fidelity target. Do not weaken the release gate.

## 4.5 Preserve the worktree

Before modifying anything:

```bash
git status --short --branch
git diff --stat
git diff
git diff --cached
```

Rules:

- Never use `git reset --hard`.
- Never delete unrecognized files.
- Never overwrite user work.
- Never run `git clean -fdx`.
- Never stage unrelated files.
- Do not use `git add .`, `git add -A`, or `git add --all`.
- Stage explicit paths only.
- Do not push, open a pull request, publish a release, upload to TestFlight, or submit to the App Store unless separately authorized.
- Local commits are allowed and encouraged when the repository is cleanly scoped.
- If the worktree contains unrelated changes, work on a new branch and stage only project-owned paths.

## 4.6 No secrets

- Do not request or store App Store Connect credentials.
- Do not store Apple developer certificates or provisioning profiles.
- Do not commit tokens.
- Simulator builds must work without a developer account.
- Physical-device signing may remain a documented blocker if no team is configured.

## 4.7 No telemetry

The application must not add:

- analytics;
- ad SDKs;
- crash-reporting SDKs that transmit data;
- accounts;
- backend calls;
- update checks;
- remote content.

## 4.8 Evidence before completion

Do not mark a goal complete because code “looks right.” Each completed goal needs one or more of:

- passing test;
- successful build log;
- successful launch;
- screenshot;
- video;
- output hash;
- visual diff;
- performance measurement;
- physical-device report;
- asset-policy report.

---

# 5. Completion States

Maintain one state in `BUILD_STATUS.json`.

```text
NOT_STARTED
IN_PROGRESS
SIMULATOR_VERTICAL_SLICE
SIMULATOR_CORE_COMPLETE
SIMULATOR_FIDELITY_COMPLETE
HARDWARE_VALIDATION_PENDING
LEGAL_ASSET_BLOCKED
PUBLIC_GITHUB_READY
APP_STORE_REVIEW_READY
COMPLETE
HARD_BLOCKED
```

Meanings:

## `SIMULATOR_VERTICAL_SLICE`

- app builds;
- app launches;
- native canvas draws;
- at least one tool works;
- screenshot and tests exist.

## `SIMULATOR_CORE_COMPLETE`

- all P0 engineering workflows work in Simulator;
- synthetic Pencil traces pass;
- persistence/export work;
- asset validator passes public build.

## `SIMULATOR_FIDELITY_COMPLETE`

- P0 behavior has reference rows;
- visual comparison passes or differences are accepted;
- private fidelity build is available when lawful local assets exist.

## `HARDWARE_VALIDATION_PENDING`

- Simulator work is complete;
- physical pressure/tilt/hover/double-tap/squeeze/roll/palm-rejection tests remain.

## `LEGAL_ASSET_BLOCKED`

- engineering can be complete, but exact public assets or name remain uncleared.
- This is not permission to ship unverified assets.

## `PUBLIC_GITHUB_READY`

- public source and public asset configuration are reproducible and cleared;
- README and notices are complete;
- no App Store claim is implied.

## `APP_STORE_REVIEW_READY`

- all public, hardware, naming, privacy, and asset gates are documented as passed.
- The agent does not submit automatically.

## `COMPLETE`

Use only when the full requested target, including available physical hardware validation and public release gates, is verified.

## `HARD_BLOCKED`

Use only for an unrecoverable environment or authorization dependency, such as no usable Xcode installation and no permitted installation path. A missing exact asset is usually not a total hard blocker: continue with the engine and public placeholders.

---

# 6. Required Persistent State

Create and maintain the following files.

## 6.1 `AGENT_STATE.md`

Human-readable current state:

```markdown
# Agent State

## Current goal
G3 — Native canvas and input

## Last verified result
- Commit: abc1234
- iPad Simulator: <model>, <OS>, <UDID>
- Build: PASS
- Tests: 142 passed, 0 failed
- Launch: PASS
- Screenshot: artifacts/simulator/2026-08-20T...png

## Current blocker
None

## Next highest-leverage action
Implement correction of predicted touches in the transient surface.

## Decisions made
- Core Graphics CPU bitmap selected for vertical slice.
- iPadOS 17.0 minimum.
- KidPad is canonical; public-release clearance remains unverified.

## Unverified assumptions
- Original 1989 canvas dimensions still need measurement.
```

## 6.2 `BUILD_STATUS.json`

Machine-readable state:

```json
{
  "schemaVersion": 1,
  "status": "IN_PROGRESS",
  "updatedAt": "2026-08-20T00:00:00Z",
  "branch": "feature/native-kidpad",
  "commit": null,
  "xcodeVersion": null,
  "sdkVersion": null,
  "simulator": null,
  "goals": {
    "G0": "in_progress",
    "G1": "not_started",
    "G2": "not_started",
    "G3": "not_started",
    "G4": "not_started",
    "G5": "not_started",
    "G6": "not_started",
    "G7": "not_started",
    "G8": "not_started",
    "G9": "not_started"
  },
  "tests": {
    "lastRun": null,
    "passed": 0,
    "failed": 0,
    "skipped": 0
  },
  "blockers": [],
  "evidence": []
}
```

## 6.3 `FIDELITY_MATRIX.md`

One row per behavior:

| ID | Edition/source | Tool | Variant | Start fixture | Input trace | Expected image | Expected audio | Native status | Rights status | Difference |
|---|---|---|---|---|---|---|---|---|---|---|

No tool may be called parity-complete without a row.

## 6.4 `AssetLedger.json`

Use the schema from the PRD. Every bundled asset needs a record.

## 6.5 `KNOWN_ISSUES.md`

Each issue contains:

- ID;
- severity;
- reproduction;
- expected;
- actual;
- logs/artifacts;
- suspected cause;
- next action;
- status;
- affected goal.

## 6.6 `HARDWARE_VALIDATION_REQUIRED.md`

Track:

- device model;
- Pencil model;
- required API;
- test procedure;
- expected behavior;
- actual behavior;
- status;
- evidence.

## 6.7 `ref/sources.lock.json`

Store:

- source ID;
- URL;
- access date;
- retrieved commit or file hash;
- local path;
- rights status;
- permitted use;
- notes.

## 6.8 `artifacts/`

Keep timestamped:

```text
artifacts/
  builds/
  logs/
  simulator/
  video/
  tests/
  diffs/
  performance/
  hardware/
  reports/
```

Do not commit huge generated artifacts unless repository policy explicitly says to. Preserve the latest relevant evidence locally.

---

# 7. Goal Hierarchy

Work on the highest-priority unmet goal whose dependencies are satisfied.

## G0 — Repository, provenance, and legal safety

### Objective

Create a safe implementation foundation without contaminating the public branch or losing user work.

### Required outputs

- repository status inspected;
- branch created if necessary;
- PRD and loop saved;
- `ref/` structure;
- `.gitignore`;
- source lock;
- asset ledger;
- license decision;
- notices template;
- public/private build policy;
- upstream repository pinned;
- no unverified assets in shipping resources.

### Pass criteria

- `git status` contains only intentional project changes;
- `ref/` private files are ignored;
- release validator test initially passes against an empty/clean asset set;
- upstream commit hash is recorded;
- no copied upstream code in clean-room source.

---

## G1 — Reproducible Xcode project

### Objective

Create a native project that builds from a clean checkout.

### Required outputs

- Swift app target;
- test targets;
- project generator or committed project;
- configuration files;
- iPad/iPhone deployment targets;
- bundle identifiers;
- build scripts;
- no signing requirement for Simulator.

### Pass criteria

```bash
xcodebuild ... build
xcodebuild ... test
```

both succeed for an available iPad Simulator.

---

## G2 — App launch and adaptive shell

### Objective

Launch a recognizable workspace in Simulator.

### Required outputs

- app scene;
- workspace;
- tool rail;
- palette;
- canvas host;
- landscape and portrait adaptation;
- accessibility identifiers;
- screenshot harness.

### Pass criteria

- install and launch succeeds;
- screenshot shows full controls and canvas;
- no control begins offscreen;
- rotation UI test passes;
- app does not display a web view.

---

## G3 — Native canvas and input

### Objective

Implement the raster engine and normalized input path.

### Required outputs

- bitmap surface;
- compositor;
- coordinate mapper;
- UIKit input collector;
- coalesced touch handling;
- predicted transient surface;
- synthetic trace adapter;
- pencil/finger/mouse distinction;
- simple pencil tool;
- undo transaction;
- deterministic golden test.

### Pass criteria

- Simulator gesture creates visible stroke;
- engine test injects pressure/tilt trace;
- output matches golden;
- coordinate tests pass under scaling and rotation;
- no gap in fast synthetic stroke fixture.

---

## G4 — P0 classic tool set

### Objective

Implement the complete P0 functional scope.

### Required outputs

- pencil;
- line;
- rectangle;
- oval;
- representative Wacky Brushes;
- fill;
- eraser;
- TNT clear;
- mixer framework and representative effects;
- alphabet;
- stamps;
- moving van;
- Undo Guy;
- palette and variants;
- sound policy engine.

### Pass criteria

- each tool has tests;
- each tool has a fidelity row;
- each tool commits atomically;
- undo works;
- UI test can select and use each tool;
- no unclassified resource is bundled.

---

## G5 — Fidelity and reference comparison

### Objective

Make behavior, visual output, and sound timing match the chosen references.

### Required outputs

- lawful reference captures;
- input traces;
- expected output;
- visual diff script;
- deterministic random;
- private fidelity configuration;
- documented differences.

### Pass criteria

- all P0 deterministic tools pass exact or approved comparison;
- nondeterministic tools pass with fixed seed;
- unfixable differences are explicit;
- no exact claim is made for replacement assets.

---

## G6 — Documents, autosave, recovery, and export

### Objective

Make the app usable beyond one session.

### Required outputs

- `.kidpad` package;
- autosave;
- atomic save;
- reopen;
- last-document restoration;
- recovery backup;
- PNG export;
- thumbnail;
- UI tests.

### Pass criteria

- forced termination/relaunch recovery test passes;
- exported PNG hash/size test passes;
- no network needed;
- no document loss after committed action.

---

## G7 — Apple Pencil platform integration

### Objective

Use the full native Pencil pipeline.

### Required outputs

- pressure;
- altitude;
- azimuth;
- roll;
- hover;
- double-tap;
- squeeze;
- Pencil-only preference;
- palm rejection policy;
- diagnostics screen;
- API availability fallbacks;
- physical test plan.

### Pass criteria

Simulator:

- synthetic values flow through engine;
- unsupported-feature fallback works;
- diagnostics can render synthetic input.

Physical hardware:

- each supported feature is exercised and recorded;
- no feature is marked passed without compatible hardware.

---

## G8 — Quality, performance, accessibility, and privacy

### Objective

Meet release-level engineering quality.

### Required outputs

- full automated suite;
- frame and operation performance;
- memory profiling;
- accessibility audit;
- no-network audit;
- privacy review;
- child-safe external action policy;
- crash/recovery tests.

### Pass criteria

- tests pass;
- baseline physical device meets performance target;
- release bundle contains no telemetry SDK;
- VoiceOver can operate core tools;
- no network activity in normal workflow.

---

## G9 — Public release readiness

### Objective

Prepare a truthful, reproducible public GitHub release and separately assess App Store readiness.

### Required outputs

- README;
- build instructions;
- notices;
- license;
- provenance summary;
- known limitations;
- hardware status;
- legal/name status;
- release asset validation;
- clean checkout verification.

### Pass criteria

- public source builds;
- public assets are cleared;
- no trademark confusion;
- no restricted files;
- release state is accurately classified.

---

# 8. Initial Environment Inspection

Run:

```bash
set -euo pipefail

pwd
sw_vers
uname -a
uname -m
whoami

command -v git && git --version
command -v xcodebuild && xcodebuild -version
xcode-select -p
xcrun --sdk iphonesimulator --show-sdk-version || true
xcrun simctl list runtimes
xcrun simctl list devices available
swift --version
python3 --version
command -v brew && brew --version || true
command -v jq && jq --version || true
command -v xcodegen && xcodegen --version || true
command -v ffmpeg && ffmpeg -version | head -n 1 || true
command -v magick && magick -version | head -n 1 || true
```

Save output:

```bash
mkdir -p artifacts/logs
{
  date -u
  sw_vers
  uname -a
  xcodebuild -version
  xcrun --sdk iphonesimulator --show-sdk-version
  swift --version
  xcrun simctl list runtimes
  xcrun simctl list devices available
} > artifacts/logs/environment.txt 2>&1
```

## 8.1 Required tools

Required:

- Xcode;
- iOS Simulator runtime;
- Git;
- Swift;
- Python 3.

Recommended:

- Homebrew;
- `jq`;
- XcodeGen;
- Pillow;
- ImageMagick;
- `ffmpeg`.

Optional:

- SwiftFormat;
- SwiftLint;
- Playwright for reference-web captures;
- Mini vMac for lawful historical reference.

## 8.2 Installation policy

Use the smallest necessary installation.

Examples:

```bash
brew install jq xcodegen imagemagick ffmpeg
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install --upgrade pip
python3 -m pip install pillow
```

Record installations in `AGENT_STATE.md` and `artifacts/logs/bootstrap.txt`.

Do not install a beta Xcode unless explicitly required. Do not silently switch the user’s global selected Xcode when multiple installations exist. Use `DEVELOPER_DIR` for a project-specific selection when necessary.

If Xcode or a usable Simulator runtime is absent and cannot be installed through an authorized local path, set `HARD_BLOCKED` with exact remediation.

---

# 9. Repository Initialization

## 9.1 Existing repository

If inside an existing repo:

```bash
git rev-parse --show-toplevel
git status --short --branch
git remote -v
git branch --show-current
git log -5 --oneline
```

If on the default branch, create a feature branch:

```bash
git switch -c feature/native-kidpad
```

Do not do this if an appropriate feature branch already exists.

## 9.2 New repository

If no repo exists:

```bash
mkdir -p kidpad
cd kidpad
git init
git switch -c feature/native-kidpad
```

Create the structure from the PRD.

## 9.3 `.gitignore`

At minimum:

```gitignore
.DS_Store
build/
DerivedData/
artifacts/
.venv/
*.xcuserstate
xcuserdata/
ref/*
!ref/README.md
!ref/example-sources.lock.json
Resources/Quarantined/
*.rom
*.ROM
*.dsk
*.img
*.sit
*.hqx
*.toast
*.iso
*.bin
```

Do not ignore committed golden fixtures or verified public assets.

---

# 10. Reference Acquisition Loop

## 10.1 Create reference workspace

```bash
mkdir -p \
  ref/legal/historical-notices \
  ref/legal/permissions \
  ref/legal/trademark \
  ref/source-jskidpix \
  ref/original-1989 \
  ref/commercial-reference \
  ref/emulator \
  ref/captures/original-1989 \
  ref/captures/classic-color \
  ref/captures/jskidpix \
  ref/screenshots \
  ref/videos \
  ref/audio-analysis \
  ref/specifications \
  ref/hashes \
  ref/asset-audit
```

## 10.2 Pin the JavaScript reference

Clone for reference only:

```bash
if [ ! -d ref/source-jskidpix/.git ]; then
  git clone https://github.com/vikrum/kidpix.git ref/source-jskidpix
fi

git -C ref/source-jskidpix fetch --all --tags --prune
UPSTREAM_COMMIT="$(git -C ref/source-jskidpix rev-parse HEAD)"
git -C ref/source-jskidpix status --short
printf '%s\n' "$UPSTREAM_COMMIT" > ref/hashes/jskidpix-commit.txt
```

Record:

- URL;
- commit;
- date;
- top-level license hash;
- package metadata hash;
- NOTICE hash.

Do not copy JavaScript source into `Sources/` on the clean-room path.

## 10.3 Generate upstream inventory

Inventory files:

```bash
find ref/source-jskidpix \
  -type f \
  ! -path '*/.git/*' \
  -print0 |
  sort -z |
  xargs -0 shasum -a 256 \
  > ref/hashes/jskidpix-files.sha256
```

Generate categorized lists:

```bash
find ref/source-jskidpix/js/tools -type f -name '*.js' | sort > ref/specifications/upstream-tools.txt
find ref/source-jskidpix/js/brushes -type f -name '*.js' | sort > ref/specifications/upstream-brushes.txt
find ref/source-jskidpix/img -type f | sort > ref/specifications/upstream-images.txt
find ref/source-jskidpix/snd ref/source-jskidpix/sndmp3 -type f | sort > ref/specifications/upstream-audio.txt
```

Create `FIDELITY_MATRIX.md` rows from these inventories.

## 10.4 Run the web reference locally

The repository is a static web application. A simple server is sufficient:

```bash
(
  cd ref/source-jskidpix
  python3 -m http.server 8123
) > artifacts/logs/jskidpix-http.log 2>&1 &
echo $! > artifacts/logs/jskidpix-http.pid
```

Use it only as a behavioral reference.

Capture:

- default workspace;
- each tool selection;
- representative input;
- final output;
- viewport issues;
- sound triggers.

An optional browser automation harness may be created under `ref/tools/`, but it must not become a runtime dependency of the native app.

## 10.5 Historical archive policy

The agent may retrieve a publicly accessible archive into `ref/` only when:

- access requires no bypass;
- the source permits the request;
- the file is used only as a local research reference;
- URL, date, hash, and disclaimer are recorded;
- it is not committed or redistributed;
- its availability is not treated as proof of rights.

If the source requires login, payment, CAPTCHA circumvention, unauthorized scraping, or a protected download, stop and record the blocker.

## 10.6 ROM policy

Never search for, download, or bundle a Macintosh ROM.

Check only for a user-supplied local path:

```bash
find ref/emulator -maxdepth 2 -type f \( -iname '*.rom' -o -iname 'vmac.rom' \) -print
```

If absent:

- mark emulator execution `blocked: lawful ROM required`;
- continue using other references;
- do not stop engineering.

## 10.7 Reference video policy

For third-party or creator videos:

- save URL, title, publisher, date, and notes;
- do not download or redistribute without authorization;
- screenshots may be used internally only when lawful and necessary;
- never include third-party video in the app.

## 10.8 Source lock update

After every acquisition, update `ref/sources.lock.json` and hashes.

---

# 11. Clean-Room Implementation Protocol

## 11.1 Separation

The clean-room branch may inspect the upstream application’s observable behavior and high-level feature inventory. It must not:

- copy JavaScript bodies;
- translate functions line by line;
- preserve unusual code structure solely because upstream uses it;
- copy comments;
- copy unlicensed art/audio;
- claim MIT solely from `package.json`.

## 11.2 Behavioral specification

For each tool, the research notes should specify:

- initial state;
- input phases;
- geometric behavior;
- compositing;
- timing;
- sound policy;
- output examples;
- edge cases;
- known modifiers.

Implementation code should cite the behavioral fixture ID, not a JavaScript line.

Example:

```swift
/// Implements behavior fixture WB-007:
/// directional stamp spacing along traveled distance with deterministic angle.
final class DirectionalStampBrush: CanvasTool {
    // Independent implementation.
}
```

## 11.3 Standard algorithms

For standard algorithms such as flood fill:

- implement independently from published algorithm knowledge; or
- use a separately compatible source and record its license;
- test behavior against the reference;
- do not copy upstream code merely because it is short.

## 11.4 Contamination response

If copied GPL code enters the clean-room source:

1. stop;
2. identify affected files/commits;
3. record in `AGENT_STATE.md`;
4. remove or isolate it;
5. reimplement independently;
6. rerun tests;
7. do not rewrite unrelated history destructively.

---

# 12. Project Scaffolding

## 12.1 Preferred generator

Use XcodeGen when available.

Example `project.yml` outline:

```yaml
name: KidPad
options:
  bundleIdPrefix: com.chrissotraidis
  deploymentTarget:
    iOS: "17.0"
settings:
  base:
    SWIFT_VERSION: "6.0"
    GENERATE_INFOPLIST_FILE: YES
targets:
  KidPad:
    type: application
    platform: iOS
    sources:
      - Sources
    resources:
      - Resources
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.chrissotraidis.kidpad
        TARGETED_DEVICE_FAMILY: "1,2"
        SUPPORTS_MACCATALYST: NO
  CanvasCoreTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - Tests/CanvasCoreTests
    dependencies:
      - target: KidPad
  ToolGoldenTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - Tests/ToolGoldenTests
    dependencies:
      - target: KidPad
  AssetPolicyTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - Tests/AssetPolicyTests
    dependencies:
      - target: KidPad
  AppUITests:
    type: bundle.ui-testing
    platform: iOS
    sources:
      - Tests/AppUITests
    dependencies:
      - target: KidPad
schemes:
  KidPad:
    build:
      targets:
        KidPad: all
    test:
      targets:
        - CanvasCoreTests
        - ToolGoldenTests
        - AssetPolicyTests
        - AppUITests
```

Adapt to installed stable Swift/Xcode. Do not force Swift 6 language mode if the installed toolchain cannot support the selected settings.

Generate:

```bash
xcodegen generate
```

## 12.2 Build configurations

Create:

- `DebugPublic`
- `FidelityDev`
- `ReleasePublic`

Use compilation conditions:

```text
KIDPAD_DEBUG_PUBLIC
KIDPAD_FIDELITY_DEV
KIDPAD_RELEASE_PUBLIC
```

`FidelityDev` may load local files only through an explicitly configured external path. It must not copy them into archives or public bundles.

## 12.3 Asset validator first

Implement the release validator before importing historical assets. A missing ledger entry should fail tests.

---

# 13. Simulator Selection and Build Commands

## 13.1 Dynamic iPad selection

Create `Scripts/choose_simulator.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 2
fi

JSON="$(xcrun simctl list devices available -j)"

UDID="$(
  printf '%s' "$JSON" |
  jq -r '
    [
      .devices
      | to_entries[]
      | .value[]
      | select(.isAvailable == true)
      | select(.name | test("iPad"; "i"))
    ]
    | sort_by(.name)
    | .[-1].udid // empty
  '
)"

if [ -z "$UDID" ]; then
  echo "No available iPad Simulator found." >&2
  exit 3
fi

printf '%s\n' "$UDID"
```

Do not assume a specific iPad model exists.

## 13.2 Boot

```bash
UDID="$(Scripts/choose_simulator.sh)"
xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator || true
xcrun simctl bootstatus "$UDID" -b
```

## 13.3 Build

```bash
set -o pipefail
UDID="$(Scripts/choose_simulator.sh)"

xcodebuild \
  -project KidPad.xcodeproj \
  -scheme KidPad \
  -configuration DebugPublic \
  -destination "platform=iOS Simulator,id=$UDID" \
  -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build \
  | tee artifacts/logs/build.log
```

If using a workspace, adapt the flag. Never hide the full log.

## 13.4 Test

```bash
xcodebuild \
  -project KidPad.xcodeproj \
  -scheme KidPad \
  -configuration DebugPublic \
  -destination "platform=iOS Simulator,id=$UDID" \
  -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  test \
  | tee artifacts/logs/test.log
```

Prefer `.xcresult`:

```bash
RESULT="artifacts/tests/KidPad-$(date -u +%Y%m%dT%H%M%SZ).xcresult"

xcodebuild \
  -project KidPad.xcodeproj \
  -scheme KidPad \
  -destination "platform=iOS Simulator,id=$UDID" \
  -derivedDataPath build/DerivedData \
  -resultBundlePath "$RESULT" \
  CODE_SIGNING_ALLOWED=NO \
  test
```

## 13.5 Install and launch

```bash
APP_PATH="$(
  find build/DerivedData/Build/Products \
    -path '*DebugPublic-iphonesimulator/*.app' \
    -maxdepth 3 \
    -print \
    -quit
)"

test -n "$APP_PATH"
test -d "$APP_PATH"

BUNDLE_ID="com.chrissotraidis.kidpad"

xcrun simctl install "$UDID" "$APP_PATH"
xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl launch \
  --console-pty \
  "$UDID" \
  "$BUNDLE_ID" \
  --ui-test-mode \
  > artifacts/logs/launch.log 2>&1 &
LAUNCH_PID=$!
sleep 2
kill "$LAUNCH_PID" 2>/dev/null || true
```

Do not rely on a blind fixed sleep for final automation. Add readiness signaling through logs, a test deep link, or UI tests.

## 13.6 Screenshot

```bash
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p artifacts/simulator
xcrun simctl io "$UDID" screenshot "artifacts/simulator/$STAMP.png"
ln -sfn "$STAMP.png" artifacts/simulator/latest.png
```

## 13.7 Video

```bash
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
VIDEO="artifacts/video/$STAMP.mp4"
mkdir -p artifacts/video

xcrun simctl io "$UDID" recordVideo --codec=h264 "$VIDEO" &
REC_PID=$!

# Run a deterministic UI test or test scenario here.

kill -INT "$REC_PID"
wait "$REC_PID" || true
```

---

# 14. Native Input Implementation Loop

## 14.1 UIKit view

Implement a `RasterCanvasView` that overrides:

- `touchesBegan`
- `touchesMoved`
- `touchesEnded`
- `touchesCancelled`

It must:

- filter/control simultaneous touch;
- identify `UITouch.TouchType.pencil`;
- use coalesced touches;
- use predicted touches on a transient layer;
- capture force, maximum force, altitude, azimuth, roll, timestamp;
- handle unavailable fields;
- map view to logical coordinates;
- emit `DrawingInput`.

## 14.2 Hover

Add supported hover handling through the current stable UIKit API. Keep hover output on a preview layer.

## 14.3 Pencil interactions

Attach `UIPencilInteraction` and implement:

- double-tap;
- squeeze;
- feature availability;
- system preferences.

No Pencil gesture may be the only access path to a required tool.

## 14.4 Synthetic input adapter

Create a protocol:

```swift
protocol DrawingInputSource {
    func events() -> AsyncStream<DrawingInput>
}
```

Implement:

- UIKit source;
- JSON trace source;
- UI-test scenario source.

A trace fixture:

```json
{
  "schemaVersion": 1,
  "canvas": { "width": 1920, "height": 1200 },
  "events": [
    {
      "phase": "began",
      "source": "syntheticTest",
      "x": 100,
      "y": 100,
      "timestamp": 0.000,
      "pressure": 0.2,
      "altitude": 1.1,
      "azimuth": 0.0,
      "roll": 0.0
    },
    {
      "phase": "moved",
      "source": "syntheticTest",
      "x": 700,
      "y": 500,
      "timestamp": 0.250,
      "pressure": 0.8,
      "altitude": 0.6,
      "azimuth": 1.2,
      "roll": 0.4
    },
    {
      "phase": "ended",
      "source": "syntheticTest",
      "x": 900,
      "y": 550,
      "timestamp": 0.350,
      "pressure": 0.4
    }
  ]
}
```

## 14.5 Hardware truth

Synthetic traces prove tool handling, not physical sensor behavior. Keep that distinction in status files.

---

# 15. Vertical Slice Loop

Implement in this order:

1. blank native app;
2. SwiftUI workspace;
3. UIKit canvas host;
4. committed bitmap;
5. transient surface;
6. coordinate mapper;
7. simple Pencil tool;
8. current color;
9. undo snapshot;
10. autosave;
11. one golden-image test;
12. one UI test;
13. simulator screenshot;
14. state update;
15. local commit.

After each step:

```text
build → test → launch → capture → inspect → update state
```

Do not build all features before the first launch.

---

# 16. Tool Implementation Loop

For each tool:

1. Select an unimplemented P0 fidelity row.
2. Confirm source edition and rights status.
3. Record observable behavior.
4. Create starting canvas fixture.
5. Create deterministic input trace.
6. Create expected output reference.
7. Implement the smallest general engine primitive.
8. Add unit tests.
9. Add golden test.
10. Add UI selection/use test.
11. Run all related tests.
12. Run full regression suite.
13. Launch and capture.
14. Compare.
15. Fix until pass.
16. Update parity matrix.
17. Update known issues.
18. Commit explicit files.

Do not add a one-off special case when a reusable primitive is the correct solution.

Recommended order:

1. pencil;
2. line;
3. rectangle;
4. oval;
5. fill;
6. basic eraser;
7. TNT;
8. stamp;
9. alphabet;
10. moving van;
11. Wacky Brush framework;
12. representative brush;
13. mixer framework;
14. representative effect;
15. remaining P0 variants.

---

# 17. Golden-Image Testing

## 17.1 Canonical rendering

Tests must use:

- fixed canvas size;
- fixed color space;
- fixed scale;
- fixed seed;
- fixed timestamps;
- fixed input trace;
- no device-dependent font unless tolerated/documented.

## 17.2 Comparison script

Create `Scripts/compare_images.py` using Pillow:

- decode RGBA;
- verify dimensions;
- count differing pixels;
- compute max channel difference;
- write amplified diff image;
- exit nonzero when threshold fails.

Default deterministic threshold: zero differing pixels.

A nonzero tolerance needs a fixture-specific justification committed with the test.

## 17.3 Visual artifact output

On failure:

```text
artifacts/diffs/<fixture>/
  expected.png
  actual.png
  diff.png
  metrics.json
```

## 17.4 Reference normalization

Never alter a reference silently. Record:

- crop;
- scale;
- color conversion;
- alpha normalization;
- edition;
- capture source.

---

# 18. Audio Fidelity Loop

For each sound behavior:

1. identify source and rights status;
2. record trigger phase;
3. record whether it loops, rate-limits, or randomizes;
4. record duration and sample metadata when lawful;
5. implement policy;
6. test event sequence;
7. use exact sample only in cleared/private configuration;
8. use clean-room sample in public fallback;
9. never label a replacement exact.

The sound engine must avoid starting hundreds of players during a stroke. Use a rate limit or loop policy matching observed behavior.

---

# 19. Asset Policy Enforcement

## 19.1 Validator behavior

`Scripts/validate_assets.py` must:

- read `AssetLedger.json`;
- enumerate all resources included in target;
- hash each file;
- require a ledger record;
- check allowed build;
- check status;
- check attribution;
- fail on duplicates with conflicting status;
- produce JSON and Markdown report.

## 19.2 Allowed public statuses

Only:

- `verified-public-domain`
- `licensed`
- `clean-room-original`

## 19.3 Forbidden public statuses

- `research-only`
- `blocked`
- `unknown`
- missing record

## 19.4 Xcode build integration

Add a prebuild validation script for `ReleasePublic`. Asset-policy tests must also run independently.

## 19.5 Quarantined exact assets

Private exact assets are loaded from a path such as:

```text
KIDPAD_FIDELITY_ASSET_ROOT=/absolute/path/to/ref/asset-pack
```

Rules:

- no default path outside repo;
- no copy into app archive;
- no fallback that silently includes them;
- developer UI clearly marks `PRIVATE FIDELITY BUILD — DO NOT DISTRIBUTE`;
- screenshots using those assets remain local unless authorized.

---

# 20. Persistence and Recovery Loop

Implement:

1. in-memory document;
2. package manifest;
3. canvas PNG or binary;
4. atomic save;
5. autosave debounce;
6. backup;
7. last-document bookmark;
8. launch restoration;
9. forced-termination test;
10. corrupted-primary recovery test;
11. PNG export.

Test forced termination through Simulator:

```bash
xcrun simctl terminate "$UDID" "$BUNDLE_ID"
xcrun simctl launch "$UDID" "$BUNDLE_ID"
```

Verify restored image through a deterministic screenshot or internal test hook.

---

# 21. UI Test Harness

Add stable accessibility identifiers:

- `workspace`
- `canvas`
- `tool.save`
- `tool.pencil`
- `tool.line`
- `tool.rectangle`
- `tool.oval`
- `tool.wackyBrush`
- `tool.mixer`
- `tool.fill`
- `tool.eraser`
- `tool.alphabet`
- `tool.stamp`
- `tool.movingVan`
- `tool.undo`
- `palette.current`
- `palette.color.<index>`

Launch arguments:

- `--ui-test-mode`
- `--reset-document`
- `--fixture <id>`
- `--disable-animations`
- `--deterministic-seed <value>`
- `--export-test-artifact <path>` where sandbox rules permit.

UI tests must not rely only on coordinate positions for controls. Use identifiers.

Canvas gestures may use coordinates because the canvas itself is the target. Engine correctness remains in trace tests.

---

# 22. Simulator Fidelity Scenarios

Create deterministic scenarios:

## Scenario S1 — Freehand

- blank canvas;
- select red;
- draw a curve;
- undo;
- redo/toggle;
- screenshot.

## Scenario S2 — Shapes

- line;
- rectangle;
- oval;
- color changes;
- screenshot.

## Scenario S3 — Fill

- draw closed rectangle;
- fill inside;
- verify outside unchanged.

## Scenario S4 — Wacky Brush

- select representative brush;
- run fixed path/seed;
- verify spacing and orientation.

## Scenario S5 — TNT

- preloaded drawing;
- trigger effect;
- verify animation completion and blank/target state;
- verify undo.

## Scenario S6 — Stamp and alphabet

- place stamp;
- place character;
- verify preview and commit.

## Scenario S7 — Moving Van

- create region;
- move;
- verify source/destination.

## Scenario S8 — Persistence

- draw;
- terminate;
- relaunch;
- verify.

## Scenario S9 — Rotation and multitasking

- landscape;
- portrait;
- compact size;
- verify controls and coordinate mapping.

## Scenario S10 — Synthetic Pencil

- inject pressure/tilt/azimuth/roll;
- verify native-mode brush response;
- verify classic mode ignores configured values.

Record screenshots/video for each.

---

# 23. Physical Apple Pencil Validation

## 23.1 Prerequisites

- physical compatible iPad;
- correct Apple Pencil generation;
- Developer Mode;
- Xcode signing team;
- cable or paired wireless device;
- installed debug build.

Do not store credentials.

## 23.2 Test groups

### H1 — Basic Pencil touch

- touch source is `.pencil`;
- location correct;
- no coordinate offset;
- down/move/up complete;
- finger policy works.

### H2 — Pressure

- raw force varies;
- normalized curve is stable;
- minimum and maximum clamps;
- classic mode behavior unchanged;
- native mode visible response.

### H3 — Tilt and azimuth

- diagnostics show expected changes;
- directional brush orientation updates;
- unavailable values handled.

### H4 — Hover

- preview appears before contact;
- preview location aligns;
- system preference respected;
- no ghost remains after exit.

### H5 — Double tap

- event received;
- preferred action handled;
- tool/eraser switch;
- no accidental destructive action.

### H6 — Squeeze

Apple Pencil Pro only:

- phase received;
- palette appears;
- hover pose used when available;
- cancel works;
- haptic feedback appropriate.

### H7 — Roll

Apple Pencil Pro only:

- roll value changes;
- mapped brush rotates;
- no jump at angle wrap;
- classic mode optional.

### H8 — Palm rejection

- hand contact during Pencil stroke does not draw;
- controls do not accidentally trigger;
- finger mode still works when no Pencil stroke active.

### H9 — Performance

- standard and fast strokes;
- 60/120 Hz frame behavior;
- Instruments trace;
- thermal/memory observations.

## 23.3 Evidence

For each test:

- device model;
- iPadOS;
- Pencil model;
- app commit;
- screen recording;
- diagnostics JSON;
- result;
- issue ID if failed.

If hardware is unavailable, leave the status `HARDWARE_VALIDATION_PENDING`. Do not fabricate.

---

# 24. Failure Taxonomy

Classify every failure before fixing.

## F1 — Environment

Examples:

- missing Xcode;
- no Simulator runtime;
- incompatible command-line tools.

Response:

- inspect exact paths/versions;
- use `DEVELOPER_DIR`;
- install permitted component;
- document blocker.

## F2 — Project generation

Examples:

- invalid `project.yml`;
- missing scheme;
- target membership.

Response:

- run XcodeGen verbosely;
- inspect generated project;
- minimize configuration;
- add validation test.

## F3 — Compile

Response:

- read first root error, not final cascade;
- preserve full log;
- fix type/API/availability issue;
- rerun narrow build, then full build.

## F4 — Test

Response:

- isolate failing test;
- reproduce with fixed fixture;
- inspect artifacts;
- determine product bug versus expected-fixture bug;
- never update golden merely to make test green without explaining the change.

## F5 — Install/launch

Response:

- inspect app path;
- bundle ID;
- Simulator state;
- crash log;
- `simctl spawn log show`;
- relaunch with console.

## F6 — Runtime crash

Response:

- capture crash;
- symbolicate if needed;
- add regression test;
- fix root cause;
- rerun scenario.

## F7 — Visual mismatch

Response:

- inspect dimension/color/transform/seed/compositing;
- generate diff;
- compare source edition;
- fix or document accepted difference.

## F8 — Input mismatch

Response:

- log view and logical coordinates;
- inspect transforms;
- compare coalesced/predicted order;
- test rotation and scale.

## F9 — Audio mismatch

Response:

- inspect policy timing and overlap;
- confirm asset status;
- do not substitute restricted sample into public target.

## F10 — Performance

Response:

- profile;
- identify CPU/GPU/main-thread bottleneck;
- optimize specific primitive;
- avoid premature full-engine rewrite.

## F11 — Asset-rights blocker

Response:

- move asset to Quarantined;
- substitute a clean-room placeholder;
- continue engineering;
- add rights task;
- do not ship.

## F12 — Simulator limitation

Response:

- add synthetic engine test;
- add physical procedure;
- mark hardware pending;
- continue all other work.

## F13 — Scope ambiguity

Response:

- choose the narrowest reversible interpretation consistent with PRD;
- record assumption;
- continue;
- do not stop for a noncritical clarification.

---

# 25. Loop Control and Anti-Stall Rules

## 25.1 Main loop

```text
while status is not a verified terminal state:
    load PRD and state
    inspect worktree and environment
    run the current baseline test/build
    select highest-priority unmet goal with satisfied dependencies
    define a concrete observable pass condition
    implement the smallest end-to-end increment
    run narrow tests
    run regression tests
    build
    launch when relevant
    capture evidence
    compare against expected/reference
    classify any failure
    fix root cause
    update state, matrices, issues, and evidence
    commit the coherent increment
```

## 25.2 Same-failure rule

After the same root failure occurs three times:

1. stop repeating the same command;
2. write a minimal reproduction;
3. reduce the system;
4. inspect authoritative documentation;
5. change strategy;
6. record the pivot.

## 25.3 No-progress rule

After five iterations without a newly passing test, successful launch, reduced blocker, or verified artifact:

- write a checkpoint in `AGENT_STATE.md`;
- list attempted hypotheses;
- identify the earliest broken assumption;
- revert only the agent’s uncommitted experimental files if safe;
- pursue a different path.

## 25.4 Golden-file rule

Never regenerate all goldens after a broad code change without reviewing diffs. Each changed golden needs:

- reason;
- source/reference;
- before/after artifact;
- approval status.

## 25.5 Scope rule

Do not begin P2 work while a P0 goal fails.

## 25.6 “Compiles” is not done

A successful compile is evidence for G1 only.

## 25.7 “Launches” is not done

A launch screenshot is evidence for G2 only.

## 25.8 “Looks right” is not done

Fidelity requires fixtures and comparison.

---

# 26. Commit Discipline

After a coherent passing increment:

```bash
git status --short
git diff --stat
git diff -- <explicit paths>
git add -- <explicit paths>
git diff --cached --stat
git diff --cached
git commit -m "feat(canvas): add native raster pencil vertical slice"
```

Suggested commit types:

- `chore(repo):`
- `docs(prd):`
- `feat(canvas):`
- `feat(tool):`
- `feat(pencil):`
- `feat(audio):`
- `feat(document):`
- `test(golden):`
- `fix(input):`
- `fix(fidelity):`
- `legal(asset):`

Do not push without explicit authorization.

---

# 27. Iteration Report Template

Append a concise record to `AGENT_STATE.md` or `Docs/AgentLog.md`:

```markdown
## Iteration 014 — 2026-08-20T18:42:00Z

### Goal
G4 / Paint Can bounded fill

### Pass condition
A fixed 64×64 enclosed-region fixture fills exactly and leaves exterior pixels unchanged.

### Changes
- Added independent scanline flood fill.
- Added cancellation check.
- Added one-action undo transaction.
- Added fixture `fill-bounded-001`.

### Evidence
- Unit tests: 8 passed.
- Golden test: exact 0-pixel difference.
- Full suite: 176 passed, 0 failed.
- Screenshot: `artifacts/simulator/...png`.

### Remaining difference
Textured fill is P1 and not implemented.

### Next action
Implement whole-canvas replacement variant.
```

---

# 28. Definition of Working

The application is “working in Simulator” only when all are true:

- build succeeds;
- tests succeed;
- app installs;
- app launches;
- workspace is visible;
- native canvas is visible;
- finger/mouse gesture draws;
- tools change;
- undo works;
- autosave/reopen works;
- export works;
- screenshot evidence exists;
- no web view implements core drawing;
- public asset validator passes.

The application is “working with Apple Pencil” only when physical compatible hardware tests pass. Synthetic traces are necessary but not sufficient.

The application is “exactly faithful” only for behaviors and assets with recorded reference evidence. Do not generalize from one tool.

The application is “public release ready” only when the release bundle contains no unverified assets and naming/source licensing are resolved.

---

# 29. Required Final Report

When the highest achievable state is reached, create `artifacts/reports/FINAL_REPORT.md` and summarize:

## 29.1 Build

- branch;
- commit;
- Xcode;
- SDK;
- deployment target;
- build command;
- result.

## 29.2 Tests

- totals;
- failed/skipped;
- `.xcresult`;
- golden coverage;
- UI scenarios;
- performance.

## 29.3 Simulator

- model;
- OS;
- UDID;
- install/launch result;
- screenshots;
- videos;
- logs.

## 29.4 Features

Table:

| Feature | Implemented | Simulator verified | Hardware verified | Fidelity status | Asset status |
|---|---:|---:|---:|---|---|

## 29.5 Legal/assets

- public name status;
- KID PIX disclaimer;
- source license;
- upstream license conflict status;
- asset counts by status;
- blocked exact assets;
- written permissions.

## 29.6 Hardware

- devices tested;
- Pencil features;
- pending items;
- exact reason.

## 29.7 Known issues

- severity;
- impact;
- workaround;
- next action.

## 29.8 Completion state

Use one state from Section 5 and explain why.

Do not claim `COMPLETE` when the truthful state is `HARDWARE_VALIDATION_PENDING` or `LEGAL_ASSET_BLOCKED`.

---

# 30. Reference Start List

Record these in `ref/sources.lock.json`:

## Core implementation reference

- https://github.com/vikrum/kidpix
- https://kidpix.app/
- https://github.com/vikrum/kidpix/blob/main/README.md
- https://github.com/vikrum/kidpix/blob/main/LICENSE
- https://github.com/vikrum/kidpix/blob/main/package.json
- https://github.com/vikrum/kidpix/blob/main/NOTICE
- https://github.com/vikrum/kidpix/issues/7
- https://github.com/vikrum/kidpix/issues/8
- https://github.com/vikrum/kidpix/issues/32

## History

- https://red-green-blue.com/kid-pix-the-early-years
- https://design.uoregon.edu/apple-honors-hickman-innovator
- https://en.wikipedia.org/wiki/Kid_Pix
- https://www.youtube.com/watch?v=csalhuSixQU

## Historical software leads

- https://www.macintoshrepository.org/92-kid-pix-1-0
- https://mactrove.com/software/kid-pix

## Emulator

- https://www.gryphel.com/c/minivmac/
- https://www.gryphel.com/c/minivmac/hardware.html

## Current product and trademark

- https://apps.apple.com/us/app/kid-pix-5-the-steam-edition/id1249381439
- https://www.mackiev.com/kidpix/index.html
- https://www.mackiev.com/update_center/kidpix/kpselect.html
- https://tsdr.uspto.gov/#caseNumber=74289094&caseSearchType=US_APPLICATION&caseType=DEFAULT&searchType=statusSearch
- https://trademarks.justia.com/742/89/kid-74289094.html

## Naming research and collisions

- https://apps.apple.com/us/app/kiddopaint-kids-coloring-book/id6744039262
- https://tsdr.uspto.gov/#caseNumber=74495238&caseSearchType=US_APPLICATION&caseType=DEFAULT&searchType=statusSearch
- https://tsdr.uspto.gov/#caseNumber=85255750&caseSearchType=US_APPLICATION&caseType=DEFAULT&searchType=statusSearch
- https://furm.com/trademarks/kidpad-85255750
- https://www.trademarkelite.com/europe/trademark/trademark-detail/009777731/KidPad
- https://dijitalmedyavecocuk.bilgi.edu.tr/2021/01/01/dijital-oykuleme-teknolojisinin-cocuklar-icin-faydalari/
- https://www.quest.gr/el/archive/nea-bitmore-kidpad-apo-ten-info-quest-technologies-teleio-paschalino-doro

## Apple

- https://developer.apple.com/app-store/review/guidelines/
- https://developer.apple.com/kids/
- https://developer.apple.com/documentation/uikit/uitouch
- https://developer.apple.com/documentation/uikit/apple-pencil-interactions
- https://developer.apple.com/documentation/uikit/uipencilinteraction
- https://developer.apple.com/documentation/uikit/adopting-hover-support-for-apple-pencil
- https://developer.apple.com/documentation/uikit/minimizing-latency-with-predicted-touches
- https://developer.apple.com/documentation/pencilkit/
- https://developer.apple.com/documentation/pencilkit/pkcanvasview
- https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices
- https://developer.apple.com/documentation/xcode/interacting-with-your-app-in-the-ios-or-ipados-simulator

## Licensing

- https://www.gnu.org/licenses/gpl-3.0.en.html
- https://www.gnu.org/licenses/gpl-faq.en.html
- https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
- https://www.apache.org/licenses/LICENSE-2.0

---

# 31. Master Execution Checklist

The agent must actively execute this checklist.

## Foundation

- [ ] Read PRD and repository instructions.
- [ ] Inspect Git status and preserve user work.
- [ ] Create/reuse feature branch.
- [ ] Record environment.
- [ ] Create state files.
- [ ] Create `ref/`.
- [ ] Add safe `.gitignore`.
- [ ] Pin upstream reference.
- [ ] Create source lock and asset ledger.
- [ ] Establish clean-room branch policy.
- [ ] Establish public/private build configurations.
- [ ] Implement asset validator.

## Project

- [ ] Generate native Xcode project.
- [ ] Add application and test targets.
- [ ] Build in iPad Simulator.
- [ ] Run tests.
- [ ] Install and launch.
- [ ] Capture screenshot.

## Engine

- [ ] Bitmap surface.
- [ ] Transient/preview surfaces.
- [ ] Coordinate mapper.
- [ ] Input normalization.
- [ ] Coalesced touches.
- [ ] Predicted touches.
- [ ] Deterministic test source.
- [ ] Pencil tool.
- [ ] Undo.
- [ ] Golden test.

## P0 tools

- [ ] Line.
- [ ] Rectangle.
- [ ] Oval.
- [ ] Wacky Brush framework.
- [ ] Representative Wacky Brushes.
- [ ] Mixer framework.
- [ ] Representative effects.
- [ ] Fill.
- [ ] Eraser.
- [ ] TNT.
- [ ] Alphabet.
- [ ] Stamps.
- [ ] Moving Van.
- [ ] Undo Guy.
- [ ] Color palettes.
- [ ] Sound policy.

## Documents

- [ ] Autosave.
- [ ] Atomic write.
- [ ] Reopen.
- [ ] Recovery.
- [ ] PNG export.
- [ ] Thumbnail.

## Fidelity

- [ ] Build fidelity matrix.
- [ ] Capture lawful references.
- [ ] Create input traces.
- [ ] Create goldens.
- [ ] Add deterministic seed.
- [ ] Compare and fix.
- [ ] Document differences.
- [ ] Keep restricted assets quarantined.

## Platform

- [ ] Landscape.
- [ ] Portrait.
- [ ] split view/Stage Manager.
- [ ] iPhone compact layout if P1.
- [ ] accessibility identifiers.
- [ ] VoiceOver.
- [ ] keyboard/pointer.
- [ ] no-network verification.

## Pencil

- [ ] Pressure implementation.
- [ ] Tilt.
- [ ] Azimuth.
- [ ] Hover.
- [ ] Double tap.
- [ ] Squeeze.
- [ ] Roll.
- [ ] Palm rejection.
- [ ] Diagnostics.
- [ ] Synthetic tests.
- [ ] Physical test report.

## Release

- [ ] Public release build passes asset validation.
- [ ] No quarantined resources.
- [ ] README disclaimer.
- [ ] Code license.
- [ ] third-party notices.
- [ ] naming status.
- [ ] privacy status.
- [ ] hardware status.
- [ ] final clean-checkout test.
- [ ] final report.

---

# 32. Final Operating Instruction

Begin with the current repository state. Do not merely repeat this plan.

At every point, choose the smallest action that produces verifiable forward progress toward the highest-priority unmet goal. Build early. Launch early. Capture evidence. Make rendering deterministic. Use reference material rigorously. Preserve exact-fidelity research without leaking unverified assets into public output. Separate Simulator success from physical Apple Pencil success. Tell the truth in status files.

Continue until the repository reaches the highest objectively supportable completion state.

# End of Agent Loop
