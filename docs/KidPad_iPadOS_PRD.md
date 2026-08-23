# KidPad for iPad
## Product Requirements Document for a Native, Apple Pencil–First Restoration of the Classic Kid Pix Experience

> **Document status:** Draft for implementation  
> **Version:** 0.2 — KidPad naming revision  
> **Date:** August 20, 2026  
> **Primary platform:** iPadOS  
> **Secondary platform:** iOS  
> **Canonical product name:** KidPad  
> **Repository name:** `kidpad`  
> **Historical reference:** Kid Pix, created by Craig Hickman  
> **Intended implementation:** Native Swift application with a custom raster canvas and direct Apple Pencil input  
> **Distribution target:** Open-source GitHub release first; App Store distribution only after all intellectual-property and licensing gates pass  
> **Legal status:** This document is a technical and product risk assessment, not legal advice.

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Binding Product Decisions](#2-binding-product-decisions)
3. [Product Context and Opportunity](#3-product-context-and-opportunity)
4. [Historical and Source Context](#4-historical-and-source-context)
5. [Product Vision](#5-product-vision)
6. [Target Users and Jobs to Be Done](#6-target-users-and-jobs-to-be-done)
7. [Goals, Non-Goals, and Success Criteria](#7-goals-non-goals-and-success-criteria)
8. [Naming, Branding, and Positioning](#8-naming-branding-and-positioning)
9. [Legal, Licensing, Trademark, and Asset Analysis](#9-legal-licensing-trademark-and-asset-analysis)
10. [Fidelity Strategy and Reference Hierarchy](#10-fidelity-strategy-and-reference-hierarchy)
11. [Product Scope](#11-product-scope)
12. [Detailed Functional Requirements](#12-detailed-functional-requirements)
13. [Apple Pencil and Input Requirements](#13-apple-pencil-and-input-requirements)
14. [User Experience and Interface Requirements](#14-user-experience-and-interface-requirements)
15. [Accessibility, Privacy, and Child-Safety Requirements](#15-accessibility-privacy-and-child-safety-requirements)
16. [Technical Architecture](#16-technical-architecture)
17. [Rendering and Graphics Architecture](#17-rendering-and-graphics-architecture)
18. [Persistence, Documents, Export, and Undo](#18-persistence-documents-export-and-undo)
19. [Audio Architecture](#19-audio-architecture)
20. [Asset Provenance and Reference Workspace](#20-asset-provenance-and-reference-workspace)
21. [Repository and Project Structure](#21-repository-and-project-structure)
22. [Testing and Quality Strategy](#22-testing-and-quality-strategy)
23. [Performance and Reliability Requirements](#23-performance-and-reliability-requirements)
24. [Implementation Phases and Milestones](#24-implementation-phases-and-milestones)
25. [Definition of Done and Release Gates](#25-definition-of-done-and-release-gates)
26. [Risks and Mitigations](#26-risks-and-mitigations)
27. [Open Questions](#27-open-questions)
28. [Appendix A: Initial Feature-Parity Inventory](#appendix-a-initial-feature-parity-inventory)
29. [Appendix B: Asset Ledger Schema](#appendix-b-asset-ledger-schema)
30. [Appendix C: Reference Sources](#appendix-c-reference-sources)
31. [Appendix D: Recommended Notices](#appendix-d-recommended-notices)
32. [Appendix E: Architecture Decision Records](#appendix-e-architecture-decision-records)

---

# 1. Executive Summary

KidPad is a proposed native iPadOS and iOS restoration of the early Kid Pix drawing experience. It should recreate the immediacy, visual personality, surprising tools, playful sounds, destructive effects, and low-friction creative loop that made the original software distinctive, while treating Apple Pencil as the modern equivalent of the mouse input around which the original was designed.

The product is not intended to be a conventional professional illustration application. It is an art toy: immediate, expressive, forgiving, surprising, and safe to explore. A child should be able to launch it and begin making something without reading instructions, managing layers, creating an account, or understanding files. An adult who used Kid Pix in the early 1990s should recognize the behavior, rhythm, and personality immediately.

The project is technically feasible. The existing `vikrum/kidpix` repository is an HTML/JavaScript reimplementation built around a small set of raster concepts: layered HTML canvases, bitmap stamps, procedural brush functions, direct pixel manipulation, destructive whole-canvas effects, sounds, and a simple tool state machine. Its implementation provides a valuable behavioral map, but it is not a native codebase and its touch support merely converts touch events into synthetic mouse events. A native implementation can preserve the original behavior while adding direct Apple Pencil pressure, tilt, azimuth, hover, double-tap, squeeze, roll, coalesced touches, predicted touches, and appropriate palm-rejection behavior.

The most serious constraints are not technical:

1. **KID PIX remains an actively used registered trademark.** Software MacKiev currently sells an iPad product named `KID PIX 5 – The STEAM Edition`. A public App Store application must not be named simply `KID PIX`, use the current KID PIX branding, or imply official affiliation without written authorization.

2. **The legal status of the original assets is not uniform.** Historical sources clearly distinguish the free black-and-white version distributed in 1989 from the $25 color version released in 1990 and the commercial Broderbund edition released in 1991. The iconic color graphics, expanded stamps, spoken alphabet, sounds, mixer effects, and later interface art should be presumed copyrighted unless their rights are independently verified or licensed.

3. **The upstream JavaScript repository has a license inconsistency.** Its top-level `LICENSE` is GPLv3 and GitHub identifies the repository as GPL-3.0, while `package.json` says MIT. The maintainer has directed users to the repository license. The safe assumption is that copied or translated upstream code is GPLv3 unless the maintainer provides written clarification or a separate license.

4. **The App Store and actual Apple Pencil hardware impose separate acceptance paths.** Simulator can build, launch, test layouts, run deterministic synthetic input traces, and perform visual regression. It cannot prove pressure, tilt, hover distance, barrel roll, squeeze, haptics, palm rejection, or device performance. Those require a physical compatible iPad and Apple Pencil.

Accordingly, this PRD adopts the following strategy:

- Build a **clean-room native implementation** in Swift, using the original behavior and the JavaScript project as references rather than mechanically translating GPL source.
- License original project code under **Apache License 2.0**, subject to final maintainer and legal review.
- Use **KidPad** as the canonical product, repository, target, scheme, and documentation name. Do not silently substitute another working title. Public commercial release still requires a formal trademark and marketplace clearance because a naming decision is not itself legal clearance.
- Keep all unverified original graphics and audio in a local, gitignored `ref/` or `Assets/Quarantined/` workspace.
- Permit an exact-fidelity developer build for private comparison, but make the release build fail when it includes any asset not classified as `verified-public-domain`, `licensed`, or `clean-room-original`.
- Pursue written permission from relevant rights holders if the project is to ship the iconic color-and-sound experience exactly.
- Treat a verified 1989 monochrome profile as a separate possible public-release path.
- Require physical-device validation for full Apple Pencil completion.

This produces a project that can move quickly without pretending unresolved rights questions do not exist.

---

# 2. Binding Product Decisions

The following decisions govern the initial implementation. Changing one requires an explicit Architecture Decision Record or PRD revision.

| Decision | Requirement |
|---|---|
| Product form | Native Swift iOS/iPadOS application, not a website wrapper |
| Primary device | iPad in landscape orientation |
| Secondary devices | iPad portrait and iPhone compact layout |
| Primary input | Apple Pencil on iPad |
| Secondary input | Finger, mouse, trackpad, and keyboard |
| UI framework | SwiftUI for application shell and adaptive controls |
| Canvas/input framework | Custom UIKit canvas hosted from SwiftUI |
| Rendering foundation | Core Graphics/CGBitmapContext first; Accelerate/Core Image/Metal only where justified |
| Primary data model | Destructive raster bitmap with transient preview and effect surfaces |
| PencilKit | Not the primary drawing engine; may be used only for isolated optional features |
| Source strategy | Clean-room native reimplementation by default |
| New source-code license | Apache-2.0, provisional pending final review |
| Upstream JS usage | Behavioral reference; do not copy or line-translate without switching to GPL-compatible handling |
| Product name | KidPad |
| Public use of “Kid Pix” | Historical/nominative reference only unless written permission is obtained |
| Exact commercial-era assets | Allowed in private reference/fidelity builds only until rights are verified |
| App networking | None in v1 |
| Analytics/ads/accounts | None |
| Persistence | Local document storage and autosave |
| Export | PNG first; JPEG and system share optional |
| Cloud/backend | Out of scope |
| Simulator | Required automated acceptance platform |
| Physical iPad | Required for full Pencil and performance acceptance |
| App Store | Not a release target until naming, asset, license, privacy, and hardware gates pass |

---

# 3. Product Context and Opportunity

## 3.1 The product gap

There is already an official modern iPad product, `KID PIX 5 – The STEAM Edition`, sold by Software MacKiev. It is a large, expanded multimedia creativity suite. It is not the same product concept as a small, direct restoration of the early Kid Pix paint experience.

The proposed opportunity is narrower:

- a lightweight native raster art toy;
- immediately recognizable to people who used early Kid Pix;
- fully usable offline;
- optimized for Apple Pencil;
- open source;
- faithful to the compact early toolset and personality;
- technically simple enough to preserve and maintain.

A web reimplementation already exists at `kidpix.app`, but it has a fixed large canvas, browser-oriented controls, primitive touch translation, open tablet-layout issues, and no access to the full expressive Apple Pencil pipeline. The native project is justified only if it becomes materially better than a packaged webpage.

## 3.2 Why the iPad is the right modern platform

The original design was built around a child’s ability to point directly with a mouse without becoming trapped by menus or document-management conventions. An iPad and Apple Pencil provide an even more direct model:

- The canvas is physically under the user’s hand.
- Pencil pressure can enlarge or intensify selected tools.
- Tilt and azimuth can orient brush stamps.
- Hover can preview the active tool or stamp.
- Double-tap can switch between a tool and eraser.
- Apple Pencil Pro squeeze can reveal a palette without permanently occupying canvas space.
- Apple Pencil Pro barrel roll can rotate directional brushes.
- Finger input can remain available for tool selection, touch drawing, panning, or child-friendly operation.
- The app can launch straight into the canvas and autosave silently.

## 3.3 Why this should remain an art toy

The project should resist the temptation to become Procreate for children. Its value comes from constraints and personality:

- No layer hierarchy in the primary interface.
- No brush marketplace.
- No account.
- No AI generation.
- No collaboration server.
- No timeline editor.
- No complex document setup.
- No modal tutorials.
- No blank professionalism.

The app should feel like a delightful machine with a small number of visible controls and unexpectedly rich behavior.

---

# 4. Historical and Source Context

## 4.1 Historical timeline relevant to scope and rights

The implementation and release strategy must distinguish at least three historical stages:

### 1989: free black-and-white version

Craig Hickman began distributing a free black-and-white version in November 1989. Hickman’s own historical account calls it “freeware.” The University of Oregon describes it as a free black-and-white version. Community references frequently call it the “public domain version,” but a release decision must locate and preserve the actual distribution notice or other explicit rights evidence rather than treating “freeware,” “free,” and “public domain” as interchangeable legal terms.

### 1990: Kid Pix Professional

Hickman developed an expanded color version sold for $25. His history specifically describes additions including:

- color;
- sounds in the interface;
- spoken alphabet;
- more wacky brushes;
- mixer effects;
- new hidden pictures;
- more rubber stamps;
- bilingual menus;
- a manual.

This is crucial: the features most people remember as the iconic color-and-sound experience were not necessarily part of the free 1989 distribution.

### 1991: commercial Broderbund release

Broderbund commercially released Kid Pix in 1991. The KID PIX trademark was later registered and has passed through multiple owners; Software MacKiev currently identifies itself as the owner and currently distributes a KID PIX iPad application.

## 4.2 Existing HTML/JavaScript reimplementation

The `vikrum/kidpix` repository describes itself as an HTML/JavaScript reimplementation. It provides:

- a main tool rail;
- color palettes;
- a 1920×1200 HTML canvas;
- layered main, temporary, preview, animation, and effect canvases;
- pixelated rendering with image smoothing disabled;
- tool modules;
- procedural brushes;
- stamps and sprite sheets;
- direct pixel effects;
- extensive sound files;
- localStorage persistence;
- a one-state swap-style undo;
- keyboard modifier behaviors;
- touch events converted into synthetic mouse events.

It is an excellent behavior and feature inventory. It is not sufficient evidence that every bundled asset is freely redistributable, and its code license must be handled as GPLv3 unless clarified.

## 4.3 Source-of-truth principle

No single reference is authoritative for product behavior, historical fidelity, asset rights, and naming. The project must maintain a reference hierarchy and record disagreements rather than silently choosing whichever version is convenient.

---

# 5. Product Vision

## 5.1 Vision statement

> Make the early Kid Pix creative experience feel native to the iPad: immediate enough for a child, faithful enough to trigger adult recognition, expressive enough to justify Apple Pencil, and legally disciplined enough to publish responsibly.

## 5.2 Product principles

### 1. Launch into creativity

The initial application view is the canvas. No account, feed, template chooser, or mandatory tutorial precedes drawing.

### 2. Safe experimentation

The user should feel able to press every button. Effects can be destructive and surprising, but undo and autosave make exploration safe.

### 3. Visual controls over text

The primary interface uses recognizable image controls. Text labels exist for accessibility and optional help, not as the main operating model.

### 4. Delight is functional

Sounds, cursor/hover previews, animated feedback, the Undo Guy, explosive erasers, and eccentric brushes are core product behavior, not decorative polish.

### 5. Fidelity over generic modernization

Modern platform behavior should support the old creative model rather than replacing it. A system share sheet is useful. Replacing the original tool rail with a generic professional toolbar is not.

### 6. Pencil-enhanced, not Pencil-exclusive

Apple Pencil is the highest-quality input path. Finger input must still work because the original target user includes young children and not every iPad owner has a Pencil.

### 7. Offline and private

A drawing application for children does not need analytics, ads, tracking, accounts, or a backend.

### 8. Provenance is a product feature

Every shipped asset must have an explicit status. Nostalgia does not erase copyright or trademark obligations.

---

# 6. Target Users and Jobs to Be Done

## 6.1 Primary user: nostalgic adult creator

**Profile:** Used Kid Pix in school or at home in the 1990s and now owns an iPad.

**Jobs:**

- Re-experience the distinctive interface, brushes, sounds, and effects.
- Make playful art without learning a professional illustration tool.
- Use Apple Pencil in a way that feels expressive but not serious.
- Export a drawing as an image.
- Share or contribute to an open-source preservation project.

**Success signal:** Within seconds of launch, the user says, “Yes, this is what Kid Pix felt like.”

## 6.2 Primary user: child

**Profile:** Roughly ages 5–11, with or without Apple Pencil.

**Jobs:**

- Start drawing without reading.
- Discover what tools do by pressing them.
- Make funny sounds and visual effects.
- Recover from mistakes.
- Save or show a picture to a parent.

**Success signal:** The child independently creates, changes tools, uses undo, and returns to the app later without adult instruction.

## 6.3 Secondary user: parent or educator

**Jobs:**

- Provide a safe, offline creative app.
- Avoid ads, account creation, or tracking.
- Export a child’s work.
- Understand what external actions are available.
- Lock external links or sharing behind a parental gate if the app enters Apple’s Kids Category.

## 6.4 Secondary user: preservationist or developer

**Jobs:**

- Inspect documented behavior and source provenance.
- Reproduce tests.
- Add a tool without destabilizing the canvas.
- Understand which assets may be distributed and which are reference-only.
- Compare the native app against historical builds and the JavaScript implementation.

---

# 7. Goals, Non-Goals, and Success Criteria

## 7.1 Product goals

### G1. Native operation

The app must be a native Swift iOS/iPadOS application. Core drawing must not run inside `WKWebView`.

### G2. Recognizable classic behavior

The initial parity target must include the essential early tool categories, destructive raster behavior, visual feedback, sound timing, and rapid tool switching.

### G3. Apple Pencil quality

The iPad experience must use direct UIKit touch input and support available Pencil features without compromising finger operation.

### G4. Exact-fidelity research

The project must be able to run a private developer fidelity build using reference assets and compare behavior against captured references.

### G5. Legally auditable release

No release artifact may contain an unverified or prohibited asset. Naming and source-code licensing must be explicit.

### G6. Open, reproducible development

A new contributor must be able to clone the public repository, generate the project, build, test, and launch the public-asset configuration without private files.

### G7. Child-safe operation

The v1 app must collect no data, require no account, contain no ads, and work offline.

## 7.2 Non-goals for v1

The following are explicitly out of scope:

- Recreating Kid Pix 5, Kid Pix 3D, Studio Deluxe, slide shows, storybooks, 3D characters, or multimedia presentation features.
- Cloud synchronization.
- User accounts.
- Social feeds or galleries.
- AI-generated art, text, or sounds.
- Online asset downloads.
- Collaboration.
- Professional vector editing.
- User-visible layer management.
- Brush scripting.
- Animation timelines.
- App Store submission before legal and hardware gates pass.
- Bundling Macintosh ROMs, disk images, manuals, or commercial assets without authorization.
- Supporting every historical platform or edition.
- Treating a browser wrapper as completion.

## 7.3 Quantitative success criteria

A release candidate must satisfy all of the following:

- The app builds and tests from a clean checkout using documented commands.
- It launches in at least one current iPad Simulator configuration.
- All P0 tools pass deterministic golden-image tests.
- All P0 tool flows pass UI tests in both landscape and portrait.
- The release asset-policy test reports zero `research-only`, `blocked`, or unclassified assets in the application bundle.
- The app performs no network requests during normal use.
- The app can create, autosave, reopen, and export a document.
- The main drawing loop maintains at least 60 frames per second on the physical baseline device during standard strokes.
- Coalesced touches are consumed where available.
- Pressure, altitude, azimuth, hover, double-tap, squeeze, and roll are feature-gated and tested on compatible physical hardware where applicable.
- A finger-only user can complete the full core workflow.
- All user-visible controls have accessibility labels and adequate target size.
- A completed rights and naming review exists for any public binary distribution.

## 7.4 Qualitative success criteria

- The application feels playful rather than clinical.
- Core operations are discoverable without tutorial text.
- Tool sounds occur at behaviorally correct moments.
- Drawing feedback is immediate.
- Original pixel art remains crisp under scaling.
- Modern controls do not visually overpower the classic workspace.
- The app does not falsely present itself as an official KID PIX product.

---

# 8. Naming, Branding, and Positioning

## 8.1 Binding naming decision

`KidPad` is the canonical product and project name.

This is no longer a placeholder. Implementation artifacts must use **KidPad** consistently unless the product owner explicitly changes the decision:

- product display name: `KidPad`;
- repository: `kidpad`;
- Xcode project, target, module, and scheme: `KidPad`;
- bundle identifier: `com.chrissotraidis.kidpad`;
- document type: `.kidpad`;
- URL scheme: `kidpad://`;
- build-condition namespace: `KIDPAD_*`;
- default implementation branch: `feature/native-kidpad`.

The name intentionally avoids presenting the application as the official `KID PIX` product while retaining a concise, child-friendly, iPad-native identity. It also communicates the product's central idea: a creative pad for kids and nostalgic adults, designed around touch and Apple Pencil.

The name decision does **not** eliminate the public-release clearance gate. A preliminary search performed on August 20, 2026 did not surface an obvious exact-name current iOS App Store application, but it did surface historical uses of `KidPad`, including earlier U.S. trademark filings, an expired European filing, an older Android parental-control application, children's tablet hardware, and an academic collaborative drawing/storytelling system. Those findings do not automatically block use, but they mean the name cannot honestly be described as legally cleared without a professional search.

Before an App Store or commercial launch, complete and archive:

- exact and confusingly-similar App Store searches in every intended storefront;
- USPTO word-mark and design-mark searches, including historical records;
- EUIPO and relevant national searches for intended markets;
- GitHub, package registry, domain, social-handle, and common-law web searches;
- App Store Connect name reservation or availability evidence;
- legal review of relevant classes and confusing similarity.

Engineering must proceed under KidPad while keeping identifiers centralized so a legally required emergency rename remains mechanically possible. That is a release-risk control, not permission to treat the name as provisional.

## 8.2 Names and branding that must not be used by default

### `KID PIX` or `Kid Pix`

Do not use this as the App Store product name, icon wordmark, bundle display name, or primary branding without written authorization from the current rights holder.

Historical prose may state that KidPad is an independent restoration or reimplementation inspired by the 1989/1990-era Kid Pix experience, provided the context is truthful and does not imply sponsorship, ownership, or official status.

### `KiddoPaint` or `Kiddo Paint`

The JavaScript reference implementation uses `KiddoPaint` as an internal namespace, but a current App Store application named `KiddoPaint: Kids Coloring Book` already exists. Do not adopt that public name or carry the upstream namespace into KidPad's public-facing architecture.

### Existing commercial logos and trade dress

Do not use Software MacKiev's current logo, current package branding, or any presentation that implies KidPad is an official KID PIX edition. Historical interface art and sounds must pass the asset ledger and release gates independently of the KidPad name.

## 8.3 Canonical identifiers

| Identifier | Canonical value |
|---|---|
| Product display name | KidPad |
| Repository | `kidpad` |
| Xcode project | `KidPad.xcodeproj` |
| Application target | `KidPad` |
| Xcode scheme | `KidPad` |
| Bundle identifier | `com.chrissotraidis.kidpad` |
| Document extension | `.kidpad` |
| URL scheme | `kidpad://` |
| Internal module prefix | Avoid prefixes; use `KP` only where an Objective-C-compatible symbol requires one |
| Default implementation branch | `feature/native-kidpad` |
| Private exact-fidelity configuration | `FidelityDev` |
| Public release configuration | `ReleasePublic` |
| Build-condition namespace | `KIDPAD_*` |

Place these values in centralized project configuration rather than scattering literals throughout the codebase. The product owner has fixed the name; centralization exists to support configuration hygiene and a legally compelled rename, not routine experimentation.

## 8.4 Positioning language

Recommended public description:

> KidPad is an independent, open-source raster art toy for iPad and iPhone. It restores the immediacy, humor, sound, and safe experimentation of classic children's paint software while being built natively for touch and Apple Pencil.

Recommended historical acknowledgement:

> Kid Pix was created by Craig Hickman. KID PIX is a registered trademark of its owner. KidPad is an independent project and is not affiliated with or endorsed by The Software MacKiev Company.

Do not market the public build as “the official Kid Pix port,” “Kid Pix for iPad,” “Kid Pix Classic,” or an authorized sequel unless written permission is obtained.

---

# 9. Legal, Licensing, Trademark, and Asset Analysis

## 9.1 Summary risk posture

| Area | Current posture | Required action |
|---|---|---|
| Name `KID PIX` | High risk for product branding | Written trademark authorization or different name |
| KidPad name | Canonical implementation name; preliminary search found historical uses and filings | Formal trademark and marketplace clearance before public commercial launch |
| 1989 free B&W program | Promising but not fully proven by secondary wording alone | Locate actual distribution notice and document provenance |
| 1990/1991 color graphics and sounds | Presumed copyrighted | License, replace, or keep reference-only |
| `vikrum/kidpix` source | Treat as GPLv3 | Clean-room implementation or GPL compliance/permission |
| Upstream package metadata | GPL/MIT conflict | Obtain written clarification before copying code |
| Upstream images/audio | Provenance unclear | Audit every file; quarantine by default |
| App Store | Name, IP, Kids, and functionality review required | Pass all gates before submission |
| Emulator ROM | Apple-copyrighted ROM cannot be bundled | User-supplied lawful ROM only |
| Reference videos/manuals | Copyrighted reference material | Store links/notes; do not redistribute without permission |

## 9.2 Trademark

The KID PIX word mark is reported as registered and renewed, registration number 1810528 and serial number 74289094, with Software MacKiev identified as the current owner. Software MacKiev’s current site also states that KID PIX is its registered trademark. The company currently offers `KID PIX 5 – The STEAM Edition` on the App Store.

Trademark rights are separate from copyright or code licensing. Even if a historical binary or source component is public domain, that does not grant a right to brand a current app with a confusingly similar active mark.

Apple’s App Review Guidelines also prohibit using another developer’s icon, brand, or product name in an app’s icon or name without approval. This creates both a legal and platform-review barrier.

### Trademark release gate

No App Store metadata, app icon, splash screen, bundle display name, or marketing page may use KID PIX as the product name unless the repository contains a written license or permission record reviewed by counsel.

## 9.3 Historical public-domain/freeware ambiguity

The upstream README says the 1989 version was released into the public domain. Wikipedia and community sources repeat that description. However:

- Craig Hickman’s own page calls the black-and-white version “freeware.”
- The University of Oregon says it was distributed free.
- “Freeware,” “free of charge,” and “public domain” are not legally identical.
- The actual 1989 distribution archive and any included notice are the best evidence.

The project must not claim an asset is verified public domain solely because a web page uses that phrase. The agent must:

1. Obtain a copy of the 1989 archive from a lawful source.
2. Preserve its original filename, hash, archive structure, and metadata.
3. Inspect all included text, About screens, resource strings, and documentation for rights language.
4. Save screenshots or extracted text of the relevant notice.
5. Record whether the dedication covers the executable, source, art, audio, or only distribution.
6. Seek legal review if the exact scope remains unclear.

Until that work is complete, 1989 assets are `research-only`, not automatically `verified-public-domain`.

## 9.4 Commercial-era assets

Hickman’s history expressly separates the free black-and-white version from the paid color edition and credits additional sound and technical contributors. The commercial editions also passed through Broderbund and later owners.

Therefore the following are presumptively restricted until proven otherwise:

- color interface graphics;
- color tool icons;
- commercial logo art;
- expanded rubber stamps;
- hidden-picture art;
- spoken alphabet recordings;
- tool sound effects;
- music or theme recordings;
- packaging and manuals;
- assets extracted from Windows, DOS, Mac, Amiga, FM Towns, or later commercial releases;
- assets in the JavaScript repository that originated from those releases.

An exact private development build may use lawfully obtained reference copies for comparison. A public release may not include them without a documented basis.

## 9.5 Upstream repository license

The repository has:

- a top-level GPLv3 `LICENSE`;
- GitHub’s GPL-3.0 classification;
- a `package.json` field that says MIT;
- a maintainer response telling a user to use the project according to the repository `LICENSE`;
- a `NOTICE` file containing several third-party MIT/BSD notices.

The safe engineering assumption is:

- the original project code is GPLv3;
- third-party modules retain their listed licenses;
- the `package.json` MIT field is inconsistent metadata, not sufficient permission to ignore the top-level license;
- assets may have separate rights from the source code.

### Consequences

A direct Swift translation, code copy, or close structural translation may be a derivative work and should be treated as GPLv3 unless the maintainer grants a separate license. GPLv3 distribution through the App Store is legally nuanced because the store’s technical and contractual terms may impose conditions that require careful compatibility analysis. This PRD does not declare that distribution categorically impossible; it declares it a legal-review requirement.

## 9.6 Recommended source strategy

The recommended implementation is clean-room at the code level:

- One research process documents observable behavior, input/output examples, screenshots, dimensions, timing, and algorithms at a functional level.
- Native implementation code is written from the behavior specification and public platform APIs.
- No JavaScript source is copied or line-translated.
- Any standard algorithm, such as scanline flood fill, is independently implemented or taken from a separately compatible source with attribution.
- The repository records which source influenced each behavior test.
- New original code is Apache-2.0.
- Asset licenses are tracked separately and are never implicitly covered by the source-code license.

This does not eliminate trademark or asset issues. It does create a cleaner code foundation.

## 9.7 Alternative GPL track

A GPL track is permitted for research:

- Create a clearly labeled branch or separate repository.
- Preserve GPL notices and source availability.
- Preserve third-party notices.
- Do not represent it as permissively licensed.
- Do not submit it to the App Store without legal review.
- Do not mix GPL-derived code into the clean-room branch.

## 9.8 App Store intellectual-property requirements

The App Review Guidelines require the developer to use only content created by the developer or content for which the developer has a license. The project must be prepared to provide authorization for third-party material during review.

The App Store build must contain:

- a license inventory;
- asset ledger;
- trademark/name decision;
- privacy policy if required;
- source acknowledgements;
- contact information;
- documentation of any commercial asset permissions.

## 9.9 Kids Category implications

If the app enters the Kids Category:

- select an Apple age band;
- external links and purchasing opportunities must be behind a parental gate;
- no third-party analytics;
- no third-party advertising;
- do not send personally identifiable information or device information to third parties;
- comply with applicable children’s privacy laws;
- treat drawings and photos as sensitive user content;
- provide a privacy policy if the app can share or handle personal information.

Recommended v1 posture:

- no analytics;
- no ads;
- no account;
- no backend;
- no in-app purchase;
- no external browser;
- no automatic upload;
- system export/share behind a parental gate when Kids Category rules apply;
- candidate age band: 6–8, subject to product and legal review.

## 9.10 Required legal artifacts

Before a public binary:

- `LEGAL_REVIEW.md`
- `TRADEMARK_CLEARANCE.md`
- `AssetLedger.json`
- `THIRD_PARTY_NOTICES.md`
- copies or hashes of written permissions
- source-code license decision
- App Store metadata review
- privacy assessment
- confirmation that no private reference files are bundled

---

# 10. Fidelity Strategy and Reference Hierarchy

## 10.1 Fidelity is multidimensional

“Exactly like Kid Pix” must be decomposed into testable categories:

1. **Visual fidelity**
   - workspace composition;
   - icon shape and scale;
   - palette;
   - cursor or hover representation;
   - pixelation and nearest-neighbor scaling;
   - stamp geometry;
   - tool animation;
   - output of deterministic effects.

2. **Interaction fidelity**
   - tool-selection sequence;
   - down/move/up behavior;
   - hidden variants;
   - size changes;
   - destructive versus previewed behavior;
   - undo semantics;
   - sound trigger timing.

3. **Audio fidelity**
   - exact sample where licensed;
   - trigger point;
   - looping behavior;
   - randomization;
   - concurrency;
   - spoken character mapping.

4. **Emotional fidelity**
   - immediacy;
   - surprise;
   - no fear of failure;
   - child-readable controls;
   - absurdity and humor.

5. **Platform-native fidelity**
   - fast Pencil response;
   - correct safe areas;
   - reliable autosave;
   - modern export;
   - adaptive layout;
   - system accessibility.

## 10.2 Product fidelity profiles

### Profile A: 1989 Monochrome

Purpose: preserve the free black-and-white release as closely as rights evidence permits.

Characteristics:

- monochrome visuals;
- tool inventory measured from the 1989 build;
- original behavior where observable;
- no assumption that later sounds, color assets, or mixer effects belong;
- potential public distribution only after rights evidence is verified.

### Profile B: Classic Color Fidelity

Purpose: reproduce the iconic 1990/1991-era color-and-sound experience.

Characteristics:

- exact behavior target;
- exact private-reference assets allowed in developer builds;
- release assets require written license or independently verified rights;
- clean-room replacements may be used in a public fallback build, but must be labeled as replacements.

### Profile C: KidPad Native

Purpose: preserve the classic experience while taking advantage of Apple Pencil.

Characteristics:

- same classic tool categories;
- optional pressure, tilt, azimuth, hover, double-tap, squeeze, and roll mappings;
- modern document/export behavior;
- adaptive iPad/iPhone layout;
- may use clean-room original art and audio when exact assets cannot be released.

The user can select a fidelity mode only when corresponding assets are legally available. Development configurations may expose all three; public builds expose only cleared profiles.

## 10.3 Reference hierarchy

When sources disagree, use this order:

1. Written rights documents and original distribution notices for legal status.
2. Executable behavior from the exact target historical build.
3. Original manuals or creator documentation for intended behavior.
4. Captured video and screenshots from lawfully operated historical builds.
5. Craig Hickman’s historical account.
6. The `vikrum/kidpix` behavior and source tree.
7. Current Software MacKiev products as lineage context, not as an automatic fidelity target.
8. Wikipedia and community commentary as discovery aids only.

## 10.4 Reference capture requirements

For each tool and variant, capture:

- starting canvas fixture;
- tool icon;
- submenu state;
- input path;
- modifier state;
- frame sequence;
- final image;
- sound sequence and timing;
- undo result;
- repeatability;
- edition/version;
- source hash;
- capture environment.

Each capture becomes a row in `FIDELITY_MATRIX.md` and a fixture in `Tests/Fixtures/`.

## 10.5 Random effects

Any effect that uses randomness must accept an injectable deterministic seed in the native engine. Production can seed from a secure or time-based source. Tests must use a fixed seed so output is exactly repeatable.

## 10.6 Pixel scaling

Historical art must use nearest-neighbor scaling unless a specific effect requires interpolation. The renderer must:

- align pixel-art assets to integer logical coordinates;
- avoid unintended antialiasing;
- preserve alpha behavior;
- avoid half-pixel placement;
- use measured original dimensions, not guessed replacements;
- document any scaling transformation in the asset ledger.

---

# 11. Product Scope

## 11.1 P0 scope

P0 defines a credible native restoration:

- app launch directly to workspace;
- adaptive classic tool rail;
- canvas;
- color palette;
- Pencil/freehand tool;
- line;
- rectangle;
- ellipse;
- basic wacky brush framework and representative brushes;
- paint bucket;
- eraser;
- TNT/full-canvas clear effect;
- alphabet/text stamping;
- rubber stamps;
- moving van/cut-and-move;
- Undo Guy;
- tool and action sounds;
- autosave;
- new/open/reopen recent document;
- PNG export;
- direct Apple Pencil input;
- finger input;
- landscape and portrait iPad layouts;
- deterministic engine tests;
- simulator automation;
- release asset-policy enforcement.

## 11.2 P1 scope

- full wacky-brush parity;
- full mixer/effect parity;
- hidden pictures;
- doorbell and fade-away erasers;
- all documented modifier variants;
- hover tool preview;
- Pencil double-tap;
- Apple Pencil Pro squeeze;
- Apple Pencil Pro barrel roll;
- pressure/tilt mapping customization;
- iPhone compact layout;
- JPEG export;
- Photos save;
- share sheet;
- multi-document browser;
- richer undo history;
- localized accessibility labels;
- parental gate.

## 11.3 P2 scope

- user-supplied lawful asset-pack import;
- licensed classic asset pack;
- macOS/Catalyst target;
- iCloud document synchronization;
- print support;
- classroom configuration;
- additional historical editions;
- optional custom stamp import;
- full restoration documentation website.

---

# 12. Detailed Functional Requirements

## 12.1 Application launch

**FR-001 [P0]** The app launches directly into the last active document or a new blank document.

**FR-002 [P0]** First launch must not require an account, network request, tutorial, or permission prompt.

**FR-003 [P0]** The first interaction with a tool that uses audio may initialize the audio engine without noticeable delay.

**FR-004 [P0]** Unsaved edits are autosaved locally.

**FR-005 [P1]** A discreet grown-up/settings area is available without interrupting child use.

## 12.2 Canvas

**FR-010 [P0]** The canvas is a destructive raster surface.

**FR-011 [P0]** The visible workspace supports a configurable logical canvas profile rather than coupling tools directly to device pixels.

**FR-012 [P0]** The JavaScript compatibility fixture supports 1920×1200 because the reference implementation uses that canvas size.

**FR-013 [P0]** The actual historical canvas dimensions for the 1989 and 1990/1991 profiles must be measured and recorded before claiming pixel parity.

**FR-014 [P0]** Scaling preserves pixel-art sharpness.

**FR-015 [P0]** The canvas does not move under a one-finger or Pencil drawing gesture.

**FR-016 [P1]** Two-finger gestures may pan or zoom only when explicitly enabled and must not interfere with drawing.

**FR-017 [P0]** Canvas coordinates remain correct under rotation, split view, Stage Manager, safe-area changes, and display scaling.

## 12.3 Tool rail

The primary rail contains recognizable controls for:

1. Save/export
2. Pencil
3. Line
4. Rectangle
5. Oval
6. Wacky Brush
7. Electric Mixer/Jumble
8. Paint Can
9. Eraser
10. Alphabet/Text
11. Rubber Stamps
12. Moving Van
13. Undo Guy

**FR-020 [P0]** Selecting a tool changes the active tool immediately and plays the appropriate sound when enabled.

**FR-021 [P0]** A selected tool has clear visual state without replacing the classic art.

**FR-022 [P0]** Tool controls meet minimum touch-target requirements even if the visual asset is smaller.

**FR-023 [P1]** Long press reveals a concise accessible name and optional variant selector.

## 12.4 Color palette

**FR-030 [P0]** A visible current color is always available.

**FR-031 [P0]** Color selection is one tap.

**FR-032 [P0]** Historical palette pages and order are represented when known.

**FR-033 [P1]** Primary, secondary, and tertiary colors support legacy alternate-button behavior through touch-native controls.

**FR-034 [P1]** The app provides an optional modern color picker without replacing classic palettes.

## 12.5 Pencil/freehand

**FR-040 [P0]** Down/move/up draws a continuous stroke with no visible gaps at normal speed.

**FR-041 [P0]** Input consumes coalesced touches.

**FR-042 [P0]** The engine can consume predicted touches for transient low-latency preview; committed output must be corrected when actual touches arrive.

**FR-043 [P0]** The classic profile can disable pressure-dependent width to preserve original behavior.

**FR-044 [P1]** Native mode maps pressure to width or intensity according to the selected tool.

**FR-045 [P1]** Tilt and azimuth may influence shape/orientation for compatible tools.

**FR-046 [P0]** A tap without movement creates the intended dot or initial mark.

## 12.6 Lines, rectangles, and ovals

**FR-050 [P0]** Shape tools preview while dragging and commit on release.

**FR-051 [P0]** Shape dimensions map exactly to logical canvas coordinates.

**FR-052 [P0]** Line width, texture, fill, outline, and modifier variants are data-driven.

**FR-053 [P1]** Shift-like constrained geometry is exposed through a visible variant or optional keyboard modifier.

## 12.7 Wacky Brush

**FR-060 [P0]** Wacky Brush is a reusable stamp/procedural brush framework, not a collection of hard-coded view callbacks.

**FR-061 [P0]** Each brush declares:

- identifier;
- icon;
- spacing;
- minimum movement;
- scale policy;
- angle policy;
- pressure policy;
- texture or procedural generator;
- sound phases;
- deterministic random-seed use;
- classic modifier variants.

**FR-062 [P0]** Brush spacing is based on traveled distance, not event count.

**FR-063 [P0]** Directional stamps rotate with the stroke direction when the reference does.

**FR-064 [P1]** Apple Pencil roll may rotate appropriate brushes in native mode.

**FR-065 [P1]** Hover previews the current brush footprint.

## 12.8 Electric Mixer / Jumble

**FR-070 [P0]** Whole-canvas effects operate on a snapshot and commit atomically.

**FR-071 [P0]** An effect cannot leave the document partially modified after cancellation or failure.

**FR-072 [P0]** Deterministic effects must match golden images exactly.

**FR-073 [P0]** Random effects use injectable seeds.

**FR-074 [P1]** Region-based and whole-canvas variants are supported.

Representative parity targets include invert, checkerboard, pattern, picture-in-picture, shadow boxes, Venetian blinds, wallpaper, frame, maze, smoke, smudge, magnify, contour, and other effects present in the reference inventory. The final list is generated from `FIDELITY_MATRIX.md`.

## 12.9 Paint Can

**FR-080 [P0]** Bounded flood fill uses exact logical pixel color matching unless the target reference specifies tolerance.

**FR-081 [P0]** Fill runs off the main thread or is sufficiently optimized to avoid freezing the UI on supported canvas sizes.

**FR-082 [P0]** The fill operation is undoable as one action.

**FR-083 [P1]** Whole-canvas color replacement is available as a legacy variant.

**FR-084 [P1]** Textured fills are supported where present in the reference.

## 12.10 Eraser

**FR-090 [P0]** Basic eraser restores background/transparent state according to the selected document profile.

**FR-091 [P0]** TNT/clear provides the expected animated and audio feedback before or during commit.

**FR-092 [P1]** Doorbell, fade-away, white-circle, hidden-picture, letter, and other observed eraser variants are implemented as separate effect definitions.

**FR-093 [P0]** The app must never leave an uncancellable destructive animation running indefinitely.

## 12.11 Alphabet/Text

**FR-100 [P0]** The user chooses a character from a visual character bar and stamps it on the canvas.

**FR-101 [P0]** Character rendering and color behavior follow the selected fidelity profile.

**FR-102 [P0]** Character sounds play only when licensed/cleared assets exist in the active build.

**FR-103 [P1]** Spoken alphabet supports locale-specific packs only when separately licensed and audited.

**FR-104 [P1]** Keyboard input can select/stamp characters without exposing a professional text editor.

## 12.12 Rubber stamps and stickers

**FR-110 [P0]** Stamps are presented in pages with visual previews.

**FR-111 [P0]** Stamp placement supports a hover/ghost preview before commit.

**FR-112 [P0]** Stamp assets preserve nearest-neighbor scaling.

**FR-113 [P1]** Pressure or pinch may scale a stamp in native mode while classic mode preserves reference behavior.

**FR-114 [P0]** Every stamp has an asset-ledger entry.

## 12.13 Moving Van

**FR-120 [P0]** The user can define a rectangular region and move or copy it according to the selected variant.

**FR-121 [P0]** The source region, destination region, background fill, and commit semantics match the reference fixture.

**FR-122 [P0]** The moving operation is undoable as one action.

**FR-123 [P1]** Optional Pencil hover previews the van/selection state.

## 12.14 Undo Guy

**FR-130 [P0]** Pressing Undo Guy reverses the last committed action.

**FR-131 [P0]** Pressing again may toggle redo when matching reference behavior, or the native profile may provide a separate redo action.

**FR-132 [P0]** Sound and animation are synchronized to the action.

**FR-133 [P1]** The native profile supports multiple undo levels while a strict classic profile may emulate the historical single-step/toggle behavior.

## 12.15 Save, open, and export

**FR-140 [P0]** The app autosaves an editable local document.

**FR-141 [P0]** The user can export a flattened PNG.

**FR-142 [P0]** Export does not require network access.

**FR-143 [P1]** Save to Photos and system share are available behind a parental gate when required.

**FR-144 [P1]** A document browser supports multiple drawings without adding complexity to the launch experience.

## 12.16 Sound controls

**FR-150 [P0]** Sound is on by default in classic profiles, subject to system audio state.

**FR-151 [P0]** A single setting can mute all app sounds.

**FR-152 [P0]** Rapid drawing does not create uncontrolled audio-channel buildup.

**FR-153 [P0]** Tool sounds support start, during, end, single, and randomized playback policies.

**FR-154 [P0]** No audio asset ships without a cleared ledger status.

---

# 13. Apple Pencil and Input Requirements

## 13.1 Direct touch pipeline

The canvas view must receive UIKit touch events directly. Each event is normalized into:

```swift
struct DrawingInput: Sendable {
    enum Source: Sendable {
        case pencil
        case finger
        case mouse
        case trackpad
        case syntheticTest
    }

    enum Phase: Sendable {
        case began
        case moved
        case ended
        case cancelled
        case hover
    }

    let phase: Phase
    let source: Source
    let location: CGPoint
    let timestamp: TimeInterval
    let normalizedPressure: CGFloat?
    let altitudeAngle: CGFloat?
    let azimuthAngle: CGFloat?
    let azimuthVector: CGVector?
    let rollAngle: CGFloat?
    let velocity: CGVector
    let isCoalesced: Bool
    let isPredicted: Bool
    let estimatedProperties: InputPropertySet
    let modifierState: ModifierState
}
```

Exact API shape may change, but tool code must not depend directly on `UITouch`.

## 13.2 Coalesced touches

For each event, consume `UIEvent.coalescedTouches(for:)` where available. This is required for smooth stroke fidelity.

## 13.3 Predicted touches

Predicted touches may be drawn into a transient preview layer. They must not permanently alter the committed bitmap. As actual events arrive, predicted output is cleared and replaced.

## 13.4 Estimated-property updates

The engine must account for `estimatedProperties` and `estimatedPropertiesExpectingUpdates`. If force or other values are corrected after initial delivery, transient or replayable stroke state must permit correction when practical.

## 13.5 Pressure

- Classic mode: disabled or mapped only when a reference behavior requires velocity/size variation.
- Native mode: normalized pressure can control size, density, opacity, stamp scale, or effect intensity per tool.
- Pressure mapping is clamped and curve-configurable.
- Finger force must not be assumed available.

## 13.6 Tilt and azimuth

- Tilt and azimuth are exposed to tools.
- Directional brush assets may orient to azimuth.
- Shading-like tools may change footprint with altitude.
- Classic mode may ignore these values.
- The app must not crash or change behavior unexpectedly when values are unavailable.

## 13.7 Roll

Apple Pencil Pro roll is available through supported APIs. It may rotate directional brushes in native mode. It must be feature-gated by OS and hardware availability.

## 13.8 Hover

Hover is used for:

- brush footprint preview;
- stamp preview;
- color/tool feedback;
- showing the intended contact point;
- optional squeeze palette positioning.

Hover must respect the system preference for hover tool previews where applicable. It must degrade cleanly on unsupported hardware.

## 13.9 Double tap

Default action:

- switch between current drawing tool and last eraser;
- respect the user’s system-preferred Pencil action when the API exposes it;
- allow disabling the custom mapping.

## 13.10 Squeeze

On Apple Pencil Pro, squeeze may open a compact radial or classic subtool palette centered near the hover pose. It must not be the only way to access any tool.

## 13.11 Palm rejection and finger policy

The app reads the system’s Pencil-only drawing preference and exposes a simple setting:

- Pencil draws; finger selects/pans.
- Pencil and finger both draw.
- Finger-only mode.

Finger interaction on controls always works. Multi-touch accidental contact must not produce drawing when a Pencil stroke is active.

## 13.12 Simulator versus physical hardware

Simulator acceptance includes:

- application build;
- launch;
- layout;
- mouse and synthesized touch;
- deterministic synthetic pressure/tilt/azimuth/roll traces at engine level;
- UI and visual regression;
- feature-unavailable fallback behavior.

Simulator acceptance does **not** prove:

- physical pressure curves;
- tilt accuracy;
- azimuth accuracy;
- hover distance;
- double-tap hardware behavior;
- squeeze;
- barrel roll;
- Pencil haptics;
- palm rejection;
- 120 Hz latency;
- real-device memory and thermal behavior.

A physical-device validation document is mandatory.

---

# 14. User Experience and Interface Requirements

## 14.1 Workspace composition

Primary landscape layout:

```text
┌───────────┬────────────────────────────────────────────┐
│ Tool Rail │                                            │
│           │                                            │
│           │                  Canvas                    │
│           │                                            │
│           │                                            │
├───────────┴────────────────────────────────────────────┤
│ Current color | Palette | Active tool variants         │
└────────────────────────────────────────────────────────┘
```

The exact rail and submenu location must follow the selected reference profile after measurements. The architecture must allow the rail, palette, and submenu to reflow without changing tool semantics.

## 14.2 Landscape

Landscape is the canonical classic experience and primary screenshot/visual-regression orientation.

## 14.3 Portrait

Portrait remains fully functional:

- tool rail may become a horizontal top or bottom strip;
- subtool options may scroll;
- canvas remains centered;
- no controls begin offscreen;
- the app never reproduces the existing web issue where an iPad opens scrolled to the bottom-right.

## 14.4 iPhone

The universal target may support iPhone through:

- scrollable compact tool bar;
- full-screen canvas;
- bottom-sheet subtools;
- finger and pointer input;
- no Apple Pencil acceptance requirement.

iPhone support must not compromise iPad architecture. It is P1 unless explicitly promoted.

## 14.5 Multitasking

Support:

- split view;
- Stage Manager;
- external display resizing;
- scene restoration;
- rotation.

Tool controls may compact but must remain accessible. Coordinate mapping must be tested at non-fullscreen sizes.

## 14.6 Classic and native affordances

Classic art remains the visual focus. Modern functions such as document management, settings, attribution, and export may live in a discreet grown-up menu. The user should not see a standard navigation stack while drawing unless necessary.

## 14.7 Help

The classic principle is “no guide.” The app may provide:

- accessible labels;
- long-press tool names;
- optional help mode;
- a grown-up README;
- no forced tutorial.

## 14.8 Haptics

Haptics may reinforce:

- tool selection;
- squeeze palette opening;
- snap or commit;
- destructive effect completion.

Haptics are optional, subtle, and disabled in strict classic mode.

## 14.9 Error handling

Children must not see raw technical errors. Recoverable errors use simple visual feedback. Detailed logs go to developer diagnostics. Document corruption must preserve a backup or exported image when possible.

---

# 15. Accessibility, Privacy, and Child-Safety Requirements

## 15.1 Accessibility

Every control must have:

- accessibility label;
- accessibility hint where behavior is non-obvious;
- selected state;
- logical focus order;
- sufficient hit target;
- VoiceOver operability.

Additional requirements:

- do not rely solely on color to indicate selection;
- optional reduced-motion mode;
- respect system audio and accessibility settings;
- preserve usability with larger text in grown-up/settings views;
- provide high-contrast selection indication without altering classic canvas output;
- keyboard shortcuts for major tools;
- switch-control-compatible controls where practical.

## 15.2 Privacy

V1 must:

- collect no analytics;
- collect no advertising identifier;
- contain no ad SDK;
- contain no crash SDK that sends data to third parties;
- require no login;
- make no network request;
- keep documents locally unless the user initiates a system export;
- avoid embedding remote web content;
- avoid background uploads.

Apple’s own diagnostics may still occur at the operating-system level; the app itself does not add telemetry.

## 15.3 Photos and files

Request Photos access only when the user explicitly chooses a Photos action. Prefer APIs that add a selected export without broad library access where possible.

## 15.4 Parental gate

When Kids Category requirements apply, place behind a parental gate:

- external links;
- GitHub link;
- privacy/legal links that open externally;
- system share sheet;
- purchases, if ever added;
- other-app navigation.

Saving locally or to Photos may be handled according to final Apple review guidance and privacy design.

## 15.5 Safety

- No chat.
- No user-generated public content.
- No web browser.
- No behavioral profiling.
- No AI prompt submission.
- No location.
- No microphone or camera in v1.
- No dark patterns.

---

# 16. Technical Architecture

## 16.1 Architecture overview

```text
┌─────────────────────────────────────────────────────────────┐
│                         KidPadApp                       │
│                 SwiftUI scenes and app lifecycle            │
├─────────────────────────────────────────────────────────────┤
│ AppShell / Workspace / ToolRail / Palette / Settings        │
├─────────────────────────────────────────────────────────────┤
│ CanvasHost (UIViewRepresentable)                            │
│  └─ RasterCanvasView (UIKit UIView or MTKView)              │
│      ├─ InputCollector                                      │
│      ├─ Hover/PencilInteractionAdapter                      │
│      ├─ CoordinateMapper                                    │
│      └─ FramePresenter                                      │
├─────────────────────────────────────────────────────────────┤
│ CanvasEngine                                                │
│  ├─ DocumentBitmap                                          │
│  ├─ PreviewSurface                                          │
│  ├─ AnimationSurface                                        │
│  ├─ ToolController                                          │
│  ├─ BrushEngine                                             │
│  ├─ EffectEngine                                            │
│  ├─ Compositor                                              │
│  ├─ UndoStore                                               │
│  └─ DeterministicRandom                                     │
├─────────────────────────────────────────────────────────────┤
│ AssetCatalog / AudioEngine / DocumentStore / ExportService  │
├─────────────────────────────────────────────────────────────┤
│ Policy                                                      │
│  ├─ AssetReleaseValidator                                   │
│  ├─ BuildConfiguration                                      │
│  └─ FeatureAvailability                                     │
└─────────────────────────────────────────────────────────────┘
```

## 16.2 Module responsibilities

### `KidPadApp`

- application lifecycle;
- scene restoration;
- dependency construction;
- document routing;
- launch configuration.

### `WorkspaceUI`

- tool rail;
- palette;
- subtool picker;
- grown-up menu;
- export;
- adaptive layout;
- accessibility.

### `CanvasUI`

- UIKit canvas;
- raw input collection;
- display-link scheduling;
- hover;
- Pencil interactions;
- coordinate transforms.

### `CanvasCore`

- platform-independent drawing model where possible;
- bitmap surfaces;
- tool state;
- deterministic brush/effect algorithms;
- undo commands;
- document serialization metadata.

### `AssetKit`

- asset manifest;
- sprite/stamp loading;
- palette definitions;
- license/provenance status;
- build-time validation.

### `KidPadAudio`

Avoid naming collision with the existing AudioKit framework. Responsibilities:

- sample preload;
- playback pools;
- start/during/end policies;
- random sample selection;
- mute state;
- interruption handling.

### `DocumentKit`

- package format;
- autosave;
- recovery;
- thumbnail generation;
- export.

### `TestSupport`

- input traces;
- fixture loading;
- deterministic clocks;
- screenshot hooks;
- simulator test menu;
- reference comparison.

## 16.3 Tool protocol

```swift
protocol CanvasTool: AnyObject {
    var id: ToolID { get }
    var capabilities: ToolCapabilities { get }

    func activate(context: ToolContext)
    func deactivate(context: ToolContext)

    func begin(_ input: DrawingInput, context: ToolContext)
    func update(_ input: DrawingInput, context: ToolContext)
    func end(_ input: DrawingInput, context: ToolContext)
    func cancel(context: ToolContext)

    func hover(_ input: DrawingInput, context: ToolContext)
}
```

Tool behavior must live outside SwiftUI views.

## 16.4 Configuration-driven tool definitions

Menus and variants should be data-driven:

```swift
struct ToolDefinition: Codable, Sendable {
    let id: ToolID
    let displayAssetID: AssetID
    let soundPolicy: SoundPolicy?
    let variants: [ToolVariantDefinition]
    let classicModifiers: ModifierMapping
    let pencilMapping: PencilMapping
}
```

This allows the parity matrix and asset ledger to map directly to implementation.

## 16.5 Concurrency

- UI and input collection occur on `MainActor`.
- expensive flood fill/effects operate on controlled worker tasks over immutable snapshots;
- commit returns atomically to the main document state;
- cancellation is supported;
- bitmap ownership must avoid concurrent mutation;
- audio scheduling must not block input;
- export runs away from the drawing frame loop.

## 16.6 Dependency policy

Prefer Apple frameworks and small, auditable dependencies. Any third-party dependency must have:

- active maintenance;
- compatible license;
- pinned version;
- no analytics/network behavior;
- entry in `THIRD_PARTY_NOTICES.md`;
- justification in an ADR.

XcodeGen may be used to make the project reproducible, but the generated `.xcodeproj` may also be committed to reduce setup friction.

---

# 17. Rendering and Graphics Architecture

## 17.1 Why PencilKit is not the primary engine

`PKCanvasView` excels at low-latency captured ink represented as strokes. KidPad requires:

- destructive pixel modification;
- flood fill;
- bitmap stamps;
- procedural stamped brushes;
- whole-canvas filters;
- hidden images;
- animated erasers;
- unusual compositing modes;
- exact pixel output;
- classic one-step commit semantics.

Using PencilKit as the primary engine would create impedance between vector-like stroke storage and the product’s raster behavior. It may be used experimentally for an optional conventional ink tool, but not as the document truth.

## 17.2 Initial rendering implementation

Use a CPU-backed bitmap:

- premultiplied RGBA8;
- explicitly defined color space;
- CGBitmapContext or equivalent buffer wrapper;
- integer logical coordinates;
- predictable alpha compositing;
- nearest-neighbor asset sampling.

Core Graphics is sufficient for:

- freehand lines;
- geometric shapes;
- bitmap stamping;
- compositing;
- text/stamp drawing;
- snapshots.

Direct buffer access or Accelerate/vImage is suitable for:

- flood fill;
- color replacement;
- pixel filters;
- region transforms.

## 17.3 Metal adoption criteria

Metal is optional until profiling proves it is needed. Adopt Metal or Core Image for a specific operation only when:

- the CPU implementation misses the frame or interaction budget on baseline hardware;
- the output can be made deterministic;
- tests compare CPU and GPU output where both exist;
- implementation complexity is justified;
- the shader source and asset pipeline remain open and auditable.

A custom `MTKView` may eventually present the bitmap or execute effects, but the initial vertical slice should not begin with a full Metal engine.

## 17.4 Surface model

The engine maintains:

1. `committedSurface` — the document truth;
2. `workingSurface` — current uncommitted stroke/effect;
3. `previewSurface` — shape, stamp, or hover preview;
4. `animationSurface` — temporary animation;
5. `predictedSurface` — predicted touches;
6. optional `referenceOverlay` — debug only, never in release.

Commit rules:

- a tool begins an undo transaction;
- transient surfaces are cleared or recomputed;
- the final result merges atomically;
- autosave is scheduled;
- a thumbnail update is coalesced.

## 17.5 Coordinate mapping

All input passes through a single mapper:

```text
window point
→ canvas view point
→ visible content transform
→ logical canvas point
→ clamped integer/pixel coordinate where required
```

No tool reads `offsetX`, view frame assumptions, or raw screen coordinates.

## 17.6 Blend modes

Create a project-owned blend-mode enum mapped to Core Graphics operations. Tests must cover:

- source-over;
- copy;
- destination-in;
- destination-out;
- multiply or screen where required;
- reference-specific custom pixel rules.

## 17.7 Texture generation

Textures may be:

- solid colors;
- repeating bitmap patterns;
- procedural patterns;
- palette-indexed masks;
- transformed stamp assets.

A texture cache is keyed by asset, color, scale, angle bucket, pressure bucket, and profile.

## 17.8 Brush spacing

Brush sampling must be distance-based and interpolate along the stroke path. A fast stroke cannot produce large gaps merely because event delivery is sparse.

## 17.9 Color management

For pixel parity:

- define a canonical working color space;
- avoid display-dependent conversion inside tests;
- store expected test output with metadata;
- document differences between historical indexed palettes and modern sRGB;
- preserve original palette values where measurable.

---

# 18. Persistence, Documents, Export, and Undo

## 18.1 Document package

Recommended `.kidpad` package:

```text
My Drawing.kidpad/
  manifest.json
  canvas.png
  thumbnail.png
  undo/
    index.json
    snapshot-0001.bin
  metadata/
    asset-profile.json
```

`manifest.json` includes:

- format version;
- canvas dimensions;
- color space;
- background semantics;
- fidelity profile;
- palette;
- random seed state where relevant;
- application version;
- created/modified dates;
- optional source/asset profile identifiers.

## 18.2 Autosave

- debounce saves during continuous drawing;
- commit after an action;
- use atomic replacement;
- retain last-known-good backup;
- recover after termination;
- do not encode the full bitmap on every touch event.

## 18.3 Undo architecture

V1 may use tile or full-snapshot undo depending measured memory:

- record dirty region before commit;
- compress or tile snapshots;
- group one tool action into one undo step;
- cap history by memory budget;
- classic profile may expose only one-step toggle while native profile retains more internally;
- destructive effect remains atomic.

## 18.4 Export

P0:

- flattened PNG;
- transparent or profile-specific background;
- correct orientation;
- no private metadata.

P1:

- JPEG with quality control;
- Photos;
- share sheet;
- document thumbnail;
- print.

## 18.5 Import

P1 may import PNG/JPEG as a starting canvas. Historical asset-pack import is separate and requires policy validation.

---

# 19. Audio Architecture

## 19.1 Requirements

- low-latency playback;
- many short effects;
- start/during/end phases;
- rate limiting;
- randomized selections;
- spoken-character mapping;
- interruption handling;
- mute state;
- no network audio.

## 19.2 Recommended implementation

Use `AVAudioEngine` with preloaded buffers or a small pool of `AVAudioPlayerNode` instances. Avoid creating a new player for every movement event.

## 19.3 Sound policies

```swift
enum SoundPolicy {
    case none
    case onceOnBegin(AssetID)
    case onceOnEnd(AssetID)
    case loopDuringStroke(AssetID)
    case rateLimitedDuringStroke(AssetID, minimumInterval: Duration)
    case multipart(begin: AssetID?, during: AssetID?, end: AssetID?)
    case random([AssetID])
    case characterMap([String: AssetID])
}
```

## 19.4 Fidelity and rights

Trigger timing can be implemented from observation. The exact audio waveform may ship only if cleared. A clean-room replacement cannot be represented as the original recording.

## 19.5 Audio tests

- asset existence;
- ledger status;
- sample rate/channel validity;
- no clipping;
- policy sequence;
- rate limiting;
- mute behavior;
- interruption/restart;
- exact hash for licensed original samples;
- timing tolerance in integration tests.

---

# 20. Asset Provenance and Reference Workspace

## 20.1 Core policy

The project separates **reference material** from **shipping assets**.

Reference material may be lawfully possessed and used privately to understand behavior. It is not automatically redistributable.

## 20.2 Required `ref/` structure

```text
ref/
  README.md
  sources.lock.json
  legal/
    historical-notices/
    permissions/
    trademark/
    notes/
  source-jskidpix/
  original-1989/
  commercial-reference/
  emulator/
  captures/
    original-1989/
    classic-color/
    jskidpix/
    current-official/
  screenshots/
  videos/
  audio-analysis/
  specifications/
  hashes/
  asset-audit/
```

Default policy:

- `ref/` is gitignored.
- `ref/README.md` and a sanitized `ref/example-sources.lock.json` may be committed.
- Source URLs, hashes, dates, and notes are committed when they do not expose private files.
- The agent never commits ROMs or unlicensed commercial software.
- Reference videos are usually stored as URLs and notes, not downloaded copies.

## 20.3 Shipping asset directories

```text
Assets/
  Verified/
  Licensed/
  CleanRoom/
  Quarantined/
```

Build configurations:

- `DebugPublic`: Verified + Licensed + CleanRoom
- `FidelityDev`: may additionally load local Quarantined assets outside the bundle
- `ReleasePublic`: Verified + Licensed + CleanRoom only
- `ReleaseLicensedClassic`: enabled only when written permissions exist

## 20.4 Asset status values

- `verified-public-domain`
- `licensed`
- `clean-room-original`
- `research-only`
- `blocked`
- `unknown`

Unknown defaults to non-shippable.

## 20.5 Release validator

A build-tool plugin or test scans:

- asset manifests;
- Xcode resources phase;
- copied bundles;
- audio catalogs;
- image catalogs;
- fonts;
- generated sprite sheets.

The release build fails when:

- an asset has no ledger entry;
- status is `research-only`, `blocked`, or `unknown`;
- hash differs from ledger;
- allowed target excludes the current build;
- required attribution is missing.

## 20.6 Exact-fidelity paths

### Path 1: written license

Obtain written permission from the relevant rights holder for specified assets, product name if desired, platforms, source distribution, binary distribution, modification, and App Store use.

### Path 2: verified 1989 distribution

Use only assets and code whose public-domain or equivalent rights are verified from the original release evidence.

### Path 3: lawful user-supplied extraction

A future tool may allow a user to import assets from legally owned media. This still requires legal review and must not bypass protection or facilitate piracy.

### Path 4: clean-room replacement

Create new icons, stamps, and sounds that reproduce functional personality without copying protected expression. These are not exact assets and must not be marketed as exact.

## 20.7 Macintosh emulation

Mini vMac is a useful open-source emulator, but Macintosh ROM files are copyrighted by Apple and must not be downloaded or redistributed by the project. The reference workflow may use:

- a user-supplied ROM lawfully obtained from owned hardware;
- a user-supplied original disk/archive;
- documented emulator configuration;
- captured screenshots/video/hashes.

If no lawful ROM is available, mark emulator reference capture blocked and use other lawful sources.

---

# 21. Repository and Project Structure

```text
kidpad/
  README.md
  LICENSE
  NOTICE.md
  THIRD_PARTY_NOTICES.md
  PRD.md
  AGENT_GOAL_LOOP.md
  project.yml
  KidPad.xcodeproj/
  Config/
    DebugPublic.xcconfig
    FidelityDev.xcconfig
    ReleasePublic.xcconfig
  Sources/
    KidPadApp/
    WorkspaceUI/
    CanvasUI/
    CanvasCore/
      Bitmap/
      Input/
      Tools/
      Brushes/
      Effects/
      Compositing/
      Undo/
      Random/
    AssetCatalog/
    KidPadAudio/
    DocumentStore/
    ExportService/
    Diagnostics/
  Resources/
    Verified/
    Licensed/
    CleanRoom/
    Manifests/
  Tests/
    CanvasCoreTests/
    ToolGoldenTests/
    InputTraceTests/
    AssetPolicyTests/
    DocumentTests/
    AudioPolicyTests/
    AppUITests/
    PerformanceTests/
    Fixtures/
      Inputs/
      Canvases/
      Golden/
      Audio/
  Scripts/
    bootstrap.sh
    choose_simulator.sh
    build.sh
    test.sh
    run_simulator.sh
    capture.sh
    validate_assets.py
    compare_images.py
    generate_parity_inventory.py
  Docs/
    Architecture/
    Fidelity/
    Legal/
    Testing/
    Hardware/
  artifacts/
    simulator/
    tests/
    diffs/
    logs/
  ref/
    # Local and gitignored except sanitized templates
  AGENT_STATE.md
  BUILD_STATUS.json
  FIDELITY_MATRIX.md
  KNOWN_ISSUES.md
  HARDWARE_VALIDATION_REQUIRED.md
```

Rules:

- no private reference asset is copied into `Resources/`;
- no tool implementation depends on file paths under `ref/`;
- public tests use committed, cleared fixtures;
- fidelity developer tests may detect local reference files and skip with an explicit message when absent;
- generated project files are reproducible.

---

# 22. Testing and Quality Strategy

## 22.1 Test pyramid

### Unit tests

- coordinate mapping;
- pressure curves;
- brush spacing;
- geometry;
- blend modes;
- flood fill;
- color conversion;
- random seed;
- undo transactions;
- serialization;
- asset policy;
- sound policy.

### Golden-image tests

Each deterministic tool runs against a known starting bitmap and input trace. Output is compared with a committed expected image.

Comparison modes:

- exact bytes for canonical deterministic output;
- exact RGBA pixels when encoding metadata differs;
- documented tolerance only for platform-rendered text or GPU paths;
- difference image written to `artifacts/diffs/`.

### Input trace tests

JSON fixtures represent:

- source;
- phase;
- timestamps;
- coordinates;
- pressure;
- altitude;
- azimuth;
- roll;
- predicted/coalesced state;
- modifiers.

The same trace can drive multiple tool implementations.

### UI tests

- launch;
- select tool;
- select color;
- draw with coordinate gestures;
- rotate;
- resize;
- undo;
- export;
- reopen;
- accessibility labels;
- parental gate;
- no control offscreen.

### Snapshot tests

Capture:

- iPad landscape;
- iPad portrait;
- split view;
- large and compact iPads;
- iPhone compact;
- light/dark system appearance if app does not force classic appearance;
- accessibility text sizes for settings.

### Audio tests

Validate policies and assets without relying solely on listening.

### Performance tests

Measure:

- stroke processing;
- large flood fill;
- whole-canvas effects;
- undo snapshot;
- save;
- export;
- memory;
- launch.

## 22.2 Reference visual comparison

For each parity row:

1. run the historical/reference implementation;
2. establish the starting fixture;
3. play a recorded input path;
4. capture final output;
5. run native engine with equivalent trace;
6. normalize scale and color space;
7. generate exact or perceptual diff;
8. inspect mismatch;
9. document intentional differences.

## 22.3 Simulator automation

The CI/local loop must:

- dynamically choose an available iPad simulator;
- boot it;
- build and test with `xcodebuild`;
- install the app;
- launch with test arguments;
- capture screenshot;
- optionally record video;
- collect console logs;
- terminate cleanly.

Do not hard-code a single simulator model or OS version.

## 22.4 Physical hardware matrix

Minimum recommended validation:

| Hardware | Purpose |
|---|---|
| Non-Pro baseline iPad + compatible Pencil | performance and broad Pencil input |
| 60 Hz iPad | minimum frame pacing |
| ProMotion iPad Pro | 120 Hz behavior and latency |
| Hover-compatible iPad Pro + Pencil | hover |
| Apple Pencil Pro compatible iPad | squeeze, roll, haptics |
| Finger-only iPad | child/touch workflow |
| iPhone | compact UI if included |

Record exact model, OS, Pencil generation, and test date.

## 22.5 Diagnostics mode

A hidden developer screen must show:

- touch source;
- raw and normalized pressure;
- maximum force;
- altitude;
- azimuth;
- roll;
- coalesced count;
- predicted count;
- estimated-property flags;
- hover pose;
- Pencil interaction events;
- frame time;
- tool;
- logical and view coordinates.

Diagnostics output may be exported as local JSON.

## 22.6 No-network test

An automated or manual release test confirms that normal use performs no network request. Dependency inspection must ensure no SDK introduces hidden telemetry.

---

# 23. Performance and Reliability Requirements

## 23.1 Frame pacing

- 60 fps minimum during normal drawing on the physical baseline device.
- Target native refresh rate on ProMotion hardware where feasible.
- No visible event-spacing gaps in fast strokes.
- Predicted touches may be used to improve perceived latency.

## 23.2 Main-thread work

- No synchronous full-canvas encoding during movement.
- No disk I/O on every touch.
- No repeated audio decode during movement.
- No whole-canvas effect on the main thread when it causes visible stalls.

## 23.3 Launch

Target warm launch to interactive canvas under one second and cold launch under two seconds on baseline hardware, measured rather than assumed.

## 23.4 Memory

Initial target:

- typical active document under 300 MB;
- peak under 600 MB during large effects on modern iPad;
- no unbounded undo history;
- memory warnings handled by trimming caches and history without losing the committed document.

These targets may be revised after real profiling.

## 23.5 Save reliability

- atomic autosave;
- backup;
- document versioning;
- recovery test after forced termination;
- no data loss after a completed tool commit.

## 23.6 Crash and error target

No known reproducible crash in P0 workflows. Public beta must include a manual crash-free test matrix even without third-party analytics.

---

# 24. Implementation Phases and Milestones

## M0. Evidence, naming, and repository foundation

Deliverables:

- repository;
- PRD and agent loop;
- source lock file;
- asset ledger schema;
- legal risk register;
- naming decision records KidPad as canonical and preserves the public-release clearance gate;
- clean-room/GPL branch separation policy;
- reference folder;
- Xcode project generation;
- empty app builds and launches.

Exit:

- clean checkout builds;
- no unverified asset is in the target;
- reference sources are pinned by URL/hash where possible.

## M1. Native vertical slice

Deliverables:

- SwiftUI workspace;
- UIKit canvas;
- coordinate mapping;
- Pencil/finger input normalization;
- simple pencil;
- color selection;
- undo;
- autosave;
- simulator build/test/capture loop.

Exit:

- draw a stroke in simulator;
- inject pressure trace in engine test;
- reopen drawing;
- golden test passes.

## M2. Core classic tools

Deliverables:

- line;
- rectangle;
- oval;
- fill;
- eraser;
- TNT clear;
- stamps;
- alphabet;
- moving van;
- basic sound engine.

Exit:

- all P0 core tools have fixtures and tests.

## M3. Wacky brush and mixer framework

Deliverables:

- data-driven variants;
- representative procedural and stamp brushes;
- deterministic random;
- whole-canvas effect engine;
- parity inventory.

Exit:

- every upstream/reference tool is classified as implemented, intentionally deferred, blocked by asset rights, or not applicable.

## M4. Fidelity and asset pass

Deliverables:

- original reference captures;
- visual comparison;
- sound timing matrix;
- verified/clean-room asset catalog;
- release validator;
- private fidelity configuration.

Exit:

- release target contains zero quarantined assets;
- private build can compare exact references without copying them into public output.

## M5. Document and platform polish

Deliverables:

- document package;
- recovery;
- PNG export;
- adaptive layouts;
- accessibility;
- Kids/privacy controls;
- grown-up menu.

Exit:

- end-to-end UI tests pass.

## M6. Apple Pencil hardware pass

Deliverables:

- coalesced/predicted correction;
- pressure;
- tilt;
- azimuth;
- hover;
- double-tap;
- squeeze;
- roll;
- haptics;
- physical performance report.

Exit:

- compatible hardware matrix passes or each unavailable feature is explicitly documented as blocked.

## M7. Public beta readiness

Deliverables:

- source/license review;
- name clearance;
- asset review;
- notices;
- privacy policy if needed;
- signed build;
- beta test plan;
- release notes.

Exit:

- GitHub release gates pass.
- App Store release remains separate and requires its own review.

---

# 25. Definition of Done and Release Gates

## 25.1 Engineering done

- Clean build and test.
- Simulator launch.
- P0 tools implemented.
- Golden tests pass.
- Autosave/recovery pass.
- PNG export passes.
- Adaptive iPad layouts pass.
- Finger workflow passes.
- No known P0 crash.
- Documentation matches implementation.

## 25.2 Fidelity done

- Every P0 behavior has a reference row.
- Every reference row names edition/source.
- Deterministic output is compared.
- Sound timing is documented.
- Differences are either fixed or explicitly accepted.
- “Exact” is never claimed for replaced assets.

## 25.3 Asset done

- Every bundled file has a ledger entry.
- Hashes match.
- No unverified assets in release.
- Attributions included.
- Fonts reviewed.
- Generated sprite sheets inherit valid source status.
- Written permissions archived.

## 25.4 Naming done

- App Store search;
- USPTO/EUIPO/common-law review;
- product and repository name approved;
- KID PIX use limited to approved historical language;
- disclaimer reviewed.

## 25.5 Apple Pencil done

- Simulator fallback tested.
- Physical pressure tested.
- Tilt/azimuth tested.
- hover tested on compatible device;
- double-tap tested;
- squeeze and roll tested on Apple Pencil Pro compatible device;
- palm rejection tested;
- Pencil-only preference tested;
- performance measured.

A physical hardware feature cannot be marked passed by synthetic Simulator input.

## 25.6 GitHub public release gate

May pass without App Store distribution when:

- source and public assets are cleared;
- README disclaimer is present;
- build instructions work;
- release binary, if any, contains no restricted material;
- no name confusion;
- known hardware limitations are disclosed.

## 25.7 App Store gate

Requires all of:

- naming/trademark clearance;
- source-code license review;
- exact asset permissions;
- App Review IP compliance;
- Kids/privacy compliance;
- physical-device tests;
- privacy metadata;
- screenshots with only cleared assets;
- no repackaged-web concern;
- no prohibited links;
- final legal approval.

---

# 26. Risks and Mitigations

| Risk | Severity | Mitigation |
|---|---:|---|
| “Kid Pix” branding rejected or challenged | Critical | Use KidPad independently; obtain written authorization for any use of the KID PIX mark |
| Exact color/sound assets are copyrighted | Critical | Quarantine; license; verified 1989 profile; clean-room fallback |
| 1989 “public domain” claim lacks explicit dedication | High | Inspect original distribution; preserve notice; legal review |
| Upstream GPL/MIT conflict | High | Treat as GPL; clean-room code; ask maintainer for clarification |
| App Store/GPL compatibility uncertainty | High | Permissive clean-room code or legal review/custom permission |
| Agent accidentally commits restricted reference assets | Critical | Gitignore, pre-commit scanner, release validator, separate directories |
| Macintosh ROM downloaded or redistributed | Critical | User-supplied lawful ROM only; no automated ROM acquisition |
| Simulator falsely treated as Pencil proof | High | Separate hardware gate; diagnostics report |
| Scope expands into all Kid Pix editions | High | Freeze v1 profile and P0 matrix |
| Professional-tool creep | Medium | Enforce non-goals and design principles |
| CPU raster effects stall | Medium | Profile; worker tasks; Accelerate/Metal selectively |
| Audio overlaps excessively | Medium | Playback pools and rate limiting |
| Random effects make tests flaky | Medium | Injectable deterministic seed |
| Tool UI is too small in multitasking | Medium | Larger invisible hit targets; adaptive layout tests |
| Exact fidelity harms accessibility | Medium | Preserve visual art while adding semantic labels and optional contrast |
| KidPad is challenged, unavailable, or confusingly similar in a target market | High | Keep identifiers centralized; complete formal clearance before public commercial launch; rename only by explicit product-owner or legal decision |
| External dependencies introduce telemetry | High | Apple-first dependency policy and audit |
| Historical archive disappears | Medium | Preserve hashes, metadata, and lawful local reference copies |
| Clean-room process is contaminated by copied code | High | Behavioral specs; review; no line translation; separate branches |
| App feels like a generic clone | High | Fidelity matrix, sound timing, visual regression, adult/child testing |

---

# 27. Open Questions

These must be answered during M0–M4:

1. Does the original 1989 archive contain an explicit public-domain dedication or only permission to redistribute?
2. Which exact historical edition is the primary color-fidelity target?
3. Who owns each commercial-era art and audio asset today?
4. Will Software MacKiev grant a license for classic assets or a trademark coexistence/official project?
5. Will Craig Hickman provide clarification on the 1989 release rights?
6. Does Vikrum intend the entire repository to be GPLv3, MIT, dual-licensed, or differently licensed by file?
7. What is the provenance of each file under `img/`, `snd/`, and `sndmp3/`?
8. What were the exact original workspace and canvas dimensions for the target edition?
9. Which hidden modifier combinations are intentional versus JavaScript additions?
10. Should strict classic mode reproduce single-step toggle undo or expose modern history invisibly?
11. Should native pressure modify classic brushes by default or only in a separate mode?
12. Which iPad and Pencil models are available for hardware validation?
13. Does the app enter the Kids Category or remain a general 4+ creativity app?
14. Is iPhone a v1 release requirement or only a universal-build compatibility target?
15. Should a future user-supplied asset importer be pursued?
16. What public name passes formal clearance?
17. Will the public repository include generated `.xcodeproj`, rely on XcodeGen, or both?
18. Which baseline iPadOS version best balances hardware support and current API availability after implementation begins?

---

# Appendix A: Initial Feature-Parity Inventory

This is a starting inventory derived from the JavaScript tree and historical descriptions. The implementation agent must generate a canonical `FIDELITY_MATRIX.md` from the pinned upstream commit and reference captures.

## A.1 Main tool categories

| Category | Representative behavior | Priority |
|---|---|---:|
| Save | image/document export | P0 |
| Pencil | freehand and variants | P0 |
| Line | preview and commit | P0 |
| Rectangle | outline/fill variants | P0 |
| Oval | outline/fill variants | P0 |
| Wacky Brush | procedural/stamp brush library | P0 |
| Electric Mixer/Jumble | whole-canvas and region effects | P0/P1 |
| Paint Can | bounded fill and replacement | P0 |
| Eraser | basic and theatrical effects | P0/P1 |
| Alphabet | character stamping and voice | P0/P1 |
| Rubber Stamps | sprite pages | P0 |
| Moving Van | cut/move/copy region | P0 |
| Undo Guy | undo/redo personality | P0 |

## A.2 Upstream JavaScript tool modules observed

- `animbrush.js`
- `astroid.js`
- `bezfollow.js`
- `brush.js`
- `circle.js`
- `composite.js`
- `contours.js`
- `cut.js`
- `eraser-doorbell.js`
- `eraser-fade-away.js`
- `eraser-hidden-pictures.js`
- `eraser-letters.js`
- `eraser-white-circles.js`
- `eraser.js`
- `flood.js`
- `fuzzer.js`
- `guilloche.js`
- `inverter.js`
- `kaleidoscope.js`
- `lanczosbrush.js`
- `line.js`
- `looper.js`
- `magnify.js`
- `maze.js`
- `partialfx.js`
- `pines.js`
- `pixelpencil.js`
- `placer.js`
- `plainbrush.js`
- `scribble.js`
- `smoke.js`
- `smoothpen.js`
- `smudge.js`
- `spiral.js`
- `spriteplacer.js`
- `square.js`
- `stamp.js`
- `three3d.js`
- `tnt.js`
- `trees.js`
- `wacky-mixer-checkerboard.js`
- `wacky-mixer-inverter.js`
- `wacky-mixer-pattern.js`
- `wacky-mixer-pip.js`
- `wacky-mixer-shadow-boxes.js`
- `wacky-mixer-venetian-blinds.js`
- `wacky-mixer-wallpaper.js`
- `wholefx.js`

## A.3 Upstream brush modules observed

- bubbles
- circles
- concentric behavior
- connect-the-dots
- dumbbell
- sine-wave forms
- icy
- leaky pen
- mean streak
- pies
- rainbow ball
- rainbow bar
- rainbow doughnut
- raindrops
- rose
- recursive/pentagonal forms
- splatter
- spray
- triangles
- twirly

## A.4 Builder modules observed

- arrow
- prints
- rail
- road

## A.5 Submenu groups observed

- brush
- circle
- eraser
- flood
- jumble
- line
- pencil
- spray
- sprites
- square
- stickers
- truck

## A.6 Audio categories observed

- menu click;
- color click;
- option click;
- pencil;
- line start/during/end;
- shape;
- flood;
- stamp;
- random oops;
- explosion;
- bubble pops;
- doorbell/door creak/wow;
- brush-specific sounds;
- mixer-specific sounds;
- truck start/during/end;
- spoken letters;
- spoken numbers and symbols.

Every item must be classified:

- `observed-original-1989`
- `observed-color-1990`
- `observed-commercial-1991`
- `upstream-only`
- `later-edition`
- `unknown`
- `implemented`
- `deferred`
- `asset-blocked`
- `not-in-target`

---

# Appendix B: Asset Ledger Schema

Recommended `AssetLedger.json` record:

```json
{
  "schemaVersion": 1,
  "assets": [
    {
      "id": "tool.undo-guy.icon",
      "kind": "image",
      "logicalRole": "Undo Guy main tool icon",
      "sourceURL": "https://example.invalid/source",
      "sourceEdition": "Kid Pix 1989",
      "sourceArchive": "KidPix.sit",
      "sourcePath": "RESOURCE_FORK/...",
      "acquiredAt": "2026-08-20T00:00:00Z",
      "sha256": "REPLACE_ME",
      "copyrightClaimant": "unknown",
      "rightsEvidence": [
        "ref/legal/historical-notices/example.txt"
      ],
      "license": "unknown",
      "status": "research-only",
      "transformations": [
        "resource extraction",
        "nearest-neighbor crop"
      ],
      "derivedAssetHashes": [],
      "allowedBuilds": [
        "FidelityDev"
      ],
      "attribution": null,
      "notes": "Do not ship until rights scope is verified."
    }
  ]
}
```

Required fields:

- stable asset ID;
- type;
- role;
- source;
- edition;
- original container/path;
- acquisition date;
- cryptographic hash;
- claimant;
- rights evidence;
- license;
- status;
- transformations;
- allowed targets;
- attribution;
- notes.

---

# Appendix C: Reference Sources

The following sources are starting references. The agent must record access date, content hash where possible, and the precise fact or behavior each supports.

## C.1 Core source repository

- Repository: https://github.com/vikrum/kidpix
- Live implementation: https://kidpix.app/
- README: https://github.com/vikrum/kidpix/blob/main/README.md
- GPLv3 license: https://github.com/vikrum/kidpix/blob/main/LICENSE
- Package metadata: https://github.com/vikrum/kidpix/blob/main/package.json
- Notices and source references: https://github.com/vikrum/kidpix/blob/main/NOTICE
- Initializer/input: https://github.com/vikrum/kidpix/blob/main/js/init/kiddopaint.js
- Display/undo/persistence: https://github.com/vikrum/kidpix/blob/main/js/util/display.js
- Sound library: https://github.com/vikrum/kidpix/blob/main/js/sounds/sounds.js
- Flood fill: https://github.com/vikrum/kidpix/blob/main/js/tools/flood.js
- Pencil: https://github.com/vikrum/kidpix/blob/main/js/tools/pixelpencil.js
- Brush engine: https://github.com/vikrum/kidpix/blob/main/js/tools/brush.js
- Tablet/small viewport issue: https://github.com/vikrum/kidpix/issues/7
- Stylus coordinate issue: https://github.com/vikrum/kidpix/issues/8
- Maintainer license response: https://github.com/vikrum/kidpix/issues/32

## C.2 Historical context

- Craig Hickman, “Kid Pix – The Early Years”: https://red-green-blue.com/kid-pix-the-early-years
- University of Oregon, “Apple honors Hickman as innovator”: https://design.uoregon.edu/apple-honors-hickman-innovator
- Wikipedia background: https://en.wikipedia.org/wiki/Kid_Pix
- Creator/history video reference: https://www.youtube.com/watch?v=csalhuSixQU

Wikipedia is a discovery source, not sufficient legal evidence.

## C.3 Historical software archives

- Macintosh Repository Kid Pix 1.0 page: https://www.macintoshrepository.org/92-kid-pix-1-0
- MacTrove Kid Pix page: https://mactrove.com/software/kid-pix

Archive availability is not proof of redistribution rights. Preserve the archive hash and inspect original notices.

## C.4 Emulator

- Mini vMac: https://www.gryphel.com/c/minivmac/
- Mini vMac hardware/ROM guidance: https://www.gryphel.com/c/minivmac/hardware.html

Do not download or redistribute Macintosh ROMs. Use a user-supplied lawful ROM.

## C.5 Current product and trademark

- Current App Store product: https://apps.apple.com/us/app/kid-pix-5-the-steam-edition/id1249381439
- Software MacKiev Kid Pix site: https://www.mackiev.com/kidpix/index.html
- Software MacKiev update page with trademark notice: https://www.mackiev.com/update_center/kidpix/kpselect.html
- Trademark record: https://tsdr.uspto.gov/#caseNumber=74289094&caseSearchType=US_APPLICATION&caseType=DEFAULT&searchType=statusSearch
- Secondary trademark summary: https://trademarks.justia.com/742/89/kid-74289094.html
- Brand acquisition announcement: https://www.prnewswire.com/news-releases/software-mackiev-acquires-kid-pix-brand-from-houghton-mifflin-harcourt-131872478.html

## C.6 Naming research and collisions

- Existing `KiddoPaint: Kids Coloring Book`: https://apps.apple.com/us/app/kiddopaint-kids-coloring-book/id6744039262
- USPTO TSDR search for historical KIDPAD filing, serial 74495238: https://tsdr.uspto.gov/#caseNumber=74495238&caseSearchType=US_APPLICATION&caseType=DEFAULT&searchType=statusSearch
- USPTO TSDR search for historical KIDPAD filing, serial 85255750: https://tsdr.uspto.gov/#caseNumber=85255750&caseSearchType=US_APPLICATION&caseType=DEFAULT&searchType=statusSearch
- Secondary summary of the 2011 KIDPAD filing reported abandoned in 2018: https://furm.com/trademarks/kidpad-85255750
- Secondary summary of European filing 009777731 reported expired: https://www.trademarkelite.com/europe/trademark/trademark-detail/009777731/KidPad
- Historical collaborative drawing/storytelling system using the KidPad name: https://dijitalmedyavecocuk.bilgi.edu.tr/2021/01/01/dijital-oykuleme-teknolojisinin-cocuklar-icin-faydalari/
- Historical children's tablet hardware sold as Bitmore KidPad: https://www.quest.gr/el/archive/nea-bitmore-kidpad-apo-ten-info-quest-technologies-teleio-paschalino-doro

These are preliminary research leads, not a legal clearance opinion. Verify current status through official registries and counsel before commercial release.

## C.7 Apple platform documentation

- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Kids design guidance: https://developer.apple.com/kids/
- `UITouch`: https://developer.apple.com/documentation/uikit/uitouch
- Apple Pencil interactions: https://developer.apple.com/documentation/uikit/apple-pencil-interactions
- `UIPencilInteraction`: https://developer.apple.com/documentation/uikit/uipencilinteraction
- Hover sample: https://developer.apple.com/documentation/uikit/adopting-hover-support-for-apple-pencil
- Predicted touches: https://developer.apple.com/documentation/uikit/minimizing-latency-with-predicted-touches
- PencilKit: https://developer.apple.com/documentation/pencilkit/
- `PKCanvasView`: https://developer.apple.com/documentation/pencilkit/pkcanvasview
- Simulator and device testing: https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices
- Simulator interaction: https://developer.apple.com/documentation/xcode/interacting-with-your-app-in-the-ios-or-ipados-simulator

## C.8 Licensing

- GNU GPLv3: https://www.gnu.org/licenses/gpl-3.0.en.html
- GNU GPL FAQ: https://www.gnu.org/licenses/gpl-faq.en.html
- Apple Standard EULA: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
- Apache License 2.0: https://www.apache.org/licenses/LICENSE-2.0

---

# Appendix D: Recommended Notices

## D.1 README historical disclaimer

> KidPad is an independent open-source project inspired by the design principles and early behavior of Kid Pix, created by Craig Hickman. KID PIX is a registered trademark of its owner. This project is not affiliated with or endorsed by The Software MacKiev Company.

## D.2 Asset disclaimer

> The public build contains only assets classified by the project’s asset ledger as verified public domain, separately licensed, or original to this project. Historical commercial assets may be used locally as research references but are not included in public releases without documented permission.

## D.3 Legal disclaimer

> Project documentation discusses licensing and intellectual-property risks for engineering purposes and does not constitute legal advice.

---

# Appendix E: Architecture Decision Records

## ADR-001: Native implementation

**Decision:** Build in native Swift.

**Rejected:** `WKWebView` wrapper.

**Reason:** A wrapper does not provide the desired input fidelity, adaptive behavior, architecture, or App Store differentiation.

## ADR-002: Custom raster canvas

**Decision:** Use a custom UIKit raster canvas.

**Rejected:** PencilKit as primary document engine.

**Reason:** The target behavior is destructive raster manipulation, not primarily editable ink strokes.

## ADR-003: Core Graphics first

**Decision:** Begin with CPU bitmap/Core Graphics.

**Rejected:** Full Metal engine from day one.

**Reason:** The product’s operations are simple and must be deterministic. Add GPU paths only after profiling.

## ADR-004: Clean-room source

**Decision:** Implement behavior independently and license new code under Apache-2.0.

**Rejected:** Mechanical Swift translation of the GPL JavaScript code.

**Reason:** Cleaner licensing and architecture for GitHub and possible App Store distribution.

## ADR-005: Quarantine unverified assets

**Decision:** Keep reference assets outside public release and enforce status at build time.

**Rejected:** Assume repository code license covers all assets.

**Reason:** Asset provenance is not established and commercial-era material is likely copyrighted.

## ADR-006: Canonical independent name

**Decision:** Use KidPad as the canonical product, repository, target, scheme, bundle, and documentation name.

**Rejected:** Earlier placeholder names, `KID PIX`, and `KiddoPaint`.

**Reason:** The product owner selected KidPad. It fits the iPad-first, child-friendly creative-pad concept while avoiding direct use of the active KID PIX product mark. Formal trademark and marketplace clearance remains a public-release gate because historical KidPad uses and filings exist.

## ADR-007: Separate Simulator and hardware acceptance

**Decision:** Treat them as independent gates.

**Rejected:** Synthetic Pencil tests as proof of physical behavior.

**Reason:** Simulator does not reproduce all hardware-specific features or performance.

---

# End of PRD
