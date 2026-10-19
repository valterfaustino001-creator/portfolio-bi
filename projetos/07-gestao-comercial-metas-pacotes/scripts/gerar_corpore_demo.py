"""
Gera as planilhas fictícias do projeto 07 (rede de unidades de serviços) no MESMO formato
bruto que as consultas Power Query do relatório esperam.

Regras de formato (para funcionar em qualquer configuração regional do Power BI):
- CSV separado por vírgula, UTF-8, sem aspas e SEM vírgula dentro dos valores
- datas em ISO (aaaa-mm-dd)
- números inteiros; percentuais escritos como "25%"
"""
import csv, json, random, sys, datetime as dt
from pathlib import Path
from openpyxl import Workbook

REF = json.load(open(sys.argv[1]))
OUT = Path(sys.argv[2]); OUT.mkdir(parents=True, exist_ok=True)
rnd = random.Random(2026)

# ---------------- cadastros fictícios ----------------
LOJAS = [  # IDLoja, nome bruto nas vendas, terminal, célula (metas), centro de custo, célula KPI, peso
    ("1", "Corpore Zeus", "14", "Corpore Zeus", "Zeus", "Zeus", 0.55),
    ("2", "Loja Belas", "15", "Corpore Belas", "Lojabelas", "Belas", 0.35),
    ("4", "Corpore Marina Baia", "16", "Corpore Marina", "Marina Baia", None, 0.10),
]
TERMINAL_NOME = {"1": "Corpore Zeus - {a}", "2": "Corpore Belas {a}", "4": "Corpore Marina {a}"}

NOMES = ["Ana", "Beatriz", "Carla", "Daniela", "Elisa", "Fernanda", "Gabriela", "Helena", "Inês", "Joana",
         "Larissa", "Marta", "Natália", "Olívia", "Paula", "Rita", "Sofia", "Teresa", "Vera", "Yara",
         "André", "Bruno", "Carlos", "Diogo", "Eduardo", "Fábio", "Gustavo", "Hugo", "Igor", "João",
         "Luís", "Mário", "Nuno", "Paulo", "Ricardo", "Sérgio", "Tiago", "Vasco"]
SOBRENOMES = ["Almeida", "Barros", "Cardoso", "Duarte", "Esteves", "Faria", "Gomes", "Henriques", "Lopes",
              "Machado", "Neves", "Oliveira", "Pacheco", "Queirós", "Ramos", "Silveira", "Tavares", "Valente",
              "Xavier", "Zanetti", "Moreira", "Correia", "Fontes", "Pinheiro"]

def nome_pessoa(r):
    a, b = r.sample(SOBRENOMES, 2)
    return f"{r.choice(NOMES)} {a} {b}"

# colaboradores: código, nome, função, loja
FUNC = []
cod = 5001
for loja in LOJAS:
    n = {"1": 14, "2": 10, "4": 5}[loja[0]]
    for _ in range(n):
        nome = nome_pessoa(rnd)
        while any(f["nome"] == nome for f in FUNC):
            nome = nome_pessoa(rnd)
        FUNC.append({"cod": str(cod), "nome": nome.upper(), "funcao": rnd.choice(REF["funcoes"]), "loja": loja})
        cod += 1
FUNC_POR_LOJA = {l[0]: [f for f in FUNC if f["loja"][0] == l[0]] for l in LOJAS}

CLIENTES = [(str(100000 + i), nome_pessoa(rnd).upper()) for i in range(2500)]

def classes(chave, upper=True):
    vistos, out = set(), []
    for i, c in REF[chave]:
        if c in ("...", "Inativo") or "«" in c: continue
        if i in vistos: continue
        vistos.add(i); out.append((i, c.upper() if upper else c))
    return out
CL_PAC = classes("classes_pacotes")
CL_SERV = classes("classes_Servico")
CL_PROD = classes("classes_Produto")
CL_CONS = classes("classes_Pacotes Consumidos")

def itens(cls, tipo):
    out = []
    for i, c in cls:
        base = " ".join(c.split()).title()
        for k in range(1, rnd.randint(3, 6)):
            out.append((i, c, f"{tipo} {base} {k:02d}".upper()))
    return out
