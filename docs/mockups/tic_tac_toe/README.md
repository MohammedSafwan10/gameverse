# Tic-Tac-Toe mockups

Approved mode-selection direction: 01-tactile-arcade.png (user selected).
02 and 03 are unselected alternatives.

Screens/states 04–11 were approved and implemented in the tactile redesign.
Generated with the built-in GPT image-generation tool using 01 as a style reference.
Warm ivory surfaces, glossy orange X / cobalt O, navy type and tactile depth.
Keep live boards front-facing and square; text, state, controls and pieces remain
native Flutter, with isolated artwork rather than a full-screen screenshot.
Statistics shown are sample data. 10 is a component sheet of two separate dialogs,
not simultaneous modals. Local multiplayer adapts the gameplay player labels.
Loss states and reset confirmations should reuse the approved components.
Production artwork, logic fixes and verification are documented in
`docs/TIC_TAC_TOE_POLISH.md`. UI text and state stay native Flutter.

## Shared generation prompt

Use case: ui-mockup. Create a single high fidelity portrait 9:19.5 mobile Tic Tac Toe UI mockup. Input image 1 is the APPROVED STYLE REFERENCE, not an edit target: match its warm ivory embossed grid backdrop, orange X and cobalt blue O glossy realistic resin pieces, beveled cream surfaces, navy bold sans-serif typography, beautifully restrained studio lighting and tactile soft contact shadows. Same product family, no new visual theme. Practical native Flutter controls and readable copy at 390x844. Screen fills canvas, no phone frame, no watermark, no attribution, no tiny illegible labels, no clipping. Render ONLY requested screen and specified copy; separate artwork from labels; ample safe margins, compact deliberate hierarchy. Not childish cartoon, not generic flat UI or glassmorphism.

## Screen prompts

### 04-gameplay.png

GAMEPLAY screen. Top back icon left, centered compact "TIC TAC TOE" title, sound and restart icons right. Orange small chip "VS AI · MEDIUM". Two cream player panels side-by-side: orange X "YOU", blue O "AI", each with score "0". Orange highlighted status pill "YOUR TURN". Center dominant perfectly square FRONT-FACING 3x3 ivory recessed board with exactly nine equal cells, no perspective distortion; state row1 X, empty, O; row2 empty, X, empty; row3 empty, O, empty. Glossy orange X and blue O with subtle depth, empty cells obvious, no winning line. Below board supporting text "Place an X in an empty square". Bottom small cream button "HOW TO PLAY". Board stays entirely visible with generous tap targets, no invented timer/coins/undo.

### 05-statistics.png

STATISTICS full screen. Back icon, heading "STATISTICS", subtle small X/O art beside title. Compact segmented mode selector "VS AI" selected orange, "TWO PLAYERS" cream. Cream hero panel containing beautiful small gold trophy and "WIN RATE", big "60%", orange progress arc. Three equal compact metric cards in one row: "PLAYED" "20", "WON" "12", "DRAWS" "3". Below cream section "BY DIFFICULTY" with four clean rows "Easy" "5 wins", "Medium" "4 wins", "Hard" "2 wins", "Impossible" "1 win". Bottom small cream section "ACHIEVEMENTS" with three restrained embossed medal icons, readable labels "First Win", "Win Streak", "Unbeatable". Visually coherent game statistics not corporate dashboard. Example data only. All copy dark navy on cream, no white-on-white.

### 06-settings.png

SETTINGS full screen. Compact back icon and heading "SETTINGS". Small glossy orange X and blue O decorative art near header, not giant hero. Three well-spaced cream rounded groups. Group "GAMEPLAY": rows "Game mode" value "VS AI" chevron, "Difficulty" value "Medium" chevron, "Auto restart" toggle off. Group "SOUND & HAPTICS": rows "Sound effects" orange toggle on, "Vibration" orange toggle on. Group "STATISTICS": rows "Reset current mode stats" chevron and "Reset all stats" chevron with restrained red icon. Bottom unobtrusive outline button "RESTORE DEFAULTS". Clear native settings structure, generous touch targets, consistent left alignment and legible contrast. No invented skins/music controls.

### 07-ai-difficulty.png

