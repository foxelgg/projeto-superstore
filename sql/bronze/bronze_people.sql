/* ====================================================================================================
    CAMADA BRONZE - PEOPLE
    - Este arquivo documenta a criação da tabela bronze_people, bem como a carga dos dados do dataset,
     oriundos do arquivo 'people.csv'.

    - Os dados são carregados sem qualquer alteração, limpeza ou transformação, com o intuito de assegurar
    a rastreabilidade dos dados e manter a fidelidade total ao arquivo CSV original.

    Observações Técnicas
    - A carga utiliza o comando '\COPY' (psql)
    - O arquivo CSV foi previamente normalizado para UTF-8
    - Para mais detalhes sobre o processo de ingestão e encoding, ver bronze_orders.sql.
    ==================================================================================================== */

-- =================================
-- CRIAÇÃO DA TABELA BRONZE_PEOPLE
-- =================================

DROP TABLE IF EXISTS bronze_people;

CREATE TABLE bronze_people (
    "Person" TEXT,
    "Region" TEXT
);

-- ===============================
-- CARGA DA TABELA BRONZE_PEOPLE
-- ===============================

\COPY bronze_people
FROM 'data/raw/people.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ';'
);

