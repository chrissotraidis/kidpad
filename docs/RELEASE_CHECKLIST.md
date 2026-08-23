# Public release checklist

This checklist keeps source publication, binary distribution, and marketplace release separate. It is an engineering checklist, not legal advice.

## Current readiness

| Release path | Status | Boundary |
| --- | --- | --- |
| Public GitHub source | Available | Repository is public |
| Local unsigned IPA | Ready | The recipient must sign it for their own device |
| Hosted unsigned IPA | Version 1.0.0 | iPad-only, unsigned, and intended for user-side signing |
| TestFlight or App Store | Not ready | Signing, store metadata, privacy review, and rights or trademark clearance remain separate work |

## Repository settings

- [ ] Confirm `main` is the intended release commit and the worktree is clean.
- [ ] Confirm only the public branches intended for preservation exist on the remote.
- [ ] Review [`README.md`](../README.md), [`RIGHTS_AND_LICENSES.md`](../RIGHTS_AND_LICENSES.md), [`NOTICE`](../NOTICE), and [`AssetLedger.json`](../AssetLedger.json).
- [ ] Confirm the README screenshot and app icon are intentionally public.
- [ ] Confirm GitHub Issues are enabled.
- [ ] Enable private vulnerability reporting after the repository becomes public.
- [ ] Add branch protection or a ruleset for `main` after the repository becomes public.

## Technical release gate

Run from a clean checkout:

```bash
zsh -n Scripts/*.sh
Scripts/verify_public_repo.sh
Scripts/verify_no_network.sh .
Scripts/build_public.sh
Scripts/package_public_ipa.sh
git diff --check
```

Then inspect the unsigned IPA:

```bash
unzip -tq build/releases/KidPad-v1.0.0-unsigned.ipa
unzip -l build/releases/KidPad-v1.0.0-unsigned.ipa
(cd build/releases && shasum -a 256 -c KidPad-v1.0.0-unsigned.ipa.sha256)
```

The IPA must contain no Classic Pack, JavaScript, HTML, reference bundle, signing material, or development-only WebKit linkage. `Scripts/verify_release_assets.sh` enforces the bundle and executable policy.

## GitHub release steps

1. Create an annotated `v1.0.0` tag from the verified `main` commit.
2. Create a GitHub Release using the `1.0.0` section of [`CHANGELOG.md`](../CHANGELOG.md).
3. Attach `KidPad-v1.0.0-unsigned.ipa` and `KidPad-v1.0.0-unsigned.ipa.sha256` only if binary distribution is intentionally approved.
4. Download both hosted assets and verify the checksum again.
5. Confirm the release page states that the IPA is unsigned and that the Classic Pack is downloaded only after user consent.

## Remaining nontechnical decision

The repository documents, but does not resolve, the rights uncertainty around historical media and the KID PIX trademark. Making source public and hosting a binary are separate publication decisions. The maintainer should make those decisions consciously and obtain qualified legal advice if independent clearance is required.
