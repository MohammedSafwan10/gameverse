# Block Merge concept selection

Direction 2 was selected by the user: mint/coral Fresh Resin. Direction 1 and 3
are alternatives, not production themes. No redesign is implemented yet.

1. `01-ceramic-studio.png`: warm ivory, orange/cobalt ceramic number tiles.
2. `02-fresh-resin-lab.png`: **approved direction**, mint/coral translucent resin.
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

Related screen/state mockups use the approved image as their style reference:

- `04-classic-gameplay.png`
- `05-time-challenge-gameplay.png`
- `06-zen-gameplay.png`
- `07-2048-milestone.png`
- `08-no-moves-result.png`
- `09-time-up-result.png`
- `10-settings.png`
- `11-how-to-play.png`
- `12-statistics.png`
- `13-pause-dialog.png`
- `14-restart-dialog.png`
- `15-leave-dialog.png`

These are proposed related compositions awaiting review, not completed Flutter
screens. Their prompts are recorded in `RELATED_SCREEN_PROMPTS.md`. No separate
setup/difficulty screen is invented: mode selection starts the matching mode.
Dialog states are separate image files, not new navigation routes.

### Composition contract

Gameplay uses a front-facing square 4x4 board. The approved tilted hero is only
decorative mode-screen art. Reduce title/decorative height before reducing readable
tile numbers. Keep all 16 cells, score, mode-specific clock and bottom controls
visible. Gameplay has no How to Play button; mode selection/settings retain help.

Keep tile material and value colors consistent: 2 turquoise, 4 pale mint,
8 apricot, 16 coral, 32 lavender, 64 teal, 128 amber, 256 violet, 512 deep coral,
1024 blue, 2048 gold. Native Flutter renders all dynamic values and controls.
Mode-hero tile colors in the original concept are not perfectly value-consistent;
the playable grid must be consistent, not copy that decorative inconsistency.
Generated gameplay compositions may also have slight material/color variations
and different header heights. Production uses one compact shared gameplay header,
one deterministic value-color mapping, and contrast-checked native number text.
Result boards, if retained, must show actual final state, not a decorative fixture.

Classic reaching 2048 is a milestone with Keep Playing; no-moves and expired-time
results have different available actions. Undo on a blocked board is conditional
on a valid prior snapshot. Timed expiry must not offer continued timed play.
Zen mockup says no clock, not an unsupported promise of an infinitely unblocked
board. Leave-confirmation wording makes no new autosave promise. Statistics are
local sample values; no fabricated online leaderboard or achievements.

After the user reviews the related mockups, isolate production artwork and
implement a complete flow alongside the scoped logic/audio rebuild.
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
