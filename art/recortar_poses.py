"""Recorta as poses das pranchas que o Peter gera no Gemini (uma prancha por personagem, várias poses).

Uso: python3 art/recortar_poses.py [prancha ...]   (sem nome, faz todas)
As pranchas ficam em art/fontes/pranchas/<nome>.jpg. Cada pose tem uma caixa em pixels na prancha
(esq, topo, dir, base), já cortada na altura da cintura, como os retratos do jogo.
Sai em art/fontes/<personagem>_<pose>.png; depois, `npm run arte` faz o recorte de revista com a bordinha.
Só tratamento técnico (tirar fundo e os textos da prancha, cortar): nada é redesenhado.
"""
import os
import sys

import numpy as np
from PIL import Image, ImageOps
from scipy import ndimage
from rembg import new_session, remove

AQUI = os.path.dirname(os.path.abspath(__file__))
PRANCHAS, SAIDA = os.path.join(AQUI, "fontes", "pranchas"), os.path.join(AQUI, "fontes")

# prancha: {arquivo de saída: caixa}. As pranchas têm 1376 x 768.
POSES = {
    "rocha": {  # o rótulo da prancha diz "ANNEX", mas é o Agente Rocha
        "rocha_neutro": (40, 40, 452, 500),
        "rocha_sorriso": (470, 40, 912, 500),
        "rocha_radio": (928, 40, 1345, 520),
    },
    "rayo": {
        "rayo_bravo": (30, 30, 470, 386),
        "rayo_medo": (470, 30, 900, 386),
        "rayo_fechado": (900, 30, 1345, 386),
        "rayo_sorriso": (30, 388, 470, 742),
        "rayo_mao": (470, 388, 900, 742),
        "rayo_olho": (900, 388, 1305, 700),
    },
    "dante": {
        "dante_pe": (40, 40, 395, 470),          # "leaving the bar"
        "dante_ordem": (370, 265, 740, 610),     # "giving an order"
        "dante_calado": (715, 45, 1000, 470),    # "silent & cold"
        "dante_pulso": (785, 225, 1345, 640),    # "the oath": a mão estendida, oferecendo o sangue
    },
    "harumi": {  # a prancha estilizada (fundo vermelho); a realista com acabamento do Rayo ficou só no teste
        "harumi_neutro": (40, 88, 340, 440),
        "harumi_taco": (366, 88, 680, 320),
        "harumi_manga": (700, 88, 1020, 375),
        "harumi_medo": (1040, 88, 1345, 460),
        "harumi_brava": (362, 432, 680, 640),
        "harumi_desdem": (700, 432, 1020, 745),
    },
    # capítulo 1 (2026-10-31): Cão de frente, Vincenzo, Constance, Biel e a Nonna (imagem avulsa, só a neutra)
    "cao": {
        "cao_neutro": (35, 50, 340, 420),
        "cao_desdem": (415, 50, 700, 376),
        "cao_pego": (738, 48, 1030, 350),
        "cao_arrebatado": (1065, 48, 1340, 332),
        "cao_encurralado": (355, 405, 598, 690),
        "cao_sorriso": (612, 415, 860, 712),
        "cao_ataque": (878, 405, 1338, 712),
    },
    "vincenzo": {
        "vincenzo_neutro": (30, 45, 672, 370),
        "vincenzo_bracos": (705, 45, 1345, 370),
        "vincenzo_copo": (30, 432, 672, 740),
        "vincenzo_aponta": (705, 432, 1345, 740),
    },
    "constance": {
        "constance_neutro": (20, 15, 452, 357),
        "constance_riso": (470, 15, 905, 357),
        "constance_seria": (922, 15, 1357, 357),
        "constance_furia": (302, 393, 678, 725),
        "constance_sussurro": (697, 393, 1357, 728),
    },
    "biel": {  # das três "confused", a 1
        "biel_neutro": (40, 76, 345, 372),
        "biel_confuso": (442, 76, 675, 372),
        "biel_chorando": (172, 395, 452, 735),
        "biel_sorriso": (592, 395, 895, 735),
        "biel_encolhido": (918, 395, 1340, 735),
    },
    "nonna": {"nonna_neutro": None},  # imagem avulsa inteira
    # Nonna, 2026-11-03: três imagens avulsas inteiras (severa, frasco, velas)
    "nonna_severa": {"nonna_severa": None},
    "nonna_frasco": {"nonna_frasco": None},
    "nonna_velas": {"nonna_velas": (740, 330, 1560, 1500)},  # só ela: a mesa e as velas ficam de fora, o recorte as embaralha
    # protagonistas (2026-11-01)
    "tomas": {
        "tomas_neutro": (145, 15, 370, 345),
        "tomas_ameaca": (550, 20, 875, 345),
        "tomas_chama": (935, 15, 1300, 345),
        "tomas_lingua": (140, 390, 415, 712),
        "tomas_dor": (595, 390, 825, 712),
        "tomas_medo": (1005, 390, 1280, 712),
    },
    "joana": {  # rótulos em inglês: delights = encanta, preaches = prega, tongue = lingua
        "joana_neutro": (100, 20, 370, 335),
        "joana_encanta": (545, 20, 835, 335),
        "joana_prega": (955, 40, 1310, 335),
        "joana_lingua": (30, 395, 400, 718),
        "joana_dor": (555, 400, 830, 718),
        "joana_medo": (1015, 400, 1325, 718),
    },
    "irene": {  # a prancha mais nova das duas de neutro/escuta/bravo/medo; os quadros têm o esgoto de fundo
        "irene_neutro": (150, 30, 520, 328),
        "irene_escuta": (770, 30, 1215, 328),
        "irene_bravo": (100, 400, 600, 700),
        "irene_medo": (720, 400, 1340, 700),
    },
    # isadora (2026-11-03): cinco imagens avulsas de corpo inteiro, com o cenário do Elísio ao fundo
    "isadora_cochicho": {"isadora_cochicho": None},
    "isadora_ofendida": {"isadora_ofendida": None},
    "isadora_aponta": {"isadora_aponta": None},
    "isadora_medo": {"isadora_medo": None},
    "isadora_vaidosa": {"isadora_vaidosa": None},
    # valentina (2026-11-03): duas imagens avulsas de corpo inteiro (estilo retícula, moldura de cartaz ao fundo)
    "valentina_assustada": {"valentina_assustada": None},
    "valentina_rindo": {"valentina_rindo": None},
    # luciana (2026-11-03): quatro imagens avulsas de corpo inteiro, fundo branco
    "luciana_fria": {"luciana_fria": None},
    "luciana_ritual": {"luciana_ritual": None},
    "luciana_ameaca": {"luciana_ameaca": None},
    "luciana_abalada": {"luciana_abalada": None},
    # arnaldo (2026-11-03): neutra nova, refeita pelo Peter (imagem avulsa de corpo inteiro)
    "arnaldo_neutro": {"arnaldo_neutro": None},
    # dante (2026-11-03): neutra nova, de pé (a antiga era sentado numa cadeira)
    "dante_neutro": {"dante_neutro": None},
    "arnaldo": {  # vigia e aponta numa prancha só, com o nome escrito embaixo (o rótulo fica fora da caixa)
        "arnaldo_vigia": (240, 40, 470, 715),
        "arnaldo_aponta": (720, 40, 1160, 715),
    },
    "irene2": {
        "irene_pensa": (180, 30, 470, 328),
        "irene_desconfia": (880, 30, 1170, 328),
        "irene_dor": (190, 400, 450, 700),
        "irene_some": (900, 400, 1180, 700),
    },
}
# pranchas de fundo vermelho chapado: o vermelho que aparece nos vãos (entre o braço e o corpo) também sai,
# e o recorte usa o modelo de ilustração (isnet-anime), que guarda o taco e os dedos finos
FUNDO_VERMELHO = {"harumi"}
# fundo vermelho, mas com o modelo geral (o terno risca de giz sai melhor nele): só apaga o vermelho dos vãos
VERMELHO_GERAL = {"vincenzo"}
APAGAR = {
    "isadora_ofendida": [(0.58, 0.45, 1.0, 1.0), (0.0, 0.8, 1.0, 1.0)],  # a mão que toca a escultura
    "isadora_medo": [(0.75, 0.4, 1.0, 1.0)],       # escultura solta ao lado
    "isadora_vaidosa": [(0.0, 0.3, 0.2, 1.0)],     # pedaço de escultura no canto
    "isadora_aponta": [(0.38, 0.1, 0.43, 0.25)],    # restos do cenário atrás da cabeça
}
# imagem de corpo inteiro: corta na cintura (fração da altura que fica), como os outros retratos
CORTE_ALTURA = {"arnaldo_vigia": 0.5, "arnaldo_aponta": 0.5, "arnaldo_neutro": 0.5, "luciana_fria": 0.5, "luciana_ritual": 0.5, "luciana_ameaca": 0.5, "luciana_abalada": 0.5, "valentina_assustada": 0.5, "valentina_rindo": 0.5, "nonna_neutro": 0.6, "isadora_cochicho": 0.5, "isadora_ofendida": 0.42, "isadora_aponta": 0.5, "isadora_medo": 0.5, "isadora_vaidosa": 0.5, "nonna_severa": 0.6, "nonna_frasco": 0.6, "dante_neutro": 0.5}
# arte que olha para o lado errado: espelha (a Nonna fica à esquerda e precisa olhar para a direita)
# (severa já olha para a direita; frasco e velas olham para a esquerda)
ESPELHAR = {"nonna", "nonna_frasco", "nonna_velas", "harumi"}  # a Harumi fica à direita e precisa olhar para a esquerda (a arte original olha para a direita)
# poses em que o modelo de ilustração leva junto um objeto do cenário (a mesa de sinuca): fica só o que os dois modelos acham
INTERSECAO = {"harumi_taco"}


