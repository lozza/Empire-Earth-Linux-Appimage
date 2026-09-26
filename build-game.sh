#!/usr/bin/env bash
set -euo pipefail
builder_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
installer=${1:?Choose your GOG installer.}
directmusic_source=${2:?Choose a DirectMusic dxnt.cab or a folder of extracted DLLs.}
output_dir=${3:?Choose an output folder.}
profile=${4:-720p}
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
if [ -f "$directmusic_source" ]; then command -v 7z >/dev/null || { printf '7z is required to read the DirectMusic CAB. You can instead select a folder containing the extracted DLLs.\n' >&2; exit 78; }; fi
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
  printf 'Installing pinned 32-bit Flatpak component %s…\n' "$ref" >&2
  run_flatpak 'Flathub user remote setup' remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  run_flatpak 'Flatpak component install' install --user --noninteractive --no-related --no-deps flathub "$ref"
  run_flatpak 'Flatpak component pin' update --user --noninteractive --no-related --no-deps --commit "$digest" "$ref"
  location=$(ref_location "$ref" "$digest") || { printf 'Pinned Flatpak component unavailable: %s\n' "$ref" >&2; exit 1; }
  printf '%s\n' "$location"
}
printf 'Checking free compatibility components…\n'
soda=$(fetch soda-9.0-1-x86_64.tar.xz 'https://github.com/bottlesdevs/wine/releases/download/soda-9.0-1/soda-9.0-1-x86_64.tar.xz' 64564696 c38fe0ad3c12a49b61ec1fcaea5c5d8da4a3d1afc5991befe2af6b125f014c28)
dxvk=$(fetch dxvk-2.7.1-6-fc848a4.tar.gz 'https://github.com/bottlesdevs/components/releases/download/dxvk-2.7.1-6-fc848a4/dxvk-2.7.1-6-fc848a4.tar.gz' 15371492 96a78de1cbe2275c9325d8a69212d9f742d5e48b3507c6f3ad684d1a186c389f)
packager=$(fetch appimagetool-x86_64.AppImage 'https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage' 15092216 a6d71e2b6cd66f8e8d16c37ad164658985e0cf5fcaa950c90a482890cb9d13e0)
chmod 755 "$packager"
runner="$cache/soda-9.0-1-x86_64"
if [ -x "$runner/bin/wine" ] && [ "$(sha256sum "$runner/bin/wine" | cut -d' ' -f1)" != 77ef3686bdee1d0ddc0dfff367ecf6875204473b1c5f14fb25f9e349725cc757 ]; then
  printf 'Cached Soda runner failed verification; extracting the verified archive again.\n'
  rm -rf "$runner"
fi
if [ ! -x "$runner/bin/wine" ]; then
  stage=$(mktemp -d "$cache/.soda.XXXXXXXX")
  tar -xJf "$soda" -C "$stage"
  [ -x "$stage/soda-9.0-1-x86_64/bin/wine" ] || { printf 'Soda archive layout changed.\n' >&2; exit 1; }
  mv "$stage/soda-9.0-1-x86_64" "$runner"
  rm -rf "$stage"
