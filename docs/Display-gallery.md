# GasDeck — display and telemetry gallery

[Home](../README.md) | [Norsk](Visningsgalleri-norsk.md) | [Configuration](Configuration.md)

Genuine **800 × 480 captures from the X20RS simulator, ETHOS 26.1.2**, running stable GasDeck 2026.10-v7. Instruments and aircraft images are drawn by the app in the simulator. Telemetry values are controlled illustrations; no physical receiver or sensor was connected. The settings beneath each example explain how to configure that view.

## Deck and Digital, with and without a picture

<table>
<tr>
<td><a href="images/native-gasdeck-deck-photo.png"><img src="images/native-gasdeck-deck-photo.png" alt="Deck / model picture" width="400"></a><br><b>Deck / model picture</b></td>
<td><a href="images/native-gasdeck-deck-hidden.png"><img src="images/native-gasdeck-deck-hidden.png" alt="Deck / Hidden" width="400"></a><br><b>Deck / Hidden</b></td>
</tr>
<tr>
<td><a href="images/native-gasdeck-digital-photo.png"><img src="images/native-gasdeck-digital-photo.png" alt="Digital / model picture" width="400"></a><br><b>Digital / model picture</b></td>
<td><a href="images/native-gasdeck-digital-hidden.png"><img src="images/native-gasdeck-digital-hidden.png" alt="Digital / Hidden" width="400"></a><br><b>Digital / Hidden</b></td>
</tr>
</table>

Choose **Appearance > Display style = Deck / Digital**, then **Image source = Image file / Selected model / Hidden**. These captures use Image file. Selected model uses the same picture area with the ETHOS model image. Only explicit Hidden reallocates that area; an image error does not. Deck is the default. Style and picture choices never change sources or calculation methods.

## Choices in the app

Open the widget menu and choose **Configure widget > Appearance**. **Display style** and **Image source** are independent. Set source pickers to telemetry actually discovered on your radio; the illustrative readings do not assign sensors automatically.

<table>
<tr>
<td><img src="images/native-gasdeck-style-choices.png" alt="Display style: Deck / Digital"><br><b>Display style</b></td>
<td><img src="images/native-gasdeck-image-choices.png" alt="Image source: Selected model / Image file / Hidden"><br><b>Image source</b></td>
</tr>
</table>

The main views use **Engine count = 1**, **RPM displays = 1**, **Temp displays = 2**, **RPM style = Retro LCD**, **Temperature unit = Celsius**, **Tank value from = Integrate flow** and **RX1/RX2 Remaining from = Consumed mAh**. Both RX packs are **LiPo / 2 cells / 2500 mAh**, tank capacity is **1000 ml**, **Flow input units = Auto** (ml/min in this example), calibration **100%** and reserve **20%**. **RF displays = 2** with VFR in percent. The four-engine views change to **Engine count/RPM displays/Temp displays = 4/4/4**, **Displacement = 20 cc** per engine and B-24 artwork; the other settings remain the same.

## Aircraft, readings and telemetry

The primary aircraft picture represents a **large single-engine acro model with a 120 cc twin-cylinder gasoline engine**: **Engine count = 1**, **RPM displays = 1**, **Temp displays = 2**. CHT L and CHT R are two cylinder-head probes, not two engines. The supplied Pilot-RC artwork illustrates this class of aircraft; no installed engine is asserted for that particular model.

The **B-24 scale example** uses four hypothetical 20 cc engines, four measured RPM channels and four CHT channels. The aircraft picture therefore matches the propulsion count. The tank remains one aggregate fuel instrument; it requires a common/combined fuel measurement covering the engines it represents.

| Program role | Readings represented in these examples | Suitable installation |
| --- | --- | --- |
| RX1 / RX2 voltage | Separate battery voltage — V | A receiver/power-management unit with both feeds measured |
| RX1 / RX2 consumed | Separate consumption counters — mAh | Independent current/consumption measurement per battery |
| RX total | Combined current — A; combined consumption — mAh | Measured aggregate current and its counter / ETHOS Consumption |
| RPM 1–4 | Independent mechanical RPM — rpm | AES II RPM inputs or compatible third-party engine telemetry |
| Temp 1–4 | Independent CHT probes — °C | AES II with probes suitable for the selected inputs, or compatible temperature telemetry |
| Flow | Instantaneous fuel flow — ml/min | AES II with a compatible flowmeter; select current flow, not average/maximum |
| Fuel used / remaining | Volume or remaining percent | Select only the source role required by Tank value from |
| Ignition | Actual status or a switch/channel command | A command is not proof that ignition power is present |
| RF / TX / timer | VFR %, transmitter V, model timer s | Discovered receiver/radio/model sources |

