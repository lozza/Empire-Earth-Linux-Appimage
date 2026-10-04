#!/usr/bin/env bash
set -euo pipefail
root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
: "${EE_INNOEXTRACT_DIR:?Set EE_INNOEXTRACT_DIR to the verified innoextract 1.9 directory.}"
: "${EE_FILE_BINARY:?Set EE_FILE_BINARY to the verified file 5.46 binary.}"
: "${EE_MAGIC_DB:?Set EE_MAGIC_DB to the verified magic.mgc.}"
: "${EE_LIBMAGIC:?Set EE_LIBMAGIC to Freedesktop SDK 24.08 libmagic.so.1.}"
: "${EE_RUNTIME:?Set EE_RUNTIME to the verified AppImage type-2 runtime.}"
: "${EE_APPIMAGETOOL:?Set EE_APPIMAGETOOL to the verified appimagetool AppImage.}"
check() { [ "$(sha256sum "$1" | cut -d' ' -f1)" = "$2" ] || { printf 'Packaging tool hash mismatch: %s\n' "$1" >&2; exit 2; }; }
check "$EE_INNOEXTRACT_DIR/bin/amd64/innoextract" 7a8ad941deeb0de8d1f804830f339fd17e27cfbce473615d79d1d65c106884e9
check "$EE_FILE_BINARY" 268c7ad01da54ad1305f179817453790ec083ac5c3e92702bca558984e7edf34
check "$EE_MAGIC_DB" 7c7cb700483efbe0dc4009589912911bae33a669bf17f71b1ae03a5f5e2de4f9
check "$EE_LIBMAGIC" 1a92fe253ed0daf6a5b7f9cfce6b99c69cd3dcb26daa52c1e6a882f819d870d2
check "$EE_RUNTIME" 4448aff037fa32788d2fb8ac9a10bd9688cd95ffcebbda05d1962278d0fa8c47
check "$EE_APPIMAGETOOL" a6d71e2b6cd66f8e8d16c37ad164658985e0cf5fcaa950c90a482890cb9d13e0
gui_lib_dir=$(dirname "$EE_LIBMAGIC")
check "$gui_lib_dir/libxkbcommon.so.0.8.1" a3f6204c7bae0bb38ca6902aae28a9f6a414e6e56f4f893cd0e1040cad931877
check "$gui_lib_dir/libxkbcommon-x11.so.0.8.1" c8654d95ebb40651c63deb3021e5fb89349f5ea19997f51a5fed145dc8b82e1c
check "$gui_lib_dir/libxcb-xkb.so.1.0.0" 96c6b173d124161fc45f93fbcf7261299c6b1f1f533a9d39b2ed3e83989dc755
check "$root/licenses/DXVK-LICENSE" a5cb1a6ded7d2d7e92d550ba28edd21be2d1d4044662b399887351023e30ce64
# Refuse a newer host-built GUI before it can reach a public AppImage.
: "${EE_GUI_BINARY:?Set EE_GUI_BINARY to the Freedesktop SDK 24.08 GUI build.}"
check_abi() {
  local file=$1 highest
  highest=$(readelf --version-info "$file" | sed -n 's/.*Name: GLIBC_\([0-9.]*\).*/\1/p' | sort -V | tail -n 1)
  [ -n "$highest" ] && [ "$(printf '%s\n' "$highest" 2.39 | sort -V | tail -n 1)" = 2.39 ] || {
    printf 'Builder component exceeds the glibc 2.39 portability limit: %s (%s)\n' "$file" "$highest" >&2
    exit 2
  }
}
for component in "$EE_GUI_BINARY" "$EE_LIBMAGIC" "$EE_FILE_BINARY" "$EE_INNOEXTRACT_DIR/bin/amd64/innoextract"; do
  check_abi "$component"
