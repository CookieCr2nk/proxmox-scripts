#!/bin/bash
# Prüft QEMU Guest Agent Status pro VM

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "QEMU Guest Agent Check"

printf "  %-6s %-25s %-10s %-15s\n" "VMID" "NAME" "STATUS" "GUEST-AGENT"
printf "  %s\n" "----------------------------------------------------------------"

for conf in /etc/pve/qemu-server/*.conf; do
    [[ -f "$conf" ]] || continue
    id=$(basename "$conf" .conf)
    name=$(grep '^name:' "$conf" 2>/dev/null | awk '{print $2}' || echo "-")
    status=$(qm status "$id" 2>/dev/null | awk '{print $2}' || echo "unknown")

    agent="nicht konfiguriert"
    if grep -q 'agent: 1' "$conf" 2>/dev/null; then
        if [[ "$status" == "running" ]]; then
            if qm agent "$id" ping &>/dev/null; then
                agent="✓ aktiv"
            else
                agent="✗ konfiguriert, nicht erreichbar"
            fi
        else
            agent="konfiguriert (VM gestoppt)"
        fi
    fi

    printf "  %-6s %-25s %-10s %-15s\n" "$id" "${name:0:25}" "$status" "$agent"
done

footer