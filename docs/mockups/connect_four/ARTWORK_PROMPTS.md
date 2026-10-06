# Connect Four production artwork

Generated with the built-in GPT image tool. Final assets live in
`assets/images/games/connect_four/`, not in Codex's generated-image directory.
The approved direction is `01-tactile-arcade.png`; screens 04–11 are the
approved companion compositions. All labels, settings, scores, turns, board
cells, help diagrams and controls are native Flutter.

## Final prompt set

### backdrop.png
Production game background portrait 1024x1536. Rich luminous cobalt blue plastic
surface with large subtly embossed circular disc recesses, matching premium
tactile Connect Four. Studio highlights top left, deep navy edges, microtexture.
Background only: no board, discs, typography or UI. Full bleed.

Refinement applied to the generated backdrop: preserve portrait cobalt plastic
and circle embossing, lower contrast 85%, remove bright white highlights, use
soft dark royal-blue relief. Calm studio backdrop around #0646B3 with darker navy
corners. No additional objects or text.

### hero.png
Isolated premium Connect Four toy board on transparent background. Exactly seven
columns and six rows, glossy cobalt board, cream ivory side rails and feet,
frontal camera with slight elevated perspective. Red and golden-yellow glossy
resin discs in bottom three rows, upper three rows empty. Cobalt oval display
plinth, small disc stacks beside feet. Realistic studio highlights, polished
plastic, crisp contours, landscape composition, narrow margin. No text/UI/scene.

### pair.png
Two tactile Connect Four discs on transparent background. Glossy ruby-red disc
leaning diagonally against a flat golden-yellow disc. Beveled rims and recessed
centers, polished resin, studio light, gentle contact shadow, centered landscape
close-up. No board, text or UI.

### red-disc.png / yellow-disc.png
One ruby-red / golden-yellow resin Connect Four token on transparent background.
Perfect circle, straight-front orthographic camera, no perspective or tilt.
Rounded beveled rim, shallow recessed center, upper-left specular highlight.
Centered object occupies 94% of square canvas. No exterior shadow or text.

## Rendering rules

- Preserve generated alpha. Corner alpha verified 0 for all four cutouts.
- Hero is decorative, never a source of board state or touch coordinates.
- Playable grid has exactly 7 columns × 6 rows, with a single shared cell geometry
  for painting and column targets. Real generated disc art sits in native holes.
- Column arrows keep their space during drop/AI thinking; no jumping board.
- Win highlights come from the controller's winning cells, not a baked image.
- Cream/navy text stays explicit in every dialog and statistics table.
- Short trophy/confetti celebration only for human/local wins; respect reduced
  motion. Do not add fake currency, profile data, online play or unrelated music.
- Validate 320×568, 360×800, 390×844 and 430×932. Short phones may scroll rather
  than clipping help/settings/actions.
- Golden files live in `test/games/classic_board/connect_four/goldens/`.

