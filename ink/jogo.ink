// O Matusalém Desaparecido · primeira versão jogável
//
// Como ler este arquivo:
//   Rayo: texto            -> fala de um personagem (o nome antes dos dois pontos)
//   texto sem nome         -> narração
//   Gatilho :: texto       -> opção ou observação especial (skill, clã, prova, teste, Disciplina)
//   # pista <aba>: texto   -> a pista entra no caderno, na folha da aba (dossie, rayo, cao, harumi, biel, bar)
//   # fundo: nome          -> troca o fundo (art/cena/fundo_<nome>.webp)
//   # entra: nome          -> põe a testemunha em cena, à direita
//   # limpa                -> tira todo mundo de cena
//   # imagem: nome         -> mostra uma ilustração de momento-chave por cima de tudo (some no próximo # fundo)
//   # final: letra         -> marca o final alcançado (para a tela de fim e os testes)
//   # musica: nome         -> troca a música (musica/<nome>.mp3); sem a tag, cada fundo já tem a sua faixa
//   ~ variavel = ...       -> muda o estado do jogo

EXTERNAL rolar(parada, nivel_fome, dificuldade)
EXTERNAL despertar()

// Ficha do protagonista (preenchida na escolha de personagem)
VAR nome = ""
VAR cla = ""
VAR carisma = 0
VAR raciocinio = 0
VAR manipulacao = 0
VAR subterfugio = 0
VAR intimidacao = 0   // parada de Força + Intimidação
VAR ocultismo = 0
VAR disciplina = ""
VAR fome = 2
VAR o = "o"         // terminação de gênero do protagonista: forasteir{o}

// Relógio: minutos desde as 23h. O sol nasce às 05h40 (400).
VAR minutos = 0
VAR limite = 400

// Pistas
VAR p_rayo_versao = false     // lobisomens na Serra
VAR p_rayo_hora = false       // entregou 02h40
VAR p_queimadura = false      // dedos queimados do Rayo
VAR p_selo = false            // selo queimado na tentativa de roubo (confissão do Rayo)
VAR p_constance = false       // Constance pagou o desvio
VAR p_rayo_frasco = false     // Rayo viu o Harumi com um frasquinho
VAR p_cao_versao = false      // Cão: chegou vazio às 03h30
VAR p_cao_selo = false        // Cão deixou escapar o selo queimado
VAR p_concreto = false        // pó de concreto da Linha Amarela
VAR p_bunker = false          // o Cão tem um esconderijo embaixo dos trilhos
VAR p_cripta = false          // Harumi falou do cheiro de cripta
VAR p_dedos = false           // cheiro de sangue antigo nos dedos do Harumi
VAR p_frasco = false          // Harumi admitiu o frasco
VAR p_boes = false            // carimbo do BOES no manifesto
VAR p_tunel = false           // o fantasma morreu num túnel, não na mata
VAR p_biel_hora = false         // o fantasma viu o relógio às 02h50
VAR p_informante = false      // Biel era informante da Dra. Elisa
VAR p_limpeza = false         // equipe de limpeza do Vincenzo trabalhou para alguém

// Estado das conversas
VAR rayo_pressao = 0
VAR rayo_confessou = false
VAR rayo_fechado = false
VAR usou_pedagio = false
VAR usou_queimadura = false
VAR sentiu_besta_rayo = false
VAR cao_travou = false
VAR cao_irritado = false
VAR cao_hora_confrontada = false
VAR harumi_pressao = 0
VAR harumi_confessou = false
VAR harumi_fechado = false
VAR usou_cripta = false
VAR usou_frasco_rayo = false
VAR usou_dedos = false
VAR sessao_feita = false
VAR biel_perguntas = 0
VAR biel_hora_feita = false
VAR biel_doeu = false
VAR biel_luz = false
VAR vincenzo_falou = false
VAR rayo_hora_vaga = false
VAR v_neutro = false
VAR rayo_serra = 0            // quantas vezes você perguntou da Serra (ele desconversa antes de contar)
VAR aviso_tempo = 0           // avisos do Vincenzo já dados: 1 = 03h, 2 = 04h, 3 = 05h
VAR constance_chegou = false
VAR constance_fechada = false
VAR constance_aliada = false  // viu o carimbo do BOES e ficou do seu lado
VAR constance_hostil = false  // percebeu que você a ameaçou ou usou Disciplina nela
VAR p_envelope = false        // Constance: envelope para "a Doutora" preso ao sarcófago
VAR p_constance_ordem = false // Constance mandou "resolver" você se chegar nela
VAR p_constance_cao = false   // Constance: "o Dante desconfia de todo mundo, menos do cachorro dele"
VAR c_veio = false
VAR c_rayo = false
VAR c_animal = false
VAR quebrou_regra = 0

-> escolha_personagem

=== escolha_personagem ===
Quem é você?
* [Tomás · Gangrel ;; Caminhoneiro do Sul. Rude, com faro de bicho. ;; Carisma 2 · Raciocínio 3 · Intimidação 6 · Animalismo]
    ~ nome = "Tomás"
    ~ cla = "Gangrel"
    ~ carisma = 2
    ~ raciocinio = 3
    ~ manipulacao = 2
    ~ subterfugio = 2
    ~ intimidacao = 6
    ~ ocultismo = 1
    ~ disciplina = "Animalismo"
* [Irene · Nosferatu ;; Ex-espiã dos esgotos de Curitiba. Ouve tudo. ;; Carisma 1 · Raciocínio 3 · Ocultismo 2 · Ofuscação]
    ~ nome = "Irene"
    ~ cla = "Nosferatu"
    ~ carisma = 1
    ~ raciocinio = 3
    ~ manipulacao = 2
    ~ subterfugio = 3
    ~ intimidacao = 4
    ~ ocultismo = 2
    ~ disciplina = "Ofuscação"
    ~ o = "a"
* [Joana · Ministério ;; Pastora de fala mansa. Vende salvação. ;; Carisma 3 · Manipulação 3 · Ocultismo 2 · Presença]
    ~ nome = "Joana"
    ~ o = "a"
    ~ cla = "Ministério"
    ~ carisma = 3
    ~ raciocinio = 2
    ~ manipulacao = 3
    ~ subterfugio = 3
    ~ intimidacao = 3
    ~ ocultismo = 2
    ~ disciplina = "Presença"
- -> prologo

