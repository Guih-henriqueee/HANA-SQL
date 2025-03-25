SELECT
    T0."DocNum" AS "Pedido de Compra(nº)",
    T0."CardName" AS "Fornecedor",
    T0."DocDate" AS "Data de Lançamento do Pedido",
    T0."DocDueDate" AS "Previsão de Pagamento",
    T0."DocTotal" AS "Valor total do pedido",
    T2."SlpName" AS "Vendedor",
    T3."DocDueDate" AS "Data de vencimento da Nota",
    T3."DocDate" AS "Data do Documento",
    T0."U_Tipo_Venc" AS "Tipo de Vencimento",
    T3."Serial" AS "Número da Nota",
    T3."SeriesStr" AS "Serial da nota",
    T3."Comments" AS "Observações da Nota",
    T3."Installmnt" AS "Prestações/Parcelas",
    SUM(T5."LineTotal") AS "Total da Nota"
FROM 
    "OPOR" T0
    LEFT JOIN "OSLP" T2 ON T0."SlpCode" = T2."SlpCode"
    LEFT JOIN "OPCH" T3 ON T0."DocEntry" = T3."DocEntry"
    LEFT JOIN "OVPM" T4 ON T3."DocEntry" = T4."DocEntry"
    LEFT JOIN "PCH1" T5 ON T3."DocEntry" = T5."DocEntry"
WHERE 
    T0."DocDate" > ADD_DAYS(CURRENT_DATE, -182) AND
    T0."CANCELED" = 'N'
GROUP BY
    T0."DocNum",
    T0."CardName",
    T0."DocDate",
    T0."DocDueDate",
    T0."DocTotal",
    T2."SlpName",
    T3."DocDueDate",
    T3."DocDate",
    T0."U_Tipo_Venc",
    T3."Serial",
    T3."SeriesStr",
    T3."Comments",
    T3."Installmnt"
ORDER BY 
    T0."DocDate",
    T0."DocNum";
