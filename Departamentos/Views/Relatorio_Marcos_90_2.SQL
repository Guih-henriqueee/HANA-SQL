-- SBO_INPOWER_PROD."View_Relatorio_Marcos_90" source

CREATE OR REPLACE VIEW SBO_INPOWER_PROD."View_Relatorio_Marcos_90" AS
SELECT

	 T0."DocNum",
	 T0."DocDate",
	 TO_NVARCHAR(T0."DocDate",
	 'YYYY-MM') as "Mes",
	 --T10."CreateDate",
 T0."CardCode",
	 T0."CardName",
	 T1."ItemCode",
	 T1."Dscription",
	 T12."StateS" as "Estado Cliente",
	 T9."FirmName",
	 T5."ItmsGrpNam",
	 T0."U_OKS_TipoAnuncio" as "Tipo Anuncio",
	 T0."U_OKS_PrCodeFull" as "FullFilment",
	 T1."Quantity",
	 T1."LineTotal",
	 T1."PriceBefDi",
	 CASE
		 WHEN T1."U_INP_CUSTOMANUAL" IS NULL OR T1."U_INP_CUSTOMANUAL" = 0 THEN D1."Price"
	 ELSE T1."U_INP_CUSTOMANUAL" 
		 END
		 AS "Price",
	 T1."PriceBefDi" / CASE WHEN (CASE
		 WHEN T1."U_INP_CUSTOMANUAL" IS NULL OR T1."U_INP_CUSTOMANUAL" = 0 THEN D1."Price"
	 ELSE T1."U_INP_CUSTOMANUAL"
		 END) > 0 
THEN (CASE
		 WHEN T1."U_INP_CUSTOMANUAL" IS NULL OR T1."U_INP_CUSTOMANUAL" = 0 THEN D1."Price"
	 ELSE T1."U_INP_CUSTOMANUAL" 
		 END)
ELSE 1.0 
END AS " Mark- UP",
	 T2."SlpName",
	 T0."U_OKS_Mlb" as "Código MLB",
	 T2."U_Loja",
	 Case When T0."DocStatus" = 'C' 
Then 'Fechado' 
Else 'Aberto' 
End as "Status",
	 T13."SeqName",
	 t1."WhsCode" as "Deposito" 
FROM SBO_INPOWER_PROD."OINV" T0 
INNER JOIN SBO_INPOWER_PROD."INV1" T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN SBO_INPOWER_PROD."OSLP" T2 ON T0."SlpCode" = T2."SlpCode" 
INNER JOIN SBO_INPOWER_PROD."OITM" T4 ON T1."ItemCode" = T4."ItemCode" 
INNER JOIN SBO_INPOWER_PROD."ITM1" D1 ON T1."ItemCode" = D1."ItemCode" AND D1."PriceList" = 5
INNER JOIN SBO_INPOWER_PROD."OITB" T5 ON T4."ItmsGrpCod" = T5."ItmsGrpCod" 
INNER JOIN SBO_INPOWER_PROD."OCTG" T6 ON T0."GroupNum" = T6."GroupNum" 
INNER JOIN SBO_INPOWER_PROD."ITM1" T7 ON T4."ItemCode" = T7."ItemCode" 
INNER JOIN SBO_INPOWER_PROD."OPLN" T8 ON T7."PriceList" = T8."ListNum" 
INNER JOIN SBO_INPOWER_PROD."OMRC" T9 ON T4."FirmCode" = T9."FirmCode" 
INNER JOIN SBO_INPOWER_PROD."OCRD" T10 ON T0."CardCode" = T10."CardCode" 
INNER JOIN SBO_INPOWER_PROD."INV12" T12 ON T0."DocEntry" = T12."DocEntry" 
LEFT JOIN SBO_INPOWER_PROD."NFN1" T13 ON T13."SeqCode" = T0."SeqCode" 
WHERE (TO_DATE(T0."DocDate") BETWEEN ADD_MONTHS((ADD_YEARS(TO_DATE(NOW()),
	 -1)),-3)
	AND TO_DATE(NOW())) 
AND T1."FreeChrgBP" = 'N' --AND (T0."DocStatus" = 'C') 
 
AND (T0."U_NumPedCan" IS NULL) 
AND (T8."ListNum" = '5') 
AND (T0.CANCELED = 'N')

---- ATUALIZAÇÃO 19-03-2025
----- Inclusão de lógica para compor custo, prevendo buraco na indexação da post de Custo Manual
----- Custo gravado na venda

;