=== prologo ===
# fundo: rua
Você chegou a São Paulo há três noites, com uma mala, um nome falso e uma dívida.
A dívida é com o Príncipe Dante, da Camarilla. Foi ele quem deixou você entrar na cidade sem fazer perguntas.
Às dez e meia da noite, um bilhete passa por baixo da porta do seu quarto de pensão. Papel grosso, lacre de cera azul.
"Porão do Vincenzo, Bixiga. Onze horas. Venha sem ninguém. D."
# fundo: salao
A cantina de cima está fechada. Uma escada de pedra desce até um bar sem placa, cheio de fumaça e de mortos bem vestidos.
Vincenzo: Benvenuto. O Príncipe espera você. Regra da casa: aqui embaixo ninguém levanta a mão nem usa Disciplina.
Dante: Sente-se. Eu não gosto de repetir, então escute.
Dante: Esta noite chegou ao Porto de Santos uma carga minha. Um sarcófago. Dentro dele, um Matusalém em torpor, mais velho que esta cidade.
Dante: A carga subiu a Serra num caminhão e devia chegar ao meu cofre, pelo túnel da Vila Sônia. Não chegou.
Dante: Meu Xerife diz que o caminhão apareceu vazio no túnel às três e meia, sem o Biel, o entregador Sangue-Ralo que vinha junto com o Rayo. # pista dossie: O Cão disse ao Príncipe que o caminhão chegou vazio às 03h30, sem o Biel, o Sangue-Ralo que acompanhava a carga.
Dante: O relatório das concessionárias diz que o caminhão não passou em pedágio nenhum, nem na Anchieta nem na Imigrantes. # pista dossie: O caminhão não passou em pedágio nenhum na descida da Serra.
Você: Por que eu? A cidade tem um Xerife.
Dante: Porque o transporte passava pela segurança do Xerife. E porque você não tem amigos aqui. Ninguém vai pedir favor a você.
Dante: Todos que tocaram na carga estão neste bar. O Rayo dirigiu o caminhão. A Harumi, do Ministério, recebeu o contêiner no porto. É ela quem manda nos estivadores de lá. O Cão recebeu no túnel.
Dante: E a Nonna Benedetta, lá no fundo, diz que fala com os mortos. O Biel não aparece desde as três. Se ele virou cinza, talvez ainda tenha algo a dizer.
Dante: Você tem até o amanhecer. Quando o sol estiver para nascer, eu volto com a Corte, e você me diz quem me traiu.
Dante: Acerte, e sua dívida está paga. Erre, e você paga por ela.
O Príncipe se levanta. Ninguém no bar olha para ele, mas todo mundo para de falar até a porta fechar.
Vincenzo: Onze e meia, forasteir{o}. O relógio corre. # limpa
~ minutos = 30
-> salao

=== salao ===
# fundo: salao
# limpa
{ minutos >= limite: -> amanhecer }
{ minutos >= 240 and aviso_tempo < 1:
    ~ aviso_tempo = 1
    Vincenzo: Três da manhã, forasteir{o}. Metade da noite já foi. Eu, no seu lugar, parava de conversar e começava a escolher.
}
{ minutos >= 300 and aviso_tempo < 2:
    ~ aviso_tempo = 2
    Vincenzo: Quatro horas. Daqui a pouco o Príncipe desce essa escada, com ou sem resposta sua.
}
{ minutos >= 360 and aviso_tempo < 3:
    ~ aviso_tempo = 3
    Pela fresta da porta lá em cima, o céu do Bixiga já não é preto. É azul-escuro.
    Vincenzo: Cinco horas. Quarenta minutos de noite. Use bem.
}
{ minutos >= 150 and not constance_chegou:
    ~ constance_chegou = true
    A porta lá de cima bate. Um terno rosa desce a escada de pedra, devagar, com dois carniçais atrás. # imagem: constance_chega
    Constance, a Primogênita Lasombra, senta na mesa reservada e pede uma taça. As sombras da sala parecem se inclinar na direção dela. # pista dossie: À 01h30 a Constance, Primogênita Lasombra, chegou ao bar. Ninguém a chamou.
}
Para onde você vai?
+ [Rayo, debruçado no balcão]
    -> rayo
+ [O Cão, no canto escuro perto da escada]
    -> cao
+ [Harumi, na mesa de sinuca]
    -> harumi
+ [Nonna Benedetta, na mesa do fundo]
    -> nonna
+ {constance_chegou} [Constance, na mesa reservada]
    -> constance
+ {not p_limpeza} [Vincenzo, o dono do bar]
    -> vincenzo
+ [Chamar o Príncipe e fazer a acusação]
    Você: Vincenzo, mande chamar o Príncipe. Eu já sei o que preciso.
    -> acusacao

// ------------------------------------------------------------------ RAYO
=== rayo ===
# fundo: balcao
# entra: rayo
{ rayo_confessou:
    Rayo: Já falei o que tinha pra falar. Agora me deixa beber em paz.
    -> salao
}
{ rayo_fechado and not rayo_pressao:
    Rayo: Você de novo? Já disse que não tenho nada pra você.
}
{ not rayo_fechado: Rayo larga o capacete no balcão. A jaqueta de couro ainda pinga da chuva. }
-> rayo_perguntas

=== rayo_perguntas ===
{ minutos >= limite: -> amanhecer }
+ {not p_rayo_versao} {rayo_serra == 0} [O que aconteceu na Serra?]
    ~ passar(20)
    ~ rayo_serra = 1
    Rayo: Choveu. Teve neblina. Atrasei um pouco e entreguei. Próxima pergunta.
    Ele vira o copo e olha para a televisão desligada.
    -> rayo_perguntas
+ {not p_rayo_versao} {rayo_serra == 1} [Insistir: "Atrasou quanto? Por quê?"]
    ~ passar(20)
    ~ rayo_serra = 2
    Rayo: Você é surd{o}? Neblina. Na Serra tem neblina. Vai perguntar do tempo pro meteorologista.
    -> rayo_perguntas
+ {not p_rayo_versao} {rayo_serra == 2} [Insistir mais uma vez: "Ninguém atrasa por neblina e esconde o rosto, Rayo."]
    ~ passar(20)
    Rayo: ...Tá. Tá bom. Mas você não vai acreditar.
    -> rayo_lobisomens
+ {not p_rayo_versao} {rayo_serra >= 1} {not rayo_fechado} [Teste: Carisma + Persuasão, dif. 2 :: Pagar uma dose e deixar ele falar.]
    ~ passar(20)
    Você empurra um copo para o lado dele do balcão.
    ~ temp dose = rolar(carisma + 1, fome, 2)
    { dose == 1 or dose == 2 or dose == 3:
        Rayo: ...Valeu. Olha, eu não conto isso pra ninguém, porque ninguém acredita.
        -> rayo_lobisomens
    - else:
        Rayo: Não bebo com quem eu não conheço.
        ~ rayo_serra += 1
        -> rayo_perguntas
    }
+ {not rayo_hora_vaga} [Que horas você entregou a carga?]
    ~ passar(20)
    ~ rayo_hora_vaga = true
    Rayo: Antes das três. Sei lá. Eu não fico olhando relógio, fico olhando a estrada.
    Você: E o Biel?
    Rayo: Ficou com a carga no portão do túnel. Nunca mais atendeu o telefone.
    -> rayo_perguntas
+ {not p_rayo_frasco} [Quem te entregou a carga no porto?]
    ~ passar(20)
    Rayo: A Harumi. Toda sorridente, como sempre. Tava guardando um frasquinho escuro na manga do quimono quando eu cheguei.
    Rayo: Achei que era perfume. Aquela lá não usa perfume. # pista rayo: O Rayo viu a Harumi guardar um frasquinho escuro na manga, no porto.
    ~ p_rayo_frasco = true
    -> rayo_perguntas
+ {p_rayo_versao} {not p_queimadura} {not rayo_confessou} [Como estava o caixão quando você entregou?]
    ~ passar(20)
    Rayo: Inteiro. Caixão lacrado, os selos da Luciana no lugar. Ninguém mexeu.
    { raciocinio >= 3:
        Raciocínio 3 :: Quando ele diz "selos", esfrega a ponta dos dedos. A pele está empolada, como queimadura recente. # pista rayo: O Rayo tem queimaduras frescas nos dedos.
        ~ p_queimadura = true
    - else:
        Ele parece sincero. Ou é bom nisso.
    }
    -> rayo_perguntas
+ {p_rayo_versao} {not rayo_confessou} {cla == "Gangrel"} [Gangrel :: Lobisomem? Eu sentiria o cheiro em você. Você fede a sombra fria.]
    ~ passar(20)
    Você: Lobisomem? Eu sentiria o cheiro em você, irmão. Você não fede a mato. Fede a sombra fria.
    Rayo fica imóvel. Entre dois Gangrel, a mentira não dura muito.
    -> rayo_confissao
