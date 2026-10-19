// =============================================================
// Tabular Editor (Advanced Scripting) — limpeza de modelo
// Modelo genérico do script entregue na auditoria.
// Rode numa CÓPIA do .pbix, com backup.
// =============================================================

// 1. Remove as tabelas de data criadas pelo Auto Date/Time
//    (depois, desligue a opção em Arquivo > Opções > Carregamento de dados)
foreach (var t in Model.Tables.ToList())
{
    if (t.Name.StartsWith("LocalDateTable_") || t.Name.StartsWith("DateTableTemplate_"))
        t.Delete();
}

// 2. Remove tabelas órfãs confirmadas pela análise de dependência
var tabelasOrfas = new[] { "TabelaLegada1", "TabelaLegada2" };   // preencher com o inventário
foreach (var nome in tabelasOrfas)
    if (Model.Tables.Contains(nome)) Model.Tables[nome].Delete();

// 3. Marca a calendário como tabela de datas
var cal = Model.Tables["dCalendário"];
cal.DataCategory = "Time";
cal.Columns["Data"].IsKey = true;

// 4. (Opcional) Remove medidas sem uso, depois de revisão manual
// var medidasSemUso = new[] { "Medida A", "Medida B" };
// foreach (var m in Model.AllMeasures.Where(x => medidasSemUso.Contains(x.Name)).ToList())
//     m.Delete();

Info("Limpeza concluída. Salve e valide o refresh.");
