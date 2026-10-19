# Especificação técnica (resumo)

Versão resumida e anonimizada da especificação que escrevi para reconstruir o ETL do zero, dentro ou fora do Pentaho. O documento original tem cerca de 1.000 linhas, com o SQL de todas as transformações, e acompanha um manual passo a passo de 9 partes para o Spoon.

## 1. Ambiente

- Pentaho PDI CE 9.4 (Java 11), execução por linha de comando com `Kitchen`.
- Driver JDBC do Firebird (Jaybird), copiado para `data-integration/lib`.
- PostgreSQL de destino, schema `sci`.
- Agendamento externo (Agendador de Tarefas do Windows).

## 2. Orquestração

```
Job mestre
 └─ job_transformacoes (Start com "Run next entries in parallel")
      ├─ set_variables → delete → get_empresas → balancete (1x por empresa)
      ├─ 12 transformações de cópia simples (truncate + insert)
      └─ cada ramo, em caso de falha → SQL que grava o erro em sci.controle_carga
 └─ Controle_carga_ini (grava o sucesso)
```

Convenções do PDI usadas:

- **Hop verde:** segue em caso de sucesso. **Vermelho:** segue em caso de falha.
- **Execute for every input row:** a entrada roda uma vez para cada linha deixada pela anterior (*Copy rows to result*).

## 3. Janela de meses (`set_variables`)

1. *Get system info* → primeiro dia do mês corrente.
2. *Calculator* → `ADD_MONTHS(-1)` encadeado, gerando `mes_00_inicio`, `mes_01_inicio`, …
3. *Formula* → `MONTHEND()` para o fim de cada mês.
4. *Replace in string* (regex `(^.{4})\/(\d{2})\/(\d{2}).+` → `$3.$2.$1`) → formato `dd.MM.yyyy`.
5. *Set variables* com escopo *root job*.

Exemplo de execução em 10/03/2026: `MES_00` = 01.03.2026 a 31.03.2026; `MES_02` = 01.01.2026 a 31.01.2026. Implementação equivalente em [`../python/janela_meses.py`](../python/janela_meses.py).

## 4. Balancete (`vsuc_empresas_tlan`)

- Uma execução por empresa; dentro dela, um *Table input* por mês da janela.
- Os fluxos convergem num passo *Formula* que cria `PERIODO` (date, 1º dia do mês).
- *Select values* renomeia os campos genéricos do driver (`MIN`→`BDCODEMP`, `SUM_4`→`BDSALDO_ATUAL` etc.).
- *Replace in string* troca caracteres especiais do nome da conta por espaço.
- *Table output* sem truncate (a limpeza foi feita antes, pelo passo `delete`).

Regras de negócio no SQL:

- Natureza da conta: grupos 0, 4, 5 = Débito; grupos 1, 2, 3 = Crédito.
- Nível: tipo 0 = Título (sintética); demais = Analítica.
- Saldos (anterior, débito, crédito, movimento, atual) somados por empresa, plano e conta.

## 5. Cópias simples

Padrão: *Table input* (Firebird) → *Select values* (renomeação e tipos de data `dd/MM/yyyy`) → *Table output* (PostgreSQL, *truncate*, commit 1000, *batch insert*).

Regras de destaque:

- **Notas de saída:** canceladas ficam de fora (`BDDATACANC IS NULL`), com valores somados por documento e natureza.
- **Afastamentos:** só os em aberto, de colaboradores não rescindidos.
- **Centro de custo do colaborador:** o mais recente (maior data de entrada).

## 6. Critérios de aceite

1. Para uma empresa e um mês, `sum(bdsaldo_atual)` no PostgreSQL bate com o balancete emitido no ERP.
2. Depois da rotina diária, `max(periodo)` = 1º dia do mês corrente, sem duplicidade por `(empresa, plano, conta, período)`.
3. `sci.controle_carga` recebe uma linha de sucesso por execução e uma linha de erro por ramo que falhar.

## 7. Solução de problemas

| Sintoma | Causa provável | O que fazer |
|---|---|---|
| "Driver class org.firebirdsql.jdbc.FBDriver could not be found" | Jaybird não instalado | Copiar o `.jar` para `data-integration/lib` e reabrir o Spoon |
| Colunas chamadas `SUM`, `CASE`, `CAST` no destino | Faltou o *Select values* | Renomear os campos |
| Balancete com linhas duplicadas | O *delete* não rodou antes do *insert* | Rodar sempre pelo job, nunca a transformação sozinha |
| `${MES_00_INICIO}` aparece literal no SQL | Falta "Replace variables in script" | Marcar a opção e rodar pelo job |
| Job termina OK mas uma tabela ficou vazia | Um ramo paralelo falhou e só gravou o erro | Consultar `sci.controle_carga` |