+ {p_rayo_versao} {not rayo_confessou} {carisma >= 3} [Carisma 3 :: Eu não trabalho pro Dante. O que você contar fica neste balcão.]
    ~ passar(20)
    Você: Eu não devo nada a essa Corte além de uma resposta. O que você contar fica neste balcão.
    Rayo olha para o Vincenzo, depois para você, e solta o ar que não precisa respirar.
    -> rayo_confissao
+ {p_rayo_versao} {not rayo_confessou} {not usou_pedagio} [Prova :: Dossiê: seu caminhão não passou em pedágio nenhum.]
    ~ passar(20)
    ~ usou_pedagio = true
    Você: Seu caminhão não passou em pedágio nenhum, Rayo. Nem Anchieta, nem Imigrantes. Que estrada você pegou?
    Rayo: ...A Estrada Velha. É fechada pra carro, ninguém olha. Atalho de quem conhece. # pista rayo: O Rayo desviou pela Estrada Velha do Mar.
    -> rayo_pressionar
+ {p_queimadura} {not rayo_confessou} {not usou_queimadura} [Prova :: Queimadura: isso nos seus dedos é marca de selo Tremere.]
    ~ passar(20)
    ~ usou_queimadura = true
    Você: Escapamento não deixa marca assim. Isso é selo Tremere. Você encostou no caixão.
    Rayo esconde a mão no bolso da jaqueta, tarde demais.
    -> rayo_pressionar
+ {p_rayo_versao} {not rayo_confessou} {not rayo_fechado} [Teste: Manipulação + Subterfúgio, dif. 3 :: Blefar: "A Constance já me contou tudo."]
    ~ passar(20)
    Você: A Constance já me contou tudo, Rayo. Só quero ouvir a sua parte.
    ~ temp r = rolar(manipulacao + subterfugio, fome, 3)
    { r:
    - 4:
        A Besta sobe pela sua garganta e você rosna no meio da frase. As presas aparecem.
        Rayo: Vocês são todos iguais.
        Ele vira as costas. Com você, ele não fala mais.
        ~ rayo_fechado = true
        ~ quebrou_regra += 1
        -> salao
    - 0:
        Rayo: A Constance? Ela não fala com gente como você. Boa tentativa.
        ~ rayo_fechado = true
        -> rayo_perguntas
    - else:
        Rayo: ...Ela te contou? Então você sabe que eu não toquei no caixão.
        -> rayo_confissao
    }
+ {p_rayo_versao} {not rayo_confessou} {disciplina == "Presença"} [Disciplina: Presença :: Sorrir como quem já é amigo dele há cem anos.]
    ~ passar(20)
    ~ despertar()
    Você deixa o calor da Presença escorrer pela voz. O Rayo relaxa os ombros sem saber por quê.
    Vincenzo pigarreia do outro lado do balcão. Ele percebeu.
    ~ quebrou_regra += 1
    -> rayo_confissao
+ {p_rayo_versao} {not rayo_confessou} {disciplina == "Animalismo"} {not sentiu_besta_rayo} [Disciplina: Animalismo :: Sentir a Besta dele.]
    ~ passar(20)
    ~ despertar()
    Você deixa a sua Besta farejar a dele. Não tem medo de lobisomem ali. Tem medo de outra coisa: alguém que paga bem e cobra caro.
    Vincenzo pigarreia do outro lado do balcão. Ele percebeu. # pista rayo: A Besta do Rayo tem medo de quem o contratou, não de lobisomens.
    ~ quebrou_regra += 1
    ~ sentiu_besta_rayo = true
    -> rayo_pressionar
+ [Voltar para o salão]
    -> salao

=== rayo_pressionar ===
~ rayo_pressao += 1
{ rayo_pressao >= 2:
    Rayo: Tá bom. Tá bom, porra.
    -> rayo_confissao
- else:
    Rayo: Isso não prova nada. Eu entreguei a carga inteira.
    -> rayo_perguntas
}

=== rayo_lobisomens ===
Rayo: Neblina grossa, daquelas que você não enxerga o próprio farol.
Rayo: Na curva da Onça, uns vultos atravessaram a pista. Grandes demais pra cachorro. Lupinos.
Rayo: Joguei o caminhão no acostamento, apaguei tudo e esperei passar. Perdi uns quarenta minutos ali. # pista rayo: Versão do Rayo, depois de muito insistir: lobisomens na neblina, 40 minutos parado.
~ p_rayo_versao = true
-> rayo_perguntas

=== rayo_confissao ===
~ rayo_confessou = true
~ p_selo = true
~ p_constance = true
Rayo: Não teve lobisomem nenhum. A Constance me pagou pra descer pela Estrada Velha.
Rayo: Os homens dela abriram o baú no meio do mato. Tentaram abrir o caixão também, mas os selos da bruxa queimaram a mão de um deles. Um selo ficou preto, chamuscado.
Rayo: Eu entrei em pânico e meti o pé. A carga chegou inteira no túnel, eu juro. # pista rayo: Constance pagou o desvio. Na Estrada Velha um dos selos Tremere ficou queimado, e a carga seguiu inteira.
~ p_rayo_hora = true
Rayo: Duas e quarenta, eu olhei. Eu tava atrasado e com medo. O Cão tava esperando no portão, e eu deixei o Biel lá com ele. # pista rayo: Rayo entregou às 02h40 no portão da Vila Sônia, e o Cão estava lá. O Cão disse ao Príncipe 03h30.
Rayo: Se o Dante souber da Constance, eu tô morto. Se ela souber que eu falei, também.
Você guarda a pista mais importante da noite: só quem viu a carga depois do desvio sabe que um selo estava queimado.
-> salao

// ------------------------------------------------------------------ CÃO
=== cao ===
# fundo: escada
# entra: cao
{ cao_travou:
    O Cão não olha mais para você. Os dedos dele tamborilam no corrimão.
    -> salao
}
{ not p_cao_versao: Debaixo da escada, onde a luz não chega, o Xerife fuma um cigarro que não traga. Os olhos amarelos acompanham você desde a porta. }
-> cao_perguntas

=== cao_perguntas ===
{ minutos >= limite: -> amanhecer }
+ {not p_cao_versao} [O que aconteceu no túnel?]
    ~ passar(20)
    Cão: O caminhão chegou às três e meia. Baú aberto, vazio. Nem sinal do moleque da moto, o Biel.
    Cão: Quer um culpado? Começa pelo motoqueiro. Anarquista não respeita carga de ninguém.
    ~ p_cao_versao = true
    -> cao_perguntas
+ {p_cao_versao} {not p_cao_selo} [Como você sabe que foi o Rayo?]
    ~ passar(20)
    Cão: Porque ele forçou a carga. Os selos da Senescal. Um tava preto, chamuscado. Bruxaria Tremere não queima sozinha.
    Ele percebe o que disse meio segundo depois de você. O cigarro para no meio do caminho. # pista cao: O Cão disse que viu um selo Tremere queimado. Mas, segundo ele, o caminhão chegou vazio.
    ~ p_cao_selo = true
    -> cao_perguntas
+ {p_cao_selo} {p_selo} {not cao_travou} [Prova :: Selo queimado: se o caminhão chegou vazio, como você viu o selo?]
    ~ passar(20)
    -> cao_trava
