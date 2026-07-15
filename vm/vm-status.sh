#!/bin/bash
# Übersicht aller VMs und Container mit Status

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "VM & Container Status"

echo "**QEMU VMs:**"
qm list 2>/dev/null | sed 's/^/  /' || echo "  qm nicht verfügbar"
echo

echo "**LXC Container:**"
pct list 2>/dev/null | sed 's/^/  /' || echo "  pct nicht verfügbar"
echo

echo "**Cluster-Ressourcen (alle Nodes):**"
pvesh get /cluster/resources --type vm --output-format text 2>/dev/null | \
    awk '{printf "  %-6s %-25s %-10s CPU:%-4s RAM:%-8s Disk:%s\n", $1, $2, $3, $4, $5, $6}' || \
    pvesh get /cluster/resources --type vm 2>/dev/null | sed 's/^/  /'

running=$(pvesh get /cluster/resources --type vm 2>/dev/null | grep -c '"status":"running"' || qm list 2>/dev/null | grep -c running || echo "?")
stopped=$(pvesh get /cluster/resources --type vm 2>/dev/null | grep -c '"status":"stopped"' || echo "?")
echo
echo "**Zusammenfassung:** Running: $running | Stopped: $stopped"

footer