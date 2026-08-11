# Audio assets

## Memory Match

The Memory Match effects are distributed under Creative Commons CC0.

- `memory_flip.wav`: `pluck_001.ogg` from Kenney Interface Sounds.
- `memory_match.wav`: `confirmation_002.ogg` from Kenney Interface Sounds.
- `memory_miss.wav`: `error_004.ogg` from Kenney Interface Sounds.
- `memory_win.wav`: `Win sound.wav` by Listener from OpenGameArt.

The sources were converted to mono, 44.1 kHz, 16-bit PCM WAV with FFmpeg.
Trailing silence was removed from the match and victory sounds, and short fades
were added to avoid clicks. Kenney assets are public domain and do not require
attribution. The OpenGameArt source is also marked CC0.

- https://kenney.nl/assets/interface-sounds
- https://opengameart.org/content/win-sound-effect

## Chess

The Chess effects are distributed under Creative Commons CC0 and were selected
to feel tactile without becoming noisy during rapid play.

- `chess_ui.wav`: `click_001.ogg` from Kenney Interface Sounds.
- `chess_move.wav`: `impactWood_light_001.ogg` from Kenney Impact Sounds.
- `chess_capture.wav`: `impactWood_medium_001.ogg` from Kenney Impact Sounds.
- `chess_check.wav`: `confirmation_003.ogg` from Kenney Interface Sounds.
- `chess_win.wav`: `jingles_PIZZI07.ogg` from Kenney Music Jingles.
- `chess_promote.wav`: `maximize_003.ogg` from Kenney Interface Sounds.
- `chess_tick.wav`: `tick_001.ogg` from Kenney Interface Sounds.
- `chess_error.wav`: `error_004.ogg` from Kenney Interface Sounds.

Sources were converted with FFmpeg 9 to mono, 44.1 kHz, 16-bit PCM WAV. A
4 ms fade-in and limiter prevent clicks and loud transients. Playback uses
pre-warmed, independent audio pools so move/capture/check cues do not interrupt
one another. The game-start cue intentionally reuses the quiet UI click.

- https://kenney.nl/assets/interface-sounds
- https://www.kenney.nl/assets/impact-sounds
- https://kenney.nl/assets/music-jingles
- https://www.kenney.nl/support
