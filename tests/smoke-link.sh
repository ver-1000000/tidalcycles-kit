#!/usr/bin/env bash
# Opt in only when other Link peers may safely change tempo.
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
temp=$(mktemp -d)
a='' b=''
cleanup() {
    [[ -z $a ]] || kill "$a" 2>/dev/null || true
    [[ -z $b ]] || kill "$b" 2>/dev/null || true
    rm -rf -- "$temp"
}
trap cleanup EXIT
mkfifo "$temp/a" "$temp/b"
exec 3<>"$temp/a" 4<>"$temp/b"
TIDAL_CONTROL_PORT=0 timeout 40 ./bin/tidal-ghci <"$temp/a" >"$temp/a.log" 2>&1 3>&- 4>&- & a=$!
TIDAL_CONTROL_PORT=0 timeout 40 ./bin/tidal-ghci <"$temp/b" >"$temp/b.log" 2>&1 3>&- 4>&- & b=$!
printf 'enableLink\n' >&3
printf 'enableLink\n' >&4
sleep 4
for cps in 0.73 1.17; do
    printf 'setcps %s\n' "$cps" >&3
    sleep 3
    printf 'getcps >>= (putStrLn . ("KIT_CPS=" ++) . show . (fromRational :: Rational -> Double))\n' >&4
    sleep 1
done
printf ':quit\n' >&3
printf ':quit\n' >&4
wait "$a"; a=''
wait "$b"; b=''
awk -F= '/^KIT_CPS=/ { expected=(++n==1 ? 0.73 : 1.17); delta=$2-expected; if(delta < -0.01 || delta > 0.01) bad=1 } END { exit(n!=2 || bad) }' "$temp/b.log" || { cat "$temp/a.log" "$temp/b.log"; exit 1; }
echo 'PASS: two Link peers followed both tempo changes'
