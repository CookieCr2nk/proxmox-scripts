#!/bin/bash
# LVM Thin Pool Auslastung (häufige Ursache für volle Storages)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "LVM Thin Pool Status"

if ! command -v lvs &>/dev/null; then
    echo "  LVM nicht verfügbar."
    footer
    exit 0
fi

echo "**Volume Groups:**"
vgs 2>/dev/null | sed 's/^/  /'
echo

echo "**Logical Volumes:**"
lvs -o lv_name,vg_name,lv_size,data_percent,metadata_percent,pool_lv 2>/dev/null | sed 's/^/  /'
echo

echo "**Warnungen (>80% data_percent):**"
warn=0
while read -r line; do
    pct_val=$(echo "$line" | awk '{print $4}' | tr -d '%')
    if [[ -n "$pct_val" && "$pct_val" =~ ^[0-9]+$ ]] && (( pct_val >= 80 )); then
        echo "  ⚠ $line"
        warn=1
    fi
done < <(lvs -o lv_name,vg_name,data_percent --noheadings 2>/dev/null)

(( warn == 0 )) && echo "  Keine Thin Pools über 80%"

footer