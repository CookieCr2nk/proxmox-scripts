#!/bin/bash
# Sicheres PVE System-Update mit Vorab-Checks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "Proxmox System-Update"

echo "**Vorab-Checks:**"
echo -n "  Cluster-Quorum: "
if is_cluster; then
    pvecm status 2>/dev/null | grep -q "Quorate:.*Yes" && echo "OK" || echo "⚠ NICHT QUORATE!"
else
    echo "N/A (Standalone)"
fi

running_vms=$(qm list 2>/dev/null | grep -c running || echo 0)
echo "  Laufende VMs: $running_vms"
echo

read -r -p "apt update && apt dist-upgrade ausführen? [j/N] " confirm
[[ "$confirm" =~ ^[jJyY] ]] || { echo "Abgebrochen."; exit 0; }

apt update
DEBIAN_FRONTEND=noninteractive apt -y dist-upgrade

echo
echo "**Kernel-Version nach Update:** $(uname -r)"
if [[ -f /var/run/reboot-required ]]; then
    echo "⚠ Neustart erforderlich! (/var/run/reboot-required)"
fi

footer