#!/bin/sh
set -eu

base_url="${1:-http://127.0.0.1:8080}"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

fetch() {
    curl --connect-timeout 5 --max-time 30 --fail --silent --show-error "$@"
}

fetch "$base_url/healthz" > "$work_dir/health"
test "$(tr -d '\r\n' < "$work_dir/health")" = "ok"

fetch --dump-header "$work_dir/headers" \
    "$base_url/top/1?range=day" > "$work_dir/page"

grep -q '<title>hckrnws</title>' "$work_dir/page"
grep -qi '^Content-Security-Policy:' "$work_dir/headers"
grep -qi '^X-Content-Type-Options: nosniff' "$work_dir/headers"

asset_path="$(grep -oE '/assets/[^\"]+\.js' "$work_dir/page" | while IFS= read -r path; do
    printf '%s' "$path"
    break
done)"
test -n "$asset_path"
fetch "$base_url$asset_path" > "$work_dir/asset"
test -s "$work_dir/asset"

for path in /img/favicon.ico /android-chrome-192x192.png /android-chrome-512x512.png; do
    fetch "$base_url$path" > /dev/null
done

status="$(curl --connect-timeout 5 --max-time 30 --silent \
    --output /dev/null --write-out '%{http_code}' \
    "$base_url/assets/does-not-exist.js")"
test "$status" = "404"

printf 'Smoke tests passed for %s\n' "$base_url"
