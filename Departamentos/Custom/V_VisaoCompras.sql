WITH "VENDAS_90" AS (SELECT 
        "ItemCode", 
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "DocDate" >= ADD_DAYS(CURRENT_DATE, -90)
    GROUP BY "ItemCode"), 
    
--  ################## EXTRAÇÃO FULFILLMENT | 90 DIAS  ##################  
    
    "VENDAS_90_MAGFULL" AS (SELECT 
        "ItemCode", 
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "DocDate" >= ADD_DAYS(CURRENT_DATE, -90) AND "SlpName" = 'Magazine Luiza' AND "FullFilment" = 'Y'
    GROUP BY "ItemCode"), 

    "VENDAS_90_MELIFULLSP" AS (SELECT 
        "ItemCode", 
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "DocDate" >= ADD_DAYS(CURRENT_DATE, -90) AND "SlpName" = 'Mercado Livre' AND "FullFilment" = 'Y'
    GROUP BY "ItemCode"),
    
    "VENDAS_90_MELIFULLMG" AS (SELECT 
        "ItemCode", 
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "DocDate" >= ADD_DAYS(CURRENT_DATE, -90) AND "SlpName" = 'Mercado Livre MG' AND "FullFilment" = 'Y'
    GROUP BY "ItemCode"),
    

    "VENDAS_90_AMZFULL" AS (SELECT 
        "ItemCode", 
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "DocDate" >= ADD_DAYS(CURRENT_DATE, -90) AND "SlpName" = 'Amazon' AND "FullFilment" = 'Y'
    GROUP BY "ItemCode"), 
    
    
    "VENDAS_90_SHPFULL" AS (SELECT 
        "ItemCode", 
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "DocDate" >= ADD_DAYS(CURRENT_DATE, -90) AND "SlpName" = 'Shopee' AND "FullFilment" = 'Y'
    GROUP BY "ItemCode"), 
    
     
    ESTOQUES_FULL AS (
    SELECT "ItemCode",
    "Estoque AMZ FULL" AS "AMZ FULL",
    "OPER.3°ML" AS "MELI SP FULL",
    "Estoque MLFULLMG" AS "MELI MG FULL",
    "Estoque Transito MAG FULL" AS "MAG FULL", 
    "Estoque SHOPEE"  AS "SHP FULL",
    ("Estoque AMZ FULL" + "Estoque MLFULLMG" + "Estoque SHOPEE" + "Estoque Transito MAG FULL" + "OPER.3°ML" ) AS "TOTAL FULL"
    FROM SBO_INPOWER_PROD."View_Estoque_Simplificado"
    
    ),
    --- FALTA INCLUIR ESTOQUE AMAZON TRANSITO!
    ESTOQUES_FULL_TRANSITO AS (
    SELECT "ItemCode", 
    "Estoque Transito FULL AMZ" AS "TRANSITO AMZ",
    "Estoque Transito FULL ML" AS "TRANSITO MELI SP",
    "Estoque Transito FULL ML- MG" AS "TRANSITO MELI MG",
    "Estoque Transito FULL MAG" AS "TRANSITO MAG",
    "Estoque Transito FULL SHOPEE"  AS "TRANSITO SHP",
    ("Estoque Transito FULL AMZ" + "Estoque Transito FULL ML- MG" + "Estoque Transito FULL SHOPEE" + "Estoque Transito FULL MAG" + "Estoque Transito FULL ML") AS "TOTAL TRANSITO"
    FROM SBO_INPOWER_PROD."View_Estoque_Simplificado"
    
    ),

    
--  ################## EXTRAÇÃO FULFILLMENT ##################    
    
    
--  ################## EXTRAÇÃO WMS ##################    
    
    WMS AS (
    
    SELECT "Cód. Item", SUM(V2."Q. Disponível") AS "Disponivel", "Operador" 
     FROM "SBO_INPOWER_PROD"."VisaoOperadorReserva" V2 
     GROUP BY "Cód. Item", "Operador" 
    
    ),
    