IT_PAC, IT_SERV, IT_PROD, IT_CONS = itens(CL_PAC, "PACOTE"), itens(CL_SERV, "SESSAO"), itens(CL_PROD, "PRODUTO"), itens(CL_CONS, "SESSAO")
PRECO = {d: rnd.choice([8000, 12000, 15000, 20000, 25000, 30000, 40000, 55000]) for _, _, d in IT_SERV + IT_PROD + IT_CONS}
PRECO.update({d: rnd.choice([60000, 90000, 120000, 180000, 250000]) for _, _, d in IT_PAC})

INICIO, FIM = dt.date(2021, 1, 4), dt.date(2026, 1, 9)
def dias():
    d = INICIO
    while d <= FIM:
        if d.weekday() < 6: yield d
        d += dt.timedelta(days=1)

def sazonal(d):  # crescimento anual + sazonalidade de fim de ano
    return (1 + 0.12 * (d.year - 2021)) * (1.25 if d.month in (11, 12) else 1.0)

def escolher_loja():
    return rnd.choices(LOJAS, weights=[l[6] for l in LOJAS])[0]

# ---------------- vendas (formato dos relatórios do sistema de gestão) ----------------
HDR = ["DataDocumento", "IDdocumento", "NumDocumento", "IdCliente", "NomeCliente", "EmailCliente", "IDfuncionario",
       "NomeFuncionario", "IdResponsavel", "Responsavel", "Codigolinha", "ServicoDescritivo", "TipoArtigo", "Quant",
       "TaxaIVA", "Desconto", "ValorUnitario", "ValorTotal", "IDLoja", "NomeLoja", "IDTerminal", "NomeTerminal",
       "IdClasse", "Classe"]
vendas = {"pac": [], "serv": [], "prod": []}
cons = []
doc = 1
for d in dias():
    f = sazonal(d)
    for chave, itens_, media in (("serv", IT_SERV, 14), ("prod", IT_PROD, 4), ("pac", IT_PAC, 1.6)):
        for _ in range(max(0, int(rnd.gauss(media * f, media * 0.35)))):
            loja = escolher_loja(); func = rnd.choice(FUNC_POR_LOJA[loja[0]]); cli = rnd.choice(CLIENTES)
            idc, cl, desc = rnd.choice(itens_)
            q = rnd.choice([1, 1, 1, 2]) if chave != "pac" else rnd.choice([1, 4, 6, 8, 10])
            pu = PRECO[desc]; tot = pu * q if chave != "pac" else pu
            vendas[chave].append([d.isoformat(), "Factura", str(doc), cli[0], cli[1], func["cod"], func["nome"], "",
                                  "0", "xxx", str(rnd.randint(100, 999)), desc, "S", str(q), rnd.choice(["0", "14"]),
                                  "0", str(pu), str(tot), loja[0], loja[1], loja[2],
                                  TERMINAL_NOME[loja[0]].format(a=d.year), idc, cl])
            doc += 1
    for _ in range(max(0, int(rnd.gauss(4.5 * f, 1.5)))):
        loja = escolher_loja(); func = rnd.choice(FUNC_POR_LOJA[loja[0]]); cli = rnd.choice(CLIENTES)
        idc, cl, desc = rnd.choice(IT_CONS)
        cons.append([str(rnd.randint(10000, 99999)), func["cod"], func["nome"], d.isoformat(), desc, cli[0], cli[1],
                     "1", str(doc), str(PRECO[desc]), loja[1], "60", loja[2], TERMINAL_NOME[loja[0]].format(a=d.year),
                     idc, cl, "", "Concluido", "", "", "", "", "", ""])
        doc += 1

def grava_csv(nome, header, linhas, enc="utf-8"):
    with open(OUT / nome, "w", newline="", encoding=enc) as fh:
        w = csv.writer(fh, delimiter=",", quoting=csv.QUOTE_NONE, escapechar=None, lineterminator="\n")
        w.writerow(header)
        for l in linhas:
            assert not any("," in str(x) for x in l), (nome, l)
            w.writerow(l)

CONS_HDR = ["idpacotes", "idfuncionario", "funcionario", "data", "servico", "idcliente", "cliente", "sessoes",
            "comprovativo", "valor", "loja", "duracao", "idterminal", "terminal", "IdClasse", "Classe", "obs", "estado",
            "", "", "", "", "", ""]
