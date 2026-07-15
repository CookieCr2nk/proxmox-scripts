#!/bin/bash
# Status aller konfigurierten Proxmox-Storages

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "Storage-Status"

pvesm status 2>/dev/null | sed 's/^/  /' || {
    echo "  pvesm nicht verfügbar"
    exit 1
}
echo

echo "**Details pro Storage:**"
pvesh get /storage --output-format text 2>/dev/null | while IFS= read -r line; do
    echo "  $line"
done

footer