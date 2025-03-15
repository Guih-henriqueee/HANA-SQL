SELECT
	 COUNT(*) AS "Teste",
	 T0."DocDate",
	 TO_NVARCHAR(T0."DocDate",
	 'YYYY-MM') as "Mes",
	 T1."ItemCode",
	 T1."Dscription",
	 T9."FirmName",
	 T5."ItmsGrpNam",
	 T0."U_OKS_TipoAnuncio" as "Tipo Anuncio",
	 T0."U_OKS_PrCodeFull" as "FullFilment",
	 SUM(T1."Quantity"),
	 SUM(T1."LineTotal") AS "LineTotal",
	 AVG(T1."PriceBefDi"),
	 (SUM(T1."Quantity") * T7."Price") AS "Total Custo",
	 AVG(T1."PriceBefDi") / CASE WHEN T7."Price" > 0 
THEN T7."Price"
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
	 t1."WhsCode" as "Deposito",
	 NULL AS "Comprador"
FROM "OINV" T0 
INNER JOIN "INV1" T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN "OSLP" T2 ON T0."SlpCode" = T2."SlpCode" 
INNER JOIN "OITM" T4 ON T1."ItemCode" = T4."ItemCode" 
INNER JOIN "OITB" T5 ON T4."ItmsGrpCod" = T5."ItmsGrpCod" 
INNER JOIN "OCTG" T6 ON T0."GroupNum" = T6."GroupNum" 
INNER JOIN "ITM1" T7 ON T4."ItemCode" = T7."ItemCode" 
INNER JOIN "OPLN" T8 ON T7."PriceList" = T8."ListNum" 
INNER JOIN "OMRC" T9 ON T4."FirmCode" = T9."FirmCode" 
INNER JOIN "OCRD" T10 ON T0."CardCode" = T10."CardCode" 
INNER JOIN "INV12" T12 ON T0."DocEntry" = T12."DocEntry" 
LEFT JOIN "NFN1" T13 ON T13."SeqCode" = T0."SeqCode" 
WHERE T0."DocDate" BETWEEN ADD_MONTHS((ADD_YEARS(CURRENT_DATE,
	 -1)),-3)
	AND CURRENT_DATE
AND T1."FreeChrgBP" = 'N' 
 
AND (T0."U_NumPedCan" IS NULL) 
AND (T8."ListNum" = '5') 
AND (T0.CANCELED = 'N')
GROUP BY T0."DocDate",
	 TO_NVARCHAR(T0."DocDate",
	 'YYYY-MM'),
	 T1."ItemCode",
	 T1."Dscription",
	 T9."FirmName",
	 T5."ItmsGrpNam",
	 T0."U_OKS_TipoAnuncio",
	 T0."U_OKS_PrCodeFull",
	 "Total Custo",
	 T2."SlpName",
	 T0."U_OKS_Mlb",
	 T2."U_Loja",
	 Case 
	 	When T0."DocStatus" = 'C' Then 'Fechado' 
		Else 'Aberto' 
	END, 
	T13."SeqName",
	t1."WhsCode