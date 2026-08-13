#!/usr/bin/env bash
# Portfolio-safe derivative of the private ArcSyn lab health check.
# Private URLs and absolute paths are externalized; this is not a drop-in
# replacement for the private operational script.
set -u

: "${OPEN_WEBUI_HEALTH_URL:?Set OPEN_WEBUI_HEALTH_URL to the private health endpoint}"
: "${JELLYFIN_HEALTH_URL:?Set JELLYFIN_HEALTH_URL to the private health endpoint}"
: "${SEARXNG_INTERNAL_URL:?Set SEARXNG_INTERNAL_URL to the internal search endpoint}"
: "${DISK_CHECK_SCRIPT:?Set DISK_CHECK_SCRIPT to the reviewed disk-check script path}"

PASS=0
FAIL=0

check() {
    local name="$1"
    shift

    if "$@" >/dev/null 2>&1; then
        printf '[PASS] %s\n' "$name"
        PASS=$((PASS + 1))
    else
        printf '[FAIL] %s\n' "$name"
        FAIL=$((FAIL + 1))
    fi
}

echo "ArcSyn AI Lab Health Check"
echo "==========================="

check "Docker service" systemctl is-active --quiet docker
check "Tailscale service" systemctl is-active --quiet tailscaled
check "nftables service" systemctl is-active --quiet nftables

check "Open WebUI container" docker inspect -f '{{.State.Running}}' open-webui
check "SearXNG container" docker inspect -f '{{.State.Running}}' searxng
check "Homepage container" docker inspect -f '{{.State.Running}}' homepage
check "Uptime Kuma container" docker inspect -f '{{.State.Running}}' uptime-kuma
check "Jellyfin container" docker inspect -f '{{.State.Running}}' jellyfin

check "Open WebUI health endpoint" curl -fsS "$OPEN_WEBUI_HEALTH_URL"
check "Jellyfin health endpoint" curl -fsS "$JELLYFIN_HEALTH_URL"

if [[ "${ARCSYN_SKIP_EXTERNAL_WORKERS:-0}" == "1" ]]; then
    echo "[SKIP] External Ollama reachable from host (external worker check disabled)"
    echo "[SKIP] External Ollama reachable from Open WebUI (external worker check disabled)"
else
    : "${EXTERNAL_OLLAMA_URL:?Set EXTERNAL_OLLAMA_URL or ARCSYN_SKIP_EXTERNAL_WORKERS=1}"

    check "External Ollama reachable from host" \
        curl -fsS "$EXTERNAL_OLLAMA_URL"

    check "External Ollama reachable from Open WebUI" \
        docker exec -e TARGET_URL="$EXTERNAL_OLLAMA_URL" open-webui python -c \
        'import os, urllib.request; urllib.request.urlopen(os.environ["TARGET_URL"], timeout=10)'
fi

check "SearXNG reachable from Open WebUI" \
    docker exec -e TARGET_URL="$SEARXNG_INTERNAL_URL" open-webui python -c \
    'import os, urllib.request; urllib.request.urlopen(os.environ["TARGET_URL"], timeout=20)'

check "Disk usage below critical threshold" "$DISK_CHECK_SCRIPT"

echo
echo "Passed: $PASS"
echo "Failed: $FAIL"

if ((FAIL > 0)); then
    exit 1
fi
