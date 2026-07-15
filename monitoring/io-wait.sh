#!/bin/bash
# I/O-Wartezeit und Disk-Aktivität

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

INTERVAL="${1:-2}"
SAMPLES="${2:-5}"

require_pve
header "I/O-Monitoring (${SAMPLES}x alle ${INTERVAL}s)"

echo "**Aktuelle iostat (falls verfügbar):**"
if command -v iostat &>/dev/null; then
    iostat -xz 1 1 2>/dev/null | sed 's/^/  /'
else
    echo "  iostat nicht installiert (apt install sysstat)"
fi
echo

echo "**CPU I/O-Wartezeit (%wa):**"
for ((i=1; i<=SAMPLES; i++)); do
    wa=$(grep 'cpu ' /proc/stat | awk '{printf "%.1f", ($6/($2+$3+$4+$5+$6+$7+$8))*100}')
    echo "  Sample $i: ${wa}% I/O-Wartezeit"
    sleep "$INTERVAL"
done
echo

echo "**Top 5 Prozesse nach I/O (falls iotop verfügbar):**"
if command -v iotop &>/dev/null; then
    iotop -b -o -n 1 2>/dev/null | head -12 | sed 's/^/  /'
else
    echo "  iotop nicht installiert (apt install iotop)"
fi

footer