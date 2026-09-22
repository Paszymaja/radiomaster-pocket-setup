#!/usr/bin/env bash
# Prepare the Meteor75 Pro II O4 serial ELRS receiver update.
# The firmware flash itself is performed by ExpressLRS Configurator.
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

CFG="$BIN_DIR/expresslrs-configurator"

if ! command -v "$CFG" >/dev/null 2>&1; then
  die "expresslrs-configurator not found. Run ./scripts/install-tools.sh first."
fi

if ! id -Gn | tr ' ' '\n' | grep -qx uucp; then
  log_warn "You are not in the 'uucp' group; Betaflight passthrough may not open the USB serial port."
  log_warn "Run: sudo usermod -aG uucp \$USER, then log out and back in."
fi

case "${1:-}" in
  "") ;;
  --launch)
    log_info "Launching ExpressLRS Configurator..."
    nohup "$CFG" >/dev/null 2>&1 &
    ;;
  *) die "Usage: $0 [--launch]" ;;
esac

cat <<'EOF'

Meteor75 Pro II O4 receiver update:
  1. Read docs/meteor75-pro-ii-o4.md and record the radio TX version.
     Select a release with the same ExpressLRS major version as the radio.
  2. Connect the drone flight controller by USB. Close Betaflight Configurator
     and any other program using its serial port; unplug/replug USB.
  3. In ExpressLRS Configurator select:
       Device category : BETAFPV 2.4 GHz
       Device          : BETAFPV 2.4GHz AIO RX
       Flashing method : BetaflightPassthrough
       Domain          : 2.4 GHz LBT (match this radio's CE_LBT setting)
       Binding phrase  : leave blank for traditional binding, as used here
  4. Flash, wait for success, then power-cycle the drone. Verify its receiver
     version/domain and connection before flight.
  5. If a new bind is needed, use Betaflight's Bind Receiver / bind_rx,
     then Bind in the radio's ExpressLRS Lua tool with M75P2 O4 selected.

This updates only the onboard serial ELRS receiver, not Betaflight or DJI O4.
EOF