+ {p_cao_versao} {p_rayo_hora or p_biel_hora} {not cao_hora_confrontada} [Prova :: Horário: a carga chegou às 02h40, não às 03h30.]
    ~ passar(20)
    ~ cao_hora_confrontada = true
    Você: {p_biel_hora:O próprio Biel viu o relógio da guarita às duas e cinquenta.|O Rayo diz que entregou às duas e quarenta, com você esperando no portão.}
    Cão: Motoqueiro mente, e morto mente mais ainda. Tinha muito caminhão naquele portão.
    Ele responde rápido demais. # pista cao: O Cão não explica o que fez entre 02h40 e 03h30.
    -> cao_perguntas
+ {cla == "Nosferatu"} {not p_concreto} [Nosferatu :: Reparar na roupa dele, de rato para rato.]
    ~ passar(20)
    Você: Você trabalha embaixo da terra, primo. Mas essa poeira aí não é de esgoto.
    Na barra da calça dele tem pó cinza, fino, de concreto novo. O mesmo que cobre as obras da Linha Amarela. # pista cao: Pó de concreto novo na roupa do Cão, como o das obras da Linha Amarela.
    Cão: Eu ando por onde quero. Sou o Xerife.
    ~ p_concreto = true
    -> cao_perguntas
+ {p_limpeza} {not p_concreto} [Prova :: Lama: a equipe do Vincenzo voltou com lama de obra. Olhar as botas do Xerife.]
    ~ passar(20)
    ~ p_concreto = true
    Você olha para baixo. Na barra da calça e nas botas do Cão tem pó cinza, fino, de concreto novo. O mesmo das obras da Linha Amarela. # pista cao: Pó de concreto novo nas botas do Cão, como o das obras da Linha Amarela. A mesma lama que voltou no carro da limpeza.
    Cão: Tá olhando o quê? Eu ando por onde quero. Sou o Xerife.
    -> cao_perguntas
+ {disciplina == "Ofuscação"} {not p_bunker} [Disciplina: Ofuscação :: Sumir na sombra da escada e escutar.]
    ~ passar(20)
    ~ despertar()
    Você sai da conversa, dá dois passos e deixa de ser vista. O Cão pisca, procura você, e pega o celular.
    Cão: Sou eu. Tranca a porta do bunker, embaixo dos trilhos. Ninguém desce até eu voltar. Ninguém. # pista cao: O Cão mandou trancar um bunker "embaixo dos trilhos".
    O Vincenzo, do balcão, olha exatamente para onde você está. Ele não diz nada, mas sabe.
    ~ p_bunker = true
    ~ quebrou_regra += 1
    -> cao_perguntas
+ {disciplina == "Animalismo"} {not p_bunker} [Disciplina: Animalismo :: Chamar o rato que dorme no casaco dele.]
    ~ passar(20)
    ~ despertar()
    Um rato cinza sai da gola do Cão e desce pela escada até o seu sapato. Na língua dos bichos, ele reclama de um buraco novo e frio, embaixo dos trilhos amarelos, onde agora tem uma caixa que cheira a morte velha. # pista cao: O rato do Cão fala de um buraco novo embaixo dos trilhos, com uma caixa que cheira a morte velha.
    Cão: Que é isso? Volta aqui, bicho.
    ~ p_bunker = true
    ~ quebrou_regra += 1
    -> cao_perguntas
+ {disciplina == "Presença"} {not cao_irritado} [Disciplina: Presença :: Ganhar a confiança dele com charme.]
    ~ passar(20)
    ~ despertar()
    Cão: Guarda esse charme pra Toreador, pastora. Eu já fui mordido por coisa mais bonita.
    Ele cospe no chão. Agora ele sabe que você usa Disciplina dentro do Porão. # pista cao: O Cão resiste à Presença. Ele tem a vontade muito forte.
    ~ cao_irritado = true
    ~ quebrou_regra += 1
    -> cao_perguntas
+ {p_cao_versao} {not cao_irritado} [Teste: Força + Intimidação, dif. 5 :: Encostar o Xerife na parede.]
    ~ passar(20)
    Você: Você recebeu a carga e está mentindo para o seu Príncipe.
    ~ temp r = rolar(intimidacao, fome, 5)
    { r == 1 or r == 2 or r == 3:
        O Cão recua um passo, sem perceber. Por um instante o Xerife parece um bicho encurralado.
        Cão: Eu protejo o que é meu. Só isso. E agora sai da minha frente. # pista cao: Encurralado, o Cão disse: "Eu protejo o que é meu."
    - else:
        Cão: Você não sabe com quem está falando, forasteir{o}. Fica esperto na volta pra casa.
    }
    ~ cao_irritado = true
    -> cao_perguntas
+ [Voltar para o salão]
    -> salao

=== cao_trava ===
~ cao_travou = true
Você: Você disse que o caminhão chegou vazio. Mas o selo só queimou na Estrada Velha, depois do porto. Só quem viu o caixão depois disso sabe que tinha um selo preto.
O Cão abre a boca e não sai nada. Pela primeira vez na noite, o Xerife não tem resposta.
Cão: ...Você não entende o que está acontecendo nesta cidade, forasteir{o}. Quando o Dante cair, quem vai proteger a gente?
Cão: Pensa bem no que vai dizer pro Príncipe. # pista cao: O Cão travou: ele viu o caixão depois do desvio. É a prova da acusação.
-> salao

// ------------------------------------------------------------------ PAIZÃO
=== harumi ===
# fundo: sinuca
# entra: harumi
{ harumi_confessou:
    Harumi: Eu já te dei o que você queria, querid{o}. Agora esquece que me viu.
    -> salao
}
{ not p_cripta: Na mesa de sinuca, a Harumi encaçapa três bolas seguidas sem tirar os olhos de você. O quimono preto tem serpentes bordadas. }
-> harumi_perguntas

=== harumi_perguntas ===
{ minutos >= limite: -> amanhecer }
{ fome >= 3 and not p_dedos:
    Fome 3 :: Quando ela passa perto, você sente: nos dedos dela, um cheiro de sangue antigo, tão forte que a sua boca se enche. # pista harumi: Cheiro de sangue muito antigo nos dedos da Harumi.
    ~ p_dedos = true
}
+ [O que saiu do porto?]
    ~ passar(20)
    Harumi: Um contêiner lacrado, querid{o}. Meus estivadores tiraram do navio e eu liberei. Nunca abri, nunca vi, nunca quis ver.
    Harumi: Se sumiu, foi no caminho. E quem fez o caminho foi esse motoqueiro anarquista.
    -> harumi_perguntas
+ {not p_cripta} [Como era a carga? Pesada, grande?]
    ~ passar(20)
    Harumi: Pesada e fedida. Cheiro de cripta, de terra de cemitério velho. Até os estivadores reclamaram.
    Ela sorri, e o sorriso dura menos do que devia. # pista harumi: A Harumi falou do "cheiro de cripta" da carga, mas diz que o contêiner saiu lacrado.
    ~ p_cripta = true
    -> harumi_perguntas
+ {p_cripta} {not usou_cripta} {not harumi_confessou} [Prova :: Cheiro de cripta: se estava lacrado, como você sentiu o cheiro?]
    ~ passar(20)
    ~ usou_cripta = true
    Você: Contêiner lacrado não tem cheiro, Harumi. Sarcófago aberto tem.
    Harumi: Eu tenho o nariz bom. Faz parte do meu negócio.
    -> harumi_pressionar
+ {p_rayo_frasco} {not usou_frasco_rayo} {not harumi_confessou} [Prova :: Frasco: o Rayo te viu guardando um frasquinho na manga.]
    ~ passar(20)
    ~ usou_frasco_rayo = true
    Você: O Rayo viu você guardar um frasco escuro na manga, no porto. Não era perfume.
    A Harumi cobre a manga com a outra mão, devagar demais.
    -> harumi_pressionar
