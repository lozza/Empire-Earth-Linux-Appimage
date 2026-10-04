#!/usr/bin/env bash
set -eu
appdir=$1
game=$2
choice=$3
digest=5464f3db1ee70d442e721e269c523a8d3e59fcb126c249c7fe24ccb23f17844b
if [ "$choice" = on ]; then
  [ -f "$appdir/camera/dreXmod.dll" ] || { printf 'This game was built without the camera patch. Rebuild with dreXmod selected and supply your local ZIP.\n' >&2; exit 78; }
  [ "$(sha256sum "$appdir/camera/dreXmod.dll" | cut -d' ' -f1)" = "$digest" ] || { printf 'Camera patch verification failed.\n' >&2; exit 78; }
  if [ -f "$game/dreXmod.dll" ] && [ "$(sha256sum "$game/dreXmod.dll" | cut -d' ' -f1)" != "$digest" ]; then
    printf 'A different dreXmod is already installed in %s. Back it up before enabling this camera patch.\n' "$game" >&2
    exit 78
  fi
  cp "$appdir/camera/dreXmod.dll" "$game/dreXmod.dll"
  # Keep any existing camera settings; seed the tested closer view only once.
  [ -f "$game/dreXmod.config" ] || cp "$appdir/camera/dreXmod.config" "$game/dreXmod.config"
  printf 'Wider camera enabled; settings: %s/dreXmod.config\n' "$game"
elif [ "$choice" = off ]; then
  if [ -f "$game/dreXmod.dll" ] && [ "$(sha256sum "$game/dreXmod.dll" | cut -d' ' -f1)" = "$digest" ]; then
    mkdir -p "$game/.camera-disabled"
    mv "$game/dreXmod.dll" "$game/.camera-disabled/dreXmod.dll"
  fi
  printf 'Builder camera patch disabled.\n'
else
  printf 'Invalid camera choice: %s\n' "$choice" >&2; exit 2
fi
