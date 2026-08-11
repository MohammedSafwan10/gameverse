# GameVerse agent guidance

Before changing a game screen, artwork, animation, or sound system, read:

1. `docs/FRONTEND_REDESIGN_PLAN.md`
2. `docs/GAME_POLISH_PLAYBOOK.md`
3. `docs/AUDIO_ASSETS.md` when audio is involved

Treat approved mockups as composition references, not loose inspiration. Preserve
responsive behavior at 320 x 568, 360 x 800, 390 x 844, and 430 x 932. Keep UI
text and state in Flutter, use cohesive isolated artwork assets, and verify that
nothing is clipped or omitted.

For short game effects, inspect and trim silence with FFmpeg, prefer prepared PCM
WAV assets, and preload separate `AudioPool` instances so gameplay never waits on
decoding. Confirm and document the license of every downloaded asset.

Before handing off a change, run the focused tests, `flutter analyze`, the full
test suite, and an Android debug build. Do not stage unrelated generated desktop
registrant changes or temporary asset-processing files.
