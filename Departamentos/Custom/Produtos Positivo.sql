SELECT 
    T0."DocNum", 
    T0."DocDate", 
    T1."ItemCode", 
    T3."ItemName", 
    SUM(T1."LineTotal") AS "Valor da Nota", 
    T1."Quantity" AS "Quantidade", 
    T0."Serial" AS "Nota Fiscal", 
    CASE WHEN T0."U_chaveacesso" IS NOT NULL THEN T0."U_chaveacesso" ELSE T7."U_ChaveAcesso" END AS "Chave de acesso", 
    T2."SlpName" AS "Vendedor", 
    NULL AS "CPF" 
FROM SBO_INPOWER_PROD."OINV" T0
INNER JOIN SBO_INPOWER_PROD."INV1" T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN SBO_INPOWER_PROD."OSLP" T2 ON T0."SlpCode" = T2."SlpCode"
INNER JOIN SBO_INPOWER_PROD."OITM" T3 ON T1."ItemCode" = T3."ItemCode"
INNER JOIN SBO_INPOWER_PROD."OITB" T4 ON T3."ItmsGrpCod" = T4."ItmsGrpCod"
INNER JOIN SBO_INPOWER_PROD."OMRC" T5 ON T3."FirmCode" = T5."FirmCode"
LEFT JOIN SBO_INPOWER_PROD."OKS_NFS" T6 ON T0."DocEntry" = T6."DocEntry"
LEFT JOIN SBO_INPOWER_PROD."@SKL25NFE" T7 ON T0."DocEntry" = T7."U_DocEntry"
WHERE 
    (T5."FirmName" LIKE '%Infi%' OR T5."FirmName" LIKE '%VAIO%') 
    AND T4."ItmsGrpNam" IN ('Tablets', 'Celular e Telefone') 
    AND T0."DocDate" >= '20241101'
    AND T0."CANCELED" = 'N' 
    AND T6."Nome Utilização" IN ('VENDAS', 'VENDAS LOJA')
GROUP BY 
    T0."DocNum", 
    T0."DocDate", 
    T1."ItemCode", 
    T3."ItemName", 
    T0."Serial", 
    T0."U_chaveacesso", 
    T7."U_ChaveAcesso",
    T2."SlpName",
    T1."Quantity"
ORDER BY 
    T0."DocNum", 
    T0."DocDate"