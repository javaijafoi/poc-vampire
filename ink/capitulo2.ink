// CAPÍTULO 2: O Custo do Esquecimento
//
// Três noites depois do Porão. Você acorda com uma noite faltando na memória e um chip de código de barras
// na língua. Na noite de gala da Corte, no Elísio do MASP, você descobre quem apagou a sua noite, e por quê.
// Resposta: a Luciana, a Senescal, para proteger o arquivo do Cão (a chantagem dele contra a Capela dela).
// O chip foi a Inquisição (o Agente Rocha), no porto. As duas coisas parecem uma só, e não são.
//
// Mecânicas novas:
//   Dentro do Elísio (salão do MASP) não vale Disciplina nem violência: o Dr. Arnaldo vê e põe você para fora.
//   Fora (vão livre, portaria, Paulista) vale tudo, mas o chip transmite: Disciplina sobe o Sinal em 2, briga em 1.
//   Sinal 5: o BOES chega.
//   Entrar ou sair do salão custa 20 minutos, passando pela portaria do Rocha.
//   O relógio começa às 19h (hora_base) no loft: olhar cada coisa custa 10 minutos. A gala abre às 22h; o sol nasce às 05h40.

// Estado do capítulo
VAR sinal = 0                 // o chip na língua: 0 a 5. No 5, o BOES chega
VAR sinal_explicado = false
VAR dentro = true             // você está no salão (true) ou do lado de fora (false)
VAR expulso = false           // o Dr. Arnaldo te pôs para fora do Elísio
VAR luciana_chegou = false
VAR c2_pode_entrar = true     // o Tomás, queimado e fugitivo, começa do lado de fora
VAR c2_bebeu_frasco = false
VAR aliado_cap2 = ""          // quem te protege no capítulo 3

// Pistas do capítulo 2
VAR p2_lama = false           // lama de esgoto nos seus sapatos
VAR p2_ligacao = false        // seu celular: chamada às 03h12 para um número sem nome
VAR p2_corte = false          // a memória foi cortada a sangue (ritual/Dominação), não por droga
VAR p2_scanner = false        // o segurança da porta tem um leitor que apita na sua boca
VAR p2_sedativo = false       // Rocha: o sedativo da Inquisição só derruba até as 2h
VAR p2_sinal_esgoto = false   // Rocha no rádio: o sinal do chip sumiu embaixo da terra, na Consolação
VAR p2_isa_lista = false      // Isadora: "só gente de bem foi à Capela" (mentira)
VAR p2_isa_ritual = false     // Isadora foi à Capela fazer um ritual de beleza (vaidade, não culpa)
VAR p2_numero = false         // o número do seu celular é o da Capela da Luciana
VAR p2_isa_capela = false     // Isadora: a Luciana saiu às 3h e voltou com a barra do vestido suja de esgoto
VAR p2_quem_apaga = false     // Arnaldo: só o Príncipe e a Senescal apagam uma noite inteira sem deixar buraco
VAR p2_arquivo = false        // Arnaldo: o Cão tinha um "seguro", um arquivo nos esgotos da Consolação
VAR p2_rocha_dante = false    // Arnaldo: o segurança humano foi posto ali por ordem de cima
VAR p2_luvas = false          // Valentina viu você às 4h com uma mulher de luvas
VAR p2_caixa = false          // os bichos da Paulista: a mulher de luvas voltou do esgoto com uma caixa
VAR p2_luciana_slip = false   // a Luciana falou dos esgotos da Consolação sem ninguém falar
VAR p2_luvas_cheiro = false   // as luvas da Luciana cheiram ao mesmo esgoto dos seus sapatos
VAR p2_constance_dica = false // Constance: a Senescal anda nervosa desde terça

// Estado das conversas
VAR isa_falou = false
VAR isa_fechada = false
VAR isa_varanda = false
VAR arn_falou = false
VAR rocha_falou = false
VAR rocha_fechado = false
VAR val_falou = 0
VAR val_bebeu = false
VAR luc_falou = false
VAR luc_fechada = false
VAR anfitriao_falou = false
VAR rayo2_falou = false
VAR c2_aviso = 0
VAR loft_bolsos = false
VAR loft_camisa = false
// Acusação do capítulo 2
VAR a2_sedativo = false
VAR a2_capela = false
VAR a2_luvas = false
VAR a2_arquivo = false
VAR a2_slip = false
VAR a2_numero = false
VAR a2_corte = false
VAR a2_lama = false
VAR a2_rocha = false
VAR a2_isadora = false

=== function acender(n) ===
~ sinal = MIN(sinal + n, 5)

// ------------------------------------------------------------------ ENTRADA
// Vem do fim do capítulo 1 (o jogo guarda o final em final_cap1).
=== capitulo_2 ===
# capitulo: 2
~ capitulo = 2
~ hora_base = 19
~ minutos = 0
~ limite = 640
~ fome = 2
~ quebrou_regra = 0
~ denunciado = false
~ poder_forte = false
~ besta_avisou = false
~ acusado = ""
~ provas_dadas = 0
~ provas_fortes = 0
~ provas_max = 3
{ final_cap1 == "":
    ~ final_cap1 = "B"
}
{ final_cap1 == "G":
    ~ fome = 3
    ~ c2_pode_entrar = false
}
-> loft

// Para quem não jogou o capítulo 1: escolhe o personagem e começa como se tivesse feito o final B.
=== capitulo_2_novo ===
~ final_cap1 = "B"
-> escolha_personagem(-> capitulo_2)

=== loft ===
# fundo: loft
# limpa
# musica: rua
{ final_cap1:
- "F": Você acorda num colchão de papelão, embaixo da galeria de esgoto do Bixiga, com a boca ardendo como se tivesse mastigado brasa.
- "G": Você acorda enterrad{o} até o peito num terreno baldio da Consolação, com a pele ainda repuxada das queimaduras e a boca ardendo como se tivesse mastigado brasa.
- else: Você acorda no chão do loft que o Príncipe te emprestou nos Jardins, de roupa, de sapato, com a boca ardendo como se tivesse mastigado brasa.
}
O sol acabou de se pôr: sete da noite. Três noites se passaram desde o Porão. Você lembra de duas. A terceira é um buraco liso, sem borda.
Você passa a língua nos dentes e sente um relevo. No espelho, embaixo da língua, tem uma tatuagem: um código de barras, fino, prateado. E por baixo da pele, uma coisa dura do tamanho de um grão de arroz.
Você tenta arrancar com a unha. A carne cede, o chip não. Está costurado por dentro, onde o seu sangue fecha tudo de novo. # pista loft: Um chip embaixo da língua, com um código de barras tatuado por cima. Não dá para arrancar.
O celular vibra no chão. Uma mensagem de voz, de agora há pouco.
{ final_cap1:
- "C_corte":
    Constance: Querid{o}. Na terça, alguém desceu ao esgoto da Consolação e levou uma coisa que a cidade inteira teme. Um Nosferatu jura que viu você saindo de um bueiro ali, às cinco da manhã, sujo até o joelho. # entra: constance # expr: seria
    Constance: Hoje, na gala, antes do sol, a Corte vai te perguntar o que você fez na terça. Eu presido. Não me faça passar vergonha.
    Constance: Ah, e o Dr. Arnaldo abre o museu às oito para quem tem contas a prestar. Quem chega antes da festa fala com o Juiz a sós.
- "C_anarq":
    Rayo: Ô, forasteir{o}. Tá todo mundo da Corte dizendo que você desceu no esgoto da Consolação na terça e saiu às cinco com alguma coisa deles. Um rato de terno jura que viu. # entra: rayo # expr: bravo
    Rayo: Eles vão te chamar na gala do MASP hoje, antes do sol, pra explicar. Se você não souber o que fez, eles inventam por você. E invenção de Camarilla acaba em estaca.
    Rayo: Dica de graça: o Juiz deles abre o museu às oito pra quem quer se explicar antes da festa. Depois disso, é na frente de todo mundo.
- "F":
    Arnaldo: Aqui é o Dr. Arnaldo, o Juiz do Elísio. Na terça, uma coisa que pertencia à Corte sumiu do esgoto da Consolação, e uma testemunha viu você saindo de um bueiro ali às cinco da manhã. # entra: arnaldo # expr: neutro
    Arnaldo: Hoje há gala no MASP. Antes do sol, a Corte vai querer saber o que você fez na terça. Recomendo vir com respostas. Quem não lembra, a Corte lembra por ele.
    Arnaldo: Eu abro o museu às oito. Se chegar antes disso, eu te ouço a sós. Depois, só na frente da Corte.
- "G":
    Arnaldo: Aqui é o Dr. Arnaldo, o Juiz do Elísio. Na terça, uma coisa que pertencia à Corte sumiu do esgoto da Consolação, e uma testemunha viu você saindo de um bueiro ali às cinco da manhã. # entra: arnaldo # expr: neutro
    Arnaldo: Hoje há gala no MASP. Antes do sol, a Corte vai querer saber o que você fez na terça. Recomendo vir com respostas. Quem não lembra, a Corte lembra por ele.
    Arnaldo: Eu abro o museu às oito. Se chegar antes disso, eu te ouço a sós. Depois, só na frente da Corte.
- else:
    Dante: Forasteir{o}. Na terça eu te mandei fazer um trabalho. Eu sei aonde te mandei. Não sei aonde você foi depois. # entra: dante # expr: calado
    Dante: Naquela madrugada, uma coisa que pertence à minha Corte sumiu do esgoto da Consolação, e um Nosferatu jura que viu você saindo de um bueiro ali às cinco da manhã. Hoje, na gala, antes do sol, você vai me dizer o que fez na terça. Se não souber, eu decido o que você fez.
    Dante: O Dr. Arnaldo, o meu Juiz, abre o museu às oito para quem tem contas a prestar. Se você chegar antes, ele te ouve a sós.
}
# limpa
Você não lembra de terça. E se você fez alguma coisa, a cidade inteira vai cobrar de você, não de quem mexeu na sua cabeça. # pista dossie: MISSÃO: descobrir o que você fez na terça, a noite apagada, e quem apagou ela. Ao amanhecer a Corte vai perguntar. Se você não souber responder, a Corte decide por você.
Você tem até o amanhecer para descobrir. Mas o Juiz só te ouve a sós se você chegar ao MASP até as oito. # pista dossie: O Dr. Arnaldo, o Juiz, recebe a sós no MASP até as 20h. Depois disso, só na gala, que abre às 22h.
-> loft_perguntas

