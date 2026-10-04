#!/usr/bin/env bash
set -euo pipefail
builder_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
installer=${1:?Choose your GOG installer.}
directmusic_source=${2:?Choose a DirectMusic dxnt.cab or a folder of extracted DLLs.}
output_dir=${3:?Choose an output folder.}
profile=${4:-720p}
camera=${5:-off}
camera_archive=${6:-}
case "$camera" in on|off) ;; *) printf 'Camera choice must be on or off.\n' >&2; exit 2 ;; esac
if [ "$camera" = on ]; then
  [ -f "$camera_archive" ] || { printf 'Select your own dreXmod 2.01 ZIP for the optional camera.\n' >&2; exit 2; }
  [ "$(stat -c %s "$camera_archive")" = 490495 ] && [ "$(sha256sum "$camera_archive" | cut -d' ' -f1)" = 97d9fb875f2a96fd0acd27d87e68a83a2b34f9840112a1ebc794ea6bd0537275 ] || { printf 'This camera ZIP is not the tested dreXmod 2.01 archive.\n' >&2; exit 2; }
fi
case "$profile" in
  720p) resolution=1280x720 ;;
  deck) resolution=1280x800 ;;
  1080p) resolution=1920x1080 ;;
  *) printf 'Choose 720p, deck, or 1080p.\n' >&2; exit 2 ;;
