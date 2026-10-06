# GasDeck illustrated configuration guide

[Home](../README.md) | [Norsk](Konfigurasjon-norsk.md) | [Installation](GasDeck.md)

The layout examples use illustrative readings. The menu and configuration images
show the widget in ETHOS.

Open the widget menu to choose **Flight log** or **Flight diagnostics**.
Scroll down and choose **Configure widget** to change settings.

<table>
<tr>
<td><img src="images/gasdeck-widget-menu.png" alt="GasDeck widget menu, upper choices"><br><b>Widget menu</b></td>
<td><img src="images/gasdeck-widget-menu-more.png" alt="GasDeck widget menu, lower choices"><br><b>Scroll down for Configure widget</b></td>
</tr>
</table>

## 1. Model and appearance

Open **Configure widget > Model / appearance**. Name follows the active ETHOS model.
The layout examples use **Engine brand = Great Power**, **Displacement = 38 cc**.

| Field | Choices and purpose |
| --- | --- |
| Engine brand / Displacement | Display information; configure RPM calibration in the sensor or ETHOS. |
| Engine count | 1-4; independent of visible RPM/temperature counts. |
| Background | Radio theme, Black or Custom. |
| Background color / Accent color | Custom palette; theme mode follows the radio. A golden normal accent is not a warning. |
| Font file | Leave blank for built-in fonts, or choose an ETHOS-supported font. |
| Image source / Image file | Selected model, another image file or Hidden. |

![Model settings](images/gasdeck-config-model.png)

This configuration image shows the defaults: no engine brand, 60 cc, one engine
and **Radio theme**.

## 2. Configure each RX battery

**RX battery 1** and **RX battery 2** have independent chemistry, cells, capacity and
sources. Defaults: LiPo, 2S, 2500 mAh, Consumed mAh.

| Field | Meaning |
| --- | --- |
| Chemistry / Cells / Capacity | LiPo or LiFe, 1-8 cells, 100-20000 mAh; match the actual pack. |
| Remaining from | Consumed mAh, Percent sensor or explicit Voltage estimate. |
| Voltage source | Pack voltage, not regulated output when estimating pack capacity. |
| Consumed mAh / Percent source | Individual pack consumption or remaining percent. |
| Current source | Optional individual current; central total current is selected separately. |

Remaining charge uses the configured capacity and each pack's consumption.
A 2500 mAh pack with 550 mAh consumed shows 78%. Check each consumption sensor
after charging and reset it when required. GasDeck does not reset the sensors.
For **Percent sensor**, select a remaining-charge source in **%**.

Do not use one combined counter for both packs: dual-feed current sharing can be uneven.
Select **RX total current / RX total consumed** under **RX / ignition** for the center fields.

If an RX meter becomes unknown after a consumption-counter reset, check the
battery charge and current mAh readings. Exit preview, confirm ignition OFF,
then choose **Accept RX counters...** in the widget menu and press **Confirm**.
This accepts the current readings for both RX batteries. It does not reset any
sensor, set charge to 100%, change the flight count or refuel the tank.
With **Consumed mAh**, missing or invalid readings remain unknown.

![Battery settings](images/gasdeck-config-battery-sources.png)

Capacity colors: green >40%, yellow <=40%, orange <=35%, red <=30%. Unknown is
a neutral empty meter with --%, not full. Voltage numbers themselves are neutral.

### LiFe and EST

Prefer individual consumed mAh or measured percent. Explicit Voltage estimate shows
**EST** and is approximate, especially for LiFe's flat curve and voltage sag.
**Alert RX estimate** defaults Off; enable deliberately if estimates should trigger alerts.

![Two LiFe packs](images/gasdeck-life-batteries.png)

## 3. Ignition and TX

**Ignition status** can be switch, logical source, channel or actual telemetry status.
**Ignition ON above** defaults to 0; ON requires a value strictly above the threshold.
Confirm both source states before using qualification.

- ON: green; allows flight qualification with the other gates.
- OFF: red; pauses the same session.
- Missing/invalid: neutral --; never treated as confirmed OFF.

![Ignition OFF](images/gasdeck-ignition-off.png)

![Missing telemetry](images/gasdeck-telemetry-unavailable.png)

