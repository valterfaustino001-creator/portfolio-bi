# Dados de demonstração (100% fictícios)

Planilhas geradas por script para alimentar o relatório do projeto 07 sem expor dados reais.
Clientes, colaboradores, valores e metas são inventados. Os formatos (colunas, cabeçalhos,
abas) são os mesmos que as consultas Power Query originais esperam.

| Arquivo | Consulta(s) no Power BI |
|---|---|
| `pacotes_vendidos_AAAA.csv` | fPacotesVendidos2021 … 2026 |
| `faturamento_servicos_AAAA.csv` | fFaturamentoServicos2021 … 2026 |
| `faturamento_produtos_AAAA.csv` | fFaturamentoProdutos2021 … 2026 |
| `pacotes_consumidos_AAAA.csv` | fPacotesConsumidos2021 … 2026 |
| `metas_colaboradores.csv` | ***fMetasFunc, dCargosAux |
| `kpi_realizado.csv` | ***fKPI_Real |
| `metas_kpi.xlsx` | ***fMetasKPI |
| `comissoes.csv` | fComissoesProd_Pac |
| `plano_contas.csv` | _DeparaPlanoContas |
| `movimento_financeiro.csv` | ---Movimento |

`consultas_power_query_demo.m` traz o código M de cada consulta apontando para estes arquivos.

## Como ligar o relatório a estes dados

1. **Parâmetro:** em *Transformar dados → Gerenciar parâmetros → Novo*, crie `BaseURL` (Texto) com o valor
   `https://raw.githubusercontent.com/valterfaustino001-creator/portfolio-bi/main/projetos/07-gestao-comercial-metas-pacotes/dados-demo/`
2. **Trocar as 31 consultas:** para cada bloco de `consultas_power_query_demo.m`, abra a consulta de mesmo nome →
   *Editor Avançado* → apague tudo → cole o bloco → *Concluído*.
3. **Apagar as consultas antigas que não são usadas** (ainda guardam links das planilhas reais):
   primeiro `---fSaídas`, `---AuxImpostos`, `---METAS_KPI`; depois
   `fImpostos_Belas_2024`, `fImpostos_ZEUS_2024`, `fImpostos_ADM_2024`, `fImpostos_Belas_2025`, `fImpostos_ZEUS_2025`,
   `fImpostos_ADM_2025`, `---fResumoDespesas_2024`, `---fResumoDespesas_2025`, `---fImobilizados`, `---METAS KPI` e as 11
   `KPI_*` (`KPI_VENDA_PAC`, `KPI_QTD_LEADS`, `KPI_VENDA_SERV`, `KPI_TKM_PROD`, `KPI_VENC_PROD`, `KPI_SATISFACAO_CLI`,
   `KPI_NUMERO_AGEN`, `KPI_HORAS_AGE`, `KPI_TO`, `KPI_DESP`, `KPI_LUCRO`).
4. **Credencial:** quando pedir, escolha *Web → Anônimo* para `raw.githubusercontent.com`.
5. **Fechar e aplicar** e atualizar.
6. **Limpar seleções salvas com nomes reais:**
   - página *Performance*: limpe a segmentação de funcionário, escolha um colaborador fictício e atualize os
     indicadores *Grupo Performance Func.*, *% Atingido Meta Func.* e *Fat. vs Meta Func.* (painel Indicadores → ⋯ → Atualizar);
   - página *Val. Pacotes Consumidos*: apague o texto digitado na busca da segmentação de funcionário.
7. Salve como `Gestao_Comercial_Metas_DEMO.pbix`.

Os scripts que geraram os dados ficam em [`../scripts/`](../scripts/).
