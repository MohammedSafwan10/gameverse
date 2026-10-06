# Website asset manifest

Approved composition: `docs/mockups/website/01-tactile-arcade.png`.
Concept images are not app screenshots. The production hero has native text
and a separate phone layer rather than baked-in fictional UI.

| Output | Source | Role / processing |
| --- | --- | --- |
| hero.webp | docs/mockups/website/hero-source.png | AI-generated text-free cream studio scene, 1536×1024, opaque; contain with CSS edge fade |
| app-home.webp | test/marketing/goldens/app-home.png | Actual Flutter HomeScreen widget render, 390×844; contains no invented statistics; not a physical-device capture |
| icon.webp | assets/icon/icon.png | Existing GameVerse app icon, maximum 128×128 |
| chess.webp | assets/images/home/games/chess.png | Existing production game artwork |
| memory-match.webp | assets/images/games/memory_match_home_hero.png | Existing production game artwork |
| flappy-bird.webp | assets/images/home/games/flappy_bird.png | Existing production game artwork |
| block-merge.webp | assets/images/home/games/block_merge.png | Existing production game artwork |
| tic-tac-toe.webp | assets/images/home/games/tic_tac_toe.png | Existing production game artwork |
| connect-four.webp | assets/images/home/games/connect_four.png | Existing production game artwork |
| quiz-master.webp | assets/images/home/games/quiz_master.png | Existing production game artwork |
| Outfit / Inter | assets/fonts/ | Self-hosted typefaces, SIL Open Font License; license files shipped alongside them |

Artwork is original AI-generated project artwork, not scraped stock artwork.
No third-party stock license is claimed. Existing art provenance remains in
the app's redesign documents. Hero prompt: a cream tactile game collection
with king/knight, yellow bird, O/X, matching flower/rocket cards, Connect Four
discs and number tile; no text or phone; reserve upper-center space for a real
app-screen layer. Consistent studio lighting, soft shadows, full subjects.

`prepare_assets.py` only converts/resizes existing images without cropping or
creative image editing. Card images fit within 640×420; WebP quality 88. Raw
source mocks and the Flutter screenshot test are not shipped by Docker.

To regenerate compressed assets, install Pillow and run from the repo root:

```powershell
python website/prepare_assets.py
node website/build.mjs
```

The widget capture uses `flutter test
test/marketing/home_capture_test.dart --update-goldens`. Review changes visually
and rerun without `--update-goldens` before accepting a new baseline. Widget
captures can differ slightly from device font fallback and status bars.