A switch reports the commanded state; it does not confirm actual ignition power.
**Refuel...**, **Finish flight...** and **Accept RX counters...** require valid
ignition OFF. The widget does not switch the ignition.
**TX voltage** selects a source or uses the available built-in transmitter battery source.

## 4. RPM and temperature layouts

**AES engine sensors** independently sets **RPM displays** and **Temp displays** to 0-4.
Select actual **RPM 1-4 source** and **Temp 1-4 source** values; extra slots do not create sensors.

| Example | RPM | Temperatures |
| --- | --- | --- |
| One engine / two monitored points | 1 | 2 |
| Multi-cylinder/components | 1 | 4 |
| Four engines | 4 | 4 |
| Fuel-only lower deck | 0 | 0 |

![One RPM, two temperatures](images/gasdeck-single-engine.png)

![Four temperatures](images/gasdeck-four-temperatures.png)

![Four engines, three actual RF slots](images/gasdeck-four-engines.png)

**RPM style**: Numeric or Retro LCD. **RPM scale max** defaults to 10000 rpm and
**RPM red zone** to 85%. These are display settings, not a rev limiter or engine-specific
safe RPM. Configure sensor/AES/ETHOS pulse/pole settings to report mechanical RPM.
MAX is the observed session peak.

**Temperature unit**: Celsius/Fahrenheit. **Temp warning / Temp critical** default
150/180 degrees Celsius even with Fahrenheit display. Set appropriate manufacturer
and sensor-location limits for your engine.
Normal text below warning, yellow at warning, red at critical.

![Numeric RPM](images/gasdeck-numeric-rpm.png)

![Fuel-only deck](images/gasdeck-fuel-only.png)

## 5. Fuel / flowmeter

Enter actual **Tank capacity** and **Refill amount**, defaults 500 ml each.
Default **Reserve / warning** is 20%, **Flow calibration** 100%.

| Tank value from | Sources | Calculation |
| --- | --- | --- |
| Capacity - consumed | Fuel used source | Loaded minus consumption since confirmed refill. |
| Integrate flow | Flow source | Consumption calculated from flow; confirm Refuel after restart. |
| Remaining volume | Remaining source | Direct sensor ml/L. |
| Remaining percent | Remaining source | Sensor percent; configured tank volume gives displayed ml. |

**Flow input units**: Auto, ml/min, L/min, ml/s. **Volume input units**: Auto, ml, L.
ETHOS ml/m means ml/min. Auto uses the source's unit; select the correct unit if mislabeled.
Flow rate, cumulative consumption and remaining volume are different values.
Calibration applies only to integrated flow.

![Fuel settings](images/gasdeck-config-fuel.png)

### Refuel and data gaps

Fill the tank and set **Refill amount** to the volume loaded. Exit preview and,
with valid ignition OFF, choose **Refuel...** in the widget menu and press **Confirm**.
This starts a new flight session and updates the consumption/flow fuel estimate;
it does not reset sensors. Confirm the first real refill before relying on that estimate.

An unexpected fuel-consumption counter reset makes the estimate unknown.

Flow integration never assumes full after radio/widget restart. Confirm a real refill.
Missing flow readings can make the estimate unknown until another confirmed
refill. Missing consumption cannot be reconstructed.
Direct remaining sensors are not overwritten by Refuel. Check hardware calibration,
fuel compatibility, mounting, air bubbles and measurement range independently.

Tank reserve segments are red. At/below the selected reserve, remaining amount is red;
normal fuel uses the accent, not battery thresholds.

![Low fuel and RX colors](images/gasdeck-low-fuel.png)

## 6. Alerts

**Low fuel alert / Low RX alert** default On; **Alert RX estimate** defaults Off.
Select **Audio folder**, **Fuel WAV** and **RX battery WAV** individually.
**Repeat interval**: default 15 s, range 1-600 s. Suitable PCM WAV: 32 kHz, mono, 16-bit.
Missing/invalid files fall back to a tone. Alerts wait for the current sound to finish.
Fuel uses reserve, RX uses <=30%. Synthetic preview never plays alerts. No sounds are bundled.

## 7. RF sources / limits

Choose 1-3 **RF displays** and actual sources. Labels follow ETHOS, e.g. RSSI 2.4G
or VFR 900M; dB/% is retained without a reading. **Log RF 1-3 source** may differ
from the main view; blank reuses that dashboard slot.

