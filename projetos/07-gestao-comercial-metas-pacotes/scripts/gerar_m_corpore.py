"""Gera o código M de substituição para cada consulta do Corpore (troca links do Google por dados-demo no GitHub)."""
import json, re, sys
Q = json.load(open(sys.argv[1])); OUT = sys.argv[2]
MAP = {}
for y in range(2021, 2027):
    MAP[f"fPacotesVendidos{y}"] = f"pacotes_vendidos_{y}.csv"
    MAP[f"fFaturamentoProdutos{y}"] = f"faturamento_produtos_{y}.csv"
    MAP[f"fFaturamentoServicos{y}"] = f"faturamento_servicos_{y}.csv"
    MAP[f"fPacotesConsumidos{y}"] = f"pacotes_consumidos_{y}.csv"
MAP.update({"***fMetasFunc": "metas_colaboradores.csv", "dCargosAux": "metas_colaboradores.csv",
            "***fKPI_Real": "kpi_realizado.csv", "***fMetasKPI": "metas_kpi.xlsx",
            "fComissoesProd_Pac": "comissoes.csv", "_DeparaPlanoContas": "plano_contas.csv",
            "---Movimento": "movimento_financeiro.csv"})
APAGAR = [k for k in Q if re.search(r"https?://", Q[k]) and k not in MAP]

def ativo(m):
    linhas = [l for l in m.splitlines() if not l.strip().startswith("//")]
    m = "\n".join(linhas).strip()
    i = m.rfind("let")
    while i > 0 and m[:i].count("let") > m[:i].count("\nin"):  # pega o último bloco let/in de topo
        i = m.rfind("let", 0, i)
    return m[i:].strip() if i >= 0 else m

out = ["// ==============================================================",
       "// CÓDIGO M DAS CONSULTAS — versão com dados fictícios do GitHub",
       "// 1) Crie o parâmetro BaseURL (Texto) com o valor:",
       "//    https://raw.githubusercontent.com/valterfaustino001-creator/portfolio-bi/main/projetos/07-gestao-comercial-metas-pacotes/dados-demo/",
       "// 2) Para cada consulta abaixo: clique nela > Editor Avançado > apague tudo > cole o bloco.",
       "// ==============================================================", ""]
for nome, arq in MAP.items():
    m = ativo(Q[nome])
    m2, n = re.subn(r'Web\.Contents\("https?://[^"]+"\)', f'Web.Contents(BaseURL, [RelativePath="{arq}"])', m)
    assert n == 1, (nome, n)
    out += [f"// ---------- {nome}  ->  {arq}", m2, ""]
open(OUT, "w", encoding="utf-8").write("\n".join(out))
print("substituir:", len(MAP)); print("apagar:", APAGAR)
