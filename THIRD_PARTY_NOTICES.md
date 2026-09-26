# Third-party notices

This repository publishes the Empire Earth builder **source and small builder
AppImage**. The builder does not contain Empire Earth, Wine, DXVK, a graphics
driver, a 32-bit Flatpak runtime, or Microsoft DirectMusic. The generated game
AppImage contains the user's own GOG and DirectMusic files and must stay private.

The builder GUI is GPL-3.0-only and uses [Slint 1.13.1](https://github.com/slint-ui/slint)
under Slint's GPLv3 distribution option. The release AppImage carries the exact
Rust crate licence files and manifests under `licenses/rust-crates/`; the
[Cargo.lock](gui/Cargo.lock) fixes their versions.

The release AppImage also includes:

- [innoextract 1.9](https://github.com/dscharrer/innoextract), with its bundled
  licence directory for innoextract, Boost, compression libraries and its C++
  runtime.
- `file` 5.46 and `magic.mgc` from Fedora's `file-5.46-10.fc44` package,
  with SDK 24.08 `libmagic.so.1` and `licenses/file-COPYING`; the upstream project is
  [file](https://github.com/file/file).
- An AppImage type-2 runtime corresponding to
  [commit caf24f9](https://github.com/AppImage/type2-runtime/commit/caf24f9f712084686bfc24a70b75e50df0aefb9c),
  with `licenses/type2-runtime-LICENSE`.

At build time, the builder fetches these free components from their upstream
sources and validates pinned hashes or Flatpak commits before using them:

- [Soda Wine 9.0-1](https://github.com/bottlesdevs/wine/releases/tag/soda-9.0-1),
  LGPL-2.1-or-later, archive SHA-256
  `c38fe0ad3c12a49b61ec1fcaea5c5d8da4a3d1afc5991befe2af6b125f014c28`.
- [DXVK 2.7.1-6](https://github.com/bottlesdevs/components/releases/tag/dxvk-2.7.1-6-fc848a4),
  zlib, archive SHA-256
  `96a78de1cbe2275c9325d8a69212d9f742d5e48b3507c6f3ad684d1a186c389f`.
- [appimagetool](https://github.com/AppImage/appimagetool/releases/tag/continuous),
  SHA-256 `a6d71e2b6cd66f8e8d16c37ad164658985e0cf5fcaa950c90a482890cb9d13e0`.
- Freedesktop Platform Compat.i386 24.08 and GL32.default 25.08, at the exact
  Flatpak commits recorded in [build-game.sh](build-game.sh).

The builder requires the user to supply GOG and DirectMusic input files locally.
Neither input file is part of this repository or its release downloads.
