# TEST-REPORT — walker-jumpman-rui-sun

**Author:** Rui Sun · **Course:** CSYE 7270, Fall 2026, Assignment 1
**Source revision under test:** `9261070` — *Add death feedback and a facing-aware camera*
**Engine:** Godot `4.7.2.stable.official.ed1daf0bf` (the exact build the starter README names as tested)
**OS:** Windows 11 Home China, 10.0.26200 · GPU path: OpenGL 3.3 compatibility, NVIDIA RTX 3070 Laptop
**Starter:** [nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman)

Godot is not on PATH here; it is a portable build. Every command below is run as:

```
<godot>/Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://tests/<file>.gd
```

Capture scripts must run **without** `--headless` — they save the engine's rendered viewport.

---

## 1. Automated checks

All three suites at revision `9261070`, run 2026-09-20 in one sitting.

| Suite | Command | Result | Raw evidence |
| --- | --- | --- | --- |
| Mechanics | `--script res://tests/test_game.gd` | **29 checks / 0 failures** | `evidence/mechanics-1789928395.246.json` |
| Keyboard | `--script res://tests/test_keyboard.gd` | **9 checks / 0 failures** | `evidence/keyboard-1789928396.621.json` |
| Reachability | `--script res://tests/verify_reach.gd` | **9 jumps / 0 failures** | `evidence/reach-1789928662.842.json` |

`evidence/` also retains every earlier run, including the two that **failed**
(`reach-1789859412.664.json`, `reach-1789859855.182.json`). They are kept on purpose; see §5.

### 1.1 What changed in the mechanics suite, and what did not

The starter shipped 25 checks. All 25 are still present, unmodified, and passing. **No assertion
was deleted, loosened, or had an expected value adjusted.** Four were added for the two declared
behaviour changes:

| Added check | Why it exists | Observed |
| --- | --- | --- |
| `death-visual-is-drawing-only` | Declared change 5.4 must not move or re-enable the player | `dying: true`, `dying_tick: 11`, `flash: 0`, `moved: false`, still disabled |
| `death-visual-cleared-on-respawn` | The flag must not leak into the next attempt | `dying: false`, `dying_tick: 0`, `flash: -1`, state `PLAYING` |
| `camera-lead-follows-facing` | Declared change 5.3 must actually reverse | `lead_right: 53.49`, `lead_left: -57.10` |
| `camera-stays-inside-level` | Easing must never frame space outside the level | min `320.0`, max `1343.9995`, limit `1344.0` |

### 1.2 The route fixture was rewritten, and here is exactly how

`tests/route_driver.gd` drives a fixed input route. It was authored for the 960-wide starter
layout with `jump_marks = [138, 292, 424, 548, 712]` and could not reach a finish at x = 1584.

**What changed:** six marks appended — `900, 1020, 1110, 1220, 1330, 1420`. The original five are
untouched and still clear the starter's step, spikes and two gaps.

**How the new marks were chosen:** not by guessing. `tests/verify_reach.gd` sweeps the take-off x
of the real player in 2 px steps and reports the window that actually lands. Each mark sits
inside its measured window, and the fixture's header records which:

| Jump | Measured window | Mark used |
| --- | --- | --- |
| third slab → approach | x 890…956 (68 px) | 900 |
| approach → pedestal | x 1010…1094 (86 px) | 1020 |
| pedestal → step one | x 1096…1162 (68 px) | 1110 |
| step one → step two | x 1212…1264 (54 px) | 1220 |
| step two → summit | x 1324…1376 (54 px) | 1330 |
| summit → over the beacon gate | x 1408…1466 (60 px) | 1420 |

**A limitation of this fixture, stated rather than hidden:** the driver holds right forever and
can never stop or reverse. If a future edit makes a landing require backing up, this test fails
rather than silently passing. That is intentional.

### 1.3 The reachability harness

`tests/verify_reach.gd` is new. It reads **no value from `tuning.gd`**, so a level that only
passes because the jump was strengthened cannot pass it. Beyond the six jumps above it also
re-measures the two starter gaps (54 px and 70 px, both unchanged) and asserts a gate:

> **`chasm is not walkable` — 0 of 40 ground-level take-offs reached the far side.**

That is the check that the new section actually gates the finish rather than being optional
scenery.

---

## 2. Baseline comparison

The point of the baseline commit `be3c32f` was to make regressions provable. These values are
byte-identical between the unmodified starter and `9261070`, which is the evidence that the
character art, the camera change and the death feedback did not touch physics:

| Value | Baseline `be3c32f` | Now `9261070` |
| --- | --- | --- |
| `fixed-jump-and-no-double` → `rise_px` | 56.07470703125 | 56.07470703125 |
| `low-ceiling` → `minimum_feet_y` | 300.000274658203 | 300.000274658203 |
| `pause-freezes` → position | (64.0, 295.9253) | (64.0, 295.9253) |
| `pause-freezes` → elapsed | 0.133333333333333 | 0.133333333333333 |
| `twenty-retries` → `max_retry_ticks` | 34 | 34 |
| `keyboard-move` → x | 91.022216796875 | 91.022216796875 |
| Coyote / buffer boundaries | inclusive 6, expired 7 | inclusive 6, expired 7 |

