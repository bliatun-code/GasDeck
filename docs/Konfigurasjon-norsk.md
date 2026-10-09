# GasDeck: illustrert konfigurasjonsguide

[Startside](../README.md) | [English](Configuration.md) | [Installasjon](GasDeck.md)

Denne gjennomgangen bruker TD SR18 med to RX-batterier og AES II med én RPM- og
én temperaturvisning. Følg **Configure widget** fra toppen og ned.
Sensornavn kan endres i ETHOS; velg kilden med riktig måling og enhet.
Menybildene viser simulatorens felt uten tilkoblet TD SR18/AES II.
Tabellene angir sensornavnene du skal velge på din radio.
Visningseksemplene bruker eksempelverdier.
Felt som ikke brukes av valgt metode er grå og inaktive.
ETHOS' kildevelger kan også vise andre sensortyper; kontroller enheten før du velger.

Åpne widgetmenyen, rull ned og velg **Configure widget**.
Etter side- eller modellbytte kan første trykk velge widgeten og neste åpne
menyen. Widgeten fornyer ETHOS-fokus mens den er valgt og synlig.
Kort og langt trykk bruker fortsatt radioens vanlige menyer.

<table>
<tr>
<td><img src="images/gasdeck-widget-menu.png" alt="GasDecks widgetmeny"><br><b>Widgetmeny</b></td>
<td><img src="images/gasdeck-widget-menu-more.png" alt="Configure widget nederst i menyen"><br><b>Configure widget</b></td>
</tr>
</table>

![Innstillingsgrupper](images/gasdeck-config-model.png)

## 1. Model / appearance

Angi motorens **Engine brand**, **Displacement** og **Engine count**.
For dette eksemplet med én motor velger du **Engine count = 1**.
Behold **Image source = Selected model** for å bruke bildet til den aktive ETHOS-modellen.
La **Font file** stå tomt for radioens innebygde fonter.

## 2. RX battery 1, deretter RX battery 2

Sett **Chemistry** og **Cells** riktig for hvert batteri.

| Felt | RX battery 1 | RX battery 2 |
| --- | --- | --- |
| Remaining from | Voltage estimate | Voltage estimate |
| Voltage source | RxBatt1 — V | RxBatt2 — V |

Med denne metoden bestemmes gjenværende kapasitet fra spenning, batteritype og
celletall. Estimatet merkes **EST** og er omtrentlig, særlig for LiFe.
**Capacity**, **Consumed mAh** og **Percent source** er inaktive med denne metoden.
Samlet **RxCurrent** velges i neste avsnitt.

![RX battery 1 med Voltage estimate](images/gasdeck-setup-rx1.png)

![RX battery 2 med Voltage estimate](images/gasdeck-setup-rx2.png)

## 3. RX / ignition

| Felt | Velg |
| --- | --- |
| RX total current | RxCurrent — A |
| RX total consumed | Egen kalkulert Consumption-sensor, for eksempel RxConsuption — mAh |
| Ignition status | Tenningsbryteren, kanalen eller en faktisk statuskilde |
| Ignition ON above | Vanligvis 0; kontroller at både ON og OFF vises riktig |
| TX voltage | Radioens batterikilde, eller tomt felt for innebygd kilde |

**RxConsuption** er et navn på en sensor du oppretter, ikke en egen fabrikkmåling.
Du kan kalle den **RxConsumption** eller velge et annet nyttig navn.
Den viser samlet RX-forbruk og kan ikke fordele forbruket mellom batteriene.

### Hvis brukt mAh mangler

1. Åpne **Model > Telemetry**, oppdag **RxCurrent** og kontroller at den viser **A**.
2. Velg **Create calculated sensor > Consumption**. Har Telemetry fanen **Sensors**,
   åpner du først **+**-menyen.
3. Sett **Source = RxCurrent**, **Unit = mAh**, passende **Range** og et nyttig navn.
4. Slå på **Persistent** og la automatisk **Reset**-kilde stå tom.
5. Etter fullading av begge pakkene telleren måler, bruker du **Reset** i den
   kalkulerte sensorens redigeringsskjerm.
6. Velg denne sensoren under **RX total consumed** i GasDeck.