=== loft_perguntas ===
{ minutos >= 20 and minutos < 30:
    {hora_falada()}. De carro, o MASP fica a meia hora daqui. Se quiser o Juiz a sós às oito, não dá para olhar tudo.
}
+ {not p2_lama} [Olhar os sapatos (10 minutos)]
    ~ p2_lama = true
    ~ passar(10)
    Os sapatos estão duros de lama preta. Não é barro de rua: cheira a esgoto velho e a ferro. # pista loft: Lama de esgoto nos seus sapatos. Você esteve embaixo da terra na noite apagada.
    -> loft_perguntas
+ {not p2_ligacao} [Ver o celular (10 minutos)]
    ~ p2_ligacao = true
    ~ passar(10)
    Na lista de chamadas, uma ligação sua de um minuto, às 03h12 da noite apagada, para um número sem nome. Ninguém atende quando você liga de novo. # pista loft: Às 03h12 da noite apagada você ligou para um número sem nome. Ninguém atende.
    -> loft_perguntas
+ {not loft_bolsos} [Revistar os bolsos (10 minutos)]
    ~ loft_bolsos = true
    ~ passar(10)
    No bolso do casaco, um papel úmido e amassado: um tíquete de estacionamento do porto de Santos, entrada às 22h40 da noite apagada. Saída, nenhuma. # pista loft: Um tíquete de estacionamento do porto de Santos: você entrou lá às 22h40 da noite apagada e não há saída marcada.
    -> loft_perguntas
+ {not loft_camisa} [Olhar a camisa no espelho (10 minutos)]
    ~ loft_camisa = true
    ~ passar(10)
    A gola da camisa está dura de sangue seco. Não é seu. Cheira a óleo diesel e maresia, e tem um gosto amargo quando você lambe o dedo, como remédio. # pista loft: Sangue seco na gola da camisa, que não é seu: cheira a diesel e maresia e tem gosto amargo de remédio.
    -> loft_perguntas
+ {ocultismo >= 2} {not p2_corte} [Ocultismo 2 :: Examinar o buraco na sua memória. (10 minutos)]
    ~ p2_corte = true
    ~ passar(10)
    Ocultismo 2 :: Droga deixa a memória borrada, como vidro embaçado. A sua não está borrada. Está cortada, reta, como papel cortado com régua. Isso é sangue. Dominação ou ritual. # pista loft: A sua noite não foi apagada por droga. Foi cortada a sangue, por Dominação ou ritual.
    -> loft_perguntas
+ {tem_frasco} {not c2_bebeu_frasco} [Frasco :: Beber uma gota do sangue do Matusalém. (10 minutos)]
    ~ c2_bebeu_frasco = true
    ~ passar(10)
    ~ fome = 1
    ~ p2_luvas = true
    ~ p2_caixa = true
    Uma gota só, na ponta da língua, em cima do chip. O sangue é tão velho que tem gosto de pedra.
    Por um segundo você vê a noite apagada: um corredor de esgoto, uma lanterna, uma mulher de luvas pretas tirando uma caixa de metal de um nicho na parede. Ela se vira para você, e a imagem se rasga. # pista loft: O sangue do Matusalém mostrou um pedaço da noite: uma mulher de luvas pretas tirando uma caixa de metal de um nicho no esgoto.
    A Fome se deita, quieta, como um cachorro que ouviu o dono.
    -> loft_perguntas
+ [Ler o convite]
    -> convite

=== convite ===
{ final_cap1:
- "C_corte":
    No chão, um envelope cor-de-rosa passado por baixo da porta. "Gala da Corte, Elísio do MASP, dez horas. Agora a cidade tem uma Primogenitura que manda. Venha. C."
- "C_anarq":
    O celular vibra. Mensagem do Rayo: "Festa dos engravatados no MASP hoje. Te ponho pra dentro pela porta dos fundos. Alguém da Corte anda perguntando por você."
- "F":
    Pela grade do esgoto, você ouve dois ratos de terno falando da gala da Corte no MASP, hoje às dez. Uma morta pode entrar onde quiser, se ninguém olhar para ela.
- "G":
    Um panfleto molhado colado no muro do terreno: a gala da Corte, no MASP, hoje. Você não foi convidad{o}. Você é cinza num telhado, para o Príncipe.
- else:
    No chão, um envelope de papel grosso com lacre de cera azul. "Gala da Corte, Elísio do MASP, dez horas. Você me deve uma noite de trabalho bem feito. Venha. D."
}
Quem apagou a sua noite vai estar lá. Todo mundo que importa vai estar lá.
-> trajeto

// O caminho até o MASP: uma animação de mapa (tag # trajeto: origem modo minutos) no lugar do corte seco.
=== trajeto ===
# limpa
{ final_cap1:
- "F":
    Você sobe pela galeria do Bixiga até a grade da Treze de Maio e sai na rua de cabeça baixa, junto com o vapor do bueiro.
    ~ passar(40)
    A cidade passa por você, acesa, molhada, cheia de gente viva que não sabe de nada. Lá no alto, o MASP aparece vermelho em cima da Paulista. # fundo: vao_livre # trajeto: bixiga pe 40
- "G":
    Você sacode a terra do corpo e sobe a Consolação a pé, pelo lado escuro da calçada, com o capuz puxado sobre as queimaduras.
    ~ passar(40)
    A cidade passa por você, acesa, molhada, cheia de gente viva que não sabe de nada. Lá no alto, o MASP aparece vermelho em cima da Paulista. # fundo: vao_livre # trajeto: consolacao pe 40
- "C_anarq":
    O Rayo buzina lá embaixo. Você sobe na garupa da moto e ele corta os Jardins pela Augusta, rindo de cada sinal vermelho.
    ~ passar(20)
    A cidade passa de lado, acesa, molhada, cheia de gente viva que não sabe de nada. Lá no alto, o MASP aparece vermelho em cima da Paulista. # fundo: vao_livre # trajeto: jardins moto 20
- else:
    Você desce, chama um táxi e manda subir a Augusta. O motorista olha você pelo retrovisor e não puxa assunto.
    ~ passar(30)
    A cidade passa pela janela, acesa, molhada, cheia de gente viva que não sabe de nada. Lá no alto, o MASP aparece vermelho em cima da Paulista. # fundo: vao_livre # trajeto: jardins taxi 30
}
{ minutos <= 60: -> juiz_cedo }
{ minutos < 180:
    ~ minutos = 180
    Você chega cedo e espera no vão livre, encostad{o} num pilar, até as portas abrirem às dez.
}
-> chegada

// Quem sai cedo do loft (chega até as 20h) fala com o Juiz a sós: ganha duas pistas, mas deixou coisas sem olhar.
=== juiz_cedo ===
# fundo: vao_livre
O museu ainda está escuro. Só uma porta lateral aberta, e um homem de terno cinza esperando nela, como quem espera um réu. # entra: arnaldo
Arnaldo: Pontual. Isso conta a seu favor. Fale. # expr: vigia
Você conta o que tem: o chip, a noite que falta, a mensagem.
~ p2_quem_apaga = true
~ p2_rocha_dante = true
~ arn_falou = true
Arnaldo: Apagar a noite de um convidado do Príncipe é crime contra a hospitalidade. E poucos sabem fazer sem deixar buraco. O Príncipe. A Senescal. # pista arnaldo: Arnaldo, a sós: só o Príncipe e a Senescal apagam uma noite inteira sem deixar buraco.
Arnaldo: Mais uma coisa. Hoje vai ter um segurança humano na porta, posto ali por ordem de cima. Eu não gosto disso. Fique de olho nele. # expr: aponta # pista arnaldo: Arnaldo, a sós: o segurança humano da porta foi posto ali "por ordem de cima". Ele não gosta disso.
Arnaldo: Até a gala, eu não te vi. Na gala, eu vejo tudo. # expr: neutro
~ minutos = 180
# limpa
Você espera no vão livre, encostad{o} num pilar, até as portas abrirem às dez.
-> chegada

