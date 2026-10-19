// =============================================================
// Movimento financeiro por competência
// Parâmetros: Server, DB_v2, Schema, cd40_id (lista de empresas)
// =============================================================

let
    // 1. Conexão e consulta SQL (filtro de empresa executado no banco)
    Fonte = Value.NativeQuery(
        PostgreSQL.Database(Server, DB_v2),
        "
            select *
            from " & Schema & ".fmovfin_competencia
            where cd40_id in (" & cd40_id & ")
        ",
        null,
        [EnableFolding = true]
    )
in
    Fonte
