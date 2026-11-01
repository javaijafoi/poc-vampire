# Recria o painel "onde os jogadores travam" no PostHog. Uso: K=phx_... CRIAR=1 python3 analise/painel_posthog.py
# Sem CRIAR, só roda as consultas e mostra o resultado. A chave pessoal (phx_) é secreta: nunca commitar.
import json, os, urllib.request
K=os.environ['K']; B='https://us.posthog.com/api/projects/701411/'
def api(path, data=None, method=None):
    r=urllib.request.Request(B+path, data=json.dumps(data).encode() if data is not None else None, method=method or ('POST' if data is not None else 'GET'),
        headers={'Authorization':'Bearer '+K,'Content-Type':'application/json'})
    return json.load(urllib.request.urlopen(r, timeout=60))
def q(sql): return api('query/', {'query':{'kind':'HogQLQuery','query':sql}})
D30="timestamp > now() - interval 30 day"
SQL={
'Onde as pessoas desistem': f"""select lugar as `Último lugar antes de sair`, count() as `Partidas sem final`
from (select properties.$session_id as s, argMax(properties.lugar, timestamp) as lugar, countIf(event = 'final') as finais
  from events where {D30} and event in ('cena','escolha','parado','saiu','final') and properties.lugar != ''
  group by s) where finais = 0 group by lugar order by 2 desc""",
'Onde ficam parados (2 min sem clicar)': f"""select properties.lugar as `Lugar`, properties.tela as `Tela`, count() as `Vezes`, uniq(distinct_id) as `Jogadores`
from events where {D30} and event = 'parado' group by 1, 2 order by 3 desc""",
'Finais alcançados': f"""select properties.final as `Final`, count() as `Vezes`, uniq(distinct_id) as `Jogadores`, round(avg(toFloat(properties.minutos_jogando))) as `Minutos jogando (média)`, round(avg(toFloat(properties.pistas)), 1) as `Pistas (média)`
from events where {D30} and event = 'final' group by 1 order by 2 desc""",
'Do começo ao fim (jogadores)': f"""select tupleElement(e, 2) as `Etapa`, uniqIf(distinct_id, tupleElement(e, 3)) as `Jogadores` from events
array join [(1, 'Abriu o jogo', event = 'jogo_aberto'), (2, 'Começou partida', event = 'partida_iniciada'), (3, 'Escolheu personagem', event = 'personagem_escolhido'),
  (4, 'Fez 10 escolhas ou mais', event = 'escolha' and toFloat(properties.escolhas) >= 10), (5, 'Chegou a um final', event = 'final')] as e
where {D30} group by tupleElement(e, 1), tupleElement(e, 2) order by tupleElement(e, 1)""",
'Por onde passam (cenas)': f"""select properties.lugar as `Lugar`, count() as `Entradas`, uniq(distinct_id) as `Jogadores`
from events where {D30} and event = 'cena' group by 1 order by 2 desc""",
'Ajuda e caderno': f"""select properties.o_que as `Abriu`, properties.lugar as `Onde`, count() as `Vezes`
from events where {D30} and event = 'abriu' group by 1, 2 order by 3 desc limit 30""",
}
for n,s in SQL.items():
    r=q(s); print(n, r.get('error'), r['results'][:4])
if os.environ.get('CRIAR'):
    d=api('dashboards/', {'name':'Matusalém · onde os jogadores travam','description':'Últimos 30 dias. Dados anônimos do jogo web (eventos enviados por web/template.html).'})
    for n,s in SQL.items():
        api('insights/', {'name':n,'query':{'kind':'DataVisualizationNode','source':{'kind':'HogQLQuery','query':s},'display':'ActionsTable'},'dashboards':[d['id']]})
    tr={'kind':'InsightVizNode','source':{'kind':'TrendsQuery','series':[{'kind':'EventsNode','event':'partida_iniciada','name':'partida_iniciada','math':'dau','custom_name':'Jogadores que começaram'},{'kind':'EventsNode','event':'final','name':'final','math':'dau','custom_name':'Jogadores que chegaram a um final'}],'interval':'day','dateRange':{'date_from':'-30d'}}}
    api('insights/', {'name':'Jogadores por dia','query':tr,'dashboards':[d['id']]})
    print('https://us.posthog.com/project/701411/dashboard/%s' % d['id'])
