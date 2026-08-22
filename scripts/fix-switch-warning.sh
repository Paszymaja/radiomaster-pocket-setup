#!/usr/bin/env bash
# Fix the switch-warning migration bug (SE button warning) in all models.
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

require_cmd python3

SD="$(detect_sd)"
python3 "$REPO_ROOT/scripts/lib/fix_switch_warning.py" "$SD/MODELS"
log_ok "Done. Safely eject the SD card and power on the radio."
