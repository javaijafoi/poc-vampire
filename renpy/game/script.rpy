# O Matusalém Desaparecido · Cena de teste: o depoimento do Rayo
#
# Como ler este arquivo:
#   rayo "texto"        -> fala de um personagem
#   "texto"             -> narração
#   "Gatilho :: texto"  -> opção especial no menu (skill, clã, prova, Disciplina)
#   $ pista("texto")    -> a pista entra no caderno do jogador
#   $ variavel = ...    -> muda o estado do jogo

define rayo = Character("Rayo")
define vin = Character("Vincenzo")
define voce = Character("[nome]", what_color="#f6d9a8")
define obs_raciocinio = Character("Raciocínio 3", screen="say_passiva")

# Ficha do protagonista (preenchida na escolha de personagem)
default nome = ""
default cla = ""
default carisma = 0
default raciocinio = 0
default manipulacao = 0
default subterfugio = 0
default disciplina = ""
default fome = 2

# Relógio: minutos desde as 23h. 240 = 03h00. O Vincenzo chama o próximo às 04h40.
default minutos = 240
default limite = 340

# O que o jogador já sabe
default pistas = []
default pista_versao = False
default pista_horario = False
default pista_queimadura = False
default pista_estrada = False
default confessou = False

# Estado da conversa
default pressao = 0
default rayo_fechado = False
default usou_pedagio = False
default usou_queimadura = False
default sentiu_besta = False
default quebrou_regra = False

transform pos_rayo:
    xpos 720 ypos 64
transform pos_capacete:
    xpos 512 ypos 428
transform pos_balcao:
    xpos 0 ypos 520

label start:
    scene bar
    show balcao at pos_balcao
    show screen hud

    menu:
        "Quem vai interrogar o Rayo?"
        "Tomás, Gangrel. Rude, com faro de bicho.":
            $ nome, cla, disciplina = "Tomás", "Gangrel", "Animalismo"
            $ carisma, raciocinio, manipulacao, subterfugio = 2, 3, 2, 2
        "Helena, Ventrue. Fala mansa, sangue azul.":
            $ nome, cla, disciplina = "Helena", "Ventrue", "Dominação"
            $ carisma, raciocinio, manipulacao, subterfugio = 3, 2, 3, 3

    "Três da manhã no Porão do Vincenzo. A chuva escorre pela janela, e um rádio toca samba velho, baixinho."
    $ tratamento = "signora" if cla == "Ventrue" else "signore"
    vin "Seu próximo convidado, [tratamento]. E lembre: aqui embaixo, nada de Disciplinas. Regra da casa."
    show rayo at pos_rayo behind balcao with dissolve
    show capacete at pos_capacete
    "Rayo larga o capacete no balcão. A jaqueta de couro ainda pinga. Ele senta de lado, de olho na porta."
    rayo "Fala logo, forasteiro. Tenho estrada antes do sol."
    $ pista("Dossiê: o caminhão não passou em pedágio nenhum na descida da Serra.")
    "Você tem uma cópia do dossiê do Príncipe: o relatório das concessionárias diz que o caminhão não passou em nenhum pedágio da Anchieta nem da Imigrantes."
    jump perguntas

label perguntas:
    if minutos >= limite:
        jump fim_tempo

    menu:
        "O que aconteceu na Serra?" if not pista_versao:
            $ passar(20)
            jump serra
        "Que horas você entregou a carga?" if not pista_horario:
            $ passar(20)
            jump entrega
        "Como estava o caixão quando você entregou?" if pista_versao and not pista_queimadura and not confessou:
            $ passar(20)
            jump caixao

        # Opções especiais: só aparecem depois que o Rayo contou a versão dele
        "Gangrel :: Lobisomem? Eu sentiria o cheiro em você. Você fede a sombra fria." if pista_versao and not confessou and cla == "Gangrel":
            $ passar(20)
            voce "Lobisomem? Eu sentiria o cheiro em você, irmão. Você não fede a mato. Fede a sombra fria."
            "Rayo fica imóvel. Entre dois Gangrel, a mentira não dura muito."
            jump confissao
        "Carisma 3 :: Eu não trabalho pro Dante. O que você contar fica neste balcão." if pista_versao and not confessou and carisma >= 3:
            $ passar(20)
            voce "Eu não devo nada a essa Corte. O que você contar fica neste balcão."
            "Rayo olha para o Vincenzo, depois para você, e solta o ar que não precisa respirar."
            jump confissao
        "Prova :: Dossiê: seu caminhão não passou em pedágio nenhum." if pista_versao and not confessou and not usou_pedagio:
            $ passar(20)
            $ usou_pedagio = True
            jump prova_pedagio
        "Prova :: Queimadura: isso nos seus dedos é marca de selo Tremere." if pista_queimadura and not confessou and not usou_queimadura:
            $ passar(20)
            $ usou_queimadura = True
            jump prova_queimadura
        'Teste: Manipulação + Subterfúgio, dif. 3 :: Blefar: "A Constance já me contou tudo."' if pista_versao and not confessou and not rayo_fechado:
            $ passar(20)
            jump blefe
        "Disciplina: Dominação :: Olhe nos meus olhos. Conte a verdade." if pista_versao and not confessou and disciplina == "Dominação":
            $ passar(20)
            jump dominacao
        "Disciplina: Animalismo :: Sentir a Besta dele." if pista_versao and not confessou and disciplina == "Animalismo" and not sentiu_besta:
            $ passar(20)
            jump animalismo
        "Encerrar o depoimento":
            jump fim