# pranchas de fundo liso escuro (azul-marinho): o rembg às vezes deixa um pedaço do fundo num vão que encosta na borda
FUNDO_LISO = {"tomas", "joana"}


def tirar_fundo_borda(im, cor, tol=28, minimo=150):
    """Apaga manchas da cor do fundo da prancha que encostam na borda do recorte."""
    a = np.array(im.convert("RGB")).astype(np.int16)
    perto = np.abs(a - np.array(cor)).max(axis=2) <= tol
    perto &= (a[..., 2] - a[..., 0]) >= (cor[2] - cor[0]) / 2  # só o azulado: o terninho vinho da Joana é quase tão escuro quanto o fundo
    if max(cor) < 30:  # fundo quase preto (Tomás): vale qualquer pixel quase preto
        perto |= a.max(axis=2) < 32
    perto &= np.array(im.getchannel("A")) > 0
    rot, n = ndimage.label(perto)
    if n:
        borda = set(np.unique(np.concatenate([rot[0], rot[-1], rot[:, 0], rot[:, -1]]))) - {0}
        tam = np.bincount(rot.ravel())
        tira = np.isin(rot, [r for r in borda if tam[r] >= minimo])
        tira = ndimage.binary_dilation(tira, iterations=2)
        alfa = np.array(im.getchannel("A")); alfa[tira] = 0
        im.putalpha(Image.fromarray(alfa))
    return im


