WITH-- Vendas nos últimos 30 dias




WMS AS (
    SELECT 
        "Cód. Item", 
        SUM(V2."Q. Disponível") AS "Disponivel",
        "Operador" 
    FROM "SBO_INPOWER_PROD"."VisaoOperadorReserva" V2 
    GROUP BY "Cód. Item", "Operador" 
),

VENDAS_30 AS (
    SELECT 
        "ItemCode",
        SUM("Quantity") AS "Quantidade_30_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "DocDate" >= ADD_DAYS(CURRENT_DATE, -30)
    GROUP BY "ItemCode"
),

-- Vendas nos últimos 90 dias
VENDAS_90 AS (
    SELECT 
        "ItemCode",
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "DocDate" >= ADD_DAYS(CURRENT_DATE, -90)
    GROUP BY "ItemCode"
),

-- Vendas nos últimos 90 dias para Amazon FULL
VENDAS_90_AMZFULL AS (
    SELECT 
        "ItemCode",
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "SlpName" = 'AMZ FULL' AND "DocDate" >= ADD_DAYS(CURRENT_DATE, -90)
    GROUP BY "ItemCode"
),

-- Vendas nos últimos 90 dias para Magalu FULL
VENDAS_90_MAGFULL AS (
    SELECT 
        "ItemCode",
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "SlpName" = 'MAG FULL' AND "DocDate" >= ADD_DAYS(CURRENT_DATE, -90)
    GROUP BY "ItemCode"
),

-- Vendas nos últimos 90 dias para Shopee FULL
VENDAS_90_SHPFULL AS (
    SELECT 
        "ItemCode",
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "SlpName" = 'SHP FULL' AND "DocDate" >= ADD_DAYS(CURRENT_DATE, -90)
    GROUP BY "ItemCode"
),

-- Vendas nos últimos 90 dias para Mercado Livre SP FULL
VENDAS_90_MELIFULLSP AS (
    SELECT 
        "ItemCode",
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "SlpName" = 'MELI SP FULL' AND "DocDate" >= ADD_DAYS(CURRENT_DATE, -90)
    GROUP BY "ItemCode"
),

-- Vendas nos últimos 90 dias para Mercado Livre MG FULL
VENDAS_90_MELIFULLMG AS (
    SELECT 
        "ItemCode",
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "SlpName" = 'MELI MG FULL' AND "DocDate" >= ADD_DAYS(CURRENT_DATE, -90)
    GROUP BY "ItemCode"
),

-- Estoques atuais por canal FULL e total consolidado
ESTOQUES_FULL AS (
    SELECT "ItemCode",
        "Estoque AMZ FULL"         AS "AMZ FULL",
        "OPER.3°ML"                AS "MELI SP FULL",
        "Estoque MLFULLMG"         AS "MELI MG FULL",
        "Estoque Transito MAG FULL"AS "MAG FULL",
        "Estoque SHOPEE"           AS "SHP FULL",
        (
            "Estoque AMZ FULL"
            + "Estoque MLFULLMG"
            + "Estoque SHOPEE"
            + "Estoque Transito MAG FULL"
            + "OPER.3°ML"
        ) AS "TOTAL FULL"
    FROM SBO_INPOWER_PROD."View_Estoque_Simplificado"
),

-- Estoques em trânsito por canal FULL e total consolidado
ESTOQUES_FULL_TRANSITO AS (
    SELECT "ItemCode", 
        "Estoque Transito FULL AMZ"    AS "TRANSITO AMZ",
        "Estoque Transito FULL ML"     AS "TRANSITO MELI SP",
        "Estoque Transito FULL ML- MG" AS "TRANSITO MELI MG",
        "Estoque Transito FULL MAG"    AS "TRANSITO MAG",
        "Estoque Transito FULL SHOPEE" AS "TRANSITO SHP",
        (
            "Estoque Transito FULL AMZ"
            + "Estoque Transito FULL ML- MG"
            + "Estoque Transito FULL SHOPEE"
            + "Estoque Transito FULL MAG"
            + "Estoque Transito FULL ML"
        ) AS "TOTAL TRANSITO"
    FROM SBO_INPOWER_PROD."View_Estoque_Simplificado"
),

