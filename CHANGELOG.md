# GasDeck change log


## 2026.10-v7 - release, 2026-10-24

- Add optional Digital Engine instruments under Appearance > Display style; Deck remains the default for existing and new models.
- Give Deck an instrument layout when Image source is Hidden; retain the familiar photo layout and upright batteries when a picture is selected.
- Keep the model-picture choice independent of style. Image errors and unavailable telemetry retain their instrument space.
- Require a full-screen widget area relative to the radio's LCD; show a setup notice in split areas and restore instruments when full-screen.
- Keep engine count, RPM displays and temperature displays independent, with individual RX reserves separate from total RX current and consumption.
- Retain calculation methods, source selections, acceptance, sessions, logging, alarms and the current menu background hold.
- Read earlier valid model settings; keep a complete pre-upgrade backup for returning to pre-Digital releases.

## 2026.10-v6 - release, 2026-10-11

- Install and upgrade using a single ZIP through FrSky Suite Lua library or manual copying.
- Show the installed version and release information in Suite.
- Keep the background still while the Home menus are open, including during touch scrolling, with a 30-second limit. Telemetry, alerts and flight logging continue.
- Keep five Home-menu choices; open Diagnostics from the bottom-right button in Flight log and return to Dashboard with RTN.
- End the flight on valid ignition OFF, retain a qualified log and let the next ignition ON start a new qualification. Unknown ignition remains a pause.
- Remove Finish flight and move Reset live peaks to Configure widget > Flight session.
- Reduce drawing work and update the illustrated guides for the menus and installation.
- Settings and flight-count formats are unchanged.

## 2026.10-v5 - release, 2026-10-09

- Balance the ignition and flight-time header; enlarge RX battery icons and percentages, with chemistry and cell count shown in configuration.
- Keep battery percentages clear; explain voltage estimates in the selected RX battery's configuration.

## 2026.10-v4 - release, 2026-10-09

- Renew ETHOS focus while the selected widget is visible, retaining the radio's standard menus.

## 2026.10-v3 - release, 2026-10-07

- Confirm Refuel with the model switched off or ignition ON; explain when an active counted flight blocks it.
- Register offline Refuel and wait for a valid fuel reading before showing the estimate.
- Grey out unused configuration fields and simplify the radio settings.
- Add an illustrated TD SR18/AES II walkthrough, including a calculated RX Consumption sensor recipe.
- Fix an intermittent source-name error and a false unknown-capacity reading after switching consumption sensors.
- Handle source and audio updates reliably when closing the widget or changing its settings.
- Regression and native simulator checks passed on ETHOS 1.6.6 and 26.1.2; physical-radio testing of the final candidate passed.

## 2026.10-v2 - release, 2026-10-06

- Add ETHOS 1.6.6 compatibility.
- Remove historical radio-test information and internal settings/counter-file details from the radio configuration menu.
- Remove the Memory snapshot menu action.
- Simplify installation and configuration documentation.
- Regression and render checks passed; physical-radio testing passed on ETHOS 26.1.2.

## 2026.10-v1 - release, 2026-10-05

- Physical X20RS testing of the final RC1 build passed on 2026-10-05.
- First named GasDeck ZIP release; dual RX power, fuel, ignition, up to four RPM/four temperatures and three RF slots.
- Unexpected consumed-mAh decreases become unknown instead of showing a falsely full battery; safe manual acknowledgement and sustained-power-loss boundaries.
- Persistent alarm cooldowns, non-overlapping WAV playback and fair GasDeck RX/fuel scheduling.
- Strict percent units, preview/live isolation, guarded disposed/nil callbacks and bounded native text/source caches.
- Versioned checksummed per-model settings; no old scalar-settings migration. Reconfigure capacities, chemistry, limits, alarms and flight options. Source layouts and counter files retained.
- Shared final check: 252 named automated checks across both widgets; preceding native simulator run: 84 functional cases and 120 production frames, zero failures.
- GasDeck cold rendering optimized with unchanged graphics; PC simulator timings are not radio CPU guarantees.
- Release code differs from the radio-tested RC1 only in displayed version/test-status strings.
- ZIP includes scripts/GasDeck/main.lua, INSTALL.txt, LICENSE and NOTICE.md; no bytecode, private helpers, settings, logs or model records.

## 2026.10-dev2 (development snapshot; no release)

- Independent repository, English/Norwegian illustrated guides and technical notes.
- Physical-radio testing passed on 2026-10-05.
- VoltDeck-aligned header; smaller ignition plaque; larger TX below; source-kind line hidden.
- Ignition is also the flight gate; OFF pauses the same session instead of recounting.
- Independent LiPo/LiFe RX capacity; up to four measured RPM and four temperatures.
- Fuel from consumption, flow integration, remaining volume or percent.
- Per-model counter, retained last log, bounded RF history and optional delayed auto-open.
- No release, bytecode, private helpers or model state published.
