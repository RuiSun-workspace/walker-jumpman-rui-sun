# PROMPTS — what was asked, and what is reconstruction

Two prompts appear on screen. They are different kinds of thing and the film says so.

---

## 1. B00 — the opening ask · **ILLUSTRATIVE RECONSTRUCTION**

> Please use Walker to convert my game design document about a compact 2D Godot
> platformer — read the landing, commit to one fixed-height jump, die fast, retry
> instantly — into a playable Godot project. Keep the starter's tuning untouched. Replace
> the character's visual identity. Extend the real level so the flag can only be reached
> through the new section. Measure every jump rather than trusting the arithmetic.

**This is not a transcript.** No such single prompt was typed. It is a reconstruction that
states, in one place, what the assignment actually asked for and what the work actually
committed to. It is labelled as reconstructed in three places: the narration says "the ask,
reconstructed", the beat's `role_note` says so, and `beat_sheet.json` metadata says so.

The three result lines under it are **not** invented build receipts. Each is a checkable fact:

| Line | Where it comes from |
| --- | --- |
| "character: `_draw()` only — tuning.gd and the 18×28 collider untouched" | `git diff bcde8bc..HEAD -- godot/features/player/tuning.gd` is empty |
| "level: 960 → 1664 px, four new landings over a chasm with no floor, flag moved to the summit" | `first_steps.json` at both revisions |
| "proof: verify_reach.gd sweeps the real player 2 px at a time; 0 of 40 ground take-offs cross the chasm" | `verify_reach.gd` output, gate row |

No fictional live build log, progress spinner, or fabricated tool output appears.

---

## 2. B10 — Your Turn · **paste-ready, meant to be run**

> Read this Godot project's tuning resource and derive, before designing anything: peak
> rise, airtime, flat jump distance, and the landing window for a rise of R. Then write a
> headless harness that sweeps the real player's take-off position in 2 px steps and
> reports, per jump, the window that actually lands. Build the level from those
> measurements. Do not raise jump strength to make geometry fit — change the geometry.
> Finally, add one optional pickup and measure what share of each safe take-off window
> collects it anyway.

The concrete experiment the beat invites: **add one optional route a competent player can
skip, then measure what share of the safe window takes it anyway.** If that share comes
back near 100%, the pickup is decoration rather than a decision — which is exactly what
happened here, and is why the last of the three result lines reads "distrust the flattering
measurement: this project's first cherry sweep read 0–4% and was broken."

---

## 3. The prompts that actually drove this work

For traceability, the real working prompts were conversational and numerous rather than a
single ask. The pattern each time was the one the assignment describes: propose a plan,
implement one bounded change, show the diff, run the checks, report what still needs human
playtesting. The full record of what was accepted, modified and rejected is in the game
repository's `FRICTIONAL.md` and `SOURCES.md` §4, not in this film.

Human decisions that changed the work, all recorded in the game repo rather than claimed here:

- keeping the tower after the two-route fork was ruled out, instead of weakening `tuning.gd`
- moving the flag rather than the spikes when the beacon gate crowded the finish
- deciding the camera must not pan vertically
- accepting the measured cherry result and documenting it rather than forcing a weak decision
- the film's shot plan and the decision to record one continuous take

---

## 4. Narration source

All twelve beats' narration is authored text in `beat_sheet.json`, synthesised locally with
Kokoro (`kokoro-v1.0.onnx`, voice `am_onyx`). No paid TTS, no cloud call, no API key. Liam
is an AI narrator standing in for Bear and is identified as such in B00 and at the sign-off
in B10. The outro card carries no narration at all.
