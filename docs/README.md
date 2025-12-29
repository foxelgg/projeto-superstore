# Superstore Sales Analysis

## 1. Visão Geral do Projeto

### Contexto do Dataset
O dataset utilizado neste projeto é o "Superstore Sales", disponibilizado no Tableau Public, bastante utilizado para fins educacionais e demonstração de análise de dados. O dataset original se refere a um e-commerce, e conta com 21 colunas e 9.994 linhas. Seus dados são dos tipos: pedidos, clientes, produtos, localidades e devoluções. Os dados foram inseridos no banco de dados através de arquivos CSV.

### Objetivo do Projeto
Este projeto de análise de dados da Superstore Sales tem por objetivo assegurar a qualidade e a consistência dos dados, por meio da aplicação da arquitetura "Medallion Architecture". Após processos que garantem a qualidade dos dados, o projeto foca no desenvolvimento e construção de seu modelo dimensional, adotando o Star Schema, com constraints bem definidas, tornando os dados prontos para consumo em análises SQL e Power BI. 

### O que este Projeto demonstra
O atual projeto demonstra a aplicação das seguintes habilidades:
- Capacidade de estruturação de pipelines analíticos
- Medallion Architecture
- Tomada de decisão sobre qualidade de dados
- Validação pós-carga
- Modelagem dimensional para BI
- Definição de Constraints e Índices
- Views para consumo analítico
- Integração entre SQL e Power BI

## 2. Tecnologias Utilizadas

- PostgreSQL: Banco de dados relacional utilizado durante todas as etapas do projeto: ingestão, tratamento, modelagem e análise de dados.
- VSCode: Ambiente de desenvolvimento, conectado ao PostgreSQL via extensão.
- SQL: Linguagem utilizada para profiling, validação, modelagem dimensional e criação de views analíticas.
- Git/GitHub: Versionamento do código SQL e documentação do projeto.
- Power BI: Ferramenta de visualização utilizada para consumo analítico e construção dos dashboards finais do projeto.

## 3. Arquitetura do Projeto

### Arquitetura
O projeto segue a Medallion Architecture, organizando os dados por camadas, com níveis distintos de refinamento, desde os dados brutos até o consumo analítico final.

### Fluxo
O fluxo de dados do projeto ocorre na seguinte ordem:
Bronze -> Silver -> Gold -> Views Analíticas -> Power BI

### Diagrama da Arquitetura
![Arquitetura do Projeto](docs/diagrams/diagrama-superstore.png)

O diagrama acima representa o fluxo completo dos dados neste projeto.

## 4. Preparação e Qualidade dos Dados (Camadas Bronze & Silver)

### 4.1 Preparação (Camada Bronze)
A camada Bronze recebe os dados brutos, carregados diretamente a partir dos arquivos CSV. Nenhuma alteração estrutural ou de conteúdo é executada nessa camada, sendo ela responsável por armazenar os dados exatamente da maneira como chegaram do dataset, para fins de rastreabilidade e auditoria. Os dados nessa camada foram definidos como tipo TEXT, para garantir que não ocorram erros ou perdas de informação na ingestão.

### 4.2 Qualidade dos Dados (Camada Silver)
A camada Silver é dedicada ao tratamento e validação de dados. Nessa etapa foi realizado o Data Profiling, uma análise exploratória que objetiva encontrar inconsistências, duplicidades ou qualquer padrão que impactasse na tipagem e modelagem dimensional dos dados. Considerando a resposta positiva ao Data Profiling e a reputação do dataset de ser bastante limpo e indicado para estudos, optou-se por não remover ou corrigir registros, e as tabelas Silver foram criadas com a tipagem correta de dados. As justificativas de decisões de qualidade de dados, bem como as regras de qualidade aplicadas, podem ser revisadas no documento 'dq_rules.md'.

### 4.3 Avaliação da Tabela 'silver_people'
Durante o Data Profiling, a tabela 'silver_people', que contém nomes de gerentes e suas respectivas regiões de responsabilidade, foi analisada, e optou-se por não utilizá-la no modelo analítico, visto que a tabela não está diretamente relacionada ao grão da fato, e resultaria na necessidade de alterar o esquema do modelo dimensional para Snowflake, aumentando a complexidade do projeto sem trazer benefício analítico justificável.

### 5. Modelo Analítico (Camada Gold)

### 5.1 Modelagem Dimensional (Camada Gold)
Camada voltada ao consumo analítico. Nela os dados foram modelados dimensionalmente, tendo sido optado o Star Schema, visando facilitar análises e a integração com o Power BI. No modelo dimensional, foram definidas as tabelas fato e dimensões, as chaves primárias (PK) e estrangeiras (FK), as constraints e os índices, com o objetivo de aprimorar a performance das consultas e alinhar o projeto a cenários de análise de negócios.

### 5.2 Tabela Fato
A tabela fato foi criada mantendo o grão do dataset original, identificado no Data Profiling, que é order line, ou seja, linhas de item de pedido. Cada linha representa um item dentro de um pedido. A tabela contém as métricas (quantity, sales, discount, profit), as chaves estrangeiras que se conectam às dimensões (product_id, customer_id, geography_id, order_date_id, ship_date_id), uma chave primária artificial (fato_sales_id), uma degenerate dimension (order_id), uma coluna descritiva (ship_mode - optou-se por manter essa coluna na tabela fato para não criar uma dimensão contendo apenas essa coluna, o que mantém boa organização sem prejuízo analítico) e uma flag (returned_flag - derivada da tabela returns).

### 5.3 Tabelas Dimensão
Colunas descritivas foram utilizadas para criar tabelas de dimensões: produtos, clientes, geografia e data. Essas tabelas recebem valores distintos, e portanto têm seus grãos alterados:
- Dimensão Produtos: Grão de 1 produto por linha.
- Dimensão Clientes: Grão de 1 cliente por linha.
- Dimensão Geografia: Grão de 1 localidade por linha.
- Dimensão Data: Grão de 1 data por linha.
As dimensões serão utilizadas analiticamente em SQL e dentro do Power BI, em conjunto com as métricas da tabela fato.

### 6. Views Analíticas
A partir da camada Gold, foram criadas views analíticas, separadas nas categorias 'view base' e 'views complementares'. O objetivo da view base ('vw_sales_analytics') é servir como base para o Power BI, contendo todos os campos analíticos e descritivos sem agregações. As views complementares, por sua vez, serviram como forma de padronizar métricas e KPIs.

### 7. Visualizações e Análises (Power BI)
Na ferramenta Power BI, os dados da view base foram utilizados para criar métricas e construir os dashboards finais. 

### 8. Conclusão e Próximos Passos
A desenvolver.



