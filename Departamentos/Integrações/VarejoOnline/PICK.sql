WITH ITENS_PEDIDOS AS (

	
	SELECT  BASE."DocEntry", count(1) AS "Itens"
	
									
	FROM ORDR DC
	INNER JOIN RDR1 BASE ON BASE."DocEntry" = DC."DocEntry" 
	LEFT JOIN PKL1 PC ON BASE."DocEntry" = PC."OrderEntry" 
	INNER JOIN OSLP SP ON BASE."SlpCode"  = SP."SlpCode"

	WHERE
	BASE."WhsCode" IN ('LJ01RET')
	AND PC."AbsEntry" IS NULL 
	AND DC."DocDate" > ADD_DAYS(CURRENT_DATE, -60)
	
	GROUP BY BASE."DocEntry"
	
)



SELECT 
	'AGUARDANDO PICK' AS "STATUS",
	DC."DocNum",
	UPPER(DC."CardName"),
	UPPER(SP."SlpName"), 
	IT."Itens"
	
	
FROM ORDR DC
INNER JOIN RDR1 BASE ON BASE."DocEntry" = DC."DocEntry" 
LEFT JOIN PKL1 PC ON BASE."DocEntry" = PC."OrderEntry" 
INNER JOIN OSLP SP ON BASE."SlpCode"  = SP."SlpCode"
LEFT JOIN ITENS_PEDIDOS IT ON DC."DocEntry" =  IT."DocEntry"

WHERE
	BASE."WhsCode" IN ('LJ01RET')
	AND PC."AbsEntry" IS NULL 
	AND DC."DocDate" > ADD_DAYS(CURRENT_DATE, -60) 
	AND DC."CANCELED" = 'N'
	--- Incluir campos de estrutura dos pedidos varejo online
    