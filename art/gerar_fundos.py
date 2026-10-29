"""Gera os fundos e as ilustrações provisórias com sdxl-turbo, em CPU (~25 s por imagem).

Uso: python3 art/gerar_fundos.py [nome ...]
Sai em art/fontes/gerado/<nome>.jpg. Sem nome, gera todos que ainda não existem.
São imagens novas, sem personagem do Peter: cenário vazio ou figurantes sem rosto.
Para trocar uma imagem, apague o .jpg e rode de novo (ou mude a semente).
"""
import os
import sys

import torch
from diffusers import AutoPipelineForText2Image

ESTILO = ", cinematic realistic photo, moody dark lighting, film grain, 35mm"
SEM_GENTE = ", empty, no people"

# nome: (prompt, semente)
CENAS = {
    # cantos do bar (uma testemunha em cada)
    "salao": ("underground speakeasy bar main room under an Italian cantina, vaulted brick ceiling, small round tables with red checkered tablecloths, warm yellow lamps, cigarette smoke, old wine bottles" + SEM_GENTE, 11),
    "escada": ("dark corner under an old stone staircase inside a basement bar, rough brick wall, single bare light bulb, deep shadows, wet floor, a rusty railing" + SEM_GENTE, 21),
    "sinuca": ("old pool table with worn green felt in a basement bar, single hanging lamp over the table, cigarette smoke, cue sticks on the wall rack, wooden paneling, beer bottles" + SEM_GENTE, 31),
    "fundo_bar": ("back corner table of an old basement bar, white lace tablecloth, many lit candles, rosary beads, old black and white family photos, small catholic saint statues, dim warm light" + SEM_GENTE, 41),
    "corte": ("basement speakeasy prepared for a secret night court, a large red velvet armchair like a throne in the center, tall candelabras, red velvet curtains, brick arches, ominous" + SEM_GENTE, 51),
    "rua": ("narrow street at night in the old Italian neighborhood of Bixiga in Sao Paulo, closed old cantina facade with a hand painted sign, stone steps going down to a basement door, wet cobblestones, rain, single dim streetlight" + SEM_GENTE, 61),
    # abertura
    "porto": ("container port of Santos Brazil at night, giant cranes, one lone shipping container under floodlights, fog over the water" + SEM_GENTE, 71),
    "serra": ("a cargo truck on a narrow foggy mountain road at night inside dense tropical rainforest, headlights in the fog, Serra do Mar Brazil", 81),
    "tunel": ("entrance gate of a subway maintenance tunnel at night, metal gate half open, rails going into darkness, a guard booth with a wall clock, single lamp, wet concrete" + SEM_GENTE, 91),
    # momentos-chave dos finais
    "bunker": ("a large ancient carved stone sarcophagus with red wax seals resting on the floor of a hidden concrete bunker, close up, subway rails above, single hanging lamp lighting the sarcophagus, dust" + SEM_GENTE, 103),
    "van": ("black unmarked van at a container port at night, men in dark suits with lanyards loading a heavy stone sarcophagus into the van, seen from far away, floodlights, fog", 111),
    "amanhecer": ("view from a rooftop at dawn over old rooftops of Sao Paulo, orange sunrise sky, heavy iron chains lying on the rooftop floor" + SEM_GENTE, 121),
    "anarquistas": ("street poles covered with photocopied posters pasted at night on Rua Augusta Sao Paulo, neon signs, graffiti, wet asphalt, a motorcycle parked" + SEM_GENTE, 131),
    "trono_vazio": ("an empty red velvet throne armchair knocked over in a candlelit basement, spilled wine glass on the floor, candles burning low" + SEM_GENTE, 141),
}

AQUI = os.path.dirname(os.path.abspath(__file__))
SAIDA = os.path.join(AQUI, "fontes", "gerado")
os.makedirs(SAIDA, exist_ok=True)
nomes = sys.argv[1:] or [n for n in CENAS if not os.path.exists(os.path.join(SAIDA, n + ".jpg"))]
if not nomes:
    sys.exit("nada a gerar")

torch.set_num_threads(os.cpu_count())
pipe = AutoPipelineForText2Image.from_pretrained("stabilityai/sdxl-turbo", torch_dtype=torch.bfloat16)
pipe.set_progress_bar_config(disable=True)
for n in nomes:
    prompt, seed = CENAS[n]
    img = pipe(prompt + ESTILO, num_inference_steps=4, guidance_scale=0.0, width=1024, height=576,
               generator=torch.Generator().manual_seed(seed)).images[0]
    img.save(os.path.join(SAIDA, n + ".jpg"), quality=92)
    print(n, flush=True)
