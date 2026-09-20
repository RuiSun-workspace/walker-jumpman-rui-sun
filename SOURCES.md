# SOURCES — walker-jumpman-rui-sun

**Author:** Rui Sun · CSYE 7270, Fall 2026, Assignment 1

---

## 1. The starter

| Field | Value |
| --- | --- |
| Project | **walker-jumpman — "First Steps"** |
| Author | Nik Bear Brown (course instructor) |
| URL | https://github.com/nikbearbrown/walker-jumpman |
| Revision I started from | cloned 2026-09-18; imported unmodified as commit `bcde8bc` in this repository |
| License | **No LICENSE, COPYING or NOTICE file exists in that repository.** Used here as coursework, under the Assignment 1 instruction to begin from this starter. I am not asserting a license it does not state, and this is not a redistribution claim. |

The unmodified starter is commit `bcde8bc` of this repository, so `git diff bcde8bc..HEAD`
shows precisely what is mine and nothing else. The starter's own screenshots are preserved
separately under `evidence/starter-screens/` because the capture scripts overwrite
`evidence/screens/`.

### What the starter provided, and I kept

- The whole movement model and every value in `godot/features/player/tuning.gd`.
- The 18×28 collider, the input map, the `MENU/PLAYING/PAUSED/DYING/COMPLETE` state machine,
  the 0.55 s retry, the `contact_settle_ticks` phantom-death guard, unlimited retries.
- The original level geometry from x 0 to x 960 — three slabs, two steps, one spike cluster.
- 25 mechanics checks and 9 keyboard checks, all still present and unmodified.
- The HUD layout, the art palette, and the visual idiom I matched when drawing BEACON.
- Its design package (`GDD.md`, `GAME-BRIEF.md`, `LEVEL-DESIGN.md`, `ASSET-PLAN.md`,
  `PLAYTEST-PLAN.md`, `PRODUCTION-PLAN.md`, `BUILD-REPORT.md`, `DESIGN-REVIEW.md`,
  `DESIGN-STATUS.json`) — left in place, unedited, and not claimed as mine.

### Design ideas that are the starter author's, not mine

- **`MECH-03` optional cherries** (GDD §, twenty collectibles, "choose the risk"). Designed by
  the starter author and never implemented in the slice. Considered for this assignment and
  **not implemented**; see TEST-REPORT §6.3.
- The "read the landing, then jump" teaching idiom and the low-step obstacle pattern, which the
  Beacon Tower's pedestal reuses.

---

## 2. What is mine

All of it is original work in this repository; none of it is imported from anywhere.

| Thing | File | Note |
| --- | --- | --- |
| BEACON character art | `godot/features/player/player.gd` `_draw()` | Original Godot vector drawing — `draw_rect`, `draw_circle`, `draw_line`, `draw_colored_polygon`. **No sprite sheet, no imported image, no generated art.** |
| Beacon Tower geometry | `godot/levels/first_steps.json` | New solids, hazard, finish, hills and labels from x 1008 to 1664 |
| Data-driven drawing | `godot/game/session.gd` `_draw()` | Rewrite of the starter's hard-coded draw calls |
| Facing-aware eased camera | `godot/game/session.gd` `_update_camera()` | Replaces the starter's constant `+100` snap |
| Death feedback | `player.gd` + `session.gd` | Drawing state only |
| HUD progress from level data | `godot/ui/hud.gd` | Replaces the hard-coded `/852` |
| Reachability harness | `godot/tests/verify_reach.gd` | New |
| Character state captures | `godot/tests/capture_character.gd` | New |
| Collider-overlay tooling | `scripts/make-character-sheet.ps1` | New |
| 4 added mechanics checks | `godot/tests/test_game.gd` | Appended; nothing removed |
| Route fixture extension | `godot/tests/route_driver.gd` | 6 marks appended to the starter's 5 |
| Documentation | `CHANGE-BRIEF.md`, `TEST-REPORT.md`, `FRICTIONAL.md`, `SOURCES.md`, `README.md` | New |

