DO BEGIN
WITH ultimomovimento0 AS (
Select t0."ItemCode", MAX(t0."TransSeq") as "TransSeq"
From OIVL as t0
Group By t0."ItemCode"),

ultimomovimento AS (
Select t0.*, t1."CreateDate", t1."CreateTime"
From ultimomovimento0 as t0
Inner Join OIVL as t1 on t0."TransSeq" = t1."TransSeq"),

saldo AS (
Select T0."ItemCode", SUM((COALESCE(T0."OnHand",0) - COALESCE(T0."IsCommited",0))) as "Saldo", T3."U_OKS_CoreDepId"
,T2."U_CodeConexao"
From OITW as T0
Inner Join "@OKS_CORE_ONF2" T2 ON T0."WhsCode"=T2."U_WhsCode" AND T2."U_CodeConexao" = '001'
INNER JOIN "OWHS" T3 ON T2."U_WhsCode"=T3."WhsCode" 
Group By T0."ItemCode", T3."U_OKS_CoreDepId",T2."U_CodeConexao"),

Produtos AS (
SELECT DISTINCT
	 T0."ItemCode" 					
	,T0."ItemName" 
	,COALESCE(T0."U_OKS_GenDefSKU",'N')						 AS "SkuPadrão?"
	,T0."U_U_SKU"											 AS "DefaultSku"	
	,T0."U_IP_Code"											 AS "DefaultProd"
	,T1."Saldo" AS "OnHand"
	,T1."U_OKS_CoreDepId"									 AS "DepId"
	,T1."U_CodeConexao"
FROM
	"OITM" T0
	INNER JOIN saldo T1 ON T0."ItemCode"=T1."ItemCode"
	LEFT JOIN "@OKS_CORE_INVEN" T4 ON (T0."ItemCode"||'-'||'NAC015714'||'-'||T1."U_OKS_CoreDepId")=T4."Code" AND T4."U_CodeConexao" = '001' AND T1."U_CodeConexao" = T4."U_CodeConexao"
    LEFT JOIN ultimomovimento T5 ON T0."ItemCode"=T5."ItemCode"
    LEFT JOIN  "RDR1" T6 
    INNER JOIN "ORDR" T7 ON T6."DocEntry"=T7."DocEntry"
    					 ON T0."ItemCode"=T6."ItemCode"
						    AND  T7."DocStatus"='O'
    LEFT JOIN  "RDN1" T8 
    INNER JOIN "ORDN" T9 ON T8."DocEntry"=T9."DocEntry"
    					 ON T0."ItemCode"=T8."ItemCode"
 WHERE
 	T0."U_OKS_CoreAtivo"='Y'
	AND T0."SellItem"='Y'
	AND T0."InvntItem"='Y'
	AND T0."validFor"='Y' AND
	((COALESCE(T4."U_UpdateDate",TO_DATE('17000101'))< T5."CreateDate"  OR 
	(COALESCE(T4."U_UpdateDate",TO_DATE('17000101'))= T5."CreateDate" AND COALESCE(T4."U_UpdateTime",0) < IFNULL(T5."CreateTime",0)*100))
	OR --PEDIDO DE VENDA
	(COALESCE(T4."U_UpdateDate",TO_DATE('17000101'))< COALESCE(T7."UpdateDate",T7."CreateDate") OR 
	(COALESCE(T4."U_UpdateDate",TO_DATE('17000101'))= COALESCE(T7."UpdateDate",T7."CreateDate") AND COALESCE(T4."U_UpdateTime",0) < COALESCE(T7."UpdateTS",T7."CreateTS")))
	OR --DEVOLUÇÃO
	(COALESCE(T4."U_UpdateDate",TO_DATE('17000101'))< COALESCE(T9."UpdateDate",T9."CreateDate") OR 
	(COALESCE(T4."U_UpdateDate",TO_DATE('17000101'))= COALESCE(T9."UpdateDate",T9."CreateDate") AND COALESCE(T4."U_UpdateTime",0) < COALESCE(T9."UpdateTS",T9."CreateTS")))
			AND COALESCE(T0."U_OKS_GRD_Marca",'') <> ''
	AND COALESCE(T0."U_OKS_GRD_Categ",'') <> ''
	AND COALESCE(T0."U_OKS_CoreAtivo",'N') = 'Y'
	AND COALESCE(T0."U_OKS_GenDefSKU",'N') = 'Y'
	AND COALESCE(T0."U_OKS_SiteVisible",'N') = 'Y'
	)
	
ORDER BY
	T0."ItemCode"),

Totais AS (
SELECT
	 T0."ItemCode" 					
	,T0."ItemName"
	,T0."DepId"
	,T0."SkuPadrão?"
	,T0."DefaultSku"
	,T0."DefaultProd"
	,SUM(T0."OnHand") AS "OnHand"
	,T0."U_CodeConexao"
FROM
	Produtos T0
GROUP BY
	 T0."ItemCode" 					
	,T0."ItemName"
	,T0."DepId"
	,T0."SkuPadrão?"
	,T0."DefaultSku"
	,T0."DefaultProd"
	,T0."U_CodeConexao"),

Resultado AS (
SELECT
	 T0."ItemCode" 					
	,T0."ItemName"
	,T0."DepId"
	,T0."SkuPadrão?"
	,T0."DefaultSku"
	,T0."DefaultProd"
	,CASE WHEN T0."OnHand" < 0 THEN 0 ELSE T0."OnHand" END AS "OnHand"
FROM
	Totais T0)

SELECT * FROM Resultado
-- WHERE "ItemCode" IN ('NAC015714','NAC015676')
ORDER BY "OnHand" DESC;

END