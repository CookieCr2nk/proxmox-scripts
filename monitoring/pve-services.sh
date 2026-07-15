#!/bin/bash
# Status wichtiger Proxmox-Dienste

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "Proxmox Dienste"

SERVICES=(
    pveproxy
    pvedaemon
    pve-cluster
    pvestatd
    spiceproxy
    qmeventd
    watchdog-mux
    corosync
    pve-ha-crm
    pve-ha-lrm
)

for svc in "${SERVICES[@]}"; do
    if systemctl list-unit-files "$svc.service" &>/dev/null 2>&1; then
        status=$(systemctl is-active "$svc" 2>/dev/null || echo "nicht installiert")
        if [[ "$status" == "active" ]]; then
            echo "  ✓ $svc: $status"
        elif [[ "$status" == "nicht installiert" || "$status" == "inactive" ]]; then
            if systemctl list-unit-files 2>/dev/null | grep -q "^${svc}.service"; then
                echo "  ✗ $svc: $status"
            fi
        else
            echo "  ? $svc: $status"
        fi
    fi
done

footer