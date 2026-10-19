// =============================================================
// Ingestão de planilhas anuais publicadas como CSV
// Cada ano é uma consulta; a tabela final empilha todas.
// (URLs substituídas por exemplos)
// =============================================================

// --- Consulta de um ano: fFaturamentoServicos2025 ---
let
    Fonte = Csv.Document(
        Web.Contents("https://docs.google.com/spreadsheets/d/e/<ID_PUBLICACAO>/pub?output=csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    Cabecalhos = Table.PromoteHeaders(Fonte, [PromoteAllScalars = true]),
    Tipos = Table.TransformColumnTypes(
        Cabecalhos,
        {{"Data", type date}, {"Valor", Currency.Type}, {"Quantidade", Int64.Type}},
        "pt-BR"
    )
in
    Tipos


// --- Tabela final: empilha todos os anos ---
// let
//     Fonte = Table.Combine({
//         fFaturamentoServicos2021, fFaturamentoServicos2022, fFaturamentoServicos2023,
//         fFaturamentoServicos2024, fFaturamentoServicos2025, fFaturamentoServicos2026
//     })
// in
//     Fonte
