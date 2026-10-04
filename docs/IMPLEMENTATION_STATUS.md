# Empire Earth builder implementation and test record

## Current release

[v0.1.0-beta.2](https://github.com/lozza/Empire-Earth-Linux-Appimage/releases/tag/v0.1.0-beta.2)
contains the tested r7 builder, published as `Empire-Earth-Builder-x86_64.AppImage`.

- Size: **8,550,904 bytes**.
- SHA-256: `7c2e0d5675e20799741ea1ca995a2759d720071b94c856411952f32b181d3f51`.
- Matching source tag commit: `c20dccfa598816b9611257e2a858f839045b2ac8`.
- Release assets: builder and checksum only. Generated games remain private.

| Platform | Status |
| --- | --- |
| Bazzite x86_64, KDE, NVIDIA RTX 3080 | Working; packaged builder, build pipeline, renderer, scaling and base-game camera checks completed. |
| Steam Deck | Working in manual testing. |
| Linux Mint | Game rendering unresolved. Recorded Vulkan tests failed; experimental OpenGL played audio without an image. |

The following sections describe the components, fixes and recorded checks.
Earlier source commits retain the chronological development history.

## Input validation

The supported GOG installer is
`setup_empire_earth_gold_2.0.0.2974_gog_v3_(78415).exe`, SHA-256
`65758cb47fc9f8073fbc66ecc71dbd8f7ee573787100ee14c5e8a1f00acfd0da`.
Innoextract extracts separate base-game and Art of Conquest folders without
running the Windows installer. Other installer versions and the community
setup patcher aren't supported.

Nine native DirectMusic DLLs must be supplied locally as a matching `dxnt.cab`
or extracted directory. `directmusic.sha256` records their checked hashes. The
original Wine DirectMusic route crashed; these DLLs allowed the game to stay
running. Commercial game files and DirectMusic aren't public release assets.

## Builder portability

The GUI is compiled with Freedesktop SDK 24.08. Its highest referenced glibc
version is **2.39**, checked on the actual packaged GUI. The initial Bazzite
host build required **2.43** and was replaced.

The final builder also contains checked SDK libxkbcommon, libxkbcommon-x11 and
libxcb-xkb. An X11 test exposed a missing `libxkbcommon-x11.so`; packaging these
libraries fixed that startup failure. Their actual MIT/X11 licence files are
included. Absolute SDK licence links are resolved into real notice files.

The packaged r7 GUI opened using Bazzite's X11 backend. A Wayland smoke test
remained open until its intentional timeout. Non-fatal Mesa warnings were
retained in the logs. The form is scrollable and its inputs, local mod browse,
resolution choice, backup action and build progress connect to the pipeline.

`package-builder.sh` checks tool/library hashes and rejects checked components
requiring glibc newer than 2.39. The AppImage checksum and `--check` passed.
Extracted build and camera-helper scripts matched their source byte for byte.

## Component acquisition and licences

The small builder downloads the following components, verifies sizes and hashes,
and reuses valid cached copies:

| Component | Download size | SHA-256 |
| --- | ---: | --- |
| Kron4ek Wine 11.0 amd64-wow64 | 73,144,724 bytes | `39574efa1132c3ca0d5c77dd2eddbe4a49cca0d6cc2c290ff4924493a1c40314` |
| DXVK 2.7.1-6-fc848a4 | 15,371,492 bytes | `96a78de1cbe2275c9325d8a69212d9f742d5e48b3507c6f3ad684d1a186c389f` |
| appimagetool | 15,092,216 bytes | `a6d71e2b6cd66f8e8d16c37ad164658985e0cf5fcaa950c90a482890cb9d13e0` |

Exact URLs and extraction checks are in `build-game.sh`.

Common 64-bit dependencies come from Freedesktop Platform 24.08, pinned to
commit `9a6d66049b19987a22bf81015ce0d1fde260df85a45e54695aad3c82f1e198ee`.
Its checked libgcc SHA-256 is
`578c566c328971dd6cee27ea89c65530c84c8810e1dd335adda8a18d6fcb8983`;
libpulse SHA-256 is
`a58e74f3b684d0d08ce9d8f4e632d0753d0df7b07f8670d0e86a4b2b4fbaade4`.

The acquisition route uses the host Flatpak command, sets up an idempotent
user-level Flathub remote when needed, and includes bounded stderr in failures.
The required common libraries and licences are copied into the private game.
Glibc-family libraries and GPU drivers are excluded. Host graphics libraries
are preferred to keep dependencies matched to the active driver.

Wine's LGPL notice, source and build-recipe references, DXVK's licence, runtime
component licences and builder tool notices are recorded in
`THIRD_PARTY_NOTICES.md` and included in the relevant packages.

The final r7 packaged pipeline completed a full cached GOG/CAB build with a
locally supplied camera ZIP. The earlier default-camera pipeline also completed
without a mod payload. The empty-cache acquisition checks performed for beta.1
used its older Soda/32-bit route; they are separate from beta.2's cached build
checks. A clean-cache beta.2 matrix across platforms hasn't been recorded.

## Wine, graphics and audio

Wine 11.0 WoW64 runs the 32-bit Windows game and DLLs using **64-bit Linux
processes**. Wine and wineserver are ELF64; Wine uses
`/lib64/ld-linux-x86-64.so.2`. The checked Wine executable SHA-256 is
`57c017cf62031e3e2b8f53ed0e43f2f1fe996b98f0e301224e9c5e1b31b1e56c`.

This replaces beta.1's Soda runner and `runtime32`, removing the requirement
for `/lib/ld-linux.so.2`, Compat.i386 and an ELF32 Vulkan driver. The Windows
DirectMusic DLLs are installed in `syswow64`. The GOG DirectDraw wrapper, DXVK
D3D9 DLL and native DirectMusic route are configured explicitly.

The launcher finds an ELF64 Vulkan ICD in standard or Flatpak locations,
resolves relative and sandbox paths, and requires NVIDIA drivers to match the
active driver version. It writes a private absolute-path manifest and sets
`VK_DRIVER_FILES` and `VK_ICD_FILENAMES`. An absent compatible driver produces
an error. Finding an ICD file doesn't guarantee successful GPU enumeration.

The launcher carries runner/runtime library paths, including Pulse directories,
and sets `WINEDLLPATH`. The bundled ELF64 libpulse and matching pulsecommon are
paired for the final game process. The system-default audio output is used.
Host libraries stay ahead of common fallbacks for the graphics stack; an earlier
ordering caused a host layer's missing `wl_fixes_interface` symbol.

Bazzite dependency inspection found **77 Unix ELF files, all ELF64**, including
host loader/libc/Vulkan, matching NVIDIA libraries and bundled Pulse libraries.
A repeat renderer test succeeded with the 32-bit Linux loader masked. Driver
fixtures covered relative distro paths, Flatpak remapping and ELF32 rejection.

## Prefix, game data and display

The Wine 11 prefix is `prefix-wow64-v11` beneath the existing XDG data folder.
It is initialized with the packaged runner and locked/staged for recovery after
interruption. The old prefix, writable game copy and saves are retained. Registry
migration imports only game settings and excludes obsolete installation paths.
Wine Mono/menu-builder overrides apply throughout setup and launch.

A restricted G: mapping points directly to the writable game directory. Without
the correct working directory, Wine 11 started in `C:\windows` and the game
crashed while looking for assets. The Z: mapping is removed.

The final launcher starts the game directly and uses the GOG wrapper with
`display=desktop`, `aspect=enabled`, `scaling=fit` and default windowed
presentation. Game resolution settings remain separate from desktop scaling.
A one-time configuration migration updates older display settings while
preserving subsequent game preferences. `--fullscreen` and `--windowed` provide
explicit alternatives.

The earlier extra Wine virtual desktop produced a 3440×1440 window containing a
1280×720 surface in the upper-left corner. Screenshots reproduced that defect.
Direct launch fixed the placement; the packaged r5 game showed a centred,
full-height image with aspect-preserving side bars. Switching to windowed
presentation then recovered the image after one startup minimise/restore test.
Repeated recovery during gameplay remains outside the recorded test coverage.

## Optional camera mod

The final GUI dropdown offers **Original camera — no mod** by default, or
**dreXmod 2.01** with an explicitly selected local ZIP. There is no automatic
mod download and no mod DLL in the public builder or source repository.

The tested ZIP is 490,495 bytes, SHA-256
`97d9fb875f2a96fd0acd27d87e68a83a2b34f9840112a1ebc794ea6bd0537275`.
The extracted DLL SHA-256 is
`5464f3db1ee70d442e721e269c523a8d3e59fcb126c249c7fe24ccb23f17844b`.
These hashes were measured from the tested community download, rather than
independently published upstream checksums. The archive provides no public
redistribution licence; it is supplied locally for the private game.

The initial base-game camera test loaded `dreXmod.dll` natively and the zoom
adjustment worked. MaxZ 30 was too far out, so the default was reduced to **20**.
`camera-only.config` disables scenario hosting, lobby extension, menu settings
and HUD features. The archive's lobby resource modification isn't installed.

The helper preserves existing configuration and protects unknown DLLs.
`--no-camera` moves only the known DLL aside; `--camera` restores the included
copy. Original-camera builds contain no patch. Fixtures checked both choices,
retained edited preferences, unknown DLL protection and missing-payload errors.
The exact generated r7 game passed camera-off/on initialization checks using an
isolated verification prefix. Expansion camera behaviour hasn't been checked.

## Recorded launch results

- Bazzite fresh-prefix Wine 11 initialization exceeded an initial 55-second
  timeout on the test HDD. Resuming completed setup and reached the RTX 3080
  DXVK renderer. Repeat base-game and Art of Conquest launches reached a
  1280×720 swapchain during development. Timed stops are test stops, rather
  than normal game exits.
- Later direct-launch screenshots verified desktop-size image placement.
  Manual base-game testing confirmed that the game worked well and that the
  camera adjustment took effect. A windowed startup minimise/restore recovered
  its image.
- Steam Deck manual testing confirmed that the game works.
- Full save/load persistence and repeated recovery during gameplay haven't
  been covered by the recorded regression checks.

## Mint failures still under investigation

Beta.1's Mint build completed, but the game failed at
`wine_vkCreateInstance`, result `-9`, followed by
`DxvkInstance::createInstance: Failed to create Vulkan instance`.
A 32-bit Pulse preload warning also appeared in a 64-bit process; that warning
alone doesn't establish the root cause.

A separate Mint live-USB test on NVIDIA first exposed a missing 32-bit loader
and matching ELF32 driver in the old route. The original Mint failure's rejected
ICD/dependency wasn't identified. The WoW64 route removes those 32-bit Linux
requirements.

The later Wine 11 Mint live log selected
`/usr/lib/x86_64-linux-gnu/libvulkan_nouveau.so`, SHA-256
`b5e4de47f1a01a37ad9e42e89a82e560f299132c5f7845777668343c5395cdb7`.
Vulkan reported `Failed to detect any valid GPUs in the current config`; Wine
reported `Failed to enumerate physical devices, res -3`, followed by the DXVK
instance failure. The log didn't include the game artifact's checksum.

The OpenGL attempt played audio without an image. Its hardware renderer and
performance aren't established. GPU support, kernel/firmware and boot/driver
configuration remain possible causes; the available logs don't prove which one
is responsible or that live boot itself is the cause.

## Packaging and release verification

An inherited `OWD` caused a reproduced nested appimagetool failure:
`Could not cd into /var/home/bazzite/Downloads/Empire-Earth-Mint-Test`.
Both builder and game packaging now use `env -u OWD` for the nested tool.
Repackaging with the same invalid `OWD` succeeded, and the final full pipeline
completed.

Beta.2 was published as a pre-release. Its live builder and checksum were
downloaded again and checked for size, checksum-file contents and byte-for-byte
equality with the tested local artifact. The release tag resolves to the matching
source commit. Documentation edits leave the release artifact and tag unchanged.

Local verification logs and screenshots are retained outside the published
source, including `r7-local-camera-build.log`, `r7-camera-off.log`,
`r7-camera-on.log`, `r7-builder-gui.png` and release verification metadata.
Some earlier temporary logs didn't survive reboot; their limits are preserved
in the historical source revisions.
