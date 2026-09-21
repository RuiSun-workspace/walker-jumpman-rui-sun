# FRICTIONAL — honest log

**Author:** Rui Sun · CSYE 7270, Fall 2026, Assignment 1 · 2026-09-18 to 2026-09-20

> **How this file was written.** Claude Code organised these entries from the actual working
> session — the commands run, the outputs, the commits, and what I said at the time. It did not
> invent any attempt, difficulty or conclusion. Quotes attributed to me are what I actually
> typed. Entries marked *(retrospective)* were written after the fact rather than in the moment.

---

## 1. Setup went smoothly, and I am saying so rather than dressing it up

**2026-09-18.** Cloning the starter, installing Godot and getting the tests green took one pass
with nothing going wrong.

What I actually did: cloned `nikbearbrown/walker-jumpman`, found the README named
`Godot 4.7.2.stable.official.ed1daf0bf` as the tested build, downloaded exactly that from the
official GitHub release rather than "some 4.x", and ran both suites before editing anything.

**25 checks / 0 failures and 9 checks / 0 failures on the first attempt**, and the engine
reported `4.7.2.stable.official.ed1daf0bf` — the same build hash the README names.

**How I checked it was really working** rather than assuming: I did not just look at the
"0 failures" line. I read the observed values — `rise_px: 56.07470703125`, route `325 ticks`,
finish at `(912.8837, 319.9253)` — and committed them as `be3c32f` so that later runs could be
compared number by number instead of pass/fail. That turned out to be the single most useful
thing I did all week: when I later claimed the character swap did not touch physics, I could
show the numbers were **bit-identical**, which is much stronger than "the tests still pass".

*Nothing was hard here. It would be dishonest to pad it.*

---

## 2. Writing the brief before the code felt like overhead, and then it wasn't

**2026-09-19, commit `c001f07`.** The assignment requires predictions first. I expected this to
be a formality.

Two things came out of it that changed the work:

- Deriving the reach budget from `tuning.gd` before designing anything surfaced
  `acceleration = 1280`, which puts the player at full speed in about **10 px**. My first level
  idea was a plain ascending staircase where the decision would be "do I back up for a running
  start?" That number kills it — a standing jump and a running jump go the same distance. The
  design was wrong before I built it, and I only found out because I wrote the numbers down.
- Forcing myself to list what must **not** change produced a 30-item list that I then had to
  actually honour. Later, when it would have been convenient to nudge `jump_velocity`, that list
  was sitting there in a committed file with my name on it.

**Unresolved at the time:** I wrote seven failure predictions and had no idea which would land.
Scoring them honestly afterwards (§7) was more uncomfortable than writing them.

---

## 3. The character swap worked first try; the problems were things tests cannot see

**Commit `522e6d1`.** I expected trouble here and got none mechanically — 25/25 with every value
identical to baseline, because the change is confined to `_draw()`.

What actually cost time was **looking at the result**. Two defects, neither of which any check
could have caught:

1. When the tracks tuck up on a jump I moved `base_top` from −6 to −4, but the hull polygon still
   ended at −6. A 2 px hole opened and the body read as **floating above a detached base**. On a
   platformer that is exactly the "misleading visual/collision" failure the rubric names.
2. The pupil sat on the rim of the lamp disc, so the eye rendered as a crescent "C" instead of an
   eye.

**What I learned:** for a drawing change, "all tests pass" carries almost no information. I
started rendering and zooming into frames as a routine step, not an afterthought. I also asked
for the real 18×28 collider to be drawn over the art (`SHEET-collider-check.png`) so the
alignment claim could be checked instead of asserted.

**A small thing I noticed and kept:** the starter's own art overhangs its collider — the belt
rect spans x −10…10 against a collider of −9…9. I did not "fix" someone else's file; I just made
sure mine does not, and said so.

---

## 4. My own brief promised something that cannot exist

**The biggest thing I got wrong.** `CHANGE-BRIEF` §3 promised two converging climbs so the player
could pick a risk level. When it came time to place platforms, the geometry refused.

The argument, which Claude derived and I checked:

- Player collider 28 px tall, platforms 16 px thick.
- Standing on a platform with top `T`, the player occupies `T−28 … T`.
- A platform 40 px above occupies `T−40 … T−24`. Those **overlap**.
- So vertically adjacent platforms may not overlap in x — which is the opposite of "parallel
  lanes".
- Separating the lanes enough needs ≥ 56 px, and the **measured peak rise is 53.3 px**. Nothing
  can ever jump from the lower lane to the upper one.

**What I did about it.** The fix that would have made the fork work is raising `jump_velocity`,
which is item one on my own do-not-change list and is what the assignment explicitly forbids. I
changed the geometry instead and rewrote the section as a challenge — a chasm that cannot be
crossed at ground level, five committed jumps, a spike gate before the flag — and recorded the
whole thing as revision R1 rather than quietly editing §3 to look correct.

**I want to be clear about attribution here:** I did not work out the vertical-budget proof
myself. Claude produced it, I read it, checked the arithmetic against the measured 53.3 px rise,
and accepted it. What was mine was the decision about what to do next.

