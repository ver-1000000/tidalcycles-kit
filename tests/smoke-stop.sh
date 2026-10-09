#!/usr/bin/env bash
# Compose lifecycle test; starts no patterns.
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
temp=$(mktemp -d)
export TIDAL_KIT_ENGINE=${TIDAL_KIT_ENGINE:-podman}
compose=("$TIDAL_KIT_ENGINE" compose -p "tidal-stop-test-$$" -f compose.yaml)
trap '"${compose[@]}" down >/dev/null 2>&1; rm -rf -- "$temp"' EXIT
"${compose[@]}" run --rm --no-deps -T audio sh -eu -c '
    test "$(id -u)" = "$(stat -c %u "$PIPEWIRE_RUNTIME_DIR/pipewire-0")"
    test "$(id -g)" = "$(stat -c %g "$PIPEWIRE_RUNTIME_DIR/pipewire-0")"
    awk "/^Cap(Inh|Prm|Eff|Bnd|Amb):/ { if (\$2 != \"0000000000000000\") bad=1; n++ }
         /^NoNewPrivs:/ { nnp=\$2 }
         END { exit(bad || n!=5 || nnp!=1) }" /proc/1/status
    echo "PASS: socket ownership, zero capabilities and no-new-privileges"
'
for round in 1 2; do
    "${compose[@]}" up -d --no-build
    cid=$("${compose[@]}" ps -a -q audio)
    for _ in {1..150}; do
        "$TIDAL_KIT_ENGINE" logs "$cid" >"$temp/audio.log" 2>&1
        grep -q '^TIDAL_KIT_AUDIO_READY$' "$temp/audio.log" && break
        [[ $("$TIDAL_KIT_ENGINE" inspect -f '{{.State.Running}}' "$cid") == true ]] || break
        sleep 0.1
    done
    grep -q '^TIDAL_KIT_AUDIO_READY$' "$temp/audio.log" || { cat "$temp/audio.log"; exit 1; }
    "${compose[@]}" stop audio
    [[ $("$TIDAL_KIT_ENGINE" inspect -f '{{.State.ExitCode}}' "$cid") != 137 ]] || {
        echo 'FAIL: audio needed SIGKILL instead of stopping gracefully'
        exit 1
    }
    tidal_cid=$("${compose[@]}" ps -a -q tidal)
    "${compose[@]}" stop tidal
    [[ $("$TIDAL_KIT_ENGINE" inspect -f '{{.State.ExitCode}}' "$tidal_cid") != 137 ]] || {
        echo 'FAIL: Tidal needed SIGKILL instead of stopping gracefully'
        exit 1
    }
    "${compose[@]}" down
    ! "$TIDAL_KIT_ENGINE" inspect "$cid" >/dev/null 2>&1
    [[ -z $(ss -H -lun 'sport = :57120') ]]
done
echo 'PASS: Compose up/down and second startup'
