# GasDeck: installation and usage

[Home](../README.md) | [Illustrated guide](Configuration.md) | [Norsk](Konfigurasjon-norsk.md)

## Installation

Download [GasDeck-2026.10-v6.zip](https://github.com/bliatun-code/GasDeck/releases/download/gasdeck-2026.10-v6/GasDeck-2026.10-v6.zip) from the release assets,
not GitHub's automatic source archive. The same ZIP supports Suite and manual installation.

- **FrSky Suite:** Connect the radio, open **Lua library**, choose **Install Lua scripts**, select the ZIP and click **Install scripts**. Suite installs the files into `/scripts/GasDeck/`.
- **Manual:** Extract the ZIP, create `/scripts/GasDeck/` on the radio's script drive and copy all five extracted files into it:

```text
scripts/
  GasDeck/
    main.lua
    ethos_lua_manifest.json
    INSTALL.txt
    LICENSE
    NOTICE.md
```

Restart ETHOS after installation.
On first installation, select **GasDeck** in a full-screen widget area and configure your model's sources,
capacities and fuel method.
Open **Configure widget** from the widget menu and check the version at the top.
Suite displays this release as **26.10.6**.
If Suite's installed entry has not refreshed, leave and reopen **Lua library**.

If the widget still shows an older version after restarting, reconnect the radio,
remove only `/scripts/GasDeck/main.luac` and restart ETHOS again.

Logging and **Synthetic preview** default Off. Keep preview off when using live
telemetry. Back up your model before updating. Keep the configured widget and existing cfg/dat files;
saved settings, source selections and flight counts are retained.

For a TD SR18 with AES II, follow the illustrated setup in menu order:
[English](Configuration.md) or [Norsk](Konfigurasjon-norsk.md).

## Hardware mapping

Discover sensors in ETHOS first. This example uses two RX voltage estimates,
combined RX consumption, one RPM, one temperature and integrated fuel flow.

| Example source and unit | GasDeck assignment |
| --- | --- |
| RxBatt1 / RxBatt2 — V | Each RX battery's Voltage source; Remaining from = Voltage estimate |
| RxCurrent — A | RX total current |
| Calculated RxConsuption — mAh | RX total consumed |
| AES RPM 1 — r/m | RPM 1 source |
| AES temp. 5 — °C | Temp 1 source; first display slot can use AES input 5 |
| AES flow — ml/min | Flow source; Tank value from = Integrate flow |
| Ignition switch/channel/status | Ignition status; never inferred from RPM |
| RSSI 2.4G / RSSI 900M — dB | RF 1 / RF 2 source |
| VFR 2.4G / VFR 900M — % | Optional distinct Log RF 1 / Log RF 2 source |

Sensor names are editable; the reading type and unit must match the field.
Inactive configuration fields are grey. GasDeck can display up to four selected RPM
and temperature readings; it does not create additional sensors.

**RxConsuption** (or **RxConsumption**) is a user-created ETHOS **Consumption**
sensor, not a factory measurement. Use **Source = RxCurrent**, **mAh** and
**Persistent**, then reset manually after fully charging both packs it measures.
Do not reset it on ignition changes or RF loss. Combined consumption cannot identify
each pack's use; do not halve it or assign it to both batteries.
Follow the [step-by-step recipe](Configuration.md#if-consumed-mah-is-missing).

For other battery/fuel methods, see the [advanced reference](Configuration.md#advanced-reference).
AES remaining-volume/percent sources need their own tank/reset setup; GasDeck Refuel
does not change those external readings.
Consult the [FrSky AES II manual](https://www.flyingtech.co.uk/wp-content/uploads/2024/05/Advanced-Engine-Suite-II-Manual.pdf)
and [FrSky TD SR18 manual](https://www.frsky-rc.com/wp-content/uploads/Downloads/Amanual/TD%20SR18%20Manual.pdf)
for hardware setup, and [ETHOS telemetry documentation](https://ethos-doc.frsky-rc.com/model-setup/telemetry/)
for sensor discovery and calculated sources.

## Estimates and safety

Prefer individual consumed mAh or measured percent. With **Voltage estimate**, the
corresponding RX battery menu shows **Remaining % is a voltage estimate.**
The dashboard percentage has no EST label. LiFe's flat voltage curve makes the
capacity estimate less reliable.
Fuel estimates require correct baseline, calibration and continuous valid data.
Missing integrated flow cannot be reconstructed. Unknown is not full.
A command is not ignition-power feedback. GasDeck never controls ignition, throttle,
receiver power, safety switches or failsafe. Keep native alerts and physical safeguards.

If an RX consumption counter unexpectedly falls, check the battery's charge and
the current mAh reading. Exit preview and confirm ignition OFF, then choose
**Accept RX counters...** in the widget menu. This accepts both RX readings;
it does not reset the sensors, flight count or fuel estimate.

## Model image and fonts

Reuse the model's selected image path; fitting preserves aspect ratio. At 800 x 480,
the image area is about 277 x 156 pixels. **320 x 180** is a good 16:9 illustration size
for this GasDeck panel; 290 x 191 also works with different unused margins.
An 800 x 480 image exceeds the widget's image-size limit.
Use ETHOS-compatible RGB/RGBA 8-bit PNG, not palette/16-bit PNG.
Large image dimensions can use too much radio memory even when the PNG file is small.
The example artwork is optional; you can use your model's own picture.
Leave **Font file** blank to use the radio's native fonts.

## Flight logs and model settings

Receiver batteries often stay connected between flights. With valid ignition OFF,
GasDeck ends the current session and retains its qualified log. The next ignition
ON starts a new qualification. Unknown ignition pauses the same session; an
unqualified start does not count or replace the previous log.

After filling the tank, set **Refill amount**, exit **Synthetic preview** and choose
**Refuel... > Confirm**. Refuel works with the model switched off or ignition ON.
It is blocked while a counted flight is still running, with an explanation in the
dialog. A paused flight is completed without changing its count. With the sensor
offline, confirmation is registered while the tank meter stays unknown. The estimate
appears when the model is switched on and the first valid fuel reading arrives;
earlier consumption cannot be recovered. Direct remaining sensors are not changed.
See [Refuel and data gaps](Configuration.md#refuel-and-data-gaps).

The last qualified log stays visible after aircraft shutdown and while the next
flight qualifies. Radio restart clears its statistics and graphs; the flight count
is saved for each model. Graphs retain brief signal drops and show gaps when readings
are missing. Live traces can take a few seconds to update.

Choose **Flight log** from the five-choice Home menu. **Diagnostics** is the button
at the bottom right, also available with an empty log. Turn the wheel right to
select it, then short-press, or touch it directly. **RTN** returns from the log or
diagnostics to Dashboard; close any open menu first. Another RTN uses ETHOS's normal
navigation. The background stays still while Home is open, for up to 30 seconds;
telemetry, alerts and logging continue. **Reset live peaks** is under
**Configure widget > Flight session**. See [Home menu and navigation](Configuration.md#home-menu-and-navigation).

Settings and flight counts are saved separately for each model. Keep the model,
widget settings and flight-counter files together in your backup when updating
or moving to another SD card.

[License](../LICENSE) | [Notice](../NOTICE.md) | [Change log](../CHANGELOG.md)
