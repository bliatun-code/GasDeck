# GasDeck: illustrert konfigurasjonsguide

[Startside](../README.md) | [English](Configuration.md) | [Tekniske notater](GasDeck.md)

Alle avlesninger, topper, tellere og grafer er syntetiske. Extra NG 78-bildet er godkjent
av eieren som illustrasjon. Fire motorer/temperaturer er hypotetiske visningsoppsett.

## 1. Modell og utseende

Åpne **Configure widget > Model / appearance**. Modellnavnet følger ETHOS-modellen.
Eksemplet bruker **Engine brand = Great Power**, **Displacement = 38 cc**.
Konfigurasjonen vises én gang i grå/sekundær tekst under modellnavnet, som i VoltDeck.

| Felt | Valg og betydning |
| --- | --- |
| Engine brand / Displacement | Merke/kubikk, ikke motordatabase eller RPM-kalibrering. |
| Engine count | 1-4; uavhengig av antall synlige RPM-/temperaturfelt. |
| Background | Radio theme, Black eller Custom. |
| Background color / Accent color | Egne farger; temamodus følger radioen. Normal gyllen aksent er ikke varsel. |
| Font file | Valgfri ETHOS-støttet font; native fonter er reserve. |
| Image source / Image file | Selected model, Image file eller Hidden. Gjenbruk samme bildesti, ikke en ny kopi. |

![Modellinnstillinger](images/gasdeck-config-model.png)

TX står under den mindre tenningsplaketten. Flytidens størrelse/plassering følger
VoltDeck. Merke/kubikk gjentas ikke under modellbildet.

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

Gjenværende % = 100 x (kapasitet - brukt mAh) / kapasitet, begrenset til 0-100 %.
2500 mAh og 550 mAh brukt gir 78 %. Etabler/nullstill forbrukstelleren etter lading.
GasDeck kjenner ikke automatisk faktisk startladning og nullstiller ikke alle sensorer.

Ikke bruk samme samlede forbruksteller for begge pakker; belastningen kan fordeles ulikt.
Velg **RX total current / RX total consumed** under **RX / ignition** til midtfeltene.

![Batteriinnstillinger](images/gasdeck-config-battery-sources.png)

Grønn >40 %, gul <=40 %, oransje <=35 %, rød <=30 %. Ukjent gir nøytral tom måler
og --%, aldri oppdiktet fullt batteri. Spenningsverdiene er nøytrale.

### LiFe og EST

Foretrekk individuelt brukt mAh eller målt prosent. Voltage estimate merkes **EST** og
er grovt, særlig med LiFe og spenningsfall under belastning. Visningsgrenser: LiPo
4,20-3,30 og LiFe 3,65-2,80 V/celle; ikke anbefalte utladings-/alarmgrenser.
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

Bryter viser kommando, ikke bevis på fysisk tenning. CMD/SENSOR/DEMO-linjen er fjernet
for TX-plass; skillet finnes fortsatt i logikken. GasDeck er bare avlesning.
Refuel, Finish flight og nullstilling krever gyldig OFF.
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
motorturtall. Pulser/poler må settes riktig i sensor/AES/ETHOS. Vi viser målt mekanisk
RPM, ikke elektrisk KV-estimat. MAX er observert topp. Preview kan overstyre aktuell
verdi uten samsvar med kildebasert MAX; galleritopper er illustrasjoner.

**Temperature unit** velger Celsius/Fahrenheit. **Temp warning / Temp critical**
er normalt 150/180 grader Celsius, også med Fahrenheit-visning. Tilpass produsent og
sensorplassering; dette er eksempler, ikke anbefaling for GP38. Gul ved varsel, rød
ved kritisk grense, ellers normal tekst.

![Numerisk RPM](images/gasdeck-numeric-rpm.png)

![Tank/flow uten RPM](images/gasdeck-fuel-only.png)

## 5. Drivstoff og flowmeter

Angi faktisk **Tank capacity** og **Refill amount**, normalt 500 ml hver.
**Reserve / warning** er normalt 20 %, **Flow calibration** 100 %.

| Tank value from | Kilder | Beregning |
| --- | --- | --- |
| Capacity - consumed | Fuel used source | Påfylt minus forbruk siden bekreftet fylling. |
| Integrate flow | Flow source | Trapesintegrasjon; Refuel kreves etter omstart. |
| Remaining volume | Remaining source | Direkte gjenværende ml/liter. |
| Remaining percent | Remaining source | Sensorprosent; tankkapasitet gir vist volum. |

**Flow input units**: Auto, ml/min, L/min, ml/s. **Volume input units**: Auto, ml, L.
ETHOS ml/m betyr ml/min. Auto følger metadata; overstyr feilmerket kilde.
Flow, totalforbruk og gjenværende er ulike verdier. Kalibrering gjelder bare integrert flow.