for ano in range(2021, 2027):
    sel = lambda rows: [r for r in rows if r[0].startswith(str(ano))]
    # pacotes vendidos: 25 colunas, a 19ª é descartada pela consulta (Column19)
    pac = [r[:18] + ["-"] + r[18:] for r in sel(vendas["pac"])]
    grava_csv(f"pacotes_vendidos_{ano}.csv", HDR[:18] + ["x"] + HDR[18:], pac)
    grava_csv(f"faturamento_servicos_{ano}.csv", HDR, sel(vendas["serv"]))
    grava_csv(f"faturamento_produtos_{ano}.csv", HDR, sel(vendas["prod"]))
    grava_csv(f"pacotes_consumidos_{ano}.csv", CONS_HDR, [r for r in cons if r[3].startswith(str(ano))])

# ---------------- metas por colaborador (fMetasFunc e dCargosAux) ----------------
MF_HDR = ["Mês Ano", "Célula", " Funcionario", " Função", "Meta", "% Comissao", "Regra 100% mais 4%",
          "Regra 130% mais 2%", "Regra 160% mais 2%", "Pacote", "Produto", "_id", "Increment"]
mf, inc = [], 1
for m in range(1, 13):
    for fu in FUNC:
        if fu["funcao"] == "Consultor de Vendas" or rnd.random() < 0.85:
            mf.append([f"2025-{m:02d}-01", fu["loja"][3], fu["nome"].title(), fu["funcao"],
                       str(rnd.choice([600000, 800000, 1000000, 1200000, 1500000])), rnd.choice(["10%", "20%", "25%"]),
                       "4%", "2%", "4%", "2%", "5%", fu["loja"][0], str(inc)])
            inc += 1
grava_csv("metas_colaboradores.csv", MF_HDR, mf)

# ---------------- comissões (CSV em Windows-1252) ----------------
grava_csv("comissoes.csv", ["MesAno", "%Pacote", "%Produto"],
          [[f"{y}-{m:02d}-01", "2%", "5%"] for y in range(2021, 2026) for m in range(1, 13)], enc="cp1252")

# ---------------- KPIs realizados ----------------
kr = []
for y in (2024, 2025):
    for m in range(1, 13):
        for loja in LOJAS[:2]:
            for ind, idi in REF["kpi_real"]:
                lo, hi = REF["kpi_real_stats"][ind]["min"], REF["kpi_real_stats"][ind]["max"]
                if hi <= 1 and hi > 0:
                    val = f"{rnd.randint(int(lo * 100) or 1, int(hi * 100) or 2)}%"
                elif hi == 0:
                    val = f"{rnd.randint(8, 22)}%"
                else:
                    val = str(rnd.randint(int(lo), int(hi)))
                kr.append([f"{y}-{m:02d}-01", f"{(m - 1) // 3 + 1}-Tri", loja[5], ind, ind, val, idi, loja[0]])
grava_csv("kpi_realizado.csv", ["Mês Ano", "TRI", "Célula", "Indicador", "Desc", "Valor", "_idIndicador", "_IdLoja"], kr)

# ---------------- metas de KPI (Excel com uma aba por grupo) ----------------
wb = Workbook(); wb.remove(wb.active)
grupos = {}
for ind, cl in REF["kpi_pairs"]:
    if cl == "...": continue
    grupos.setdefault(ind[:28].replace("/", "-").replace("$", ""), []).append((ind, cl))
serial0 = dt.date(1899, 12, 30)
for aba, pares in grupos.items():
    ws = wb.create_sheet(aba[:31])
    ws.append(["Mês Ano", "Loja", "Id", "indicador", "Classe", "Meta"])
    for y in (2024, 2025):
        for m in range(1, 13):
            serial = (dt.date(y, m, 1) - serial0).days
            for loja in LOJAS[:2]:
                for ind, cl in pares:
                    meta = rnd.choice([100000, 250000, 500000, 800000, 1200000, 2000000]) if "VENDA" in ind else rnd.randint(1, 300)
                    ws.append([serial, loja[3], int(loja[0]), ind, cl, meta])