=== chegada ===
# fundo: vao_livre
# musica: rua
O MASP flutua em cima do vão livre, vermelho, sustentado no ar. Embaixo, na Paulista, a cidade ainda acorda para a noite.
Na porta lateral, um segurança de terno preto, crachá e ponto no ouvido confere os convidados com um leitor na mão. # entra: rocha
Quando você passa, o leitor apita. Ele não olha para o seu convite. Olha para a sua boca. # expr rocha: sorriso
Rocha: Boa festa. Não suma de novo. # pista rocha: O segurança da porta tem um leitor que apitou quando você passou. Ele olhou para a sua boca e disse "não suma de novo".
~ p2_scanner = true
Elísio :: Lá dentro vale a lei do Elísio: nada de Disciplina, nada de violência, e o Dr. Arnaldo, o Juiz, vê tudo. Aqui fora, no vão livre e na Paulista, pode tudo. Mas o chip na sua língua escuta.
{ not c2_pode_entrar:
    O salão é para quem tem convite. Você fica do lado de fora, no vão livre, vendo os vestidos subirem a escada.
    ~ dentro = false
    -> fora
}
{ final_cap1 == "F": Você entra atrás de uma bandeja de taças, de avental, com a cara de ninguém. Quem serve não é convidada. Quem serve não é vista. }
{ final_cap1 == "C_anarq": O Rayo te põe para dentro pela porta da cozinha e fica lá fora, encostado na moto. }
-> salao2

// ------------------------------------------------------------------ AVISOS (hora, chegada da Luciana)
=== avisos2 ===
{ minutos >= 390 and not luciana_chegou:
    ~ luciana_chegou = true
    { expulso or not dentro:
        Lá em cima, pelo vidro do museu, você vê a gala parar. Uma mulher de cabelo curto, vestido escuro e luvas pretas sobe a escada. A Senescal chegou. # pista dossie: À {hora_digital()} a Luciana, a Senescal, chegou à gala.
    - else:
        A música para meio compasso. Uma mulher de cabelo curto, vestido escuro e luvas pretas atravessa o salão sem cumprimentar ninguém. A Senescal chegou. # pista dossie: À {hora_digital()} a Luciana, a Senescal, chegou à gala. Ela usa luvas pretas.
    }
}
{ minutos >= 480 and c2_aviso < 1:
    ~ c2_aviso = 1
    {hora_falada()}. Os primeiros convidados começam a ir embora. Metade da noite já foi.
}
{ minutos >= 570 and c2_aviso < 2:
    ~ c2_aviso = 2
    {hora_falada()}. Os garçons recolhem as taças. Faltam {tempo_falta()} para o sol.
}
->->

// ------------------------------------------------------------------ DENTRO: O SALÃO DO ELÍSIO
=== salao2 ===
# fundo: gala
# limpa
~ dentro = true
{ minutos >= limite: -> amanhecer2 }
-> avisos2 ->
{ fome >= 4 and not besta_avisou:
    ~ besta_avisou = true
    Fome {fome} :: Você ouve o coração de cada garçom do salão. Aqui dentro, uma mordida é crime. Lá fora, na Paulista, a cidade está cheia de pescoço.
}
Quem você procura no salão?
+ {not isa_fechada} [Isadora, a anfitriã, no meio do salão]
    -> isadora
+ [Dr. Arnaldo, o Juiz, perto dos cavaletes de vidro]
    -> arnaldo
+ {luciana_chegou} {not luc_fechada} [Luciana, a Senescal, sozinha perto da janela]
    -> luciana
+ {final_cap1 != "C_anarq"} {final_cap1 != "F"} {not anfitriao_falou} [{final_cap1 == "C_corte":A Constance, que te convidou|O Príncipe Dante, que te convidou}]
    -> anfitriao
+ {disciplina == "Ofuscação"} {luciana_chegou} {not p2_luciana_slip} [Disciplina: Ofuscação :: Sumir na sombra da janela e ouvir a Luciana. (O Dr. Arnaldo está olhando.)]
    -> ofuscacao_dentro
+ {disciplina == "Animalismo"} {not p2_arquivo} [Disciplina: Animalismo :: Chamar o rato que mora no forro do museu. (O Dr. Arnaldo está olhando.)]
    -> animalismo_dentro
+ {disciplina == "Presença"} {not isa_fechada} {not p2_isa_capela} [Disciplina: Presença :: Fazer a Isadora se apaixonar por você em público. (O Dr. Arnaldo está olhando.)]
    -> presenca_dentro
+ [Descer para o vão livre (20 minutos, pela portaria)]
    ~ passar(20)
    ~ dentro = false
    -> fora
+ [Chamar quem preside a Corte e contar o que você fez na terça (encerra o capítulo)]
    -> confirmar_acusacao2

=== confirmar_acusacao2 ===
Você tem @pistas no caderno. Faltam {tempo_falta()} para o amanhecer. Depois que a Corte ouvir, o capítulo acaba. Não tem volta.
{ not isa_falou or not arn_falou or not rocha_falou or val_falou == 0 or not luc_falou:
    Ainda não ouvi :: {not isa_falou: · a Isadora}{not arn_falou: · o Dr. Arnaldo}{not rocha_falou: · o segurança da porta}{val_falou == 0: · a Valentina, na Paulista}{luciana_chegou and not luc_falou: · a Luciana}{not luciana_chegou: · a Senescal, que ainda não chegou}
}
+ [Sim. Agora.]
    -> acusacao2
+ [Ainda não.]
    { dentro and not expulso: -> salao2 }
    -> fora

// Disciplina dentro do Elísio: dá a pista, mas o Juiz vê e põe você para fora.
=== ofuscacao_dentro ===
~ passar(20)
~ despertar()
~ p2_luciana_slip = true
Você deixa de ser vista no vão da cortina. A Luciana fala baixo ao celular, de costas para o salão.
Luciana: ...está comigo. A caixa toda. Ninguém abre aquilo enquanto eu existir. E {o == "a":a|o} forasteir{o} não vai lembrar. Eu garanti. # pista luciana: Escondid{o}, você ouviu a Luciana ao telefone: "A caixa toda está comigo. {o == "a":A|O} forasteir{o} não vai lembrar. Eu garanti."
-> arnaldo_viu

=== animalismo_dentro ===
~ passar(20)
~ despertar()
~ p2_arquivo = true
~ p2_caixa = true
Um rato desce pelo cabo de um cavalete de vidro e para no seu sapato. Ele cheira a lama dos seus sapatos e reconhece.
Na língua dos bichos, ele conta: a galeria embaixo da Consolação, o nicho na parede, a caixa de metal do homem de olho amarelo. Uma mulher de luvas levou a caixa. Você estava lá, de pé, sem piscar. # pista bar: O rato do museu: a caixa de metal do Cão ficava num nicho no esgoto da Consolação. Uma mulher de luvas levou. Você estava lá, de pé, sem piscar.
-> arnaldo_viu

=== presenca_dentro ===
~ passar(20)
~ despertar()
~ p2_isa_capela = true
Você deixa a Presença escorrer pelo salão. A Isadora se vira para você como uma flor vira para o sol.
Isadora: Você é a única pessoa interessante desta festa. Quer um segredo? A Luciana cancelou a minha sessão na Capela naquela noite, às três. E voltou de madrugada com a barra do vestido suja de esgoto. Ela, que não pisa em poça. # entra: isadora # expr: cochicho # pista isadora: Isadora: a Luciana cancelou a sessão dela na Capela às três da noite apagada e voltou com a barra do vestido suja de esgoto.
-> arnaldo_viu

=== arnaldo_viu ===
~ quebrou_regra += 1
~ expulso = true
~ dentro = false
# limpa
Uma mão seca pousa no seu ombro. # entra: arnaldo # expr: aponta
Arnaldo: No meu Elísio, não. Nem uma gota. Você sabe a regra, e eu sei o que vi.
Arnaldo: Para fora. Esta noite você não sobe mais esta escada. E o Príncipe vai saber.
Dois carniçais te acompanham até o vão livre. O segurança da porta sorri quando você passa. # expr rocha: sorriso
-> fora

// ------------------------------------------------------------------ FORA: VÃO LIVRE E PAULISTA
=== fora ===
# fundo: vao_livre
# limpa
~ dentro = false
{ sinal >= 5: -> boes }
{ minutos >= limite: -> amanhecer2 }
-> avisos2 ->
{ sinal > 0 and not sinal_explicado:
    ~ sinal_explicado = true
    Sinal {sinal} :: O chip esquenta embaixo da sua língua, como uma moeda deixada no sol. Cada vez que você usa Disciplina aqui fora, ele transmite. Se esquentar demais, alguém vem buscar.
}
Para onde você vai?
+ [O segurança da portaria]
    -> rocha
