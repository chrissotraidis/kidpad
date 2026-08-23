# Historical provenance

This document records how KidPad came to exist, which earlier projects it
references, what was reused, what was independently implemented, and what is
still unknown. It is a project history, not legal advice or a claim of complete
historical or algorithmic fidelity.

## Provenance at a glance

| Stage | What existed | Relationship to the next stage |
| --- | --- | --- |
| Original Kid Pix, 1989 | Craig Hickman's black-and-white Macintosh paint program | Public archives preserve a compiled Motorola 68K application, not its editable source |
| Expanded Kid Pix, 1990 to 1991 | Kid Pix Professional, followed by Brøderbund's commercial color-and-sound Kid Pix 1.0 | Added color, sounds, tools, artwork, and contributions beyond the 1989 freeware application |
| JSKidPix, 2021 | A new HTML and JavaScript reimplementation by Vikrum Nijjar and contributors | Recreated visible behavior for the browser and published a collection of PNG and WAV media |
| KidPad, 2026 | A new native Swift, SwiftUI, UIKit, and Core Graphics application | Used one pinned JSKidPix revision as its behavior catalog and optional media source |

The practical lineage is therefore:

`original compiled application -> JSKidPix reconstruction -> KidPad native reconstruction`

That lineage does not mean that original Macintosh machine code, Pascal source,
or JavaScript executes inside KidPad. It describes the sequence of references
used to understand the experience.

## The original Macintosh applications

Craig Hickman's own history says that he first programmed Macintosh software in
Rascal and later moved to Pascal. It also distinguishes three early releases:

- The first Kid Pix was a black-and-white program designed for the original
  Macintosh's 512 x 342 display.
- Hickman began distributing that version in November 1989 as freeware.
- Kid Pix Professional added color, sounds, and more tools in 1990.
- Brøderbund published the expanded commercial Kid Pix 1.0 in March 1991.

The 1989 application's internal help identifies the program as copyright 1989
by Craig Hickman and permits that version to be given away and distributed. It
does not contain or offer the program's editable source code.

Sources:

