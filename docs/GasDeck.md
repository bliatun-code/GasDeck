# GasDeck: installation and usage

[Home](../README.md) | [Illustrated guide](Configuration.md) | [Norsk](Konfigurasjon-norsk.md)

## Installation

1. Download [GasDeck-2026.10-v3.zip](https://github.com/bliatun-code/GasDeck/releases/download/gasdeck-2026.10-v3/GasDeck-2026.10-v3.zip) from the release assets.
2. Extract `scripts/GasDeck` onto the radio SD card so the final path is `scripts/GasDeck/main.lua`.
3. Remove any existing `scripts/GasDeck/main.luac`, then restart ETHOS.
4. Select **GasDeck** in a full-screen widget area and configure your model's sources, capacities and fuel method.

Logging and **Synthetic preview** default Off. Keep preview off when using live
telemetry. Keep a backup of your model and widget settings when updating.

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

Prefer individual consumed mAh or measured percent. Voltage estimates are marked EST;
LiFe's flat voltage curve makes the capacity estimate less reliable.
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
use **Finish flight...** to end the current session. Ignition OFF by itself pauses
the session; ignition ON resumes it without counting a second flight.

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

Settings and flight counts are saved separately for each model. Keep the model,
widget settings and flight-counter files together in your backup when updating
or moving to another SD card.

[License](../LICENSE) | [Notice](../NOTICE.md) | [Change log](../CHANGELOG.md)
