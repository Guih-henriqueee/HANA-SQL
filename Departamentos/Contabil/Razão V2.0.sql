WITH NotasFiscais AS (
(
	(
	SELECT 'ORIN' AS "Tabela", "Serial", "ObjType", "TransId"
	FROM  SBO_INPOWER_PROD.ORIN
	
	WHERE "TransId" IS NOT NULL 
	 )
	UNION ALL
	(
		SELECT 'OINV' AS "Tabela", "Serial", "ObjType",  "TransId"
		FROM  SBO_INPOWER_PROD.OINV 
		WHERE "TransId" IS NOT NULL 
	
		)UNION ALL 
		(
		SELECT 'OPCH' AS "Tabela", "Serial", "ObjType",  "TransId"
		FROM  SBO_INPOWER_PROD.OPCH 
		WHERE "TransId" IS NOT NULL 
	
		)
)),
Notas_CP AS (


SELECT 'CP' AS "Type", D0."TransId", COALESCE (D2."TransId",0) AS "IdNota", D1."DocEntry", D1."DocNum", COALESCE (D2."Serial", 0) AS "Serial"

FROM  SBO_INPOWER_PROD.OVPM D0 
	LEFT JOIN SBO_INPOWER_PROD.VPM2 D1 ON D0."DocEntry" = D1."DocNum"
	LEFT JOIN NotasFiscais D2 ON (D1."DocTransId" = D2."TransId" AND D1."InvType" = 18  AND D2."ObjType" = 18) OR (D1."DocTransId" = D2."TransId" AND D1."InvType" = 14 AND D2."ObjType" = 14)
	
	
),
Notas_CR AS (
SELECT 'CR' AS "Type", D1."InvType", D0."TransId", COALESCE (D2."TransId",D1."InvType",0) AS "IdNota", D1."DocEntry", D1."DocNum", COALESCE (D2."Serial", 0) AS "Serial"

FROM  SBO_INPOWER_PROD.ORCT D0 
	LEFT JOIN SBO_INPOWER_PROD.RCT2 D1 ON D0."DocEntry" = D1."DocNum"
	LEFT JOIN NotasFiscais D2 ON (D1."DocTransId" = D2."TransId" AND D1."InvType" = 13  AND D2."ObjType" = 13) OR (D1."DocTransId" = D2."TransId" AND D1."InvType" = 14 AND D2."ObjType" = 14)
	
)	


SELECT 
A."TransId",
CAST ( A."RefDate" AS DATE) AS "Data", 
COALESCE(N1."Serial", N2."Serial", N3."Serial",0) AS "Nota Fiscal",

 CASE
        WHEN A."TransType" = 13  THEN 'NS (A/R Invoice)'
        WHEN A."TransType" = 14  THEN 'DS (A/R Credit Memo)'
        WHEN A."TransType" = 18  THEN 'NE (A/P Invoice)'
        WHEN A."TransType" = 19  THEN 'DE (A/P Credit Memo)'
        WHEN A."TransType" = 30  THEN 'LC (Journal Entry)'
        WHEN A."TransType" = 24  THEN 'CR (Incoming Payment)'
        WHEN A."TransType" = 46  THEN 'CP (Vendor Payment)'
        WHEN A."TransType" = 15  THEN 'EN (Delivery)'
        WHEN A."TransType" = 16  THEN 'Devolução (Returns)'
        WHEN A."TransType" = 20  THEN 'PD (Goods Receipt PO)'
        WHEN A."TransType" = 21  THEN 'DM (Goods Return)'
        WHEN A."TransType" = 67  THEN 'TF'
        WHEN A."TransType" = 202 THEN 'Ordem de Produção'
        ELSE 'Outros Tipos'
    END AS "Tipos", 

B."Segment_0" as "Conta Contabil",
B."Segment_0" as "Nome Conta Contabil", 
IFNULL(D."Segment_0", C."CardCode") as "Contra Partida", 
IFNULL(D."AcctName", C."CardName") as "Nome Contra Partida", 
sum(A."Debit"), 
sum(A."Credit"),
A."LineMemo", A."BPLName", A."VatRegNum"
FROM  SBO_INPOWER_PROD.JDT1 A 
LEFT JOIN Notas_CP N1 ON
    (A."TransType" = 46 AND A."TransId" = N1."TransId" )
    OR  (A."TransType" = 18 AND A."TransId" = N1."IdNota" )
    OR (A."TransType" = 14 AND A."TransId" = N1."IdNota")
LEFT JOIN Notas_CR N2 ON 
    (A."TransType" = 24 AND A."TransId" = N2."TransId" )
LEFT JOIN NotasFiscais N3 ON   
    (A."TransType" = 13 AND A."TransId" = N3."TransId" AND  A."TransId" = N3."TransId") 
    OR (A."TransType" = 14 AND A."TransId" = N3."TransId" AND  A."TransId" = N3."TransId") 
    OR (A."TransType" = 18 AND A."TransId" = N3."TransId" AND  A."TransId" = N3."TransId") 
     
    
    
    
INNER JOIN SBO_INPOWER_PROD.OACT B ON A."Account" = B."AcctCode"
LEFT JOIN SBO_INPOWER_PROD.OCRD C ON A."ContraAct" = C."CardCode"
LEFT JOIN SBO_INPOWER_PROD.OACT D ON A."ContraAct" = D."AcctCode"

WHERE 
	A."RefDate" BETWEEN '20250101' AND '20250331' AND "TransType" = 18
	/*A."TransId" = 11303893  OR (A."BaseRef" = '1036211' AND A."TransType" = 18)*/
GROUP BY B."AcctName", CASE
        WHEN A."TransType" = 13  THEN 'NS (A/R Invoice)'
        WHEN A."TransType" = 14  THEN 'DS (A/R Credit Memo)'
        WHEN A."TransType" = 18  THEN 'NE (A/P Invoice)'
        WHEN A."TransType" = 19  THEN 'DE (A/P Credit Memo)'
        WHEN A."TransType" = 30  THEN 'LC (Journal Entry)'
        WHEN A."TransType" = 24  THEN 'CR (Incoming Payment)'
        WHEN A."TransType" = 46  THEN 'CP (Vendor Payment)'
        WHEN A."TransType" = 15  THEN 'EN (Delivery)'
        WHEN A."TransType" = 16  THEN 'Devolução (Returns)'
        WHEN A."TransType" = 20  THEN 'PD (Goods Receipt PO)'
        WHEN A."TransType" = 21  THEN 'DM (Goods Return)'
        WHEN A."TransType" = 67  THEN 'TF'
        WHEN A."TransType" = 202 THEN 'Ordem de Produção'
        ELSE 'Outros Tipos'
    END, A."TransId", A."RefDate", B."Segment_0", B."Segment_0", IFNULL(D."Segment_0", C."CardCode"), IFNULL(D."AcctName", C."CardName"), A."LineMemo", A."BPLName", A."VatRegNum", COALESCE(N1."Serial", N2."Serial", N3."Serial",0)
   
