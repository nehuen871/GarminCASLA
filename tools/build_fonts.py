"""Build Garmin BMFont atlases from Orbitron (SIL OFL); requires Pillow."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "resources/fonts"
OUT.mkdir(parents=True, exist_ok=True)
CHARS = " 0123456789:/.%ABCDEFGHIJKLMNOPQRSTUVWXYZ-"
for name, size in [("Clock", 58), ("Data", 22), ("Date", 17), ("Label", 12)]:
    font = ImageFont.truetype(str(ROOT / "assets/fonts/Orbitron.ttf"), size)
    ascent, descent = font.getmetrics()
    cell_w, cell_h = size + 4, ascent + descent + 4
    atlas = Image.new("RGBA", (cell_w * 10, cell_h * ((len(CHARS) + 9) // 10)))
    draw = ImageDraw.Draw(atlas)
    lines = [
        f'info face="Orbitron" size={size} bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1',
        f'common lineHeight={ascent + descent} base={ascent} scaleW={atlas.width} scaleH={atlas.height} pages=1 packed=0',
        f'page id=0 file="{name}.png"', f'chars count={len(CHARS)}'
    ]
    for i, char in enumerate(CHARS):
        x, y = (i % 10) * cell_w, (i // 10) * cell_h
        x0, y0, x1, y1 = font.getbbox(char)
        w, h = x1 - x0, y1 - y0
        draw.text((x - x0, y - y0), char, font=font, fill="white")
        lines.append(f'char id={ord(char)} x={x} y={y} width={w} height={h} xoffset={x0} yoffset={y0} xadvance={round(font.getlength(char))} page=0 chnl=15')
    atlas.save(OUT / f"{name}.png")
    (OUT / f"{name}.fnt").write_text("\n".join(lines) + "\n")
(OUT / "fonts.xml").write_text('<fonts>\n' + ''.join(f'<font id="{name}" filename="{name}.fnt"/>\n' for name in ["Clock", "Data", "Date", "Label"]) + '</fonts>\n')
