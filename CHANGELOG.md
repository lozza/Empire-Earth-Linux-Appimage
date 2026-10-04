# Changelog

## v0.1.0-beta.2 — 2026-10-04

- Replace the legacy 32-bit Linux Wine route with pinned Wine 11.0 WoW64 and common Freedesktop Platform 24.08 libraries. Windows game files remain 32-bit; Linux runner and graphics dependencies are 64-bit.
- Discover native 64-bit Vulkan drivers, preserve matching host graphics dependencies, pair bundled Pulse libraries, and retain launch diagnostics.
- Use direct game launch, a restricted G: game mapping, desktop-size aspect-preserving scaling and default windowed presentation. Remove the extra Wine virtual desktop that caused upper-left image placement.
- Preserve existing game data and saves, create a separate Wine 11 prefix, and migrate only game registry settings. Stage initialization with locks and recoverable output.
- Add Camera / zoom mod selection: original camera by default, or explicitly supplied local dreXmod 2.01 ZIP. No automatic mod download or public mod binary. Seed maximum zoom distance 20 and disable unrelated mod features.
- Make the GUI scrollable, connect local mod browsing, and bundle verified SDK X11 keyboard libraries with their licences. Keep the checked glibc 2.39 ceiling.
- Clear inherited OWD for nested AppImage packaging, resolving a reproduced packaging-directory failure.
- Update source/licence notices and distinguish Bazzite evidence from unresolved Mint and untested Deck behaviour.

Builder: 8,550,904 bytes; SHA-256 `7c2e0d5675e20799741ea1ca995a2759d720071b94c856411952f32b181d3f51`.

## v0.1.0-beta.1 — 2026-09-26

Initial public GOG/DirectMusic builder with pinned Soda, DXVK and 32-bit runtime acquisition. Bazzite renderer and build checks were recorded. Subsequent Mint launch failures and desktop display issues prompted beta.2. This historical release is superseded.
