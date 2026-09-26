# Empire Earth builder implementation status

## Milestone 1 — private game test

- Verified the user's GOG Gold installer by SHA-256
  `65758cb47fc9f8073fbc66ecc71dbd8f7ee573787100ee14c5e8a1f00acfd0da`.
  Innoextract produced separate base and Art of Conquest folders without
  executing the Windows installer.
- The base game failed with Wine's original OpenGL/DirectDraw route. A verified
  DXVK 32-bit `d3d9.dll` allowed graphics initialization. Wine's built-in
  DirectMusic then crashed; nine native DLLs from the user's locally supplied
  `dxnt.cab` allowed the game to stay running through short tests. The base
  game and expansion each reached a running process on Bazzite. A full play,
  audio, save/reload and second-launch result was not recorded here.
- Both games use separate GOG registry keys for window width/height. 1280×800
  and 1920×1080 settings were observed in the game prefix after timed launches.

## Milestone 2 — separate builder and public-safe input flow

- Built a private offline builder, then removed its bundled Wine, DirectMusic,
  graphics driver and 32-bit runtime for the public candidate. The small
  builder requires a verified GOG installer and separately supplied DirectMusic
  CAB or DLL folder. It downloads pinned Soda, DXVK and appimagetool archives,
  verifies their sizes/hashes, and obtains exact Flatpak 24.08 Compat.i386 and
  25.08 Mesa Intel commits. A generated game contains all selected components;
  Bottles and system Wine are not used.
- The first empty-cache Bazzite run exposed an archive cleanup bug after Soda
  extraction; it was fixed. The second empty-cache run downloaded all three free archives and produced a
  checksummed private game AppImage. A later final-candidate empty-cache run
  also downloaded, verified and packaged successfully; see local
  `final-clean-cache-build.log` and `final-test-output`.
- The game build strips glibc-family files from `runtime32`. A targeted
  extraction of the generated game found `libgcc_s.so.1` hash
  `411a1ec14114b13eb0c38bca92ea8231876bcb72fa5d00074fb2ef7b4d7b8a16`,
  found no bundled `runtime32/libc.so.6`, and found no
  `GLIBC_ABI_GNU_TLS` requirement in that `libgcc_s`.

## Milestone 3 — builder ABI and release gate

- Rebuilt the GUI inside Freedesktop SDK 24.08 as in the HP1 beta.3 workflow.
  The current SDK GUI is packaged from the same executable in `AppDir`;
  its frozen SHA-256 is
  `4665819ad7573cf4decba2977b2171e3d166d42a098e789100c371d649c6b627`. Its highest referenced glibc version is
  `GLIBC_2.39`; the first Bazzite-built GUI required `GLIBC_2.43` and is not a
  release candidate. The packaged builder GUI hash matched the SDK executable in `AppDir`.
  The final packaged builder SHA-256 is
  `77709162d19f78a12ae4a49540f2c6ac644268b625b333a39da16daafde7b009`
  after bundling pinned SDK libmagic, component licences, and the GOG display preset fix.
  Bazzite packaged-GUI smoke remained open for 8 seconds until test timeout.
  This is only a Bazzite smoke test, not Deck or Mint verification.
- The user later authorized a beta release without Deck and Mint results.
  Their platform status must remain explicitly unverified in the README and
  Release. The final source and AppImage hashes must match the published files.
- Remaining platform checks: packaged builder startup, fresh component build,
  private game's first/second launch, graphics, audible sound, controls,
  settings/saves on both Deck and Mint. An SDK ABI check or Bazzite smoke test
  is not equivalent to either platform test. Access/test arrangement is
  pending with the user.

## Milestone 4 — Bazzite generated-game launch

- A fresh XDG prefix initialized successfully as ordinary user from the private
  generated game AppImage. `wineboot -u` and `wineserver -w` completed.
- A timed first base-game launch kept `Empire Earth.exe` running and DXVK's
  32-bit D3D9 log identified NVIDIA RTX 3080. This establishes renderer
  initialization, not completed gameplay or audible sound.
- The initial GOG `dxcfg.ini` default ignored the 1280×720 registry preset and
  produced a 3440×1440 desktop window. Changing the private GOG wrapper file
  to `display=1280x720@60` and `presentation=fullscreen` produced a verified
  1280×720 DXVK swapchain on second launch. The builder launcher now writes
  these settings for both base and expansion only on first launch or explicit
  profile selection. A subsequent generated game from the patched launcher started from a
  fresh prefix and reached a 1280×720 fullscreen DXVK swapchain; the expansion
  and a repeat base launch did the same with that prefix.
- There is no claim of gameplay, audible sound, controls, save/load, Deck or
  Mint success from these timed process and renderer tests.

## Milestone 5 — generated game's 32-bit ELF checks

- Targeted extraction of the generated game shows Wine's ELF32 interpreter
  `/lib/ld-linux.so.2`, with host `/lib/libc.so.6` and `/lib/ld-linux.so.2`
  resolving together. No glibc-family files remain in `runtime32`.
- `runtime32/libgcc_s.so.1` matches the 24.08 SHA-256
  `411a1ec14114b13eb0c38bca92ea8231876bcb72fa5d00074fb2ef7b4d7b8a16`
  and has no `GLIBC_ABI_GNU_TLS` requirement. The pinned Intel ICD has maximum
  `GLIBC_2.38` and SHA-256
  `00cc1d3252bc83222368ee2534cfc5c0d56d7438fa76defde7cbb9e60c1145b9`.
  On Bazzite `ldd` resolved its non-glibc ELF32 dependencies from the bundled
  `runtime32` folder and glibc/loader from the host. This is a dependency
  check, not an Intel GPU launch test on Mint.
- `runtime32/libpulse.so.0` resolves `libpulsecommon-17.0.so` from the bundled
  `runtime32/pulseaudio` folder; the final game process preloads it only when
  the host Pulse/PipeWire socket is present. Audible sound remains untested.