![Drivstoffinnstillinger](images/gasdeck-config-fuel.png)

### Refuel og datagap

Ved bekreftet tenning OFF etablerer Refuel faktisk Refill amount og ny sesjon.
Det fyller ikke tanken fysisk eller nullstiller andre sensorer. Forbruksmetoden
lagrer startverdi; uventet tellernullstilling gjør estimatet ukjent, ikke fullt.
Før første bekreftelse antas startforbruk null: etabler riktig baseline før bruk.

Flowintegrasjon antar aldri full tank etter omstart. Bekreft faktisk fylling.
Datagap/tidsavbrudd over 2 s gjør estimatet ukjent frem til ny reell fylling.
Tapt forbruk kan ikke rekonstrueres. Direkte nivåsensor overstyres ikke av Refuel.
Kontroller montering, luftbobler, drivstofftype, kalibrering og måleområde for utstyret.

Tankens reservesegmenter er røde. Mengde/prosent blir rødt ved eller under valgt
reserve; normalt brukes aksentfarge, ikke batteriterskler.

![Lavt drivstoff og RX-farger](images/gasdeck-low-fuel.png)

## 6. Varsler

**Low fuel alert / Low RX alert** er normalt på; **Alert RX estimate** av.
Velg **Audio folder**, **Fuel WAV** og **RX battery WAV** individuelt.
**Repeat interval**: normalt 15 s, valgbart 1-600 s. PCM WAV: 32 kHz, mono, 16-bit.
Ugyldig/manglende fil gir tone. Felles avspillingslås hindrer overlapping.
Fuel følger reserve, RX <=30 %. Preview spiller aldri varsler. Ingen lyd følger pakken.

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
mens RSSI er nyttig for margin. 95 % er vårt tidlige visuelle merke, ikke universell
produsentalarm. Behold native varsler og bruk dokumentasjonen for din mottaker.

![RF-innstillinger](images/gasdeck-config-rf.png)

TD SR18 har to 2,4 GHz-antenner og én 900 MHz-antenne, men ikke nødvendigvis tre RF-verdier.
Firmware kan kombinere VFR. Ikke konstruer tredje kilde ut fra antall antenner.

## 8. Flysesjon

Logging er normalt av. Velg **Throttle source** og **Ignition status**, uten separat ARM.

| Felt | Standard og virkemåte |
| --- | --- |
| Flight minimum | 60 s samlet kvalifiserende tid; valgbart 60-3600 s. |
| Throttle gate / High throttle time | >=50 % normalisert gass i >=5 s; valgbart. |
| Throttle low/high (raw) | -1024/+1024 API-verdier, ikke skjermens -100/+100 %; omvendte endepunkter støttes. |
| Airborne gate | Valgfri; --- og Always on passerer. Ikke luftdetektor. |
| Power loss source | Overstyring; ellers holder én gyldig positiv RX-spenning sesjonen i live. |
| Power loss delay | 10 s sammenhengende bortfall; 3-120 s. |
| Auto-open log / Extra log delay | Av / 5 s; åpner én gang etter kvalifisert sesjonsslutt ved bortfall. |
| Flight time from / ETHOS timer | GasDecks kvalifiserende tid eller valgt ETHOS-timer. |

![Flyinnstillinger](images/gasdeck-config-flight.png)

OFF/ukjent pauser tid, men beholder statistikk/grafer. ON fortsetter uten ny telling.
Ett manglende RX-batteri avslutter ikke dobbelmating. Langt RF-bortfall kan ligne strømbortfall.
Med tilkoblede RX-pakker mellom turer brukes **Finish flight** eller reell **Refuel**, tenning OFF.

Siste kvalifiserte logg beholdes ved modellavslag og ny ukvalifisert kandidat.
Den erstattes først av neste kvalifiserte tur. RF-grafer inkluderer pauser; flytid
teller bare godkjente intervaller. Benktest kan fortsatt kvalifisere: filtre er ikke flybevis.

Auto-open venter Power loss delay pluss Extra log delay. Ny spenning eller manuelt
visnings-/innstillingsbytte avbryter. Sen aktivering åpner ikke eldre logger.
Manuell Finish/Refuel er ikke strømbortfalls-triggeren for automatisk visning.

![Syntetisk siste flylogg](images/gasdeck-flight-log.png)

## 9. Diagnose, meny og preview

**Flight diagnostics** viser rå/normalisert gass, tenning, airborne gate, strøm og
kvalifisering. Følg sperreårsaken; LOG DISABLED er ikke feil.
**Reset live peaks** tømmer aktuelle topper, ikke telleren. **Memory snapshot**
viser miljøets ledige minne, ikke isolert widgetforbruk.
**Reset flight count** gjelder modellen; avslutt aktiv sesjon med gyldig OFF først.

