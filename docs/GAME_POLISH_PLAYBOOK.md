# GameVerse Game Polish Playbook

## Why this exists

Read this guide before redesigning a game screen or replacing its sound effects.
It records the workflow that produced the approved Memory Match experience: UI
that closely matches the selected mockup, cohesive artwork, immediate tactile
audio, compact-phone reliability, and documented asset licensing.

This file complements `docs/FRONTEND_REDESIGN_PLAN.md`. The redesign plan defines
the product direction; this playbook explains how to execute and verify it.

## Start from evidence

Before editing code:

1. Inspect the approved mockup at its original resolution.
2. Capture or inspect the current implementation at the same logical phone size.
3. Compare hierarchy, proportions, crop behavior, typography, spacing, depth,
   artwork scale, and decorative details—not only colors and widget order.
4. List concrete mismatches before changing code. Examples include a hero being
   too short, artwork being clipped, cards feeling flat, or labels wrapping.
5. Inspect the controller and navigation contract so visual changes do not alter
   game rules accidentally.

Do not treat a mockup as a loose mood board after the direction has been
approved. Reproduce its composition with responsive Flutter widgets while
keeping text and controls native, accessible, and adaptable.

## UI implementation rules

- Use generated artwork as individual transparent assets, not as a screenshot of
  the entire interface.
- Render text, buttons, progress, scores, and state in Flutter.
- Preserve complete subjects. Prefer `BoxFit.contain`, bounded `Stack` layouts,
  or rows/columns with `Expanded` over grids that silently crop their final row.
- Match the reference's major proportions first: header, hero, primary mode card,
  secondary cards, and bottom action. Fine spacing comes afterward.
- Add depth deliberately with borders, highlights, and soft shadows. A correct
  layout can still feel unfinished when every surface is flat.
- Use a dedicated display style for game titles instead of stretching ordinary
  body typography.
- Keep decorative sparkles and background marks non-interactive and subtle.
- Scale height, padding, typography, and artwork for compact phones. Scrolling is
  acceptable when content cannot fit, but clipping and overflow are not.

Verify every redesigned screen at these logical sizes:

- 320 x 568
- 360 x 800
- 390 x 844
- 430 x 932

The Memory Match responsive/golden coverage is in
`test/games/brain_training/memory_match/memory_match_screens_responsive_test.dart`.

## Artwork workflow

When existing artwork cannot match the selected direction:

1. Generate a small, cohesive sprite sheet using the approved mockup as the
   visual reference.
2. Request text-free, isolated subjects on a flat chroma-key background when
   transparent output is unavailable.
3. Remove the chroma background and inspect every extracted asset at full size.
4. Use consistent lighting, material, camera angle, border treatment, and color
   palette across the set.
5. Save only final production assets under `assets/images/`; do not ship source
   sheets, temporary extractions, or unused variants.
6. Register the asset path in `pubspec.yaml` and add a test when missing assets
   would otherwise fail silently.

Memory Match production art lives in
`assets/images/games/memory_match/`.

## Sound selection workflow

Sound is part of the game feel, not a last-minute placeholder. Give distinct
events distinct sounds:

- Tap or card flip: very short and tactile, typically 50–150 ms.
- Correct match: bright confirmation, typically 300–700 ms.
- Incorrect match: soft negative cue, typically 80–250 ms; avoid harsh alarms.
- Game win: memorable flourish, typically 1–3 seconds.

Search reputable asset libraries and confirm the license on the source page
before downloading. Prefer CC0/public-domain assets for commercial safety.
Kenney and properly marked OpenGameArt files worked well for Memory Match.

Do not reuse an unrelated effect merely because it already exists in the repo.
The sound should fit the action, emotional tone, and visual material of the game.

## FFmpeg preparation

Inspect duration and silence before integrating a clip:

```powershell
ffprobe -v error -show_entries format=filename,duration -of csv=p=0 input.wav
ffmpeg -hide_banner -i input.wav -af "silencedetect=noise=-45dB:d=0.01" -f null NUL
```

For short mobile effects, convert to mono 44.1 kHz 16-bit PCM WAV. PCM is larger
than MP3 or OGG but avoids decoder startup latency and is appropriate for small
effects:

```powershell
ffmpeg -y -i input.ogg -ac 1 -ar 44100 -c:a pcm_s16le output.wav
```

Trim dead space and add a short fade when needed:

```powershell
ffmpeg -y -i input.wav `
  -af "atrim=0:1.9,afade=t=out:st=1.74:d=0.16,alimiter=limit=0.9" `
  -ac 1 -ar 44100 -c:a pcm_s16le output.wav
```

Choose trim points from the actual `silencedetect` output; do not copy the sample
times blindly. Keep FFmpeg downloads and source packs in a temporary directory.
Commit only the prepared game assets.

## Flutter low-latency audio pattern

Avoid calling `AudioPlayer.play(AssetSource(...))` on one shared player for every
event. That repeatedly loads/decodes assets and rapid effects interrupt each
other.

Use the installed `audioplayers` package's `AudioPool`:

1. Create a separate pool for each sound.
2. Preload the pools while the mode screen is visible.
3. Give frequent sounds such as card flips multiple prepared players.
4. Start playback without awaiting it in gameplay logic; audio must not block a
   card flip, match resolution, timer, or navigation.
5. Re-check mute state after asynchronous pool initialization.
6. Dispose prepared pools with the owning service.

The production example is
`lib/games/brain_training/memory_match/services/sound_service.dart`.

## Licensing and project hygiene

- Record the original filename, creator or pack, source URL, license, conversion,
  and edits in `docs/AUDIO_ASSETS.md`.
- Add every final sound to `pubspec.yaml`.
- Do not delete shared legacy sounds until repository-wide usage is checked.
- Do not commit downloaded archives, FFmpeg binaries, failed golden diffs, or
  generated desktop registrant noise.
- Preserve unrelated user changes in the working tree.

## Definition of done

A game polish pass is complete only when:

- The implementation is visually compared with the approved reference.
- No important artwork, text, or controls are missing or cropped.
- Tap, match, miss, and completion feedback sound intentional and immediate.
- Audio has no accidental leading/trailing silence.
- Asset licenses and transformations are documented.
- `flutter analyze` passes.
- Focused responsive/golden tests pass twice: once when updating approved
  goldens, then again without `--update-goldens`.
- The complete Flutter test suite passes.
- A debug Android APK builds successfully.
- New assets are checked on a real device after a full restart, because hot
  reload does not refresh the asset bundle.

