# Block Merge concept selection

Three mode-selection concepts; none is approved or implemented yet:

1. `01-ceramic-studio.png`: warm ivory, orange/cobalt ceramic number tiles.
2. `02-fresh-resin-lab.png`: mint, coral and translucent resin.
3. `03-midnight-glass.png`: navy, luminous glass tiles and amber accents.

Generated with the built-in GPT image tool. Full prompt set: `PROMPTS.md`.
Best-score values are illustrative, not a claim about stored player data.
These are composition references, not production interface assets.

## Rule direction and research

The current code implements a 4x4 swipe-based 2048 variant, not a drag-chain
2248 game or falling-number shooter. Keep this distinction explicit before a
logic rebuild. The original game describes moving tiles and merging equal numbers:
https://gabrielecirulli.github.io/2048/ . A contemporary developer listing also
describes Classic, Zen and three-minute Time Attack variants:
https://play.google.com/store/apps/details?id=com.aramis.puzzle2048 .

Concepts preserve the current Classic, Time Challenge and Zen choices. The
precise Zen recovery rules and timed-mode win conditions need agreement before
implementation. Do not promise infinite play on a finite blocked board without
defining the recovery mechanic. Do not copy competitor artwork or sound assets.

## Next after selection

Create matching gameplay, setup if needed, results, pause/restart/leave, settings
and help mockups; then isolate production art and implement a complete flow.
Keep all mode actions/help on one page at normal phone sizes; reduce decorative
hero height first on compact devices. Native Flutter should render tile numbers,
scores, controls and state. A perspective hero must not become a distorted
playable board.

The user also requested a logic/game-feel rebuild and newly sourced sound effects.
This concept-only step has not changed controllers, downloaded sounds or built an
APK. During implementation, review directional merge order, once-per-turn merges,
spawn only on changed moves, score consistency, undo after win/game-over, mode
switch/save behavior, malformed saves, active-time clocks, repeated input and
exactly-once statistics. Current move-audio code contains a placeholder; it is
not a completed sound system. Source licensed quiet move/merge/milestone/result
effects, inspect and prepare them with FFmpeg, and preload independent pools.
