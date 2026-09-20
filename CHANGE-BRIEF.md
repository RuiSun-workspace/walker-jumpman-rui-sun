# CHANGE-BRIEF — walker-jumpman-rui-sun

**Author:** Rui Sun · **Course:** CSYE 7270, Fall 2026, Assignment 1
**Written:** 2026-09-19, **before any gameplay or drawing code was edited.**
**Starter:** [nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman) — "First Steps" control/retry slice.
**Engine:** Godot 4.7.2.stable.official.ed1daf0bf (Windows 11).
**Baseline commits:** `bcde8bc` (unmodified starter) and `be3c32f` (my baseline test run).

> **Append-only record.** This document is a prediction, not a report. The text below
> is preserved as originally written. Everything I got wrong stays wrong on the page;
> corrections go in [§8 Revision log](#8-revision-log) with a date, and in TEST-REPORT.md.

---

## 1. Baseline I am starting from

I ran the starter's own checks on my machine before writing this, and then played it myself.

| Check | Result |
| --- | --- |
| `godot --headless --path godot --script res://tests/test_game.gd` | 25 checks / 0 failures |
| `godot --headless --path godot --script res://tests/test_keyboard.gd` | 9 checks / 0 failures |
| My own playthrough (keyboard, windowed) | Reached the flag; controls and retry felt correct |

Two things I noticed while playing that this brief plans around. Both are properties of
the **unmodified starter**, not defects I introduced:

**Observation A — the camera is static for roughly 40% of the run.**
`session.gd:153` is `camera.position.x = clampf(player.position.x + 100, 320, level.width - 320)`.
With a 640-wide viewport and a 960-wide level the clamp range is only `[320, 640]`, so:

| Phase | Player x | Camera x |
| --- | --- | --- |
| Start | 64 → 220 | pinned at 320 |
| Middle | 220 → 540 | tracking |
| **End** | **540 → 912** | **pinned at 640 (372 px, ~40% of the course)** |

The clamp itself is correct — it stops the camera from framing space outside the level.
The cause is that the level is only 1.5 viewports wide and the constant `+100` look-ahead
pushes the camera into the right clamp early.

**Observation B — spike death has text feedback but no visual feedback.**
`resolve_contacts()` sets `player.enabled = false`; `player._physics_process` then returns
at its first line and never calls `queue_redraw()` again. The character freezes on whatever
frame it died on for the full 0.55 s retry window. The HUD draws a card reading
"Watch the spikes", but nothing on the character or the spikes changes.

---

## 2. Character concept — **BEACON**

Replacing the starter's blue-shirted blocky humanoid (`player.gd:_draw()`, seven `draw_rect`
calls) with **Beacon: a one-eyed lighthouse robot**.

### Visual features that distinguish it

| Feature | Beacon | Starter character |
| --- | --- | --- |
| Silhouette | Tapered tower — wide tracked base narrowing to a lamp housing | Uniform vertical rectangle |
| Locomotion | Continuous tracked base (no legs) | Two rectangular legs that alternate |
| Head | Single large lamp eye occupying most of the head | Small 5×5 eye square on a square head |
| Facing cue | Lamp eye slides toward facing; a soft light cone projects that way | Eye square swaps to the left or right side |
| Palette | Warm brass shell, amber lamp, cool ink shadow | Cool blue shirt, orange belt, cream eye |

This is a change of **shape and silhouette**, not a recolor: the legs are gone, the head/body
proportion inverts, and the outline goes from a rectangle to a trapezoid.

### Reading against the 18×28 collider

The collider (`player.gd:_ready()`) is an 18×28 `RectangleShape2D` centred at `(0, -14)`,
so it occupies local `x ∈ [-9, 9]`, `y ∈ [-28, 0]`. **All opaque body geometry will be drawn
strictly inside that box.** The only thing that extends past it is the projected light cone,
which will be drawn translucent and low-contrast so it reads unmistakably as emitted light
rather than as solid body. I chose a design that fits the box rather than one with ears or a
scarf specifically to avoid a visual/collision mismatch.

