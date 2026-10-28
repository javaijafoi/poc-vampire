"""Converte uma arte (PNG com fundo já recortado) em pixel art.

Uso: python3 art/pixelizar.py entrada.png saida.png LARGURA [CORES]
Reduz para LARGURA pixels, limita a paleta a CORES cores e põe um contorno escuro de 1 pixel.
"""
import sys
from PIL import Image, ImageEnhance, ImageFilter


def pixelizar(entrada, saida, largura, cores=40):
    im = Image.open(entrada).convert("RGBA")
    altura = round(im.height * largura / im.width)

    # Reduz com o alfa pré-multiplicado, para a borda não puxar a cor do fundo.
    pm = im.convert("RGBa").resize((largura, altura), Image.LANCZOS)
    pq = pm.convert("RGBA")
    alfa = pq.getchannel("A").point(lambda a: 255 if a >= 128 else 0)

    rgb = pq.convert("RGB")
    rgb = ImageEnhance.Contrast(rgb).enhance(1.12)
    rgb = ImageEnhance.Color(rgb).enhance(1.25)
    rgb = rgb.filter(ImageFilter.UnsharpMask(radius=1, percent=60, threshold=2))

    # Paleta reduzida, calculada só com os pixels visíveis.
    fundo = Image.new("RGB", rgb.size, (0, 0, 0))
    fundo.paste(rgb, mask=alfa)
    pal = fundo.quantize(colors=cores, method=Image.Quantize.MEDIANCUT, kmeans=4, dither=Image.Dither.NONE)
    out = pal.convert("RGBA")

    # Contorno: pixel transparente vizinho de um opaco vira a cor mais escura da paleta.
    px, a = out.load(), alfa.load()
    escuro = min(pal.convert("RGB").getcolors(largura * altura), key=lambda c: sum(c[1]))[1]
    for y in range(altura):
        for x in range(largura):
            if a[x, y]:
                continue
            viz = [(x + dx, y + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))]
            if any(0 <= vx < largura and 0 <= vy < altura and a[vx, vy] for vx, vy in viz):
                px[x, y] = escuro + (255,)
            else:
                px[x, y] = (0, 0, 0, 0)
    out.save(saida)
    return out


if __name__ == "__main__":
    pixelizar(sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]) if len(sys.argv) > 4 else 40)
