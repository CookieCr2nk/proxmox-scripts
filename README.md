# Proxmox Scripts

Sammlung nützlicher Bash-Skripte für den Betrieb und die Wartung einer **Proxmox VE** Umgebung.

Alle Skripte sind für die Ausführung **direkt auf dem Proxmox Host** gedacht (nicht in VMs). Die meisten nutzen native PVE-Tools (`pvesh`, `qm`, `pct`, `pvesm`, …) und benötigen keine zusätzlichen Abhängigkeiten.

## Schnellstart

```bash
git clone <repo-url> /opt/proxmox-scripts
cd /opt/proxmox-scripts
./install.sh
```

Einzelnes Skript ausführen:

```bash
./monitoring/node-info.sh
./maintenance/health-check.sh
```

## Verzeichnisstruktur

```
proxmox-scripts/
├── lib/common.sh          # Gemeinsame Hilfsfunktionen
├── install.sh             # Ausführungsrechte setzen
├── host-temp.sh           # Hardware-Temperaturen (sysfs)
├── gpu-back-to-host.sh    # iGPU von VFIO zurück an Host binden
├── monitoring/            # Überwachung & Diagnose
├── storage/               # Storage, ZFS, LVM, Disks
├── vm/                    # VMs, Container, Backups
├── maintenance/           # Updates, Zertifikate, Bereinigung
└── cluster/               # Cluster, HA, Ceph, Replikation
```

## Skript-Übersicht

### Monitoring

| Skript | Beschreibung |
|--------|--------------|
| `monitoring/node-info.sh` | Hostname, PVE-Version, Kernel, Uptime, Cluster-Info |
| `monitoring/host-resources.sh` | CPU, Load, RAM, Swap, Top-Prozesse, KSM |
| `monitoring/network-info.sh` | Interfaces, Bridges, Routing, DNS, Firewall |
| `monitoring/log-errors.sh` | Letzte Syslog-Fehler und fehlgeschlagene PVE-Tasks |
| `monitoring/io-wait.sh` | I/O-Wartezeit und Disk-Aktivität |
| `monitoring/pve-services.sh` | Status wichtiger PVE-Dienste (pveproxy, corosync, …) |
| `host-temp.sh` | CPU-, Core- und NVMe-Temperaturen via sysfs |

### Storage

| Skript | Beschreibung |
|--------|--------------|
| `storage/storage-status.sh` | Alle konfigurierten Storages und Belegung |
| `storage/zfs-health.sh` | ZFS Pool-Status, Kapazität und Fehler |
| `storage/zfs-scrub-status.sh` | Scrub-Status und Empfehlungen |
| `storage/disk-usage.sh` | Dateisysteme und größte VM-Images |
| `storage/smart-disk-check.sh` | SMART-Gesundheit aller Festplatten |
| `storage/orphaned-disks.sh` | Disk-Dateien ohne VM/CT-Referenz finden |
| `storage/lvm-thin-status.sh` | LVM Thin Pool Auslastung (Warnung ab 80 %) |

### VM & Container

| Skript | Beschreibung |
|--------|--------------|
| `vm/vm-status.sh` | Übersicht aller VMs und CTs mit Status |
| `vm/vm-resources.sh` | CPU- und RAM-Nutzung pro VM/CT |
| `vm/snapshot-list.sh` | Alle Snapshots auflisten (`[VMID]` optional) |
| `vm/guest-agent-check.sh` | QEMU Guest Agent Erreichbarkeit |
| `vm/backup-list.sh` | Letzte vzdump-Backups (`[TAGE]`, Standard: 7) |
| `vm/bulk-start-stop.sh` | Mehrere VMs/CTs starten/stoppen/shutdown |
| `vm/unused-vmids.sh` | Freie VMIDs in einem Bereich finden |

### Maintenance

| Skript | Beschreibung |
|--------|--------------|
| `maintenance/health-check.sh` | Kombinierter Schnellcheck (empfohlen für Cron) |
| `maintenance/apt-update-check.sh` | Verfügbare Updates anzeigen (ohne Installation) |
| `maintenance/pve-update.sh` | Interaktives `apt dist-upgrade` mit Vorab-Checks |
| `maintenance/subscription-check.sh` | Subscription- und Repo-Status |
| `maintenance/cert-expiry.sh` | SSL-Zertifikat-Ablauf prüfen (`[WARN_TAGE]`) |
| `maintenance/cleanup-snapshots.sh` | Alte Snapshots bereinigen (Dry-Run Standard) |
| `maintenance/scheduled-tasks.sh` | Backup-Jobs, Cron und Systemd-Timer |
| `maintenance/reboot-required.sh` | Prüft ob Neustart nach Updates nötig ist |

### Cluster

| Skript | Beschreibung |
|--------|--------------|
| `cluster/cluster-status.sh` | Corosync, Quorum, Nodes |
| `cluster/ha-status.sh` | High Availability Manager und Ressourcen |
| `cluster/replication-status.sh` | ZFS- und PVE-Replikation |
| `cluster/ceph-status.sh` | Ceph Health, OSDs und Pools |

### Hardware / GPU

| Skript | Beschreibung |
|--------|--------------|
| `gpu-back-to-host.sh` | Intel iGPU von vfio-pci zurück an i915-Treiber binden |

## Empfohlene Cron-Jobs

```cron
# Täglicher Gesundheitscheck um 6:00
0 6 * * * /opt/proxmox-scripts/maintenance/health-check.sh >> /var/log/pve-health.log 2>&1

# Wöchentlicher ZFS Scrub (Sonntag 2:00) – Poolname anpassen
0 2 * * 0 root zpool scrub rpool

# Monatliche SMART-Prüfung
0 3 1 * * /opt/proxmox-scripts/storage/smart-disk-check.sh >> /var/log/smart-check.log 2>&1

# Zertifikat-Warnung alle 2 Wochen
0 8 1,15 * * /opt/proxmox-scripts/maintenance/cert-expiry.sh 30
```

## Optionale Pakete

Einige Skripte nutzen zusätzliche Tools, falls installiert:

| Paket | Skript | Installation |
|-------|--------|--------------|
| `smartmontools` | `smart-disk-check.sh` | `apt install smartmontools` |
| `sysstat` | `io-wait.sh` | `apt install sysstat` |
| `iotop` | `io-wait.sh` | `apt install iotop` |

## Hinweise & Sicherheit

- **Schreibende Skripte** (`pve-update.sh`, `cleanup-snapshots.sh`, `bulk-start-stop.sh`) fragen vor destruktiven Aktionen nach Bestätigung.
- `cleanup-snapshots.sh` läuft standardmäßig im **Dry-Run** – erst mit `--execute` werden Snapshots gelöscht.
- `orphaned-disks.sh` listet nur verdächtige Dateien – **niemals blind löschen**.
- `gpu-back-to-host.sh` erfordert, dass die GPU-VM gestoppt ist.
- Cluster-Skripte geben auf Standalone-Nodes einen Hinweis aus und beenden sich sauber.

## Symlinks (optional)

```bash
ln -sf /opt/proxmox-scripts/maintenance/health-check.sh /usr/local/sbin/pve-health-check
ln -sf /opt/proxmox-scripts/vm/vm-status.sh /usr/local/sbin/pve-vm-status
ln -sf /opt/proxmox-scripts/storage/zfs-health.sh /usr/local/sbin/pve-zfs-health
```

## Lizenz

Frei verwendbar – ohne Garantie. Vor produktivem Einsatz in einer Testumgebung prüfen.