
SELECT 
    Distinct (T3."Code")
FROM OINV T0 
    INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry"
    INNER JOIN OSTC T2 ON T1."TaxCode" = T2."Code"
    INNER JOIN OTFC T3 ON T2."TfcId" = T3."AbsId"
WHERE T0."DocDate" >= '20250101'