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
    WHERE "DocDate" >= ADD_DAYS(CURRENT_DATE, - 90)
    GROUP BY "ItemCode"
),

-- Vendas nos últimos 90 dias para Amazon FULL
VENDAS_90_AMZFULL AS (
    SELECT 
        "ItemCode",
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "SlpName" = 'AMZ FULL' AND "DocDate" >= ADD_DAYS(CURRENT_DATE, - 90)
    GROUP BY "ItemCode"
),

-- Vendas nos últimos 90 dias para Magalu FULL
VENDAS_90_MAGFULL AS (
    SELECT 
        "ItemCode",
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "SlpName" = 'MAG FULL' AND "DocDate" >= ADD_DAYS(CURRENT_DATE, - 90)
    GROUP BY "ItemCode"
),

-- Vendas nos últimos 90 dias para Shopee FULL
VENDAS_90_SHPFULL AS (
    SELECT 
        "ItemCode",
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "SlpName" = 'SHP FULL' AND "DocDate" >= ADD_DAYS(CURRENT_DATE, - 90)
    GROUP BY "ItemCode"
),

-- Vendas nos últimos 90 dias para Mercado Livre SP FULL
VENDAS_90_MELIFULLSP AS (
    SELECT 
        "ItemCode",
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "SlpName" = 'MELI SP FULL' AND "DocDate" >= ADD_DAYS(CURRENT_DATE, - 90)
    GROUP BY "ItemCode"
),

-- Vendas nos últimos 90 dias para Mercado Livre MG FULL
VENDAS_90_MELIFULLMG AS (
    SELECT 
        "ItemCode",
        SUM("Quantity") AS "Quantidade_90_Dias"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "SlpName" = 'MELI MG FULL' AND "DocDate" >= ADD_DAYS(CURRENT_DATE, - 90)
    GROUP BY "ItemCode"
),

