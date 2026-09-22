# RadioMaster Pocket Setup

Scripts and documentation to configure, back up, and keep a
[RadioMaster Pocket](https://www.radiomasterrc.com/products/pocket-radio-controller)
(EdgeTX + internal ExpressLRS) up to date — configured on the PC instead of
through the radio's buttons.

This repo records a working setup and automates the fiddly parts so the radio
can be reproduced or updated when EdgeTX / ExpressLRS publish new releases.

## What's inside

| Path | Purpose |
|------|---------|
| `README.md` | You are here |
| `AGENTS.md` | Playbook for AI agents working on this repo |
| `docs/setup.md` | Full step-by-step, from a brand-new radio |
| `docs/updating.md` | How to update EdgeTX / ELRS / SD content / Lua |
| `docs/reference.md` | Settings reference, device targets, file map |
| `docs/meteor75-pro-ii-o4.md` | Meteor radio model, receiver target, binding, future updates |
| `docs/troubleshooting.md` | Known issues and fixes |
| `scripts/*.sh` | Automation (backup, configure, check/update versions) |
| `config/settings.env` | The radio settings applied by `configure.sh` |

## Prerequisites

- Arch Linux (Omarchy) with `bash`, `curl`, `unzip`, `python3` (all present).
- `gh` (GitHub CLI) is used only to build/push this repo, not by the scripts.
- A USB-C **data** cable (the Pocket's **top** port is data; bottom is charge).
- Optional: a Chromium browser + STM32 udev rules if you flash firmware via
  EdgeTX Buddy instead of the bootloader method.

## Quick start

```bash
# 1. Put the radio in "USB Storage" mode, then back it up
./scripts/backup.sh

# 2. One-time: install EdgeTX Companion + ExpressLRS Configurator (no sudo)
./scripts/install-tools.sh

# 3. Apply this repo's settings + create the "FPV Sim" model (idempotent)
./scripts/configure.sh

# Optional: add a dedicated Meteor75 Pro II O4 ELRS model (idempotent)
./scripts/create-meteor75-pro-ii-o4.sh

# 4. See what's out of date
./scripts/check-versions.sh

# 5. Update as needed (each prints exact on-radio steps)
./scripts/update-edgetx.sh   # EdgeTX firmware + SD content
./scripts/update-elrs.sh     # internal ExpressLRS module
./scripts/update-lua.sh      # ExpressLRS Lua script
./scripts/update-meteor-elrs.sh # Meteor onboard ELRS receiver guidance
```

The EdgeTX and Lua updaters download and stage files. The ELRS helpers print
the Configurator targets and connection steps; flashing is done in the
Configurator. Radio bootloader and USB mode selections are done on the radio.

## Notes

- The ELRS **binding phrase is never stored** here. `update-elrs.sh` explains
  the optional phrase setting; the Meteor receiver uses traditional binding.
- Backups are written to `~/pocket-sd-backups/` and are git-ignored.
- See `docs/reference.md` for the exact EdgeTX device targets and settings.
