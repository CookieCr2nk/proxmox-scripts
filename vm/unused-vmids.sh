#!/bin/bash
# Zeigt freie VMIDs im konfigurierten Bereich

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

START="${1:-100}"
END="${2:-999}"

require_pve
header "Freie VMIDs ($START–$END)"

declare -A USED
for conf in /etc/pve/qemu-server/*.conf /etc/pve/lxc/*.conf; do
    [[ -f "$conf" ]] || continue
    id=$(basename "$conf" .conf)
    USED[$id]=1
done

free_list=()
for ((id=START; id<=END; id++)); do
    [[ -z "${USED[$id]}" ]] && free_list+=("$id")
done

echo "**Belegte VMIDs:** ${#USED[@]}"
echo "**Freie VMIDs:**    ${#free_list[@]}"
echo

if ((${#free_list[@]} > 0 && ${#free_list[@]} <= 50)); then
    echo "Freie IDs: ${free_list[*]}"
elif ((${#free_list[@]} > 50)); then
    echo "Erste 20 freie IDs: ${free_list[*]:0:20} ..."
    echo "Letzte 10 freie IDs: ${free_list[*]: -10}"
fi

footer