+ {p_dedos} {not usou_dedos} {not harumi_confessou} [Prova :: Sangue: seus dedos cheiram a sangue mais velho que esta cidade.]
    ~ passar(20)
    ~ usou_dedos = true
    Você: Seus dedos cheiram a sangue antigo, Harumi. Antigo demais pra ser seu.
    -> harumi_pressionar
+ {cla == "Ministério"} {not p_frasco} [Ministério :: Irmão, a Serpente ensina que todo segredo tem preço.]
    ~ passar(20)
    Você: Irmã, nós servimos à mesma Serpente. Ela ensina que todo segredo tem preço. Me diga o seu.
    Harumi: ...Alguém da Serpente. Logo hoje. Tá bom. Eu tirei um pouquinho. Só um frasco, pros meus clientes mais especiais. O velho nem vai sentir falta. # pista harumi: A Harumi admitiu que abriu o sarcófago e tirou um frasco de sangue para vender.
    ~ p_frasco = true
    -> harumi_perguntas
+ {not harumi_fechado} {not harumi_confessou} [Teste: Força + Intimidação, dif. 4 :: Segurar o taco dela e falar baixo.]
    ~ passar(20)
    Você segura o taco de sinuca no meio da tacada dela.
    ~ temp r = rolar(intimidacao, fome, 4)
    {
    - r == 1 or r == 2 or r == 3:
        Harumi: Solta. Solta o taco, eu falo. Ninguém encosta em mim aqui dentro.
        -> harumi_confissao
    - r == 4:
        A Besta empurra e você quebra o taco ao meio. O bar inteiro fica quieto. O Vincenzo pousa o copo devagar.
        ~ quebrou_regra += 1
        ~ harumi_fechado = true
        Harumi: Vincenzo! Seu convidado está quebrando a regra da casa.
        -> salao
    - else:
        Harumi: Que gracinha. Você acha que me assusta? Eu tenho cem anos de gente mais feia que você.
        ~ harumi_fechado = true
        -> harumi_perguntas
    }
+ {disciplina == "Presença"} {not harumi_confessou} [Disciplina: Presença :: Fazer ela querer contar tudo para você.]
    ~ passar(20)
    ~ despertar()
    Você deixa a Presença tomar a sala. A Harumi, que vive de seduzir os outros, se pega sorrindo para você como para uma velha amizade.
    ~ quebrou_regra += 1
    -> harumi_confissao
+ {disciplina == "Animalismo"} {not harumi_confessou} [Disciplina: Animalismo :: Farejar o medo dela.]
    ~ passar(20)
    ~ despertar()
    A Besta dela não tem medo de você. Tem medo de gente de terno, crachá e lanterna. Gente que caça vampiro. # pista harumi: A Harumi tem medo de caçadores, de gente "de terno e crachá".
    ~ quebrou_regra += 1
    -> harumi_pressionar
+ [Voltar para o salão]
    -> salao

=== harumi_pressionar ===
~ harumi_pressao += 1
{ harumi_pressao >= 2:
    Harumi: Tá bom. Mas isso não sai desta mesa.
    -> harumi_confissao
- else:
    Harumi: Você está vendo coisa, querid{o}. Eu só cuido de mercadoria.
    -> harumi_perguntas
}

=== harumi_confissao ===
~ harumi_confessou = true
~ p_frasco = true
~ p_boes = true
Harumi: Eu abri o caixão. Só o suficiente pra encher um frasco. Sangue daquele, meus clientes pagam uma fortuna.
Harumi: Mas tem outra coisa, e essa é a que me tira o sono. O manifesto da carga tinha um carimbo. BOES. Batalhão de Operações Especiais.
Harumi: Carga do Príncipe, com carimbo de caçador. Você entende o que isso quer dizer? Eu não quero entender. # pista harumi: O manifesto da carga tinha um carimbo do BOES, os caçadores. A carga do Príncipe tinha papel da Segunda Inquisição.
Você guarda o carimbo como quem guarda uma arma carregada.
-> salao

// ------------------------------------------------------------------ NONNA E O FANTASMA
=== nonna ===
# fundo: fundo_bar
{ sessao_feita and biel_perguntas >= 3:
    Nonna: Ele já foi, filh{o}. Os mortos não ficam muito tempo por causa dos vivos.
    -> salao
}
{ sessao_feita:
    # entra: biel
    O fantasma do Biel ainda está ali, por cima da chama da vela, mais fraco a cada minuto.
    -> biel_perguntas_loop
}
Nonna: Senta, filh{o}. Você quer falar com o rapaz que morreu hoje, eu sei. Ele está aqui desde as três, andando em volta da minha mesa.
Nonna: Mas os mortos não falam de graça. Eu chamo ele, e você me fica devendo um favor. Um dia eu cobro.
+ [Aceitar. "Um favor. Combinado."]
    -> sessao
+ [Agora não]
    -> salao

=== sessao ===
~ passar(60)
~ sessao_feita = true
A Nonna acende sete velas e reza baixinho em italiano. A sessão demora. Os ponteiros do relógio andam uma hora inteira.
O ar esfria. A chama das velas deita para o lado, como se alguém tivesse sentado na cadeira vazia. # entra: biel
Biel: Onde... onde eu tô? A carga. Cadê a carga do patrão?
Nonna: Ele tem pouco tempo, filh{o}. Três perguntas, talvez. Escolhe bem.
-> biel_perguntas_loop

=== biel_perguntas_loop ===
{ biel_perguntas >= 3:
    O fantasma tremula e se apaga junto com a última vela.
    Nonna: Acabou. Agora você me deve um favor.
    -> salao
}
{ minutos >= limite: -> amanhecer }
{ ocultismo >= 2 and not p_tunel:
    Ocultismo 2 :: Você sabe que fantasmas repetem o lugar onde morreram. O Biel fala com eco, como quem está num túnel, e a roupa dele pinga água de esgoto, não orvalho de mata. # pista biel: O fantasma morreu num túnel, não na Serra. Ele morreu depois da entrega.
    ~ p_tunel = true
}
+ {biel_perguntas < 3} [Como você morreu?]
    ~ passar(10)
    ~ biel_perguntas += 1
    Biel: Eu defendi a carga, moço. Até o fim. Uma fera me pegou no escuro. Olho amarelo, unha comprida.
    Biel: Só pode ter sido o Rayo. Ele é Gangrel, vira bicho. # pista biel: O fantasma acha que foi o Rayo, porque "uma fera de olho amarelo" o pegou no escuro.
    -> biel_perguntas_loop
+ {biel_perguntas < 3} {not p_tunel} [Onde você estava quando morreu?]
    ~ passar(10)
    ~ biel_perguntas += 1
    ~ p_tunel = true
    Biel: Tava escuro... tinha eco. Pingava água do teto. Cheiro de esgoto e de trilho. A carga já tinha descido do caminhão.
    Na Serra não tem trilho nem esgoto. # pista biel: O fantasma morreu num lugar com eco, trilho e esgoto, depois que a carga desceu do caminhão: o túnel.
    -> biel_perguntas_loop
+ {biel_perguntas < 3} {not biel_hora_feita} [Que horas você morreu?]
    ~ passar(10)
    ~ biel_perguntas += 1
    ~ biel_hora_feita = true
    Biel: Hora? Morto não tem hora, moço. É tudo uma noite só, comprida.
    Biel: Eu lembro do escuro. Do frio. Do resto, não.
    A vela mais próxima apaga. Uma pergunta a menos.
    -> biel_perguntas_loop
