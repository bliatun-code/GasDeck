# GasDeck

A full-screen receiver-power, gasoline-engine and fuel dashboard for FrSky ETHOS 1.6.6 and 26.1.2.

**GasDeck 2026.10-v6: latest release. Physical radio testing passed.**

[Download GasDeck-2026.10-v6.zip](https://github.com/bliatun-code/GasDeck/releases/download/gasdeck-2026.10-v6/GasDeck-2026.10-v6.zip) | [Release notes](https://github.com/bliatun-code/GasDeck/releases/tag/gasdeck-2026.10-v6)

![GasDeck: RPM, temperatures, dual RX batteries and fuel](docs/images/gasdeck-single-engine.png)

The screenshots use illustrative values and example layouts.

[Illustrated configuration guide](docs/Configuration.md) |
[Norsk veiledning](docs/Konfigurasjon-norsk.md) |
[Installation and usage](docs/GasDeck.md) |
[Lua source](scripts/GasDeck/main.lua)

## Choose your engine deck

<table>
<tr><td><img src="docs/images/gasdeck-single-engine.png" alt="One RPM and two temperatures"><br><b>One engine</b><br>Retro LCD RPM, flow and tank reserve.</td><td><img src="docs/images/gasdeck-four-temperatures.png" alt="One RPM and four temperatures"><br><b>Four temperatures</b><br>Independently chosen measurement points.</td></tr>
<tr><td><img src="docs/images/gasdeck-four-engines.png" alt="Four RPM, four temperatures and three RF slots"><br><b>Four engines</b><br>Up to four RPM and four temperatures.</td><td><img src="docs/images/gasdeck-numeric-rpm.png" alt="Numeric measured RPM"><br><b>Numeric RPM</b><br>Measured speed and session peak.</td></tr>
<tr><td><img src="docs/images/gasdeck-flight-log.png" alt="Synthetic flight summary"><br><b>Flight summary</b><br>Peaks, fuel use and RF signal history.</td><td><img src="docs/images/gasdeck-low-fuel.png" alt="Fuel reserve and receiver battery colors"><br><b>Reserve and alerts</b><br>Fuel reserve and separate RX capacity.</td></tr>
</table>

## Highlights

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

Download [GasDeck-2026.10-v6.zip](https://github.com/bliatun-code/GasDeck/releases/download/gasdeck-2026.10-v6/GasDeck-2026.10-v6.zip) from the release assets, not GitHub's automatic source archive. The same ZIP supports both methods:

- **FrSky Suite:** Connect the radio, open **Lua library**, choose **Install Lua scripts**, select the ZIP and click **Install scripts**.
- **Manual:** Extract the ZIP, create `/scripts/GasDeck/` on the radio's script drive and copy all extracted files into it. The final Lua path is `/scripts/GasDeck/main.lua`.

Restart ETHOS after installation.
On first installation, select **GasDeck** in a full-screen widget area. Follow the
[TD SR18 / AES II walkthrough](docs/Configuration.md) or [norsk veiledning](docs/Konfigurasjon-norsk.md).
Turn **Synthetic preview** off for live operation.
Open **Configure widget** from the widget menu and check the version at the top.
Suite displays this release as **26.10.6**.
If Suite's installed entry has not refreshed, leave and reopen **Lua library**.
If the widget still shows an older version after restarting, follow the
[installation troubleshooting](docs/GasDeck.md#installation).

Back up your model before updating. Keep the configured widget and existing cfg/dat files;
saved settings, source selections and flight counts are retained.

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

## Electric models

[VoltDeck](https://github.com/bliatun-code/VoltDeck) covers electric flight-pack
capacity, power and electric-motor dashboards. The projects have independent releases.
