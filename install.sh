#!/bin/bash
# Setzt Ausführungsrechte für alle Skripte

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setze Ausführungsrechte in $REPO_DIR ..."
find "$REPO_DIR" -type f -name '*.sh' ! -path '*/.git/*' -exec chmod +x {} \;

count=$(find "$REPO_DIR" -type f -name '*.sh' ! -path '*/.git/*' | wc -l)
echo "Fertig: $count Skripte ausführbar gemacht."
echo
echo "Optional: Symlinks nach /usr/local/sbin/"
echo "  ln -sf $REPO_DIR/maintenance/health-check.sh /usr/local/sbin/pve-health-check"