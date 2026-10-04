# Empire Earth Gold Edition on Linux

I put this together to make getting **Empire Earth Gold Edition running on Linux** a bit easier.

It takes your own GOG installer and builds a game AppImage with the compatibility files included. It supports both the original game and **The Art of Conquest**. The Windows game runs through Wine.

It's still a beta. **Tested and working on Bazzite and Steam Deck.** Mint still needs further work.

**[Download Empire Earth Builder v0.1.0-beta.2](https://github.com/lozza/Empire-Earth-Linux-Appimage/releases/tag/v0.1.0-beta.2)** — under **Assets**, choose `Empire-Earth-Builder-x86_64.AppImage`. There's also a `.sha256` file to check the download.

## What's new in beta.2

- Wine 11.0 WoW64, so the game no longer needs a 32-bit Linux loader or graphics driver.
- Fixes for image scaling and recovery after minimising.
- An optional camera mod dropdown. Original camera is the default; dreXmod needs your own local ZIP.
- The builder includes its required X11 keyboard libraries and is built with Freedesktop SDK 24.08.

Beta.2 replaces beta.1. See the [changelog](CHANGELOG.md) for the changes and the [technical documentation](docs/IMPLEMENTATION_STATUS.md) for component details and testing.

## What you'll need

- An **x86_64 Linux desktop**, glibc **2.39 or newer**, and working **64-bit Vulkan graphics**.
- Your own supported GOG installer and matching DirectMusic files, listed below.
- **Flatpak, curl, tar and sha256sum**, plus standard shell tools.
- **7z** if you're supplying a CAB or optional mod ZIP.
- Internet access for the first build and plenty of free space; allow around **8 GB**.

The first build downloads about **104 MB** of Wine, DXVK and packaging tools, plus the pinned Freedesktop Platform 24.08 runtime if needed. Downloads are checked and cached for later builds. Flatpak sets up a user-level Flathub remote if needed, without sudo.

You don't need Bottles or a separate Wine/Proton installation. The compatibility files are packaged into your game AppImage. Your game installer and other local inputs aren't uploaded.

### GOG installer

This beta accepts:

`setup_empire_earth_gold_2.0.0.2974_gog_v3_(78415).exe`

SHA-256: `65758cb47fc9f8073fbc66ecc71dbd8f7ee573787100ee14c5e8a1f00acfd0da`.

A renamed copy with the same contents is fine. Other installer versions, installed folders and the community `EE_Setup.exe` patcher aren't supported in this beta. The builder extracts the GOG installer without running its Windows setup program.

### DirectMusic files

The tested audio setup needs **nine older Microsoft DirectMusic DLLs** that aren't included in this GOG installer. Supply your own matching `dxnt.cab` from a DirectX installation you own, or a folder containing its extracted DLLs. The builder checks their hashes.

The tested CAB came from a local Age of Empires III DirectX folder. Reading a CAB needs `7z`; an extracted DLL folder doesn't.

## Build and play

1. Download the builder and mark it executable through your file manager's **Properties → Permissions**.
2. Open it. Choose your GOG installer, DirectMusic files and an output folder.
3. Pick a starting resolution.
4. Leave **Camera / zoom mod** on **Original camera — no mod**, or follow the optional camera instructions below.
5. Click **Build AppImage** and wait for **BUILD COMPLETE**.
6. Open the `Empire-Earth-Gold-GOG-private.AppImage` it creates.

Use `--aoc` when launching to play **The Art of Conquest**.

The game starts with windowed presentation scaled to the desktop, keeping the correct aspect ratio. On the tested KDE desktop it fills the screen. Your starting game resolution is separate from this scaling, and later in-game settings are kept. You can use `--fullscreen` or `--windowed` when launching to choose the presentation.

### Steam Deck

**Tested and working on Steam Deck.** Build in **Desktop Mode**, following the steps above, then add your generated game AppImage to Steam if desired. **1280×720** is a suggested starting resolution.

### Optional wider camera

The camera mod is **off by default**.

If you want it, get the supported **dreXmod 2.01 ZIP** yourself from the [creator/community page](https://empireearth.eu/drexmod/). Choose dreXmod in the **Camera / zoom mod** dropdown, then select your ZIP with **Browse mod ZIP**.

The builder checks the ZIP and DLL hashes. It doesn't download the mod automatically or include it in the public builder.

The starting maximum zoom distance is **20**. The mod's lobby, HUD, menu and scenario-hosting features are disabled. This changes camera distance independently of resolution. The camera adjustment works in the base game; its behaviour in The Art of Conquest hasn't been checked yet.

Games built with the mod accept `--no-camera` to disable it and `--camera` to restore it. Without either flag, the choice made in the builder is used. Existing `dreXmod.config` settings are kept; you can change `Camera/Zoom/MaxZ` there. A different installed mod DLL won't be overwritten.

## Saves, settings and backups

Your writable game files, saves, settings and Wine prefixes are stored outside the AppImage at:

`${XDG_DATA_HOME:-$HOME/.local/share}/empire-earth-gog-private-test/`

Rebuilding doesn't remove this folder. Beta.2 creates a separate Wine 11 prefix and keeps the old prefix and game copy. Close the game before rebuilding or backing up.

Use **Back up saves and settings** in the builder to create a dated backup. This includes the game copy and prefix, so it can be large.

## Platforms and known issues

| Platform | Status |
| --- | --- |
| Bazzite | Tested and working. |
| Steam Deck | Tested and working. |
| Linux Mint | Still needs further work. Graphics failed in the recorded Mint tests. |

Mint's Vulkan launch failed, and the experimental OpenGL option produced audio without an image. The cause is still unresolved. `--opengl` is available for troubleshooting, but its hardware rendering and performance aren't established.

This is still a beta. Expansion camera behaviour and repeated minimise/restore during gameplay need more testing. Detailed build and launch results are in the [technical documentation](docs/IMPLEMENTATION_STATUS.md).

## Troubleshooting

Build messages are shown in the builder and saved as `empire-earth-builder.log` in your output folder. Game diagnostics are saved under the game-data folder at `logs/latest.log`.

If something goes wrong, include your Linux version, GPU, resolution and the relevant log output. Logs can contain local paths, so check them before sharing.

## Download checksum

The beta.2 builder is **8,550,904 bytes**, with SHA-256:

`7c2e0d5675e20799741ea1ca995a2759d720071b94c856411952f32b181d3f51`

To check it:

```sh
sha256sum -c Empire-Earth-Builder-x86_64.AppImage.sha256
```

## Command line and source builds

```sh
./Empire-Earth-Builder-x86_64.AppImage --build \
  '/path/to/setup_empire_earth_gold.exe' \
  '/path/to/dxnt.cab' \
  '/path/to/output-folder' 720p off
```

For the optional mod, replace `off` with `on` and add the ZIP path:

```sh
./Empire-Earth-Builder-x86_64.AppImage --build \
  '/path/to/setup_empire_earth_gold.exe' \
  '/path/to/dxnt.cab' \
  '/path/to/output-folder' 720p on '/path/to/dreXmod-2.01.zip'
```

Profiles are `720p`, `deck` and `1080p`. `EE_COMPONENT_CACHE` selects a different component cache. `--check` checks the builder's bundled tools.

To rebuild the builder, compile the GUI with Freedesktop SDK 24.08 and Cargo using [Cargo.lock](gui/Cargo.lock), then run `package-builder.sh` with its required verified tool paths. `EE_GUI_BINARY` must point to the SDK build. `EE_LIBMAGIC` supplies SDK libmagic and identifies its neighbouring keyboard libraries. Packaging checks hashes and rejects checked components requiring glibc newer than 2.39.

## Thanks

Thanks to the people behind **Wine, Kron4ek Wine Builds, DXVK, AppImage, Freedesktop SDK and Slint**, the **dreXmod authors and EmpireEarth.eu community**, and everyone who helped test things and report problems.

This builds on what we learned getting the Harry Potter AppImage builder working.

The builder source is GPLv3; see the [third-party licences and source notices](THIRD_PARTY_NOTICES.md). This is an unofficial fan project. No Empire Earth, DirectMusic or dreXmod files are included in the public download. Generated game AppImages contain your commercial game files and must stay private.
