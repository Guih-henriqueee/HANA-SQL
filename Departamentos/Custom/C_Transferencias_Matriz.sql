SELECT 
    T0."DocNum" AS "Nº Documento NS", 
    T0."DocDate" AS "Data Documento NS",
    T0."VATRegNum" AS "CNPJ Origem", 
    T2."Usage" AS "Natureza Operação", 
    SUM(T3."LineTotal") AS "Total Linha", 
    T0."Serial" AS "Nº NF", 
    Z4."CreateDate" AS "Data de Criação NE",
    Z5."CreateDate" AS "Data de Criação DS",
    CAST(T0."Header" AS NVARCHAR(255)) AS "Abertura", 
    CAST(T0."Footer" AS NVARCHAR(255)) AS "Encerramento", 
    Z0."U_NAME" AS "Usuário"
FROM OINV T0 
INNER JOIN INV12 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN OUSG T2 ON T1."MainUsage" = T2."ID" 
INNER JOIN INV1 T3 ON T0."DocEntry" = T3."DocEntry"
INNER JOIN OUSR Z0 ON T0."UserSign" = Z0."USERID"
LEFT JOIN ORIN Z5 ON T0."Serial"  = Z5."Serial" AND (
        (T0."VATRegNum" = '17.642.282/0005-57' AND Z5."CardCode" = 'CLJ001') OR
        (T0."VATRegNum" = '17.642.282/0007-19' AND Z5."CardCode" = 'CLJ001') OR
        (T0."VATRegNum" = '17.642.282/0004-76' AND Z5."CardCode" = 'CLJ001') OR
        (T0."VATRegNum" = '17.642.282/0003-95' AND Z5."CardCode" = 'CLJ001') 
    )
LEFT JOIN OPCH Z4 
    ON T0."Serial" = Z4."Serial"
    AND (
        (T0."VATRegNum" = '17.642.282/0005-57' AND Z4."CardCode" = 'F001577') OR
        (T0."VATRegNum" = '17.642.282/0007-19' AND Z4."CardCode" = 'F002550') OR
        (T0."VATRegNum" = '17.642.282/0004-76' AND Z4."CardCode" = 'F002085') OR
        (T0."VATRegNum" = '17.642.282/0003-95' AND Z4."CardCode" = 'F002550') 
    )
WHERE 
    T0."CardCode" = 'CLJ001' 
    ---AND T0."CANCELED" = 'N'  
    AND T2."ID" = 47 
    AND T0."VATRegNum" IN ('17.642.282/0005-57', '17.642.282/0007-19', '17.642.282/0004-76', '17.642.282/0003-95')  
GROUP BY 
    T0."DocNum", T0."DocDate", T0."VATRegNum", 
    T2."Usage", T0."Serial", Z4."CreateDate",Z5."CreateDate", 
    CAST(T0."Header" AS NVARCHAR(255)), CAST(T0."Footer" AS NVARCHAR(255)),
    Z0."U_NAME"
ORDER BY "Total Linha" DESC;
