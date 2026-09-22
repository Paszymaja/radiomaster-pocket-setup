#!/usr/bin/env bash
# Guide the internal ExpressLRS module update via the Configurator GUI.
# The flash itself is GUI-only; this checks prerequisites and prints the steps.
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

CFG="$BIN_DIR/expresslrs-configurator"

# --- prerequisites ---------------------------------------------------------
if ! id -Gn | tr ' ' '\n' | grep -qx uucp; then
  log_warn "You are not in the 'uucp' group — serial access will fail."
  log_warn "Run:  sudo usermod -aG uucp \$USER   then log out and back in."
fi

if ! command -v "$CFG" >/dev/null 2>&1; then
  die "expresslrs-configurator not found. Run ./scripts/install-tools.sh first."
fi

# --- launch (optional) -----------------------------------------------------
if [ "${1:-}" = "--launch" ]; then
  log_info "Launching ExpressLRS Configurator..."
  nohup "$CFG" >/dev/null 2>&1 &
fi

cat <<EOF

ExpressLRS module update steps:
  1. Power the radio ON.
  2. Connect the TOP USB-C port -> on the radio choose "USB Serial (VCP)".
     (Requires VCP mode = CLI, already set by this repo's config.)
  3. In the Configurator select:
       Device category : RadioMaster 2.4 GHz
       Device          : RadioMaster Pocket Internal 2.4GHz TX
       Flashing method : EdgeTXPassthrough
  4. Regulatory domain:
        2.4 GHz LBT  -> EU / CE (100 mW)
        2.4 GHz ISM  -> FCC / elsewhere (full power)
  5. Binding phrase is optional. If you set one, record it privately and use
     the same phrase on receivers meant to auto-bind. The Meteor receiver
     currently has no phrase and was paired using the Lua Bind command.
     A phrase is NOT stored in this repo.
  6. Click "Flash".

After flashing, run ./scripts/update-lua.sh to refresh the Lua script.
EOF
