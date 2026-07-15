#!/bin/bash
# Schneller Gesundheitscheck – führt mehrere Diagnose-Skripte aus

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/common.sh
source "$REPO_DIR/lib/common.sh"

require_pve
header "Proxmox Gesundheitscheck"

run_check() {
    local script=$1
    local label=$2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "▶ $label"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ -x "$script" ]]; then
        "$script" 2>&1 | sed 's/^/  /'
    elif [[ -f "$script" ]]; then
        bash "$script" 2>&1 | sed 's/^/  /'
    else
        echo "  Skript nicht gefunden: $script"
    fi
    echo
}

run_check "$REPO_DIR/monitoring/node-info.sh"       "Node-Info"
run_check "$REPO_DIR/monitoring/host-resources.sh" "Ressourcen"
run_check "$REPO_DIR/storage/storage-status.sh"    "Storage"
run_check "$REPO_DIR/vm/vm-status.sh"              "VM/CT Status"
run_check "$REPO_DIR/storage/zfs-health.sh"        "ZFS Health"
run_check "$REPO_DIR/maintenance/cert-expiry.sh"   "Zertifikate"

if is_cluster; then
    run_check "$REPO_DIR/cluster/cluster-status.sh" "Cluster"
fi

echo "Gesundheitscheck abgeschlossen."
footer