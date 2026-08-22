#!/usr/bin/env bash
# Install EdgeTX Companion (AppImage) and ExpressLRS Configurator (portable)
# into ~/apps/ with symlinks in ~/.local/bin/. No sudo required.
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

require_cmd curl unzip

EDGETX_REPO="EdgeTX/edgetx"
ELRS_CFG_REPO="ExpressLRS/ExpressLRS-Configurator"

mkdir -p "$APPS_DIR" "$BIN_DIR"

# --- EdgeTX Companion ------------------------------------------------------
COMPANION_APPIMAGE="$APPS_DIR/edgetx-companion.AppImage"
log_info "Fetching latest EdgeTX Companion..."
EDGETX_VER="$(gh_latest_tag "$EDGETX_REPO")"
CMP_URL="https://github.com/$EDGETX_REPO/releases/download/$EDGETX_VER/edgetx-cpn-linux-$EDGETX_VER.zip"
log_info "  version $EDGETX_VER"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
curl -fsSL -o "$TMP/companion.zip" "$CMP_URL"
unzip -q -o "$TMP/companion.zip" -d "$TMP/"
APPIMAGE="$(find "$TMP" -maxdepth 1 -name '*.AppImage' -print -quit)"
[ -n "$APPIMAGE" ] || die "No AppImage found in Companion zip"
mv -f "$APPIMAGE" "$COMPANION_APPIMAGE"
chmod +x "$COMPANION_APPIMAGE"
ln -sf "$COMPANION_APPIMAGE" "$BIN_DIR/edgetx-companion"
log_ok "EdgeTX Companion $EDGETX_VER -> $BIN_DIR/edgetx-companion"

# --- ExpressLRS Configurator ----------------------------------------------
CFG_DIR="$APPS_DIR/expresslrs-configurator"
log_info "Fetching latest ExpressLRS Configurator..."
CFG_VER="$(gh_latest_tag "$ELRS_CFG_REPO")"
CFG_VER_NUM="${CFG_VER#v}"
CFG_URL="$(gh_asset_url "$ELRS_CFG_REPO" "expresslrs-configurator-$CFG_VER_NUM.zip")"
[ -n "$CFG_URL" ] || CFG_URL="https://github.com/$ELRS_CFG_REPO/releases/download/$CFG_VER/expresslrs-configurator-$CFG_VER_NUM.zip"
log_info "  version $CFG_VER"

curl -fsSL -o "$TMP/cfg.zip" "$CFG_URL"
rm -rf "$CFG_DIR"
mkdir -p "$CFG_DIR"
unzip -q -o "$TMP/cfg.zip" -d "$CFG_DIR"
chmod +x "$CFG_DIR/expresslrs-configurator" "$CFG_DIR/chrome-sandbox" 2>/dev/null || true
ln -sf "$CFG_DIR/expresslrs-configurator" "$BIN_DIR/expresslrs-configurator"
log_ok "ExpressLRS Configurator $CFG_VER -> $BIN_DIR/expresslrs-configurator"

log_ok "Done. Both tools are on PATH via $BIN_DIR"