+ {biel_perguntas < 3} {not biel_doeu} [Doeu?]
    ~ passar(10)
    ~ biel_perguntas += 1
    ~ biel_doeu = true
    Biel: Doeu, moço. Ainda dói. Dói o tempo todo.
    Ele chora sem lágrima. A Nonna balança a cabeça para você, devagar.
    -> biel_perguntas_loop
+ {biel_perguntas < 3} {not biel_luz} [Você viu alguma luz? Tem alguma coisa do outro lado?]
    ~ passar(10)
    ~ biel_perguntas += 1
    ~ biel_luz = true
    Biel: Luz? Tem uma luz, tem... Não, é a vela da senhora. Do outro lado não tem nada. Tem fila.
    Nonna: Não gasta o menino com bobagem, filh{o}.
    -> biel_perguntas_loop
+ {biel_perguntas < 3} {not p_biel_hora} [Quer deixar algum recado pra sua mãe?]
    ~ passar(10)
    ~ biel_perguntas += 1
    ~ p_biel_hora = true
    Biel: A mãe... Fala pra ela que eu liguei. Eu liguei da guarita do túnel pra dizer que tava tudo certo, que o patrão chegava antes das três.
    Biel: Ela nem atendeu. O relógio da guarita marcava duas e cinquenta. Depois disso... # pista biel: O Biel ligou para a mãe da guarita do túnel às 02h50. A carga já estava lá e ele ainda estava vivo. O Cão disse 03h30.
    Ele se apaga um pouco, mais leve.
    -> biel_perguntas_loop
+ {biel_perguntas < 3} {p_boes} {not p_informante} [Prova :: Carimbo do BOES: quem te pagava, Biel?]
    ~ passar(10)
    ~ biel_perguntas += 1
    ~ p_informante = true
    Você: A carga tinha carimbo do BOES. E alguém contou a rota pra eles. Quem te pagava, Biel?
    O fantasma se encolhe. Parece que vai sumir.
    Biel: A doutora... A Dra. Elisa. Ela me dava dinheiro pra contar por onde a carga ia. Disse que era só pra garantir que chegava.
    Biel: Não conta pro Rayo. Eu não quero ser lembrado como dedo-duro. # pista biel: O Biel era informante da Dra. Elisa, da Segunda Inquisição. Os caçadores sabiam da rota, e não interceptaram.
    -> biel_perguntas_loop
+ [Deixar o fantasma descansar]
    Nonna: Vai em paz, filh{o}.
    ~ biel_perguntas = 3
    -> salao

// ------------------------------------------------------------------ CONSTANCE (chega à 01h30)
=== constance ===
# fundo: salao
# entra: constance
{ constance_fechada:
    Constance: Eu já fui generosa com você, forasteir{o}. Não abuse.
    -> salao
}
{ not c_veio: Constance gira a taça sem beber. O terno rosa é a única cor viva da sala, e as sombras em volta da mesa são mais escuras do que deviam. }
-> constance_perguntas

=== constance_perguntas ===
{ minutos >= limite: -> amanhecer }
+ {not c_veio} [O que a senhora veio fazer aqui esta noite?]
    ~ passar(20)
    ~ c_veio = true
    Constance: Beber. Ouvir. O Porão é o único lugar da cidade onde o Príncipe não manda.
    Constance: E ver de perto quem o Dante escolheu pra fazer o trabalho do Xerife dele. # pista constance: A Constance chegou sem ser chamada e sabe que você investiga para o Príncipe.
    -> constance_perguntas
+ {not c_rayo} [A senhora conhece o motoqueiro, o Rayo?]
    ~ passar(20)
    ~ c_rayo = true
    Constance: Eu conheço todo mundo que tem preço, querid{o}. O dele é bem baixo.
    Ela não nega. Também não confirma.
    -> constance_perguntas
+ {p_constance} {not p_envelope} [Prova :: Desvio: o Rayo diz que a senhora pagou pra ele descer pela Estrada Velha.]
    ~ passar(20)
    ~ p_envelope = true
    Constance: Aquele garoto fala demais.
    Ela deixa o silêncio durar até ficar desconfortável. Depois sorri.
    Constance: Paguei. Eu queria ver o que o Dante trazia escondido para a minha cidade. Uma Primogênita tem esse direito.
    Constance: Meus homens não abriram o caixão. Os selos da bruxa queimaram a mão de um deles. Mas tinha um envelope preso ao sarcófago, por fora. Endereçado "À Doutora". Sem nome.
    Constance: O caixão seguiu inteiro pela Serra. Se sumiu, sumiu depois. Procure quem recebeu. # pista constance: A Constance admitiu o desvio. O caixão seguiu inteiro, e tinha um envelope preso a ele endereçado "À Doutora".
    -> constance_perguntas
+ {p_boes} {not constance_aliada} {not constance_hostil} [Prova :: Carimbo do BOES: mostrar o manifesto a ela, em voz baixa.]
    ~ passar(20)
    ~ constance_aliada = true
    Constance para a taça no meio do caminho. Pela primeira vez na noite, ela parece ter a idade que tem.
    Constance: Guarde isso. Não mostre a ninguém antes da hora. Quando a hora chegar, eu fico do seu lado na Corte. # pista constance: A Constance viu o carimbo do BOES e prometeu ficar do seu lado na Corte.
    -> constance_perguntas
+ {not p_constance_cao} {not constance_hostil} [Teste: Manipulação + Subterfúgio, dif. 4 :: Insinuar que o Príncipe já desconfia dela.]
    ~ passar(20)
    Você: O Príncipe sabe que a senhora tem interesse nessa carga.
    ~ temp r = rolar(manipulacao + subterfugio, fome, 4)
    { r:
    - 4:
        A Besta escapa e você bate a mão na mesa dela. A taça cai. As sombras da sala inteira se levantam do chão, e os carniçais dela dão um passo à frente.
        Constance: Vincenzo. O seu convidado esqueceu onde está.
        ~ quebrou_regra += 1
        ~ constance_hostil = true
        ~ constance_fechada = true
        -> salao
    - 0:
        Constance: Ameaça de forasteir{o} é como garoa em São Paulo. Molha, mas ninguém lembra.
        ~ constance_hostil = true
        -> constance_perguntas
    - else:
        ~ p_constance_cao = true
        Constance: O Dante desconfia de todo mundo, querid{o}. Menos do cachorro dele. É por isso que ele nunca olha pra escada.
        Ela olha para o canto escuro onde o Cão fuma, e volta a olhar para você. # pista constance: Constance: "O Dante desconfia de todo mundo, menos do cachorro dele." Ela olhou para o Cão.
        -> constance_perguntas
    }
+ {p_tunel} {not p_bunker} {not constance_hostil} [Prova :: Túnel: o Biel morreu embaixo da terra. Onde o Xerife esconde as coisas dele?]
    ~ passar(20)
    ~ p_bunker = true
    Constance: As minhas sombras andam pela cidade inteira, querid{o}. Menos por um lugar.
    Constance: Um buraco novo embaixo dos trilhos da Linha Amarela. Fechado com ferro e sal, do jeito que o Cão gosta. Faz um mês que eu não consigo ver o que tem lá dentro. # pista constance: Constance: o Cão tem um esconderijo novo embaixo da Linha Amarela, fechado com ferro e sal, onde as sombras dela não entram.
    -> constance_perguntas
