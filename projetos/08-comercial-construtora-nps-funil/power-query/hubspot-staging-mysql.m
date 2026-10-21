// =============================================================
// Negócios do HubSpot lidos da camada de staging em MySQL
// (servidor e banco substituídos por exemplos)
// =============================================================
let
    Fonte = MySQL.Database("servidor-staging", "dbstage", [ReturnSingleDatabase = true]),
    Deals = Fonte{[Schema = "dbstage", Item = "hs_deal"]}[Data],
    Tipos = Table.TransformColumnTypes(
        Deals,
        {
            {"createdate", type date},
            {"data_da_primeira_visita", type date},
            {"data_proposta", type date},
            {"data_do_descarte", type date},
            {"closedate", type date}
        }
    )
in
    Tipos
