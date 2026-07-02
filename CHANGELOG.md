# Changelog

All notable changes to SnubWorks are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/) and [Semantic Versioning](https://semver.org/) (pre-1.0: minor = feature round, patch = fixes/balance).

> **Versioning reset.** The app was renamed SNUB FORCE → SnubWorks and moved
> to production (TEAMFORCE VPS, `snubworks.teamsnubbing.com`) at this point.
> Version numbering restarts at 0.1.0; the SNUB FORCE 0.1–0.6 history below is
> prologue, kept for reference.

## [0.3.0] — 2026-07-02

Visual-fidelity pass: the rig now reads component-by-component as a real HWO
snubbing stack, keeping the low-poly style. No physics/gameplay changes; all
anchor points (slip heights, stroke, BOP envelope, JH waypoints) untouched.

### Added
- **Guy wires / tag lines** — 11 instanced cables (4 crown stays to the rail
  corner posts, 7 ground guys to instanced deadman anchors), routed so nothing
  crosses a rail or overhangs the cutaway.
- **Jack frames** — bold-orange cylinders + chrome rods; instanced stationary
  frame (corner columns + top spreader) and a traveling frame (cheek plates +
  instanced rod-guide sleeves) that visibly rides the stroke.
- **BOP stack articulation** — casing head, drilling spool with side outlets,
  bolted inter-ram flanges, 32 instanced flange bolts, weathered `redRust`
  lower stack, cellar collar walls around the base.
- **BOP-access platform (y≈5.6)** — railed grating landing around the jack
  base with hazard kickplates, plus ground→platform and platform→basket
  ladders (instanced rungs).
- **Hose & cable bundles** — three tube runs from the HPU ground lines up the
  back-left corner into the jack and basket console.
- **Work lighting** — mast floodlight fixture + warm shadow-free point light
  over the basket (sun remains the only shadow caster).

### Changed
- Orange/red materials tuned toward painted steel (lower roughness/metalness).

Perf: ~+27 mesh draw calls + 10 InstancedMesh + 1 non-shadow light for the
whole pass; repeated parts (cables, bolts, posts, rails, rungs, sleeves,
columns) are all instanced.

## [0.2.0] — 2026-07-02

Visual/physics fixes to the v0.1.0 gin-pole rework, requested after seeing it
live: the crane and mast bracing were clipping through the basket.

### Fixed
- **Winch now hangs from the gin pole itself** — removed the separate,
  disconnected boom/tip/brace/sheave assembly; the winch line hangs from
  `GIN_CROWN`, the crown sheave at the actual top of the mast (the tallest
  object on the rig), instead of a floating structure beside it.
- **Basket clipping** — removed the ground guy wires and low A-frame braces
  that cut straight through the basket rails and floor; the gin pole is now
  self-supporting, integrated into the package (no ground rigging).
- **Solid-floor clipping** — added a `framedFloor()` helper that cuts a real
  1.7×1.7 bore hole through both the structural basket floor and the grating
  overlay, so the pipe/joint/tongs passing through the well centre no longer
  punch through "solid" deck.

### Added
- **Power tongs** — a second, shorter tong arm at the back-left basket
  corner carries a red power-tong body (hydraulic side arm + jaw plates)
  that swings in on a pivot to engage the pipe whenever a connection is
  being made or broken (`X`), easing back to parked the rest of the time.

## [0.1.0] — 2026-07-02

First SnubWorks-branded release, deployed to production on the TEAMFORCE VPS.

### Added
- Rebrand: SNUB FORCE → **SnubWorks** (title, topbar, title card, docs).
- **PIN access gate** (default `8326`), TeamForce-style overlay; unlocks per
  browser session via `sessionStorage`.
- **Skip Tutorial** — button on the title screen and inside the tutorial
  overlay itself.
- **Dev pressure-freeze button** (topbar) — halts wellhead pressure drift,
  surge/swab, kick escalation, and event ramps so other systems can be
  tested without fighting the gauge. Toggle + toast feedback.
- Initial gin-pole/BOP visual pass toward the reference rig photo: red
  christmas-tree livery on the BOP/annular stack, gate-valve handwheels,
  and a tall single mast replacing the two short angled poles (refined
  further in 0.2.0 after clipping was spotted live).
- **Versioning** — `VERSION` constant rendered bottom-right; this file
  going forward. major.minor.patch: patch = fixes/tuning, minor = feature
  round, major = breaking/structural overhaul.
- Docker/Caddy production deployment on the TEAMFORCE VPS, alongside
  TeamForce, at `https://snubworks.teamsnubbing.com` (see `deploy/DEPLOY.md`).

## [0.4.1] — 2026-06-13 (SNUB FORCE)

Visual QA & realism tuning of the 0.4.0 additions. Positions/scales/rotations only — no new systems.

### Fixed
- **Winch cable topology** — raised the crane boom/sheave (`tip.y` → `BASKET_Y+4.0`, sheave ≈16.5) so it sits above the joint's full travel; the hoist line now always runs *downward* from the sheave to the load instead of pointing up at the aligned position.
- **Pickup arc** — the joint is now drawn in under the sheave as it stands vertical (`lift` → `{6.5,8.5,-3.2}`) for a more natural hoist, then swings to well centre.
- **Final alignment** — raised the stab position (`align.y` 11.4 → 12.0) so the joint bottom lands in the slip-bowl region (~7.9) rather than hanging short; elevators unlatch and the winch line goes slack once the joint is stabbed (slips take the load).
- **Branding proportions** — jack-base decal resized to its plate (0.62 → 0.24 tall, no overhang); basket brand banner lowered to hang from the top rail.
- **Floating detail** — corner work lights seated onto the posts; pipe-rack second row seated on the first.
- **Lease layout** — moved two work-light towers from `z=+4` (in front of the cut plane, floating off the pad) to behind it, on the gravel.
- **Camera pan bounds** — `clampCam` now also bounds the focus point (`tx/ty/tz`) so panning can't lose the scene.

## [0.4.0] — 2026-06-13

Realism & immersion pass — environment, branding, joint handling, and camera. No physics or balance changes.

### Added
- **"Jack in Black" livery** — black/yellow branding across the snubbing unit. Jack base and traveling plates repainted black with hazard-stripe trim, yellow accent collars on the hydraulic barrels, and `JACK IN BLACK` canvas-texture decals on the jack base, basket rail, accumulator skid, and equipment trailer. New `makeBrandedMaterial()` plus hazard/grating/brand-decal texture helpers.
- **Detailed work basket (`createBasketDetails`)** — grating floor, yellow toe-boards/kickplates, mid-rails, a control console with levers/knobs and indicator lights, draped hose bundles, a toolbox, and corner work lights — giving clear visual separation between the traveling assembly, basket, jack frame, and slip bowl.
- **Oilfield lease environment (`createLeasePad`)** — gravel lease pad with rig mats, an accumulator (BOP control) skid with nitrogen bottles, a pump/pressure-control skid, a guyed flare stack with a flickering flame + light, snaking hose runs, safety cones/barricades, work-light towers, and a branded equipment trailer. All kept behind the cut plane so the underground cutaway stays unobstructed.
- **Catwalk & pipe rack (`createCatwalkAndPipeRack`)** — a V-trough catwalk with a V-door ramp and a pipe rack holding stacked joint inventory beside the unit.
- **Add Joint sequence** — `ADD JOINT` button (and `J` key) drives a staged pickup animation through `idle → attaching → lifting → swinging → aligned`, with pickup elevators, a crane boom + hanging sheave block, and a dynamic winch line (`createJointHandlingSystem` / `updateJointHandling`). A HUD status readout reports the current handling state; completed joints increment a per-shift "staged" tally. Purely cosmetic — it does **not** touch the depth/joint scoring tally.
- **Enhanced camera (`createCameraControls` / `setCameraPreset`)** — smooth eased orbit, zoom, right-drag/Shift pan, and reset, plus preset view buttons (Overview, Basket, Wellhead, Catwalk, Cutaway). The idle title-screen auto-spin is preserved until the user takes control.

### Changed
- Animated emissives (flare flame, work lights) flicker via a shared `flickerMats` pass in the render loop.

## [0.3.0] — 2026-06-10

### Added
- **Four slip sets** — heavy + snub (inverted) slips at both the traveling plate and the stationary basket, with distinct 3D wedges (yellow = heavy, blue = snub). Heavy slips only carry pipe-heavy string; snub slips only restrain pipe-light string — the wrong type for the load won't hold, with specific runaway warnings/fail reasons. Keys: `Q/A` stationary, `E/D` traveling. Auto mode sets both types at a station (safe through neutral-point transitions); a toast warns when the string crosses the neutral point.
- **Annular closing pressure control** — slider + `Z/X` keys with a live REQUIRED value that tracks wellhead pressure. Under-squeezed: gas leaks past the element (particles, hiss, seal wear, slow pressure bleed-down). Over-squeezed: friction wear while stripping.
- **Gas release at tool joints** — every collar passing through the annular vents a visible puff with a synthesized hiss; much larger when the annular is leaking.
- **Realistic joint tally** — joints are generated per level at ~10 m (32.8 ft) each with ±0.5 m variation. Joint counting, scoring, well-diagram ticks, and 3D collar positions all derive from the same table.
- **Slips refuse to close on a tool joint** — manual attempts are rejected with a warning; the auto sequencer nudges the jack (or the pipe) to clear the collar before setting.

### Fixed
- **Pipe/collar animation direction** — tool-joint collars previously moved opposite to actual pipe travel; they now sit at their true positions along the string and move with it.

### Changed
- Runaway grace period 0.9 s → 1.1 s to account for the richer slip decisions.
- Slip animation logic simplified to one linear actuator per wedge set.

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
