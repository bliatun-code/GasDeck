# GasDeck: illustrert konfigurasjonsguide

[Startside](../README.md) | [English](Configuration.md) | [Installasjon og bruk](GasDeck.md)

**GasDeck er prøvd på fysisk X20RS med modell under ETHOS 26.1.2.**

Visningseksemplene bruker eksempelverdier. Meny- og konfigurasjonsbildene viser
widgeten i ETHOS.

Åpne widgetmenyen for å velge **Flight log** eller **Flight diagnostics**.
Rull ned og velg **Configure widget** for å endre innstillinger.

<table>
<tr>
<td><img src="images/gasdeck-widget-menu.png" alt="GasDecks widgetmeny, øvre valg"><br><b>Widgetmeny</b></td>
<td><img src="images/gasdeck-widget-menu-more.png" alt="GasDecks widgetmeny, nedre valg"><br><b>Rull ned til Configure widget</b></td>
</tr>
</table>

## 1. Modell og utseende

Åpne **Configure widget > Model / appearance**. Modellnavnet følger ETHOS-modellen.
Visningseksemplene bruker **Engine brand = Great Power**, **Displacement = 38 cc**.
Merke og kubikk vises under modellnavnet.

| Felt | Valg og betydning |
| --- | --- |
| Engine brand / Displacement | Merke/kubikk, ikke motordatabase eller RPM-kalibrering. |
| Engine count | 1-4; uavhengig av antall synlige RPM-/temperaturfelt. |
| Background | Radio theme, Black eller Custom. |
| Background color / Accent color | Egne farger; temamodus følger radioen. Normal gyllen aksent er ikke varsel. |
| Font file | Valgfri ETHOS-støttet font; tomt felt bruker radioens innebygde fonter. |
| Image source / Image file | Selected model, Image file eller Hidden. |

![Modellinnstillinger](images/gasdeck-config-model.png)

Dette konfigurasjonsbildet viser standardvalgene: tomt motormerke, 60 cc, én motor
og **Radio theme**.

## 2. To separate mottakerbatterier

**RX battery 1** og **RX battery 2** har individuell kjemi, celler, kapasitet og kilder.
Standard: LiPo, 2S, 2500 mAh, Consumed mAh.

| Felt | Betydning |
| --- | --- |
| Chemistry / Cells / Capacity | LiPo/LiFe, 1-8 celler, 100-20000 mAh; match faktisk pakke. |
| Remaining from | Consumed mAh, Percent sensor eller eksplisitt Voltage estimate. |
| Voltage source | Pakkespenning; regulert utgang er ikke egnet som pakkeestimat. |
| Consumed mAh / Percent source | Individuelt brukt mAh eller gjenværende prosent. |
| Current source | Valgfri individuell strøm; samlet RX-strøm velges separat. |

Gjenværende kapasitet beregnes fra valgt kapasitet og hver pakkes forbruk.
2500 mAh og 550 mAh brukt gir 78 %. Kontroller forbrukssensoren etter lading
og nullstill den ved behov.
GasDeck kjenner ikke automatisk faktisk startladning og nullstiller ikke forbrukssensorene.

Uventet nullstilling av forbrukstelleren kan gjøre gjenværende kapasitet ukjent.
Kontroller faktisk lading og mAh-avlesningen før du velger **Accept RX counters...**
i widgetmenyen. Valget krever gyldig tenning **OFF** og **Synthetic preview** av.
Trykk **Confirm** for å akseptere begge RX-avlesningene. Det nullstiller ikke
sensorene, setter ikke ladingen til 100 % og endrer ikke flytelleren.
Drivstoffpåfylling bekreftes separat med **Refuel**.

Ikke bruk samme samlede forbruksteller for begge pakker; belastningen kan fordeles ulikt.
Velg **RX total current / RX total consumed** under **RX / ignition** til midtfeltene.

![Batteriinnstillinger](images/gasdeck-config-battery-sources.png)

Grønn >40 %, gul <=40 %, oransje <=35 %, rød <=30 %. Ukjent gir nøytral tom måler
og --%, aldri oppdiktet fullt batteri. Spenningsverdiene er nøytrale.

### LiFe og EST

Foretrekk individuelt brukt mAh eller målt prosent. Voltage estimate merkes **EST** og
er grovt, særlig med LiFe og spenningsfall under belastning.
**Alert RX estimate** er normalt av og må aktiveres bevisst.

![To LiFe-pakker](images/gasdeck-life-batteries.png)

## 3. Tenning og TX

Velg **Ignition status** som fysisk/logisk bryter, kanal eller faktisk statussensor.
**Ignition ON above** er normalt 0; ON krever verdi større enn grensen.
Kontroller begge stillinger med ekte data før flylogging.

- ON: grønn; øvrige vilkår kan kvalifisere flyging.
- OFF: rød; samme sesjon pauser.
- Manglende/ugyldig: nøytral --; aldri bekreftet OFF.

![Tenning OFF](images/gasdeck-ignition-off.png)

![Manglende telemetri](images/gasdeck-telemetry-unavailable.png)

