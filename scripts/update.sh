#!/usr/bin/env bash
# Orchestrator: check versions, then run the storage-mode updaters, then
# remind about the ELRS module (which needs USB Serial/VCP mode).
# Usage: update.sh [--sounds]
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

EXTRA=""
[ "${1:-}" = "--sounds" ] && EXTRA="--sounds"

"$REPO_ROOT/scripts/check-versions.sh"
echo

"$REPO_ROOT/scripts/update-edgetx.sh" $EXTRA
echo

"$REPO_ROOT/scripts/update-lua.sh"
echo

cat <<EOF
ELRS module (internal ExpressLRS) is updated separately because it needs the
radio in USB Serial (VCP) mode, not storage mode:
  ./scripts/update-elrs.sh
EOF