### Planned state reads

| State | Visual |
| --- | --- |
| Facing right | Lamp eye and light cone shifted to `+x`; antenna trails left |
| Facing left | Mirrored; antenna trails right |
| Standing | Tracks flat; existing `stride` sine drives a subtle tread-roll instead of leg swing |
| Jumping | Tracks retract upward, lamp brightens, cone widens |
| Dying (new, see §4) | Lamp goes dark, eye becomes a dim red, cone disappears |

### Preserved
`tuning.gd` and the collider are **not touched** for the character change. Movement, jump
arc, and collision behaviour will be byte-for-byte the starter's.

---

## 3. Level extension — **BEACON TOWER**

The starter level is 960 wide, spawn `[64, 320]`, three ground slabs, two small steps,
one spike cluster at `x = 320`, finish at `[916, 264, 24, 56]`.

### Reach budget (derived from `tuning.gd`, predicted — to be verified)

| Quantity | Value |
| --- | --- |
| Peak rise `v²/2g = 320²/1920` | **53.3 px** (baseline test measured 56.07 px) |
| Airtime floor-to-floor | 0.667 s |
| Flat jump distance at full speed | **106.7 px** |
| Landing window for a +40 px step | **26.7 – 80 px** past the take-off edge |

**A finding that changed my design.** `acceleration = 1280 px/s²` means the player reaches
full speed 160 in about **10 px** of run-up. So "should I back up for a running start?" is
not a real decision in this game — a standing jump and a running jump go the same distance.
My first idea was a plain ascending staircase, and this number kills it: a plain staircase
would be a sequence of jumps with no choice in it, which is exactly the "merely stretch an
empty floor" case the assignment rules out.

### What I am building instead

A tower that still ascends step by step, but where **the summit is reachable two ways**, so
the player has to commit to a risk level before the first step.

- **Approach.** A short gap past the existing finish position leads to a ground-level base
  platform. A spike bed sits on the base's centre, so the tower's floor is lethal, not free.
- **Inner climb (fast, punishing).** Three narrow steps rising ~40 px each, stacked over the
  spike bed. A missed landing drops onto spikes → death and retry.
- **Outer climb (slow, safe).** A longer run of wider steps around the right side, rising in
  smaller increments. A missed landing drops onto clear ground → walk back and try again.
- **Summit.** Both routes converge on a single top platform. **The finish flag moves here**,
  so the new section must be completed to win.

The decision is legible from the ground: the player can see the spike bed under the inner
steps and the longer, clean outer path beside it, and picks speed or safety before jumping.

### Constraints this must respect

- Every step rise stays **≤ 40 px** (safety margin under the 53.3 px ceiling) and every
  horizontal gap stays inside the **26.7 – 80 px** landing window for that rise.
- The HUD draws an **opaque** bar over screen `y ∈ [0, 74]` and another over `y ∈ [335, 360]`
  (`hud.gd:19,26`). The camera is fixed at `y = 180`, so world `y` maps 1:1 to screen `y`.
  **The summit platform must therefore sit below `y = 74`** or it will be hidden behind the
  HUD. With the ground at `y = 320` that allows at most ~246 px of climb.
- The original route from spawn to `x = 960` stays playable and unchanged.
- `fall_y = 430` and the spawn point stay as they are.

---

## 4. What must remain unchanged

Unless listed in §5, all of the following are preserved exactly:

- **Movement tuning** — every value in `tuning.gd`: speed 160, acceleration 1280,
  deceleration 1920, jump velocity −320, gravity 960, terminal velocity 480,
  coyote 6 ticks, buffer 6 ticks.
- **Collider** — 18×28 rectangle at offset `(0, −14)`, layer 2 / mask 1.
- **Controls** — A/D and arrows to move, Space to jump, R to retry, Escape/P to pause,
  Enter to confirm, M for menu. No key is added, removed, or rebound.
