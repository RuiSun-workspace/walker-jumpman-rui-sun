# film/ — the Brutalist explainer's source and evidence

The film itself is **not** in this repository: the assignment says to keep MP4 and MP3 out
of GitHub. Everything here is the authoring record and the evidence trail, so a reviewer
can check what the film claims without downloading it.

## The film

| Field | Value |
| --- | --- |
| Filename | `claude-liam-walker-jumpman-rui-sun-walkthrough.mp4` |
| SHA-256 | `5a7c346e81c2e0afbe5b274161a24c376789ee3c931d3908c14cdfe28023964c` |
| Format | 3840×2160 h264, 30 fps, AAC 48 kHz stereo |
| Duration | 270.767 s (4 min 31 s) |
| Size | 22.69 MB |
| Game revision demonstrated | `8a4d63d04251030607222c88a2d517002c0c10fd` |
| `build_id` | `1892d76f5d742b612041dd6587f95bcaaa38cc77399eb23e7f88ee0e6cad1732` |
| **Link** | [Northeastern OneDrive](https://northeastern-my.sharepoint.com/:v:/g/personal/sun_r3_northeastern_edu/IQDqDx3xiwwsRLmp6MLOgMnLAY9sLFPMN-FauK6ICBKZ_gM?e=AyiTai) — viewable by anyone signed in with a Northeastern account |

## What is here

| File | What it is |
| --- | --- |
| `beat_sheet.json` | All twelve beats: narration, durations, shot types, Remotion props, and the per-beat QC declarations |
| `coverage.json` | The feature contract — 15 implemented features with timed evidence in the capture, 6 planned features with reasons |
| `CAPTURE.md` | How the gameplay was recorded, the `build_id` method, the timebase, and the clip trims |
| `FACTCHECK.md` | Every number and claim in the film with its source, separating source-code fact from untested judgment |
| `SHOTLIST.md` | Beat-by-beat shot list, the labelling policy, and five things a reviewer should check by eye |
| `PROMPTS.md` | The two on-screen prompts, and which one is a reconstruction |
| `RIFF.md` | The inspect-then-narrate record, including two riffs that were cut and why |
| `BUILD-PROMPT.md` | Reproducible build steps, environment, and the documented deviations from the toolkit's command line |
| `capture/run-01-inputs.jsonl` | The input log: every key press/release and beat marker with capture time, physics tick, player position, deaths and cherries |
| `capture/source-manifest.txt` | The 18-file manifest that `build_id` hashes |
| `_qc/REPORT.md` | Gate V's final verdict: 0 BLOCKER, 0 MAJOR |
| `_qc/contact_sheet.png` | The 24 frames Gate V sampled |

## Verification a reviewer can run

With the film file in hand:

```bash
# the film is the one this repository describes
sha256sum claude-liam-walker-jumpman-rui-sun-walkthrough.mp4
# expect 5a7c346e81c2e0afbe5b274161a24c376789ee3c931d3908c14cdfe28023964c

# the evidence contract holds (needs the full reel, which includes capture/run-01.mp4)
python skills/make/godot-waikthrough/scripts/verify_walkthrough.py <reel>
```

`coverage.json` references `capture/run-01.mp4` (3840×2160, 34.3 s, sha256
`42eb71711195b5c5d9386ec07f20b7c258ba7232352a594dc2f1203d205bccd8`). That file is the raw
gameplay take and is also kept out of the repository as an MP4; it lives beside the film in
the same media location.

## Honest notes

- The gameplay is a **scripted-input capture**, not a human playtest. It is labelled that
  way on every beat, in `coverage.json`, and in the narration's framing. Human playtesting
  is recorded separately in [TEST-REPORT.md](../TEST-REPORT.md) §3.
- B00's prompt is an **illustrative reconstruction**, not a transcript.
- The code shown in B03 and B07 is **verbatim** source — B07's is the starter's original
  code, shown because it is the cause of the defect the film explains.
- Gate V's `full_bleed` and `contrast_regions` declarations on the gameplay beats are
  narrow, per-beat, and written with reasons in `beat_sheet.json`. They suppress only
  edge-bleed and whole-frame contrast respectively; every other frame check stayed active.
  One Gate V finding — B01's text overflowing the frame — was a **real defect and was
  fixed**, not declared away.