| Profile | RSSI warning / critical | VFR early / low |
| --- | --- | --- |
| ACCESS / TD / TW | 35 / 32 dB | 95 / 50% |
| ACCST | 45 / 42 dB | 95 / 50% |
| Custom | Each slot's configured dB limits | Each slot's configured percent limits |

**RSSI scale min/max** controls display range, default 0-100 dB, not radio alarms.
Normal is accent, warning yellow, critical red, unknown neutral.
VFR reflects valid-frame delivery, RSSI signal strength. VFR can reveal delivery drops
clearly; RSSI still helps show link margin. 95% is an early visual marker, not a universal
manufacturer alarm. Match receiver documentation and keep native alerts.

![RF settings](images/gasdeck-config-rf.png)

Choose only RF sources actually reported by your receiver. Antenna count may
differ from the number of available readings; some receivers combine VFR.

## 8. Flight session

Logging defaults Off. Select **Throttle source** and **Ignition status**; no separate ARM.

| Field | Default / meaning |
| --- | --- |
| Flight minimum | 60 s accumulated qualifying time; range 60-3600 s. |
| Throttle gate / High throttle time | >=50% normalized throttle for >=5 s, configurable. |
| Throttle low/high (raw) | Use raw endpoints from Flight diagnostics, such as -1024/+1024; reversed endpoints supported. |
| Airborne gate | Optional; blank and Always on pass. Not an airborne detector. |
| Power loss source | Override; otherwise either positive valid RX voltage keeps power alive. |
| Power loss delay | 10 s sustained loss; 3-120 s. |
| Auto-open log / Extra log delay | Off / 5 s; opens once after qualified power-loss completion. |
| Flight time from / ETHOS timer | GasDeck qualifying session time or selected native timer. |

![Flight settings](images/gasdeck-config-flight.png)

Ignition OFF/unknown pauses but retains statistics/history. ON resumes without recounting.
With default power tracking, one missing RX feed does not end the session while
the other remains valid. Extended RF loss may imitate power loss.
If batteries stay connected between sorties, exit preview, confirm ignition OFF,
then choose **Finish flight...** and press **Confirm**. This ends the current session,
keeps the last qualified log and allows a new flight. It does not reset the count or
change fuel. Use **Refuel...** instead when you have actually refilled the tank.

The last qualified log remains after switching off the aircraft and while the next
flight qualifies. Only a qualified flight replaces it. RF history includes pauses;
flight time counts qualifying intervals. Bench running can qualify, so disable
logging during bench work when appropriate.

Auto-open waits Power loss delay plus Extra log delay. Returning power or manual
view/settings changes cancel it. Enabling later does not replay old logs.
Manual Finish/Refuel is not the power-loss auto-open trigger.

![Synthetic retained flight log](images/gasdeck-flight-log.png)

## 9. Diagnostics, menu and preview

**Flight diagnostics** shows raw/normalized throttle, ignition, airborne gate, power
and qualifying time. Follow the blocking reason; LOG DISABLED is not an error.
**Reset live peaks** clears current maxima, not the counter.
**Reset flight count** is per model; finish the active session with confirmed OFF first.

![Diagnostics](images/gasdeck-diagnostics.png)

**Synthetic preview** shows example readings without counting flights or playing
alerts. Turn it Off to use live readings and the confirmation actions.

## 10. Storage and troubleshooting

Settings, source assignments and flight count are saved for each model.
Back up the SD card and ETHOS model together. Check sources and battery settings
if you copy a model. Detailed flight logs and graphs are cleared on radio restart.

| Symptom | Check |
| --- | --- |
| Widget missing | Check scripts/GasDeck/main.lua, restart ETHOS and review Lua errors in Info. |
| Empty RX meters | Individual method/source/capacity, Preview Off. |
| Unknown fuel after data gap | Missing flow cannot be reconstructed; confirm a real refill. |
| No counted flight | Logging, ignition, normalized throttle, power/time gates; diagnostics. |
| OFF does not create another flight | Intentional; Finish flight / Refuel between sorties. |
| No image | Correct model path, RGB/RGBA 8-bit PNG and suitable dimensions; Suite Image Manager. |

[Installation](GasDeck.md) | [Home](../README.md)
