#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

fail() {
    echo "[TEST FAIL] $*" >&2
    exit 1
}

mkdir -p "$TEST_ROOT/bin"

cat >"$TEST_ROOT/bin/systemctl" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK

cat >"$TEST_ROOT/bin/curl" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK

cat >"$TEST_ROOT/bin/docker" <<'MOCK'
#!/usr/bin/env bash

if [[ "${1:-}" == "inspect" && "${2:-}" == "-f" && "${3:-}" == "{{.State.Running}}" ]]; then
    container="${4:-}"
    target="${PORTFOLIO_DOCKER_TARGET:-}"
    state="${PORTFOLIO_DOCKER_STATE:-true}"

    if [[ -n "$target" && "$container" == "$target" ]]; then
        case "$state" in
            true|false)
                printf '%s\n' "$state"
                exit 0
                ;;
            missing)
                exit 1
                ;;
            *)
                echo "unsupported mock Docker state: $state" >&2
                exit 64
                ;;
        esac
    fi

    printf 'true\n'
    exit 0
fi

exit 0
MOCK

chmod +x "$TEST_ROOT/bin/systemctl" "$TEST_ROOT/bin/curl" "$TEST_ROOT/bin/docker"

run_health() {
    PATH="$TEST_ROOT/bin:$PATH" \
    OPEN_WEBUI_HEALTH_URL="http://127.0.0.1/open-webui-health" \
    JELLYFIN_HEALTH_URL="http://127.0.0.1/jellyfin-health" \
    SEARXNG_INTERNAL_URL="http://127.0.0.1/searxng-health" \
    DISK_CHECK_SCRIPT="true" \
    ARCSYN_SKIP_EXTERNAL_WORKERS=1 \
    bash "$REPO_ROOT/scripts/check-lab-health.portfolio.sh"
}

run_health >"$TEST_ROOT/running-output"

container_cases=(
    "open-webui|Open WebUI container"
    "searxng|SearXNG container"
    "homepage|Homepage container"
    "uptime-kuma|Uptime Kuma container"
    "jellyfin|Jellyfin container"
)

for case_entry in "${container_cases[@]}"; do
    IFS='|' read -r container label <<<"$case_entry"

    grep -Fq "[PASS] $label" "$TEST_ROOT/running-output" ||
        fail "running container did not PASS: $container"

    if PORTFOLIO_DOCKER_TARGET="$container" \
        PORTFOLIO_DOCKER_STATE=false \
        run_health >"$TEST_ROOT/stopped-output" 2>&1; then
        fail "stopped container false-PASSed: $container"
    fi
    grep -Fq "[FAIL] $label" "$TEST_ROOT/stopped-output" ||
        fail "stopped container did not report FAIL: $container"

    if PORTFOLIO_DOCKER_TARGET="$container" \
        PORTFOLIO_DOCKER_STATE=missing \
        run_health >"$TEST_ROOT/missing-output" 2>&1; then
        fail "missing container false-PASSed: $container"
    fi
    grep -Fq "[FAIL] $label" "$TEST_ROOT/missing-output" ||
        fail "missing container did not report FAIL: $container"
done

echo "Portfolio health predicate regression passed."
