-- =============================================================
-- Gera um intervalo por mês, de 01/2019 até o mês atual (PostgreSQL)
-- Usado pela carga histórica: o job roda o balancete uma vez por linha.
-- =============================================================
with recursive DateRanges as (
    select
        date '2019-01-01' as StartDate,
        (date '2019-01-01' + interval '1 month' - interval '1 day') as EndDate
    union all
    select
        (EndDate + interval '1 day')::date,
        (EndDate + interval '1 day' + interval '1 month' - interval '1 day')::date
    from DateRanges
    where EndDate + interval '1 day' < current_date
)
select
    to_char(StartDate, 'DD.MM.YYYY') as StartDate,
    to_char(EndDate,   'DD.MM.YYYY') as EndDate
from DateRanges;
