/* ====================================================================================================
    CAMADA GOLD - FATO SALES
    Este arquivo documenta a evolução da camada Silver para a camada Gold. Nesse arquivo estarão
    registrados os seguintes processos:
    
    - Decisão do modelo dimensional da camada Gold
    - Definição do grão: Um registro por item de pedido
    - Criação da Tabela Fato: fato_sales, com tipos corretos e constraints definidas

    - A fonte dos dados que alimentarão a tabela fato_sales são as tabelas silver_orders e silver_returns,
    que foram validadas e contém dados confiáveis para análise.

    - Os detalhes sobre a modelagem dimensional da tabela fato_sales são encontrados no arquivo README.md.
    ==================================================================================================== */

-- Criação da tabela fato_sales
DROP TABLE IF EXISTS fato_sales;

CREATE TABLE fato_sales (
    fato_sales_id SERIAL PRIMARY KEY,
    order_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    customer_id TEXT NOT NULL,
    geography_id INTEGER NOT NULL,
    order_date_id INTEGER NOT NULL,
    ship_date_id INTEGER NOT NULL,
    ship_mode TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    sales NUMERIC(10,2) NOT NULL,
    discount NUMERIC(3,2) NOT NULL,
    profit NUMERIC(10,2) NOT NULL,
    returned_flag INTEGER NOT NULL
);

-- Inserção de dados na tabela fato_sales
INSERT INTO fato_sales (
    order_id,
    product_id,
    customer_id,
    geography_id,
    order_date_id,
    ship_date_id,
    ship_mode,
    quantity,
    sales,
    discount,
    profit,
    returned_flag
)
SELECT
    so.order_id AS order_id,
    p.product_id AS product_id,
    c.customer_id AS customer_id,
    g.geography_id AS geography_id,
    d1.date_id AS order_date_id,
    d2.date_id AS ship_date_id,
    so.ship_mode AS ship_mode,
    so.quantity AS quantity,
    so.sales AS sales,
    so.discount AS discount,
    so.profit AS profit,
    CASE
        WHEN r.order_id IS NOT NULL THEN 1 ELSE 0
    END AS returned_flag
FROM silver_orders so
JOIN dim_products p ON so.product_id = p.product_id
JOIN dim_customers c ON so.customer_id = c.customer_id
JOIN dim_geography g ON so.city = g.city AND so.state = g.state AND so.country = g.country
JOIN dim_date d1 ON so.order_date = d1.full_date
JOIN dim_date d2 ON so.ship_date = d2.full_date
LEFT JOIN silver_returns r ON so.order_id = r.order_id;

-- =====================================================================
-- DEFINIÇÃO DE CONSTRAINTS DE CHAVES ESTRANGEIRAS NA TABELA FATO_SALES
-- =====================================================================

-- Chave estrangeira product_id
ALTER TABLE fato_sales
ADD CONSTRAINT fk_fato_sales_products
FOREIGN KEY (product_id)
REFERENCES dim_products(product_id);

-- Chave estrangeira customer_id
ALTER TABLE fato_sales
ADD CONSTRAINT fk_fato_sales_customers
FOREIGN KEY (customer_id)
REFERENCES dim_customers(customer_id);

-- Chave estrangeira geography_id
ALTER TABLE fato_sales
ADD CONSTRAINT fk_fato_sales_geography
FOREIGN KEY (geography_id)
REFERENCES dim_geography(geography_id);

-- Chave estrangeira order_date_id
ALTER TABLE fato_sales
ADD CONSTRAINT fk_fato_sales_order_date
FOREIGN KEY (order_date_id)
REFERENCES dim_date(date_id);

-- Chave estrangeira ship_date_id
ALTER TABLE fato_sales
ADD CONSTRAINT fk_fato_sales_ship_date
FOREIGN KEY (ship_date_id)
REFERENCES dim_date(date_id);

-- ================================================
-- VALIDAÇÃO DE DADOS PÓS DEFINIÇÃO DE CONSTRAINTS
-- ================================================

-- Verificar se existem órfãos na FK product_id
SELECT
    COUNT(*) FILTER (WHERE p.product_id IS NULL) AS products_orfao
FROM fato_sales f
LEFT JOIN dim_products p
    ON f.product_id = p.product_id;

-- Verificar se existem órfãos na FK customer_id
SELECT
    COUNT(*) FILTER (WHERE c.customer_id IS NULL) AS customers_orfao
FROM fato_sales f
LEFT JOIN dim_customers c
    ON f.customer_id = c.customer_id;

-- Verificar se existem órfãos na FK geography_id
SELECT
    COUNT(*) FILTER (WHERE g.geography_id IS NULL) AS geo_orfao
FROM fato_sales f
LEFT JOIN dim_geography g
    ON f.geography_id = g.geography_id;

-- Verificar se existem órfãos nas FKs order_date_id e ship_date_id
SELECT
    COUNT(*) FILTER (WHERE d1.date_id IS NULL) AS order_date_orfao,
    COUNT(*) FILTER (WHERE d2.date_id IS NULL) AS ship_date_orfao
FROM fato_sales f
LEFT JOIN dim_date d1 ON f.order_date_id = d1.date_id
LEFT JOIN dim_date d2 ON f.ship_date_id = d2.date_id;

-- Validação de volume de dados
SELECT
    (SELECT COUNT(*) FROM silver_orders) AS total_silver,
    (SELECT COUNT(*) FROM fato_sales) AS total_fato; -- Deve retornar o mesmo volume, considerando que o grão foi mantido na tabela fato.

-- Validação de métricas agregadas
SELECT
    SUM(sales) AS silver_sales,
    (SELECT SUM(sales) FROM fato_sales) AS fact_sales
FROM silver_orders;

SELECT
    SUM(quantity) AS silver_quantity,
    (SELECT SUM(quantity) FROM fato_sales) AS fato_quantity
FROM silver_orders;

SELECT
    SUM(profit) AS silver_profit,
    (SELECT SUM(profit) FROM fato_sales) AS fato_profit
FROM silver_orders;

-- Validação da flag 'returned_flag'
SELECT
    returned_flag,
    COUNT(*) AS total_linhas
FROM fato_sales
GROUP BY returned_flag;

SELECT
    COUNT(DISTINCT order_id) AS fato_order_id
FROM fato_sales
WHERE returned_flag = 1;

SELECT
    COUNT(DISTINCT order_id) AS silver_order_id
FROM silver_returns;

-- ===========================================
-- CRIAÇÃO DE ÍNDICES NAS FKS DA TABELA FATO
-- ===========================================

-- Índice na FK product_id
CREATE INDEX idx_fato_sales_product_id
    ON fato_sales(product_id);

-- Índice na FK customer_id
CREATE INDEX idx_fato_sales_customer_id
    ON fato_sales(customer_id);

-- Índice na FK geography_id
CREATE INDEX idx_fato_sales_geography_id
    ON fato_sales(geography_id);

-- Índice na FK order_date_id
CREATE INDEX idx_fato_sales_order_date_id
    ON fato_sales(order_date_id);

-- Índice na FK ship_date_id
CREATE INDEX idx_fato_sales_ship_date_id
    ON fato_sales(ship_date_id);