En bryter viser kommandoen, ikke at tenningen fysisk er på. GasDeck viser status
og styrer ikke tenningen.
**Refuel...**, **Finish flight...** og **Accept RX counters...** krever gyldig tenning OFF.
**TX voltage** velger kilde eller tilgjengelig innebygd radio-batterikilde.

## 4. RPM og temperaturer

**AES engine sensors** setter **RPM displays** og **Temp displays** til 0-4 hver,
uavhengig. Velg faktiske **RPM 1-4 source** og **Temp 1-4 source**. Flere felt skaper ikke sensorer.

| Eksempel | RPM | Temperatur |
| --- | --- | --- |
| En motor / to målepunkter | 1 | 2 |
| Flere sylindre/komponenter | 1 | 4 |
| Fire motorer | 4 | 4 |
| Tank/flow uten RPM | 0 | 0 |

![En RPM og to temperaturer](images/gasdeck-single-engine.png)

![Fire temperaturer](images/gasdeck-four-temperatures.png)

![Fire motorer og tre RF-kilder](images/gasdeck-four-engines.png)

**RPM style** er Numeric eller Retro LCD. **RPM scale max** er normalt 10000 rpm,
**RPM red zone** 85 %. Visningsvalg er ikke turtallsbegrensning eller dokumentert trygt
motorturtall. Pulser/poler må settes riktig i sensor/AES/ETHOS. Visningen bruker målt
mekanisk RPM. MAX viser høyeste målte verdi.

**Temperature unit** velger Celsius/Fahrenheit. **Temp warning / Temp critical**
er normalt 150/180 grader Celsius, også med Fahrenheit-visning. Tilpass grensene
til motoren og sensorplasseringen. Gul ved varsel, rød
ved kritisk grense, ellers normal tekst.

![Numerisk RPM](images/gasdeck-numeric-rpm.png)

![Tank/flow uten RPM](images/gasdeck-fuel-only.png)

## 5. Drivstoff og flowmeter

Angi faktisk **Tank capacity** og **Refill amount**, normalt 500 ml hver.
**Reserve / warning** er normalt 20 %, **Flow calibration** 100 %.

| Tank value from | Kilder | Beregning |
| --- | --- | --- |
| Capacity - consumed | Fuel used source | Påfylt minus forbruk siden bekreftet fylling. |
| Integrate flow | Flow source | Forbruk beregnet fra flow; Refuel kreves etter omstart. |
| Remaining volume | Remaining source | Direkte gjenværende ml/liter. |
| Remaining percent | Remaining source | Sensorprosent; tankkapasitet gir vist volum. |

**Flow input units**: Auto, ml/min, L/min, ml/s. **Volume input units**: Auto, ml, L.
ETHOS ml/m betyr ml/min. Auto følger sensorenheten; overstyr feilmerket kilde.
Flow, totalforbruk og gjenværende er ulike verdier. Kalibrering gjelder bare integrert flow.

![Drivstoffinnstillinger](images/gasdeck-config-fuel.png)

### Refuel og datagap

Fyll tanken og sett **Refill amount** til påfylt mengde. Slå av preview og kontroller
gyldig tenning OFF. Velg **Refuel...** og trykk **Confirm** for å oppdatere
drivstoffestimatet og starte en ny flysesjon.
Det fyller ikke tanken fysisk eller nullstiller andre sensorer. Forbruksmetoden
regner fra forbruket ved bekreftet fylling. Bruk Refuel etter fylling, så beregningen
starter fra riktig forbruk og tankmengde. Uventet tellernullstilling gjør estimatet ukjent.

Flowintegrasjon antar aldri full tank etter omstart. Bekreft faktisk fylling.
Manglende flow kan gjøre estimatet ukjent frem til ny bekreftet fylling.
Tapt forbruk kan ikke rekonstrueres. Direkte nivåsensor overstyres ikke av Refuel.
Kontroller montering, luftbobler, drivstofftype, kalibrering og måleområde for utstyret.

Tankens reservesegmenter er røde. Mengde/prosent blir rødt ved eller under valgt
reserve; normalt brukes aksentfarge, ikke batteriterskler.

![Lavt drivstoff og RX-farger](images/gasdeck-low-fuel.png)

## 6. Varsler

**Low fuel alert / Low RX alert** er normalt på; **Alert RX estimate** av.
Velg **Audio folder**, **Fuel WAV** og **RX battery WAV** individuelt.
**Repeat interval**: normalt 15 s, valgbart 1-600 s. PCM WAV: 32 kHz, mono, 16-bit.
Ugyldig/manglende fil gir tone. Fuel følger reserve, RX <=30 %.
**Synthetic preview** spiller ikke varsler. Ingen lyd følger pakken.

## 7. RF-kilder og grenser

Velg 1-3 **RF displays** og faktiske kilder. Navn følger ETHOS, f.eks. RSSI 2.4G
eller VFR 900M; dB/% beholdes uten verdi. **Log RF 1-3 source** kan avvike fra
hovedskjermen; tomt valg gjenbruker feltets kilde.