def fantasma(im):
    """O Biel é o morto que a Nonna chama: duotone azul e branco, um pouco transparente (igual ao recortar_personagens.py)."""
    alfa = im.getchannel("A")
    cinza = ImageOps.autocontrast(im.convert("L"), cutoff=1)
    cor = ImageOps.colorize(cinza, black=(8, 22, 58), mid=(70, 130, 200), white=(240, 248, 255))
    cor.putalpha(Image.fromarray((np.array(alfa) * 0.88).astype(np.uint8)))
    return cor


def limpar(im, limiar=30):
    """Alfa sólido: fica só a maior mancha (some o texto da prancha), sem buracos."""
    a = np.array(im.getchannel("A")) > limiar
    rot, n = ndimage.label(a)
    if n > 1:
        a = rot == (np.argmax(np.bincount(rot.ravel())[1:]) + 1)
    a = ndimage.binary_fill_holes(a)
    im.putalpha(Image.fromarray(np.where(a, np.maximum(np.array(im.getchannel("A")), 255 * a), 0).astype(np.uint8)))
    return im


def soltar_cenario(im, raio=7):
    """Esculturas do cenário coladas na personagem: erode, fica a maior mancha, dilata de volta dentro do recorte."""
    alfa = np.array(im.getchannel("A"))
    nucleo = ndimage.binary_erosion(alfa > 128, iterations=raio)
    rot, n = ndimage.label(nucleo)
    if n > 1:
        nucleo = rot == (np.argmax(np.bincount(rot.ravel())[1:]) + 1)
    volta = ndimage.binary_dilation(nucleo, iterations=raio + 2) & (alfa > 0)
    im.putalpha(Image.fromarray(np.where(volta, alfa, 0).astype(np.uint8)))
    return im


