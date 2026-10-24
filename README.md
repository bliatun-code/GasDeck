# GasDeck

A full-screen receiver-power, gasoline-engine and fuel dashboard for FrSky ETHOS 1.6.6 and 26.1.2.

**GasDeck 2026.10-v7: latest release. Physical radio testing passed.**

[Download GasDeck-2026.10-v7.zip](https://github.com/bliatun-code/GasDeck/releases/download/gasdeck-2026.10-v7/GasDeck-2026.10-v7.zip) | [Release notes](https://github.com/bliatun-code/GasDeck/releases/tag/gasdeck-2026.10-v7)

<table>
<tr>
<td><img src="docs/images/native-gasdeck-deck-photo.png" alt="Deck / model picture" width="400"><br><b>Deck / model picture</b></td>
<td><img src="docs/images/native-gasdeck-deck-hidden.png" alt="Deck / Hidden" width="400"><br><b>Deck / Hidden</b></td>
</tr>
<tr>
<td><img src="docs/images/native-gasdeck-digital-photo.png" alt="Digital Engine / model picture" width="400"><br><b>Digital Engine / model picture</b></td>
<td><img src="docs/images/native-gasdeck-digital-hidden.png" alt="Digital Engine / Hidden" width="400"><br><b>Digital Engine / Hidden</b></td>
</tr>
</table>

Genuine X20RS / ETHOS 26.1.2 simulator captures of the current stable version, with controlled illustrative telemetry. No physical sensors were connected.

[Full display gallery and sensor setups](docs/Display-gallery.md) |
[Norsk visningsgalleri](docs/Visningsgalleri-norsk.md) |
[Illustrated configuration guide](docs/Configuration.md) |
[Norsk veiledning](docs/Konfigurasjon-norsk.md) |
[Installation and usage](docs/GasDeck.md) |
[Lua source](scripts/GasDeck/main.lua)

Large twin-cylinder acro: one 120 cc engine, one RPM source and two CHT probes. The four-engine example uses matching B-24 artwork. See the gallery for exact program choices, source roles and units.

## Display style and model picture

Choose **Display style = Deck** for the upright batteries and familiar instruments. **Digital** offers another instrument view focused on receiver power, RPM, temperatures and fuel, with **Instrument focus: Engine** shown as information. Deck is the default for new models and settings from versions before Digital. Previously saved Deck/Digital choices are retained.

**Image source** is independent in both styles: **Selected model**, **Image file** or **Hidden**. Hidden gives the picture area to larger readings. In Deck, a selected model picture keeps the familiar composition. A failed image keeps its area and shows the error; missing telemetry also retains instrument positions.

Changing style or image does not change calculation methods, telemetry sources, units, alerts, acceptance or flight logging. Inactive fields retain their saved values.

**Full screen:** The widget area must fill the radio's complete LCD, including on radios with a lower resolution. A split area shows **Full screen required**; choose a full-screen area to restore the instruments. **Screen size unavailable** means the LCD dimensions could not be read; the app retries automatically. Selected sources and settings are retained.

## Choose your engine deck

<table>
<tr><td><img src="docs/images/native-gasdeck-deck-photo.png" alt="One RPM and two temperatures"><br><b>One engine</b><br>Retro LCD RPM, flow and tank reserve.</td><td><img src="docs/images/native-gasdeck-deck-rpm1-temp4.png" alt="One RPM and four temperatures"><br><b>Four temperatures</b><br>Independently chosen measurement points.</td></tr>
<tr><td><img src="docs/images/native-gasdeck-quad-deck-photo.png" alt="Four RPM, four temperatures and two RF slots"><br><b>Four engines</b><br>Up to four RPM and four temperatures.</td><td><img src="docs/images/native-gasdeck-numeric-deck.png" alt="Numeric measured RPM"><br><b>Numeric RPM</b><br>Measured speed and session peak.</td></tr>
<tr><td><img src="docs/images/gasdeck-flight-log.png" alt="Illustrative flight summary"><br><b>Flight summary</b><br>Peaks, fuel use and RF signal history.</td><td><img src="docs/images/gasdeck-low-fuel.png" alt="Fuel reserve and receiver battery colors"><br><b>Reserve and alerts</b><br>Fuel reserve and separate RX capacity.</td></tr>
</table>

## Highlights

- Deck and Digital display styles, with an independent model-picture choice.
- Active model name and optional reuse of its selected model picture.
- Receiver battery readings and transmitter voltage.
- Two independently configured LiPo/LiFe RX batteries; individual mAh, percent or explicit voltage estimate.
- Combined RX current and consumption.
- Independently selectable 0-4 measured RPM and 0-4 temperatures, LCD or numeric RPM.
- Flow in ml/min; tank from consumed volume, integrated flow, remaining volume or percent.
- Configurable reserve, separate low-fuel/RX WAV files and a repeat interval.
- Ignition ON/OFF/unknown; source-named RSSI/VFR and 1-3 actual RF sources.
- Per-model counter, retained last flight and optional delayed automatic log opening.
- Radio theme, black or custom background, with your selected model picture.

## Install GasDeck

Download [GasDeck-2026.10-v7.zip](https://github.com/bliatun-code/GasDeck/releases/download/gasdeck-2026.10-v7/GasDeck-2026.10-v7.zip) from the release assets, not GitHub's automatic source archive. The same ZIP supports both methods:

- **FrSky Suite:** Connect the radio, open **Lua library**, choose **Install Lua scripts**, select the ZIP and click **Install scripts**.
- **Manual:** Extract the ZIP, create `/scripts/GasDeck/` on the radio's script drive and copy all extracted files into it. The final Lua path is `/scripts/GasDeck/main.lua`.

Restart ETHOS after installation.
On first installation, select **GasDeck** in a full-screen widget area. Follow the
[TD SR18 / AES II walkthrough](docs/Configuration.md) or [norsk veiledning](docs/Konfigurasjon-norsk.md).
Turn **Synthetic preview** off for live operation.
Open **Configure widget** from the widget menu and check the version at the top.
Suite displays this release as **26.10.7**.
If Suite's installed entry has not refreshed, leave and reopen **Lua library**.
If the widget still shows an older version after restarting, follow the
[installation troubleshooting](docs/GasDeck.md#installation).

Back up the SD card and ETHOS model storage together before updating. Keep the configured
widget and existing cfg/dat files; saved settings, sources and flight counts are retained.
See [upgrading and rollback](docs/GasDeck.md#upgrading-and-rollback) before returning to an older release.

## Ignition and sorties

ON is green, OFF red and unavailable status neutral with `--`. A switch reports
a command, not proof of ignition power or a running engine. GasDeck never controls
the aircraft.

![Ignition OFF and TX voltage](docs/images/gasdeck-ignition-off.png)

Enable logging, select throttle and ignition. Defaults: 60 s qualifying time including
5 s above 50% normalized throttle. Valid ignition OFF ends the session and retains
its qualified log. The next ON starts a new qualification. Unknown ignition pauses
the current session. Blank airborne gate is optional.

Gasoline sorties can retain receiver batteries between flights. Confirm an actual
**Refuel** after filling the tank. Refuel also works with the
model off or ignition ON; a qualified active flight blocks it. Loss of both RX feeds for
**Power loss delay** also ends the session; RF failure can resemble disconnected power.
The last qualified log remains until a new flight qualifies. Only the counter survives
radio restart; graphs/summary stay in RAM. Automatic log opening defaults Off.

Open **Flight log** from the five-choice Home menu. Its bottom-right **Diagnostics**
button shows the logging conditions, even with no recorded flight. **RTN** returns
from either view to Dashboard. See the [menu walkthrough](docs/Configuration.md#home-menu-and-navigation).

## Safety and compatibility

Keep native alarms, failsafe, pre-flight checks and physical ignition safety
enabled. Check sources and settings on your own model when using other radio
or firmware combinations.

## License

GasDeck is available under [MIT](LICENSE). The example artwork has separate
terms described in [NOTICE](NOTICE.md).

## Deck family

| App | Best suited to | Main instruments |
| --- | --- | --- |
| [VoltDeck](https://github.com/bliatun-code/VoltDeck) | Electric powered models | Flight-pack capacity, current, electrical power and motor telemetry. |
| [GasDeck](https://github.com/bliatun-code/GasDeck) | Gasoline powered models | Receiver batteries, engine RPM, temperatures and fuel. |
| [SoarDeck](https://github.com/bliatun-code/SoarDeck) | Sailplanes and motor gliders | Altitude, vario, history and motor-battery capacity when applicable. |

Each project has its own repository, illustrated guides and releases.
