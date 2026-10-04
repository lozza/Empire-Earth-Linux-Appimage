# Empire Earth builder implementation status

## Current release — v0.1.0-beta.2

The public beta.2 package is the exact tested r7 builder, renamed to
`Empire-Earth-Builder-x86_64.AppImage`: 8,550,904 bytes, SHA-256
`7c2e0d5675e20799741ea1ca995a2759d720071b94c856411952f32b181d3f51`.
Milestone 13 records its packaged build and GUI checks. The README and changelog
summarize current behaviour. Earlier milestones are historical evidence and
include superseded runners, display settings and private prototypes.

The user authorized publication of the integrated fixes. Bazzite evidence is
recorded below, and the user now confirms that it works on Steam Deck (Milestone
15). A successful Mint launch, a save/load cycle and complete repeated gameplay
recovery remain unverified. Publish only this builder and its
checksum, with matching source; never publish a generated game or mod binary.


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

## Milestone 6 — Mint Vulkan failure and private diagnostic candidate (2026-10-03)

- User clarified that Mint completed the game build. Its launch reached DXVK
  `v2.7.1-288-gfc848a41` and failed at `wine_vkCreateInstance`, result `-9`,
  followed by `DxvkInstance::createInstance: Failed to create Vulkan instance`.
  The log also showed the 32-bit Pulse preload warning in a 64-bit process;
  that warning alone does not establish an audio or graphics root cause.
- Audited the HP1 beta.3 Mint milestones and the released EE source. The EE
  GUI already references at most GLIBC_2.39 and its game acquisition uses
  pinned Compat.i386 24.08, the checked libgcc, glibc removal, Intel fallback,
  user Flathub setup and bounded Flatpak diagnostics. The builder itself is
  not the failure now reported. Exact rejected Mint ICD/dependency remains
  unknown: the friend’s machine is currently unavailable.
- Fixed confirmed discovery defects: distro manifests with relative library
  names now resolve in i386 library directories; Flatpak files/lib/vulkan
  manifests are searched, and sandbox-absolute library paths are remapped to
  their installed host files. ELF64 drivers are rejected. Retained pinned
  runtime libraries ahead of driver directories to avoid importing a newer
  Flatpak libgcc/libstdc++ pair. Added a required GUI path and a GLIBC_2.39
  packaging ceiling to reject accidental future Bazzite host builds.
- The launcher records terminal output, selected driver/hash/library paths
  and Vulkan loader driver diagnostics under XDG game data/logs/latest.log.
  Existing game files, prefix and saves are preserved.
- Private candidate `Empire-Earth-Builder-Mint-diagnostic-r1-x86_64.AppImage`
  SHA-256 `ec0868c379699c3a4bc589c4d8c5f2c97f1a8a95895b3be9dea42ce2387172ef`.
  Packaged AppRun matched source by byte comparison and checksum passed.
  No game AppImage or commercial files were published.
- Regression checks passed using actual ELF32 driver files in Mint-style and
  Flatpak-style directory layouts, plus rejection of an ELF64 file. Packaged
  GUI remained open for an eight-second Bazzite smoke. The packaged candidate
  completed a cached full GOG/CAB build. A fresh-XDG Bazzite launch initialized
  the prefix but exceeded its 45-second test budget before rendering. A second
  30-second launch selected the matching NVIDIA GL32 driver and reached a
  1280x720 DXVK presentation swapchain. Timeouts are deliberate test stops,
  not successful game exits; gameplay/audio/save-load were not established.
  Logs: /tmp/ee-mint-followup-{build,gui,launch,repeat}.log.
- Pending: Mint test of this exact candidate and its newly generated game,
  with automatic launch log if Vulkan still fails. A conventional Mint VM can
  check userspace packaging but cannot establish Intel hardware behavior.
  Do not claim the reported Mint failure is resolved or publish a replacement
  release on these Bazzite-only results.

## Milestone 7 — private WoW64 candidate (2026-10-03/04)

