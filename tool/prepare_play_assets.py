"""Export exact-size Play images; format/resampling only, no creative edits.

Run: python tool/prepare_play_assets.py
Feature source must come from the recorded image-generation workflow.
"""
from pathlib import Path
from PIL import Image

repo = Path(__file__).resolve().parent.parent
out = repo / "docs/play-store/assets"
out.mkdir(parents=True, exist_ok=True)
for source, name, size in [
    (repo / "assets/icon/icon.png", "app-icon-512.png", (512, 512)),
    (repo / "docs/play-store/feature-evergreen-source.png", "feature-graphic-1024x500.png", (1024, 500)),
]:
    with Image.open(source) as image:
        assert abs(image.width / image.height - size[0] / size[1]) < 0.02, "Unexpected aspect ratio; regenerate rather than distort"
        image.convert("RGB").resize(size, Image.Resampling.LANCZOS).save(out / name, optimize=True)
    print(f"{name}: {size}, {(out / name).stat().st_size} bytes")
