#!/usr/bin/env bash
# Back up the EdgeTX SD card to ~/pocket-sd-backups/<timestamp>/.
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

require_cmd rsync

SD="$(detect_sd)"
STAMP="$(date +%Y-%m-%d_%H%M%S)"
DEST="$BACKUP_DIR/pocket-sd-$STAMP"

mkdir -p "$BACKUP_DIR"
log_info "Backing up $SD -> $DEST"
rsync -a --delete "$SD" "$DEST/"
log_ok "Backup complete: $DEST"

# Keep only the 10 most recent backups
ls -1dt "$BACKUP_DIR"/pocket-sd-* 2>/dev/null | tail -n +11 | xargs -r rm -rf
log_info "Backups stored in $BACKUP_DIR (10 kept)"
