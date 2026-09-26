# Empire Earth Gold Edition on Linux

**Empire Earth Builder** is a desktop tool that turns your supported GOG Empire Earth Gold Edition installer into a Linux AppImage you can launch directly. Choose the installer, your own DirectMusic files, an output folder and a resolution; the tool builds the game app for you. No Bottles or system Wine/Proton installation is needed.

The original Windows game runs inside the AppImage using packaged compatibility software. It behaves like a standalone Linux app, but the game's code has **not** been rewritten as native Linux software. This is a **public beta**.

**[Download the v0.1 beta builder](https://github.com/lozza/Empire-Earth-Linux-Appimage/releases/tag/v0.1.0-beta.1)** — under **Assets**, choose `Empire-Earth-Builder-x86_64.AppImage`. A `.sha256` file is provided to check the download.

## Why this builder exists

Empire Earth Gold Edition was made for an older version of Windows. On Linux it needs a suitable Wine runner, 32-bit graphics and audio components, and game-specific display settings. This builder brings those steps together for your own GOG copy. It makes a private AppImage for the base game and **The Art of Conquest** without asking you to install Bottles or system Wine.

## The GOG installer and DirectMusic files required

This beta accepts **only the verified GOG Gold Edition installer** `setup_empire_earth_gold_2.0.0.2974_gog_v3_(78415).exe`, with SHA-256 `65758cb47fc9f8073fbc66ecc71dbd8f7ee573787100ee14c5e8a1f00acfd0da`. A renamed copy with the same contents is accepted; other versions, installed folders and community installers are not yet supported.

The GOG installer also needs **nine older Microsoft DirectMusic DLLs** that it does not include. Supply a `dxnt.cab` from another DirectX installation you own, or a folder containing its extracted DLLs. The builder checks their exact hashes. A CAB needs the host `7z` command; an extracted DLL folder does not. The tested CAB came from a local Age of Empires III DirectX folder. The community `EE_Setup.exe` patcher is not part of this beta.

The builder download contains **no Empire Earth or DirectMusic files**. Both inputs stay local and are never uploaded. This is an unofficial fan project, not connected to GOG or the original developers.

## Build the game AppImage

**An internet connection is required for the first build.** The tool downloads free Wine, DXVK and AppImage packaging components, verifies their sizes and hashes, and caches them for later builds. Those three downloads total about **95 MB**. It also obtains exact 32-bit Flatpak components when needed; they occupy about **840 MB installed**, and transfer size depends on what the host already has. The builder uses the host `flatpak`, `curl`, `tar` and `sha256sum` commands, but does not require host Wine or Bottles. The game installer and DirectMusic files stay local throughout.

### Linux desktop

1. Download the builder, mark its AppImage as executable in your file manager (usually under **Properties → Permissions**), then open it.
2. Select the supported GOG installer and your DirectMusic CAB or DLL folder. Choose an output folder with **Browse**, or paste full paths if no file chooser is available.
3. Choose a starting resolution, then click **Build AppImage**.
4. Wait for **BUILD COMPLETE**, then open `Empire-Earth-Gold-GOG-private.AppImage` from the output folder. Launch it with `--aoc` to play The Art of Conquest.

### Steam Deck

In **Desktop Mode**, follow the same build steps. **1280×720** is the recommended starting preset based on the HP1 portability work; this Empire Earth beta has **not yet been tested on Deck**. The 1280×800 option is also unverified. After building, you can add the private game AppImage to Steam for Gaming Mode. Controls and first-run behavior in Gaming Mode still need direct testing.

### Backups and logs

**Back up saves and settings** creates a dated archive of the private game data, including the writable game copy and Wine prefix. It may be large. Close the game first, then choose a destination in the builder. The builder writes `empire-earth-builder.log` in the output folder for build failures.

## What has been tested

- On **x86_64 Bazzite**, a packaged builder window opened and a build from an empty component cache downloaded, verified and packaged the required components. The current beta candidate also completed a cached build.
- From a fresh private Wine prefix on Bazzite, the base game reached a **1280×720 fullscreen DXVK D3D9** renderer. The Art of Conquest and a repeat base-game launch reached the same renderer. The earlier private test was also reported to load the game.
- **Audible sound, full gameplay, controls and an actual save/load cycle have not been verified** for this beta. The builder and generated game have not yet been tested on **Steam Deck or Linux Mint 22.3**.

Saves, settings, the writable game copy and the Wine prefix live outside the read-only game AppImage at `${XDG_DATA_HOME:-$HOME/.local/share}/empire-earth-gog-private-test/`. Rebuilding the AppImage does not remove this folder. The starting resolution is applied on first launch; later in-game changes are kept unless you explicitly choose a launch resolution.

## Known beta issues

- **Steam Deck and Mint are unverified.** The builder follows the HP1 beta.3 portability pattern, but this game's complete build, first launch, graphics, sound, controls and saves still need tests on those systems.
- **DirectMusic must come from your own local files.** The GOG installer alone is insufficient for the audio route tested here. The community patcher has not been integrated or tested.
- **Graphics depend on a matching 32-bit Vulkan driver.** The builder packages a pinned Intel fallback. AMD and NVIDIA need a compatible host or Flatpak GL32 driver; the game shows an error when it cannot find one.
- **Large first build:** the Flatpak components and private game AppImage need substantial free disk space. Flatpak availability and download errors appear in the build log.

If you report a problem, include your Linux version, GPU, selected resolution and the relevant part of `empire-earth-builder.log` or the game's terminal output. Check logs before sharing them because they may contain local paths.

The [builder source](.) is published under GPLv3 with [third-party notices](THIRD_PARTY_NOTICES.md). The beta AppImage includes notices for its bundled free tools. A game AppImage made with this builder contains commercial files and is for personal use; **do not upload it to this repository**.

## Command line and source builds

```sh
./Empire-Earth-Builder-x86_64.AppImage --build \
  '/path/to/setup_empire_earth_gold.exe' \
  '/path/to/dxnt.cab' \
  '/path/to/output-folder' 720p
```

`EE_COMPONENT_CACHE` can select a different download cache. `--check` checks the bundled builder tools. The [implementation status](docs/IMPLEMENTATION_STATUS.md) records the local beta tests. To rebuild the builder itself, compile the GUI with Freedesktop SDK 24.08 and Cargo using `gui/Cargo.lock`, then run `package-builder.sh` with the verified tool paths it requests, including `EE_LIBMAGIC`. Its tool and component hashes are checked in the source.
