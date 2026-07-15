#!/bin/bash
# Festplattenbelegung: Host und VM-Disk-Pfade

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "Festplattenbelegung"

echo "**Host-Dateisysteme:**"
df -hT -x tmpfs -x devtmpfs 2>/dev/null | sed 's/^/  /'
echo

echo "**Größte Verzeichnisse unter /var/lib/vz:**"
if [[ -d /var/lib/vz ]]; then
    du -h --max-depth=1 /var/lib/vz 2>/dev/null | sort -hr | head -10 | sed 's/^/  /'
else
    echo "  /var/lib/vz nicht vorhanden"
fi
echo

echo "**VM/CT Images (größte 15):**"
find /var/lib/vz/images / -path '*/images/*' -name '*.raw' -o -name '*.qcow2' -o -name '*.vmdk' 2>/dev/null | \
    xargs -r du -h 2>/dev/null | sort -hr | head -15 | sed 's/^/  /' || \
    find /var/lib/vz -type f \( -name '*.raw' -o -name '*.qcow2' \) -exec du -h {} + 2>/dev/null | sort -hr | head -15 | sed 's/^/  /'

footer