fi
runtime=$(ensure_ref 'org.freedesktop.Platform.Compat.i386//24.08' 88db92773b8ed6b2f712eb7e41be3568f20e408e68f610c06c27d843fd7e4e63)
mesa=$(ensure_ref 'org.freedesktop.Platform.GL32.default//25.08' 7e1d4739a4c4f25468727c89669b18f1318064a8f9213697f38b802e2f64c114)
[ "$(sha256sum "$runtime/ld-linux.so.2" | cut -d' ' -f1)" = c5f1ada6cdffb7d88acb0e83eb6e3c92181d444d5c2a83b003b21a7403c2214e ] || { printf '32-bit loader verification failed.\n' >&2; exit 1; }
[ "$(sha256sum "$runtime/libc.so.6" | cut -d' ' -f1)" = 7b1fceaf59ab018e2955ee7bd0fb958b4ef8477c90dc728daff1b02def9ef2cb ] || { printf '32-bit glibc verification failed.\n' >&2; exit 1; }
[ "$(sha256sum "$runtime/libgcc_s.so.1" | cut -d' ' -f1)" = 411a1ec14114b13eb0c38bca92ea8231876bcb72fa5d00074fb2ef7b4d7b8a16 ] || { printf '32-bit libgcc verification failed.\n' >&2; exit 1; }
[ "$(sha256sum "$mesa/lib/libvulkan_intel.so" | cut -d' ' -f1)" = 00cc1d3252bc83222368ee2534cfc5c0d56d7438fa76defde7cbb9e60c1145b9 ] || { printf 'Intel driver verification failed.\n' >&2; exit 1; }
work=$(mktemp -d "$output_dir/.empire-earth-build.XXXXXXXX")
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/extracted" "$work/AppDir/game" "$work/AppDir/runtime32" "$work/AppDir/dxvk" "$work/AppDir/directmusic" "$work/AppDir/graphics"
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
cp -a "$runtime/." "$work/AppDir/runtime32/"
cp "$mesa/lib/libvulkan_intel.so" "$work/AppDir/graphics/"
tar -xzOf "$dxvk" dxvk-2.7.1-6-fc848a4/x32/d3d9.dll > "$work/AppDir/dxvk/d3d9.dll"
[ "$(sha256sum "$work/AppDir/dxvk/d3d9.dll" | cut -d' ' -f1)" = c2086c47afe10ea71b1e1489917a205fb840158d9e0b09b07d8a4f99f9563fa6 ] || { printf 'DXVK D3D9 verification failed.\n' >&2; exit 1; }
if [ -d "$directmusic_source" ]; then
  for dll in dmband dmcompos dmime dmloader dmscript dmstyle dmsynth dmusic dswave; do cp "$directmusic_source/$dll.dll" "$work/AppDir/directmusic/"; done
else
  7z e -y -o"$work/AppDir/directmusic" "$directmusic_source" dmband.dll dmcompos.dll dmime.dll dmloader.dll dmscript.dll dmstyle.dll dmsynth.dll dmusic.dll dswave.dll > "$work/directmusic-extract.log"
fi
(cd "$work/AppDir/directmusic" && sha256sum -c "$builder_dir/directmusic.sha256" >/dev/null) || { printf 'The selected DirectMusic files do not match the tested versions.\n' >&2; exit 1; }
for name in ld-linux.so.2 libc.so libc.so.6 libm.so libm.so.6 libmvec.so.1 libpthread.so.0 libdl.so.2 librt.so.1 libutil.so.1 libanl.so.1 libresolv.so.2 libnss_compat.so.2 libnss_db.so.2 libnss_dns.so.2 libnss_files.so.2 libnss_hesiod.so.2 libnss_resolve.so.2 libBrokenLocale.so.1 libthread_db.so.1 libmemusage.so libpcprofile.so; do
  rm -f "$work/AppDir/runtime32/$name"
done
for directory in 'Empire Earth' 'Empire Earth - The Art of Conquest'; do cp "$work/AppDir/dxvk/d3d9.dll" "$work/AppDir/game/$directory/d3d9.dll"; done
sed "s/^DEFAULT_RESOLUTION=.*/DEFAULT_RESOLUTION=$resolution/" "$builder_dir/game-AppRun" > "$work/AppDir/AppRun"
chmod 755 "$work/AppDir/AppRun"
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
if [ -d "$mesa/share/licenses/freedesktop-sdk/mesa" ]; then
  cp -a "$mesa/share/licenses/freedesktop-sdk/mesa" "$work/AppDir/licenses/Mesa"
fi
ln -s empire-earth.svg "$work/AppDir/.DirIcon"
cat > "$work/AppDir/PRIVATE_GAME.txt" <<'NOTE'
Private game AppImage generated from a user-supplied verified GOG installer
and user-supplied DirectMusic files. Do not redistribute this game AppImage.
Wine, DXVK, AppImage tooling and 32-bit runtime were verified by pinned
SHA-256 hashes or Flatpak commits before use.
NOTE
printf 'Packaging the private game AppImage…\n'
ARCH=x86_64 APPIMAGE_EXTRACT_AND_RUN=1 MAGIC="$builder_dir/tools/magic.mgc" LD_LIBRARY_PATH="$builder_dir/tools/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" PATH="$builder_dir/tools:$PATH" "$packager" --no-appstream --comp zstd --runtime-file "$builder_dir/tools/runtime-x86_64-private" "$work/AppDir" "$work/game.AppImage" > "$work/packaging.log" 2>&1 || { tail -40 "$work/packaging.log" >&2; exit 1; }
mv "$work/game.AppImage" "$output"
chmod 755 "$output"
(cd "$(dirname "$output")" && sha256sum "$(basename "$output")") > "$output.sha256"
printf 'BUILD COMPLETE: %s\n' "$output"
