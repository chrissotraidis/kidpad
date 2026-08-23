# Rights and licenses

This file describes the project’s engineering boundary. It is not legal advice
or a clearance opinion.

## Native source

The original Swift/UIKit/SwiftUI source, tests, Xcode project scaffolding, and
documentation are licensed under the Apache License 2.0. See [`LICENSE`](LICENSE)
and [`NOTICE`](NOTICE).

## Downloaded Classic Pack

KidPad's app bundle and public source tree do not contain the classic PNG/WAV
files. After the user agrees on first launch, the app downloads a fixed catalog
of data files directly from
`vikrum/kidpix@99c67f3427d229f7db60b03dcf19df4d8c2a8ecf`, verifies the complete
pack digest, and stores it in the user's Application Support directory. KidPad
does not download or execute JavaScript.

The upstream repository is published under GPL-3.0, and its README states that
the original 1989 Kid Pix 1.0 was released into the public domain. KidPad relies
on that upstream publication, license, and statement as the basis for offering
the download. The pack is obtained from the exact upstream revision rather than
redistributed inside the KidPad repository or application binary.

That basis is not independent proof that every underlying historical image,
sound, logo, or trademark is in the public domain or was separately cleared by
the upstream publisher. Public availability alone is not proof of ownership.
Users should review the
[upstream source](https://github.com/vikrum/kidpix), its
[public-domain statement](https://github.com/vikrum/kidpix/tree/99c67f3427d229f7db60b03dcf19df4d8c2a8ecf), the
[GPL-3.0 license](https://github.com/vikrum/kidpix/blob/99c67f3427d229f7db60b03dcf19df4d8c2a8ecf/LICENSE),
and this residual uncertainty before downloading.

`Resources/FidelityDev` is an ignored local cache for private tests. Its
contents must never be committed or packaged.

## JSKidPix reference

The optional local copy under `Resources/JSKidPix` is used only by the opt-in
`--reference-web` comparison harness and is excluded from public builds. KidPad
does not mechanically translate or download that JavaScript into the native
engine.

## Bundled font

`Resources/Licensed/ChiKareGo2.ttf` is bundled under Creative Commons
Attribution. Its source, attribution, and hash are recorded in
[`docs/THIRD_PARTY_FONTS.md`](docs/THIRD_PARTY_FONTS.md).

## Name and inspiration

KidPad is an independent, unofficial native recreation of the early Kid Pix
experience. It deliberately recreates recognizable tools, presentation,
artwork, and sounds obtained through the pinned JSKidPix pack. KID PIX is a
trademark of its respective rights holder. KidPad is not affiliated with,
endorsed by, sponsored by, or licensed by The Software MacKiev Company, Craig
Hickman, or any current Kid Pix rights holder.

Marketplace and commercial release clearance remains a separate step. Do not
infer permission from a file being present locally, a repository being
accessible, or a third-party source tree being public.

## Before adding third-party material

Record the source, license, version or commit, intended use, and redistribution
rights before adding code or assets. Update `NOTICE`, `AssetLedger.json`, and
this document where applicable, and ensure `Scripts/build_public.sh` plus
`Scripts/verify_release_assets.sh` still pass.
