// ==============================================================
// CÓDIGO M DAS CONSULTAS — versão com dados fictícios do GitHub
// 1) Crie o parâmetro BaseURL (Texto) com o valor:
//    https://raw.githubusercontent.com/valterfaustino001-creator/portfolio-bi/main/projetos/07-gestao-comercial-metas-pacotes/dados-demo/
// 2) Para cada consulta abaixo: clique nela > Editor Avançado > apague tudo > cole o bloco.
// ==============================================================

// ---------- fPacotesVendidos2021  ->  pacotes_vendidos_2021.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="pacotes_vendidos_2021.csv"]),[Delimiter=",", Columns=25, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Colunas Removidas" = Table.RemoveColumns(Fonte,{"Column19"}),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(#"Colunas Removidas", [PromoteAllScalars=true]),
    #"Tipo Alterado com Localidade" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"DataDocumento", type datetime}}, "en-US"),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Tipo Alterado com Localidade",{{"DataDocumento", type date}, {"Quant", Int64.Type}, {"ValorTotal", type number}, {"ValorUnitario", type number}})
in
    #"Tipo Alterado"

// ---------- fFaturamentoProdutos2021  ->  faturamento_produtos_2021.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="faturamento_produtos_2021.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado com Localidade" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"DataDocumento", type datetime}}, "en-US"),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Tipo Alterado com Localidade",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}})
in
    #"Tipo Alterado"

// ---------- fFaturamentoServicos2021  ->  faturamento_servicos_2021.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="faturamento_servicos_2021.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado com Localidade" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"DataDocumento", type datetime}}, "en-US"),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Tipo Alterado com Localidade",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}})
in
    #"Tipo Alterado"

// ---------- fPacotesConsumidos2021  ->  pacotes_consumidos_2021.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="pacotes_consumidos_2021.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado com Localidade" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"data", type datetime}}, "en-US"),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Tipo Alterado com Localidade",{{"data", type date}, {"sessoes", Int64.Type}, {"valor", type number}})
in
    #"Tipo Alterado"

// ---------- fPacotesVendidos2022  ->  pacotes_vendidos_2022.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="pacotes_vendidos_2022.csv"]),[Delimiter=",", Columns=25, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Colunas Removidas" = Table.RemoveColumns(Fonte,{"Column19"}),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(#"Colunas Removidas", [PromoteAllScalars=true]),
    #"Tipo Alterado com Localidade" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"DataDocumento", type datetime}}, "en-US"),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Tipo Alterado com Localidade",{{"DataDocumento", type date}, {"Quant", Int64.Type}, {"ValorTotal", type number}, {"ValorUnitario", type number}})
in
    #"Tipo Alterado"

// ---------- fFaturamentoProdutos2022  ->  faturamento_produtos_2022.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="faturamento_produtos_2022.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
     #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado com Localidade" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"DataDocumento", type datetime}}, "en-US"),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Tipo Alterado com Localidade",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}})
in
    #"Tipo Alterado"

// ---------- fFaturamentoServicos2022  ->  faturamento_servicos_2022.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="faturamento_servicos_2022.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado com Localidade" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"DataDocumento", type datetime}}, "en-US"),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Tipo Alterado com Localidade",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}}),
    #"Colunas Renomeadas" = Table.RenameColumns(#"Tipo Alterado",{{"''", "IdCliente"}})
in
    #"Colunas Renomeadas"

// ---------- fPacotesConsumidos2022  ->  pacotes_consumidos_2022.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="pacotes_consumidos_2022.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado com Localidade" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"data", type datetime}}, "en-US"),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Tipo Alterado com Localidade",{{"data", type date}, {"sessoes", Int64.Type}, {"valor", type number}})
in
    #"Tipo Alterado"

// ---------- fPacotesVendidos2023  ->  pacotes_vendidos_2023.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="pacotes_vendidos_2023.csv"]),[Delimiter=",", Columns=25, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Colunas Removidas" = Table.RemoveColumns(Fonte,{"Column19"}),
  #"Cabeçalhos Promovidos" = Table.PromoteHeaders(#"Colunas Removidas", [PromoteAllScalars=true]),
    #"Tipo Alterado com Localidade" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"DataDocumento", type datetime}}, "en-US"),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Tipo Alterado com Localidade",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}, {"ValorUnitario", type number}})
in
    #"Tipo Alterado"

// ---------- fFaturamentoProdutos2023  ->  faturamento_produtos_2023.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="faturamento_produtos_2023.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado com Localidade" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"DataDocumento", type datetime}}, "en-US"),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Tipo Alterado com Localidade",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}})
in
    #"Tipo Alterado"