+ [A Valentina, na calçada da Paulista, com o rebanho dela]
    -> valentina
+ {final_cap1 == "C_anarq"} {not rayo2_falou} [O Rayo, encostado na moto]
    -> rayo2
+ {luciana_chegou} {expulso} {not luc_fechada} [A Luciana, que desceu para atender o celular no vão livre]
    -> luciana
+ {isa_falou} {not isa_varanda} {not isa_fechada} {not expulso} [Chamar a Isadora para a varanda, longe do Juiz]
    -> isadora_varanda
+ {not expulso} {c2_pode_entrar} [Subir para o salão (20 minutos, pela portaria)]
    ~ passar(20)
    -> salao2
+ {not c2_pode_entrar} {val_falou >= 1} [Entrar com a Valentina, como parte do rebanho dela]
    ~ passar(20)
    ~ c2_pode_entrar = true
    Valentina: Cabeça baixa e sorriso bobo, querid{o}. Você é meu acompanhante. # entra: valentina # expr: rindo
    -> salao2
+ [Chamar quem preside a Corte e contar o que você fez na terça (encerra o capítulo)]
    -> confirmar_acusacao2

=== boes ===
# limpa
# musica: final_triste
O chip não esquenta mais. Ele queima. Você sente o gosto de metal derretido na boca.
Na Paulista, três vans pretas param ao mesmo tempo, uma em cada faixa. Homens de colete e capacete descem com lanternas de luz branca, quente como sol de meio-dia.
# imagem: van
O BOES não pergunta nada. Ele sabe exatamente onde você está. Ele sempre soube.
Você corre para o vão livre. A luz te alcança no meio do caminho.
FINAL 2X · O SINAL. Você usou Disciplina demais com o chip na língua, e a Inquisição veio buscar a isca. # final: 2X
-> END

// ------------------------------------------------------------------ ISADORA (dentro)
=== isadora ===
# fundo: gala
# entra: isadora
{ not isa_falou: A Isadora gira no meio do salão, taça na mão, vestido preto que abre como uma flor. Todos olham para ela, e ela sabe. }
~ isa_falou = true
-> isadora_perguntas

=== isadora_perguntas ===
{ minutos >= limite: -> amanhecer2 }
-> avisos2 ->
+ {not p2_isa_lista} [Quem esteve na Capela da Luciana nesta semana?]
    ~ passar(20)
    ~ p2_isa_lista = true
    Isadora: Na Capela? Só gente de bem, querid{o}. O Príncipe, eu mesma. Ninguém mais. # expr: ofendida # pista isadora: Isadora: "Na Capela, esta semana, só o Príncipe e eu."
    Ela responde rápido, e não olha para você.
    -> isadora_perguntas
+ {p2_isa_lista} {not p2_isa_ritual} [O que a senhora foi fazer na Capela?]
    ~ passar(20)
    ~ p2_isa_ritual = true
    Isadora: Isso é pergunta que se faça a uma dama? # expr: ofendida
    Isadora: ...Um ritual de beleza. A Luciana sabe deixar uma Toreador mais Toreador. Você não vai contar a ninguém, vai? # expr: cochicho # pista isadora: A Isadora foi à Capela fazer um ritual de beleza. É vaidade, e ela tem vergonha.
    -> isadora_perguntas
+ {p2_ligacao} {not p2_numero} [Prova :: Ligação: de quem é este número, que eu liguei às 03h12?]
    ~ passar(20)
    ~ p2_numero = true
    ~ p2_isa_capela = true
    Você mostra o celular. Ela ri, e para de rir.
    Isadora: É o número da Capela, querid{o}. Todo mundo que é alguém tem. # expr: cochicho # pista isadora: O número para o qual você ligou às 03h12 é o da Capela da Luciana.
    Isadora: Engraçado. Foi desse número que a Luciana me ligou às três para cancelar a minha sessão. Ela disse que tinha uma emergência. E voltou de madrugada com a barra do vestido suja de esgoto. Ela, que não pisa em poça. # pista isadora: Isadora: a Luciana cancelou a sessão dela às três da noite apagada e voltou de madrugada com a barra do vestido suja de esgoto.
    -> isadora_perguntas
+ {not p2_isa_capela} {not isa_fechada} {fome < 5} [Teste: Carisma + Persuasão, dif. 3 :: Elogiar a festa como ela gosta.]
    ~ passar(20)
    Você: Eu já fui a festas em três cidades. Nenhuma tinha uma anfitriã como esta.
    ~ temp r = rolar(carisma + 1, fome, 3)
    { r == 1 or r == 2 or r == 3:
        ~ p2_isa_capela = true
        Isadora: Ah, finalmente alguém com olhos. Vou te dar um presente, então. # expr: vaidosa
        Isadora: A Luciana cancelou a minha sessão na Capela naquela noite, às três. E voltou de madrugada com a barra do vestido suja de esgoto. # expr: cochicho # pista isadora: Isadora: a Luciana cancelou a sessão dela às três da noite apagada e voltou de madrugada com a barra do vestido suja de esgoto.
    - else:
        ~ isa_fechada = true
        Isadora: Três cidades? Que provinciano. Com licença. # expr: ofendida
        Ela gira e vai embora, e você deixa de existir para ela.
        -> salao2
    }
    -> isadora_perguntas
+ {cla == "Ministério"} {not p2_isa_capela} [Ministério :: Oferecer a ela um segredo de beleza da Serpente.]
    ~ passar(20)
    ~ p2_isa_capela = true
    Você: O Ministério conhece banhos de sangue que a Capela nem imagina. Eu ensino um. Em troca de uma fofoca.
    Isadora: ...Fechado. A Luciana cancelou a minha sessão naquela noite, às três. E voltou com a barra do vestido suja de esgoto. # expr: cochicho # pista isadora: Isadora: a Luciana cancelou a sessão dela às três da noite apagada e voltou de madrugada com a barra do vestido suja de esgoto.
    -> isadora_perguntas
+ [Voltar ao salão]
    -> salao2

// Na varanda, fora do Elísio: vale apertar, mas a Isadora sabe que você a tirou da proteção.
=== isadora_varanda ===
~ passar(20)
~ isa_varanda = true
# fundo: vao_livre
# entra: isadora
Você leva a Isadora até a varanda, longe do Juiz. Ela percebe tarde, no último degrau.
Isadora: Aqui fora não é Elísio, querid{o}. O que você quer? # expr: medo
+ {not p2_isa_capela} [Teste: Força + Intimidação, dif. 3 :: Encostar ela no parapeito.]
    ~ acender(1)
    ~ temp r = rolar(intimidacao, fome, 3)
    { r == 1 or r == 2 or r == 3:
        ~ p2_isa_capela = true
        Isadora: Solta! A Luciana. Foi a Luciana. Ela cancelou a minha sessão às três e voltou suja de esgoto. Satisfeit{o}? # expr: medo # pista isadora: Isadora, apertada na varanda: a Luciana cancelou a sessão dela às três da noite apagada e voltou suja de esgoto.
    - else:
        Isadora: Socorro! # expr: medo
        Ela grita, e o salão inteiro ouve. Com você, ela não fala mais.
    }
    ~ isa_fechada = true
    -> fora
+ [Deixar ela voltar. Não vale o escândalo.]
    Isadora: Sábia decisão. # expr: ofendida
    -> fora

// ------------------------------------------------------------------ DR. ARNALDO (dentro)
=== arnaldo ===
# fundo: gala
# entra: arnaldo
{ not arn_falou: Entre os cavaletes de vidro do acervo, o Dr. Arnaldo observa o salão com as mãos para trás. Ninguém fica perto dele por muito tempo. }
~ arn_falou = true
-> arnaldo_perguntas

=== arnaldo_perguntas ===
{ minutos >= limite: -> amanhecer2 }
-> avisos2 ->
+ {not p2_quem_apaga} [Quem nesta cidade consegue apagar uma noite inteira de alguém?]
    ~ passar(20)
    ~ p2_quem_apaga = true
    Arnaldo: Apagar uma noite de um convidado do Príncipe é crime contra a hospitalidade. Eu enforco gente por menos.
    Arnaldo: E poucos sabem fazer sem deixar buraco. O Príncipe. A Senescal. Nenhum dos dois vai admitir. # pista arnaldo: Arnaldo: só o Príncipe e a Senescal apagam uma noite inteira sem deixar buraco.
    -> arnaldo_perguntas
+ {p2_lama} {not p2_arquivo} [Prova :: Lama: eu estive no esgoto naquela noite. O que tem lá embaixo?]
    ~ passar(20)
    ~ p2_arquivo = true
    Arnaldo: Esgoto é território de Nosferatu. E de um Xerife que não está mais entre nós.
    Arnaldo: O Cão tinha um seguro. Um arquivo, numa galeria embaixo da Consolação. Se ele caísse, os segredos de alguém iam para a rua. # pista arnaldo: Arnaldo: o Cão tinha um "seguro", um arquivo numa galeria embaixo da Consolação. Se ele caísse, os segredos de alguém iam para a rua.
    Arnaldo: Pergunte a quem ficou mais aliviad{o} quando ele caiu. Não fui eu.
    -> arnaldo_perguntas
