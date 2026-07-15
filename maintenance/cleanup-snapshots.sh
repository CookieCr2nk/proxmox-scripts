#!/bin/bash
# Löscht alte VM-Snapshots (älter als X Tage), mit Dry-Run

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

DAYS="${1:-30}"
DRY_RUN="${2:---dry-run}"

require_pve
header "Snapshot-Bereinigung (älter als $DAYS Tage)"

if [[ "$DRY_RUN" == "--dry-run" ]]; then
    echo "Modus: DRY-RUN (keine Löschungen)"
else
    echo "Modus: LIVE – Snapshots werden gelöscht!"
    read -r -p "Wirklich fortfahren? [j/N] " confirm
    [[ "$confirm" =~ ^[jJyY] ]] || { echo "Abgebrochen."; exit 0; }
fi
echo

cutoff_epoch=$(date -d "$DAYS days ago" +%s 2>/dev/null || echo 0)

for conf in /etc/pve/qemu-server/*.conf; do
    [[ -f "$conf" ]] || continue
    id=$(basename "$conf" .conf)

    qm listsnapshot "$id" 2>/dev/null | tail -n +2 | while read -r snap_line; do
        snap_name=$(echo "$snap_line" | awk '{print $1}')
        [[ "$snap_name" == "current" || -z "$snap_name" ]] && continue

        snap_info=$(qm listsnapshot "$id" --snapshot "$snap_name" 2>/dev/null)
        snap_date=$(echo "$snap_info" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
        if [[ -n "$snap_date" ]]; then
            snap_epoch=$(date -d "$snap_date" +%s 2>/dev/null || echo 9999999999)
            if (( snap_epoch < cutoff_epoch )); then
                echo "  VM $id: Snapshot '$snap_name' vom $snap_date"
                if [[ "$DRY_RUN" != "--dry-run" ]]; then
                    qm delsnapshot "$id" "$snap_name" && echo "    → gelöscht"
                fi
            fi
        fi
    done
done

echo
echo "**Nutzung:** $0 [TAGE] [--execute]"
echo "  Standard: Dry-Run, 30 Tage"
footer