#!/bin/bash
# Letzte Fehler in Syslog und PVE-Logs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

LINES="${1:-50}"

require_pve
header "Letzte Fehler (letzte $LINES Zeilen)"

echo "**Syslog (error/warning):**"
journalctl -p warning..err --no-pager -n "$LINES" 2>/dev/null | sed 's/^/  /' || \
    grep -iE 'error|warn|fail|critical' /var/log/syslog 2>/dev/null | tail -n "$LINES" | sed 's/^/  /' || \
    echo "  Keine Logs verfügbar"
echo

echo "**PVE Tasks (fehlgeschlagen):**"
if [[ -d /var/log/pve/tasks ]]; then
    find /var/log/pve/tasks -type f -name '*.log' -mtime -7 2>/dev/null | while read -r f; do
        if grep -qiE 'TASK ERROR|failed|error' "$f" 2>/dev/null; then
            echo "  --- $(basename "$f") ---"
            grep -iE 'TASK ERROR|error|failed' "$f" 2>/dev/null | tail -5 | sed 's/^/    /'
        fi
    done
    echo "  (nur Tasks der letzten 7 Tage)"
else
    echo "  Kein Task-Log-Verzeichnis"
fi
echo

echo "**Corosync (falls Cluster):**"
if is_cluster && [[ -f /var/log/corosync/corosync.log ]]; then
    grep -iE 'error|warn|fail' /var/log/corosync/corosync.log 2>/dev/null | tail -10 | sed 's/^/  /' || echo "  Keine Fehler"
else
    echo "  Nicht relevant (kein Cluster)"
fi

footer