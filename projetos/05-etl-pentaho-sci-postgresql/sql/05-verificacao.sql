-- =============================================================
-- Consultas de verificação pós-carga (PostgreSQL)
-- =============================================================

-- 1. Última carga bem-sucedida e erros recentes
select * from sci.controle_carga order by ini_carga desc limit 50;

-- 2. Volume do balancete por mês
select periodo, count(*) as linhas, count(distinct bdcodemp) as empresas
from sci.vsuc_empresas_tlan
group by periodo
order by periodo desc;

-- 3. Duplicidade (deve retornar zero linhas)
select bdcodemp, bdcodplapadrao, bdcodcta, periodo, count(*)
from sci.vsuc_empresas_tlan
group by 1, 2, 3, 4
having count(*) > 1;

-- 4. Critério de aceite: o mês mais recente deve ser o mês corrente
select max(periodo) = date_trunc('month', current_date)::date as carga_em_dia
from sci.vsuc_empresas_tlan;
