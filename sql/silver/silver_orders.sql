/* ====================================================================================================
    CAMADA SILVER - ORDERS
    Este arquivo documenta todos os processos que ocorrerão na camada Silver referentes a tabela orders.
    Os processos que serão executados, em ordem:
    
    - Data Profiling: Análise exploratória da tabela bronze_orders, com o intuito de identificar erros,
    inconsistências, duplicidades ou qualquer padrão relevante que impacte na modelagem e tipagem dos
    dados. Nenhuma transformação ou correção ocorre durante o Profiling.
    
    - Definição do Modelo: A partir do Data Profiling, serão definidos os tipos corretos dos dados
    de cada coluna. A modelagem dimensional ocorrerá na camada Gold.
    
    - Criação da Tabela Silver: Criação da tabela da camada Silver, com tipos corretos de dados,
    representando a versão confiável dos dados originais (camada Bronze).

    - Carga e Transformação da Tabela Silver: Inserção de dados da tabela bronze_orders na tabela
    silver_orders, aplicando conversões de tipagem, visto que a tabela bronze segue padrão TEXT para
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

-- Verificar total de linhas da base
SELECT
    COUNT(*) AS total_linhas
FROM bronze_orders;

-- Verificar granularidade da tabela
SELECT
    COUNT(*) AS total_linhas,
    COUNT(DISTINCT "Row ID") AS total_rows,
    COUNT(DISTINCT "Order ID") AS total_pedidos,
    COUNT(DISTINCT "Product ID") AS total_produtos,
    COUNT(DISTINCT "Customer ID") AS total_clientes
FROM bronze_orders; -- Row ID não tem duplicidades.

-- Verificar diferença entre total de linhas e linhas com pedido + produto distintos
SELECT
    COUNT(*) AS total_linhas,
    COUNT(DISTINCT ("Order ID", "Product ID")) AS linhas_pedido_produto,
    COUNT(DISTINCT "Row ID") AS linhas_unicas
FROM bronze_orders; -- grão de linhas de item de pedido (order line / order item). O mesmo pedido pode ter diferentes produtos, e também o mesmo produto mais de uma vez.

-- Verificar se Row ID é sequencial (sem gaps)
SELECT
    MIN("Row ID"),
    MAX("Row ID"),
    COUNT(DISTINCT "Row ID")
FROM bronze_orders;

-- Verificar se campos críticos contém registros nulificados
SELECT
    COUNT(*) FILTER (WHERE "Row ID" IS NULL) AS row_id_nulos,
    COUNT(*) FILTER (WHERE "Order ID" IS NULL) AS order_id_nulos,
    COUNT(*) FILTER (WHERE "Customer ID" IS NULL) AS customer_id_nulos,
    COUNT(*) FILTER (WHERE "Product ID" IS NULL) AS product_id_nulos
FROM bronze_orders;

-- Verificar quantidade de produtos por pedido
SELECT
    "Order ID",
    COUNT(*) AS qtd_produtos
FROM bronze_orders
GROUP BY "Order ID"
ORDER BY qtd_produtos DESC;

-- Verificar integridade do intervalo temporal de datas
SELECT
    MIN(TO_DATE("Order Date", 'DD/MM/YYYY')) AS min_order_date,
    MAX(TO_DATE("Order Date", 'DD/MM/YYYY')) AS max_order_date,
    MIN(TO_DATE("Ship Date", 'DD/MM/YYYY')) AS min_ship_date,
    MAX(TO_DATE("Ship Date", 'DD/MM/YYYY')) AS max_ship_date
FROM bronze_orders;

-- Verificar se existem casos em que a data da entrega antecede a data da compra (Ship Date < Order Date)
SELECT
    COUNT(*) AS datas_invalidas
FROM bronze_orders
WHERE "Ship Date"::date < "Order Date"::date;

-- Verificar se existem datas nulificadas
SELECT
    COUNT(*) FILTER (WHERE "Order Date" IS NULL) AS order_date_nulos,
    COUNT(*) FILTER (WHERE "Ship Date" IS NULL) AS ship_date_nulos
FROM bronze_orders;

-- Verificar se existem datas com formato inválido (Datas que resultarão em NULL após CAST na carga)
SELECT
    COUNT(*) FILTER (WHERE "Order Date" !~ '^\d{2}/\d{2}/\d{4}$') AS order_date_invalido,
    COUNT(*) FILTER (WHERE "Ship Date" !~ '^\d{2}/\d{2}/\d{4}$') AS ship_date_invalido
FROM bronze_orders;

-- Verificar se existem valores nulos em colunas descritivas importantes para modelagem, FKs e joins futuros
SELECT
    COUNT(*) FILTER (WHERE "City" IS NULL) AS city_nulos,
    COUNT(*) FILTER (WHERE "Category" IS NULL) AS category_nulos,
    COUNT(*) FILTER (WHERE "Customer Name" IS NULL) AS customer_name_nulos,
    COUNT(*) FILTER (WHERE "State" IS NULL) AS state_nulos,
    COUNT(*) FILTER (WHERE "Segment" IS NULL) AS segment_nulos,
    COUNT(*) FILTER (WHERE "Ship Mode" IS NULL) AS ship_mode_nulos,
    COUNT(*) FILTER (WHERE "Sub-Category" IS NULL) AS sub_category_nulos,
    COUNT(*) FILTER (WHERE "Product Name" IS NULL) AS product_name_nulos
FROM bronze_orders;

-- Verificar se existem strings vazias em colunas descritivas importantes para modelagem, FKs e joins futuros
SELECT
    COUNT(*) FILTER (WHERE TRIM("City") = '') AS city_vazio,
    COUNT(*) FILTER (WHERE TRIM("Category") = '') AS category_vazio,
    COUNT(*) FILTER (WHERE TRIM("Customer Name") = '') AS customer_name_vazio,
    COUNT(*) FILTER (WHERE TRIM("State") = '') AS state_vazio,
    COUNT(*) FILTER (WHERE TRIM("Segment") = '') AS segment_vazio,
    COUNT(*) FILTER (WHERE TRIM("Ship Mode") = '') AS ship_mode_vazio,
    COUNT(*) FILTER (WHERE TRIM("Sub-Category") = '') AS sub_category_vazio,
    COUNT(*) FILTER (WHERE TRIM("Product Name") = '') AS product_name_vazio
FROM bronze_orders;

-- Verificar se existem anormalidades em comprimento de nomes de categorias descritivas
SELECT
    MAX(LENGTH("City")) AS tamanho_city,
    MAX(LENGTH("Category")) AS tamanho_category,
    MAX(LENGTH("Customer Name")) AS tamanho_customer_name,
    MAX(LENGTH("State")) AS tamanho_state,
    MAX(LENGTH("Segment")) AS tamanho_segment,
    MAX(LENGTH("Ship Mode")) AS tamanho_ship_mode,
    MAX(LENGTH("Sub-Category")) AS tamanho_sub_category,
    MAX(LENGTH("Product Name")) AS tamanho_product_name
FROM bronze_orders;

-- Verificar cardinalidade
SELECT
    COUNT(DISTINCT "City") AS city_distinct,
    COUNT(DISTINCT "Category") AS category_distinct,
    COUNT(DISTINCT "Customer Name") AS customer_name_distinct,
    COUNT(DISTINCT "State") AS state_distinct,
    COUNT(DISTINCT "Segment") AS segment_distinct,
    COUNT(DISTINCT "Ship Mode") AS ship_mode_distinct,
    COUNT(DISTINCT "Sub-Category") AS sub_category_distinct,
    COUNT(DISTINCT "Product Name") AS product_name_distinct
FROM bronze_orders;

-- Verificar se as colunas Sales ou Quantity tem valores negativos, zerados ou nulos
SELECT
    COUNT(*) FILTER (WHERE "Sales" IS NULL) AS sales_nulos,
    COUNT(*) FILTER (WHERE "Sales"::numeric <= 0) AS sales_zerados_ou_negativos,
    COUNT(*) FILTER (WHERE "Quantity" IS NULL) AS quantity_nulos,
    COUNT(*) FILTER (WHERE "Quantity"::numeric <= 0) AS quantity_zerados_ou_negativos
FROM bronze_orders;

-- Verificar se Discount é nulo, negativo ou maior que 1 (Desconto maior que 100%)
SELECT
    COUNT(*) FILTER (WHERE "Discount" IS NULL) AS desconto_nulo,
    COUNT(*) FILTER (WHERE "Discount"::numeric < 0) AS desconto_negativo,
    COUNT(*) FILTER (WHERE ROUND("Discount"::numeric, 2) > 1) AS desconto_maior1
FROM bronze_orders;

-- Verificar se Profit é nulo
SELECT
    COUNT(*) FILTER (WHERE "Profit" IS NULL) AS profit_nulo
FROM bronze_orders;

-- Verificar distribuição de Sales com mínima, máxima, média e mediana
SELECT
    ROUND(MIN("Sales"::numeric), 2) AS min_sales,
    ROUND(MAX("Sales"::numeric), 2) AS max_sales,
    ROUND(AVG("Sales"::numeric), 2) AS media_sales,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Sales"::numeric)::numeric, 2) AS mediana_sales
FROM bronze_orders;

-- Verificar distribuição de Quantity com mínima, máxima, média e mediana
SELECT
    ROUND(MIN("Quantity"::numeric), 2) AS min_quantity,
    ROUND(MAX("Quantity"::numeric), 2) AS max_quantity,
    ROUND(AVG("Quantity"::numeric), 2) AS media_quantity,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Quantity"::numeric)::numeric, 2) AS mediana_quantity
FROM bronze_orders;

-- Verificar distribuição de Discount com mínima, máxima, média e mediana
SELECT
    ROUND(MIN("Discount"::numeric), 2) AS min_discount,
    ROUND(MAX("Discount"::numeric), 2) AS max_discount,
    ROUND(AVG("Discount"::numeric), 2) AS media_discount,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Discount"::numeric)::numeric, 2) AS mediana_discount
FROM bronze_orders;

-- Verificar distribuição de Profit com mínima, máxima, média e mediana
SELECT
    ROUND(MIN("Profit"::numeric), 2) AS min_profit,
    ROUND(MAX("Profit"::numeric), 2) AS max_profit,
    ROUND(AVG("Profit"::numeric), 2) AS media_profit,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Profit"::numeric)::numeric, 2) AS mediana_profit
FROM bronze_orders;

-- Verificar outliers com percentis em Sales
SELECT
    ROUND(MAX("Sales"::numeric), 2) AS max_sales,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY "Sales"::numeric)::numeric, 2) AS top5_sales,
    ROUND(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY "Sales"::numeric)::numeric, 2) AS top1_sales
FROM bronze_orders;

-- Verificar outliers com percentis em Quantity
SELECT
    ROUND(MAX("Quantity"::numeric), 2) AS max_quantity,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY "Quantity"::numeric)::numeric, 2) AS top5_quantity,
    ROUND(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY "Quantity"::numeric)::numeric, 2) AS top1_quantity
FROM bronze_orders;

-- Verificar outliers com percentis em Discount
SELECT
    ROUND(MAX("Discount"::numeric), 2) AS max_discount,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY "Discount"::numeric)::numeric, 2) AS top5_discount,
    ROUND(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY "Discount"::numeric)::numeric, 2) AS top1_discount
FROM bronze_orders;

-- Verificar outliers em Profit
SELECT
    ROUND(MAX("Profit"::numeric), 2) AS max_profit,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY "Profit"::numeric)::numeric, 2) AS top5_profit,
    ROUND(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY "Profit"::numeric)::numeric, 2) AS top1_profit
FROM bronze_orders;

-- ================================
-- CRIAÇÃO DA TABELA SILVER_ORDERS
-- ================================

DROP TABLE IF EXISTS silver_orders;

CREATE TABLE silver_orders (
    row_id          INTEGER,
    order_id        TEXT,
    order_date      DATE,
    ship_date       DATE,
    ship_mode       TEXT,
    customer_id     TEXT,
    customer_name   TEXT,
    segment         TEXT,
    country         TEXT,
    city            TEXT,
    state           TEXT,
    postal_code     TEXT,
    region          TEXT,
    product_id      TEXT,
    category        TEXT,
    sub_category    TEXT,
    product_name    TEXT,
    sales           NUMERIC(10,2),
    quantity        INTEGER,
    discount        NUMERIC(3,2),
    profit          NUMERIC(10,2)
);

-- ==============================
-- CARGA DA TABELA SILVER_ORDERS
-- ==============================

INSERT INTO silver_orders (
    row_id,
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    sales,
    quantity,
    discount,
    profit
)
SELECT
    CAST("Row ID" AS INTEGER),
    CAST("Order ID" AS TEXT),
    CAST("Order Date" AS DATE),
    CAST("Ship Date" AS DATE),
    CAST("Ship Mode" AS TEXT),
    CAST("Customer ID" AS TEXT),
    CAST("Customer Name" AS TEXT),
    CAST("Segment" AS TEXT),
    CAST("Country" AS TEXT),
    CAST("City" AS TEXT),
    CAST("State" AS TEXT),
    CAST("Postal Code" AS TEXT),
    CAST("Region" AS TEXT),
    CAST("Product ID" AS TEXT),
    CAST("Category" AS TEXT),
    CAST("Sub-Category" AS TEXT),
    CAST("Product Name" AS TEXT),
    CAST("Sales" AS NUMERIC(10,2)),
    CAST("Quantity" AS INTEGER),
    CAST("Discount" AS NUMERIC(3,2)),
    CAST("Profit" AS NUMERIC(10,2))
FROM bronze_orders;

-- ==============================
-- VALIDAÇÃO PÓS-CARGA (SILVER)
-- ==============================
-- As queries abaixo asseguram que:
-- a. Nenhum dado foi perdido na carga da tabela Silver
-- b. Nenhum CAST gerou valores nulos inesperados
-- c. As regras de negócio validadas na Bronze permanecem válidas
-- d. Os dados estão aptos para modelagem dimensional na camada Gold

-- Verificar contagem de registros
SELECT
    (SELECT COUNT(*) FROM bronze_orders) AS bronze_count,
    (SELECT COUNT(*) FROM silver_orders) AS silver_count;

-- Verificar NULLs após CAST na tabela Silver para colunas DATE, NUMERIC e INTEGER
SELECT
    COUNT(*) FILTER (WHERE row_id IS NULL) AS row_id_nulo,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS order_date_nulo,
    COUNT(*) FILTER (WHERE ship_date IS NULL) AS ship_date_nulo,
    COUNT(*) FILTER (WHERE sales IS NULL) AS sales_nulo,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS quantity_nulo,
    COUNT(*) FILTER (WHERE discount IS NULL) AS discount_nulo,
    COUNT(*) FILTER (WHERE profit IS NULL) AS profit_nulo
FROM silver_orders;

-- Revalidar regras de negócio adotadas
SELECT
    COUNT(*) FILTER (WHERE sales <= 0) AS sales_invalido,
    COUNT(*) FILTER (WHERE quantity <= 0) AS quantity_invalido,
    COUNT(*) FILTER (WHERE discount < 0 OR discount > 1) AS discount_invalido
FROM silver_orders;

-- Revalidar datas
SELECT
    COUNT(*) FILTER (WHERE ship_date < order_date) AS data_invalida1
FROM silver_orders;

-- Revalidar ranges de colunas numéricas
SELECT
    MIN(sales) AS min_sales,
    MAX(sales) AS max_sales,
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity,
    MIN(discount) AS min_discount,
    MAX(discount) AS max_discount,
    MIN(profit) AS min_profit,
    MAX(profit) AS max_profit
FROM silver_orders;