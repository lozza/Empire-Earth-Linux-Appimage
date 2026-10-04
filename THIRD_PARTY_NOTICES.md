# Third-party notices

This repository publishes the Empire Earth builder **source and small builder
AppImage**. The builder does not contain Empire Earth, Wine, DXVK, a graphics
driver, a Flatpak runtime, or Microsoft DirectMusic. The generated game
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

- [Wine 11.0 WoW64, Kron4ek vanilla build](https://github.com/Kron4ek/Wine-Builds/releases/tag/11.0),
  LGPL-2.1-or-later, archive SHA-256
  `39574efa1132c3ca0d5c77dd2eddbe4a49cca0d6cc2c290ff4924493a1c40314`.
  The corresponding upstream source is
  [Wine 11.0](https://dl.winehq.org/wine/source/11.0/wine-11.0.tar.xz),
  with the [tagged build recipe](https://github.com/Kron4ek/Wine-Builds/tree/11.0).
  The builder carries `licenses/Wine-LGPL-2.1` for the private game output.
- [DXVK 2.7.1-6](https://github.com/bottlesdevs/components/releases/tag/dxvk-2.7.1-6-fc848a4),
  zlib, archive SHA-256
  `96a78de1cbe2275c9325d8a69212d9f742d5e48b3507c6f3ad684d1a186c389f`.
- [appimagetool](https://github.com/AppImage/appimagetool/releases/tag/continuous),
  SHA-256 `a6d71e2b6cd66f8e8d16c37ad164658985e0cf5fcaa950c90a482890cb9d13e0`.
- Freedesktop Platform 24.08, commit
  `9a6d66049b19987a22bf81015ce0d1fde260df85a45e54695aad3c82f1e198ee`.
  Only common 64-bit libraries are copied into the private game, with glibc
  and GPU drivers excluded. Its component licences are carried in the game.
  No 32-bit Linux runtime or graphics driver is needed by the new WoW64 route.

The builder requires the user to supply GOG and DirectMusic input files locally.
Neither input file is part of this repository or its release downloads.
# Optional dreXmod camera patch

When selected, the builder requires the user's own local dreXmod 2.01 ZIP.
Users can obtain it from the creator/community page at
https://empireearth.eu/drexmod/. The builder does not download or distribute
the mod. The tested standalone ZIP is checked at 490,495 bytes, SHA-256
`97d9fb875f2a96fd0acd27d87e68a83a2b34f9840112a1ebc794ea6bd0537275`;
its PE32 DLL is checked against
`5464f3db1ee70d442e721e269c523a8d3e59fcb126c249c7fe24ccb23f17844b`.
These are hashes measured from the tested archive. The builder distributes no
dreXmod DLL. The archive includes no licence establishing public redistribution
permission; do not treat it as GPL or redistribute generated game AppImages.
The camera configuration supplied by this project disables other mod features.

## Builder keyboard libraries

The builder includes libxkbcommon, libxkbcommon-x11 and libxcb-xkb from the
Freedesktop SDK 24.08 used for the GUI build. Their MIT/X11-style copyright and
licence notices are included in `licenses/gui-keyboard/` inside the builder.
Source projects: https://github.com/xkbcommon/libxkbcommon and
https://gitlab.freedesktop.org/xorg/lib/libxcb.
