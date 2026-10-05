# GasDeck

A full-screen receiver-power, gasoline-engine and fuel dashboard for FrSky ETHOS.

**Development snapshot: 2026.10-dev2. Physical-radio testing passed, reported by the owner on 2026-10-05. No GasDeck release is published yet.**

![GasDeck: RPM, temperatures, dual RX batteries and fuel](docs/images/gasdeck-single-engine.png)

Native ETHOS simulator rendering with synthetic readings, not a recorded flight.
The Extra NG 78 / Great Power 38 cc aircraft is the owner's illustration.
Multi-engine and multi-temperature variants are hypothetical examples, not its actual equipment.

[Illustrated configuration guide](docs/Configuration.md) |
[Norsk veiledning](docs/Konfigurasjon-norsk.md) |
[Installation and technical notes](docs/GasDeck.md) |
[Lua source](scripts/GasDeck/main.lua)

## Choose your engine deck

<table>
<tr><td><img src="docs/images/gasdeck-single-engine.png" alt="One RPM and two temperatures"><br><b>One engine</b><br>Retro LCD RPM, flow and tank reserve.</td><td><img src="docs/images/gasdeck-four-temperatures.png" alt="One RPM and four temperatures"><br><b>Four temperatures</b><br>Independently chosen measurement points.</td></tr>
<tr><td><img src="docs/images/gasdeck-four-engines.png" alt="Four RPM, four temperatures and three RF slots"><br><b>Four engines</b><br>Up to four RPM and four temperatures.</td><td><img src="docs/images/gasdeck-numeric-rpm.png" alt="Numeric measured RPM"><br><b>Numeric RPM</b><br>Measured speed and session peak.</td></tr>
<tr><td><img src="docs/images/gasdeck-flight-log.png" alt="Synthetic flight summary"><br><b>Flight summary</b><br>Peaks, fuel use and bounded RF history.</td><td><img src="docs/images/gasdeck-low-fuel.png" alt="Fuel reserve and receiver battery colors"><br><b>Reserve and alerts</b><br>Fuel reserve and separate RX capacity.</td></tr>
</table>

## Highlights

- Active model name and optional reuse of its selected model picture.
- VoltDeck-aligned header, neutral engine text and TX voltage under the ignition plaque.
- Two independently configured LiPo/LiFe RX batteries; individual mAh, percent or explicit voltage estimate.
- Combined RX current and consumption, without inventing a split between batteries.
- Independently selectable 0-4 measured RPM and 0-4 temperatures, LCD or numeric RPM.
- Flow in ml/min; tank from consumed volume, integrated flow, remaining volume or percent.
- Configurable reserve, separate low-fuel/RX WAV files and a repeat interval.
- Ignition ON/OFF/unknown; source-named RSSI/VFR and 1-3 actual RF sources.
- Per-model counter, retained last flight and optional delayed automatic log opening.
- Theme, black or custom background; no bundled runtime artwork, fonts, sounds or bytecode.

## Install this development snapshot

1. Download the repository using **Code > Download ZIP**, or obtain the readable [Lua source](scripts/GasDeck/main.lua).
2. Copy only its `scripts/GasDeck` folder to the radio SD card. The final path must be `scripts/GasDeck/main.lua`, not a nested repository folder.
3. Restart ETHOS and select **GasDeck** in a full-screen widget area.
4. Configure actual model sensors, capacities, ignition and fuel method.
5. Turn **Synthetic preview** off before live measurement, alarm or flight-count checks.

Keep existing `gc*.cfg` and `gd*.dat` files when upgrading. If stale `main.luac`
remains, remove only that generated file; ETHOS compiles the Lua on the target itself.
Do not install documentation, private helpers or another radio's settings.
A future release will be a named **GasDeck ZIP** containing the widget folder.
There is intentionally no release tag or release download link yet.

## Ignition and sorties

ON is green, OFF red and unavailable status neutral with `--`. A switch reports
a command, not proof of ignition power or a running engine. GasDeck never controls
the aircraft. The redundant CMD/SENSOR/DEMO line is omitted; TX uses that space.

![Ignition OFF and TX voltage](docs/images/gasdeck-ignition-off.png)

Enable logging, select throttle and ignition. Defaults: 60 s qualifying time including
5 s above 50% normalized throttle. Ignition OFF/unknown pauses the same session;
ON again does not count a second flight. Blank airborne gate is optional.

Gasoline sorties often retain receiver batteries. Use **Finish flight** or confirm an
actual **Refuel**, with valid ignition OFF, between sorties. Loss of both RX feeds for
**Power loss delay** also ends the session; RF failure can resemble disconnected power.
The last qualified log remains until a new flight qualifies. Only the counter survives
radio restart; graphs/summary stay in RAM. Automatic log opening defaults Off.

## Testing, safety and publication

Owner-reported physical-radio testing passed on 2026-10-05. Simulator target: X20RS,
ETHOS 26.1.2 / FrSky Suite 2.0.1. Earlier functional development passed 60 automated
regression cases and 44 native simulator cases. Gallery data are synthetic, not AES II
calibration or universal hardware compatibility. Keep native alarms, failsafe,
pre-flight checks and physical ignition safety enabled.

Implementation and original prose: [MIT](LICENSE).
Owner-supplied artwork has a separate status in [NOTICE](NOTICE.md).
Publish only curated Lua, documentation and approved illustrations.
Notes, private tests/feeders, live telemetry logs, native model/radio records, per-model
state, bytecode, sounds and fonts remain private.

## Electric models

[VoltDeck](https://github.com/bliatun-code/VoltDeck) covers electric flight-pack
capacity, power and electric-motor dashboards. The projects have independent releases.
