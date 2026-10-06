# Audio assets

## Connect Four

Reuses the existing licensed, FFmpeg-prepared CC0 PCM WAV effects documented
below. No new external download or music loop:

- Disc drop: Kenney Interface Sounds `pluck_001.ogg`, `memory_flip.wav`, volume 0.40.
- Win: Kenney Music Jingles `jingles_PIZZI07.ogg`, `chess_win.wav`, volume 0.45.
- Draw: Kenney Interface Sounds `confirmation_002.ogg`, `memory_match.wav`, volume 0.45.

All are mono 44.1 kHz 16-bit PCM. FFmpeg silence detection was checked for the
short drop cue; it is about 0.10 seconds with no detected 30 ms silence span.
Independent pools preload on mode entry. Mute is checked before and after pool
preparation, using the settings controller rather than an independent stale flag.
Gameplay never awaits playback. Shared legacy MP3s remain because Flappy Bird
still references them; Connect Four no longer uses them.

## Tic-Tac-Toe

Reuses existing FFmpeg-prepared CC0 mono 44.1 kHz 16-bit PCM clips:

- Move: Kenney Interface Sounds `pluck_001.ogg`, prepared as
  `memory_flip.wav`, volume 0.45.
- Win: Kenney Music Jingles `jingles_PIZZI07.ogg`, prepared as
  `chess/sounds_v2/chess_win.wav`, volume 0.48.
- Draw: Kenney Interface Sounds `confirmation_002.ogg`, prepared as
  `memory_match.wav`, volume 0.48.

See the entries below for original source URLs and licenses. Independent audio
pools preload on mode entry; gameplay does not await playback. Mute is checked
again after preload. No music loop or loud start cue is added.

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
