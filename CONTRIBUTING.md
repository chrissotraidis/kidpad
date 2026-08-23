# Contributing to KidPad

Thanks for helping make KidPad a friendly, native iPad drawing app.

## Before you start

For bugs, search existing issues first. For larger changes, open an issue to
describe the user-facing behavior before investing in a broad implementation.
Small fixes, tests, documentation, and accessibility improvements can go
straight into a pull request.

## Development workflow

1. Create a focused branch from `main`.
2. Build and test the public profile with [`docs/BUILDING.md`](docs/BUILDING.md).
3. Keep changes scoped and include a regression test or Simulator reproduction
   when practical.
4. For UI changes, include the Simulator device/runtime and before/after
   screenshots or a short evidence note.
5. Run `git diff --check` before opening the pull request.

The native app lives in `Sources/`; automated coverage is in `Tests/` and
`UITests/`. Prefer changes to the native canvas and workspace over changes to
the optional web reference harness.

## Public-safe contributions

Do not add credentials, ROMs, copied historical PNG/WAV files, or the local
`Resources/JSKidPix` bundle. Changes to the pinned Classic Pack catalog or any
new bundled assets must include their source, license, and integrity data. Update
[`RIGHTS_AND_LICENSES.md`](RIGHTS_AND_LICENSES.md) when a contribution changes
the asset or third-party-code boundary.

Use `ReleasePublic` for screenshots and binaries shared in issues or pull
requests. The ignored `Resources/FidelityDev` cache must never become target
membership.

## Pull requests

A good pull request explains the user-visible result, lists the validation
performed, and calls out known limitations. Reviewers may ask for a narrower
scope, a test, or clearer rights information before merging.

By submitting a contribution, you agree that it may be distributed under the
Apache License 2.0 used by this project, unless you and the maintainer have
agreed otherwise in writing.
