-- =============================================================
-- Schema de destino e tabelas de controle de carga (PostgreSQL)
-- =============================================================
create schema if not exists sci;

-- Uma linha por execução: sucesso (mensagem nula) ou "Erro na transformação X"
create table if not exists sci.controle_carga (
    data_carga  date,
    ini_carga   timestamp,
    mensagem    varchar(255)
);

-- Início e fim da carga histórica
create table if not exists sci.controle_carga_inicial (
    data_hora   timestamp,
    etapa       varchar(50)
);

-- Melhoria proposta: chave primária no balancete para impedir duplicidade
-- alter table sci.vsuc_empresas_tlan
--     add constraint pk_vsuc_empresas_tlan
--     primary key (bdcodemp, bdcodplapadrao, bdcodcta, periodo);