def tirar_vermelho(im, minimo=150):
    """Apaga manchas grandes do vermelho do fundo que ficaram dentro do recorte (o rembg preenche os vãos)."""
    a = np.array(im).astype(np.int16)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    verm = ((r > 105) & (r > 2.0 * g) & (r > 2.0 * b)) | ((r > 22) & (r > 2.8 * g) & (r > 2.8 * b))
    verm = ndimage.binary_opening(verm, iterations=2)
    rot, n = ndimage.label(verm)
    if n:
        tam = np.bincount(rot.ravel()); tam[0] = 0
        grande = tam[rot] >= minimo
        grande = ndimage.binary_dilation(grande, iterations=2)
        alfa = np.array(im.getchannel("A")); alfa[grande] = 0
        im.putalpha(Image.fromarray(alfa))
    return im


sessao = new_session("isnet-general-use")
sessao_ilustra = new_session("isnet-anime")
for prancha in sys.argv[1:] or POSES:
    img = Image.open(os.path.join(PRANCHAS, prancha + ".jpg")).convert("RGB")
    for nome, caixa in POSES[prancha].items():
        # amplia 2x antes do rembg: a prancha é pequena e o recorte fica mais limpo
        parte = img.crop(caixa) if caixa else img
        if caixa or max(parte.size) < 1500:  # imagem avulsa pequena (1376 x 768, de corpo inteiro) também amplia
            parte = parte.resize((parte.width * 2, parte.height * 2), Image.LANCZOS)
        if prancha in FUNDO_VERMELHO:
            out = limpar(remove(parte, session=sessao_ilustra), 128)
            if nome in INTERSECAO:
                geral = limpar(remove(parte, session=sessao))
                out.putalpha(Image.fromarray(np.minimum(np.array(out.getchannel("A")), np.array(geral.getchannel("A")))))
            out = tirar_vermelho(out)
        else:
            out = limpar(remove(parte, session=sessao))
            if prancha in VERMELHO_GERAL:
                out = tirar_vermelho(out)
            if prancha in FUNDO_LISO:
                cor = np.median(np.array(img.crop((caixa[0], caixa[1], caixa[0] + 12, caixa[1] + 12))).reshape(-1, 3), axis=0)
                out = limpar(tirar_fundo_borda(out, cor))
        if nome.startswith("isadora_"):
            out = soltar_cenario(out)
            for x0, y0, x1, y1 in APAGAR.get(nome, []):  # restos do cenário que não saem sozinhos (frações da caixa)
                alfa = np.array(out.getchannel("A")); h, w = alfa.shape
                alfa[int(y0 * h):int(y1 * h), int(x0 * w):int(x1 * w)] = 0
                out.putalpha(Image.fromarray(alfa))
            out = limpar(out)  # sobra solta do cenário (ex.: pedaço de escultura ao lado) some: fica só a maior mancha
            out = out.crop(out.getbbox())
        out = out.crop(out.getbbox())
        if nome in CORTE_ALTURA:
            out = out.crop((0, 0, out.width, int(out.height * CORTE_ALTURA[nome])))
            out = out.crop(out.getbbox())
        if prancha in ESPELHAR:
            out = ImageOps.mirror(out)
        if prancha == "biel":
            out = fantasma(out)
        out.save(os.path.join(SAIDA, nome + ".png"))
        print(nome, out.size)
