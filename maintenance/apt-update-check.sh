#!/bin/bash
# Prüft verfügbare APT-Updates (ohne Installation)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "APT Update-Check"

echo "Aktualisiere Paketlisten (apt update)..."
apt update -qq 2>&1 | tail -3 | sed 's/^/  /'
echo

upgradable=$(apt list --upgradable 2>/dev/null | grep -c upgradable || echo 0)
echo "**Aktualisierbare Pakete:** $upgradable"
echo

if (( upgradable > 0 )); then
    echo "**PVE-relevante Updates:**"
    apt list --upgradable 2>/dev/null | grep -iE 'pve|proxmox|qemu|ceph|corosync' | sed 's/^/  /' || echo "  Keine PVE-spezifischen Updates"
    echo
    echo "**Alle Updates:**"
    apt list --upgradable 2>/dev/null | tail -n +2 | sed 's/^/  /'
fi

echo
echo "**Hinweis:** Updates installieren mit: apt dist-upgrade"
footer