// O Matusalém Desaparecido · Cena de teste: o depoimento do Rayo
//
// Como ler este arquivo:
//   Rayo: texto       -> fala de um personagem (o nome antes dos dois pontos)
//   texto sem nome    -> narração
//   Gatilho :: texto   -> opção ou observação especial (skill, clã, prova, Disciplina)
//   # pista: texto    -> a pista entra no caderno do jogador
//   # expr: nome      -> troca a expressão do Rayo (neutro, sorrindo, preocupado)
//   ~ variavel = ...  -> muda o estado do jogo

EXTERNAL rolar(parada, nivel_fome, dificuldade)
EXTERNAL despertar()

// Ficha do protagonista (preenchida na escolha de personagem)
VAR nome = ""
VAR cla = ""
VAR carisma = 0
VAR raciocinio = 0
VAR manipulacao = 0
VAR subterfugio = 0
VAR disciplina = ""
VAR fome = 2

// Relógio: minutos desde as 23h. 240 = 03h00. O Vincenzo chama o próximo às 04h40.
VAR minutos = 240
VAR limite = 340

// O que o jogador já sabe
VAR pista_versao = false
VAR pista_horario = false
VAR pista_queimadura = false
VAR pista_estrada = false
VAR confessou = false

// Estado da conversa
VAR pressao = 0
VAR rayo_fechado = false
VAR usou_pedagio = false
VAR usou_queimadura = false
VAR sentiu_besta = false
VAR quebrou_regra = false

-> escolha_personagem

=== escolha_personagem ===
Quem vai interrogar o Rayo?
* [Tomás, Gangrel. Rude, com faro de bicho.]
    ~ nome = "Tomás"
    ~ cla = "Gangrel"
    ~ carisma = 2
    ~ raciocinio = 3
    ~ manipulacao = 2
    ~ subterfugio = 2
    ~ disciplina = "Animalismo"
* [Helena, Ventrue. Fala mansa, sangue azul.]
    ~ nome = "Helena"
    ~ cla = "Ventrue"
    ~ carisma = 3
    ~ raciocinio = 2
    ~ manipulacao = 3
    ~ subterfugio = 3
    ~ disciplina = "Dominação"
- -> abertura

=== abertura ===
Três da manhã no Porão do Vincenzo. A chuva escorre pela janela, e um rádio toca samba velho, baixinho.
Vincenzo: Seu próximo convidado, {cla == "Ventrue":signora|signore}. E lembre: aqui embaixo, nada de Disciplinas. Regra da casa.
Rayo larga o capacete no balcão. A jaqueta de couro ainda pinga. Ele senta de lado, de olho na porta. # entra: rayo
Rayo: Fala logo, forasteiro. Tenho estrada antes do sol. # expr: neutro
Você tem uma cópia do dossiê do Príncipe: o relatório das concessionárias diz que o caminhão não passou em nenhum pedágio da Anchieta nem da Imigrantes. # pista: Dossiê: o caminhão não passou em pedágio nenhum na descida da Serra.
-> perguntas

=== perguntas ===
{ minutos >= limite: -> fim_tempo }
+ {not pista_versao} [O que aconteceu na Serra?]
    ~ passar(20)
    -> serra
+ {not pista_horario} [Que horas você entregou a carga?]
    ~ passar(20)
    -> entrega
+ {pista_versao} {not pista_queimadura} {not confessou} [Como estava o caixão quando você entregou?]
    ~ passar(20)
    -> caixao

// Opções especiais: só aparecem depois que o Rayo contou a versão dele
+ {pista_versao} {not confessou} {cla == "Gangrel"} [Gangrel :: Lobisomem? Eu sentiria o cheiro em você. Você fede a sombra fria.]
    ~ passar(20)
    Você: Lobisomem? Eu sentiria o cheiro em você, irmão. Você não fede a mato. Fede a sombra fria.
    Rayo fica imóvel. Entre dois Gangrel, a mentira não dura muito.
    -> confissao
