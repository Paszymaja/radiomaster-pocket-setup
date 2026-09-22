# Reference

## Radio settings (applied by `configure.sh` via `config/settings.env`)

| Setting | Value | radio.yml key |
|---------|-------|---------------|
| Battery range | 6.4 – 8.2 V | `vBatMin` 64, `vBatMax` 82 (0.1 V units) |
| Battery low warning | 6.4 V | `vBatWarn` 64 |
| Contrast | 15 | `contrast` |
| Inactivity alarm | 10 min | `inactivityTimer` (minutes) |
| Backlight duration | 15 s | `lightAutoOff` 3 (×5 s) |
| ADC filter | off | `noJitterFilter` 1 |
| Sound mode | All | `beepMode` `mode_all` |
| USB mode | Ask | `USBMode` 0 |
| VCP mode | CLI | `serialPort.VCP.mode` |
| Internal RF | CRSF 5.25 M | `internalModule` `TYPE_CROSSFIRE`, `internalModuleBaudrate` 4 |

## Model profiles

- **POCKET** (`model00.yml`) — ExpressLRS profile, full AETR + switch mixes
  (SA/SB/SC/SD/SE/P1), CRSF telemetry sensors. Use for real drones.
- **FPV Sim** (created by `configure.sh`) — copy of POCKET with `moduleData.0.type
  = TYPE_NONE` (RF off), set as the default model for sim use.
- **M75P2 O4** (created by `create-meteor75-pro-ii-o4.sh`) — dedicated Meteor75
  Pro II O4 model copied from POCKET with internal ELRS/CRSF active. See
  [the Meteor setup record](meteor75-pro-ii-o4.md).

## Device targets (ExpressLRS Configurator)

- Category: `RadioMaster 2.4 GHz`
- Device: `RadioMaster Pocket Internal 2.4GHz TX`
- Method: `EdgeTXPassthrough`
- Domain: `2.4 GHz LBT` (EU/CE) · `2.4 GHz ISM` (FCC/other)

## EdgeTX build facts

- Board `pocket`; monochrome 128x64 (`lcd_depth: 1`).
- SD content variant: `bw128x64`.
- Firmware asset: `pocket-<git-hash>.bin` inside `edgetx-firmware-vX.Y.Z.zip`.

## File map (SD card, storage mode)

```
RADIO/radio.yml             radio settings (has checksum + manuallyEdited)
MODELS/modelXX.yml          models (XX = index; no checksum)
FIRMWARE/pocket-*.bin       firmware images (bootloader flashes these)
SCRIPTS/TOOLS/elrs.lua      ExpressLRS Lua script
edgetx.sdcard.version       SD content version marker
```

## Key paths on this machine

- Tools: `~/apps/edgetx-companion.AppImage`, `~/apps/expresslrs-configurator/`
- Symlinks: `~/.local/bin/edgetx-companion`, `~/.local/bin/expresslrs-configurator`
- Backups: `~/pocket-sd-backups/`
