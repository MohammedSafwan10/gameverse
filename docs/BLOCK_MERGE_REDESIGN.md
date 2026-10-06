# Block Merge — Fresh Resin

Approved direction: `mockups/block_merge/02-fresh-resin-lab.png`, followed by
gameplay and state references 04–15. The implementation preserves the mint room,
terrazzo hero board, coral Classic card, mint clock card, lilac Zen card, ivory
panels and deep-teal native text. It deliberately uses a compact shared header
and contrast-safe text rather than baking an entire mockup into the interface.

## Complete flow

Mode selection, Classic / Time Challenge / Zen gameplay, settings, help,
statistics, pause, restart, leave, 2048 milestone, blocked-board result and
expired-time result. There is no invented difficulty selector.

Normal layouts fit at 320×568, 360×800, 390×844 and 430×932. Compact screens
reduce decorative hero area first. Accessibility text at 1.3× can scroll instead
of clipping actions. Help/settings/statistics and tall result panels can scroll.
The mode screen retains all mode buttons and help on one page at normal scaling.

## Rules and persistence

- All modes use the same pure 4×4 swipe-2048 engine, not 2248, chain selection,
  or a number shooter. Compression → one merge per source tile → compression.
- Each changed swipe spawns exactly one random tile in an empty cell, with
  90% probability of 2 and 10% of 4. A new board starts with two tiles.
- No-op swipes do not spawn, score, increase moves or replace undo.
- Score adds each newly merged tile. Best score is historical, including after
  undo. Current highest tile is recalculated after undo.
- Classic and Zen are untimed. Zen is relaxed play, not infinite play.
  Blocked boards offer one prior undo when available, or a fresh game.
- Time Challenge has 180 seconds of active play. Elapsed timestamps handle
  delayed callbacks and fractional active time across pause. Background,
  confirmations, settings, tutorial, pause and milestone stop the active clock.
- Reaching 2048 is a one-time milestone in all modes. Keep Playing preserves
  the board; timed play resumes its remaining clock. A full board can
  subsequently show No Moves Left. Wins are recorded once across resume/undo.
- Undo restores one valid previous board/score and consumes that snapshot.
  It never restores time. Expired timed runs cannot undo or continue.
- One active run is saved as a versioned GetStorage map: board, score, prior
  snapshot, moves, active/remaining time and milestone/stat flags.
  Returning to its mode resumes it; choosing another mode replaces it.
  Restart clears the current run, not the best score.
- Valid old saves migrate on use. Invalid boards safely start fresh; invalid
  undo snapshots are ignored without discarding the current board. Malformed
  preferences cannot wipe unrelated valid records.

## Artwork, motion, audio

Ten production PNGs live in `assets/images/games/block_merge/`. Prompts:
`mockups/block_merge/ARTWORK_PROMPTS.md`. Transparent sprites were inspected
in rendered Flutter layouts. Playable cells are native text over a tinted
blank resin texture; the perspective hero is decorative. Image decode sizes
are bounded; no idle per-tile particle/pulse controllers run continuously.

Pure move trajectories drive directional slides and a short spawn response.
Reduced-motion settings bypass slides/confetti. State, hit targets and dynamic
values stay in Flutter; result mini-boards show the actual final grid.
Barlow ExtraBold is bundled under OFL as a BlockResin-only family, leaving
other game typography unchanged.

Fresh Kenney CC0 effects were downloaded and prepared with FFmpeg. See
`AUDIO_ASSETS.md`. Independent preloaded pools keep decoding out of input.
No music loop, loud startup cue or queued late effects.

Removed unused legacy storage service, tile widget and particle renderer.
These deletions are recoverable in Git history. Unrelated desktop registrants,
lockfile edits and temporary processing files are not staged.

## Verification and remaining limits

Focused tests cover 1,000 randomized boards, every direction, merge-once,
no-op behavior, undo recovery, pause, timeout, milestone/resume, statistics,
save validation, four phone sizes, accessible text, an inspected 390×844
mode golden, and actions in all six dialogs at compact and standard sizes.
Final checks: 63 focused tests pass; `flutter analyze` has no issues; Android
debug APK builds successfully. The final serial full suite reports 329 passes
and the existing nine unrelated golden failures. APK inspection confirms all
three prepared WAVs match their source files byte-for-byte.

The full suite has pre-existing Memory Match, Flappy Bird and utility golden
failures; unrelated baselines are not updated to hide them. Parallel tests can
also collide on older Tic-Tac-Toe shared storage, so a serial full run is used.
ADB reported no connected device. Physical-device artwork, audio loudness/
latency and long-session smoothness still need a device check.
The debug APK is verification, not a new production/GitHub release.
Its build still prints future Gradle/AGP compatibility warnings; this feature
does not silently perform a major Android build-system migration.
No claim of universal bug-free behavior is made.
