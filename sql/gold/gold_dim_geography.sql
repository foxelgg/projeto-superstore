/* ====================================================================================================
    CAMADA GOLD - DIMENSÃO GEOGRAPHY
    Este arquivo documenta a evolução da camada Silver para a camada Gold. Nesse arquivo estarão
    registrados os seguintes processos:
    
    - Decisão do modelo dimensional da camada Gold
    - Definição do grão: Um registro por geolocalidade (geography_id)
    - Criação da Tabela Dimensão: dim_geography, com tipos corretos e constraints definidas

    - A fonte dos dados que alimentarão a tabela dim_geography é a tabela silver_orders, que foi validada 
    e contém dados confiáveis para análise.

    - Os detalhes sobre a modelagem dimensional da tabela dim_geography são encontrados no arquivo 
    README.md.
    ==================================================================================================== */

-- Criação da tabela dim_geography
DROP TABLE IF EXISTS dim_geography;

CREATE TABLE dim_geography (
    geography_id SERIAL PRIMARY KEY,
    country TEXT NOT NULL,
    state TEXT NOT NULL,
    city TEXT NOT NULL,
    region TEXT NOT NULL,
    CONSTRAINT unique_geography UNIQUE (country, state, city)
);

-- Inserção de dados na tabela dim_geography
INSERT INTO dim_geography (
    country,
    state,
    city,
    region
)
SELECT DISTINCT
    country,
    state,
    city,
    region
FROM silver_orders;

-- Adicionando a coluna city + state na tabela dim_geography - Útil para evitar ambiguidades na criação de visuais de mapas no Power BI
ALTER TABLE dim_geography
ADD COLUMN city_state TEXT;

-- Inserção de dados na coluna city_state
UPDATE dim_geography
SET city_state = CONCAT(city, ', ', state, ', USA');