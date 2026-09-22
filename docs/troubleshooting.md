# Troubleshooting

## Switch warning on the SE button after a firmware update

**Symptom**: after updating EdgeTX (2.10 → 2.12), the radio warns about `SE`
(the momentary button) at startup, when it used to warn about SB/SC.

**Cause**: the firmware migration converts the old `switchWarningState` string
to the new `switchWarning:` map incorrectly, setting `SE: pos: mid` (invalid for
a 2-position button) and dropping `SC`.

**Fix**:
```bash
./scripts/fix-switch-warning.sh
```
It rewrites the affected model's `switchWarning` to `SA/SB/SC/SD = up` and
removes `SE`. If you switch to another model and see it again, re-run it.

## "Permission denied: /dev/ttyACM0" when flashing ELRS

**Cause**: the serial port is `root:uucp` and your session isn't in the `uucp`
group (group changes only apply to a fresh login).

**Fix**:
```bash
sudo usermod -aG uucp $USER     # then log out and back in
# quick one-off (resets on replug):
sudo chmod a+rw /dev/ttyACM0
```

## SD card version warning

**Symptom**: "SD Card Warning" at startup.

**Cause**: `edgetx.sdcard.version` doesn't match the firmware. The bootloader
flash updates only firmware, not the SD content marker.

**Fix**: run `./scripts/update-edgetx.sh` — it merges the latest SD content and
refreshes `edgetx.sdcard.version` to match.

## ELRS Lua script missing / "Loading…" stuck

- Confirm the script is `elrs.lua` in `SCRIPTS/TOOLS/` (not the obsolete
  `elrsV3.lua`). Run `./scripts/update-lua.sh`.
- Confirm the current model uses the internal CRSF module and VCP mode is `CLI`
  (see `docs/reference.md`).

## Telemetry lost / Lua fails on the radio

The CRSF baudrate may be too high. This repo sets 5.25 M; if you get constant
"Telemetry lost/recovered", lower it in the model's internal RF settings
(400 K is the safe fallback).

## Meteor receiver will not bind

Read [the Meteor setup record](meteor75-pro-ii-o4.md) for this drone's exact
receiver target and update sequence. Check the ELRS version line on the radio
and receiver: their **major** versions must match, and this setup uses
`CE_LBT` on both sides. Check that the `M75P2 O4` model is selected and its
internal CRSF module is on. With a receiver that has no binding phrase,
`bind_rx` in Betaflight CLI or **Bind Receiver** in the Receiver tab puts it
into bind mode; then choose **Bind** in the radio's ExpressLRS tool. A solid
receiver LED and `C` on the radio indicate a link.

If Betaflight passthrough cannot open the drone's USB serial port, close
Betaflight Configurator and other apps using it, then unplug/reconnect the
drone USB cable before retrying.

## Restoring from a mistake

Backups are in `~/pocket-sd-backups/`. To restore, mount the SD card in USB
Storage mode and copy the backup contents back over the card, then reboot.
