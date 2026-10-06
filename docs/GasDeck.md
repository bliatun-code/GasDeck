# GasDeck: installation and usage

[Home](../README.md) | [Illustrated guide](Configuration.md) | [Norsk](Konfigurasjon-norsk.md)

## Installation

1. Download [GasDeck-2026.10-v2.zip](https://github.com/bliatun-code/GasDeck/releases/download/gasdeck-2026.10-v2/GasDeck-2026.10-v2.zip) from the release assets.
2. Extract `scripts/GasDeck` onto the radio SD card so the final path is `scripts/GasDeck/main.lua`.
3. Remove any existing `scripts/GasDeck/main.luac`, then restart ETHOS.
4. Select **GasDeck** in a full-screen widget area and configure your model's sources, capacities and fuel method.

Logging and **Synthetic preview** default Off. Keep preview off when using live
telemetry. Keep a backup of your model and widget settings when updating.

## Hardware mapping

Discover and configure sensors in ETHOS first, then select their sources in GasDeck.

| Data | GasDeck assignment |
| --- | --- |
| RX1/RX2 voltage | Each battery's Voltage source. |
| Individual mAh/percent | Its own Consumed mAh / Percent source. |
| Combined RX current/consumption | RX total current / RX total consumed. |
| RPM/temperatures | Independent RPM/Temp 1-4 slots. |
| Flowmeter rate | Flow source and correct units. |
| Cumulative fuel used | Fuel used source in Capacity - consumed mode. |
| Actual remaining ml/percent | Remaining source and matching method. |
| Ignition command/feedback | Ignition status; never inferred from RPM. |
| RSSI/VFR | Actual dashboard and optional distinct log sources. |

GasDeck displays up to four selected RPM and temperature readings. Consult your
equipment's manual for wiring, sensor setup and calibration.
[FrSky AES II manual](https://www.flyingtech.co.uk/wp-content/uploads/2024/05/Advanced-Engine-Suite-II-Manual.pdf),
[FrSky North America AES II](https://frskyna.com/products/frsky-advanced-engine-suite).

TD SR18's two 2.4 GHz antennas and one 900 MHz antenna do not establish three telemetry
values; some firmware combines VFR.
[FrSky TD SR18 manual](https://www.flyingtech.co.uk/wp-content/uploads/2023/10/TD-SR18-Manual.pdf),
[FrSky TD R18](https://www.frsky-rc.com/td-r18/).
[ETHOS telemetry documentation](https://ethos-doc.frsky-rc.com/model-setup/telemetry/)
explains discovery and calculated sources.

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
use **Finish flight...** to end the current session, or **Refuel...** after actually
adding fuel. Refuelling also completes the current flight. Ignition OFF by itself
pauses the session; ignition ON resumes it without counting a second flight.

The last qualified log stays visible after aircraft shutdown and while the next
flight qualifies. Radio restart clears its statistics and graphs; the flight count
is saved for each model. Graphs retain brief signal drops and show gaps when readings
are missing. Live traces can take a few seconds to update.

Settings and flight counts are saved separately for each model. Keep the model,
widget settings and flight-counter files together in your backup when updating
or moving to another SD card.

[License](../LICENSE) | [Notice](../NOTICE.md) | [Change log](../CHANGELOG.md)