// ---------- fFaturamentoServicos2023  ->  faturamento_servicos_2023.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="faturamento_servicos_2023.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Texto Extraído Antes do Delimitador" = Table.TransformColumns(#"Cabeçalhos Promovidos", {{"DataDocumento", each Text.BeforeDelimiter(_, " "), type text}}),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Texto Extraído Antes do Delimitador",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}})
in
    #"Tipo Alterado"

// ---------- fPacotesConsumidos2023  ->  pacotes_consumidos_2023.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="pacotes_consumidos_2023.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado com Localidade" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos", {{"data", type datetime}}, "en-US"),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Tipo Alterado com Localidade",{{"data", type date}, {"sessoes", Int64.Type}, {"valor", type number}})
in
    #"Tipo Alterado"

// ---------- fPacotesVendidos2024  ->  pacotes_vendidos_2024.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="pacotes_vendidos_2024.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Texto Extraído Antes do Delimitador" = Table.TransformColumns(#"Cabeçalhos Promovidos", {{"DataDocumento", each Text.BeforeDelimiter(_, " "), type text}}),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Texto Extraído Antes do Delimitador",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}, {"ValorUnitario", type number}})
in
    #"Tipo Alterado"

// ---------- fFaturamentoProdutos2024  ->  faturamento_produtos_2024.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="faturamento_produtos_2024.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado1" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"Quant", Int64.Type}, {"ValorTotal", type number}}),
    #"Texto Extraído Antes do Delimitador" = Table.TransformColumns(#"Tipo Alterado1", {{"DataDocumento", each Text.BeforeDelimiter(_, " "), type text}}),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Texto Extraído Antes do Delimitador",{{"DataDocumento", type date}})
in
    #"Tipo Alterado"

// ---------- fFaturamentoServicos2024  ->  faturamento_servicos_2024.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="faturamento_servicos_2024.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}})
in
    #"Tipo Alterado"

// ---------- fPacotesConsumidos2024  ->  pacotes_consumidos_2024.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="pacotes_consumidos_2024.csv"]),[Delimiter=",", Columns=19, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Colunas Removidas" = Table.RemoveColumns(#"Cabeçalhos Promovidos",{"__PowerAppsId__"}),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Colunas Removidas",{{"data", type date}, {"sessoes", Int64.Type}, {"valor", type number}})
in
    #"Tipo Alterado"

// ---------- fPacotesVendidos2025  ->  pacotes_vendidos_2025.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="pacotes_vendidos_2025.csv"]),[Delimiter=",", Columns=25, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Colunas Removidas" = Table.RemoveColumns(Fonte,{"Column19"}),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(#"Colunas Removidas", [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}, {"ValorUnitario", type number}})
in
    #"Tipo Alterado"

// ---------- fFaturamentoProdutos2025  ->  faturamento_produtos_2025.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="faturamento_produtos_2025.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Colunas Removidas" = Table.RemoveColumns(#"Cabeçalhos Promovidos",{"NomeFuncionario"}),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Colunas Removidas",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}}),
    #"Ano Inserido" = Table.AddColumn(#"Tipo Alterado", "ano", each Date.Year([DataDocumento]), Int64.Type),
    #"Linhas Filtradas" = Table.SelectRows(#"Ano Inserido", each ([ano] = 2025)),
    #"Colunas Removidas1" = Table.RemoveColumns(#"Linhas Filtradas",{"ano"})
in
    #"Colunas Removidas1"

// ---------- fFaturamentoServicos2025  ->  faturamento_servicos_2025.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="faturamento_servicos_2025.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}}),
    #"Ano Inserido" = Table.AddColumn(#"Tipo Alterado", "ano", each Date.Year([DataDocumento]), Int64.Type),
    #"Linhas Filtradas" = Table.SelectRows(#"Ano Inserido", each ([ano] = 2025)),
    #"Colunas Removidas" = Table.RemoveColumns(#"Linhas Filtradas",{"ano"})
in
    #"Colunas Removidas"

// ---------- fPacotesConsumidos2025  ->  pacotes_consumidos_2025.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="pacotes_consumidos_2025.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"data", type date}, {"valor", type number}, {"sessoes", Int64.Type}})
in
    #"Tipo Alterado"