Values that **should** differ, because the level is longer:

| Value | Baseline | Now |
| --- | --- | --- |
| `complete-real-route` → ticks | 325 | 576 |
| `complete-real-route` → jump marks used | 5 | 11 |
| `complete-real-route` → end position | (912.8837, 319.9253) | (1582.213, 199.9253) |
| `complete-real-route` → deaths | 0 | 0 |

---

## 3. Human playtest log

Played by Rui Sun at the keyboard, windowed, on the machine described in the header.
**There was no second playtester.** Every quote below is what was actually said at the time.

### Session 1 — 2026-09-18 — unmodified starter (`bcde8bc`)

Played the starter before writing a line of code, to have a real "before". Reached the flag;
movement, jump, pause and retry all behaved. Two observations, both about the **starter**:

> "相机跟随总体没什么问题，只有在开始和结束的时候没有跟随"
> (camera follow is fine overall, it just doesn't follow at the start and at the end)

> "尖刺撞上去会提示死亡，但是没有对应动画"
> (hitting the spikes prints a death message, but there's no matching animation)

Both were traced to specific lines and became CHANGE-BRIEF §1 Observations A and B, and then
declared changes 5.3 and 5.4.

### Session 2 — 2026-09-19 — after `522e6d1` (BEACON character)

Asked to check four things: left/right readability, airborne readability, whether the drawn
edge matches where Beacon can actually stand, and whether the light cone hides anything.

> "完全没有问题，继续下一步" (no problems at all, go to the next step)

Recorded honestly as a **blanket approval**, not as four individually confirmed items.

### Session 3 — 2026-09-19 — after `c2f2e50` (Beacon Tower)

> "最后的尖刺离终点有点近" (the last spikes are a bit close to the finish)

> "不论我向左或向右，腿都是按照向右的方式运动的，应该修改一下"
> (whichever way I move, the legs animate as if moving right — this should be fixed)

Both acted on in `3d7d43f`. See §5.

### Session 4 — 2026-09-19 — after `3d7d43f`

> "没什么问题了，继续下一步" (no more problems, go to the next step)

### Session 5 — after `9261070` (camera + death feedback) — **PENDING**

The build was launched and looked at, but the specific questions asked — is the death feedback
legible, does reversing direction make the camera uncomfortable, is the camera adequate during
the climb — **were not answered**, and the route/failure/replay pass below has not been run by
hand on this revision. Those rows are marked PENDING in §4 and this report is not final until
they are filled in with real answers.

---

## 4. Required check table

| Check | Evidence | Result |
| --- | --- | --- |
| **Startup and controls** — project runs; movement, jump, pause/resume, restart | `test_keyboard.gd` 9/9: `enter-start`, `keyboard-move`, `keyboard-jump`, `escape-pause`, `enter-resume`, `r-retry`, `enter-replay`, `pause-main-menu`, `menu-start-again`. Human sessions 1–4. | **PASS** |
| **Character appearance** — left/right, standing, jumping; no visual/collision mismatch | `evidence/screens/character/` — six engine-rendered states, plus `SHEET-collider-check.png` which draws the real 18×28 collider over the art. Human session 2. | **PASS** |
| **Extended route** — a normal route reaches both new landings and the relocated finish | `complete-real-route`: 11 marks, 576 ticks, 0 deaths, ends at (1582.213, 199.9253) on the summit. `verify_reach.gd` measures all six new jumps at 54–86 px. Screenshot `evidence/screens/05-tower.png`. | **PASS (automated)** · human pass **PENDING** |
| **Failure and recovery** — a real hazard or missed landing produces the expected retry; replay works after completion | `actual-spike-collision`, `fall-boundary`, `respawn`, `twenty-retries`, `duplicate-death-ignored`, `manual-restart-not-death`, `replay-idempotent`. Screenshot `evidence/screens/02-failure.png`. | **PASS (automated)** · human pass **PENDING** |
| **Camera and presentation** — the extension and landing/finish information stay visible and readable | `camera-stays-inside-level` (max 1343.9995 vs limit 1344.0), `camera-lead-follows-facing`. Screenshots `05-tower.png`, `04-complete.png`. Known limitation in §6. | **PASS (automated)** · human judgement **PENDING** |
| **Automated checks** — commands, results, failures and updates explained | §1 above, including the two genuine failures in §5.3 and the route-fixture rewrite in §1.2. | **PASS** |

---

## 5. Inspect-and-revise cycles

Five, all driven by an observation rather than by a crash.

### 5.1 — Beacon appeared to float above a detached base (found by looking at a frame)

Tucking the tracks on a jump moved `base_top` from −6 to −4 while the hull still ended at −6,
leaving a 2 px hole. The body read as hovering over its own base — a visual/collision misread on
exactly the axis the assignment scores. The hull bottom now follows `base_top`. Fixed in
`522e6d1` before that commit shipped.

### 5.2 — The eye read as a crescent, not an eye

The pupil was centred on the rim of the lamp disc, producing a "C". Moved inward to
`facing * 1.0`. Cosmetic, but the eye is the whole character concept.

### 5.3 — The reachability harness was green for the wrong reason, twice

Both failures are preserved in `evidence/reach-1789859412.664.json` and
`reach-1789859855.182.json`.

1. `attempt()` treated any state other than `PLAYING` as death. Touching the goal sets
   `COMPLETE`, so the summit jump — which lands on the flag — reported **36 of 36 fatal**. The
   jump had always been fine. Fixed in the test.
2. The "is the chasm walkable" gate allowed a 9 px collider overhang against a target starting at
   x = 1176, the exact right edge of the approach ground, so *landing back where it started*
   counted as crossing. Target moved to x = 1200. Fixed in the test.

**Neither was fixed by changing the level.** A green report that is green for the wrong reason is
worth as much as a red one, which is why the failing runs stay in `evidence/`.

### 5.4 — Human report: treads did not read as directional (session 3)

The cause was frequency, not sign. `fposmod(position.x * 0.6, 5.0)` does reverse with travel, but
a 5 px pattern at 160 px/s cycles at **32 Hz** — unresolvable, so it read as static texture in
both directions, and showed nothing at all standing still.

Two changes: geared down to roughly 7 Hz to match the starter's own leg cadence
(`sin(tick * 0.7)`, ≈ 6.7 Hz), and — the part that actually answered the complaint — the
**leading drive sprocket is now drawn larger than the trailing idler and carries the hub pin**, a
*static* cue that reads while standing still. Compare `SHEET-beacon-states.png` left and right rows.

While re-rendering to check this, a second defect appeared: a detached vertical line beside the
hull. Four tread marks were stepped through a 20 px cycle while the hull exposes only a 15 px
window, so the wrapped mark was drawn outside Beacon. Present since `522e6d1`; **no automated
check would ever have caught it.** Wrapped marks are now skipped.

### 5.5 — Human report: the beacon gate crowded the flag (session 3)

Measurable, and the harness had already recorded the symptom without my reading it: 30 of 30
successful take-offs over the gate reported `reached_goal`, meaning every completion happened in
mid-air and the tower had no landing beat at the top.

Width 1600 → 1664, summit 184 → 248 wide, finish x 1520 → 1584. Gate-to-flag is now 80 px.
`reached_goal` falls to **1 of 30** — the other 29 land on the summit and walk in. The take-off
window is unchanged at 60 px, so the jump is no harder; it just resolves on the ground.

### 5.6 — The broken antenna was invisible (found by looking at a frame)

The first death-feedback version folded the mast to `(-facing * 5.5, -21)`, which is *inside* the
lamp housing — and the housing is drawn later, so the snapped antenna could not be seen at all.
All 29 checks passed. It is now drawn after the housing, hinged back over the gallery, tip at
x = ±7.4, still inside the collider box.

**Pattern worth naming:** three of these six defects (5.1, 5.4's second half, 5.6) were invisible
to every automated check and only a rendered frame could catch them.

---

## 6. Known limitations

Stated plainly rather than presented as solved.

1. **The camera still goes static near the summit.** Widening the level did not remove session
   1's observation. The clamp pins the camera at `width − 320 = 1344`, which the facing-aware
   lead reaches at player x ≈ 1264, so roughly the last 320 px of the climb is a static shot.
   This is *correct* behaviour — the alternative is framing space outside the level — but it is
   a real limitation and the original complaint is only partly addressed.
2. **The camera never moves vertically.** `camera.y` is a constant 180. The tower fits inside the
   viewport by design (summit y = 200, flag y = 130, HUD bar ends at y = 74), so this is a
   deliberate constraint on how tall the level may ever get, not a solved problem.
3. **The extension is challenge-led, not choice-led.** CHANGE-BRIEF promised two converging
   routes. That is geometrically impossible with this tuning (CHANGE-BRIEF R1) and the level now
   has one route with five committed jumps. The starter's own unimplemented `MECH-03` optional
   cherries would supply the missing decision; they are not implemented here.
4. **One playtester.** Only the author has played this. No second person has been observed
   playing it, and none is claimed.
5. **The route fixture is not a human.** It holds right and jumps at fixed x positions. It proves
   a route exists; it does not prove a person can reliably repeat it.
6. **No export was built or tested.** Source only, run from the editor or the binary with
   `--path godot`.
7. **Intermediate duplicate test runs were kept, not curated.** `evidence/` contains several runs
   with identical results from the same code state. They are noise, but deleting evidence looked
   worse than keeping it.

---

## 7. Reproducing everything

```
# automated
<godot>/Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://tests/test_game.gd
<godot>/Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://tests/test_keyboard.gd
<godot>/Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://tests/verify_reach.gd

# rendered frames (must NOT be headless)
<godot>/Godot_v4.7.2-stable_win64.exe --path godot --script res://tests/capture_game.gd
<godot>/Godot_v4.7.2-stable_win64.exe --path godot --script res://tests/capture_character.gd
powershell -ExecutionPolicy Bypass -File scripts/make-character-sheet.ps1

# play it
<godot>/Godot_v4.7.2-stable_win64.exe --path godot
```