label serra:
    rayo "Neblina grossa, daquelas que você não enxerga o próprio farol."
    rayo "Na curva da Onça, uns vultos atravessaram a pista. Grandes demais pra cachorro. Lupinos."
    $ pista("Versão do Rayo: lobisomens na neblina, 40 minutos parado.")
    rayo "Joguei o caminhão no acostamento, apaguei tudo e esperei passar. Perdi uns quarenta minutos ali."
    $ pista_versao = True
    jump perguntas

label entrega:
    rayo "Duas e quarenta. Deixei o caminhão no portão do túnel, na Vila Sônia, com o Zé Carlos de olho na carga."
    rayo "O Cão tava lá esperando. Eu não fico perto daquele bicho mais do que precisa."
    voce "E o Zé?"
    $ pista("Rayo entregou às 02h40 no portão da Vila Sônia. O Cão disse ao Príncipe 03h30.")
    rayo "Ficou. Nunca mais atendeu o telefone."
    $ pista_horario = True
    jump perguntas

label caixao:
    rayo "Inteiro. Caixão lacrado, os selos da Senescal no lugar. Ninguém mexeu."
    if raciocinio >= 3:
        $ pista("O Rayo tem queimaduras frescas nos dedos.")
        obs_raciocinio "Quando ele diz \"selos\", esfrega a ponta dos dedos. A pele está empolada, como queimadura recente."
        $ pista_queimadura = True
    else:
        "Ele parece sincero. Ou é bom nisso."
    jump perguntas

label prova_pedagio:
    voce "Seu caminhão não passou em pedágio nenhum, Rayo. Nem Anchieta, nem Imigrantes. Que estrada você pegou?"
    $ pista("O Rayo desviou pela Estrada Velha do Mar.")
    rayo "...A Estrada Velha. É fechada pra carro, ninguém olha. Atalho de quem conhece."
    $ pista_estrada = True
    jump pressionar

label prova_queimadura:
    voce "Escapamento não deixa marca assim. Isso é selo Tremere. Você encostou no caixão."
    "Rayo esconde a mão no bolso da jaqueta, tarde demais."
    jump pressionar

label pressionar:
    $ pressao += 1
    if pressao >= 2:
        rayo "Tá bom. Tá bom, porra."
        jump confissao
    rayo "Isso não prova nada. Eu entreguei a carga inteira."
    jump perguntas

label blefe:
    voce "A Constance já me contou tudo, Rayo. Só quero ouvir a sua parte."
    # 0 falha, 1 sucesso, 2 crítico, 3 crítico bagunçado, 4 falha bestial
    $ resultado = rolar(manipulacao + subterfugio, fome, 3)
    call screen dados
    if resultado == 4:
        "A Besta sobe pela sua garganta e você rosna no meio da frase. As presas aparecem."
        rayo "Vocês são todos iguais."
        hide rayo
        hide capacete
        "Ele pega o capacete e sobe a escada. O depoimento acabou."
        $ quebrou_regra = True
        jump fim
    elif resultado == 0:
        rayo "A Constance? Ela não fala com gente como você. Boa tentativa."
        $ rayo_fechado = True
        jump perguntas
    elif resultado == 3:
        "Funciona, mas a Fome aparece no seu rosto: você encara a veia do pescoço dele por tempo demais. O Vincenzo para de secar o copo."
        jump confissao
    else:
        rayo "...Ela te contou? Então você sabe que eu não toquei no caixão."
        jump confissao

label dominacao:
    voce "Olhe nos meus olhos, Rayo."
    $ despertar()
    "Sua vontade entra na cabeça dele como uma chave. Ele começa a falar com a voz plana de quem está dormindo."
    vin "Signora. Regra da casa. Isso vai chegar ao Príncipe."
    $ quebrou_regra = True
    jump confissao

label animalismo:
    $ despertar()
    "Você deixa a sua Besta farejar a dele. Não tem medo de lobisomem ali. Tem medo de outra coisa: alguém que paga bem e cobra caro."
    $ pista("A Besta do Rayo tem medo de quem o contratou, não de lobisomens.")
    "Vincenzo pigarreia do outro lado do balcão. Ele percebeu."
    $ quebrou_regra = True
    $ sentiu_besta = True
    jump pressionar

label confissao:
    $ confessou = True
    $ pista_estrada = True
    rayo "Não teve lobisomem nenhum. A Constance me pagou pra descer pela Estrada Velha."
    rayo "Os homens dela abriram o baú no meio do mato. Tentaram abrir o caixão também, mas os selos da bruxa queimaram a mão de um deles. Um selo ficou preto, chamuscado."
    $ pista("Constance pagou o desvio. Um dos selos Tremere ficou queimado na tentativa de roubo.")
    rayo "Eu entrei em pânico e meti o pé. A carga chegou inteira no túnel, eu juro. Duas e quarenta."
    rayo "Se o Dante souber da Constance, eu tô morto. Se ela souber que eu falei, também."
    jump fim

label fim_tempo:
    vin "Tempo, [tratamento]. O Paizão está esperando lá em cima."
    jump fim

label fim:
    if confessou:
        "Você guarda a pista mais importante da noite: quem viu a carga depois do desvio sabe que um selo estava queimado."
    else:
        "Você fica com a versão do Rayo e a sensação de que faltou alguma coisa."
    if quebrou_regra:
        "O Vincenzo anota alguma coisa num caderninho. A regra da casa foi quebrada, e o Príncipe vai saber."
    call screen fim_cena
    return
