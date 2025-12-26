/* ====================================================================================================
    CAMADA GOLD - DIMENSÃO DATE
    Este arquivo documenta a evolução da camada Silver para a camada Gold. Nesse arquivo estarão
    registrados os seguintes processos:
    
    - Decisão do modelo dimensional da camada Gold
    - Definição do grão: Um registro por data (date_id)
    - Criação da Tabela Dimensão: dim_date, com tipos corretos e constraints definidas

    - A fonte dos dados que alimentarão a tabela dim_date é a tabela silver_orders, que foi validada 
    e contém dados confiáveis para análise.

    - Os detalhes sobre a modelagem dimensional da tabela dim_date são encontrados no arquivo README.md.
    ==================================================================================================== */

-- Criação da tabela dim_date
DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name TEXT NOT NULL,
    quarter TEXT NOT NULL,
    day_of_week TEXT NOT NULL
);

-- Inserção de dados na tabela dim_date a partir da tabela silver_orders
INSERT INTO dim_date (
    full_date,
    year,
    month,
    month_name,
    quarter,
    day_of_week
)
SELECT
    full_date,
    EXTRACT(YEAR FROM full_date) AS year,
    EXTRACT(MONTH FROM full_date) AS month,
    TO_CHAR(full_date, 'Month') AS month_name,
    TO_CHAR(full_date, 'Q') AS quarter,
    TO_CHAR(full_date, 'Day') AS day_of_week
FROM (
    SELECT order_date AS full_date FROM silver_orders
    UNION
    SELECT ship_date AS full_date FROM silver_orders
)
ORDER BY full_date;
