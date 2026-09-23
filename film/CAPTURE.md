# CAPTURE — walker-jumpman-rui-sun walkthrough

## Game under capture

| Field | Value |
| --- | --- |
| Project | `walker-jumpman-rui-sun` — extension of [nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman) |
| Repository | https://github.com/RuiSun-workspace/walker-jumpman-rui-sun |
| Source commit at capture | `8a4d63d04251030607222c88a2d517002c0c10fd` |
| Working tree at capture | clean (`git status --porcelain` empty) |
| `build_id` | `1892d76f5d742b612041dd6587f95bcaaa38cc77399eb23e7f88ee0e6cad1732` |
| Engine | Godot `4.7.2.stable.official.ed1daf0bf` |
| Renderer | OpenGL 3.3 compatibility, NVIDIA RTX 3070 Laptop |
| OS | Windows 11 Home China 10.0.26200 |

### How `build_id` is computed

It is **not** a git hash — the evidence gate requires 64 hex characters, and git object
names are SHA-1. Method, reproducible:

1. `git ls-files godot` at the capture commit, sorted lexicographically — 18 files.
2. For each, one line: `<sha256 of file bytes>` + two spaces + the repo-relative path.
3. Join with `\n`, append a trailing `\n`, UTF-8, no BOM.
4. `build_id` = SHA-256 of that manifest.

The manifest itself ships beside the capture as `capture/source-manifest.txt`, so the
value can be recomputed without trusting this note.

## Capture method

An **isolated copy** of the project at `F:/7270/capture-build`, so no harness or
configuration change touches the submitted source. One change was made to that copy:

```
; capture build only
window/size/window_width_override=3840
window/size/window_height_override=2160
```

That is 6× the project's 640×360 base viewport — an exact integer scale under the
project's `canvas_items` stretch mode, so the Movie Maker records **native 3840×2160
with no resampling**. The shipped project still says 1280×720. `--resolution` on the
command line does **not** override the project's window override; that was tested and
produced a 1280×720 recording, which is why the copy's `project.godot` was edited instead.

```bash
Godot_v4.7.2-stable_win64_console.exe --path F:/7270/capture-build/godot \
  --disable-vsync --fixed-fps 30 \
  --write-movie F:/7270/reels/_frames/f.png \
  --script res://tests/capture_film.gd

ffmpeg -framerate 30 -start_number 0 -i f%08d.png \
  -c:v libx264 -preset slow -crf 15 -pix_fmt yuv420p capture/run-01.mp4
```

PNG rather than AVI: the art is flat vector, so a lossless PNG sequence costs little and
keeps 4K text crisp. 1029 frames occupied about 500 MB before encoding.

This is **offline rendering, not evidence of real-time frame rate.** It ran at roughly
7% of real time and took 7 min 44 s of wall clock for 34.3 s of footage.

## How the run is driven

`godot/tests/capture_film.gd` in the capture copy. Constraints it holds to:

- Every input is a real `InputEventKey` pushed through `Input.parse_input_event` — the
  same path a keyboard takes, and the idiom the shipped `tests/test_keyboard.gd` uses.
- Timing comes from **observing player position and state**, never from frame counts. A
  frame-counted earlier version produced `deaths=1` at 720p and `deaths=0` at 4K, so
  frame counting is not reproducible here.
- It never teleports the player, never sets state, never disables a collision, and never
  calls a test-only gameplay shortcut. **Both deaths on screen are real:** for the hazard
  death the driver declines to jump and walks into the spikes; for the fall it declines to
  jump and walks off the end of step one.

**This is a `scripted-input` capture. It is not a human playtest.** Human playtesting is
recorded separately in the project's `TEST-REPORT.md` §3.

### Timebase

With `--fixed-fps 30` and 60 physics ticks per second, each rendered frame advances
exactly 1/30 s of simulated time, so **capture seconds == video seconds**. Every timestamp
in `capture/run-01-inputs.jsonl` is therefore directly usable as a `coverage.json`
interval. One loop of the driver's `steps()` is one *rendered* frame, not one physics
tick; an earlier version divided by 60 and halved every timestamp, which the dry run
caught because a 9.98 s route was logged as 4.9 s.

## Capture inventory

| File | Detail |
| --- | --- |
| `capture/run-01.mp4` | 3840×2160, h264, 30 fps, 1029 frames, 34.300 s, 6.82 MB |
| `capture/run-01.mp4` SHA-256 | `42eb71711195b5c5d9386ec07f20b7c258ba7232352a594dc2f1203d205bccd8` |
| `capture/run-01-inputs.jsonl` | 69 lines: every key press/release and beat marker, with `t_s`, `phys_tick`, `player_tick`, player position, deaths, cherries, state |
| `capture/source-manifest.txt` | the 18-line manifest `build_id` hashes |

Original PNG frames are retained at `F:/7270/reels/_frames` until the final film's
evidence has been verified.

## Run outcome, as printed by the driver

```
FILM RUN: length=34.23s deaths=2 cherries=6/6 finish_time=9.98s
```

Beat markers, in capture seconds:

| `t_s` | Event |
| --- | --- |
| 0.000 | menu |
| 2.200 | started from the menu |
| 4.500 | hazard death: Watch the spikes |
| 5.300 | auto retry at spawn |
| 12.067 | paused |
| 13.767 | resumed |
| 16.333 | fall death: Missed the landing |
| 17.733 | manual retry, deaths 2 → 2 |
| 27.533 | completed: 9.98 s, 6 cherries, 2 retries |
| 30.233 | replay: deaths 0, cherries 0 |
| 32.733 | back to the main menu |

The dry run at 960×540 produced **identical** beat timestamps, which is the evidence that
the position-driven route is deterministic at a fixed frame rate.

## Clip trims

Cut from the PNG sequence by frame index, not by seeking the encoded file, so every
boundary is exact and every clip is frame-aligned at 30 fps:

| Beat | Start frame | Frames | Duration | Capture window |
| --- | --- | --- | --- | --- |
| `media/B02.mp4` | 0 | 180 | 6.000 s | 0.0 – 6.0 |
| `media/B03.mp4` | 180 | 378 | 12.600 s | 6.0 – 18.6 |
| `media/B04.mp4` | 558 | 282 | 9.400 s | 18.6 – 28.0 |
| `media/B05.mp4` | 840 | 189 | 6.300 s | 28.0 – 34.3 |

180 + 378 + 282 + 189 = 1029, the whole take with nothing dropped and nothing reused.

## Audio

The game ships **no audio at all** — no sound files exist in the project and none are
loaded. Liam's narration is therefore the only audio track and nothing was muted. No
sound effect was fabricated to fill the silence.
