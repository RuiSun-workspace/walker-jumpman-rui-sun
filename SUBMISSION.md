# SUBMISSION — CSYE 7270 Assignment 1

**Assignment:** Assignment 1 — Extend Walker Jumpman

**Student:** Rui Sun (`sun.r3@northeastern.edu`)

**Project name:** `walker-jumpman-rui-sun`

**GitHub repository URL:** https://github.com/RuiSun-workspace/walker-jumpman-rui-sun

**Submitted commit SHA:** *see the Canvas note — it is the commit that adds this file, and a
commit cannot contain its own SHA. Run `git rev-parse HEAD` on the pushed `main`.*

**Game-source revision shown in the film:** `8a4d63d04251030607222c88a2d517002c0c10fd`

> The film was rendered from `8a4d63d`. Commits after it add only documentation — this file,
> the `film/` authoring record, the film link in `README.md`, and the film credits in
> `SOURCES.md`. **No file under `godot/` changed after `8a4d63d`**, which is checkable:
>
> ```bash
> git diff --stat 8a4d63d..HEAD -- godot/     # expect empty output
> ```

**Godot version and operating system:** Godot `4.7.2.stable.official.ed1daf0bf` on
Windows 11 Home China 10.0.26200. The starter's README names the same engine build as its
tested one.

**Final film URL:**
https://northeastern-my.sharepoint.com/:v:/g/personal/sun_r3_northeastern_edu/IQDqDx3xiwwsRLmp6MLOgMnLAY9sLFPMN-FauK6ICBKZ_gM?e=AyiTai

**Final film filename:** `claude-liam-walker-jumpman-rui-sun-walkthrough.mp4`

**Final film SHA-256:** `5a7c346e81c2e0afbe5b274161a24c376789ee3c931d3908c14cdfe28023964c`

*(3840×2160 h264, 30 fps, AAC 48 kHz stereo, 270.767 s, 22.69 MB. Hosted on Northeastern
OneDrive with link scope "People in Northeastern University with the link", view-only, no
expiry. MP4 and MP3 are excluded from the repository by `.gitignore`.)*

---

## Summary of my changes

Built on **[nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman)**.
The unmodified starter is commit `bcde8bc` of this repository, so everything of mine is
exactly `git diff bcde8bc..HEAD`.

**Character — BEACON.** The starter's blue blocky humanoid becomes a one-eyed lighthouse
robot: legs replaced by a tracked base, the head becomes a lamp housing holding one large
amber eye, and the outline goes from a rectangle to a trapezoid. Facing reads from five
cues at once; airborne reads from four more. All original Godot vector drawing — no sprite
sheet, no imported image, no generated art. **`tuning.gd` and the 18×28 collider are
untouched**, and every opaque part is drawn inside that collider box.

**Level — Beacon Tower.** 960 → 1664 px. Four new landings that require jumps (the
assignment asks for two), over a chasm with no floor that cannot be crossed at ground
level, plus a spike gate between the last landing and the flag. The finish moved from
`[916,264]` to `[1584,144]` on the summit, so the new section must be completed to win. The
original route from spawn to x = 960 is unchanged and still playable.

**Drawing made data-driven.** The starter drew the grid to a literal `961`, hills to a
literal `[100,470,770]`, every spike between the literals `320` and `304`, and the finish
pole between `320` and `250`. Under that code the summit spikes would have been painted on
the ground while their trigger sat 136 px higher. All of it now reads the level JSON.

**MECH-03 cherries**, implemented from the starter's own GDD spec (designed there, never
built). Every clause of the spec is a check, including "a cherry overlapping a fatal hazard
on the same tick is not awarded".

**Two declared behaviour changes**, both written into `CHANGE-BRIEF.md` §5 before any code
was edited: a velocity-driven eased camera lead, and purely visual death feedback inside
the existing 0.55 s retry window.

**Verification.** 35 mechanics checks, 9 keyboard checks, and a new 15-row reachability
harness — all passing. `verify_reach.gd` sweeps the real player's take-off position 2 px at
a time and **reads no value from `tuning.gd`**, so a level that only passes because the jump
was strengthened cannot pass it.

---

## Known limitations

Stated here as well as in `TEST-REPORT.md` §6, because they matter to how the work is read.

1. **The extension is challenge-led, not choice-led.** `CHANGE-BRIEF.md` promised two
   converging routes; R1 proves that is geometrically impossible at this tuning (a 28 px
   player on 16 px platforms needs 56 px of lane separation; the measured peak rise is
   53.3 px). The cherries were then added specifically to supply that missing decision and
   **measurement says they do not** — 83–100% of every safe take-off window collects them
   anyway. They are a completion goal. The decision gap is open and documented, not closed.
2. **The camera is still static for roughly the last 320 px of the climb.** The clamp is
   correct — the alternative is framing space outside the level — but the day-one complaint
   is only partly addressed. The camera never pans vertically at all.
3. **One playtester.** Only the author has played this and only the author has watched the
   film. No second person is claimed anywhere.
4. **The route fixture and the film's capture are scripted input, not playtests.** They
   prove a route exists; they do not prove a person can repeat it. Both are labelled
   `scripted-input` wherever they appear.
5. **No export was built or tested.** Source only, run from the editor or the binary.
6. **Residual camera movement under rapid reversal is 11.3 px, not zero** — reduced about
   ninefold from 97 px, not eliminated.
7. **Six GDD features are `planned`, not built:** moving platforms, audio and mute,
   settings and key remapping, the Web export, the full three-zone twenty-cherry course,
   and the two-route fork. Each carries a written reason in `film/coverage.json`.

---

## Where to look

| Document | What it answers |
| --- | --- |
| [README.md](README.md) | How to run it, controls, what changed, the film link |
| [CHANGE-BRIEF.md](CHANGE-BRIEF.md) | Predictions written before any code, append-only, with revisions R1–R8 |
| [TEST-REPORT.md](TEST-REPORT.md) | Automated results, baseline comparison, six human playtest sessions, seven inspect-and-revise cycles, limitations |
| [FRICTIONAL.md](FRICTIONAL.md) | The honest log — what I tried, what surprised me, what I rejected, what is still unresolved |
| [SOURCES.md](SOURCES.md) | Starter credit, tools, and the human/AI split including the film |
| [film/](film/) | Beat sheet, coverage contract, fact-check, shot list, prompts, input log, QC reports |

## Verifying this submission

```bash
git clone https://github.com/RuiSun-workspace/walker-jumpman-rui-sun.git
cd walker-jumpman-rui-sun

<godot> --headless --path godot --script res://tests/test_game.gd      # 35 / 0
<godot> --headless --path godot --script res://tests/test_keyboard.gd  #  9 / 0
<godot> --headless --path godot --script res://tests/verify_reach.gd   # 15 / 0
<godot> --path godot                                                   # play it

git diff --stat 8a4d63d..HEAD -- godot/    # empty: the film shows this exact game source
```
