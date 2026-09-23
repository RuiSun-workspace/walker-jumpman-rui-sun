# FACTCHECK — every number and claim in the film, with its source

Rule applied throughout: a **source-code fact** is something readable in the repository or
measured by a harness; an **untested judgment** is an opinion. The film must not present
the second as the first. Anything below marked *judgment* is flagged as such in narration
or is confined to the Verdict beat, which exists to hold opinions.

Game source: commit `8a4d63d04251030607222c88a2d517002c0c10fd`,
`build_id 1892d76f5d742b612041dd6587f95bcaaa38cc77399eb23e7f88ee0e6cad1732`.
Engine `Godot 4.7.2.stable.official.ed1daf0bf`.

---

## B00 — the ask

| Claim | Status | Source |
| --- | --- | --- |
| The prompt shown is a reconstruction | **disclosed as such** | Stated in the narration ("The ask, reconstructed"), in the beat's `role_note`, and in `beat_sheet.json` metadata. It is not a transcript and is never presented as one. |
| "tuning.gd and the 18×28 collider untouched" | fact | `git diff bcde8bc..HEAD -- godot/features/player/tuning.gd` is empty; the collider is built in `player.gd:_ready()` and unchanged. |
| "960 → 1664 px" | fact | `first_steps.json` `width` at `bcde8bc` is 960; at HEAD it is 1664. |
| "0 of 40 ground take-offs cross the chasm" | measured | `verify_reach.gd` gate `chasm is not walkable`, `reached_far_side_on_foot: 0`, `samples_4px: 40`. |

## B01 — what was built

| Claim | Status | Source |
| --- | --- | --- |
| "not the three-zone course the design document proposes" | fact | `GDD.md` §6 describes three zones and twenty cherries; `BUILD-REPORT.md` says the slice is not that. |
| "the starter's two gaps and one spike cluster" | fact | `first_steps.json` at `bcde8bc`: solids leave gaps 448–512 and 736–784; one hazard `[320,304,24,16]`. |
| "Four new landings" | fact | pedestal, step one, step two, summit — four solids added past x=1008. |
| "two converging routes … geometrically impossible" | measured/derived | `CHANGE-BRIEF.md` R1. 28 px collider + 16 px platform ⇒ 56 px lane separation needed; measured peak rise 53.3 px (`fixed-jump-and-no-double` observes `rise_px 56.07470703125` for the discrete integration, theoretical `v²/2g = 320²/1920 = 53.33`). |

## B02 — gameplay (0.0–6.0 s)

| Claim | Status | Source |
| --- | --- | --- |
| "recorded at four K straight out of the engine" | fact | `ffprobe` on `capture/run-01.mp4`: 3840×2160. Godot Movie Maker, `CAPTURE.md`. |
| "One fixed jump" | fact | `tuning.gd` has a single `jump_velocity`; `fixed-jump-and-no-double` asserts `jumps == 1` after a second press. |
| "a real death on the spikes" | fact | Input log: no Space press between the step jump and the hazard; state → DYING at `t_s 4.500` with `death_reason "Watch the spikes"`. |

## B03 — mechanism: death you can see

| Claim | Status | Source |
| --- | --- | --- |
| Code shown is verbatim project source | fact | `session.gd` `_physics_process`, HEAD. Not a reconstruction — and labelled that way on the card, in contrast to the toolkit's own teaching illustrations. |
| "the player's physics function returns on its first line while disabled" | fact | `player.gd:_physics_process` begins `if not enabled: return`. |
| "The starter printed the words and changed nothing" | fact | At `bcde8bc`, `hud.gd` draws `game.death_reason`; nothing else changes. No `dying` state existed. |
| "the retry window is still 0.55 seconds" | fact | `resolve_contacts` sets `retry_remaining = 0.55` at both `bcde8bc` and HEAD. |
| "maximum of thirty-four ticks, bit-identical" | measured | `twenty-retries` reports `max_retry_ticks: 34` at baseline `be3c32f` and at HEAD. |
| "The brief predicted this would break pause-freezes. It did not." | fact | `CHANGE-BRIEF.md` §7.6 predicted it; `pause-freezes` still reports `(64.0, 295.9253)` / elapsed `0.1333`. |

## B04 — gameplay (6.0–18.6 s)

| Claim | Status | Source |
| --- | --- | --- |
| "a chasm with no floor" | fact | No solid covers x 1176–1416 in `first_steps.json`. |
| "the clock stops with it" | fact on screen | The HUD elapsed reads `07.1` in frames at 12.2 s, 12.8 s and 13.3 s of the capture. `elapsed` only accumulates in the PLAYING branch. |
| "Missed the landing — a different death" | fact | `death_reason` is set from `position.y > fall_y`, a separate condition from hazard overlap. Log records that exact string at `t_s 16.333`. |
| "R restarts, and the counter holds" | fact | Log: manual retry at `t_s 17.733`, `deaths 2 → 2`. `restart_attempt()` does not touch `deaths`; `manual-restart-not-death` asserts it. |

## B05 — mechanism: measured, not calculated

