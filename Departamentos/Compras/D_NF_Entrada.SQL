SELECT T0."DocDate", 
    T0."CardCode", 
    T0."CardName", 
    T1."ItemCode",
    T4."Usage"
    T1."Dscription", 
    T3."FirmName", 
    T1."Quantity", 
    T1."Price", 
    T1."LineTotal", 
    T0."DocTotal" 
FROM "SBO_INPOWER_PROD"."OPCH" T0  
INNER JOIN "SBO_INPOWER_PROD"."PCH1" T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN "SBO_INPOWER_PROD"."OITM" T2 ON T2."ItemCode" = T1."ItemCode" 
INNER JOIN "SBO_INPOWER_PROD"."OMRC" T3 ON T2."FirmCode" = T3."FirmCode"
INNER JOIN "SBO_INPOWER_PROD"."PCH12" T4 ON T1."Usage" = T4."MainUsage"
WHERE T1."DocDate" >= ADD_MONTHS(CURRENT_DATE, -12)
    AND T4."Usage" LIKE '%COMPRAS%';