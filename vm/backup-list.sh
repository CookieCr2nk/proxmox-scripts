#!/bin/bash
# Liste der letzten Backups pro VM/CT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

DAYS="${1:-7}"

require_pve
header "Backups (letzte $DAYS Tage)"

echo "**Backup-Jobs (vzdump):**"
if [[ -d /var/log/vzdump ]]; then
    find /var/log/vzdump -name '*.log' -mtime "-$DAYS" 2>/dev/null | sort -r | while read -r log; do
        result=$(grep -E 'TASK OK|TASK ERROR|Finished' "$log" 2>/dev/null | tail -1)
        echo "  $(basename "$log"): $result"
    done
else
    echo "  Kein vzdump-Log-Verzeichnis"
fi
echo

echo "**Backup-Dateien (neueste 20):**"
find /var/lib/vz/dump -type f \( -name '*.vma*' -o -name '*.tar*' \) -mtime "-$DAYS" 2>/dev/null | \
    xargs -r ls -lht 2>/dev/null | head -20 | awk '{print "  "$6" "$7" "$8" "$5" "$9}' || \
    echo "  Keine Backups gefunden"

footer