#!/usr/bin/env bash
# Update the ExpressLRS Lua script (elrs.lua) in SCRIPTS/TOOLS/ and remove
# obsolete version-labelled copies (elrsV3.lua/.luac, elrsV2, ELRS.lua).
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

require_cmd curl

SD="$(detect_sd)"
TOOLS="$SD/SCRIPTS/TOOLS"
mkdir -p "$TOOLS"

log_info "Fetching latest ExpressLRS Lua script..."
LUA_URL="$(gh_asset_url ExpressLRS/ExpressLRS 'elrs.lua')"
[ -n "$LUA_URL" ] || LUA_URL="https://raw.githubusercontent.com/ExpressLRS/ExpressLRS/master/src/lua/elrs.lua"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
curl -fsSL -o "$TMP/elrs.lua" "$LUA_URL"
cp -f "$TMP/elrs.lua" "$TOOLS/elrs.lua"

# remove obsolete copies
for old in elrsV3.lua elrsV3.luac elrsV2.lua elrsV2.luac ELRS.lua ELRS.luac; do
  rm -f "$TOOLS/$old"
done

log_ok "elrs.lua installed in $TOOLS"
log_info "Removed obsolete elrsV*/ELRS.* copies if present."
