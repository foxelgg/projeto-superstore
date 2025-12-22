/* ====================================================================================================
    CAMADA SILVER - RETURNS
    Este arquivo documenta todos os processos que ocorrerão na camada Silver referentes a tabela returns.
    Os processos que serão executados, em ordem:
    
    - Data Profiling: Análise exploratória da tabela bronze_returns, com o intuito de identificar erros,
    inconsistências, duplicidades ou qualquer padrão relevante que impacte na modelagem e tipagem dos
    dados. Nenhuma transformação ou correção ocorre durante o Profiling.
    
    - Definição do Modelo: A partir do Data Profiling, serão definidos os tipos corretos dos dados
    de cada coluna. A modelagem dimensional ocorrerá na camada Gold.
    
    - Criação da Tabela Silver: Criação da tabela da camada Silver, com tipos corretos de dados,
    representando a versão confiável dos dados originais (camada Bronze).

    - Carga e Transformação da Tabela Silver: Inserção de dados da tabela bronze_returns na tabela
    silver_returns, aplicando conversões de tipagem, visto que a tabela bronze segue padrão TEXT para
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

-- Verificar cardinalidade e granularidade da tabela
SELECT 
    COUNT(*) AS total_linhas,
    COUNT(DISTINCT "Order ID") AS pedidos_distintos
FROM bronze_returns; -- Cada linha da tabela representa o retorno de um order_id único.

-- Verificar registros nulos ou strings vazias
SELECT
    COUNT(*) FILTER (WHERE "Returned" IS NULL OR TRIM("Returned") = '') AS returned_invalido,
    COUNT(*) FILTER (WHERE "Order ID" IS NULL OR TRIM("Order ID") = '') AS order_id_invalido
FROM bronze_returns;

-- Verificar integridade referencial com a tabela orders
SELECT
    COUNT(*) AS pedidos_sem_correspondencia
FROM bronze_returns r
LEFT JOIN bronze_orders o
    ON r."Order ID" = o."Order ID"
WHERE o."Order ID" IS NULL;

-- Verificar se a coluna Returned apresenta valores iguais
SELECT
    "Returned",
    COUNT(*)
FROM bronze_returns
GROUP BY "Returned";

-- =================================
-- CRIAÇÃO DA TABELA SILVER_RETURNS
-- =================================

DROP TABLE IF EXISTS silver_returns;

CREATE TABLE silver_returns (
    returned TEXT,
    order_id TEXT
);

-- ===============================
-- CARGA DA TABELA SILVER_RETURNS
-- ===============================

INSERT INTO silver_returns (
    returned,
    order_id
)
SELECT
    CAST("Returned" AS TEXT),
    CAST("Order ID" AS TEXT)
FROM bronze_returns;

-- ==============================
-- VALIDAÇÃO PÓS-CARGA (SILVER)
-- ==============================
-- As queries abaixo asseguram que:
-- a. Nenhum dado foi perdido na carga da tabela Silver
-- b. Nenhum valor nulo inesperado surgiu após a carga
-- c. A integridade referencial se manteve após a carga
-- d. Os dados estão aptos para modelagem dimensional na camada Gold

-- Verificar contagem de registros
SELECT
    (SELECT COUNT(*) FROM bronze_returns) AS bronze_count,
    (SELECT COUNT(*) FROM silver_returns) AS silver_count;

-- Verificar NULLs ou strings vazias após carga
SELECT
    COUNT(*) FILTER (WHERE returned IS NULL OR TRIM(returned) = '') AS returned_invalido,
    COUNT(*) FILTER (WHERE order_id IS NULL OR TRIM(order_id) = '') AS order_id_invalido
FROM silver_returns;

-- Verificar consistência de domínio na coluna 'Returned'
SELECT
    COUNT(*) FILTER (WHERE returned NOT IN ('Yes')) AS returned_invalido
FROM silver_returns;

-- Verificar integridade referencial pós carga
SELECT
    COUNT(*) AS orders_sem_correspondencia
FROM silver_returns r
LEFT JOIN silver_orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;