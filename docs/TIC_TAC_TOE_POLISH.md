# Tic-Tac-Toe tactile redesign

## Approved direction

Reference: `docs/mockups/tic_tac_toe/01-tactile-arcade.png` and approved
screens 04–11. Warm embossed ivory, navy type, glossy orange X and cobalt O.
Mode selection, AI setup, gameplay, results, statistics, settings, help and
restart/leave confirmations use this family. Do not restore the old dark/glass UI.

Text, selection, counts, buttons and the playable nine-cell board remain native
Flutter. The mode hero is decorative perspective artwork; the playable board
must stay square and front-facing. Compact screens may scroll, never crop controls.

## Production assets

Directory: `assets/images/games/tic_tac_toe/`.
Generated with the built-in GPT image tool using the approved reference:

- `x-piece.png`: isolated glossy orange resin X, front-facing, transparent.
- `o-piece.png`: isolated glossy cobalt resin O, front-facing, transparent.
- `hero-board.png`: ivory nine-cell perspective display board with X/O pieces.
- `paired-pieces.png`: orange X and cobalt O sculpture on a small ivory plinth.
- `cream-background.png`: text-free warm ivory embossed X/O tile backdrop,
  subtle plant shadows; no baked-in buttons or text.

Generation requirements: coherent warm studio lighting, restrained contact
shadows, complete uncropped subjects, realistic resin instead of flat cartoon
icons. Keep original mockups separate from production assets. Trophy artwork is
shared with Memory Match. Production assets were visually inspected in rendered
390 x 844 golden screens.

Body font: Barlow SemiBold from the Google Fonts Barlow repository,
https://github.com/google/fonts/tree/main/ofl/barlow . SIL OFL 1.1 license is
bundled at `assets/fonts/Barlow-OFL.txt`. Existing Barlow Condensed is the display
face. Audio sources and prepared PCM details are in `docs/AUDIO_ASSETS.md`.

## Logic safeguards

- Human taps cannot play the AI's turn or overwrite occupied cells.
- AI runs against a copied board; it cannot mutate live state during search.
- Old AI responses cannot unlock or change a new round.
- Backgrounding, help and confirmations suspend input, AI and auto-restart.
- A stale asynchronous stats save cannot install a timer in a newer round.
- Statistics load before updates so first-game results are not overwritten.
- Results use the round's mode/difficulty snapshot, not later settings changes.
- Hard always checks immediate wins/blocks, then uses minimax most of the time.
  Easy/Medium deliberately allow mistakes; Impossible never loses in exhaustive
  reachable human-play tests (the human starts as X).

Statistics persist in existing GetStorage. Preferences retain the existing
session-scoped behavior; do not claim cross-launch preference persistence.
This is an offline game; there is no new network backend.

## Verification

Focused suite: 49 tests, including all four difficulty levels, lifecycle/race
regressions, every screen at 320x568, 360x800, 390x844 and 430x932, larger text,
compact confirmations, and eight visually inspected goldens. Run without
`--update-goldens` for the final check.

`flutter analyze` passes. Full-suite run on 2026-10-06: 203 passed, nine golden
comparisons outside Tic-Tac-Toe differ by 0.08–0.35% (Memory Match, Flappy Bird,
Profile, Achievements and app Settings). Those baselines were not overwritten.
Do not report the full suite as green until these differences are investigated.

Android debug build succeeded and was installed with `adb install -r`, retaining
app data. Real-device AI setup and settings artwork were inspected; the user
approved the final implementation. Generated screenshots and processing logs
stay out of the commit.

Removed five unreferenced legacy Tic-Tac-Toe widget/theme/animation files; Git
history retains them. No shared assets or unrelated registrants were removed.
