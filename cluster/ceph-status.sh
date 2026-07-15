#!/bin/bash
# Ceph Cluster Status (falls Ceph installiert)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "Ceph Status"

if ! command -v ceph &>/dev/null; then
    echo "  Ceph nicht installiert oder nicht im PATH."
    footer
    exit 0
fi

echo "**Ceph Health:**"
ceph -s 2>/dev/null | sed 's/^/  /' || echo "  Ceph nicht erreichbar"
echo

echo "**OSD Status:**"
ceph osd stat 2>/dev/null | sed 's/^/  /' || true
echo

echo "**Pool-Nutzung:**"
ceph df 2>/dev/null | sed 's/^/  /' || true

footer