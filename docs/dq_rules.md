# Data Quality Rules - Orders (Camada BRONZE)

## 1. Contexto do Dataset
Esse projeto utiliza o Dataset "Superstore Sales" do Tableau Public, comumente utilizado para fins educacionais e demonstração de análise de dados. É um dataset de pedidos de vendas (orders) com foco para análises financeiras e comerciais. O dataset original conta com 21 colunas e 9.994 linhas.

## 2. Escopo do Data Profiling
A etapa de Data Profiling deste projeto teve como objetivo:
- Identificar granularidade da tabela
- Identificar possíveis chaves primárias e estrangeiras
- Identificar valores nulos, vazios, irregulares ou inválidos
- Validar regras de negócio para métricas
- Avaliar distribuição estatística e colunas numéricas
- Identificar possíveis outliers (valores muito acima do esperado)
- Justificar decisões de manutenção dos dados

## 3. Colunas Descritivas

### 3.1 Validação de nulos e strings vazias
As seguintes colunas descritivas foram analisadas: City, State, Category, Sub-Category, Customer Name, Segment, Ship Mode, Product Name.

Resultado:
- Nenhuma coluna apresentou valores nulos
- Nenhuma coluna apresentou strings vazias.

### 3.2 Comprimento máximo (em caracteres)
| Coluna        | Comprimento Máximo |
| ------        | ------------------ |
| City          | 17                 |
| State         | 20                 |
| Category      | 15                 |
| Sub-Category  | 11                 |
| Segment       | 11                 |
| Ship Mode     | 14                 |
| Customer Name | 22                 |
| Product Name  | 127                |

Resultado:
- Nenhuma coluna apresenta irregularidade em relação ao tamanho em caracteres da maior linha. O comprimento elevado em Product Name é esperado, por se tratar de uma coluna de alta cardinalidade e maior descritibilidade.

### 3.3 Cardinalidade
| Coluna        | Cardinalidade |
| ------        | ------------- |
| City          | 531           |
| State         | 49            |
| Category      | 3             |
| Sub-Category  | 17            |
| Segment       | 3             |
| Ship Mode     | 4             |
| Customer Name | 793           |
| Product Name  | 1850          |

Resultado:
- Essa query exploratória visa evidenciar quais colunas contém maiores valores distintos e quais contém menores. Útil para modelagem de dados, pois ajuda a definir dimensões do star schema e a compreender o volume esperado em cada tabela dimensional.

## 4. Colunas Métricas

### 4.1 Regras de Negócio
Para este projeto, as seguintes regras de negócio quanto à métricas foram adotadas:
- Sales: A coluna 'Sales' representa o valor de venda de determinada quantidade de um determinado item. Considera-se que esse valor não pode ser negativo, pois se refere à uma venda. Embora este valor pudesse ser zerado, considerando a venda de alguma amostra ou brinde, neste dataset foi constatada a inexistência desse fato, ou seja, não há registros com Sales = 0, tornando essa condição inválida neste projeto.
- Quantity: A coluna 'Quantity' se refere a quantidade vendida de determinado item, e portanto deve ser sempre maior que zero. 
- Discount: A coluna 'Discount' representa o desconto concedido na venda de determinado item. É considerado válido qualquer valor entre 0 e 1, sendo 0 quando um item simplesmente não tem desconto aplicado, e 1 quando um item tem desconto de 100%.
- Profit: A coluna 'Profit' se refere ao resultado econômico referente a determinada venda. Este valor pode ser negativo, caso a venda represente prejuízo (loss), positivo, caso a venda represente lucro (profit), ou zerado, caso os custos da venda sejam iguais ao valor de venda do item.

### 4.2 Distribuição Estatística

**SALES**
| Métrica      | Valor    |
| -------      | -----    |
| Min          | 0.44     |
| Max          | 22638.48 |
| Média        | 229.86   |
| Mediana      | 54.49    |
| Percentil 95 | 956.98   |
| Percentil 99 | 2481.69  |

