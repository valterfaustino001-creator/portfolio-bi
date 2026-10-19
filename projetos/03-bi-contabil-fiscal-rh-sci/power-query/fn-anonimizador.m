// =============================================================
// fnAnonimizador
// Mascara o meio de um texto, mantendo N caracteres no início e no fim.
// Uso: demonstrar relatórios sem expor nomes de pessoas ou empresas.
//
// Exemplos:
//   fnAnonimizador("Maria Silva", 3)        -> "Mar*****lva"
//   fnAnonimizador("Maria Silva", 3, 12)    -> "Mar******lva"  (força 12 caracteres no total)
//
// Aplicar numa coluna:
//   Table.TransformColumns(Fonte, {{"Nome", each fnAnonimizador(_, 3), type text}})
// =============================================================

(
    Nome as text,
    CaracteresPermitidosInicioFim as number,
    optional QuantidadeCaracteresForcada as number
) =>
let
    Caracteres = Text.Length(Nome),

    Ini =
        if Caracteres >= CaracteresPermitidosInicioFim
        then CaracteresPermitidosInicioFim
        else Caracteres,

    Fim =
        if Caracteres - CaracteresPermitidosInicioFim > 0 then
            (
                if Caracteres - CaracteresPermitidosInicioFim >= CaracteresPermitidosInicioFim
                then CaracteresPermitidosInicioFim
                else Caracteres - CaracteresPermitidosInicioFim
            )
        else 0,

    Miolo =
        if QuantidadeCaracteresForcada <> null
        then QuantidadeCaracteresForcada - Ini - Fim
        else Caracteres - Ini - Fim,

    NomeSemMiolo =
        Text.Start(Nome, Ini)
        & Text.Repeat("*", Miolo)
        & Text.End(Nome, Fim)
in
    NomeSemMiolo
