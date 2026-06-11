# Changelog

All notable changes to SNUB FORCE are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/) and [Semantic Versioning](https://semver.org/) (pre-1.0: minor = feature round, patch = fixes/balance).

## [0.2.0] — 2026-06-10

### Added
- **`LEVELS[]` data table** — five authored levels (name, pressure, target, objective, pipe preset, drift rate, events, scoring overrides) plus endless synthesized levels beyond the table.
- **`PIPES` presets** — pipe weight and piston area now drive string weight, well force, neutral point, *and* surge magnitude (bigger pipe displaces more fluid).
- **Trip-out objective** — pull a standing string to surface; joints "racked back" scoring, `STRING RECOVERED` win state, swab/pump pressure dynamic.
- **Mixed objective (round trip)** — snub to target, stage flips with messaging and +250 bonus, trip back out to win.
- **Well events engine** — scheduled `gasPocket`, `pressureDrop`, and `sandSlug` events with 3-second advance warnings and pressure ramps.
- **Pause/resume** — Esc key, topbar button, auto-pause on tab hide; overlay with Resume / Restart Level / Quit to Title.
- **7-step tutorial overlay** — covers traveling slips, stationary slips, jack stroke, neutral point, pipe-light vs pipe-heavy, pressure control; auto-shows on first play, re-openable from title.
- **Level persistence** — highest unlocked level saved; CONTINUE button on title screen.
- **Objective HUD readout** — topbar shows current stage goal (`SNUB IN → 240 ft` / `TRIP OUT → SURFACE`); stage-aware well diagram marker and 3D target ring.

### Changed
- Script reorganized into 11 numbered sections (config/levels, audio, state, scene, particles, HUD, input, game flow, sequencer, simulation, render).
- Scoring (joint points, level bonus, seal multiplier, par time) is now per-level data.

### Fixed
- **Neutral point inconsistency** — the NP marker previously used `P/4` while the LIGHT/HEAVY badge compared forces with different ratios; both now derive from the same pipe data (`NP = P·area/weight`), so the marker and the badge always agree.

### Removed
- Dead code: `phaseT`, unused `settled` helper, no-op branch in jack logic, module-level `lastJoints`, `window._wellGlow` global (now scoped).

## [0.1.0] — 2026-06-10

### Added
- Initial prototype: single-file Three.js snubbing simulator.
- Manual and auto slip/jack sequencing with grip interlocks and runaway detection.
- Wellhead pressure management (surge/swab, bleed/pump, gas drift, seal wear, blowout, kick).
- 3D scene: procedural BOP stack, hydraulic jack, work basket, earth cutaway with neutral-point and target markers.
- 2D HUD: well diagram with NP marker, banded pressure gauge, force readouts, light/heavy badge.
- Synthesized audio (Web Audio, zero assets) with persistent sound toggle.
- Particles (gas, sparks, motion streaks), camera shake, fail/win overlays, high-score persistence.