Ikke nullstill RX-forbruk ved tenningsendring eller RF-bortfall. Persistent beholder
avlesningen ved radioomstart; den kan ikke gjenskape forbruk mens strømmålingen manglet.
Se [ETHOS' Consumption-sensorer](https://ethos-doc.frsky-rc.com/model-setup/telemetry/#consumption-sensor).

![Kildefelter under RX / ignition](images/gasdeck-setup-rx-total.png)

## 4. AES engine sensors

| Felt | Velg |
| --- | --- |
| RPM displays | 1 |
| Temp displays | 1 |
| RPM 1 source | AES RPM 1 — r/m (rpm), noen ganger kalt AESRPM1 |
| Temp 1 source | AES temp. 5 — °C |
| Temperature unit | Celsius, eventuelt Fahrenheit |

**Temp 1** er første visningsfelt og kan vise AES-temperaturinngang 5.
Velg den tilkoblede sensoren som viser en rimelig temperatur.
Tilpass **RPM scale max**, **RPM red zone**, **Temp warning** og **Temp critical**
til motoren. Disse visningsgrensene styrer ikke motoren.

![Én RPM- og én temperaturvisning](images/gasdeck-setup-engine.png)

![Kildefelter for temperatur](images/gasdeck-setup-temperature.png)

## 5. Fuel / flowmeter

| Felt | Velg eller angi |
| --- | --- |
| Tank value from | Integrate flow |
| Tank capacity | Faktisk tankvolum i ml |
| Refill amount | Drivstoff i tanken etter fylling; ved full tank brukes Tank capacity |
| Flow source | AES flow — ml/min |
| Flow input units | Auto når sensoren viser ml/min (ETHOS kan skrive ml/m) |
| Flow calibration | 100 % til å begynne med; juster etter kontroll mot målt forbruk |
| Reserve / warning | Ønsket reserve, for eksempel 20 % |

Bruk **AES flow**, som er aktuell flow. **AES avg. flow** og **AES max flow** er
andre målinger og skal ikke brukes til integrasjonen.
**Fuel used source**, **Remaining source** og **Volume input units** er inaktive
med **Integrate flow**.

![Innstillinger for Integrate flow](images/gasdeck-setup-fuel.png)

### Refuel og datagap

Fyll tanken, sett **Refill amount** og velg **Refuel... > Confirm** i widgetmenyen
eller drivstoffinnstillingene. Slå av **Synthetic preview** først.

Bekreftelsen fungerer med en gang, også med avslått modell eller tenning ON.
Er sensoren frakoblet, er bekreftelsen registrert selv om tankmåleren fortsatt er
ukjent. Slå på modellen: estimatet vises når første gyldige flowavlesning kommer.
Forbruk før denne avlesningen kan ikke gjenskapes.

Refuel sperres mens en telt flyging fortsatt pågår; dialogen forklarer årsaken.
En pauset flyging avsluttes mens flytelleren og den kvalifiserte loggen beholdes.
Etter at flowmålingen har startet, gjør et uobservert gap estimatet ukjent frem til
ny bekreftet fylling. Bekreft faktisk fylling på nytt etter radio-/widgetomstart.
Refuel nullstiller ikke AES eller andre telemetrisensorer.

## 6. Alerts

Velg **Low fuel alert**, **Low RX alert** og ønsket **Repeat interval**.
**Alert RX estimate** er normalt av; slå det på bevisst for dette oppsettet med
spenningsestimat. Drivstoffvarsler følger **Reserve / warning**; RX-varsler bruker 30 %.

For talevarsler velger du **Audio folder**, **Fuel WAV** og **RX battery WAV**.
Ingen lyder følger pakken. Manglende eller ugyldig fil gir tone.

## 7. RF sources / limits

| Felt | Eksempel |
| --- | --- |
| RF displays | 2 |
| RF 1 source | RSSI 2.4G — dB |
| RF 1 profile | ACCESS / TD / TW |
| RF 2 source | RSSI 900M — dB |
| RF 2 profile | ACCESS / TD / TW |

La **Log RF 1 source / Log RF 2 source** stå tomme for å tegne de valgte RSSI-kildene.
Du kan i stedet velge **VFR 2.4G / VFR 900M** for å tegne gyldig rammerate i **%**.
RSSI-signalstyrke og VFR-rammelevering er forskjellige målinger.

![To RF-visninger med kildefelter](images/gasdeck-setup-rf.png)

## 8. Flight session

La **Enable log** stå Off hvis du bare ønsker instrumentvisningen.
For flytelling slår du det på og velger **Throttle source**; tidligere valgt
**Ignition status** er flygingens tenningsvilkår. Kontroller rå gassverdier i
**Flight diagnostics** før du setter **Throttle low/high (raw)**.

Standardkravene er 60 sekunder og minst 5 sekunder over 50 % normalisert gass.
Velg **Airborne gate** bare hvis du har en egnet kilde.
Tom **Power loss source** bruker én gyldig positiv RX-spenning.
Tenning OFF pauser samme sesjon; ON fortsetter uten å telle to ganger.

![Flysesjonsinnstillinger](images/gasdeck-setup-flight.png)

## 9. Preview og sluttkontroll

Behold **Synthetic preview** Off for reell telemetri.
Med modellen på kontrollerer du begge batterispenningene, samlet RX-strøm/forbruk,
RPM, temperatur, aktuell flow og RF-målinger. Bekreft Refuel etter fylling og
kontroller at drivstoffmengden tilsvarer **Refill amount** når gyldig flow er tilgjengelig.

## Avansert referanse

### Batterimetoder og sensortype

| Remaining from | Nødvendig måling | Bruk |
| --- | --- | --- |
| Voltage estimate | Pakkespenning i V; riktig batteritype/celletall | Omtrentlig kapasitet fra spenning, merket EST |
| Consumed mAh | Individuelt brukt mAh; riktig Capacity | Gjenværende kapasitet fra pakkens forbruk |
| Percent sensor | Individuell gjenværende kapasitet i % | Bruker oppgitt prosent |

**Voltage source** viser fortsatt pakkespenning og brukes til strømbortfall i flyloggen.
Navnet på kilden endrer ikke målingstype eller enhet.

Ikke halver samlet **RxConsuption** eller bruk verdien som forbruk for begge batterier.
Individuelt gjenværende fra brukt mAh forblir ukjent uten egen måling.
GasDeck beregner ikke mAh fra strømfeltene eller summerer individuelle tellere.

En kalkulert ETHOS **Percent**-sensor kan gi en normalisert **%**-kilde.
Er den basert på spenning, er den fortsatt et spenningsestimat: kontroller mapping
for tomt/fullt batteri og ikke behandle verdien som målt kapasitet. Endring av
**Range** på en rå spenningssensor alene gjør ikke avlesningen i V til gyldig prosent.
Se [ETHOS' Percent-sensorer](https://ethos-doc.frsky-rc.com/model-setup/telemetry/#percent-sensor).

Ved uventet nullstilling av individuell forbruksteller: kontroller faktisk lading
og mAh-avlesningene. Slå av preview, bekreft gyldig tenning OFF og velg
**Accept RX counters... > Confirm**. Det aksepterer begge avlesningene uten å
nullstille sensorene, sette kapasitet til 100 %, endre flytelleren eller fylle tanken.
Manglende eller ugyldige målinger forblir ukjente.

Batterifarger: grønn >40 %, gul ≤40 %, oransje ≤35 %, rød ≤30 %.
Ukjent viser en nøytral tom måler med **--%**. Spenningsverdiene er nøytrale.

### Andre drivstoffmetoder og enheter

| Tank value from | Kilde/type | Innstillinger som brukes |
| --- | --- | --- |
| Capacity - consumed | Fuel used source — samlet brukt ml eller L | Tank capacity, Refill amount, Volume input units; bekreftet startverdi |
| Integrate flow | Flow source — ml/min, L/min eller ml/s | Tank capacity, Refill amount, Flow input units, Flow calibration |
| Remaining volume | Remaining source — sensorens gjenværende ml eller L | Tank capacity og Volume input units |
| Remaining percent | Remaining source — sensorens gjenværende % | Tank capacity gjør prosent om til vist ml |

**Flow source / Flow input units** brukes også til FLOW-visningen i de andre metodene.
Flow, samlet forbruk og gjenværende volum er ulike sensortyper.
Auto følger oppgitt enhet; velg riktig overstyring hvis kilden er feilmerket.
**Flow calibration** påvirker bare integrert flow.

Med **Capacity - consumed** registreres Refuel uten telemetri og venter på den
første gyldige tellerverdien som nytt utgangspunkt. Tidligere forbruk kan ikke
gjenskapes. Uventet nedgang i telleren gjør estimatet ukjent.

**AES res. vol.** (ml) og **AES res. pect.** (%) kan velges for tilhørende metode
først når tankkapasitet og fyllings-/nullstillingsfunksjon er konfigurert på
AES-/ETHOS-siden. Kontroller avlesningene mot faktisk full tank før bruk.
Refuel i GasDeck endrer ikke dette eksterne tankoppsettet eller nullstiller målingene.
Bruk nullstillingsprosedyren som AES-fastvaren støtter.
Se [FrSkys AES II-manual](https://www.flyingtech.co.uk/wp-content/uploads/2024/05/Advanced-Engine-Suite-II-Manual.pdf).

Kontroller flowmeterets kalibrering, drivstofftype, montering, luftbobler og måleområde.
Tankens reservesegmenter og gjenværende mengde ved/under reserve er røde;
normalt brukes aksentfargen.

### Visning, bilder og lydvalg

RPM- og temperaturantall velges uavhengig, fra 0 til 4 hver. Flere visningsfelt
oppretter ikke sensorer. RPM-kalibrering gjøres i sensoren/AES/ETHOS.
MAX viser høyeste observerte verdi. Temperaturgrensene legges inn i °C,
også når temperaturen vises i Fahrenheit.

Bakgrunn kan være **Radio theme**, **Black** eller **Custom**.
Gyllen aksent er normalfargen. Bruk et RGB/RGBA 8-bit PNG-modellbilde;
store dimensjoner krever mer minne. Se [bilde- og fontoppsett](GasDeck.md#model-image-and-fonts).

WAV-filer bør være PCM, 32 kHz, mono, 16-bit. Repeat interval er 1–600 sekunder;
varsler venter til aktuell lyd er ferdig. Preview spiller ingen varsler.

### RF-profiler

| Profil | RSSI varsel / kritisk | VFR tidlig / lav |
| --- | --- | --- |
| ACCESS / TD / TW | 35 / 32 dB | 95 / 50 % |
| ACCST | 45 / 42 dB | 95 / 50 % |
| Custom | Egne dB-grenser | Egne %-grenser |

RSSI-skalaen er normalt 0–100 dB og styrer visningsområdet, ikke radioalarmen.
Ukjente RF-verdier er nøytrale. Velg bare kilder mottakeren faktisk rapporterer;
antenneantall bestemmer ikke antall målinger. Behold radioens egne varsler.

### Sesjonsslutt, diagnose og lagring

**Finish flight... > Confirm** krever preview Off og gyldig tenning OFF.
Valget avslutter sesjonen, beholder siste kvalifiserte logg og gjør klar for en ny
flyging uten å endre drivstoff eller flyteller. Bruk Refuel etter faktisk tankfylling.

Power loss delay er normalt 10 sekunder (3–120). Ett manglende RX-batteri avslutter
ikke sesjonen mens den andre spenningskilden er gyldig. Langt RF-bortfall kan ligne
strømbortfall. Valgfri **Auto-open log** venter denne tiden pluss **Extra log delay**
(normalt 5 sekunder); ny spenning eller manuelt visnings-/innstillingsbytte avbryter.
Manuell Finish/Refuel åpner ikke loggen automatisk.

Bare en kvalifisert flyging erstatter siste logg. Flytid teller kvalifiserende
intervaller; RF-grafer inkluderer pauser. **Flight time from** kan bruke en ETHOS-timer.
Benkkjøring kan kvalifisere; slå av logging under benkarbeid ved behov.

**Flight diagnostics** viser gass, tenning, airborne-/strømvilkår og sperreårsak.
**Reset live peaks** tømmer maksimumsverdier uten å endre telleren.
**Reset flight count** gjelder modellen; avslutt sesjonen med gyldig OFF først.
Widgeten viser tenningsstatus og styrer aldri tenning eller gass.

Innstillinger og flyteller lagres per modell; detaljerte logger og grafer tømmes
ved radioomstart. Ta sikkerhetskopi av SD-kort og modell sammen, og kontroller
kildene hvis du kopierer en modell.

### Feilsøking

| Symptom | Kontroller |
| --- | --- |
| Widget mangler | scripts/GasDeck/main.lua, omstart og Lua-feil under Info |
| Tom RX-måler | Valgt metode/kilde, batteritype/celletall eller Capacity, preview Off |
| Ukjent fuel etter Refuel uten telemetri | Bekreftelsen er registrert; slå på modellen og vent på gyldig valgt drivstoffmåling |
| Ukjent fuel etter flowgap | Tapt forbruk kan ikke gjenskapes; bekreft faktisk ny fylling |
| Ingen flytelling | Enable log, tenning, gassverdier og kvalifiseringskrav; diagnose |
| Tenning OFF starter ikke ny flyging | Finish flight eller Refuel mellom turer |
| Bilde mangler | Modellsti, RGB/RGBA 8-bit PNG og passende størrelse; Suite Image Manager |

[Installasjon](GasDeck.md) | [Startside](../README.md)
