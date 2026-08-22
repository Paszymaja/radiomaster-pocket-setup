#!/usr/bin/env bash
# Apply config/settings.env to RADIO/radio.yml and create/set the FPV Sim model.
# Idempotent. The SD card must be mounted (USB Storage mode).
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

require_cmd python3

SD="$(detect_sd)"
SETTINGS="$REPO_ROOT/config/settings.env"

[ -f "$SETTINGS" ] || die "Missing $SETTINGS"

log_info "Applying settings from $SETTINGS to $SD"
python3 "$REPO_ROOT/scripts/lib/configure.py" "$SETTINGS" "$SD"

log_ok "Configuration applied. Safely eject the SD card and power on the radio."
