# Padrões de desenvolvimento que uso nos projetos

## Modelagem

- **Star schema:** fatos com prefixo `f`, dimensões com `d`, parâmetros com `p`, auxiliares com `Aux`.
- **Uma calendário principal** relacionada às fatos. Datas alternativas (emissão, pagamento, venda) ficam como relacionamentos **inativos**, ativados com `USERELATIONSHIP`.
- **Auto Date/Time desligado.**
- Chaves compostas montadas no SQL (ex.: `empresa || categoria`) para modelos multiempresa.

## DAX

- Medidas em tabelas de medidas por tema (`DRE`, `Faturamento`, `Fluxo de Caixa`…), com pastas de exibição.
- `VAR` / `RETURN` em toda medida com mais de uma etapa.
- `DIVIDE` em vez de `/`.
- Medidas de cor e de rótulo separadas das de valor, para formatação condicional e títulos dinâmicos.
- Em despesa, variação positiva = estouro (lógica invertida em relação à receita).

## Power Query (M)

- `Value.NativeQuery(..., [EnableFolding = true])` para manter o *query folding*.
- Parâmetros para servidor, banco, schema e empresa: o mesmo arquivo vira template para vários clientes.
- *Joins* feitos no SQL de origem, não com *merge* entre consultas carregadas.

## Publicação

- **Modelo semântico** publicado uma vez; **relatórios finos** em conexão dinâmica.
- Páginas de detalhe (*drill-through*) e *tooltips* ocultas, com navegação por botões.
