#!/bin/bash

# Proxmox Temperatur-Auslese via sysfs (keine Third-Party-Tools)
# Funktioniert auf den meisten Intel/AMD-Systemen mit Kernel-Support

echo "=== Proxmox Hardware Temperaturen ==="
echo "Zeit: $(date '+%Y-%m-%d %H:%M:%S')"

# 1. CPU Paket-Temperatur finden (x86_pkg_temp oder acpitz)
echo -e "\n**CPU Temperaturen:**"
for zone in /sys/class/thermal/thermal_zone*; do
    type_file="$zone/type"
    temp_file="$zone/temp"
    
    if [ -f "$type_file" ] && [ -f "$temp_file" ]; then
        temp_raw=$(cat "$temp_file" 2>/dev/null)
        temp_type=$(cat "$type_file" 2>/dev/null)
        
        if [ -n "$temp_raw" ] && (( temp_raw > 0 )); then
            temp_c=$((temp_raw / 1000))
            echo "  $temp_type: ${temp_c}°C"
        fi
    fi
done

# 2. Core-Temperaturen via hwmon (falls vorhanden)
echo -e "\n**CPU Cores (hwmon):**"
hwmon_count=0
for hwmon in /sys/class/hwmon/hwmon*/; do
    name_file="$hwmon/name"
    if [ -f "$name_file" ] && grep -qi "coretemp\|k10temp" "$name_file" 2>/dev/null; then
        hwmon_count=$((hwmon_count + 1))
        echo "  Coretemp-$hwmon_count:"
        for temp_input in "$hwmon"temp*_input; do
            if [ -f "$temp_input" ]; then
                temp_raw=$(cat "$temp_input" 2>/dev/null)
                if [ -n "$temp_raw" ] && (( temp_raw > 0 )); then
                    temp_c=$((temp_raw / 1000))
                    label=$(basename "$temp_input" | sed 's/temp.*_input/input/')
                    echo "    $label: ${temp_c}°C"
                fi
            fi
        done
    fi
done

# 3. NVMe/SSD Temperaturen (falls vorhanden)
echo -e "\n**Speicher Temperaturen:**"
nvme_list=$(ls /sys/class/nvme/*/device/hwmon*/ 2>/dev/null | head -5)
if [ -n "$nvme_list" ]; then
    for nvme_temp in $nvme_list/temp1_input; do
        if [ -f "$nvme_temp" ]; then
            temp_raw=$(cat "$nvme_temp" 2>/dev/null)
            if [ -n "$temp_raw" ] && (( temp_raw > 1000 )); then
                temp_c=$((temp_raw / 1000))
                nvme_dev=$(echo "$nvme_temp" | sed 's|/device/hwmon.*/temp1_input||; s|/sys/class/nvme/||; s|/||g')
                echo "  NVMe $nvme_dev: ${temp_c}°C"
            fi
        fi
    done
else
    echo "  Keine NVMe-Sensoren gefunden"
fi

echo -e "\n=== Ende ==="