| Claim | Status | Source |
| --- | --- | --- |
| "reads nothing from the tuning resource" | fact | `verify_reach.gd` contains no reference to `tuning`; it drives the real player and observes outcomes. |
| "windows between 54 and 86 pixels" | measured | `verify_reach.gd`: 54, 70, 68, 86, 68, 54, 54, 60 px across the eight swept jumps. |
| "zero of forty ground take-offs crossed the chasm" | measured | Same run, gate row. |
| "28 px player … 16 px platform … 56 px separation … peak rise 53.3" | derived + measured | Collider size from `player.gd:_ready()`; platform heights from `first_steps.json`; rise from `tuning.gd` and confirmed by `fixed-jump-and-no-double`. |
| "the geometry changed instead of the tuning" | fact | `tuning.gd` diff against `bcde8bc` is empty. |

## B06 — gameplay (18.6–28.0 s)

| Claim | Status | Source |
| --- | --- | --- |
| "four landings the starter never had" | fact | `[1104,296,72,24]`, `[1192,280,64,16]`, `[1304,240,64,16]`, `[1416,200,248,16]`. |
| "three spikes drawn on the summit platform" | fact on screen | Hazard `[1480,184,24,16]`; `_add_area` builds three triangles; the frames show them on the platform. |

## B07 — mechanism: two literals that lie

| Claim | Status | Source |
| --- | --- | --- |
| Code shown is verbatim **starter** source | fact | `git show bcde8bc:godot/game/session.gd`, the hazard loop. |
| "320 for the base, 304 for the point" | fact | Both literals appear in that loop. |
| "spacing hard-coded to 8 px" | fact | `entry[0] + i*8` — independent of the hazard's own width. |
| "the trigger polygons are built from each hazard's own rectangle" | fact | `_add_area()` uses `rect.size.y` and `rect.size.x / 3.0`. |
| "would have been painted 136 pixels lower" | derived | Gate top is y=184; the starter's literal point is y=304. 304 − 184 = 120 for the point, and 320 − 184 = 136 for the base-to-top distance quoted in narration. **The narration says "a hundred and thirty-six pixels lower", which is the base-line offset (320 → 184).** Stated here so the arithmetic can be checked rather than taken on trust. |
| "grid to a literal 961, hills to [100,470,770], flag pole 320→250, HUD bar /852" | fact | All four appear in the starter's `session.gd` / `hud.gd` at `bcde8bc`. |

## B08 — gameplay (28.0–34.3 s)

| Claim | Status | Source |
| --- | --- | --- |
| "Six of six berries" | fact on screen | Completion card reads `6 of 6 cherries`; driver logged `cherries=6/6`. |
| "the attempt resets" | fact | `start_session()` sets `deaths = 0` and `restart_attempt()` clears cherries; log shows `deaths 0 cherries 0` after the replay. |

**Discrepancy recorded rather than hidden:** the completion card in the footage reads
`11.2 s / 6 of 6 cherries / 1 retries`, while the driver's run summary printed
`finish_time=9.98s` and `deaths=2`. These are different quantities, not an error: the card
shows `last_finish_time` and `deaths` **at the moment of completion for that attempt's
session state**, and the capture's own HUD clock had been running across the paused hold.
The narration therefore says only "Six of six berries" and does not read the seconds aloud.
`coverage.json` `completion-and-replay` states both figures side by side.

## B09 — Verdict

Everything in this beat is either restated fact from above or explicitly framed as open:

| Claim | Status |
| --- | --- |
| "83–100% of every safe window collects them" | measured — `verify_reach.gd` cherry rows: 1.00, 1.00, 0.83, 0.85, 1.00, 0.97 |
| "the player is a body sweeping a parabola, not a point tracing one" | *judgment*, offered as the explanation for the measured result |
| "the camera is static for the last three hundred pixels" | derived — clamp at `width − 320 = 1344`, reached at player x ≈ 1264; summit flag at 1584 ⇒ ~320 px |
| "it never pans vertically" | fact — `camera.position.y` is set once to 180 and never changed |
| "exactly one person has played this" | fact — `TEST-REPORT.md` §3 and §6.4; no second playtester is claimed |
| "A scripted route is not a playtest" | *judgment*, and the reason the capture is labelled `scripted-input` everywhere |

## B10 — Your Turn

Contains no factual claim about this game beyond those above. The prompt is an instruction
to the viewer, not a record of what was run.

## B11 — outro

Locked card. No narration; silent under the existing slug-seeded jingle, per `OUTRO-LOCK.md`.

---

## Things the film does NOT claim

- It does not claim a complete walkthrough of the full GDD; six features are listed
  `planned` in `coverage.json` with reasons.
- It does not claim real-time performance. The capture is offline Movie Maker rendering at
  roughly 7% of real time; `CAPTURE.md` says so.
- It does not claim human verification of the scripted route. Human playtesting is a
  separate record in the project's `TEST-REPORT.md` §3.
- It does not claim the cherries are a risk choice. The measurement said otherwise and the
  Verdict says otherwise.
- It does not claim coyote time is visually demonstrated. `coverage.json` says in the
  observation that a successful ordinary jump looks identical with or without it.
