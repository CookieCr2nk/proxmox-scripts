#!/bin/bash
# Detaillierte Ressourcennutzung pro VM/CT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_pve
header "VM/CT Ressourcen"

printf "  %-6s %-20s %-10s %8s %10s %10s\n" "VMID" "NAME" "STATUS" "CPU%" "MEM used" "MAXMEM"
printf "  %s\n" "----------------------------------------------------------------------"

pvesh get /cluster/resources --type vm 2>/dev/null | \
    python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
except:
    sys.exit(0)
for r in sorted(data, key=lambda x: x.get('vmid', 0)):
    vmid = r.get('vmid', '-')
    name = (r.get('name') or '-')[:20]
    status = r.get('status', '-')
    cpu = r.get('cpu', 0)
    mem = r.get('mem', 0)
    maxmem = r.get('maxmem', 0)
    def fmt(b):
        if b >= 1073741824: return f'{b/1073741824:.1f}G'
        if b >= 1048576: return f'{b/1048576:.0f}M'
        return f'{b}B'
    print(f'  {vmid:<6} {name:<20} {status:<10} {cpu*100:7.1f}% {fmt(mem):>10} {fmt(maxmem):>10}')
" 2>/dev/null || \
    pvesh get /cluster/resources --type vm --output-format text 2>/dev/null | sed 's/^/  /'

footer