-- =============================================================
-- Balancete mensal de uma empresa (origem: Firebird / ERP SCI)
-- ${MES_00_INICIO} / ${MES_00_FIM}: variáveis do PDI no formato dd.MM.yyyy
-- ?                              : código da empresa (vem do passo get_empresa)
-- O mesmo SQL roda para MES_00 .. MES_02 (diária) ou MES_00 .. MES_24 (anual).
-- =============================================================
select MIN(BALAN.BDCODEMP)        as BDCODEMP,
       MIN(BALAN.BDCNPJEMP)       as BDCNPJEMP,
       MIN(BALAN.BDNOMEMP)        as BDNOMEMP,
       BALAN.BDCODPLAPADRAO       as BDCODPLAPADRAO,
       BALAN.BDCODCTA             as BDCODCTA,
       BALAN.BDCTALON             as BDCTALON,
       BALAN.BDNOMCTA             as BDNOMCTA,
       MAX(BALAN.BDGRPCTA)        as BDGRPCTA,
       case                                              -- natureza da conta
         when MAX(BALAN.BDGRPCTA) in (0,4,5) then 'Debito'
         when MAX(BALAN.BDGRPCTA) in (1,2,3) then 'Credito'
         else 'Debito'
       end                        as BDDEBCRE,
       MAX(BALAN.BDTIPCTA)        as BDTIPCTA,
       case when MAX(BALAN.BDTIPCTA) = 0 then 'Titulo' else 'Analitico' end as BDNIVELCTA,
       SUM(BALAN.BDSALDO_ANTERIOR) as BDSALDO_ANTERIOR,
       SUM(BALAN.BDSALDO_DEB)      as BDSALDO_DEB,
       SUM(BALAN.BDSALDO_CRE)      as BDSALDO_CRE,
       SUM(BALAN.BDMOVIMENTO)      as BDMOVIMENTO,
       SUM(BALAN.BDSALDO_ATUAL)    as BDSALDO_ATUAL
from VW_EMPRESAS_REF_ATUAL EMP
cross join VSUC_SP_RETORNA_BALANCETE(
        EMP.BDCODEMP,
        '${MES_00_INICIO}', '${MES_00_FIM}',
        1,
        (select first 1 PLA.BDCODTPLA from PLANOS_TPLA PLA          -- primeira conta do plano
          where PLA.BDCODPLAPADRAO = EMP.BDCODPLAPADRAO
          order by PLA.BDCODPLAPADRAO, PLA.BDCTALON),
        (select first 1 PLA.BDCODTPLA from PLANOS_TPLA PLA          -- última conta do plano
          where PLA.BDCODPLAPADRAO = EMP.BDCODPLAPADRAO
          order by PLA.BDCODPLAPADRAO desc, PLA.BDCTALON desc),
        0, '', (select BDAAAAMM from aaaamm(current_date)),
        0, 0, 1, 1, 1, 0, 0, '1,2,3,4,5,6,7,8,9', 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
     ) BALAN
where EMP.BDCODPLAPADRAO is not null
  and EMP.BDCODEMP = ?
group by BALAN.BDCODEMP, BALAN.BDCODPLAPADRAO, BALAN.BDCODCTA, BALAN.BDCTALON, BALAN.BDNOMCTA
order by BALAN.BDCODEMP, BALAN.BDCTALON;
