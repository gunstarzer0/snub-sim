# TODO — Development Priorities

Categorized backlog. Roughly ordered within each category; ⭐ = next up.

## Gameplay
- [ ] ⭐ Level select screen (unlocked levels, per-level best scores)
- [ ] ⭐ Balance pass on levels 4–5 (big-bore surge rate vs bleed capacity is tight)
- [ ] More event types: stuck pipe (jack force spike), slip failure (forced re-grip), H2S alarm (timed mask penalty)
- [ ] Equipment upgrades between levels (faster jack, tougher seal, bigger bleed line)
- [ ] Combo/streak scoring for clean cycles (no warnings during a joint)
- [ ] Daily challenge seed (fixed level + leaderboard-ready scoring)

## Physics
- [ ] ⭐ Optional "realistic" mode: honest pipe specs (true lb/ft and OD areas) with deeper wells to match
- [ ] Gas law pressure model (volume/temperature) instead of linear drift
- [ ] Equalize/vent sequence when passing tool joints through the rams
- [ ] Pipe buckling limit when snubbing pipe-light (max snub force)
- [ ] Friction/drag varying with depth and dogleg
- [ ] Variable jack speed (analog input) instead of fixed rate

## Visuals
- [ ] Post-processing bloom for emissives (selective, performance-gated)
- [ ] Animated fluid in the cutaway (shader on the wellbore glow plane)
- [ ] Pipe bow/flex visual when snubbing against high force
- [ ] Operator figure in the basket with simple animations
- [ ] Weather states (rain, night floods) tied to level themes
- [ ] Damage decals on seal wear / overpressure

## UX
- [ ] ⭐ Mobile/touch layout (collapsible panels, larger hit targets, portrait support)
- [ ] Settings panel (volume slider, camera sensitivity, colorblind-safe gauge bands)
- [ ] Interactive tutorial (guided first cycle with highlighted buttons, not just text)
- [ ] Replay last fail (short state ring-buffer)
- [ ] Localized strings table (the copy is already centralized in a few places)

## Audio
- [ ] Engine/powerpack idle layer that follows hydraulic load
- [ ] Distinct alarm tones per danger type (overpressure vs kick vs runaway)
- [ ] Doppler/space on gas release effects
- [ ] Music stinger on level start / win (still synthesized, keep zero-asset)

## Technical Debt
- [ ] ⭐ Extract `src/sim` (physics + sequencer + events) into framework-free modules; unit-test headless in Node
- [ ] Pin Three.js version locally (vendor the file) to drop the CDN dependency for offline use
- [ ] Replace per-frame full canvas redraws (diagram/gauge) with dirty-flag redraws
- [ ] ESLint config + GitHub Action
- [ ] GitHub Pages deploy workflow on `main`
- [ ] Type annotations via JSDoc (editor intellisense without a build step)