+ {pista_versao} {not confessou} {carisma >= 3} [Carisma 3 :: Eu não trabalho pro Dante. O que você contar fica neste balcão.]
    ~ passar(20)
    Você: Eu não devo nada a essa Corte. O que você contar fica neste balcão.
    Rayo olha para o Vincenzo, depois para você, e solta o ar que não precisa respirar.
    -> confissao
+ {pista_versao} {not confessou} {not usou_pedagio} [Prova :: Dossiê: seu caminhão não passou em pedágio nenhum.]
    ~ passar(20)
    ~ usou_pedagio = true
    -> prova_pedagio
+ {pista_queimadura} {not confessou} {not usou_queimadura} [Prova :: Queimadura: isso nos seus dedos é marca de selo Tremere.]
    ~ passar(20)
    ~ usou_queimadura = true
    -> prova_queimadura
+ {pista_versao} {not confessou} {not rayo_fechado} [Teste: Manipulação + Subterfúgio, dif. 3 :: Blefar: "A Constance já me contou tudo."]
    ~ passar(20)
    -> blefe
+ {pista_versao} {not confessou} {disciplina == "Dominação"} [Disciplina: Dominação :: Olhe nos meus olhos. Conte a verdade.]
    ~ passar(20)
    -> dominacao
+ {pista_versao} {not confessou} {disciplina == "Animalismo"} {not sentiu_besta} [Disciplina: Animalismo :: Sentir a Besta dele.]
    ~ passar(20)
    -> animalismo
+ [Encerrar o depoimento]
    -> fim

=== serra ===
Rayo: Neblina grossa, daquelas que você não enxerga o próprio farol. # expr: sorrindo
Rayo: Na curva da Onça, uns vultos atravessaram a pista. Grandes demais pra cachorro. Lupinos.
Rayo: Joguei o caminhão no acostamento, apaguei tudo e esperei passar. Perdi uns quarenta minutos ali. # pista: Versão do Rayo: lobisomens na neblina, 40 minutos parado.
~ pista_versao = true
-> perguntas

=== entrega ===
Rayo: Duas e quarenta. Deixei o caminhão no portão do túnel, na Vila Sônia, com o Zé Carlos de olho na carga. # expr: neutro
Rayo: O Cão tava lá esperando. Eu não fico perto daquele bicho mais do que precisa.
Você: E o Zé?
Rayo: Ficou. Nunca mais atendeu o telefone. # pista: Rayo entregou às 02h40 no portão da Vila Sônia. O Cão disse ao Príncipe 03h30.
~ pista_horario = true
-> perguntas

=== caixao ===
Rayo: Inteiro. Caixão lacrado, os selos da Senescal no lugar. Ninguém mexeu. # expr: sorrindo
{ raciocinio >= 3:
    Raciocínio 3 :: Quando ele diz "selos", esfrega a ponta dos dedos. A pele está empolada, como queimadura recente. # pista: O Rayo tem queimaduras frescas nos dedos.
    ~ pista_queimadura = true
- else:
    Ele parece sincero. Ou é bom nisso.
}
-> perguntas

=== prova_pedagio ===
Você: Seu caminhão não passou em pedágio nenhum, Rayo. Nem Anchieta, nem Imigrantes. Que estrada você pegou?
Rayo: ...A Estrada Velha. É fechada pra carro, ninguém olha. Atalho de quem conhece. # pista: O Rayo desviou pela Estrada Velha do Mar. # expr: preocupado
~ pista_estrada = true
-> pressionar

=== prova_queimadura ===
Você: Escapamento não deixa marca assim. Isso é selo Tremere. Você encostou no caixão.
Rayo esconde a mão no bolso da jaqueta, tarde demais.
-> pressionar

