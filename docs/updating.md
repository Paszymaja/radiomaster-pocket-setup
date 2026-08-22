# Updating when new versions are released

The Pocket has **three** independently-versioned components, updated by three
different mechanisms:

| Component | Version source | Update mechanism |
|-----------|----------------|------------------|
| EdgeTX firmware | `api.github.com/repos/EdgeTX/edgetx/releases/latest` | bootloader flash (`pocket-*.bin`) |
| EdgeTX SD content | `api.github.com/repos/EdgeTX/edgetx-sdcard/releases/latest` | merge `bw128x64.zip` |
| ExpressLRS module | `api.github.com/repos/ExpressLRS/ExpressLRS/releases/latest` | Configurator `EdgeTXPassthrough` |
| ExpressLRS Lua | same ELRS release (`elrs.lua`) | copy to `SCRIPTS/TOOLS/` |

## Workflow

```bash
./scripts/check-versions.sh    # 1. what's installed vs latest?
./scripts/update-edgetx.sh     # 2. if EdgeTX/SD content changed
./scripts/update-elrs.sh       # 3. if ELRS changed
./scripts/update-lua.sh        # 4. if Lua changed
```

`update.sh` runs the checks and calls the applicable updaters in order.

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
- Binding phrase (prompted — keep it identical across all your ELRS gear)

After flashing, `update-lua.sh` refreshes the Lua script.

## ExpressLRS Lua

`update-lua.sh` downloads `elrs.lua` (the ELRS 4.x name) and removes obsolete
`elrsV3.lua`/`.luac` from `SCRIPTS/TOOLS/`.