- [Craig Hickman, "Kid Pix: The Early Years"](https://red-green-blue.com/kid-pix-the-early-years)
- [Internet Archive: noncommercial 1989 Kid Pix](https://archive.org/details/kid-pix-10)
- [Internet Archive: commercial Kid Pix 1.1](https://archive.org/details/kid-pix-11)
- [Info-Mac archive description](https://www.applefritter.com/node/13664)

## Original-source investigation

On August 23, 2026, the KidPad project performed a public archival search for
the original Kid Pix source. The search covered the Internet Archive, Info-Mac
mirrors, the Garbo CD archive, Macintosh software archives, GitHub's public
repository index, Craig Hickman's current and Wayback-preserved sites, JSKidPix
history and issues, and the Computer History Museum's public research material.

Two preserved disk images were downloaded and their HFS filesystems and
Macintosh resource forks were inspected directly:

| Image | SHA-256 | Inspection result |
| --- | --- | --- |
| `KidPix10.img` | `d9af1f8b103a680506e7b98e683387b2489820cedf9a88afe2d67a3ef0a3f5a9` | The Kid Pix application has a 103,664-byte resource fork with 102 resources, including five compiled `CODE` segments. No Pascal, Rascal, project, or resource-source files were present. |
| `KidPix11.img` | `6047bbf9a576a0406eb6f34c91f4bf906a467674576267632431acd501365c0c` | The Kid Pix application has a 681,139-byte resource fork with 338 resources, including nine compiled `CODE` segments, 147 `PICT` resources, and 24 `snd ` resources. No editable source project was present. |

The 1989 `CODE` resources retain a few procedure-like text fragments, but they
are compiled 68K instructions, not original Pascal. They omit the original
comments, types, project structure, and most human-readable names.

The Info-Mac `kid-pix.hqx` download and the Garbo CD `KIDPIX.CPT` entry resolve
to the same Compact Pro application payload. Their archive descriptions call it
the Kid Pix paint program, not a source distribution.

No public source release was found. This does not prove that the source no
longer exists. It may survive on private development media or in an archival
collection that has not been digitized or publicly cataloged.

The Internet Archive describes its holdings as original binaries and related
digital ephemera. Craig Hickman also donated Kid Pix artifacts and ephemera to
the Computer History Museum. The public descriptions do not confirm whether
that donation includes source disks. The museum accepts research and
digitization inquiries for material that is not available online.

Sources:

- [Internet Archive Artist Residency exhibition description](https://www.evergoldprojects.com/exhibition/the-internet-archives-2019-artist-in-residency-exhibition-june-29-august-17/)
- [Computer History Museum research access](https://computerhistory.org/access-and-research/)

## How JSKidPix was made

JSKidPix describes itself as an HTML and JavaScript reimplementation. Its Git
history begins in August 2021 and does not contain the original Kid Pix source.

Its public issue history provides a concrete example of its reconstruction
method. While investigating a 3D brush, contributors:

1. drew controlled examples in the original application;
2. compared stroke direction, offset, pattern, and speed;
3. asked Craig Hickman for a high-level explanation;
4. reverse engineered the public 1989 executable when observation was not
   sufficient; and
5. implemented and visually tested the resulting browser behavior.

The discovered effect was based on two simultaneous strokes: a solid line and
an offset halftone line. That is representative of how an effect that looks
mathematically complex can be recreated from ordinary drawing primitives once
its construction is understood.

JSKidPix also credits established open-source graphics components for general
problems such as curve fitting, path simplification, dithering, smoothing,
spatial lookup, and WebGL image effects. These include CanvasDither,
`simplify-path`, `fitCurve`, `glfx.js`, `kdtree`, `smooth.js`, and other
components listed in its `NOTICE` file.

Sources:

- [JSKidPix repository](https://github.com/vikrum/kidpix)
- [JSKidPix 3D-brush investigation](https://github.com/vikrum/kidpix/issues/9)
- [Pinned JSKidPix revision used by KidPad](https://github.com/vikrum/kidpix/tree/99c67f3427d229f7db60b03dcf19df4d8c2a8ecf)

### JSKidPix media

The JSKidPix repository publishes PNG and WAV files used for its interface,
stamps, effects, and sounds. Some filenames resemble the output of classic Mac
resource-extraction tools. The repository does not provide a complete
file-by-file account of who created each historical image or sound, which Kid
Pix release supplied it, or which extraction process was used.

KidPad therefore treats the upstream repository and exact commit as the known
source of its optional Classic Pack. It does not claim that the deeper
historical provenance of every media file has been independently established.

## How KidPad was made

KidPad Version 1 was developed as a native Apple-platform application. Its
shipping drawing engine is implemented in Swift and Core Graphics. SwiftUI and
UIKit provide the workspace, menus, document flow, touch handling, and Apple
Pencil integration.

The implementation boundary is:

| Component | KidPad source or reference |
| --- | --- |
| Application lifecycle, workspace, canvas, documents, input, and audio playback | New native KidPad code |
| Tool catalog, visible behavior, option ordering, palette values, and sound mapping | Studied from pinned JSKidPix and checked through tests and visual comparison |
| Classic artwork and sounds | 228 PNG and WAV data files downloaded from pinned JSKidPix only after user consent |
| Bitmap-style font | Separately licensed ChiKareGo2 font documented in `docs/THIRD_PARTY_FONTS.md` |
| Original Kid Pix source code | Not obtained or used |
| Original 68K executable code | Not copied, linked, translated, or executed by KidPad |
| JSKidPix JavaScript | Not included or executed by the shipping app |

KidPad's native code was not produced by mechanically translating JavaScript
line by line. Developers studied the behavior exposed by JSKidPix, implemented
equivalent native operations, compared results, wrote automated tests, and
iterated on an iPad and Mac. Some tools are close behavioral recreations while
some complex effects remain deliberate native approximations. The current
status is recorded in [`PARITY_MATRIX.md`](PARITY_MATRIX.md).

### AI-assisted engineering

KidPad was developed by Chris Sotraidis with AI-assisted software engineering.
AI tools helped inspect references, implement and review Swift code, build
tests, investigate failures, draft documentation, and iterate on the interface.
Product direction, scope decisions, installation approval, physical-device
testing, and release acceptance were performed by the project maintainer.

AI did not provide or recover original Kid Pix source code. No private Kid Pix
source tree was supplied to the AI tools used for KidPad, and the project did
not knowingly use an undisclosed source-code leak. Its implementation inputs
were the public JSKidPix repository, public historical material, observed
application behavior, standard Apple frameworks, and iterative testing.

## What is exact and what is approximate

"Recreated" does not mean that every original routine was recovered.

- Media files in the installed Classic Pack are verified against the pinned
  JSKidPix revision.
- The KidPad Swift implementation is native and independently structured.
- Standard drawing operations such as lines, shapes, compositing, flood fill,
  and image placement use modern Core Graphics implementations.
- Tool selection, option order, sound mapping, and the general interaction model
  follow the JSKidPix reference.
- Several Wacky Brush, Electric Mixer, texture, timing, and animation details
  remain approximations rather than proven matches to an original Kid Pix
  algorithm.

This distinction is intentional. Version 1 prioritized a complete, responsive,
native iPad experience while preserving explicit records of remaining parity
work.

## Rights and historical claims

The terms "freeware," "public domain," "open source," and "freely
downloadable" are not interchangeable.

- The preserved 1989 application identifies itself as copyrighted and permits
  that version to be redistributed for free.
- JSKidPix states that the original 1989 Kid Pix 1.0 was released into the
  public domain and publishes its repository under GPL-3.0.
- The GPL license on JSKidPix establishes terms for that repository, but it does
  not by itself prove the ownership or status of every older image, sound,
  trademark, or other historical work present in it.
- The color-and-sound commercial releases involved Brøderbund and additional
  credited contributors, so they should not be treated as identical to the
  1989 freeware application.

KidPad reports these facts and the remaining uncertainty rather than converting
an upstream statement into an independent clearance claim. See
[`../RIGHTS_AND_LICENSES.md`](../RIGHTS_AND_LICENSES.md) for the active
engineering boundary.

## Open historical questions

The following questions remain unanswered:

- Do Craig Hickman's original Pascal project and development disks still
  survive?
- Does the Computer History Museum hold source media that is not publicly
  cataloged or digitized?
- Which exact Kid Pix release supplied each PNG and WAV published by JSKidPix?
- What permissions, beyond the upstream repository license and statements,
  apply to each underlying historical media work?
- Which KidPad approximations differ materially from the authentic 1989 or 1991
  application behavior?

Future research should preserve the accepted Version 1 baseline, keep private
or restricted archival material out of the public repository, record every new
source and permission, and update this document when evidence changes.
