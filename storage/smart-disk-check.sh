#!/bin/bash
# SMART-Status aller Festplatten

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "SMART Festplatten-Check"

if ! command -v smartctl &>/dev/null; then
    echo "  smartmontools nicht installiert."
    echo "  Installation: apt install smartmontools"
    footer
    exit 1
fi

echo "**Block-Devices:**"
lsblk -d -o NAME,SIZE,MODEL,ROTA,TYPE 2>/dev/null | sed 's/^/  /'
echo

for dev in /dev/sd? /dev/nvme?n1; do
    [[ -b "$dev" ]] || continue
    echo "**$dev:**"
    smartctl -H "$dev" 2>/dev/null | grep -E 'SMART overall|test result|PASSED|FAILED' | sed 's/^/  /' || \
        echo "  SMART nicht unterstützt oder Zugriff verweigert"
    smartctl -A "$dev" 2>/dev/null | grep -iE 'Reallocated|Pending|Uncorrectable|Temperature|Power_On|Wear' | sed 's/^/  /' || true
    echo
done

footer