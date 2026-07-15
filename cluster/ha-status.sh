#!/bin/bash
# High Availability Status

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "High Availability Status"

if ! is_cluster; then
    echo "  HA erfordert einen Cluster."
    footer
    exit 0
fi

echo "**HA Manager Status:**"
ha-manager status 2>/dev/null | sed 's/^/  /' || echo "  ha-manager nicht verfügbar"
echo

echo "**HA-Ressourcen:**"
pvesh get /cluster/ha/resources 2>/dev/null | sed 's/^/  /' || \
    grep -r 'ha:' /etc/pve/qemu-server/ /etc/pve/lxc/ 2>/dev/null | sed 's/^/  /' || \
    echo "  Keine HA-Ressourcen konfiguriert"

footer