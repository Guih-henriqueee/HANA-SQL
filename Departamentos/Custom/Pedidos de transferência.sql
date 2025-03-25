WITH 
-- CTE para calcular as quantidades por pedido e transferência
Quantidades AS (
    SELECT 
        T0."DocNum",
        SUM(T1."Quantity") AS "QuantidadeTotalPedido",
        SUM(T2."Quantity") AS "QuantidadeTotalTransferencia",
        SUM(T1."Quantity" * T1."Price") AS "ValorTotalPedido",
        SUM(T2."Quantity" * T2."Price") AS "ValorTotalTransferencia"
    FROM 
        SBO_INPOWER_PROD."OWTQ" T0
    INNER JOIN
        SBO_INPOWER_PROD."WTQ1" T1 ON T0."DocEntry" = T1."DocEntry"
    LEFT JOIN
        SBO_INPOWER_PROD."WTR1" T2 ON T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine"
    GROUP BY 
        T0."DocNum"
),
-- CTE para calcular as divergências entre pedido e transferência
Divergencias AS (
    SELECT 
        T0."DocNum",
        COALESCE(SUM(T1."Quantity"), 0) - COALESCE(SUM(T2."Quantity"), 0) AS "Divergencia"
    FROM 
        SBO_INPOWER_PROD."OWTQ" T0
    INNER JOIN
        SBO_INPOWER_PROD."WTQ1" T1 ON T0."DocEntry" = T1."DocEntry"
    LEFT JOIN
        SBO_INPOWER_PROD."WTR1" T2 ON T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine"
    GROUP BY 
        T0."DocNum"
)
SELECT DISTINCT
    T0."DocNum" AS "Nº do Pedido",
    T1."ItemCode" AS "Código do item",	--Adicionando itens a query
    T0."DocDate" AS "Data do pedido de Transferência",
    T0."DocDueDate" AS "Data de Agenda",
    T0."ToWhsCode",
    T4."SlpName" AS "Responsável",
    T3."DocNum" AS "Nº da Transferência",
    T3."ToWhsCode" AS "Nome do deposito",
    T3."DocDate" AS "Data de Transferência",
    T0."DocStatus" AS "Status do Documento",
    
    CURRENT_DATE  AS "hoje", 
    
    -- Cálculo dos dias entre a data de agenda e a data atual
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Coluna3", 
    
    -- Validações usando subquery para verificar se o pedido está no passado
    CASE 
        WHEN DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0 
            THEN 1 
            ELSE 0 
    END AS "Valida Passado",
    
    -- Validação da transferência usando subquery
    CASE 
        WHEN T3."DocDate" IS NULL OR T3."DocDate" = '' 
            THEN 1 
            ELSE 0 
    END AS "Coluna4",
    
    -- Subquery para combinar validações de atraso e pendência de transferência
    CASE 
        WHEN DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0 
            THEN 1 
            ELSE 0 
    END
    +
    CASE 
        WHEN T3."DocDate" IS NULL OR T3."DocDate" = '' 
            THEN 1 
            ELSE 0 
    END AS "Atrasado",
    
    -- Quantidade total ajustada para o pedido específico ou soma
    CASE 
        WHEN T0."DocNum" = 1659  
            THEN 300 
            ELSE Q."QuantidadeTotalPedido"
    END AS "Quantidade Total do Pedido2",
    
    -- Cálculo da divergência reutilizando a subquery com COALESCE para substituir NULL por 0
    COALESCE(Q."QuantidadeTotalPedido", 0) - COALESCE(Q."QuantidadeTotalTransferencia", 0) AS "Divergencia",
    
    -- Verificação de divergência usando a CTE
    CASE
        WHEN COALESCE(Q."QuantidadeTotalPedido", 0) - COALESCE(Q."QuantidadeTotalTransferencia", 0) > 0
            THEN 1
            ELSE 0 
    END AS "Pedido Divergente",
    
    -- Outra versão de divergência usando o valor ajustado para pedido 1659, com COALESCE
    COALESCE(
        CASE 
            WHEN T0."DocNum" = 1659  
                THEN 300 
                ELSE Q."QuantidadeTotalPedido"
        END, 0)
    -
    COALESCE(Q."QuantidadeTotalTransferencia", 0) AS "Divergencia2",
    
    -- Verificação de divergência para o pedido 1659 ou geral, com COALESCE
    CASE
        WHEN COALESCE(
                CASE 
                    WHEN T0."DocNum" = 1659  
                        THEN 300 
                        ELSE Q."QuantidadeTotalPedido"
                END, 0)
             -
             COALESCE(Q."QuantidadeTotalTransferencia", 0) > 0
            THEN 1
            ELSE 0 
    END AS "Pedido Divergente2",
    
    -- Utilização da CTE para calcular o valor total dos pedidos
    Q."ValorTotalPedido" AS "Valor do Total Pedido",
    Q."ValorTotalTransferencia" AS "Valor do Total Transferência",
    
    -- Quantidades totais
    Q."QuantidadeTotalPedido" AS "Quantidade Total do Pedido",
    Q."QuantidadeTotalTransferencia" AS "Quantidade Total da Transferência"
    
FROM
    SBO_INPOWER_PROD."OWTQ" T0
INNER JOIN
    SBO_INPOWER_PROD."WTQ1" T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN
    SBO_INPOWER_PROD."WTR1" T2 ON T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine"
LEFT JOIN
    SBO_INPOWER_PROD."OWTR" T3 ON T2."DocEntry" = T3."DocEntry"
INNER JOIN
    SBO_INPOWER_PROD."OSLP" T4 ON T0."SlpCode" = T4."SlpCode"
INNER JOIN 
    Quantidades Q ON T0."DocNum" = Q."DocNum"
INNER JOIN
    Divergencias D ON T0."DocNum" = D."DocNum"
    
WHERE
    T4."SlpName" LIKE '%Logis%' 
    
ORDER BY
    T0."DocNum", T3."DocNum"