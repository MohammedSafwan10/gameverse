"""Prepare compact WebP copies of existing production artwork (Pillow required).
No creative image edits; converts/resizes without cropping subjects.
Run after producing test/marketing/goldens/app-home.png and saving hero-source.png.
"""
from pathlib import Path
from PIL import Image
import shutil

root = Path(__file__).resolve().parent
repo = root.parent
out = root / "assets"
out.mkdir(exist_ok=True)
sources = {
    "chess": "assets/images/home/games/chess.png",
    "memory-match": "assets/images/games/memory_match_home_hero.png",
    "flappy-bird": "assets/images/home/games/flappy_bird.png",
    "block-merge": "assets/images/home/games/block_merge.png",
    "tic-tac-toe": "assets/images/home/games/tic_tac_toe.png",
    "connect-four": "assets/images/home/games/connect_four.png",
    "quiz-master": "assets/images/home/games/quiz_master.png",
    "icon": "assets/icon/icon.png",
    "app-home": "test/marketing/goldens/app-home.png",
    "hero": "docs/mockups/website/hero-source.png",
}
for name, relative in sources.items():
    image = Image.open(repo / relative)
    limit = (1536, 1024) if name == "hero" else (780, 1688) if name == "app-home" else (640, 420)
    if name == "icon":
        limit = (128, 128)
    image.thumbnail(limit, Image.Resampling.LANCZOS)
    image.save(out / f"{name}.webp", quality=88, method=6)
for font in ["Outfit-900.ttf", "Inter-400.ttf", "Inter-600.ttf"]:
    shutil.copy2(repo / "assets/fonts" / font, out / font)
for license in ["Outfit-OFL.txt", "Inter-OFL.txt"]:
    shutil.copy2(repo / "assets/fonts" / license, out / license)
print("Prepared WebP artwork, real widget capture, offline fonts and licenses.")