esac
[ -f "$installer" ] || { printf 'GOG installer not found: %s\n' "$installer" >&2; exit 2; }
[ -f "$directmusic_source" ] || [ -d "$directmusic_source" ] || { printf 'DirectMusic CAB or folder not found: %s\n' "$directmusic_source" >&2; exit 2; }
case "$output_dir" in /*) ;; *) printf 'Output folder must be an absolute path.\n' >&2; exit 2 ;; esac
for program in curl flatpak tar sha256sum; do command -v "$program" >/dev/null || { printf 'Required tool is missing: %s\n' "$program" >&2; exit 78; }; done
if [ -f "$directmusic_source" ] || [ "$camera" = on ]; then command -v 7z >/dev/null || { printf '7z is required to read the DirectMusic CAB or optional camera ZIP.\n' >&2; exit 78; }; fi
expected=65758cb47fc9f8073fbc66ecc71dbd8f7ee573787100ee14c5e8a1f00acfd0da
actual=$(sha256sum "$installer" | cut -d' ' -f1)
[ "$actual" = "$expected" ] || { printf 'This GOG installer version is not verified (SHA-256 %s).\n' "$actual" >&2; exit 2; }
mkdir -p "$output_dir"
output="$output_dir/Empire-Earth-Gold-GOG-private.AppImage"
[ ! -e "$output" ] || { printf 'Output already exists: %s\n' "$output" >&2; exit 2; }
cache=${EE_COMPONENT_CACHE:-"${XDG_CACHE_HOME:-$HOME/.cache}/empire-earth-builder/components"}
mkdir -p "$cache"
fetch() {
  local name=$1 url=$2 size=$3 digest=$4 destination="$cache/$1" partial
  if [ -f "$destination" ] && [ "$(stat -c %s "$destination")" = "$size" ] && [ "$(sha256sum "$destination" | cut -d' ' -f1)" = "$digest" ]; then
    printf 'Using verified cached %s.\n' "$name" >&2
    printf '%s\n' "$destination"
    return
  fi
  partial="$destination.$$.partial"
  printf 'Downloading verified %s…\n' "$name" >&2
  curl --fail --location --silent --show-error --retry 2 --proto '=https' --tlsv1.2 --output "$partial" "$url"
  [ "$(stat -c %s "$partial")" = "$size" ] && [ "$(sha256sum "$partial" | cut -d' ' -f1)" = "$digest" ] || { rm -f "$partial"; printf 'Download verification failed: %s\n' "$name" >&2; exit 1; }
  mv "$partial" "$destination"
  printf '%s\n' "$destination"
}
ref_location() {
  local ref=$1 digest=$2 scope commit location
  for scope in --user --system; do
    commit=$(flatpak info "$scope" --show-commit "$ref" 2>/dev/null || true)
    [ "$commit" = "$digest" ] || continue
    location=$(flatpak info "$scope" --show-location "$ref" 2>/dev/null || true)
    [ -d "$location/files" ] && { printf '%s/files\n' "$location"; return 0; }
  done
  return 1
}
run_flatpak() {
  local label=$1 result status
  shift
  if result=$(flatpak "$@" 2>&1); then
    [ -z "$result" ] || printf '%s\n' "$result" | tail -n 8 >&2
  else
    status=$?
    printf '%s failed (exit %s): %s\n' "$label" "$status" "$(printf '%s' "$result" | tail -c 1600)" >&2
    exit 1
  fi
}
ensure_ref() {
  local ref=$1 digest=$2 location
  if location=$(ref_location "$ref" "$digest"); then printf '%s\n' "$location"; return; fi
  printf 'Installing pinned 64-bit Flatpak component %s…\n' "$ref" >&2
  run_flatpak 'Flathub user remote setup' remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  run_flatpak 'Flatpak component install' install --user --noninteractive --no-related --no-deps flathub "$ref"
  run_flatpak 'Flatpak component pin' update --user --noninteractive --no-related --no-deps --commit "$digest" "$ref"
  location=$(ref_location "$ref" "$digest") || { printf 'Pinned Flatpak component unavailable: %s\n' "$ref" >&2; exit 1; }
  printf '%s\n' "$location"
}
printf 'Checking free compatibility components…\n'
wine_archive=$(fetch wine-11.0-amd64-wow64.tar.xz 'https://github.com/Kron4ek/Wine-Builds/releases/download/11.0/wine-11.0-amd64-wow64.tar.xz' 73144724 39574efa1132c3ca0d5c77dd2eddbe4a49cca0d6cc2c290ff4924493a1c40314)
dxvk=$(fetch dxvk-2.7.1-6-fc848a4.tar.gz 'https://github.com/bottlesdevs/components/releases/download/dxvk-2.7.1-6-fc848a4/dxvk-2.7.1-6-fc848a4.tar.gz' 15371492 96a78de1cbe2275c9325d8a69212d9f742d5e48b3507c6f3ad684d1a186c389f)
packager=$(fetch appimagetool-x86_64.AppImage 'https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage' 15092216 a6d71e2b6cd66f8e8d16c37ad164658985e0cf5fcaa950c90a482890cb9d13e0)
chmod 755 "$packager"
runner="$cache/wine-11.0-amd64-wow64"
if [ -x "$runner/bin/wine" ] && [ "$(sha256sum "$runner/bin/wine" | cut -d' ' -f1)" != 57c017cf62031e3e2b8f53ed0e43f2f1fe996b98f0e301224e9c5e1b31b1e56c ]; then
  printf 'Cached WoW64 runner failed verification; extracting the verified archive again.\n'
  rm -rf "$runner"
fi
if [ ! -x "$runner/bin/wine" ]; then
  stage=$(mktemp -d "$cache/.wine.XXXXXXXX")
  tar -xJf "$wine_archive" -C "$stage"
  [ -x "$stage/wine-11.0-amd64-wow64/bin/wine" ] || { printf 'WoW64 archive layout changed.\n' >&2; exit 1; }
  mv "$stage/wine-11.0-amd64-wow64" "$runner"
  rm -rf "$stage"
fi
platform=$(ensure_ref 'org.freedesktop.Platform//24.08' 9a6d66049b19987a22bf81015ce0d1fde260df85a45e54695aad3c82f1e198ee)
runtime="$platform/lib/x86_64-linux-gnu"
[ "$(sha256sum "$runtime/libgcc_s.so.1" | cut -d' ' -f1)" = 578c566c328971dd6cee27ea89c65530c84c8810e1dd335adda8a18d6fcb8983 ] || { printf '64-bit libgcc verification failed.\n' >&2; exit 1; }
[ "$(sha256sum "$runtime/libpulse.so.0" | cut -d' ' -f1)" = a58e74f3b684d0d08ce9d8f4e632d0753d0df7b07f8670d0e86a4b2b4fbaade4 ] || { printf '64-bit PulseAudio verification failed.\n' >&2; exit 1; }
work=$(mktemp -d "$output_dir/.empire-earth-build.XXXXXXXX")
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/extracted" "$work/AppDir/game" "$work/AppDir/runtime64" "$work/AppDir/dxvk" "$work/AppDir/directmusic"
printf 'Extracting your GOG installer locally…\n'
"$builder_dir/tools/innoextract/innoextract" --extract --output-dir "$work/extracted" "$installer" > "$work/extraction.log"
for directory in 'Empire Earth' 'Empire Earth - The Art of Conquest'; do
  [ -d "$work/extracted/$directory" ] || { printf 'Expected game folder is missing: %s\n' "$directory" >&2; exit 2; }
  cp -a "$work/extracted/$directory" "$work/AppDir/game/"
done
[ -f "$work/AppDir/game/Empire Earth/Empire Earth.exe" ]
[ -f "$work/AppDir/game/Empire Earth - The Art of Conquest/EE-AOC.exe" ]
printf 'Adding Wine, graphics, and audio files…\n'
cp -a "$runner" "$work/AppDir/runner"
# Common libraries only: no GPU driver or glibc/loader is copied.
cp -a "$runtime"/*.so* "$work/AppDir/runtime64/"
for directory in pulseaudio alsa-lib; do
  [ ! -d "$runtime/$directory" ] || cp -a "$runtime/$directory" "$work/AppDir/runtime64/"
done
mkdir -p "$work/AppDir/runtime64/etc"
cp -a "$platform/etc/fonts" "$work/AppDir/runtime64/etc/"
# This private game is not running in a Flatpak /run/host sandbox.
rm -f "$work/AppDir/runtime64/etc/fonts/conf.d/50-flatpak.conf"

tar -xzOf "$dxvk" dxvk-2.7.1-6-fc848a4/x32/d3d9.dll > "$work/AppDir/dxvk/d3d9.dll"
[ "$(sha256sum "$work/AppDir/dxvk/d3d9.dll" | cut -d' ' -f1)" = c2086c47afe10ea71b1e1489917a205fb840158d9e0b09b07d8a4f99f9563fa6 ] || { printf 'DXVK D3D9 verification failed.\n' >&2; exit 1; }
if [ -d "$directmusic_source" ]; then
  for dll in dmband dmcompos dmime dmloader dmscript dmstyle dmsynth dmusic dswave; do cp "$directmusic_source/$dll.dll" "$work/AppDir/directmusic/"; done
else
  7z e -y -o"$work/AppDir/directmusic" "$directmusic_source" dmband.dll dmcompos.dll dmime.dll dmloader.dll dmscript.dll dmstyle.dll dmsynth.dll dmusic.dll dswave.dll > "$work/directmusic-extract.log"
fi
(cd "$work/AppDir/directmusic" && sha256sum -c "$builder_dir/directmusic.sha256" >/dev/null) || { printf 'The selected DirectMusic files do not match the tested versions.\n' >&2; exit 1; }
for name in ld-linux-x86-64.so.2 ld-linux.so.2 libc.so libc.so.6 libc_malloc_debug.so.0 libSegFault.so libm.so libm.so.6 libmvec.so.1 libpthread.so.0 libdl.so.2 librt.so.1 libutil.so.1 libanl.so.1 libresolv.so.2 libnss_compat.so.2 libnss_db.so.2 libnss_dns.so.2 libnss_files.so.2 libnss_hesiod.so.2 libnss_resolve.so.2 libBrokenLocale.so.1 libthread_db.so.1 libmemusage.so libpcprofile.so; do
  rm -f "$work/AppDir/runtime64/$name"
done
for directory in 'Empire Earth' 'Empire Earth - The Art of Conquest'; do cp "$work/AppDir/dxvk/d3d9.dll" "$work/AppDir/game/$directory/d3d9.dll"; done
sed "s/^DEFAULT_RESOLUTION=.*/DEFAULT_RESOLUTION=$resolution/;s/^DEFAULT_CAMERA=.*/DEFAULT_CAMERA=$camera/" "$builder_dir/game-AppRun" > "$work/AppDir/AppRun"
chmod 755 "$work/AppDir/AppRun"
cp "$builder_dir/migrate-settings.awk" "$work/AppDir/"
cp "$builder_dir/configure-camera.sh" "$work/AppDir/"
if [ "$camera" = on ]; then
  printf 'Adding verified optional camera patch (zoom limit 20)…\n'
  mkdir "$work/AppDir/camera"
  7z e -y -o"$work/AppDir/camera" "$camera_archive" dreXmod.dll > "$work/camera-extract.log"
  [ "$(sha256sum "$work/AppDir/camera/dreXmod.dll" | cut -d' ' -f1)" = 5464f3db1ee70d442e721e269c523a8d3e59fcb126c249c7fe24ccb23f17844b ] || { printf 'Camera DLL verification failed.\n' >&2; exit 1; }
  cp "$builder_dir/camera-only.config" "$work/AppDir/camera/dreXmod.config"
