# Offline typography

Outfit and Inter are bundled as native Flutter fonts; no HTTP requests, cache
warm-up or GoogleFonts package is needed at runtime. Static weights 400–900 were
instantiated from Google Fonts' original variable TTFs using fontTools. Inter's
optical size is fixed at 14 for readable supporting/UI text.

- Outfit: https://github.com/google/fonts/tree/main/ofl/outfit
- Inter: https://github.com/google/fonts/tree/main/ofl/inter
- Both: SIL Open Font License 1.1; notices bundled under `assets/fonts/`.
- Neither supplied notice declares a Reserved Font Name.
- Reproduction: `python tool/prepare_fonts.py` with fontTools installed.
- Existing Barlow/Barlow Condensed and DM Serif licenses remain in this folder.

Font preparation is asset generation, not required during normal app builds.