- The supplied Mint live-USB conversation describes a separate NVIDIA host:
  Wine initially lacked `/lib/ld-linux.so.2`, then lacked a matching ELF32
  NVIDIA Vulkan driver. This does not establish the exact cause on the
  friend's original Mint machine.
- Switched the private candidate to verified Kron4ek Wine 11.0 amd64-wow64:
  archive SHA-256 `39574efa1132c3ca0d5c77dd2eddbe4a49cca0d6cc2c290ff4924493a1c40314`,
  size 73,144,724 bytes. Windows game DLLs remain 32-bit; Wine's Unix processes
  use the host's 64-bit loader and graphics stack. Kept the pinned DXVK and
  AppImage packaging tools. Replaced Compat.i386 with pinned Freedesktop
  Platform 24.08 common 64-bit libraries, excluding glibc and GPU drivers.
  Source, licence and private-game notices were updated.
- Fixed the Wine 11 working directory with a restricted G: game mapping;
  without it the game started in C:\\windows and crashed looking for assets.
  Wine's virtual desktop now enforces the selected resolution. Existing
  writable game data and the old prefix are retained; a separate Wine 11
  prefix imports only game settings, excluding obsolete installer paths.
- Kept the host's 64-bit libraries ahead of common fallback libraries to
  match its active graphics stack. The previous private r2 ordering triggered
  a host Vulkan layer's missing `wl_fixes_interface` symbol. The bundled ELF64
  PulseAudio library and matching private pulsecommon remain paired.
- Recommended private r3 builder SHA-256:
  `0e01a6b85298443d824bc3e4978d10f5c994b8283845719263c1ae017d4bc972`.
  Exact generated private game SHA-256:
  `a7455cb25b3308679fa18a97716c30675ddf166014982e78462b0b77cd56f2f8`.
  Both checksum checks passed on October 4. Extracted game AppRun matched
  source byte for byte; extracted builder GUI references at most GLIBC_2.39.
  Extracted Wine and wineserver are ELF64, and Wine uses
  `/lib64/ld-linux-x86-64.so.2`. Bundled libgcc and Pulse hashes match their pins.
- The packaged builder completed a cached full local GOG/CAB build. This is
  not proof of a clean-cache download on Mint or Deck. October 3 temporary
  logs did not survive reboot; October 4 verification logs are stored in the
  workspace's ignored `wow64-verification` directory.
- On Bazzite, first initialization in fresh XDG data exceeded an initial
  55-second timeout on this HDD. Resuming completed setup and reached the
  NVIDIA RTX 3080 DXVK renderer with a 1280x720 swapchain. A repeat launch
  with `/usr/lib/ld-linux.so.2` masked by bubblewrap reached the same renderer.
  Art of Conquest then reached a 1280x720 swapchain using the same prefix.
  Tests were stopped with the exact private prefix's wineserver, rather than
  counted as normal successful game exits.
- Live dependency inspection found 77 Unix ELF files, all ELF64: host libc,
  loader, Vulkan and Wayland, matching NVIDIA driver, and bundled libpulse
  plus pulsecommon. No ELF32 Unix library was loaded. ICD regression fixtures
  passed for relative distro paths, Flatpak path remapping and ELF32 rejection.
  Restricted registry migration excluded Wine settings and installer paths.
- Experimental `--opengl` previously rendered through software llvmpipe;
  hardware performance is not established. Mint and Steam Deck have not
  tested r3. Audible sound, gameplay, controls, save/load and handheld window
  behavior remain unverified. No replacement public release, commercial
  game files or generated game AppImage has been uploaded.

## Milestone 8 — supplied Mint live launch log (2026-10-04)

- User supplied terminal output from `/home/mint/Desktop/Empire-Earth-Gold-GOG-private.AppImage`.
  This log identifies the Wine 11 prefix and 64-bit runtime route, but contains
  no artifact hash; the exact tested game artifact has not been fingerprinted.
