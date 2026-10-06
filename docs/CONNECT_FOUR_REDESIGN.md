# Connect Four redesign handoff

Approved references: `docs/mockups/connect_four/01-tactile-arcade.png` and
`04`–`11`. Direction 2 and 3 are not production themes.

Implemented mode selection, AI difficulty setup, gameplay, human/AI/local
results, draw, pause/restart/leave dialogs, statistics, settings and help.
Cobalt/cream tactile surfaces, real glossy disc/board cutouts, readable native
text, safe areas and scroll fallback replace the old dark/glass UI.

## Game logic

- 7×6 gravity board. Red/human starts; local players alternate red/yellow.
- Easy: mostly random legal moves, with occasional tactical win.
- Medium: immediate wins and blocks, otherwise center-ordered depth-3 search.
- Hard: immediate wins and blocks, depth-5 alpha-beta search off the UI isolate.
  Hard is strong but **not claimed unbeatable**.
- Gravity-aware four-cell windows; terminal scores exceed heuristic bounds.
- Horizontal, vertical and both diagonal wins; a winning final move beats draw.
- Exactly four winning cells including the last disc are highlighted.
- Immutable board snapshots, guarded column indices and full-column rejection.
- Generation guards cancel old moves after reset/disposal/settings changes.
- Pause blocks taps and delayed turns/search application. Resuming continues the
  pending turn once. Pause also freezes the game duration and auto-restart.
- Auto-restart waits five active seconds; the result remains readable and manual
  replay is available. Reset/disposal cancels its timer.
- Results recorded once; incomplete rounds never count. Statistics sanitize
  malformed persisted fields. Existing valid results/preferences are preserved.
- Three independent quiet PCM audio pools; authoritative live mute preference.

## Verification

Focused tests include tactical AI for every difficulty, legal move/self-play
and immutable inputs, invalid columns, terminal search refusal, draw and diagonal
fixtures, paused/reset work, duplicate result prevention and corrupt persistence.
Responsive/golden tests cover six pages plus win/draw at all four required
phone sizes, and compact pause/restart/leave dialogs.

Final verification on 2026-10-06: all 64 Connect Four tests pass, and the combined
Tic-Tac-Toe/Connect Four suite passes 123 tests. Analyzer is clean and the Android
debug build succeeds. The APK was installed retaining data; mode selection and
gameplay were inspected on the physical device. Full suite: 271 passed, nine
existing golden differences in Memory Match, Flappy Bird and utility screens.
Those unrelated baselines were not overwritten; do not claim a fully green suite.

Do not update golden files blindly. Visually compare with approved references,
then run focused tests again **without** updating baselines, analyzer, full
suite and one final Android debug build. Real-device verification needs a full
restart/install after adding new bundled assets.

Release cleanup replaced Flappy Bird's shared `drop.mp3` / `win.mp3` references
with licensed PCM pools, then removed both obsolete MP3 files.
Do not stage unrelated desktop registrants, pre-existing lockfile changes,
test failure images, or temporary processing files.