**Still unresolved:** the extension is now challenge-led, and "a clear player decision" is the
weakest part of my submission. I know what would fix it — the starter's own unimplemented
`MECH-03` optional cherries, which exist precisely to make the player "choose the risk". I chose
not to add them (§8).

---

## 5. I stopped calculating and started measuring, and then the measurement was wrong twice

I had algebra for every jump window. I did not trust it enough to ship a level on it, so I built
`tests/verify_reach.gd`: sweep the real player's take-off x in 2 px steps, with the shipped
tuning, and record where it actually lands. Deliberately, it reads **no value from `tuning.gd`**,
so a level that only passes because the jump was strengthened cannot pass it.

The measured windows came out 54–86 px against my predicted "26.7–80 px landing window", so the
algebra was roughly right — but the harness itself was wrong twice, and both failures are still
sitting in `evidence/reach-1789859412.664.json` and `reach-1789859855.182.json`:

1. It treated any state other than `PLAYING` as death. Touching the goal sets `COMPLETE`, so the
   summit jump — the one that *lands on the flag* — reported **36 of 36 fatal**. I spent a while
   convinced the geometry was broken. It never was.
2. The "is the chasm walkable" gate allowed a 9 px collider overhang against a target starting at
   the exact right edge of the approach ground, so **landing back where you started** counted as
   crossing the chasm.

**What I learned, and it is the thing I would tell someone else:** a red test is not automatically
a level bug, and a green test is not automatically a working level. Both of these were bugs in the
instrument. I fixed them in the test, not in the level — the level geometry did not change because
of either — and I kept the failing runs in `evidence/` on purpose, because a green report that is
green for the wrong reason is worth exactly as much as a red one.

---

## 6. Playing it found what none of the 38 checks could

**Commit `3d7d43f`.** After the tower was built and everything was green, I played it and found
two things.

**"The last spikes are a bit close to the finish."** I said this from feel. It turned out to be
measurable, and the harness had *already recorded it* in output I had read without understanding:
30 of 30 successful take-offs over the gate reported `reached_goal`, which means every single
completion happened in mid-air and the tower had no landing beat at the top. The data was in front
of me and I only understood it after playing. Widening the level and moving the flag dropped that
to 1 of 30 — the other 29 now land and walk in — with the take-off window unchanged at 60 px, so
the jump is no harder, it just resolves on the ground.