// ---------- fPacotesVendidos2026  ->  pacotes_vendidos_2026.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="pacotes_vendidos_2026.csv"]),[Delimiter=",", Columns=25, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Colunas Removidas" = Table.RemoveColumns(Fonte,{"Column19"}),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(#"Colunas Removidas", [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}, {"ValorUnitario", type number}}),
    #"Linhas Filtradas" = Table.SelectRows(#"Tipo Alterado", each [DataDocumento] >= #date(2026, 1, 1) and [DataDocumento] <= #date(2026, 12, 31))
in
    #"Linhas Filtradas"

// ---------- fFaturamentoProdutos2026  ->  faturamento_produtos_2026.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="faturamento_produtos_2026.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Colunas Removidas" = Table.RemoveColumns(#"Cabeçalhos Promovidos",{"NomeFuncionario"}),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Colunas Removidas",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}}),
    #"Ano Inserido" = Table.AddColumn(#"Tipo Alterado", "ano", each Date.Year([DataDocumento]), Int64.Type),
    #"Colunas Removidas1" = Table.RemoveColumns(#"Ano Inserido",{"ano"}),
    #"Linhas Filtradas1" = Table.SelectRows(#"Colunas Removidas1", each [DataDocumento] >= #date(2026, 1, 1) and [DataDocumento] <= #date(2026, 12, 31))
in
    #"Linhas Filtradas1"

// ---------- fFaturamentoServicos2026  ->  faturamento_servicos_2026.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="faturamento_servicos_2026.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"DataDocumento", type date}, {"ValorTotal", type number}, {"Quant", Int64.Type}}),
    #"Ano Inserido" = Table.AddColumn(#"Tipo Alterado", "ano", each Date.Year([DataDocumento]), Int64.Type),
    #"Colunas Removidas" = Table.RemoveColumns(#"Ano Inserido",{"ano"}),
    #"Linhas Filtradas1" = Table.SelectRows(#"Colunas Removidas", each [DataDocumento] >= #date(2026, 1, 1) and [DataDocumento] <= #date(2026, 12, 31))
in
    #"Linhas Filtradas1"

// ---------- fPacotesConsumidos2026  ->  pacotes_consumidos_2026.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="pacotes_consumidos_2026.csv"]),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"data", type date}, {"valor", type number}, {"sessoes", Int64.Type}}),
    #"Linhas Filtradas" = Table.SelectRows(#"Tipo Alterado", each [data] >= #date(2026, 1, 1) and [data] <= #date(2026, 12, 31))
in
    #"Linhas Filtradas"

// ---------- ***fMetasFunc  ->  metas_colaboradores.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="metas_colaboradores.csv"]),[Delimiter=",", Columns=13, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"Mês Ano", type text}, {"Célula", type text}, {" Funcionario", type text}, {" Função", type text}, {"Meta", Int64.Type}, {"% Comissao", type number}, {"Regra 100% mais 4%", type number}, {"Regra 130% mais 2%", type number}, {"Regra 160% mais 2%", type number}, {"Pacote", type number}, {"Produto", type number}, {"_id", Int64.Type}, {"Increment", Int64.Type}}),
    #"Valor Substituído" = Table.ReplaceValue(#"Tipo Alterado",".","",Replacer.ReplaceText,{"Mês Ano"}),
    #"Tipo Alterado1" = Table.TransformColumnTypes(#"Valor Substituído",{{"Mês Ano", type date}}),
    #"Erros Substituídos" = Table.ReplaceErrorValues(#"Tipo Alterado1", {{"Meta", 0}}),
    #"Valor Substituído1" = Table.ReplaceValue(#"Erros Substituídos","Corpore Zeus","Zeus",Replacer.ReplaceText,{"Célula"}),
    #"Valor Substituído2" = Table.ReplaceValue(#"Valor Substituído1","Corpore Belas","LojaBelas",Replacer.ReplaceText,{"Célula"})
in
    #"Valor Substituído2"

// ---------- dCargosAux  ->  metas_colaboradores.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="metas_colaboradores.csv"]),[Delimiter=",", Columns=13, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"Mês Ano", type text}, {"Célula", type text}, {" Funcionario", type text}, {" Função", type text}, {"Meta", Int64.Type}, {"% Comissao", type number}, {"Regra 100% mais 4%", type number}, {"Regra 130% mais 2%", type number}, {"Regra 160% mais 2%", type number}, {"Pacote", type number}, {"Produto", type number}, {"_id", Int64.Type}, {"Increment", Int64.Type}}),
    #"Valor Substituído" = Table.ReplaceValue(#"Tipo Alterado",".","",Replacer.ReplaceText,{"Mês Ano"}),
    #"Tipo Alterado1" = Table.TransformColumnTypes(#"Valor Substituído",{{"Mês Ano", type date}}),
    #"Outras Colunas Removidas" = Table.SelectColumns(#"Tipo Alterado1",{"Célula", " Funcionario", " Função"}),
    #"Duplicatas Removidas" = Table.Distinct(#"Outras Colunas Removidas", {" Funcionario"}),
    #"Colocar Cada Palavra Em Maiúscula" = Table.TransformColumns(#"Duplicatas Removidas",{{" Funcionario", Text.Proper, type text}})
