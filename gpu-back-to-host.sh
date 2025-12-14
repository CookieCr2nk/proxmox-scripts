#!/bin/bash
set -e

GPU_DEV="0000:00:02.0"

# 1) VM muss aus sein, sonst bringt das nichts
if pvesh get /cluster/resources --type vm | grep -q "running"; then
  echo "Warnung: Es laufen noch VMs, bitte GPU-VM stoppen."
fi

echo "Unbind von vfio-pci..."
if [ -e "/sys/bus/pci/drivers/vfio-pci/$GPU_DEV" ]; then
  echo "$GPU_DEV" > /sys/bus/pci/drivers/vfio-pci/unbind
fi

# Optional: ID aus vfio entfernen (falls du sie per options vfio-pci ids=... hinzugefügt hast)
VENDOR=$(cat /sys/bus/pci/devices/$GPU_DEV/vendor)
DEVICE=$(cat /sys/bus/pci/devices/$GPU_DEV/device)
echo "$VENDOR $DEVICE" > /sys/bus/pci/drivers/vfio-pci/remove_id || true

echo "i915 laden (falls nicht geladen)..."
modprobe i915 || true

echo "GPU an i915 binden..."
echo "$GPU_DEV" > /sys/bus/pci/drivers/i915/bind

echo "Fertig – iGPU sollte wieder für die Host-Konsole verfügbar sein."
