# Portfólio de BI e Engenharia de Dados — Valter Faustino

**Power BI · DAX · Power Query (M) · PostgreSQL · Pentaho PDI · n8n**

Sou analista sênior de BI, com 13 anos em dados. Trabalho principalmente com FP&A (DRE, DFC, fluxo de caixa, orçamento) e com integração de ERPs: Omie, Conta Azul e o ERP contábil SCI. Este repositório reúne projetos reais que desenvolvi, **anonimizados**. Não há dados de clientes, credenciais nem arquivos `.pbix` com dados.

> 🇺🇸 *English summary:* Senior BI analyst with 13 years in data. This repo showcases real-world, anonymized Power BI semantic models (FP&A, accounting, HR, real-estate CRM), a Pentaho ETL pipeline (Firebird → PostgreSQL), and a Power BI performance audit. Each project folder holds the business context, the architecture, the data model and selected DAX, M and SQL code.

---

## 📊 Projetos

| # | Projeto | Domínio | Destaques | Stack |
|---|---|---|---|---|
| 01 | [Template Financeiro — ERP Omie](projetos/01-template-financeiro-omie/) | FP&A | 99 tabelas · **731 medidas DAX** · 130 relacionamentos · 83 páginas · multiempresa | Power BI, DAX, M, PostgreSQL |
| 02 | [Template Financeiro — ERP Conta Azul](projetos/02-template-financeiro-conta-azul/) | FP&A | 65 tabelas · 553 medidas · modelo compartilhado + relatório fino | Power BI, DAX, M, PostgreSQL |
| 03 | [BI Contábil, Fiscal e RH — ERP SCI](projetos/03-bi-contabil-fiscal-rh-sci/) | Contabilidade / RH | 61 tabelas · 352 medidas · índices de liquidez e endividamento · turnover | Power BI, DAX, M, PostgreSQL |
| 04 | [CRM Imobiliário — Funil de Vendas](projetos/04-crm-imobiliario-vendas/) | Comercial | Funil Leads → Reservas → Vendas · VGV · forecast · ranking de corretores | Power BI, DAX, PostgreSQL |
| 05 | [ETL Pentaho — ERP SCI → PostgreSQL](projetos/05-etl-pentaho-sci-postgresql/) | Engenharia de dados | 4 rotinas de carga · 13 cargas em paralelo · carga incremental por janela de meses | Pentaho PDI, Firebird, PostgreSQL |
| 06 | [Auditoria de Performance em Power BI](projetos/06-auditoria-performance-powerbi/) | Otimização | 164 tabelas auditadas · causa raiz de refresh lento · script Tabular Editor | pbixray, Python, Tabular Editor |
| 07 | [Gestão Comercial, Metas e Pacotes](projetos/07-gestao-comercial-metas-pacotes/) | Comercial / Varejo de serviços | Meta diária por dias úteis · Pareto dinâmico · pacotes vendidos x consumidos · 11 KPIs | Power BI, DAX, M (Google Sheets) |

---

## 🧠 Competências demonstradas

- **Modelagem dimensional:** star schema, várias tabelas calendário com relacionamentos inativos (`USERELATIONSHIP`), tabelas de parâmetros e *field parameters*.
- **DAX avançado:** inteligência de tempo (YoY, MoM, acumulados), análise vertical e horizontal, DRE gerencial, aging, PMR/PMP, ranking dinâmico, funil acumulado, forecast parametrizado.
- **Power Query (M):** consultas nativas parametrizadas com *query folding* (`Value.NativeQuery` + `EnableFolding=true`), templates multiempresa e funções personalizadas (ex.: anonimização de nomes).
- **Arquitetura no Power BI Service:** modelo semântico compartilhado + relatórios finos (*thin reports*) em conexão dinâmica.
- **ETL:** jobs e transformações no Pentaho, orquestração em paralelo, tabela de controle de carga e tratamento de erro.
- **Diagnóstico e performance:** leitura do modelo VertiPaq fora do Power BI, análise de dependências, limpeza de objetos sem uso.

## 🗂️ Estrutura do repositório

```
portfolio-bi/
├── README.md                       ← você está aqui
├── projetos/
│   ├── 01-template-financeiro-omie/
│   │   ├── README.md               ← contexto, arquitetura, modelo, destaques
│   │   ├── dax/                    ← medidas selecionadas (.dax)
│   │   ├── power-query/            ← consultas M (.m)
│   │   └── imagens/                ← prints do relatório
│   ├── 02-template-financeiro-conta-azul/
│   ├── 03-bi-contabil-fiscal-rh-sci/
│   ├── 04-crm-imobiliario-vendas/
│   ├── 05-etl-pentaho-sci-postgresql/
│   ├── 06-auditoria-performance-powerbi/
│   └── 07-gestao-comercial-metas-pacotes/
└── docs/
    └── padroes-de-desenvolvimento.md
```

## 📫 Contato

- LinkedIn: [linkedin.com/in/valter-filho-82371b14b](https://www.linkedin.com/in/valter-filho-82371b14b/)
- E-mail: valterfaustino001@gmail.com

---

<sub>Os projetos foram desenvolvidos para clientes reais. Nomes de empresas, servidores, IPs, identificadores e dados foram removidos ou trocados por valores genéricos.</sub>
