-- =============================================================
-- get_empresas (origem: Firebird / ERP SCI)
-- Empresas ativas na competência atual, só pessoa jurídica,
-- excluindo clientes do tipo 3.
-- O resultado vai para "Copy rows to result" e dispara o balancete
-- uma vez por empresa.
-- =============================================================
select EMP.BDCODEMP empresa
from SP_CONSULTAEMPRESAS((select BDAAAAMM from aaaamm(current_date)), 0, null) EMP
where not exists (
        select BDCODCLI
        from VFIN_BASE_TCLIENTE CLI
        where CLI.BDCODCLI = EMP.BDCODCLI
          and CLI.BDCODTIPOCLI = 3
      )
  and strlen(EMP.BDCNPJEMP) > 15;   -- CNPJ formatado (pessoa jurídica)
