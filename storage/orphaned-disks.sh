#!/bin/bash
# Findet Disk-Dateien ohne zugehörige VM/CT-Konfiguration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "Verwaiste Disk-Dateien"

echo "Suche nach Images, die in keiner VM/CT-Konfiguration referenziert sind..."
echo

orphan_count=0
while IFS= read -r img; do
    [[ -f "$img" ]] || continue
    basename_img=$(basename "$img")
    found=0

    for conf in /etc/pve/qemu-server/*.conf /etc/pve/lxc/*.conf; do
        [[ -f "$conf" ]] || continue
        if grep -qF "$basename_img" "$conf" 2>/dev/null || grep -qF "$img" "$conf" 2>/dev/null; then
            found=1
            break
        fi
    done

    if (( found == 0 )); then
        size=$(du -h "$img" 2>/dev/null | cut -f1)
        echo "  ⚠ $img ($size)"
        orphan_count=$((orphan_count + 1))
    fi
done < <(find /var/lib/vz/images -type f \( -name '*.raw' -o -name '*.qcow2' -o -name '*.vmdk' \) 2>/dev/null)

if (( orphan_count == 0 )); then
    echo "  Keine verwaisten Disks gefunden."
else
    echo
    echo "  Gefunden: $orphan_count Datei(en) – bitte manuell prüfen vor dem Löschen!"
fi

footer