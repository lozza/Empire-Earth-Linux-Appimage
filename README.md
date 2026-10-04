# Empire Earth Gold Edition on Linux

**Empire Earth Builder** is a desktop tool that turns your supported GOG Empire Earth Gold Edition installer into a Linux AppImage you can launch directly. Choose the installer, your own DirectMusic files, an output folder and a resolution; the tool builds the game app for you.

The original Windows game runs with packaged compatibility software. The game's code has not been rewritten as native Linux software. This is an unofficial fan project and a **public beta**.

**[Download Empire Earth Builder v0.1.0-beta.2](https://github.com/lozza/Empire-Earth-Linux-Appimage/releases/tag/v0.1.0-beta.2)** — under **Assets**, choose `Empire-Earth-Builder-x86_64.AppImage`. A matching `.sha256` file is provided.

## What's new in beta.2

- **Updated compatibility route:** Wine 11.0 WoW64 runs the 32-bit Windows game through 64-bit Linux libraries, removing the previous need for a 32-bit Linux loader and Vulkan driver.
- **Display fixes:** the GOG wrapper scales to the desktop with the correct aspect ratio. Windowed presentation fills the tested KDE desktop and improves recovery after minimising.
- **Optional wider camera:** a named mod dropdown lets you select your own local dreXmod ZIP. Original camera is the default; the mod is never downloaded automatically or included in the public builder.
- **Builder portability:** the GUI is compiled with Freedesktop SDK 24.08, has a checked glibc 2.39 ceiling, and includes its required X11 keyboard libraries.

See the [changelog](CHANGELOG.md) and [recorded implementation milestones](docs/IMPLEMENTATION_STATUS.md) for details. Beta.2 supersedes beta.1, whose generated game failed to launch on Mint. The revised route has been tested on Bazzite; **successful Mint and Steam Deck game launches are still unverified**.

## Your local files

This beta accepts only the verified GOG Gold Edition installer:

`setup_empire_earth_gold_2.0.0.2974_gog_v3_(78415).exe`

SHA-256: `65758cb47fc9f8073fbc66ecc71dbd8f7ee573787100ee14c5e8a1f00acfd0da`.

A renamed copy with identical contents is accepted. Other installer versions, installed folders and the community `EE_Setup.exe` patcher are not supported in this beta. The GOG installer is extracted directly, without running its Windows setup program.

The tested audio route also requires **nine older Microsoft DirectMusic DLLs** absent from this GOG installer. Supply your own matching `dxnt.cab` from a DirectX installation you own, or a folder containing its extracted DLLs. The builder checks their exact hashes. The tested CAB came from a local Age of Empires III DirectX folder. Extracting a CAB requires the host `7z` command; an extracted DLL folder does not.

The public builder contains **no Empire Earth, DirectMusic or dreXmod files**. These inputs stay local and are never uploaded. Generated game AppImages contain commercial files and must stay private.

## First build and requirements

**The first build needs an internet connection.** The builder downloads pinned Wine, DXVK and AppImage packaging tools, verifies their sizes and SHA-256 hashes, and caches valid copies. These three downloads total about **104 MB**. It also obtains a pinned Freedesktop Platform 24.08 through Flatpak when needed; the additional transfer depends on what is already installed. Required common libraries and licences are placed in the generated game AppImage.

The builder uses the host `flatpak`, `curl`, `tar`, `sha256sum` and standard shell tools. It sets up a user-level Flathub remote when needed, without sudo. CAB and optional mod ZIP extraction also require `7z`. **No Bottles or system Wine/Proton installation is required.** Allow substantial free space for extraction, the component cache and game output; 8 GB is a useful starting allowance.

The game needs an x86_64 Linux desktop with a working **64-bit Vulkan driver** compatible with the active GPU. Its launcher checks standard and Flatpak driver locations and uses a private manifest. GPU drivers are not included in the public builder. A driver file alone does not establish that the GPU works; the launcher records Vulkan diagnostics when launch fails.

## Build and play

### Linux desktop

1. Download the builder and mark it executable in your file manager, usually under **Properties → Permissions**.
2. Open it. Select the supported GOG installer, your DirectMusic CAB or DLL folder, and an output folder.
3. Choose a starting resolution. Leave **Camera / zoom mod** at **Original camera — no mod**, or follow the optional camera instructions below.
4. Click **Build AppImage** and wait for **BUILD COMPLETE**. Download and packaging progress appears in the diagnostic log.
5. Open `Empire-Earth-Gold-GOG-private.AppImage` in the output folder. Use `--aoc` to play **The Art of Conquest**.

The game starts with desktop-size, aspect-preserving windowed presentation. On the tested KDE desktop it fills the screen. The resolution choice sets the game's starting resolution, independently of this display scaling; subsequent in-game preferences are kept. `--fullscreen` and `--windowed` are available for comparison.

### Steam Deck

Build in **Desktop Mode**, following the same steps. **1280×720** is a suggested starting preset based on the HP1 portability work. Both that preset and 1280×800 remain unverified for this Empire Earth release on Deck. You can add your generated game AppImage to Steam, but Gaming Mode, controls and first-run behaviour still need direct testing.

### Optional wider camera

The **Camera / zoom mod** dropdown defaults to **Original camera — no mod**.

To use **dreXmod 2.01**, obtain the standalone ZIP yourself from the [creator/community download page](https://empireearth.eu/drexmod/), select that named option, then use **Browse mod ZIP**. The builder accepts only the tested ZIP and verifies both the archive and DLL hashes. It does not download or distribute the mod.

The generated camera configuration uses a maximum zoom distance of **20**, with the mod's lobby, HUD, menu and scenario-hosting features disabled. Camera distance is separate from resolution. The base-game camera effect was confirmed by the user; expansion camera behaviour is unverified.

Games built with the mod accept `--no-camera` to disable the tested DLL and `--camera` to restore it. Without either flag, the Build dropdown determines the choice. An original-camera build contains no mod payload. Existing `dreXmod.config` preferences are preserved; `Camera/Zoom/MaxZ` can be edited there. A different installed mod DLL is protected against replacement.

## Saves, settings, backups and logs

Writable game files, saves, settings and prefixes live outside the read-only AppImage at:

`${XDG_DATA_HOME:-$HOME/.local/share}/empire-earth-gog-private-test/`

Rebuilding the AppImage does not remove this folder. Beta.2 creates a separate `prefix-wow64-v11`, retains the old prefix and game copy, and imports only game registry settings. Close the game before rebuilding or backing up.

**Back up saves and settings** in the builder creates a dated archive of the private game data. It includes the writable game copy and prefix, so it may be large.

The builder writes `empire-earth-builder.log` in the output folder. Game and Vulkan diagnostics are saved under the game-data folder at `logs/latest.log`. When reporting a problem, include your Linux version, GPU, chosen resolution and relevant log output. Logs may include local paths.

## Tested platforms and limitations

| Platform | Recorded result |
| --- | --- |
| x86_64 Bazzite, KDE, NVIDIA RTX 3080 | Exact beta.2 builder GUI opened with X11; packaged build completed using cached components and a local mod ZIP. Fresh-prefix and repeat Wine 11 game launches reached the DXVK renderer during development. Desktop scaling was checked with screenshots. The user reports the game works well and confirms the camera effect. One startup minimise/restore test recovered its image. |
| Linux Mint | Earlier beta.1 built a game but failed at Vulkan instance creation. A Wine 11 live-USB test started the runner but the selected Nouveau driver could not enumerate a GPU. Experimental OpenGL produced audio without an image. A successful graphical game launch with this release is not established. |
| Steam Deck | This Empire Earth release has not been directly tested. |

The exact beta.2 builder is **8,550,904 bytes**, SHA-256:

`7c2e0d5675e20799741ea1ca995a2759d720071b94c856411952f32b181d3f51`

The packaged GUI's highest referenced glibc version is **2.39**. This ABI check is not proof of Mint or Deck launch success. The current build verification used a populated cache; earlier clean-cache tests belong to beta.1 and do not establish a clean-cache beta.2 build on another platform.

Remaining checks include a full audio/control/save-load cycle, repeated minimise/restore during gameplay, expansion camera behaviour, and complete first/second launch tests on Mint and Deck. The Mint live-USB graphics failure is unresolved; it has not been proven to be merely a live-boot limitation. `--opengl` is an experimental WineD3D alternative with unverified hardware rendering and performance.

## Command line and source builds

```sh
./Empire-Earth-Builder-x86_64.AppImage --build \
  '/path/to/setup_empire_earth_gold.exe' \
  '/path/to/dxnt.cab' \
  '/path/to/output-folder' 720p off
```

For the optional local mod, replace `off` with `on` and add the ZIP path:

```sh
./Empire-Earth-Builder-x86_64.AppImage --build \
  '/path/to/setup_empire_earth_gold.exe' \
  '/path/to/dxnt.cab' \
  '/path/to/output-folder' 720p on '/path/to/dreXmod-2.01.zip'
```

Resolution profiles are `720p`, `deck` and `1080p`. `EE_COMPONENT_CACHE` selects another component cache; `--check` checks the bundled builder tools. Verify the release download with:

```sh
sha256sum -c Empire-Earth-Builder-x86_64.AppImage.sha256
```

To rebuild the builder, compile the GUI with Freedesktop SDK 24.08 and Cargo using [Cargo.lock](gui/Cargo.lock), then run `package-builder.sh` with its required verified tool paths. `EE_GUI_BINARY` must point to that SDK build. `EE_LIBMAGIC` supplies SDK libmagic and identifies its neighbouring keyboard libraries. Packaging checks tool/library hashes and rejects a GUI or checked dependency exceeding glibc 2.39. Source and acquisition pins are recorded in the scripts and [implementation status](docs/IMPLEMENTATION_STATUS.md).

The builder source is GPLv3; see [third-party licences and source notices](THIRD_PARTY_NOTICES.md). Generated game AppImages are for personal use: **do not upload them or commercial game files to this repository**.
