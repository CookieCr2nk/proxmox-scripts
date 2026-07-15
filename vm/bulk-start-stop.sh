#!/bin/bash
# Mehrere VMs/CTs starten oder stoppen (mit Bestätigung)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

ACTION="${1:-}"
shift || true
IDS=("$@")

usage() {
    echo "Nutzung: $0 <start|stop|shutdown> <VMID> [VMID ...]"
    echo "Beispiel: $0 shutdown 100 101 102"
    exit 1
}

[[ -n "$ACTION" && ${#IDS[@]} -gt 0 ]] || usage
require_pve

header "Bulk $ACTION"

echo "Folgende VMs/CTs werden bearbeitet: ${IDS[*]}"
read -r -p "Fortfahren? [j/N] " confirm
[[ "$confirm" =~ ^[jJyY] ]] || { echo "Abgebrochen."; exit 0; }

for id in "${IDS[@]}"; do
    if [[ -f "/etc/pve/qemu-server/${id}.conf" ]]; then
        case "$ACTION" in
            start)   qm start "$id" && echo "  VM $id gestartet" ;;
            stop)    qm stop "$id" && echo "  VM $id gestoppt" ;;
            shutdown) qm shutdown "$id" && echo "  VM $id Shutdown gesendet" ;;
        esac
    elif [[ -f "/etc/pve/lxc/${id}.conf" ]]; then
        case "$ACTION" in
            start)   pct start "$id" && echo "  CT $id gestartet" ;;
            stop)    pct stop "$id" && echo "  CT $id gestoppt" ;;
            shutdown) pct shutdown "$id" && echo "  CT $id Shutdown gesendet" ;;
        esac
    else
        echo "  VMID $id nicht gefunden"
    fi
done

footer