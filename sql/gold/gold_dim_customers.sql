/* ====================================================================================================
    CAMADA GOLD - DIMENSÃO CUSTOMERS
    Este arquivo documenta a evolução da camada Silver para a camada Gold. Nesse arquivo estarão
    registrados os seguintes processos:
    
    - Decisão do modelo dimensional da camada Gold
    - Definição do grão: Um registro por cliente (customer_id)
    - Criação da Tabela Dimensão: dim_customers, com tipos corretos e constraints definidas

    - A fonte dos dados que alimentarão a tabela dim_customers é a tabela silver_orders, que foi validada 
    e contém dados confiáveis para análise.

    - Os detalhes sobre a modelagem dimensional da tabela dim_customers são encontrados no arquivo 
    README.md.
    ==================================================================================================== */

-- Criação da tabela dim_customers
DROP TABLE IF EXISTS dim_customers;

CREATE TABLE dim_customers (
    customer_id TEXT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    segment TEXT NOT NULL
);

-- Inserção de dados na tabela dim_customers
INSERT INTO dim_customers (
    customer_id,
    customer_name,
    segment
)
SELECT DISTINCT
    customer_id,
    customer_name,
    segment
FROM silver_orders;