+ {disciplina == "Ofuscação"} {not p_constance_ordem} [Disciplina: Ofuscação :: Sumir e escutar o que ela diz aos carniçais.]
    ~ passar(20)
    ~ despertar()
    ~ quebrou_regra += 1
    ~ p_constance_ordem = true
    Você deixa de ser vista e para atrás da cadeira dela. Constance se inclina para o carniçal da esquerda.
    Constance: Se o forasteir{o} chegar no Cão, deixa chegar. Se chegar em mim, resolve antes do sol. # pista constance: A Constance mandou o carniçal "resolver" você se a investigação chegar nela. Se chegar no Cão, ela deixa.
    A sombra dela se estica pelo chão até o seu pé, e para ali. Talvez ela saiba que você está ouvindo. Talvez não.
    -> constance_perguntas
+ {disciplina == "Presença"} {not constance_hostil} [Disciplina: Presença :: Encantar a Primogênita.]
    ~ passar(20)
    ~ despertar()
    ~ quebrou_regra += 1
    ~ constance_hostil = true
    Constance ri, um riso curto e sem graça nenhuma.
    Constance: Isso funciona com motoqueiro, pastora. Eu tenho trezentos anos. Não faça de novo.
    -> constance_perguntas
+ {disciplina == "Animalismo"} {not c_animal} [Disciplina: Animalismo :: Farejar a Besta dela.]
    ~ passar(20)
    ~ despertar()
    ~ quebrou_regra += 1
    ~ c_animal = true
    A Besta dela não tem medo de ninguém nesta sala. Mas está com fome. Não de sangue: de uma oportunidade. Ela espera alguém cair. # pista constance: A Besta da Constance espera uma oportunidade. Ela quer ver alguém cair, e não é o Rayo.
    -> constance_perguntas
+ [Voltar para o salão]
    -> salao

// ------------------------------------------------------------------ VINCENZO
=== vincenzo ===
# fundo: balcao
{ not vincenzo_falou: Vincenzo: Um conselho, forasteir{o}? Ou só uma bebida? }
{ vincenzo_falou: Vincenzo: De volta ao balcão, forasteir{o}. }
~ vincenzo_falou = true
+ {not v_neutro} [Alguém usou os seus serviços esta noite?]
    ~ passar(20)
    ~ v_neutro = true
    Vincenzo: O Porão é neutro. Eu não pergunto, e não conto.
    Vincenzo: Volte quando souber o que perguntar. Pergunta vaga ganha resposta vaga. # pista bar: Vincenzo: "Volte quando souber o que perguntar." Ele sabe de alguma coisa.
    -> salao
+ {v_neutro} {p_tunel or p_concreto} {not p_limpeza} [Prova :: Túnel: alguém morreu embaixo da terra esta noite. Quem pagou a limpeza?]
    ~ passar(20)
    ~ p_limpeza = true
    Vincenzo: Agora sim, uma pergunta.
    Vincenzo: Minha equipe de limpeza trabalhou hoje, depois das três. O carro voltou com lama de obra nas rodas e cheiro de esgoto.
    Vincenzo: Quem pagou? Alguém que tem a chave dos túneis. Eu não disse nome nenhum. # pista bar: A equipe de limpeza do Vincenzo trabalhou depois das 3h para alguém com a chave dos túneis. O carro voltou com lama de obra e cheiro de esgoto.
    -> salao
+ [Só uma bebida]
    Vincenzo: Sangue de porco com um pouco de vinho. Por conta da casa. A noite vai ser longa.
    -> salao

// ------------------------------------------------------------------ ACUSAÇÃO E FINAIS
=== amanhecer ===
# fundo: salao
# limpa
Vincenzo: Acabou o tempo, forasteir{o}. O céu já está clareando lá fora. O Príncipe chegou.
-> acusacao

=== acusacao ===
# fundo: corte
# limpa
A Corte desce a escada. O Príncipe Dante senta no meio do salão. Ao lado dele, de terno rosa, a Primogênita Lasombra Constance observa você sem piscar.
Dante: Então, forasteir{o}. Quem me traiu?
{ quebrou_regra >= 2: Vincenzo: Antes, Príncipe: este aí usou Disciplina no meu Porão. Mais de uma vez. }
+ [Rayo, o motoqueiro]
    -> final_rayo
+ [Harumi, do porto]
    -> final_harumi
+ {p_constance} [Constance, a Primogênita Lasombra]
    -> final_constance
+ [O Xerife, o Cão]
    -> acusa_cao
+ [Admitir que não sabe]
    -> final_nao_sei

=== function provas_cao() ===
~ temp n = 0
{ p_bunker:
    ~ n += 1
}
{ p_concreto:
    ~ n += 1
}
{ p_limpeza:
    ~ n += 1
}
{ p_tunel:
    ~ n += 1
}
{ p_biel_hora or p_rayo_hora:
    ~ n += 1
}
~ return n

=== acusa_cao ===
Você: Foi o seu Xerife, Príncipe. O Cão recebeu a carga e mentiu para o senhor.
# entra: cao
Cão: Isso é palavra de forasteir{o} contra a minha.
{ cao_travou:
    Você: Ele disse que o caminhão chegou vazio. Mas sabia que um selo Tremere estava queimado. O selo só queimou na Estrada Velha. Ele viu o caixão.
    -> cao_desmorona
}
{ provas_cao() >= 4:
    Você junta as peças diante da Corte, uma por uma.
    { p_biel_hora or p_rayo_hora: Você: A carga chegou antes das três. Ele disse três e meia ao senhor. }
    { p_tunel: Você: O Biel morreu no túnel, depois da entrega. O próprio morto disse. }
    { p_limpeza: Você: Alguém com a chave dos túneis pagou a limpeza do Vincenzo depois das três. }
    { p_concreto: Você: Ele tem pó de concreto da Linha Amarela na roupa. }
    { p_bunker: Você: E ele tem um bunker embaixo dos trilhos, trancado esta noite. }
    -> cao_desmorona
}
Você tenta, mas tudo o que tem são suspeitas.
Dante: Você me traz um palpite na frente da Corte inteira?
-> final_sem_provas

=== cao_desmorona ===
O Cão olha para a escada. Dois carniçais do Príncipe já estão lá.
Cão: Tá bom. Tá no bunker, embaixo da Linha Amarela. Intacto. Eu ia devolver quando a poeira baixasse.
Cão: E o moleque viu o que não devia. Fiz o que um Xerife faz.
Dante: Você fez o que um traidor faz.
O Cão não espera os carniçais. Ele salta por cima da mesa, e em meio segundo as unhas dele estão na sua garganta. O seu sangue pinga no chão do Porão.
Dante: Pare.
Uma palavra só. O Cão congela no ar, como cachorro que ouviu o dono. Os carniçais o arrastam para longe de você.
Dante: Ninguém toca em quem me serve. Pelo menos esta noite.
Você leva a mão ao pescoço. Mais um segundo e não sobrava nada para o Príncipe proteger.
{ p_boes:
    Constance não tira os olhos de você. Ela percebe que você sabe mais do que disse.
    Você tem o carimbo do BOES no bolso. O Príncipe ia entregar o Matusalém para os caçadores. O que você faz?
    + [Ficar calado e entregar só o Cão ao Príncipe]
        -> final_b
    + [Mostrar o carimbo do BOES para a Corte inteira]
        -> final_c_corte
    + [Guardar a prova e levar aos Anarquistas, pelo Rayo]
        -> final_c_anarquistas
- else:
    -> final_b
}

=== final_rayo ===
# entra: rayo
Rayo: Eu? Eu entreguei aquela carga inteira!
Dante: O motoqueiro desviou a rota. Isso basta para mim.
Os carniçais arrastam o Rayo escada acima. A porta fica aberta. O céu está clareando.
# imagem: rayo_morto
# musica: final_triste
Ao amanhecer, o Rayo é amarrado no telhado da cantina. O sol faz o resto.
Na noite seguinte, o motoclube dele declara guerra à Camarilla. A Augusta pega fogo.
-> morte_bode

