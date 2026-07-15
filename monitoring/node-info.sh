#!/bin/bash
# Proxmox Node-Informationen: Version, Uptime, Kernel

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "Proxmox Node-Informationen"

echo "**Hostname:** $(hostname -f)"
echo "**Node:**     $(pve_node_name)"
echo

if [[ -f /etc/pve/.version ]]; then
    echo "**PVE Version:** $(cat /etc/pve/.version)"
fi
echo "**Kernel:**       $(uname -r)"
echo "**Architektur:**  $(uname -m)"
echo

echo "**Uptime:**"
uptime -p 2>/dev/null || uptime
echo

echo "**PVE Pakete (Auszug):**"
dpkg -l 2>/dev/null | grep -E '^ii\s+(pve-manager|proxmox-ve|qemu-server|pve-cluster|pve-qemu-kvm)' | awk '{print "  "$2" "$3}' || true

if is_cluster; then
    echo
    echo "**Cluster:** aktiv"
    pvecm status 2>/dev/null | grep -E 'Quorum|Nodes|Node ID' | sed 's/^/  /' || true
else
    echo
    echo "**Cluster:** Standalone (kein Cluster)"
fi

footer