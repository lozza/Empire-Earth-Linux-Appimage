# Changelog

## v0.1.0-beta.2 — 2026-10-04

- Replaced the legacy 32-bit Linux Wine route with pinned Wine 11.0 WoW64 and common Freedesktop Platform 24.08 libraries. Windows game files remain 32-bit; Linux runner and graphics dependencies are 64-bit.
- Added discovery of native 64-bit Vulkan drivers, preserved matching host graphics dependencies, paired bundled Pulse libraries, and retained launch diagnostics.
- Added direct game launch, a restricted G: game mapping, desktop-size aspect-preserving scaling and default windowed presentation. Removed the extra Wine virtual desktop that caused upper-left image placement.
- Preserved existing game data and saves, created a separate Wine 11 prefix, and migrated only game registry settings. Staged initialization with locks and recoverable output.
- Added Camera / zoom mod selection: original camera by default, or explicitly supplied local dreXmod 2.01 ZIP. No automatic mod download or public mod binary. Set maximum zoom distance 20 and disabled unrelated mod features.
- Made the GUI scrollable, connected local mod browsing, and bundled verified SDK X11 keyboard libraries with their licences. Kept the checked glibc 2.39 ceiling.
- Cleared inherited OWD for nested AppImage packaging, resolving a reproduced packaging-directory failure.
- Updated source and third-party notices. Tested and working on Bazzite and Steam Deck; Mint graphics still need further work.

Builder: 8,550,904 bytes; SHA-256 `7c2e0d5675e20799741ea1ca995a2759d720071b94c856411952f32b181d3f51`.

## v0.1.0-beta.1 — 2026-09-26

Initial public GOG/DirectMusic builder with pinned Soda, DXVK and 32-bit runtime acquisition. Bazzite renderer and build checks were recorded. Subsequent Mint launch failures and desktop display issues prompted beta.2. This historical release is superseded.