- **Jump rules** — one fixed-height jump, no double jump, no variable jump height,
  coyote and buffer windows inclusive at 6 ticks and expired at 7.
- **Collision and death** — hazard `Area2D` overlap and `position.y > fall_y` are the only
  two death conditions; the three exact triangular spike polygons stay exact.
- **Retry** — 0.55 s retry delay, unlimited retries, `contact_settle_ticks = 2` guard against
  the phantom second death, manual `R` restart not counted as a death.
- **Pause** — Escape/P toggling, focus-loss auto-pause, jump-release requirement on resume.
- **Completion** — `goal.overlaps_body(player)` in the `PLAYING` state, and Enter to replay.
- **State machine** — `MENU / PLAYING / PAUSED / DYING / COMPLETE`.

I will not raise jump strength, lower gravity, or weaken a collision check to make the
extension passable. If a jump does not work, the geometry gets revised.

---

## 5. Changes to original behaviour I am declaring up front

Four departures, each with a reason and its own check. Three of them are required by the
assignment's own warning that a wider level needs camera, bounds, background, label and
finish-marker work.

| # | Change | Why | How I will check it |
| --- | --- | --- | --- |
| 5.1 | `session.gd:_draw()` stops using hard-coded coordinates (grid `range(0,961,32)`, hills at `[100,470,770]`, spike `y` fixed at 320/304, flag pole fixed at `y` 250–320, label positions) and derives them from the level JSON instead. | The assignment states explicitly that moving data alone does not draw a hazard or label in the right place. A spike on a raised platform would be drawn on the ground. | Compare a `capture_game.gd` screenshot against the JSON rectangles; confirm every drawn spike sits on the platform its `Area2D` is on. |
| 5.2 | HUD progress bar denominator `(player.x − 64) / 852` (`hud.gd:24`) becomes a value computed from spawn and finish. | 852 is `916 − 64`. With a longer level the bar would read 100% while the player is only halfway, which is a "what you see disagrees with what is true" defect. | Walk the full route and confirm the bar reads ~0% at spawn and ~100% at the finish. |
| 5.3 | Camera look-ahead changes from the constant `+100` to a facing-aware offset. | Observation A. Cosmetic, affects framing only, not physics. **This is a real behaviour change** and is the one item here I could defend dropping. | Play both directions; confirm the camera never frames outside the level bounds and never hides the next landing. Re-run the full mechanics suite for regressions. |
| 5.4 | Add purely visual death feedback inside the existing 0.55 s window. | Observation B. **No timing, physics, or collision change** — the 0.55 s stays 0.55 s, `deaths` still increments once. Requires letting the player redraw while `enabled == false`, which means a `dying` flag the session sets and `reset_at()` clears. | `twenty-retries` must still report `max_retry_ticks ≤ 60`; `pause-freezes` must still pass (redrawing must not resume simulation); `duplicate-death-ignored` must still hold. |

### Test fixture change (disclosed, not hidden)

`tests/route_driver.gd` drives a fixed input route with `jump_marks = [138, 292, 424, 548, 712]`
and a permanently-right `test_axis = 1.0`. This fixture was authored for the original layout
and **will not work on the extension** — I predict it needs more than new numbers (see §7.5).
I will update it, state exactly what changed and why in TEST-REPORT.md, and add a check that
the route actually reaches the relocated finish. **I will not delete or weaken an assertion
to get a green report.**

---

## 6. What I expect to go right

- The character swap is confined to `_draw()` and should not move a single test.
- The camera's existing clamp `[320, width − 320]` is already correct and will
  automatically give a much wider pan once the level widens — Observation A should
  largely resolve itself as a side effect of the extension.

---

## 7. Predicted failure cases

Seven predictions. Each has a specific check, and each will be scored honestly in
TEST-REPORT.md as *happened* or *did not happen*.