Main values: RX1 7.80 V / 87% / 325 mAh, RX2 7.60 V / 85% / 375 mAh, 2500 mAh per battery. Total consumption is 700 mAh; current 1.80 A. Tank 1000 ml, remaining 760 ml / 76%, flow 18.0 ml/min. Do not split a combined consumption source into two invented per-battery counters.

**Engine count**, **RPM displays** and **Temp displays** are independent. A single engine may have four probes; a multi-engine installation may have fewer sensors. Zero hides that instrument family without pretending a missing reading is zero.

See the [FrSky AES II description](https://www.frsky-rc.biz/ws/frsky-advanced-engine-suite-ii-aes-ii.html) and [FrSky AES II manual](https://www.flyingtech.co.uk/wp-content/uploads/2024/05/Advanced-Engine-Suite-II-Manual.pdf) for RPM, temperature and flow inputs and their electrical/probe requirements. AES II supports more temperature inputs than GasDeck's four display slots; select the probes you need. Third-party telemetry is usable when ETHOS exposes the required numeric role/unit. Verify protocol and input compatibility separately from selecting a display slot.

## RPM and temperature counts

All 25 combinations of 0–4 RPM and 0–4 temperature fields in Deck, with Hidden. Click an image for full resolution. Engine count follows the RPM count in these examples (minimum one engine); temperature count is independent. Single-engine examples with 3–4 temperatures represent extra measurement points, not an assertion about cylinders or engines.

<table>
<tr>
<td><a href="images/native-gasdeck-deck-rpm0-temp0.png"><img src="images/native-gasdeck-deck-rpm0-temp0.png" alt="0 RPM / 0 temperatures" width="150"></a><br><b>0 RPM / 0 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm0-temp1.png"><img src="images/native-gasdeck-deck-rpm0-temp1.png" alt="0 RPM / 1 temperatures" width="150"></a><br><b>0 RPM / 1 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm0-temp2.png"><img src="images/native-gasdeck-deck-rpm0-temp2.png" alt="0 RPM / 2 temperatures" width="150"></a><br><b>0 RPM / 2 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm0-temp3.png"><img src="images/native-gasdeck-deck-rpm0-temp3.png" alt="0 RPM / 3 temperatures" width="150"></a><br><b>0 RPM / 3 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm0-temp4.png"><img src="images/native-gasdeck-deck-rpm0-temp4.png" alt="0 RPM / 4 temperatures" width="150"></a><br><b>0 RPM / 4 temperatures</b></td>
</tr>
<tr>
<td><a href="images/native-gasdeck-deck-rpm1-temp0.png"><img src="images/native-gasdeck-deck-rpm1-temp0.png" alt="1 RPM / 0 temperatures" width="150"></a><br><b>1 RPM / 0 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm1-temp1.png"><img src="images/native-gasdeck-deck-rpm1-temp1.png" alt="1 RPM / 1 temperatures" width="150"></a><br><b>1 RPM / 1 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm1-temp2.png"><img src="images/native-gasdeck-deck-rpm1-temp2.png" alt="1 RPM / 2 temperatures" width="150"></a><br><b>1 RPM / 2 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm1-temp3.png"><img src="images/native-gasdeck-deck-rpm1-temp3.png" alt="1 RPM / 3 temperatures" width="150"></a><br><b>1 RPM / 3 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm1-temp4.png"><img src="images/native-gasdeck-deck-rpm1-temp4.png" alt="1 RPM / 4 temperatures" width="150"></a><br><b>1 RPM / 4 temperatures</b></td>
</tr>
<tr>
<td><a href="images/native-gasdeck-deck-rpm2-temp0.png"><img src="images/native-gasdeck-deck-rpm2-temp0.png" alt="2 RPM / 0 temperatures" width="150"></a><br><b>2 RPM / 0 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm2-temp1.png"><img src="images/native-gasdeck-deck-rpm2-temp1.png" alt="2 RPM / 1 temperatures" width="150"></a><br><b>2 RPM / 1 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm2-temp2.png"><img src="images/native-gasdeck-deck-rpm2-temp2.png" alt="2 RPM / 2 temperatures" width="150"></a><br><b>2 RPM / 2 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm2-temp3.png"><img src="images/native-gasdeck-deck-rpm2-temp3.png" alt="2 RPM / 3 temperatures" width="150"></a><br><b>2 RPM / 3 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm2-temp4.png"><img src="images/native-gasdeck-deck-rpm2-temp4.png" alt="2 RPM / 4 temperatures" width="150"></a><br><b>2 RPM / 4 temperatures</b></td>
</tr>
<tr>
<td><a href="images/native-gasdeck-deck-rpm3-temp0.png"><img src="images/native-gasdeck-deck-rpm3-temp0.png" alt="3 RPM / 0 temperatures" width="150"></a><br><b>3 RPM / 0 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm3-temp1.png"><img src="images/native-gasdeck-deck-rpm3-temp1.png" alt="3 RPM / 1 temperatures" width="150"></a><br><b>3 RPM / 1 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm3-temp2.png"><img src="images/native-gasdeck-deck-rpm3-temp2.png" alt="3 RPM / 2 temperatures" width="150"></a><br><b>3 RPM / 2 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm3-temp3.png"><img src="images/native-gasdeck-deck-rpm3-temp3.png" alt="3 RPM / 3 temperatures" width="150"></a><br><b>3 RPM / 3 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm3-temp4.png"><img src="images/native-gasdeck-deck-rpm3-temp4.png" alt="3 RPM / 4 temperatures" width="150"></a><br><b>3 RPM / 4 temperatures</b></td>
</tr>
<tr>
<td><a href="images/native-gasdeck-deck-rpm4-temp0.png"><img src="images/native-gasdeck-deck-rpm4-temp0.png" alt="4 RPM / 0 temperatures" width="150"></a><br><b>4 RPM / 0 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm4-temp1.png"><img src="images/native-gasdeck-deck-rpm4-temp1.png" alt="4 RPM / 1 temperatures" width="150"></a><br><b>4 RPM / 1 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm4-temp2.png"><img src="images/native-gasdeck-deck-rpm4-temp2.png" alt="4 RPM / 2 temperatures" width="150"></a><br><b>4 RPM / 2 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm4-temp3.png"><img src="images/native-gasdeck-deck-rpm4-temp3.png" alt="4 RPM / 3 temperatures" width="150"></a><br><b>4 RPM / 3 temperatures</b></td>
<td><a href="images/native-gasdeck-deck-rpm4-temp4.png"><img src="images/native-gasdeck-deck-rpm4-temp4.png" alt="4 RPM / 4 temperatures" width="150"></a><br><b>4 RPM / 4 temperatures</b></td>
</tr>
</table>
### Digital

<details>
<summary>0 RPM / 0 temperatures</summary>

![0 RPM / 0 temperatures](images/native-gasdeck-digital-rpm0-temp0.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 0**; **Temp displays = 0**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

<details>
<summary>0 RPM / 1 temperatures</summary>

![0 RPM / 1 temperatures](images/native-gasdeck-digital-rpm0-temp1.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 0**; **Temp displays = 1**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

<details>
<summary>1 RPM / 0 temperatures</summary>

![1 RPM / 0 temperatures](images/native-gasdeck-digital-rpm1-temp0.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 0**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

<details>
<summary>1 RPM / 1 temperatures</summary>

![1 RPM / 1 temperatures](images/native-gasdeck-digital-rpm1-temp1.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 1**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

<details>
<summary>1 RPM / 2 temperatures</summary>

![1 RPM / 2 temperatures](images/native-gasdeck-digital-rpm1-temp2.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

<details>
<summary>2 RPM / 2 temperatures</summary>

![2 RPM / 2 temperatures](images/native-gasdeck-digital-rpm2-temp2.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 2**; **RPM displays = 2**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

<details>
<summary>2 RPM / 4 temperatures</summary>

![2 RPM / 4 temperatures](images/native-gasdeck-digital-rpm2-temp4.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 2**; **RPM displays = 2**; **Temp displays = 4**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

<details>
<summary>3 RPM / 3 temperatures</summary>

![3 RPM / 3 temperatures](images/native-gasdeck-digital-rpm3-temp3.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 3**; **RPM displays = 3**; **Temp displays = 3**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

<details>
<summary>4 RPM / 4 temperatures</summary>

![4 RPM / 4 temperatures](images/native-gasdeck-digital-rpm4-temp4.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 4**; **RPM displays = 4**; **Temp displays = 4**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

## Four-engine example with matching aircraft artwork

<table>
<tr>
<td><a href="images/native-gasdeck-quad-deck-photo.png"><img src="images/native-gasdeck-quad-deck-photo.png" alt="Four-engine B-24 / Deck / picture" width="400"></a><br><b>Four-engine B-24 / Deck / picture</b></td>
<td><a href="images/native-gasdeck-quad-deck-hidden.png"><img src="images/native-gasdeck-quad-deck-hidden.png" alt="Four-engine B-24 / Deck / Hidden" width="400"></a><br><b>Four-engine B-24 / Deck / Hidden</b></td>
</tr>
<tr>
<td><a href="images/native-gasdeck-quad-digital-photo.png"><img src="images/native-gasdeck-quad-digital-photo.png" alt="Four-engine B-24 / Digital / picture" width="400"></a><br><b>Four-engine B-24 / Digital / picture</b></td>
<td><a href="images/native-gasdeck-quad-digital-hidden.png"><img src="images/native-gasdeck-quad-digital-hidden.png" alt="Four-engine B-24 / Digital / Hidden" width="400"></a><br><b>Four-engine B-24 / Digital / Hidden</b></td>
</tr>
</table>

## RPM presentation

<details>
<summary>Deck / Numeric RPM</summary>

![Deck / Numeric RPM](images/native-gasdeck-numeric-deck.png)

Settings: **Display style = Deck**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Numeric**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

<details>
<summary>Digital / Numeric RPM</summary>

![Digital / Numeric RPM](images/native-gasdeck-numeric-digital.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Numeric**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

## Fuel methods

<details>
<summary>Capacity - consumed</summary>

![Capacity - consumed](images/native-gasdeck-fuel-method-1.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Capacity - consumed**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

<details>
<summary>Integrate flow</summary>

![Integrate flow](images/native-gasdeck-fuel-method-2.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

<details>
<summary>Remaining volume</summary>

![Remaining volume](images/native-gasdeck-fuel-method-3.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Remaining volume**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

<details>
<summary>Remaining percent</summary>

![Remaining percent](images/native-gasdeck-fuel-method-4.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Remaining percent**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

## RX battery methods

<details>
<summary>Consumed mAh</summary>

![Consumed mAh](images/native-gasdeck-rx-method-1.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

<details>
<summary>Percent sensor</summary>

![Percent sensor](images/native-gasdeck-rx-method-2.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = % sensor / % sensor**.

</details>

<details>
<summary>Voltage estimate</summary>

![Voltage estimate](images/native-gasdeck-rx-method-3.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Voltage estimate / Voltage estimate**.

</details>

<details>
<summary>RX1 consumed mAh / RX2 voltage estimate</summary>

![RX1 consumed mAh / RX2 voltage estimate](images/native-gasdeck-rx-mixed.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Voltage estimate**.

</details>

## Temperature units

<details>
<summary>Fahrenheit temperature labels</summary>

![Fahrenheit temperature labels](images/native-gasdeck-fahrenheit.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**; **Temperature unit = Fahrenheit**.

</details>

## Theme and colors

<details>
<summary>Radio theme</summary>

![Radio theme](images/native-gasdeck-radio-theme.png)

Settings: **Display style = Deck**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**; **Background = Radio theme**.

</details>

<details>
<summary>Custom background/accent</summary>

![Custom background/accent](images/native-gasdeck-custom-theme.png)

Settings: **Display style = Deck**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**; **Background = Custom**.

</details>

## RF

<details>
<summary>Three independent RF displays</summary>

![Three independent RF displays](images/native-gasdeck-rf-three.png)

Settings: **Display style = Deck**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**; **RF displays = 3**.

</details>

## Missing data and warnings

<details>
<summary>Configured engine sources unavailable</summary>

![Configured engine sources unavailable](images/native-gasdeck-missing-telemetry.png)

Settings: **Display style = Digital**; **Image source = Hidden**; **Engine count = 1**; **RPM displays = 1**; **Temp displays = 2**; **RPM style = Retro LCD**; **Tank value from = Integrate flow**; **RX1 / RX2 remaining = Consumed mAh / Consumed mAh**.

</details>

## Other choices and source dependencies

This gallery covers the distinct display choices, rather than every combination of arbitrary colors, sensor names and readings. **Radio theme / Black / Custom**, an accent color and optional font can be set independently. Leave Font file blank for native ETHOS fonts. Full screen means the radio’s complete LCD, including at a lower resolution.

Each RX battery has **LiPo / LiFe**, its own cell count and method. Fuel methods are **Capacity - consumed / Integrate flow / Remaining volume / Remaining percent**. Match **ml or L** volume and **ml/min, L/min or ml/s** flow inputs to the actual source; the display uses ml and ml/min. RF has 1–3 actual sources. RPM/temperature limits, reserve, alerts and flight logging are covered in the configuration guide.

Inactive fields retain their values. A source may still be required for calculation, alarm or logging when a display is hidden. Missing measurements remain unknown, not zero or full. The actual Synthetic preview warning remains intact; turn Preview off for normal use. See the [configuration guide](Configuration.md) for the complete field reference and [NOTICE](../NOTICE.md) for aircraft artwork.

B-24: [charner1963, Wikimedia Commons / Openclipart, CC0 1.0](https://commons.wikimedia.org/wiki/File:Consolidated_B-24_Liberator.svg).
