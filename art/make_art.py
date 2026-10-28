# Gera a arte provisória em pixel art (320x180) usada nas duas versões.
import os, random, sys
from PIL import Image, ImageDraw
out = sys.argv[1]
random.seed(7)
W, H = 320, 180
bg = Image.new('RGB', (W, H), (34, 16, 22))
d = ImageDraw.Draw(bg)
# parede de tijolo
for y in range(0, 132, 6):
    off = 0 if (y // 6) % 2 == 0 else 6
    for x in range(-off, W, 12):
        c = random.choice([(42, 20, 26), (38, 18, 24), (46, 22, 28)])
        d.rectangle([x, y, x + 10, y + 4], fill=c)
# janela com chuva e luzes da cidade
d.rectangle([14, 18, 114, 104], fill=(52, 30, 22))
d.rectangle([18, 22, 110, 100], fill=(12, 22, 40))
for _ in range(70):
    x, y = random.randint(18, 110), random.randint(60, 100)
    d.point((x, y), fill=random.choice([(230, 190, 90), (90, 200, 200), (200, 120, 80), (120, 140, 200)]))
for i in range(6):  # prédios
    x0 = 18 + i * 16; h = random.randint(18, 40)
    d.rectangle([x0, 100 - h, x0 + 12, 100], fill=(18, 30, 50))
    for wy in range(100 - h + 3, 98, 5):
        for wx in range(x0 + 2, x0 + 11, 4):
            if random.random() < 0.4: d.point((wx, wy), fill=(220, 180, 90))
for _ in range(45):  # chuva
    x, y = random.randint(18, 108), random.randint(22, 94)
    d.line([x, y, x + 2, y + 6], fill=(70, 100, 140))
d.rectangle([62, 22, 64, 100], fill=(52, 30, 22)); d.rectangle([18, 58, 110, 60], fill=(52, 30, 22))
# prateleiras com garrafas
for sy in (44, 84):
    d.rectangle([196, sy, 312, sy + 3], fill=(84, 50, 30))
    x = 200
    while x < 306:
        w = random.choice([5, 6, 7]); h = random.randint(14, 22)
        c = random.choice([(40, 90, 50), (150, 90, 30), (120, 30, 40), (60, 60, 90), (170, 150, 110)])
        d.rectangle([x, sy - h, x + w, sy - 1], fill=c)
        d.rectangle([x + w // 2 - 1, sy - h - 4, x + w // 2, sy - h], fill=c)
        d.point((x + 1, sy - h + 3), fill=tuple(min(255, v + 70) for v in c))
        x += w + random.randint(2, 4)
# letreiro neon
d.rectangle([132, 26, 176, 34], fill=(60, 14, 24))
for x in range(135, 174, 3): d.point((x, 30), fill=(255, 70, 90))
# luminária e brilho quente
d.line([160, 0, 160, 46], fill=(20, 12, 10))
d.polygon([(150, 56), (170, 56), (166, 46), (154, 46)], fill=(120, 80, 40))
for r in range(40, 0, -4):
    glow = Image.new('RGB', (W, H), (0, 0, 0)); gd = ImageDraw.Draw(glow)
    gd.ellipse([160 - r * 2, 60 - r, 160 + r * 2, 60 + r], fill=(10, 6, 2))
    bg = Image.blend(bg, Image.eval(Image.merge('RGB', [Image.eval(c, lambda v: v) for c in bg.split()]), lambda v: v), 0)
    from PIL import ImageChops
    bg = ImageChops.add(bg, glow)
d = ImageDraw.Draw(bg)
# balcão
d.rectangle([0, 130, W, H], fill=(56, 30, 20))
d.rectangle([0, 130, W, 134], fill=(122, 72, 40))
d.rectangle([0, 135, W, 136], fill=(30, 16, 12))
for x in range(0, W, 20): d.line([x, 137, x, H], fill=(46, 24, 16))
# rádio
d.rectangle([22, 116, 52, 130], fill=(90, 60, 40)); d.rectangle([26, 119, 38, 127], fill=(40, 30, 24))
for x in range(27, 38, 2): d.line([x, 120, x, 126], fill=(70, 50, 36))
d.rectangle([42, 120, 48, 123], fill=(230, 190, 90))
bg.save(f'{out}/bar.png')
bg.resize((1280, 720), Image.NEAREST).save(f'{out}/bar@4x.png')

# Rayo: pixel art da arte do Trello (fundo recortado em art/fontes/rayo_recorte.png)
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixelizar import pixelizar
S = pixelizar(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'fontes/rayo_recorte.png'), f'{out}/rayo.png', 240, 48)
S.resize((480, 552), Image.NEAREST).save(f'{out}/rayo@2x.png')

# capacete no balcão
C = Image.new('RGBA', (34, 24), (0, 0, 0, 0)); c = ImageDraw.Draw(C)
c.ellipse([1, 1, 33, 30], fill=(140, 30, 36, 255)); c.rectangle([0, 18, 34, 24], fill=(0, 0, 0, 0))
c.rectangle([4, 16, 30, 19], fill=(30, 30, 36, 255)); c.rectangle([16, 6, 28, 13], fill=(40, 50, 70, 255))
c.point((10, 6), fill=(220, 120, 120, 255))
C.save(f'{out}/capacete.png'); C.resize((136, 96), Image.NEAREST).save(f'{out}/capacete@4x.png')
print('ok')
