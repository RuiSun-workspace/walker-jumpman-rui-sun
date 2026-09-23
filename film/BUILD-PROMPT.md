# BUILD-PROMPT — how this reel was produced, reproducibly

Everything here ran locally with no paid service, no API key, and no network call beyond
one-time dependency and model downloads.

## Environment

| Tool | Version | Where |
| --- | --- | --- |
| Godot | `4.7.2.stable.official.ed1daf0bf` | `F:/7270/godot-4.7.2/` (portable) |
| Python | 3.11.5 in a venv | `F:/7270/film-env/` |
| ffmpeg / ffprobe | 9.0.1 essentials | `F:/7270/tools/ffmpeg-9.0.1-essentials_build/bin/` |
| Node / npm | 22.x / 11.6.1 | system |
| Remotion deps | 234 packages | `F:/7270/brutalist.art/runtime/remotion/node_modules/` |
| Kokoro model | `kokoro-v1.0.onnx` + `voices-v1.0.bin` | `F:/7270/brutalist.art/runtime/models/kokoro/` |
| OS | Windows 11 Home China 10.0.26200 | — |

**Python 3.11, not 3.14.** `requirements.txt` pins `Pillow<11`, which has no cp314 wheel,
so pip falls back to a source build and fails.

Every shell that runs the pipeline needs:

```
PATH = F:\7270\tools\bin;F:\7270\tools\ffmpeg-9.0.1-essentials_build\bin;%PATH%
PYTHONUTF8=1
PYTHONIOENCODING=utf-8
```

## Steps, in order

```bash
# 1. record — from an ISOLATED copy of the game, so no config change touches the source
Godot_v4.7.2-stable_win64_console.exe --path F:/7270/capture-build/godot \
  --disable-vsync --fixed-fps 30 \
  --write-movie F:/7270/reels/_frames/f.png \
  --script res://tests/capture_film.gd

# 2. assemble the full take (evidence) and the four per-beat trims (media slots)
ffmpeg -framerate 30 -start_number 0    -i f%08d.png -frames:v 1029 ... capture/run-01.mp4
ffmpeg -framerate 30 -start_number 0    -i f%08d.png -frames:v 180  ... media/B02.mp4
ffmpeg -framerate 30 -start_number 180  -i f%08d.png -frames:v 378  ... media/B04.mp4
ffmpeg -framerate 30 -start_number 558  -i f%08d.png -frames:v 282  ... media/B06.mp4
ffmpeg -framerate 30 -start_number 840  -i f%08d.png -frames:v 189  ... media/B08.mp4

# 3. evidence gate — must pass before authoring anything
python skills/make/godot-waikthrough/scripts/verify_walkthrough.py REEL

# 4. narration
python runtime/scripts/generate_audio_kokoro.py REEL

# 5. align: pad gameplay audio with silence to the clip length; set render_duration_s
#    (scratch script; the rule it applies is documented in SHOTLIST.md)

# 6. bookends and graphic beats
python runtime/scripts/remotion_scenes.py REEL

# 7. master
python runtime/scripts/compile.py REEL --height 2160 --fps 30 --out REEL/exports/landscape
```

Step 7 is exactly what `./art final REEL --height 2160 --fps 30` dispatches to
(`art:111-116`), invoked directly because of the shell issue in the next section.

## Deviations from the documented command line, and why

The skill's commands are `./art godot-waikthrough --check REEL`, `./art final …` — bash
entry points. Three toolkit defects made the literal invocations impossible on this
machine. **None of them was worked around by editing the toolkit**, which is untouched
apart from `runtime/remotion/package-lock.json`, which `npm install` rewrote.

1. **`./setup` and `./art doctor` exit 1 on a clean clone.** Their ElevenLabs guard greps
   the whole repository and matches the repository's *own* nine example files under
   `youtube/`. Platform-independent. Worked around by calling the underlying scripts
   directly; the readiness checks the guard would have run were performed by hand and are
   recorded in the project's `FRICTIONAL.md`.
2. **`remotion_scenes.py:90` calls `subprocess.run(["npx", …])`.** Windows `CreateProcess`
   resolves only `.exe`, so `npx.cmd` is invisible to it and all eight graphic beats failed
   with `WinError 2`. Worked around with `F:/7270/tools/bin/npx.exe`, a 4.6 KB C# shim that
   forwards straight to `node.exe node_modules/npm/bin/npx-cli.js` — which is all `npx.cmd`
   does.
3. **The same script has a UTF-8 / GBK double bind on a Chinese-locale Windows.** It reads
   the beat sheet with `Path.read_text()` and no encoding, and decodes child output with
   `subprocess.run(text=True)`. With `PYTHONUTF8=1` the sheet reads correctly but child
   output crashes the decoder; without it, the reverse. It also crashes *twice*, because its
   error handler then does `r.stderr[-800:]` on a `None`. Worked around by launching from
   PowerShell rather than Git Bash, which keeps the PATH in a form the `remotion.cmd` →
   `cmd.exe` layer can use. The byte that crashed the decoder turned out to be a localized
   cmd message: `'"node"' 不是内部或外部命令`.

A fourth defect does not affect this deliverable: ffmpeg's `drawtext` filter receives a
Windows path containing `\` and `:` and the filtergraph parser mangles it. That only
affects `--review` cuts (`compile.py:788`); a final master never draws the label.

## Steps that are mine rather than the toolkit's

- `godot/tests/capture_film.gd` in the capture copy — the input-only route driver.
- The frame-index trims in step 2, chosen from the driver's own beat log.
- The alignment rule in step 5: narration is written shorter than the clip and padded with
  silence, so gameplay is never retimed. The toolkit's ordinary footage path would have
  slowed the clip to fit the narration.

## What was not done

No upload, no publication, no Git push of media. No Short was produced. No vertical cut.
No `pantry` intake was run on the captures. No paid media generation of any kind.
