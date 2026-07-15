#!/bin/bash
# Prüft ob ein Neustart nach Kernel-/Library-Updates nötig ist

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "Neustart erforderlich?"

if [[ -f /var/run/reboot-required ]]; then
    echo "  ⚠ JA – Neustart erforderlich!"
    echo
    echo "  Grund:"
    cat /var/run/reboot-required.pkgs 2>/dev/null | sed 's/^/    /' || \
        cat /var/run/reboot-required 2>/dev/null | sed 's/^/    /'
else
    echo "  ✓ Kein Neustart erforderlich"
fi
echo

running=$(($(qm list 2>/dev/null | grep -c running || echo 0) + $(pct list 2>/dev/null | grep -c running || echo 0)))
echo "**Laufende VMs/CTs:** $running"
echo "**Aktueller Kernel:** $(uname -r)"
if [[ -d /boot ]]; then
    latest_kernel=$(ls -1 /boot/vmlinuz-* 2>/dev/null | sort -V | tail -1 | sed 's|/boot/vmlinuz-||')
    echo "**Neuester installierter Kernel:** ${latest_kernel:-unbekannt}"
    if [[ -n "$latest_kernel" && "$(uname -r)" != "$latest_kernel" ]]; then
        echo "  ⚠ Neuerer Kernel installiert, aber noch nicht gebootet"
    fi
fi

footer