![Diagnose](images/gasdeck-diagnostics.png)

**Synthetic preview** viser oppdiktede verdier uten flytelling/varsler.
Slå av for ekte tester. Galleriets syntetiske historie er ikke flybevis.

## 10. Lagring og feilsøking

Innstillinger: opptil to alternerende sjekksumbeskyttede gc1*.cfg-spor per modell.
Teller: opptil to gd*.dat-spor. Spor opprettes ved skriving, ikke per flyging.
ETHOS lagrer kilder. Detaljert logg/grafer tømmes ved radioomstart.

| Symptom | Kontroller |
| --- | --- |
| Widget mangler | scripts/GasDeck/main.lua, omstart, Info-feil og gammel bytekode. |
| Tom RX-måler | Individuell metode/kilde/kapasitet; Preview av. |
| Ukjent fuel etter gap | Tapt flow kan ikke rekonstrueres; bekreft reell ny fylling. |
| Ingen flytelling | Logging, tenning, normalisert gass, strøm/tid; diagnose. |
| OFF skaper ikke ny flyging | Med hensikt; Finish flight / Refuel mellom turer. |
| Bilde mangler | Modellsti, RGB/RGBA 8-bit PNG og størrelse; Suite Image Manager. |

[Tekniske notater](GasDeck.md) | [Startside](../README.md)


## Sikkerhetsoppdatering, oktober 2026

Eieren bekreftet bestått fysisk X20RS-radiotest av de siste RC1-pakkene den 2026-10-05. Sluttkontrollen passerte 252 automatiske kontrollpunkter for begge widgetene samlet; den native simulatorprøven passerte 84 funksjonstester og 120 skjermtegninger. Dette er ikke generell kompatibilitets- eller sikkerhetssertifisering.

- Uventet nedgang i forbrukstelleren større enn 0,1 % av konfigurert kapasitet (minimum 1 mAh) gjør gjenværende kapasitet ukjent. Widgeten viser ikke automatisk fullt batteri ved en sensorreset.
- En valgt batterispenningskilde må være borte like lenge som konfigurert avslutningsforsinkelse før tilbakekomst tillater en ny tellerbaseline. Korte telemetrigap, ARM-/tenningspauser og demo frigir ikke sperren. Langt RF-bortfall kan likevel ligne batteribytte; dette er ikke en fysisk batteridetektor.
- Etter kontroll av faktisk lading og mAh-avlesning: meny **Accept battery counter...** i VoltDeck eller **Accept RX counters...** i GasDeck. Bekreftelse krever gyldig ARM AV eller tenning AV. Valget aksepterer avlesningen, men nullstiller ikke sensoren, endrer ikke faktisk lading og påvirker ikke flytellingen. Tankfylling i GasDeck er uavhengig.
- Prosentkilden må ha prosentenhet, eventuelt eksplisitt råkilde uten enhet men med %-enhetstekst. Volt eller ampere kan ikke brukes som prosent.
- Lydintervallet overlever korte tilbakekomster, manglende målinger og konfigurasjonsendringer. GasDeck gir RX første lydplass ved samtidige varsler, og veksler deretter mellom RX og drivstoff. Ingen WAV skal overlappe eller blokkere det andre varselet permanent.
- Demo endrer ikke reelle maksimumsverdier, batterisperrer eller tankintegrasjon. Uobservert flow-gap gjør fremdeles estimatet ukjent og krever ny bekreftet tankfylling.
- Lange tekster forkortes uten å kutte UTF-8-tegn. Tekstmåling har maksimalt 64 cacheoppføringer. Sensornavn oppdateres hvert femte sekund og ved kildebytte; sensorenheten følger kilden umiddelbart.

### Kompatibilitet og sikkerhetskopi

Denne hovedversjonen har bevisst ingen migrering av gamle innstillinger. Nye modellfiler bruker /scripts/vc3*.cfg i VoltDeck og /scripts/gc1*.cfg i GasDeck. Gamle vc*/gc*-filer blir verken lest, endret eller slettet; konfigurer de nye standardinnstillingene på nytt. Tellerfilene og det nåværende kildeformatet er uendret, slik at valgte kilder og flytellere kan beholdes uten import av gamle tallinnstillinger. Nye innstillingsfiler bruker VD5/GD2 og eksplisitt skjema 1; kildeheaderne forblir VD4/GD1. Ugyldige og ukjente fremtidige skjemaer overskrives ikke. Behold sikkerhetskopier og kontroller kapasitet, kjemi, skalaer, varsler og flylogggrenser på radioen. GasDeck flytter ikke reservert ARM til tenning. Private testhjelpere og modellspesifikke innstillinger følger ikke widgetpakken.