--  ################## EXTRAÇÃO WMS ##################    
    
    "VENDAS_30" AS (SELECT 
        "ItemCode", 
        SUM("Quantity") AS "Quantidade_30_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "DocDate" >= ADD_DAYS(CURRENT_DATE, -30)
    GROUP BY "ItemCode"), 
    
    "VENDAS_MES_ATUAL" AS (SELECT 
        "ItemCode", 
        SUM("Quantity") AS "Quantidade_Mes_Atual",
        CASE 
            WHEN SUM("Quantity") > 0 THEN SUM("LineTotal") / SUM("Quantity") 
            ELSE 0 
        END AS "Preço Médio Venda"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "DocDate" BETWEEN ADD_DAYS(ADD_MONTHS(LAST_DAY(ADD_MONTHS(CURRENT_DATE, -1)), 0), 1)
                      AND CURRENT_DATE
    GROUP BY "ItemCode"),
   
    RANKING AS ((
    SELECT "ItemCode",
        MAX(CASE WHEN RN = 1 THEN SalespersonData END) AS "Top Vendedor"
    FROM (
        SELECT "ItemCode",
            CASE 
                WHEN "U_Loja" LIKE 'Mark%' THEN "SlpName" 
                ELSE "U_Loja" 
            END || ' (' || TO_VARCHAR(TO_INTEGER(SUM("Quantity"))) || ')' AS SalespersonData,
            ROW_NUMBER() OVER (
                PARTITION BY "ItemCode" 
                ORDER BY SUM("Quantity") DESC
            ) AS RN
        FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
        WHERE "DocDate" BETWEEN 
            ADD_DAYS(ADD_MONTHS(LAST_DAY(ADD_MONTHS(CURRENT_DATE, -1)), 0), 1)
            AND CURRENT_DATE
        GROUP BY "ItemCode", "U_Loja", "SlpName"
    ) AS sub
    GROUP BY "ItemCode"
)),
    
    BASE AS (
    SELECT 
    T0."Cód. Item",
    UPPER(MAX(T0."Descrição do Item")) AS "Descrição do Item",
    UPPER(MAX(T0."Categoria")) AS "Categoria",
    UPPER(MAX(T0."Fabricante")) AS "Fabricante",
    MAX(T0."Custo") AS "Custo",

    (SELECT SUM(V2."Q. Disponível") 
     FROM "SBO_INPOWER_PROD"."VisaoOperadorReserva" V2 
     WHERE T0."Cód. Item" = V2."Cód. Item") AS "Q. Disponível WMS",

    IFNULL((SELECT SUM(V0."OnHand") 
              FROM "SBO_INPOWER_PROD"."OITW" V0 
              INNER JOIN "SBO_INPOWER_PROD"."OWHS" V1 
              ON V0."WhsCode" = V1."WhsCode" 
              AND V1."U_OKS_DepVendavel" = 'Y' 
              WHERE T0."Cód. Item" = V0."ItemCode"), 0) AS "Quantidade SAP",

    IFNULL(T2."Quantidade_Mes_Atual", 0) AS "Q. Vendas Mês Atual",
    ROUND(IFNULL(T2."Preço Médio Venda", 0),2) AS "Preço Médio Venda do Mês",
    IFNULL(T4."Quantidade_30_Dias", 0) AS "Q Vendas 30 Dias",
    IFNULL(T1."Quantidade_90_Dias", 0) AS "Q. Vendas 90 Dias",

    MAX(T5."Top Vendedor") AS "Top Vendedor mês atual",

    CAST ((SELECT MAX(PCH."DocDate") 
     FROM "SBO_INPOWER_PROD"."PCH1" PCH 
     WHERE PCH."ItemCode" = T0."Cód. Item" 
       AND PCH."Usage" IN ('61', '48', '67')) AS DATE) AS "Data da Última Compra", 
       D0."U_U_INPComprador" AS "Comprador",
       
    IFNULL(F1."Quantidade_90_Dias", 0) AS "V.FULL 90 Dias MAG",
    IFNULL(EF."MAG FULL", 0) AS "ESTQ. MAG FULL",
    IFNULL(EFT."TRANSITO MAG", 0) AS "TRANSITO MAG FULL",
    
    IFNULL(F2."Quantidade_90_Dias", 0) AS "V.FULL 90 Dias MELISP",
    IFNULL(EF."MELI SP FULL", 0) AS "ESTQ. MELI SP FULL",
    IFNULL(EFT."TRANSITO MELI SP", 0) AS "TRANSITO MELI SP FULL",
    
    IFNULL(F3."Quantidade_90_Dias", 0) AS "V.FULL 90 Dias MELIMG",
    IFNULL(EF."MELI MG FULL", 0) AS "ESTQ. MELI MG FULL",
    IFNULL(EFT."TRANSITO MELI MG", 0) AS "TRANSITO MELI MG FULL",
    
    IFNULL(F4."Quantidade_90_Dias", 0) AS "V.FULL 90 Dias AMZ",
    IFNULL(EF."AMZ FULL", 0) AS "ESTQ. AMZ FULL",
    IFNULL(EFT."TRANSITO AMZ", 0) AS "TRANSITO AMZ FULL",
    
    IFNULL(F5."Quantidade_90_Dias", 0) AS "V.FULL 90 Dias SHP",
    IFNULL(EF."SHP FULL", 0) AS "ESTQ. SHP FULL",
    IFNULL(EFT."TRANSITO SHP", 0) AS "TRANSITO SHP FULL",
    
    --- INICIO TOTAIS
    IFNULL(EFT."TOTAL TRANSITO", 0) AS "TOTAL TRANSITO",
    IFNULL(EF."TOTAL FULL", 0) AS "TOTAL FULL",
    --- FIM TOTAIS
    
    IFNULL(B4YOUSP."Disponivel", 0) AS "WMS B4YOU SP",
    IFNULL(B4YOUES."Disponivel", 0) AS  "WMS B4YOU ES",
    IFNULL(PLATINUM."Disponivel", 0) AS "WMS PLATINUM"
    
    
    
    

FROM "SBO_INPOWER_PROD"."VisaoOperadorReserva" T0

LEFT JOIN Vendas_90 T1 ON T0."Cód. Item" = T1."ItemCode"
LEFT  JOIN "SBO_INPOWER_PROD".OITM D0 ON T0."Cód. Item" = D0."ItemCode" 
LEFT JOIN Vendas_30 T4 ON T0."Cód. Item" = T4."ItemCode"
LEFT JOIN Vendas_Mes_Atual T2 ON T0."Cód. Item" = T2."ItemCode"

-- JUNÇÃO FULFILLMENT 
LEFT JOIN VENDAS_90_MAGFULL F1 ON T0."Cód. Item" = F1."ItemCode"
LEFT JOIN VENDAS_90_MELIFULLSP F2 ON T0."Cód. Item" = F2."ItemCode"
LEFT JOIN VENDAS_90_MELIFULLMG F3 ON T0."Cód. Item" = F3."ItemCode"
LEFT JOIN VENDAS_90_AMZFULL F4 ON T0."Cód. Item" = F4."ItemCode"
LEFT JOIN VENDAS_90_SHPFULL F5 ON T0."Cód. Item" = F5."ItemCode"
LEFT JOIN ESTOQUES_FULL EF ON T0."Cód. Item" = EF."ItemCode"
LEFT JOIN ESTOQUES_FULL_TRANSITO EFT ON T0."Cód. Item" = EFT."ItemCode"
-- JUNÇÃO FULFILLMENT 

-- JUNÇÃO WMS
LEFT JOIN WMS B4YOUSP ON T0."Cód. Item" = B4YOUSP."Cód. Item" AND B4YOUSP."Operador" = 'B4YOU'
LEFT JOIN WMS B4YOUES ON T0."Cód. Item" = B4YOUES."Cód. Item" AND B4YOUES."Operador" = 'B4YOU-ES'
LEFT JOIN WMS PLATINUM ON T0."Cód. Item" = PLATINUM."Cód. Item" AND PLATINUM."Operador" = 'PLATINUM'
-- JUNÇÃO WMS
-- RANKING
LEFT JOIN RANKING T5 ON T0."Cód. Item" = T5."ItemCode"
-- RANKING

GROUP BY 
T0."Cód. Item", 
T2."Quantidade_Mes_Atual", 
T2."Preço Médio Venda", 
"Quantidade_30_Dias", 
T1."Quantidade_90_Dias", 
F1."Quantidade_90_Dias", 
F2."Quantidade_90_Dias", 
F3."Quantidade_90_Dias", 
F4."Quantidade_90_Dias",
F5."Quantidade_90_Dias",
EF."MAG FULL",
EF."MELI SP FULL",
EF."MELI MG FULL",
EF."AMZ FULL",
EF."SHP FULL",
EFT."TRANSITO MAG",
EFT."TRANSITO MELI SP",
EFT."TRANSITO MELI MG",
EFT."TRANSITO AMZ",
EFT."TRANSITO SHP",
D0."U_U_INPComprador",
B4YOUSP."Disponivel",
B4YOUES."Disponivel", 
PLATINUM."Disponivel",
EFT."TOTAL TRANSITO",
EF."TOTAL FULL") 

SELECT * FROM BASE;

