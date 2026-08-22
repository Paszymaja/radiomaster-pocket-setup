# AGENTS.md — RadioMaster Pocket setup

Operational knowledge for AI agents working on this repo. Read this before
touching the radio's SD card or writing/editing scripts. The "gotchas" below
were discovered the hard way and are easy to get wrong.

## Hardware identity

- **Radio**: RadioMaster Pocket, **internal ExpressLRS** variant.
  - EdgeTX `board: pocket`, `lcd_depth: 1` → **monochrome 128x64** display
    (NOT color). EdgeTX UI = monochrome; SD content variant = `bw128x64`.
  - Internal module is CRSF (`internalModule: TYPE_CROSSFIRE`).
- Radio runs EdgeTX. Model/radio settings are **YAML** on the SD card.

## SD card layout (storage mode)

When the radio is in "USB Storage" mode, the SD card mounts at
`/run/media/<user>/<LABEL>/` (label is usually `B2AB-B066` but **detect it** —
see `scripts/lib/common.sh`). Key paths:

```
RADIO/radio.yml            radio-wide settings (battery, backlight, switches...)
MODELS/modelXX.yml         one file per model, XX = 2-digit index (00, 01, ...)
FIRMWARE/                  EdgeTX .bin firmware files (flash from bootloader)
SCRIPTS/TOOLS/             Lua scripts incl. ExpressLRS (elrs.lua)
edgetx.sdcard.version      SD content version marker (text file)
```

## Tools (installed user-space, no sudo)

- `~/apps/edgetx-companion.AppImage` → symlinked `~/.local/bin/edgetx-companion`
- `~/apps/expresslrs-configurator/` → symlinked `~/.local/bin/expresslrs-configurator`
- Installed from official prebuilt binaries (the AUR `edgetx-companion` build
  requires `sudo` for Qt/CMake deps — avoid it). See `scripts/install-tools.sh`.

## Editing YAML by hand — RULES

- `RADIO/radio.yml` has a `checksum:` and `manuallyEdited:` field. When editing
  by hand, **set `manuallyEdited: 1`**; on next boot EdgeTX loads the file,
  ignores the stale checksum, and re-saves (recomputes checksum, resets
  `manuallyEdited` to 0). Verified in `radio/src/storage/sdcard_yaml.cpp`.
- `MODELS/modelXX.yml` files have **no checksum** — edit freely.
- Field units (verified against EdgeTX source):
  - `inactivityTimer` → **minutes** (10 = 10 min).
  - `lightAutoOff` → **5-second** units (3 = 15 s).
  - `vBatWarn` / `vBatMin` / `vBatMax` → **0.1 V** (64 = 6.4 V).
  - `noJitterFilter: 1` → ADC/jitter filter **OFF** (`0` = filter active).
  - `internalModuleBaudrate: 4` → CRSF **5.25 M** (index `(store+1)%6`).
  - `USBMode: 0` → "Ask"; `serialPort.VCP.mode: CLI` needed for ELRS passthrough.
- Model `switchWarning` (2.12 format) `pos` values: `none`/`up`/`mid`/`down`.
  A 2-position button (SE) must NOT be `mid` — that always triggers a warning.

## Known EdgeTX 2.10 → 2.12 migration bug

Upgrading firmware migrates `switchWarningState: AuBuCuDu` (old) to the new
`switchWarning:` map, but **mangles** it (drops `SC`, sets `SB` and `SE` to
`mid`). `SE: mid` on a 2-position button warns forever. Fix (see
`scripts/fix-switch-warning.sh`): set `SA/SB/SC/SD` to `up` and remove `SE`.
Applies only to the model EdgeTX re-saved; other models still hold the old
format until loaded.

## FPV Sim model recipe

1. Copy the live POCKET model (`MODELS/model00.yml`) to the next free
   `modelXX.yml`.
2. `header.name` → `"FPV Sim"`.
3. `moduleData.0.type` → `TYPE_NONE` (RF off); drop the `mod.crsf` sub-block.
4. Set `currModel: <index>` in `radio.yml` (index = the `XX` number).
   `currModel` is index-based → `model04.yml` is index 4.

## ExpressLRS (module + Lua)

- Configurator targets: **Device category `RadioMaster 2.4 GHz`** →
  **`RadioMaster Pocket Internal 2.4GHz TX`**; method **`EdgeTXPassthrough`**.
- Regulatory domain: **`2.4 GHz LBT`** (EU/CE) or **`2.4 GHz ISM`** (FCC/other).
- Radio must be **on**, connected via the **top** USB port, and set to
  **USB Serial (VCP)**; `serialPort.VCP.mode` must be `CLI`.
- Serial access: user must be in the **`uucp`** group
  (`sudo usermod -aG uucp <user>` + re-login). Configurator is GUI-only.
- Lua script: ELRS 4.x uses **`elrs.lua`** (delete old `elrsV3.lua`/`.luac`).
- Binding phrase: case-sensitive, identical on TX + all receivers; never commit.

## Version sources (GitHub API)

- EdgeTX firmware: `api.github.com/repos/EdgeTX/edgetx/releases/latest`
  (firmware zip contains `pocket-<hash>.bin`).
- EdgeTX SD content: `api.github.com/repos/EdgeTX/edgetx-sdcard/releases/latest`
  (`bw128x64.zip` for the Pocket).
- ExpressLRS: `api.github.com/repos/ExpressLRS/ExpressLRS/releases/latest`
  (`elrs.lua` release asset).
- Installed EdgeTX version: read `semver:` from `RADIO/radio.yml`.
- Installed SD content: read `edgetx.sdcard.version`.
- Installed ELRS module version: **not readable from the SD** — read on the radio
  via the ExpressLRS Lua (Tools → ExpressLRS).

## Script conventions

- Bash + Python stdlib only (no PyYAML). Idempotent. `set -euo pipefail`.
- Never commit: SD backups, downloaded firmware/zips, or the binding phrase.
- `scripts/lib/common.sh` provides `detect_sd()` and GitHub latest helpers.