=== final_harumi ===
# entra: harumi
Harumi: Eu? Eu só cuido de mercadoria, Príncipe. O senhor sabe disso.
{ p_frasco:
    Você: Ela abriu o sarcófago e tirou um frasco do sangue do Matusalém para vender.
    Dante: Então ela roubou de mim. Dá no mesmo.
}
A Harumi é levada pela escada, ainda sorrindo, sem pressa nenhuma.
# imagem: harumi_morto
# musica: final_triste
Na noite seguinte, o porto de Santos tem uma nova dona. A antiga foi encontrada numa câmara fria de contêiner, de olhos abertos.
-> morte_bode

=== final_constance ===
Você: A Constance pagou o desvio do caminhão.
Constance: Que acusação interessante, vinda de alguém que chegou na cidade há três noites.
{ p_envelope: Você: Ela mesma admitiu. Os homens dela abriram o baú na Serra. }
Constance: Abri, e o caixão seguiu inteiro. O forasteir{o} sabe disso. Só não sabe onde ele está.
Dante olha para ela por um longo tempo. Ele não pode derrubar a Primogênita Lasombra por causa de um forasteir{o}. Ainda não.
# musica: final_triste
Dante: Saia da minha cidade antes da próxima noite. Sua dívida não está paga.
Você não chega à próxima noite. Na escada da pensão, a sua própria sombra se levanta da parede e fecha a sua boca.
# imagem: amanhecer
Os Lasombra não deixam acusação sem resposta. De manhã, sobra uma mancha de cinza no degrau e um lenço cor-de-rosa.
-> final_a_epilogo

=== morte_bode ===
Três noites depois, alguém bate na porta da sua pensão. É o Cão, com o cigarro que ele não traga.
Cão: Bom trabalho, forasteir{o}. Bom até demais. Gente esperta não dura nesta cidade.
# imagem: amanhecer
Ninguém pergunta por você. Você não tinha amigos aqui, como o Príncipe disse.
-> final_a_epilogo

=== final_a_epilogo ===
# imagem: bunker
# musica: final_triste
Longe dali, embaixo dos trilhos da Linha Amarela, um sarcófago com um selo queimado espera no escuro. Só o Cão sabe onde ele está.
FINAL A · O BODE EXPIATÓRIO. Você acusou a pessoa errada e pagou com a vida. # final: A
-> END

=== final_sem_provas ===
# entra: cao
O Cão sorri, mostrando os dentes tortos.
Cão: Príncipe, alguém de fora que acusa o Xerife sem prova é alguém que trabalha para alguém.
Dante: Concordo.
Antes que você chegue à escada, as mãos do Cão estão nos seus ombros.
# imagem: amanhecer
# musica: final_triste
Quando você abre os olhos, tem correntes nos pulsos, no telhado da cantina, olhando o céu do Bixiga ficar cor de laranja. É a última coisa que você vê.
FINAL D · SEM PROVAS. Você acusou o culpado sem ter como provar. # final: D
-> END

=== final_b ===
Dante: Você me serviu bem, forasteir{o}. Sua dívida está paga.
# imagem: cao_morto
# musica: final_verdade
O Cão é levado escada acima. Ao amanhecer, a cidade tem um novo Xerife, e o antigo vira cinza no telhado.
Os carniçais do Príncipe buscam o sarcófago no bunker antes do sol.
# imagem: van
Três noites depois, uma van preta sem placa estaciona no porto de Santos. Homens de terno e crachá carregam um sarcófago com um selo queimado.
Você foi a ferramenta da traição, e ainda não sabe.
Na saída, o Rayo segura o seu braço. Rayo: O Cão não fez isso sozinho, forasteir{o}. Alguém mandou ele esconder o caixão. Abre o olho.
Continua no capítulo 2.
FINAL B · A VERDADE PARA O PRÍNCIPE. Você acertou, quase morreu, e o Príncipe te protegeu. Por enquanto. # final: B
-> END

=== final_c_corte ===
Você: Antes, Príncipe, uma pergunta para a Corte. Por que a carga do Príncipe tinha carimbo do BOES no manifesto?
O salão inteiro vira para Dante.
{ p_informante: Você: O Biel, que vigiava a carga, era pago pela Dra. Elisa, da Segunda Inquisição. Os caçadores sabiam da rota e não interceptaram. Porque eram eles que iam receber. }
{ p_envelope: Você: E preso ao sarcófago tinha um envelope endereçado "À Doutora". A Dra. Elisa, da Segunda Inquisição. }
{ constance_aliada: Constance se levanta antes que alguém mande você calar a boca. Como prometeu. }
Constance: Príncipe. A Corte gostaria de ouvir a sua explicação.
Dante não explica. Pela primeira vez em cem anos, o Príncipe de São Paulo não tem o que dizer.
# imagem: trono_vazio
# musica: final_verdade
Antes do amanhecer, Constance convoca o Primogênito. Dante sai do Porão escoltado, pela escada dos fundos.
{ constance_hostil:
    Constance: Você tem faro, forasteir{o}. E pouco juízo. Não esqueci o que você tentou comigo esta noite.
    Constance: Fique na cidade. Prefiro você onde eu possa ver.
- else:
    Constance: Você tem faro, forasteir{o}. Fique na cidade. Eu vou precisar de gente que não tem amigos.
}
Na escada dos fundos, Dante para e olha para você. Não tem raiva no olhar dele. Tem paciência.
Continua no capítulo 2.
FINAL C · A VERDADE CONTRA O PRÍNCIPE · CONSTANCE # final: C
-> END

=== final_c_anarquistas ===
Você não diz nada sobre o carimbo. O Cão é levado. O Príncipe paga a sua dívida com um aceno.
Na saída, você para no balcão, ao lado do Rayo.
Você: Me dá o telefone de quem manda no seu motoclube. Tenho uma coisa que vai interessar.
{ p_informante: Você: E diz pra eles que o Biel era pago pela Segunda Inquisição. Eles vão querer saber quem mais é. }
Rayo: Você é louc{o}, forasteir{o}. Gostei.
# imagem: anarquistas
# musica: final_verdade
Na noite seguinte, cópias do manifesto com o carimbo do BOES aparecem coladas nos postes da Augusta. Os Anarquistas têm a prova de que o Príncipe negocia com caçadores.
A guerra que vem aí é sua também. E o Príncipe, que salvou a sua vida ontem, vai querer saber quem colou aqueles papéis.
Continua no capítulo 2.
FINAL C · A VERDADE CONTRA O PRÍNCIPE · ANARQUISTAS # final: C
-> END

=== final_nao_sei ===
Você: Eu não sei, Príncipe. Não tenho como afirmar quem foi.
O salão inteiro prende a respiração que ninguém ali precisa.
Dante: Uma resposta honesta. A primeira da noite.
Dante: Mas a sua dívida continua. E eu vou cobrá-la do único jeito de que um devedor não foge.
Ele corta o próprio pulso com a unha e estende o braço. Os carniçais seguram os seus ombros.
# musica: final_triste
Três noites, três goles. Na terceira, você já não lembra por que um dia quis ir embora de São Paulo. Você ama o Príncipe. Você sempre amou.
Embaixo dos trilhos da Linha Amarela, o sarcófago continua no escuro. Você nunca vai procurar. Ele não deixaria.
Continua no capítulo 2.
FINAL E · O SERVO DO PRÍNCIPE. Você não acusou ninguém e virou servo do Príncipe pelo Laço de Sangue. # final: E
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
