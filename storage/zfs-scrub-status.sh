#!/bin/bash
# ZFS Scrub-Status und Empfehlungen

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "ZFS Scrub-Status"

if ! command -v zpool &>/dev/null; then
    echo "  ZFS nicht verfügbar."
    footer
    exit 0
fi

for pool in $(zpool list -H -o name 2>/dev/null); do
    echo "**Pool: $pool**"
    scrub_line=$(zpool status "$pool" 2>/dev/null | grep -E 'scan:|scrub' | head -1)
    echo "  $scrub_line"

    last_scrub=$(zpool status "$pool" 2>/dev/null | grep 'scan:' | sed 's/.*scan: //')
    if echo "$last_scrub" | grep -q 'none'; then
        echo "  ⚠ Empfehlung: Noch kein Scrub durchgeführt → zpool scrub $pool"
    elif echo "$last_scrub" | grep -q 'in progress'; then
        echo "  → Scrub läuft gerade"
    else
        echo "  ✓ Letzter Scrub abgeschlossen"
    fi
    echo
done

echo "**Scrub starten (manuell):**"
echo "  zpool scrub <poolname>"
echo "  Cron-Beispiel: 0 2 * * 0 root zpool scrub rpool"

footer