/* ====================================================================================================
    CAMADA BRONZE - ORDERS
    - Este arquivo documenta a criação da tabela bronze_orders, bem como a carga dos dados do dataset,
     oriundos do arquivo 'orders.csv'.

    - Na camada bronze, os arquivos serão mantidos exatamente como chegaram do dataset original, ou seja,
     não haverá nenhum tipo de alteração, limpeza ou reorganização de quaisquer dados. Dados crus,
     assim como são encontrados no arquivo CSV original.

    - As tabelas serão criadas utilizando todos os tipos de dados como TEXT, afim de evitar possíveis
     erros de ingestão no banco de dados. Em camadas posteriores, os tipos corretos de cada dado serão
     introduzidos, substituindo TEXT nos casos necessários.

    CONVERSÃO DE ENCODING
    - Antes da carga, o arquivo CSV original foi convertido de WIN1252 para UTF-8, para evitar falhas
     na hora de carregar dados utilizando '\COPY'.
    - Conversão realizada no VSCode: 
        Reopen with Encoding -> WIN1252
        Save with Encoding -> UTF-8

    CARGA DA TABELA BRONZE_ORDERS
    - A carga se deu através do comando '\COPY' que é específico do psql, e portanto deve ser executado
     **EM SESSÃO PSQL**, que executei no terminal dentro do VSCode.
    - Exemplo de execução:
        cd projeto_superstore_analysis
        psql -h localhost -U postgres -d projeto_superstore -p 5433
    ==================================================================================================== */

-- ==================================
-- CRIAÇÃO DA TABELA BRONZE_ORDERS
-- ==================================

DROP TABLE IF EXISTS bronze_orders;

CREATE TABLE bronze_orders (
    "Row ID" TEXT,
    "Order ID" TEXT,
    "Order Date" TEXT,
    "Ship Date" TEXT,
    "Ship Mode" TEXT,
    "Customer ID" TEXT,
    "Customer Name" TEXT,
    "Segment" TEXT,
    "Country" TEXT,
    "City" TEXT,
    "State" TEXT,
    "Postal Code" TEXT,
    "Region" TEXT,
    "Product ID" TEXT,
    "Category" TEXT,
    "Sub-Category" TEXT,
    "Product Name" TEXT,
    "Sales" TEXT,
    "Quantity" TEXT,
    "Discount" TEXT,
    "Profit" TEXT
);

-- ===========================================================
-- CARGA DA TABELA BRONZE_ORDERS - EXECUTAR NO TERMINAL PSQL
-- ===========================================================

\COPY bronze_orders
FROM 'data/raw/orders.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ';'
);