**"Whichever way I move, the legs animate as if moving right."** I assumed I had a sign error.
I was wrong. The tread scroll *does* reverse with travel; the problem is that a 5 px pattern at
160 px/s cycles at **32 Hz**, which is far too fast to resolve, so it reads as static texture in
both directions — and shows nothing at all when standing still. The fix was two parts: gear it
down to about 7 Hz (the starter's own leg cadence is ≈ 6.7 Hz), and add a **static** cue by making
the leading drive sprocket larger than the trailing idler. The static part is what actually
answered my complaint; the animation was never going to.

While re-rendering frames to check that, a detached vertical line appeared beside the hull — four
tread marks stepped through a 20 px cycle while the hull only exposes 15 px, so the wrapped mark
was being drawn outside the character. **It had been there since `522e6d1` and every check passed
the whole time.**

### 6b — and then the camera fix I wrote *created* a defect, which only playing found

**2026-09-21.** I ran the full six-item pass on `9261070`. Five items behaved. The sixth: the
camera shook badly when I reversed direction repeatedly.

That one is mine. The facing-aware lead I added two commits earlier reads `facing`, which is
discrete — it flips the instant the key changes, moving the camera target 160 px in one frame.
Easing toward a target that teleports is exactly a swing.

**What I did before touching the code:** wrote a check that taps left and right every three ticks
and records the camera position *relative to the player*, so my own movement is not counted.
**My first version of that check was wrong**, and I want that on the record: it reported 207 px,
but `fresh()` parks the camera at x = 320 and the test teleports the player to x = 800, so a
5-tick settle was measuring the camera's catch-up as if it were shake. I nearly chased that. With
a 60-tick settle the real number is **97.02 px** — about 15% of the screen oscillating, which
matches what I felt.

The fix drives the lead from velocity instead of facing and eases the lead itself at 2.2/s,
much slower than the camera's own 7/s follow, so tapping cancels out. **97.02 px → 11.32 px.**

**The thing I did not expect:** the same instrument showed the old version was not just shaky but
*backwards*. With the player parked and velocity forced left, it still reported a lead of +79.99.
`facing` only updates inside `_physics_process` from the input axis, so the camera had been
following the last key pressed rather than the direction Beacon was actually moving. I reported
shake; measuring it found a second, worse bug underneath.

I also renamed `camera-lead-follows-facing` to `camera-lead-follows-travel` and **raised** its
threshold from 40 to 60, because parking the player makes the settled value readable. Saying that
out loud because changing a test while fixing a bug is exactly where it would be easy to cheat —
this one got stricter, and the observed value went from ±53…57 to ±78.

---

## 7. Scoring my own predictions, including the one I got wrong

*(retrospective)* From `CHANGE-BRIEF` §7:

| # | Prediction | What happened |
| --- | --- | --- |
| 7.1 | A tower step will be out of reach on the first pass | **Did not happen.** Measuring before placing meant every jump was reachable first try. |
| 7.2 | Drawn geometry will disagree with physics geometry | **Pre-empted.** I rewrote the draw code to be data-driven before placing the summit spikes. Under the old code they would have been painted on the ground while their triggers sat 136 px higher. |
| 7.3 | The summit will hide behind the HUD | **Did not happen**, because the y ≤ 74 limit went into the brief as a constraint and the tower was designed under it. |
| 7.4 | The background will stop at x = 960 | **Pre-empted** by the same rewrite. |
| 7.5 | The route fixture will need redesign, not renumbering | **Wrong.** Six new marks were enough. The driver still cannot stop or reverse, and I left that limitation documented rather than papered over. |
| 7.6 | The death-visual change will break `pause-freezes` or `twenty-retries` | **Wrong.** `pause-freezes` still reports `(64.0, 295.9253)` and `twenty-retries` still reports `max_retry_ticks: 34`, unchanged from baseline. A reasonable prediction that simply did not come true. |
| 7.7 | The spike bed will produce an unfair or double-counted death | **Overtaken.** The spike bed was measured out of that position before it shipped (it cut a take-off window to 38 px), so the case never arose. |

Four of seven were pre-empted by measuring first, two were plainly wrong, one never arose. The
honest summary is that **the predictions I got wrong were wrong in the safe direction**, and the
real defects came from somewhere I had not predicted at all: rendered frames.

---

## 8. Choosing not to add a feature

**2026-09-20.** I wanted to add a special item. Looking into it, the starter's `GDD.md` already
specifies `MECH-03 — Collect optional cherries` in detail, including edge cases, and
`BUILD-REPORT.md` says it was never implemented. Implementing it would have been a natural
extension, would have supplied the player decision my level lacks (§4), and the GDD's edge cases
would have converted directly into assertions.

I decided against it for now, because `TEST-REPORT.md`, `FRICTIONAL.md`, `SOURCES.md`,
`README.md` and the required film were all still unwritten and those are the graded deliverables.
Recording the decision here so it reads as a choice with a reason, not an oversight.

I also considered and rejected a movement-altering power-up — double jump or a speed boost. It
would contradict the preserved tuning that the entire evidence chain in TEST-REPORT §2 rests on.

---

## 9. Still unresolved

1. **The camera limitation I reported on day one is only partly fixed.** Widening the level and
   adding a facing-aware eased lead helped the middle of the run, but the clamp still pins the
   camera for roughly the last 320 px of the climb. That is correct behaviour rather than a bug,
   which is exactly why I cannot claim to have solved it.
2. **I do not know whether the climb is fair to someone who has never seen it.** I designed it, so
   I know where every landing is. No second person has played it, and I am not going to invent one.
3. **Whether the measured 54 px take-off windows are comfortable at human reaction speed** is not
   something the harness can answer. It proves a route exists; it does not prove a person can
   repeat it reliably.
4. **The camera shake is reduced, not eliminated.** 97.02 px → 11.32 px is roughly ninefold, but
   it is not zero. I have not felt the remaining amount as a problem, and I have not specifically
   asked anyone else to judge it either.
5. **How many of my own tests are measuring what I think they measure.** Three times now an
   instrument was wrong rather than the game — twice in the reachability harness (§5) and once in
   the camera-shake check, which reported 207 px when the real figure was 97 px. Each time I
   caught it by the number looking implausible. I do not have a systematic way of catching the
   ones that look plausible.

---

## 10. Contribution summary

**Mine:** the character concept and the decision to fit it inside the collider rather than
overhang it; keeping the tower after the fork was ruled out instead of weakening the tuning;
writing the brief first and keeping it append-only; moving the flag rather than the spikes;
deciding the camera must not pan vertically; deferring the cherries; and every playtest
observation in TEST-REPORT §3.

**Claude's:** locating the relevant code; deriving the reach budget and the vertical-budget proof;
writing the drawing code, tower geometry, camera, death feedback, test harnesses and capture
tooling; diagnosing the 32 Hz tread frequency; and finding three defects by inspecting rendered
frames.

**Accepted after checking:** the vertical-budget proof, the 32 Hz diagnosis, and the drive-sprocket
idea — all three were not what I expected, and I verified each against a measurement or a frame
before taking it.

**Rejected:** the two-route fork from my own brief, the lip spike bed, a movement-altering
power-up, and any suggestion of changing tuning to make geometry work.

**Traceability:** `bcde8bc` starter · `be3c32f` baseline numbers · `c001f07` brief before code ·
`522e6d1` character · `c2f2e50` tower and data-driven drawing · `3d7d43f` first playtest acted on ·
`9261070` camera and death feedback · `878e90c` documents · then the velocity-driven camera from
the second playtest. Test evidence in `evidence/`, including the two failing reachability runs.
Revisions R1–R7 in `CHANGE-BRIEF.md` §8.