wb.save(OUT / "metas_kpi.xlsx")

# ---------------- plano de contas (De-Para) e movimento financeiro ----------------
CONTAS = {
    "Receita": ["Faturamento de Pacotes Vendidos", "Faturamento de Produtos", "Faturamento de Serviço",
                "Faturamento de Pacotes Consumidos"],
    "Custos Totais": ["Compra de Produtos para Revenda", "Materiais de Consumo", "Comissões sobre Vendas",
                      "Descartáveis e EPI", "Manutenção de Equipamentos"],
    "Despesas Total": ["Aluguel", "Energia Elétrica", "Água", "Internet e Telefonia", "Salários", "Encargos Sociais",
                       "Vale Transporte", "Marketing Digital", "Material de Escritório", "Contabilidade",
                       "Sistemas e Software", "Limpeza e Conservação", "Segurança", "Seguros", "Tarifas Bancárias",
                       "Treinamentos", "Uniformes", "Combustível", "Viagens", "Despesas Diversas"],
    "Impostos": ["INSS", "IRT CONTA DE OUTREM", "IRT CONTA PRÓPRIA", "IPU", "RETENÇÃO NA FONTE",
                 "IMPOSTO INDUSTRIAL", "IMPOSTO SOBRE VALOR ACRESCENTADO (IVA)"],
}
ORDEM = {"Receita": "1", "Custos Totais": "2", "Despesas Total": "4", "Impostos": "6"}
dep = [[c, str(i + 1), t, ORDEM[t]] for i, (t, cs) in enumerate(CONTAS.items()) for c in cs]
# a consulta remove a 2ª coluna antes de promover o cabeçalho
grava_csv("plano_contas.csv", ["DESCRIÇÃO ", "Índice", "Tipo", "Ordem"], dep)

mov = []
cc_venda = {"1": "Zeus", "2": "Lojabelas", "4": "Marina Baia"}
agg = {}
for chave, tipo in (("serv", "Faturamento de Serviço"), ("prod", "Faturamento de Produtos"),
                    ("pac", "Faturamento de Pacotes Vendidos")):
    for r in vendas[chave]:
        k = (tipo, cc_venda[r[18]], r[0]); agg[k] = agg.get(k, 0) + int(r[17])
for r in cons:
    loja = next(l for l in LOJAS if l[1] == r[10])
    k = ("Faturamento de Pacotes Consumidos", cc_venda[loja[0]], r[3]); agg[k] = agg.get(k, 0) + int(r[9])
for (tipo, cc, data), v in sorted(agg.items()):
    mov.append([tipo, tipo, cc, str(v), data, {"Zeus": "1", "Lojabelas": "2"}.get(cc, "0")])
receita_mes = {}
for (tipo, cc, data), v in agg.items():
    receita_mes[(cc, data[:7])] = receita_mes.get((cc, data[:7]), 0) + v
for (cc, ym), rec in sorted(receita_mes.items()):
    data = f"{ym}-05"
    for conta in CONTAS["Custos Totais"]:
        mov.append([conta, "Despesas Variáveis", cc, str(int(rec * rnd.uniform(0.03, 0.07))), data, {"Zeus": "1", "Lojabelas": "2"}.get(cc, "0")])
    for conta in CONTAS["Despesas Total"]:
        mov.append([conta, "Despesas Fixas", cc, str(int(rec * rnd.uniform(0.01, 0.04))), data, {"Zeus": "1", "Lojabelas": "2"}.get(cc, "0")])
    for conta in CONTAS["Impostos"]:
        mov.append([conta, "Impostos", cc, str(int(rec * rnd.uniform(0.005, 0.02))), data, {"Zeus": "1", "Lojabelas": "2"}.get(cc, "0")])
grava_csv("movimento_financeiro.csv", ["DESC", "Classificação", "Centro de Custo", "Valor", "DataKey", "IdCC"], mov)

resumo = {p.name: sum(1 for _ in open(p, encoding="cp1252" if p.name == "comissoes.csv" else "utf-8")) - 1
          for p in sorted(OUT.glob("*.csv"))}
print(json.dumps(resumo, indent=1))
print("colaboradores:", len(FUNC), "clientes:", len(CLIENTES))
