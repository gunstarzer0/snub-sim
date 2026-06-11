# SNUB FORCE — Hydraulic Workover / Snubbing Simulator

An arcade-style 3D simulation of **hydraulic workover (snubbing) operations**: stripping pipe into and out of a live, pressurized well using a hydraulic jack, two sets of slips, and careful wellhead pressure management.

Built as a single static HTML file with [Three.js](https://threejs.org/) — no build step, no framework. Open `index.html` in a browser (or serve the folder with any static server) and play.

> ⚠️ **Not a training tool (yet).** Physics is deliberately arcade-simplified and gameplay-tuned. See the roadmap — realistic operations modeling is a later milestone.

---

## Gameplay

The well is under pressure and pushes up on the pipe's cross-sectional area. Pipe weight pulls down. The depth where these forces balance is the **neutral point (NP)**:

| State | Condition | Danger |
|---|---|---|
| **PIPE LIGHT** | string weight < well force (above NP) | Ungripped pipe **launches out of the hole** |
| **PIPE HEAVY** | string weight > well force (below NP) | Ungripped pipe **drops down the well** |

At least one set of slips must grip the pipe at all times. The jack strokes 10 ft; you move pipe by cycling grips:

**Snub-in cycle:** jack up empty → set traveling slips → release stationary slips → jack down (pipe goes in) → set stationary → release traveling → repeat.

Meanwhile, pipe movement displaces wellbore fluid: stripping **in** surges pressure up (bleed it off), pulling **out** swabs it down (pump it back up). Leave the green band too long and you wear out the annular seal, blow the BOP, or take a gas kick.

### Objectives (per level)

- `snub-in` — run pipe to target depth
- `trip-out` — pull the full string back to surface
- `mixed` — round trip: snub to target, then trip out

Levels also schedule **well events** (gas pockets, pressure drops, sand slugs) with a 3-second warning.

### Controls

| Input | Action |
|---|---|
| `W` / `S` (or ↑/↓) | Jack extend / retract |
| `Q` | Stationary slips set/open |
| `E` | Traveling slips set/open |
| `B` / `P` | Bleed / pump wellhead pressure |
| `Esc` | Pause |
| `M` | Sound toggle |
| Mouse drag / wheel | Orbit / zoom camera |
| **AUTO mode** | Rig sequences slips & jack; you manage pressure only |

---

## Architecture

Everything lives in `index.html`, organized into numbered sections:

| # | Section | Responsibility |
|---|---|---|
| 1 | **CONFIG & LEVELS** | Tuning constants, `PIPES` presets, `LEVELS[]` table, `getLevel()` (endless scaling) |
| 2 | **AUDIO** | `AudioFX` — fully synthesized Web Audio (hydraulic hum, slips, alarms, kicks); no asset files |
| 3 | **GAME STATE** | Single `st` object + derived physics (`upForce`, `stringWt`, `npDepth`, `stageInfo`) |
| 4 | **3D SCENE** | Procedural BOP stack, jack, traveling head, basket, earth cutaway, NP/target markers |
| 5 | **PARTICLES** | Pooled `THREE.Points` systems: gas, sparks, motion streaks |
| 6 | **HUD** | 2D canvas well diagram (NP marker, zones) + banded pressure gauge |
| 7 | **INPUT** | Hold-buttons, keyboard, manual/auto + direction toggles |
| 8 | **GAME FLOW** | `startLevel`, stage transitions, win/fail, pause/resume, tutorial overlay, persistence |
| 9 | **AUTO SEQUENCER** | 7-state slip/jack cycle state machine |
| 10 | **SIMULATION** | Per-frame physics: jack/slip interlocks, runaway detection, pressure dynamics, events, seal wear, kicks |
| 11 | **RENDER LOOP** | `requestAnimationFrame` → `update(dt)` → `refreshHUD(dt)` → Three.js render |

### Adding a level

Append an entry to `LEVELS` in section 1:

```js
{ name:'My Well', objective:'mixed',        // 'snub-in' | 'trip-out' | 'mixed'
  p0:850,                                   // starting wellhead pressure, psi
  target:270,                               // target depth, ft (snub-in / mixed)
  startDepth:0,                             // initial pipe in hole, ft (trip-out)
  pipe:'hw278',                             // key into PIPES
  drift:6,                                  // psi/s gas migration
  events:[ {t:50, type:'gasPocket', dP:250, dur:3, warn:'GAS POCKET'} ],
  scoring:{ joint:120, parTime:650 } }      // overrides merged onto SCORE_DEF
```

Event types: `gasPocket` / `pressureDrop` (pressure ramp of `dP` psi over `dur` s) and `sandSlug` (instant `seal` % damage).

---

## Development

### Branch strategy (solo developer)

- `main` — stable, playable releases only
- `develop` — active development; merge to `main` when a version ships
- `feature/<name>` — major features (e.g. `feature/multiplayer-hud`), merged into `develop`

### Commit conventions

[Conventional Commits](https://www.conventionalcommits.org/): `type(scope): summary`

- `feat:` new gameplay/visual/audio feature
- `fix:` bug fix
- `refactor:` restructuring without behavior change
- `balance:` tuning constants / level difficulty
- `docs:` README, CHANGELOG, comments
- `chore:` tooling, repo hygiene

Example: `feat(levels): add sour-gas event chain to level 4`

### Roadmap

| Milestone | Scope |
|---|---|
| **M1 — Prototype** ✅ | Single-file 3D arcade loop: jack/slips, pressure, NP, manual+auto, audio |
| **M2 — Core Gameplay** | Level select screen, balance pass, more event types, equipment upgrades, mobile layout, score persistence per level |
| **M3 — Realistic Snubbing Operations** | Real force/area math with honest pipe specs, gas laws for wellbore pressure, equalize/vent sequence through BOP rams, pipe buckling limits, variable stroke speeds |
| **M4 — Training Simulator** | Scenario editor, procedure checklists scored against IRP/industry practice, failure-mode drills, instructor mode, telemetry export |
| **M5 — Commercial Release** | Branding, licensing model, LMS/SCORM integration, multi-language, accessibility, hosted deployment |

### Future structure (when it outgrows one file)

```
snub-force/
├─ index.html              # shell only
├─ src/
│  ├─ sim/                 # simulation engine (pure logic, testable headless)
│  │  ├─ physics.js        # forces, NP, pressure model
│  │  ├─ sequencer.js      # slip/jack state machine
│  │  └─ events.js         # well event engine
│  ├─ render/              # Three.js scene, rig builder, particles, camera
│  ├─ ui/                  # HUD canvases, overlays, input bindings
│  ├─ audio/               # AudioFX synth engine
│  └─ levels/              # LEVELS data + pipe presets (JSON)
├─ assets/                 # textures/models/sounds if ever needed
└─ test/                   # unit tests for src/sim (no DOM/WebGL required)
```

The split is designed so the **simulation engine has zero DOM/Three.js dependencies** — it can be unit-tested in Node and reused for an instructor dashboard or headless scoring.

### GitHub Actions (future)

- **Lint:** ESLint on push to `develop`/PRs (`eslint src/`)
- **Test:** run headless sim tests (`node --test test/`) — possible once `src/sim` is extracted
- **Deploy:** on push to `main`, publish the folder to GitHub Pages (`actions/deploy-pages`) — the app is already static, so this is one workflow file
- **Release packaging:** on tag `v*`, zip the app and attach to a GitHub Release

---

## Running locally

No install needed:

```sh
# option 1: just open it
start index.html          # Windows

# option 2: any static server
npx http-server . -p 8347
```

Requires WebGL and an internet connection for the Three.js CDN.

## License

MIT — see [LICENSE](LICENSE).
