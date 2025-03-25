SELECT 
    T0."DocNum" AS "Numero do Pedido",
    T0."CardName",
    T2."SlpName",
    T0."DocDate",
    T0."DocTotal",
    T1."DocNum" AS "Nº SAP da Nota",
    T1."Serial" AS "Nota Fiscal",
    SUM(st."LineTotal") AS "Total da nota"
FROM 
    SBO_INPOWER_PROD."ORDR" T0
    LEFT JOIN (
        SELECT 
            "CardCode", 
            "DocEntry", 
            "DocNum", 
            "Serial", 
            ROW_NUMBER() OVER (PARTITION BY "CardCode" ORDER BY "DocDate" DESC) AS "RowNum"
        FROM SBO_INPOWER_PROD."OINV"
    ) T1 ON T0."CardCode" = T1."CardCode" AND T1."RowNum" = 1
    LEFT JOIN SBO_INPOWER_PROD."OSLP" T2 ON T0."SlpCode" = T2."SlpCode"
    LEFT JOIN SBO_INPOWER_PROD."INV1" st ON T1."DocEntry" = st."DocEntry"
WHERE 
    T2."SlpName" LIKE '%SIS%'
    AND T0."CANCELED" = 'N'
GROUP BY 
    T0."DocNum", 
    T0."CardName", 
    T2."SlpName", 
    T0."DocDate", 
    T0."DocTotal", 
    T1."DocNum",
    T1."Serial"
ORDER BY 
    T1."DocNum" DESC;
