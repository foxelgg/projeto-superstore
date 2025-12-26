/* ====================================================================================================
    CAMADA GOLD - DIMENSÃO PRODUCTS
    Este arquivo documenta a evolução da camada Silver para a camada Gold. Nesse arquivo estarão
    registrados os seguintes processos:
    
    - Decisão do modelo dimensional da camada Gold
    - Definição do grão: Um registro por produto (product_id)
    - Criação da Tabela Dimensão: dim_products, com tipos corretos e constraints definidas

    - A fonte dos dados que alimentarão a tabela dim_products é a tabela silver_orders, que foi validada 
    e contém dados confiáveis para análise.

    - Os detalhes sobre a modelagem dimensional da tabela dim_products são encontrados no arquivo 
    README.md.
    ==================================================================================================== */

-- Criação da tabela dim_products
DROP TABLE IF EXISTS dim_products; 

CREATE TABLE dim_products (
    product_id TEXT NOT NULL PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    sub_category TEXT NOT NULL
);

-- Inserção de dados na tabela dim_products
INSERT INTO dim_products (
    product_id,
    product_name,
    category,
    sub_category
)
SELECT DISTINCT
    product_id,
    MIN(product_name), -- uso de MIN() necessário para consolidar PK duplicada por valores descritivos diferentes. Documentado em dq_rules.md.
    MIN(category),
    MIN(sub_category)
FROM silver_orders
GROUP BY product_id;
