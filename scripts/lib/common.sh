#!/usr/bin/env bash
# Shared helpers for the RadioMaster Pocket setup scripts.
# Source this from other scripts: source "$(dirname "$0")/lib/common.sh"

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$HOME/pocket-sd-backups}"
APPS_DIR="${APPS_DIR:-$HOME/apps}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

# --- logging ---------------------------------------------------------------
c_reset=$'\033[0m'; c_red=$'\033[31m'; c_green=$'\033[32m'; c_yellow=$'\033[33m'; c_cyan=$'\033[36m'
log_info() { printf '%s[INFO]%s %s\n' "$c_cyan" "$c_reset" "$*"; }
log_ok()   { printf '%s[ OK ]%s %s\n' "$c_green" "$c_reset" "$*"; }
log_warn() { printf '%s[WARN]%s %s\n' "$c_yellow" "$c_reset" "$*"; }
log_err()  { printf '%s[ERR ]%s %s\n' "$c_red" "$c_reset" "$*" >&2; }
die()      { log_err "$*"; exit 1; }

# --- dependencies ----------------------------------------------------------
require_cmd() {
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || die "Missing required command: $c"
  done
}

# --- SD card detection -----------------------------------------------------
# Finds the mounted EdgeTX SD card (contains RADIO/radio.yml or
# edgetx.sdcard.version). Prints the mount path or exits 1.
detect_sd() {
  local base="/run/media/$USER"
  [ -d "$base" ] || die "No /run/media/$USER directory — is the radio in USB Storage mode?"
  for d in "$base"/*/; do
    if [ -f "${d}RADIO/radio.yml" ] || [ -f "${d}edgetx.sdcard.version" ]; then
      printf '%s' "$d"
      return 0
    fi
  done
  die "EdgeTX SD card not found under $base — connect the radio and choose USB Storage."
}

# --- GitHub API ------------------------------------------------------------
# gh_latest_tag <owner/repo>  -> prints latest release tag (e.g. "v2.12.2")
gh_latest_tag() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | python3 -c 'import sys,json;print(json.load(sys.stdin)["tag_name"])'
}

# gh_asset_url <owner/repo> <grep>  -> prints the first matching asset download URL
gh_asset_url() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | python3 -c 'import sys,json
d=json.load(sys.stdin)
needle=sys.argv[1]
for a in d.get("assets",[]):
    if needle in a["name"]:
        print(a["browser_download_url"]); break' "$2"
}