- Wine and DXVK started without the earlier missing 32-bit loader failure.
  The launcher selected `/usr/lib/x86_64-linux-gnu/libvulkan_nouveau.so`,
  SHA-256 `b5e4de47f1a01a37ad9e42e89a82e560f299132c5f7845777668343c5395cdb7`.
  Vulkan repeatedly reported `Failed to detect any valid GPUs in the current config`;
  Wine reported `Failed to enumerate physical devices, res -3`, followed by
  DXVK's `Failed to create Vulkan instance`. This is a failed launch.
- The presence of an ELF64 ICD file is insufficient proof of a usable driver.
  The log does not establish whether GPU support, kernel/firmware, live boot
  configuration, or another driver issue caused enumeration failure.
  Next diagnostic is the existing explicit `--opengl` route, plus host kernel,
  GPU/kernel-driver and boot-command-line information if it also fails.
- Original supplied text is retained privately in
  `wow64-verification/mint-live-r3-user-log.txt`. No platform-success or audio
  claim is inferred from this output.

## Milestone 9 — nested AppImage packaging directory fix (2026-10-04)

- User supplied an eight-line builder log: cached Wine/DXVK/packager were
  verified, local extraction and staging completed, then packaging failed with
  `Could not cd into /var/home/bazzite/Downloads/Empire-Earth-Mint-Test`.
  This build did not complete. It is separate from the preceding Mint render test.
- Reproduced the exact error with the pinned appimagetool using an inherited
  `OWD` pointing to that absent directory. The nested AppImage runtime attempts
  to restore the outer AppImage's original directory. Clearing only `OWD` for
  appimagetool allowed its version command to succeed. Both game packaging
  and builder packaging now use `env -u OWD` for the nested tool.
- Repackaged the builder successfully with the same invalid `OWD` deliberately
  set. Exact r4 extracted build script matched source, shell syntax checks,
  packaged builder `--check` and source diff whitespace checks passed.
  r4 SHA-256:
  `9bcd5312f08719eb9303019d1401e0a020ba55059a44af5a5dfa3358aaedaa4c`.
  No full commercial game rebuild was performed for this environment-only
  packaging correction, and Mint rendering remains unresolved. Artifact and
  packaging log are retained in the ignored `wow64-verification` directory.
- User also reports the Mint OpenGL attempt played audio but showed no image.
  Audible audio is established by that report; rendering/gameplay is not.
  Boot options, active graphics renderer and the OpenGL launch log are pending.

## Milestone 10 — fullscreen image placement (2026-10-04)

- User reported fullscreen with the visible game restricted to the upper-left
  area. Launched the supplied Desktop game and captured its X11 window pixels:
  Wine Desktop was 3440x1440 while DXVK's surface remained 1280x720. The
  screenshot confirms the image placement defect; renderer logs alone had
  missed it. This reproduces on Bazzite, independently of Mint live boot.
- Changing wrapper presentation to windowed inside the same Wine desktop did
  not fix it. Direct-launch tests staged through symlinked Wine directories
  exited with a Pulse Unix-function load failure; repeating with the actual
  mounted runner path avoided that diagnostic staging problem.
- Direct game launch without the extra Wine Desktop, with GOG wrapper
  `display=desktop`, `presentation=fullscreen`, `aspect=enabled`, `scaling=fit`,
  produced a centred, full-height image on the 3440x1440 monitor. Side bars
  preserve the game's aspect ratio. Screenshot: `direct-realpath-game.png` in
  the private verification directory. Gameplay and pointer mapping have not
  been established by this startup screenshot.
- Launcher now uses that direct route and performs a one-time wrapper
  configuration migration. Game-resolution registry presets and existing
  game data remain separate from monitor presentation size. This supersedes
  Milestone 7's virtual-desktop approach. Mint and Deck graphics remain unverified.
