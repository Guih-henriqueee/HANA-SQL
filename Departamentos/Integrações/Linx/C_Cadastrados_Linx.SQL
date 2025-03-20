WITH "Produtos" AS (
SELECT DISTINCT
	 T0."ItemCode" 					
	,T0."ItemName" 
	,COALESCE(T0."U_OKS_GRD_ItGrade",'N') 	AS "ItmGrade"
	,COALESCE(T0."U_OKS_GRD_NrGrade",'') 	AS "NrGrade"
	,COALESCE(T0."validFor",'N') 			AS "Ativo"	
	,T0."U_OKS_GRD_AtribX" 					AS "ItmAtributoX"
	,T0."U_OKS_GRD_AtribY" 					AS "ItmAtributoY"
	,T0."U_OKS_GRD_Marca"					AS "Marca"
	,T0."U_OKS_GRD_Categ"					AS "Categoria"
	,T0."U_OKS_GRD_Produ"					AS "DefinicaoProduto"
	,COALESCE(T0."U_OKS_GenDefSKU",'N')		AS "SkuPadrão?"
	,T0."U_U_SKU"							AS "DefaultSku"	
	,T0."U_IP_Code"							AS "DefaultProd"
	,COALESCE(T0."U_OKS_SiteVisible",'N')	AS "VisivelSite?"
	,COALESCE(T0."SWeight1",0)				AS "Peso"
	,COALESCE(T0."SWidth1",0)				AS "Largura"
	,COALESCE(T0."SHeight1",0)				AS "Altura"
	,COALESCE(T0."SLength1",0)				AS "Profundidade"				
FROM
	"OITM" T0
	INNER JOIN "OMRC" T1 ON T0."FirmCode"= T1."FirmCode"
						    AND T0."U_OKS_CoreAtivo"='Y'
	LEFT JOIN "@OKS_CORE_ITENS" T2 ON T0."ItemCode"=T2."Code"
WHERE
	(COALESCE(T0."UpdateDate",T0."CreateDate")> COALESCE(T2."U_UpdateDate",TO_DATE('17000101'))
	OR  (COALESCE(T0."UpdateDate",T0."CreateDate")= COALESCE(T2."U_UpdateDate",TO_DATE('17000101'))
	     AND COALESCE(T0."UpdateTS",T0."CreateTS",0) >= COALESCE(T2."U_UpdateTime",0)))
	AND T0."SellItem"='Y'
	AND T0."InvntItem"='Y'
	AND T0."validFor"='Y')
	
	
, "ItmGrade" AS(
SELECT
	 T0."ItemCode"
	,T0."ItemName" 
	,T0."NrGrade"
	,T0."Marca"
	,T0."Categoria"
	,T0."DefinicaoProduto"
	,T0."SkuPadrão?"
	,T0."DefaultSku"
	,T0."DefaultProd"
	,T0."VisivelSite?"
	,T1."U_EixoX"
	,T1."U_EixoY"
	,T1."U_CodDescript"
	,T0."Peso"
	,T0."Largura"
	,T0."Altura"
	,T0."Profundidade"
FROM 
	"Produtos" T0
	INNER JOIN "@OKS_GRD_GRDE" T1 
	INNER JOIN "@OKS_GRD_RDE1" T2 ON T1."Code"=T2."Code"				
								  ON T0."NrGrade"=T1."Code"
								  AND T0."ItmGrade"='Y'
								  AND T0."Ativo"='Y')	
								  				
, "Skus" AS(
SELECT
	 T0."ItemCode" 
	,T0."ItemName"
	,T0."NrGrade"
	,T0."Marca"
	,T0."Categoria"
	,T0."DefinicaoProduto"
	,T0."SkuPadrão?"
	,T0."DefaultSku"
	,T0."DefaultProd"
	,T0."VisivelSite?"
	,T1."U_CodDescript" AS "CodGrade"
	,T3."U_CodDescript" AS "GradeX"
	,T3."Name"			AS "GradeDescX"
	,T5."U_CodDescript" AS "GradeY"
	,T5."Name"			AS "GradeDescY"
	,T4."U_CodDescript" AS "AtributoX"
	,T6."U_CodDescript" AS "AtributoY"
	,T0."Peso"
	,T0."Largura"
	,T0."Altura"
	,T0."Profundidade"
FROM 
	"Produtos" T0
	INNER JOIN "@OKS_GRD_GRDE" T1 ON T0."NrGrade"=T1."Code"
			 
  	INNER JOIN "@OKS_GRD_TPGR" T3 
    INNER JOIN "@OKS_GRD_PGR1" T4 ON T3."Code"=T4."Code" 
    							  ON T1."U_EixoX"=T3."Code"	
    							  AND T0."ItmAtributoX"=CAST(T4."LineId" AS NVARCHAR(20))
	INNER JOIN "@OKS_GRD_TPGR" T5 
    INNER JOIN "@OKS_GRD_PGR1" T6 ON T5."Code"=T6."Code" 
    							  ON T1."U_EixoY"=T5."Code"
    							  AND T0."ItmAtributoY"=CAST(T6."LineId" AS NVARCHAR(20)))
    							      							  
