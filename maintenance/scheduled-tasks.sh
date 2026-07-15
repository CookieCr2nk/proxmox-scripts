#!/bin/bash
# Übersicht geplanter Backup- und Wartungsjobs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "Geplante Tasks"

echo "**Backup-Jobs (Datacenter):**"
if [[ -f /etc/pve/jobs.cfg ]]; then
    grep -A5 'vzdump' /etc/pve/jobs.cfg 2>/dev/null | sed 's/^/  /' || \
        cat /etc/pve/jobs.cfg 2>/dev/null | sed 's/^/  /'
else
    echo "  Keine jobs.cfg gefunden"
fi
echo

echo "**Cron (root):**"
crontab -l 2>/dev/null | grep -v '^#' | grep -v '^$' | sed 's/^/  /' || echo "  Kein Crontab"
echo

echo "**Systemd Timer:**"
systemctl list-timers --no-pager 2>/dev/null | head -15 | sed 's/^/  /'

footer