- Repackaged the user's existing private game with the new AppRun, leaving
  commercial content private. Exact r5 game SHA-256:
  `f388be5b508299d5c9215101d8c98b63d91e1ce2fbc00d7f3886d107f1bb2c45`.
  Launched that packaged artifact and captured its centred, scaled intro
  (`r5-packaged-game.png`); fullscreen window and DXVK surface both measure
  3440x1440. This confirms startup image placement, not gameplay/save/audio.
- Repackaged r5 builder SHA-256:
  `9b32f4fd765f52bf982109a597f77f66f882e91a55c55082ee1241d2ffff71df`.
  Its packaged tool check and both checksum checks passed. No full GOG/CAB
  rebuild or new public release occurred for this launcher correction.

## Milestone 11 — private camera-only dreXmod test (2026-10-04)

- User reports r5 works well but asks for a greater maximum zoom-out. The
  community's primary documentation describes dreXmod's configurable camera
  and `Camera/Zoom/MaxZ`. The installed GOG game had no camera mod.
- Obtained the standalone dreXmod 2.01 ZIP through the official community
  manual-install link. Observed archive SHA-256:
  `97d9fb875f2a96fd0acd27d87e68a83a2b34f9840112a1ebc794ea6bd0537275`;
  DLL SHA-256 `5464f3db1ee70d442e721e269c523a8d3e59fcb126c249c7fe24ccb23f17844b`.
  These are measured downloaded hashes, not independently published pins.
- Prepared configuration with upstream MaxZ 30, normal style 1, and disabled
  ScenarioHosting, LobbyExtension, MenuSettings and HUDPlayers. Did not copy
  the archive's lobby resource modification. After user saved/closed the game
  and replied ready, installed DLL/config only in the writable base-game copy.
  Saved existence/backup state and a removal helper in the private verification
  directory. Expansion files, game executable and AppImage were not modified.
- Launched the r5 packaged game: Wine's loader trace confirms native loading of
  `G:\\EMPIRE EARTH\\dreXmod.dll`. The actual camera effect and gameplay remain
  pending user test. No builder integration or redistribution decision has
  been made; the downloaded ZIP includes no licence notice establishing public
  redistribution permission.
- User confirms the camera test worked, but MaxZ 30 was too far out. Reduced
  the writable base-game config to MaxZ 20 and relaunched after confirming no
  game process remained. User assessment of this closer limit is pending.

## Milestone 12 — minimise/restore test (2026-10-04)

- User reports a black screen after minimising and restoring, requiring a
  restart. No game process was active when the diagnostic change was made.
  The prior launch log also contains a virtual-memory allocation failure;
  that line is retained and is not proven to be caused by minimisation.
- Backed up the writable base-game dxcfg.ini and changed only its presentation
  to windowed, keeping display=desktop and aspect/scaling settings. Launched
  the r5 AppImage. DXVK confirms Windowed=true at 3440x1440, while KDE still
  displays a screen-filling window. Camera MaxZ remains 20.
- Iconified the test window, remapped it and requested normal window activation.
  Screenshot `camera-patch/windowed-after-restore.png` shows the game's loading
  screen after restoration. This establishes one recovery during startup;
  minimise/restore during gameplay and repeated cycles remain unverified.
  The game is left running for the user's test. Only writable configuration
  was changed; no new AppImage or public release was packaged in this step.

## Milestone 13 — builder integration and explicit local mod selection (2026-10-04)

- Integrated direct launch, desktop-size scaling, default windowed presentation
  and one-time configuration migration in the builder's generated launcher.
  `--fullscreen` and `--windowed` allow comparison. Existing saves and game
  resolution preferences are retained.
- Initial private r6 prototype used an unchecked camera checkbox and an
  optional verified download. User requested named mod selection without
  automatic downloading; r7 replaces it with a Camera / zoom mod dropdown:
  Original camera (default) or dreXmod 2.01 with the user's local ZIP. The GUI
  reveals a Browse mod ZIP input only for that choice. There is no mod download
  URL or mod DLL in the final builder. Notices and README credit the community
  source and describe local input, not builder redistribution of the DLL.