| Profil | RSSI varsel/kritisk | VFR tidlig/lav |
| --- | --- | --- |
| ACCESS / TD / TW | 35 / 32 dB | 95 / 50 % |
| ACCST | 45 / 42 dB | 95 / 50 % |
| Custom | Egne dB-grenser per felt | Egne prosentgrenser per felt |

**RSSI scale min/max** bestemmer visningsområde, normalt 0-100 dB, ikke radioalarmer.
Normalt er aksentfarge, varsel gult, kritisk rødt og ukjent nøytralt.
VFR viser gyldige rammer, RSSI signalstyrke. VFR kan vise kvalitetstap tydelig,
mens RSSI er nyttig for margin. 95 % er widgetens tidlige visuelle merke, ikke universell
produsentalarm. Behold radioens egne varsler og bruk dokumentasjonen for din mottaker.

![RF-innstillinger](images/gasdeck-config-rf.png)

TD SR18 har to 2,4 GHz-antenner og én 900 MHz-antenne, men ikke nødvendigvis tre RF-verdier.
Firmware kan kombinere VFR. Ikke konstruer tredje kilde ut fra antall antenner.

## 8. Flysesjon

Logging er normalt av. Velg **Throttle source** og **Ignition status**, uten separat ARM.

| Felt | Standard og virkemåte |
| --- | --- |
| Flight minimum | 60 s samlet kvalifiserende tid; valgbart 60-3600 s. |
| Throttle gate / High throttle time | >=50 % normalisert gass i >=5 s; valgbart. |
| Throttle low/high (raw) | Endepunkter for valgt gasskilde, normalt -1024/+1024; kontroller mot diagnosen. Omvendte endepunkter støttes. |
| Airborne gate | Valgfri; --- og Always on passerer. Ikke luftdetektor. |
| Power loss source | Overstyring; ellers holder én gyldig positiv RX-spenning sesjonen i live. |
| Power loss delay | 10 s sammenhengende bortfall; 3-120 s. |
| Auto-open log / Extra log delay | Av / 5 s; åpner én gang etter kvalifisert sesjonsslutt ved bortfall. |
| Flight time from / ETHOS timer | GasDecks kvalifiserende tid eller valgt ETHOS-timer. |

![Flyinnstillinger](images/gasdeck-config-flight.png)

OFF/ukjent pauser tid, men beholder statistikk/grafer. ON fortsetter uten ny telling.
Ett manglende RX-batteri avslutter ikke dobbelmating. Langt RF-bortfall kan ligne strømbortfall.
Med tilkoblede RX-pakker mellom turer: slå av preview, kontroller gyldig tenning OFF,
velg **Finish flight...** og trykk **Confirm**. Det avslutter sesjonen og gjør klar
for en ny tur uten å nullstille flytelleren eller endre drivstoffmengden.
Bruk **Refuel...** når tanken faktisk er fylt.

Siste kvalifiserte logg beholdes ved modellavslag og ny ukvalifisert kandidat.
Den erstattes først av neste kvalifiserte tur. RF-grafer inkluderer pauser; flytid
teller bare godkjente intervaller. Benktest kan fortsatt kvalifisere: filtre er ikke flybevis.

Auto-open venter Power loss delay pluss Extra log delay. Ny spenning eller manuelt
visnings-/innstillingsbytte avbryter. Sen aktivering åpner ikke eldre logger.
Manuell Finish flight/Refuel åpner ikke loggen automatisk.

![Siste flylogg](images/gasdeck-flight-log.png)

## 9. Diagnose, meny og preview

**Flight diagnostics** viser rå/normalisert gass, tenning, airborne gate, strøm og
kvalifisering. Følg sperreårsaken; LOG DISABLED er ikke feil.
**Reset live peaks** tømmer aktuelle topper, ikke telleren.
**Reset flight count** gjelder modellen; avslutt aktiv sesjon med gyldig OFF først.

![Diagnose](images/gasdeck-diagnostics.png)

**Synthetic preview** viser oppdiktede verdier uten flytelling/varsler.
Slå av for levende telemetri.

## 10. Feilsøking

Innstillinger og flyteller gjelder valgt modell. Loggstatistikk og grafer tømmes
ved radioomstart. Ta sikkerhetskopi av modell og innstillinger før utskifting.

| Symptom | Kontroller |
| --- | --- |
| Widget mangler | scripts/GasDeck/main.lua, omstart og feilmeldinger under Info. |
| Tom RX-måler | Individuell metode/kilde/kapasitet; Preview av. |
| Ukjent fuel etter gap | Tapt flow kan ikke rekonstrueres; bekreft reell ny fylling. |
| Ingen flytelling | Logging, tenning, normalisert gass, strøm/tid; diagnose. |
| OFF skaper ikke ny flyging | Med hensikt; Finish flight / Refuel mellom turer. |
| Bilde mangler | Modellsti, RGB/RGBA 8-bit PNG og størrelse; Suite Image Manager. |

[Installasjon og bruk](GasDeck.md) | [Startside](../README.md)