**Assets:** none. No image, audio, font or model file was added to this project. Text is drawn
with `ThemeDB.fallback_font`, Godot's built-in default, exactly as the starter did.

---

## 3. Tools

| Tool | Version | Use | License / access |
| --- | --- | --- | --- |
| Godot Engine | `4.7.2.stable.official.ed1daf0bf` | Engine, headless test runner, viewport capture | MIT. Portable build from the official GitHub release `4.7.2-stable`, file `Godot_v4.7.2-stable_win64.exe.zip`, SHA-256 `731980F9608D61333E5BAF54A2EF17210ACC7A538446C0CB9969F002ACA1E953` |
| Claude Code (Claude Opus 5) | — | Pair programming; see §4 | Northeastern access. **No purchased API credits and no paid asset-generation service were used.** |
| Git | 2.x for Windows | Version control | GPLv2 |
| Windows PowerShell | 5.1 | Test running, image compositing via `System.Drawing` | Bundled with Windows |
| Brutalist `godot-waikthrough` skill | https://github.com/nikbearbrown/brutalist.art | Required explainer film workflow | **No LICENSE file exists in that repository.** Course-provided; used as instructed. |

---

## 4. Human and AI contribution

Claude Code was used throughout, as the assignment expects. Splitting it honestly:

### Decisions I made

- The BEACON concept, and specifically choosing a silhouette that **fits inside the 18×28
  collider** rather than one with ears or a scarf that would overhang it.
- Keeping the tower concept after the two-route fork was shown to be impossible, and accepting a
  challenge-led extension instead of weakening `tuning.gd` to make the fork fit.
- Writing `CHANGE-BRIEF.md` before any code was edited, and keeping it append-only.
- Moving the flag rather than the spikes when the beacon gate crowded the finish — moving the
  spikes would have pushed them into the landing zone.
- Deciding the camera must not pan vertically.
- **Deferring the cherry collectible** rather than adding scope before the graded documents were
  written.
- Every playtest observation in TEST-REPORT §3 is mine, from actually playing the build.

### What Claude did

- Located the drawing code, collider, level data, camera and finish logic on request.
- Derived the reach budget from `tuning.gd` and, from it, the vertical-budget proof that a
  two-lane fork cannot exist at this tuning (CHANGE-BRIEF R1). **I did not work that out myself;
  I checked the argument and accepted it.**
- Wrote the BEACON drawing code, the tower geometry, the data-driven draw rewrite, the camera and
  death-feedback code, the test harnesses and the capture tooling.
- Diagnosed the 32 Hz tread frequency as the cause of my "legs don't reverse" report, and
  proposed the larger drive sprocket as a static cue. The diagnosis was not what I expected —
  I assumed a sign error.
- Found three defects by inspecting rendered frames: the floating base, the detached tread mark,
  and the invisible snapped antenna.

### What I rejected or corrected

- **Rejected the two-route fork** promised in my own brief, once the geometry proved it out —
  rather than raising jump strength, which would have made it fit.
- **Rejected a lip spike bed** after measurement showed it cut a take-off window to 38 px with
  the previous jump's landing point sitting on the boundary.
- **Rejected adding a movement-altering power-up**, which would have contradicted the preserved
  tuning that the whole evidence chain rests on.
- Required that the two reachability-harness failures be fixed **in the test, not the level**,
  and that the failing runs stay in `evidence/`.

### What AI did NOT do

- It did not play the game. Every human playtest line in TEST-REPORT §3 is a real session.
- It did not invent a second playtester. There isn't one.
- It did not generate any art, audio, or imported asset.

Film credits — narration, beat sheet, and visuals — will be recorded here once the Brutalist
explainer is produced.

---

## 5. Collaborators

None. No other student contributed to this submission.
