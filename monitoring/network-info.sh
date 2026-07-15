#!/bin/bash
# Netzwerk-Interfaces, Bridges und Routing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "Netzwerk-Übersicht"

echo "**Interfaces (IP-Adressen):**"
ip -br addr 2>/dev/null | sed 's/^/  /' || ifconfig -a 2>/dev/null | grep -E 'inet |flags' | sed 's/^/  /'
echo

echo "**Bridges:**"
if command -v brctl &>/dev/null; then
    brctl show 2>/dev/null | sed 's/^/  /' || echo "  Keine Bridges"
else
    bridge link show 2>/dev/null | sed 's/^/  /' || echo "  bridge-utils nicht installiert"
fi
echo

echo "**Standard-Route:**"
ip route show default 2>/dev/null | sed 's/^/  /' || route -n 2>/dev/null | grep '^0.0.0.0' | sed 's/^/  /'
echo

echo "**DNS (resolv.conf):**"
grep -v '^#' /etc/resolv.conf 2>/dev/null | grep -v '^$' | sed 's/^/  /' || echo "  Nicht verfügbar"
echo

echo "**Firewall (pve-firewall):**"
if command -v pve-firewall &>/dev/null; then
    pve-firewall status 2>/dev/null | sed 's/^/  /' || echo "  Status nicht abrufbar"
else
    echo "  pve-firewall nicht verfügbar"
fi

footer