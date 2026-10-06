"""One-time font preparation, not used by the app or its builds.

Requires fonttools. Sources and redistribution terms: docs/FONT_ASSETS.md.
Download originals into ignored .dart_tool; ship static fonts and OFL notices.
"""
from pathlib import Path
from urllib.request import urlretrieve
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / '.dart_tool' / 'font_sources'
OUT = ROOT / 'assets' / 'fonts'
WORK.mkdir(parents=True, exist_ok=True)
for family, source in [('Outfit', 'Outfit[wght].ttf'),
                       ('Inter', 'Inter[opsz,wght].ttf')]:
    base = f'https://raw.githubusercontent.com/google/fonts/main/ofl/{family.lower()}/'
    original = WORK / source
    urlretrieve(base + source.replace('[', '%5B').replace(']', '%5D'), original)
    urlretrieve(base + 'OFL.txt', OUT / f'{family}-OFL.txt')
    for weight in (400, 500, 600, 700, 800, 900):
        axes = {'wght': weight}
        if family == 'Inter':
            axes['opsz'] = 14
        font = instantiateVariableFont(TTFont(original), axes, inplace=False)
        font.save(OUT / f'{family}-{weight}.ttf')
        print(f'{family} {weight}: {font["OS/2"].usWeightClass}')
