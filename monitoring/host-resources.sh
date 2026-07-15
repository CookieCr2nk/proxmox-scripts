#!/bin/bash
# CPU, RAM, Load und Swap-Übersicht

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "Host-Ressourcen"

echo "**CPU:**"
lscpu 2>/dev/null | grep -E 'Model name|CPU\(s\)|Thread|Core|Socket' | sed 's/^/  /' || nproc
echo

echo "**Load Average:**"
awk '{print "  1m: "$1"  5m: "$2"  15m: "$3}' /proc/loadavg
echo

echo "**Speicher:**"
free -h | sed 's/^/  /'
echo

echo "**Top 5 Prozesse nach RAM:**"
ps aux --sort=-%mem 2>/dev/null | head -6 | sed 's/^/  /' || ps -eo pid,user,%mem,rss,comm --sort=-%mem | head -6 | sed 's/^/  /'
echo

echo "**KSM (Memory Deduplication):**"
if [[ -f /sys/kernel/mm/ksm/pages_shared ]]; then
    shared=$(cat /sys/kernel/mm/ksm/pages_shared)
    shared_mb=$((shared * 4096 / 1048576))
    echo "  Geteilte Seiten: $shared (${shared_mb} MiB eingespart)"
else
    echo "  KSM nicht verfügbar"
fi

footer