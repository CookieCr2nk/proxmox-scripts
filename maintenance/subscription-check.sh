#!/bin/bash
# Proxmox Subscription-Status

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "Proxmox Subscription"

if command -v pveversion &>/dev/null; then
    pveversion 2>/dev/null | sed 's/^/  /'
    echo
fi

if [[ -f /etc/apt/sources.list.d/pve-enterprise.list ]]; then
    echo "**Enterprise Repo:** aktiviert"
else
    echo "**Enterprise Repo:** nicht konfiguriert (No-Subscription Repo aktiv?)"
fi
echo

pvesubscription get 2>/dev/null | sed 's/^/  /' || \
    cat /etc/pve/subscription 2>/dev/null | sed 's/^/  /' || \
    echo "  Kein Subscription-Key hinterlegt (Community/No-Subscription Modus)"

footer