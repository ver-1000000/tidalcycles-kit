#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
root=$PWD
temp=$(mktemp -d)
trap 'rm -rf -- "$temp"' EXIT
export TIDAL_KIT_ENGINE="$root/tests/fixtures/runtime"
export KIT_TEST_ARGS="$temp/args"
./bin/tidal-ghci -e '1 + 1'
grep -Fx -- compose "$KIT_TEST_ARGS"
grep -Fx -- --no-deps "$KIT_TEST_ARGS"
grep -Fx -- "$root/compose.yaml" "$KIT_TEST_ARGS"
! grep -Fx -- -ghci-script "$KIT_TEST_ARGS"
./bin/tidal-ghci
grep -Fx /opt/kit/boot/BootTidal.hs "$KIT_TEST_ARGS"
./bin/ghci
! grep -Fx -- -ghci-script "$KIT_TEST_ARGS"
./bin/tidal-ghci -ghci-script "$root/runtime/BootTidal.hs"
grep -Fx "$root/runtime/BootTidal.hs:/opt/kit/selected-boot.hs:ro" "$KIT_TEST_ARGS"
reject() { if "$@" >"$temp/error" 2>&1; then printf 'Unexpected success: %s\n' "$*"; exit 1; fi; }
reject ./bin/tidal-ghci -ghci-script
reject ./bin/tidal-ghci -ghci-script "$temp/missing"
reject ./bin/tidal-ghci -ghci-script runtime/BootTidal.hs -ghci-script runtime/BootTidal.hs
reject env TIDAL_CONTROL_PORT=65536 ./bin/tidal-ghci
reject env TIDAL_CONTROL_PORT=x ./bin/tidal-ghci
TIDAL_CONTROL_PORT=00080 ./bin/tidal-ghci
grep -Fx TIDAL_CONTROL_PORT=80 "$KIT_TEST_ARGS"
(cd "$HOME"; reject "$root/bin/tidal-ghci")
(cd /; reject "$root/bin/tidal-ghci")
mkdir "$temp/comma,path"
(cd "$temp/comma,path"; reject "$root/bin/tidal-ghci")
reject env TIDAL_KIT_ENGINE="$temp/missing" ./bin/tidal-ghci
reject env PIPEWIRE_RUNTIME_DIR="$temp" sh runtime/audio-entrypoint true
grep -F 'PipeWire socket is missing' "$temp/error"
printf 'PASS: Compose adapter arguments, path guards and errors\n'
