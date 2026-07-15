#!/bin/bash
# Storage/VM Replikations-Status

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "Replikations-Status"

echo "**ZFS Replikation (falls konfiguriert):**"
if command -v zfs &>/dev/null; then
    zfs list -t filesystem -o name,origin,used,avail 2>/dev/null | grep '@' | sed 's/^/  /' || \
        echo "  Keine ZFS-Snapshots/Replikation sichtbar"
else
    echo "  ZFS nicht verfügbar"
fi
echo

echo "**PVE Storage Replication Jobs:**"
if [[ -f /etc/pve/replication.cfg ]]; then
    cat /etc/pve/replication.cfg 2>/dev/null | sed 's/^/  /'
else
    echo "  Keine replication.cfg"
fi
echo

echo "**Aktive Replikations-Tasks:**"
pvesh get /cluster/replication 2>/dev/null | sed 's/^/  /' || \
    grep -r 'replicate' /etc/pve/ 2>/dev/null | head -10 | sed 's/^/  /' || \
    echo "  Keine aktiven Replikations-Jobs"

footer