+ {p2_scanner} {not p2_rocha_dante} [O segurança da porta é humano. Quem pôs ele ali?]
    ~ passar(20)
    ~ p2_rocha_dante = true
    Arnaldo: Eu sei que é humano. Senti o cheiro quando ele chegou. # expr: vigia
    Arnaldo: Ordem de cima. E eu não discuto ordem de cima no meio de uma gala. # pista arnaldo: Arnaldo: o segurança humano da porta foi posto ali "por ordem de cima".
    -> arnaldo_perguntas
+ {p2_corte} {not p2_quem_apaga} [Prova :: Corte: a minha memória foi cortada a sangue, não por droga.]
    ~ passar(20)
    ~ p2_quem_apaga = true
    Arnaldo: Então alguém cometeu um crime no seu crânio. Poucos sabem cortar tão reto. O Príncipe. A Senescal. # pista arnaldo: Arnaldo: só o Príncipe e a Senescal apagam uma noite inteira sem deixar buraco.
    -> arnaldo_perguntas
+ [Voltar ao salão]
    -> salao2

// ------------------------------------------------------------------ O ANFITRIÃO (Dante ou Constance)
=== anfitriao ===
~ passar(20)
~ anfitriao_falou = true
{ final_cap1 == "C_corte":
    # entra: constance
    Constance: Você veio. Ótimo. A cidade mudou de mãos e ainda tem gente se acostumando.
    Constance: Um conselho de graça: a Senescal anda nervosa desde terça. Uma Tremere nervosa é uma Tremere que perdeu alguma coisa. # pista constance: Constance: a Senescal anda nervosa desde terça, como quem perdeu alguma coisa.
    ~ p2_constance_dica = true
- else:
    # entra: dante
    Dante: Você fez um trabalho para mim na terça, forasteir{o}. A primeira parte, fez bem. Não me pergunte qual. O resto da noite, você me conta antes do sol. # expr: neutro
    Você: Eu não lembro de terça.
    Dante: Melhor assim. # expr: calado # pista dossie: O Príncipe diz que você fez um trabalho para ele na terça, a noite apagada. Ele não quis dizer qual.
    { constance_aliada:
        Do outro lado do salão, a Constance ergue a taça para você. Ela lembra do Porão. # entra: constance
        Constance: A Senescal anda nervosa desde terça, querid{o}. Uma Tremere nervosa perdeu alguma coisa. # pista constance: Constance: a Senescal anda nervosa desde terça, como quem perdeu alguma coisa.
        ~ p2_constance_dica = true
    }
}
-> salao2

// ------------------------------------------------------------------ AGENTE ROCHA (portaria, fora)
=== rocha ===
# fundo: vao_livre
# entra: rocha
{ rocha_fechado:
    Rocha: Circulando. # expr: radio
    -> fora
}
{ not rocha_falou: O segurança não tira os olhos da sua boca. O leitor dele pisca uma luz verde, devagar, como um coração. }
~ rocha_falou = true
-> rocha_perguntas

=== rocha_perguntas ===
{ sinal >= 5: -> boes }
{ minutos >= limite: -> amanhecer2 }
-> avisos2 ->
+ {not p2_sedativo} [O que tem na minha língua?]
    ~ passar(20)
    Rocha: Um presente. Você estava no porto na terça, meio dormindo. Bebeu do pescoço errado. # expr: sorriso
    Rocha: O resto é confidencial.
    -> rocha_perguntas
+ {not p2_sedativo} {not rocha_fechado} {fome < 5} [Teste: Manipulação + Subterfúgio, dif. 3 :: Blefar: "A Doutora já me contou. Só quero ouvir de você."]
    ~ passar(20)
    ~ temp r = rolar(manipulacao + subterfugio, fome, 3)
    {
    - r == 1 or r == 2 or r == 3:
        -> rocha_conta
    - r == 4:
        A Besta sobe e você mostra as presas para um humano, na porta do Elísio.
        ~ acender(1)
        ~ rocha_fechado = true
        Rocha: Isso foi gravado. Obrigado. # expr: radio
        -> fora
    - else:
        Rocha: A Doutora não conta nada pra ninguém. Boa tentativa. # expr: sorriso
        ~ rocha_fechado = true
        -> fora
    }
+ {not p2_sedativo} [Teste: Força + Intimidação, dif. 4 :: Prensar o humano na pilastra.]
    ~ passar(20)
    ~ acender(1)
    ~ temp ri = rolar(intimidacao, fome, 4)
    { ri == 1 or ri == 2 or ri == 3:
        -> rocha_conta
    - else:
        Ele não tem medo. Ele aperta o ponto no ouvido e fala uma palavra que você não entende. O chip esquenta. # expr: radio
        ~ acender(1)
        ~ rocha_fechado = true
        -> fora
    }
+ {disciplina == "Presença"} {not p2_sedativo} [Disciplina: Presença :: Encantar o humano. (O chip vai transmitir.)]
    ~ passar(20)
    ~ despertar()
    ~ acender(2)
    Ele é treinado para tudo, menos para gostar de você. O rosto dele amolece.
    -> rocha_conta
+ {disciplina == "Ofuscação"} {not p2_sinal_esgoto} [Disciplina: Ofuscação :: Sumir e ouvir o rádio dele. (O chip vai transmitir.)]
    ~ passar(20)
    ~ despertar()
    ~ acender(2)
    ~ p2_sedativo = true
    ~ p2_sinal_esgoto = true
    Você some. Ele pisca, olha para o leitor, e o leitor ainda mostra você ali, a dois metros. Ele fala baixo no rádio.
    Rocha: A isca está no MASP, Doutora. O sedativo segurou até as duas da manhã de terça, como previsto. Depois disso o sinal desceu para baixo da terra, na Consolação, e só voltou às cinco. Não fomos nós. # expr: radio # pista rocha: Rocha, no rádio: o sedativo da Inquisição só segurou você até as 2h. Depois disso o sinal do chip desceu para o esgoto da Consolação e voltou às 5h. "Não fomos nós."
    -> fora
+ [Voltar ao vão livre]
    -> fora

=== rocha_conta ===
~ p2_sedativo = true
Rocha: Tá. Sedativo na veia do estivador que você mordeu no porto. Derruba vampiro por duas horas, certinho. A Doutora aproveitou para pôr o brinquedo. # expr: sorriso
Rocha: Você acordou às duas e saiu andando. O resto da sua noite não é com a gente. A gente também queria saber onde você foi. # pista rocha: Rocha: o sedativo da Inquisição só segurou você até as 2h; o chip foi posto no porto. O resto da noite "não é com a gente".
-> rocha_perguntas

// ------------------------------------------------------------------ VALENTINA (Paulista, fora)
=== valentina ===
# fundo: paulista
# entra: valentina
{ val_falou == 0: Na calçada da Paulista, a Valentina passeia de braço dado com um rapaz que sorri demais. O rebanho dela. Ela te vê e levanta a taça. }
-> valentina_perguntas

=== valentina_perguntas ===
{ sinal >= 5: -> boes }
{ minutos >= limite: -> amanhecer2 }
-> avisos2 ->
+ {val_falou == 0} [Você me viu na terça à noite?]
    ~ passar(20)
    ~ val_falou = 1
    Valentina: Eu vejo muita gente, querid{o}. Vejo tanta gente que nem lembro. # expr: rindo
    -> valentina_perguntas
+ {val_falou == 1} {not p2_luvas} [Insistir: "Pensa bem. Terça. Aqui na Paulista."]
    ~ passar(20)
    ~ val_falou = 2
    Valentina: Você é insistente. Gosto disso. Terça... não, não lembro. # expr: rindo
    -> valentina_perguntas
+ {val_falou >= 1} {p2_lama} {not p2_luvas} [Prova :: Lama: eu voltei do esgoto naquela noite. Alguém me viu sair.]
    ~ passar(20)
    -> valentina_conta
+ {val_falou == 2} {not p2_luvas} [Insistir mais uma vez: "Valentina. Por favor."]
    ~ passar(20)
    -> valentina_conta
+ {disciplina == "Animalismo"} {not p2_caixa} [Disciplina: Animalismo :: Perguntar aos pombos e aos ratos da Paulista. (O chip vai transmitir.)]
    ~ passar(20)
    ~ despertar()
    ~ acender(2)
    ~ p2_luvas = true
    ~ p2_caixa = true
    Você chama, baixo. Os pombos das marquises descem, os ratos sobem das grades. Todos viram você na terça.
    Uma mulher de luvas pretas te levou pela grade do esgoto da Consolação às três e pouco. Às cinco, ela te trouxe de volta, e carregava uma caixa de metal debaixo do braço. # pista valentina: Os bichos da Paulista: às três uma mulher de luvas pretas te levou pela grade do esgoto da Consolação. Às cinco ela te trouxe de volta, com uma caixa de metal.
    -> valentina_perguntas