- Local ZIP size/hash and extracted DLL hash are checked. Missing or unsupported
  archives are rejected before acquisition. Generated games with the mod seed
  MaxZ 20, normal style, disabled lobby/HUD/menu features, and retain existing
  camera settings. `--no-camera` disables only the known tested DLL by moving
  it aside; `--camera` restores the bundled copy. A different DLL is protected.
- Fixture tests covered on/off, retained edited preferences, unknown DLL
  protection and missing-payload diagnostics. A packaged camera-on build
  completed with the local ZIP; the earlier default-off pipeline also completed
  without any mod acquisition. Wine/DXVK/packager were cached; this is not a
  new clean-cache platform verification. The actual r7 generated game's
  init-only camera off/on checks use the existing isolated verification prefix,
  not the user's active game data.
- Additional packaged GUI test exposed a missing X11 `libxkbcommon-x11.so`.
  Added checked SDK 24.08 libxkbcommon, libxkbcommon-x11 and libxcb-xkb, with
  actual licence files and ABI checks. The final packaged GUI opened on
  Bazzite's X11 backend and its dropdown was captured in `r7-builder-gui.png`.
  Its highest imported GLIBC version is 2.39. The earlier Wayland smoke also
  stayed running until its intentional timeout. Non-fatal host Mesa warnings
  are retained in the GUI logs. Made the form scrollable for the extra inputs.
- Resolved SDK absolute `/usr/share/licenses` links to real notice files in
  both the builder keyboard notices and generated game's runtime notices.
- Recommended r7 private builder: 8,550,904 bytes; SHA-256
  `7c2e0d5675e20799741ea1ca995a2759d720071b94c856411952f32b181d3f51`.
  Checksum and packaged tool checks passed; extracted build/helper scripts
  matched source byte for byte. This supersedes the unpublished r6 prototype.
  Logs, private games and candidates are retained in ignored verification data.
  No GitHub release or generated game upload was made. Mint/Deck, expansion
  camera behavior and repeated gameplay recovery still require testing.

## Milestone 14 — public beta.2 publication (2026-10-04)

- Published [v0.1.0-beta.2](https://github.com/lozza/Empire-Earth-Linux-Appimage/releases/tag/v0.1.0-beta.2)
  as a pre-release, with matching source commit
  `c20dccfa598816b9611257e2a858f839045b2ac8`.
- Uploaded only `Empire-Earth-Builder-x86_64.AppImage` and its `.sha256`.
  Downloaded both live assets again and checked size, checksum-file contents
  and byte-for-byte equality with the tested local builder. Live builder:
  8,550,904 bytes, SHA-256
  `7c2e0d5675e20799741ea1ca995a2759d720071b94c856411952f32b181d3f51`.
  The tag resolves to the matching source commit. Commercial game content,
  generated private games and mod binaries were not uploaded.
- Updated README, changelog, implementation status and release notes. Marked
  beta.1 superseded with a beta.2 link, retaining its original artifact/history.
  Test claims retain unresolved Mint graphics and unverified Deck behaviour.
- Verification metadata and downloaded copies are retained privately in
  `wow64-verification/github-beta2-download/`. This milestone changes
  documentation only; the released artifact and tag remain unchanged.

## Milestone 15 — user-reported Steam Deck success (2026-10-04)

- After the beta.2 release and Nexus description draft, the user reports:
  "This works fine on deck, btw". Record Steam Deck as working by user report.
- The report does not specify an artifact hash, operating mode, resolution or
  separate first/second-launch, audio, controls and save/load observations.
  Do not turn this report into a claim that every individual check was recorded.
- Updated the current README, changelog and beta.2 release notes to reflect
  this new evidence. Earlier milestones describe the status at their dates.
  No code, release artifact, checksum or tag changes are required. Mint's
  graphics failure remains unresolved.
