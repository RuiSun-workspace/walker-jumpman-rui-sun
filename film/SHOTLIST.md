# SHOTLIST — claude-liam-walker-jumpman-rui-sun-walkthrough

Landscape 16:9, native 3840×2160, 30 fps. Twelve beats, 270.77 s (4 min 31 s).
Audio: Kokoro `am_onyx`, Liam in for Bear. The game has no audio of any kind.

**Every clip is duration-matched to its beat, so the compositor's retime ratio is
1.000000 and no gameplay is slowed, sped, or centre-cut.** Gameplay narration was written
short and its audio padded with trailing silence to the clip length, rather than the clip
being stretched to the narration.

| # | Act | Source | Duration | Frames | Content |
| --- | --- | --- | --- | --- | --- |
| B00 | ASK | Remotion `ClaudeComposerAsk` | 17.300 s | 519 | Claude composer cold open. **Reconstructed** walker prompt + three result lines. |
| B01 | BLUF | Remotion `BrutalistHesitantWriter` | 22.767 s | 683 | "two converging routes." struck through and replaced with "one committed climb." |
| **B02** | **GAMEPLAY** | `capture/run-01.mp4` **0.0 – 6.0 s** | 6.000 s | 180 | Menu card → Enter → run → one jump over the starter step → cherry → walks into the spikes → hazard death with the spikes flashing → auto retry. |
| B03 | MECHANISM | Remotion `GodotDevWorkbench` (code) | 34.967 s | 1049 | **Verbatim** `session.gd` DYING branch. Six cued lines + a five-row notes panel on what changed and what did not. |
| **B04** | **GAMEPLAY** | `capture/run-01.mp4` **6.0 – 18.6 s** | 12.600 s | 378 | Two starter gaps → Escape pause with the clock frozen at 07.1 s → Enter resume → pedestal → step one → walks off the edge → fall death → auto retry → manual `R` with the counter unmoved. |
| B05 | MECHANISM | Remotion `SkillTeardownMechanism` | 41.600 s | 1248 | The reachability harness: four body lines, measured windows, the chasm gate, and why the two-lane fork cannot exist. |
| **B06** | **GAMEPLAY** | `capture/run-01.mp4` **18.6 – 28.0 s** | 9.400 s | 282 | The clean run: starter course → pedestal → step one → step two → summit → over the beacon gate → the relocated flag. |
| B07 | MECHANISM | Remotion `GodotDevWorkbench` (code) | 41.233 s | 1237 | **Verbatim starter** hazard-drawing loop at `bcde8bc`. Five cued lines on the two literals, plus what they would have drawn. |
| **B08** | **GAMEPLAY** | `capture/run-01.mp4` **28.0 – 34.3 s** | 6.300 s | 189 | Completion card → Enter replay with counters reset → Escape → M → main menu. |
| B09 | VERDICT | Remotion `ClaudeVerdictArtifact` | 38.400 s | 1152 | Six lines: shown working, measured, preserved, two honest failures, still open. |
| B10 | HANDOFF | Remotion `ClaudeComposerAsk` | 33.200 s | 996 | Your Turn: paste-ready prompt, three result lines, one concrete experiment. Liam signs off here. |
| B11 | OUTRO | Remotion `ClaudeTitleOutro` | 7.000 s | 210 | Locked outro card. **Silent** under the existing slug-seeded jingle. |

Gameplay total: 34.300 s across four consecutive, non-overlapping trims — 180 + 378 + 282 + 189 = 1029 frames, the whole take, nothing dropped and nothing reused.

---

## Labelling, stated explicitly

| Thing shown | How it is labelled |
| --- | --- |
| B00's prompt | "The ask, **reconstructed**" in the narration; `role_note` and metadata `note` both say illustrative reconstruction, not a transcript. |
| B02/B04/B06/B08 | `shot.label` on each beat reads "Scripted-input capture · native 3840×2160". `coverage.json` records `method: scripted-input`. Not a human playtest, and never described as one. |
| B03/B07 code | Labelled "Verbatim project source, not a reconstruction" and "Verbatim starter source" on the card's `source` line. The toolkit's own workbench examples label themselves teaching illustrations; these do the opposite because they are real. |
| Held frames | **None.** No beat contains a frozen final-frame hold. Narration was shortened instead. |
| Replays | **None.** No action is shown twice. |

## Audio plan

Liam's narration is the only audio bed. There is nothing to duck, mute, or mix under,
because the project contains no audio file and loads none. No sound effect was fabricated
for the film. Gameplay carries no audio into the outro; the final card is silent apart from
the stock jingle, per `OUTRO-LOCK.md`.

## What a reviewer should check by eye

1. B02 at ~4.5 s — the spikes visibly change colour on the death frame, and Beacon's lamp goes dark. If the flash is not visible, the death-feedback claim in B03 is not earned.
2. B04 at ~12.1–13.8 s — the elapsed clock must read the same value for the whole pause.
3. B06 at ~8.0 s of the clip — the three gate spikes must be sitting **on the summit platform**, not on the ground line. That is the entire payoff of B07.
4. B07's notes panel — the arithmetic (320 → 184) should be checkable against `FACTCHECK.md`.
5. B11 — no narration, no gameplay audio, no invented jingle.