+ {fome >= 3} {not val_bebeu} [Fome {fome} :: Aceitar um gole do rebanho dela.]
    ~ passar(20)
    ~ val_bebeu = true
    ~ fome = MAX(fome - 2, 1)
    Valentina: Só um gole. Ele é meu. # expr: rindo
    O rapaz sorri o tempo todo. Ele nem sente.
    -> valentina_perguntas
+ [Voltar ao vão livre]
    -> fora

=== valentina_conta ===
~ p2_luvas = true
~ val_falou = 2
Valentina: ...Tá. Eu vi. Às quatro, mais ou menos. Você andava como sonâmbul{o}, de braço dado com uma mulher de luvas pretas e casaco escuro. # expr: assustada
Valentina: Pensei que era encontro. Ela olhou para mim e eu... achei melhor esquecer. Com aquela lá, a gente acha melhor esquecer. # pista valentina: Valentina viu você às 4h da noite apagada, andando como sonâmbul{o}, de braço dado com uma mulher de luvas pretas.
-> valentina_perguntas

// ------------------------------------------------------------------ RAYO (fora, só no caminho dos Anarquistas)
=== rayo2 ===
~ passar(20)
~ rayo2_falou = true
# fundo: vao_livre
# entra: rayo
Rayo: E aí, descobriu quem mexeu na sua cabeça? # expr: sorriso
Rayo: Fica de olho na Toreador de vermelho, a Valentina. Ela caça na Paulista toda noite. Se alguém te viu, foi ela. E ela finge que não lembra de nada. # pista dossie: Rayo: a Valentina caça na Paulista toda noite. Se alguém te viu, foi ela, e ela finge que não lembra.
-> fora

// ------------------------------------------------------------------ LUCIANA (chega à 01h30)
=== luciana ===
{ expulso:
    # fundo: vao_livre
- else:
    # fundo: gala
}
# entra: luciana
{ not luc_falou: A Luciana não bebe nem dança. Tira e põe uma luva, devagar, olhando a Paulista lá embaixo. }
~ luc_falou = true
-> luciana_perguntas

=== luciana_perguntas ===
{ minutos >= limite: -> amanhecer2 }
-> avisos2 ->
+ [Boa noite, Senescal.]
    ~ passar(20)
    Luciana: Você parece cansad{o}. Noites mal dormidas? # expr: fria
    { final_cap1 == "F": Ela demora um segundo a mais olhando para o seu rosto. Para a cidade, você era uma morta nos esgotos. Ela não pergunta nada. Isso também é uma resposta. }
    -> luciana_perguntas
+ [Onde a senhora estava na madrugada de terça?]
    ~ passar(20)
    Luciana: Na Capela, trabalhando, como toda noite. A cidade não se protege sozinha. # expr: fria
    -> luciana_perguntas
+ {p2_arquivo} {not p2_luciana_slip} [Prova :: Arquivo: o que a senhora sabe do seguro do Cão?]
    ~ passar(20)
    ~ p2_luciana_slip = true
    Luciana: Aquele lixo embaixo da Consolação já não... # expr: abalada
    Ela para. Você não disse onde era. Ninguém disse. # pista luciana: A Luciana falou "embaixo da Consolação" sem ninguém dizer onde ficava o arquivo do Cão.
    Luciana: Já não interessa a ninguém. O Cão está morto. Os segredos dele também. # expr: fria
    -> luciana_perguntas
+ {cla == "Nosferatu"} {not p2_luciana_slip} [Nosferatu :: Os ratos de baixo dizem que alguém com chave Tremere abriu a galeria da Consolação.]
    ~ passar(20)
    ~ p2_luciana_slip = true
    Você: Lá embaixo a gente fala, Senescal. Alguém com chave Tremere abriu a galeria da Consolação na terça. A do Cão.
    Luciana: Os ratos falam demais. # expr: abalada # pista luciana: Quando você falou da galeria do Cão na Consolação, a Luciana não negou. Disse: "Os ratos falam demais."
    -> luciana_perguntas
+ {cla == "Gangrel"} {not p2_luvas_cheiro} [Gangrel :: Chegar perto e farejar as luvas dela.]
    ~ passar(20)
    ~ p2_luvas_cheiro = true
    Você chega perto, perto demais. Por baixo do perfume, as luvas dela cheiram ao mesmo esgoto velho e ao mesmo ferro que os seus sapatos. # pista luciana: As luvas da Luciana cheiram ao mesmo esgoto dos seus sapatos.
    Luciana: Distância, Gangrel. Você não está no mato. # expr: ameaca
    -> luciana_perguntas
+ {p2_isa_capela} [Prova :: Capela: a senhora cancelou a Isadora às três e voltou suja de esgoto.]
    ~ passar(20)
    Luciana: Emergências acontecem. E a Isadora conta tudo para todos, por isso ninguém ouve. # expr: fria
    -> luciana_perguntas
+ {p2_luvas or p2_luvas_cheiro} {p2_luciana_slip} [Encarar: "Era a senhora. De luvas, no esgoto, comigo."]
    ~ passar(20)
    ~ luc_fechada = true
    Luciana: Cuidado, forasteir{o}. Tem coisa que é melhor não lembrar. Eu estou te fazendo um favor que você nem sabe. # expr: ameaca
    Ela aperta o seu braço com a mão de luva. Por um segundo, o corte na sua memória arde como uma ferida aberta. Depois ela solta, e vai embora. # pista luciana: A Luciana te ameaçou: "Tem coisa que é melhor não lembrar. Eu estou te fazendo um favor."
    { expulso: -> fora }
    -> salao2
+ [Voltar]
    { expulso or not dentro: -> fora }
    -> salao2

// ------------------------------------------------------------------ ACUSAÇÃO E FINAIS
=== amanhecer2 ===
# limpa
O céu atrás do MASP fica azul-escuro. O Elísio vai fechar. A Corte manda te chamar. # fundo: gala
-> acusacao2

=== acusacao2 ===
# fundo: corte
# limpa
{ final_cap1 == "C_corte":
    A Corte se reúne no último andar do museu, entre os quadros. A Constance preside, de pé. # entra: constance
    Constance: Terça à noite, querid{o}. Você saiu de um bueiro da Consolação às cinco da manhã. O que você fez lá embaixo, e com quem?
- else:
    A Corte se reúne no último andar do museu, entre os quadros. O Príncipe Dante senta numa cadeira de acrílico, como num trono. # entra: dante
    Dante: Terça à noite, forasteir{o}. Você saiu de um bueiro da Consolação às cinco da manhã. O que você fez lá embaixo, e com quem? Diga à Corte. Agora.
}
{ expulso:
    ~ denunciado = true
    ~ provas_max = 4
    Arnaldo: Antes: {o == "a":esta|este} aí usou Disciplina no meu Elísio. Eu pus para fora. Que a Corte ouça com isso em mente. # entra: arnaldo # expr: aponta
}
{ fome >= 5:
    ~ provas_max = 4
    A Fome está nos seus olhos. Todo mundo vê. Com fome assim, toda acusação parece desespero.
}
{ favor_principe and final_cap1 != "C_corte":
    ~ provas_max = MAX(provas_max - 1, 2)
    O Príncipe olha para você e lembra do favor que deve. Ele vai te ouvir com mais paciência.
}
-> acusacao2_escolha

=== acusacao2_escolha ===
+ [Eu estava com a Luciana, a Senescal. Ela apagou a minha noite.]
    -> confirma2("luciana")
+ [A Inquisição me drogou e me usou. O segurança da porta é deles.]
    -> confirma2("rocha")
+ [Eu estava com a Isadora, a anfitriã. Ela apagou a minha noite.]
    -> confirma2("isadora")
+ [Admitir que não sabe]
    -> confirma2("nao_sei")

// Resposta à Corte não tem volta: confirma antes, e avisa se as pistas fortes apontam para outro lado.
=== confirma2(quem) ===
~ temp fortes = 0
{ p2_corte: 
    ~ fortes += 1
}
{ p2_numero: 
    ~ fortes += 1
}
{ p2_isa_capela: 
    ~ fortes += 1
}
{ p2_luvas or p2_luvas_cheiro: 
    ~ fortes += 1
}
{ p2_arquivo: 
    ~ fortes += 1
}
{ p2_luciana_slip: 
    ~ fortes += 1
}
{ quem:
- "luciana": Você vai dizer à Corte que estava com a Senescal e que ela apagou a sua noite. Depois disso, ela é sua inimiga, com ou sem prova.
- "rocha": Você vai dizer à Corte que a Inquisição apagou a sua noite e que o segurança da porta é deles.
- "isadora": Você vai dizer à Corte que estava com a Isadora e que ela apagou a sua noite.
- else: Você vai dizer à Corte que não sabe o que fez na terça.
}
{ quem != "luciana" and fortes >= 2:
    Atenção :: {fortes} pistas fortes do seu caderno apontam para a Senescal, não para {quem == "nao_sei":o "não sei"|quem você vai acusar}.
}
{ quem == "nao_sei" and fortes >= 1:
    Atenção :: Você tem pistas no caderno. Quem diz "não sei" diante da Corte fica sem proteção nenhuma.
}
+ [Sim. É isso que eu vou dizer.]
    { quem:
    - "luciana":
        ~ acusado = "luciana"
        Você: Eu desci atrás de uma caixa, e não estava sozinh{o}. A Senescal estava lá. A Luciana me pegou e apagou a minha noite.
        O salão inteiro olha para a mulher de luvas pretas. Ela não se mexe. # entra: luciana # expr: fria
        -> provas2
    - "rocha":
        ~ acusado = "rocha"
        Você: O segurança da porta é da Inquisição. Eles me drogaram no porto e apagaram a minha noite.
        -> provas2
    - "isadora":
        ~ acusado = "isadora"
        Você: Foi a Isadora. Ela esteve na Capela, ela mentiu sobre isso.
        Isadora: Eu?! # entra: isadora # expr: ofendida
        -> provas2
    - else:
        -> final2_nao_sei
    }