fi
cat > "$work/AppDir/empire-earth.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Empire Earth Gold Edition (Private)
Exec=empire-earth
Icon=empire-earth
Categories=Game;
Terminal=false
DESKTOP
cp "$builder_dir/empire-earth.svg" "$work/AppDir/empire-earth.svg"
mkdir -p "$work/AppDir/licenses"
cp "$builder_dir/GAME_THIRD_PARTY_NOTICES.txt" "$work/AppDir/licenses/"
cp "$builder_dir/licenses/type2-runtime-LICENSE" "$work/AppDir/licenses/"
cp "$builder_dir/licenses/DXVK-LICENSE" "$work/AppDir/licenses/"
cp "$builder_dir/licenses/Wine-LGPL-2.1" "$work/AppDir/licenses/"
cp -a "$platform/share/licenses/freedesktop-sdk" "$work/AppDir/licenses/Runtime64"
# Resolve SDK /usr licence links into real files for the private AppImage.
while IFS= read -r -d '' notice; do
  target=$(readlink "$notice")
  case "$target" in
    /usr/share/licenses/*)
      source_notice="$platform${target#/usr}"
      [ -f "$source_notice" ] || { printf 'Runtime licence notice is missing: %s\n' "$target" >&2; exit 1; }
      rm "$notice"
      cp "$source_notice" "$notice" ;;
  esac
done < <(find "$work/AppDir/licenses/Runtime64" -type l -print0)
ln -s empire-earth.svg "$work/AppDir/.DirIcon"
cat > "$work/AppDir/PRIVATE_GAME.txt" <<'NOTE'
Private game AppImage generated from a user-supplied verified GOG installer
and user-supplied DirectMusic files. Do not redistribute this game AppImage.
Wine WoW64, DXVK, AppImage tooling and 64-bit runtime were verified by pinned
SHA-256 hashes or Flatpak commits before use.
NOTE
printf 'Packaging the private game AppImage…\n'
# The nested AppImage must use this process's actual directory, not a stale
# original directory inherited from the outer builder's AppImage runtime.
ARCH=x86_64 APPIMAGE_EXTRACT_AND_RUN=1 MAGIC="$builder_dir/tools/magic.mgc" LD_LIBRARY_PATH="$builder_dir/tools/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" PATH="$builder_dir/tools:$PATH" env -u OWD "$packager" --no-appstream --comp zstd --runtime-file "$builder_dir/tools/runtime-x86_64-private" "$work/AppDir" "$work/game.AppImage" > "$work/packaging.log" 2>&1 || { tail -40 "$work/packaging.log" >&2; exit 1; }
mv "$work/game.AppImage" "$output"
chmod 755 "$output"
(cd "$(dirname "$output")" && sha256sum "$(basename "$output")") > "$output.sha256"
printf 'BUILD COMPLETE: %s\n' "$output"
