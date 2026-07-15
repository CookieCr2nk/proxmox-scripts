#!/bin/bash
# ZFS Pool-Gesundheit und Kapazität

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "ZFS Pool-Gesundheit"

if ! command -v zpool &>/dev/null; then
    echo "  ZFS nicht installiert oder nicht verfügbar."
    footer
    exit 0
fi

echo "**Pool-Status:**"
zpool status 2>/dev/null | sed 's/^/  /' || echo "  Keine ZFS Pools"
echo

echo "**Pool-Kapazität:**"
zpool list 2>/dev/null | sed 's/^/  /' || true
echo

echo "**ZFS Fehler (zpool status -v):**"
for pool in $(zpool list -H -o name 2>/dev/null); do
    errors=$(zpool status "$pool" 2>/dev/null | grep -cE 'state: ONLINE|errors:' || true)
    state=$(zpool list -H -o health "$pool" 2>/dev/null)
    echo "  $pool: $state"
    zpool status "$pool" 2>/dev/null | grep -A2 'errors:' | sed 's/^/    /' || true
done

footer