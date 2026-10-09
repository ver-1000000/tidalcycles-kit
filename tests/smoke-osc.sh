#!/usr/bin/env bash
# Uses the audio image's language interpreter, without starting an audio server.
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
root=$PWD
temp=$(mktemp -d)
receiver=''
receiver_name="tidal-osc-test-$$"
runtime=${TIDAL_KIT_ENGINE:-podman}
trap '"$runtime" rm -f "$receiver_name" >/dev/null 2>&1 || true; [[ -z $receiver ]] || wait "$receiver" 2>/dev/null || true; rm -rf -- "$temp"' EXIT
[[ -z $(ss -H -lun 'sport = :57120') ]] || { echo 'Stop existing SuperDirt first.'; exit 1; }
timeout 150 "$runtime" run --rm --name "$receiver_name" --init --network=host --read-only --tmpfs /tmp \
    --user 65534:65534 --cap-drop=ALL --security-opt=no-new-privileges \
    --mount "type=bind,source=$root/tests,target=/tests,readonly" \
    --entrypoint sh "${TIDAL_KIT_AUDIO_IMAGE:-localhost/tidalcycles-kit-audio:dev}" \
    -c 'mkdir -p /tmp/runtime && chmod 700 /tmp/runtime && exec sclang -a -l /opt/kit/boot/sclang.yaml -D /tests/osc-receiver.scd' > "$temp/receiver" 2>&1 &
receiver=$!
for _ in {1..600}; do
    grep -q OSC_RECEIVER_READY "$temp/receiver" && break
    kill -0 "$receiver" 2>/dev/null || break
    sleep 0.1
done
grep -q OSC_RECEIVER_READY "$temp/receiver" || { cat "$temp/receiver"; exit 1; }
if [[ ${1:-} == --editor ]]; then
    plugin=$(cd -- "${2:?Pass plugin checkout}" && pwd -P)
    KIT_TEST_ROOT=$root KIT_TEST_PLUGIN=$plugin timeout 100 nvim --headless -u NONE -n -S tests/editor.vim > "$temp/ghci" 2>&1
else
    mode=tidal-ghci
    [[ ${1:-} != --raw-boot ]] || mode=ghci
    {
        if [[ $mode == ghci ]]; then cat runtime/BootTidal.hs; printf '\n'; fi
        printf 'import Control.Concurrent (threadDelay)\nd1 $ sound "bd*4"\nthreadDelay 4000000\n'
        printf 'hush\nthreadDelay 3000000\nthisNameDoesNotExist\nputStrLn "KIT_RECOVERED"\n'
        printf ':quit\n'
    } | timeout 90 "./bin/$mode" > "$temp/ghci" 2>&1 || { cat "$temp/ghci"; exit 1; }
    grep -q KIT_RECOVERED "$temp/ghci"
    grep -qi 'not in scope' "$temp/ghci"
fi
"$runtime" exec "$receiver_name" touch /tmp/kit-osc-finished || { cat "$temp/receiver"; exit 1; }
if ! wait "$receiver"; then cat "$temp/receiver" "$temp/ghci"; exit 1; fi
receiver=''
grep 'PASS:' "$temp/receiver"
