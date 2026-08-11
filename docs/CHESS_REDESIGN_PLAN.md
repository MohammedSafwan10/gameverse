# Chess redesign plan

## Approved direction

Direction A is the visual source of truth for the Chess redesign. The complete
screen reference pack is in `docs/mockups/chess/`.

The visual system uses:

- deep cobalt/navy backgrounds with a restrained chess pattern;
- warm ivory cards and headers;
- orange primary actions and selected states;
- thin gold edging and controlled soft shadows;
- premium stylized 3D ceramic, stone, and metal chess artwork;
- tall condensed display type with simpler readable supporting type.

The mockups are composition references, not flattened production screens. Text,
buttons, board state, timers, move lists, switches, result reasons, and selection
states must remain native Flutter UI.

## Reference pack

1. `01-mode-selection.png`
2. `02-gameplay.png`
3. `03-match-setup.png`
4. `04-pause-options.png`
5. `05-promotion.png`
6. `06-checkmate-result.png`
7. `07-draw-result.png`
8. `08-settings.png`
9. `09-how-to-play.png`
10. `10-move-history.png`

## Existing product contract to preserve

- Modes: local play and play versus AI. Training exists in the controller and
  must not be removed accidentally even if it is not promoted on the mode screen.
- AI difficulty: three levels.
- Optional clocks: 5, 10, 15, or 30 minutes per player.
- Legal-move and last-move highlighting.
- Board theme selection.
- Sound toggle.
- Move history with copy action.
- FEN copy and import.
- Promotion to queen, rook, bishop, or knight.
- Restart and guarded leave flows.
- Saved win, loss, and draw statistics.

## Gameplay and result states

The main gameplay layout must support normal play, selected piece, legal moves,
last move, capture, check, AI thinking, paused play, and timed play. The board is
always a true square and should use the maximum safe width without cropping.

The result layout is reusable. It must distinguish:

- checkmate;
- resignation;
- timeout;
- stalemate;
- dead/insufficient-material position;
- repetition draw;
- move-rule draw;
- agreed draw if draw offers are retained or added.

Result copy must state the reason instead of showing only a generic `DRAW`.
Official rule references:

- FIDE Laws of Chess: https://handbook.fide.com/chapter/e012023
- FIDE Online Chess Regulations:
  https://handbook.fide.com/chapter/OnlineChessRegulations

## Production artwork inventory

Generate and ship isolated artwork rather than cropping it from the mockups:

- mode hero: ivory king and black knight on a compact board pedestal;
- Classic mode board preview;
- AI emblem: black/ivory mechanical knight or knight bust;
- two-player emblem: facing ivory and black kings;
- match setup gold chess clock;
- pause artwork: ivory king and black knight;
- promotion pieces: ivory queen, rook, bishop, and knight;
- victory artwork: gold trophy with ivory king;
- draw artwork: opposing kings with a small balance symbol;
- settings artwork: gold gear and black knight;
- history artwork: scroll and black knight;
- help artwork for checkmate, movement, castling, en passant, and promotion.

The playable board pieces should remain a consistent deterministic set. Prefer
the existing vector piece pipeline with improved material treatment in Flutter,
or a rigorously aligned set of isolated sprites. Do not use independently
generated piece images that differ in camera angle, scale, or silhouette.

## Responsive implementation rules

Verify at 320 x 568, 360 x 800, 390 x 844, and 430 x 932.

- Compact screens may scroll, but the board itself must never be clipped.
- Reduce header and player-panel height before reducing board size.
- Keep promotion choices reachable; switch from one row to a 2x2 grid when
  available width cannot preserve 44 logical-pixel touch targets.
- Keep destructive leave/reset actions visually separated from primary actions.
- Pause clocks while a blocking dialog is open.
- The move-history dialog needs a bounded, independently scrollable list.
- Use native text so labels remain sharp and adaptable.

## Suggested implementation order

1. Theme tokens and reusable ivory/navy/orange surface components.
2. Mode selection and match setup.
3. Board, player panels, clocks, state banner, and bottom actions.
4. Promotion, pause, restart, leave, and move-history dialogs.
5. Result screen with dynamic ending reason.
6. Settings and How to Play.
7. Responsive tests, golden tests, logic regressions, analysis, full tests, and
   Android debug build.