in
    #"Colocar Cada Palavra Em Maiúscula"

// ---------- ***fKPI_Real  ->  kpi_realizado.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="kpi_realizado.csv"]),[Delimiter=",", Columns=8, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Valor Substituído" = Table.ReplaceValue(#"Cabeçalhos Promovidos",".","",Replacer.ReplaceText,{"Mês Ano"}),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Valor Substituído",{{"Mês Ano", type date}, {"TRI", type text}, {"Célula", type text}, {"Indicador", type text}, {"Desc", type text}, {"Valor", type number}, {"_idIndicador", Int64.Type}, {"_IdLoja", Int64.Type}}),
    #"Valor Substituído1" = Table.ReplaceValue(#"Tipo Alterado","Belas","LojaBelas",Replacer.ReplaceText,{"Célula"})
in
    #"Valor Substituído1"

// ---------- ***fMetasKPI  ->  metas_kpi.xlsx
let
    Fonte = Excel.Workbook(Web.Contents(BaseURL, [RelativePath="metas_kpi.xlsx"]), null, true),
    #"Linhas Filtradas" = Table.SelectRows(Fonte, each ([Kind] = "Sheet")),
    #"Outras Colunas Removidas" = Table.SelectColumns(#"Linhas Filtradas",{"Data"}),
    #"Data Expandido" = Table.ExpandTableColumn(#"Outras Colunas Removidas", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6"}),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(#"Data Expandido", [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"Mês Ano", Int64.Type}, {"Loja", type text}, {"Id", Int64.Type}, {"indicador", type text}, {"Classe", type text}, {"Meta", Int64.Type}}),
    #"Erros Substituídos" = Table.ReplaceErrorValues(#"Tipo Alterado", {{"Meta", null}}),
    #"Erros Substituídos1" = Table.ReplaceErrorValues(#"Erros Substituídos", {{"Id", null}}),
    #"Erros Substituídos2" = Table.ReplaceErrorValues(#"Erros Substituídos1", {{"Mês Ano", null}}),
    #"Tipo Alterado1" = Table.TransformColumnTypes(#"Erros Substituídos2",{{"Mês Ano", type date}, {"Meta", type number}}),
    #"Valor Substituído" = Table.ReplaceValue(#"Tipo Alterado1","Corpore Zeus","Zeus",Replacer.ReplaceText,{"Loja"}),
    #"Valor Substituído1" = Table.ReplaceValue(#"Valor Substituído","Corpore Belas","LojaBelas",Replacer.ReplaceText,{"Loja"}),
    #"Linhas Filtradas1" = Table.SelectRows(#"Valor Substituído1", each ([Loja] = "LojaBelas" or [Loja] = "Zeus"))
in
    #"Linhas Filtradas1"

// ---------- fComissoesProd_Pac  ->  comissoes.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="comissoes.csv"]),[Delimiter=",", Columns=3, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"MesAno", type date}, {"%Pacote", Percentage.Type}, {"%Produto", Percentage.Type}})
in
    #"Tipo Alterado"

// ---------- _DeparaPlanoContas  ->  plano_contas.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="plano_contas.csv"]),[Delimiter=",", Columns=4, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Colunas Removidas" = Table.RemoveColumns(Fonte,{"Column2"}),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(#"Colunas Removidas", [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"Ordem", Int64.Type}}),
    #"Duplicatas Removidas" = Table.Distinct(#"Tipo Alterado", {"DESCRIÇÃO "})
in
    #"Duplicatas Removidas"

// ---------- ---Movimento  ->  movimento_financeiro.csv
let
    Fonte = Csv.Document(Web.Contents(BaseURL, [RelativePath="movimento_financeiro.csv"]),[Delimiter=",", Columns=6, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Colunas Renomeadas" = Table.RenameColumns(#"Cabeçalhos Promovidos",{{"IdCC", "IdCC2"}}),
    #"Tipo Alterado com Localidade" = Table.TransformColumnTypes(#"Colunas Renomeadas", {{"DataKey", type date}}, "en-US"),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Tipo Alterado com Localidade",{{"Valor", type number}})
in
    #"Tipo Alterado"