**7.1 — A tower step is out of reach.**
I expect to get at least one step wrong on the first pass: either a rise over 53.3 px, or a
horizontal gap outside the 26.7–80 px landing window, so the player clips the step's left
face and falls.
*Check:* run `test_game.gd` and watch `complete-real-route` — an unreachable step shows up as
the 900-tick timeout with `state != COMPLETE`. Then confirm by hand at the keyboard, because a
scripted route can succeed on a jump a human cannot reliably repeat.

**7.2 — Drawn geometry disagrees with physics geometry.**
The most likely visible bug in this project. `session.gd:_draw()` writes spike `y` as the
literals 320 and 304, so a spike placed on a platform at `y = 280` will be *drawn* on the
ground while its trigger sits in the air. The finish flag has the same problem: the pole is
drawn from `y = 320` to `y = 250` regardless of where the finish rectangle actually is, so
moving the finish to the summit will leave the flag floating at ground level.
*Check:* run `capture_game.gd` (non-headless) and overlay each drawn element against the JSON
rectangle. Every hazard and the finish must be drawn where its collision shape is.

**7.3 — The summit is hidden behind the HUD.**
`hud.gd` fills screen `y ∈ [0, 74]` with opaque `#f6f3ec`, and the camera never moves in `y`.
If the tower climbs more than ~246 px the summit platform, the finish flag, and the
"FINISH" label go behind that bar and the player cannot see what they are jumping at.
*Check:* assert the minimum platform `y` in the JSON is greater than 74 plus clearance, and
confirm visually in a screenshot that the summit and flag are fully below the HUD bar.

**7.4 — The background stops at x = 960.**
The grid loop is `range(0, 961, 32)` and the hills are a literal `[100, 470, 770]`. Past
`x = 960` the extension will render on flat cream with no grid and no parallax, which will
read as "the level ran out" rather than as a new section.
*Check:* screenshot the extension; the grid and hill treatment must continue across the seam.

**7.5 — The route fixture needs redesign, not renumbering.**
`route_driver.gd` holds `test_axis` at `1.0` forever and only jumps when
`position.x >= mark and is_on_floor()`. On a tower with narrow steps I expect this to walk
straight off the far edge of a step before its next jump mark, because it can never stop or
reverse. New numbers alone will not fix that.
*Check:* run the route; if it dies or times out, record the actual failure before changing the
fixture, and describe the redesign in TEST-REPORT.md rather than quietly swapping the array.

**7.6 — The death-visual change breaks a pause or retry test.**
To animate a dead player I have to redraw a node whose `_physics_process` early-returns.
If I implement that by re-enabling the player or by driving redraws from the wrong state, I
expect `pause-freezes` to fail (position drifting while paused) or `twenty-retries` to fail
(retry window no longer ≤ 60 ticks).
*Check:* the full 25-check mechanics suite after the change, compared against the 25/25
baseline in `be3c32f`.

**7.7 — The new spike bed kills the player during respawn or on arrival.**
The spike bed under the inner climb is the first hazard in this project that a player can
fall onto from a height. `contact_settle_ticks` only guards the two frames after a reset. I
expect at least one case where landing on or near the bed produces a death that feels unfair
or a double-count.
*Check:* deliberately fall onto the bed from each tower step; confirm `deaths` increments
exactly once each time and the retry returns to the original spawn, not to the tower.

---

## 8. Revision log

*Revisions are appended here with a date; nothing above this line is edited.*

---

### R1 — 2026-09-19 — The two-route fork in §3 is geometrically impossible. Extension is challenge-led instead.

**What §3 promised:** an inner climb and an outer climb converging on a summit, so the player
picks a risk level. **What I built:** a single ascending tower over a bottomless chasm.

**Why.** Before placing any platform I worked out the vertical budget, and it rules the fork out:

- The player collider is 28 px tall; platforms are 16 px thick.
- A player standing on a platform with top `T` occupies `T-28 … T`.
- A platform 40 px above it occupies `T-40 … T-24`.
- Those overlap on `T-28 … T-24`, so **two vertically adjacent platforms may not overlap in x**
  or the player standing on the lower one is embedded in the upper one.
