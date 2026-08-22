#!/usr/bin/env bash
# Report installed vs latest versions (EdgeTX, SD content, ExpressLRS).
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

require_cmd curl python3

SD="$(detect_sd)"
RADIO="$SD/RADIO/radio.yml"

# --- installed -------------------------------------------------------------
FW_INSTALLED="$(python3 -c "import sys;print(next((l.split(':')[1].strip() for l in open(sys.argv[1]) if l.startswith('semver:')), 'unknown'))" "$RADIO")"
SD_INSTALLED="$(cat "$SD/edgetx.sdcard.version" 2>/dev/null || echo 'unknown')"

# --- latest ----------------------------------------------------------------
log_info "Querying GitHub for latest versions..."
FW_LATEST="$(gh_latest_tag EdgeTX/edgetx | sed 's/^v//')"
SD_LATEST="$(gh_latest_tag EdgeTX/edgetx-sdcard | sed 's/^v//')"
ELRS_LATEST="$(gh_latest_tag ExpressLRS/ExpressLRS | sed 's/^v//')"

# --- report ----------------------------------------------------------------
printf '\n%-18s %-12s %-12s %s\n' "Component" "Installed" "Latest" "Status"
printf '%-18s %-12s %-12s %s\n' "------------------" "------------" "------------" "------"

status() { [ "$1" = "$2" ] && echo "OK" || echo "UPDATE"; }

printf '%-18s %-12s %-12s %s\n' "EdgeTX firmware" "$FW_INSTALLED" "$FW_LATEST" "$(status "$FW_INSTALLED" "$FW_LATEST")"
printf '%-18s %-12s %-12s %s\n' "EdgeTX SD content" "$SD_INSTALLED" "$SD_LATEST" "$(status "$SD_INSTALLED" "$SD_LATEST")"
printf '%-18s %-12s %-12s %s\n' "ExpressLRS (mod.)" "check on radio" "$ELRS_LATEST" "manual"

cat <<EOF

Note: the ExpressLRS module version is read on the radio via
  Tools -> ExpressLRS (Lua script).
Update with: ./scripts/update-edgetx.sh and ./scripts/update-elrs.sh
EOF
