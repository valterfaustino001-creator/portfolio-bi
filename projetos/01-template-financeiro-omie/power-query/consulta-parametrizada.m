// =============================================================
// Consulta nativa parametrizada (template multiempresa)
// Parâmetros do arquivo:
//   Server  -> host do PostgreSQL           (ex.: "meu-servidor.postgres.database.azure.com")
//   DB      -> banco                         (ex.: "erp")
//   Schema  -> schema da camada tratada      (ex.: "treated_layer")
//   cd40_id -> lista de empresas do cliente  (ex.: "'101','102'")
//
// EnableFolding=true faz o Power BI empurrar etapas seguintes para o banco,
// e o filtro por empresa roda no próprio PostgreSQL.
// =============================================================

let
    Fonte = Value.NativeQuery(
        PostgreSQL.Database(Server, DB),
        "
            select *
            from " & Schema & ".fcontratos
            where cd40_id in (" & cd40_id & ")
        ",
        null,
        [EnableFolding = true]
    )
in
    Fonte


// -------------------------------------------------------------
// Calendário vindo do banco (tabela de apoio única para todos os clientes)
// -------------------------------------------------------------
// let
//     Fonte = Value.NativeQuery(
//         PostgreSQL.Database(Server, DB),
//         "SELECT data ""Data"", nome_dia ""Nome dia"", dia_semana ""Dia Semana"",
//                 ""Dia"", ""Mes"", ""NomeMes"", ""Trimestre"", ""Ano"", ""MesAno"",
//                 ""yymm"", ""workday"", ""Semana""
//          FROM support_tables.dcalendario",
//         null,
//         [EnableFolding = true]
//     )
// in
//     Fonte