- To clear that overlap the lanes must be ≥ 56 px apart vertically — but the measured peak rise
  is **53.3 px**, so nothing can ever jump from the lower lane to the upper one.

Two stacked lanes therefore cannot both branch from a common platform and cannot merge. Making
them side by side instead needs roughly 400 px of extra width per lane, which is a bigger level
than this assignment window supports. This is a measured limit of the starter's own tuning, not
a shortcut: §4 forbids raising jump strength, and raising it is the only thing that would make
the fork fit.

**What replaced it.** The assignment asks for "a clear player decision **or challenge**". The
extension is now a challenge: a chasm with no floor that cannot be crossed at ground level,
crossed by five jumps up a tower where every miss is fatal, and a spike gate on the summit
between the last landing and the flag.

| Element | Rect | Note |
| --- | --- | --- |
| Approach ground | `[1008, 320, 168, 64]` | 48 px gap from the original course |
| Pedestal | `[1104, 296, 72, 24]` | new landing 1 |
| Step one | `[1192, 280, 64, 16]` | new landing 2, over the chasm |
| Step two | `[1304, 240, 64, 16]` | new landing 3, over the chasm |
| Summit | `[1416, 200, 184, 16]` | new landing 4 |
| Beacon gate | hazard `[1480, 184, 24, 16]` | spikes between the last landing and the flag |
| Finish | `[1520, 144, 24, 56]` | relocated from `[916, 264, 24, 56]` |

Level width 960 → 1600. Four new landings that require jumps; the requirement was two.

### R2 — 2026-09-19 — Take-off windows are measured, not calculated.

`godot/tests/verify_reach.gd` sweeps the take-off x of the **real player** in 2 px steps with the
shipped tuning and records where it actually lands. Measured windows:

| Jump | Window |
| --- | --- |
| starter gap 1 (unchanged) | x 394…446, 54 px |
| starter gap 2 (unchanged) | x 666…734, 70 px |
| third slab → approach | x 890…956, 68 px |
| approach → pedestal | x 1010…1094, 86 px |
| pedestal → step one | x 1096…1162, 68 px |
| step one → step two | x 1212…1264, 54 px |
| step two → summit | x 1324…1376, 54 px |
| summit → over the beacon gate | x 1408…1466, 60 px |
| chasm walkable at ground level? | 0 of 40 take-offs reached the far side |

§3's predicted "26.7 – 80 px landing window for a +40 px step" was close: the measured windows for
the +40 steps are 54 px. The route fixture's new jump marks were then chosen from this table rather
than guessed.

### R3 — 2026-09-19 — The second spike cluster moved from the chasm lip to the summit.

§3 planned a spike bed at the base of the climb. Measurement killed that placement: spikes on the
approach at the chasm lip cut the take-off window for the pedestal jump from 86 px down to 38 px,
and the player's landing point coming off the previous gap sits *on* that boundary, so the jump
became a coin flip through no skill of the player's. Two other positions were tried on paper and
failed the same way — the 168 px approach is simply too short to hold a hazard and a +24 jump.

The spikes moved to `[1480, 184, 24, 16]` on the summit, between the final landing and the flag.
Measured window to clear them: 60 px, in line with every other jump. The new section still has both
failure modes the assignment asks to demonstrate — a fall and a hazard.

### R4 — 2026-09-19 — Two bugs found in my own verification script, not in the level.

Recorded because a green report that was green for the wrong reason is worth as much as a red one.

1. `attempt()` treated any state other than `PLAYING` as a death. Touching the goal sets
   `COMPLETE`, so the summit jump — which lands on the flag — was reported as **36 of 36 fatal**.
   The jump was always fine.
2. The "is the chasm walkable" gate allowed a 9 px collider overhang and used a target starting at
   x = 1176, the exact right edge of the approach ground. Landing back where it started counted as
   crossing. Target moved to x = 1200.

Both were fixed in the test, not in the level. Level geometry did not change as a result of either.