, "Result" AS (
--PRODUTOS
SELECT
	 T0."ItemCode" 					
	,T0."ItemName" 
	,T0."Marca"
	,T0."Categoria"
	,T0."DefinicaoProduto"
	,T0."SkuPadrão?"
	,T0."DefaultSku"
	,T0."DefaultProd"
	,T0."VisivelSite?"
	,''	 AS "Sku" 					
	,''	 AS "SkuName"
	,CASE WHEN COALESCE(T1."U_CodDescript",'0')='' THEN '0' ELSE COALESCE(T1."U_CodDescript",'0') END AS "CodGrade"
	,CASE WHEN COALESCE(T3."U_CodDescript",'0')='' THEN '0' ELSE COALESCE(T3."U_CodDescript",'0') END AS "GradeX"
	,T3."Name"			AS "GradeDescX"
	,CASE WHEN COALESCE(T5."U_CodDescript",'0')='' THEN '0' ELSE COALESCE(T5."U_CodDescript",'0') END AS "GradeY"
	,T5."Name"			AS "GradeDescY"
	,''  AS "AtributoX"
	,''  AS "AtributoY"
	,T0."Peso"
	,T0."Largura"
	,T0."Altura"
	,T0."Profundidade"
FROM
	"Produtos" T0
	LEFT JOIN "ItmGrade" T1 
	INNER JOIN "@OKS_GRD_GRDE" T2  ON T1."NrGrade"=T2."Code"
								   ON T0."ItemCode"= T1."ItemCode"
	LEFT JOIN "@OKS_GRD_TPGR" T3
	INNER JOIN "@OKS_GRD_PGR1" T4 ON T3."Code"=T4."Code"
								  ON T2."U_EixoX"=T3."Code"	
	LEFT JOIN "@OKS_GRD_TPGR" T5 
    INNER JOIN "@OKS_GRD_PGR1" T6 ON T5."Code"=T6."Code" 
    							  ON T2."U_EixoY"=T5."Code"  						  
	LEFT JOIN "Skus" T7  ON T0."ItemCode"= T7."ItemCode"
WHERE
	T7."ItemCode" IS NULL
UNION
--GRADE
SELECT
	 T1."ItemCode" 						
	,T1."ItemName" 	
	,T0."Marca"
	,T0."Categoria"
	,T0."DefinicaoProduto"
	,T0."SkuPadrão?"
	,T0."DefaultSku"
	,T0."DefaultProd"
	,T0."VisivelSite?"
	,T0."ItemCode"	    AS "Sku" 					
	,T0."ItemName"	    AS "SkuName"
	,T0."CodGrade"
	,T0."GradeX"
	,T0."GradeDescX"
	,T0."GradeY"
	,T0."GradeDescY"
	,T0."AtributoX"
	,T0."AtributoY"
	,T0."Peso"
	,T0."Largura"
	,T0."Altura"
	,T0."Profundidade"
FROM
	"Skus" T0
	INNER JOIN "OITM" T1 ON T0."NrGrade"=T1."ItemCode"
)

SELECT DISTINCT
	 T0."ItemCode"					
	,T0."ItemName"
	,COALESCE(T0."Marca",'0')		AS "Marca"
	,COALESCE(T0."Categoria",'0')	AS "Categoria"
	,T0."DefinicaoProduto"
	,T0."SkuPadrão?"
	,T0."DefaultSku"
	,T0."DefaultProd"
	,T0."VisivelSite?"
	,CASE WHEN T0."SkuPadrão?" = 'Y'
	      THEN T0."ItemCode" 
	      ELSE T0."Sku" 					
	 END							AS "Sku"
	 ,CASE WHEN T0."SkuPadrão?" = 'Y'
	      THEN T0."ItemName"
	      ELSE T0."SkuName" 					
	 END							AS "SkuName"
	,T0."CodGrade"
	,T0."GradeX"
	,T0."GradeDescX"
	,T0."GradeY"
	,T0."GradeDescY"
	,T0."AtributoX"
	,T0."AtributoY"
	,T0."Peso"
	,T0."Largura"
	,T0."Altura"
	,T0."Profundidade"
FROM 
	"Result" T0
WHERE
	T0."SkuPadrão?" = 'N'
	OR (T0."SkuPadrão?" = 'Y' AND T0."CodGrade"=0)