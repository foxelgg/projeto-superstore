/* ====================================================================================================
    CAMADA BRONZE - RETURNS
    - Este arquivo documenta a criação da tabela bronze_returns, bem como a carga dos dados do dataset,
     oriundos do arquivo 'returns.csv'.

    - Os dados são carregados sem qualquer alteração, limpeza ou transformação, com o intuito de assegurar
    a rastreabilidade dos dados e manter a fidelidade total ao arquivo CSV original.

    Observações Técnicas
    - A carga utiliza o comando '\COPY' (psql)
    - O arquivo CSV foi previamente normalizado para UTF-8
    - Para mais detalhes sobre o processo de ingestão e encoding, ver bronze_orders.sql.
    ==================================================================================================== */

-- ==================================
-- CRIAÇÃO DA TABELA BRONZE_RETURNS
-- ==================================

DROP TABLE IF EXISTS bronze_returns;

CREATE TABLE bronze_returns (
    "Returned" TEXT,
    "Order ID" TEXT
);

-- ================================
-- CARGA DA TABELA BRONZE_RETURNS
-- ================================

\COPY bronze_returns
FROM 'data/raw/returns.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ';'
);