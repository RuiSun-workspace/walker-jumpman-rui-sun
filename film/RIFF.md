# RIFF — inspect first, then narrate

The riff rule: look at the take, then say what is happening on screen, what mechanism
causes it, and one useful trade-off. Source-code facts and untested judgments are marked
apart. The human judges feel and fun; the AI plays, records, explains and checks.

Each entry below was written **after** inspecting the frames it describes, not from the
beat plan.

---

## B02 · 0.0 – 6.0 s

**Inspected:** frames 0–180. Menu card, Enter at 2.200 s, run right, jump at x=138, one
cherry taken, walks into the spikes, death card with the spikes lighter than before.

**On screen:** the death is not an event the player triggered deliberately in the fiction —
the driver simply stops pressing jump and the course does the rest.

**Mechanism:** a hazard `Area2D` overlap sets `DYING`, disables the player, and starts a
0.55 s timer. The visible change is new: the guilty hazard brightens and the lamp dies.

**Trade-off:** all of that feedback lives in `_draw()`. It costs nothing in simulation and
therefore cannot be blamed for a movement regression — but it also means the feedback can
be completely wrong and every test still passes. That happened twice on this project.

**Judgment, flagged:** the flash reads clearly at 4K. Whether it reads on a phone has not
been tested.

---

## B04 · 6.0 – 18.6 s

**Inspected:** frames 180–558. Two gaps crossed, pause card held across three sampled
frames with `07.1` unchanged, resume, two tower landings, then the walk off step one.

**On screen:** the second death looks the same as the first for about two frames, and then
the card says something different — "Missed the landing" rather than "Watch the spikes."

**Mechanism:** two independent conditions. `position.y > fall_y` is checked before the
hazard loop runs, and the reason string is chosen from that check.

**Trade-off:** one shared retry path for both deaths keeps the loop tight and the code
small, but it also means the player learns the difference only from the sentence on the
card. If that sentence were wrong, nothing else in the game would contradict it.

**Judgment, flagged:** walking off a ledge is a fair way to demonstrate a fall, but it is
not how a human usually dies there — a human misjudges the jump. The scripted route cannot
misjudge, so it declines instead.

---

## B06 · 18.6 – 28.0 s

**Inspected:** frames 558–840. Four landings, the cherry counter reaching 6/6, the gate
spikes on the summit, the flag.

**On screen:** the climb reads as four separate commitments rather than one movement, and
there is visibly nothing under steps one and two.

**Mechanism:** each landing sits inside a take-off window measured by sweeping the real
player, 54 to 86 px wide. The chasm is not crossable at ground level, so the tower is the
only route to the flag.

**Trade-off:** placing platforms from measured windows rather than the theoretical 106.7 px
flat jump makes the course honest but also makes it tight — every window is narrower than
the arithmetic promises, because the arithmetic ignores the collider.

**Judgment, flagged:** whether 54 px is comfortable at human reaction speed is unknown. The
harness proves a route exists; it does not prove a person can repeat it.

---

## B08 · 28.0 – 34.3 s

**Inspected:** frames 840–1029. Completion card, replay, pause, main menu.

**On screen:** the card reports the attempt, and the replay wipes it. The numbers on the
card and the numbers the driver printed are **not the same numbers**, which is worth
saying out loud rather than glossing.

**Mechanism:** `last_finish_time` and the session `deaths` counter have different lifetimes.
`start_session()` resets one set; `restart_attempt()` resets another.

**Trade-off:** two counters with two lifetimes is the right model for a retry-heavy game,
and it is also the easiest way to misreport your own results. This project did exactly that
once: the first dry run printed `deaths=0 cherries=0` because it read the values *after*
the replay had already reset them.

**Judgment, flagged:** none. Everything here is on screen.

---

## Riffs that were cut

- A line about the camera easing was dropped from B06: the camera is genuinely static for
  the last stretch of that clip, so praising the easing over that footage would have been
  narration contradicting the picture. The camera is handled in the Verdict instead, where
  its limitation can be stated.
- A line about coyote time was dropped from B02. A successful ordinary jump looks identical
  with and without it, so there was nothing to point at. It is named in `coverage.json` with
  that reasoning rather than dramatised.
