#!/bin/bash
# Alle Snapshots pro VM/CT auflisten

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

VMID="${1:-}"

require_pve
header "Snapshot-Übersicht"

list_vm_snapshots() {
    local id=$1
    local name
    name=$(qm config "$id" 2>/dev/null | grep '^name:' | awk '{print $2}' || \
           pct config "$id" 2>/dev/null | grep '^hostname:' | awk '{print $2}' || echo "unknown")

    if qm config "$id" &>/dev/null; then
        snaps=$(qm listsnapshot "$id" 2>/dev/null | tail -n +2)
        if [[ -n "$snaps" ]]; then
            echo "**VM $id ($name):**"
            echo "$snaps" | sed 's/^/  /'
            echo
        fi
    elif pct config "$id" &>/dev/null; then
        snaps=$(pct listsnapshot "$id" 2>/dev/null | tail -n +2)
        if [[ -n "$snaps" ]]; then
            echo "**CT $id ($name):**"
            echo "$snaps" | sed 's/^/  /'
            echo
        fi
    fi
}

if [[ -n "$VMID" ]]; then
    list_vm_snapshots "$VMID"
else
    total=0
    for conf in /etc/pve/qemu-server/*.conf; do
        [[ -f "$conf" ]] || continue
        id=$(basename "$conf" .conf)
        if qm listsnapshot "$id" 2>/dev/null | tail -n +2 | grep -q .; then
            list_vm_snapshots "$id"
            total=$((total + 1))
        fi
    done
    for conf in /etc/pve/lxc/*.conf; do
        [[ -f "$conf" ]] || continue
        id=$(basename "$conf" .conf)
        if pct listsnapshot "$id" 2>/dev/null | tail -n +2 | grep -q .; then
            list_vm_snapshots "$id"
            total=$((total + 1))
        fi
    done
    if (( total == 0 )); then
        echo "  Keine Snapshots gefunden."
    fi
fi

echo "**Nutzung:** $0 [VMID]  – optional nur eine VM/CT anzeigen"
footer