+ [Não. Pensar de novo.]
    -> acusacao2_escolha

=== provas2 ===
{ final_cap1 == "C_corte":
    Constance: Palavra não basta. {provas_max == 4:Quatro|{provas_max == 2:Duas|Três}} coisas, as melhores que você tiver.
- else:
    Dante: Palavra não basta. {provas_max == 4:Quatro|{provas_max == 2:Duas|Três}} coisas, as melhores que você tiver.
}
-> provas2_loop

// Contra a Luciana valem as provas fortes. As outras gastam uma vez e não convencem.
=== provas2_loop ===
{ provas_dadas >= provas_max: -> veredito2 }
O que você mostra à Corte?
+ {p2_sedativo} {not a2_sedativo} [O sedativo da Inquisição só me segurou até as 2h]
    ~ a2_sedativo = true
    ~ provas_dadas += 1
    ~ provas_fortes += 1
    Você: A Inquisição me drogou no porto, sim. Mas a droga deles só segura duas horas. Às duas eu acordei. Quem apagou o resto da noite foi outra pessoa.
    -> reage2(true) ->
    -> provas2_loop
+ {p2_corte} {not a2_corte} [A minha memória foi cortada a sangue, não por droga]
    ~ a2_corte = true
    ~ provas_dadas += 1
    ~ provas_fortes += 1
    Você: A minha noite não está borrada. Está cortada, reta. Isso é sangue. Humano nenhum faz isso.
    -> reage2(true) ->
    -> provas2_loop
+ {p2_numero} {not a2_numero} [Às 03h12 eu liguei para a Capela da Luciana]
    ~ a2_numero = true
    ~ provas_dadas += 1
    ~ provas_fortes += 1
    Você: Às três e doze da noite apagada, eu liguei para a Capela. Do meu celular. Eu estava com ela, ou indo atrás dela.
    -> reage2(true) ->
    -> provas2_loop
+ {p2_isa_capela} {not a2_capela} [A Luciana saiu da Capela às três e voltou suja de esgoto]
    ~ a2_capela = true
    ~ provas_dadas += 1
    ~ provas_fortes += 1
    Você: Às três ela cancelou a sessão da Isadora com uma emergência. Voltou de madrugada com a barra do vestido suja de esgoto. Como os meus sapatos.
    -> reage2(true) ->
    -> provas2_loop
+ {p2_luvas or p2_luvas_cheiro} {not a2_luvas} [A mulher de luvas que me levou pelo esgoto]
    ~ a2_luvas = true
    ~ provas_dadas += 1
    ~ provas_fortes += 1
    Você: {p2_luvas:Eu fui visto às quatro, de braço dado com uma mulher de luvas pretas, andando como sonâmbul{o}.|As luvas dela cheiram ao mesmo esgoto dos meus sapatos.} Olhe as mãos da Senescal.
    -> reage2(true) ->
    -> provas2_loop
+ {p2_arquivo} {not a2_arquivo} [O arquivo do Cão nos esgotos da Consolação]
    ~ a2_arquivo = true
    ~ provas_dadas += 1
    ~ provas_fortes += 1
    Você: O Cão guardava um seguro nos esgotos da Consolação. Os segredos de alguém. {p2_caixa:Uma mulher de luvas levou a caixa na terça.|Na terça alguém foi buscar.}
    -> reage2(true) ->
    -> provas2_loop
+ {p2_luciana_slip} {not a2_slip} [A Luciana sabia onde estava o arquivo sem ninguém dizer]
    ~ a2_slip = true
    ~ provas_dadas += 1
    ~ provas_fortes += 1
    Você: Eu perguntei do arquivo do Cão, e ela respondeu "embaixo da Consolação". Ninguém tinha dito onde era.
    -> reage2(true) ->
    -> provas2_loop
