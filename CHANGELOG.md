# GasDeck change log

## 2026.10-v1 - release, 2026-10-05

- Owner confirmed physical X20RS testing of the final RC1 build on 2026-10-05.
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
- Owner reported physical-radio testing passed on 2026-10-05.
- VoltDeck-aligned header; smaller ignition plaque; larger TX below; source-kind line hidden.
- Ignition is also the flight gate; OFF pauses the same session instead of recounting.
- Independent LiPo/LiFe RX capacity; up to four measured RPM and four temperatures.
- Fuel from consumption, flow integration, remaining volume or percent.
- Per-model counter, retained last log, bounded RF history and optional delayed auto-open.
- No release, bytecode, private helpers or model state published.
