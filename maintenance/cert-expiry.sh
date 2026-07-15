#!/bin/bash
# SSL-Zertifikat-Ablauf für PVE API/Webinterface

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

WARN_DAYS="${1:-30}"

require_pve
header "SSL-Zertifikat Ablauf"

check_cert() {
    local file=$1
    local label=$2
    if [[ ! -f "$file" ]]; then
        echo "  $label: Datei nicht gefunden ($file)"
        return
    fi
    expiry=$(openssl x509 -enddate -noout -in "$file" 2>/dev/null | cut -d= -f2)
    if [[ -z "$expiry" ]]; then
        echo "  $label: Konnte nicht gelesen werden"
        return
    fi
    expiry_epoch=$(date -d "$expiry" +%s 2>/dev/null)
    now_epoch=$(date +%s)
    days_left=$(( (expiry_epoch - now_epoch) / 86400 ))

    if (( days_left < WARN_DAYS )); then
        echo "  ⚠ $label: läuft ab in $days_left Tagen ($expiry)"
    else
        echo "  ✓ $label: gültig noch $days_left Tage ($expiry)"
    fi
}

check_cert "/etc/pve/local/pve-ssl.pem" "PVE API/Web (pve-ssl.pem)"
check_cert "/etc/pve/pve-root-ca.pem" "PVE Root CA"

echo
echo "**ACME (Let's Encrypt):**"
if [[ -d /etc/pve/nodes/$(hostname -s)/priv ]]; then
    ls /etc/live/ 2>/dev/null | sed 's/^/  /' || echo "  Keine ACME-Zertifikate"
    pvenode acme cert list 2>/dev/null | sed 's/^/  /' || true
else
    echo "  ACME nicht konfiguriert"
fi

footer