#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
: "${EE_TEST_ELF64:?Choose an actual 64-bit driver ELF for the discovery regression test.}"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
# Exercise the launcher's actual discovery functions with distro/Flatpak layouts.
is_elf64() { [ "$(od -An -j4 -N1 -t u1 "$1" 2>/dev/null | tr -d ' ')" = 2 ]; }
source <(sed -n '/^  resolve_icd() {/,/^  ICD_LIBRARY=$/p' "$root/game-AppRun" | sed '$d')
GPU_FAMILY=intel
GPU_DRIVER=i915
mkdir -p "$work/native/share/vulkan/icd.d" "$work/native/lib/x86_64-linux-gnu" "$work/flatpak/lib/vulkan/icd.d"
cp "$EE_TEST_ELF64" "$work/native/lib/x86_64-linux-gnu/libvulkan_intel.so"
printf '{"ICD":{"library_path":"libvulkan_intel.so"}}\n' > "$work/native/share/vulkan/icd.d/intel_icd.x86_64.json"
find_icd "$work/native"
[[ "$ICD_LIBRARY" == "$work/native/lib/x86_64-linux-gnu/libvulkan_intel.so" ]]
cp "$EE_TEST_ELF64" "$work/flatpak/lib/libvulkan_intel.so"
printf '{"ICD":{"library_path":"/usr/lib/x86_64-linux-gnu/GL/default/lib/libvulkan_intel.so"}}\n' > "$work/flatpak/lib/vulkan/icd.d/intel_icd.x86_64.json"
find_icd "$work/flatpak"
[[ "$ICD_LIBRARY" == "$work/flatpak/lib/libvulkan_intel.so" ]]
cp "${EE_TEST_ELF32:?Choose an actual ELF32 driver for the rejection test.}" "$work/flatpak/lib/libvulkan_intel.so"
if find_icd "$work/flatpak"; then echo 'Incorrectly accepted ELF32 driver' >&2; exit 1; fi
printf 'PASS: Mint relative library, Flatpak absolute remapping, ELF32 rejection.\n'