done
for component in "$gui_lib_dir/libxkbcommon.so.0.8.1" "$gui_lib_dir/libxkbcommon-x11.so.0.8.1" "$gui_lib_dir/libxcb-xkb.so.1.0.0"; do check_abi "$component"; done
appdir="$root/AppDir"
mkdir -p "$appdir/tools/lib" "$appdir/usr/bin" "$appdir/licenses"
mkdir -p "$appdir/usr/lib" "$appdir/licenses/gui-keyboard"
cp "$gui_lib_dir/libxkbcommon.so.0.8.1" "$appdir/usr/lib/libxkbcommon.so.0"
cp "$gui_lib_dir/libxkbcommon-x11.so.0.8.1" "$appdir/usr/lib/libxkbcommon-x11.so.0"
ln -sfn libxkbcommon-x11.so.0 "$appdir/usr/lib/libxkbcommon-x11.so"
cp "$gui_lib_dir/libxcb-xkb.so.1.0.0" "$appdir/usr/lib/libxcb-xkb.so.1"
cp -a "$gui_lib_dir/../../share/licenses/freedesktop-sdk/libxkbcommon" "$gui_lib_dir/../../share/licenses/freedesktop-sdk/xorg-lib-xcb" "$appdir/licenses/gui-keyboard/"
# SDK licence symlinks refer to its /usr sandbox; store the actual notice.
rm -f "$appdir/licenses/gui-keyboard/xorg-lib-xcb/COPYING"
cp "$gui_lib_dir/../../share/licenses/common/LICENSE_424ba57213ef" "$appdir/licenses/gui-keyboard/xorg-lib-xcb/COPYING"
rm -rf "$appdir/licenses/rust-crates"
cp -a "$root/licenses/rust-crates" "$appdir/licenses/"
cp "$root/licenses/file-COPYING" "$root/licenses/type2-runtime-LICENSE" "$appdir/licenses/"
cp "$root/AppRun" "$root/build-game.sh" "$root/game-AppRun" "$root/directmusic.sha256" "$root/migrate-settings.awk" "$appdir/"
cp "$root/configure-camera.sh" "$root/camera-only.config" "$appdir/"
cp "$root/packaging/GAME_THIRD_PARTY_NOTICES.txt" "$appdir/GAME_THIRD_PARTY_NOTICES.txt"
cp "$root/assets/empire-earth.svg" "$appdir/empire-earth.svg"
rm -rf "$appdir/tools/innoextract"
cp -a "$EE_INNOEXTRACT_DIR" "$appdir/tools/innoextract"
cp "$EE_FILE_BINARY" "$appdir/tools/file"
cp "$EE_MAGIC_DB" "$appdir/tools/magic.mgc"
cp "$EE_LIBMAGIC" "$appdir/tools/lib/libmagic.so.1"
cp "$EE_RUNTIME" "$appdir/tools/runtime-x86_64-private"
cp "$root/LICENSE" "$appdir/licenses/Empire-Earth-Builder-GPL-3.0"
cp "$root/licenses/DXVK-LICENSE" "$root/licenses/Wine-LGPL-2.1" "$appdir/licenses/"
cp "$root/THIRD_PARTY_NOTICES.md" "$appdir/licenses/THIRD_PARTY_NOTICES.md"
cp "$root/gui/Cargo.lock" "$appdir/licenses/rust-crates/Cargo.lock"
cp "$root/empire-earth-builder.desktop" "$appdir/"
ln -sfn empire-earth.svg "$appdir/.DirIcon"
cp "$EE_GUI_BINARY" "$appdir/usr/bin/empire-earth-builder-gui"
chmod 755 "$appdir/AppRun" "$appdir/build-game.sh" "$appdir/usr/bin/empire-earth-builder-gui"
output="$root/Empire-Earth-Builder-x86_64.AppImage"
rm -f "$output.partial"
ARCH=x86_64 APPIMAGE_EXTRACT_AND_RUN=1 MAGIC="$EE_MAGIC_DB" PATH="$appdir/tools:$PATH" env -u OWD "$EE_APPIMAGETOOL" --no-appstream --comp zstd --runtime-file "$EE_RUNTIME" "$appdir" "$output.partial"
mv "$output.partial" "$output"
chmod 755 "$output"
(cd "$(dirname "$output")" && sha256sum "$(basename "$output")") > "$output.sha256"
printf 'Builder ready: %s\n' "$output"