=== pressionar ===
~ pressao += 1
{ pressao >= 2:
    Rayo: Tá bom. Tá bom, porra. # expr: preocupado
    -> confissao
- else:
    Rayo: Isso não prova nada. Eu entreguei a carga inteira. # expr: neutro
    -> perguntas
}

=== blefe ===
Você: A Constance já me contou tudo, Rayo. Só quero ouvir a sua parte.
~ temp resultado = rolar(manipulacao + subterfugio, fome, 3)
// 0 falha, 1 sucesso, 2 crítico, 3 crítico bagunçado, 4 falha bestial
{ resultado:
- 4:
    A Besta sobe pela sua garganta e você rosna no meio da frase. As presas aparecem.
    Rayo: Vocês são todos iguais. # expr: neutro
    Ele pega o capacete e sobe a escada. O depoimento acabou.
    ~ quebrou_regra = true
    -> fim
- 0:
    Rayo: A Constance? Ela não fala com gente como você. Boa tentativa. # expr: sorrindo
    ~ rayo_fechado = true
    -> perguntas
- 3:
    Funciona, mas a Fome aparece no seu rosto: você encara a veia do pescoço dele por tempo demais. O Vincenzo para de secar o copo.
    -> confissao
- else:
    Rayo: ...Ela te contou? Então você sabe que eu não toquei no caixão. # expr: preocupado
    -> confissao
}

=== dominacao ===
Você: Olhe nos meus olhos, Rayo.
~ despertar()
Sua vontade entra na cabeça dele como uma chave. Ele começa a falar com a voz plana de quem está dormindo.
Vincenzo: Signora. Regra da casa. Isso vai chegar ao Príncipe.
~ quebrou_regra = true
-> confissao

=== animalismo ===
~ despertar()
Você deixa a sua Besta farejar a dele. Não tem medo de lobisomem ali. Tem medo de outra coisa: alguém que paga bem e cobra caro.
Vincenzo pigarreia do outro lado do balcão. Ele percebeu. # pista: A Besta do Rayo tem medo de quem o contratou, não de lobisomens.
~ quebrou_regra = true
~ sentiu_besta = true
-> pressionar

=== confissao ===
~ confessou = true
~ pista_estrada = true
Rayo: Não teve lobisomem nenhum. A Constance me pagou pra descer pela Estrada Velha. # expr: preocupado
Rayo: Os homens dela abriram o baú no meio do mato. Tentaram abrir o caixão também, mas os selos da bruxa queimaram a mão de um deles. Um selo ficou preto, chamuscado.
Rayo: Eu entrei em pânico e meti o pé. A carga chegou inteira no túnel, eu juro. Duas e quarenta. # pista: Constance pagou o desvio. Um dos selos Tremere ficou queimado na tentativa de roubo.
Rayo: Se o Dante souber da Constance, eu tô morto. Se ela souber que eu falei, também.
-> fim

=== fim_tempo ===
Vincenzo: Tempo, {cla == "Ventrue":signora|signore}. O Paizão está esperando lá em cima.
-> fim

=== fim ===
{ confessou:
    Você guarda a pista mais importante da noite: quem viu a carga depois do desvio sabe que um selo estava queimado.
- else:
    Você fica com a versão do Rayo e a sensação de que faltou alguma coisa.
}
{ quebrou_regra: O Vincenzo anota alguma coisa num caderninho. A regra da casa foi quebrada, e o Príncipe vai saber. }
FIM DA CENA DE TESTE # fim
-> END

// Funções de apoio
=== function passar(m) ===
~ minutos = minutos + m

// Versões de reserva dos dados, para o editor Inky.
// No jogo de verdade, quem rola os dados é o código do jogo (regras V5 completas).
=== function rolar(parada, fome_atual, dificuldade) ===
~ temp sucessos = RANDOM(0, parada)
{ sucessos >= dificuldade:
    ~ return 1
- else:
    ~ return 0
}

=== function despertar() ===
{ RANDOM(1, 10) < 6:
    ~ fome = fome + 1
}