Resultado:
- Analisando a distribuição estatística da coluna Sales, conclui-se que não há anomalia ou qualquer provável erro de negócio. A diferença considerável entre o Top 1% (Percentil 99) e o MAX pode significar que existem uma ou algumas vendas muito grandes registradas, algo comum em dados de vendas, conhecido como cauda longa (concentração maior de vendas pequenas, mas presença de algumas vendas muito grandes).

**QUANTITY**
| Métrica      | Valor |
| ------       | ----- |
| Min          | 1.00  |
| Max          | 14.00 |
| Média        | 3.79  |
| Mediana      | 3.00  |
| Percentil 95 | 8.00  |
| Percentil 99 | 11.00 |

Resultado:
- Analisando a distribuição estatística da coluna Quantity, nenhum valor além do comportamento esperado foi identificado.

**DISCOUNT**
| Métrica      | Valor |
| ------       | ----- |
| Min          | 0.00  |
| Max          | 0.80  |
| Média        | 0.16  |
| Mediana      | 0.20  |
| Percentil 95 | 0.70  |
| Percentil 99 | 0.80  |

Resultado:
- Analisando a distribuição estatística da coluna Discount, nenhuma quebra nas regras adotadas pode ser encontrada. O valor mínimo é 0, ou seja, sem desconto e o máximo é 0.80 (80% de desconto). Valores compatíveis com práticas comerciais comuns.

**PROFIT**
| Métrica      | Valor    |
| ------       | -----    |
| Min          | -6599.98 |
| Max          | 8399.98  |
| Média        | 28.66    |
| Mediana      | 8.67     |
| Percentil 95 | 168.47   |
| Percentil 99 | 580.66   |

Resultado:
- Os valores seguem a premissa da regra de negócio adotada, tendo valores negativos (prejuízos) e valores positivos (lucros). A diferença considerável entre o Top 1% (Percentil 99) e o MAX é plausível e tem comportamento semelhante a 'Sales', o que está de acordo.

## 5. Decisões de Qualidade
- Nenhuma regra de limpeza (DELETE/UPDATE) foi aplicada
- Nenhuma capagem ou winsorização nas colunas numéricas foi aplicada
- Após profiling, todos os dados foram validados e mantidos conforme origem
- As decisões tiveram apoio em regras de negócio e distribuição estatística

## 6. Resumo Executivo
O dataset original é bastante popular, muito usado para estudo e aprendizado, e apresenta excelente qualidade de dados. A qualidade dos dados é comprovada pelas análises executadas durante o Data Profiling que identificariam inconsistências nos dados. Após a finalização da camada Silver, os dados foram considerados aptos para modelagem e análise na camada Gold.

## 7. Tabelas Auxiliares (Returns e People)

### 7.1 Returns
A tabela 'Returns' funciona como uma tabela de lookup de pedidos devolvidos.

- Cada linha representa um pedido retornado.
- A granularidade da tabela é de pedido ('Order ID').
- A coluna 'Order ID' apresenta valores únicos e não nulos.
- Todos os pedidos 'Order ID' da tabela 'Returns' possuem correspondência na tabela 'Orders', garantindo integridade referencial lógica.
- A ausência de registros para um pedido na tabela 'Returns' indica implicitamente que o pedido não foi devolvido. Isso ocorre por que a coluna 'Returned' só trabalha com o valor 'Yes', sem a ocorrência de 'No'.
- A tabela 'Returns' funcionará como uma flag implícita através de LEFT JOINs com a tabela 'Orders'.

### 7.2 People
A tabela 'People' funciona como uma tabela de atribuição organizacional, relacionando regiões (Region) com seus respectivos responsáveis (Person).

- Cada linha representa uma região única associada a uma pessoa única responsável, ou seja, sem duplicidades nas colunas 'Region' e 'Person'.
- A granularidade da tabela é de região.
- Todas os valores presentes na coluna 'region' da tabela 'people' existem no domínio da tabela 'orders' (coluna 'region'), garantindo consistência de domínio.
- A tabela não representa clientes, embora os nomes presentes na coluna 'Person' possam ser encontrados na coluna 'Customer Name' da tabela 'orders'. É apenas uma coincidência que se dá pelo fato do dataset usar nomes fictícios.

