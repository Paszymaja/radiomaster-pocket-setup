#!/usr/bin/env bash
# Update EdgeTX firmware + SD content. Prepares everything that can be
# automated, then prints the on-radio steps.
# Usage: update-edgetx.sh [--sounds]   (--sounds also merges the en sound pack)
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

require_cmd curl unzip python3 rsync

MERGE_SOUNDS=0
[ "${1:-}" = "--sounds" ] && MERGE_SOUNDS=1

SD="$(detect_sd)"
FIRMWARE_DIR="$SD/FIRMWARE"

FW_TAG="$(gh_latest_tag EdgeTX/edgetx)"            # e.g. v2.12.2
SDC_TAG="$(gh_latest_tag EdgeTX/edgetx-sdcard)"    # e.g. v2.12.1

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# --- firmware --------------------------------------------------------------
log_info "EdgeTX firmware: $FW_TAG"
FW_ZIP_URL="https://github.com/EdgeTX/edgetx/releases/download/$FW_TAG/edgetx-firmware-$FW_TAG.zip"
curl -fsSL -o "$TMP/fw.zip" "$FW_ZIP_URL"
unzip -q -o "$TMP/fw.zip" -d "$TMP/fw" "pocket-*.bin"
POCKET_BIN="$(find "$TMP/fw" -name 'pocket-*.bin' -print -quit)"
[ -n "$POCKET_BIN" ] || die "No pocket-*.bin found in firmware zip"
cp -f "$POCKET_BIN" "$FIRMWARE_DIR/"
log_ok "Staged firmware: $(basename "$POCKET_BIN") -> FIRMWARE/"

# --- SD content (base, bw128x64) -------------------------------------------
# Merge the base content but preserve user data (MODELS/, RADIO/). The version
# marker is taken from the merged content, so it always reflects reality.
log_info "SD content: $SDC_TAG"
SDC_URL="https://github.com/EdgeTX/edgetx-sdcard/releases/download/$SDC_TAG/bw128x64.zip"
curl -fsSL -o "$TMP/sdc.zip" "$SDC_URL"
unzip -q -o "$TMP/sdc.zip" -d "$TMP/sdc"
rsync -a --exclude='MODELS/' --exclude='RADIO/' "$TMP/sdc/" "$SD/"
log_ok "Merged SD content (edgetx.sdcard.version -> $(cat "$SD/edgetx.sdcard.version"))"

# --- optional sound pack ---------------------------------------------------
if [ "$MERGE_SOUNDS" = 1 ]; then
  SND_TAG="$(gh_latest_tag EdgeTX/edgetx-sdcard-sounds)"
  log_info "Sound pack: $SND_TAG"
  SND_URL="$(gh_asset_url EdgeTX/edgetx-sdcard-sounds '-en-' "$SND_TAG")"
  [ -n "$SND_URL" ] || die "en sound pack asset not found"
  curl -fsSL -o "$TMP/sounds.zip" "$SND_URL"
  mkdir -p "$SD/SOUNDS"
  unzip -q -o "$TMP/sounds.zip" -d "$SD/SOUNDS/"
  log_ok "Merged en sound pack into SOUNDS/"
fi

# --- on-radio steps --------------------------------------------------------
cat <<EOF

Next steps (on the radio):
  1. Safely eject the SD card from the PC.
  2. Power the radio OFF.
  3. Hold BOTH trim switches inward + press POWER  -> bootloader menu.
  4. Choose "Write Firmware" -> select $(basename "$POCKET_BIN") -> long-press to flash.
  5. Reboot. Firmware is now $FW_TAG.
EOF
