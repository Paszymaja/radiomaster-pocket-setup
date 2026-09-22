# Updating when new versions are released

The Pocket and Meteor have independently versioned components:

| Component | Version source | Update mechanism |
|-----------|----------------|------------------|
| EdgeTX firmware | highest non-prerelease release by semver from `EdgeTX/edgetx` | bootloader flash (`pocket-*.bin`) |
| EdgeTX SD content | highest non-prerelease release by semver from `EdgeTX/edgetx-sdcard` | merge `bw128x64.zip` |
| ExpressLRS radio module | radio's ExpressLRS Lua version line | Configurator `EdgeTXPassthrough` |
| ExpressLRS Lua | SD file `SCRIPTS/TOOLS/elrs.lua` | copy release asset to `SCRIPTS/TOOLS/` |
| Meteor ExpressLRS receiver | receiver Web UI or connected Lua version line | Configurator `BetaflightPassthrough` |
| Meteor Betaflight FC | Betaflight Configurator or CLI `version` | separate Betaflight update |

Do **not** use GitHub `releases/latest` for EdgeTX: parallel supported release
lines can make the most recently published release the wrong one for the
Pocket. The repo scripts select the highest stable semantic version.

## Workflow

```bash
./scripts/check-versions.sh    # 1. what's installed vs latest?
./scripts/update-edgetx.sh     # 2. if EdgeTX/SD content changed
./scripts/update-elrs.sh       # 3. if ELRS changed
./scripts/update-lua.sh        # 4. if Lua changed
./scripts/update-meteor-elrs.sh # 5. prepare the Meteor receiver update
```

`update.sh` runs the version check and the EdgeTX/SD/Lua storage-mode updaters;
the radio module and Meteor receiver ELRS helpers are run separately.
For the Meteor receiver and binding, follow [its setup record](meteor75-pro-ii-o4.md).

## EdgeTX firmware + SD content

`update-edgetx.sh` downloads the latest firmware zip and extracts `pocket-*.bin`
into `FIRMWARE/`, then merges the `bw128x64.zip` base SD content (preserving
your `MODELS/` and `RADIO/`), which also refreshes `edgetx.sdcard.version`.
Add `--sounds` to also merge the English voice pack. Then **you**:

1. Safely eject the SD card.
2. Flash via bootloader: radio off → hold both trim switches inward + power →
   **Write Firmware** → select `pocket-*.bin` → long-press → reboot.

> The bootloader method needs no browser/DFU/udev setup. EdgeTX Buddy (web) is
> the alternative for the firmware step but needs Chromium + DFU udev rules.

## ExpressLRS module

`update-elrs.sh` requires the radio **on** and in **USB Serial (VCP)** mode, with
`serialPort.VCP.mode = CLI` (already set by this repo's config). It launches the
Configurator; select:

- Device category `RadioMaster 2.4 GHz` → device `RadioMaster Pocket Internal 2.4GHz TX`
- Flashing method `EdgeTXPassthrough`
- Regulatory domain: `2.4 GHz LBT` (EU) or `2.4 GHz ISM` (elsewhere)
- Binding phrase: optional; if used, keep it identical on devices that should
  auto-bind. The Meteor receiver currently uses traditional binding with no
  receiver phrase (see [its record](meteor75-pro-ii-o4.md)).

After flashing, `update-lua.sh` refreshes the Lua script.

## ExpressLRS Lua

`update-lua.sh` downloads `elrs.lua` (the ELRS 4.x name) and removes obsolete
`elrsV3.lua`/`.luac` from `SCRIPTS/TOOLS/`.
