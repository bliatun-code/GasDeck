# GasDeck

A full-screen receiver-power, gasoline-engine and fuel dashboard for FrSky ETHOS.

**GasDeck 2026.10-v1: first release. The owner confirmed physical X20RS radio testing of the final RC1 build on 2026-10-05.**

[Download GasDeck-2026.10-v1.zip](https://github.com/bliatun-code/GasDeck/releases/download/gasdeck-2026.10-v1/GasDeck-2026.10-v1.zip) | [Release notes](https://github.com/bliatun-code/GasDeck/releases/tag/gasdeck-2026.10-v1)

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

## Install GasDeck

1. Download [GasDeck-2026.10-v1.zip](https://github.com/bliatun-code/GasDeck/releases/download/gasdeck-2026.10-v1/GasDeck-2026.10-v1.zip) from the release assets, not GitHub's automatic source archive.
2. Extract `scripts/GasDeck` onto the radio SD card; the final path is `scripts/GasDeck/main.lua`.
3. Remove stale `main.luac`, restart ETHOS and select **GasDeck** in a full-screen widget area.
4. Configure actual sources, capacities, ignition and fuel method. Turn **Synthetic preview** off for live operation.

**Upgrade warning:** This major version deliberately does not import old scalar settings. Back up the model and its cfg/dat files. Reconfigure capacity, chemistry, limits, alarms and flight options. New settings use `/scripts/vc3*.cfg` (VoltDeck) or `/scripts/gc1*.cfg` (GasDeck). Existing flight-counter files and current ordered ETHOS source assignments are retained; verify every source. Old cfg files are left untouched. Remove the old matching `main.luac` before restarting ETHOS.

The ZIP contains Lua, installation instructions, license and notices. No private helpers, settings, model records or bytecode are included.

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

The owner confirmed physical X20RS radio testing of the final RC1 builds on 2026-10-05. The shared final check passed 252 named automated checks; the preceding native ETHOS 26.1.2 simulator run passed 84 functional cases and 120 production-rendered frames. Counts cover both widgets, not 252 cases per widget. This is a project test report, not universal hardware compatibility or safety certification.

Simulator target: X20RS / ETHOS 26.1.2 / FrSky Suite 2.0.1. Gallery data are
synthetic, not AES II calibration. Keep native alarms, failsafe, pre-flight
checks and physical ignition safety enabled.

The release is based on the physically tested 2026.10-v1-rc1 source.
Only displayed version/test-status strings were changed for publication.

Implementation and original prose: [MIT](LICENSE).
Owner-supplied artwork has a separate status in [NOTICE](NOTICE.md).
Publish only curated Lua, documentation and approved illustrations.
Notes, private tests/feeders, live telemetry logs, native model/radio records, per-model
state, bytecode, sounds and fonts remain private.

## Electric models

[VoltDeck](https://github.com/bliatun-code/VoltDeck) covers electric flight-pack
capacity, power and electric-motor dashboards. The projects have independent releases.
