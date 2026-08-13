#!/usr/bin/env bash
# Portfolio-safe derivative of the private ArcSyn disk-space monitor.
# Live filesystem paths and the live status-file path are intentionally externalized.
set -u

WARNING_PERCENT="${WARNING_PERCENT:-80}"
CRITICAL_PERCENT="${CRITICAL_PERCENT:-90}"
STATUS_FILE="${STATUS_FILE:-}"
: "${ARCSYN_DISK_PATHS:?Set ARCSYN_DISK_PATHS as a newline-delimited list of real paths to check}"

mapfile -t PATHS <<< "$ARCSYN_DISK_PATHS"

if ((${#PATHS[@]} == 0)); then
    echo "No disk paths configured" >&2
    exit 64
fi

OVERALL="OK"
EXIT_CODE=0

if [[ -n "$STATUS_FILE" ]]; then
    mkdir -p "$(dirname "$STATUS_FILE")"
    exec > >(tee "$STATUS_FILE") 2>&1
fi

echo "ArcSyn Disk-Space Status"
echo "Generated: $(date --iso-8601=seconds)"
echo "Warning threshold: ${WARNING_PERCENT}%"
echo "Critical threshold: ${CRITICAL_PERCENT}%"
echo

for path in "${PATHS[@]}"; do
    if [[ -z "$path" ]]; then
        continue
    fi

    if [[ ! -e "$path" ]]; then
        echo "[CRITICAL] Missing path: $path"
        OVERALL="CRITICAL"
        EXIT_CODE=2
        continue
    fi

    read -r filesystem percent available < <(
        df -P "$path" |
        awk 'NR == 2 {
            gsub("%", "", $5)
            print $1, $5, $4
        }'
    )

    available_human="$(
        numfmt \
            --from-unit=1024 \
            --to=iec-i \
            --suffix=B \
            "$available"
    )"

    status="OK"

    if ((percent >= CRITICAL_PERCENT)); then
        status="CRITICAL"
        OVERALL="CRITICAL"
        EXIT_CODE=2
    elif ((percent >= WARNING_PERCENT)); then
        status="WARNING"
        if [[ "$OVERALL" == "OK" ]]; then
            OVERALL="WARNING"
        fi
    fi

    printf '[%s] %s — %s%% used, %s available, filesystem %s\n' \
        "$status" \
        "$path" \
        "$percent" \
        "$available_human" \
        "$filesystem"
done

echo
echo "Overall: $OVERALL"

exit "$EXIT_CODE"
