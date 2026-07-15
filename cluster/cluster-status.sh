#!/bin/bash
# Cluster-Gesundheit und Node-Status

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "Cluster-Status"

if ! is_cluster; then
    echo "  Dieser Node ist kein Cluster-Mitglied (Standalone)."
    footer
    exit 0
fi

echo "**Corosync Status:**"
pvecm status 2>/dev/null | sed 's/^/  /'
echo

echo "**Cluster-Nodes:**"
pvecm nodes 2>/dev/null | sed 's/^/  /' || pvesh get /cluster/resources --type node 2>/dev/null | sed 's/^/  /'
echo

echo "**Expected Votes / Quorum:**"
corosync-quorumtool -s 2>/dev/null | sed 's/^/  /' || true
echo

echo "**Cluster-Config Version:**"
pvecm status 2>/dev/null | grep -E 'Config version|Node name' | sed 's/^/  /'

footer