+ {p2_lama} {not a2_lama} [A lama de esgoto nos meus sapatos]
    ~ a2_lama = true
    ~ provas_dadas += 1
    Você: Eu acordei com lama de esgoto nos sapatos.
    { acusado == "luciana": Luciana: Metade desta cidade anda no esgoto. Os Nosferatu moram lá. # expr: fria }
    -> reage2(false) ->
    -> provas2_loop
+ {p2_scanner or p2_sedativo or p2_sinal_esgoto} {not a2_rocha} [O chip na minha língua e o segurança da porta]
    ~ a2_rocha = true
    ~ provas_dadas += 1
    Você: Tem um chip embaixo da minha língua, e o segurança da porta tem o leitor.
    O salão murmura. Ninguém gosta de ouvir a palavra Inquisição dentro do Elísio.
    -> reage2(false) ->
    -> provas2_loop
+ {p2_isa_lista or p2_isa_ritual} {not a2_isadora} [A Isadora mentiu sobre a Capela]
    ~ a2_isadora = true
    ~ provas_dadas += 1
    Você: A Isadora disse que só ela e o Príncipe foram à Capela. Ela mentiu.
    { p2_isa_ritual: Isadora: Eu fui fazer um ritual de beleza! Satisfeit{o}? Agora a cidade inteira sabe. # entra: isadora # expr: ofendida }
    -> reage2(false) ->
    -> provas2_loop
+ [{provas_dadas > 0:Isso é tudo o que eu tenho.|Não tenho prova nenhuma. Só a minha palavra.}]
    -> veredito2

// Depois de cada prova: a Corte mostra se ela pegou ou não quem você acusou.
=== reage2(forte) ===
{ acusado == "luciana":
    { forte:
        Pegou :: A Senescal não responde. Os dedos dela apertam a luva. A Corte inteira viu.
    - else:
        Não pegou :: A Senescal nem pisca. Isso prova que alguma coisa aconteceu com você, não que foi ela.
    }
- else:
    { forte:
        Não encaixa :: Isso aponta para a Senescal, não para quem você acusou. A Corte se entreolha.
    - else:
        Não pegou :: Ninguém se abala. É pouco para acusar alguém diante da Corte.
    }
}
->->

=== veredito2 ===
{ acusado:
- "rocha": -> final2_rocha
- "isadora": -> final2_isadora
}
{ provas_fortes >= provas_max: -> luciana_cai }
{ provas_fortes > 0:
    Você tem peças, mas não o bastante. Contra a Senescal, meia prova é suicídio.
- else:
    Você acusa a Senescal com as mãos vazias.
}
-> final2_sem_provas

// O caminho certo: a Luciana cai, quase te mata, e alguém te protege.
=== luciana_cai ===
# musica: final_verdade
Luciana: ...Sim. Fui eu. # entra: luciana # expr: abalada
Luciana: O Cão guardava os segredos da minha Capela num buraco do esgoto, com ordem de soltar tudo se ele morresse. Ele morreu. Alguém tinha que buscar antes dos ratos.
Luciana: E você estava lá, forasteir{o}. Drogad{o}, com um chip na boca, seguindo o cheiro do Cão como um cachorro. Eu apaguei a sua noite para você não lembrar do que viu. Foi misericórdia. # expr: fria
Ela tira uma luva. Os dedos dela estão vermelhos, e o sangue na sua veia começa a ferver. # expr: ritual
Você cai de joelhos. O seu sangue sobe pela garganta, quente, querendo sair por qualquer lugar.
{ final_cap1:
- "C_corte":
    ~ aliado_cap2 = "constance"
    Constance: Basta. # entra: constance
    As sombras do salão inteiro se levantam e amarram as mãos da Senescal antes que ela feche o punho.
    Constance: Na minha Corte, ninguém mata convidado meu. Nem você, Luciana.
- "C_anarq":
    ~ aliado_cap2 = "rayo"
    O vidro da janela estoura. O Rayo entra pela escada de incêndio, capacete na mão, e acerta o capacete na mão nua da Senescal. # entra: rayo # expr: bravo
    Rayo: Mexeu com quem anda comigo, bruxa.
- "F":
    ~ aliado_cap2 = "arnaldo"
    Arnaldo: No meu Elísio, não. # entra: arnaldo # expr: lamina
    A lâmina do Juiz encosta no pescoço da Senescal. O ritual morre no meio.
- "G":
    ~ aliado_cap2 = "arnaldo"
    Arnaldo: No meu Elísio, não. # entra: arnaldo # expr: lamina
    A lâmina do Juiz encosta no pescoço da Senescal. O ritual morre no meio.
- else:
    ~ aliado_cap2 = "dante"
    Dante: Pare. # entra: dante # expr: ordem
    Uma palavra só. A Senescal congela com a mão no ar, como no Porão o Cão congelou.
    Dante: Quem me serve, ninguém toca. Nem você, Luciana. Pelo menos esta noite.
}
O sangue volta para dentro das suas veias. Você respira, sem precisar respirar, só para lembrar que ainda está aqui.
Agora você tem a sua terça inteira: o porto, o chip, o esgoto, a caixa do Cão, as luvas pretas. Você não roubou nada. Você só viu.
A Luciana calça a luva de novo, devagar. A caixa do Cão continua com ela. Você sabe disso. Ela sabe que você sabe.
Agora a pergunta é outra: para quem você leva essa verdade?
+ {final_cap1 != "C_corte"} [Ao Príncipe Dante]
    -> final2_dante
+ [À Constance]
    -> final2_constance
+ [Ao Dr. Arnaldo, o Juiz]
    -> final2_arnaldo
+ [A ninguém. Guardar o segredo da Luciana para usar depois.]
    -> final2_guardar

=== saida2_rayo ===
# fundo: vao_livre
Na saída, o segurança da portaria abre a porta para você e passa o leitor perto da sua boca. Bip. # entra: rocha # expr: sorriso
Rocha: Até a próxima. A gente sabe onde você dorme.
Na Paulista, uma moto encosta no meio-fio. É o Rayo. # entra: rayo # expr: neutro
Rayo: A bruxa apagou a sua noite pra esconder os segredos dela. Mas quem pôs o chip na sua boca foi outra gente, forasteir{o}. E essa gente tem informante no meio da gente. Abre o olho.
Continua no capítulo 3.
->->

=== final2_dante ===
~ aliado_cap2 = "dante"
# imagem: trono_vazio
Você leva a verdade ao Príncipe, sozinh{o}, depois que a Corte esvazia. Ele ouve tudo sem piscar.
Dante: A Senescal fica. Eu preciso dela. Mas agora ela me deve, e você sabe por quê. Isso vale mais do que a cabeça dela. # entra: dante # expr: calado
-> saida2_rayo ->
FINAL 2B · A VERDADE PARA O PRÍNCIPE. Você descobriu quem apagou a sua noite, e o Príncipe guardou a Senescal na coleira. Ele te protege no capítulo 3. # final: 2B
-> END

=== final2_constance ===
~ aliado_cap2 = "constance"
# imagem: anarquistas
Você leva a verdade à Constance. Ela sorri como quem recebe um presente esperado.
Constance: Uma Senescal com segredos e um Príncipe que a protege. Isso é uma corda, querid{o}. E eu sei puxar corda. # entra: constance # expr: seria
-> saida2_rayo ->
FINAL 2C · A VERDADE PARA A CONSTANCE. Você deu à Lasombra uma corda no pescoço da Senescal. Ela te protege no capítulo 3. # final: 2C
-> END

=== final2_arnaldo ===
~ aliado_cap2 = "arnaldo"
Você leva a verdade ao Dr. Arnaldo. A lei é a lei, até para a Senescal.
Arnaldo: Crime contra a hospitalidade. Vai a julgamento. E eu não esqueço de quem trouxe a prova. # entra: arnaldo # expr: aponta
-> saida2_rayo ->
FINAL 2J · A VERDADE PARA A LEI. Você entregou a Senescal ao Juiz. A Camarilla te deve, e a Luciana te odeia. O Dr. Arnaldo te protege no capítulo 3. # final: 2J
-> END

=== final2_guardar ===
~ aliado_cap2 = "ninguem"
Você não conta a ninguém. Na saída, a Luciana passa por você e para.
Luciana: Você podia ter me entregado. Por que não? # entra: luciana # expr: fria
Você: Porque agora a senhora me deve uma noite.
Ela não sorri. Mas não diz não.
-> saida2_rayo ->
FINAL 2K · O SEGREDO DA SENESCAL. Você guardou a verdade e a Senescal ficou te devendo. Ninguém te protege no capítulo 3, mas a Capela abre a porta para você. # final: 2K
-> END

// Finais ruins: acusou errado, sem provas ou não sabe. Cada personagem escapa de um deles.
=== final2_rocha ===
O segurança da porta é trazido ao salão. Ele não tem medo de ninguém ali. # entra: rocha
Rocha: Eu sou funcionário do cerimonial, senhores. Humano. Vocês querem mesmo que eu explique quem me contratou? # expr: sorriso
Ninguém quer. O Príncipe faz um gesto pequeno, e o assunto acaba.
# musica: final_triste
Na saída, o Rocha aperta o ponto no ouvido. O chip na sua língua esquenta até queimar.
{ cla == "Nosferatu": -> irene_some_sinal }
# imagem: van
Antes de você chegar ao fim da Paulista, as vans pretas já estão lá. A Inquisição não precisa mais da isca. A isca falou demais.
FINAL 2A · A ISCA QUE FALOU. Você acusou a Inquisição diante da Corte e ela respondeu do jeito dela. # final: 2A
-> END

=== irene_some_sinal ===
Você desce pela primeira grade de esgoto que vê. Embaixo da terra, o chip perde o sinal, como perdeu na terça.
# imagem: tunel
Lá em cima, as vans pretas rodam a Paulista inteira procurando uma morta que já estava morta.
Continua no capítulo 3.
FINAL 2F · A RATA SEM SINAL. Irene acusou a pessoa errada, mas embaixo da terra o chip não alcança. # final: 2F
-> END

=== final2_isadora ===
Isadora: Um ritual de beleza! É disso que vocês me acusam? # entra: isadora # expr: ofendida
O salão ri. Primeiro baixo, depois alto. A Isadora chora sem lágrimas, e a Corte ri ainda mais.
A única pessoa que não ri é a Luciana. Ela olha para você como quem anota um nome.
# musica: final_triste
# imagem: amanhecer
Na noite seguinte, você acorda no loft e não lembra do seu próprio nome. Desta vez, o corte foi até o fim.
FINAL 2A · A NOITE INTEIRA. Você acusou a pessoa errada, e a Senescal terminou o serviço. # final: 2A
-> END

=== final2_sem_provas ===
Luciana: Uma acusação de quem não lembra nem onde dormiu. # entra: luciana # expr: fria
Ela tira a luva e encosta dois dedos na sua testa, na frente de todo mundo. Ninguém a impede. # expr: ritual
{ cla == "Gangrel": -> tomas_resiste }
A sala some. O seu nome some. Você sorri para a Senescal como quem sorri para a mãe.
# musica: final_triste
# imagem: amanhecer
Você vai servir a Capela pelo resto das suas noites, sem lembrar de nenhuma.
FINAL 2D · SEM PROVAS. Você acusou a Senescal sem ter como provar, e ela apagou você inteir{o}. # final: 2D
-> END

=== tomas_resiste ===
A Besta não aceita ordem de ninguém. Ela morde a ordem no meio, como morde corrente.
Você empurra a Senescal, quebra a janela de vidro do museu e cai no vão livre, dois andares abaixo, rolando. # musica: final_triste
# imagem: serra
Atrás de você, o Elísio grita. Na sua frente, a Paulista inteira. O chip ferve na sua boca. Você corre para o mato, para longe do sinal.
Continua no capítulo 3.
FINAL 2G · O BICHO NÃO ESQUECE. Tomás acusou sem provas, mas a Besta não deixou a Senescal apagar ele. Agora ele é procurado também pela Capela. # final: 2G
-> END

=== final2_nao_sei ===
Você: Eu não sei. Não lembro.
{ final_cap1 == "C_corte":
    Constance: Então você é inútil para mim, querid{o}. # entra: constance # expr: riso
- else:
    Dante: Então você é inútil para mim, forasteir{o}. # entra: dante # expr: calado
}
Ninguém te expulsa. Pior: ninguém olha mais para você.
Na saída, o segurança da porta segura o seu braço com gentileza. # entra: rocha # expr: sorriso
Rocha: A Doutora quer conversar. Pode ser por bem.
# musica: final_triste
{ cla == "Ministério": -> joana_dupla }
# imagem: van
A van preta te leva para um lugar sem janela. Ali você lembra de muita coisa. Eles fazem você lembrar.
FINAL 2E · A ISCA RECOLHIDA. Você não soube responder, e a Inquisição veio buscar o que era dela. # final: 2E
-> END

=== joana_dupla ===
Você sorri para o humano como sorri para os fiéis que vão dar o dízimo.
Você: Por bem, irmão. Eu sempre vou por bem. Diga à Doutora que eu tenho muito a contar sobre a Corte.
Ele hesita. Ninguém nunca ofereceu antes.
# imagem: van
Na van preta, você conta à Inquisição três mentiras e uma verdade, e volta para casa antes do sol com um número de telefone novo.
Continua no capítulo 3.
FINAL 2H · A AGENTE DUPLA. Joana não soube responder, mas se ofereceu à Inquisição antes que a levassem. Agora ela espiona os dois lados. # final: 2H
-> END
