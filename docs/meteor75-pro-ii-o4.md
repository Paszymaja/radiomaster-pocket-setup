# Meteor75 Pro II O4: radio profile, receiver, and binding

This records the working setup on **2026-09-22**. The [BETAFPV Meteor75 Pro II
O4](https://betafpv.com/products/meteor75-pro-ii-o4-brushless-whoop-quadcopter)
has a Matrix 1S 3IN1 HD flight controller with an onboard **serial** ELRS 2.4 GHz
receiver. Its receiver firmware is separate from Betaflight and from the
Pocket's internal ELRS transmitter firmware.

## Recorded state

| Component | Observed or installed state |
|-----------|-----------------------------|
| Radio | RadioMaster Pocket, internal 2.4 GHz ELRS; EdgeTX 2.12.2, SD content 2.12.1 |
| Radio ELRS TX | `4.1.0 CE_LBT a9d4a9`, read from `SYS` → `Tools` → `ExpressLRS` |
| Radio model | `M75P2 O4` in `MODELS/model05.yml` on this SD card; cloned from `POCKET` (`model00.yml`) with internal CRSF enabled |
| Drone FC | Betaflight target `BETAFPVG473`, firmware `2025.12.5-alpha` (2026-06-25); serial receiver protocol `CRSF` |
| Drone ELRS RX before update | `3.5.6 ee188b ISM2G4`; Web UI reported `Unified_ESP8285_2400_RX` |
| Drone ELRS RX flashed | Official ExpressLRS `4.1.0`, `CE_LBT`, `BETAFPV 2.4GHz AIO RX` target (`betafpv.rx_2400.aio`, ESP8285, firmware family `Unified_ESP8285_2400_RX`). Flash tool verified the written image hash. A post-flash Web UI version read was **not** recorded. |
| Link after flash | Traditional bind succeeded: radio Lua displayed `C`, receiver LED stayed solid, Betaflight reported RX rate 250 and live receiver channels. The user confirmed the drone works. |

The original TX/RX versions could not bind: ExpressLRS requires the **major**
version number to match. The original RX also used `ISM2G4` while the radio
used `CE_LBT`. See the [ExpressLRS compatibility and binding guide](https://www.expresslrs.org/quick-start/binding/).

The radio's binding phrase is **unknown** and is never stored in this repo.
The receiver was flashed without a binding phrase and paired with the Lua
`Bind` command. If either side is reflashed with a new phrase, arrange the
same phrase on both devices or repeat traditional binding with **no phrase
set on the receiver**. Do not commit a phrase or device backups.

## Recreate the radio model

With the Pocket in **USB Storage** mode through its **top** USB-C port:

```bash
./scripts/backup.sh
./scripts/create-meteor75-pro-ii-o4.sh
```

The script is idempotent, copies the live `POCKET` model, preserves its channel
and switch mixes and internal CRSF module, resets the copied timer, and uses
the next free `modelXX.yml` index. `model05.yml` is the index on this radio;
another card can use a different index. Safely eject USB storage, start the
radio normally, press `MDL`, and select `M75P2 O4` before binding or flying.
The model name is short enough for the Pocket's monochrome display.

## Update the radio and receiver later

1. Back up the radio SD card with `./scripts/backup.sh`. Before a Betaflight
   update, save a fresh `diff all` from Betaflight CLI somewhere private. The
   `diff all` taken during this setup was kept only in `/tmp`, so do not rely
   on it surviving a reboot. Record the currently installed TX and RX versions.
2. Choose an official ExpressLRS release supported by **both** devices. Flash
   the radio's internal module with `./scripts/update-elrs.sh` instructions:
   `RadioMaster 2.4 GHz` → `RadioMaster Pocket Internal 2.4GHz TX`,
   `EdgeTXPassthrough`, and the appropriate `2.4 GHz LBT` regulatory domain
   for this setup. The radio must be on and in **USB Serial (VCP)** mode.
   Refresh `SCRIPTS/TOOLS/elrs.lua` with `./scripts/update-lua.sh` if needed.
3. Flash the drone's **receiver**, not the flight controller, using the
   [official BETAFPV AIO RX instructions](https://www.expresslrs.org/quick-start/receivers/betafpv2400/).
   Run `./scripts/update-meteor-elrs.sh` for this repo's target-specific
   checklist (`--launch` also opens the Configurator).
   In ExpressLRS Configurator select `BETAFPV 2.4 GHz` →
   `BETAFPV 2.4GHz AIO RX`, method `BetaflightPassthrough`, and the same
   regulatory domain as the radio (`2.4 GHz LBT` here). For traditional
   binding, leave the RX binding phrase blank. Close Betaflight Configurator
   and other programs holding the drone's USB serial port, then power-cycle
   the FC before flashing. On this hardware, USB alone powered the receiver.
4. Wait for the flash success indication, unplug/reconnect drone USB, and
   verify the receiver version and domain if possible. With the TX off, an
   unconnected RX normally starts an `ExpressLRS RX` Wi-Fi access point after
   about 60 seconds; its Web UI is at `http://10.0.0.1`. The factory/default
   AP password is `expresslrs` if it has not been changed.
5. If needed, put the receiver in binding mode with Betaflight's **Bind
   Receiver** button or the `bind_rx` CLI command. Then, with `M75P2 O4`
   selected, choose **Bind** in the radio's ExpressLRS Lua tool. A solid RX
   LED and `C` at the top right of the Lua tool indicate a connected link.
   Power-cycle and verify it reconnects without another bind command.

The original successful RX flash used the official **4.1.0 LBT**
`Unified_ESP8285_2400_RX` binary from ExpressLRS Configurator's release
cache, configured for `betafpv.rx_2400.aio`, through Betaflight passthrough.
The flasher identified an `ESP8285H16`, wrote **551,184 bytes**, and verified
the hash before reset. The Configurator procedure above is the maintainable
way to repeat it; temporary build files and a local Python serial workaround
from that flash are not part of this repo.

## Before flight after a firmware or model change

With props removed, use Betaflight's Receiver tab to check the AETR channels,
throttle low near 1000, yaw centered near 1500, and the arm switch. The FC has
`map AETR1234`; its arm range is AUX1/CH5 **1700–2100**. The Pocket's
`stickMode: 1` YAML value is zero-based **Mode 2**, so throttle is the **left
vertical stick**. During this setup, a read taken before the stick was lowered
showed CH3 at 1500 and CH5 at 1000; the final live read was interrupted because
the USB port became busy. The user subsequently reported that the drone works.
Recheck the endpoints and switch direction before flight.

Do not confuse receiver firmware with the FC's Betaflight firmware or the DJI
O4 air unit firmware; each has its own update process.

## Indoor Betaflight Profile 2 (added 2026-09-22)

The FC now has a visible **PID Profile 2** and **Rate Profile 2**, both named
`INDOOR` and active after the save/reboot. Betaflight CLI indexes start at
zero, so these are `profile 1` and `rateprofile 1`. The repeatable CLI commands
are in [`config/meteor75-pro-ii-o4-indoor.cli`](../config/meteor75-pro-ii-o4-indoor.cli).
They were applied and read back on this drone's Betaflight `2025.12.5-alpha`.
After a future Betaflight update, check command compatibility before reusing
the file.

The **P, I, D, feedforward, and filter values** in PID Profile 2 match the
factory `GF 1811` tune in Profile 1. Web recommendations cannot establish a
better PID tune for this specific airframe without flight logs. The indoor
changes are control limits:

| Setting | Factory Profile 1 | Indoor Profile 2 |
|---------|-------------------|------------------|
| Angle mode maximum tilt | 60° | 30° |
| Roll / pitch center sensitivity | 70°/s | 50°/s |
| Roll / pitch maximum rate | 670°/s | 350°/s |
| Yaw center / maximum rate | 70°/s / 670°/s | 50°/s / 300°/s |
| Throttle limit | Off | Off; full lift remains available |

The slower Actual rates follow [Betaflight's rate guidance](https://betaflight.com/docs/wiki/guides/current/Rate-Calculator),
which describes a flatter center response for smooth flying. Betaflight keeps
[PID and rate profiles separate](https://betaflight.com/docs/wiki/guides/current/Profiles).

Profile 1 had `auto_profile_cell_count = 1`, which would select it when a 1S
battery was detected. This was set to `0` so the chosen indoor profile stays
active after power cycling; its factory PID and filter values were otherwise
left as they were. Rate Profile 1 was left at its original settings. The
existing Angle mode switch assignment was not changed; use Angle mode for the
30° tilt limit to take effect. The Pocket's `SB` switch drives AUX2/CH6; its
low range (900–1300) selects Angle mode in the saved Betaflight configuration.
Rate Profile 2's gentler stick response applies
in Acro as well. Select PID Profile 1 and Rate Profile 1 in Betaflight if you
want the original outdoor feel, or select both Profile 2 slots for indoor use.

The pre-change `diff all` was backed up locally under `/tmp` during this
session. Make a fresh private backup before any later Betaflight changes, and
check channel directions and arm switch with props removed before flying the
new profile.
