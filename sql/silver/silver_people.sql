/* ====================================================================================================
    CAMADA SILVER - PEOPLE
    Este arquivo documenta todos os processos que ocorrerão na camada Silver referentes a tabela people.
    Os processos que serão executados, em ordem:
    
    - Data Profiling: Análise exploratória da tabela bronze_people, com o intuito de identificar erros,
    inconsistências, duplicidades ou qualquer padrão relevante que impacte na modelagem e tipagem dos
    dados. Nenhuma transformação ou correção ocorre durante o Profiling.
    
    - Definição do Modelo: A partir do Data Profiling, serão definidos os tipos corretos dos dados
    de cada coluna. A modelagem dimensional ocorrerá na camada Gold.
    
    - Criação da Tabela Silver: Criação da tabela da camada Silver, com tipos corretos de dados,
    representando a versão confiável dos dados originais (camada Bronze).

    - Carga e Transformação da Tabela Silver: Inserção de dados da tabela bronze_people na tabela
    silver_people, aplicando conversões de tipagem, visto que a tabela bronze segue padrão TEXT para
    todas as colunas, padronizações simples de campos e flags de qualidade de dados, sempre que
    necessário.

    - Validação Pós-carga: Execução de queries de validação para verificar se a carga e transformação
    ocorreram com êxito, sem perdas de registros ou inconsistências.

    - As regras de qualidade definidas e aplicadas nesta etapa estão devidamente documentadas no 
    arquivo 'dq_rules.md'.
    ==================================================================================================== */

-- ================
-- DATA PROFILING
-- ================

-- Verificar cardinalidade da tabela 
SELECT
    COUNT(*) AS total_linhas,
    COUNT(DISTINCT "Region") AS regioes_distintas,
    COUNT(DISTINCT "Person") AS pessoas_distintas
FROM bronze_people;

-- Verificar consistência do domínio
SELECT
    COUNT(DISTINCT p."Region") AS regioes_sem_correspondencia
FROM bronze_people p
LEFT JOIN bronze_orders o
    ON p."Region" = o."Region"
WHERE o."Region" IS NULL;

-- Verificar registros nulos ou strings vazias
SELECT
    COUNT(*) FILTER (WHERE "Person" IS NULL OR TRIM("Person") = '') AS pessoa_invalida,
    COUNT(*) FILTER (WHERE "Region" IS NULL OR TRIM("Region") = '') AS regiao_invalida
FROM bronze_people;

-- ================================
-- CRIAÇÃO DA TABELA SILVER_PEOPLE
-- ================================

DROP TABLE IF EXISTS silver_people;

CREATE TABLE silver_people (
    person TEXT,
    region TEXT
);

-- ==============================
-- CARGA DA TABELA SILVER_PEOPLE
-- ==============================

INSERT INTO silver_people (
    person,
    region
)
SELECT
    CAST("Person" AS TEXT),
    CAST("Region" AS TEXT)
FROM bronze_people;

-- ==============================
-- VALIDAÇÃO PÓS-CARGA (SILVER)
-- ==============================
-- As queries abaixo asseguram que:
-- a. Nenhum dado foi perdido na carga da tabela Silver
-- b. Nenhum valor inesperado surgiu após a carga
-- c. A consistência de domínio se manteve após a carga
-- d. Os dados estão aptos para modelagem dimensional na camada Gold

-- Verificar contagem de registros
SELECT
    (SELECT COUNT(*) FROM bronze_people) AS bronze_count,
    (SELECT COUNT(*) FROM silver_people) AS silver_count;

-- Verificar NULLs ou strings vazias pós carga
SELECT
    COUNT(*) FILTER (WHERE person IS NULL OR TRIM(person) = '') AS pessoa_invalida,
    COUNT(*) FILTER (WHERE region IS NULL OR TRIM(region) = '') AS regiao_invalida
FROM silver_people;

-- Verificar consistência de domínio pós carga
SELECT
    COUNT(DISTINCT p.region) AS regioes_sem_correspondencia
FROM silver_people p
LEFT JOIN silver_orders o
    ON p.region = o.region
WHERE o.region IS NULL;