## Description

I put this together to make getting **Empire Earth Gold Edition running on Linux** a bit easier.

It takes your own GOG installer and builds a game AppImage with the compatibility files included. It supports both the original game and **The Art of Conquest**, using Wine to run them on Linux.

It's still a beta. **Tested and working on Bazzite and Steam Deck.** Mint still needs further work.

No game files are included in the builder.

## Installation instructions

1. Download `Empire-Earth-Builder-x86_64.AppImage` from the [release page](https://github.com/lozza/Empire-Earth-Linux-Appimage/releases/tag/v0.1.0-beta.2).
2. Mark it executable through your file manager's **Properties → Permissions**, then open it.
3. Choose your GOG installer, DirectMusic files and output folder.
4. Pick a starting resolution.
5. Leave the camera on its original setting, or choose **dreXmod 2.01** and select your own supported mod ZIP.
6. Click **Build AppImage** and wait for **BUILD COMPLETE**.
7. Open the `Empire-Earth-Gold-GOG-private.AppImage` it creates.

Use `--aoc` when launching to play The Art of Conquest.

On Steam Deck, build it in **Desktop Mode**, then add the generated game AppImage to Steam if you want.

## Main features

- Builds a game AppImage from your own GOG copy.
- Packages Wine and DXVK into the game AppImage, so you don't need Bottles or a separate Wine installation.
- Includes fixes for image scaling and recovery after minimising.
- Starting resolution options of **1280×720**, **1280×800** and **1920×1080**.
- Optional wider camera using dreXmod, with a starting maximum zoom distance of **20**.
- Keeps saves and settings outside the AppImage, so rebuilding doesn't erase them.
- Includes a backup button, build progress and troubleshooting logs.

The camera mod is **off by default**. You choose whether to include it, and the builder doesn't download it automatically.

## Requirements

You'll need:

- An **x86_64 Linux desktop**, glibc **2.39 or newer**, and working **64-bit Vulkan graphics**.
- Your own GOG installer: `setup_empire_earth_gold_2.0.0.2974_gog_v3_(78415).exe`.
- Your own matching DirectMusic `dxnt.cab` or extracted DLLs. These are required for the tested audio setup and aren't included in the GOG installer.
- **Flatpak, curl, tar and sha256sum**, plus standard shell tools.
- **7z** if you're supplying a CAB or mod ZIP.
- Internet access for the first build and plenty of free space; allow around **8 GB**.

The first build downloads about **104 MB** of compatibility tools, plus the required Flatpak runtime if needed. Downloads are checked and cached for later builds.

If you want the wider camera, get the supported **dreXmod 2.01 ZIP** yourself from [EmpireEarth.eu](https://empireearth.eu/drexmod/). Other GOG installer versions and the community setup patcher aren't supported in this beta.

Please keep the generated game AppImage private, as it contains your commercial game files.

## Shout outs

Thanks to the people behind **Wine, Kron4ek Wine Builds, DXVK, AppImage, Freedesktop SDK and Slint**.

Thanks as well to the **dreXmod authors and EmpireEarth.eu community** for the optional camera mod, and everyone who helped test things and report problems.

This builds on what we learned getting the Harry Potter AppImage builder working.