-- Vendas no mês atual com preço médio
VENDAS_MES_ATUAL AS (
    SELECT 
        "ItemCode", 
        SUM("Quantity") AS "Quantidade_Mes_Atual",
        CASE 
            WHEN SUM("Quantity") > 0 THEN SUM("LineTotal") / SUM("Quantity") 
            ELSE 0 
        END AS "Preco_Medio_Venda"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "DocDate" BETWEEN ADD_DAYS(ADD_MONTHS(LAST_DAY(ADD_MONTHS(CURRENT_DATE, -1)), 0), 1)
                      AND CURRENT_DATE
    GROUP BY "ItemCode"
),

-- Ranking dos top 20 itens mais vendidos no mês atual
RANKING AS (
    SELECT "ItemCode",
        MAX(CASE WHEN RN = 1 THEN SalespersonData END) AS "Top_Vendedor"
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
),

-- Última data de compra e comprador para cada item
DATA_COMPRA_COMPRADOR AS (
    SELECT 
        "ItemCode",
        MAX("DocDate") AS "Data_Ultima_Compra",
        MAX("Buyer") AS "Comprador"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    GROUP BY "ItemCode"
),

-- Bloco principal que consolida os dados
BASE AS (
    SELECT 
        DISTINCT 
            V."Cód. Item"                                       AS "Cód. Item",
            V."Descrição do Item"                               AS "Descrição do Item",
            V."Categoria"                                       AS "Categoria",
            V."Fabricante"                                      AS "Fabricante",
            IT."AvgPrice"                                       AS "Custo",
            
            IFNULL((SELECT SUM(V2."Q. Disponível") 
            FROM "SBO_INPOWER_PROD"."VisaoOperadorReserva" V2 
            WHERE V."Cód. Item" = V2."Cód. Item"), 0)          AS "Q. Disponível WMS",

            IFNULL((SELECT SUM(V0."OnHand") 
            FROM "SBO_INPOWER_PROD"."OITW" V0 
            INNER JOIN "SBO_INPOWER_PROD"."OWHS" V1 
            ON V0."WhsCode" = V1."WhsCode" 
            AND V1."U_OKS_DepVendavel" = 'Y' 
            WHERE V."Cód. Item" = V0."ItemCode"), 0)           AS "Quantidade SAP",

            IFNULL(MES."Quantidade_Mes_Atual", 0)              AS "Q. Vendas Mês Atual",
            IFNULL(MES."Preco_Medio_Venda", 0)                 AS "Preço Médio Venda do Mês",

            IFNULL(DIA30."Quantidade_30_Dias", 0)              AS "Q Vendas 30 Dias",
            IFNULL(DIA90."Quantidade_90_Dias", 0)              AS "Q. Vendas 90 Dias",

            IFNULL(RK."Top_Vendedor", '')                      AS "Top Vendedor mês atual",

            IFNULL(DCC."Data_Ultima_Compra", NULL)             AS "Data da Última Compra",
            IFNULL(DCC."Comprador", '')                        AS "Comprador",

            IFNULL(MAG."Quantidade_90_Dias", 0)                AS "V.FULL 90 Dias MAG",
            IFNULL(EST."MAG FULL", 0)                          AS "ESTQ. MAG FULL",
            IFNULL(ESTT."TRANSITO MAG", 0)                     AS "TRANSITO MAG FULL",

            IFNULL(MELISP."Quantidade_90_Dias", 0)             AS "V.FULL 90 Dias MELISP",
            IFNULL(EST."MELI SP FULL", 0)                      AS "ESTQ. MELI SP FULL",
            IFNULL(ESTT."TRANSITO MELI SP", 0)                 AS "TRANSITO MELI SP FULL",

            IFNULL(MELIMG."Quantidade_90_Dias", 0)             AS "V.FULL 90 Dias MELIMG",
            IFNULL(EST."MELI MG FULL", 0)                      AS "ESTQ. MELI MG FULL",
            IFNULL(ESTT."TRANSITO MELI MG", 0)                 AS "TRANSITO MELI MG FULL",

            IFNULL(AMZ."Quantidade_90_Dias", 0)                AS "V.FULL 90 Dias AMZ",
            IFNULL(EST."AMZ FULL", 0)                          AS "ESTQ. AMZ FULL",
            IFNULL(ESTT."TRANSITO AMZ", 0)                     AS "TRANSITO AMZ FULL",

            IFNULL(SHP."Quantidade_90_Dias", 0)                AS "V.FULL 90 Dias SHP",
            IFNULL(EST."SHP FULL", 0)                          AS "ESTQ. SHP FULL",
            IFNULL(ESTT."TRANSITO SHP", 0)                     AS "TRANSITO SHP FULL",

            IFNULL(ESTT."TOTAL TRANSITO", 0)                   AS "TOTAL TRANSITO",
            IFNULL(EST."TOTAL FULL", 0)                        AS "TOTAL FULL",

            IFNULL(B4YOUSP."Disponivel", 0)                    AS "WMS B4YOU SP",
            IFNULL(B4YOUES."Disponivel", 0)                    AS "WMS B4YOU ES",
            IFNULL(PLATINUM."Disponivel", 0)                   AS "WMS PLATINUM"

    FROM "SBO_INPOWER_PROD"."VisaoOperadorReserva" V

    LEFT JOIN "SBO_INPOWER_PROD"."OITM" IT                      ON V."Cód. Item" = IT."ItemCode"

    LEFT JOIN VENDAS_MES_ATUAL MES                              ON V."Cód. Item" = MES."ItemCode"
    LEFT JOIN VENDAS_30 DIA30                                   ON V."Cód. Item" = DIA30."ItemCode"
    LEFT JOIN VENDAS_90 DIA90                                   ON V."Cód. Item" = DIA90."ItemCode"

    LEFT JOIN VENDAS_90_AMZFULL AMZ                             ON V."Cód. Item" = AMZ."ItemCode"
    LEFT JOIN VENDAS_90_MAGFULL MAG                             ON V."Cód. Item" = MAG."ItemCode"
    LEFT JOIN VENDAS_90_SHPFULL SHP                             ON V."Cód. Item" = SHP."ItemCode"
    LEFT JOIN VENDAS_90_MELIFULLSP MELISP                       ON V."Cód. Item" = MELISP."ItemCode"
    LEFT JOIN VENDAS_90_MELIFULLMG MELIMG                       ON V."Cód. Item" = MELIMG."ItemCode"

    LEFT JOIN ESTOQUES_FULL EST                                 ON V."Cód. Item" = EST."ItemCode"
    LEFT JOIN ESTOQUES_FULL_TRANSITO ESTT                       ON V."Cód. Item" = ESTT."ItemCode"

    LEFT JOIN RANKING RK                                        ON V."Cód. Item" = RK."ItemCode"

    LEFT JOIN DATA_COMPRA_COMPRADOR DCC                         ON V."Cód. Item" = DCC."ItemCode"

    LEFT JOIN WMS B4YOUSP                                       ON V."Cód. Item" = B4YOUSP."Cód. Item" AND B4YOUSP."Operador" = 'B4YOU'
    LEFT JOIN WMS B4YOUES                                       ON V."Cód. Item" = B4YOUES."Cód. Item" AND B4YOUES."Operador" = 'B4YOU-ES'
    LEFT JOIN WMS PLATINUM                                      ON V."Cód. Item" = PLATINUM."Cód. Item" AND PLATINUM."Operador" = 'PLATINUM'
)

-- Resultado final
SELECT BASE.*
        CASE 
                WHEN "ESTQ. MAG FULL"                                   > 0   				        THEN 'MAG Full'
	        WHEN "ESTQ. MELI SP FULL"                               > 0 				        THEN 'MELI SP'
	        WHEN "ESTQ. MELI MG FULL"                               > 0					THEN 'MELI MG'
	        WHEN "ESTQ. AMZ FULL"                                   > 0 					THEN 'AMAZON'
	        WHEN "ESTQ. SHP FULL"                                   > 0 					THEN 'SHOPEE'
	        WHEN "TOTAL FULL"       = 0 AND "TOTAL TRANSITO"        > 0                                     THEN 'Em Transito'
	        ELSE 'Sem FULL'             END "Estoque Full",
	CASE 
                WHEN "TOTAL FULL"                                       > 0                                     THEN 'Sim' 
                ELSE 'Não'                  END "Flag_Em_Transito" 

FROM BASE
	