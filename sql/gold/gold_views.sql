/* ====================================================================================================
    CAMADA GOLD - VIEWS
    Este arquivo documenta a criação de views, a partir das tabelas que compõem o modelo dimensional
    desenvolvido na camada Gold, para consumo analítico em SQL e no Power BI.
    
    As views serão divididas em três categorias:
    - View base: Nomeada de 'vw_sales_analytics', será a view utilizada para alimentar o Power BI. Ela
    é bastante ampla e envolve todas as métricas e colunas descritivas da base de dados, e sua função é
    servir como base para o Power BI, onde análises mais específicas e interativas serão desenvolvidas
    a partir de funções DAX.
    - Views analíticas: Views específicas que serviram de apoio para análises pontuais no Power BI.
    - Views complementares: Views menos amplas, desenvolvidas exclusivamente neste documento, com foco
    em análises específicas usando SQL.

    - Os detalhes sobre essa etapa podem ser consultados no documento README.md do projeto.
    ==================================================================================================== */

-- Criação da View Base para uso no Power BI
CREATE OR REPLACE VIEW vw_sales_analytics AS
SELECT
    f.fato_sales_id,
    f.order_id,
    d1.full_date AS order_date,
    d2.full_date AS ship_date,
    c.customer_id,
    c.customer_name,
    c.segment,
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    g.country,
    g.region,
    g.state,
    g.city,
    f.ship_mode,
    f.quantity,
    f.sales,
    f.discount,
    f.profit,
    f.returned_flag
FROM fato_sales f
JOIN dim_date d1 ON f.order_date_id = d1.date_id
JOIN dim_date d2 ON f.ship_date_id = d2.date_id
JOIN dim_customers c ON f.customer_id = c.customer_id
JOIN dim_products p ON f.product_id = p.product_id
JOIN dim_geography g ON f.geography_id = g.geography_id;

-- Criação da View Analítica - Análise Geográfica
CREATE OR REPLACE VIEW vw_geo_analytics AS
SELECT
    g.state,
    g.country,
    SUM(f.sales) AS receita_total_estado,
    SUM(f.profit) AS lucro_liquido_estado,
    COUNT(DISTINCT f.order_id) AS total_pedidos_estado,
    CASE
        WHEN SUM(f.profit) < 0 THEN 'Prejuízo'
        WHEN SUM(f.profit) <= 5000 THEN 'Lucro <= R$5.000'
        WHEN SUM(f.profit) <= 15000 THEN 'Lucro <= R$15.000'
    ELSE 'Lucro > R$15.001' END AS faixa_lucro_estado
FROM fato_sales f
JOIN dim_geography g ON f.geography_id = g.geography_id
WHERE f.returned_flag = 0
GROUP BY g.state, g.country;


-- =================================
-- Criação das Views Complementares
-- =================================

-- View KPIs (Receita bruta, lucro total, média de desconto, margem de lucro, ticket médio e taxa de devolução)
CREATE OR REPLACE VIEW vw_sales_kpis AS
SELECT
    ROUND(SUM(sales), 2) AS receita_bruta,
    ROUND(SUM(profit), 2) AS lucro_total,
    ROUND(AVG(discount), 4) AS media_desconto,
    ROUND(SUM(profit) / SUM(sales), 4) AS margem_lucro,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)::NUMERIC AS ticket_medio,
    ROUND(COUNT(DISTINCT CASE WHEN returned_flag = 1 THEN order_id END) / COUNT(DISTINCT order_id)::NUMERIC, 4) AS taxa_devolucao
FROM vw_sales_analytics;

-- View Sales by Category (Total de vendas por categoria)
CREATE OR REPLACE VIEW vw_sales_by_category AS
SELECT
    p.category AS categoria,
    SUM(f.sales) AS total_vendas
FROM fato_sales f
JOIN dim_products p ON f.product_id = p.product_id
GROUP BY p.category;

-- View Sales by Date (Total de vendas por ano e mês)
CREATE OR REPLACE VIEW vw_sales_by_date AS
SELECT
    d.year AS ano,
    d.month AS mes,
    SUM(f.sales) AS total_vendas
FROM fato_sales f
JOIN dim_date d ON f.order_date_id = d.date_id
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

-- View Sales by City (Total de vendas por cidade)
CREATE OR REPLACE VIEW vw_sales_by_city AS
SELECT
    g.city AS cidade,
    SUM(f.sales) AS total_vendas
FROM fato_sales f
JOIN dim_geography g ON f.geography_id = g.geography_id
GROUP BY g.city
ORDER BY total_vendas DESC;
