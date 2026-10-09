#!/usr/bin/env bash
# Audible, normal-gain Compose test; lower physical output volume first.
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
case ${1:-bd} in
    bd) pattern='d1 $ sound "bd*2"' ;;
    superpiano) pattern='d1 $ note "0 4 7 12" # sound "superpiano" # gain 0.4' ;;
    *) echo 'Usage: smoke-audio.sh [bd|superpiano]' >&2; exit 2 ;;
esac
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
temp=$(mktemp -d)
export TIDAL_KIT_ENGINE=${TIDAL_KIT_ENGINE:-podman}
compose=("$TIDAL_KIT_ENGINE" compose -p "tidal-audio-test-$$" -f compose.yaml -f tests/compose.audio-test.yaml)
trap '"${compose[@]}" down >/dev/null 2>&1; rm -rf -- "$temp"' EXIT
"${compose[@]}" up -d --no-build audio
cid=$("${compose[@]}" ps -a -q audio)
for _ in {1..150}; do
    "$TIDAL_KIT_ENGINE" logs "$cid" >"$temp/audio.log" 2>&1
    grep -q '^KIT_RECORDING_READY$' "$temp/audio.log" && break
    [[ $("$TIDAL_KIT_ENGINE" inspect -f '{{.State.Running}}' "$cid") == true ]] || break
    sleep 0.1
done
grep -q '^KIT_RECORDING_READY$' "$temp/audio.log" || { cat "$temp/audio.log"; exit 1; }
printf 'import Control.Concurrent (threadDelay)\n%s\nthreadDelay 4000000\nhush\nthreadDelay 4000000\n:quit\n' "$pattern" |
    timeout 90 ./bin/tidal-ghci >"$temp/tidal.log" 2>&1 || { cat "$temp/tidal.log"; exit 1; }
"$TIDAL_KIT_ENGINE" exec "$cid" touch /tmp/kit-recording-finish
status=$(timeout 30 "$TIDAL_KIT_ENGINE" wait "$cid")
"$TIDAL_KIT_ENGINE" logs "$cid" >"$temp/audio.log" 2>&1
[[ $status == 0 ]] || { cat "$temp/audio.log" "$temp/tidal.log"; exit 1; }
grep '^PASS:' "$temp/audio.log"