AI DIFFICULTY setup screen, full portrait. Back icon, compact title "PLAY VS AI". Ivory hero surface with a small 3D X/O paired sculpture and dark navy heading "Choose your challenge". Four generously padded selection rows: "EASY" subtitle "A relaxed start"; "MEDIUM" subtitle "A balanced challenge"; "HARD" subtitle "Think ahead"; "IMPOSSIBLE" subtitle "Can you force a draw?". Medium selected with orange outlined cream card and circular check; others cream with empty radio. Bottom broad orange rounded CTA "START GAME" with cream arrow icon. No invented choice of player symbol, no extra game modes. Clean type and each row artwork only tiny coherent tactile badge, no excessive robots.

### 08-win-result.png

WIN RESULT full portrait screen. Compact back icon, centered cream celebration panel with small golden trophy, tasteful sparse confetti, orange dimensional heading "YOU WIN!" and navy subtitle "Three in a row". Center a front-facing square ivory 3x3 board, exactly nine cells, row1 X O O, row2 empty X empty, row3 empty empty X. All X orange and O blue; subtle orange diagonal winning connector behind X from top-left to bottom-right, never obscuring pieces. Small chip "VS AI · MEDIUM". Bottom broad orange "PLAY AGAIN" button and cream outlined "BACK TO MODES" button. No stars rating, invented currency or stats. Realistic tactile board and trophy like reference.

### 09-draw-result.png

DRAW RESULT full portrait screen. Warm ivory backdrop. Small balanced orange X and blue O paired sculpture, navy heading "IT'S A DRAW", subtitle "A well-matched round". Square front-facing 3x3 board exactly nine cells, row1 X O X; row2 X O O; row3 O X X. Must follow exact cell arrangement: this is a legal draw, NO three equal pieces on any row column or diagonal. Orange X blue O. No winning connector, no trophy, no victory confetti. Bottom orange "PLAY AGAIN", secondary cream "BACK TO MODES". Friendly and premium, not sad or childish.

### 10-confirmations.png

One portrait UI reference SHEET showing TWO separate centered cream rounded confirmation dialog cards stacked vertically with clear space between them. Background is gently dimmed blurred ivory gameplay board, no fake full screen navigation. Upper card: small tactile circular orange restart arrow, heading "RESTART GAME?", subtitle "Start this round again?", cream secondary button "KEEP PLAYING", orange primary button "RESTART". Lower card: small navy exit arrow in ivory disc, heading "LEAVE GAME?", subtitle "Your current round will be lost.", orange main button "KEEP PLAYING", smaller navy text button "LEAVE GAME". Explicitly two component previews, NOT a real UI showing two modal dialogs simultaneously. Restrained hierarchy, ample button spacing, no giant art or duplicate copy.

### 11-how-to-play.png

HOW TO PLAY full portrait screen. Back icon, heading "HOW TO PLAY". Small paired orange X and blue O below title. Three cream rounded instructional sections with small orange numbered circle and dark navy copy. Section 1 "TAKE TURNS", supporting "Place your piece in an empty square." tiny front-facing board preview. Section 2 "MAKE A LINE", supporting "Match three across, down, or diagonally." three miniature 3x3 board diagrams clearly showing orange X row, column, and diagonal wins respectively. Section 3 "FULL BOARD?", supporting "No winning line means a draw." tiny balanced X/O illustration. Bottom broad orange CTA "GOT IT". All instructions readable, diagrams precise exactly 3x3 grids, no extra rules or scoring inventions. Generous spacing and no art obscuring copy.

## Help diagram correction

Precise edit of provided HOW TO PLAY UI mockup. Preserve entire layout, every word, palette, typography, lighting, materials, all buttons, and first two instruction sections EXACTLY. Change ONLY the tiny 3x3 board in lower-right of section 3 titled FULL BOARD?. Current board incorrectly has winning diagonals. Replace nine pieces with this EXACT arrangement, row1 orange X, blue O, orange X; row2 orange X, blue O, blue O; row3 blue O, orange X, orange X. This must be a legal draw with no three identical symbols across rows, columns or diagonals. Keep exactly nine equal cells and identical realistic glossy resin pieces. No other changes.

The final help image replaces an invalid draw illustration. Final draw boards:
X O X / X O O / O X X (no winning row, column or diagonal).