-- Estoques atuais por canal FULL e total consolidado
ESTOQUES_FULL AS (
    SELECT "ItemCode",
    "Estoque AMZ FULL"                                          AS "AMZ FULL",
    "OPER.3°ML"                                                 AS "MELI SP FULL",
    "Estoque MLFULLMG"                                          AS "MELI MG FULL",
    "Estoque Transito MAG FULL"                                 AS "MAG FULL", 
    "Estoque SHOPEE"                                            AS "SHP FULL",
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
    "Estoque Transito FULL AMZ"                                 AS "TRANSITO AMZ",
    "Estoque Transito FULL ML"                                  AS "TRANSITO MELI SP",
    "Estoque Transito FULL ML- MG"                              AS "TRANSITO MELI MG",
    "Estoque Transito FULL MAG"                                 AS "TRANSITO MAG",
    "Estoque Transito FULL SHOPEE"                              AS "TRANSITO SHP",
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
VENDAS_MES_ATUAL AS (SELECT 
        "ItemCode", 
        SUM("Quantity") AS "Quantidade_Mes_Atual",
        CASE 
            WHEN SUM("Quantity") > 0 THEN SUM("LineTotal") / SUM("Quantity") 
            ELSE 0 
        END AS "Preço Médio Venda"
    FROM "SBO_INPOWER_PROD"."View_Relatorio_Marcos_90"
    WHERE "DocDate" BETWEEN ADD_DAYS(ADD_MONTHS(LAST_DAY(ADD_MONTHS(CURRENT_DATE, -1)), 0), 1)
                      AND CURRENT_DATE
    GROUP BY "ItemCode"
),

-- Ranking dos top 20 itens mais vendidos no mês atual
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
   -- Bloco principal que consolida os dados de vendas, estoques e rankings por ItemCode

BASE AS (
    SELECT 
        DISTINCT 
            V."Cód. Item"                                       AS "Cód. Item",
            V."Descrição do Item"                               AS "Descrição do Item",
            V."Fabricante"                                      AS "Fabricante",
            V."Categoria"                                       AS "Categoria",

            (SELECT SUM(V2."Q. Disponível") 
            FROM "SBO_INPOWER_PROD"."VisaoOperadorReserva" V2 
            WHERE V."Cód. Item" = V2."Cód. Item")              AS "Q. Disponível WMS",

            IFNULL((SELECT SUM(V0."OnHand") 
            FROM "SBO_INPOWER_PROD"."OITW" V0 
            INNER JOIN "SBO_INPOWER_PROD"."OWHS" V1 
            ON V0."WhsCode" = V1."WhsCode" 
            AND V1."U_OKS_DepVendavel" = 'Y' 
            WHERE V."Cód. Item" = V0."ItemCode"), 0)            AS "Quantidade SAP",


            -- Quantidade vendida no mês atual
            IFNULL(MES."Quantidade_Mes_Atual", 0)               AS "QTD Venda Mês Atual",

            -- Quantidade vendida nos últimos 30 e 90 dias
            IFNULL(DIA30."Quantidade_30_Dias", 0)               AS "QTD Venda 30 dias",
            IFNULL(DIA90."Quantidade_90_Dias", 0)               AS "QTD Venda 90 dias",

            -- Quantidade vendida nos últimos 90 dias por canal FULL
            IFNULL(AMZ."Quantidade_90_Dias", 0)                 AS "QTD Venda AMZ FULL 90 dias",
            IFNULL(MAG."Quantidade_90_Dias", 0)                 AS "QTD Venda MAG FULL 90 dias",
            IFNULL(SHP."Quantidade_90_Dias", 0)                 AS "QTD Venda SHP FULL 90 dias",
            IFNULL(MELISP."Quantidade_90_Dias", 0)              AS "QTD Venda MELI SP FULL 90 dias",
            IFNULL(MELIMG."Quantidade_90_Dias", 0)              AS "QTD Venda MELI MG FULL 90 dias",

            -- Quantidade de estoque no WMS
            IFNULL(B4YOUSP."Disponivel", 0)                     AS "WMS B4YOU SP",
            IFNULL(B4YOUES."Disponivel", 0)                     AS "WMS B4YOU ES",
            IFNULL(PLATINUM."Disponivel", 0)                    AS "WMS PLATINUM",

            -- Estoque atual por canal FULL e total consolidado
            IFNULL(EST."AMZ FULL", 0)                           AS "Estoque AMZ FULL",
            IFNULL(EST."MAG FULL", 0)                           AS "Estoque MAG FULL",
            IFNULL(EST."SHP FULL", 0)                           AS "Estoque SHP FULL",
            IFNULL(EST."MELI SP FULL", 0)                       AS "Estoque MELI SP FULL",
            IFNULL(EST."MELI MG FULL", 0)                       AS "Estoque MELI MG FULL",
            IFNULL(EST."TOTAL FULL", 0)                         AS "Estoque TOTAL FULL",

            -- Estoque em trânsito por canal FULL e total consolidado
            IFNULL(ESTT."TRANSITO AMZ", 0)                      AS "TRANSITO AMZ FULL",
            IFNULL(ESTT."TRANSITO MAG", 0)                      AS "TRANSITO MAG FULL",
            IFNULL(ESTT."TRANSITO SHP", 0)                      AS "TRANSITO SHP FULL",
            IFNULL(ESTT."TRANSITO MELI SP", 0)                  AS "TRANSITO MELI SP FULL",
            IFNULL(ESTT."TRANSITO MELI MG", 0)                  AS "TRANSITO MELI MG FULL",
            IFNULL(ESTT."TOTAL TRANSITO", 0)                    AS "TRANSITO TOTAL FULL",

            -- Preço médio de venda
            IFNULL(MES."Preço Médio Venda", 0)                  AS "Preço Médio Venda",

            -- Indicação de top vendedor (ranking)
            IFNULL(RK."Top Vendedor", '')                       AS "Top Vendedor"

    FROM "SBO_INPOWER_PROD"."VisaoOperadorReserva" V

    -- Junção com a tabela de itens
    LEFT JOIN "SBO_INPOWER_PROD"."OITM" IT                      ON V."Cód. Item"   = IT."ItemCode"

    -- Junção com a tabela de vendas do mês atual
    LEFT JOIN VENDAS_MES_ATUAL MES                              ON V."Cód. Item"   = MES."ItemCode"

    -- Junção com vendas dos últimos 30 dias
    LEFT JOIN VENDAS_30 DIA30                                   ON V."Cód. Item"   = DIA30."ItemCode"

    -- Junção com vendas dos últimos 90 dias
    LEFT JOIN VENDAS_90 DIA90                                   ON V."Cód. Item"   = DIA90."ItemCode"

    -- Junções com vendas por canal FULL nos últimos 90 dias
    LEFT JOIN VENDAS_90_AMZFULL AMZ                             ON V."Cód. Item"   = AMZ."ItemCode"
    LEFT JOIN VENDAS_90_MAGFULL MAG                             ON V."Cód. Item"   = MAG."ItemCode"
    LEFT JOIN VENDAS_90_SHPFULL SHP                             ON V."Cód. Item"   = SHP."ItemCode"
    LEFT JOIN VENDAS_90_MELIFULLSP MELISP                       ON V."Cód. Item"   = MELISP."ItemCode"
    LEFT JOIN VENDAS_90_MELIFULLMG MELIMG                       ON V."Cód. Item"   = MELIMG."ItemCode"

    --- Junção com estoque WMS    
    LEFT JOIN WMS B4YOUSP                                       ON V."Cód. Item"   = B4YOUSP."Cód. Item"       AND B4YOUSP."Operador"   = 'B4YOU'
    LEFT JOIN WMS B4YOUES                                       ON V."Cód. Item"   = B4YOUES."Cód. Item"       AND B4YOUES."Operador"   = 'B4YOU-ES'
    LEFT JOIN WMS PLATINUM                                      ON V."Cód. Item"   = PLATINUM."Cód. Item"      AND PLATINUM."Operador"  = 'PLATINUM'

    -- Junção com estoques atuais por canal FULL
    LEFT JOIN ESTOQUES_FULL EST                                 ON V."Cód. Item"   = EST."ItemCode"

    -- Junção com estoques em trânsito por canal FULL
    LEFT JOIN ESTOQUES_FULL_TRANSITO ESTT                       ON V."Cód. Item"   = ESTT."ItemCode"

    -- Junção com ranking de vendas
    LEFT JOIN RANKING RK                                        ON V."Cód. Item"   = RK."ItemCode"
)

-- Resultado final
SELECT * FROM BASE;



