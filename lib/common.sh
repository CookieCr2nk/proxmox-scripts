#!/bin/bash
# Gemeinsame Hilfsfunktionen für proxmox-scripts

require_pve() {
    if [[ ! -f /etc/pve/.version ]]; then
        echo "Fehler: Dieses Skript muss auf einem Proxmox VE Host ausgeführt werden." >&2
        exit 1
    fi
}

header() {
    echo "=== $1 ==="
    echo "Zeit: $(date '+%Y-%m-%d %H:%M:%S')"
    echo
}

footer() {
    echo
    echo "=== Ende ==="
}

human_bytes() {
    local bytes=$1
    if (( bytes >= 1099511627776 )); then
        printf "%.2f TiB" "$(echo "scale=2; $bytes / 1099511627776" | bc)"
    elif (( bytes >= 1073741824 )); then
        printf "%.2f GiB" "$(echo "scale=2; $bytes / 1073741824" | bc)"
    elif (( bytes >= 1048576 )); then
        printf "%.2f MiB" "$(echo "scale=2; $bytes / 1048576" | bc)"
    else
        printf "%d B" "$bytes"
    fi
}

pve_node_name() {
    hostname -s
}

is_cluster() {
    [[ -f /etc/pve/corosync.conf ]]
}

script_dir() {
    cd "$(dirname "${BASH_SOURCE[1]}")" && pwd
}

load_common() {
    local dir
    dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    # shellcheck source=lib/common.sh
    source "$dir/../lib/common.sh" 2>/dev/null || source "$dir/lib/common.sh" 2>/dev/null || true
}