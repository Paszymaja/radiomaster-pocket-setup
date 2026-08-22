#!/usr/bin/env bash
# Update EdgeTX firmware + SD content version marker.
# Prepares everything that can be automated, then prints the on-radio steps.
# Usage: update-edgetx.sh [--sounds]   (--sounds also merges the en sound pack)
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

require_cmd curl unzip python3

MERGE_SOUNDS=0
[ "${1:-}" = "--sounds" ] && MERGE_SOUNDS=1

SD="$(detect_sd)"
FIRMWARE_DIR="$SD/FIRMWARE"

FW_LATEST_TAG="$(gh_latest_tag EdgeTX/edgetx)"
FW_VER="${FW_LATEST_TAG#v}"
SD_VER_TAG="$(gh_latest_tag EdgeTX/edgetx-sdcard)"
SD_VER="${SD_VER_TAG#v}"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# --- firmware --------------------------------------------------------------
log_info "EdgeTX firmware: $FW_VER"
FW_ZIP_URL="https://github.com/EdgeTX/edgetx/releases/download/$FW_LATEST_TAG/edgetx-firmware-$FW_VER.zip"
curl -fsSL -o "$TMP/fw.zip" "$FW_ZIP_URL"
unzip -q -o "$TMP/fw.zip" -d "$TMP/fw" "pocket-*.bin"
POCKET_BIN="$(find "$TMP/fw" -name 'pocket-*.bin' -print -quit)"
[ -n "$POCKET_BIN" ] || die "No pocket-*.bin found in firmware zip"
cp -f "$POCKET_BIN" "$FIRMWARE_DIR/"
log_ok "Staged firmware: $(basename "$POCKET_BIN") -> FIRMWARE/"

# --- SD content version marker --------------------------------------------
printf '%s' "$SD_VER" > "$SD/edgetx.sdcard.version"
log_ok "Updated edgetx.sdcard.version -> $SD_VER"

# --- optional sound pack ---------------------------------------------------
if [ "$MERGE_SOUNDS" = 1 ]; then
  log_info "Merging en sound pack..."
  SND_ZIP_URL="$(gh_asset_url EdgeTX/edgetx-sdcard-sounds 'en.zip')"
  [ -n "$SND_ZIP_URL" ] || SND_ZIP_URL="https://github.com/EdgeTX/edgetx-sdcard-sounds/releases/download/$SD_VER_TAG/en.zip"
  curl -fsSL -o "$TMP/sounds.zip" "$SND_ZIP_URL"
  mkdir -p "$SD/SOUNDS"
  unzip -q -o "$TMP/sounds.zip" -d "$SD/SOUNDS/"
  log_ok "Sound pack merged into SOUNDS/"
fi

# --- on-radio steps --------------------------------------------------------
cat <<EOF

Next steps (on the radio):
  1. Safely eject the SD card from the PC.
  2. Power the radio OFF.
  3. Hold BOTH trim switches inward + press POWER  -> bootloader menu.
  4. Choose "Write Firmware" -> select $(basename "$POCKET_BIN") -> long-press to flash.
  5. Reboot. Firmware is now $FW_VER.

$( [ "$MERGE_SOUNDS" = 0 ] && echo "Tip: re-run with --sounds to also update the voice pack." )
EOF
