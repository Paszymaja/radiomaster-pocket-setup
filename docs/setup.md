# Full setup (from a brand-new radio)

Use this to reproduce the working setup. Steps that touch the SD card assume
the radio is in **USB Storage** mode: power on → connect the **top** USB port →
choose **USB Storage**.

## 0. Prerequisites

- Arch/Omarchy with `bash`, `curl`, `unzip`, `python3`.
- USB-C data cable (top port).
- For flashing the internal ELRS module: `sudo usermod -aG uucp $USER` + re-login.

## 1. Back up the SD card

```bash
./scripts/backup.sh
```

Creates a timestamped copy under `~/pocket-sd-backups/`. Always back up before
any firmware/SD content change.

## 2. Install the tools (one-time)

```bash
./scripts/install-tools.sh
```

Installs EdgeTX Companion (AppImage) and ExpressLRS Configurator (portable) to
`~/apps/`, symlinked into `~/.local/bin/`. No `sudo` required.

## 3. Configure the radio

```bash
./scripts/configure.sh
```

Applies the settings in `config/settings.env` to `RADIO/radio.yml`
(battery range 6.4–8.2 V, battery-low 6.4 V, contrast 15, inactivity 10 min,
backlight 15 s, ADC filter off — see `docs/reference.md`), then creates the
**FPV Sim** model (a copy of the POCKET profile with RF switched off) and sets
it as the default model. Idempotent — safe to re-run.

## 4. Update firmware + SD content (if applicable)

```bash
./scripts/check-versions.sh   # see what's outdated
./scripts/update-edgetx.sh    # stages firmware + SD content, prints flash steps
```

The EdgeTX firmware flash is done on the radio:
1. Safely eject the SD card.
2. Radio **off** → hold **both trim switches inward** + press **power** → bootloader.
3. **Write Firmware** → select the `pocket-*.bin` → long-press to flash → reboot.

## 5. Update the internal ExpressLRS module (if applicable)

```bash
./scripts/update-elrs.sh
```

It verifies `uucp` access, launches the Configurator, and prints the exact
click-through (target `RadioMaster Pocket Internal 2.4GHz TX`, method
`EdgeTXPassthrough`, regulatory domain, binding phrase).

## 6. Update the ExpressLRS Lua script (if applicable)

```bash
./scripts/update-lua.sh
```

Copies `elrs.lua` into `SCRIPTS/TOOLS/` and removes obsolete `elrsV3.*`.

## 7. Fly

- **Sim**: with FPV Sim as the default model, connect USB and choose **Joystick**
  when the sim asks; calibrate in the sim.
- **Real drone**: switch the model back to **POCKET** (the ELRS profile) and bind
  your receiver (binding phrase auto-binds if you set one).
